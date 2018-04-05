if !exists("g:gtd_gtdfiles")
    let g:gtd_gtdfiles = ["~/.my_vimgtd.gtd"]
endif

if !exists("g:gtd_pickup_date_from_calendar")
    let g:gtd_pickup_date_from_calendar = 1
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
"autocmd FileType gtd        nnoremap <buffer>           <TAB>       :ToggleFold<CR>
autocmd FileType gtd        nnoremap <buffer>           <TAB>       :exec 'normal za'<CR>
autocmd FileType gtd        nnoremap <buffer> <silent>  <leader>gp  :AddDatePlan<cr>
autocmd FileType gtd        nnoremap <buffer> <silent>  <leader>gf  :FinishTodo<cr>
autocmd FileType gtd        nnoremap <buffer> <silent>  <leader>gs  :SchedList<cr>
autocmd FileType gtd        nnoremap <buffer> <silent>  <leader>gt  :TaskList<cr>
if g:gtd_pickup_date_from_calendar
autocmd FileType gtd        nnoremap <buffer> <silent>  <cr>        :call SelectDate()<cr>
endif
autocmd FileType gtt        nnoremap <buffer>           <cr>        :call GotoSchedDefinition(1)<cr>
autocmd FileType gtt        nnoremap <buffer>           tt          :q<cr>
autocmd FileType gtt        nnoremap <buffer>           ff          jmnl:call GotoSchedDefinition(0)<cr> :FinishTodo<cr> :w<cr> <c-w><c-w>'n
autocmd FileType gtt        nnoremap <buffer>           u           <c-w>j u:w<cr> <c-w>k

autocmd FileType gtd        vnoremap <buffer> <silent>  <leader>gc  :call GtdResetDaily()<cr>
autocmd FileType gtd        inoremap <buffer>           [] [ ] 

autocmd InsertLeave *.gtd call AlignDate()

" Simple map {{{
autocmd FileType gtd        nnoremap <buffer> <silent>  <leader>p   :AddDatePlan<cr>Eh
autocmd FileType gtd        nnoremap <buffer> <silent>  ff          :FinishTodo<cr>
autocmd FileType gtd        nnoremap <buffer> <silent>  tt          :TaskListToggle<cr>
autocmd FileType gtd        vnoremap <buffer> <silent>  <leader>c   :call GtdResetDaily()<cr>
" Simple map }}}

"autocmd BufEnter    *.gtd echom "BufEnter"
"autocmd BufWinEnter *.gtd echom "BufWinEnter"
"autocmd VimEnter    *.gtd echom "VimEnter"
"autocmd BufNew      *.gtd echom "BufNew"
"autocmd BufAdd      *.gtd echom "BufAdd"
