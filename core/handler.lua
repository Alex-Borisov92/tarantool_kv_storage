local json    		= require('json')
local af      		= require('core.af')
local uuid    		= require('uuid')
local hist 	  		= require('core.hist')
local box 	  		= require('box')
local os 	  		= require('os')
local log 	  		= require('log')
local utils   		= require('core.utils')
local emaker 		= require('core.eventmaker')
local sql 			= require('core.sql_router')

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
function Handler.rsp(status, data)
	----POST
	if status == 200 then
		return
			{
			status = status,
			body   = json.encode({['action'] 	= data.scoring.action,
								  ['reasons'] 	= data.scoring.reasons,
								  ['_id']		= data._id,
								  ['_t']		= data.t

			}),
		}
	else
		return { --TODO write structure for other statuses
			status = status,
			--body   = json.encode({['action'] = data}),
		}
	end
end

--- Get value
---@param req table
---@return table
function Handler.get(req)
	local value = Handler.kv:get(req:stash('id'))
	if value == nil then
		return Handler.rsp(404)
	end
	return Handler.rsp(203) --TODO don't forget to write docs about changes
end

--- Del value
---@param req table
---@return table
function Handler.del(req)
	local value = Handler.kv:drop(req:stash('id'))
	if value == nil then
		return Handler.rsp(404)
	end
	return Handler.rsp(202) --TODO don't forget to write docs about changes
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
	return Handler.rsp(201, scoring) --TODO don't forget to write docs about changes
end

--- Post event_info
---@param req table
---@return table
function Handler.post(req)
	local ok, src = pcall(req.json, req)

	if not ok then
		return Handler.rsp(400)
	end

	if src['value'] == nil then
		return Handler.rsp(400)
	end

	local event = emaker.make_post(src)
	local scoring = af.make_scoring(event)
	event.scoring = scoring
	local add = Handler.kv:add(event._id, event) --TODO change local variable?

	if not add then
		return Handler.rsp(409)
	end

	if add then
		sql.sql_post(event)
	end

	return Handler.rsp(200, event)
end

return Handler