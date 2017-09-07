if !exists("g:gtd_gtdfiles")
    let g:gtd_gtdfiles = ["~/.my_vimgtd.gtd"]
endif


func! OpenGtd()
    for f in g:gtd_gtdfiles
        exec "vi" . f
    endfor
endfunc




autocmd FileType gtd inoremap [] [ ] 

command! -nargs=0 Gtdo :call OpenGtd()


"autocmd BufEnter    *.gtd echom "BufEnter"
"autocmd BufWinEnter *.gtd echom "BufWinEnter"
"autocmd VimEnter    *.gtd echom "VimEnter"
"autocmd BufNew      *.gtd echom "BufNew"
"autocmd BufAdd      *.gtd echom "BufAdd"
