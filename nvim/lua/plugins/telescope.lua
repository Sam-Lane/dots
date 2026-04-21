return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      local telescope = require("telescope")

      telescope.setup({
        defaults = {
          prompt_prefix = "🔎 ",
          file_ignore_patterns = {
            "vendor/",
            "node-modules/",
            "venv/",
            ".git/",
            "gems/",
            "__pycache__/",
            ".pytest_cache/",
            ".ruff_cache/",
            "target/",
          },
        },
        pickers = {
          find_files = {
            find_command = { "rg", "--files", "--hidden", "-g", "!.git" },
          },
        },
      })

      telescope.load_extension("fzf")

      -- Border highlights
      vim.api.nvim_set_hl(0, "TelescopeBorder", { fg = "#FF79C6" })
      vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = "#FF79C6" })
      vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { fg = "#FF79C6" })
      vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { fg = "#FF79C6" })

      -- Keymaps
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<S-f>", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<C-f>", builtin.live_grep, { desc = "Live grep" })
      vim.keymap.set("n", "gw", builtin.grep_string, { silent = true, desc = "Grep word under cursor" })
      vim.keymap.set("n", "<S-b>", builtin.buffers, { desc = "Buffers" })
      vim.keymap.set("n", "<C-b>", builtin.git_branches, { desc = "Git branches" })
      vim.keymap.set("n", "<space>o", builtin.lsp_document_symbols, { silent = true, desc = "Document symbols" })
      vim.keymap.set("n", "<space>s", builtin.lsp_workspace_symbols, { silent = true, desc = "Workspace symbols" })
    end,
  },
}
