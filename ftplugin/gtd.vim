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

if !exists("g:gtd_auto_update_task_list")
    let g:gtd_auto_update_task_list = 1
endif

if !exists("g:gtd_task_list_lines")
    let g:gtd_task_list_lines = 15
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

let g:listBufferName = "__gtd_list_buffer__"
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
"exec 'pyfile ' . getcwd() . '/gtd.py'

let s:_py="python3 "
if !has("python3")
    if !has("python")
        echohl WarningMsg
        echom  "mgtd requires py >= 2.7 or py3"
        echohl None
        unlet s:_py
        finish
    endif
    let s:_py="python "
endif

let s:plug = expand("<sfile>:p:h:h")
let s:script = s:plug . '/script/gtd.py'
if has('python3')
    exec 'py3file ' . fnameescape(s:script)
elseif has('python')
    exec 'pyfile ' . fnameescape(s:script)
endif

let s:strIdPattern = '\d\{8}-\d\{6}'
let s:strIdTagPattern = '<id:\d\{8}-\d\{6}>'


" ------------------------------------------------------------------------------
" Main stuff
" ------------------------------------------------------------------------------

" Get virtcol of pat in cursor-line. Count from 1.
func! GetVirtCol(pat)
    let line = getline(".")
    let theMatch = match(line, a:pat)
    if theMatch < 0
        return theMatch
    endif
    let cursorBak = getcurpos()
    call cursor(".", theMatch + 1) " theMatch count from 0, but the curpos count from 1, so +1.
    let theVirtCol = virtcol(".")
    call cursor(cursorBak[1], cursorBak[2])
    "echom theMatch theVirtCol
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

" Return: project, task, comment, ...
func! GetLineType(line)
    if match(a:line, '^\s*\* ') >= 0
        return 'task'
    elseif match(a:line, '^\s*\[.\] ') >= 0
        return 'project'
    else
        return 'other'
    endif
endfunc

func! SelectDate()
    let ret = IsCursorOnDate()
    if ret[0] == 1
        "echom "is on date"
        let g:preBufNr = bufnr('%')
        "echom 'in gtd preBufNr: ' . g:preBufNr
        call GtdCalendar(0)
    endif
endfunc

func! SelectDateAfter()
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
        unlet g:gtdCalendarSelectedDate
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

"    if len(date) == 0
"        return -1
"    endif

    return date
endfunc

func! GetDueDate(line)
    return GetDate(a:line, "[peto]")
endfunc

" Add a string to current (at tail)
" str: string to add to current line
" colNum: column to align to.
func! AddStringToCurLine(str, colNum)
    let line = getline(".")
    exec "normal $"
    if a:colNum >= 0
        let width = virtcol(".")
        let r = repeat(" ", a:colNum - width - 1)
    else
        let r = ''
    endif
    let newLine = line . r . a:str
    call setline(".", newLine)
endfunc

" Add date on current(cursor) line.
" dateType: "p" / "f" / ...
" colNum  : Align date to colNum.
func! AddDate(dateType, colNum)
"    let line = getline(".")
"    exec "normal $"
"    let width = virtcol(".")
"    let newLine = line . repeat(" ", a:colNum - width - 1) . strftime("[" . a:dateType . ":%Y-%m-%d]")
"    call setline(".", newLine)

    call AddStringToCurLine(strftime("[" . a:dateType . ":%Y-%m-%d]"), a:colNum)
endfunc

func! FinishRepeatedTask()
    let line = getline(".")
    let planDate = GetDueDate(line)
    "if has('python3')
    "    python3 PyDateAdd(vim.eval("planDate"), 1, "%Y-%m-%d")
    "else
    "    python PyDateAdd(vim.eval("planDate"), 1, "%Y-%m-%d")
    "endif
    exec s:_py . 'PyDateAdd(vim.eval("planDate"), 1, "%Y-%m-%d")'
    "echom 'new date' b:pyRet

    let newLine = substitute(line, '\([peto]:\)\d\{4}-\d\{2}-\d\{2}', '\1' . b:pyRet, '') " Calc new date
    "echom "newLine" newLine
    exec "normal zRyy"
    call AddDate("f", g:gtd_date_align_col + g:dateWidth)
    exec "normal p"
    call setline(".", newLine)
endfunc

