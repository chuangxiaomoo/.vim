fu! <SID>arrowS()

    nm <Up>    r↑k
    nm <Down>  r↓j
    nm <Left>  r←h
    nm <Right> r→l
    nm ,e :call <SID>arrowE()<CR>

endf

fu! <SID>arrowE()
    nun <Up>
    nun <Down>
    nun <Left>
    nun <Right>
    call Source_comma_map()
endf

" :nmap ,a :call <SID>arrowS()<CR>

