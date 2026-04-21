-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Indentation
-- Note: noexpandtab is intentional — preserves original vimrc behaviour where tabs are used
-- globally except in YAML files (which override via autocmd in autocmds.lua)
vim.opt.tabstop = 4
vim.opt.softtabstop = 0
vim.opt.shiftwidth = 4
vim.opt.expandtab = false
vim.opt.smartindent = true

-- Files
vim.opt.swapfile = false
vim.opt.undodir = vim.fn.expand("~/.vim/undodir")
vim.opt.undofile = true
vim.opt.autoread = true
vim.opt.hidden = true

-- Search
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Display
vim.opt.wrap = false
vim.opt.cursorline = true
vim.opt.cmdheight = 1
vim.opt.signcolumn = "yes"
vim.opt.shortmess:append("c")

-- Performance
vim.opt.updatetime = 300

-- Clipboard
vim.opt.clipboard = "unnamedplus"

-- Python provider
vim.g.python3_host_prog = "/opt/homebrew/bin/python3"
