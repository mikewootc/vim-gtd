" Quit when a (custom) syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

" ----------------------------------------
" Separator line
syn match   gtdSeparator ".*=\{40}=.*"

" ----------------------------------------
" Title
syn match   gtdTitle   "\[\[.*\]\]" contains=ALL

" ----------------------------------------
" Date
syn match   gtdDate "[0-9]\{4}\-[0-9]\{2}\-[0-9]\{2}"

" ----------------------------------------
" Plan date
"syn region  gtdPlanDate start=/\[p:/ end=/\]/ oneline contains=gtdDate

" ----------------------------------------
" Overdue date
syn region  gtdOverdueDate start=/\[o:/ end=/\]/ oneline

" ----------------------------------------
" Normal(planned)
syn match   gtdPlanned "[^\]]*\[p:"me=e-3 contains=gtdDate,gtdContext,gtdWorker
"syn match   gtdPlanned "^\s*\[\*\] " nextgroup=gtdPlanDate

" ----------------------------------------
" Today
"syn match   gtdToday "[^\]]*\[t:"me=e-3 contains=gtdDate,gtdContext,gtdWorker

" ----------------------------------------
" Emergency
syn match   gtdEmergency "[^\]]*\[e:"me=e-3 contains=gtdDate,gtdContext,gtdWorker
"syn match   gtdEmergency "^\s*\* .\+\[e:"me=e-3 contains=gtdDate,gtdContext,gtdWorker

" ----------------------------------------
" Overdue
syn match   gtdOverdue "[^\]]*\[o:"me=e-3 contains=gtdDate,gtdContext,gtdWorker
"syn match   gtdOverdue "\* *\[o:"me=e-3 contains=gtdDate,gtdContext,gtdWorker

" ----------------------------------------
" Finished
syn match   gtdFinished '.\+\[f:\d\{4}.\d\{2}.\d\{2}\]' contains=gtdOverdueDate
"syn match   gtdFinished '.\+\(\[f:\)\@='

" ----------------------------------------
" High prio project
syn match   gtdHighPrio "^\s*\[\*\] " contains=ALL

" ----------------------------------------
" Low prio project
syn match   gtdLowPrio "^\s*\[\.\] " contains=ALL

" ----------------------------------------
" Substeps
"syn match   gtdSubstep "^\s*\*.\+" contains=gtdDate,gtdContext,gtdWorker,gtdEmergency,gtdPlanned,gtdOverdue

" ----------------------------------------
" Context
syn match   gtdContext " #[^#]*# "

" ----------------------------------------
" Worker
syn match   gtdWorker " @\S\+ "
syn match   gtdWorker "^@\S\+ "
syn match   gtdWorker " @\S\+$"

" ----------------------------------------
" Bold
syn region gtdBold matchgroup=gtdBoldMark start="\S\@<=\*\*\|\*\*\S\@=" end="\S\@<=\*\*\|\*\*\S\@=" keepend oneline concealends

" ----------------------------------------
" Note
syn match   gtdNote "^\s*>.*" contains=ALL

" ----------------------------------------
" Comment
syn match   gtdComment "\/\/.*"

" ----------------------------------------
" Brace
syn match   gtdBrace "{{{\d*"
syn match   gtdBrace "}}}\d*"



if exists("g:gtd_use_solamo_color") && g:gtd_use_solamo_color
    hi  link    gtdSeparator            Special
    hi  link    gtdDate                 String
    hi  link    gtdOverdueDate          hl_red
"    hi  link    gtdPlanDate             hl_magenta
    hi  link    gtdTitle                Title
    hi  link    gtdPlanned              hl_blue
"    hi  link    gtdToday                hl_yellow_l
    hi  link    gtdEmergency            hl_yellow
    hi  link    gtdOverdue              hl_red
    hi  link    gtdHighPrio             hl_orange_l
    hi  link    gtdLowPrio              Comment
"    hi  link    gtdSubstep              PreProc
    hi  link    gtdFinished             hl_green_d
    hi  link    gtdContext              hl_cyan
    hi  link    gtdWorker               hl_brown
    hi          gtdBold                 cterm=bold              gui=bold
    hi  link    gtdNote                 Comment
    hi  link    gtdComment              Comment
    hi          gtdBrace                ctermfg=DarkGray        guifg=#303030
else
    hi          gtdSeparator            ctermfg=DarkCyan        guifg=DarkCyan
    hi          gtdDate                 ctermfg=DarkCyan        guifg=DarkCyan
    hi          gtdOverdueDate          ctermfg=DarkRed         guifg=DarkRed
"    hi          gtdPlanDate             ctermfg=DarkCyan        guifg=DarkCyan
    hi          gtdTitle                ctermfg=DarkMagenta     guifg=DarkMagenta
    hi          gtdPlanned              ctermfg=Cyan            guifg=Cyan
"    hi          gtdToday                ctermfg=Yellow          guifg=Yellow
    hi          gtdEmergency            ctermfg=DarkYellow      guifg=DarkYellow
    hi          gtdOverdue              ctermfg=DarkRed         guifg=DarkRed
    hi          gtdHighPrio             ctermfg=DarkYellow      guifg=DarkYellow
    hi          gtdLowPrio              ctermfg=DarkGray        guifg=DarkGray
"    hi          gtdSubstep              ctermfg=DarkBlue        guifg=DarkBlue
    hi          gtdFinished             ctermfg=DarkGreen       guifg=DarkGreen
    hi          gtdContext              ctermfg=DarkCyan        guifg=DarkCyan
    hi          gtdWorker               ctermfg=Blue            guifg=Blue
    hi          gtdBold                 cterm=bold              gui=bold
    hi          gtdNote                 ctermfg=DarkGray        guifg=DarkGray
    hi          gtdComment              ctermfg=DarkGray        guifg=DarkGray
    hi          gtdBrace                ctermfg=DarkGray        guifg=DarkGray
endif


let b:current_syntax = "gtd"

" vim: ts=4
