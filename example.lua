---
--- Created By 0xWaleed
--- DateTime: 5/4/21 8:11 AM
---

require('varguard')

local dataSchema = {
    name = '',
    lan  = '',
    day  = 'required|type:number|min:3|max:4'
}

local data       = {
    name = 'waleed',
    lan  = 'ar',
    day = 5
}

local isValid, values = varguard_verify(dataSchema, data)
print(isValid)

if isValid then
    for k, v in pairs(values) do
        print(k, v)
    end
else
    print(values)
end
