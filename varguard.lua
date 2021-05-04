---
--- Created By 0xWaleed
--- DateTime: 5/4/21 12:42 AM
---

local function splitter(string, sep)
    sep = sep or '%s'
    local t = {}
    for str in string.gmatch(string, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

function varguard_parse_validators(validators)

    local allValidators = splitter(validators, '|')
    local results = {}
    for _, v in ipairs(allValidators) do
        local st = splitter(v, ':')

        local vName = st[1]
        local args = {}

        if st[2] then
            args = splitter(st[2], ',?%s')
        end
        results[vName] = args
    end

    return results
end

