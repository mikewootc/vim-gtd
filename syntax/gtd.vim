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
" Tag Daily
syn match   gtdDaily "<d\d:->"
syn match   gtdDailyFinished "<d\d:v>"
syn match   gtdDailyFailed "<d\d:x>"

" ---------------------------------------- 
" Tag except
syn match   gtdShouldNot "<shnot>"
syn match   gtdShould    "<right>"

" ----------------------------------------
" Overdue date
syn region  gtdOverdueDate start=/\[o:/ end=/\]/ oneline

" ----------------------------------------
" Normal(planned)
syn match   gtdPlanned "[^\]]*\[p:"me=e-3 contains=gtdDate,gtdContext,gtdWorker,gtdDaily,gtdDailyFinished,gtdDailyFailed
"syn match   gtdPlanned "^\s*\[\*\] " nextgroup=gtdPlanDate

" ----------------------------------------
" Today
syn match   gtdToday "[^\]]*\[t:"me=e-3 contains=gtdDate,gtdContext,gtdWorker,gtdDaily,gtdDailyFinished,gtdDailyFailed

" ----------------------------------------
" Emergency
syn match   gtdEmergency "[^\]]*\[e:"me=e-3 contains=gtdDate,gtdContext,gtdWorker,gtdDaily,gtdDailyFinished,gtdDailyFailed
"syn match   gtdEmergency "^\s*\* .\+\[e:"me=e-3 contains=gtdDate,gtdContext,gtdWorker

" ----------------------------------------
" Overdue
syn match   gtdOverdue "[^\]]*\[o:"me=e-3 contains=gtdDate,gtdContext,gtdWorker,gtdDaily,gtdDailyFinished,gtdDailyFailed
"syn match   gtdOverdue "\* *\[o:"me=e-3 contains=gtdDate,gtdContext,gtdWorker

" ----------------------------------------
" Finished
syn match   gtdFinished '.\+\[f:\d\{4}.\d\{2}.\d\{2}\]' contains=gtdOverdueDate,gtdDaily,gtdDailyFinished,gtdDailyFailed,gtdShould,gtdShouldNot

" ----------------------------------------
" Moved away 子弹笔记的移走
syn match   gtdMovedAway '\* > .*'

" ----------------------------------------
" Moved in 子弹笔记的移入
syn match   gtdMovedIn '\* < .*'
syn match   gtdMovedIn '^\s*< .*'

" ----------------------------------------
" Failed
syn match   gtdFailed '^\s*\~ .*'
syn match   gtdFailed '\* \~ .*'
syn match   gtdFailed '\d\+\. \~ .*'


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
syn match   gtdComment "\/\/.*" contains=gtdShouldNot,gtdShould
syn match   gtdComment "\s*\d\+\. \+\/\/.*" contains=gtdShouldNot,gtdShould

" ----------------------------------------
" Brace
syn match   gtdBrace "{{{\d*"
syn match   gtdBrace "}}}\d*"

" ----------------------------------------
" Item ID
"syn match   gtdItemId '<id:\d{8}-\d{6}>' conceal
syn match   gtdItemId /<id:\d\{8}-\d\{6}>/ conceal



if exists("g:gtd_use_solamo_color") && g:gtd_use_solamo_color
    hi  link    gtdSeparator            Special
    hi  link    gtdDate                 String
    hi  link    gtdOverdueDate          hl_red_l
    hi  link    gtdDaily                Normal
    hi  link    gtdDailyFinished        hl_green_d
    hi  link    gtdDailyFailed          hl_red_l
    hi  link    gtdShould               hl_green_l
    hi  link    gtdShouldNot            hl_red_l
"    hi  link    gtdPlanDate             hl_magenta
    hi  link    gtdTitle                Title
    hi  link    gtdPlanned              hl_blue
    hi  link    gtdToday                hl_orange
    hi  link    gtdEmergency            hl_yellow
    hi  link    gtdOverdue              hl_red_l
    hi  link    gtdHighPrio             hl_orange_l
    hi  link    gtdLowPrio              Comment
"    hi  link    gtdSubstep              PreProc
    hi  link    gtdFinished             hl_green_d
    hi  link    gtdFailed               hl_red
    hi  link    gtdMovedIn              hl_cyan_d
    hi  link    gtdContext              hl_cyan
    hi  link    gtdWorker               hl_brown
    hi          gtdBold                 cterm=bold              gui=bold
    hi  link    gtdNote                 Comment
    hi  link    gtdComment              Comment
    hi  link    gtdMovedAway            Comment
    hi          gtdBrace                ctermfg=DarkGray        guifg=#303030
    hi  link    gtdItemId               hl_gray_dd
else
    hi          gtdSeparator            ctermfg=DarkCyan        guifg=DarkCyan
    hi          gtdDate                 ctermfg=DarkCyan        guifg=DarkCyan
    hi          gtdOverdueDate          ctermfg=DarkRed         guifg=DarkRed
    hi link     gtdDaily                Normal
    hi          gtdDailyFinished        ctermfg=DarkGreen       guifg=DarkGreen
    hi          gtdDailyFailed          ctermfg=DarkRed         guifg=DarkRed
    hi          gtdShould               ctermfg=LightGreen      guifg=LightGreen
    hi          gtdShouldNot            ctermfg=DarkRed         guifg=DarkRed
    hi          gtdTitle                ctermfg=DarkMagenta     guifg=DarkMagenta
    hi          gtdPlanned              ctermfg=Cyan            guifg=Cyan
    hi          gtdToday                ctermfg=Yellow          guifg=Yellow
    hi          gtdEmergency            ctermfg=DarkYellow      guifg=DarkYellow
    hi          gtdOverdue              ctermfg=DarkRed         guifg=DarkRed
    hi          gtdHighPrio             ctermfg=DarkYellow      guifg=DarkYellow
    hi          gtdLowPrio              ctermfg=DarkGray        guifg=DarkGray
    hi          gtdFinished             ctermfg=DarkGreen       guifg=DarkGreen
    hi          gtdFailed               ctermfg=DarkRed         guifg=DarkRed
    hi          gtdMovedIn              ctermfg=Magenta         guifg=DarkCyan
    hi          gtdContext              ctermfg=DarkCyan        guifg=DarkCyan
    hi          gtdWorker               ctermfg=Blue            guifg=Blue
    hi          gtdBold                 cterm=bold              gui=bold
    hi          gtdNote                 ctermfg=DarkGray        guifg=DarkGray
    hi          gtdComment              ctermfg=DarkGray        guifg=DarkGray
    hi          gtdBrace                ctermfg=DarkGray        guifg=DarkGray
    hi          gtdItemId               ctermfg=DarkGray        guifg=DarkGray
endif


let b:current_syntax = "gtd"

" vim: ts=4
