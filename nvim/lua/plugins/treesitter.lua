return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.install").install({
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
      })
    end,
  },
}
