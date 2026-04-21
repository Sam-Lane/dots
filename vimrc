set number
set rnu
set tabstop=4 softtabstop=0 expandtab shiftwidth=4
set smartindent
set noswapfile
set undodir=~/.vim/undodir
set undofile
set incsearch
set hidden
set nowrap
set ignorecase
set smartcase
set autoread

nnoremap <SPACE> <Nop>
let mapleader=" "
set clipboard+=unnamedplus

nnoremap Y y$

" Install vim-plug if not found
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif


autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif

call plug#begin('~/.vim/plugged')

" LSP and completion
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'windwp/nvim-autopairs'

Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'NoahTheDuke/vim-just'
Plug 'itchyny/lightline.vim'

Plug 'ryanoasis/vim-devicons'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'

Plug 'scrooloose/nerdtree', {'on': 'NERDTreeToggle'}
Plug 'Xuyuanp/nerdtree-git-plugin'

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-writer.nvim'

Plug 'junegunn/vim-easy-align'

Plug 'fatih/vim-go'
Plug 'jglasovic/venv-lsp.nvim'

Plug 'stsewd/fzf-checkout.vim'
Plug 'tpope/vim-fugitive'
Plug 'junegunn/gv.vim'
Plug 'airblade/vim-gitgutter'
Plug 'rhysd/git-messenger.vim', {'on': 'GitMessager'}
Plug 'kdheepak/lazygit.nvim'
Plug 'christoomey/vim-tmux-navigator'

" tpope collection
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'

Plug 'Yggdroot/indentLine'

" Debugger plugins
Plug 'szw/vim-maximizer'

Plug 'voldikss/vim-floaterm'

" Initialize plugin system
call plug#end()

let g:dracula_colorterm = 0
colorscheme catppuccin

hi Visual term=reverse cterm=reverse

let g:lightline = {
			\'colorscheme': 'catppuccin',
			\'active' : {
			\'left': [['mode', 'paste'],
			\['gitbranch', 'readonly', 'filename', 'modified']],
			\'right': [['filetype', 'lineinfo', 'percent']]
			\},
			\'component_function': {
			\'gitbranch': 'FugitiveHead',
			\},
			\}

lua << EOF
-- Treesitter setup
require'nvim-treesitter.configs'.setup {
    ensure_installed = {
        "python",
        "go",
        "bash",
        "php",
        "javascript",
        "json",
        "yaml",
        "rust",
        "lua",
		"toml"
    },
    highlight = {
        enable = true
    },
    indent = {
        enable = true
    }
}

-- Mason setup for LSP server management
require("mason").setup({
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
        }
    }
})

local lsp_servers = {
	"pyright",
	"gopls",
	"phpactor",
	"ts_ls",
	"jsonls",
	"bashls",
	"rust_analyzer",
	"ansiblels",
	"terraformls"
}

require("mason-lspconfig").setup({
    ensure_installed = lsp_servers,
    automatic_installation = true,
})

for _, server in ipairs(lsp_servers) do
	vim.lsp.enable(server)
end

-- LSP setup using lspconfig
local cmp_nvim_lsp = require('cmp_nvim_lsp')

-- Enhanced capabilities with nvim-cmp
local capabilities = cmp_nvim_lsp.default_capabilities()



local aug = vim.api.nvim_create_augroup("UserLspKeys", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
  group = aug,
  callback = function(ev)
    local bufnr = ev.buf
    local opts = { buffer = bufnr, silent = true, noremap = true }

    -- Go to / info
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'gy', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', 'gr', function() require('telescope.builtin').lsp_references() end, opts)
    vim.keymap.set('n', 'K',  vim.lsp.buf.hover, opts)

    -- Actions / diagnostics / utils
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n','v' }, '<leader>f', function() vim.lsp.buf.format({ async = true, bufnr = bufnr }) end, opts)
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
    vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
  end,
})


-- Diagnostic configuration
vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = false,
})

-- Diagnostic signs
local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = " " }
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Completion setup
local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup({
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
    }, {
        { name = 'buffer' },
    })
})

-- Use buffer source for `/` and `?`
cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' }
    }
})

-- Use cmdline & path source for ':'
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        { name = 'cmdline' }
    })
})

-- Autopairs setup
require('nvim-autopairs').setup({})
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
EOF

