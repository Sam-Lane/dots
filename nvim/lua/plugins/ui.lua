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
    "nvim-lualine/lualine.nvim",
    lazy = false,
    dependencies = { "tpope/vim-fugitive" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "catppuccin-nvim",
          globalstatus = true,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { { function() return vim.fn.FugitiveHead() end, icon = "" }, "readonly", "filename", "modified" },
          lualine_c = {},
          lualine_x = { "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },

  -- Indent guides
  { "Yggdroot/indentLine" },
}
