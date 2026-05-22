-- config/pathway.lua
local root = ...

local unpack = unpack or table.unpack
local pathways = {}
local groups = {}

local maker = root:CreatePathwayMaker(0, 0)

local InitPathway = function()
    --root:ClearPathwayCache()
    local needPush = root:PathwayCacheIsNull()
    --print("needPush:", needPush)
    local jsonText = root:LoadText("config/pathway.json")
    --print("json:" .. jsonText)
    local data = FF_G.Json.decode(jsonText)
    local index = 0
    for i, line in ipairs(data.lines) do
        --print('name:' .. line.name)
        local lineInfo = {}
        -- 索引
        pathways[i] = lineInfo
        -- 名字
        pathways[line.name] = lineInfo
        if needPush then
            local params = {}
            table.insert(params, line.isLoop == true)
            for _, point in ipairs(line.points) do
                table.insert(params, point.x)
                table.insert(params, point.y)
                table.insert(params, point.tension)
                table.insert(params, point.numSegments)
            end
            local pathway = maker.MakeCurve(unpack(params))
            --line.curve = pathway
            root:PushPathway(pathway)
        end
        lineInfo.cacheIndex = index
        index = index + 1
    end
    for _, group in ipairs(data.groups) do
        local pathways = {}
        for _, idx in ipairs(group.lineIndexs) do
            table.insert(pathways, idx)
        end
        groups[group.name] = pathways
    end
end

-- 通过名字获取鱼线
-- name: 鱼线名
local GetPathwayIndexByName = function(name)
    local pathway = pathways[name]
    if pathway == nil then
        print("Can't find pathway:" .. name)
        return
    end
    return pathway.cacheIndex
end

local GetPathwayIndexByIndex = function(index)
    local pathway = pathways[index]
    if pathway == nil then
        print("Can't find pathway:" .. index)
        return
    end
    return pathway.cacheIndex
end

local GetPathwayNamesByGroup = function(groupName)
    local group = groups[groupName]
    if group == nil then
        print("Can't find group:" .. groupName)
        return
    end
    return group
end

-- 随机获取指定组中的鱼线
-- groupName: 组名
local GetPathwayIndexByGroup = function(groupName)
    local group = groups[groupName]
    if group == nil then
        print("Can't find group:" .. group)
        return
    end
    local len = #group
    local rand = root:NextInt()
    local index = (rand % len) + 1
    print("GetPathwayIndexByGroup:", rand, " ", index, " ", len)
    return GetPathwayIndexByName(group[index])
end

InitPathway()
FF_G.PathwayHelper = {
    GetPathwayIndexByIndex = GetPathwayIndexByIndex,
    GetPathwayIndexByName = GetPathwayIndexByName,
    GetPathwayIndexByGroup = GetPathwayIndexByGroup,
    GetPathwayNamesByGroup = GetPathwayNamesByGroup,
}
