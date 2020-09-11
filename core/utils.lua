local Utils ={}
--TODO TEMPORARY FILE FOR USEFUL FUNCTIONS - REWRITE AS SEPARATE MODULE
--TODO to beatify according to startdart
function Utils.tbl_print(tbl)
    for k,v in pairs(tbl) do
        if v then
            if type(v) =='table' then
            print('table='..tostring(k))
            Utils.tbl_print(v)
            else
                print(k,v)
            end
            else print('tbl_print: table is empty!. :(')
        end
    end

end

return Utils