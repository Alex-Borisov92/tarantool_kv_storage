-- import
local box     = require('box')
local log     = require('log')
local storage = require('core.storage')
local handler = require('core.handler')
local srv  	  = require('http.server')
local router  = require('http.router')


-- init storage
log.info('creating box-storage...')
box.cfg {
	log_level    = log.INFO,
	log_nonblock = true,
	log_format   = 'plain',
}
local space = box.schema.space.create('kv', {
	field_count   = 2,
	if_not_exists = true,
	format        = { { name = 'key', type = 'string' }, { name = 'value', type = 'any' } }
})
space:create_index('primary', {
	unique        = true,
	if_not_exists = true,
	parts         = { { 'key', 'string' } }
})

-- init kv-storage
log.info('creating kv-storage...')
local kv = storage.new(space)

-- init http-handler
log.info('creating http-handler...')
local hdl  = handler.init(kv)

-- init http-server
local host = '127.0.0.1'
local port = '8080'
local rps_lmt = 2
if #arg > 0 then
	host = arg[1]
end
if #arg > 1 then
	port = arg[2]
end



local function limited_rps(handler, rps_limit)
    return function (req)
        local ts = os.time()
        local rows = request_count_db.get_space():select({req.peer.host, ts})
        if #rows ~= 0 and rows[1][request_count_db.model.cnt] == rps_limit then
            local resp = req:render({text = 'Too Many Requests'})
            resp.status = 429
            return resp
        end
        request_count_db.get_space():upsert({req.peer.host, ts, 1}, {{'+', request_count_db.model.cnt, 1}})
        return handler(req)
    end
end


log.info('creating http-server...')
local server = srv.new(host, port,{ log_requests = true })

local httpd = router.new()
server:set_router(httpd)

httpd:route({ path = '/kv/:id', method = 'GET' }, limited_rps(hdl.get,rps_lmt ))
httpd:route({ path = '/kv/:id', method = 'DELETE' }, limited_rps(hdl.del,rps_lmt))
httpd:route({ path = '/kv/:id', method = 'PUT' }, limited_rps(hdl.put,rps_lmt))
httpd:route({ path = '/kv', method = 'POST' }, limited_rps(hdl.post,rps_lmt))
httpd:hook('after_dispatch', function(req, rsp)
	-- log all correct operations
	log.info(string.format("%s %s %s %s", rsp.status, req.method, req.path, req:read_cached()))
end)
server:start()