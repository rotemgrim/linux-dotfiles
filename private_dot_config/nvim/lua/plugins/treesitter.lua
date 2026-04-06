return {
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "windwp/nvim-ts-autotag",
    },
    opts = {
      ensure_installed = {
        "typescript",
        "tsx",
        "css",
        "html",
        "javascript",
      },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      -- This is key for embedded languages
      indent = {
        enable = true,
      },
    },
  },
  -- Add styled-components plugin for CSS-in-JS highlighting
  {
    "styled-components/vim-styled-components",
    branch = "main",
    ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  },
}
