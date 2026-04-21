return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "python",
          "go",
          "bash",
          "php",
          "javascript",
          "json",
          "yaml",
          "rust",
          "lua",
          "toml",
        },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
}
