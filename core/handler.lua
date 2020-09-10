local json    = require('json')
local af      = require('core.af')
local uuid    = require('uuid')
local hist 	  = require('core.hist')
local box 	  = require('box')
local os 	  = require('os')


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
function Handler.post(req) --todo bad impelementation. need to write separate module for SQL?
	local function add_to_sql_bd(id, card,amount,t,extid) --todo dynamic aggrs? what about data mapping?
		if card and amount and extid and t and id then
			print('Data in sql bd has been added.')
			return box.execute("INSERT INTO main VALUES ("..id..", "..extid ..", "..t..","..card..","..amount ..")") -- first prototype. TODO rewrite

		end
	end
	local ok, event_info = pcall(req.json, req)


	event_info.t = os.time()
	event_info._id = uuid.str()

	local history_info = hist.compute(event_info)
	local event_info = table.insert(event_info, history_info)

	local scoring = af.scoring(event_info)
	if not ok then
		return Handler.rsp(400)
	end
	if event_info['value'] == nil then
		return Handler.rsp(400)
	end
	local ok = Handler.kv:add(event_info.id, event_info['value'])
	if not ok then
		return Handler.rsp(409)
	end
	if ok then
		add_to_sql_bd(event_info.id, event_info.value.card,event_info.value.amount,event_info.t, event_info.value.extid)
	else
		return error('Adding data to SQL table has been failed')
	end


	return Handler.rsp(200, scoring)
end

return Handler