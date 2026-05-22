
--保存类类型的虚表
local _class = {}

-- @brief lua面向对象定义class
function Class(classname, super)
	assert(type(classname) == "string" and #classname > 0)
	-- 生成一个类类型
	local class_type = {}
	
	-- 在创建对象的时候自动调用
	class_type.ctor = false
	class_type.__delete = false
	class_type.__cname = classname
	
	class_type.super = super
	class_type.New = function(...)
		-- 生成一个类对象
		local obj = {}
		obj._class_type = class_type
		-- 在初始化之前注册基类方法
		setmetatable(obj, { 
			__index = _class[class_type],
		})
		-- 调用初始化方法
		do
			local create
			create = function(c, ...)
				if c.super then
					create(c.super, ...)
				end
				if c.ctor then
					c.ctor(obj, ...)
				end
			end

			create(class_type, ...)
		end

		-- 注册一个delete方法
		obj.Delete = function(self)
			local now_super = self._class_type 
			while now_super ~= nil do	
				if now_super.__delete then
					now_super.__delete(self)
				end
				now_super = now_super.super
			end

			ClassTracker:LeakRemove(self)
		end

		obj.StopClassTracking = function(self)
			ClassTracker:LeakRemove(self)			
		end

		ClassTracker:LeakAdd(obj)

		return obj
	end

	local vtbl = {}
	_class[class_type] = vtbl
 
	setmetatable(class_type, {
		__newindex = function(t,k,v)
			vtbl[k] = v
		end
		, 
		--For call parent method
		__index = vtbl,
	})
 
	if super then
		setmetatable(vtbl, {
			__index = function(t,k)
				local ret = _class[super][k]
				--do not do accept, make hot update work right!
				--vtbl[k] = ret
				return ret
			end
		})
	end
 
	return class_type
end


-- @example
-- local A = Class("A")
-- function A:ctor(...) print("A-> ctor", ...) end
-- function A:__delete() print("A-> __delete") end

-- local B = Class("B", A)
-- function B:ctor(...) print("B-> ctor", ...) end
-- function B:__delete() print("B-> __delete") end

-- local C = Class("C", B)
-- function C:ctor(...) print("C-> ctor", ...) end
-- function C:__delete() print("C-> __delete") end

-- local c = C.New(10, 20, 30)
-- c:Delete()

-- -- output
-- -- A-> ctor  10  20  30
-- -- B-> ctor  10  20  30
-- -- C-> ctor  10  20  30
-- -- C-> __delete
-- -- B-> __delete
-- -- A-> __delete
