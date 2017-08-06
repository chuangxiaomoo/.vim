" ~/.vim/.cscope.vimrc|84|
" ~/.vim/.forgot_vim_skills.md
" ~/.vim/.vi_test_file
" ~/.vim/.map
"
" :helptags $VIMRUNTIME/doc
" :helptags $HOME/.vim/doc/
" :help quickref
" :help c_CTRL-R_=
"
" -------- __Forbind__ below, or disaster come along  --------------
"
"           set term=xterm 
"           map <ESC>     
"
" clean all plugin maps in <buffer>

" -------- __clear_too many__, dangerous --------
" mapclear <buffer>

syntax on
syntax enable
syntax clear Search

source ~/.vim/.cscope.vimrc
source ~/.vim/.snip.vimrc

filetype plugin on
filetype plugin indent on 

"
" set nowrapscan
" expandtab, smarttab, shiftwidth, tabstop, softtabstop
" set fileformats ff, if line end with , please check with /[^]$
"
" 无 折 返 查 找
" set nowrapscan

" no beep or flash is wanted
set vb t_vb=

set diffopt=context:1
set et sta sw=4 tabstop=4 sts=4   
set hls
set cursorline
set wildmenu
set wildmode=longest,full
set wrap nolist
"et linebreak breakat+=()
set ru
set nu
set is
set noic
set noeb vb t_vb=
set noshowmatch             "when type (),the cursor jump
set nocursorcolumn
set tabpagemax=20
set winwidth=82
set fileencodings=ucs-bom,utf-8,cp936,gb18030
set tw=10000
set fo=cqMmt                " cqMmtrol             
set cinoptions=:0           " switch case
"et autochdir 	            " when open a file, cd `dirname file`
"et scroll=10               " default is half screen when <C-D>;
set scrolloff=2
set background=light
set showcmd
set encoding=utf-8
set splitbelow nosplitright
set matchpairs+=<:>

"
" ttf relative path, and ttF obsolute 
" tty yank to xm, and ttY append --- Don't use V but v to visual mode
"

noremap ttx     :r!cat ~/bin/.warehouse/xert.sh<CR>
noremap ttd     :r!date +\%Y-\%m-\%d<CR>E
noremap ttD     :r!date +\%Y.\%m.\%d<CR>E
noremap ttt     :r!date +\%T<CR>E
noremap ttf     o<C-R>%<ESC>vB
noremap ttF     :cd /<CR>O<C-R>%<ESC>:cd -<CR>v0

nmap    ttp     :r   /dev/shm/xm<CR>
vmap    tty     :w!  /dev/shm/xm<CR>
vmap    ttY     :w >>/dev/shm/xm<CR>

"
" upper and lower case
"
vmap    ttc     :B !tr 'A-Z' 'a-z'<CR>
vmap    ttC     :B !tr 'a-z' 'A-Z'<CR>
vmap    tti     ttc:'<,'>B:s#/#_#g<CR>

 map    tth     Vtth
vmap    tth     :s#/#_#g<CR>V:s#^#int get_#g<CR>V:s#$#(void *data);#g<CR>Vttc/xkd<CR>

 map    fff     :call Save_filename()<CR>
vmap    fff     JV4<Vgq
vmap    fft     :s/  */	/g<CR>
noremap fft     :%s/  */	/g<CR>

noremap ffp     :set fileencoding=cp936<CR>:w<CR>:set fileencoding<CR>
noremap ffu     :set fileencoding=utf-8<CR>:w<CR>:set fileencoding<CR>
noremap ffx     :set tw=999<CR>ggVGd
noremap ffc     ggVGy
noremap ffv     ggVG

" vim info and session
set             sessionoptions-=curdir
set             sessionoptions+=sesdir
noremap ffs     :mksession! .session.vim<CR>
"                                           :wviminfo! .viminfo<CR>
noremap ffl     :source     .session.vim<CR>
"                                           :rviminfo  .viminfo<cR>

