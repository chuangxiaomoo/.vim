"========================================================
" Highlight All Function
"========================================================

" syn match   cFunction "\<[a-zA-Z_][a-zA-Z_0-9]*\>*("me=e-1
" syn match   cFunction   "[a-zA-Z_][a-zA-Z_0-9]*\s*("me=e-1
" syn match   cFunction   "[a-zA-Z_][a-zA-Z_0-9]*\s("me=e-2

"========================================================
" Highlight All Math Operator
"========================================================
" C math operators
syn match       cMathOperator     display "[-+*/%=]"

" C Ternary conditional 
" syn region    cMulti
" syn match       cTernary          display "?\| : "   

" C pointer operators
syn match       cPointerOperator  display "->\|\."

" C bit operators
syn match       cBinaryOperator   display "\(&\||\|\^\|<<\|>>\)=\="
syn match       cBinaryOperator   "\~"
syn match       cBinaryOperatorError display "\~="

" More C logical operators - highlight in preference to binary
syn match       cLogicalOperator  display "[!<>]=\="
syn match       cLogicalOperator  display "=="

" C logical   operators - boolean results
syn match       cLogicalOperator  display "&&\|||"
syn match       cLogicalOperatorError display "\(&&\|||\)="


" Math Operator
hi def link cFunction              cFuncolor
hi def link cMathOperator          Opercolor
hi def link cTernary               Opercolor
hi def link cPointerOperator       Opercolor
hi def link cLogicalOperator       Opercolor
hi def link cBinaryOperator        Opercolor
hi def link cBinaryOperatorError   cError
hi def link cLogicalOperator       Opercolor
hi def link cLogicalOperatorError  Opercolor

syn keyword cType       BOOL My_Type_1 My_Type_2 My_Type_3 dyn
syn keyword cConstant   FAILURE SUCCESS FALSE TRUE RETVOID __FUNCTION__
syn keyword	cStatement	TEST return_val_if_fail return_if_fail goto_tag_if_fail until list_for_each_safe
syn keyword	cStatement	once init thread
"yn keyword	cRepeat		TEST return_val_if_fail return_if_fail
"yn keyword	cStatement	xt_pri xt_dbg xt_ret xt_goto sy_ret sy_goto

" /usr/share/vim/vim73/syntax/syncolor.vim
" /usr/share/vim/vim73/syntax/c.vim
