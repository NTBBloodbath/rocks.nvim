---@mod rocks.config.internal rocks.nvim internal configuration
--
-- Copyright (C) 2023 Neorocks Org.
--
-- Version:    0.1.0
-- License:    GPLv3
-- Created:    05 Jul 2023
-- Updated:    27 Aug 2023
-- Homepage:   https://github.com/nvim-neorocks/rocks.nvim
-- Maintainers: NTBBloodbath <bloodbathalchemist@protonmail.com>, Vhyrro <vhyrro@gmail.com>
--
---@brief [[
--
-- rocks.nvim configuration options (internal)
--
---@brief ]]

---@type RocksConfig
local config = {}

local constants = require("rocks.constants")
local fs = require("rocks.fs")

--- rocks.nvim default configuration
---@class RocksConfig
local default_config = {
    ---@type string Local path in your filesystem to install rocks
    ---@diagnostic disable-next-line: param-type-mismatch
    rocks_path = vim.fs.joinpath(vim.fn.stdpath("data"), "rocks"),
    ---@type string Rocks declaration file path
    ---@diagnostic disable-next-line: param-type-mismatch
    config_path = vim.fs.joinpath(vim.fn.stdpath("config"), "rocks.toml"),
    ---@type string Luarocks binary path
    luarocks_binary = "luarocks",
    ---@type boolean Whether to query luarocks.org lazily
    lazy = false,
    ---@type boolean Whether to automatically add freshly installed plugins to the 'runtimepath'
    dynamic_rtp = true,
    ---@class RocksConfigDebugInfo
    debug_info = {
        ---@type boolean
        was_g_rocks_nvim_sourced = vim.g.rocks_nvim ~= nil,
        ---@type string[]
        unrecognized_configs = {},
    },
    ---@type fun():RocksToml
    get_rocks_toml = function()
        local config_file = fs.read_or_create(config.config_path, constants.DEFAULT_CONFIG)
        return require("toml").decode(config_file)
    end,
    ---@type fun():RockSpec[]
    get_user_rocks = function()
        local rocks_toml = config.get_rocks_toml()
        local user_rocks = vim.tbl_deep_extend("force", rocks_toml.rocks or {}, rocks_toml.plugins or {})
        for name, data in pairs(user_rocks) do
            if type(data) == "string" then
                ---@type RockSpec
                user_rocks[name] = {
                    name = name,
                    version = data,
                }
            else
                user_rocks[name].name = name
            end
        end
        return user_rocks
    end,
}

---@type RocksOpts
local opts = type(vim.g.rocks_nvim) == "function" and vim.g.rocks_nvim() or vim.g.rocks_nvim or {}

local check = require("rocks.config.check")

config = vim.tbl_deep_extend("force", {
    debug_info = {
        urecognized_configs = check.get_unrecognized_keys(opts, default_config),
    },
}, default_config, opts)
---@cast config RocksConfig

local ok, err = check.validate(config)
if not ok then
    vim.notify("Rocks: " .. err, vim.log.levels.ERROR)
end

if #config.debug_info.unrecognized_configs > 0 then
    vim.notify(
        "unrecognized configs found in vim.g.rocks_nvim: " .. vim.inspect(config.debug_info.unrecognized_configs),
        vim.log.levels.WARN
    )
end

return config

--- config.lua ends here
