return {
  {
    "scrooloose/nerdtree",
    cmd = "NERDTreeToggle",
    dependencies = {
      "Xuyuanp/nerdtree-git-plugin",
      "tiagofumo/vim-nerdtree-syntax-highlight",
      "ryanoasis/vim-devicons",
    },
    init = function()
      vim.g.NERDTreeShowHidden = 1
    end,
    keys = {
      { "<C-n>", "<cmd>NERDTreeToggle<CR>", desc = "Toggle NERDTree" },
    },
  },
}
