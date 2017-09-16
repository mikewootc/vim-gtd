" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
  finish
endif

" Don't load another plugin for this buffer
let b:did_ftplugin = 1

" Behaves just like gtd
runtime! ftplugin/gtd.vim


func! GotoTaskDefinition()
    let line = getline(".")
    "echo "line" line
    let loc = matchstr(line, '\(<l:\)\@<=.*:\d\+>\@=')
    "echo "loc" loc
    let locPair = split(loc, ':')
    "echo locPair
    let file = locPair[0]
    let line = locPair[1]

    wincmd j
    exec 'vi' . file
    exec 'normal ' line . 'gg'
endfunc

"autocmd FileType gtt nnoremap <buffer> <cr> :call GotoTaskDefinition()<cr>


