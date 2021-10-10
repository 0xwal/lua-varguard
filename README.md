# lua-varguard

Simple API to validate input inspired by [PHP-Laravel](https://laravel.com/docs/8.x/validation) framework.

## Usage

```lua
require('varguard')

function rule_email(value, args)
    -- check if not email return false
    return false
end

local rules           = {
    name                = 'required|type:string',
    email               = 'required|type:string|email',
    ['address.country'] = 'required',
    ['address.city']    = 'required'
}

local data            = {
    name    = 'lua',
    email   = 'not-email',
    address = {
        country = 'SA',
        -- city    = 'RY'
    }
}

local validation = VarGuard(rules, data)
local isValid, values = validation:validate()
-- isValid == status of validation
print(validation:passes())
print(#validation:errors())
```

## Todo

* Add more rules.
* Support Array of Objects