tnoremap <Esc> <C-\><C-n>

" Test settings
let test#strategy = "floaterm"
let test#php#runner = 'phpunit'
let test#php#phpunit#executable = 'docker-compose exec app vendor/bin/phpunit'

" -------------------------------------------------------------------------------------------------
" Native LSP settings
" -------------------------------------------------------------------------------------------------

" Better display for messages
set cmdheight=1
" Smaller updatetime for CursorHold & CursorHoldI
set updatetime=300
" don't give |ins-completion-menu| messages.
set shortmess+=c
" always show signcolumns
set signcolumn=yes


" Use leader t to open terminal
nnoremap <leader>t :terminal<CR>

" Additional LSP-related key mappings are set per buffer by on_attach function


let g:go_def_mapping_enabled = 0
let NERDTreeShowHidden=1

map <C-n> :NERDTreeToggle<CR>
map <C-g> :GoDoc<CR>

" setup indentation for yml
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
set noexpandtab
set cursorline

nnoremap <S-f> :Telescope find_files<CR>
nnoremap <C-f> :Telescope live_grep <CR>
nnoremap <silent> gw :Telescope grep_string <CR>
" nnoremap <C-f> :Telescope fzf_writer staged_grep <CR>
nnoremap <S-b> :Telescope buffers <CR>
nnoremap <C-b> :Telescope git_branches<CR>

" Additional LSP-related telescope mappings
nnoremap <silent> <space>o :Telescope lsp_document_symbols<CR>
nnoremap <silent> <space>s :Telescope lsp_workspace_symbols<CR>


lua << EOF
require('telescope').load_extension('fzf_writer')

require('telescope').setup{
defaults = {
	prompt_prefix="🔎 ",
	file_ignore_patterns = {
		"vendor/",
		"node-modules/",
		"venv/",
		".git/",
		"gems/",
		"__pycache__/",
		".pytest_cache/",
		".ruff_cache/",
		"target/",
		},
	},
	extensions = {
		fzf_writer = {
			minimum_grep_characters = 2,
			minimum_files_characters = 2,

			-- Disabled by default.
			-- Will probably slow down some aspects of the sorter, but can make color highlights.
			-- I will work on this more later.
			use_highlighter = true,
		}
	},
	pickers = {
		find_files = {
			find_command = {'rg', '--files', '--hidden', '-g', '!.git'},
		}
	}
}
EOF

highlight TelescopeBorder         guifg=#FF79C6
highlight TelescopePromptBorder   guifg=#FF79C6
highlight TelescopeResultsBorder  guifg=#FF79C6
highlight TelescopePreviewBorder  guifg=#FF79C6


let g:python3_host_prog = '/opt/homebrew/bin/python3'

"terraform fmt on save
let g:terraform_fmt_on_save=1

" Git remaps
nnoremap <silent> <leader>gb :GBranches<CR>
nnoremap <silent> <leader>gs :below Git<CR>
nnoremap <silent> <leader>lg :LazyGit<CR>

" FloatTerm
nnoremap <silent> <leader>ft :FloatermNew<CR>
nnoremap <silent> <leader>t :FloatermToggle<CR>

" Easy align
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)


" remap swap file
nnoremap <C-s> <C-^> " Remove bad habits
nnoremap <Left> <nop>
vnoremap <Left> <nop>
inoremap <Left> <nop>

nnoremap <Right> <nop>
vnoremap <Right> <nop>
inoremap <Right> <nop>

nnoremap <Up> <nop>
vnoremap <Up> <nop>
inoremap <Up> <nop>

nnoremap <Down> <nop>
vnoremap <Down> <nop>
inoremap <Down> <nop>

" base64 encode a string
:vnoremap <leader>64 c<c-r>=system('base64', @")<c-r><esc>
" base64 dencode a string
:vnoremap <leader>d64 c<c-r>=system('base64 --decode', @")<c-r><esc>


" Auto groups

fun! TrimWhiteSpace()
	let l:save = winsaveview()
	keeppatterns %s/\s\+$//e
	call winrestview(l:save)
endfun

augroup AUTO_WHITESPACE
	autocmd!
	autocmd BufWritePre * :call TrimWhiteSpace()
augroup END

lua << EOF
require('venv-lsp').setup()
EOF

