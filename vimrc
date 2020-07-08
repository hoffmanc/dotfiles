execute pathogen#infect()

set hidden
set nocompatible
filetype off
syntax enable

" Set , as leader key
let mapleader = ","

" set true colors
if has("termguicolors")
  set t_8f=[38;2;%lu;%lu;%lum
  set t_8b=[48;2;%lu;%lu;%lum
  set termguicolors
endif

colorscheme gruvbox

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
let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
" ag is fast enough that CtrlP doesn't need to cache
let g:ctrlp_use_caching = 0

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
        if empty(spring_rspec)
          let g:test_type = 'bundle exec rspec '
        else
          let g:test_type = 'bundle exec rspec '
        end
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
autocmd BufWritePre *.js,*.jsx,*.css,*.json,*.md,*.yaml,*.html Prettier

set background=dark
let g:go_fmt_command = "goimports"
let g:go_rename_command = "gopls"

nnoremap <leader>n :set paste<CR>
nnoremap <leader>N :set nopaste<CR>
