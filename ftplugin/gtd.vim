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

if !exists("g:gtd_emergency_days")
    let g:gtd_emergency_days = 7
endif


let g:taskBufferName = "__gtd_task_list__"

if exists("loaded_gtd") || &cp
  finish
endif
let loaded_gtd = 1

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

" Check if the tasks if overdued or emergency.
" This function would go through the whole content of current buffer.
func! CheckOverdue()
    let totalLines = line('$')
    let i = 1

    while i <= totalLines
        let line = getline(i)                                   "echom line
        let planDate = GetDate(line, "p")
        if ! planDate
            let planDate = GetDate(line, "e")
        endif                                                   "echom 'planDate: ' . planDate
        let completeDate = GetDate(line, "f")                   "echom 'completeDate: ' . completeDate
        if completeDate
            "echom "Completed"
        else " Not completed
            let today = strftime("%Y%m%d")
            if planDate
                if today > planDate " overdue
                    if match(line, '\[[ep]:') > 0
                        let repl = substitute(line, '\[[ep]:', "[o:", "")
                        call setline(i, repl)
                    endif
                else
                    python DateDiffer(vim.eval("today"), vim.eval("planDate"))
                    if b:pyRet < g:gtd_emergency_days " emergency
                        if match(line, '\[[op]:') > 0
                            let repl = substitute(line, '\[[op]:', "[e:", "")
                            call setline(i, repl)
                        endif
                    else
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
        if len(allLines) <= 0
            let bnr = bnr + 1
            continue
        endif

        let curTaskStack = []
        let preOTaskStack = []
        let preETaskStack = []
        let prePTaskStack = []
        for line in allLines
            let taskLevel = GetTaskLevel(line)
            if taskLevel < 0 " Empty line
                continue
            endif

            let stackLen = len(curTaskStack)
            if taskLevel > stackLen
                call add(curTaskStack, line)
            elseif taskLevel == stackLen
                let curTaskStack[stackLen - 1] = line
            elseif taskLevel < stackLen
                call remove(curTaskStack, taskLevel - 1, stackLen - 1)
                call add(curTaskStack, line)
            endif

            let finished = GetDate(line, "f")
            if finished
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
        endfor

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

function! TaskListBufInit()
    setlocal filetype=gtd
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
    let taskLine = "'" . taskLine . " 明天'"
    return taskLine
endfunc
autocmd FileType gtd nnoremap <buffer> <leader>gs :!tt <c-r>=GetTaskLine()<cr>
" personal }}}

autocmd BufEnter __gtd_task_list__ call TaskListBufInit()
autocmd BufEnter *.gtd  call GtdBufInit()
autocmd BufEnter *.gtdt call GtdBufInit()

if g:gtd_auto_check_overdue
    autocmd BufEnter *.gtd silent! call CheckOverdue()
endif

autocmd FileType gtd nnoremap <buffer> <TAB> :call ToggleFold()<CR>
autocmd FileType gtd nnoremap <buffer> <silent> <leader>gp <ESC>:call AddDate("p", 101)<cr>  | "gtd plan date
autocmd FileType gtd nnoremap <buffer> <silent> <leader>gf <ESC>:call AddDate("f", 115)<cr>  | "gtd finish task(Add finish date)
autocmd FileType gtd nnoremap <buffer> <silent> <leader>gc :call CheckOverdue()<cr>
autocmd FileType gtd nnoremap <buffer> <silent> <leader>gt :call TaskList()<cr>

autocmd FileType gtd inoremap <buffer> [] [ ] 
