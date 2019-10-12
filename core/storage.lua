---@class KVStorage
---@field protected space table
local KVStorage   = {}
KVStorage.__index = KVStorage

---@class temp_storage
---@field protected space table
local temp_storage   = {}
temp_storage.__index = temp_storage

setmetatable(KVStorage, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})

setmetatable(temp_storage, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})



--- Create new instance
---@param space table
---@return KVStorage
function KVStorage.new(space)
	local self = setmetatable({}, KVStorage)
	self.space = space
	return self
end

--- Create new TEMP instance
---@param space table
---@return temp_storage
function temp_storage.new_t(space)
	local self = setmetatable({}, temp_storage)
	self.space = space
	return self
end


--- Add value
---@param key string
---@param val any
---@return void
function KVStorage:add(key, val)
	return pcall(self.space.insert, self.space, { key, val })
end

--- Set value
---@param key string
---@param val any
---@return void
function KVStorage:set(key, val)
	return self.space:update(key, { { '=', 2, val } })
end

--- Get value
---@param key string
---@return any
function KVStorage:get(key)
	local tuple = self.space:get(key)
	if tuple == nil then
		return nil
	end
	return tuple[2]
end

--- Drop value
---@param key string
---@return void
function KVStorage:drop(key)
	return self.space:delete(key)
end

return KVStorage