noremap ff3     :copen<CR>gg/\<error\>\c<CR>
noremap ff4     :copen<CR>gg/^\%(.*obsolescent\)\@!.*\zs.arning:<CR>
noremap ff5     :copen<CR>gg/undefined reference<CR>

let mapleader=','
let maplocalleader='\'

function! Recall_buf_funcs()
    if exists('b:is_sniping') | unlet b:is_sniping | endif
    call Update_snip_syntax()
endf

function! Source_comma_map()
    " Don't use map <buffer>, it will be clear by mapclear or so command
    " nore <silent> <LocalLeader>g :<CR>
    "inore <silent> <LocalLeader>g

    no <silent> <leader>`  :tabe /root/.maintaince.txt<CR>
    no <silent> <leader>1  :tabfirst<CR>
    no <silent> <leader>2  :tablast<CR>
    no          <leader>3  :grep -r "" [0-9a-zA-Z]* .[0-9a-z]*<S-Left><S-Left><Left><Left>
    no          <leader>#  :grep -r "" <C-R>%<S-Left><Left><Left>
    no <silent> <leader>4  :set et sta ts=8 sw=8 sts=8<CR>
    no <silent> <leader>5  :e <C-r>%<CR>
    no <silent> <leader>q  :q!<CR>
    "oremap     <leader>a  Occupied by Align, though ffx, no <leader>a 
    "o <silent> <leader>b  Occupied by Boxdraw BufExplorer
    no          <leader>ba :tabedit <C-R>%<C-W>h
    no <silent> <leader>c  :botright copen 11<CR>
    no          <leader>d  :cex system('  ')<Left><Left><Left>
    no <silent> <leader>e  :tabe ~/.vimrc<CR>
    no <silent> <leader>f  :set winwidth=30<CR>:NERDTreeToggle<CR>
    no <silent> <leader>g  <C-W>gF
    no          <leader>p  vi(y:tabedit <C-R>"<CR>
    no <silent> <leader>h  :sh<CR>
    no          <leader>i  :set ic<CR>
    no          <leader>m  :!Markdown.pl --html4tags <C-R>% > /winc/md.html<CR> 
    no <silent> <leader>n  :cnewer<CR>
    no <silent> <leader>o  :colder<CR>
    no <silent> <leader>r  :cclose<CR>:make!<CR><CR>:bo copen 11<CR>G
   "   same.as.    <C-X>r  :cclose<CR>:make!<CR><CR>:bo copen 11<CR>G  
   "no          <leader>s  :mapclear <buffer><CR>:source ~/.vimrc<CR>:echo ". vimrc succ!"<CR>
    no          <leader>s  :source ~/.vimrc<CR>:call Recall_buf_funcs()<CR>:echo ". vimrc succ!"<CR>
    no          <leader>x  :tabonly<CR><C-W>o
    im          <leader>>  ＞
    im          <leader><  ＜
   "im          <leader>>  <C-Q>uff1e
   "im          <leader><  <C-Q>uff1c
    "o <silent> <leader>t  Occupied by Align
    no          <leader>w  :w!<CR>

    no <S-Up>    <Up>   
    no <S-Down>  <Down> 
    no <S-Left>  <Left> 
    no <S-Right> <Right>
    "
    " Mouse keys
    " noremap <C-LeftDrag>  <LeftDrag> don't work very well
    "
    set mousetime=700
    nnoremap <RightMouse>  <4-LeftMouse>

    nnoremap <F6>          :set term=xterm mouse=a<CR>
    nnoremap <F7>          :set term=linux mouse=<CR>
    nnoremap <F8>          :call Toggle_snip_syntax()<CR>
    nnoremap <silent> <F3> :set nu<CR>
    nnoremap <silent> <F4> :set nonu<CR>
    nnoremap          <F5> :cclose<CR>:make<CR>:copen<CR><CR>

    " del
    cnoremap <C-Y>    <BS>
    cnoremap <C-O>    <Del>
    inoremap <C-Y>    <BS>
    inoremap <C-O>    <Del>
endf

"
" PuTTY -> setting -> Terminal -> Keyboard -> The Backspace key -> Control-?
" SqCRT -> Default Session -> Terminal -> simulat -> map key -> BS send delete
"

inoremap <C-K>    <Up>
inoremap <C-J>    <Down>
inoremap <C-H>    <Esc>i
inoremap <C-L>    <Right>

inoremap <C-A>    <Home>
inoremap <C-E>    <End>
inoremap <C-B>    <S-Left>
inoremap <C-F>    <S-Right>
inoremap <C-G>    <ESC>lEa

"noremap <C-K>    <ESC>lC
inoremap <C-U>    <ESC>v0c
inoremap <C-D>    <ESC> ce
inoremap <C-W>    <ESC>vbc

cnoremap <C-K>    <Up>
cnoremap <C-J>    <Down>
cnoremap <C-H>    <Left>
cnoremap <C-L>    <Right>
cnoremap <C-A>    <Home>
cnoremap <C-E>    <End>

cnoremap <C-B>    <S-Left>
cnoremap <C-F>    <S-Right>

" <C-X> is all for plugins

vmap    <C-X>.  :B s#[（“‘]#<#g\|s#[”’）]#>#g<CR>
cnor    <C-X>r  '<,'>s/\<\>//g<Left><Left><Left><Left><Left>

nmap    <C-X>c  :tabonly<CR><C-W>o:quit<CR>
nmap    <C-X>k  :call Toggle_iskey()<CR>

" 删除指定内容的行
nmap    <C-X>4  :set   expandtab<CR>:%retab!<CR>
nmap    <C-X>3  :set noexpandtab<CR>:%retab!<CR>

nmap    <C-X>r  :cclose<CR>:make!<CR><CR>:bo copen 11<CR>G
nmap    <C-X>s  :%s#\<\>##g<Left><Left><Left><Left><Left>
nmap    <C-X>t  :%s#[ \t][ \t]*$##g<CR>:%s#\t# #g<CR>:%s#  *#\t#g<CR>/xkcdef<CR>,4
vmap    <C-X>/  c/*  */<ESC><Left><Left>Pl

"
" Search & Replace & Delete & Highlight
"
nmap    <C-X>/  /\<\><Left><Left>|                  " /Word
nmap    <C-X>?  ?\<\><Left><Left>|                  " ?Word
nmap    <C-X>*  /\*\*.\{-}\*\*<CR>|                 " 高亮 markdown Strong
nmap    <C-X>`  :call Toggle_snip_syntax()<CR>|     " 高亮 嵌套语法 <F8>
nmap    <C-X>S  :%s/^\n\n\n/\r/gc|                  " Squeeze压缩三空行
nmap    <C-X>D  :%s/  *$//gc<CR>|                   " 删除行末尾的空格

