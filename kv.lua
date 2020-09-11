-- import
local box           = require('box')
local log           = require('log')
local storage       = require('core.storage')
local handler       = require('core.handler')
local srv  	        = require('http.server')
local router        = require('http.router')
local os 	        = require('os')
local utils         = require('core.utils')

-- init storage
log.info('creating box-storage...')
box.cfg {
	log_level    = log.INFO,
	--log_nonblock = true, TODO investigate why this parameter has been outdated
	log_format   = 'plain',
}

local space = box.schema.space.create('kv', {
	field_count   = 1,
	if_not_exists = true,
	format        = {
	{ name = 'value', type = 'any' }, --TODO custom data mapping?
	--{ name = 'card', type = 'string' },
    --{ name = 'amount', type = 'integer' },
    --{ name = 't', type = 'integer' },
    }
})
--TODO investigate - how to inicializate SQL storage correctly?
box.execute("CREATE TABLE main1 (_id VARCHAR(100), extid VARCHAR(10), t INT, card VARCHAR(100), amount INT,PRIMARY KEY (t, card))")

--local statement = "SELECT COUNT("..h[_id]..") FROM main WHERE card=="..h.value.card.."and t>="..tostring((h.t - 60*60*24))
--local statement = 'SELECT * FROM main'
--local sql_out = box.execute(statement) -- TODO document?
--[[ sql_out - structure
table=metadata
table=1
name    EXTID
type    string
table=2
name    T
type    integer
table=3
name    CARD
type    string
table=4
name    AMOUNT
type    integer
table=rows
]]




space:create_index('primary', {
	unique        = true,
	if_not_exists = true,
	parts         = { { 'key', 'string' } }
})




-- init kv-storage
log.info('creating kv-storage...')
local kv = storage.new(space)

-- init temp-storage
log.info('creating temp-storage...')


-- init http-handler
log.info('creating http-handler...')
local hdl  = handler.init(kv)

-- init http-server
local host = '*'
local port = '8081'
local rps_lmt = 100
if #arg > 0 then
	host = arg[1]
end
if #arg > 1 then
	port = arg[2]
end

function kv.get_space()
    return box.space[kv.space_name]
end



-- Model storing requests count for ip and ts
local request_count = {
    space_name = 'request_count',
    model = {
        ip = 1,
        ts = 2,
        cnt = 3,
    },
}

test_scheme = box.schema.space.create(request_count.space_name, {
    if_not_exists = true,
    temporary = true,
})
test_scheme:create_index('primary', {
    type = 'hash',
    parts = {request_count.model.ip, 'string', request_count.model.ts, 'unsigned'},
    if_not_exists = true,
})




function limited_rps(handler, rps_limit)
    return function (req)
        local ts = os.time()
        local rows = box.space[request_count.space_name]:select({req:peer()['host'], ts})
        if #rows ~= 0 and rows[1][request_count.model.cnt] == rps_limit then
            local resp = req:render({text = 'Too Many Requests'})
            resp.status = 429
            return resp
        end
        box.space[request_count.space_name]:upsert({req:peer()['host'], ts, 1}, {{'+', request_count.model.cnt, 1}})
        return handler(req)
    end
end
log.info('creating http-server...')
local server = srv.new(host, port,{ log_requests = true })

local httpd = router.new()
server:set_router(httpd)

httpd:route({ path = '/kv/:id', method = 'GET' }, limited_rps(hdl.get,rps_lmt))
httpd:route({ path = '/kv/:id', method = 'DELETE' }, limited_rps(hdl.del,rps_lmt))
httpd:route({ path = '/kv/:id', method = 'PUT' },limited_rps(hdl.put,rps_lmt))
httpd:route({ path = '/kv', method = 'POST' },limited_rps(hdl.post,rps_lmt))
httpd:hook('after_dispatch', function(req, rsp)
	-- log all correct operations
	log.info(string.format("%s %s %s %s %s", rsp.status, req.method, req.path, req:read_cached()),req.peer.host)
end)
server:start()