return {
  -- Colorscheme: catppuccin (active)
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("catppuccin")
      -- Keep visual selection legible
      vim.api.nvim_set_hl(0, "Visual", { reverse = true })
    end,
  },

  -- Colorscheme: dracula (available but not active)
  {
    "dracula/vim",
    name = "dracula",
    lazy = true,
    init = function()
      vim.g.dracula_colorterm = 0
    end,
  },

  -- Status line
  {
    "itchyny/lightline.vim",
    lazy = false,
    init = function()
      vim.g.lightline = {
        colorscheme = "catppuccin",
        active = {
          left = { { "mode", "paste" }, { "gitbranch", "readonly", "filename", "modified" } },
          right = { { "filetype", "lineinfo", "percent" } },
        },
        component_function = {
          gitbranch = "FugitiveHead",
        },
      }
    end,
  },

  -- File type icons (used by NERDTree)
  { "ryanoasis/vim-devicons" },

  -- Indent guides
  { "Yggdroot/indentLine" },
}
