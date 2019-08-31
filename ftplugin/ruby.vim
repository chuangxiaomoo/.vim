" Vim filetype plugin
" Language:		Ruby
" Maintainer:		Tim Pope <vimNOSPAM@tpope.org>
" URL:			https://github.com/vim-ruby/vim-ruby
" Release Coordinator:  Doug Kearns <dougkearns@gmail.com>
" ----------------------------------------------------------------------------

if (exists("b:did_ftplugin"))
  finish
endif
let b:did_ftplugin = 1

let s:cpo_save = &cpo
set cpo&vim

if has("gui_running") && !has("gui_win32")
  setlocal keywordprg=ri\ -T\ -f\ bs
else
  setlocal keywordprg=ri
endif

" Matchit support
if exists("loaded_matchit") && !exists("b:match_words")
  let b:match_ignorecase = 0

  let b:match_words =
	\ '\<\%(if\|unless\|case\|while\|until\|for\|do\|class\|module\|def\|begin\)\>=\@!' .
	\ ':' .
	\ '\<\%(else\|elsif\|ensure\|when\|rescue\|break\|redo\|next\|retry\)\>' .
	\ ':' .
	\ '\<end\>' .
	\ ',{:},\[:\],(:)'

  let b:match_skip =
	\ "synIDattr(synID(line('.'),col('.'),0),'name') =~ '" .
	\ "\\<ruby\\%(String\\|StringDelimiter\\|ASCIICode\\|Escape\\|" .
	\ "Interpolation\\|NoInterpolation\\|Comment\\|Documentation\\|" .
	\ "ConditionalModifier\\|RepeatModifier\\|OptionalDo\\|" .
	\ "Function\\|BlockArgument\\|KeywordAsMethod\\|ClassVariable\\|" .
	\ "InstanceVariable\\|GlobalVariable\\|Symbol\\)\\>'"
endif

setlocal formatoptions-=t formatoptions+=croql

