" Gtd task syntax

if exists("b:current_syntax")
  finish
endif

" Read the gtd syntax to start with
runtime! syntax/gtd.vim
unlet b:current_syntax

" ----------------------------------------
" Task Location
syn match   gtdTaskLoc '<.*:\d\+>' conceal


if exists("g:gtd_use_solamo_color") && g:gtd_use_solamo_color
    hi  link    gtdTaskLoc              hl_gray_dd
else
    hi          gtdTaskLoc              ctermfg=DarkGray        guifg=DarkGray
endif


let b:current_syntax = "gtt"
" vim: ts=4
