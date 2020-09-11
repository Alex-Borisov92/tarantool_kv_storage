local utils =require('core.utils')
local Af = {}
---Scoring module
---@param info table
---@return str
function Af.scoring(info)
    rules ={}
    result = {}
    --TODO add commentaries. To return JSON?
    function rules.rule1()
        if info.value.card then
            if info.value.card == 'test' then
                return table.insert(result,'DENY')
            else
               return table.insert(result,'ALLOW')
            end
        end
    end
    function rules.rule2()
        if info.value.amount then
                if info.value.amount > 5 then
                    return table.insert(result,'DENY')
                else
                   return table.insert(result,'ALLOW')
                end
        end
    end

    function rules.rule3() --experimental for historical data
        utils.tbl_print(info)
        if info[1]['history'].count_by_card_d then
                if tonumber(info[1]['history'].count_by_card_d) > 2 then
                    return table.insert(result,'DENY')
                else
                    return table.insert(result,'ALLOW')
                end
        end
    end

    for _, f in pairs(rules) do
       pcall(f)
    end
    for _, r in pairs(result) do
        if r =='DENY' then
            return r 
        end

    end

  return 'ALLOW'

end
return Af