setlocal include=^\\s*\\<\\(load\\>\\\|require\\>\\\|autoload\\s*:\\=[\"']\\=\\h\\w*[\"']\\=,\\)
setlocal includeexpr=substitute(substitute(v:fname,'::','/','g'),'$','.rb','')
setlocal suffixesadd=.rb

if exists("&ofu") && has("ruby")
  setlocal omnifunc=rubycomplete#Complete
endif

" To activate, :set ballooneval
if has('balloon_eval') && exists('+balloonexpr')
  setlocal balloonexpr=RubyBalloonexpr()
endif


" TODO:
"setlocal define=^\\s*def

setlocal comments=:#
setlocal commentstring=#\ %s

if !exists('g:ruby_version_paths')
  let g:ruby_version_paths = {}
endif

function! s:query_path(root)
  let code = "print $:.join %q{,}"
  if &shell =~# 'sh' && $PATH !~# '\s'
    let prefix = 'env PATH='.$PATH.' '
  else
    let prefix = ''
  endif
  if &shellxquote == "'"
    let path_check = prefix.'ruby -e "' . code . '"'
  else
    let path_check = prefix."ruby -e '" . code . "'"
  endif

  let cd = haslocaldir() ? 'lcd' : 'cd'
  let cwd = getcwd()
  try
    exe cd fnameescape(a:root)
    let path = split(system(path_check),',')
    exe cd fnameescape(cwd)
    return path
  finally
    exe cd fnameescape(cwd)
  endtry
endfunction

function! s:build_path(path)
  let path = join(map(copy(a:path), 'v:val ==# "." ? "" : v:val'), ',')
  if &g:path !~# '\v^\.%(,/%(usr|emx)/include)=,,$'
    let path = substitute(&g:path,',,$',',','') . ',' . path
  endif
  return path
endfunction

if !exists('b:ruby_version') && !exists('g:ruby_path') && isdirectory(expand('%:p:h'))
  let s:version_file = findfile('.ruby-version', '.;')
  if !empty(s:version_file)
    let b:ruby_version = get(readfile(s:version_file, '', 1), '')
    if !has_key(g:ruby_version_paths, b:ruby_version)
      let g:ruby_version_paths[b:ruby_version] = s:query_path(fnamemodify(s:version_file, ':p:h'))
    endif
  endif
endif

if exists("g:ruby_path")
  let s:ruby_path = type(g:ruby_path) == type([]) ? join(g:ruby_path, ',') : g:ruby_path
elseif has_key(g:ruby_version_paths, get(b:, 'ruby_version', ''))
  let s:ruby_paths = g:ruby_version_paths[b:ruby_version]
  let s:ruby_path = s:build_path(s:ruby_paths)
else
  if !exists('g:ruby_default_path')
    if has("ruby") && has("win32")
      ruby ::VIM::command( 'let g:ruby_default_path = split("%s",",")' % $:.join(%q{,}) )
    elseif executable('ruby')
      let g:ruby_default_path = s:query_path($HOME)
    else
      let g:ruby_default_path = map(split($RUBYLIB,':'), 'v:val ==# "." ? "" : v:val')
    endif
  endif
  let s:ruby_paths = g:ruby_default_path
  let s:ruby_path = s:build_path(s:ruby_paths)
endif

if stridx(&l:path, s:ruby_path) == -1
  let &l:path = s:ruby_path
endif
if exists('s:ruby_paths') && stridx(&l:tags, join(map(copy(s:ruby_paths),'v:val."/tags"'),',')) == -1
  let &l:tags = &tags . ',' . join(map(copy(s:ruby_paths),'v:val."/tags"'),',')
endif

if has("gui_win32") && !exists("b:browsefilter")
  let b:browsefilter = "Ruby Source Files (*.rb)\t*.rb\n" .
                     \ "All Files (*.*)\t*.*\n"
endif

let b:undo_ftplugin = "setl fo< inc< inex< sua< def< com< cms< path< tags< kp<"
      \."| unlet! b:browsefilter b:match_ignorecase b:match_words b:match_skip"
      \."| if exists('&ofu') && has('ruby') | setl ofu< | endif"
      \."| if has('balloon_eval') && exists('+bexpr') | setl bexpr< | endif"

if !exists("g:no_plugin_maps") && !exists("g:no_ruby_maps")
  nnoremap <silent> <buffer> [m :<C-U>call <SID>searchsyn('\<def\>','rubyDefine','b','n')<CR>
  nnoremap <silent> <buffer> ]m :<C-U>call <SID>searchsyn('\<def\>','rubyDefine','','n')<CR>
  nnoremap <silent> <buffer> [M :<C-U>call <SID>searchsyn('\<end\>','rubyDefine','b','n')<CR>
  nnoremap <silent> <buffer> ]M :<C-U>call <SID>searchsyn('\<end\>','rubyDefine','','n')<CR>
  xnoremap <silent> <buffer> [m :<C-U>call <SID>searchsyn('\<def\>','rubyDefine','b','v')<CR>
  xnoremap <silent> <buffer> ]m :<C-U>call <SID>searchsyn('\<def\>','rubyDefine','','v')<CR>
  xnoremap <silent> <buffer> [M :<C-U>call <SID>searchsyn('\<end\>','rubyDefine','b','v')<CR>
  xnoremap <silent> <buffer> ]M :<C-U>call <SID>searchsyn('\<end\>','rubyDefine','','v')<CR>

  nnoremap <silent> <buffer> [[ :<C-U>call <SID>searchsyn('\<\%(class\<Bar>module\)\>','rubyModule\<Bar>rubyClass','b','n')<CR>
  nnoremap <silent> <buffer> ]] :<C-U>call <SID>searchsyn('\<\%(class\<Bar>module\)\>','rubyModule\<Bar>rubyClass','','n')<CR>
  nnoremap <silent> <buffer> [] :<C-U>call <SID>searchsyn('\<end\>','rubyModule\<Bar>rubyClass','b','n')<CR>
  nnoremap <silent> <buffer> ][ :<C-U>call <SID>searchsyn('\<end\>','rubyModule\<Bar>rubyClass','','n')<CR>
  xnoremap <silent> <buffer> [[ :<C-U>call <SID>searchsyn('\<\%(class\<Bar>module\)\>','rubyModule\<Bar>rubyClass','b','v')<CR>
  xnoremap <silent> <buffer> ]] :<C-U>call <SID>searchsyn('\<\%(class\<Bar>module\)\>','rubyModule\<Bar>rubyClass','','v')<CR>
  xnoremap <silent> <buffer> [] :<C-U>call <SID>searchsyn('\<end\>','rubyModule\<Bar>rubyClass','b','v')<CR>
  xnoremap <silent> <buffer> ][ :<C-U>call <SID>searchsyn('\<end\>','rubyModule\<Bar>rubyClass','','v')<CR>

  let b:undo_ftplugin = b:undo_ftplugin
        \."| sil! exe 'unmap <buffer> [[' | sil! exe 'unmap <buffer> ]]' | sil! exe 'unmap <buffer> []' | sil! exe 'unmap <buffer> ]['"
        \."| sil! exe 'unmap <buffer> [m' | sil! exe 'unmap <buffer> ]m' | sil! exe 'unmap <buffer> [M' | sil! exe 'unmap <buffer> ]M'"

  if maparg('im','n') == ''
    onoremap <silent> <buffer> im :<C-U>call <SID>wrap_i('[m',']M')<CR>
    onoremap <silent> <buffer> am :<C-U>call <SID>wrap_a('[m',']M')<CR>
    xnoremap <silent> <buffer> im :<C-U>call <SID>wrap_i('[m',']M')<CR>
    xnoremap <silent> <buffer> am :<C-U>call <SID>wrap_a('[m',']M')<CR>
    let b:undo_ftplugin = b:undo_ftplugin
          \."| sil! exe 'ounmap <buffer> im' | sil! exe 'ounmap <buffer> am'"
          \."| sil! exe 'xunmap <buffer> im' | sil! exe 'xunmap <buffer> am'"
  endif

  if maparg('iM','n') == ''
    onoremap <silent> <buffer> iM :<C-U>call <SID>wrap_i('[[','][')<CR>
    onoremap <silent> <buffer> aM :<C-U>call <SID>wrap_a('[[','][')<CR>
    xnoremap <silent> <buffer> iM :<C-U>call <SID>wrap_i('[[','][')<CR>
    xnoremap <silent> <buffer> aM :<C-U>call <SID>wrap_a('[[','][')<CR>
    let b:undo_ftplugin = b:undo_ftplugin
          \."| sil! exe 'ounmap <buffer> iM' | sil! exe 'ounmap <buffer> aM'"
          \."| sil! exe 'xunmap <buffer> iM' | sil! exe 'xunmap <buffer> aM'"
  endif

  if maparg("\<C-]>",'n') == ''
    nnoremap <silent> <buffer> <C-]>       :<C-U>exe  v:count1."tag <C-R>=RubyCursorIdentifier()<CR>"<CR>
    nnoremap <silent> <buffer> g<C-]>      :<C-U>exe         "tjump <C-R>=RubyCursorIdentifier()<CR>"<CR>
    nnoremap <silent> <buffer> g]          :<C-U>exe       "tselect <C-R>=RubyCursorIdentifier()<CR>"<CR>
    nnoremap <silent> <buffer> <C-W>]      :<C-U>exe v:count1."stag <C-R>=RubyCursorIdentifier()<CR>"<CR>
    nnoremap <silent> <buffer> <C-W><C-]>  :<C-U>exe v:count1."stag <C-R>=RubyCursorIdentifier()<CR>"<CR>
    nnoremap <silent> <buffer> <C-W>g<C-]> :<C-U>exe        "stjump <C-R>=RubyCursorIdentifier()<CR>"<CR>
    nnoremap <silent> <buffer> <C-W>g]     :<C-U>exe      "stselect <C-R>=RubyCursorIdentifier()<CR>"<CR>
    nnoremap <silent> <buffer> <C-W>}      :<C-U>exe          "ptag <C-R>=RubyCursorIdentifier()<CR>"<CR>
    nnoremap <silent> <buffer> <C-W>g}     :<C-U>exe        "ptjump <C-R>=RubyCursorIdentifier()<CR>"<CR>
    let b:undo_ftplugin = b:undo_ftplugin
          \."| sil! exe 'nunmap <buffer> <C-]>'| sil! exe 'nunmap <buffer> g<C-]>'| sil! exe 'nunmap <buffer> g]'"
          \."| sil! exe 'nunmap <buffer> <C-W>]'| sil! exe 'nunmap <buffer> <C-W><C-]>'"
          \."| sil! exe 'nunmap <buffer> <C-W>g<C-]>'| sil! exe 'nunmap <buffer> <C-W>g]'"
          \."| sil! exe 'nunmap <buffer> <C-W>}'| sil! exe 'nunmap <buffer> <C-W>g}'"
  endif

  if maparg("gf",'n') == ''
    " By using findfile() rather than gf's normal behavior, we prevent
    " erroneously editing a directory.
    nnoremap <silent> <buffer> gf         :<C-U>exe <SID>gf(v:count1,"gf",'edit')<CR>
    nnoremap <silent> <buffer> <C-W>f     :<C-U>exe <SID>gf(v:count1,"\<Lt>C-W>f",'split')<CR>
    nnoremap <silent> <buffer> <C-W><C-F> :<C-U>exe <SID>gf(v:count1,"\<Lt>C-W>\<Lt>C-F>",'split')<CR>
    nnoremap <silent> <buffer> <C-W>gf    :<C-U>exe <SID>gf(v:count1,"\<Lt>C-W>gf",'tabedit')<CR>
    let b:undo_ftplugin = b:undo_ftplugin
          \."| sil! exe 'nunmap <buffer> gf' | sil! exe 'nunmap <buffer> <C-W>f' | sil! exe 'nunmap <buffer> <C-W><C-F>' | sil! exe 'nunmap <buffer> <C-W>gf'"
  endif
