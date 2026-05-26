return {
  {
    "tpope/vim-fugitive",
    keys = {
      { "<leader>gs", "<cmd>below Git<CR>", silent = true, desc = "Git status" },
    },
  },
  { "junegunn/gv.vim" },
  { "airblade/vim-gitgutter" },
  {
    "rhysd/git-messenger.vim",
    cmd = "GitMessenger", -- note: original vimrc had a typo "GitMessager" — fixed here
  },
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      {
        "<leader>dv",
        function()
          local lib = require("diffview.lib")
          if lib.get_current_view() then
            vim.cmd("DiffviewClose")
          else
            vim.cmd("DiffviewOpen")
          end
        end,
        desc = "Toggle Diffview",
      },
    },
  },
  {
    "kdheepak/lazygit.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>lg", "<cmd>LazyGit<CR>", silent = true, desc = "LazyGit" },
    },
  },
  {
    "junegunn/fzf",
    dir = "~/.fzf",
    build = "./install --all",
  },
  { "junegunn/fzf.vim" },
  {
    "stsewd/fzf-checkout.vim",
    keys = {
      { "<leader>gb", "<cmd>GBranches<CR>", silent = true, desc = "Git branches" },
    },
  },
}
