return {
  {
    "fatih/vim-go",
    init = function()
      -- Disable vim-go's gd mapping so nvim LSP (gopls) handles it instead
      vim.g.go_def_mapping_enabled = 0
    end,
    keys = {
      { "<C-g>", "<cmd>GoDoc<CR>", desc = "Go documentation" },
    },
  },

  { "NoahTheDuke/vim-just" },

  {
    "jglasovic/venv-lsp.nvim",
    config = function()
      require("venv-lsp").setup()
    end,
  },

  -- Orphaned settings from original vimrc (vim-test not installed, kept for reference):
  -- vim.g["test#strategy"] = "floaterm"
  -- vim.g["test#php#runner"] = "phpunit"
  -- vim.g["test#php#phpunit#executable"] = "docker-compose exec app vendor/bin/phpunit"

  -- Orphaned: terraform_fmt_on_save requires hashivim/vim-terraform (not installed).
  -- Add the plugin below to activate it:
  -- { "hashivim/vim-terraform", init = function() vim.g.terraform_fmt_on_save = 1 end },
}