endif

let &cpo = s:cpo_save
unlet s:cpo_save

if exists("g:did_ruby_ftplugin_functions")
  finish
endif
let g:did_ruby_ftplugin_functions = 1

function! RubyBalloonexpr()
  if !exists('s:ri_found')
    let s:ri_found = executable('ri')
  endif
  if s:ri_found
    let line = getline(v:beval_lnum)
    let b = matchstr(strpart(line,0,v:beval_col),'\%(\w\|[:.]\)*$')
    let a = substitute(matchstr(strpart(line,v:beval_col),'^\w*\%([?!]\|\s*=\)\?'),'\s\+','','g')
    let str = b.a
    let before = strpart(line,0,v:beval_col-strlen(b))
    let after  = strpart(line,v:beval_col+strlen(a))
    if str =~ '^\.'
      let str = substitute(str,'^\.','#','g')
      if before =~ '\]\s*$'
        let str = 'Array'.str
      elseif before =~ '}\s*$'
        " False positives from blocks here
        let str = 'Hash'.str
      elseif before =~ "[\"'`]\\s*$" || before =~ '\$\d\+\s*$'
        let str = 'String'.str
      elseif before =~ '\$\d\+\.\d\+\s*$'
        let str = 'Float'.str
      elseif before =~ '\$\d\+\s*$'
        let str = 'Integer'.str
      elseif before =~ '/\s*$'
        let str = 'Regexp'.str
      else
        let str = substitute(str,'^#','.','')
      endif
    endif
    let str = substitute(str,'.*\.\s*to_f\s*\.\s*','Float#','')
    let str = substitute(str,'.*\.\s*to_i\%(nt\)\=\s*\.\s*','Integer#','')
    let str = substitute(str,'.*\.\s*to_s\%(tr\)\=\s*\.\s*','String#','')
    let str = substitute(str,'.*\.\s*to_sym\s*\.\s*','Symbol#','')
    let str = substitute(str,'.*\.\s*to_a\%(ry\)\=\s*\.\s*','Array#','')
    let str = substitute(str,'.*\.\s*to_proc\s*\.\s*','Proc#','')
    if str !~ '^\w'
      return ''
    endif
    silent! let res = substitute(system("ri -f rdoc -T \"".str.'"'),'\n$','','')
    if res =~ '^Nothing known about' || res =~ '^Bad argument:' || res =~ '^More than one method'
      return ''
    endif
    return res
  else
    return ""
  endif
endfunction

function! s:searchsyn(pattern,syn,flags,mode)
  norm! m'
  if a:mode ==# 'v'
    norm! gv
  endif
  let i = 0
  let cnt = v:count ? v:count : 1
  while i < cnt
    let i = i + 1
    let line = line('.')
    let col  = col('.')
    let pos = search(a:pattern,'W'.a:flags)
    while pos != 0 && s:synname() !~# a:syn
      let pos = search(a:pattern,'W'.a:flags)
    endwhile
    if pos == 0
      call cursor(line,col)
      return
    endif
  endwhile
endfunction

function! s:synname()
  return synIDattr(synID(line('.'),col('.'),0),'name')
endfunction

function! s:wrap_i(back,forward)
  execute 'norm k'.a:forward
  let line = line('.')
  execute 'norm '.a:back
  if line('.') == line - 1
    return s:wrap_a(a:back,a:forward)
  endif
  execute 'norm jV'.a:forward.'k'
endfunction

function! s:wrap_a(back,forward)
  execute 'norm '.a:forward
  if line('.') < line('$') && getline(line('.')+1) ==# ''
    let after = 1
  endif
  execute 'norm '.a:back
  while getline(line('.')-1) =~# '^\s*#' && line('.')
    -
  endwhile
  if exists('after')
    execute 'norm V'.a:forward.'j'
  elseif line('.') > 1 && getline(line('.')-1) =~# '^\s*$'
    execute 'norm kV'.a:forward
  else
    execute 'norm V'.a:forward
  endif
endfunction

function! RubyCursorIdentifier()
  let asciicode    = '\%(\w\|[]})\"'."'".']\)\@<!\%(?\%(\\M-\\C-\|\\C-\\M-\|\\M-\\c\|\\c\\M-\|\\c\|\\C-\|\\M-\)\=\%(\\\o\{1,3}\|\\x\x\{1,2}\|\\\=\S\)\)'
  let number       = '\%(\%(\w\|[]})\"'."'".']\s*\)\@<!-\)\=\%(\<[[:digit:]_]\+\%(\.[[:digit:]_]\+\)\=\%([Ee][[:digit:]_]\+\)\=\>\|\<0[xXbBoOdD][[:xdigit:]_]\+\>\)\|'.asciicode
  let operator     = '\%(\[\]\|<<\|<=>\|[!<>]=\=\|===\=\|[!=]\~\|>>\|\*\*\|\.\.\.\=\|=>\|[~^&|*/%+-]\)'
  let method       = '\%(\<[_a-zA-Z]\w*\>\%([?!]\|\s*=>\@!\)\=\)'
  let global       = '$\%([!$&"'."'".'*+,./:;<=>?@\`~]\|-\=\w\+\>\)'
  let symbolizable = '\%(\%(@@\=\)\w\+\>\|'.global.'\|'.method.'\|'.operator.'\)'
  let pattern      = '\C\s*\%('.number.'\|\%(:\@<!:\)\='.symbolizable.'\)'
  let [lnum, col]  = searchpos(pattern,'bcn',line('.'))
  let raw          = matchstr(getline('.')[col-1 : ],pattern)
  let stripped     = substitute(substitute(raw,'\s\+=$','=',''),'^\s*:\=','','')
  return stripped == '' ? expand("<cword>") : stripped
