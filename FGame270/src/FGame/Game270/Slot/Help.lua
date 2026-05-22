local Defined = import("..Cfgs.Defined")
local cls = {}

function cls.SetJpNumberTransform(render, IsBigSymbol)
    if render.text == nil then
        return
    end
    local len = #render.text

    local conf = nil
    if IsBigSymbol then
        conf = Defined.JPNumberTransform.symbol_big[len]
    else
        conf = Defined.JPNumberTransform.symbol[len]
    end


    if conf.scale then
        if type(conf.scale) == "table" then
            if conf.scale.x then
                render.scaleX = conf.scale.x
            end
            if conf.scale.y then
                render.scaleY = conf.scale.y
            end
        elseif type(conf.scale) == "number" then
            render.scaleX = conf.scale
            render.scaleY = conf.scale
        end
    end

    if conf.position then
        if type(conf.position) == "table" then
            if conf.position.x then
                render.x = conf.position.x
            end
            if conf.position.y then
                render.y = conf.position.y
            end
        end
    end

    if conf.size then
        if type(conf.size) == "table" then
            if conf.size.height then
                render.height = conf.size.height
            end
            if conf.size.width then
                render.width = conf.size.width
            end
        end
    end
end

return cls
