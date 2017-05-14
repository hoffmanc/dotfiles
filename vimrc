execute pathogen#infect()

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

" Ctrl-P settings
let g:ctrlp_max_height = 20
if executable('ag')
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
endif

" Sane Ignore For ctrlp
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\.git$\|\.hg$\|\.svn$\|\.yardoc$\|public\/images$\|public\/system$\|data$\|log$\|tmp\|lib\/thincloud_base',
  \ 'file': '\.exe$\|\.so$\|\.dat$'
  \ }

" Checktime reloads files editted outside vim (git)
nnoremap <leader>q :checktime<CR>

" Random Leader Commands
nnoremap <leader>a :tabe\|:Ag
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
au FileType cucumber setlocal shiftwidth=2 tabstop=2
au FileType ruby setlocal shiftwidth=2 tabstop=2
au BufRead,BufNewFile *.thor set filetype=ruby
au BufRead,BufNewFile *.rabl set filetype=ruby
au BufRead,BufNewFile *.axlsx set filetype=ruby
au BufRead,BufNewFile *.hamljs set filetype=haml

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
        let g:test_type = 'be rspec'
      else
        let g:test_type = 'be spring rspec'
      end
    end
  end
  return g:test_type
endfunction

function! RunAll()
  let test_type = TestType()
  if test_type == "rails"
    "let cmd = "ruby -Itest"
    let cmd = "bin/rake test"
  elseif test_type == "rails5"
    let cmd = "rails test"
  else
    let cmd = test_type
  endif
  let cmd = cmd . " " . expand("%")
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

function! GemDoc()
  let wordUnderCursor = expand("<cword>")
  exe "silent !launchy https://rubygems.org/gems/" . wordUnderCursor | redraw!
endfunction

nnoremap <leader>sg :call GemDoc()<CR>

set nobackup
set directory=/tmp/
set undodir=/tmp/
set eol

nmap <leader>p o<ESC>p
nmap <leader>P o<ESC>P

let g:elm_format_autosave = 1

" Kill trailing whitespace
autocmd FileType c,cpp,java,php,ruby,css,js,coffee autocmd BufWritePre <buffer> :%s/\s\+$//e