endfunction

function! s:gf(count,map,edit) abort
  if getline('.') =~# '^\s*require_relative\s*\(["'']\).*\1\s*$'
    let target = matchstr(getline('.'),'\(["'']\)\zs.\{-\}\ze\1')
    return a:edit.' %:h/'.target.'.rb'
  elseif getline('.') =~# '^\s*\%(require[( ]\|load[( ]\|autoload[( ]:\w\+,\)\s*\s*\%(::\)\=File\.expand_path(\(["'']\)\.\./.*\1,\s*__FILE__)\s*$'
    let target = matchstr(getline('.'),'\(["'']\)\.\./\zs.\{-\}\ze\1')
    return a:edit.' %:h/'.target.'.rb'
  elseif getline('.') =~# '^\s*\%(require \|load \|autoload :\w\+,\)\s*\(["'']\).*\1\s*$'
    let target = matchstr(getline('.'),'\(["'']\)\zs.\{-\}\ze\1')
  else
    let target = expand('<cfile>')
  endif
  let found = findfile(target, &path, a:count)
  if found ==# ''
    return 'norm! '.a:count.a:map
  else
    return a:edit.' '.fnameescape(found)
  endif
endfunction

"
" Instructions for enabling "matchit" support:
"
" 1. Look for the latest "matchit" plugin at
"
"         http://www.vim.org/scripts/script.php?script_id=39
"
"    It is also packaged with Vim, in the $VIMRUNTIME/macros directory.
"
" 2. Copy "matchit.txt" into a "doc" directory (e.g. $HOME/.vim/doc).
"
" 3. Copy "matchit.vim" into a "plugin" directory (e.g. $HOME/.vim/plugin).
"
" 4. Ensure this file (ftplugin/ruby.vim) is installed.
"
" 5. Ensure you have this line in your $HOME/.vimrc:
"         filetype plugin on
"
" 6. Restart Vim and create the matchit documentation:
"
"         :helptags ~/.vim/doc
"
"    Now you can do ":help matchit", and you should be able to use "%" on Ruby
"    keywords.  Try ":echo b:match_words" to be sure.
"
" Thanks to Mark J. Reed for the instructions.  See ":help vimrc" for the
" locations of plugin directories, etc., as there are several options, and it
" differs on Windows.  Email gsinclair@soyabean.com.au if you need help.
"

" vim: nowrap sw=2 sts=2 ts=8:
"
"
" ------------------------------------- zhangj zj
"
if exists("b:did_RUBY_ftplugin")
  finish
endif
let b:did_RUBY_ftplugin = 1
"
"------------------------------------------------------------------------------
"  Avoid a wrong syntax highlighting for $(..) and $((..))
"------------------------------------------------------------------------------
let b:is_ruby           = 1
"
" ---------- Do we have a mapleader other than '\' ? ------------
"
if exists("g:RUBY_MapLeader")
  let maplocalleader  = g:RUBY_MapLeader
endif    
"
let s:MSWIN =   has("win16") || has("win32") || has("win64") || has("win95")
"
" ---------- RUBY dictionary -----------------------------------
"
" This will enable keyword completion for ruby
" using Vim's dictionary feature |i_CTRL-X_CTRL-K|.
" 
if exists("g:RUBY_Dictionary_File")
  let save=&dictionary
  silent! exe 'setlocal dictionary='.g:RUBY_Dictionary_File
  silent! exe 'setlocal dictionary+='.save
endif    
"
command! -nargs=1 -complete=customlist,RUBY_StyleList   				BashStyle   		call RUBY_Style(<f-args>)
command! -nargs=1 -complete=customlist,RUBY_ScriptSectionList   ScriptSection   call RUBY_ScriptSectionListInsert(<f-args>)
command! -nargs=1 -complete=customlist,RUBY_KeywordCommentList  KeywordComment  call RUBY_KeywordCommentListInsert(<f-args>)
"
" ---------- hot keys ------------------------------------------
"
"   Alt-F9   run syntax check
"  Ctrl-F9   update file and run script
" Shift-F9   command line arguments
"
if has("gui_running")
  "
   map  <buffer>  <silent>  <S-F1>        :call RUBY_HelpRUBYsupport()<CR>
  imap  <buffer>  <silent>  <S-F1>   <C-C>:call RUBY_HelpRUBYsupport()<CR>
  "
   map  <buffer>  <silent>  <A-F9>        :call RUBY_SyntaxCheck()<CR>
  imap  <buffer>  <silent>  <A-F9>   <C-C>:call RUBY_SyntaxCheck()<CR>
  "
   map  <buffer>  <silent>  <C-F9>        :call RUBY_Run("n")<CR>
  imap  <buffer>  <silent>  <C-F9>   <C-C>:call RUBY_Run("n")<CR>
  if !s:MSWIN
    vmap  <buffer>  <silent>  <C-F9>   <C-C>:call RUBY_Run("v")<CR>
  endif
  "
  map   <buffer>  <silent>  <S-F9>        :call RUBY_ScriptCmdLineArguments()<CR>
  imap  <buffer>  <silent>  <S-F9>   <C-C>:call RUBY_ScriptCmdLineArguments()<CR>
endif
"
if !s:MSWIN
   map  <buffer>  <silent>    <F9>        :call RUBY_Debugger()<CR>
  imap  <buffer>  <silent>    <F9>   <C-C>:call RUBY_Debugger()<CR>
endif
"
"
" ---------- help ----------------------------------------------------
"
 noremap  <buffer>  <silent>  <LocalLeader>hb            :call RUBY_help('b')<CR>
