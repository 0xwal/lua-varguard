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

    it('should return true when rules is empty', function()
        assert.is_true(VarGuard({}, {}):passes())
    end)

    it('should return false when input is nil and rules is not empty', function()
        assert.is_false(VarGuard({ id = '' }, nil):passes())
        assert.is_true(VarGuard({ id = '' }, nil):fails())
    end)

    it('should throw error when rule is not exist', function()
        assert.was_error(function()
            VarGuard({
                name = 'rule_not_exist'
            }, { name = 'Waleed' }):validate()
        end, 'Rule [rule_not_exist] has no handler.')
    end)

    it('should invoke the rule handler', function()
        _G.rule_check = spy()
        VarGuard({
            name = 'check'
        }, { name = 'Waleed' }):validate()
        assert.spy(_G.rule_check).was_called(1)
    end)

    it('should invoke the rule handler with required value', function()
        _G.rule_check = spy()
        VarGuard({
            name = 'check'
        }, { name = 'Waleed' }):validate()
        assert.spy(_G.rule_check).was_called_with('Waleed', {})
    end)

    it('should return (false, error) when rule return false', function()
        stub(_G, 'rule_check')
        _G.rule_check.returns(false)
        local isSuccess, error = VarGuard({
            name = 'check'
        }, { name = 'Waleed' }):validate()
        assert.is_false(isSuccess)
        assert.is_equal('Rule [check] returned falsy for `name`.', error)
    end)

    it('should return true when rule return true', function()
        stub(_G, 'rule_check')
        _G.rule_check.returns(true)
        local result = VarGuard({
            name = 'check'
        }, { name = 'Waleed' }):validate()
        assert.is_true(result)
    end)

    it('should return (false, message) when second rule returned falsy', function()
        stub(_G, 'rule_check1')
        stub(_G, 'rule_check2')
        _G.rule_check1.returns(true)
        _G.rule_check2.returns(false)
        local isSuccess, error = VarGuard({
            name = 'check1|check2'
        }, { name = 'Waleed' }):validate()
        assert.is_false(isSuccess)
        assert.is_equal('Rule [check2] returned falsy for `name`.', error)
    end)

    it('should return true and validated data when rule is empty', function()
        local isSuccess, data = VarGuard({
            name = ''
        }, { name = 'Waleed' }):validate()

        assert.is_equal(true, isSuccess)
        assert.is_same({ name = 'Waleed' }, data)
    end)

    it('should return (true, validated data) for multiple values', function()
        stub(_G, 'rule_check')
        _G.rule_check.returns(true)
        local isSuccess, data = VarGuard({
            name = 'check',
            lan  = ''
        }, { name = 'Waleed', lan = 'ar' }):validate()

        assert.is_equal(true, isSuccess)
        assert.is_same({ name = 'Waleed', lan = 'ar' }, data)
    end)

    it('should able to get all errors', function()
        stub(_G, 'rule_check1')
        stub(_G, 'rule_check2')
        _G.rule_check1.returns(false)
        _G.rule_check2.returns(false)
        local errors = VarGuard({
            id   = 'check1|check2',
            name = 'check1|check2'
        }, { id = 1, name = 'Waleed' }):errors()
        assert.is_array(#errors)
        assert.is_equal(#errors, 4)
        -- table is not always in the same order due to have lua works
        if errors[1]:find('id') then
            assert.are_same({
                'Rule [check1] returned falsy for `id`.',
                'Rule [check2] returned falsy for `id`.',
                'Rule [check1] returned falsy for `name`.',
                'Rule [check2] returned falsy for `name`.'
            }, errors)
        else
            assert.are_same({
                'Rule [check1] returned falsy for `name`.',
                'Rule [check2] returned falsy for `name`.',
                'Rule [check1] returned falsy for `id`.',
                'Rule [check2] returned falsy for `id`.'
            }, errors)
        end
    end)

    it('should able to get the first error', function()
        stub(_G, 'rule_check1')
        stub(_G, 'rule_check2')
        _G.rule_check1.returns(false)
        _G.rule_check2.returns(false)
        local validation = VarGuard({
            id = 'check1|check2',
        }, { id = 1, name = 'Waleed' })
        assert.is_equal(2, #validation:errors())
        assert.is_equal(validation:errors()[1], validation:first())
    end)

    it('should pass when value is not required and nil when using rule_type', function()
        local isSuccess, data = VarGuard({
            name = 'type:string'
        }, {}):validate()

        assert.is_equal(true, isSuccess)
        assert.is_same({}, data)
    end)

    --it('should remove data that is not exist in rules', function()
    --    local isSuccess, data = varguard_verify({
    --        name = '',
    --        lan  = ''
    --    }, { name = 'Waleed', lan = 'ar', something = true })
    --
    --    assert.is_equal(true, isSuccess)
    --    assert.is_same({ name = 'Waleed', lan = 'ar' }, data)
    --end)

    it('should return false for empty input', function()
        local rules      = { name = 'required' }
        local validation = VarGuard(rules, {})
        assert.is_false(validation:passes())
    end)

    it('should be different instance for each call', function()
        local rules            = { name = 'required' }
        local firstValidation  = VarGuard(rules, { name = 'Waleed' })
        local secondValidation = VarGuard(rules, {})
        assert.is_true(firstValidation:passes())
        assert.is_false(secondValidation:passes())
    end)

    describe('object', function()
        local dataInput, rules
        before_each(function()
            dataInput = {}
            rules     = {}
        end)

        describe('invalid input', function()
            it('should return(false, error) when the field of single nested object is not exist', function()
                dataInput.person        = {}

                rules['person.name']    = 'required'

                local isSuccess, errMsg = VarGuard(rules, dataInput):validate()

                assert.is_equal(false, isSuccess)
                assert.is_equal('Rule [required] returned falsy for `person.name`.', errMsg)
            end)

            it('should return(false, error) when the one field of multi fields object is not exist', function()
                dataInput.person        = {
                    name = "Waleed"
                }

                rules['person.name']    = 'required'
                rules['person.country'] = 'required'

                local isSuccess, errMsg = VarGuard(rules, dataInput):validate()

                assert.is_equal(false, isSuccess)
                assert.is_equal('Rule [required] returned falsy for `person.country`.', errMsg)
            end)

            it('should return(false, error) when the field of multi nested object is not exist', function()
                dataInput.person                = {
                    address = {

                    }
                }

                rules['person.address']         = 'required'
                rules['person.address.country'] = 'required'

                local isSuccess, errMsg         = VarGuard(rules, dataInput):validate()

                assert.is_equal(false, isSuccess)
                assert.is_equal('Rule [required] returned falsy for `person.address.country`.', errMsg)
            end)

            it('should return(false, error) when one field of multi fields nested object is not exist', function()
                dataInput.person                = {
                    address = {
                        country = 'KSA'
                    }
                }

                rules['person.address']         = 'required'
                rules['person.address.country'] = 'required'
                rules['person.address.city']    = 'required'

                local isSuccess, errMsg         = VarGuard(rules, dataInput):validate()

                assert.is_equal(false, isSuccess)
                assert.is_equal('Rule [required] returned falsy for `person.address.city`.', errMsg)
            end)
        end)

        describe('valid input', function()
            it('should able to validate single nest object with single field', function()
                dataInput.person                 = { name = 'Waleed' }

                rules['person.name']             = 'required'

                local isSuccess, validatedFields = VarGuard(rules, dataInput):validate()

                assert.is_equal(true, isSuccess)
                assert.is_same(dataInput, validatedFields)
            end)

            it('should able to validate single nest object with multiple field', function()
                dataInput.person                 = {
                    name     = 'Waleed',
                    language = 'ar'
                }

                rules['person.name']             = 'required'
                rules['person.language']         = 'required'

                local isSuccess, validatedFields = VarGuard(rules, dataInput):validate()

                assert.is_equal(true, isSuccess)
                assert.is_same(dataInput, validatedFields)
            end)

            it('should able to validate multiple nest object with single field', function()
                dataInput.person                 = {
                    address = {
                        country = 'Saudi Arabia'
                    }
                }

                rules['person.address']          = 'required'
                rules['person.address.country']  = 'required'

                local isSuccess, validatedFields = VarGuard(rules, dataInput):validate()

                assert.is_equal(true, isSuccess)
                assert.is_same(dataInput, validatedFields)
            end)

            it('should able to validate multiple nest object with multi fields', function()
                dataInput.person                 = {
                    address = {
                        country = 'Saudi Arabia',
                        city    = 'RY'
                    }
                }

                rules['person.address']          = 'required'
                rules['person.address.country']  = 'required'
                rules['person.address.city']     = 'required'

                local isSuccess, validatedFields = VarGuard(rules, dataInput):validate()

                assert.is_equal(true, isSuccess)
                assert.is_same(dataInput, validatedFields)
            end)
        end)

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
