local json    = require('json')

---@class Handler
---@field protected kv KVStorage
local Handler = {
	kv = nil,
}

--- Init handler
---@param kv KVStorage
---@return Handler
function Handler.init(kv)
	Handler.kv = kv
	return Handler
end

--- Build http response
---@private
---@param status int
---@param body table
---@return table
function Handler.rsp(status, body)
	return {
		status = status,
		body   = body,
	}
end

--- Get value
---@param req table
---@return table
function Handler.get(req)
	local value = Handler.kv:get(req:stash('id'))
	if value == nil then
		return Handler.rsp(404)
	end
	return Handler.rsp(200, json.encode(value))
end

--- Del value
---@param req table
---@return table
function Handler.del(req)
	local value = Handler.kv:drop(req:stash('id'))
	if value == nil then
		return Handler.rsp(404)
	end
	return Handler.rsp(200)
end

--- Put value
---@param req table
---@return table
function Handler.put(req)
	local ok, data = pcall(req.json, req)
	if not ok then
		Handler.rsp(400)
	end
	if data['value'] == nil then
		return Handler.rsp(400)
	end
	local value = Handler.kv:set(req:stash('id'), data['value'])
	if value == nil then
		return Handler.rsp(404)
	end
	return Handler.rsp(200)
end

--- Post data
---@param req table
---@return table
function Handler.post(req)
	local ok, data = pcall(req.json, req)
	if not ok then
		return Handler.rsp(400)
	end
	if data['key'] == nil or data['value'] == nil then
		return Handler.rsp(400)
	end
	local ok = Handler.kv:add(data['key'], data['value'])
	if not ok then
		return Handler.rsp(409)
	end
	return Handler.rsp(200)
end

return Handler