inoremap  <buffer>  <silent>  <LocalLeader>hb       <Esc>:call RUBY_help('b')<CR>
"
 noremap  <buffer>  <silent>  <LocalLeader>hh            :call RUBY_help('h')<CR>
inoremap  <buffer>  <silent>  <LocalLeader>hh       <Esc>:call RUBY_help('h')<CR>
"
 noremap  <buffer>  <silent>  <LocalLeader>hm            :call RUBY_help('m')<CR>
inoremap  <buffer>  <silent>  <LocalLeader>hm       <Esc>:call RUBY_help('m')<CR>
"
 noremap  <buffer>  <silent>  <LocalLeader>hbs          :call RUBY_HelpRUBYsupport()<CR>
inoremap  <buffer>  <silent>  <LocalLeader>hbs     <Esc>:call RUBY_HelpRUBYsupport()<CR>
"
" ---------- comment menu ----------------------------------------------------
"
 noremap  <buffer>  <silent>  <LocalLeader>cl           :call RUBY_EndOfLineComment()<CR>
inoremap  <buffer>  <silent>  <LocalLeader>cl      <Esc>:call RUBY_EndOfLineComment()<CR>
vnoremap  <buffer>  <silent>  <LocalLeader>cl      <Esc>:call RUBY_MultiLineEndComments()<CR>a

 noremap  <buffer>  <silent>  <LocalLeader>cj           :call RUBY_AdjustLineEndComm()<CR>
inoremap  <buffer>  <silent>  <LocalLeader>cj      <Esc>:call RUBY_AdjustLineEndComm()<CR>
vnoremap  <buffer>  <silent>  <LocalLeader>cj           :call RUBY_AdjustLineEndComm()<CR>

 noremap  <buffer>  <silent>  <LocalLeader>cs           :call RUBY_GetLineEndCommCol()<CR>
inoremap  <buffer>  <silent>  <LocalLeader>cs      <Esc>:call RUBY_GetLineEndCommCol()<CR>

 noremap  <buffer>  <silent>  <LocalLeader>cfr          :call RUBY_InsertTemplate("comment.frame")<CR>
inoremap  <buffer>  <silent>  <LocalLeader>cfr     <Esc>:call RUBY_InsertTemplate("comment.frame")<CR>
 noremap  <buffer>  <silent>  <LocalLeader>cfu          :call RUBY_InsertTemplate("comment.function")<CR>
inoremap  <buffer>  <silent>  <LocalLeader>cfu     <Esc>:call RUBY_InsertTemplate("comment.function")<CR>
 noremap  <buffer>  <silent>  <LocalLeader>ch           :call RUBY_InsertTemplate("comment.file-description")<CR>
inoremap  <buffer>  <silent>  <LocalLeader>ch      <Esc>:call RUBY_InsertTemplate("comment.file-description")<CR>

 noremap  <buffer>  <silent>  <LocalLeader>ct           :call RUBY_InsertDateAndTime('dt')<CR>
inoremap  <buffer>  <silent>  <LocalLeader>ct      <Esc>:call RUBY_InsertDateAndTime('dt')<CR>a
vnoremap  <buffer>  <silent>  <LocalLeader>ct     s<Esc>:call RUBY_InsertDateAndTime('dt')<CR>

 noremap  <buffer>  <silent>  <LocalLeader>ckb     $:call RUBY_InsertTemplate("comment.keyword-bug")       <CR>
 noremap  <buffer>  <silent>  <LocalLeader>ckt     $:call RUBY_InsertTemplate("comment.keyword-todo")      <CR>
 noremap  <buffer>  <silent>  <LocalLeader>ckr     $:call RUBY_InsertTemplate("comment.keyword-tricky")    <CR>
 noremap  <buffer>  <silent>  <LocalLeader>ckw     $:call RUBY_InsertTemplate("comment.keyword-warning")   <CR>
 noremap  <buffer>  <silent>  <LocalLeader>cko     $:call RUBY_InsertTemplate("comment.keyword-workaround")<CR>
 noremap  <buffer>  <silent>  <LocalLeader>ckn     $:call RUBY_InsertTemplate("comment.keyword-keyword")   <CR>

inoremap  <buffer>  <silent>  <LocalLeader>ckb     <C-C>$:call RUBY_InsertTemplate("comment.keyword-bug")       <CR>
inoremap  <buffer>  <silent>  <LocalLeader>ckt     <C-C>$:call RUBY_InsertTemplate("comment.keyword-todo")      <CR>
inoremap  <buffer>  <silent>  <LocalLeader>ckr     <C-C>$:call RUBY_InsertTemplate("comment.keyword-tricky")    <CR>
inoremap  <buffer>  <silent>  <LocalLeader>ckw     <C-C>$:call RUBY_InsertTemplate("comment.keyword-warning")   <CR>
inoremap  <buffer>  <silent>  <LocalLeader>cko     <C-C>$:call RUBY_InsertTemplate("comment.keyword-workaround")<CR>
inoremap  <buffer>  <silent>  <LocalLeader>ckn     <C-C>$:call RUBY_InsertTemplate("comment.keyword-keyword")   <CR>

 noremap  <buffer>  <silent>  <LocalLeader>ce           :call RUBY_echo_comment()<CR>j'
inoremap  <buffer>  <silent>  <LocalLeader>ce      <C-C>:call RUBY_echo_comment()<CR>j'
 noremap  <buffer>  <silent>  <LocalLeader>cr           :call RUBY_remove_echo()<CR>j'
inoremap  <buffer>  <silent>  <LocalLeader>cr      <C-C>:call RUBY_remove_echo()<CR>j'
 noremap  <buffer>  <silent>  <LocalLeader>cv           :call RUBY_CommentVimModeline()<CR>
inoremap  <buffer>  <silent>  <LocalLeader>cv      <C-C>:call RUBY_CommentVimModeline()<CR>
"
 noremap    <buffer>            <LocalLeader>css   <Esc>:ScriptSection<Space>
inoremap    <buffer>            <LocalLeader>css   <Esc>:ScriptSection<Space>
 noremap    <buffer>            <LocalLeader>ckc   <Esc>:KeywordComment<Space>
inoremap    <buffer>            <LocalLeader>ckc   <Esc>:KeywordComment<Space>
"
" ---------- statement menu ----------------------------------------------------
"
 noremap  <buffer>  <silent>  <LocalLeader>sh           :call RUBY_InsertTemplate("statements.here")<CR>
