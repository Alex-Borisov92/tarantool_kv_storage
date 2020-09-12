local json    = require('json')
local af      = require('core.af')
local uuid    = require('uuid')
local hist 	  = require('core.hist')
local box 	  = require('box')
local os 	  = require('os')
local log 	  = require('log')
local utils   = require('core.utils')
local storage = require('core.storage')
local EventMaker = {}
    function EventMaker.make_post(d)
         post = d
         post.t = os.time() * 1000 --time in milliseconds
    	 post._id = uuid.str()
         --TODO what  internal fields will be useful too?
         ----ADDING HISTORICAL DATA
         post.history = hist.compute(d).history
        --table.insert(post, hist.compute(d))

         --TODO ADD BINBASE INFO
         --TODO ADD IP INFO
         --TODO ADD EMAIL INFO
         return post
    end
    function EventMaker.make_put(d)
         --TODO add logic
         put ={}
         return put
    end


return EventMaker