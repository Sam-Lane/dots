-- nvim-treesitter v1 is a parser manager only.
-- Highlight, indent, and folds are handled by neovim's native vim.treesitter API
-- (available since nvim 0.10+). The configs/ensure_installed modules no longer exist.
--
-- Parsers bundled with neovim (no plugin needed):
--   c, lua, vim, vimdoc, query, markdown, markdown_inline
return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- build runs once on install/update, not on every startup
    build = function()
      require("nvim-treesitter.install").install({
        "python", "go", "bash", "php",
        "javascript", "json", "yaml",
        "rust", "toml",
      })
    end,
    config = function()
      -- Enable native treesitter highlight for every filetype that has a parser.
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    end,
  },
}