inoremap  <buffer>  <silent>  <LocalLeader>sh      <Esc>:call RUBY_InsertTemplate("statements.here")<CR>

 noremap  <buffer>  <silent>  <LocalLeader>sr           :call RUBY_InsertTemplate("statements.xt_ret")<CR>
inoremap  <buffer>  <silent>  <LocalLeader>sr      <Esc>:call RUBY_InsertTemplate("statements.xt_ret")<CR>

 noremap  <buffer>  <silent>  <LocalLeader>st           :call RUBY_InsertTemplate("statements.test")<CR>
inoremap  <buffer>  <silent>  <LocalLeader>st      <Esc>:call RUBY_InsertTemplate("statements.test")<CR>

 noremap  <buffer>  <silent>  <LocalLeader>sx           :call RUBY_InsertTemplate("statements.xert")<CR>
inoremap  <buffer>  <silent>  <LocalLeader>sx      <Esc>:call RUBY_InsertTemplate("statements.xert")<CR>

" -- self define end --
 noremap  <buffer>  <silent>  <LocalLeader>sc           :call RUBY_InsertTemplate("statements.case")<CR>
 noremap  <buffer>  <silent>  <LocalLeader>sei          :call RUBY_InsertTemplate("statements.elif")<CR>
 noremap  <buffer>  <silent>  <LocalLeader>sfi          :call RUBY_InsertTemplate("statements.for-in")<CR>
 noremap  <buffer>  <silent>  <LocalLeader>sfo          :call RUBY_InsertTemplate("statements.for")<CR>
 noremap  <buffer>  <silent>  <LocalLeader>sif          :call RUBY_InsertTemplate("statements.if")<CR>
 noremap  <buffer>  <silent>  <LocalLeader>sie          :call RUBY_InsertTemplate("statements.if-else")<CR>
 noremap  <buffer>  <silent>  <LocalLeader>ss           :call RUBY_InsertTemplate("statements.select")<CR>
 noremap  <buffer>  <silent>  <LocalLeader>su           :call RUBY_InsertTemplate("statements.until")<CR>
 noremap  <buffer>  <silent>  <LocalLeader>sw           :call RUBY_InsertTemplate("statements.while")<CR>

inoremap  <buffer>  <silent>  <LocalLeader>sc      <Esc>:call RUBY_InsertTemplate("statements.case")<CR>
inoremap  <buffer>  <silent>  <LocalLeader>sei     <Esc>:call RUBY_InsertTemplate("statements.elif")<CR>
inoremap  <buffer>  <silent>  <LocalLeader>sfi     <Esc>:call RUBY_InsertTemplate("statements.for-in")<CR>
inoremap  <buffer>  <silent>  <LocalLeader>sfo     <Esc>:call RUBY_InsertTemplate("statements.for")<CR>
inoremap  <buffer>  <silent>  <LocalLeader>sif     <Esc>:call RUBY_InsertTemplate("statements.if")<CR>
inoremap  <buffer>  <silent>  <LocalLeader>sie     <Esc>:call RUBY_InsertTemplate("statements.if-else")<CR>
inoremap  <buffer>  <silent>  <LocalLeader>ss      <Esc>:call RUBY_InsertTemplate("statements.select")<CR>
inoremap  <buffer>  <silent>  <LocalLeader>su      <Esc>:call RUBY_InsertTemplate("statements.until")<CR>
inoremap  <buffer>  <silent>  <LocalLeader>sw      <Esc>:call RUBY_InsertTemplate("statements.while")<CR>

vnoremap  <buffer>  <silent>  <LocalLeader>sfi     <Esc>:call RUBY_InsertTemplate("statements.for-in", "v")<CR>
vnoremap  <buffer>  <silent>  <LocalLeader>sfo     <Esc>:call RUBY_InsertTemplate("statements.for", "v")<CR>
vnoremap  <buffer>  <silent>  <LocalLeader>sif     <Esc>:call RUBY_InsertTemplate("statements.if", "v")<CR>
vnoremap  <buffer>  <silent>  <LocalLeader>sie     <Esc>:call RUBY_InsertTemplate("statements.if-else", "v")<CR>
vnoremap  <buffer>  <silent>  <LocalLeader>ss      <Esc>:call RUBY_InsertTemplate("statements.select", "v")<CR>
vnoremap  <buffer>  <silent>  <LocalLeader>su      <Esc>:call RUBY_InsertTemplate("statements.until", "v")<CR>
vnoremap  <buffer>  <silent>  <LocalLeader>sw      <Esc>:call RUBY_InsertTemplate("statements.while", "v")<CR>

 noremap  <buffer>  <silent>  <LocalLeader>sfu          :call RUBY_InsertTemplate("statements.function")<CR>
inoremap  <buffer>  <silent>  <LocalLeader>sfu     <Esc>:call RUBY_InsertTemplate("statements.function")<CR>
vnoremap  <buffer>  <silent>  <LocalLeader>sfu     <Esc>:call RUBY_InsertTemplate("statements.function", "v")<CR>

 noremap  <buffer>  <silent>  <LocalLeader>sfm          :call RUBY_InsertTemplate("statements.mfunction")<CR>
inoremap  <buffer>  <silent>  <LocalLeader>sfm     <Esc>:call RUBY_InsertTemplate("statements.mfunction")<CR>
vnoremap  <buffer>  <silent>  <LocalLeader>sfm     <Esc>:call RUBY_InsertTemplate("statements.mfunction", "v")<CR>

 noremap  <buffer>  <silent>  <LocalLeader>sp           :call RUBY_InsertTemplate("statements.printf")<CR>
inoremap  <buffer>  <silent>  <LocalLeader>sp      <Esc>:call RUBY_InsertTemplate("statements.printf")<CR>
vnoremap  <buffer>  <silent>  <LocalLeader>sp      <Esc>:call RUBY_InsertTemplate("statements.printf", "v")<CR>
                                                                                                                 
 noremap  <buffer>  <silent>  <LocalLeader>sec          :call RUBY_InsertTemplate("statements.echo")<CR>
inoremap  <buffer>  <silent>  <LocalLeader>sec     <Esc>:call RUBY_InsertTemplate("statements.echo")<CR>
vnoremap  <buffer>  <silent>  <LocalLeader>sec     <Esc>:call RUBY_InsertTemplate("statements.echo", "v")<CR>

