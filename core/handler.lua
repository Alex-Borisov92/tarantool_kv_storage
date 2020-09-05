local json    = require('json')
local af      = require('core.af')
--local hist 	  = require('core.hist')


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
---@param d table
---@return table
function Handler.rsp(status, d)
	return {
		status = status,
		body   = json.encode({['action'] = d}), --TODO reformat response
	}
end

--- Get value
---@param req table
---@return table
function Handler.get(req)
	local event_info = pcall(req.json, req)
	local scoring = pcall(af.scoring(event_info))
	local value = Handler.kv:get(req:stash('id'))
	if value == nil then
		return Handler.rsp(404)
	end
	return Handler.rsp(200, scoring)
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
	local ok, event_info = pcall(req.json, req)
	local scoring = pcall(af.scoring(event_info))
	if not ok then
		Handler.rsp(400)
	end
	if event_info['value'] == nil then
		return Handler.rsp(400)
	end
	local value = Handler.kv:set(req:stash('id'), event_info['value'])
	if value == nil then
		return Handler.rsp(404)
	end
	return Handler.rsp(200, scoring)
end

--- Post event_info
---@param req table
---@return table
function Handler.post(req)
	local ok, event_info = pcall(req.json, req)
	--local history_info = hist.compute(event_info)
	--local event_info = table.insert(event_info, history_info)
	local scoring = af.scoring(event_info)
	if not ok then
		return Handler.rsp(400)
	end
	if event_info['key'] == nil or event_info['value'] == nil then
		return Handler.rsp(400)
	end
	local ok = Handler.kv:add(event_info['key'], event_info['value'])
	if not ok then
		return Handler.rsp(409)
	end
	return Handler.rsp(200, scoring)
end

return Handler