" Change mark of daily routine task like:
"   <d1:v><d2:v><d3:-><d4:-><d5:-><d6:-><d7:-> Get up early. [t:2018-04-04]
" Where <d2:v> means finished, <d3:->means next todo(tomorrow).
" NOTE: Just support less than 10 days(since just checked 1 '\d' character) now.
" mark: 'v': finished, 'x': failed.
func! ChangeRepeatedTaskMark(mark)
    let line = getline(".")
    let planDate = GetDueDate(line)
    " Calc the next day.
    "if has('python3')
    "    python3 PyDateAdd(vim.eval("planDate"), 1, "%Y-%m-%d")
    "else
    "    python PyDateAdd(vim.eval("planDate"), 1, "%Y-%m-%d")
    "endif
    exec s:_py . 'PyDateAdd(vim.eval("planDate"), 1, "%Y-%m-%d")'

    let line = substitute(line, '\([peto]:\)\d\{4}-\d\{2}-\d\{2}', '\1' . b:pyRet, '') " substitute date to then next day.
    let line = substitute(line, '<d\(\d\):->', '<d\1:'. a:mark . '>', '') " Mark finished: like: <d2:v>
    call setline(".", line)
endfunc

func! FinishDailyTask()
    call ChangeRepeatedTaskMark('v')
endfunc

func! FinishTodo()
    let line = getline(".")
    if match(line, '<r:\d.\+>') > 0
        call FinishRepeatedTask()
    elseif match(line, '<d\d:->') > 0
        call FinishDailyTask()
    else
        call AddDate("f", g:gtd_date_align_col + g:dateWidth)
    endif
endfunc

func! FailDailyTask()
    call ChangeRepeatedTaskMark('x')
endfunc

" Align specified date
func! AlignSpeciDate(dateType, colNum)
    let line = getline(".")
    let planDateCol = GetVirtCol('\[' . a:dateType . ':')
    if planDateCol > 0                  " Has plan date
        if planDateCol > a:colNum       " Should move left
            let leftSpaceCol = GetVirtCol(' \+\[' . a:dateType . ':')
            if leftSpaceCol < planDateCol " Could move
                let couldMove  = planDateCol - leftSpaceCol
                let shouldMove = planDateCol - a:colNum
                let shouldMove = couldMove >= shouldMove ? shouldMove : couldMove
                let newLine = substitute(line, repeat(" ", shouldMove) . '\(\[' . a:dateType . '\)', '\1', '')
                call setline(".", newLine)
            endif
        elseif planDateCol < a:colNum   " Should move right
            let shouldMove = a:colNum - planDateCol
            let newLine = substitute(line, '\(\[' . a:dateType . '\)', repeat(" ", shouldMove) . '\1', '')
            call setline(".", newLine)
        endif
    endif
endfunc

func! AlignDate()
    call AlignSpeciDate('[peto]', g:gtd_date_align_col)
    call AlignSpeciDate('f',     g:gtd_date_align_col + g:dateWidth)
endfunc


" Change tag for plannd(p/e/t/o) time
" line: line Content to change
" toTag: p/e/t/o
" setLineNum: >0: set changed line to setLineNum of current-buffer. ==0: doesn't set buffer.
func! ChangePlannedTag(line, toTag, setLineNum)
    if match(a:line, '\[[peto]:') > 0 && match(a:line, '\[' . a:toTag . ':') < 0  
        let repl = substitute(a:line, '\[[peto]:', '[' . a:toTag . ':', "")
        if a:setLineNum > 0
            call setline(a:setLineNum, repl)
        endif
    endif
endfunc


