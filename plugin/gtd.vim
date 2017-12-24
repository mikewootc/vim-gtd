if !exists("g:gtd_gtdfiles")
    let g:gtd_gtdfiles = ["~/.my_vimgtd.gtd"]
endif

if !exists("g:gtd_pickup_date_from_calendar")
    let g:gtd_pickup_date_from_calendar = 0
endif


func! OpenGtd()
    for f in g:gtd_gtdfiles
        exec "vi" . f
    endfor
endfunc

autocmd BufRead,BufNewFile *.gtd         setf gtd
autocmd BufRead,BufNewFile *.gtl         setf gtl

" Commands =====================================================================
command! -nargs=0 Gtdo :call OpenGtd()

" Key maps =====================================================================
autocmd FileType gtd        nnoremap <buffer>           <TAB>       :ToggleFold<CR>
autocmd FileType gtd        nnoremap <buffer> <silent>  <leader>gp  :AddDatePlan<cr>
autocmd FileType gtd        nnoremap <buffer> <silent>  <leader>gf  :FinishTodo<cr>
"autocmd FileType gtd        nnoremap <buffer> <silent>  <leader>gr  :FinishRepeatedTask<cr>
autocmd FileType gtd        nnoremap <buffer> <silent>  <leader>gc  :CheckOverdue<cr>
autocmd FileType gtd        nnoremap <buffer> <silent>  <leader>gs  :SchedList<cr>
autocmd FileType gtd        nnoremap <buffer> <silent>  <leader>gt  :TaskList<cr>
"autocmd FileType gtd,gtt    nnoremap <buffer>           <leader>gs  :!tt <c-r>=GetTodoLine()<cr>|"personal
if g:gtd_pickup_date_from_calendar
autocmd FileType gtd        nnoremap <buffer> <silent>  <cr>        :call SelectDate()<cr>
endif
autocmd FileType gtt        nnoremap <buffer>           <cr>        :call GotoSchedDefinition()<cr>

autocmd FileType gtd        inoremap <buffer>           [] [ ] 

"autocmd InsertLeave FileType gtd call AlignDate()
autocmd InsertLeave *.gtd call AlignDate()


"autocmd BufEnter    *.gtd echom "BufEnter"
"autocmd BufWinEnter *.gtd echom "BufWinEnter"
"autocmd VimEnter    *.gtd echom "VimEnter"
"autocmd BufNew      *.gtd echom "BufNew"
"autocmd BufAdd      *.gtd echom "BufAdd"
