" Gtd task syntax

if exists("b:current_syntax")
  finish
endif

" Read the gtd syntax to start with
runtime! syntax/gtd.vim
unlet b:current_syntax

let b:current_syntax = "gtl"
" vim: ts=4
