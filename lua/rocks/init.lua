-- Copyright (C) 2024 Neorocks Org.
--
-- License:    GPLv3
-- Created:    05 Jul 2023
-- Updated:    24 Apr 2024
-- Homepage:   https://github.com/nvim-neorocks/rocks.nvim
-- Maintainers: NTBBloodbath <bloodbathalchemist@protonmail.com>, Vhyrro <vhyrro@gmail.com>, mrcjkb <marc@jakobi.dev>

---@mod rocks-nvim rocks.nvim
---
---@brief [[
---
---A luarocks plugin manager for Neovim.
---
---@brief ]]

---@toc rocks-contents

---@mod rocks-toml
---
---@brief [[
---rocks.nvim stores information about installed plugins in the
---`[plugins]` or `[rocks]` entries.
---`[plugins]` can be managed automatically using |rocks-commands|.
---
---Example:
---
--->toml
---     [plugins]
---     "rocks.nvim" = "2.0.0"
---     neorg = { version = "8.0.0", opt = true }
---
---     [plugins."sweetie.nvim"]
---     version = "2.0.0"
---     opt = true
---<
---
--- For the foll spec, refer to the |RockSpec|.
---@brief ]]

---@class RockSpec
---@field name string The name of the rock
---@field version? string The rock version
---@field opt? boolean Set to `true` to prevent rocks from being loaded eagerly
---@field pin? boolean Pinned rocks will not be updated
---@field install_args? string[] Additional args to pass to `luarocks install`
---@field [string] unknown Fields that can be added by external modules

---@brief [[
--- NOTE: Currently, all options except for `install_args` can be passed to `:Rocks install`.
---@brief ]]

local rocks = {}

---@package
---@deprecated
function rocks.packadd(rock_name, opts)
    vim.deprecate("rocks.packadd", "Neovim's built-in 'packadd'", "3.0.0", "rocks.nvim")
    require("rocks.runtime").packadd({ name = rock_name }, opts)
end

return rocks
