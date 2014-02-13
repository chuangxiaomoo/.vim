"#################################################################################
"
"       Filename:  ruby-support.vim
"
"    Description:  BASH support     (VIM Version 7.0+)
"
"                  Write BASH-scripts by inserting comments, statements, tests,
"                  variables and builtins.
"
"  Configuration:  There are some personal details which should be configured
"                    (see the files README.rubysupport and rubysupport.txt).
"
"   Dependencies:  The environmnent variables $HOME und $SHELL are used.
"
"   GVIM Version:  7.0+
"
"         Author:  Dr.-Ing. Fritz Mehner, FH Südwestfalen, 58644 Iserlohn, Germany
"          Email:  mehner@fh-swf.de
"
"        Version:  see variable  g:RUBY_Version  below
"        Created:  26.02.2001
"        License:  Copyright (c) 2001-2011, Fritz Mehner
"                  This program is free software; you can redistribute it and/or
"                  modify it under the terms of the GNU General Public License as
"                  published by the Free Software Foundation, version 2 of the
"                  License.
"                  This program is distributed in the hope that it will be
"                  useful, but WITHOUT ANY WARRANTY; without even the implied
"                  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
"                  PURPOSE.
"                  See the GNU General Public License version 2 for more details.
"       Revision:  $Id: ruby-support.vim,v 1.111 2011/12/24 12:23:49 mehner Exp $
"
"------------------------------------------------------------------------------
"
" Prevent duplicate loading:
"
if exists("g:RUBY_Version") || &cp
 finish
endif
let g:RUBY_Version= "3.9"  						" version number of this script; do not change
"
if v:version < 700
  echohl WarningMsg | echo 'plugin ruby-support.vim needs Vim version >= 7'| echohl None
