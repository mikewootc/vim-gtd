" ------------------------------------------------------------------------------
" Options
" ------------------------------------------------------------------------------
if !exists("g:gtd_auto_check_overdue")
    let g:gtd_auto_check_overdue = 0
endif

if !exists("g:gtd_check_overdue_auto_save")
    let g:gtd_check_overdue_auto_save = 0
endif

if !exists("g:sched_list_with_parents")
    let g:sched_list_with_parents = 1
endif

if !exists("g:gtd_auto_update_sched_list")
    let g:gtd_auto_update_sched_list = 1
endif

if !exists("g:gtd_emergency_days")
    let g:gtd_emergency_days = 7
endif

if !exists("g:gtd_date_align_col")
    let g:gtd_date_align_col = 101
endif

if !exists("g:gtd_align_date_when_exit_insert")
    let g:gtd_align_date_when_exit_insert = 1
endif

let g:schedBufferName = "__gtd_sched_list__"
let g:dateWidth = 14


" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
  finish
endif

" Don't load another plugin for this buffer
let b:did_ftplugin = 1

"if exists("b:loaded_gtd") || &cp
"  finish
"endif
"let b:loaded_gtd = 1

" ------------------------------------------------------------------------------
" Python stuff
" ------------------------------------------------------------------------------

python << EOF
import datetime, time, vim

# Calc the date interval of (endDate - startDate)
# startDate: string looks like: 20170827
# endDate  : string looks like: 20170827
# return   : date interval. And return value for vim is in b:pyRet.
def DateDiffer(startDate, endDate):
    timeS = time.strptime(vim.eval(startDate),"%Y%m%d")
    timeE = time.strptime(vim.eval(endDate),"%Y%m%d")
    startDate = datetime.datetime(timeS[0],timeS[1],timeS[2],timeS[3],timeS[4],timeS[5])
    endDate   = datetime.datetime(timeE[0],timeE[1],timeE[2],timeE[3],timeE[4],timeE[5])
    differ = (endDate - startDate).days

    b = vim.current.buffer
    b.vars["pyRet"] = differ
    return differ
EOF

" ------------------------------------------------------------------------------
" Main stuff
" ------------------------------------------------------------------------------

" Get virtcol of pat in cursor-line.
func! GetVirtCol(pat)
    let line = getline(".")
    let theMatch = match(line, a:pat)
    if theMatch < 0
        return theMatch
    endif
    let cursorBak = getcurpos()
    call cursor(".", theMatch)
    let theVirtCol = virtcol(".")
    call cursor(cursorBak[1], cursorBak[2])
    return theVirtCol
endfunc

" Toggle fold
func! ToggleFold()
    if foldlevel('.') > 0
        if foldclosed('.') != -1 " Folded
            exec "normal zO"
        else
            exec "normal zC"
        endif
    endif
"    let b:fold_status += 1
"    if b:fold_status > 2
"        let b:fold_status = 0
"        exec "normal zM"
"    else
"        exec "normal zr"
"    endif
"    echo "Fold: " . b:fold_status
endfunc

" return: [1, type, date(2017-09-16)] if true; [0, "", ""]: if false
func! IsCursorOnDate()
    let c = getline('.')[col('.')-1]  " only one character under cursor
    if c == ' '
        return [0, '', '']
    endif

    let keywordBak = &iskeyword
    set iskeyword+=-
    set iskeyword+=:
    let word = expand('<cword>')
    let &iskeyword = keywordBak

    if match(word, '\a:\d\{4}-\d\{2}-\d\{2}') >= 0
        echom "is on date"
        let ret = extend([1], split(word, ':'))
        return ret
    else
        return [0, '', '']
    endif
endfunc

function! SelectDate()
    let ret = IsCursorOnDate()
    if ret[0] == 1
        "echom "is on date"
        let g:preBufNr = bufnr('%')
        "echom 'in gtd preBufNr: ' . g:preBufNr
        call GtdCalendar(0)
    endif
endfunc

