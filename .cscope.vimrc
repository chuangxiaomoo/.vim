" ---------------------- menu color     -------------------------------
set completeopt=menuone
highlight Pmenu     ctermbg=5 guibg=LightMagenta
highlight PmenuSel  ctermfg=5 ctermbg=7 guibg=Grey

" ---------------------- clang complete -------------------------------
let g:clang_user_options='|| exit 0'
let g:clang_complete_auto = 0
let g:clang_complete_copen = 0
let g:clang_close_preview=0

" ---------------------- BufExplorer ----------------------------------
" http://zhouliang.pro/2012/06/28/vim-buffer/
" # the alternate buffer for ":e #" and CTRL-^
let g:bufExplorerDefaultHelp=0       " Do not show default help.
let g:bufExplorerShowRelativePath=1  " Show relative paths.
let g:bufExplorerSortBy='mru'        " Sort by most recently used.
let g:bufExplorerSplitRight=0        " Split left.
let g:bufExplorerSplitVertical=1     " Split vertically.
let g:bufExplorerSplitVertSize=36    " Split width
let g:bufExplorerUseCurrentWindow=0  " Open in new window.

" ---------------------- NERD Tree ------------------------------------
"et NERDTreeIgnore=['\.o$', '\.a$', '\.out$', '^tags$', '\.sh$', '\~$']
let NERDTreeIgnore=['\.o$', '\.a$', '\.out$', '^tags$', '\~$']
let NERDTreeSortOrder=['\.c$', '\.h$', '*', '\/$']
let NERDTreeChDirMode=0	" the NerdTree never change CWD
let NERDChristmasTree=1
let NERDTreeAutoCenter=1
let NERDTreeBookmarksFile=$VIM.'\Data\NerdBookmarks.txt'
let NERDTreeMouseMode=2
let NERDTreeShowBookmarks=1
let NERDTreeShowFiles=1
let NERDTreeShowHidden=0
let NERDTreeShowLineNumbers=0
let NERDTreeWinPos='right'
let NERDTreeWinSize=40

" ---------------------- Taglist <F1> to show help --------------------
let Tlist_Inc_Winwidth=0
let Tlist_WinWidth=30
let Tlist_Show_One_File=1       " on dfl, show all tags in the buf
let Tlist_Exit_OnlyWindow=1     " on dfl, if only the Tlist is open, can't close the window
let Tlist_Enable_Fold_Column=0  " no  
let Tlist_Display_Prototype=0   " prototype
"et Tlist_Compact_Format=1      " blank line between section macro, variable and function

" ---------------------- c-support ------------------------------------
let g:C_Styles = { '*.c,*.h' : 'default', '*.cc,*.cpp,*.hh' : 'CPP' }

"
"cscope=============================================================
set cscopequickfix=s-,c-,d-,i-,t-,e-,g-,f-         "cw to check on qkfix
if has("cscope")
        set csprg=/usr/bin/cscope
        set nocsverb
        set cst
        set csto=0

        " add any database in current directory
        if filereadable(".cscope.out")
            cs add .cscope.out

        " else add database pointed to by environment
        endif

        "et tags+=.cscope.out
        set csverb
endif

function! QfMakeConv()
   let qflist = getqflist()
   for i in qflist
      let i.text = iconv(i.text, "cp936", "utf-8")
   endfor
   call setqflist(qflist)
endfunction


" -------------------  cscope  ----------------------------------------
" USAGE: cs add [prepath]/cscope.out [prepath] [flags]
"        [prepath] is the pathname after `cscope -P`
"        e.g. /usr/include/
"
" cd /usr/include && cscope -Rbq -P`pwd` -f .cscope.out
"
let csdir="/usr/include"
let csfile = ": cs add " . csdir . "/.cscope.out " . csdir
function! Cs_add_file()
        :execute g:csfile
endfunct

function! Save_filename()
   "let g:save_filename = expand('%:p')
    let @z=expand('%:p')
endf

