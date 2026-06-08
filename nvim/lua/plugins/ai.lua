return {
  {
    "greggh/claude-code.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("claude-code").setup()
    end,
    keys = {
      { "<C-,>",      "<cmd>ClaudeCode<CR>",        mode = { "n", "t" }, desc = "Toggle Claude Code" },
      { "<leader>cC", "<cmd>ClaudeCodeResume<CR>",  desc = "Resume Claude conversation" },
      { "<leader>cV", "<cmd>ClaudeCodeVerbose<CR>", desc = "Claude verbose mode" },
    },
  },
}