" var
 noremap  <buffer>  <silent>  <LocalLeader>svv     a${}<Left>
inoremap  <buffer>  <silent>  <LocalLeader>svv      ${}<Left>

 noremap  <buffer>  <silent>  <LocalLeader>svp     a"${}"<Left><Left>
inoremap  <buffer>  <silent>  <LocalLeader>svp      "${}"<Left><Left>
" array memb
 noremap  <buffer>  <silent>  <LocalLeader>sam     a${[]}<Left><Left><Left>
inoremap  <buffer>  <silent>  <LocalLeader>sam      ${[]}<Left><Left><Left>
vnoremap  <buffer>  <silent>  <LocalLeader>sam     s${[]}<Left><Left><Esc>P

 noremap  <buffer>  <silent>  <LocalLeader>saa     a${[@]}<Left><Left><Left><Left>
inoremap  <buffer>  <silent>  <LocalLeader>saa      ${[@]}<Left><Left><Left><Left>
vnoremap  <buffer>  <silent>  <LocalLeader>saa     s${[@]}<Left><Left><Left><Esc>P

" when quoted, as 1
 noremap  <buffer>  <silent>  <LocalLeader>sa1     a${[*]}<Left><Left><Left><Left>
inoremap  <buffer>  <silent>  <LocalLeader>sa1      ${[*]}<Left><Left><Left><Left>
vnoremap  <buffer>  <silent>  <LocalLeader>sa1     s${[*]}<Left><Left><Left><Esc>P

" array slice
 noremap  <buffer>  <silent>  <LocalLeader>sas     a${[@]::}<Left><Left><Left><Left><Left><Left>
inoremap  <buffer>  <silent>  <LocalLeader>sas      ${[@]::}<Left><Left><Left><Left><Left><Left>
vnoremap  <buffer>  <silent>  <LocalLeader>sas     s${[@]::}<Left><Left><Left><Left><Left><Esc>P

