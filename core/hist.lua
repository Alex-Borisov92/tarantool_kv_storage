local box           = require('box') --TODO beatify code according to standarts
--TODO WARNING! THIS MODULE HASNT TESTED AND DEBUGGED YET! YOU NEED TO CHECK IT BEFORE USING!

--in: event_info
local Hist = {}
--SQL like simple aggregate editor
function Hist.compute(h)
    metrics ={}
    result ={}
    function metrics.count_by_card_d()
        local statement = "SELECT COUNT("..h[_id]..") FROM main WHERE card=="..h.value.card.."and t>="..tostring((h.t - 60*60*24))
        local metric_result = box.execute(statement)
        print(metric_result[1]) --TODO debug and delete after - we need result here
        return table.insert(result,metric_result)
    end



    for _, f in pairs(metrics) do
        pcall(f)
    end
    return result












end
return Hist