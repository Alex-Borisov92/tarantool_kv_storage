local utils =require('core.utils')
local Af = {}
---Scoring module
---@param info table
---@return table
function Af.make_scoring(info)
    rules   = {}
    reasons = {''} --TODO bad code. need to rewrite without any init reasons. see Handler.rsp - code 200
    result  = {}
    out     = {} --TODO too many tables?

    function rules.rule1()
        local reason = 'Bad card'
        if info.value.card then
            if info.value.card == 'test' then
                table.insert(reasons, reason)
                return table.insert(result,'DENY')
            --else
            --   return table.insert(result,'ALLOW')
            end
        end
    end
    function rules.rule2()
        local reason = 'Big amount'
        if info.value.amount then
                if info.value.amount > 5 then
                    table.insert(reasons, reason)
                    return table.insert(result,'DENY')
                --else
                --   return table.insert(result,'ALLOW')
                end
        end
    end
    --experimental for historical data
    function rules.rule3()
        local reason = 'Suspicious card activity'
        if info.history.count_by_card_d then
                if tonumber(info.history.count_by_card_d) > 2 then
                    table.insert(reasons, reason)
                    return table.insert(result,'DENY')
                --else
                --    return table.insert(result,'ALLOW')
                end
        end
    end
    --TODO ADD LIST FUNCTIONALITY

    for _, f in pairs(rules) do
       pcall(f)
    end
    out.reasons = reasons
    if #result > 0 then --TODO bad decision - hard to scale if to add new actions.
        out.action  = 'DENY'
    else
        out.action = 'ALLOW'
    end

  return out

end
return Af