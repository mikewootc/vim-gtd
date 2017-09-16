" ------------------------------------------------------------------------------
" Options
" ------------------------------------------------------------------------------
if !exists("g:gtd_auto_check_overdue")
    let g:gtd_auto_check_overdue = 0
endif

if !exists("g:gtd_check_overdue_auto_save")
    let g:gtd_check_overdue_auto_save = 0
endif

if !exists("g:task_list_with_parents")
    let g:task_list_with_parents = 1
endif

if !exists("g:gtd_auto_update_tasklist")
    let g:gtd_auto_update_tasklist = 1
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

let g:taskBufferName = "__gtd_task_list__"
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
    let keywordBak = &iskeyword
    set iskeyword+=-
    set iskeyword+=:
    let word = expand('<cword>')
    let &iskeyword = keywordBak

    if match(word, '\a:\d\{4}-\d\{2}-\d\{2}') >= 0
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
        call Calendar(0)
    endif
endfunc

function! SelectDateAfter()
    let ret = IsCursorOnDate()
    if ret[0] == 1 && exists("g:calendarSelectedDate")
        let year    = g:calendarSelectedDate[0]
        let month   = g:calendarSelectedDate[1]
        if month < 10
            let month = '0' . month
        endif
        let day     = g:calendarSelectedDate[2]
        if day < 10
            let day = '0' . day
        endif
        let dateString = year . "-" . month . "-" . day

        let line = getline(".")
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

" Check if the tasks if overdued or emergency.
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

" Get the task indent level, count from 1. calc by: (line_indents space / &tabstop)
" line  : text string of line.
" return: indent level.
func! GetTaskLevel(line)
    let step = &tabstop
    let indents = match(a:line, "\\S")

    if indents < 0
        return -1
    endif
    return (indents / step) + 1
endfunc

" Add task in: curTaskStack into list: taskList.
" This function is order to add tasks into list with its ancestors.
" taskList    : task list
" curTaskStack: task to add
" preTaskStack: previously added task
" e.g. If the context is:
"   [ ] GrandpaTask
"       [ ] FatherTask
"           [ ] CousinTask
"           [ ] CurrentTaskToAdd
" then: curTaskStack = ['[ ] GrandpaTask', '[ ] FatherTask', '[ ] CurrentTaskToAdd']
"       preTaskStack = ['[ ] GrandpaTask', '[ ] FatherTask', '[ ] CousinTask']
func! TaskListAddTask(taskList, curTaskStack, preTaskStack)
    if g:task_list_with_parents
        let curTaskStackLen = len(a:curTaskStack)
        let preTaskStackLen = len(a:preTaskStack)
        let i = 0
        while i < curTaskStackLen
            if i < preTaskStackLen && a:curTaskStack[i] == a:preTaskStack[i]
                let i = i + 1
                continue
            endif

            call add(a:taskList, a:curTaskStack[i])
            let i = i + 1
        endw
    else
        call add(a:taskList, a:curTaskStack[len(a:curTaskStack)-1])
    endif
endfunc

" Open a window to show task list.
" list  : the task lines to show. Each item of the list is a text line.
" return: none
func! OpenTaskList(list)
    " Open list buffer
    let listBufNum = bufnr(g:taskBufferName)
    if listBufNum == -1                         " Has no list buffer
        exe "split " . g:taskBufferName
    else                                        " Already has buffer
        let listWinNum = bufwinnr(listBufNum)
        if listWinNum != -1                     " Has task list win ...
            if winnr() != listWinNum            " ... but but current win, then jump to it.
                exe listWinNum . "wincmd w"
            endif
        else                                    " Has no task win, then open it by split.
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
" all tasks which are planned, and then show them in a splited window.
func! TaskList()
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

        if bname == g:taskBufferName
            let bnr = bnr + 1
            continue
        endif


        let allLines = readfile(bname)
        if len(allLines) <= 0 " Empty file
            let bnr = bnr + 1
            continue
        endif

        let curTaskStack = []
        let preOTaskStack = []
        let preETaskStack = []
        let prePTaskStack = []
"        for line in allLines
        let i = 0
        while i < len(allLines)
            let line = allLines[i]
            let taskLevel = GetTaskLevel(line)
            if taskLevel < 0 " Empty line
                let i += 1
                continue
            endif

            let taskLine = line . '  <l:' . bname . ':' . (i + 1) . '>'
            let stackLen = len(curTaskStack)
            if taskLevel > stackLen                 " sub-level
                call add(curTaskStack, taskLine)
            elseif taskLevel == stackLen            " same-level
                let curTaskStack[stackLen - 1] = taskLine
            elseif taskLevel < stackLen             " parent-level
                call remove(curTaskStack, taskLevel - 1, stackLen - 1)
                call add(curTaskStack, taskLine)
            endif

            let finished = GetDate(line, "f")
            if finished
                let i += 1
                continue
            endif

            let overdueDate = GetDate(line, "o")
            if overdueDate
                call TaskListAddTask(listOverdue, curTaskStack, preOTaskStack)
                let preOTaskStack = copy(curTaskStack)
            endif

            let emergencyDate = GetDate(line, "e")
            if emergencyDate
                call TaskListAddTask(listEmergency, curTaskStack, preETaskStack)
                let preETaskStack = copy(curTaskStack)
            endif

            let plannedDate = GetDate(line, "p")
            if plannedDate
                call TaskListAddTask(listPlanned, curTaskStack, prePTaskStack)
                let prePTaskStack = copy(curTaskStack)
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
    call OpenTaskList(list)
endfunc

func! TaskListUpdate()
    let i = 1
    while i <= winnr('$')
        let i += 1
        let bnr = winbufnr(i)
        let wname = bufname(bnr)
        if wname == g:taskBufferName
            call TaskList()
        endif
    endw
endfunc

function! TaskListBufInit()
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
func! GetTaskLine()
    let taskLine = getline(".")
    let taskLine = substitute(taskLine, '^\s*\[.\] *', "", "")
    let taskLine = substitute(taskLine, '\s*\[.:\d\{4}-\d\{2}-\d\{2}\]', "", "")
    let taskLine = substitute(taskLine, '<.*:\d\+>', "", "")
    let taskLine = "'" . taskLine . " 明天'"
    return taskLine
endfunc
" personal }}}


" Commands =====================================================================
command! ToggleFold         call ToggleFold()
command! AddDatePlan        call AddDate("p", g:gtd_date_align_col)
command! AddDateFinish      call AddDate("f", g:gtd_date_align_col + g:dateWidth)
command! CheckOverdue       call CheckOverdue()
command! TaskList           call TaskList()
command! AlignDate          call AlignDate()

autocmd BufEnter        __gtd_task_list__   call TaskListBufInit()
autocmd BufEnter        *.gtd,*.gtdt        call GtdBufInit()
if g:gtd_pickup_date_from_calendar
autocmd BufEnter        *.gtd,*.gtdt        call SelectDateAfter()
endif
if g:gtd_auto_update_tasklist
autocmd BufWritePost    *.gtd,*.gtdt        call TaskListUpdate()
endif
if g:gtd_auto_check_overdue
autocmd BufEnter        *.gtd silent!       call CheckOverdue()
endif

" Setting ======================================================================
setlocal fo-=t fo-=c fo+=roql
setlocal comments=://

