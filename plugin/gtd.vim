if !exists("g:gtd_gtdfiles")
    let g:gtd_gtdfiles = ["~/.my_vimgtd.gtd"]
endif


func! OpenGtd()
    for f in g:gtd_gtdfiles
        exec "vi" . f
    endfor
endfunc


" Commands =====================================================================
command! -nargs=0 Gtdo :call OpenGtd()

" Key maps =====================================================================
autocmd FileType gtd nnoremap <buffer>          <TAB>      :ToggleFold<CR>
autocmd FileType gtd nnoremap <buffer> <silent> <leader>gp :AddDatePlan<cr>
autocmd FileType gtd nnoremap <buffer> <silent> <leader>gf :AddDateFinish<cr>
autocmd FileType gtd nnoremap <buffer> <silent> <leader>gc :CheckOverdue<cr>
autocmd FileType gtd nnoremap <buffer> <silent> <leader>gt :TaskList<cr>

autocmd FileType gtd inoremap <buffer> [] [ ] 

"autocmd InsertLeave FileType gtd call AlignDate()
autocmd InsertLeave *.gtd call AlignDate()


"autocmd BufEnter    *.gtd echom "BufEnter"
"autocmd BufWinEnter *.gtd echom "BufWinEnter"
"autocmd VimEnter    *.gtd echom "VimEnter"
"autocmd BufNew      *.gtd echom "BufNew"
"autocmd BufAdd      *.gtd echom "BufAdd"
