local chunkFile = cc.FileUtils:getInstance():fullPathForFilename("src/packagelua/src.chunk.zip")
if LoadChunksFromZIP and chunkFile ~= "" then
    LoadChunksFromZIP(chunkFile)
    print("Loading Chunk:" .. chunkFile)
end

require("packagelua.src.PackageEntry")
