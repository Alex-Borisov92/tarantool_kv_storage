local Af = {}
---Scoring module
---@param info table
---@return str
function Af.scoring(info)
    rules ={}
    result = {}
    function rules.rule1()
        if info.value then
            if info.value == 'test' then
                return table.insert(result,'DENY')
            else
                return table.insert(result,'ALLOW')
            end
        end
    end
    function rules.rule2()
        if info.amount then
                if info.amount > 5 then
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
        end--=DENY
    end

  return 'ALLOW'

end
return Af