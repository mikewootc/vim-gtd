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
syn region  gtdPlanDate start=/\[p:/ end=/\]/ oneline contains=gtdDate

" ----------------------------------------
" Overdue date
syn region  gtdOverdueDate start=/\[o:/ end=/\]/ oneline

" ----------------------------------------
" Normal Task(planned)
syn match   gtdPlannedSteps "[^\]]*\[p:"me=e-3 contains=gtdDate,gtdContext,gtdWorker
"syn match   gtdPlannedSteps "^\s*\[\*\] " nextgroup=gtdPlanDate

" ----------------------------------------
" Emergency Task
syn match   gtdEmergencySteps "[^\]]*\[e:"me=e-3 contains=gtdDate,gtdContext,gtdWorker

" ----------------------------------------
" Overdue Task
syn match   gtdOverdueSteps "[^\]]*\[o:"me=e-3 contains=gtdDate,gtdContext,gtdWorker

" ----------------------------------------
" High prio Task
syn match   gtdHighPrioSteps "^\s*\[\*\] " contains=ALL
"hi          gtdHighSteps ctermfg=DarkYellow   guifg=DarkYellow

" ----------------------------------------
" Substeps
syn match   gtdSubstep "^\s*\*.\+" contains=gtdDate,gtdContext,gtdWorker

" ----------------------------------------
" Finished
"syn match   gtdFinished '.\+\(\[f:\)\@='
syn match   gtdFinished '.\+\[f:\d\{4}.\d\{2}.\d\{2}\]' contains=gtdOverdueDate

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
    hi  link    gtdPlanDate             hl_magenta
    hi  link    gtdTitle                Title
    hi  link    gtdPlannedSteps         hl_blue
    hi  link    gtdEmergencySteps       hl_yellow
    hi  link    gtdOverdueSteps         hl_red
    hi  link    gtdHighPrioSteps        hl_orange_l
    hi  link    gtdSubstep              PreProc
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
    hi          gtdPlanDate             ctermfg=DarkCyan        guifg=DarkCyan
    hi          gtdTitle                ctermfg=DarkMagenta     guifg=DarkMagenta
    hi          gtdPlannedSteps         ctermfg=Cyan            guifg=Cyan
    hi          gtdEmergencySteps       ctermfg=DarkYellow      guifg=DarkYellow
    hi          gtdOverdueSteps         ctermfg=DarkRed         guifg=DarkRed
    hi          gtdHighPrioSteps        ctermfg=DarkYellow      guifg=DarkYellow
    hi          gtdSubstep              ctermfg=DarkBlue        guifg=DarkBlue
    hi          gtdFinished             ctermfg=DarkGreen       guifg=DarkGreen
    hi          gtdContext              ctermfg=DarkCyan        guifg=DarkCyan
    hi          gtdWorker               ctermfg=Blue            guifg=Blue
    hi          gtdBold                 cterm=bold              gui=bold
    hi          gtdNote                 ctermfg=DarkGray        guifg=DarkGray
    hi          gtdComment              ctermfg=DarkGray        guifg=DarkGray
    hi          gtdBrace                ctermfg=DarkGray        guifg=DarkGray
endif

" vim: ts=4
