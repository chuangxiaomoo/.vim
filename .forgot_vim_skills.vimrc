"
" .forgot_vim_skills.vimrc 
"
    " / 搜索 \c 忽略大小写
    /<patter>\c 
    
    " s 全局替换不报错 /ge 
    
    
    " | 多命令 s multi command
    :'<,'>s/a/b/g|'<,'>s/A/B/g
    "
    " \| 多命令 /, cscope 在cxx中就可以由多关键字更准确的搜索 
    /abc\|123\|456
    
    " 匹配到"foo", "foobar", "foofoo", "barfoobar"
    /\(foo\|bar\)\+

    " \& 过滤匹配 fortuin forever
    " \& 在 :s 替换时可以实现精确替换
    /forever\&...

    " 空格 to tab, to replace space to <tab>
    " 为方便 load sql, 可以用自己写的 <C-X>t
    :set ts=8 expandtab
    :%retab!

    " tab to 空格, to replace space to <tab>
    :set ts=4 noexpandtab
    :%retab!

    " 选择性替换 replace，使用sed的地址功能
    :g/^\a/s/$/ /<CR>   

    " :g 与 :s 一样，可以用其后的字符(e.g. +)作为 模式 seprator
    :g+//+s/foobar/barfoo/g

    " 跨行搜索 :help \_
    /ygp\_s\+nmap

    " 文件路径名 与 单词
    iskeyword
    isfname

    " don't issue an error message when fail，错误时不中断map
    :%s/pattern/toword/ge

    " vs goto line of tag_you_want
    :vs +/tag_you_want file


    " vi file 跳转
    +/{pat}
    +[num]
    

" ----------------------------------------------------------------------------
    fuzzyfinder.vim 听说是个利器

" ----------------------------------------------------------------------------
    <C-X><C-I>      在本文件字典中补全，而不是所有buffer
    <C-X><C-L>      补全一行

" ----------------------------------------------------------------------------
    -select text-objects 用ai选中一个块

" ----------------------------------------------------------------------------
" 定制tabline  set tabline=%{ShortTabLabel()}
" http://liyanrui.is-programmer.com/2008/3/30/vim-tab-label-usage.1857.html

" ----------------------------------------------------------------------------
"   使用vim的会话(session)及viminfo
" http://easwy.com/blog/archives/advanced-vim-skills-session-file-and-viminfo/

