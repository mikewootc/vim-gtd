" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
  finish
endif

" If auto-hide task list window when jump to task line in main window.
if !exists("g:gtd_hide_tasklist_when_goto_def")
    let g:gtd_hide_tasklist_when_goto_def = 0
endif


" Don't load another plugin for this buffer
let b:did_ftplugin = 1

" Behaves just like gtd
runtime! ftplugin/gtd.vim


func! GotoSchedDefinition(checkAutoHide)
    let line = getline(".")
    let loc = matchstr(line, '\(<l:\)\@<=.*:\d\+>\@=')
    let locPair = split(loc, ':')
    let file = locPair[0]
    let line = locPair[1]
    let taskWinNr = winnr()

    wincmd j
    exec 'vi ' . file
    exec 'normal ' line . 'gg'

    if g:gtd_hide_tasklist_when_goto_def && a:checkAutoHide
        exec taskWinNr . 'wincmd w'
        exec 'q'
    endif
endfunc

func! TaskListBackupPosition()
    let b:taskListBakPos = line('.')
endfunc

func! TaskListRestorePosition()
    exec 'normal ' . b:taskListBakPos . 'gg'
endfunc

"autocmd FileType gtt nnoremap <buffer> <cr> :call GotoSchedDefinition()<cr>


