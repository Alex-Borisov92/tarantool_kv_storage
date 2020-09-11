local box           = require('box') --TODO beatify code according to standarts
--in: event_info
local Hist = {}


--SQL like simple aggregate editor
function Hist.compute(h)
    result  = {}
    result.history = {}
    metrics = {}
    function metrics.count_by_card_d()
        local statement = "SELECT count(1) FROM main1 WHERE card='"..h.value.card.."' and t > "..tostring((h.t - 60*60*24 * 1000))
        local metric_result = box.execute(statement)
        result['history']["count_by_card_d"] = metric_result['rows'][1][1]

    end

    for _, f in pairs(metrics) do
        pcall(f)
    end
    return result
end

return Hist