function! SelectDateAfter()
    echom "SelectDateAfter"
    let ret = IsCursorOnDate()
    if ret[0] == 1 && exists("g:gtdCalendarSelectedDate")
        let year    = g:gtdCalendarSelectedDate[0]
        let month   = g:gtdCalendarSelectedDate[1]
        if month < 10
            let month = '0' . month
        endif
        let day     = g:gtdCalendarSelectedDate[2]
        if day < 10
            let day = '0' . day
        endif
        let dateString = year . "-" . month . "-" . day

        let line = getline(".")
        echom line
        let newLine = substitute(line, '\[' . ret[1] . ':' . '\d\{4}-\d\{2}-\d\{2}' . '\]', '\[' . ret[1] . ':' . dateString . '\]', '')
        call setline(".", newLine)
    endif
endfunc


" Get date of specific type
" line  : text content of line
" type  : "p":plan ; "f":complete; "e":emergency; "o":overdue
" return: the date string looks like: 20170827
func! GetDate(line, type)
    let dateRaw = matchstr(a:line, a:type . ":\\d\\{4}-\\d\\{2}-\\d\\{2}")
    let repl = substitute(dateRaw, a:type . ":", "", "g")
    let date = substitute(repl, "-", "", "g")
    return date
endfunc

" Add date on current(cursor) line.
" dateType: "p" / "f" / ...
" colNum  : Align date to colNum.
func! AddDate(dateType, colNum)
    let line = getline(".")
    exec "normal $"
    let width = virtcol(".")
    let newLine = line . repeat(" ", a:colNum - width - 1) . strftime("[" . a:dateType . ":%Y-%m-%d]")
    call setline(".", newLine)
endfunc

" Align specified date
func! AlignSpeciDate(dateType, colNum)
    let line = getline(".")
    let planDateCol = GetVirtCol('\[' . a:dateType . ':')
    if planDateCol > 0
        if planDateCol > a:colNum       " Should move left
            let leftSpaceCol = GetVirtCol(' \+\[' . a:dateType . ':')
            if leftSpaceCol < planDateCol " Could move
                let couldMove  = planDateCol - leftSpaceCol - 1
                let shouldMove = planDateCol - a:colNum + 1
                let shouldMove = couldMove >= shouldMove ? shouldMove : couldMove
                let newLine = substitute(line, repeat(" ", shouldMove) . '\(\[' . a:dateType . '\)', '\1', '')
                call setline(".", newLine)
            endif
        elseif planDateCol < a:colNum   " Should move right
            let shouldMove = a:colNum - planDateCol - 1
            let newLine = substitute(line, '\(\[' . a:dateType . '\)', repeat(" ", shouldMove) . '\1', '')
            call setline(".", newLine)
        endif
    endif
endfunc

func! AlignDate()
    call AlignSpeciDate('[poe]', g:gtd_date_align_col)
    call AlignSpeciDate('f',     g:gtd_date_align_col + g:dateWidth)
endfunc

" Check if the todos if overdued or emergency.
" This function would go through the whole content of current buffer.
func! CheckOverdue()
    let totalLines = line('$')
    let i = 1

    while i <= totalLines
        let line = getline(i)                                   "echom line
        let planDate = GetDate(line, "[peo]")
        let completeDate = GetDate(line, "f")                   "echom 'completeDate: ' . completeDate
        if completeDate
            "echom "Completed"
        else " Not completed
            let today = strftime("%Y%m%d")
            if planDate
                if today > planDate                     " overdue
                    if match(line, '\[[ep]:') > 0
                        let repl = substitute(line, '\[[ep]:', "[o:", "")
                        call setline(i, repl)
                    endif
                else
                    python DateDiffer(vim.eval("today"), vim.eval("planDate"))
                    if b:pyRet < g:gtd_emergency_days   " emergency
                        if match(line, '\[[op]:') > 0
                            let repl = substitute(line, '\[[op]:', "[e:", "")
                            call setline(i, repl)
                        endif
                    else                                " just planned
                        if match(line, '\[[oe]:') > 0
                            let repl = substitute(line, '\[[oe]:', "[p:", "")
                            call setline(i, repl)
                        endif
                    endif
                endif
            endif
        endif

        let i = i + 1
    endw

    if g:gtd_check_overdue_auto_save
        silent! w
    endif
