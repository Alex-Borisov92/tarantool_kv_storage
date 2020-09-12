local json    = require('json')
local af      = require('core.af')
local uuid    = require('uuid')
local hist 	  = require('core.hist')
local box 	  = require('box')
local os 	  = require('os')
local log 	  = require('log')
local utils   = require('core.utils')
local storage = require('core.storage')
local sqlRouter = {}
    function sqlRouter.sql_post(d)
        local card =d.value.card
        local amount = d.value.amount
        local extid = d.value.extid
        local t =d.t
        local id = d._id
        if card and amount and extid and t and id then
	 	 local statement = "INSERT INTO main1 VALUES ('"..id.."', '"..extid .."', "..t..", '"..card.."', "..amount ..")"
	 	 local ok = box.execute(statement) -- first prototype. TODO rewrite
            if ok then
                log.info(id..': Data in SQL BD has been added successfully.')
            else
               log.info(id..': Adding data to SQL table has been failed.')
            end
        end
    end
    function sqlRouter.sql_put(d)
         --TODO add logic
         put ={}
         return put
    end


return sqlRouter