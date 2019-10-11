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

if #arg > 0 then
	host = arg[1]
end
if #arg > 1 then
	port = arg[2]
end



log.info('creating http-server...')
local server = srv.new(host, port,{ log_requests = true })

local httpd = router.new()
server:set_router(httpd)

httpd:route({ path = '/kv/:id', method = 'GET' },hdl.get)
httpd:route({ path = '/kv/:id', method = 'DELETE' }, hdl.del,rps_lmt)
httpd:route({ path = '/kv/:id', method = 'PUT' }, hdl.put)
httpd:route({ path = '/kv', method = 'POST' },hdl.post,2)
httpd:hook('after_dispatch', function(req, rsp)
	-- log all correct operations
	log.info(string.format("%s %s %s %s", rsp.status, req.method, req.path, req:read_cached()))
end)
server:start()