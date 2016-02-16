execute pathogen#infect()

set nocompatible
filetype off
syntax enable

" Set , to be leader key
let mapleader = ","

set background=dark
colorscheme solarized
set guifont=AndaleMono:h14
set guioptions-=T
set hlsearch
set backspace=2

set clipboard=unnamed

" Dont ask to re-read files changed outside vim
set autoread

set relativenumber
set number
set lazyredraw
set cursorline

" original repos on github
"git clone git://github.com/tpope/vim-pathogen
"git clone git://github.com/tpope/vim-fugitive
"git clone git://github.com/tpope/vim-surround
"git clone git://github.com/tpope/vim-unimpaired
"git clone git://github.com/tpope/vim-repeat
"git clone git://github.com/tpope/vim-rails
"git clone git://github.com/mileszs/ack.vim
"git clone git://github.com/scrooloose/nerdcommenter
"git clone git://github.com/kien/ctrlp.vim
"git clone git://github.com/thoughtbot/vim-rspec
"git clone git://github.com/godlygeek/tabular
"git clone git://github.com/tpope/vim-eunuch

filetype plugin indent on
"set ignorecase

"" Configure vim-rspec
"let s:rspec_tmux_command = "tmux send -t primary.0 'rspec --drb {spec}' Enter" 
"let g:rspec_command = "!echo " . s:rspec_tmux_command . " && " . s:rspec_tmux_command
"nnoremap <leader>rr :silent call RunNearestSpec()<CR><c-L>
"nnoremap <leader>rf :silent call RunCurrentSpecFile()<CR><c-L>
"nnoremap <leader>rl :silent call RunLastSpec()<CR><c-L>

" Configure vim-slime
let g:slime_target = "tmux"
let g:slime_default_config = {"socket_name": "default", "target_pane": ":2.1"}

" Ctrl-P settings
let g:ctrlp_max_height = 20
set wildignore+=*/tmp/*
set wildignore+=*/node_modules/*
if executable('ag')
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
endif

" Checktime reloads files editted outside vim (git)
nnoremap <leader>q :checktime

" Toggle line number Ctrl-N
nmap <C-N><C-N> :set invnumber<CR>

" Random Leader Commands
nnoremap <leader>a :tabe\|:Ack 
nnoremap <leader>g :Git
nnoremap <leader>4 :tabclose<CR>
nnoremap <leader>. :! 
nnoremap <leader>{ :Tabularize /{

" Clear highlighting
map <C-h> :nohl<cr>

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
"function! g:ToggleRedline()
  "if(&colorcolumn == 101)
    "set colorcolumn=0
  "else
    "set colorcolumn=101
  "endif
"endfunc
"nnoremap <leader>l :call g:ToggleRedline()<cr>

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

" Function for swapping splits. Obtained from.. http://stackoverflow.com/questions/2586984/how-can-i-swap-positions-of-two-open-files-in-splits-in-vim
function! MarkWindowSwap()
    let g:markedWinNum = winnr()
endfunction

function! DoWindowSwap()
    "Mark destination
    let curNum = winnr()
    let curBuf = bufnr( "%" )
    exe g:markedWinNum . "wincmd w"
    "Switch to source and shuffle dest->source
    let markedBuf = bufnr( "%" )
    "Hide and open so that we aren't prompted and keep history
    exe 'hide buf' curBuf
    "Switch to dest and shuffle source->dest
    exe curNum . "wincmd w"
    "Hide and open so that we aren't prompted and keep history
    exe 'hide buf' markedBuf 
endfunction

nmap <silent> <leader>mn :call MarkWindowSwap()<CR>
nmap <silent> <leader>ms :call DoWindowSwap()<CR>
""" END SWAPPING SPLITS """

function! TmuxRun(cmd)
  exe "silent !tmux send-keys -t ':0.0' C-z " . shellescape(a:cmd) . " Enter" | redraw!
  let g:last_minitest_command = a:cmd
endfunction

function! RunLast()
  call TmuxRun(g:last_minitest_command)
endfunction

function! TestType()
  let rspec = system('grep rspec Gemfile')
  if empty(rspec)
    let rails_version = system('rails -v')
    if empty(matchstr(rails_version, " 5"))
      return 'rails'
    else
      return 'rails5'
    endif
  else
    return 'rspec'
  end
endfunction

function! RunAll()
  let test_type = TestType()
  if test_type == "rails"
    let cmd = "ruby -Itest"
  elseif test_type == "rails5"
    let cmd = "rails test"
  else
    let cmd = "be rspec"
  endif
  let cmd = cmd . " " . expand("%")
  call TmuxRun(cmd)
endfunction

function! RunLine()
  let test_type = TestType()
  if test_type == "rails"
    let cmd = "m"
  else if test_type == "rails5"
    let cmd = "rails test"
  else
    let cmd = "be rspec"
  endif
  let cmd = cmd . " " . expand("%") . ":" . line(".")
  call TmuxRun(cmd)
endfunction

nnoremap <leader>l :call RunLine()<CR>
nnoremap <leader>a :call RunAll()<CR>
nnoremap <leader>R :call RunLast()<CR>

set nobackup
set directory=/tmp/
set undodir=/tmp/

nmap <leader>p o<ESC>p
nmap <leader>P o<ESC>P

" Sane Ignore For ctrlp
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\.git$\|\.hg$\|\.svn$\|\.yardoc\|public\/images\|public\/system\|data\|log\|tmp$',
  \ 'file': '\.exe$\|\.so$\|\.dat$'
  \ }