endfunc

" Get the todo indent level, count from 1. calc by: (line_indents space / &tabstop)
" line  : text string of line.
" return: indent level.
func! GetTodoLevel(line)
    let step = &tabstop
    let indents = match(a:line, "\\S")

    if indents < 0
        return -1
    endif
    return (indents / step) + 1
endfunc

" Add sched in: curSchedStack into list: schedList.
" This function is order to add scheds into list with its ancestors.
" schedList    : sched list
" curSchedStack: sched to add
" preSchedStack: previously added sched
" e.g. If the context is:
"   [ ] GrandpaSched
"       [ ] FatherSched
"           [ ] CousinSched
"           [ ] CurrentSchedToAdd
" then: curSchedStack = ['[ ] GrandpaSched', '[ ] FatherSched', '[ ] CurrentSchedToAdd']
"       preSchedStack = ['[ ] GrandpaSched', '[ ] FatherSched', '[ ] CousinSched']
func! SchedListAdd(schedList, curSchedStack, preSchedStack)
    if g:sched_list_with_parents
        let curSchedStackLen = len(a:curSchedStack)
        let preSchedStackLen = len(a:preSchedStack)
        let i = 0
        while i < curSchedStackLen
            if i < preSchedStackLen && a:curSchedStack[i] == a:preSchedStack[i]
                let i = i + 1
                continue
            endif

            call add(a:schedList, a:curSchedStack[i])
            let i = i + 1
        endw
    else
        call add(a:schedList, a:curSchedStack[len(a:curSchedStack)-1])
    endif
endfunc

" Open a window to show sched list.
" list  : the sched lines to show. Each item of the list is a text line.
" return: none
func! SchedListOpen(list)
    " Open list buffer
    let listBufNum = bufnr(g:schedBufferName)
    if listBufNum == -1                         " Has no list buffer
        exe "split " . g:schedBufferName
    else                                        " Already has buffer
        let listWinNum = bufwinnr(listBufNum)
        if listWinNum != -1                     " Has sched list win ...
            if winnr() != listWinNum            " ... but but current win, then jump to it.
                exe listWinNum . "wincmd w"
            endif
        else                                    " Has no sched win, then open it by split.
            exe "split +buffer" . listBufNum
        endif
    endif

    " Write content
    setlocal modifiable
    %delete
    for line in a:list
        call append(line('$'), line)
    endfor
    1delete
    setlocal nomodifiable
endfunc

" This function will go through all buffers to find 'gtd' file, and extract
" all scheds which are planned, and then show them in a splited window.
func! SchedList()
    let listEmergency       = []
    let listOverdue         = []
    let listPlanned         = []
    let bufferAmount        = bufnr("$")
    let bnr = 1 " Buffer number
    while bnr <= bufferAmount " Go through all buffers
        let bname = bufname(bnr)
        let btype = getbufvar(bnr, '&ft')

        if btype != "gtd"
            let bnr = bnr + 1
            continue
        endif

        if bname == g:schedBufferName
            let bnr = bnr + 1
            continue
        endif


        let allLines = readfile(bname)
        if len(allLines) <= 0 " Empty file
            let bnr = bnr + 1
            continue
        endif

        let curSchedStack = []
        let preOSchedStack = []
        let preESchedStack = []
        let prePSchedStack = []
