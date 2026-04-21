return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      local lsp_servers = {
        "pyright",
        "gopls",
        "phpactor",
        "ts_ls",
        "jsonls",
        "bashls",
        "rust_analyzer",
        "ansiblels",
        "terraformls",
      }

      require("mason").setup({
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
      })

      require("mason-lspconfig").setup({
        ensure_installed = lsp_servers,
        automatic_installation = true,
      })

      for _, server in ipairs(lsp_servers) do
        vim.lsp.enable(server)
      end

      -- Diagnostic display
      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = false,
      })

      local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end

      -- LSP keymaps (set per buffer on attach)
      local aug = vim.api.nvim_create_augroup("UserLspKeys", { clear = true })
      vim.api.nvim_create_autocmd("LspAttach", {
        group = aug,
        callback = function(ev)
          local bufnr = ev.buf
          local opts = { buffer = bufnr, silent = true, noremap = true }

          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, opts)
          vim.keymap.set("n", "gr", function() require("telescope.builtin").lsp_references() end, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set({ "n", "v" }, "<leader>f", function()
            vim.lsp.buf.format({ async = true, bufnr = bufnr })
          end, opts)
          vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
          vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
          vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        end,
      })
    end,
  },

  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },
}
