-- Trim trailing whitespace on save
vim.api.nvim_create_augroup("AUTO_WHITESPACE", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
  group = "AUTO_WHITESPACE",
  pattern = "*",
  callback = function()
    local view = vim.fn.winsaveview()
    vim.cmd("keeppatterns %s/\\s\\+$//e")
    vim.fn.winrestview(view)
  end,
})

-- YAML: use 2-space indentation
vim.api.nvim_create_augroup("YAML_INDENT", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = "YAML_INDENT",
  pattern = "yaml",
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
  end,
})
