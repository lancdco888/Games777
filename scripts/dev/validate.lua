#!/usr/bin/env lua5.1
-- Headless smoke tests for Games777 Lua modules (no Cocos2d-x native runtime).

local mock = require("scripts.dev.mock_cocos")
local workspace = mock.workspace

local passed = 0
local failed = 0

local function ok(name)
    passed = passed + 1
    print("[PASS] " .. name)
end

local function fail(name, err)
    failed = failed + 1
    io.stderr:write("[FAIL] " .. name .. ": " .. tostring(err) .. "\n")
end

local function assert_eq(name, got, expected)
    if got == expected then
        ok(name)
    else
        fail(name, string.format("expected %s, got %s", tostring(expected), tostring(got)))
    end
end

-- 1. BuildConfig.json loads and decodes
do
    local path = workspace .. "/bootstrap/src/BuildConfig.json"
    local f = io.open(path, "r")
    if not f then
        fail("BuildConfig.json exists", "file not found")
    else
        local raw = f:read("*a")
        f:close()
        local json = require("json")
        BuildConfig = json.decode(raw)
        if type(BuildConfig) == "table" and BuildConfig.PKG_NAME then
            ok("BuildConfig.json decodes")
            assert_eq("BuildConfig.PKG_NAME", BuildConfig.PKG_NAME, "com.Games777.ow")
        else
            fail("BuildConfig.json decodes", "invalid table")
        end
    end
end

-- 2. ApkCfg domain_to_config_param mapping
do
    local ApkCfg = require("bootstrap.src.ApkCfg")
    local apk = ApkCfg.new()
    local sample = {
        login_ip = "127.0.0.1",
        port = 21000,
        login_download_url = "https://cdn.example.com/assets/",
        default_language = "en",
        desc = "test",
        region = "US",
        language = "en,zh",
        class = "1",
    }
    local param = apk:domain_to_config_param(sample)
    assert_eq("ApkCfg.loginIp", param.loginIp, "127.0.0.1")
    assert_eq("ApkCfg.port", param.port, 21000)
    assert_eq("ApkCfg.IsGoogle", param.IsGoogle, true)
    assert_eq("ApkCfg.Language[1]", param.Language[1], "en")
end

-- 3. Pure utility: utils.get_parent_dir
do
    local utils = require("bootstrap.src.utils")
    assert_eq(
        "utils.get_parent_dir",
        utils.get_parent_dir("/tmp/download/apk.cfg"),
        "/tmp/download/"
    )
end

-- 4. JSON patch: invalid JSON returns nil instead of throwing
do
    require("bootstrap.src.json_patch")
    local json = require("json")
    assert_eq("json_patch invalid decode", json.decode("{not json}"), nil)
end

-- 5. Cocos functions.lua: class() and string.split
do
    local TestClass = class("TestClass")
    function TestClass:ctor(v) self.v = v end
    local inst = TestClass.new(42)
    assert_eq("class() constructor", inst.v, 42)
    assert_eq("string.split", string.split("a,b,c", ",")[2], "b")
end

-- 6. Module inventory: count .lua files under workspace
do
    local handle = io.popen('find "' .. workspace .. '" -name "*.lua" | wc -l')
    local count = tonumber(handle:read("*a"))
    handle:close()
    if count and count > 900 then
        ok("Lua module inventory (" .. count .. " files)")
    else
        fail("Lua module inventory", "expected 900+ lua files, got " .. tostring(count))
    end
end

print("")
print(string.format("Results: %d passed, %d failed", passed, failed))
os.exit(failed > 0 and 1 or 0)
