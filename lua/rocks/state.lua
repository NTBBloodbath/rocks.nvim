---@mod rocks.state
--
-- Copyright (C) 2023 Neorocks Org.
--
-- Version:    0.1.0
-- License:    GPLv3
-- Created:    19 Jul 2023
-- Updated:    27 Aug 2023
-- Homepage:   https://github.com/nvim-neorocks/rocks.nvim
-- Maintainers: NTBBloodbath <bloodbathalchemist@protonmail.com>, Vhyrro <vhyrro@gmail.com>
--
---@brief [[
--
-- Functions for keeping track of the state of installed packages.
--
---@brief ]]

local state = {}

local luarocks = require("rocks.luarocks")
local nio = require("nio")

---@type fun(): {[string]: Rock}
---@async
state.installed_rocks = nio.create(function()
    ---@type {[string]: Rock}
    local rocks = {}

    local future = nio.control.future()

    luarocks.cli({
        "list",
        "--porcelain",
    }, function(obj)
        if obj.code ~= 0 then
            future.set_error(obj.stderr)
        else
            future.set(obj.stdout)
        end
    end, { text = true })

    local installed_rock_list = future.wait()

    for name, version in installed_rock_list:gmatch("(%S+)%s+(%S+)%s+installed%s+%S+") do
        rocks[name] = { name = name, version = version }
    end

    return rocks
end)

---@type fun(): {[string]: Rock}
---@async
state.outdated_rocks = nio.create(function()
    ---@type {[string]: Rock}
    local rocks = {}

    local future = nio.control.future()

    luarocks.cli({
        "list",
        "--porcelain",
        "--outdated",
    }, function(obj)
        if obj.code ~= 0 then
            future.set_error(obj.stderr)
        else
            future.set(obj.stdout)
        end
    end, { text = true })

    local installed_rock_list = future.wait()

    for name, version, target_version in installed_rock_list:gmatch("(%S+)%s+(%S+)%s+(%S+)%s+%S+") do
        rocks[name] = { name = name, version = version, target_version = target_version }
    end

    return rocks
end)

---List the dependencies of an installed Rock
---@type fun(rock:Rock): {[string]: RockDependency}
---@async
state.rock_dependencies = nio.create(function(rock)
    ---@type {[string]: RockDependency}
    local dependencies = {}

    local future = nio.control.future()

    luarocks.cli({
        "show",
        "--deps",
        "--porcelain",
        rock.name,
    }, function(obj)
        if obj.code ~= 0 then
            future.set_error(obj.stderr)
        else
            future.set(obj.stdout)
        end
    end, { text = true })

    local dependency_list = future.wait()

    for line in string.gmatch(dependency_list, "%S*[^\n]+") do
        local name, version = line:match("(%S+)%s%S+%s(%S+)")
        if not name then
            name = line:match("(%S+)")
        end
        if name and name ~= "lua" then
            dependencies[name] = { name = name, version = version }
        end
    end

    return dependencies
end)

return state
