set number
set rnu
set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab
set smartindent
set noswapfile
set undodir=~/.vim/undodir
set undofile
set incsearch
set hidden
set nowrap

nnoremap <SPACE> <Nop>
let mapleader=" "


" Install vim-plug if not found
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif


autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif

call plug#begin('~/.vim/plugged')

Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'itchyny/lightline.vim'

Plug 'scrooloose/nerdtree', {'on': 'NERDTreeToggle'}
Plug 'Xuyuanp/nerdtree-git-plugin'

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-writer.nvim'
Plug 'fannheyward/telescope-coc.nvim'

Plug 'hashivim/vim-terraform'
Plug 'junegunn/vim-easy-align'
Plug 'fatih/vim-go'

Plug 'stsewd/fzf-checkout.vim'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'rhysd/git-messenger.vim', {'on': 'GitMessager'}

" tpope collection
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'

Plug 'Yggdroot/indentLine'

" Debugger plugins
Plug 'puremourning/vimspector'
Plug 'szw/vim-maximizer'

Plug 'voldikss/vim-floaterm'

Plug 'ThePrimeagen/vim-be-good', {'on': 'VimBeGood'}
" Initialize plugin system
call plug#end()

let g:dracula_colorterm = 0
colorscheme dracula

hi Visual term=reverse cterm=reverse

let g:lightline = {
			\'colorscheme': 'dracula',
			\'active' : {
			\'left': [['mode', 'paste'],
			\['gitbranch', 'readonly', 'filename', 'modified']],
			\'right': [['filetype', 'lineinfo', 'percent']]
			\},
			\'component_function': {
			\'gitbranch': 'FugitiveHead'
			\},
			\}

lua << EOF
require'nvim-treesitter.configs'.setup {
    ensure_installed = {
        "python",
		"go",
		"bash",
		"php",
		"javascript",
		"json",
		"yaml"
    },
    highlight = {
        enable = true
    },
    indent = {
        enable = true
    }
}
EOF

" Test settings
let test#strategy = "floaterm"
let test#php#runner = 'phpunit'
let test#php#phpunit#executable = 'docker-compose exec app vendor/bin/phpunit'

" -------------------------------------------------------------------------------------------------
" coc.nvim default settings
" -------------------------------------------------------------------------------------------------
let g:coc_global_extensions = ['coc-docker', 'coc-pairs', 'coc-go', 'coc-jedi', 'coc-phpls', 'coc-tsserver', 'coc-json', 'coc-yaml', 'coc-sh']

" if hidden is not set, TextEdit might fail.
set hidden
" Better display for messages
set cmdheight=1
" Smaller updatetime for CursorHold & CursorHoldI
set updatetime=300
" don't give |ins-completion-menu| messages.
set shortmess+=c
" always show signcolumns
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use `[c` and `]c` to navigate diagnostics
nmap <silent> [c <Plug>(coc-diagnostic-prev)
nmap <silent> ]c <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr :Telescope coc references<CR>

" Use U to show documentation in preview window
nnoremap <silent> U :call <SID>show_documentation()<CR>

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Remap for format selected region
vmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)
" Show all diagnostics
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>


let g:go_def_mapping_enabled = 0
let NERDTreeShowHidden=1

map <C-n> :NERDTreeToggle<CR>
map <C-g> :GoDoc<CR>

" setup indentation for yml
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
set noexpandtab
set cursorline

nnoremap <S-f> :Telescope find_files<CR>
" nnoremap <C-f> :Telescope live_grep <CR>
nnoremap <C-f> :Telescope fzf_writer staged_grep <CR>
nnoremap <S-b> :Telescope buffers <CR>
nnoremap <C-b> :Telescope git_branches<CR>


lua << EOF
require('telescope').load_extension('fzf_writer')
require('telescope').load_extension('coc')

require('telescope').setup{
	defaults = {
		prompt_prefix="🔎 ",
		file_ignore_patterns = {
		"vendor/",
		"node-modules/",
		}
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
    }
}
EOF

highlight TelescopeBorder         guifg=#FF79C6
highlight TelescopePromptBorder   guifg=#FF79C6
highlight TelescopeResultsBorder  guifg=#FF79C6
highlight TelescopePreviewBorder  guifg=#FF79C6


" terraform fmt on save
let g:terraform_fmt_on_save=1

" Git remaps
nnoremap <silent> <leader>gb :GBranches<CR>
nnoremap <silent> <leader>gs :Gstatus<CR>

" Easy align
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

" remap swap file
nnoremap <C-s> <C-^>

" Remove bad habits
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


