return {
  { "tpope/vim-commentary" },
  { "tpope/vim-surround" },
  {
    "junegunn/vim-easy-align",
    keys = {
      { "ga", "<Plug>(EasyAlign)", mode = { "n", "x" }, desc = "Easy align" },
    },
  },
  { "szw/vim-maximizer" },
  {
    "voldikss/vim-floaterm",
    keys = {
      { "<leader>ft", "<cmd>FloatermNew<CR>", silent = true, desc = "New floating terminal" },
      { "<leader>t",  "<cmd>FloatermToggle<CR>", silent = true, desc = "Toggle floating terminal" },
    },
  },
}
