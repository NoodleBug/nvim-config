-- lazy_plugins.lua

-- Load the Lazy plugin manager
local Lazy = require("lazy")

-- Specify the plugins you want to install
Lazy.plugins = {
    -- Example plugin: 'vim-airline'
    {
        "github/copilot.vim",
        config = function()
            -- Optional configuration for the plugin
            -- You can add settings or keybindings here
        end,
        event = "VimEnter", -- Event to trigger the plugin setup
    },
    -- Add more plugins here as needed
}