"        for line in allLines
        let i = 0
        while i < len(allLines)
            let line = allLines[i]
            let schedLevel = GetTodoLevel(line)
            if schedLevel < 0 " Empty line
                let i += 1
                continue
            endif

            let schedLine = line . '  <l:' . bname . ':' . (i + 1) . '>'
            let stackLen = len(curSchedStack)
            if schedLevel > stackLen                 " sub-level
                call add(curSchedStack, schedLine)
            elseif schedLevel == stackLen            " same-level
                let curSchedStack[stackLen - 1] = schedLine
            elseif schedLevel < stackLen             " parent-level
                call remove(curSchedStack, schedLevel - 1, stackLen - 1)
                call add(curSchedStack, schedLine)
            endif

            let finished = GetDate(line, "f")
            if finished
                let i += 1
                continue
            endif

            let overdueDate = GetDate(line, "o")
            if overdueDate
                call SchedListAdd(listOverdue, curSchedStack, preOSchedStack)
                let preOSchedStack = copy(curSchedStack)
            endif

            let emergencyDate = GetDate(line, "e")
            if emergencyDate
                call SchedListAdd(listEmergency, curSchedStack, preESchedStack)
                let preESchedStack = copy(curSchedStack)
            endif

            let plannedDate = GetDate(line, "p")
            if plannedDate
                call SchedListAdd(listPlanned, curSchedStack, prePSchedStack)
                let prePSchedStack = copy(curSchedStack)
            endif
"        endfor
        let i += 1
        endw

        let bnr = bnr + 1
    endw

    let list = []
    let list = add(list, "o ==========================================================")
    let list = list + listOverdue
    let list = add(list, "e ==========================================================")
    let list = list + listEmergency
    let list = add(list, "p ==========================================================")
    let list = list + listPlanned
    call SchedListOpen(list)
endfunc

func! SchedListUpdate()
    let i = 1
    while i <= winnr('$')
        let bnr = winbufnr(i)
        let wname = bufname(bnr)
        if wname == g:schedBufferName
            call SchedList()
        endif
        let i += 1
    endw
endfunc

function! SchedListBufInit()
    setlocal filetype=gtt
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal nobuflisted
    setlocal noswapfile
    setlocal nolist
    setlocal nowrap
    setlocal textwidth=0
endfunc

function! GtdBufInit()
    setlocal foldmethod=marker
    setlocal expandtab
    let b:fold_status=0
endfunc

" personal {{{
func! GetTodoLine()
    let todoLine = getline(".")
    let todoLine = substitute(todoLine, '^\s*\[.\] *', "", "")
    let todoLine = substitute(todoLine, '\s*\[.:\d\{4}-\d\{2}-\d\{2}\]', "", "")
    let todoLine = substitute(todoLine, '<.*:\d\+>', "", "")
    let todoLine = "'" . todoLine . " 明天'"
    return todoLine
endfunc
" personal }}}


" Commands =====================================================================
command! ToggleFold         call ToggleFold()
command! AddDatePlan        call AddDate("p", g:gtd_date_align_col)
command! AddDateFinish      call AddDate("f", g:gtd_date_align_col + g:dateWidth)
command! CheckOverdue       call CheckOverdue()
command! SchedList           call SchedList()
command! AlignDate          call AlignDate()

autocmd BufEnter        __gtd_sched_list__       call SchedListBufInit()
autocmd BufEnter        *.gtd,*.gtdt            call GtdBufInit()
if g:gtd_pickup_date_from_calendar
autocmd BufEnter        *.gtd,*.gtdt silent!    call SelectDateAfter()
endif
if g:gtd_auto_update_sched_list
autocmd BufWritePost    *.gtd,*.gtdt            call SchedListUpdate()
endif
if g:gtd_auto_check_overdue
autocmd BufEnter        *.gtd silent!           call CheckOverdue()
autocmd BufWritePre     *.gtd silent!           call CheckOverdue()
endif

" Setting ======================================================================

" t Auto-wrap text using textwidth
" c Auto-wrap comments using textwidth, inserting the current comment
" r Automatically insert the current comment leader after hitting <Enter> in Insert mode.
" o Automatically insert the current comment leader after hitting 'o' or 'O' in Normal mode.
" q Allow formatting of comments with "gq".
" l Long lines are not broken in insert mode: When a line was longer than 'textwidth' when the insert command started, Vim does not automatically format it.
setlocal fo-=t fo-=c fo+=roql
setlocal comments=://

