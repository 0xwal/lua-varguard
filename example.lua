---
--- Created By 0xWaleed
--- DateTime: 5/4/21 8:11 AM
---

require('varguard')

function print_table(t, indent)
    if not t then
        return
    end
    if not indent then
        indent = 0
    end
    local formatting
    if type(t) ~= 'table' then
        formatting = string.rep("  ", indent)
        print(formatting .. tostring(t))
        return
    end
    for k, v in pairs(t) do
        formatting = string.rep("  ", indent) .. k .. ": "
        if type(v) == "table" then
            print(formatting)
            print_table(v, indent + 1)
        else
            print(formatting .. tostring(v))
        end
    end
end


local dataSchema = {
    name = '',
    lan  = '',
    day  = 'required|type:number|min:3|max:4',
    tech = 'required',
    ['tech.name'] = 'required',
    ['tech.major'] = 'required',
    ['tech.major.number'] = 'required'
}

local data       = {
    name = 'waleed',
    lan  = 'ar',
    day = 3,
    tech = {
        --name = "asp",
        major = {
            --number = '145'
        }
    }
}

local validation = VarGuard(dataSchema, data)
local isValid, values = validation:validate()
print(string.format('(was %s', (isValid and 'valid)' or 'not valid)')))

if isValid then
   print_table(values, 1)
else
    print_table(validation:errors())
end
