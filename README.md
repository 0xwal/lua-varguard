# lua-varguard

Simple API to validate input inspired by [PHP-Laravel](https://laravel.com/docs/8.x/validation) framework.

## Usage

```lua
require('varguard')

local rules = {
    name = 'required|type:string',
    day  = 'required|type:number|min:3|max:4'
}

local data = {
    name = 'lua',
    day = 4,
    discarded = 'filtered from `values` as it is not exist in rules'
}

local isValid, values = VarGuard(rules, data):validate()

--[[
    isValid -> true
    values -> {
        name = 'lua',
        day = 4
    }
]]
```

## Todo
* Support nested table.
* Add more rules.
