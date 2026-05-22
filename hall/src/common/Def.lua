Def = Def or {}

--国家区别：1.缅甸 2.马来西亚 3.新加坡 4.印度尼西亚 9.泰国 10.缅甸5
function Def.Reload(region, language)
    Def = {}

	--移除老的Def
	for name,mod in pairs(package.loaded) do
		if string.find(name, "hall.src.common.Def") ~= nil then
			package.loaded[name] = nil
		end
	end

    --加载公共配置
    require("hall.src.common.Def.Common")
    --加载语言相关配置
    require("hall.src.common.Def.Language.language")
    --加载地区相关配置
    
    local ok = pcall(
        function()
            require("hall.src.common.Def.Region." .. ConfigParam.Region)
        end
    )
    if not ok then
        require("hall.src.common.Def.Region.en")
    end
end

Def.Reload()
