param([int]$ListenPort = 17901)

$ErrorActionPreference = 'Stop'
$guid = '258EAFA5-E914-47DA-95CA-C5AB0DC85B11'
$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, $ListenPort)
$listener.Start()
$ListenPort = ([System.Net.IPEndPoint]$listener.LocalEndpoint).Port
Write-Host "goserver bridge listening on ws://127.0.0.1:$ListenPort"

function Read-Exact([System.Net.Sockets.NetworkStream]$stream, [int]$count) {
    $buffer = New-Object byte[] $count
    $filled = 0
    while ($filled -lt $count) {
        $read = $stream.Read($buffer, $filled, $count - $filled)
        if ($read -le 0) { return $null }
        $filled += $read
    }
    return $buffer
}

function Write-Locked([System.Net.Sockets.NetworkStream]$stream, [byte[]]$bytes) {
    [System.Threading.Monitor]::Enter($stream)
    try {
        $stream.Write($bytes, 0, $bytes.Length)
        $stream.Flush()
    } finally {
        [System.Threading.Monitor]::Exit($stream)
    }
}

function Get-FrameLength([byte[]]$buffer) {
    if ($buffer.Length -lt 2) { return -1 }
    $bits = $buffer[1] -band 0x7f
    $start = 2
    $length = [int]$bits
    if ($bits -eq 126) {
        if ($buffer.Length -lt 4) { return -1 }
        $length = (($buffer[2] -band 0xff) -shl 8) -bor ($buffer[3] -band 0xff)
        $start = 4
    } elseif ($bits -eq 127) {
        if ($buffer.Length -lt 10) { return -1 }
        $length = 0
        for ($i = 2; $i -lt 10; $i++) { $length = ($length * 256) + ($buffer[$i] -band 0xff) }
        $start = 10
    }
    if ($length -gt 2000000) { return -2 }
    $masked = ($buffer[1] -band 0x80) -ne 0
    return $start + $(if ($masked) { 4 } else { 0 }) + $length
}

function Decode-Frame([byte[]]$buffer) {
    $opcode = $buffer[0] -band 0x0f
    $bits = $buffer[1] -band 0x7f
    $start = 2
    $length = [int]$bits
    if ($bits -eq 126) {
        $length = (($buffer[2] -band 0xff) -shl 8) -bor ($buffer[3] -band 0xff)
        $start = 4
    } elseif ($bits -eq 127) {
        $length = 0
        for ($i = 2; $i -lt 10; $i++) { $length = ($length * 256) + ($buffer[$i] -band 0xff) }
        $start = 10
    }
    $masked = ($buffer[1] -band 0x80) -ne 0
    $offset = $start + $(if ($masked) { 4 } else { 0 })
    $payload = New-Object byte[] $length
    if ($length -gt 0) { [Array]::Copy($buffer, $offset, $payload, 0, $length) }
    if ($masked) {
        for ($i = 0; $i -lt $length; $i++) {
            $payload[$i] = [byte]($payload[$i] -bxor $buffer[$start + ($i -band 3)])
        }
    }
    return @{ opcode = $opcode; payload = $payload }
}

function Encode-Frame([int]$opcode, [byte[]]$payload) {
    $length = $payload.Length
    if ($length -lt 126) {
        $header = New-Object byte[] 2
        $header[1] = [byte]$length
    } elseif ($length -lt 65536) {
        $header = New-Object byte[] 4
        $header[1] = 126
        $header[2] = [byte](($length -shr 8) -band 0xff)
        $header[3] = [byte]($length -band 0xff)
    } else {
        $header = New-Object byte[] 10
        $header[1] = 127
        $rest = [int64]$length
        for ($i = 9; $i -ge 2; $i--) {
            $header[$i] = [byte]($rest -band 0xff)
            $rest = $rest -shr 8
        }
    }
    $header[0] = [byte](0x80 -bor $opcode)
    $frame = New-Object byte[] ($header.Length + $length)
    [Array]::Copy($header, 0, $frame, 0, $header.Length)
    if ($length -gt 0) { [Array]::Copy($payload, 0, $frame, $header.Length, $length) }
    return $frame
}

function Send-Text([System.Net.Sockets.NetworkStream]$stream, [string]$text) {
    Write-Locked $stream (Encode-Frame 0x1 ([System.Text.Encoding]::UTF8.GetBytes($text)))
}

function Accept-Upgrade([System.Net.Sockets.NetworkStream]$stream, [string]$header) {
    $match = [regex]::Match($header, 'Sec-WebSocket-Key:\s*(.+)', 'IgnoreCase')
    if (-not $match.Success -or $header -notmatch 'Upgrade:\s*websocket') {
        Write-Locked $stream ([System.Text.Encoding]::ASCII.GetBytes("HTTP/1.1 400 Bad Request`r`nConnection: close`r`n`r`n"))
        return $false
    }
    $key = $match.Groups[1].Value.Trim()
    $sha = [System.Security.Cryptography.SHA1]::Create()
    try {
        $accept = [Convert]::ToBase64String($sha.ComputeHash([System.Text.Encoding]::ASCII.GetBytes($key + $guid)))
    } finally {
        $sha.Dispose()
    }
    $response = "HTTP/1.1 101 Switching Protocols`r`nUpgrade: websocket`r`nConnection: Upgrade`r`nSec-WebSocket-Accept: $accept`r`n`r`n"
    Write-Locked $stream ([System.Text.Encoding]::ASCII.GetBytes($response))
    return $true
}