" Check if the todos if overdued or emergency.
" This function would go through the whole content of current buffer.
func! CheckOverdue()
    let totalLines = line('$')
    let i = 1

    while i <= totalLines
        let line = getline(i)                                   "echom line
        let planDate = GetDueDate(line)
        let completeDate = GetDate(line, "f")                   "echom 'completeDate: ' . completeDate
        if completeDate
            "echom "Completed"
        else " Not completed
            let today = strftime("%Y%m%d")
            if planDate
                if today > planDate                         " overdue
                    "if match(line, '\[[ep]:') > 0
                    "    let repl = substitute(line, '\[[ep]:', "[o:", "")
                    "    call setline(i, repl)
                    "endif
                    call ChangePlannedTag(line, 'o', i)
                else
                    "if has('python3')
                    "    python3 PyDateDiffer(vim.eval("today"), vim.eval("planDate"))
                    "else
                    "    python PyDateDiffer(vim.eval("today"), vim.eval("planDate"))
                    "endif
                    exec s:_py . 'PyDateDiffer(vim.eval("today"), vim.eval("planDate"))'
                    echom b:pyRet
                    if b:pyRet == 0                         " today
                        call ChangePlannedTag(line, 't', i)
                    elseif b:pyRet < g:gtd_emergency_days   " emergency
                        "if match(line, '\[[op]:') > 0
                        "    let repl = substitute(line, '\[[op]:', "[e:", "")
                        "    call setline(i, repl)
                        "endif
                        call ChangePlannedTag(line, 'e', i)
                    else                                    " just planned
                        "if match(line, '\[[oe]:') > 0
                        "    let repl = substitute(line, '\[[oe]:', "[p:", "")
                        "    call setline(i, repl)
                        "endif
                        call ChangePlannedTag(line, 'p', i)
                    endif
                endif
            endif
        endif

        let i = i + 1
    endwhile

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

" Open a window to show sched list.
" list  : the sched lines to show. Each item of the list is a text line.
" return: none
func! ListWinOpen(list)
    " Open list buffer
    let listBufNum = bufnr(g:listBufferName)
    if listBufNum == -1                         " Has no list buffer
        exe "split " . g:listBufferName
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

    if g:gtd_task_list_lines
        " Resize task window to N lines.
        silent! exec "resize " . g:gtd_task_list_lines
    endif

    " Write content
    setlocal modifiable
    let delBak = @"
    %delete
    for line in a:list
        call append(line('$'), line)
    endfor
    1delete
    let @" = delBak
    setlocal nomodifiable
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
        endwhile
    else
        call add(a:schedList, a:curSchedStack[len(a:curSchedStack)-1])
    endif
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

        if bname == g:listBufferName
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
        let i += 1
        endwhile

        let bnr = bnr + 1
    endwhile

    let list = []
    let list = add(list, "o ==========================================================")
    let list = list + listOverdue
    let list = add(list, "e ==========================================================")
    let list = list + listEmergency
    let list = add(list, "p ==========================================================")
    let list = list + listPlanned
    call ListWinOpen(list)
endfunc

"func! CompareTodoByPlanDate(todo1, todo2)
"    let planDate1 = GetDate(a:todo1, "[p]")
"    let planDate2 = GetDate(a:todo2, "[p]")
"
"    echom planDate1, planDate2
"    return planDate1 - planDate2
"    echom a:todo1, a:todo2
"    return 1;
"endfunc

"func! SortTodoList(list, compare)
"endfunc

" Add a new item (which means a new line after current line with an ID tag)
func! NewTodo()
    exec "normal o"
    call AddId()
endfunc

func! TaskList()
    let listTask       = []
    let bufferAmount        = bufnr("$")
    let bnr = 1 " Buffer number
    while bnr <= bufferAmount " Go through all buffers
        let bname = bufname(bnr)
        let btype = getbufvar(bnr, '&ft')

        if btype != "gtd"
            let bnr = bnr + 1
            continue
        endif

        if bname == g:listBufferName " Ignore listBuffer
            let bnr = bnr + 1
            continue
        endif

        let allLines = readfile(bname)
        if len(allLines) <= 0 " Empty file
            let bnr = bnr + 1
            continue
        endif

        let i = 0
        while i < len(allLines)
            let line = allLines[i]
            if GetLineType(line) == 'task'
                " Ignore finished tasks
                let finished = GetDate(line, "f")
                if finished
                    let i += 1
                    continue
                endif

                " Insert node
                let lineDate = GetDueDate(line)
                let matchWhenHaveFree = match(line, '\.\.\.\.')  " 当空闲时就处理

                if !lineDate && matchWhenHaveFree < 0  " Ignore not-planned tasks and not when-have-free
                    let i += 1
                    continue
                endif

                let lineForList = substitute(line, '\(^\s*\)\([^\[]\+\)', '\2\1', '') . '  <l:' . bname . ':' . (i + 1) . '>'
                if len(listTask) == 0   " 空列表, 添加第一项
                    call add(listTask, lineForList)
                    let i += 1
                    continue
                endif

                if matchWhenHaveFree >= 0   " 空闲时处理
                    call insert(listTask, lineForList, 0)
                    let i += 1
                    continue
                endif

                let j = 0
                while j < len(listTask)
                    let itDate = GetDueDate(listTask[j])
                    if itDate && lineDate < itDate
                        "echom "Insert" j lineDate itDate
                        call insert(listTask, lineForList, j)
                        break
                    endif

                    let j += 1
                endwhile
                if j >= len(listTask)
                    "echom "Push back 2"
                    call add(listTask, lineForList)
                endif

            endif

            let i += 1
        endwhile

"        echo "===================="
"        for it in listTask
"            echo it
"        endfor
        let bnr = bnr + 1
    endwhile

    call ListWinOpen(listTask)

    let listBufNum = bufnr(g:listBufferName)

    "setlocal modifiable
    "setlocal nomodifiable
endfunc

func! TaskListToggle()
    let i = 1
    while i <= winnr('$')
        let bnr = winbufnr(i)
        let bname = bufname(bnr)
        if bname == g:listBufferName
            exec i.'wincmd w'
            exec "q"
            return
        endif
        let i += 1
    endwhile

    call TaskList()
endfunc

func! TaskListUpdate()
    let i = 1
    while i <= winnr('$')
        let bnr = winbufnr(i)
        let wname = bufname(bnr)
        if wname == g:listBufferName
            call TaskList()
        endif
        let i += 1
    endwhile
endfunc

func! SchedListBufInit()
    setlocal filetype=gtt
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal nobuflisted
    setlocal noswapfile
    setlocal nolist
    setlocal nowrap
    setlocal textwidth=0
endfunc

func! GtdBufInit()
    setlocal foldmethod=marker
    setlocal expandtab
    let b:fold_status=0
endfunc

func! GtdResetDaily()
    silent! exec "'<,'>s/:#/:-/g"
    silent! exec "'<,'>s/:v/:-/g"
    silent! exec "'<,'>s/:x/:-/g"
endfunc


func! AddAlarm(text)
    "eechom a:text
    let txt = substitute(a:text, '^\s*\(.\{-}\)\s*$', '\1', '')
    "eechom txt
    let firstChar = strpart(txt, 0, 1)
    "eechom firstChar
    let pm = 0

    " Check whether has a 'p' leading. (for pm)
    if firstChar == "p"
        let pm = 1
        let txt = strpart(txt, 1, 36)
        let txt = substitute(txt, '^\s*\(.\{-}\)\s*$', '\1', '')
    endif

    " Get hour & minute
    let lstTxt = split(txt, '[: ]\+')
    let hour = get(lstTxt, 0)
    let minute = get(lstTxt, 1)

    if pm
        let hour += 12
    endif

    if len(hour) < 2
        let hour = '0' . hour
    endif
    if len(minute) < 2
        let minute = '0' . minute
    endif

    " Set alarm string
    let alarmText = '<a:' . hour . ':' . minute . '>'

    " Add plan date first(if not exists)
    let line = getline(".")
    let planDate = GetDueDate(line)
    if !planDate
        echom 'no plan date'
        call AddDate("p", g:gtd_date_align_col)
    endif

    " Set new line with alarm
    let line = getline(".")
    let newLine = substitute(line, '\( \+\[[peto]:\d\{4}-\d\{2}-\d\{2}\]\)', ' ' . alarmText . '\1', '')
    call setline(".", newLine)
    exec "normal i\<esc>"
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

func! AddId()
    "call AddStringToCurLine(' <id:' . localtime() . '>', -1)
    call AddStringToCurLine(strftime(" <id:%Y%m%d-%H%M%S>"), -1)
endfunc

"" Get ID for a todo line
"" line: line string
"func! GetId(line)
"endfunc

" Get the tree path of id
" lineNum: number of line
" return: list of id path. e.g.: [idGrandpa, idFather, idSon, idGrandson]
func! GetIdpath(lineNum)
    let lstPath = []
    let lineNum = a:lineNum
    let line = getline(lineNum)
    let id = matchstr(line, s:strIdTagPattern)
    let todoLevel = GetTodoLevel(line)
    "echo 'id: ' id ', todoLevel: ' todoLevel
    if len(id) <= 0
        echoerr 'No id for current line'
        return []
    endif
    call insert(lstPath, id, 0)

    let bakTodoLevel = todoLevel
    while lineNum > 1
        let line = getline(lineNum)
        let todoLevel = GetTodoLevel(line)
        if len(line) > 0 && todoLevel < bakTodoLevel       " It's my ancestor
            let id = matchstr(line, s:strIdTagPattern)
            if len(id) <= 0                     " has no id in this line
                echoerr 'Found ancestor node with no ID in line:' lineNum
                return []
            endif
            call add(lstPath, id)
        endif
        let bakTodoLevel = todoLevel
        let lineNum = lineNum - 1
    endw
    echo 'GetIdpath, result: ' lstPath

    return lstPath
endfunc


func! ArchiveTodo()
    call GetIdpath(line('.'))
endfunc

" Commands =====================================================================
command! ToggleFold         call ToggleFold()
command! AddDatePlan        call AddDate("p", g:gtd_date_align_col)
command! FinishTodo         call FinishTodo()
command! FailDailyTask      call FailDailyTask()
"command! FinishRepeatedTask call FinishRepeatedTask()
command! CheckOverdue       call CheckOverdue()
command! SchedList          call SchedList()
command! TaskList           call TaskList()
command! TaskListToggle     call TaskListToggle()
command! AlignDate          call AlignDate()
command! -nargs=1 Al        call AddAlarm(<f-args>)

autocmd BufEnter        __gtd_list_buffer__     call SchedListBufInit()
autocmd BufEnter        *.gtd,*.gtdt            call GtdBufInit()
if g:gtd_pickup_date_from_calendar
autocmd BufEnter        *.gtd,*.gtdt silent!    call SelectDateAfter()
endif
if g:gtd_auto_update_task_list
autocmd BufWritePost    *.gtd,*.gtdt            call TaskListUpdate()
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
setlocal comments+=:*