" GBK编码转UTF-8
nmap <C-L>q :call QfMakeConv()<CR>
" markdown标题列表
"map <C-L>l :cclose<CR>:vimgrep /^[\-.*#]#* \\|^[0-9a-z][0-9]*\. /j <C-R>%<CR>:copen<CR>G<C-W>k
nmap <C-L>6 :cclose<CR>:vimgrep /^\[^/j  <C-R>%<CR>:copen<CR>G<C-W>k
nmap <C-L>l :cclose<CR>:vimgrep /^##* /j <C-R>%<CR>:copen<CR>G<C-W>k
nmap <C-L>h :cclose<CR>:vimgrep /^# /j <C-R>%<CR>:copen<CR>G<C-W>k
nmap <C-L>j mfmF:view  .flowchar.i<CR>
nmap <C-L>k mfmF:view  <C-R>z<CR>

"
" L mean Location
"

nmap <silent> <C-L>o   :let Tlist_Display_Prototype=1<CR>:TlistUpdate<CR>:let Tlist_WinWidth=80<CR>:Tlist<CR>
nmap <silent> <C-L>t   :TlistUpdate<CR>:set winwidth=30<CR>:TlistOpen<CR>
nmap <silent> <C-L>T   :w<CR>:TlistUpdate<CR>:TlistHighlightTag<CR>
"map          <C-L>T   :TlistSync

"
" 1~4 is reserved for markdown
"
"
nmap <C-L>$  mE`CmD`BmC`AmB`EmA:echo "Refreshed DCBA!"<CR>
nmap <C-L>5  $a     <ESC>:w<CR>
nmap <C-L>7  :set isk+=-<CR>viw<C-L>l:let @l=substitute(@l, '201.', '201.', 'g')<CR>/<C-R>l<CR>
nmap <C-L>%   /     $<CR>
nmap <C-L>m  :marks ABCD<CR>
nmap <C-L>a  :cs find s 

"use [.] to  match literal symbol '.', and [*] as '*'
nmap <C-L>e  :cs find e <C-R>=expand("<cword>")<CR>
nmap <C-L>E  :let @l=substitute(@l, '(', '.', 'g')<CR>:cs find e <C-R>l<CR>

nmap <C-L>r  :cclose<CR>:60vs Makefile<CR>:%s/run\ r://e<CR>u h
nmap <C-L>p  mF:e .cscope.files<CR>
nmap <C-L>P  mF:tabedit .cscope.files<CR>

" 1st time, run `csgen` on command; `csgen -f` convenient for customize .cscope.file 
nmap <C-L>z  :cs kill .cscope.out<CR>:!csgen -f<CR>:cs add .cscope.out<CR>jk
nmap <C-L>Z  :cs kill .cscope.out<CR>:!csgen -u<CR>:cs add .cscope.out<CR>jk
nmap <C-L>A  :execute Cs_add_file()<CR>

"
" map cs, scs, vert scs 
"
" __attention__: cscope g
"   Nor does it recognize function definitions with a function pointer argument
"

nmap <C-L>c  :cs find c <C-R>=expand("<cword>")<CR><CR>
nmap <C-L>d  :cs find d <C-R>=expand("<cword>")<CR><CR>
nmap <C-L>f  :cs find f <C-R>=expand("<cfile>")<CR><CR>
nmap <C-L>i  :cs find i <C-R>=expand("<cfile>")<CR><CR>
nmap <C-L>s  :cs find s <C-R>=expand("<cword>")<CR><CR>
nmap <C-L>g  :cs find g <C-R>=expand("<cword>")<CR><CR>

nmap <C-L>C  :vert scs find c <C-R>=expand("<cword>")<CR><CR>
nmap <C-L>D  :vert scs find d <C-R>=expand("<cword>")<CR><CR>
nmap <C-L>F  :vert scs find f <C-R>=expand("<cfile>")<CR><CR>
nmap <C-L>G  :vert scs find g <C-R>=expand("<cword>")<CR><CR>
"map <C-L>I  :vert scs find i <C-R>=expand("<cfile>")<CR><CR>
"map <C-L>S  :vert scs find s <C-R>=expand("<cword>")<CR><CR>

" cp current file to clipboard -- help expand()
" :p expand to full path
" :h head (last path component removed)
" :t tail (last path component only)
nmap <C-L>y  :let @y = expand("%:t")<CR>
nmap <C-L>Y  :let @y = expand("%:p")<CR>

"
" k for C/C++ keyword
"
nmap <silent> <C-L>`  :copen<CR>/>>[^,]*\(typedef\\|struct\\|enum\\|union\\|define\\|case\\|class\)<CR>

