set hidden
set nocompatible
filetype off
syntax enable

" set the runtime path to include Vundle and initialize
" git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

set rtp+=~/.config/nvim/bundle/Vundle.vim
call vundle#begin()
Plugin 'fatih/vim-go'
Plugin 'jpalardy/vim-slime'
Plugin 'jremmen/vim-ripgrep'
Plugin 'kien/ctrlp.vim'
Plugin 'morhetz/gruvbox'
Plugin 'MaxMEllon/vim-jsx-pretty'
Plugin 'pangloss/vim-javascript'
Plugin 'prettier/vim-prettier'
Plugin 'SirVer/ultisnips'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-eunuch'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-repeat'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-unimpaired'
Plugin 'dense-analysis/ale'
Plugin 'godlygeek/tabular'
Plugin 'jasonccox/vim-wayland-clipboard'
Plugin 'jparise/vim-graphql'
Plugin 'nvim-lua/plenary.nvim'
Plugin 'nvim-telescope/telescope.nvim'
Plugin 'VundleVim/Vundle.vim'
call vundle#end()
filetype plugin indent on " required

" Set , as leader key
let mapleader = ","

" set true colors
if has("termguicolors")
  set t_8f=[38;2;%lu;%lu;%lum
  set t_8b=[48;2;%lu;%lu;%lum
  set termguicolors
endif

colorscheme gruvbox

lua << EOF
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
EOF

" disable toolbar
set guioptions-=T
set hlsearch
set backspace=2

set clipboard=unnamed

set relativenumber
set number
set lazyredraw
set cursorline

filetype plugin indent on

let g:wakatime_ScreenRedraw = 1
"
"
" Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
" let g:ctrlp_user_command = 'rg %s -l'
" ag is fast enough that CtrlP doesn't need to cache
"
if executable('rg')
  set grepprg=rg\ --color=never
  let g:ctrlp_user_command = 'rg %s --files --color=never --glob ""'
  let g:ctrlp_use_caching = 0
else
  let g:ctrlp_clear_cache_on_exit = 0
endif
 
"" Ctrl-P and ack.vim settings
"let g:ctrlp_max_height = 20
"if executable('ag')
  "let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
  "let g:ctrlp_match_func = { 'match': 'pymatcher#PyMatch' }
  "let g:ackprg = 'ag --vimgrep'
"endif

"" Sane Ignore For ctrlp
"let g:ctrlp_custom_ignore = {
  "\ 'dir':  '\.git$\|\.hg$\|\.svn$\|\.yardoc$\|public\/images$\|public\/system$\|data$\|log$\|tmp\|lib\/thincloud_base\|vendor',
  "\ 'file': '\.exe$\|\.so$\|\.dat$'
  "\ }

" Checktime reloads files editted outside vim (git)
nnoremap <leader>q :checktime<CR>

" Random Leader Commands
nnoremap <leader>g :tabe\|:Ag
nnoremap <leader>{ :Tabularize /{

" Clear highlighting
map <C-h> :nohl<CR>

" Press Shift+P while in visual mode to replace the selection without
" overwriting the default register
vmap P p :call setreg('"', getreg('0')) <CR>

" Search mappings: These will make it so that going to the next one in a
" search will center on the line it's found in.
map N Nzz
map n nzz

" Set tab to 2 spaces
set expandtab
set shiftwidth=2
set tabstop=2

au FileType html setlocal shiftwidth=2 tabstop=2
au FileType javascript setlocal shiftwidth=2 tabstop=2
au FileType coffee setlocal shiftwidth=2 tabstop=2
au FileType ruby setlocal shiftwidth=2 tabstop=2
au BufRead,BufNewFile *.thor set filetype=ruby
au BufRead,BufNewFile *.rabl set filetype=ruby
au BufRead,BufNewFile *.axlsx set filetype=ruby
au BufRead,BufNewFile *.hamljs set filetype=haml
au BufRead,BufNewFile *.inky let b:eruby_subtype='html'
au BufRead,BufNewFile *.inky set filetype=eruby 
au FileType xml setlocal equalprg=xmllint\ --format\ --recover\ -\ 2>/dev/null

" toggle red line at 101st character to keep lines under 80 chars
function! g:ToggleRedline()
  if(&colorcolumn == 101)
    set colorcolumn=0
  else
    set colorcolumn=101
  endif
endfunc
nnoremap <leader>L :call g:ToggleRedline()<cr>

" Populate args list with files in the quickfix window. Obtained from.. http://stackoverflow.com/questions/5686206/search-replace-using-quickfix-list-in-vim
command! -nargs=0 -bar Qargs execute 'args ' . QuickfixFilenames()
function! QuickfixFilenames()
  " Building a hash ensures we get each buffer only once
  let buffer_numbers = {}
  for quickfix_item in getqflist()
    let buffer_numbers[quickfix_item['bufnr']] = bufname(quickfix_item['bufnr'])
  endfor
  return join(values(buffer_numbers))
endfunction

" Test running helpers
function! TmuxRun(cmd)
  exe "silent !tmux send-keys -t ':0.0' C-z " . shellescape(a:cmd) . " Enter" | redraw!
  let g:last_minitest_command = a:cmd
endfunction

function! RunLast()
  call TmuxRun(g:last_minitest_command)
endfunction

function! TestType()
  if !exists('g:test_type')
    let filename = expand("%") 
    if filename =~? '.go$'
      let g:test_type = 'go'
    else
      let rspec = system('grep rspec Gemfile')
      let spring_rspec = system('grep spring-commands-rspec Gemfile')
      if empty(rspec)
        let rails_version = system('rails -v')
        if empty(matchstr(rails_version, " 5"))
          let g:test_type = 'rails'
        else
          let g:test_type = 'rails5'
        endif
      else
        let g:test_type = 'dk exec web rspec'
      end
    end
  end
  return g:test_type
endfunction

function! RunAll()
  let test_type = TestType()
  if test_type == "go"
    let cmd = "go test -run "
    let cmd = cmd . "Test" . strpart(expand("%:t"),0,strlen(expand("%:t")) - 8)
  elseif test_type == "rails"
    let cmd = "bin/rake test TEST=" . expand("%")
  elseif test_type == "rails5"
    let cmd = "rails test TEST=" . expand("%")
  else
    let cmd = test_type . expand("%")
  endif
  call TmuxRun(cmd)
endfunction

function! RunLine()
  let test_type = TestType()
  if test_type == "rails"
    let cmd = "m"
  elseif test_type == "rails5"
    let cmd = "rails test"
  else
    let cmd = test_type
  endif
  let cmd = cmd . " " . expand("%") . ":" . line(".")
  call TmuxRun(cmd)
endfunction

nnoremap <leader>l :call RunLine()<CR>
nnoremap <leader>a :call RunAll()<CR>
nnoremap <leader>R :call RunLast()<CR>

function! Migrate()
  call TmuxRun("rake db:migrate && RAILS_ENV=test rake db:migrate")
endfunction

function! Rollback()
  call TmuxRun("rake db:rollback && RAILS_ENV=test rake db:rollback")
endfunction

function! Redo()
  call TmuxRun("rake db:migrate:redo && RAILS_ENV=test rake db:migrate:redo")
endfunction

nnoremap <leader>rm :call Migrate()<CR>
nnoremap <leader>rr :call Rollback()<CR>
nnoremap <leader>re :call Redo()<CR>

function! GemDoc()
  let wordUnderCursor = expand("<cword>")
  exe "silent !launchy https://rubygems.org/gems/" . wordUnderCursor | redraw!
endfunction

nnoremap <leader>sg :call GemDoc()<CR>


set directory=~/.vim/swap//
set backupdir=~/.vim/backup//
set undofile
set undodir=~/.vim/undo//
set eol

set undolevels=1000
set undoreload=10000

" force newline when putting yanked inline strings
nmap <leader>p o<ESC>p
nmap <leader>P o<ESC>P

let g:elm_format_autosave = 1

" Kill trailing whitespace
autocmd FileType c,cpp,java,php,ruby,css,js,javascript.jsx,coffee,dockerfile autocmd BufWritePre <buffer> :%s/\s\+$//e

let g:prettier#autoformat = 0
" autocmd BufWritePre *.js,*.jsx,*.css,*.json,*.md,*.yaml,*.html Prettier

set background=dark
let g:go_fmt_command = "goimports"
let g:go_rename_command = "gopls"
let g:go_highlight_diagnostic_warnings = 0

nnoremap <leader>n :set paste<CR>
nnoremap <leader>N :set nopaste<CR>

let s:last_go_run = ""

function! g:CurrentGoSuiteTest()
  let s:last_go_run = "./..."
  call g:LastGoFileTest()
endfunc
nnoremap <leader>rs :call g:CurrentGoSuiteTest()<CR><C-L>

function! g:CurrentGoFileTest()
  let s:last_go_run = expand("%")
  call g:LastGoFileTest()
endfunc
nnoremap <leader>rf :call g:CurrentGoFileTest()<CR><C-L>

function! g:CurrentGoFuncTest()
  let temp = system("~/src/pico-mes/testReducer -file " . expand("%") . " -line " . line("."))
  let s:last_go_run = substitute(temp, '\n', '', 'g')
  call g:LastGoFileTest()
endfunc
nnoremap <leader>rl :call g:CurrentGoFuncTest()<CR><C-L>

function! g:LastGoFileTest()
  :execute "! tmux send -t :mes.0 'clear' Enter"
  :execute "! tmux send -t :mes.0 'dk exec -e GIN_MODE=release mes_test go test " . s:last_go_run . " -v' Enter"
endfunc
nnoremap <leader>rr :call g:LastGoFileTest()<CR><C-L>

" ale
let g:ale_lint_delay = 1000
let g:ale_linters = { 'rust': ['cargo', 'rls'] }
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'bash': ['shellcheck'],
\   'c': ['clang'],
\   'cpp': ['clang'],
\   'css': ['prettier'],
\   'graphql': ['prettier'],
\   'go': ['gofmt'],
\   'html': ['tidy', 'tidy'],
\   'javascript': ['prettier', 'eslint'],
\   'json': ['prettier', 'fixjson'],
\   'markdown': ['prettier'],
\   'rust': ['rustfmt'],
\   'svg': ['tidy'],
\   'typescript': ['prettier', 'eslint'],
\   'vim': ['vimls'],
\}
let g:ale_rust_rls_toolchain = 'stable'
let g:ale_completion_enabled = 1
let g:ale_completion_autoimport = 1
let g:ale_fix_on_save = 1

autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescript
autocmd BufNewFile,BufRead *.graphql set filetype=graphql
autocmd BufWritePre *.js,*.jsx,*.ts,*.tsx,*.css,*.json,*.md Prettier

nnoremap <silent> <leader>f :ALEFix<cr>
nnoremap <silent> <leader>I :ALEGoToDefinition -split<cr>
nnoremap <silent> <leader>i :ALEDetail<cr>

inoremap <silent><expr> <Tab> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <silent><expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-TAB>"
