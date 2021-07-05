---
--- Created By 0xWaleed
--- DateTime: 5/4/21 12:36 AM
---

require('varguard')

-- validation format: validator:arg, arg|validator|validator:arg

describe('varguard_verify', function()

    it('should exist', function()
        assert.is_not_nil(varguard_verify)
    end)

    it('should return (false, error) if first argument is not table', function()
        assert.are_same({ false, 'Rules is not table, nil given.' }, { varguard_verify(nil, {}) })
        assert.are_same({ false, 'Rules is not table, boolean given.' }, { varguard_verify(true, {}) })
        assert.are_same({ false, 'Rules is not table, number given.' }, { varguard_verify(1, {}) })
        assert.are_same({ false, 'Rules is not table, function given.' }, { varguard_verify(function()
        end, {}) })
    end)

    it('should return true when rules is empty', function()
        assert.is_true(varguard_verify({}, {}))
    end)

    it('should return (false, error message) when data is nil', function()
        assert.is_equal(table.unpack { false, 'Data is nil.' }, varguard_verify({}, nil))
    end)

    it('should throw error when rule is not exist', function()
        assert.was_error(function()
            varguard_verify({
                name = 'rule_not_exist'
            }, { name = 'Waleed' })
        end, 'Rule [rule_not_exist] has no handler.')
    end)

    it('should invoke the rule handler', function()
        _G.rule_check = spy()
        varguard_verify({
            name = 'check'
        }, { name = 'Waleed' })
        assert.spy(_G.rule_check).was_called(1)
    end)

    it('should invoke the rule handler with required value', function()
        _G.rule_check = spy()
        varguard_verify({
            name = 'check'
        }, { name = 'Waleed' })
        assert.spy(_G.rule_check).was_called_with('Waleed', {})
    end)

    it('should return (false, error) when rule return false', function()
        stub(_G, 'rule_check')
        _G.rule_check.returns(false)
        local isSuccess, error = varguard_verify({
            name = 'check'
        }, { name = 'Waleed' })
        assert.is_false(isSuccess)
        assert.is_equal('Rule [check] returned falsy for `name`.', error)
    end)

    it('should return true when rule return true', function()
        stub(_G, 'rule_check')
        _G.rule_check.returns(true)
        local result = varguard_verify({
            name = 'check'
        }, { name = 'Waleed' })
        assert.is_true(result)
    end)

    it('should return (false, message) when second rule returned falsy', function()
        stub(_G, 'rule_check1')
        stub(_G, 'rule_check2')
        _G.rule_check1.returns(true)
        _G.rule_check2.returns(false)
        local isSuccess, error = varguard_verify({
            name = 'check1|check2'
        }, { name = 'Waleed' })
        assert.is_false(isSuccess)
        assert.is_equal('Rule [check2] returned falsy for `name`.', error)
    end)

    it('should return true and validated data when rule is empty', function()
        local isSuccess, data = varguard_verify({
            name = ''
        }, { name = 'Waleed' })

        assert.is_equal(true, isSuccess)
        assert.is_same({ name = 'Waleed' }, data)
    end)

    it('should return (true, validated data) for multiple values', function()
        stub(_G, 'rule_check')
        _G.rule_check.returns(true)
        local isSuccess, data = varguard_verify({
            name = 'check',
            lan  = ''
        }, { name = 'Waleed', lan = 'ar' })

        assert.is_equal(true, isSuccess)
        assert.is_same({ name = 'Waleed', lan = 'ar' }, data)
    end)

    it('should remove data that is not exist in rules', function()
        local isSuccess, data = varguard_verify({
            name = '',
            lan  = ''
        }, { name = 'Waleed', lan = 'ar', something = true })

        assert.is_equal(true, isSuccess)
        assert.is_same({ name = 'Waleed', lan = 'ar' }, data)
    end)

end)

