local FBasePkgHub = class("FBasePkgHub")

function FBasePkgHub:ctor()
    self.protoMap = {}
end

function FBasePkgHub:Pkg2Pb(pkg)
    local name = self.protoMap[pkg.typeName]
    if not name then
        name = self:Pkg2pbName(pkg.typeName)
    end
    pkg._msgName_ = name
    return pkg
end

function FBasePkgHub:Pb2Pkg(pb)
    local pkgTypeName = nil
    for k, v in pairs(self.protoMap) do
        if pb._msgName_ == v then
            pkgTypeName = k
        end
    end

    if pkgTypeName == nil then
        pkgTypeName = self:Pb2pkgName(pb._msgName_)
    end
    
    local pkg = _G[pkgTypeName].Create()
    for k, v in pairs(pkg) do
        pkg[k] = pb[k]
    end
    return pkg
end

function FBasePkgHub:Pb2pkgName(name)
    name = string.gsub(name, "PB", "PKG")
    name = string.gsub(name, "%.", "_")
    return name
end

function FBasePkgHub:Pkg2pbName(name)
    name = string.gsub(name, "PKG", "PB")
    name = string.gsub(name, "_", ".")
    name = string.gsub(name, "Slots%.Client", "Slots_Client")
    name = string.gsub(name, "Client%.Slots", "Client_Slots")
    name = string.gsub(name, "Leave%.Success", "Leave_Success")
    name = string.gsub(name, "Enter%.Success", "Enter_Success")
    return name
end

return FBasePkgHub