" draw keys, Box or Remove
vmap    <silent> <C-X>b :B !sed -e '1s/+-/┌─/g' -e '1s/-+/─┐/g' -e '$s/+-/└─/g' -e '$s/-+/─┘/g' -e 's/-/─/g' -e 's/\|/│/g'<CR>
vmap    <silent> <C-X>r :B !sed -e 's/[+-]/ /g' -e 's/\|/ /g'<CR>

vmap    <C-X>s  :s#\<\>##g<Left><Left><Left><Left><Left>
vmap    <C-X>_  c__<ESC>Pl
vmap    <C-X><  c<><ESC>Pl
vmap    <C-X>(  c()<ESC>Pl
vmap    <C-X>[  c[]<ESC>Pl
vmap    <C-X>{  c{}<ESC>Pl
vmap    <C-X>h  c``<ESC>Pl
vmap    <C-X>`  c“”<ESC>Pl
vmap    <C-X>"  c""<ESC>Pl
vmap    <C-X>'  c''<ESC>Pl
vmap    <C-X>8  c**<ESC>Pl
vmap    <C-X>*  c****<ESC>hPl


" zc    to fold
vmap    <C-X>f  c{{{<CR><C-R>"}}}<ESC>

vmap    <C-X>u  c[]()<ESC>hhPl
imap    <C-X>u   []()<ESC>i
nmap    <C-X>u  a[]()<ESC>i

" 注意不完全初始化时，末尾追加`,`
nmap    <C-X>a  0[{jv0]}k<C-X>a
vmap    <C-X>a  :<C-U>AlignCtrl p0P0 {<CR>:'<,'>Align {<CR>:AlignCtrl p0P1 ,<CR>:'<,'>Align ,<CR>:AlignCtrl p0P0 }<CR>:'<,'>Align }<CR> 
vmap    <C-X>D  :s/^.*.*\n//g<Left><Left><Left><Left><Left><Left><Left>
vmap    <C-X>m  :<C-U>AlignCtrl Wp1P0 \\<CR>:'<,'>Align \\<CR>

" -ppi4 to format preprocess code
nmap    <C-X>i  ggVG<C-x>i
vmap    <C-X>i  :<C-U>e ++ff=unix %<CR>:%s/<C-V><C-M>//ge<CR>:'<,'>!indent -ppi4
        \ -bad -bap -nbbo -nbc -br -brs -ncdb
        \ -ce -ci4 -cli0 -cp33 -ncs -d0 -nfc1 -nfca -hnl -lp -npcs -nprs -npsl
        \ -saf -sai -saw -nsc -nsob -nss -lps -l84
        \ --no-tabs -ip0 -i4
        \ --declaration-indentation 8<CR><CR>

" markdown -> 
imap    <C-X>>  -＞

nmap <C-P>  :cp<CR>
nmap <C-N>  :cn<CR>

nmap <C-j>  :tabp<CR>
nmap <C-k>  :tabn<CR>
nmap <C-H>  viw"ly*<C-O>

" CTRL-R CTRL-F the Filename under the cursor
" CTRL-R CTRL-P the Filename under the cursor, expanded with 'path' as in |gf|
" CTRL-R CTRL-W the word under the cursor
" CTRL-R CTRL-A the W-O-R-D under the cursor; see |WORD|

vmap <C-H>  gh<C-O>
vmap <C-J>  "jy
vmap <C-K>  "ky
vmap <C-L>  "ly

" vi( is conveniet to copy if()
" use <C-V> instead of <V> to switch to VisualMode
" use <C-R>0 to paste yank via y on INSERT mode
imap <C-V>h <Esc>"hgPko
imap <C-V>j <Esc>"jgPko
imap <C-V>k <Esc>"kgPko
imap <C-V>l <Esc>"lgpko

" :vertical diffsplit FILE_RIGHT
" do        - Get changes from other window into the current window.
" dp        - Put the changes from current window into the other window.
" [c        Jump backwards to the previous start of a change.
" ]c        Jump forwards to the next start of a change.
" zo        un-fold
" zc        when normal, re-fold inside {}
"           when visual, re-fold all {} inside __SELECTed__
" zf        fold __SELECT__
set fdm=marker

" :syntax keyword {group} {keyword} ...
" 语法组 {group} -> DiffChange DiffAdd Search 
hi DiffChange                           ctermbg=0
hi DiffDelete                           cterm=reverse
hi DiffAdd                              ctermfg=0
hi CursorColumn     term=underline      cterm=underline  ctermbg=NONE ctermfg=NONE
hi htmlBold         ctermfg=DarkGreen   gui=bold guifg=DarkGreen

function! Resize_scroll()
    " check if changing
    checktime

    " 9 * {4,3,2} + 4
    if winheight(0) >= 40
       "echo 'scroll 18'
        nnoremap <C-F>  18<C-E>
        nnoremap <C-B>  18<C-Y>
        nnoremap <C-D>  18gj
        nnoremap <C-U>  18gk
    elseif winheight(0) >= 31
       "echo 'scroll 13'
        nnoremap <C-F>  13<C-E>
        nnoremap <C-B>  13<C-Y>
        nnoremap <C-D>  13gj
        nnoremap <C-U>  13gk
    else
       "echo 'scroll 8'
        nnoremap <C-F>   8<C-E>
        nnoremap <C-B>   8<C-Y>
        nnoremap <C-D>   8gj
        nnoremap <C-U>   8gk
    endif
endf

function! Toggle_iskey()
    " /usr/share/vim/vim73/syntax/progress.vim|iskeyword|   del '-'
    " /usr/share/vim/vim73/syntax/sh.vim|sh_noisk|          del '.'
    if !exists("g:toggle_iskey")
        let g:toggle_iskey = 0
    endif

    if g:toggle_iskey == 0
        echo "add ->"
        set iskeyword+=.,-,>
        let g:toggle_iskey = 1
    else
        echo "del ->"
        let g:toggle_iskey = 0
        set iskeyword-=.,-,>
    endif
endf

function! Filetype_check()
  if getline(1) =~ '^/[\*\/]' 
      setf cpp
  elseif getline(1) =~ '::'
      setf dosbatch 
  elseif getline(1) =~ '^# '
      setf markdown
      setl ai
  endif
endf

function! Word_mode(num)
    " :call Filetype_check()
    autocmd BufNewFile,BufRead,BufEnter * call Filetype_check()

    if a:num == 1
        cd /root/bin/.m1doc/
    elseif a:num == 2
        cd /root/bin/.m2doc/
    elseif a:num == 3
        cd /root/bin/.m3doc/
    elseif a:num == 0
        " http://man.lupaworld.com/content/manage/vi/doc/change.html#fo-table
        " gqq format current line
        setlocal ft=markdown
        "etlocal tw=82
        setlocal et sta ts=2 sw=2 sts=2
        setlocal fo-=a   " auto format paragraph is dangerous
        setlocal fo-=l   " Long lines are broken in insert mode
        setlocal fo+=tc  " Auto-wrap text using textwidth
        setlocal fo+=ro  " insert the current comment leader
        setlocal fo+=wn  " w & n don't work well, always 2
        setlocal fo+=Mm  " formatoptions Mm work for CJK

        " setlocal complete+=k./*
        " setlocal iskeyword+=          " change motion of 'w' '*'
    endif
endf

let g:is_in_tlist = 0
function! Update_Tlist_nor()
    if mode() == 'n' || mode() == 'i'
        if g:is_in_tlist == 0
            silent! TlistHighlightTag
        endif
    endif
endf

" if bufname("%") == "" 

if has("autocmd")
 augroup vimrcEx
 au!
 autocmd BufReadPost *
   \ if line("'\"") > 1 && line("'\"") <= line("$") |
   \   exe "normal! g`\"" |
   \ endif
 augroup END

 autocmd! bufwritepost                 .vimrc source %
 autocmd  BufNewFile Makefile          0r ~/.vim/skeleton/Makefile
 autocmd  BufNewFile Makefile.prj      0r ~/.vim/skeleton/Makefile.prj
 autocmd  BufNewFile README            0r ~/.vim/skeleton/README
 autocmd  BufNewFile *.py              0r ~/.vim/skeleton/skeleton.py

 autocmd  BufEnter,BufRead             *.u   setlocal ft=markdown
 autocmd  BufEnter,BufNewFile,BufRead  *.pl  setlocal makeprg=perl\ %
 autocmd  BufEnter,BufNewFile,BufRead  *.py  setlocal makeprg=python\ %
 autocmd  BufEnter,BufNewFile,BufRead  *.sh  setlocal makeprg=/bin/bash\ %
 "utocmd  FileType ruby                      setlocal makeprg=ruby\ %           iskeyword+=_,$,@,%,#,-
 autocmd  FileType sh                        setlocal makeprg=bash\ %           iskeyword-=.
 autocmd  FileType php                       setlocal makeprg=php\ %           iskeyword-=.
 autocmd  FileType text                      setlocal textwidth=80
 autocmd  FileType mysql                     setlocal complete+=k~/.vim/wordlists/mysql.list
 autocmd  FileType mysql                     nmap <C-L>a :grep "CREATE PROCEDURE" <C-R>%<CR><CR>
 autocmd  FileType make                      imap <localleader>svv $()<left>
 autocmd  BufEnter,BufNewFile,BufRead  *.rc  setlocal ft=sh
 autocmd  BufEnter,BufNewFile,BufRead  *.sh  setlocal complete+=k~/.vim/bash-support/wordlists/bash.list
 autocmd  BufEnter,BufRead             *.inc setlocal ft=sh
 autocmd  BufEnter,BufRead             *.i   setlocal ft=cpp ai | call Update_snip_syntax()
 autocmd  BufEnter,BufRead             *sql* setlocal ft=mysql
 autocmd  BufEnter,BufRead           chan.md cd ~/bin/stk/.chan/
 autocmd  BufEnter,BufNewFile,BufRead  *.bsp setlocal ft=make

 " end
 autocmd  BufEnter,BufNewFile,BufRead m[0-9] set path=,,
 autocmd  BufEnter,BufNewFile,BufRead    m1  call Word_mode(1)
 autocmd  BufEnter,BufNewFile,BufRead    m2  call Word_mode(2)
 autocmd  BufEnter,BufNewFile,BufRead    m3  call Word_mode(3)

 autocmd  WinEnter,BufNew,BufEnter,BufRead  *   call Introduce_boxdraw()
 autocmd  WinEnter,BufNew,BufEnter,BufRead  *   call Resize_scroll()

 " Tlist refresh
 autocmd  CursorMoved,CursorMovedI *            call Update_Tlist_nor()
"autocmd  BufEnter __Tag_List__                 let  g:is_in_tlist = 1
"autocmd  BufLeave __Tag_List__                 let  g:is_in_tlist = 0

 " FileType
 autocmd  FileType c        setlocal   path=.,/usr/include,/usr/local/include,, iskeyword-=!
 autocmd  FileType cpp      setlocal   path=.,/usr/include,/usr/local/include,, iskeyword-=!
 autocmd  FileType c        setlocal   complete+=k~/.vim/c-support/wordlists/c-c++-keywords.list
 autocmd  FileType cpp      setlocal   complete+=k~/.vim/c-support/wordlists/*
 autocmd  FileType python   setlocal   complete+=k~/.vim/pydiction-1.2/pydiction.py
 autocmd  FileType python   setlocal   et sta sw=4 sts=4 scrolloff=1
 autocmd  FileType markdown setlocal   et sta ts=2 sw=2 sts=2 | call Update_snip_syntax()
 autocmd  FileType xml      setlocal   et sta ts=2 sw=2 sts=2
endif


" user register y
" 
    "o            <C-W>b  buff
    "o            <C-W>c  org is close, overload to :tabonly
    "o            <C-W>o  current window the only one
    "o            <C-W>q  quit, so frequently, so a more convenient key
    "o            <C-W>s  split window
    "o            <C-W>v  vspli window

    no <silent>   <C-W>c  :tabonly<CR><C-W>o
    no <silent>   <C-W>d  :50vs ~/bin/stk/dbank<CR>ggn$h
    no            <C-W>e  :vs<CR>:e <C-R><C-F><CR>
    no <silent>   <C-W>f  :cclose<CR>:tabedit <C-R>%<CR>
    no            <C-W>t  :tabedit 
    no            <C-W>m  mF:e ~/bin/m
    no            <C-W>x  mF:e /dev/shm/xm<CR>
nnoremap          <C-W>.  0*:sp .codelist<CR>nyy:q<CR>pk
nnoremap          <C-W>/  :only<CR>0*:sp .soptter.nb.md<CR>n

"
" ---------------- <C-M> double for quickfix jump -----------------------
"
nnoremap          <C-M>b  :!man bash<CR>
nnoremap          <C-M>B  :set ft=sh<CR>
nnoremap          <C-M>c  mA[{0f_lvf(h"yy`A:r!~/bin/7Lite 0 <C-R><C-A> <C-R>y <C-R>%<CR>f{
nnoremap          <C-M>d  ?\<<C-R><C-F>(\\|fn_<C-R><C-F>(\\|<C-R><C-W>=<CR>
nnoremap          <C-M>f  lbvey[[2kO<ESC>:r!~/bin/7Lite 0 <C-R>0<CR>
" fn_<C-R>0

nnoremap <silent> <C-M>k  mA*`A:sp +b /dev/shm/ma<CR>:bd! {/run/shm/ma}<CR>`A:!MANWIDTH=88 ma <cword><CR>:cclose<CR>:25sp /dev/shm/ma<CR>:set ic nonu ft=c<CR>
nnoremap          <C-M>sd :!svn di <C-R><C-F><CR>
nnoremap          <C-M>sl :!svn log  <C-R><C-F><CR>

nnoremap          <C-M>u  :e ++ff=unix %
nnoremap          <C-M>w  :call Word_mode(0)<CR>
nnoremap          <C-M>W  :call Filetype_check()<CR>
nnoremap      <C-M><C-M>  <CR>

" ---------------- Goyo  ~/.vim/autoload/goyo.vim -----------------------
nnoremap          <C-W>g  :Goyo<CR>
let g:goyo_width = 108
let g:goyo_height = 96
let g:goyo_margin_top = 0
let g:goyo_margin_bottom = 0
let g:goyo_linenr = 1

function! s:goyo_enter()
    nm  j gj
    nm  k gk
    nm  <C-j> <Down>
    nm  <C-k> <Up>
    nm  <silent> <leader>c  :cclos<CR>
    nm  <silent> <leader>o  :copen<CR>
    no  <silent> <leader>q   mM:q!<CR>`M
    set nocursorline
endfunction

function! s:goyo_leave()
    nun j
    nun k
    no  <C-j>  :tabp<CR>
    no  <C-k>  :tabn<CR>
    no  <silent> <leader>c  :botright copen 11<CR>
    no  <silent> <leader>o  :colder<CR>
    no  <silent> <leader>q  :q!<CR>
    set cursorline
endfunction

autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()

"
" <C-C> can also interrupt grep, register 'y' is used in below <C-C>
" reg 0~9 are used for yank and del, do occupy them
" x is the default register of motion d x p 
" yp just yank, ygp will put a newline
"

imap <C-C><C-S> <Esc>:w<CR>
nmap <C-C><C-S> <Esc>:w<CR>
vmap <C-C><C-S> <Esc>:w<CR>

imap <C-C><C-A> <Esc>ggVG
nmap <C-C><C-A> <Esc>ggVG

vmap <C-C><C-C> "yy
vmap <C-C><C-X> "yx

vmap <C-C><C-V> "xx"yP
imap <C-C><C-V> <Esc>"ypa
nmap <C-C><C-V> "yp

" unexpectalbe <C-C>
nmap <C-L><C-C> <C-L>
nmap <C-W><C-C> <C-W>

function! Escape_char(orgstr)
    " % not in the list
    " can't search string include '
    let b:tmpstr = a:orgstr

    let b:tmpstr = substitute(b:tmpstr, '', '', 'g')
    let b:tmpstr = substitute(b:tmpstr, '\[', '\\&', 'g')
    let b:tmpstr = substitute(b:tmpstr, '\]', '\\&', 'g')
    let b:tmpstr = substitute(b:tmpstr, '[.*^/?~$]', '\\&', 'g')

    return b:tmpstr
endf

" 缩写后面输入[Ctrl+V]取消替换
function! Ab_c()
    iab #i #include
    iab #w while
endf

call Ab_c()
call Source_comma_map()
call Resize_scroll()

"
"  gA    Append current word to highlight list
"  gh    highlight current path or WORD
" vgh    highlight selected
"
"        viW 选中一个块WORD
"
nmap gA mG/<C-R>/\\|<C-R><C-W><CR>`G
vmap gA <C-L>mG/<C-R>/\\|<C-R>l<CR>`G
nmap gh /<C-R>=Escape_char('<C-R><C-F>')<CR><CR>
vmap gh  "yy/<C-R>=Escape_char('<C-R>y')<CR><CR>

" copy a CHAR 
nmap X vy
vmap X y