--[[ returns
    validator:
        args
]]--
describe('varguard_parse_validators', function()
    it('should exist', function()
        assert.is_not_nil(varguard_parse_validators)
    end)

    it('should return array of validators', function()
        assert.is_same({
            required = {}
        }, varguard_parse_validators('required'))
    end)

    it('should parse a validator with arguments', function()
        assert.is_same({
            required = { 'arg' }
        }, varguard_parse_validators('required:arg'))
    end)

    it('should parse multiple arguments', function()
        assert.is_same({
            required = { 'first', 'second' }
        }, varguard_parse_validators('required:first,second'))
    end)

    it('should parse multiple validators without args', function()
        assert.is_same({
            required = {},
            type     = {}
        }, varguard_parse_validators('required|type'))
    end)

    it('should parse multiple validators with args', function()
        assert.is_same({
            required = {
                'now'
            },
            type     = {
                'string'
            }
        }, varguard_parse_validators('required:now|type:string'))
    end)

    it('should parse multiple validators with multi arguments', function()
        assert.is_same({
            required = {
                'now',
                'right'
            },
            type     = {
                'string',
                'table'
            }
        }, varguard_parse_validators('required:now,right|type:string,table'))
    end)

    it('should ignore empty line after comma in the args', function()
        assert.is_same({
            required = {
                'now',
                'right'
            },
            type     = {
                'string',
                'table'
            }
        }, varguard_parse_validators('required:now, right|type:string, table'))
    end)

    it('should ignore arguments when validator has a colon', function()
        assert.is_same({
            required = {},
            type     = {}
        }, varguard_parse_validators('required:|type:'))
    end)
end)

describe('rule_required', function()
    it('should exist', function()
        assert.is_not_nil(rule_required)
    end)

    it('should return true when argument is not nil', function()
        assert.is_true(rule_required(true))
        assert.is_true(rule_required(false))
        assert.is_true(rule_required('something'))
        assert.is_true(rule_required(function()
        end))
        assert.is_true(rule_required(1))
        assert.is_true(rule_required({}))
    end)

    it('should return false for empty string and nil', function()
        assert.is_false(rule_required(''))
        assert.is_false(rule_required(nil))
    end)
end)

describe('rule_type', function()
    it('should exist', function()
        assert.is_not_nil(rule_type)
    end)

    it('should return false when type is not one of types', function()
        assert.is_false(rule_type(4, { 'string', 'boolean' }))
    end)

    it('should return true when type exist in the specified types', function()
        assert.is_true(rule_type(4, { 'string', 'boolean', 'number' }))
    end)
end)

describe('rule_callable', function()
    it('should exist', function()
        assert.is_not_nil(rule_callable)
    end)

    it('should return false when input is not callable', function()
        assert.is_false(rule_callable(true))
        assert.is_false(rule_callable({}))
        assert.is_false(rule_callable(1))
        assert.is_false(rule_callable(nil))
    end)

    it('should return true when input is function', function()
        assert.is_true(rule_callable(function()
        end))
    end)

    it('should return true when input is table and has __call', function()
        local callableTable = setmetatable({}, {
            __call = function()
            end
        })
        assert.is_true(rule_callable(callableTable))
    end)

    it('should return false when table metadata has __call that is not a function', function()
        local callableTable = setmetatable({}, {
            __call = 1
        })
        assert.is_false(rule_callable(callableTable))
    end)
end)

describe('rule_max', function()
    it('should exist', function()
        assert.is_not_nil(rule_max)
    end)

    it('should return false when arguments is nil', function()
        assert.is_false(rule_max(2, {}))
    end)

    it('should return false when the max is not a number', function()
        assert.is_false(rule_max(2, { 'k' }))
    end)

    it('should return false when input greater than max', function()
        assert.is_false(rule_max(5, { '4' }))
    end)

    it('should return true when input is less or equal than max', function()
        assert.is_true(rule_max(2, { '4' }))
        assert.is_true(rule_max(4, { '4' }))
    end)
end)

describe('rule_min', function()
    it('should exist', function()
        assert.is_not_nil(rule_min)
    end)

    it('should return false when arguments is nil', function()
        assert.is_false(rule_min(2, {}))
    end)

    it('should return false when the min is not a number', function()
        assert.is_false(rule_min(2, { 'k' }))
    end)

    it('should return false when input less than min', function()
        assert.is_false(rule_min(2, { '4' }))
    end)

    it('should return true when input is greater or equal than min', function()
        assert.is_true(rule_min(5, { '4' }))
        assert.is_true(rule_min(4, { '4' }))
    end)
end)