endif
"
"#################################################################################
"
" Platform specific items:
"
"
let	s:MSWIN =		has("win16") || has("win32") || has("win64") || has("win95")
"
let s:installation						= '*undefined*'
let s:RUBY_GlobalTemplateFile	= ''
let s:RUBY_GlobalTemplateDir	= ''
"
if	s:MSWIN
  " ==========  MS Windows  ======================================================
	"
	" change '\' to '/' to avoid interpretation as escape character
	if match(	substitute( expand("<sfile>"), '\', '/', 'g' ), 
				\		substitute( expand("$HOME"),   '\', '/', 'g' ) ) == 0
		" USER INSTALLATION ASSUMED
		let s:installation						= 'local'
		let s:plugin_dir  						= substitute( expand('<sfile>:p:h:h'), '\', '/', 'g' )
		let s:RUBY_LocalTemplateFile	= s:plugin_dir.'/ruby-support/templates/Templates'
		let s:RUBY_LocalTemplateDir		= fnamemodify( s:RUBY_LocalTemplateFile, ":p:h" ).'/'
	else
		" SYSTEM WIDE INSTALLATION
		let s:installation						= 'system'
		let s:plugin_dir  						= $VIM.'/vimfiles'
		let s:RUBY_GlobalTemplateDir	= s:plugin_dir.'/ruby-support/templates'
		let s:RUBY_GlobalTemplateFile	= s:RUBY_GlobalTemplateDir.'/Templates'
		let s:RUBY_LocalTemplateFile	= $HOME.'/vimfiles/ruby-support/templates/Templates'
		let s:RUBY_LocalTemplateDir		= fnamemodify( s:RUBY_LocalTemplateFile, ":p:h" ).'/'
	end
	"
	let s:RUBY_BASH									= 'ruby.exe'
	let s:RUBY_Man        					= 'man.exe'
	let s:RUBY_OutputGvim						= 'xterm'
else
  " ==========  Linux/Unix  ======================================================
	"
	if match( expand("<sfile>"), expand("$HOME") ) == 0
		" USER INSTALLATION ASSUMED
		let s:installation						= 'local'
		let s:plugin_dir  						= expand('<sfile>:p:h:h')
		let s:RUBY_LocalTemplateFile	= s:plugin_dir.'/ruby-support/templates/Templates'
		let s:RUBY_LocalTemplateDir		= fnamemodify( s:RUBY_LocalTemplateFile, ":p:h" ).'/'
	else
		" SYSTEM WIDE INSTALLATION
		let s:installation						= 'system'
		let s:plugin_dir  						= $VIM.'/vimfiles'
		let s:RUBY_GlobalTemplateDir	= s:plugin_dir.'/ruby-support/templates'
		let s:RUBY_GlobalTemplateFile	= s:RUBY_GlobalTemplateDir.'/Templates'
		let s:RUBY_LocalTemplateFile	= $HOME.'/.vim/ruby-support/templates/Templates'
		let s:RUBY_LocalTemplateDir		= fnamemodify( s:RUBY_LocalTemplateFile, ":p:h" ).'/'
	end
	"
	let s:RUBY_BASH									= $SHELL
	let s:RUBY_Man        					= 'man'
	let s:RUBY_OutputGvim						= 'vim'
  " ==============================================================================
endif
"
"
"------------------------------------------------------------------------------
"
	let s:RUBY_CodeSnippets  				= s:plugin_dir.'/ruby-support/codesnippets/'
"
"  g:RUBY_Dictionary_File  must be global
"
if !exists("g:RUBY_Dictionary_File")
	let g:RUBY_Dictionary_File     = s:plugin_dir.'/ruby-support/wordlists/ruby.list'
endif
"
"  Modul global variables    {{{1
"
let s:RUBY_MenuHeader							= 'yes'
let s:RUBY_Root										= 'B&ash.'
let s:RUBY_Debugger               = 'term'
let s:RUBY_rubydb                 = 'rubydb'
let s:RUBY_LineEndCommColDefault  = 49
let s:RUBY_LoadMenus              = 'yes'
let s:RUBY_CreateMenusDelayed     = 'no'
let s:RUBY_TemplateOverriddenMsg	= 'no'
let s:RUBY_SyntaxCheckOptionsGlob = ''
"
let s:RUBY_XtermDefaults          = '-fa courier -fs 12 -geometry 80x24'
let s:RUBY_GuiSnippetBrowser      = 'gui'										" gui / commandline
let s:RUBY_GuiTemplateBrowser     = 'gui'										" gui / explorer / commandline
let s:RUBY_Printheader            = "%<%f%h%m%<  %=%{strftime('%x %X')}     Page %N"
let s:RUBY_Wrapper                = s:plugin_dir.'/ruby-support/scripts/wrapper.sh'
"
"let s:RUBY_FormatDate						= '%x'
"let s:RUBY_FormatTime						= '%X %Z'
let s:RUBY_Errorformat    			= '%f:\ %s\ %l:\ %m'
let s:RUBY_FormatDate						= '%F'
let s:RUBY_FormatTime						= '%X'
let s:RUBY_FormatYear						= '%Y'
"
let s:RUBY_Ctrl_j								= 'on'
let s:RUBY_TJT									= '[ 0-9a-zA-Z_]*'
let s:RUBY_TemplateJumpTarget1  = '<+'.s:RUBY_TJT.'+>\|{+'.s:RUBY_TJT.'+}'
let s:RUBY_TemplateJumpTarget2  = '<-'.s:RUBY_TJT.'->\|{-'.s:RUBY_TJT.'-}'
let s:RUBY_FileFormat						= 'unix'
"
"------------------------------------------------------------------------------
"  Some variables for internal use only
"------------------------------------------------------------------------------
let s:RUBY_Active         = -1                    " state variable controlling the Ruby-menus
let s:RUBY_SetCounter     = 0                     "
let s:RUBY_Set_Txt        = "SetOptionNumber_"
let s:RUBY_Shopt_Txt      = "ShoptOptionNumber_"
"
"------------------------------------------------------------------------------
"  Look for global variables (if any)    {{{1
"------------------------------------------------------------------------------
function! RUBY_CheckGlobal ( name )
  if exists('g:'.a:name)
    exe 'let s:'.a:name.'  = g:'.a:name
  endif
endfunction   " ---------- end of function  RUBY_CheckGlobal  ----------
"
call RUBY_CheckGlobal('RUBY_BASH                  ')
call RUBY_CheckGlobal('RUBY_Errorformat           ')
call RUBY_CheckGlobal('RUBY_CodeSnippets          ')
call RUBY_CheckGlobal('RUBY_Ctrl_j                ')
call RUBY_CheckGlobal('RUBY_Debugger              ')
call RUBY_CheckGlobal('RUBY_rubydb                ')
call RUBY_CheckGlobal('RUBY_FileFormat            ')
call RUBY_CheckGlobal('RUBY_FormatDate            ')
call RUBY_CheckGlobal('RUBY_FormatTime            ')
call RUBY_CheckGlobal('RUBY_FormatYear            ')
call RUBY_CheckGlobal('RUBY_GuiSnippetBrowser     ')
call RUBY_CheckGlobal('RUBY_GuiTemplateBrowser    ')
call RUBY_CheckGlobal('RUBY_LineEndCommColDefault ')
call RUBY_CheckGlobal('RUBY_LoadMenus             ')
call RUBY_CheckGlobal('RUBY_CreateMenusDelayed    ')
call RUBY_CheckGlobal('RUBY_Man                   ')
call RUBY_CheckGlobal('RUBY_MenuHeader            ')
call RUBY_CheckGlobal('RUBY_OutputGvim            ')
call RUBY_CheckGlobal('RUBY_Printheader           ')
call RUBY_CheckGlobal('RUBY_Root                  ')
call RUBY_CheckGlobal('RUBY_SyntaxCheckOptionsGlob')
call RUBY_CheckGlobal('RUBY_TemplateOverriddenMsg ')
call RUBY_CheckGlobal('RUBY_XtermDefaults         ')
call RUBY_CheckGlobal('RUBY_GlobalTemplateFile    ')

if exists('g:RUBY_GlobalTemplateFile') && !empty(g:RUBY_GlobalTemplateFile)
	let s:RUBY_GlobalTemplateDir	= fnamemodify( s:RUBY_GlobalTemplateFile, ":h" )
endif
"
" set default geometry if not specified
"
if match( s:RUBY_XtermDefaults, "-geometry\\s\\+\\d\\+x\\d\\+" ) < 0
	let s:RUBY_XtermDefaults	= s:RUBY_XtermDefaults." -geometry 80x24"
endif
"
" escape the printheader
"
let s:RUBY_Printheader  = escape( s:RUBY_Printheader, ' %' )
"
"------------------------------------------------------------------------------
"  Control variables (not user configurable)
"------------------------------------------------------------------------------
let s:Attribute                = { 'below':'', 'above':'', 'start':'', 'append':'', 'insert':'' }
let s:RUBY_Attribute           = {}
let s:RUBY_ExpansionLimit      = 10
let s:RUBY_FileVisited         = []
"
let s:RUBY_MacroNameRegex        = '\([a-zA-Z][a-zA-Z0-9_]*\)'
let s:RUBY_MacroLineRegex				 = '^\s*|'.s:RUBY_MacroNameRegex.'|\s*=\s*\(.*\)'
let s:RUBY_MacroCommentRegex		 = '^§'
let s:RUBY_ExpansionRegex				 = '|?'.s:RUBY_MacroNameRegex.'\(:\a\)\?|'
let s:RUBY_NonExpansionRegex		 = '|'.s:RUBY_MacroNameRegex.'\(:\a\)\?|'
"
let s:RUBY_TemplateNameDelimiter = '-+_,\. '
let s:RUBY_TemplateLineRegex		 = '^==\s*\([a-zA-Z][0-9a-zA-Z'.s:RUBY_TemplateNameDelimiter
let s:RUBY_TemplateLineRegex		.= ']\+\)\s*==\s*\([a-z]\+\s*==\)\?'
let s:RUBY_TemplateIf						 = '^==\s*IF\s\+|STYLE|\s\+IS\s\+'.s:RUBY_MacroNameRegex.'\s*=='
let s:RUBY_TemplateEndif				 = '^==\s*ENDIF\s*=='
"
let s:RUBY_ExpansionCounter     = {}
let s:RUBY_TJT									= '[ 0-9a-zA-Z_]*'
let s:RUBY_TemplateJumpTarget1  = '<+'.s:RUBY_TJT.'+>\|{+'.s:RUBY_TJT.'+}'
let s:RUBY_TemplateJumpTarget2  = '<-'.s:RUBY_TJT.'->\|{-'.s:RUBY_TJT.'-}'
let s:RUBY_Macro                = {'|AUTHOR|'         : 'first name surname',
											\						 '|AUTHORREF|'      : '',
											\						 '|COMPANY|'        : '',
											\						 '|COPYRIGHTHOLDER|': '',
											\						 '|EMAIL|'          : '',
											\						 '|LICENSE|'        : 'GNU General Public License',
											\						 '|ORGANIZATION|'   : '',
											\						 '|PROJECT|'        : '',
											\		 				 '|STYLE|'          : ''
											\						}
let	s:RUBY_MacroFlag						= {	':l' : 'lowercase'			,
											\							':u' : 'uppercase'			,
											\							':c' : 'capitalize'		,
											\							':L' : 'legalize name'	,
											\						}
let s:RUBY_ActualStyle					= 'default'
let s:RUBY_ActualStyleLast			= s:RUBY_ActualStyle
let s:RUBY_Template             = { 'default' : {} }
let s:RUBY_TemplatesLoaded			= 'no'

let s:MsgInsNotAvail	= "insertion not available for a fold"
let s:RUBY_saved_option					= {}
"
"------------------------------------------------------------------------------
"  BASH Menu Initialization      {{{1
"------------------------------------------------------------------------------
function!	RUBY_InitMenu ()
	"
	"===============================================================================================
	"----- menu Main menu entry -------------------------------------------   {{{2
	"===============================================================================================
	"
	"-------------------------------------------------------------------------------
	"----- Menu : root menu  ---------------------------------------------------------------------
	"-------------------------------------------------------------------------------
	if s:RUBY_MenuHeader == "yes"
		call RUBY_InitMenuHeader()
	endif
	"
	"-------------------------------------------------------------------------------
	"----- menu Comments   {{{2
	"-------------------------------------------------------------------------------
	exe " menu           ".s:RUBY_Root.'&Comments.end-of-&line\ comment<Tab>\\cl                    :call RUBY_EndOfLineComment()<CR>'
	exe "imenu           ".s:RUBY_Root.'&Comments.end-of-&line\ comment<Tab>\\cl               <Esc>:call RUBY_EndOfLineComment()<CR>'
	exe "vmenu <silent>  ".s:RUBY_Root.'&Comments.end-of-&line\ comment<Tab>\\cl               <Esc>:call RUBY_MultiLineEndComments()<CR>A'

	exe " menu <silent>  ".s:RUBY_Root.'&Comments.ad&just\ end-of-line\ com\.<Tab>\\cj              :call RUBY_AdjustLineEndComm()<CR>'
	exe "imenu <silent>  ".s:RUBY_Root.'&Comments.ad&just\ end-of-line\ com\.<Tab>\\cj         <Esc>:call RUBY_AdjustLineEndComm()<CR>'
	exe "vmenu <silent>  ".s:RUBY_Root.'&Comments.ad&just\ end-of-line\ com\.<Tab>\\cj              :call RUBY_AdjustLineEndComm()<CR>'

	exe " menu <silent>  ".s:RUBY_Root.'&Comments.&set\ end-of-line\ com\.\ col\.<Tab>\\cs          :call RUBY_GetLineEndCommCol()<CR>'
	exe "imenu <silent>  ".s:RUBY_Root.'&Comments.&set\ end-of-line\ com\.\ col\.<Tab>\\cs     <Esc>:call RUBY_GetLineEndCommCol()<CR>'

	exe " menu <silent>  ".s:RUBY_Root.'&Comments.&frame\ comment<Tab>\\cfr                         :call RUBY_InsertTemplate("comment.frame")<CR>'
	exe "imenu <silent>  ".s:RUBY_Root.'&Comments.&frame\ comment<Tab>\\cfr                    <Esc>:call RUBY_InsertTemplate("comment.frame")<CR>'
	exe " menu <silent>  ".s:RUBY_Root.'&Comments.f&unction\ description<Tab>\\cfu                  :call RUBY_InsertTemplate("comment.function")<CR>'
	exe "imenu <silent>  ".s:RUBY_Root.'&Comments.f&unction\ description<Tab>\\cfu             <Esc>:call RUBY_InsertTemplate("comment.function")<CR>'
	exe " menu <silent>  ".s:RUBY_Root.'&Comments.file\ &header<Tab>\\ch                            :call RUBY_InsertTemplate("comment.file-description")<CR>'
	exe "imenu <silent>  ".s:RUBY_Root.'&Comments.file\ &header<Tab>\\ch                       <Esc>:call RUBY_InsertTemplate("comment.file-description")<CR>'

	exe "amenu ".s:RUBY_Root.'&Comments.-Sep1-                    :'
	exe " menu <silent>  ".s:RUBY_Root."&Comments.toggle\\ &comment<Tab>\\\\cc        :call RUBY_CommentToggle()<CR>j"
	exe "imenu <silent>  ".s:RUBY_Root."&Comments.toggle\\ &comment<Tab>\\\\cc   <Esc>:call RUBY_CommentToggle()<CR>j"
	exe "vmenu <silent>  ".s:RUBY_Root."&Comments.toggle\\ &comment<Tab>\\\\cc        :call RUBY_CommentToggle()<CR>j"
	exe "amenu ".s:RUBY_Root.'&Comments.-SEP2-                    :'

	exe " menu ".s:RUBY_Root.'&Comments.&date<Tab>\\cd                       :call RUBY_InsertDateAndTime("d")<CR>'
	exe "imenu ".s:RUBY_Root.'&Comments.&date<Tab>\\cd                  <Esc>:call RUBY_InsertDateAndTime("d")<CR>a'
	exe "vmenu ".s:RUBY_Root.'&Comments.&date<Tab>\\cd                 s<Esc>:call RUBY_InsertDateAndTime("d")<CR>'
	exe " menu ".s:RUBY_Root.'&Comments.date\ &time<Tab>\\ct                 :call RUBY_InsertDateAndTime("dt")<CR>'
	exe "imenu ".s:RUBY_Root.'&Comments.date\ &time<Tab>\\ct            <Esc>:call RUBY_InsertDateAndTime("dt")<CR>a'
	exe "vmenu ".s:RUBY_Root.'&Comments.date\ &time<Tab>\\ct           s<Esc>:call RUBY_InsertDateAndTime("dt")<CR>'
	"
	exe "amenu ".s:RUBY_Root.'&Comments.-SEP3-                    :'
	"
	exe " noremenu ".s:RUBY_Root.'&Comments.&echo\ "<line>"<Tab>\\ce       :call RUBY_echo_comment()<CR>j'
	exe "inoremenu ".s:RUBY_Root.'&Comments.&echo\ "<line>"<Tab>\\ce  <C-C>:call RUBY_echo_comment()<CR>j'
	exe " noremenu ".s:RUBY_Root.'&Comments.&remove\ echo<Tab>\\cr         :call RUBY_remove_echo()<CR>j'
	exe "inoremenu ".s:RUBY_Root.'&Comments.&remove\ echo<Tab>\\cr    <C-C>:call RUBY_remove_echo()<CR>j'
	"
	exe "amenu ".s:RUBY_Root.'&Comments.-SEP4-                    :'
	"
	"----- Submenu : BASH-Comments : Script Sections  ----------------------------------------------------------
	"
	if s:RUBY_MenuHeader == "yes"
	exe "amenu ".s:RUBY_Root.'&Comments.&script\ sections<Tab>\\css.Comments-1<Tab>Ruby   :call RUBY_MenuTitle()<CR>'
	exe "amenu ".s:RUBY_Root.'&Comments.&script\ sections<Tab>\\css.-Sep1-                :'
	endif
	"
	exe " menu <silent> ".s:RUBY_Root.'&Comments.&script\ sections<Tab>\\css.GLOBALS            :call RUBY_InsertTemplate("comment.file-sections-globals"   )<CR>'
	exe " menu <silent> ".s:RUBY_Root.'&Comments.&script\ sections<Tab>\\css.CMD\.LINE          :call RUBY_InsertTemplate("comment.file-sections-cmdline"   )<CR>'
	exe " menu <silent> ".s:RUBY_Root.'&Comments.&script\ sections<Tab>\\css.SAN\.CHECKS        :call RUBY_InsertTemplate("comment.file-sections-sanchecks" )<CR>'
	exe " menu <silent> ".s:RUBY_Root.'&Comments.&script\ sections<Tab>\\css.FUNCT\.DEF\.       :call RUBY_InsertTemplate("comment.file-sections-functdef"  )<CR>'
	exe " menu <silent> ".s:RUBY_Root.'&Comments.&script\ sections<Tab>\\css.TRAPS              :call RUBY_InsertTemplate("comment.file-sections-traps"     )<CR>'
	exe " menu <silent> ".s:RUBY_Root.'&Comments.&script\ sections<Tab>\\css.MAIN\ SCRIPT       :call RUBY_InsertTemplate("comment.file-sections-mainscript")<CR>'
	exe " menu <silent> ".s:RUBY_Root.'&Comments.&script\ sections<Tab>\\css.STAT+CLEANUP       :call RUBY_InsertTemplate("comment.file-sections-statistics")<CR>'
	"
	exe "imenu <silent> ".s:RUBY_Root.'&Comments.&script\ sections<Tab>\\css.GLOBALS       <C-C>:call RUBY_InsertTemplate("comment.file-sections-globals"   )<CR>'
	exe "imenu <silent> ".s:RUBY_Root.'&Comments.&script\ sections<Tab>\\css.CMD\.LINE     <C-C>:call RUBY_InsertTemplate("comment.file-sections-cmdline"   )<CR>'
	exe "imenu <silent> ".s:RUBY_Root.'&Comments.&script\ sections<Tab>\\css.SAN\.CHECKS   <C-C>:call RUBY_InsertTemplate("comment.file-sections-sanchecks" )<CR>'
	exe "imenu <silent> ".s:RUBY_Root.'&Comments.&script\ sections<Tab>\\css.FUNCT\.DEF\.  <C-C>:call RUBY_InsertTemplate("comment.file-sections-functdef"  )<CR>'
	exe "imenu <silent> ".s:RUBY_Root.'&Comments.&script\ sections<Tab>\\css.TRAPS         <C-C>:call RUBY_InsertTemplate("comment.file-sections-traps"     )<CR>'
	exe "imenu <silent> ".s:RUBY_Root.'&Comments.&script\ sections<Tab>\\css.MAIN\ SCRIPT  <C-C>:call RUBY_InsertTemplate("comment.file-sections-mainscript")<CR>'
	exe "imenu <silent> ".s:RUBY_Root.'&Comments.&script\ sections<Tab>\\css.STAT+CLEANUP  <C-C>:call RUBY_InsertTemplate("comment.file-sections-statistics")<CR>'
	"
	"----- Submenu : BASH-Comments : Keywords  ----------------------------------------------------------
	"
	if s:RUBY_MenuHeader == "yes"
	exe "amenu ".s:RUBY_Root.'&Comments.\#\ \:&KEYWORD\:<Tab>\\ckc.Comments-2<Tab>Ruby :call RUBY_MenuTitle()<CR>'
	exe "amenu ".s:RUBY_Root.'&Comments.\#\ \:&KEYWORD\:<Tab>\\ckc.-Sep1-              :'
	exe "amenu ".s:RUBY_Root.'&Comments.ta&gs\ (plugin).Comments-3<Tab>Ruby  :call RUBY_MenuTitle()<CR>'
	exe "amenu ".s:RUBY_Root.'&Comments.ta&gs\ (plugin).-Sep1-               :'
	endif
	"
	exe " menu <silent> ".s:RUBY_Root.'&Comments.\#\ \:&KEYWORD\:<Tab>\\ckc.&BUG<Tab>\\ckb                :call RUBY_InsertTemplate("comment.keyword-bug")       <CR>'
	exe " menu <silent> ".s:RUBY_Root.'&Comments.\#\ \:&KEYWORD\:<Tab>\\ckc.&TODO<Tab>\\ckt               :call RUBY_InsertTemplate("comment.keyword-todo")      <CR>'
	exe " menu <silent> ".s:RUBY_Root.'&Comments.\#\ \:&KEYWORD\:<Tab>\\ckc.T&RICKY<Tab>\\ckr             :call RUBY_InsertTemplate("comment.keyword-tricky")    <CR>'
	exe " menu <silent> ".s:RUBY_Root.'&Comments.\#\ \:&KEYWORD\:<Tab>\\ckc.&WARNING<Tab>\\ckw            :call RUBY_InsertTemplate("comment.keyword-warning")   <CR>'
	exe " menu <silent> ".s:RUBY_Root.'&Comments.\#\ \:&KEYWORD\:<Tab>\\ckc.&WORKAROUND<Tab>\\cko         :call RUBY_InsertTemplate("comment.keyword-workaround")<CR>'
	exe " menu <silent> ".s:RUBY_Root.'&Comments.\#\ \:&KEYWORD\:<Tab>\\ckc.&new\ keyword<Tab>\\ckn       :call RUBY_InsertTemplate("comment.keyword-keyword")   <CR>'
	"
	exe "imenu <silent> ".s:RUBY_Root.'&Comments.\#\ \:&KEYWORD\:<Tab>\\ckc.&BUG<Tab>\\ckb           <C-C>:call RUBY_InsertTemplate("comment.keyword-bug")     <CR>'
	exe "imenu <silent> ".s:RUBY_Root.'&Comments.\#\ \:&KEYWORD\:<Tab>\\ckc.&TODO<Tab>\\ckt          <C-C>:call RUBY_InsertTemplate("comment.keyword-todo")    <CR>'
	exe "imenu <silent> ".s:RUBY_Root.'&Comments.\#\ \:&KEYWORD\:<Tab>\\ckc.T&RICKY<Tab>\\ckr        <C-C>:call RUBY_InsertTemplate("comment.keyword-tricky")  <CR>'
	exe "imenu <silent> ".s:RUBY_Root.'&Comments.\#\ \:&KEYWORD\:<Tab>\\ckc.&WARNING<Tab>\\ckw       <C-C>:call RUBY_InsertTemplate("comment.keyword-warning") <CR>'
	exe "imenu <silent> ".s:RUBY_Root.'&Comments.\#\ \:&KEYWORD\:<Tab>\\ckc.&WORKAROUND<Tab>\\cko    <C-C>:call RUBY_InsertTemplate("comment.keyword-workaround") <CR>'
	exe "imenu <silent> ".s:RUBY_Root.'&Comments.\#\ \:&KEYWORD\:<Tab>\\ckc.&new\ keyword<Tab>\\ckn  <C-C>:call RUBY_InsertTemplate("comment.keyword-keyword")        <CR>'
	"
	"----- Submenu : BASH-Comments : Tags  ----------------------------------------------------------
	"
	exe "amenu ".s:RUBY_Root.'&Comments.ta&gs\ (plugin).&AUTHOR                :call RUBY_InsertMacroValue("AUTHOR")<CR>'
	exe "amenu ".s:RUBY_Root.'&Comments.ta&gs\ (plugin).&AUTHORREF             :call RUBY_InsertMacroValue("AUTHORREF")<CR>'
	exe "amenu ".s:RUBY_Root.'&Comments.ta&gs\ (plugin).&COMPANY               :call RUBY_InsertMacroValue("COMPANY")<CR>'
	exe "amenu ".s:RUBY_Root.'&Comments.ta&gs\ (plugin).&COPYRIGHTHOLDER       :call RUBY_InsertMacroValue("COPYRIGHTHOLDER")<CR>'
	exe "amenu ".s:RUBY_Root.'&Comments.ta&gs\ (plugin).&EMAIL                 :call RUBY_InsertMacroValue("EMAIL")<CR>'
	exe "amenu ".s:RUBY_Root.'&Comments.ta&gs\ (plugin).&LICENSE               :call RUBY_InsertMacroValue("LICENSE")<CR>'
	exe "amenu ".s:RUBY_Root.'&Comments.ta&gs\ (plugin).&ORGANIZATION          :call RUBY_InsertMacroValue("ORGANIZATION")<CR>'
	exe "amenu ".s:RUBY_Root.'&Comments.ta&gs\ (plugin).&PROJECT               :call RUBY_InsertMacroValue("PROJECT")<CR>'

	exe "imenu ".s:RUBY_Root.'&Comments.ta&gs\ (plugin).&AUTHOR           <Esc>:call RUBY_InsertMacroValue("AUTHOR")<CR>a'
	exe "imenu ".s:RUBY_Root.'&Comments.ta&gs\ (plugin).&AUTHORREF        <Esc>:call RUBY_InsertMacroValue("AUTHORREF")<CR>a'
	exe "imenu ".s:RUBY_Root.'&Comments.ta&gs\ (plugin).&COMPANY          <Esc>:call RUBY_InsertMacroValue("COMPANY")<CR>a'
	exe "imenu ".s:RUBY_Root.'&Comments.ta&gs\ (plugin).&COPYRIGHTHOLDER  <Esc>:call RUBY_InsertMacroValue("COPYRIGHTHOLDER")<CR>a'
	exe "imenu ".s:RUBY_Root.'&Comments.ta&gs\ (plugin).&EMAIL            <Esc>:call RUBY_InsertMacroValue("EMAIL")<CR>a'
	exe "imenu ".s:RUBY_Root.'&Comments.ta&gs\ (plugin).&LICENSE          <Esc>:call RUBY_InsertMacroValue("LICENSE")<CR>a'
	exe "imenu ".s:RUBY_Root.'&Comments.ta&gs\ (plugin).&ORGANIZATION     <Esc>:call RUBY_InsertMacroValue("ORGANIZATION")<CR>a'
	exe "imenu ".s:RUBY_Root.'&Comments.ta&gs\ (plugin).&PROJECT          <Esc>:call RUBY_InsertMacroValue("PROJECT")<CR>a'

	exe "vmenu ".s:RUBY_Root.'&Comments.ta&gs\ (plugin).&AUTHOR          s<Esc>:call RUBY_InsertMacroValue("AUTHOR")<CR>a'
	exe "vmenu ".s:RUBY_Root.'&Comments.ta&gs\ (plugin).&AUTHORREF       s<Esc>:call RUBY_InsertMacroValue("AUTHORREF")<CR>a'
	exe "vmenu ".s:RUBY_Root.'&Comments.ta&gs\ (plugin).&COMPANY         s<Esc>:call RUBY_InsertMacroValue("COMPANY")<CR>a'
	exe "vmenu ".s:RUBY_Root.'&Comments.ta&gs\ (plugin).&COPYRIGHTHOLDER s<Esc>:call RUBY_InsertMacroValue("COPYRIGHTHOLDER")<CR>a'
	exe "vmenu ".s:RUBY_Root.'&Comments.ta&gs\ (plugin).&EMAIL           s<Esc>:call RUBY_InsertMacroValue("EMAIL")<CR>a'
	exe "vmenu ".s:RUBY_Root.'&Comments.ta&gs\ (plugin).&LICENSE         s<Esc>:call RUBY_InsertMacroValue("LICENSE")<CR>a'
	exe "vmenu ".s:RUBY_Root.'&Comments.ta&gs\ (plugin).&ORGANIZATION    s<Esc>:call RUBY_InsertMacroValue("ORGANIZATION")<CR>a'
	exe "vmenu ".s:RUBY_Root.'&Comments.ta&gs\ (plugin).&PROJECT         s<Esc>:call RUBY_InsertMacroValue("PROJECT")<CR>a'

	exe " menu ".s:RUBY_Root.'&Comments.&vim\ modeline<Tab>\\cv               :call RUBY_CommentVimModeline()<CR>'
	exe "imenu ".s:RUBY_Root.'&Comments.&vim\ modeline<Tab>\\cv          <Esc>:call RUBY_CommentVimModeline()<CR>'
	"
	"-------------------------------------------------------------------------------
	"----- menu Statements   {{{2
	"-------------------------------------------------------------------------------

	exe "anoremenu ".s:RUBY_Root.'&Statements.&case<Tab>\\sc	     				:call RUBY_InsertTemplate("statements.case")<CR>'
	exe "anoremenu ".s:RUBY_Root.'&Statements.e&lif<Tab>\\sei							:call RUBY_InsertTemplate("statements.elif")<CR>'
	exe "anoremenu ".s:RUBY_Root.'&Statements.&for\ in<Tab>\\sf						:call RUBY_InsertTemplate("statements.for-in")<CR>'
	exe "anoremenu ".s:RUBY_Root.'&Statements.&for\ ((\.\.\.))<Tab>\\sfo	:call RUBY_InsertTemplate("statements.for")<CR>'
	exe "anoremenu ".s:RUBY_Root.'&Statements.&if<Tab>\\si								:call RUBY_InsertTemplate("statements.if")<CR>'
	exe "anoremenu ".s:RUBY_Root.'&Statements.if-&else<Tab>\\sie					:call RUBY_InsertTemplate("statements.if-else")<CR>'
	exe "anoremenu ".s:RUBY_Root.'&Statements.&select<Tab>\\ss						:call RUBY_InsertTemplate("statements.select")<CR>'
	exe "anoremenu ".s:RUBY_Root.'&Statements.un&til<Tab>\\su							:call RUBY_InsertTemplate("statements.until")<CR>'
	exe "anoremenu ".s:RUBY_Root.'&Statements.&while<Tab>\\sw							:call RUBY_InsertTemplate("statements.while")<CR>'

	exe "inoremenu ".s:RUBY_Root.'&Statements.&case<Tab>\\sc	     				<Esc>:call RUBY_InsertTemplate("statements.case")<CR>'
	exe "inoremenu ".s:RUBY_Root.'&Statements.e&lif<Tab>\\sei							<Esc>:call RUBY_InsertTemplate("statements.elif")<CR>'
	exe "inoremenu ".s:RUBY_Root.'&Statements.&for\ in<Tab>\\sf						<Esc>:call RUBY_InsertTemplate("statements.for-in")<CR>'
	exe "inoremenu ".s:RUBY_Root.'&Statements.&for\ ((\.\.\.))<Tab>\\sfo	<Esc>:call RUBY_InsertTemplate("statements.for")<CR>'
	exe "inoremenu ".s:RUBY_Root.'&Statements.&if<Tab>\\si								<Esc>:call RUBY_InsertTemplate("statements.if")<CR>'
	exe "inoremenu ".s:RUBY_Root.'&Statements.if-&else<Tab>\\sie					<Esc>:call RUBY_InsertTemplate("statements.if-else")<CR>'
	exe "inoremenu ".s:RUBY_Root.'&Statements.&select<Tab>\\ss						<Esc>:call RUBY_InsertTemplate("statements.select")<CR>'
	exe "inoremenu ".s:RUBY_Root.'&Statements.un&til<Tab>\\su							<Esc>:call RUBY_InsertTemplate("statements.until")<CR>'
	exe "inoremenu ".s:RUBY_Root.'&Statements.&while<Tab>\\sw							<Esc>:call RUBY_InsertTemplate("statements.while")<CR>'

	exe "vnoremenu ".s:RUBY_Root.'&Statements.&for\ in<Tab>\\sf						<Esc>:call RUBY_InsertTemplate("statements.for-in", "v")<CR>'
	exe "vnoremenu ".s:RUBY_Root.'&Statements.&for\ ((\.\.\.))<Tab>\\sfo	<Esc>:call RUBY_InsertTemplate("statements.for", "v")<CR>'
	exe "vnoremenu ".s:RUBY_Root.'&Statements.&if<Tab>\\si								<Esc>:call RUBY_InsertTemplate("statements.if", "v")<CR>'
	exe "vnoremenu ".s:RUBY_Root.'&Statements.if-&else<Tab>\\sie					<Esc>:call RUBY_InsertTemplate("statements.if-else", "v")<CR>'
	exe "vnoremenu ".s:RUBY_Root.'&Statements.&select<Tab>\\ss						<Esc>:call RUBY_InsertTemplate("statements.select", "v")<CR>'
	exe "vnoremenu ".s:RUBY_Root.'&Statements.un&til<Tab>\\su							<Esc>:call RUBY_InsertTemplate("statements.until", "v")<CR>'
	exe "vnoremenu ".s:RUBY_Root.'&Statements.&while<Tab>\\sw							<Esc>:call RUBY_InsertTemplate("statements.while", "v")<CR>'
	"
	exe "anoremenu ".s:RUBY_Root.'&Statements.-SEP3-          :'

	exe "anoremenu ".s:RUBY_Root.'&Statements.&break										obreak '
	exe "anoremenu ".s:RUBY_Root.'&Statements.co&ntinue									ocontinue '
	exe "anoremenu ".s:RUBY_Root.'&Statements.e&xit											oexit '
	exe "anoremenu ".s:RUBY_Root.'&Statements.f&unction<Tab>\\sfu 			:call RUBY_InsertTemplate("statements.function")<CR>'
	exe "anoremenu ".s:RUBY_Root.'&Statements.&return										oreturn '
	exe "anoremenu ".s:RUBY_Root.'&Statements.s&hift										oshift '
	exe "anoremenu ".s:RUBY_Root.'&Statements.&trap											otrap '
	"
	exe "inoremenu ".s:RUBY_Root.'&Statements.&break								<Esc>obreak '
	exe "inoremenu ".s:RUBY_Root.'&Statements.co&ntinue							<Esc>ocontinue '
	exe "inoremenu ".s:RUBY_Root.'&Statements.e&xit									<Esc>oexit '
	exe "inoremenu ".s:RUBY_Root.'&Statements.f&unction<Tab>\\sfu 			<Esc>:call RUBY_InsertTemplate("statements.function")<CR>'
	exe "vnoremenu ".s:RUBY_Root.'&Statements.f&unction<Tab>\\sfu 			<Esc>:call RUBY_InsertTemplate("statements.function", "v")<CR>'
	exe "inoremenu ".s:RUBY_Root.'&Statements.&return								<Esc>oreturn '
	exe "inoremenu ".s:RUBY_Root.'&Statements.s&hift								<Esc>oshift '
	exe "inoremenu ".s:RUBY_Root.'&Statements.&trap									<Esc>otrap '
	"
	"
	exe "anoremenu ".s:RUBY_Root.'&Statements.-SEP1-          :'

	exe "anoremenu ".s:RUBY_Root.'&Statements.&$(\.\.\.)			a$()<Left>'
	exe "inoremenu ".s:RUBY_Root.'&Statements.&$(\.\.\.)			 $()<Left>'
	exe "vnoremenu ".s:RUBY_Root.'&Statements.&$(\.\.\.)			s$()<Esc>P'

	exe "anoremenu ".s:RUBY_Root.'&Statements.$&{\.\.\.}			a${}<Left>'
	exe "inoremenu ".s:RUBY_Root.'&Statements.$&{\.\.\.}			 ${}<Left>'
	exe "vnoremenu ".s:RUBY_Root.'&Statements.$&{\.\.\.}			s${}<Esc>P'
	"
	exe " noremenu ".s:RUBY_Root.'&Statements.$&((\.\.\.))		a$(())<Esc>hi'
	exe "inoremenu ".s:RUBY_Root.'&Statements.$&((\.\.\.))		 $(())<Left><Left>'
	exe "vnoremenu ".s:RUBY_Root.'&Statements.$&((\.\.\.))		s$(())<Esc>hP'
	"
	exe "anoremenu ".s:RUBY_Root.'&Statements.&printf\ \ "%s"<Tab>\\sp		     :call RUBY_InsertTemplate("statements.printf")<CR>'
	exe "inoremenu ".s:RUBY_Root.'&Statements.&printf\ \ "%s"<Tab>\\sp		<Esc>:call RUBY_InsertTemplate("statements.printf")<CR>'
	exe "vnoremenu ".s:RUBY_Root.'&Statements.&printf\ \ "%s"<Tab>\\sp		<Esc>:call RUBY_InsertTemplate("statements.printf", "v")<CR>'
	"
	exe "anoremenu ".s:RUBY_Root.'&Statements.ech&o\ \ -e\ ""<Tab>\\se		     :call RUBY_InsertTemplate("statements.echo")<CR>'
	exe "inoremenu ".s:RUBY_Root.'&Statements.ech&o\ \ -e\ ""<Tab>\\se		<Esc>:call RUBY_InsertTemplate("statements.echo")<CR>'
	exe "vnoremenu ".s:RUBY_Root.'&Statements.ech&o\ \ -e\ ""<Tab>\\se 	<Esc>:call RUBY_InsertTemplate("statements.echo", "v")<CR>'
	"
	exe "amenu  ".s:RUBY_Root.'&Statements.-SEP5-                                 :'
	exe "anoremenu ".s:RUBY_Root.'&Statements.&array\ elem\.\ \ \ ${\.[\.]}<tab>\\sa\       a${[]}<Left><Left><Left>'
	exe "inoremenu ".s:RUBY_Root.'&Statements.&array\ elem\.\ \ \ ${\.[\.]}<tab>\\sa\        ${[]}<Left><Left><Left>'
	exe "vnoremenu ".s:RUBY_Root.'&Statements.&array\ elem\.\ \ \ ${\.[\.]}<tab>\\sa\       s${[]}<Left><Left><Esc>P'
                                                                                   
	exe "anoremenu ".s:RUBY_Root.'&Statements.&arr\.\ elem\.s\ (all)\ \ \ ${\.[@]}<tab>\\saa     	a${[@]}<Left><Left><Left><Left>'
	exe "inoremenu ".s:RUBY_Root.'&Statements.&arr\.\ elem\.s\ (all)\ \ \ ${\.[@]}<tab>\\saa     	 ${[@]}<Left><Left><Left><Left>'
	exe "vnoremenu ".s:RUBY_Root.'&Statements.&arr\.\ elem\.s\ (all)\ \ \ ${\.[@]}<tab>\\saa     	s${[@]}<Left><Left><Left><Esc>P'
                                                                                   
	exe "anoremenu ".s:RUBY_Root.'&Statements.arr\.\ elem\.s\ (&1\ word)\ \ \ ${\.[*]}<tab>\\sa1 		a${[*]}<Left><Left><Left><Left>'
	exe "inoremenu ".s:RUBY_Root.'&Statements.arr\.\ elem\.s\ (&1\ word)\ \ \ ${\.[*]}<tab>\\sa1 		 ${[*]}<Left><Left><Left><Left>'
	exe "vnoremenu ".s:RUBY_Root.'&Statements.arr\.\ elem\.s\ (&1\ word)\ \ \ ${\.[*]}<tab>\\sa1 		s${[*]}<Left><Left><Left><Esc>P'
                                                                                   
	exe "anoremenu ".s:RUBY_Root.'&Statements.&subarray\ \ \ ${\.[@]::}<tab>\\ssa     	a${[@]::}<Left><Left><Left><Left><Left><Left>'
	exe "inoremenu ".s:RUBY_Root.'&Statements.&subarray\ \ \ ${\.[@]::}<tab>\\ssa     	 ${[@]::}<Left><Left><Left><Left><Left><Left>'
	exe "vnoremenu ".s:RUBY_Root.'&Statements.&subarray\ \ \ ${\.[@]::}<tab>\\ssa     	s${[@]::}<Left><Left><Left><Left><Left><Esc>P'
                                                                                   
	exe "anoremenu ".s:RUBY_Root.'&Statements.no\.\ of\ ele&m\.s\ \ \ ${#\.[@]}<tab>\\san		a${#[@]}<Left><Left><Left><Left>'
	exe "inoremenu ".s:RUBY_Root.'&Statements.no\.\ of\ ele&m\.s\ \ \ ${#\.[@]}<tab>\\san		 ${#[@]}<Left><Left><Left><Left>'
	exe "vnoremenu ".s:RUBY_Root.'&Statements.no\.\ of\ ele&m\.s\ \ \ ${#\.[@]}<tab>\\san		s${#[@]}<Left><Left><Left><Esc>P'
                                                                                   
	exe "anoremenu ".s:RUBY_Root.'&Statements.list\ of\ in&dices\ \ \ ${!\.[*]}<tab>\\sai   a${![*]}<Left><Left><Left><Left>'
	exe "inoremenu ".s:RUBY_Root.'&Statements.list\ of\ in&dices\ \ \ ${!\.[*]}<tab>\\sai    ${![*]}<Left><Left><Left><Left>'
	exe "vnoremenu ".s:RUBY_Root.'&Statements.list\ of\ in&dices\ \ \ ${!\.[*]}<tab>\\sai   s${![*]}<Left><Left><Left><Esc>P'
	"
	if s:RUBY_CodeSnippets != ""
		exe " menu  <silent> ".s:RUBY_Root.'S&nippets.read\ code\ snippet<Tab>\\nr        :call RUBY_CodeSnippets("r")<CR>'
		exe "imenu  <silent> ".s:RUBY_Root.'S&nippets.read\ code\ snippet<Tab>\\nr   <C-C>:call RUBY_CodeSnippets("r")<CR>'
		exe " menu  <silent> ".s:RUBY_Root.'S&nippets.write\ code\ snippet<Tab>\\nw       :call RUBY_CodeSnippets("w")<CR>'
		exe "imenu  <silent> ".s:RUBY_Root.'S&nippets.write\ code\ snippet<Tab>\\nw  <C-C>:call RUBY_CodeSnippets("w")<CR>'
		exe "vmenu  <silent> ".s:RUBY_Root.'S&nippets.write\ code\ snippet<Tab>\\nw  <C-C>:call RUBY_CodeSnippets("wv")<CR>'
		exe " menu  <silent> ".s:RUBY_Root.'S&nippets.edit\ code\ snippet<Tab>\\ne        :call RUBY_CodeSnippets("e")<CR>'
		exe "imenu  <silent> ".s:RUBY_Root.'S&nippets.edit\ code\ snippet<Tab>\\ne   <C-C>:call RUBY_CodeSnippets("e")<CR>'
		exe "amenu  <silent> ".s:RUBY_Root.'S&nippets.-SEP6-                    		  :'
	endif
  "
  exe "amenu  <silent>  ".s:RUBY_Root.'S&nippets.edit\ &local\ templates<Tab>\\ntl          :call RUBY_BrowseTemplateFiles("Local")<CR>'
  exe "imenu  <silent>  ".s:RUBY_Root.'S&nippets.edit\ &local\ templates<Tab>\\ntl     <C-C>:call RUBY_BrowseTemplateFiles("Local")<CR>'
	if s:installation == 'system'
		exe "amenu  <silent>  ".s:RUBY_Root.'S&nippets.edit\ &global\ templates<Tab>\\ntg         :call RUBY_BrowseTemplateFiles("Global")<CR>'
		exe "imenu  <silent>  ".s:RUBY_Root.'S&nippets.edit\ &global\ templates<Tab>\\ntg    <C-C>:call RUBY_BrowseTemplateFiles("Global")<CR>'
	endif
  exe "amenu  <silent>  ".s:RUBY_Root.'S&nippets.reread\ &templates<Tab>\\ntr               :call RUBY_RereadTemplates("yes")<CR>'
  exe "imenu  <silent>  ".s:RUBY_Root.'S&nippets.reread\ &templates <Tab>\\ntr         <C-C>:call RUBY_RereadTemplates("yes")<CR>'
  exe "amenu            ".s:RUBY_Root.'S&nippets.switch\ template\ st&yle<Tab>\\nts         :RubyStyle<Space>'
  exe "imenu            ".s:RUBY_Root.'S&nippets.switch\ template\ st&yle<Tab>\\nts    <C-C>:RubyStyle<Space>'
	"
	"-------------------------------------------------------------------------------
	"----- menu Tests   {{{2
	"-------------------------------------------------------------------------------
	exe "	noremenu ".s:RUBY_Root.'&Tests.file\ &exists<Tab>-e															    					a[ -e  ]<Left><Left>'
	exe "	noremenu ".s:RUBY_Root.'&Tests.file\ exists\ and\ has\ a\ &size\ greater\ than\ zero<Tab>-s		a[ -s  ]<Left><Left>'
	"
	exe "inoremenu ".s:RUBY_Root.'&Tests.file\ &exists<Tab>-e																						[ -e  ]<Left><Left>'
	exe "inoremenu ".s:RUBY_Root.'&Tests.file\ exists\ and\ has\ a\ &size\ greater\ than\ zero<Tab>-s		[ -s  ]<Left><Left>'
	"
	exe "imenu ".s:RUBY_Root.'&Tests.-Sep1-                         :'
	"
	"---------- submenu arithmetic tests -----------------------------------------------------------
	"
	exe "	noremenu ".s:RUBY_Root.'&Tests.&arithmetic\ tests.arg1\ is\ &equal\ to\ arg2<Tab>-eq									 a[  -eq  ]<Esc>F-hi'
	exe "	noremenu ".s:RUBY_Root.'&Tests.&arithmetic\ tests.arg1\ &not\ equal\ to\ arg2<Tab>-ne									 a[  -ne  ]<Esc>F-hi'
	exe "	noremenu ".s:RUBY_Root.'&Tests.&arithmetic\ tests.arg1\ &less\ than\ arg2<Tab>-lt											 a[  -lt  ]<Esc>F-hi'
	exe "	noremenu ".s:RUBY_Root.'&Tests.&arithmetic\ tests.arg1\ le&ss\ than\ or\ equal\ to\ arg2<Tab>-le			 a[  -le  ]<Esc>F-hi'
	exe "	noremenu ".s:RUBY_Root.'&Tests.&arithmetic\ tests.arg1\ &greater\ than\ arg2<Tab>-gt									 a[  -gt  ]<Esc>F-hi'
	exe "	noremenu ".s:RUBY_Root.'&Tests.&arithmetic\ tests.arg1\ g&reater\ than\ or\ equal\ to\ arg2<Tab>-ge		 a[  -ge  ]<Esc>F-hi'
	"
	exe "inoremenu ".s:RUBY_Root.'&Tests.&arithmetic\ tests.arg1\ is\ &equal\ to\ arg2<Tab>-eq										[  -eq  ]<Esc>F-hi'
	exe "inoremenu ".s:RUBY_Root.'&Tests.&arithmetic\ tests.arg1\ &not\ equal\ to\ arg2<Tab>-ne										[  -ne  ]<Esc>F-hi'
	exe "inoremenu ".s:RUBY_Root.'&Tests.&arithmetic\ tests.arg1\ &less\ than\ arg2<Tab>-lt												[  -lt  ]<Esc>F-hi'
	exe "inoremenu ".s:RUBY_Root.'&Tests.&arithmetic\ tests.arg1\ le&ss\ than\ or\ equal\ to\ arg2<Tab>-le				[  -le  ]<Esc>F-hi'
	exe "inoremenu ".s:RUBY_Root.'&Tests.&arithmetic\ tests.arg1\ &greater\ than\ arg2<Tab>-gt										[  -gt  ]<Esc>F-hi'
	exe "inoremenu ".s:RUBY_Root.'&Tests.&arithmetic\ tests.arg1\ g&reater\ than\ or\ equal\ to\ arg2<Tab>-ge			[  -ge  ]<Esc>F-hi'
	"
	"---------- submenu file exists and has permission ---------------------------------------------
	"
	exe "	noremenu ".s:RUBY_Root.'&Tests.file\ exists\ and\ has\ &permission.file\ exists\ and											<Esc>'
	exe "	noremenu ".s:RUBY_Root.'&Tests.file\ exists\ and\ has\ &permission.\ is\ &readable<Tab>-r								 a[ -r  ]<Left><Left>'
	exe "	noremenu ".s:RUBY_Root.'&Tests.file\ exists\ and\ has\ &permission.\ is\ &writable<Tab>-w								 a[ -w  ]<Left><Left>'
	exe "	noremenu ".s:RUBY_Root.'&Tests.file\ exists\ and\ has\ &permission.\ is\ e&xecutable<Tab>-x							 a[ -x  ]<Left><Left>'
	exe "	noremenu ".s:RUBY_Root.'&Tests.file\ exists\ and\ has\ &permission.\ its\ S&UID-bit\ is\ set<Tab>-u			 a[ -u  ]<Left><Left>'
	exe "	noremenu ".s:RUBY_Root.'&Tests.file\ exists\ and\ has\ &permission.\ its\ S&GID-bit\ is\ set<Tab>-g			 a[ -g  ]<Left><Left>'
	exe "	noremenu ".s:RUBY_Root.'&Tests.file\ exists\ and\ has\ &permission.\ its\ "stic&ky"\ bit\ is\ set<Tab>-k a[ -k  ]<Left><Left>'
	"
	exe "inoremenu ".s:RUBY_Root.'&Tests.file\ exists\ and\ has\ &permission.file\ exists\ and											<Esc>'
	exe "inoremenu ".s:RUBY_Root.'&Tests.file\ exists\ and\ has\ &permission.\ is\ &readable<Tab>-r									[ -r  ]<Left><Left>'
	exe "inoremenu ".s:RUBY_Root.'&Tests.file\ exists\ and\ has\ &permission.\ is\ &writable<Tab>-w									[ -w  ]<Left><Left>'
	exe "inoremenu ".s:RUBY_Root.'&Tests.file\ exists\ and\ has\ &permission.\ is\ e&xecutable<Tab>-x								[ -x  ]<Left><Left>'
	exe "inoremenu ".s:RUBY_Root.'&Tests.file\ exists\ and\ has\ &permission.\ its\ S&UID-bit\ is\ set<Tab>-u				[ -u  ]<Left><Left>'
	exe "inoremenu ".s:RUBY_Root.'&Tests.file\ exists\ and\ has\ &permission.\ its\ S&GID-bit\ is\ set<Tab>-g				[ -g  ]<Left><Left>'
	exe "inoremenu ".s:RUBY_Root.'&Tests.file\ exists\ and\ has\ &permission.\ its\ "stic&ky"\ bit\ is\ set<Tab>-k	[ -k  ]<Left><Left>'
	"
	"---------- submenu file exists and has type ----------------------------------------------------
	"
	exe "	noremenu ".s:RUBY_Root.'&Tests.file\ exists\ and\ has\ t&ype.file\ exists\ and\ is\ a						<Esc>'
	exe "	noremenu ".s:RUBY_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ &block\ special\ file<Tab>-b			a[ -b  ]<Left><Left>'
	exe "	noremenu ".s:RUBY_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ &character\ special\ file<Tab>-c	a[ -c  ]<Left><Left>'
	exe "	noremenu ".s:RUBY_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ &directory<Tab>-d								a[ -d  ]<Left><Left>'
	exe "	noremenu ".s:RUBY_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ named\ &pipe\ (FIFO)<Tab>-p			a[ -p  ]<Left><Left>'
	exe "	noremenu ".s:RUBY_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ regular\ &file<Tab>-f						a[ -f  ]<Left><Left>'
	exe "	noremenu ".s:RUBY_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ &socket<Tab>-S										a[ -S  ]<Left><Left>'
	exe "	noremenu ".s:RUBY_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ symbolic\ &link<Tab>-L						a[ -L  ]<Left><Left>'
	"
	exe "inoremenu ".s:RUBY_Root.'&Tests.file\ exists\ and\ has\ t&ype.file\ exists\ and\ is\ a			<Esc>'
	exe "inoremenu ".s:RUBY_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ &block\ special\ file<Tab>-b			 [ -b  ]<Left><Left>'
	exe "inoremenu ".s:RUBY_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ &character\ special\ file<Tab>-c	 [ -c  ]<Left><Left>'
	exe "inoremenu ".s:RUBY_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ &directory<Tab>-d								 [ -d  ]<Left><Left>'
	exe "inoremenu ".s:RUBY_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ named\ &pipe\ (FIFO)<Tab>p-			 [ -p  ]<Left><Left>'
	exe "inoremenu ".s:RUBY_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ regular\ &file<Tab>-f						 [ -f  ]<Left><Left>'
	exe "inoremenu ".s:RUBY_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ &socket<Tab>-S										 [ -S  ]<Left><Left>'
	exe "inoremenu ".s:RUBY_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ symbolic\ &link<Tab>-L						 [ -L  ]<Left><Left>'
	"
	"---------- submenu string comparison ------------------------------------------------------------
	"
	exe "	noremenu ".s:RUBY_Root.'&Tests.string\ &comparison.length\ of\ string\ is\ &zero<Tab>-z									  a[ -z  ]<Left><Left>'
	exe "	noremenu ".s:RUBY_Root.'&Tests.string\ &comparison.length\ of\ string\ is\ &non-zero<Tab>-n								a[ -n  ]<Left><Left>'
	exe "	noremenu ".s:RUBY_Root.'&Tests.string\ &comparison.strings\ are\ &equal\ (1)<Tab>=															a[  =  ]<Esc>bhi'
	exe "	noremenu ".s:RUBY_Root.'&Tests.string\ &comparison.strings\ are\ e&qual\ (2)<Tab>==														a[  ==  ]<Esc>bhi'
	exe "	noremenu ".s:RUBY_Root.'&Tests.string\ &comparison.strings\ are\ n&ot\ equal<Tab>!=												a[  !=  ]<Esc>bhi'
	exe "	noremenu ".s:RUBY_Root.'&Tests.string\ &comparison.string1\ sorts\ &before\ string2\ lexicograph\.<Tab><	a[  <  ]<Esc>bhi'
	exe "	noremenu ".s:RUBY_Root.'&Tests.string\ &comparison.string1\ sorts\ &after\ string2\ lexicograph\.<Tab>>		a[  >  ]<Esc>bhi'
	exe "	noremenu ".s:RUBY_Root.'&Tests.string\ &comparison.string\ matches\ &regexp<Tab>=~												a[[  =~  ]]<Esc>2bhi'
	"
	exe "inoremenu ".s:RUBY_Root.'&Tests.string\ &comparison.length\ of\ string\ is\ &zero<Tab>-z										 [ -z  ]<Left><Left>'
	exe "inoremenu ".s:RUBY_Root.'&Tests.string\ &comparison.length\ of\ string\ is\ &non-zero<Tab>-n								 [ -n  ]<Left><Left>'
	exe "inoremenu ".s:RUBY_Root.'&Tests.string\ &comparison.strings\ are\ &equal\ (1)<Tab>=															 [  =  ]<Esc>bhi'
	exe "inoremenu ".s:RUBY_Root.'&Tests.string\ &comparison.strings\ are\ e&qual\ (2)<Tab>==														 [  ==  ]<Esc>bhi'
	exe "inoremenu ".s:RUBY_Root.'&Tests.string\ &comparison.strings\ are\ n&ot\ equal<Tab>!=												 [  !=  ]<Esc>bhi'
	exe "inoremenu ".s:RUBY_Root.'&Tests.string\ &comparison.string1\ sorts\ &before\ string2\ lexicograph\.<Tab><	 [  <  ]<Esc>bhi'
	exe "inoremenu ".s:RUBY_Root.'&Tests.string\ &comparison.string1\ sorts\ &after\ string2\ lexicograph\.<Tab>>		 [  >  ]<Esc>bhi'
	exe "inoremenu ".s:RUBY_Root.'&Tests.string\ &comparison.string\ matches\ &regexp<Tab>=~												 [[  =~  ]]<Esc>2bhi'
	"
	exe "	noremenu ".s:RUBY_Root.'&Tests.file\ exists\ and\ is\ &owned\ by\ the\ effective\ UID<Tab>-O							 a[ -O  ]<Left><Left>'
	exe "	noremenu ".s:RUBY_Root.'&Tests.file\ exists\ and\ is\ owned\ by\ the\ effective\ &GID<Tab>-G							 a[ -G  ]<Left><Left>'
	exe "	noremenu ".s:RUBY_Root.'&Tests.file\ exists\ a&nd\ has\ been\ modified\ since\ it\ was\ last\ read<Tab>-N	 a[ -N  ]<Left><Left>'
	exe "	noremenu ".s:RUBY_Root.'&Tests.file\ descriptor\ fd\ is\ open\ and\ refers\ to\ a\ &terminal<Tab>-t				 a[ -t  ]<Left><Left>'
	exe "	noremenu ".s:RUBY_Root.'&Tests.-Sep3-                         :'
	exe "	noremenu ".s:RUBY_Root.'&Tests.file&1\ is\ newer\ than\ file2\ (modification\ date)<Tab>-nt								 a[  -nt  ]<Esc>F-hi'
	exe "	noremenu ".s:RUBY_Root.'&Tests.file1\ is\ older\ than\ file&2<Tab>-ot																			 a[  -ot  ]<Esc>F-hi'
	exe "	noremenu ".s:RUBY_Root.'&Tests.file1\ and\ file2\ have\ the\ same\ device\ and\ &inode\ numbers<Tab>-ef		 a[  -ef  ]<Esc>F-hi'
	exe "	noremenu ".s:RUBY_Root.'&Tests.-Sep4-                         :'
	exe "	noremenu ".s:RUBY_Root.'&Tests.&shell\ option\ optname\ is\ enabled<Tab>-o																 a[ -o  ]<Left><Left>'
	"
	exe "inoremenu ".s:RUBY_Root.'&Tests.file\ exists\ and\ is\ &owned\ by\ the\ effective\ UID<Tab>-O                [ -O  ]<Left><Left>'
	exe "inoremenu ".s:RUBY_Root.'&Tests.file\ exists\ and\ is\ owned\ by\ the\ effective\ &GID<Tab>-G								[ -G  ]<Left><Left>'
	exe "inoremenu ".s:RUBY_Root.'&Tests.file\ exists\ a&nd\ has\ been\ modified\ since\ it\ was\ last\ read<Tab>-N		[ -N  ]<Left><Left>'
	exe "inoremenu ".s:RUBY_Root.'&Tests.file\ descriptor\ fd\ is\ open\ and\ refers\ to\ a\ &terminal<Tab>-t					[ -t  ]<Left><Left>'
	exe "inoremenu ".s:RUBY_Root.'&Tests.-Sep3-                         :'
	exe "inoremenu ".s:RUBY_Root.'&Tests.file&1\ is\ newer\ than\ file2\ (modification\ date)<Tab>-nt									[  -nt  ]<Esc>F-hi'
	exe "inoremenu ".s:RUBY_Root.'&Tests.file1\ is\ older\ than\ file&2<Tab>-ot																				[  -ot  ]<Esc>F-hi'
	exe "inoremenu ".s:RUBY_Root.'&Tests.file1\ and\ file2\ have\ the\ same\ device\ and\ &inode\ numbers<Tab>-ef			[  -ef  ]<Esc>F-hi'
	exe "inoremenu ".s:RUBY_Root.'&Tests.-Sep4-                         :'
	exe "inoremenu ".s:RUBY_Root.'&Tests.&shell\ option\ optname\ is\ enabled<Tab>-o																	[ -o  ]<Left><Left>'
	"
	"-------------------------------------------------------------------------------
	"----- menu Parameter Substitution   {{{2
	"-------------------------------------------------------------------------------

	exe " noremenu <silent> ".s:RUBY_Root.'&ParamSub.&substitution\ <tab>${\ }                               :call RUBY_InsertTemplate("paramsub.substitution")<CR>'
	exe " noremenu <silent> ".s:RUBY_Root.'&ParamSub.use\ &default\ value<tab>${\ :-\ }                      :call RUBY_InsertTemplate("paramsub.use-default-value")<CR>'
	exe " noremenu <silent> ".s:RUBY_Root.'&ParamSub.&assign\ default\ value<tab>${\ :=\ }                   :call RUBY_InsertTemplate("paramsub.assign-default-value")<CR>'
	exe " noremenu <silent> ".s:RUBY_Root.'&ParamSub.display\ &error\ if\ null\ or\ unset<tab>${\ :?\ }      :call RUBY_InsertTemplate("paramsub.display-error")<CR>'
	exe " noremenu <silent> ".s:RUBY_Root.'&ParamSub.use\ alternate\ &value<tab>${\ :+\ }                    :call RUBY_InsertTemplate("paramsub.use-alternate-value")<CR>'
	exe " noremenu <silent> ".s:RUBY_Root.'&ParamSub.&substring\ expansion<tab>${\ :\ :\ }                   :call RUBY_InsertTemplate("paramsub.substring-expansion")<CR>'
	exe " noremenu <silent> ".s:RUBY_Root.'&ParamSub.list\ of\ var\.s\ &beginning\ with\ prefix<tab>${!\ *}  :call RUBY_InsertTemplate("paramsub.names-matching-prefix")<CR>'
	exe " noremenu <silent> ".s:RUBY_Root.'&ParamSub.&indirect\ parameter\ expansion<tab>${!\ }               :call RUBY_InsertTemplate("paramsub.indirect-parameter-expansion")<CR>'
	exe " noremenu <silent> ".s:RUBY_Root.'&ParamSub.-Sep1-           :'
	exe " noremenu <silent> ".s:RUBY_Root.'&ParamSub.parameter\ &length\ in\ characters<Tab>${#\ }           :call RUBY_InsertTemplate("paramsub.parameter-length")<CR>'
	exe " noremenu <silent> ".s:RUBY_Root.'&ParamSub.match\ beginning;\ del\.\ &shortest\ part<Tab>${\ #\ }  :call RUBY_InsertTemplate("paramsub.remove-matching-prefix-pattern")<CR>'
	exe " noremenu <silent> ".s:RUBY_Root.'&ParamSub.match\ beginning;\ del\.\ &longest\ part<Tab>${\ ##\ }  :call RUBY_InsertTemplate("paramsub.remove-all-matching-suffix-pattern")<CR>'
	exe " noremenu <silent> ".s:RUBY_Root.'&ParamSub.match\ end;\ delete\ s&hortest\ part<Tab>${\ %\ }       :call RUBY_InsertTemplate("paramsub.remove-matching-suffix-pattern")<CR>'
	exe " noremenu <silent> ".s:RUBY_Root.'&ParamSub.match\ end;\ delete\ l&ongest\ part<Tab>${\ %%\ }       :call RUBY_InsertTemplate("paramsub.remove-all-matching-suffix-pattern")<CR>'
	exe " noremenu <silent> ".s:RUBY_Root.'&ParamSub.substitute,\ match\ &first<Tab>${\ /\ /\ }                 :call RUBY_InsertTemplate("paramsub.pattern-substitution")<CR>'
	exe " noremenu <silent> ".s:RUBY_Root.'&ParamSub.substitute,\ match\ &all<Tab>${\ //\ /\ }                  :call RUBY_InsertTemplate("paramsub.pattern-substitution-all")<CR>'
	exe " noremenu <silent> ".s:RUBY_Root.'&ParamSub.substitute,\ match\ &begin<Tab>${\ /#\ /\ }                :call RUBY_InsertTemplate("paramsub.pattern-substitution-begin")<CR>'
	exe " noremenu <silent> ".s:RUBY_Root.'&ParamSub.substitute,\ match\ &end<Tab>${\ /%\ /\ }                  :call RUBY_InsertTemplate("paramsub.pattern-substitution-end")<CR>'
	exe " noremenu <silent> ".s:RUBY_Root.'&ParamSub.&lowercase\ to\ uppercase<Tab>${\ ^\ }                   :call RUBY_InsertTemplate("paramsub.first-lower-to-upper")<CR>'
	exe " noremenu <silent> ".s:RUBY_Root.'&ParamSub.each\ l&owercase\ to\ uppercase<Tab>${\ ^^\ }            :call RUBY_InsertTemplate("paramsub.all-lower-to-upper")<CR>'
	exe " noremenu <silent> ".s:RUBY_Root.'&ParamSub.&uppercase\ to\ lowercase<Tab>${\ ,\ }                   :call RUBY_InsertTemplate("paramsub.first-upper-to-lower")<CR>'
	exe " noremenu <silent> ".s:RUBY_Root.'&ParamSub.each\ u&ppercase\ to\ lowercase<Tab>${\ ,,\ }            :call RUBY_InsertTemplate("paramsub.all-upper-to-lower")<CR>'

	exe "vnoremenu <silent> ".s:RUBY_Root.'&ParamSub.s&ubstitution\ <tab>${\ }                               <C-C>:call RUBY_InsertTemplate("paramsub.substitution", "v")<CR>'
	"
	exe "inoremenu <silent> ".s:RUBY_Root.'&ParamSub.&substitution\ <tab>${\ }                               <C-C>:call RUBY_InsertTemplate("paramsub.substitution")<CR>'
	exe "inoremenu <silent> ".s:RUBY_Root.'&ParamSub.use\ &default\ value<tab>${\ :-\ }                      <C-C>:call RUBY_InsertTemplate("paramsub.use-default-value")<CR>'
	exe "inoremenu <silent> ".s:RUBY_Root.'&ParamSub.&assign\ default\ value<tab>${\ :=\ }                   <C-C>:call RUBY_InsertTemplate("paramsub.assign-default-value")<CR>'
	exe "inoremenu <silent> ".s:RUBY_Root.'&ParamSub.display\ &error\ if\ null\ or\ unset<tab>${\ :?\ }      <C-C>:call RUBY_InsertTemplate("paramsub.display-error")<CR>'
	exe "inoremenu <silent> ".s:RUBY_Root.'&ParamSub.use\ alternate\ &value<tab>${\ :+\ }                    <C-C>:call RUBY_InsertTemplate("paramsub.use-alternate-value")<CR>'
	exe "inoremenu <silent> ".s:RUBY_Root.'&ParamSub.&substring\ expansion<tab>${\ :\ :\ }                   <C-C>:call RUBY_InsertTemplate("paramsub.substring-expansion")<CR>'
	exe "inoremenu <silent> ".s:RUBY_Root.'&ParamSub.list\ of\ var\.s\ &beginning\ with\ prefix<tab>${!\ *}  <C-C>:call RUBY_InsertTemplate("paramsub.names-matching-prefix")<CR>'
	exe "inoremenu <silent> ".s:RUBY_Root.'&ParamSub.&indirect\ parameter\ expansion<tab>${!\ }               <C-C>:call RUBY_InsertTemplate("paramsub.indirect-parameter-expansion")<CR>'
	exe "inoremenu <silent> ".s:RUBY_Root.'&ParamSub.-Sep1-           :'
	exe "inoremenu <silent> ".s:RUBY_Root.'&ParamSub.parameter\ &length\ in\ characters<Tab>${#\ }           <C-C>:call RUBY_InsertTemplate("paramsub.parameter-length")<CR>'
	exe "inoremenu <silent> ".s:RUBY_Root.'&ParamSub.match\ beginning;\ del\.\ &shortest\ part<Tab>${\ #\ }  <C-C>:call RUBY_InsertTemplate("paramsub.remove-matching-prefix-pattern")<CR>'
	exe "inoremenu <silent> ".s:RUBY_Root.'&ParamSub.match\ beginning;\ del\.\ &longest\ part<Tab>${\ ##\ }  <C-C>:call RUBY_InsertTemplate("paramsub.remove-all-matching-suffix-pattern")<CR>'
	exe "inoremenu <silent> ".s:RUBY_Root.'&ParamSub.match\ end;\ delete\ s&hortest\ part<Tab>${\ %\ }       <C-C>:call RUBY_InsertTemplate("paramsub.remove-matching-suffix-pattern")<CR>'
	exe "inoremenu <silent> ".s:RUBY_Root.'&ParamSub.match\ end;\ delete\ l&ongest\ part<Tab>${\ %%\ }       <C-C>:call RUBY_InsertTemplate("paramsub.remove-all-matching-suffix-pattern")<CR>'
	exe "inoremenu <silent> ".s:RUBY_Root.'&ParamSub.substitute,\ match\ &first<Tab>${\ /\ /\ }                 <C-C>:call RUBY_InsertTemplate("paramsub.pattern-substitution")<CR>'
	exe "inoremenu <silent> ".s:RUBY_Root.'&ParamSub.substitute,\ match\ &all<Tab>${\ //\ /\ }                  <C-C>:call RUBY_InsertTemplate("paramsub.pattern-substitution-all")<CR>'
	exe "inoremenu <silent> ".s:RUBY_Root.'&ParamSub.substitute,\ match\ &begin<Tab>${\ /#\ /\ }                <C-C>:call RUBY_InsertTemplate("paramsub.pattern-substitution-begin")<CR>'
	exe "inoremenu <silent> ".s:RUBY_Root.'&ParamSub.substitute,\ match\ &end<Tab>${\ /%\ /\ }                  <C-C>:call RUBY_InsertTemplate("paramsub.pattern-substitution-end")<CR>'
	exe "inoremenu <silent> ".s:RUBY_Root.'&ParamSub.&lowercase\ to\ uppercase<Tab>${\ ^\ }                   <C-C>:call RUBY_InsertTemplate("paramsub.first-lower-to-upper")<CR>'
	exe "inoremenu <silent> ".s:RUBY_Root.'&ParamSub.each\ l&owercase\ to\ uppercase<Tab>${\ ^^\ }            <C-C>:call RUBY_InsertTemplate("paramsub.all-lower-to-upper")<CR>'
	exe "inoremenu <silent> ".s:RUBY_Root.'&ParamSub.&uppercase\ to\ lowercase<Tab>${\ ,\ }                   <C-C>:call RUBY_InsertTemplate("paramsub.first-upper-to-lower")<CR>'
	exe "inoremenu <silent> ".s:RUBY_Root.'&ParamSub.each\ u&ppercase\ to\ lowercase<Tab>${\ ,,\ }            <C-C>:call RUBY_InsertTemplate("paramsub.all-upper-to-lower")<CR>'
	"-------------------------------------------------------------------------------
	"----- menu Special Variables   {{{2
	"-------------------------------------------------------------------------------

	exe "	noremenu ".s:RUBY_Root.'Spec&Vars.&number\ of\ posit\.\ param\.<tab>${#}							 a${#}'
	exe "	noremenu ".s:RUBY_Root.'Spec&Vars.&all\ posit\.\ param\.\ (quoted\ spaces)<tab>${*}		 a${*}'
	exe "	noremenu ".s:RUBY_Root.'Spec&Vars.all\ posit\.\ param\.\ (&unquoted\ spaces)<tab>${@}	 a${@}'
	exe "	noremenu ".s:RUBY_Root.'Spec&Vars.n&umber\ of\ posit\.\ parameters<tab>${#@}	         a${#@}'
	exe "	noremenu ".s:RUBY_Root.'Spec&Vars.&return\ code\ of\ last\ command<tab>${?}						 a${?}'
	exe "	noremenu ".s:RUBY_Root.'Spec&Vars.&PID\ of\ this\ shell<tab>${$}											 a${$}'
	exe "	noremenu ".s:RUBY_Root.'Spec&Vars.&flags\ set<tab>${-}																 a${-}'
	exe "	noremenu ".s:RUBY_Root.'Spec&Vars.&last\ argument\ of\ prev\.\ command<tab>${_}				 a${_}'
	exe "	noremenu ".s:RUBY_Root.'Spec&Vars.PID\ of\ last\ &background\ command<tab>${!}				 a${!}'
	"
	exe "inoremenu ".s:RUBY_Root.'Spec&Vars.&number\ of\ posit\.\ param\.<tab>${#}								${#}'
	exe "inoremenu ".s:RUBY_Root.'Spec&Vars.&all\ posit\.\ param\.\ (quoted\ spaces)<tab>${*}			${*}'
	exe "inoremenu ".s:RUBY_Root.'Spec&Vars.all\ posit\.\ param\.\ (&unquoted\ spaces)<tab>${@}		${@}'
	exe "inoremenu ".s:RUBY_Root.'Spec&Vars.n&umber\ of\ posit\.\ parameters<tab>${#@}	        	${#@}'
	exe "inoremenu ".s:RUBY_Root.'Spec&Vars.&return\ code\ of\ last\ command<tab>${?}							${?}'
	exe "inoremenu ".s:RUBY_Root.'Spec&Vars.&PID\ of\ this\ shell<tab>${$}												${$}'
	exe "inoremenu ".s:RUBY_Root.'Spec&Vars.&flags\ set<tab>${-}																	${-}'
	exe "inoremenu ".s:RUBY_Root.'Spec&Vars.&last\ argument\ of\ prev\.\ command<tab>${_}					${_}'
	exe "inoremenu ".s:RUBY_Root.'Spec&Vars.PID\ of\ last\ &background\ command<tab>${!}					${!}'
	"
	"-------------------------------------------------------------------------------
	"----- menu Environment Variables   {{{2
	"-------------------------------------------------------------------------------
	"
	call RUBY_EnvirMenus ( s:RUBY_Root.'E&nviron.&BASH\ \.\.\.\ RUBY_VERSION', s:RubyEnvironmentVariables[0:16] )
	"
	call RUBY_EnvirMenus ( s:RUBY_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME', s:RubyEnvironmentVariables[17:32] )
	"
	call RUBY_EnvirMenus ( s:RUBY_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG', s:RubyEnvironmentVariables[33:49] )
	"
	call RUBY_EnvirMenus ( s:RUBY_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE', s:RubyEnvironmentVariables[50:65] )
	"
	call RUBY_EnvirMenus ( s:RUBY_Root.'E&nviron.&PATH\ \.\.\.\ UID', s:RubyEnvironmentVariables[66:86] )
	"
	"-------------------------------------------------------------------------------
	"----- menu Builtins  a-l   {{{2
	"-------------------------------------------------------------------------------
	call	RUBY_BuiltinMenus ( s:RUBY_Root.'&Builtins.Builtins\ \ &a-f', s:RubyBuiltins[0:21] )
	call	RUBY_BuiltinMenus ( s:RUBY_Root.'&Builtins.Builtins\ \ &g-r', s:RubyBuiltins[22:41] )
	call	RUBY_BuiltinMenus ( s:RUBY_Root.'&Builtins.Builtins\ \ &s-w', s:RubyBuiltins[42:57] )
	"
	"
	"-------------------------------------------------------------------------------
	"----- menu set   {{{2
	"-------------------------------------------------------------------------------
	"
	exe "amenu ".s:RUBY_Root.'s&et.&allexport<Tab>-a       oset -o allexport  '
	exe "amenu ".s:RUBY_Root.'s&et.&braceexpand<Tab>-B     oset -o braceexpand'
	exe "amenu ".s:RUBY_Root.'s&et.emac&s                  oset -o emacs      '
	exe "amenu ".s:RUBY_Root.'s&et.&errexit<Tab>-e         oset -o errexit    '
	exe "amenu ".s:RUBY_Root.'s&et.e&rrtrace<Tab>-E        oset -o errtrace   '
	exe "amenu ".s:RUBY_Root.'s&et.func&trace<Tab>-T       oset -o functrace  '
	exe "amenu ".s:RUBY_Root.'s&et.&hashall<Tab>-h         oset -o hashall    '
	exe "amenu ".s:RUBY_Root.'s&et.histexpand\ (&1)<Tab>-H oset -o histexpand '
	exe "amenu ".s:RUBY_Root.'s&et.hist&ory                oset -o history    '
	exe "amenu ".s:RUBY_Root.'s&et.i&gnoreeof              oset -o ignoreeof  '
	exe "amenu ".s:RUBY_Root.'s&et.&keyword<Tab>-k         oset -o keyword    '
	exe "amenu ".s:RUBY_Root.'s&et.&monitor<Tab>-m         oset -o monitor    '
	exe "amenu ".s:RUBY_Root.'s&et.no&clobber<Tab>-C       oset -o noclobber  '
	exe "amenu ".s:RUBY_Root.'s&et.&noexec<Tab>-n          oset -o noexec     '
	exe "amenu ".s:RUBY_Root.'s&et.nog&lob<Tab>-f          oset -o noglob     '
	exe "amenu ".s:RUBY_Root.'s&et.notif&y<Tab>-b          oset -o notify     '
	exe "amenu ".s:RUBY_Root.'s&et.no&unset<Tab>-u         oset -o nounset    '
	exe "amenu ".s:RUBY_Root.'s&et.onecm&d<Tab>-t          oset -o onecmd     '
	exe "amenu ".s:RUBY_Root.'s&et.physical\ (&2)<Tab>-P   oset -o physical   '
	exe "amenu ".s:RUBY_Root.'s&et.pipe&fail               oset -o pipefail   '
	exe "amenu ".s:RUBY_Root.'s&et.posix\ (&3)             oset -o posix      '
	exe "amenu ".s:RUBY_Root.'s&et.&privileged<Tab>-p      oset -o privileged '
	exe "amenu ".s:RUBY_Root.'s&et.&verbose<Tab>-v         oset -o verbose    '
	exe "amenu ".s:RUBY_Root.'s&et.v&i                     oset -o vi         '
	exe "amenu ".s:RUBY_Root.'s&et.&xtrace<Tab>-x          oset -o xtrace     '
	"
	exe "vmenu ".s:RUBY_Root.'s&et.&allexport<Tab>-a       <Esc>:call RUBY_set("allexport  ")<CR>'
	exe "vmenu ".s:RUBY_Root.'s&et.&braceexpand<Tab>-B     <Esc>:call RUBY_set("braceexpand")<CR>'
	exe "vmenu ".s:RUBY_Root.'s&et.emac&s                  <Esc>:call RUBY_set("emacs      ")<CR>'
	exe "vmenu ".s:RUBY_Root.'s&et.&errexit<Tab>-e         <Esc>:call RUBY_set("errexit    ")<CR>'
	exe "vmenu ".s:RUBY_Root.'s&et.e&rrtrace<Tab>-E        <Esc>:call RUBY_set("errtrace   ")<CR>'
	exe "vmenu ".s:RUBY_Root.'s&et.func&trace<Tab>-T       <Esc>:call RUBY_set("functrace  ")<CR>'
	exe "vmenu ".s:RUBY_Root.'s&et.&hashall<Tab>-h         <Esc>:call RUBY_set("hashall    ")<CR>'
	exe "vmenu ".s:RUBY_Root.'s&et.histexpand\ (&1)<Tab>-H <Esc>:call RUBY_set("histexpand ")<CR>'
	exe "vmenu ".s:RUBY_Root.'s&et.hist&ory                <Esc>:call RUBY_set("history    ")<CR>'
	exe "vmenu ".s:RUBY_Root.'s&et.i&gnoreeof              <Esc>:call RUBY_set("ignoreeof  ")<CR>'
	exe "vmenu ".s:RUBY_Root.'s&et.&keyword<Tab>-k         <Esc>:call RUBY_set("keyword    ")<CR>'
	exe "vmenu ".s:RUBY_Root.'s&et.&monitor<Tab>-m         <Esc>:call RUBY_set("monitor    ")<CR>'
	exe "vmenu ".s:RUBY_Root.'s&et.no&clobber<Tab>-C       <Esc>:call RUBY_set("noclobber  ")<CR>'
	exe "vmenu ".s:RUBY_Root.'s&et.&noexec<Tab>-n          <Esc>:call RUBY_set("noexec     ")<CR>'
	exe "vmenu ".s:RUBY_Root.'s&et.nog&lob<Tab>-f          <Esc>:call RUBY_set("noglob     ")<CR>'
	exe "vmenu ".s:RUBY_Root.'s&et.notif&y<Tab>-b          <Esc>:call RUBY_set("notify     ")<CR>'
	exe "vmenu ".s:RUBY_Root.'s&et.no&unset<Tab>-u         <Esc>:call RUBY_set("nounset    ")<CR>'
	exe "vmenu ".s:RUBY_Root.'s&et.onecm&d<Tab>-t          <Esc>:call RUBY_set("onecmd     ")<CR>'
	exe "vmenu ".s:RUBY_Root.'s&et.physical\ (&2)<Tab>-P   <Esc>:call RUBY_set("physical   ")<CR>'
	exe "vmenu ".s:RUBY_Root.'s&et.pipe&fail               <Esc>:call RUBY_set("pipefail   ")<CR>'
	exe "vmenu ".s:RUBY_Root.'s&et.posix\ (&3)             <Esc>:call RUBY_set("posix      ")<CR>'
	exe "vmenu ".s:RUBY_Root.'s&et.&privileged<Tab>-p      <Esc>:call RUBY_set("privileged ")<CR>'
	exe "vmenu ".s:RUBY_Root.'s&et.&verbose<Tab>-v         <Esc>:call RUBY_set("verbose    ")<CR>'
	exe "vmenu ".s:RUBY_Root.'s&et.v&i                     <Esc>:call RUBY_set("vi         ")<CR>'
	exe "vmenu ".s:RUBY_Root.'s&et.&xtrace<Tab>-x          <Esc>:call RUBY_set("xtrace     ")<CR>'
	"
	"-------------------------------------------------------------------------------
	"----- menu shopt   {{{2
	"-------------------------------------------------------------------------------
	call	RUBY_ShoptMenus ( s:RUBY_Root.'sh&opt.shopt\ \ &a-g', s:RubyShopt[0:20] )
	call	RUBY_ShoptMenus ( s:RUBY_Root.'sh&opt.shopt\ \ &h-x', s:RubyShopt[21:39] )
	"
	"------------------------------------------------------------------------------
	"----- menu Regex    {{{2
	"------------------------------------------------------------------------------
	"
	exe "anoremenu ".s:RUBY_Root.'Rege&x.match\ \ \ [[\ =~\ ]]<Tab>\\xm              a[[  =~  ]]<Left><Left><Left><Left><Left><Left><Left>'
	exe "inoremenu ".s:RUBY_Root.'Rege&x.match\ \ \ [[\ =~\ ]]<Tab>\\xm               [[  =~  ]]<Left><Left><Left><Left><Left><Left><Left>'
	exe "amenu     ".s:RUBY_Root.'Rege&x.-Sep01-      :'
	"
	exe "anoremenu ".s:RUBY_Root.'Rege&x.zero\ or\ more\ \ \ &*(\ \|\ )              a*(\|)<Left><Left>'
	exe "anoremenu ".s:RUBY_Root.'Rege&x.one\ or\ more\ \ \ \ &+(\ \|\ )             a+(\|)<Left><Left>'
	exe "anoremenu ".s:RUBY_Root.'Rege&x.zero\ or\ one\ \ \ \ \ &?(\ \|\ )           a?(\|)<Left><Left>'
	exe "anoremenu ".s:RUBY_Root.'Rege&x.exactly\ one\ \ \ \ \ &@(\ \|\ )  				   a@(\|)<Left><Left>'
	exe "anoremenu ".s:RUBY_Root.'Rege&x.anyth\.\ except\ \ \ &!(\ \|\ )             a!(\|)<Left><Left>'
	"
	exe "inoremenu ".s:RUBY_Root.'Rege&x.zero\ or\ more\ \ \ &*(\ \|\ )               *(\|)<Left><Left>'
	exe "inoremenu ".s:RUBY_Root.'Rege&x.one\ or\ more\ \ \ \ &+(\ \|\ )              +(\|)<Left><Left>'
	exe "inoremenu ".s:RUBY_Root.'Rege&x.zero\ or\ one\ \ \ \ \ &?(\ \|\ )            ?(\|)<Left><Left>'
	exe "inoremenu ".s:RUBY_Root.'Rege&x.exactly\ one\ \ \ \ \ &@(\ \|\ )  				    @(\|)<Left><Left>'
	exe "inoremenu ".s:RUBY_Root.'Rege&x.anyth\.\ except\ \ \ &!(\ \|\ )              !(\|)<Left><Left>'
	"
	exe "vnoremenu ".s:RUBY_Root.'Rege&x.zero\ or\ more\ \ \ &*(\ \|\ )              s*(\|)<Esc>hPla'
	exe "vnoremenu ".s:RUBY_Root.'Rege&x.one\ or\ more\ \ \ \ &+(\ \|\ )             s+(\|)<Esc>hPla'
	exe "vnoremenu ".s:RUBY_Root.'Rege&x.zero\ or\ one\ \ \ \ \ &?(\ \|\ )           s?(\|)<Esc>hPla'
	exe "vnoremenu ".s:RUBY_Root.'Rege&x.exactly\ one\ \ \ \ \ &@(\ \|\ )  				   s@(\|)<Esc>hPla'
	exe "vnoremenu ".s:RUBY_Root.'Rege&x.anyth\.\ except\ \ \ &!(\ \|\ )             s!(\|)<Esc>hPla'
	"
	exe "amenu ".s:RUBY_Root.'Rege&x.-Sep1-      :'
  "
  exe "anoremenu ".s:RUBY_Root.'Rege&x.[:&alnum:]<Tab>\\pan   a[:alnum:]'
  exe "anoremenu ".s:RUBY_Root.'Rege&x.[:alp&ha:]<Tab>\\pal   a[:alpha:]'
  exe "anoremenu ".s:RUBY_Root.'Rege&x.[:asc&ii:]<Tab>\\pas   a[:ascii:]'
  exe "anoremenu ".s:RUBY_Root.'Rege&x.[:&blank:]<Tab>\\pb   a[:blank:]'
  exe "anoremenu ".s:RUBY_Root.'Rege&x.[:&cntrl:]<Tab>\\pc   a[:cntrl:]'
  exe "anoremenu ".s:RUBY_Root.'Rege&x.[:&digit:]<Tab>\\pd   a[:digit:]'
  exe "anoremenu ".s:RUBY_Root.'Rege&x.[:&graph:]<Tab>\\pg   a[:graph:]'
  exe "anoremenu ".s:RUBY_Root.'Rege&x.[:&lower:]<Tab>\\pl   a[:lower:]'
  exe "anoremenu ".s:RUBY_Root.'Rege&x.[:&print:]<Tab>\\ppr  a[:print:]'
  exe "anoremenu ".s:RUBY_Root.'Rege&x.[:pu&nct:]<Tab>\\ppu  a[:punct:]'
  exe "anoremenu ".s:RUBY_Root.'Rege&x.[:&space:]<Tab>\\ps   a[:space:]'
  exe "anoremenu ".s:RUBY_Root.'Rege&x.[:&upper:]<Tab>\\pu   a[:upper:]'
  exe "anoremenu ".s:RUBY_Root.'Rege&x.[:&word:]<Tab>\\pw    a[:word:]'
  exe "anoremenu ".s:RUBY_Root.'Rege&x.[:&xdigit:]<Tab>\\px  a[:xdigit:]'
  "
  exe "inoremenu ".s:RUBY_Root.'Rege&x.[:&alnum:]<Tab>\\pan   [:alnum:]'
  exe "inoremenu ".s:RUBY_Root.'Rege&x.[:alp&ha:]<Tab>\\pal   [:alpha:]'
  exe "inoremenu ".s:RUBY_Root.'Rege&x.[:asc&ii:]<Tab>\\pas   [:ascii:]'
  exe "inoremenu ".s:RUBY_Root.'Rege&x.[:&blank:]<Tab>\\pb    [:blank:]'
  exe "inoremenu ".s:RUBY_Root.'Rege&x.[:&cntrl:]<Tab>\\pc    [:cntrl:]'
  exe "inoremenu ".s:RUBY_Root.'Rege&x.[:&digit:]<Tab>\\pd    [:digit:]'
  exe "inoremenu ".s:RUBY_Root.'Rege&x.[:&graph:]<Tab>\\pg    [:graph:]'
  exe "inoremenu ".s:RUBY_Root.'Rege&x.[:&lower:]<Tab>\\pl    [:lower:]'
  exe "inoremenu ".s:RUBY_Root.'Rege&x.[:&print:]<Tab>\\ppr   [:print:]'
  exe "inoremenu ".s:RUBY_Root.'Rege&x.[:pu&nct:]<Tab>\\ppu   [:punct:]'
  exe "inoremenu ".s:RUBY_Root.'Rege&x.[:&space:]<Tab>\\ps    [:space:]'
  exe "inoremenu ".s:RUBY_Root.'Rege&x.[:&upper:]<Tab>\\pu    [:upper:]'
  exe "inoremenu ".s:RUBY_Root.'Rege&x.[:&word:]<Tab>\\pw     [:word:]'
  exe "inoremenu ".s:RUBY_Root.'Rege&x.[:&xdigit:]<Tab>\\px   [:xdigit:]'
	"
	exe "amenu ".s:RUBY_Root.'Rege&x.-Sep2-      :'
	"
	exe "anoremenu ".s:RUBY_Root.'Rege&x.${RUBY_REMATCH[&0]}    	     a${RUBY_REMATCH[0]}'
	exe "anoremenu ".s:RUBY_Root.'Rege&x.${RUBY_REMATCH[&1]}    	     a${RUBY_REMATCH[1]}'
	exe "anoremenu ".s:RUBY_Root.'Rege&x.${RUBY_REMATCH[&2]}    	     a${RUBY_REMATCH[2]}'
	exe "anoremenu ".s:RUBY_Root.'Rege&x.${RUBY_REMATCH[&3]}    	     a${RUBY_REMATCH[3]}'
	"
	exe "inoremenu ".s:RUBY_Root.'Rege&x.${RUBY_REMATCH[&0]}    	<Esc>a${RUBY_REMATCH[0]}'
	exe "inoremenu ".s:RUBY_Root.'Rege&x.${RUBY_REMATCH[&1]}    	<Esc>a${RUBY_REMATCH[1]}'
	exe "inoremenu ".s:RUBY_Root.'Rege&x.${RUBY_REMATCH[&2]}    	<Esc>a${RUBY_REMATCH[2]}'
	exe "inoremenu ".s:RUBY_Root.'Rege&x.${RUBY_REMATCH[&3]}    	<Esc>a${RUBY_REMATCH[3]}'
	"
	"
	"-------------------------------------------------------------------------------
	"----- menu I/O redirection   {{{2
	"-------------------------------------------------------------------------------
	"      
	exe "	menu ".s:RUBY_Root.'&I/O-Redir.take\ STDIN\ from\ file<Tab><												a<Space><<Space>'
	exe "	menu ".s:RUBY_Root.'&I/O-Redir.direct\ STDOUT\ to\ file<Tab>>												a<Space>><Space>'
	exe "	menu ".s:RUBY_Root.'&I/O-Redir.direct\ STDOUT\ to\ file;\ append<Tab>>>							a<Space>>><Space>'
	exe "	menu ".s:RUBY_Root.'&I/O-Redir.direct\ STDOUT\ to\ STDERR<Tab>>&2				      			a<Space>>&2'
	"
	exe "	menu ".s:RUBY_Root.'&I/O-Redir.direct\ file\ descr\.\ n\ to\ file<Tab>n>						a<Space>><Space><ESC>2hi'
	exe "	menu ".s:RUBY_Root.'&I/O-Redir.direct\ file\ descr\.\ n\ to\ file;\ append<Tab>n>> 	a<Space>>><Space><ESC>3hi'
	exe "	menu ".s:RUBY_Root.'&I/O-Redir.take\ file\ descr\.\ n\ from\ file<Tab>n< 						a<Space><<Space><ESC>2hi'
	"
	exe "	menu ".s:RUBY_Root.'&I/O-Redir.duplicate\ STDOUT\ to\ file\ descr\.\ n<Tab>n>&			a<Space>>& <ESC>2hi'
	exe "	menu ".s:RUBY_Root.'&I/O-Redir.duplicate\ STDIN\ from\ file\ descr\.\ n<Tab>n<&			a<Space><& <ESC>2hi'
	exe "	menu ".s:RUBY_Root.'&I/O-Redir.direct\ STDOUT\ and\ STDERR\ to\ file<Tab>&>					a<Space>&> '
	"
	exe "	menu ".s:RUBY_Root.'&I/O-Redir.close\ STDIN<Tab><&-																	a<Space><&- '
	exe "	menu ".s:RUBY_Root.'&I/O-Redir.close\ STDOUT<Tab>>&-																a<Space>>&- '
	exe "	menu ".s:RUBY_Root.'&I/O-Redir.close\ input\ from\ file\ descr\.\ n<Tab>n<&-				a<Space><&- <ESC>3hi'
	exe "	menu ".s:RUBY_Root.'&I/O-Redir.close\ output\ from\ file\ descr\.\ n<Tab>n>&-				a<Space>>&- <ESC>3hi'
	exe "	menu ".s:RUBY_Root.'&I/O-Redir.append\ STDOUT\ and\ STDERR<Tab>&>>            			a<Space>&>> '
	"
	exe "imenu ".s:RUBY_Root.'&I/O-Redir.take\ STDIN\ from\ file<Tab><												<Space><<Space>'
	exe "imenu ".s:RUBY_Root.'&I/O-Redir.direct\ STDOUT\ to\ file<Tab>>												<Space>><Space>'
	exe "imenu ".s:RUBY_Root.'&I/O-Redir.direct\ STDOUT\ to\ file;\ append<Tab>>>							<Space>>><Space>'
	"
	exe "imenu ".s:RUBY_Root.'&I/O-Redir.direct\ file\ descr\.\ n\ to\ file<Tab>n>						<Space>><Space><ESC>2hi'
	exe "imenu ".s:RUBY_Root.'&I/O-Redir.direct\ file\ descr\.\ n\ to\ file;\ append<Tab>n>> 	<Space>>><Space><ESC>3hi'
	exe "imenu ".s:RUBY_Root.'&I/O-Redir.take\ file\ descr\.\ n\ from\ file<Tab>n< 						<Space><<Space><ESC>2hi'
	exe "imenu ".s:RUBY_Root.'&I/O-Redir.direct\ STDOUT\ to\ STDERR<Tab>>&2				      			<Space>>&2'
	"
	exe "imenu ".s:RUBY_Root.'&I/O-Redir.duplicate\ STDOUT\ to\ file\ descr\.\ n<Tab>n>&			<Space>>& <Left><Left><Left>'
	exe "imenu ".s:RUBY_Root.'&I/O-Redir.duplicate\ STDIN\ from\ file\ descr\.\ n<Tab>n<&			<Space><& <Left><Left><Left>'
	exe "imenu ".s:RUBY_Root.'&I/O-Redir.direct\ STDOUT\ and\ STDERR\ to\ file<Tab>&>					<Space>&> '
	"
	exe "imenu ".s:RUBY_Root.'&I/O-Redir.close\ STDIN<Tab><&-																	<Space><&- '
	exe "imenu ".s:RUBY_Root.'&I/O-Redir.close\ STDOUT<Tab>>&-																<Space>>&- '
	exe "imenu ".s:RUBY_Root.'&I/O-Redir.close\ input\ from\ file\ descr\.\ n<Tab>n<&-				<Space><&- <ESC>3hi'
	exe "imenu ".s:RUBY_Root.'&I/O-Redir.close\ output\ from\ file\ descr\.\ n<Tab>n>&-				<Space>>&- <ESC>3hi'
	exe "imenu ".s:RUBY_Root.'&I/O-Redir.append\ STDOUT\ and\ STDERR<Tab>&>>            			<Space>&>> '
	"
	"
	exe "	menu ".s:RUBY_Root.'&I/O-Redir.here-document<Tab><<-label														a<<-EOF<CR><CR>EOF<CR># ===== end of here-document =====<ESC>2ki'
	exe "imenu ".s:RUBY_Root.'&I/O-Redir.here-document<Tab><<-label														<<-EOF<CR><CR>EOF<CR># ===== end of here-document =====<ESC>2ki'
	exe "vmenu ".s:RUBY_Root.'&I/O-Redir.here-document<Tab><<-label														S<<-EOF<CR>EOF<CR># ===== end of here-document =====<ESC>kPk^i'
	"
	"------------------------------------------------------------------------------
	"----- menu Run    {{{2
	"------------------------------------------------------------------------------
	"   run the script from the local directory
	"   ( the one in the current buffer ; other versions may exist elsewhere ! )
	"

	exe " menu <silent> ".s:RUBY_Root.'&Run.save\ +\ &run\ script<Tab>\\rr\ \r<C-F9>            :call RUBY_Run("n")<CR>'
	exe "imenu <silent> ".s:RUBY_Root.'&Run.save\ +\ &run\ script<Tab>\\rr\ \r<C-F9>       <C-C>:call RUBY_Run("n")<CR>'
	if	!s:MSWIN
		exe "vmenu <silent> ".s:RUBY_Root.'&Run.save\ +\ &run\ script<Tab>\\rr\ \r<C-F9>       <C-C>:call RUBY_Run("v")<CR>'
	endif
	"
	"   set execution right only for the user ( may be user root ! )
	"
	exe " menu <silent> ".s:RUBY_Root.'&Run.script\ cmd\.\ line\ &arg\.<Tab>\\ra\ \ <S-F9>            :call RUBY_ScriptCmdLineArguments()<CR>'
	exe "imenu <silent> ".s:RUBY_Root.'&Run.script\ cmd\.\ line\ &arg\.<Tab>\\ra\ \ <S-F9>       <C-C>:call RUBY_ScriptCmdLineArguments()<CR>'
	"
	exe " menu <silent> ".s:RUBY_Root.'&Run.Ruby\ cmd\.\ line\ &arg\.<Tab>\\rba                       :call RUBY_RubyCmdLineArguments()<CR>'
	exe "imenu <silent> ".s:RUBY_Root.'&Run.Ruby\ cmd\.\ line\ &arg\.<Tab>\\rba                  <C-C>:call RUBY_RubyCmdLineArguments()<CR>'
	"
	exe " menu <silent> ".s:RUBY_Root.'&Run.save\ +\ &check\ syntax<Tab>\\rc\ \ <A-F9>      :call RUBY_SyntaxCheck()<CR>'
	exe "imenu <silent> ".s:RUBY_Root.'&Run.save\ +\ &check\ syntax<Tab>\\rc\ \ <A-F9> <C-C>:call RUBY_SyntaxCheck()<CR>'
	exe " menu <silent> ".s:RUBY_Root.'&Run.syntax\ check\ o&ptions<Tab>\\rco               :call RUBY_SyntaxCheckOptionsLocal()<CR>'
	exe "imenu <silent> ".s:RUBY_Root.'&Run.syntax\ check\ o&ptions<Tab>\\rco          <C-C>:call RUBY_SyntaxCheckOptionsLocal()<CR>'
	"
	if	!s:MSWIN
		exe " menu <silent> ".s:RUBY_Root.'&Run.start\ &debugger<Tab>\\rd\ \ \ \ <F9>           :call RUBY_Debugger()<CR>'
		exe "imenu <silent> ".s:RUBY_Root.'&Run.start\ &debugger<Tab>\\rd\ \ \ \ <F9>      <C-C>:call RUBY_Debugger()<CR>'
		exe " menu <silent> ".s:RUBY_Root.'&Run.make\ script\ &executable<Tab>\\re              :call RUBY_MakeScriptExecutable()<CR>'
		exe "imenu <silent> ".s:RUBY_Root.'&Run.make\ script\ &executable<Tab>\\re         <C-C>:call RUBY_MakeScriptExecutable()<CR>'
	endif
	"
	exe "amenu          ".s:RUBY_Root.'&Run.-Sep1-                                 :'
	"
	if	s:MSWIN
		exe " menu <silent> ".s:RUBY_Root.'&Run.&hardcopy\ to\ printer\.ps<Tab>\\rh           :call RUBY_Hardcopy("n")<CR>'
		exe "imenu <silent> ".s:RUBY_Root.'&Run.&hardcopy\ to\ printer\.ps<Tab>\\rh      <C-C>:call RUBY_Hardcopy("n")<CR>'
		exe "vmenu <silent> ".s:RUBY_Root.'&Run.&hardcopy\ to\ printer\.ps<Tab>\\rh      <C-C>:call RUBY_Hardcopy("v")<CR>'
	else
		exe " menu <silent> ".s:RUBY_Root.'&Run.&hardcopy\ to\ FILENAME\.ps<Tab>\\rh           :call RUBY_Hardcopy("n")<CR>'
		exe "imenu <silent> ".s:RUBY_Root.'&Run.&hardcopy\ to\ FILENAME\.ps<Tab>\\rh      <C-C>:call RUBY_Hardcopy("n")<CR>'
		exe "vmenu <silent> ".s:RUBY_Root.'&Run.&hardcopy\ to\ FILENAME\.ps<Tab>\\rh      <C-C>:call RUBY_Hardcopy("v")<CR>'
	endif
	exe " menu          ".s:RUBY_Root.'&Run.-SEP2-                                 :'
	exe " menu <silent> ".s:RUBY_Root.'&Run.plugin\ &settings<Tab>\\rs                       :call RUBY_Settings()<CR>'
	exe "imenu <silent> ".s:RUBY_Root.'&Run.plugin\ &settings<Tab>\\rs                  <C-C>:call RUBY_Settings()<CR>'
	"
	exe "imenu          ".s:RUBY_Root.'&Run.-SEP3-                                 :'
	"
	if	!s:MSWIN
		exe " menu  <silent>  ".s:RUBY_Root.'&Run.x&term\ size<Tab>\\rt                       :call RUBY_XtermSize()<CR>'
		exe "imenu  <silent>  ".s:RUBY_Root.'&Run.x&term\ size<Tab>\\rt                  <C-C>:call RUBY_XtermSize()<CR>'
	endif
	"
	if	s:MSWIN
		if s:RUBY_OutputGvim == "buffer"
			exe " menu  <silent>  ".s:RUBY_Root.'&Run.&output:\ BUFFER->term<Tab>\\ro          :call RUBY_Toggle_Gvim_Xterm_MS()<CR>'
			exe "imenu  <silent>  ".s:RUBY_Root.'&Run.&output:\ BUFFER->term<Tab>\\ro     <C-C>:call RUBY_Toggle_Gvim_Xterm_MS()<CR>'
		else
			exe " menu  <silent>  ".s:RUBY_Root.'&Run.&output:\ TERM->buffer<Tab>\\ro          :call RUBY_Toggle_Gvim_Xterm_MS()<CR>'
			exe "imenu  <silent>  ".s:RUBY_Root.'&Run.&output:\ TERM->buffer<Tab>\\ro     <C-C>:call RUBY_Toggle_Gvim_Xterm_MS()<CR>'
		endif
	else
		if s:RUBY_OutputGvim == "vim"
			exe " menu  <silent>  ".s:RUBY_Root.'&Run.&output:\ VIM->buffer->xterm<Tab>\\ro          :call RUBY_Toggle_Gvim_Xterm()<CR>'
			exe "imenu  <silent>  ".s:RUBY_Root.'&Run.&output:\ VIM->buffer->xterm<Tab>\\ro     <C-C>:call RUBY_Toggle_Gvim_Xterm()<CR>'
		else
			if s:RUBY_OutputGvim == "buffer"
				exe " menu  <silent>  ".s:RUBY_Root.'&Run.&output:\ BUFFER->xterm->vim<Tab>\\ro        :call RUBY_Toggle_Gvim_Xterm()<CR>'
				exe "imenu  <silent>  ".s:RUBY_Root.'&Run.&output:\ BUFFER->xterm->vim<Tab>\\ro   <C-C>:call RUBY_Toggle_Gvim_Xterm()<CR>'
			else
				exe " menu  <silent>  ".s:RUBY_Root.'&Run.&output:\ XTERM->vim->buffer<Tab>\\ro        :call RUBY_Toggle_Gvim_Xterm()<CR>'
				exe "imenu  <silent>  ".s:RUBY_Root.'&Run.&output:\ XTERM->vim->buffer<Tab>\\ro   <C-C>:call RUBY_Toggle_Gvim_Xterm()<CR>'
			endif
		endif
	endif
	"
	"===============================================================================================
	"----- menu help     {{{2
	"===============================================================================================
	"
	exe " menu  <silent>  ".s:RUBY_Root.'&Help.&Ruby\ manual<Tab>\\hb                    :call RUBY_help("b")<CR>'
	exe "imenu  <silent>  ".s:RUBY_Root.'&Help.&Ruby\ manual<Tab>\\hb               <C-C>:call RUBY_help("b")<CR>'
	"
	exe " menu  <silent>  ".s:RUBY_Root.'&Help.&help\ (Ruby\ builtins)<Tab>\\hh          :call RUBY_help("h")<CR>'
	exe "imenu  <silent>  ".s:RUBY_Root.'&Help.&help\ (Ruby\ builtins)<Tab>\\hh     <C-C>:call RUBY_help("h")<CR>'
	"
	exe " menu  <silent>  ".s:RUBY_Root.'&Help.&manual\ (utilities)<Tab>\\hm             :call RUBY_help("m")<CR>'
	exe "imenu  <silent>  ".s:RUBY_Root.'&Help.&manual\ (utilities)<Tab>\\hm        <C-C>:call RUBY_help("m")<CR>'
	"
	exe " menu  <silent>  ".s:RUBY_Root.'&Help.ruby-&support<Tab>\\hbs           :call RUBY_HelpBASHsupport()<CR>'
	exe "imenu  <silent>  ".s:RUBY_Root.'&Help.ruby-&support<Tab>\\hbs      <C-C>:call RUBY_HelpBASHsupport()<CR>'
	"
endfunction		" ---------- end of function  RUBY_InitMenu  ----------

"------------------------------------------------------------------------------
"  BASH Menu Header Initialization      {{{1
"------------------------------------------------------------------------------
function! RUBY_InitMenuHeader ()
	exe "amenu ".s:RUBY_Root.'Ruby          :call RUBY_MenuTitle()<CR>'
	exe "amenu ".s:RUBY_Root.'-Sep0-        :'
	exe "amenu ".s:RUBY_Root.'&Comments.Comments<Tab>Ruby   :call RUBY_MenuTitle()<CR>'
	exe "amenu ".s:RUBY_Root.'&Comments.-Sep0-              :'
	exe "amenu ".s:RUBY_Root.'&Statements.Statements<Tab>Ruby  :call RUBY_MenuTitle()<CR>'
	exe "amenu ".s:RUBY_Root.'&Statements.-Sep0-               :'
	exe "amenu ".s:RUBY_Root.'&Snippets.Snippets<Tab>Ruby  :call RUBY_MenuTitle()<CR>'
	exe "amenu ".s:RUBY_Root.'&Snippets.-Sep0-             :'
	exe "amenu ".s:RUBY_Root.'&Tests.Tests<Tab>Ruby   :call RUBY_MenuTitle()<CR>'
	exe "amenu ".s:RUBY_Root.'&Tests.-Sep0-           :'
	exe "amenu ".s:RUBY_Root.'&Tests.&arithmetic\ tests.Tests-1<Tab>Ruby   :call RUBY_MenuTitle()<CR>'
	exe "amenu ".s:RUBY_Root.'&Tests.&arithmetic\ tests.-Sep0-             :'
	exe "amenu ".s:RUBY_Root.'&Tests.file\ exists\ and\ has\ &permission.Tests-2<Tab>Ruby :call RUBY_MenuTitle()<CR>'
	exe "amenu ".s:RUBY_Root.'&Tests.file\ exists\ and\ has\ &permission.-Sep0-           :'
	exe "amenu ".s:RUBY_Root.'&Tests.file\ exists\ and\ has\ t&ype.Tests-3<Tab>Ruby       :call RUBY_MenuTitle()<CR>'
	exe "amenu ".s:RUBY_Root.'&Tests.file\ exists\ and\ has\ t&ype.-Sep0-                 :'
	exe "amenu ".s:RUBY_Root.'&Tests.string\ &comparison.Tests-4<Tab>Ruby                 :call RUBY_MenuTitle()<CR>'
	exe "amenu ".s:RUBY_Root.'&Tests.string\ &comparison.-Sep0-                           :'
	exe "amenu ".s:RUBY_Root.'&ParamSub.ParamSub<Tab>Ruby :call RUBY_MenuTitle()<CR>'
	exe "amenu ".s:RUBY_Root.'&ParamSub.-Sep0-            :'
	exe "amenu ".s:RUBY_Root.'Spec&Vars.SpecVars<Tab>Ruby :call RUBY_MenuTitle()<CR>'
	exe "amenu ".s:RUBY_Root.'Spec&Vars.-Sep0-            :'
	exe "amenu ".s:RUBY_Root.'E&nviron.Environ<Tab>Ruby   :call RUBY_MenuTitle()<CR>'
	exe "amenu ".s:RUBY_Root.'E&nviron.-Sep0-             :'
	exe "amenu ".s:RUBY_Root.'E&nviron.&BASH\ \.\.\.\ RUBY_VERSION.Environ-1<Tab>Ruby :call RUBY_MenuTitle()<CR>'
	exe "amenu ".s:RUBY_Root.'E&nviron.&BASH\ \.\.\.\ RUBY_VERSION.-Sep0-             :'
	exe "amenu ".s:RUBY_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.Environ-2<Tab>Ruby   :call RUBY_MenuTitle()<CR>'
	exe "amenu ".s:RUBY_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.-Sep0-               :'
	exe "amenu ".s:RUBY_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.Environ-3<Tab>Ruby   :call RUBY_MenuTitle()<CR>'
	exe "amenu ".s:RUBY_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.-Sep0-               :'
	exe "amenu ".s:RUBY_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.Environ-4<Tab>Ruby :call RUBY_MenuTitle()<CR>'
	exe "amenu ".s:RUBY_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.-Sep0-             :'
	exe "amenu ".s:RUBY_Root.'E&nviron.&PATH\ \.\.\.\ UID.Environ-5<Tab>Ruby      :call RUBY_MenuTitle()<CR>'
	exe "amenu ".s:RUBY_Root.'E&nviron.&PATH\ \.\.\.\ UID.-Sep0-                  :'
	exe "amenu ".s:RUBY_Root.'&Builtins.Builtins<Tab>Ruby  :call RUBY_MenuTitle()<CR>'
	exe "amenu ".s:RUBY_Root.'&Builtins.-Sep0-             :'
	exe "amenu ".s:RUBY_Root.'&Builtins.Builtins\ \ &a-f.Builtins\ 1<Tab>Ruby  :call RUBY_MenuTitle()<CR>'
	exe "amenu ".s:RUBY_Root.'&Builtins.Builtins\ \ &a-f.-Sep0-                :'
	exe "amenu ".s:RUBY_Root.'&Builtins.Builtins\ \ &g-r.Builtins\ 2<Tab>Ruby  :call RUBY_MenuTitle()<CR>'
	exe "amenu ".s:RUBY_Root.'&Builtins.Builtins\ \ &g-r.-Sep0-                :'
	exe "amenu ".s:RUBY_Root.'&Builtins.Builtins\ \ &s-w.Builtins\ 3<Tab>Ruby  :call RUBY_MenuTitle()<CR>'
	exe "amenu ".s:RUBY_Root.'&Builtins.Builtins\ \ &s-w.-Sep0-                :'
	exe "amenu ".s:RUBY_Root.'s&et.set<Tab>Ruby   :call RUBY_MenuTitle()<CR>'
	exe "amenu ".s:RUBY_Root.'s&et.-Sep0-         :'
	exe "amenu ".s:RUBY_Root.'sh&opt.shopt<Tab>Ruby   :call RUBY_MenuTitle()<CR>'
	exe "amenu ".s:RUBY_Root.'sh&opt.-Sep0-           :'
	exe "amenu ".s:RUBY_Root.'sh&opt.shopt\ \ &a-g.shopt\ 1<Tab>Ruby :call RUBY_MenuTitle()<CR>'
	exe "amenu ".s:RUBY_Root.'sh&opt.shopt\ \ &a-g.-Sep0-            :'
	exe "amenu ".s:RUBY_Root.'sh&opt.shopt\ \ &h-x.shopt\ 2<Tab>Ruby :call RUBY_MenuTitle()<CR>'
	exe "amenu ".s:RUBY_Root.'sh&opt.shopt\ \ &h-x.-Sep0-            :'
	exe "amenu ".s:RUBY_Root.'Rege&x.Regex<Tab>ruby   :call RUBY_MenuTitle()<CR>'
	exe "amenu ".s:RUBY_Root.'Rege&x.-Sep0-           :'
	exe "amenu ".s:RUBY_Root.'&I/O-Redir.I/O-Redir<Tab>Ruby :call RUBY_MenuTitle()<CR>'
	exe "amenu ".s:RUBY_Root.'&I/O-Redir.-Sep0-             :'
	exe "amenu ".s:RUBY_Root.'&Run.Run<Tab>Ruby   :call RUBY_MenuTitle()<CR>'
	exe "amenu ".s:RUBY_Root.'&Run.-Sep0-         :'
	exe "amenu ".s:RUBY_Root.'&Help.Help<Tab>Ruby :call RUBY_MenuTitle()<CR>'
	exe "amenu ".s:RUBY_Root.'&Help.-Sep0-        :'
endfunction    " ----------  end of function RUBY_InitMenuHeader  ----------

function! RUBY_MenuTitle ()
	echo "This is a menu title."
endfunction    " ----------  end of function RUBY_MenuTitle  ----------

let	s:RubyEnvironmentVariables  = [
	\	'&BASH',        'BASH&PID',               'RUBY_&ALIASES',
	\	'RUBY_ARG&C',   'RUBY_ARG&V',             'RUBY_C&MDS',       'RUBY_C&OMMAND',
	\	'RUBY_&ENV',    'RUBY_E&XECUTION_STRING', 'RUBY_&LINENO',     'BASH&OPTS',      'RUBY_&REMATCH',
	\	'RUBY_&SOURCE', 'RUBY_S&UBSHELL',         'RUBY_VERS&INFO',   'RUBY_VERSIO&N',  'RUBY_XTRACEFD',
	\	'&CDPATH',      'C&OLUMNS',               'CO&MPREPLY',       'COM&P_CWORD',
	\	'COMP_&KEY',    'COMP_&LINE',             'COMP_POI&NT',      'COMP_&TYPE',
	\	'COMP_WORD&BREAKS', 'COMP_&WORDS',
	\	'&DIRSTACK',    '&EMAC&S',                '&EUID',            '&FCEDIT',
	\	'F&IGNORE',     'F&UNCNAME',              '&GLOBIGNORE',      'GRO&UPS',
	\	'&HISTCMD',     'HI&STCONTROL',           'HIS&TFILE',        'HIST&FILESIZE',
	\	'HISTIG&NORE',  'HISTSI&ZE',              'HISTTI&MEFORMAT',  'H&OME',
	\	'HOSTFIL&E',    'HOSTN&AME',              'HOSTT&YPE',        '&IFS',
	\	'IGNO&REEOF',   'INPUTR&C',               '&LANG',            '&LC_ALL',
	\	'LC_&COLLATE',  'LC_C&TYPE',              'LC_M&ESSAGES',     'LC_&NUMERIC',
	\	'L&INENO',      'LINE&S',                 '&MACHTYPE',        'M&AIL',
	\	'MAILCHEC&K',   'MAIL&PATH',              '&OLDPWD',          'OPTAR&G',
	\	'OPTER&R',      'OPTIN&D',                'OST&YPE',          '&PATH',
	\	'P&IPESTATUS',  'P&OSIXLY_CORRECT',       'PPI&D',            'PROMPT_&COMMAND',
	\	'PROMPT_&DIRTRIM',
	\	'PS&1',         'PS&2',                   'PS&3',             'PS&4',
	\	'P&WD',         '&RANDOM',                'REPL&Y',           '&SECONDS',
	\	'S&HELL',       'SH&ELLOPTS',             'SH&LVL',           '&TIMEFORMAT',
	\	'T&MOUT',       'TMP&DIR',                '&UID',
	\	]

let s:RubyBuiltins  = [
  \ '&alias',   'b&g',      '&bind',     'brea&k',    'b&uiltin',  '&caller',
  \ 'c&d',      'c&ommand', 'co&mpgen',  'com&plete', 'c&ontinue', 'comp&opt',
  \ 'd&eclare', 'di&rs',    'diso&wn',   'ec&ho',     'e&nable',   'e&val',
  \ 'e&xec',    'ex&it',    'expor&t',   '&false',    'f&c',       'f&g',  
  \ '&getopts', '&hash',    'help',      'h&istory',  '&jobs', 
  \ '&kill',    '&let',     'l&ocal',    'logout',    '&mapfile',   '&popd',
  \ 'print&f',  'p&ushd',   'p&wd',      '&read',     'read&array', 'readonl&y', 
  \ 'retur&n',  '&set', 
  \ 's&hift',   's&hopt',   's&ource',   'susp&end',  '&test',
  \ 'ti&mes',   't&rap',    'true',      't&ype',     'ty&peset',   '&ulimit',
  \ 'umas&k',   'un&alias', 'u&nset',    '&wait',
  \ ]

let	s:RubyShopt = [
	\	'autocd',        'cdable_vars',      'cdspell',       'checkhash',
	\	'checkjobs',     'checkwinsize',     'cmdhist',       'compat31',       'compat32',       'compat40', 
	\	'dirspell',      'dotglob',          'execfail',      'expand_aliases',
	\	'extdebug',      'extglob',          'extquote',      'failglob',
	\	'force_fignore', 'globstar',         'gnu_errfmt',    'histappend',    'histreedit',
	\	'histverify',    'hostcomplete',     'huponexit',     'interactive_comments',
	\	'lithist',       'login_shell',      'mailwarn',      'no_empty_cmd_completion',
	\	'nocaseglob',    'nocasematch',      'nullglob',      'progcomp',
	\	'promptvars',    'restricted_shell', 'shift_verbose', 'sourcepath',
	\	'xpg_echo',
	\	]

"------------------------------------------------------------------------------
"  Build the list for the Ruby help tab completion
"------------------------------------------------------------------------------
let s:RUBY_Builtins     = s:RubyBuiltins[:]
let index	= 0
while index < len( s:RUBY_Builtins )
	let s:RUBY_Builtins[index]	= substitute( s:RUBY_Builtins[index], '&', '', '' )
	let index = index + 1
endwhile

"------------------------------------------------------------------------------
"  RUBY_EnvirMenus: generate the  menu entries for environmnent variables  {{{1
"------------------------------------------------------------------------------
function! RUBY_EnvirMenus ( menupath, liblist )
	for item in a:liblist
		let replacement	= substitute( item, '[&\\]*', '','g' )
		exe " noremenu  ".a:menupath.'.'.item.'          a${'.replacement.'}'
		exe "inoremenu  ".a:menupath.'.'.item.'           ${'.replacement.'}'
	endfor
endfunction    " ----------  end of function RUBY_EnvirMenus  ----------

"------------------------------------------------------------------------------
"  RUBY_BuiltinMenus: generate the  menu entries for environmnent variables  {{{1
"------------------------------------------------------------------------------
function! RUBY_BuiltinMenus ( menupath, liblist )
	for item in a:liblist
		let replacement	= substitute( item, '[&\\]*', '','g' )
		exe " noremenu  ".a:menupath.'.'.item.'          a'.replacement.' '
		exe "inoremenu  ".a:menupath.'.'.item.'           '.replacement.' '
	endfor
endfunction    " ----------  end of function RUBY_BuiltinMenus  ----------

"------------------------------------------------------------------------------
"  RUBY_ShoptMenus: generate the  menu entries for environmnent variables  {{{1
"------------------------------------------------------------------------------
function! RUBY_ShoptMenus ( menupath, liblist )
	for item in a:liblist
		let replacement	= substitute( item, '[&\\]*', '','g' )
		exe " noremenu  ".a:menupath.'.'.item.'                oshopt -s '.replacement
		exe "inoremenu  ".a:menupath.'.'.item.'                 shopt -s '.replacement
		exe "vnoremenu  ".a:menupath.'.'.item.'   <Esc>:call RUBY_shopt("'.replacement.'")<CR>'
	endfor
endfunction    " ----------  end of function RUBY_ShoptMenus  ----------

"------------------------------------------------------------------------------
"  RUBY_RereadTemplates     {{{1
"  rebuild commands and the menu from the (changed) template file
"------------------------------------------------------------------------------
function! RUBY_RereadTemplates ( displaymsg )
	let s:style							= 'default'
	let s:RUBY_Template     = { 'default' : {} }
	let s:RUBY_FileVisited  = []
	let	messsage							= ''
	"
	if s:installation == 'system'
		"-------------------------------------------------------------------------------
		" system installation
		"-------------------------------------------------------------------------------
		if filereadable( s:RUBY_GlobalTemplateFile )
			call RUBY_ReadTemplates( s:RUBY_GlobalTemplateFile )
		else
			echomsg "Global template file '".s:RUBY_GlobalTemplateFile."' not readable."
			return
		endif
		let	messsage	= "Templates read from '".s:RUBY_GlobalTemplateFile."'"
		"
		if filereadable( s:RUBY_LocalTemplateFile )
			call RUBY_ReadTemplates( s:RUBY_LocalTemplateFile )
			let messsage	= messsage." and '".s:RUBY_LocalTemplateFile."'"
			if s:RUBY_Macro['|AUTHOR|'] == 'YOUR NAME'
				echomsg "Please set your personal details in file '".s:RUBY_LocalTemplateFile."'."
			endif
		else
			let template	= [ '|AUTHOR|    = YOUR NAME', 
						\						'|COPYRIGHT| = Copyright (c) |YEAR|, |AUTHOR|'
						\		]
			if finddir( s:RUBY_LocalTemplateDir ) == ''
				" try to create a local template directory
				if exists("*mkdir")
					try 
						call mkdir( s:RUBY_LocalTemplateDir, "p" )
						" write a default local template file
						call writefile( template, s:RUBY_LocalTemplateFile )
					catch /.*/
					endtry
				endif
			else
				" write a default local template file
				call writefile( template, s:RUBY_LocalTemplateFile )
			endif
		endif
		"
	else
		"-------------------------------------------------------------------------------
		" local installation
		"-------------------------------------------------------------------------------
		if filereadable( s:RUBY_LocalTemplateFile )
			call RUBY_ReadTemplates( s:RUBY_LocalTemplateFile )
			let	messsage	= "Templates read from '".s:RUBY_LocalTemplateFile."'"
		else
			echomsg "Local template file '".s:RUBY_LocalTemplateFile."' not readable." 
			return
		endif
		"
	endif
	if a:displaymsg == 'yes'
		echomsg messsage.'.'
	endif

endfunction    " ----------  end of function RUBY_RereadTemplates  ----------
"
"------------------------------------------------------------------------------
"  RUBY_BrowseTemplateFiles     {{{1
"------------------------------------------------------------------------------
function! RUBY_BrowseTemplateFiles ( type )
	let	templatefile	= eval( 's:RUBY_'.a:type.'TemplateFile' )
	let	templatedir		= eval('s:RUBY_'.a:type.'TemplateDir')
	if isdirectory( templatedir )
		if has("browse") && s:RUBY_GuiTemplateBrowser == 'gui'
			let	l:templatefile	= browse(0,"edit a template file", templatedir, "" )
		else
				let	l:templatefile	= ''
			if s:RUBY_GuiTemplateBrowser == 'explorer'
				exe ':Explore '.templatedir
			endif
			if s:RUBY_GuiTemplateBrowser == 'commandline'
				let	l:templatefile	= input("edit a template file", templatedir, "file" )
			endif
		endif
		if l:templatefile != ""
			:execute "update! | split | edit ".l:templatefile
		endif
	else
		echomsg a:type." template directory '".templatedir."' does not exist."
	endif
endfunction    " ----------  end of function RUBY_BrowseTemplateFiles  ----------
"
"------------------------------------------------------------------------------
"  RUBY_ReadTemplates     {{{1
"  read the template file(s), build the macro and the template dictionary
"
"------------------------------------------------------------------------------
let	s:style			= 'default'
function! RUBY_ReadTemplates ( templatefile )

  if !filereadable( a:templatefile )
    echohl WarningMsg
    echomsg "Ruby Support template file '".a:templatefile."' does not exist or is not readable"
    echohl None
    return
  endif

	let	skipmacros	= 0
  let s:RUBY_FileVisited  += [a:templatefile]

  "------------------------------------------------------------------------------
  "  read template file, start with an empty template dictionary
  "------------------------------------------------------------------------------

  let item  		= ''
	let	skipline	= 0
  for line in readfile( a:templatefile )
		" if not a comment :
    if line !~ s:RUBY_MacroCommentRegex
      "
			"-------------------------------------------------------------------------------
			" IF |STYLE| IS ...
			"-------------------------------------------------------------------------------
      "
      let string  = matchlist( line, s:RUBY_TemplateIf )
      if !empty(string) 
				if !has_key( s:RUBY_Template, string[1] )
					" new s:style
					let	s:style	= string[1]
					let	s:RUBY_Template[s:style]	= {}
					continue
				endif
			endif
			"
			"-------------------------------------------------------------------------------
			" ENDIF
			"-------------------------------------------------------------------------------
      "
      let string  = matchlist( line, s:RUBY_TemplateEndif )
      if !empty(string)
				let	s:style	= 'default'
				continue
			endif
      "
			"-------------------------------------------------------------------------------
      " macros and file includes
			"-------------------------------------------------------------------------------
      "
      let string  = matchlist( line, s:RUBY_MacroLineRegex )
      if !empty(string) && skipmacros == 0
        let key = '|'.string[1].'|'
        let val = string[2]
        let val = substitute( val, '\s\+$', '', '' )
        let val = substitute( val, "[\"\']$", '', '' )
        let val = substitute( val, "^[\"\']", '', '' )
        "
        if key == '|includefile|' && count( s:RUBY_FileVisited, val ) == 0
					let path   = fnamemodify( a:templatefile, ":p:h" )
          call RUBY_ReadTemplates( path.'/'.val )    " recursive call
        else
          let s:RUBY_Macro[key] = escape( val, '&' )
        endif
        continue                                     " next line
      endif
      "
      " template header
      "
      let name  = matchstr( line, s:RUBY_TemplateLineRegex )
      "
      if !empty(name)
				" start with a new template
        let part  = split( name, '\s*==\s*')
        let item  = part[0]
        if has_key( s:RUBY_Template[s:style], item ) && s:RUBY_TemplateOverriddenMsg == 'yes'
          echomsg "style '".s:style."' / existing Ruby Support template '".item."' overridden"
        endif
        let s:RUBY_Template[s:style][item] = ''
				let skipmacros	= 1
        "
        let s:RUBY_Attribute[item] = 'below'
        if has_key( s:Attribute, get( part, 1, 'NONE' ) )
          let s:RUBY_Attribute[item] = part[1]
        endif
      else
				" add to a template 
        if !empty(item)
          let s:RUBY_Template[s:style][item] .= line."\n"
        endif
      endif
    endif
  endfor " ----- readfile -----
	let s:RUBY_ActualStyle	= 'default'
	if !empty( s:RUBY_Macro['|STYLE|'] )
		let s:RUBY_ActualStyle	= s:RUBY_Macro['|STYLE|']
	endif
	let s:RUBY_ActualStyleLast	= s:RUBY_ActualStyle
endfunction    " ----------  end of function RUBY_ReadTemplates  ----------

"------------------------------------------------------------------------------
" RUBY_Style{{{1
" ex-command RubyStyle : callback function
"------------------------------------------------------------------------------
function! RUBY_Style ( style )
	let lstyle  = substitute( a:style, '^\s\+', "", "" )	" remove leading whitespaces
	let lstyle  = substitute( lstyle, '\s\+$', "", "" )		" remove trailing whitespaces
	if has_key( s:RUBY_Template, lstyle )
		if len( s:RUBY_Template[lstyle] ) == 0
			echomsg "style '".lstyle."' : no templates defined"
			return
		endif
		let s:RUBY_ActualStyleLast	= s:RUBY_ActualStyle
		let s:RUBY_ActualStyle	= lstyle
		if len( s:RUBY_ActualStyle ) > 1 && s:RUBY_ActualStyle != s:RUBY_ActualStyleLast
			echomsg "template style is '".lstyle."'"
		endif
	else
		echomsg "style '".lstyle."' does not exist"
	endif
endfunction    " ----------  end of function RUBY_Style  ----------

"------------------------------------------------------------------------------
" RUBY_StyleList     {{{1
" ex-command RubyStyle
"------------------------------------------------------------------------------
function!	RUBY_StyleList ( ArgLead, CmdLine, CursorPos )
	" show all types / types beginning with a:ArgLead
	return filter( copy(keys(s:RUBY_Template)), 'v:val =~ "\\<'.a:ArgLead.'\\w*"' )
endfunction    " ----------  end of function RUBY_StyleList  ----------

"------------------------------------------------------------------------------
" RUBY_OpenFold     {{{1
" Open fold and go to the first or last line of this fold.
"------------------------------------------------------------------------------
function! RUBY_OpenFold ( mode )
	if foldclosed(".") >= 0
		" we are on a closed  fold: get end position, open fold, jump to the
		" last line of the previously closed fold
		let	foldstart	= foldclosed(".")
		let	foldend		= foldclosedend(".")
		normal zv
		if a:mode == 'below'
			exe ":".foldend
		endif
		if a:mode == 'start'
			exe ":".foldstart
		endif
	endif
endfunction    " ----------  end of function RUBY_OpenFold  ----------

"------------------------------------------------------------------------------
"  RUBY_InsertTemplate     {{{1
"  insert a template from the template dictionary
"  do macro expansion
"------------------------------------------------------------------------------
function! RUBY_InsertTemplate ( key, ... )


	if s:RUBY_TemplatesLoaded == 'no'
		call RUBY_RereadTemplates('no')        
		let s:RUBY_TemplatesLoaded	= 'yes'
	endif

	if !has_key( s:RUBY_Template[s:RUBY_ActualStyle], a:key ) &&
	\  !has_key( s:RUBY_Template['default'], a:key )
		echomsg "style '".a:key."' / template '".a:key
	\        ."' not found. Please check your template file in '".s:RUBY_GlobalTemplateDir."'"
		return
	endif

	if &foldenable
		let	foldmethod_save	= &foldmethod
		set foldmethod=manual
	endif
  "------------------------------------------------------------------------------
  "  insert the user macros
  "------------------------------------------------------------------------------

	" use internal formatting to avoid conficts when using == below
	"
	call RUBY_SaveOption( 'equalprg' )
	set equalprg=

  let mode  = s:RUBY_Attribute[a:key]

	" remove <SPLIT> and insert the complete macro
	"
	if a:0 == 0
		let val = RUBY_ExpandUserMacros (a:key)
		if empty(val)
			return
		endif
		let val	= RUBY_ExpandSingleMacro( val, '<SPLIT>', '' )

		if mode == 'below'
			call RUBY_OpenFold('below')
			let pos1  = line(".")+1
			put  =val
			let pos2  = line(".")
			" proper indenting
			exe ":".pos1
			let ins	= pos2-pos1+1
			exe "normal ".ins."=="
			"
		elseif mode == 'above'
			let pos1  = line(".")
			put! =val
			let pos2  = line(".")
			" proper indenting
			exe ":".pos1
			let ins	= pos2-pos1+1
			exe "normal ".ins."=="
			"
		elseif mode == 'start'
			normal gg
			call RUBY_OpenFold('start')
			let pos1  = 1
			put! =val
			let pos2  = line(".")
			" proper indenting
			exe ":".pos1
			let ins	= pos2-pos1+1
			exe "normal ".ins."=="
			"
		elseif mode == 'append'
			if &foldenable && foldclosed(".") >= 0
				echohl WarningMsg | echomsg s:MsgInsNotAvail  | echohl None
				exe "set foldmethod=".foldmethod_save
				return
			else
				let pos1  = line(".")
				put =val
				let pos2  = line(".")-1
				exe ":".pos1
				:join!
			endif
			"
		elseif mode == 'insert'
			if &foldenable && foldclosed(".") >= 0
				echohl WarningMsg | echomsg s:MsgInsNotAvail  | echohl None
				exe "set foldmethod=".foldmethod_save
				return
			else
				let val   = substitute( val, '\n$', '', '' )
				let currentline	= getline( "." )
				let pos1  = line(".")
				let pos2  = pos1 + count( split(val,'\zs'), "\n" )
				" assign to the unnamed register "" :
				let @"=val
				normal p
				" reformat only multiline inserts and previously empty lines
				if pos2-pos1 > 0 || currentline =~ ''
					exe ":".pos1
					let ins	= pos2-pos1+1
					exe "normal ".ins."=="
				endif
			endif
			"
		endif
		"
	else
		"
		" =====  visual mode  ===============================
		"
		if  a:1 == 'v'
			let val = RUBY_ExpandUserMacros (a:key)
			let val	= RUBY_ExpandSingleMacro( val, s:RUBY_TemplateJumpTarget2, '' )
			if empty(val)
				return
			endif

			if match( val, '<SPLIT>\s*\n' ) >= 0
				let part	= split( val, '<SPLIT>\s*\n' )
			else
				let part	= split( val, '<SPLIT>' )
			endif

			if len(part) < 2
				let part	= [ "" ] + part
				echomsg '<SPLIT> missing in template '.a:key
			endif
			"
			" 'visual' and mode 'insert':
			"   <part0><marked area><part1>
			" part0 and part1 can consist of several lines
			"
			if mode == 'insert'
				let pos1  = line(".")
				let pos2  = pos1
				let	string= @*
				let replacement	= part[0].string.part[1]
				" remove trailing '\n'
				let replacement   = substitute( replacement, '\n$', '', '' )
				exe ':s/'.string.'/'.replacement.'/'
			endif
			"
			" 'visual' and mode 'below':
			"   <part0>
			"   <marked area>
			"   <part1>
			" part0 and part1 can consist of several lines
			"
			if mode == 'below'

				:'<put! =part[0]
				:'>put  =part[1]

				let pos1  = line("'<") - len(split(part[0], '\n' ))
				let pos2  = line("'>") + len(split(part[1], '\n' ))
				""			echo part[0] part[1] pos1 pos2
				"			" proper indenting
				exe ":".pos1
				let ins	= pos2-pos1+1
				exe "normal ".ins."=="
			endif
			"
		endif		" ---------- end visual mode
	endif

	" restore formatter programm
	call RUBY_RestoreOption( 'equalprg' )

  "------------------------------------------------------------------------------
  "  position the cursor
  "------------------------------------------------------------------------------
  exe ":".pos1
  let mtch = search( '<CURSOR>', 'c', pos2 )
	if mtch != 0
		let line	= getline(mtch)
		if line =~ '<CURSOR>$'
			call setline( mtch, substitute( line, '<CURSOR>', '', '' ) )
			if  a:0 != 0 && a:1 == 'v' && getline(".") =~ '^\s*$'
				normal J
			else
				:startinsert!
			endif
		else
			call setline( mtch, substitute( line, '<CURSOR>', '', '' ) )
			:startinsert
		endif
	else
		" to the end of the block; needed for repeated inserts
		if mode == 'below'
			exe ":".pos2
		endif
  endif

  "------------------------------------------------------------------------------
  "  marked words
  "------------------------------------------------------------------------------
	" define a pattern to highlight
	call RUBY_HighlightJumpTargets ()

	if &foldenable
		" restore folding method
		exe "set foldmethod=".foldmethod_save
		normal zv
	endif

endfunction    " ----------  end of function RUBY_InsertTemplate  ----------
"
"------------------------------------------------------------------------------
"  RUBY_Input : Input after a highlighted prompt    {{{1
"------------------------------------------------------------------------------
function! RUBY_Input ( promp, text, ... )
	echohl Search																					" highlight prompt
	call inputsave()																			" preserve typeahead
	if a:0 == 0 || empty(a:1)
		let retval	=input( a:promp, a:text )
	else
		let retval	=input( a:promp, a:text, a:1 )
	endif
	call inputrestore()																		" restore typeahead
	echohl None																						" reset highlighting
	let retval  = substitute( retval, '^\s\+', "", "" )		" remove leading whitespaces
	let retval  = substitute( retval, '\s\+$', "", "" )		" remove trailing whitespaces
	return retval
endfunction    " ----------  end of function RUBY_Input ----------
"
"------------------------------------------------------------------------------
"  RUBY_AdjustLineEndComm: adjust line-end comments      {{{1
"------------------------------------------------------------------------------
"
" patterns to ignore when adjusting line-end comments (incomplete):
let	s:AlignRegex	= [
	\	'\${\?#' ,
	\	'\${[^#]\+##\?.\+}' ,
	\	'"[^"]*"' ,
	\	"'[^']*'" ,
	\	"`[^`]*`" ,
	\	]

function! RUBY_AdjustLineEndComm ( ) range
	"
	if !exists("b:RUBY_LineEndCommentColumn")
		let	b:RUBY_LineEndCommentColumn	= s:RUBY_LineEndCommColDefault
	endif

	let save_cursor = getpos(".")

	let	save_expandtab	= &expandtab
	exe	":set expandtab"

	let	linenumber	= a:firstline
	exe ":".a:firstline

	while linenumber <= a:lastline
		let	line= getline(".")

		let idx1	= 1 + match( line, '\s*#.*$', 0 )
		let idx2	= 1 + match( line,    '#.*$', 0 )

		" comment with leading whitespaces left unchanged
		if     match( line, '^\s*#' ) == 0
			let idx1	= 0
			let idx2	= 0
		endif

		for regex in s:AlignRegex
			if match( line, regex ) > -1
				let start	= matchend( line, regex )
				let idx1	= 1 + match( line, '\s*#.*$', start )
				let idx2	= 1 + match( line,    '#.*$', start )
				break
			endif
		endfor

		let	ln	= line(".")
		call setpos(".", [ 0, ln, idx1, 0 ] )
		let vpos1	= virtcol(".")
		call setpos(".", [ 0, ln, idx2, 0 ] )
		let vpos2	= virtcol(".")

		if   ! (   vpos2 == b:RUBY_LineEndCommentColumn
					\	|| vpos1 > b:RUBY_LineEndCommentColumn
					\	|| idx2  == 0 )

			exe ":.,.retab"
			" insert some spaces
			if vpos2 < b:RUBY_LineEndCommentColumn
				let	diff	= b:RUBY_LineEndCommentColumn-vpos2
				call setpos(".", [ 0, ln, vpos2, 0 ] )
				let	@"	= ' '
				exe "normal	".diff."P"
			end

			" remove some spaces
			if vpos1 < b:RUBY_LineEndCommentColumn && vpos2 > b:RUBY_LineEndCommentColumn
				let	diff	= vpos2 - b:RUBY_LineEndCommentColumn
				call setpos(".", [ 0, ln, b:RUBY_LineEndCommentColumn, 0 ] )
				exe "normal	".diff."x"
			end

		end
		let linenumber=linenumber+1
		normal j
	endwhile
	" restore tab expansion settings and cursor position
	let &expandtab	= save_expandtab
	call setpos('.', save_cursor)

endfunction		" ---------- end of function  RUBY_AdjustLineEndComm  ----------
"
"------------------------------------------------------------------------------
"  Comments : get line-end comment position    {{{1
"------------------------------------------------------------------------------
function! RUBY_GetLineEndCommCol ()
	let actcol	= virtcol(".")
	if actcol+1 == virtcol("$")
		let	b:RUBY_LineEndCommentColumn	= ''
		while match( b:RUBY_LineEndCommentColumn, '^\s*\d\+\s*$' ) < 0
			let b:RUBY_LineEndCommentColumn = RUBY_Input( 'start line-end comment at virtual column : ', actcol, '' )
		endwhile
	else
		let	b:RUBY_LineEndCommentColumn	= virtcol(".")
	endif
  echomsg "line end comments will start at column  ".b:RUBY_LineEndCommentColumn
endfunction		" ---------- end of function  RUBY_GetLineEndCommCol  ----------
"
"------------------------------------------------------------------------------
"  Comments : single line-end comment    {{{1
"------------------------------------------------------------------------------
function! RUBY_EndOfLineComment ( ) range
	if !exists("b:RUBY_LineEndCommentColumn")
		let	b:RUBY_LineEndCommentColumn	= s:RUBY_LineEndCommColDefault
	endif
	" ----- trim whitespaces -----
	exe a:firstline.','.a:lastline.'s/\s*$//'

	for line in range( a:lastline, a:firstline, -1 )
		let linelength	= virtcol( [line, "$"] ) - 1
		let	diff				= 1
		if linelength < b:RUBY_LineEndCommentColumn
			let diff	= b:RUBY_LineEndCommentColumn -1 -linelength
		endif
		exe "normal	".diff."A "
		call RUBY_InsertTemplate('comment.end-of-line-comment')
		if line > a:firstline
			normal k
		endif
	endfor
endfunction		" ---------- end of function  RUBY_EndOfLineComment  ----------
"
"------------------------------------------------------------------------------
"  Comments : put statement in an echo    {{{1
"------------------------------------------------------------------------------
function! RUBY_echo_comment ()
	let	line	= escape( getline("."), '"' )
	let	line	= substitute( line, '^\s*', '', '' )
	call setline( line("."), 'echo "'.line.'"' )
	silent exe "normal =="
	return
endfunction    " ----------  end of function RUBY_echo_comment  ----------
"
"------------------------------------------------------------------------------
"  Comments : remove echo from statement  {{{1
"------------------------------------------------------------------------------
function! RUBY_remove_echo ()
	let	line	= substitute( getline("."), '\\"', '"', 'g' )
	let	line	= substitute( line, '^\s*echo\s\+"', '', '' )
	let	line	= substitute( line, '"$', '', '' )
	call setline( line("."), line )
	silent exe "normal =="
	return
endfunction    " ----------  end of function RUBY_remove_echo  ----------
"
"------------------------------------------------------------------------------
"  Comments : multi line-end comments    {{{1
"------------------------------------------------------------------------------
function! RUBY_MultiLineEndComments ( )
	"
  if !exists("b:RUBY_LineEndCommentColumn")
		let	b:RUBY_LineEndCommentColumn	= s:RUBY_LineEndCommColDefault
  endif
	"
	let pos0	= line("'<")
	let pos1	= line("'>")
	"
	" ----- trim whitespaces -----
  exe pos0.','.pos1.'s/\s*$//'
	"
	" ----- find the longest line -----
	let maxlength	= max( map( range(pos0, pos1), "virtcol([v:val, '$'])" ) )
	let	maxlength	= max( [b:RUBY_LineEndCommentColumn, maxlength+1] )
	"
	" ----- fill lines with blanks -----
	for linenumber in range( pos0, pos1 )
		exe ":".linenumber
		if getline(linenumber) !~ '^\s*$'
			let diff	= maxlength - virtcol("$")
			exe "normal	".diff."A "
			call RUBY_InsertTemplate('comment.end-of-line-comment')
		endif
	endfor
	"
	" ----- back to the begin of the marked block -----
	stopinsert
	normal '<$
	if match( getline("."), '\/\/\s*$' ) < 0
		if search( '\/\*', 'bcW', line(".") ) > 1
			normal l
		endif
		let save_cursor = getpos(".")
		if getline(".")[save_cursor[2]+1] == ' '
			normal l
		endif
	else
		normal $
	endif
endfunction		" ---------- end of function  RUBY_MultiLineEndComments  ----------
"
"------------------------------------------------------------------------------
"  Comments : toggle comments (range)   {{{1
"------------------------------------------------------------------------------
function! RUBY_CommentToggle () range
	let	comment=1									" 
	for line in range( a:firstline, a:lastline )
		if match( getline(line), '^#') == -1					" no comment 
			let comment = 0
			break
		endif
	endfor

	if comment == 0
			exe a:firstline.','.a:lastline."s/^/#/"
	else
			exe a:firstline.','.a:lastline."s/^#//"
	endif

endfunction    " ----------  end of function RUBY_CommentToggle ----------
"
"------------------------------------------------------------------------------
"  Comments : Substitute tags    {{{1
"------------------------------------------------------------------------------
function! RUBY_SubstituteTag( pos1, pos2, tag, replacement )
	"
	" loop over marked block
	"
	let	linenumber=a:pos1
	while linenumber <= a:pos2
		let line=getline(linenumber)
		"
		" loop for multiple tags in one line
		"
		let	start=0
		while match(line,a:tag,start)>=0				" do we have a tag ?
			let frst=match(line,a:tag,start)
			let last=matchend(line,a:tag,start)
			if frst!=-1
				let part1=strpart(line,0,frst)
				let part2=strpart(line,last)
				let line=part1.a:replacement.part2
				"
				" next search starts after the replacement to suppress recursion
				"
				let start=strlen(part1)+strlen(a:replacement)
			endif
		endwhile
		call setline( linenumber, line )
		let	linenumber=linenumber+1
	endwhile

endfunction    " ----------  end of function  Ruby_SubstituteTag  ----------
"
"------------------------------------------------------------------------------
"  Comments : vim modeline    {{{1
"------------------------------------------------------------------------------
function! RUBY_CommentVimModeline ()
  	put = '# vim: set tabstop='.&tabstop.' shiftwidth='.&shiftwidth.': '
endfunction    " ----------  end of function RUBY_CommentVimModeline  ----------
"
"------------------------------------------------------------------------------
"  RUBY_BuiltinComplete : builtin completion    {{{1
"------------------------------------------------------------------------------
function!	RUBY_BuiltinComplete ( ArgLead, CmdLine, CursorPos )
	"
	" show all builtins
	"
	if empty(a:ArgLead)
		return s:RUBY_Builtins
	endif
	"
	" show builtins beginning with a:ArgLead
	"
	let	expansions	= []
	for item in s:RUBY_Builtins
		if match( item, '\<'.a:ArgLead.'\w*' ) == 0
			call add( expansions, item )
		endif
	endfor
	return	expansions
endfun
"
"-------------------------------------------------------------------------------
"   Comment : Script Sections             {{{1
"-------------------------------------------------------------------------------
let s:ScriptSection	= { 
	\ "GLOBALS"          : "file-sections-globals"    , 
	\ "CMD\.LINE"				 : "file-sections-cmdline"    , 
	\ "SAN\.CHECKS"		   : "file-sections-sanchecks"  , 
	\ "FUNCT\.DEF\."		 : "file-sections-functdef"   , 
	\ "TRAPS"        		 : "file-sections-traps"      , 
	\ "MAIN\ SCRIPT"		 : "file-sections-mainscript" , 
	\ "STAT+CLEANUP"		 : "file-sections-statistics" , 
	\ }

function!	RUBY_ScriptSectionList ( ArgLead, CmdLine, CursorPos )
	return filter( copy( sort(keys( s:ScriptSection)) ), 'v:val =~ "\\<'.a:ArgLead.'\\w*"' )
endfunction    " ----------  end of function RUBY_ScriptSectionList  ----------

function! RUBY_ScriptSectionListInsert ( arg )
	if has_key( s:ScriptSection, a:arg )
		call RUBY_InsertTemplate( 'comment.'.s:ScriptSection[a:arg] )
	else
		echomsg "entry '".a:arg."' does not exist"
	endif
endfunction    " ----------  end of function RUBY_ScriptSectionListInsert  ----------
"
"-------------------------------------------------------------------------------
"   Comment : Keyword Comments             {{{1
"-------------------------------------------------------------------------------
let s:KeywordComment	= { 
	\	'BUG'          : 'keyword-bug',
	\	'TODO'         : 'keyword-todo',
	\	'TRICKY'       : 'keyword-tricky',
	\	'WARNING'      : 'keyword-warning',
	\	'WORKAROUND'   : 'keyword-workaround',
	\	'new\ keyword' : 'keyword-keyword',
	\ }

function!	RUBY_KeywordCommentList ( ArgLead, CmdLine, CursorPos )
	return filter( copy( sort(keys( s:KeywordComment)) ), 'v:val =~ "\\<'.a:ArgLead.'\\w*"' )
endfunction    " ----------  end of function RUBY_KeywordCommentList  ----------

function! RUBY_KeywordCommentListInsert ( arg )
	if has_key( s:KeywordComment, a:arg )
		call RUBY_InsertTemplate( 'comment.'.s:KeywordComment[a:arg] )
	else
		echomsg "entry '".a:arg."' does not exist"
	endif
endfunction    " ----------  end of function RUBY_KeywordCommentListInsert  ----------
"
"------------------------------------------------------------------------------
"  RUBY_help : lookup word under the cursor or ask    {{{1
"------------------------------------------------------------------------------
let s:RUBY_DocBufferName       = "RUBY_HELP"
let s:RUBY_DocHelpBufferNumber = -1
"
function! RUBY_help( type )

	let cuc		= getline(".")[col(".") - 1]		" character under the cursor
	let	item	= expand("<cword>")							" word under the cursor
	if empty(item) || match( item, cuc ) == -1
		if a:type == 'm'
			let	item=RUBY_Input('[tab compl. on] name of command line utility : ', '', 'shellcmd' )
		endif
		if a:type == 'h'
			let	item=RUBY_Input('[tab compl. on] name of ruby builtin : ', '', 'customlist,RUBY_BuiltinComplete' )
		endif
	endif

	if empty(item) &&  a:type != 'b'
		return
	endif
	"------------------------------------------------------------------------------
	"  replace buffer content with ruby help text
	"------------------------------------------------------------------------------
	"
	" jump to an already open ruby help window or create one
	"
	if bufloaded(s:RUBY_DocBufferName) != 0 && bufwinnr(s:RUBY_DocHelpBufferNumber) != -1
		exe bufwinnr(s:RUBY_DocHelpBufferNumber) . "wincmd w"
		" buffer number may have changed, e.g. after a 'save as'
		if bufnr("%") != s:RUBY_DocHelpBufferNumber
			let s:RUBY_DocHelpBufferNumber=bufnr(s:RUBY_OutputBufferName)
			exe ":bn ".s:RUBY_DocHelpBufferNumber
		endif
	else
		exe ":new ".s:RUBY_DocBufferName
		let s:RUBY_DocHelpBufferNumber=bufnr("%")
		setlocal buftype=nofile
		setlocal noswapfile
		setlocal bufhidden=delete
		setlocal filetype=ruby		" allows repeated use of <S-F1>
		setlocal syntax=OFF
	endif
	setlocal	modifiable
	"
	"-------------------------------------------------------------------------------
	" read Ruby help
	"-------------------------------------------------------------------------------
	if a:type == 'h'
		silent exe ":%!help  ".item
	endif
	"
	"-------------------------------------------------------------------------------
	" open a manual (utilities)
	"-------------------------------------------------------------------------------
	if a:type == 'm' 
		"
		" Is there more than one manual ?
		"
		let manpages	= system( s:RUBY_Man.' -k '.item )
		if v:shell_error
			echomsg	"shell command '".s:RUBY_Man." -k ".item."' failed"
			:close
			return
		endif
		let	catalogs	= split( manpages, '\n', )
		let	manual		= {}
		"
		" Select manuals where the name exactly matches
		"
		for line in catalogs
			if line =~ '^'.item.'\s\+(' 
				let	itempart	= split( line, '\s\+' )
				let	catalog		= itempart[1][1:-2]
				let	manual[catalog]	= catalog
			endif
		endfor
		"
		" Build a selection list if there are more than one manual
		"
		let	catalog	= ""
		if len(keys(manual)) > 1
			for key in keys(manual)
				echo ' '.item.'  '.key
			endfor
			let defaultcatalog	= ''
			if has_key( manual, '1' )
				let defaultcatalog	= '1'
			else
				if has_key( manual, '8' )
					let defaultcatalog	= '8'
				endif
			endif
			let	catalog	= input( 'select manual section (<Enter> cancels) : ', defaultcatalog )
			if ! has_key( manual, catalog )
				:close
				:redraw
				echomsg	"no appropriate manual section '".catalog."'"
				return
			endif
		endif

		set filetype=man
		silent exe ":%!".s:RUBY_Man.' '.catalog.' '.item

		if s:MSWIN
			call s:ruby_RemoveSpecialCharacters()
		endif

	endif
	"
	"-------------------------------------------------------------------------------
	" open the ruby manual
	"-------------------------------------------------------------------------------
	if a:type == 'b'
		silent exe ":%!man 1 ruby"

		if s:MSWIN
			call s:ruby_RemoveSpecialCharacters()
		endif

		if !empty(item)
				" assign to the search pattern register "" :
				let @/=item
				echo "use n/N to search for '".item."'"
		endif
	endif

	setlocal nomodifiable
endfunction		" ---------- end of function  RUBY_help  ----------
"
"------------------------------------------------------------------------------
"  remove <backspace><any character> in CYGWIN man(1) output   {{{1
"  remove           _<any character> in CYGWIN man(1) output   {{{1
"------------------------------------------------------------------------------
"
function! s:ruby_RemoveSpecialCharacters ( )
	let	patternunderline	= '_\%x08'
	let	patternbold				= '\%x08.'
	setlocal modifiable
	if search(patternunderline) != 0
		silent exe ':%s/'.patternunderline.'//g'
	endif
	if search(patternbold) != 0
		silent exe ':%s/'.patternbold.'//g'
	endif
	setlocal nomodifiable
	silent normal gg
endfunction		" ---------- end of function  s:ruby_RemoveSpecialCharacters   ----------
"
"------------------------------------------------------------------------------
"  Run : Syntax Check, check if local options does exist    {{{1
"------------------------------------------------------------------------------
"
function! s:ruby_find_option ( list, option )
	for item in a:list
		if item == a:option
			return 0
		endif
	endfor
	return -1
endfunction    " ----------  end of function s:ruby_find_option  ----------
"
function! RUBY_SyntaxCheckOptions( options )
	let startpos=0
	while startpos < strlen( a:options )
		" match option switch ' -O ' or ' +O '
		let startpos		= matchend ( a:options, '\s*[+-]O\s\+', startpos )
		" match option name
		let optionname	= matchstr ( a:options, '\h\w*\s*', startpos )
		" remove trailing whitespaces
		let optionname  = substitute ( optionname, '\s\+$', "", "" )
		" check name
		let found				= s:ruby_find_option ( s:RubyShopt, optionname )
		if found < 0
			redraw
			echohl WarningMsg | echo ' no such shopt name :  "'.optionname.'"  ' | echohl None
			return 1
		endif
		" increment start position for next search
		let startpos		=  matchend  ( a:options, '\h\w*\s*', startpos )
	endwhile
	return 0
endfunction		" ---------- end of function  RUBY_SyntaxCheckOptions----------
"
"------------------------------------------------------------------------------
"  Run : Syntax Check, local options    {{{1
"------------------------------------------------------------------------------
"
function! RUBY_SyntaxCheckOptionsLocal ()
	let filename = expand("%")
  if empty(filename)
		redraw
		echohl WarningMsg | echo " no file name or not a shell file " | echohl None
		return
  endif
	let	prompt	= 'syntax check options for "'.filename.'" : '

	if exists("b:RUBY_SyntaxCheckOptionsLocal")
		let	b:RUBY_SyntaxCheckOptionsLocal= RUBY_Input( prompt, b:RUBY_SyntaxCheckOptionsLocal, '' )
	else
		let	b:RUBY_SyntaxCheckOptionsLocal= RUBY_Input( prompt , "", '' )
	endif

	if RUBY_SyntaxCheckOptions( b:RUBY_SyntaxCheckOptionsLocal ) != 0
		let b:RUBY_SyntaxCheckOptionsLocal	= ""
	endif
endfunction		" ---------- end of function  RUBY_SyntaxCheckOptionsLocal  ----------
"
"------------------------------------------------------------------------------
"  Run : syntax check    {{{1
"------------------------------------------------------------------------------
function! RUBY_SyntaxCheck ()
	exe	":cclose"
	let	l:currentbuffer=bufname("%")
	exe	":update"
	call RUBY_SaveOption( 'makeprg' )
	exe	":setlocal makeprg=".s:RUBY_BASH
	let l:fullname				= expand("%:p")
	"
	" check global syntax check options / reset in case of an error
	if RUBY_SyntaxCheckOptions( s:RUBY_SyntaxCheckOptionsGlob ) != 0
		let s:RUBY_SyntaxCheckOptionsGlob	= ""
	endif
	"
	let	options=s:RUBY_SyntaxCheckOptionsGlob
	if exists("b:RUBY_SyntaxCheckOptionsLocal")
		let	options=options." ".b:RUBY_SyntaxCheckOptionsLocal
	endif
	"
	" match the Ruby error messages (quickfix commands)
	" errorformat will be reset by function RUBY_Handle()
	" ignore any lines that didn't match one of the patterns
	"
	exe	':setlocal errorformat='.s:RUBY_Errorformat
	silent exe ":make -n ".options.' -- "'.l:fullname.'"'
	exe	":botright cwindow"
	exe	':setlocal errorformat='
	call RUBY_RestoreOption('makeprg')
	"
	" message in case of success
	"
	redraw!
	if l:currentbuffer ==  bufname("%")
		echohl Search | echo l:currentbuffer." : Syntax is OK" | echohl None
		nohlsearch						" delete unwanted highlighting (Vim bug?)
	endif
endfunction		" ---------- end of function  RUBY_SyntaxCheck  ----------
"
"------------------------------------------------------------------------------
"  Run : debugger    {{{1
"------------------------------------------------------------------------------
function! RUBY_Debugger ()
	if !executable(s:RUBY_rubydb)
		echohl Search
		echo   s:RUBY_rubydb' is not executable or not installed! '
		echohl None
		return
	endif
	"
	silent exe	":update"
	let	l:arguments	= exists("b:RUBY_ScriptCmdLineArgs") ? " ".b:RUBY_ScriptCmdLineArgs : ""
	let	Sou					= fnameescape( expand("%:p") )
	"
	"
	if has("gui_running") || &term == "xterm"
		"
		" debugger is ' rubydb'
		"
		if s:RUBY_Debugger == "term"
			let dbcommand	= "!xterm ".s:RUBY_XtermDefaults.' -e '.s:RUBY_rubydb.' -- '.Sou.l:arguments.' &'
			silent exe dbcommand
		endif
		"
		" debugger is 'ddd'
		"
		if s:RUBY_Debugger == "ddd"
			if !executable("ddd")
				echohl WarningMsg
				echo "The debugger 'ddd' does not exist or is not executable!"
				echohl None
				return
			else
				silent exe '!ddd --debugger '.s:RUBY_rubydb.' '.Sou.l:arguments.' &'
			endif
		endif
	else
		" no GUI : debugger is ' rubydb'
		silent exe '!'.s:RUBY_rubydb.' -- '.Sou.l:arguments
	endif
endfunction		" ---------- end of function  RUBY_Debugger  ----------
"
"----------------------------------------------------------------------
"  Run : toggle output destination (Linux/Unix)    {{{1
"----------------------------------------------------------------------
function! RUBY_Toggle_Gvim_Xterm ()

	if has("gui_running")
		if s:RUBY_OutputGvim == "vim"
			exe "aunmenu  <silent>  ".s:RUBY_Root.'&Run.&output:\ VIM->buffer->xterm'
			exe " menu    <silent>  ".s:RUBY_Root.'&Run.&output:\ BUFFER->xterm->vim<Tab>\\ro          :call RUBY_Toggle_Gvim_Xterm()<CR>'
			exe "imenu    <silent>  ".s:RUBY_Root.'&Run.&output:\ BUFFER->xterm->vim<Tab>\\ro     <C-C>:call RUBY_Toggle_Gvim_Xterm()<CR>'
			let	s:RUBY_OutputGvim	= "buffer"
		else
			if s:RUBY_OutputGvim == "buffer"
				exe "aunmenu  <silent>  ".s:RUBY_Root.'&Run.&output:\ BUFFER->xterm->vim'
				exe " menu    <silent>  ".s:RUBY_Root.'&Run.&output:\ XTERM->vim->buffer<Tab>\\ro        :call RUBY_Toggle_Gvim_Xterm()<CR>'
				exe "imenu    <silent>  ".s:RUBY_Root.'&Run.&output:\ XTERM->vim->buffer<Tab>\\ro   <C-C>:call RUBY_Toggle_Gvim_Xterm()<CR>'
				let	s:RUBY_OutputGvim	= "xterm"
			else
				" ---------- output : xterm -> gvim
				exe "aunmenu  <silent>  ".s:RUBY_Root.'&Run.&output:\ XTERM->vim->buffer'
				exe " menu    <silent>  ".s:RUBY_Root.'&Run.&output:\ VIM->buffer->xterm<Tab>\\ro        :call RUBY_Toggle_Gvim_Xterm()<CR>'
				exe "imenu    <silent>  ".s:RUBY_Root.'&Run.&output:\ VIM->buffer->xterm<Tab>\\ro   <C-C>:call RUBY_Toggle_Gvim_Xterm()<CR>'
				let	s:RUBY_OutputGvim	= "vim"
			endif
		endif
	else
		if s:RUBY_OutputGvim == "vim"
			let	s:RUBY_OutputGvim	= "buffer"
		else
			let	s:RUBY_OutputGvim	= "vim"
		endif
	endif
	echomsg "output destination is '".s:RUBY_OutputGvim."'"

endfunction    " ----------  end of function RUBY_Toggle_Gvim_Xterm ----------
"
"----------------------------------------------------------------------
"  Run : toggle output destination (Windows)    {{{1
"----------------------------------------------------------------------
function! RUBY_Toggle_Gvim_Xterm_MS ()
	if has("gui_running")
		if s:RUBY_OutputGvim == "buffer"
			exe "aunmenu  <silent>  ".s:RUBY_Root.'&Run.&output:\ BUFFER->term'
			exe " menu    <silent>  ".s:RUBY_Root.'&Run.&output:\ TERM->buffer<Tab>\\ro         :call RUBY_Toggle_Gvim_Xterm_MS()<CR>'
			exe "imenu    <silent>  ".s:RUBY_Root.'&Run.&output:\ TERM->buffer<Tab>\\ro    <C-C>:call RUBY_Toggle_Gvim_Xterm_MS()<CR>'
			let	s:RUBY_OutputGvim	= "xterm"
		else
			exe "aunmenu  <silent>  ".s:RUBY_Root.'&Run.&output:\ TERM->buffer'
			exe " menu    <silent>  ".s:RUBY_Root.'&Run.&output:\ BUFFER->term<Tab>\\ro         :call RUBY_Toggle_Gvim_Xterm_MS()<CR>'
			exe "imenu    <silent>  ".s:RUBY_Root.'&Run.&output:\ BUFFER->term<Tab>\\ro    <C-C>:call RUBY_Toggle_Gvim_Xterm_MS()<CR>'
			let	s:RUBY_OutputGvim	= "buffer"
		endif
	endif
endfunction    " ----------  end of function RUBY_Toggle_Gvim_Xterm_MS ----------
"
"------------------------------------------------------------------------------
"  Run : make script executable    {{{1
"------------------------------------------------------------------------------
function! RUBY_MakeScriptExecutable ()
	let	filename	= fnameescape( expand("%:p") )
	silent exe "!chmod u+x ".filename
	redraw!
	if v:shell_error
		echohl WarningMsg
	  echo 'Could not make "'.filename.'" executable !'
	else
		echohl Search
	  echo 'Made "'.filename.'" executable.'
	endif
	echohl None
endfunction		" ---------- end of function  RUBY_MakeScriptExecutable  ----------
"
"------------------------------------------------------------------------------
"  RUBY_RubyCmdLineArguments : Ruby command line arguments       {{{1
"------------------------------------------------------------------------------
function! RUBY_RubyCmdLineArguments ()
	let	prompt	= 'Ruby command line arguments for "'.expand("%").'" : '
	if exists("b:RUBY_RubyCmdLineArgs")
		let	b:RUBY_RubyCmdLineArgs= RUBY_Input( prompt, b:RUBY_RubyCmdLineArgs )
	else
		let	b:RUBY_RubyCmdLineArgs= RUBY_Input( prompt , "" )
	endif
endfunction    " ----------  end of function RUBY_RubyCmdLineArguments ----------
"
"------------------------------------------------------------------------------
"  Run : run    {{{1
"------------------------------------------------------------------------------
"
let s:RUBY_OutputBufferName   = "Ruby-Output"
let s:RUBY_OutputBufferNumber = -1
"
function! RUBY_Run ( mode )
	silent exe ':cclose'
"
	let	l:arguments				= exists("b:RUBY_ScriptCmdLineArgs") ? " ".b:RUBY_ScriptCmdLineArgs : ""
	let	l:currentbuffer   = bufname("%")
	let l:fullname				= expand("%:p")
	let l:fullnameesc			= fnameescape( l:fullname )
	"
	silent exe ":update"
	"
	if a:mode=="v"
		let tmpfile	= tempname()
		silent exe ":'<,'>write ".tmpfile
	endif

	let l:rubyCmdLineArgs	= exists("b:RUBY_RubyCmdLineArgs") ? ' '.b:RUBY_RubyCmdLineArgs.' ' : ''
	"
	"------------------------------------------------------------------------------
	"  Run : run from the vim command line (Linux only)
	"------------------------------------------------------------------------------
	"
	if s:RUBY_OutputGvim == "vim"
		"
		" ----- visual mode ----------
		"
		if a:mode=="v"
			echomsg  ":!".s:RUBY_BASH.l:rubyCmdLineArgs." < ".tmpfile." -s ".l:arguments
			exe ":!".s:RUBY_BASH.l:rubyCmdLineArgs." < ".tmpfile." -s ".l:arguments
			call delete(tmpfile)
			return
		endif
		"
		" ----- normal mode ----------
		"
		call RUBY_SaveOption( 'makeprg' )
		exe	":setlocal makeprg=".s:RUBY_BASH
		exe	':setlocal errorformat='.s:RUBY_Errorformat
		"
		if a:mode=="n"
			exe ":make ".l:rubyCmdLineArgs.l:fullnameesc.l:arguments
		endif
		if &term == 'xterm'
			redraw!
		endif
		"
		call RUBY_RestoreOption( 'makeprg' )
		exe	":botright cwindow"

		if l:currentbuffer != bufname("%") && a:mode=="n"
			let	pattern	= '^||.*\n\?'
			setlocal modifiable
			" remove the regular script output (appears as comment)
			if search(pattern) != 0
				silent exe ':%s/'.pattern.'//'
			endif
			" read the buffer back to have it parsed and used as the new error list
			silent exe ':cgetbuffer'
			setlocal nomodifiable
			silent exe	':cc'
		endif
		"
		exe	':setlocal errorformat='
	endif
	"
	"------------------------------------------------------------------------------
	"  Run : redirect output to an output buffer
	"------------------------------------------------------------------------------
	if s:RUBY_OutputGvim == "buffer"

		let	l:currentbuffernr = bufnr("%")

		if l:currentbuffer ==  bufname("%")
			"
			if bufloaded(s:RUBY_OutputBufferName) != 0 && bufwinnr(s:RUBY_OutputBufferNumber)!=-1
				exe bufwinnr(s:RUBY_OutputBufferNumber) . "wincmd w"
				" buffer number may have changed, e.g. after a 'save as'
				if bufnr("%") != s:RUBY_OutputBufferNumber
					let s:RUBY_OutputBufferNumber	= bufnr(s:RUBY_OutputBufferName)
					exe ":bn ".s:RUBY_OutputBufferNumber
				endif
			else
				silent exe ":new ".s:RUBY_OutputBufferName
				let s:RUBY_OutputBufferNumber=bufnr("%")
				setlocal noswapfile
				setlocal buftype=nofile
				setlocal syntax=none
				setlocal bufhidden=delete
				setlocal tabstop=8
			endif
			"
			" run script
			"
			setlocal	modifiable
			if a:mode=="n"
				if	s:MSWIN
					silent exe ":%!".s:RUBY_BASH.l:rubyCmdLineArgs.' "'.l:fullname.'" '.l:arguments
				else
					silent exe ":%!".s:RUBY_BASH.l:rubyCmdLineArgs." ".l:fullnameesc.l:arguments
				endif
			endif
			"
			if a:mode=="v"
				silent exe ":%!".s:RUBY_BASH.l:rubyCmdLineArgs." < ".tmpfile." -s ".l:arguments
			endif
			setlocal	nomodifiable
			"
			" stdout is empty / not empty
			"
			if line("$")==1 && col("$")==1
				silent	exe ":bdelete"
			else
				if winheight(winnr()) >= line("$")
					exe bufwinnr(l:currentbuffernr) . "wincmd w"
				endif
			endif
			"
		endif
	endif
	"
	"------------------------------------------------------------------------------
	"  Run : run in a detached xterm
	"------------------------------------------------------------------------------
	if s:RUBY_OutputGvim == 'xterm'
		"
		if	s:MSWIN
			exe ':!'.s:RUBY_BASH.l:rubyCmdLineArgs.' "'.l:fullname.'" '.l:arguments
		else
			if a:mode=='n'
				silent exe '!xterm -title '.l:fullnameesc.' '.s:RUBY_XtermDefaults
							\			.' -e '.s:RUBY_Wrapper.' '.l:rubyCmdLineArgs.l:fullnameesc.l:arguments.' &'
			endif
			"
			if a:mode=="v"
				let titlestring	= l:fullnameesc.'\ lines\ \ '.line("'<").'\ -\ '.line("'>")
				silent exe ':!xterm -title '.titlestring.' '.s:RUBY_XtermDefaults
							\			.' -e '.s:RUBY_Wrapper.' '.l:rubyCmdLineArgs.tmpfile.l:arguments.' &'
			endif
		endif
		"
	endif
	"
	if !has("gui_running") &&  v:progname != 'vim'
		redraw!
	endif
endfunction    " ----------  end of function RUBY_Run  ----------
"
"------------------------------------------------------------------------------
"  Run : xterm geometry    {{{1
"------------------------------------------------------------------------------
function! RUBY_XtermSize ()
	let regex	= '-geometry\s\+\d\+x\d\+'
	let geom	= matchstr( s:RUBY_XtermDefaults, regex )
	let geom	= matchstr( geom, '\d\+x\d\+' )
	let geom	= substitute( geom, 'x', ' ', "" )
	let	answer= RUBY_Input("   xterm size (COLUMNS LINES) : ", geom, '' )
	while match(answer, '^\s*\d\+\s\+\d\+\s*$' ) < 0
		let	answer= RUBY_Input(" + xterm size (COLUMNS LINES) : ", geom, '' )
	endwhile
	let answer  = substitute( answer, '^\s\+', "", "" )		 				" remove leading whitespaces
	let answer  = substitute( answer, '\s\+$', "", "" )						" remove trailing whitespaces
	let answer  = substitute( answer, '\s\+', "x", "" )						" replace inner whitespaces
	let s:RUBY_XtermDefaults	= substitute( s:RUBY_XtermDefaults, regex, "-geometry ".answer , "" )
endfunction		" ---------- end of function  RUBY_XtermDefaults  ----------
"
"
"------------------------------------------------------------------------------
"  set : option    {{{1
"------------------------------------------------------------------------------
function! RUBY_set (arg)
	let	s:RUBY_SetCounter	= 0
	let	save_line					= line(".")
	let	actual_line				= 0
	"
	" search for the maximum option number (if any)
	normal gg
	while actual_line < search( s:RUBY_Set_Txt."\\d\\+" )
		let actual_line	= line(".")
	 	let actual_opt  = matchstr( getline(actual_line), s:RUBY_Set_Txt."\\d\\+" )
		let actual_opt  = strpart( actual_opt, strlen(s:RUBY_Set_Txt),strlen(actual_opt)-strlen(s:RUBY_Set_Txt))
		if s:RUBY_SetCounter < actual_opt
			let	s:RUBY_SetCounter = actual_opt
		endif
	endwhile
	let	s:RUBY_SetCounter = s:RUBY_SetCounter+1
	silent exe ":".save_line
	"
	" insert option
	let zz= "set -o ".a:arg."       # ".s:RUBY_Set_Txt.s:RUBY_SetCounter
	normal '<
	put! =zz
	let zz= "set +o ".a:arg."       # ".s:RUBY_Set_Txt.s:RUBY_SetCounter
	normal '>
	put  =zz
	let	s:RUBY_SetCounter	= s:RUBY_SetCounter+1
endfunction		" ---------- end of function  RUBY_set  ----------
"
"------------------------------------------------------------------------------
"  shopt : option    {{{1
"------------------------------------------------------------------------------
function! RUBY_shopt (arg)
	let	s:RUBY_SetCounter	= 0
	let	save_line					= line(".")
	let	actual_line				= 0
	"
	" search for the maximum option number (if any)
	normal gg
	while actual_line < search( s:RUBY_Shopt_Txt."\\d\\+" )
		let actual_line	= line(".")
	 	let actual_opt  = matchstr( getline(actual_line), s:RUBY_Shopt_Txt."\\d\\+" )
		let actual_opt  = strpart( actual_opt, strlen(s:RUBY_Shopt_Txt),strlen(actual_opt)-strlen(s:RUBY_Shopt_Txt))
		if s:RUBY_SetCounter < actual_opt
			let	s:RUBY_SetCounter = actual_opt
		endif
	endwhile
	let	s:RUBY_SetCounter = s:RUBY_SetCounter+1
	silent exe ":".save_line
	"
	" insert option
	let zz= "shopt -s ".a:arg."       # ".s:RUBY_Shopt_Txt.s:RUBY_SetCounter."\n"
	normal '<
	put! =zz
	let zz= "shopt -u ".a:arg."       # ".s:RUBY_Shopt_Txt.s:RUBY_SetCounter
	normal '>
	put  =zz
	let	s:RUBY_SetCounter	= s:RUBY_SetCounter+1
endfunction		" ---------- end of function  RUBY_shopt  ----------
"
"------------------------------------------------------------------------------
"  Run : Command line arguments    {{{1
"------------------------------------------------------------------------------
function! RUBY_ScriptCmdLineArguments ()
	let filename = expand("%")
  if empty(filename)
		redraw
		echohl WarningMsg | echo " no file name " | echohl None
		return
  endif
	let	prompt	= 'command line arguments for "'.filename.'" : '
	if exists("b:RUBY_ScriptCmdLineArgs")
		let	b:RUBY_ScriptCmdLineArgs= RUBY_Input( prompt, b:RUBY_ScriptCmdLineArgs , 'file' )
	else
		let	b:RUBY_ScriptCmdLineArgs= RUBY_Input( prompt , "", 'file' )
	endif
endfunction		" ---------- end of function  RUBY_ScriptCmdLineArguments  ----------
"
"------------------------------------------------------------------------------
"  Ruby-Idioms : read / edit code snippet    {{{1
"------------------------------------------------------------------------------
function! RUBY_CodeSnippets(arg1)
	if isdirectory(s:RUBY_CodeSnippets)
		"
		" read snippet file, put content below current line
		"
		if a:arg1 == "r"
			if has("gui_running") && s:RUBY_GuiSnippetBrowser == 'gui'
				let	l:snippetfile=browse(0,"read a code snippet",s:RUBY_CodeSnippets,"")
			else
				let	l:snippetfile=input("read snippet ", s:RUBY_CodeSnippets, "file" )
			end
			if filereadable(l:snippetfile)
				let	linesread= line("$")
				"
				" Prevent the alternate buffer from being set to this files
				call RUBY_SaveOption('cpoptions')
				setlocal cpoptions-=a
				:execute "read ".l:snippetfile
				call RUBY_RestoreOption('cpoptions')
				"
				let	linesread= line("$")-linesread-1
				if linesread>=0 && match( l:snippetfile, '\.\(ni\|noindent\)$' ) < 0
					silent exe "normal =".linesread."+"
				endif
			endif
		endif
		"
		" update current buffer / split window / edit snippet file
		"
		if a:arg1 == "e"
			if has("gui_running") && s:RUBY_GuiSnippetBrowser == 'gui'
				let	l:snippetfile=browse(0,"edit a code snippet",s:RUBY_CodeSnippets,"")
			else
				let	l:snippetfile=input("edit snippet ", s:RUBY_CodeSnippets, "file" )
			end
			if l:snippetfile != ""
				:execute "update! | split | edit ".l:snippetfile
			endif
		endif
		"
		" write whole buffer or marked area into snippet file
		"
		if a:arg1 == "w" || a:arg1 == "wv"
			if has("gui_running") && s:RUBY_GuiSnippetBrowser == 'gui'
				let	l:snippetfile=browse(0,"write a code snippet",s:RUBY_CodeSnippets,"")
			else
				let	l:snippetfile=input("write snippet ", s:RUBY_CodeSnippets, "file" )
			end
			if l:snippetfile != ""
				if filereadable(l:snippetfile)
					if confirm("File exists ! Overwrite ? ", "&Cancel\n&No\n&Yes") != 3
						return
					endif
				endif
				if a:arg1 == "w"
					:execute ":write! ".l:snippetfile
				else
					:execute ":*write! ".l:snippetfile
				end
			endif
		endif

	else
		echo "code snippet directory ".s:RUBY_CodeSnippets." does not exist (please create it)"
	endif
endfunction		" ---------- end of function  RUBY_CodeSnippets  ----------
"
"------------------------------------------------------------------------------
"  Run : hardcopy    {{{1
"------------------------------------------------------------------------------
function! RUBY_Hardcopy (mode)
  let outfile = expand("%")
  if empty(outfile)
    redraw
    echohl WarningMsg | echo " no file name " | echohl None
    return
  endif
	let outdir	= getcwd()
	if filewritable(outdir) != 2
		let outdir	= $HOME
	endif
	if  !s:MSWIN
		let outdir	= outdir.'/'
	endif
  let old_printheader=&printheader
  exe  ':set printheader='.s:RUBY_Printheader
  " ----- normal mode ----------------
  if a:mode=="n"
    silent exe  'hardcopy > '.outdir.outfile.'.ps'
    if  !s:MSWIN
      echo 'file "'.outfile.'" printed to "'.outdir.outfile.'.ps"'
    endif
  endif
  " ----- visual mode ----------------
  if a:mode=="v"
    silent exe  "*hardcopy > ".outdir.outfile.".ps"
    if  !s:MSWIN
      echo 'file "'.outfile.'" (lines '.line("'<").'-'.line("'>").') printed to "'.outdir.outfile.'.ps"'
    endif
  endif
  exe  ':set printheader='.escape( old_printheader, ' %' )
endfunction   " ---------- end of function  RUBY_Hardcopy  ----------
"
"------------------------------------------------------------------------------
"  Run : settings    {{{1
"------------------------------------------------------------------------------
function! RUBY_Settings ()
	let	txt	=     "     Ruby-Support settings\n\n"
  let txt = txt.'               author name :  "'.s:RUBY_Macro['|AUTHOR|']."\"\n"
  let txt = txt.'                 authorref :  "'.s:RUBY_Macro['|AUTHORREF|']."\"\n"
  let txt = txt.'                   company :  "'.s:RUBY_Macro['|COMPANY|']."\"\n"
  let txt = txt.'          copyright holder :  "'.s:RUBY_Macro['|COPYRIGHTHOLDER|']."\"\n"
  let txt = txt.'                     email :  "'.s:RUBY_Macro['|EMAIL|']."\"\n"
  let txt = txt.'                   licence :  "'.s:RUBY_Macro['|LICENSE|']."\"\n"
  let txt = txt.'              organization :  "'.s:RUBY_Macro['|ORGANIZATION|']."\"\n"
  let txt = txt.'                   project :  "'.s:RUBY_Macro['|PROJECT|']."\"\n"
	let txt = txt.'    code snippet directory :  "'.s:RUBY_CodeSnippets."\"\n"
	" ----- template files  ------------------------
	let txt = txt.'            template style :  "'.s:RUBY_ActualStyle."\"\n"
	let txt = txt.'       plugin installation :  "'.s:installation."\"\n"
	if s:installation == 'system'
		let txt = txt.'global template directory :  "'.s:RUBY_GlobalTemplateDir."\"\n"
		if filereadable( s:RUBY_LocalTemplateFile )
			let txt = txt.'  local template directory :  "'.s:RUBY_LocalTemplateDir."\"\n"
		endif
	else
		let txt = txt.'  local template directory :  "'.s:RUBY_LocalTemplateDir."\"\n"
	endif
	let txt = txt.'glob. syntax check options :  "'.s:RUBY_SyntaxCheckOptionsGlob."\"\n"
	if exists("b:RUBY_SyntaxCheckOptionsLocal")
		let txt = txt.' buf. syntax check options :  "'.b:RUBY_SyntaxCheckOptionsLocal."\"\n"
	endif
	" ----- dictionaries ------------------------
	if g:RUBY_Dictionary_File != ""
		let ausgabe= &dictionary
		let ausgabe= substitute( ausgabe, ",", ",\n                            + ", "g" )
		let txt = txt."        dictionary file(s) :  ".ausgabe."\n"
	endif
	if exists("b:RUBY_RubyCmdLineArgs")
		let ausgabe = b:RUBY_RubyCmdLineArgs
	else
		let ausgabe = ""
	endif
	let txt = txt." Ruby cmd.line argument(s) :  ".ausgabe."\n"
	let txt = txt."      current output dest. :  ".s:RUBY_OutputGvim."\n"
	if	!s:MSWIN
		let txt = txt.'            xterm defaults :  '.s:RUBY_XtermDefaults."\n"
	endif
	let txt = txt.'                    rubydb :  "'.s:RUBY_rubydb."\"\n"
	let txt = txt."\n"
	let txt = txt."       Additional hot keys\n\n"
	let txt = txt."                  Shift-F1 :  help for builtin under the cursor \n"
	let txt = txt."                   Ctrl-F9 :  update file, run script           \n"
	let txt = txt."                    Alt-F9 :  update file, run syntax check     \n"
	let txt = txt."                  Shift-F9 :  edit command line arguments       \n"
	if	!s:MSWIN
	let txt = txt."                        F9 :  debug script (".s:RUBY_Debugger.")\n"
	endif
	let	txt = txt."___________________________________________________________________________\n"
	let	txt = txt." Ruby-Support, Version ".g:RUBY_Version." / Dr.-Ing. Fritz Mehner / mehner@fh-swf.de\n\n"
	echo txt
endfunction		" ---------- end of function  RUBY_Settings  ----------
"
"------------------------------------------------------------------------------
"  Run : help rubysupport     {{{1
"------------------------------------------------------------------------------
function! RUBY_HelpBASHsupport ()
	try
		:help rubysupport
	catch
		exe ':helptags '.s:plugin_dir.'/doc'
		:help rubysupport
	endtry
endfunction    " ----------  end of function RUBY_HelpBASHsupport ----------

"------------------------------------------------------------------------------
"  date and time    {{{1
"------------------------------------------------------------------------------
function! RUBY_InsertDateAndTime ( format )
	if a:format == 'd'
		return strftime( s:RUBY_FormatDate )
	end
	if a:format == 't'
		return strftime( s:RUBY_FormatTime )
	end
	if a:format == 'dt'
		return strftime( s:RUBY_FormatDate ).' '.strftime( s:RUBY_FormatTime )
	end
	if a:format == 'y'
		return strftime( s:RUBY_FormatYear )
	end
endfunction    " ----------  end of function RUBY_InsertDateAndTime  ----------

"------------------------------------------------------------------------------
"  RUBY_HighlightJumpTargets
"------------------------------------------------------------------------------
function! RUBY_HighlightJumpTargets ()
	if s:RUBY_Ctrl_j == 'on'
		exe 'match Search /'.s:RUBY_TemplateJumpTarget1.'\|'.s:RUBY_TemplateJumpTarget2.'/'
	endif
endfunction    " ----------  end of function RUBY_HighlightJumpTargets  ----------

"------------------------------------------------------------------------------
"  RUBY_JumpCtrlJ     {{{1
"------------------------------------------------------------------------------
function! RUBY_JumpCtrlJ ()
  let match	= search( s:RUBY_TemplateJumpTarget1.'\|'.s:RUBY_TemplateJumpTarget2, 'c' )
	if match > 0
		" remove the target
		call setline( match, substitute( getline('.'), s:RUBY_TemplateJumpTarget1.'\|'.s:RUBY_TemplateJumpTarget2, '', '' ) )
	else
		" try to jump behind parenthesis or strings in the current line 
		if match( getline(".")[col(".") - 1], "[\]})\"'`]"  ) != 0
			call search( "[\]})\"'`]", '', line(".") )
		endif
		normal l
	endif
	return ''
endfunction    " ----------  end of function RUBY_JumpCtrlJ  ----------

"------------------------------------------------------------------------------
"  RUBY_ExpandUserMacros     {{{1
"------------------------------------------------------------------------------
function! RUBY_ExpandUserMacros ( key )

	if has_key( s:RUBY_Template[s:RUBY_ActualStyle], a:key )
		let template 								= s:RUBY_Template[s:RUBY_ActualStyle][ a:key ]
	else
		let template 								= s:RUBY_Template['default'][ a:key ]
	endif
	let	s:RUBY_ExpansionCounter	= {}										" reset the expansion counter

  "------------------------------------------------------------------------------
  "  renew the predefined macros and expand them
	"  can be replaced, with e.g. |?DATE|
  "------------------------------------------------------------------------------
	let	s:RUBY_Macro['|BASENAME|']	= toupper(expand("%:t:r"))
  let s:RUBY_Macro['|DATE|']  		= RUBY_DateAndTime('d')
  let s:RUBY_Macro['|FILENAME|']	= expand("%:t")
  let s:RUBY_Macro['|PATH|']  		= expand("%:p:h")
  let s:RUBY_Macro['|SUFFIX|']		= expand("%:e")
  let s:RUBY_Macro['|TIME|']  		= RUBY_DateAndTime('t')
  let s:RUBY_Macro['|YEAR|']  		= RUBY_DateAndTime('y')

  "------------------------------------------------------------------------------
  "  delete jump targets if mapping for C-j is off
  "------------------------------------------------------------------------------
	if s:RUBY_Ctrl_j == 'off'
		let template	= substitute( template, s:RUBY_TemplateJumpTarget1.'\|'.s:RUBY_TemplateJumpTarget2, '', 'g' )
	endif

  "------------------------------------------------------------------------------
  "  look for replacements
  "------------------------------------------------------------------------------
	while match( template, s:RUBY_ExpansionRegex ) != -1
		let macro				= matchstr( template, s:RUBY_ExpansionRegex )
		let replacement	= substitute( macro, '?', '', '' )
		let template		= substitute( template, macro, replacement, "g" )

		let match	= matchlist( macro, s:RUBY_ExpansionRegex )

		if !empty( match[1] )
			let macroname	= '|'.match[1].'|'
			"
			" notify flag action, if any
			let flagaction	= ''
			if has_key( s:RUBY_MacroFlag, match[2] )
				let flagaction	= ' (-> '.s:RUBY_MacroFlag[ match[2] ].')'
			endif
			"
			" ask for a replacement
			if has_key( s:RUBY_Macro, macroname )
				let	name	= RUBY_Input( match[1].flagaction.' : ', RUBY_ApplyFlag( s:RUBY_Macro[macroname], match[2] ) )
			else
				let	name	= RUBY_Input( match[1].flagaction.' : ', '' )
			endif
			if empty(name)
				return ""
			endif
			"
			" keep the modified name
			let s:RUBY_Macro[macroname]  			= RUBY_ApplyFlag( name, match[2] )
		endif
	endwhile

  "------------------------------------------------------------------------------
  "  do the actual macro expansion
	"  loop over the macros found in the template
  "------------------------------------------------------------------------------
	while match( template, s:RUBY_NonExpansionRegex ) != -1

		let macro			= matchstr( template, s:RUBY_NonExpansionRegex )
		let match			= matchlist( macro, s:RUBY_NonExpansionRegex )

		if !empty( match[1] )
			let macroname	= '|'.match[1].'|'

			if has_key( s:RUBY_Macro, macroname )
				"-------------------------------------------------------------------------------
				"   check for recursion
				"-------------------------------------------------------------------------------
				if has_key( s:RUBY_ExpansionCounter, macroname )
					let	s:RUBY_ExpansionCounter[macroname]	+= 1
				else
					let	s:RUBY_ExpansionCounter[macroname]	= 0
				endif
				if s:RUBY_ExpansionCounter[macroname]	>= s:RUBY_ExpansionLimit
					echomsg "recursion terminated for recursive macro ".macroname
					return template
				endif
				"-------------------------------------------------------------------------------
				"   replace
				"-------------------------------------------------------------------------------
				let replacement = RUBY_ApplyFlag( s:RUBY_Macro[macroname], match[2] )
				let template 		= substitute( template, macro, replacement, "g" )
			else
				"
				" macro not yet defined
				let s:RUBY_Macro['|'.match[1].'|']  		= ''
			endif
		endif

	endwhile

  return template
endfunction    " ----------  end of function RUBY_ExpandUserMacros  ----------

"------------------------------------------------------------------------------
"  RUBY_ApplyFlag     {{{1
"------------------------------------------------------------------------------
function! RUBY_ApplyFlag ( val, flag )
	"
	" l : lowercase
	if a:flag == ':l'
		return  tolower(a:val)
	endif
	"
	" u : uppercase
	if a:flag == ':u'
		return  toupper(a:val)
	endif
	"
	" c : capitalize
	if a:flag == ':c'
		return  toupper(a:val[0]).a:val[1:]
	endif
	"
	" L : legalized name
	if a:flag == ':L'
		return  RUBY_LegalizeName(a:val)
	endif
	"
	" flag not valid
	return a:val
endfunction    " ----------  end of function RUBY_ApplyFlag  ----------
"
"------------------------------------------------------------------------------
"  RUBY_ExpandSingleMacro     {{{1
"------------------------------------------------------------------------------
function! RUBY_ExpandSingleMacro ( val, macroname, replacement )
  return substitute( a:val, escape(a:macroname, '$' ), a:replacement, "g" )
endfunction    " ----------  end of function RUBY_ExpandSingleMacro  ----------

"------------------------------------------------------------------------------
"  RUBY_InsertMacroValue     {{{1
"------------------------------------------------------------------------------
function! RUBY_InsertMacroValue ( key )
	if s:RUBY_Macro['|'.a:key.'|'] == ''
		echomsg 'the tag |'.a:key.'| is empty'
		return
	endif
	"
	if &foldenable && foldclosed(".") >= 0
		echohl WarningMsg | echomsg s:MsgInsNotAvail  | echohl None
		return
	endif
	if col(".") > 1
		exe 'normal! a'.s:RUBY_Macro['|'.a:key.'|']
	else
		exe 'normal! i'.s:RUBY_Macro['|'.a:key.'|']
	endif
endfunction    " ----------  end of function RUBY_InsertMacroValue  ----------

"------------------------------------------------------------------------------
"  insert date and time     {{{1
"------------------------------------------------------------------------------
function! RUBY_InsertDateAndTime ( format )
	if &foldenable && foldclosed(".") >= 0
		echohl WarningMsg | echomsg s:MsgInsNotAvail  | echohl None
		return ""
	endif
	if col(".") > 1
		exe 'normal a'.RUBY_DateAndTime(a:format)
	else
		exe 'normal i'.RUBY_DateAndTime(a:format)
	endif
endfunction    " ----------  end of function RUBY_InsertDateAndTime  ----------

"------------------------------------------------------------------------------
"  generate date and time     {{{1
"------------------------------------------------------------------------------
function! RUBY_DateAndTime ( format )
	if a:format == 'd'
		return strftime( s:RUBY_FormatDate )
	elseif a:format == 't'
		return strftime( s:RUBY_FormatTime )
	elseif a:format == 'dt'
		return strftime( s:RUBY_FormatDate ).' '.strftime( s:RUBY_FormatTime )
	elseif a:format == 'y'
		return strftime( s:RUBY_FormatYear )
	endif
endfunction    " ----------  end of function RUBY_DateAndTime  ----------
"
"------------------------------------------------------------------------------
"  RUBY_CreateMenusDelayed   {{{1
"------------------------------------------------------------------------------
let s:RUBY_MenusVisible = 'no'								" state : 0 = not visible / 1 = visible
"
function! RUBY_CreateMenusDelayed ()
	if s:RUBY_CreateMenusDelayed == 'yes' && s:RUBY_MenusVisible == 'no'
		call RUBY_CreateGuiMenus()
	endif
endfunction    " ----------  end of function RUBY_CreateMenusDelayed  ----------
"
"------------------------------------------------------------------------------
"  RUBY_CreateGuiMenus    {{{1
"------------------------------------------------------------------------------
function! RUBY_CreateGuiMenus ()
	if s:RUBY_MenusVisible == 'no'
		aunmenu <silent> &Tools.Load\ Ruby\ Support
		amenu   <silent> 40.1000 &Tools.-SEP100- :
		amenu   <silent> 40.1021 &Tools.Unload\ Ruby\ Support <C-C>:call RUBY_RemoveGuiMenus()<CR>
		call RUBY_InitMenu()
		let s:RUBY_MenusVisible = 'yes'
	endif
endfunction    " ----------  end of function RUBY_CreateGuiMenus  ----------

"------------------------------------------------------------------------------
"  RUBY_ToolMenu    {{{1
"------------------------------------------------------------------------------
function! RUBY_ToolMenu ()
	amenu   <silent> 40.1000 &Tools.-SEP100- :
	amenu   <silent> 40.1021 &Tools.Load\ Ruby\ Support <C-C>:call RUBY_CreateGuiMenus()<CR>
endfunction    " ----------  end of function RUBY_ToolMenu  ----------

"------------------------------------------------------------------------------
"  RUBY_RemoveGuiMenus    {{{1
"------------------------------------------------------------------------------
function! RUBY_RemoveGuiMenus ()
	if s:RUBY_MenusVisible == 'yes'
		exe "aunmenu <silent> ".s:RUBY_Root
		"
		aunmenu <silent> &Tools.Unload\ Ruby\ Support
		call RUBY_ToolMenu()
		"
		let s:RUBY_MenusVisible = 'no'
	endif
endfunction    " ----------  end of function RUBY_RemoveGuiMenus  ----------
"
"------------------------------------------------------------------------------
"  RUBY_SaveOption    {{{1
"  param 1 : option name
"  param 2 : characters to be escaped (optional)
"------------------------------------------------------------------------------
function! RUBY_SaveOption ( option, ... )
	exe 'let escaped =&'.a:option
	if a:0 == 0
		let escaped	= escape( escaped, ' |"\' )
	else
		let escaped	= escape( escaped, ' |"\'.a:1 )
	endif
	let s:RUBY_saved_option[a:option]	= escaped
endfunction    " ----------  end of function RUBY_SaveOption  ----------
"
"------------------------------------------------------------------------------
"  RUBY_RestoreOption    {{{1
"------------------------------------------------------------------------------
function! RUBY_RestoreOption ( option )
	exe ':setlocal '.a:option.'='.s:RUBY_saved_option[a:option]
endfunction    " ----------  end of function RUBY_RestoreOption  ----------
"
"================================================================================
"  show / hide the menus   {{{1
"  define key mappings (gVim only)
"
"================================================================================
"
call RUBY_ToolMenu()
"
if s:RUBY_LoadMenus == 'yes' && s:RUBY_CreateMenusDelayed == 'no'
	call RUBY_CreateGuiMenus()
endif
"
nmap    <silent>  <Leader>lbs             :call RUBY_CreateGuiMenus()<CR>
nmap    <silent>  <Leader>ubs             :call RUBY_RemoveGuiMenus()<CR>
"
"
"------------------------------------------------------------------------------
"  Automated header insertion   {{{1
"------------------------------------------------------------------------------
"
if has("autocmd")
	"
	autocmd BufNewFile,BufRead           *.rb call RUBY_CreateMenusDelayed()
	"
	" Ruby-script : insert header, write file, make it executable
	"
	if !exists( 'g:RUBY_AlsoRuby' )
		"
		autocmd BufNewFile,BufRead           *.rb set filetype=ruby
		" style is taken from s:RUBY_Style
		autocmd BufNewFile                   *.rb call RUBY_InsertTemplate("comment.file-description")
		autocmd BufRead                      *.rb call RUBY_HighlightJumpTargets()
		"
	else
		" 
		" g:RUBY_AlsoRuby is a list of filename patterns
		"
		if type( g:RUBY_AlsoRuby ) == 3
			for pattern in g:RUBY_AlsoRuby
				exe "autocmd BufNewFile,BufRead          ".pattern." set filetype=rb"
				" style is taken from s:RUBY_Style
				exe "autocmd BufNewFile                  ".pattern." call RUBY_InsertTemplate('comment.file-description')"
				exe 'autocmd BufRead                     ".pattern." call RUBY_HighlightJumpTargets()'
			endfor
		endif
		"
		" g:RUBY_AlsoRuby is a dictionary ( "file pattern" : "template style" )
		"
		if type( g:RUBY_AlsoRuby ) == 4
			for [ pattern, stl ] in items( g:RUBY_AlsoRuby )
				exe "autocmd BufNewFile,BufRead          ".pattern." set filetype=rb"
				" style is defined by the file extensions
				exe "autocmd BufNewFile,BufRead,BufEnter ".pattern." call RUBY_Style( '".stl."' )"
				exe "autocmd BufNewFile                  ".pattern." call RUBY_InsertTemplate('comment.file-description')"
				exe 'autocmd BufRead                     ".pattern." call RUBY_HighlightJumpTargets()'
			endfor
		endif
		"
	endif
endif " has("autocmd")
"
"------------------------------------------------------------------------------
" vim: tabstop=2 shiftwidth=2 foldmethod=marker
