---
--- Created By 0xWaleed
--- DateTime: 5/4/21 12:42 AM
---

local function splitter(string, sep)
    sep     = sep or '%s'
    local t = {}
    for str in string.gmatch(string, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

function varguard_parse_validators(validators)

    local allValidators = splitter(validators, '|')
    local results       = {}
    for _, v in ipairs(allValidators) do
        local st    = splitter(v, ':')

        local vName = st[1]
        local args  = {}

        if st[2] then
            args = splitter(st[2], ',?%s')
        end
        results[vName] = args
    end

    return results
end

function varguard_verify(rules, data)
    if not data then
        return false, 'Data is nil.'
    end

    if type(rules) ~= 'table' then
        return false, 'Rules is not table, ' .. type(rules) .. ' given.'
    end

    local validatedData = {}

    for k, v in pairs(rules) do

        if v == '' then
            validatedData[k] = data[k]
        end

        local validators = varguard_parse_validators(v)
        for ruleName, args in pairs(validators) do
            local ruleHandler = _G['rule_' .. ruleName]
            if not ruleHandler then
                error(('Rule [%s] has no handler.'):format(ruleName))
            end
            if not ruleHandler(data[k], args) then
                return false, ('Rule [%s] returned falsy for `%s`.'):format(ruleName, k)
            end
            validatedData[k] = data[k]
        end
    end

    return true, validatedData
end

function rule_required(input)
    return input ~= nil and input ~= ''
end

function rule_type(input, types)
    for _, t in ipairs(types) do
        if type(input) == t then
            return true
        end
    end
    return false
end

function rule_callable(input)
    local typeOfInput = type(input)
    if typeOfInput == 'function' then
        return true
    end

    if typeOfInput ~= 'table' then
        return false
    end

    local mt = getmetatable(input)

    if not mt then
        return false
    end

    return mt.__call ~= nil and type(mt.__call) == 'function'
end

function rule_max(input, args)
    local max = args[1]
    if not max then
        return false
    end

    max = tonumber(max)

    if not max then
        return false
    end

    return input <= max
end

function rule_min(input, args)
    local min = args[1]
    if not min then
        return false
    end

    min = tonumber(min)

    if not min then
        return false
    end

    return input >= min
end