function Read-WsFrame([System.Net.Sockets.NetworkStream]$stream) {
    $cache = New-Object System.Collections.Generic.List[byte]
    while ($true) {
        $need = if ($cache.Count -lt 2) { -1 } else { Get-FrameLength $cache.ToArray() }
        if ($need -eq -2) { throw 'frame too large' }
        if ($need -ge 2 -and $cache.Count -ge $need) { return Decode-Frame $cache.ToArray() }
        $more = Read-Exact $stream 1
        if ($null -eq $more) { return $null }
        $cache.Add($more[0])
    }
}

function Start-RemotePump([System.Net.Sockets.NetworkStream]$remote, [System.Net.Sockets.NetworkStream]$browser) {
    $worker = [powershell]::Create()
    [void]$worker.AddScript({
        param($remote, $browser)
        function Encode-Frame([int]$opcode, [byte[]]$payload) {
            $length = $payload.Length
            if ($length -lt 126) {
                $header = New-Object byte[] 2
                $header[1] = [byte]$length
            } elseif ($length -lt 65536) {
                $header = New-Object byte[] 4
                $header[1] = 126
                $header[2] = [byte](($length -shr 8) -band 0xff)
                $header[3] = [byte]($length -band 0xff)
            } else {
                $header = New-Object byte[] 10
                $header[1] = 127
                $rest = [int64]$length
                for ($i = 9; $i -ge 2; $i--) {
                    $header[$i] = [byte]($rest -band 0xff)
                    $rest = $rest -shr 8
                }
            }
            $header[0] = [byte](0x80 -bor $opcode)
            $frame = New-Object byte[] ($header.Length + $length)
            [Array]::Copy($header, 0, $frame, 0, $header.Length)
            if ($length -gt 0) { [Array]::Copy($payload, 0, $frame, $header.Length, $length) }
            return $frame
        }
        try {
            $buffer = New-Object byte[] 8192
            while ($true) {
                $count = $remote.Read($buffer, 0, $buffer.Length)
                if ($count -le 0) { break }
                $slice = New-Object byte[] $count
                [Array]::Copy($buffer, $slice, $count)
                $encoded = Encode-Frame 0x2 $slice
                [System.Threading.Monitor]::Enter($browser)
                try {
                    $browser.Write($encoded, 0, $encoded.Length)
                    $browser.Flush()
                } finally {
                    [System.Threading.Monitor]::Exit($browser)
                }
            }
        } catch {
        }
    })
    [void]$worker.AddArgument($remote)
    [void]$worker.AddArgument($browser)
    $worker.BeginInvoke() | Out-Null
    return $worker
}

try {
    while ($true) {
        $client = $listener.AcceptTcpClient()
        $client.NoDelay = $true
        Write-Host "preview connected"
        $stream = $client.GetStream()
        $tcp = $null
        $worker = $null
        try {
            $header = New-Object System.Collections.Generic.List[byte]
            while ($header.Count -lt 4 -or -not ($header[$header.Count - 4] -eq 13 -and $header[$header.Count - 3] -eq 10 -and $header[$header.Count - 2] -eq 13 -and $header[$header.Count - 1] -eq 10)) {
                $one = Read-Exact $stream 1
                if ($null -eq $one) { throw 'header closed' }
                $header.Add($one[0])
                if ($header.Count -gt 8192) { throw 'header too large' }
            }
            if (-not (Accept-Upgrade $stream ([System.Text.Encoding]::ASCII.GetString($header.ToArray())))) {
                Write-Host "websocket upgrade failed"
                continue
            }
            Write-Host "websocket ready"
            $remote = $null
            while ($client.Connected) {
                $message = Read-WsFrame $stream
                if ($null -eq $message) { break }
                if ($message.opcode -eq 0x8) {
                    Write-Locked $stream (Encode-Frame 0x8 ([byte[]]@()))
                    break
                }
                if ($message.opcode -eq 0x9) {
                    Write-Locked $stream (Encode-Frame 0xA $message.payload)
                    continue
                }
                if ($message.opcode -eq 0x1 -and $null -eq $tcp) {
                    try {
                        $request = [System.Text.Encoding]::UTF8.GetString($message.payload) | ConvertFrom-Json
                        Write-Host "dial $($request.host):$($request.port)"
                        $tcp = New-Object System.Net.Sockets.TcpClient
                        $tcp.NoDelay = $true
                        $tcp.Connect([string]$request.host, [int]$request.port)
                        $remote = $tcp.GetStream()
                        Write-Host "tcp open $($request.host):$($request.port)"
                        Send-Text $stream '{"ok":true}'
                        $worker = Start-RemotePump $remote $stream
                    } catch {
                        Write-Host "tcp failed: $($_.Exception.Message)"
                        Send-Text $stream ("{`"ok`":false,`"error`":`"连不上 $($request.host):$($request.port)`"}")
                        break
                    }
                    continue
                }
                if ($message.opcode -eq 0x2 -and $null -ne $remote) {
                    $remote.Write($message.payload, 0, $message.payload.Length)
                    $remote.Flush()
                }
            }
        } catch {
            Write-Host "bridge error: $($_.Exception.Message)"
            try { Send-Text $stream "{`"ok`":false,`"error`":`"$($_.Exception.Message)`"}" } catch {}
        } finally {
            Write-Host "preview closed"
            if ($tcp) { $tcp.Close() }
            if ($worker) { $worker.Stop(); $worker.Dispose() }
            $client.Close()
        }
    }
} finally {
    $listener.Stop()
}