" array size
 noremap  <buffer>  <silent>  <LocalLeader>san     a${#[@]}<Left><Left><Left><Left>
inoremap  <buffer>  <silent>  <LocalLeader>san      ${#[@]}<Left><Left><Left><Left>
vnoremap  <buffer>  <silent>  <LocalLeader>san     s${#[@]}<Left><Left><Left><Esc>P

" index of assigned items
 noremap  <buffer>  <silent>  <LocalLeader>sai     a${![*]}<Left><Left><Left><Left>
inoremap  <buffer>  <silent>  <LocalLeader>sai      ${![*]}<Left><Left><Left><Left>
vnoremap  <buffer>  <silent>  <LocalLeader>sai     s${![*]}<Left><Left><Left><Esc>P
  "
  " ----------------------------------------------------------------------------
  " POSIX character classes
  " ----------------------------------------------------------------------------
  "
nnoremap  <buffer>  <silent>  <LocalLeader>xm   a[[  =~  ]]<Left><Left><Left><Left><Left><Left><Left>
inoremap  <buffer>  <silent>  <LocalLeader>xm    [[  =~  ]]<Left><Left><Left><Left><Left><Left><Left>
  "
nnoremap  <buffer>  <silent>  <LocalLeader>pan   a[:alnum:]<Esc>
nnoremap  <buffer>  <silent>  <LocalLeader>pal    a[:alpha:]<Esc>
nnoremap  <buffer>  <silent>  <LocalLeader>pas    a[:ascii:]<Esc>
nnoremap  <buffer>  <silent>  <LocalLeader>pb    a[:blank:]<Esc>
nnoremap  <buffer>  <silent>  <LocalLeader>pc    a[:cntrl:]<Esc>
nnoremap  <buffer>  <silent>  <LocalLeader>pd    a[:digit:]<Esc>
nnoremap  <buffer>  <silent>  <LocalLeader>pg    a[:graph:]<Esc>
nnoremap  <buffer>  <silent>  <LocalLeader>pl    a[:lower:]<Esc>
nnoremap  <buffer>  <silent>  <LocalLeader>ppr   a[:print:]<Esc>
nnoremap  <buffer>  <silent>  <LocalLeader>ppu   a[:punct:]<Esc>
nnoremap  <buffer>  <silent>  <LocalLeader>ps    a[:space:]<Esc>
nnoremap  <buffer>  <silent>  <LocalLeader>pu    a[:upper:]<Esc>
nnoremap  <buffer>  <silent>  <LocalLeader>pw    a[:word:]<Esc>
nnoremap  <buffer>  <silent>  <LocalLeader>px    a[:xdigit:]<Esc>
"
inoremap  <buffer>  <silent>  <LocalLeader>pan   [:alnum:]
inoremap  <buffer>  <silent>  <LocalLeader>pal   [:alpha:]
inoremap  <buffer>  <silent>  <LocalLeader>pas   [:ascii:]
inoremap  <buffer>  <silent>  <LocalLeader>pb    [:blank:]
inoremap  <buffer>  <silent>  <LocalLeader>pc    [:cntrl:]
inoremap  <buffer>  <silent>  <LocalLeader>pd    [:digit:]
inoremap  <buffer>  <silent>  <LocalLeader>pg    [:graph:]
inoremap  <buffer>  <silent>  <LocalLeader>pl    [:lower:]
inoremap  <buffer>  <silent>  <LocalLeader>ppr   [:print:]
inoremap  <buffer>  <silent>  <LocalLeader>ppu   [:punct:]
inoremap  <buffer>  <silent>  <LocalLeader>ps    [:space:]
inoremap  <buffer>  <silent>  <LocalLeader>pu    [:upper:]
inoremap  <buffer>  <silent>  <LocalLeader>pw    [:word:]
inoremap  <buffer>  <silent>  <LocalLeader>px    [:xdigit:]
"
" ---------- snippet menu ----------------------------------------------------
"
nnoremap  <buffer>  <silent>  <LocalLeader>nr         :call RUBY_CodeSnippets("r")<CR>
nnoremap  <buffer>  <silent>  <LocalLeader>nw         :call RUBY_CodeSnippets("w")<CR>
vnoremap  <buffer>  <silent>  <LocalLeader>nw    <C-C>:call RUBY_CodeSnippets("wv")<CR>
nnoremap  <buffer>  <silent>  <LocalLeader>ne         :call RUBY_CodeSnippets("e")<CR>
"
nnoremap  <buffer>  <silent>  <LocalLeader>ntl        :call RUBY_BrowseTemplateFiles("Local")<CR>
nnoremap  <buffer>  <silent>  <LocalLeader>ntg        :call RUBY_BrowseTemplateFiles("Global")<CR> 
nnoremap  <buffer>  <silent>  <LocalLeader>ntr        :call RUBY_RereadTemplates()<CR>
nnoremap  <buffer>            <LocalLeader>nts        :BashStyle<Space>
"
 inoremap  <buffer>  <silent>  <LocalLeader>nr    <Esc>:call RUBY_CodeSnippets("r")<CR>
 inoremap  <buffer>  <silent>  <LocalLeader>nw    <Esc>:call RUBY_CodeSnippets("w")<CR>
 inoremap  <buffer>  <silent>  <LocalLeader>ne    <Esc>:call RUBY_CodeSnippets("e")<CR>
"
 inoremap  <buffer>  <silent>  <LocalLeader>ntl   <Esc>:call RUBY_BrowseTemplateFiles("Local")<CR>
 inoremap  <buffer>  <silent>  <LocalLeader>ntg   <Esc>:call RUBY_BrowseTemplateFiles("Global")<CR> 
 inoremap  <buffer>  <silent>  <LocalLeader>ntr   <Esc>:call RUBY_RereadTemplates()<CR>
 inoremap  <buffer>            <LocalLeader>nts   <Esc>:BashStyle<Space>
"
" ---------- test  ----------------------------------------------------
"
nnoremap  <buffer>  <silent>  <LocalLeader>t1   a[ -  ]<Left><Left><Left>
inoremap  <buffer>  <silent>  <LocalLeader>t1    [ -  ]<Left><Left><Left>
"
nnoremap  <buffer>  <silent>  <LocalLeader>t2   a[  -  ]<Left><Left><Left><Left><Left>
inoremap  <buffer>  <silent>  <LocalLeader>t2    [  -  ]<Left><Left><Left><Left><Left>
"
" ---------- run menu ----------------------------------------------------
"
 map  <buffer>  <silent>  <LocalLeader>rr           :call RUBY_Run("n")<CR>
imap  <buffer>  <silent>  <LocalLeader>rr      <Esc>:call RUBY_Run("n")<CR>
 map  <buffer>  <silent>  <LocalLeader>ra           :call RUBY_ScriptCmdLineArguments()<CR>
imap  <buffer>  <silent>  <LocalLeader>ra      <Esc>:call RUBY_ScriptCmdLineArguments()<CR>
 map  <buffer>  <silent>  <LocalLeader>rba          :call RUBY_BashCmdLineArguments()<CR>
imap  <buffer>  <silent>  <LocalLeader>rba     <Esc>:call RUBY_BashCmdLineArguments()<CR>

 map  <buffer>  <silent>  <LocalLeader>rc           :call RUBY_SyntaxCheck()<CR>
imap  <buffer>  <silent>  <LocalLeader>rc      <Esc>:call RUBY_SyntaxCheck()<CR>

 map  <buffer>  <silent>  <LocalLeader>rco          :call RUBY_SyntaxCheckOptionsLocal()<CR>
imap  <buffer>  <silent>  <LocalLeader>rco     <Esc>:call RUBY_SyntaxCheckOptionsLocal()<CR>

if !s:MSWIN
   map  <buffer> <silent> <LocalLeader>re           :call RUBY_MakeScriptExecutable()<CR>
  imap  <buffer> <silent> <LocalLeader>re      <Esc>:call RUBY_MakeScriptExecutable()<CR>

   map  <buffer>  <silent>  <LocalLeader>rd           :call RUBY_Debugger()<CR>
  imap  <buffer>  <silent>  <LocalLeader>rd      <Esc>:call RUBY_Debugger()<CR>

  vmap  <buffer>  <silent>  <LocalLeader>rr      <Esc>:call RUBY_Run("v")<CR>

  if has("gui_running")
     map  <buffer>  <silent>  <LocalLeader>rt           :call RUBY_XtermSize()<CR>
    imap  <buffer>  <silent>  <LocalLeader>rt      <Esc>:call RUBY_XtermSize()<CR>
  endif
endif

 map  <buffer>  <silent>  <LocalLeader>rh           :call RUBY_Hardcopy("n")<CR>
imap  <buffer>  <silent>  <LocalLeader>rh      <Esc>:call RUBY_Hardcopy("n")<CR>
vmap  <buffer>  <silent>  <LocalLeader>rh      <Esc>:call RUBY_Hardcopy("v")<CR>
"
 map  <buffer>  <silent>  <LocalLeader>rs           :call RUBY_Settings()<CR>
imap  <buffer>  <silent>  <LocalLeader>rs      <Esc>:call RUBY_Settings()<CR>

if s:MSWIN
   map  <buffer>  <silent>  <LocalLeader>ro           :call RUBY_Toggle_Gvim_Xterm_MS()<CR>
  imap  <buffer>  <silent>  <LocalLeader>ro      <Esc>:call RUBY_Toggle_Gvim_Xterm_MS()<CR>
else
   map  <buffer>  <silent>  <LocalLeader>ro           :call RUBY_Toggle_Gvim_Xterm()<CR>
  imap  <buffer>  <silent>  <LocalLeader>ro      <Esc>:call RUBY_Toggle_Gvim_Xterm()<CR>
endif

"-------------------------------------------------------------------------------
" additional mapping : single quotes around a Word (non-whitespaces)
"                      masks the normal mode command '' (jump to the position
"                      before the latest jump)
" additional mapping : double quotes around a Word (non-whitespaces)
"-------------------------------------------------------------------------------
nnoremap    <buffer>   ''   ciW''<Esc>P
nnoremap    <buffer>   ""   ciW""<Esc>P
"
"if !exists("g:RUBY_Ctrl_j") || ( exists("g:RUBY_Ctrl_j") && g:RUBY_Ctrl_j != 'off' )
"  nmap    <buffer>  <silent>  <C-j>   i<C-R>=RUBY_JumpCtrlJ()<CR>
"  imap    <buffer>  <silent>  <C-j>    <C-R>=RUBY_JumpCtrlJ()<CR>
"endif
