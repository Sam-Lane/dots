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
