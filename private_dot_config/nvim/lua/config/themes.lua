-- Manage all themes and selection logic

-- Define all theme plugins here
return {
  -- OneDarkPro theme
  {
    "olimorris/onedarkpro.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("onedarkpro").setup({
        -- Add your onedarkpro configuration here
      })
      -- Select the theme variant here
      vim.cmd("colorscheme onedark_dark")
    end,
  },

  --  Add more themes here as needed
  -- Example:
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({})
      vim.cmd("colorscheme tokyonight")
    end,
  },
}
