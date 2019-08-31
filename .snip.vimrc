"
" http://vim.wikia.com/wiki/Different_syntax_highlighting_within_regions_of_a_file
"
function! TextEnableCodeSnip(filetype,start,end,textSnipHl) abort
  let ft=toupper(a:filetype)
  let group='textGroup'.ft
  if exists('b:current_syntax')
    let s:current_syntax=b:current_syntax
    " Remove current syntax definition, as some syntax files (e.g. cpp.vim)
    " do nothing if b:current_syntax is defined.
    unlet b:current_syntax
  endif
  execute 'syntax include @'.group.' syntax/'.a:filetype.'.vim'
  try
    execute 'syntax include @'.group.' after/syntax/'.a:filetype.'.vim'
  catch
  endtry
  if exists('s:current_syntax')
    let b:current_syntax=s:current_syntax
  else
    unlet b:current_syntax
  endif
  execute 'syntax region textSnip'.ft.'
  \ matchgroup='.a:textSnipHl.'
  \ start="'.a:start.'" end="'.a:end.'"
  \ contains=@'.group
endfunction

function! Update_snip_syntax()
  if !exists('b:snip_visited')
      let g:is_sniping=0
      let b:snip_visited=1
      call Toggle_snip_syntax()
      return
  else
      let b:snip_visited=0
      if  g:is_sniping == 0 | return | endif
  endif
  call TextEnableCodeSnip(     'txt',      '```txt'     ,            '```', 'SpecialComment')
  call TextEnableCodeSnip(     'cpp',      '```cpp'     ,            '```', 'SpecialComment')
  call TextEnableCodeSnip(     'sql',      '```sql'     ,            '```', 'SpecialComment')
  call TextEnableCodeSnip(      'sh',      '```bash'    ,            '```', 'SpecialComment')
  call TextEnableCodeSnip(    'html',      '```html'    ,            '```', 'SpecialComment')
  call TextEnableCodeSnip(  'python',      '```python'  ,            '```', 'SpecialComment')
  call TextEnableCodeSnip('markdown',      '```markdown',            '```', 'SpecialComment')
endf

function! Toggle_snip_syntax()
  let g:is_sniping = !g:is_sniping
  if  exists('b:snip_visited') && b:snip_visited==0 
      echo g:is_sniping ? "enable_snip_hl" : "disable_snip_hl" 
  endif
  call Update_snip_syntax()
endf

let g:is_sniping = 0

" auto:
" @begin=sh@
" @end=sh@
" sed -i -e '/@begin=/s/@$//g' -e '/@begin=/s/@begin=/```/g'  *
" sed -i -e '/@end=/s/@$//g' -e '/@end=/s/@end=/```/g'  *
nmap <silent> \il         :call C_InsertTemplate("idioms.mysnip")<CR>
imap <silent> \il    <Esc>:call C_InsertTemplate("idioms.mysnip")<CR>

function! MyTabLine()
  let s = ''
  for i in range(tabpagenr('$'))
    " select the highlighting
    if i + 1 == tabpagenr()
      let s .= '%#TabLineSel#'
    else
      let s .= '%#TabLine#'
    endif

    " set the tab page number (for mouse clicks)
    let s .= '%' . (i + 1) . 'T'
    let s .= '[' . i . ']'

    " the label is made by MyTabLabel()
    let s .= ' %{MyTabLabel(' . (i + 1) . ')} '
  endfor

  " after the last tab fill with TabLineFill and reset tab page nr
  let s .= '%#TabLineFill#%T'

  " right-align the label to close the current tab page
  if tabpagenr('$') > 1
    let s .= '%=%#TabLine#%999Xclose'
  endif

  return s
endfunction

function! MyTabLabel(n)
  let buflist = tabpagebuflist(a:n)
  let winnr = tabpagewinnr(a:n)
  let file = bufname(buflist[winnr - 1])
  let tip = ''
  if getbufvar(file, '&modified')
      let tip = '+ '
  endif
  if file == ''
      if getbufvar(file, '&buftype') == 'quickfix'
          let file = '__Quickfix__'
      else
          let file = '[No Name]'
      endif
  endif
  return tip . fnamemodify(file, ':t')
endfunction

function! Asc_comp(i1, i2)
   return a:i1 - a:i2
endfunc

function! LSB()
  let buf_list = []
  for i in range(tabpagenr('$'))
    let buf_list += tabpagebuflist(i+1)
  endfor

  echo sort(buf_list, "Asc_comp")
  echo "nr    cnt  bufname"

  let o = 0
  for i in buf_list
      if o != i
         let nr=count(buf_list, i)
         let tip = ''
         if i < 10
             let tip = ' '
         endif

         let file = bufname(i)
         if file == ''
             if getbufvar(file, '&buftype') == 'quickfix'
                 let file = '__Quickfix__'
             else
                 let file = '[No Name]'
             endif
         endif

         echo tip . i . '    ' . nr . '    ' . file
      endif
      let o = i
  endfor
endfunction

" ====================== exec ======================================

set tabline=%!MyTabLine()
"et switchbuf=useopen,usetab
