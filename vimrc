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
  silent !curl -fLo ~/.nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif


autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif

" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')

" Make sure you use single quotes
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'dracula/vim', { 'as': 'dracula' }

Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

Plug 'scrooloose/nerdtree', {'on': 'NERDTreeToggle'}
Plug 'airblade/vim-gitgutter'
Plug 'Xuyuanp/nerdtree-git-plugin'
" Shorthand notation; fetches https://github.com/junegunn/vim-easy-align
Plug 'junegunn/vim-easy-align'

Plug 'itchyny/lightline.vim'

Plug 'fatih/vim-go'

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'

Plug 'hashivim/vim-terraform'

Plug 'rhysd/git-messenger.vim', {'on': 'GitMessager'}

Plug 'stsewd/fzf-checkout.vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-commentary'

Plug 'Yggdroot/indentLine'

" Debugger plugins
Plug 'puremourning/vimspector'
Plug 'szw/vim-maximizer'

Plug 'jiangmiao/auto-pairs'
Plug 'machakann/vim-sandwich'

Plug 'voldikss/vim-floaterm'
Plug 'vim-test/vim-test'

" Initialize plugin system
call plug#end()

color dracula
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
let g:coc_global_extensions = ['coc-docker', 'coc-go', 'coc-jedi', 'coc-phpls', 'coc-tsserver', 'coc-json', 'coc-yaml', 'coc-sh']

" if hidden is not set, TextEdit might fail.
set hidden
" Better display for messages
set cmdheight=2
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
nmap <silent> gr <Plug>(coc-references)

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
nnoremap <C-f> :Telescope live_grep <CR>
nnoremap <S-b> :Telescope buffers <CR>
nnoremap <C-b> :Telescope git_branches<CR>

highlight TelescopeBorder         guifg=#ff79c6
highlight TelescopePromptBorder   guifg=#ff79c6
highlight TelescopeResultsBorder  guifg=#ff79c6
highlight TelescopePreviewBorder  guifg=#ff79c6

lua << EOF
require('telescope').setup{
	defaults = {
		prompt_prefix="🔎 ",
		file_ignore_patterns = {
		"vendor/*",
			}
	}
}
EOF


" terraform fmt on save
let g:terraform_fmt_on_save=1

" Git remaps
nnoremap <silent> <leader>gb :GBranches<CR>
nnoremap <silent> <leader>gs :Gstatus<CR>

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


