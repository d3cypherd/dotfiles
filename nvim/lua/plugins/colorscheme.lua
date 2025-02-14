return {
  { -- add kanagawa
    "rebelot/kanagawa.nvim",
    lazy = true, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    --config = function()
    --  -- load the colorscheme here
    --  vim.cmd([[colorscheme kanagawa-dragon]])
    --end
  },
  { -- add rose-pine
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
  },

  -- Configure LazyVim to load colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "rose-pine-moon",
    },
  },
}
