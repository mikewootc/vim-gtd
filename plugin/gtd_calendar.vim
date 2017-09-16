"=============================================================================
" GtdCalendar forked and modified from Yasuhiro Matsumoto's calendar.vim
" Used for vim gtd.

let g:gtd_calendar_version = "1.7"
if &compatible
  finish
endif

if !exists("g:gtd_calendar_sign")
  let g:gtd_calendar_sign = "<SID>GtdCalendarSign"
endif
if !exists("g:gtd_calendar_mark")
 \|| (g:gtd_calendar_mark != 'left'
 \&& g:gtd_calendar_mark != 'left-fit'
 \&& g:gtd_calendar_mark != 'right')
  let g:gtd_calendar_mark = 'left'
endif
if !exists("g:gtd_calendar_navi")
 \|| (g:gtd_calendar_navi != 'top'
 \&& g:gtd_calendar_navi != 'bottom'
 \&& g:gtd_calendar_navi != 'both'
 \&& g:gtd_calendar_navi != '')
  let g:gtd_calendar_navi = 'top'
endif
if !exists("g:gtd_calendar_navi_label")
  let g:gtd_calendar_navi_label = "Prev,Today,Next"
endif
if !exists("g:gtd_calendar_diary")
  let g:gtd_calendar_diary = "~/diary"
endif
if !exists("g:gtd_calendar_focus_today")
  let g:gtd_calendar_focus_today = 0
endif

"*****************************************************************
"* GtdCalendar commands
"*****************************************************************
:command! -nargs=* GtdCalendar  call GtdCalendar(0,<f-args>)
:command! -nargs=* CalendarH call GtdCalendar(1,<f-args>)

if !hasmapto("<Plug>CalendarV")
  "nmap <unique> <Leader>cal <Plug>CalendarV " Mike change
  nmap <unique> <Leader>ca <Plug>CalendarV
endif
"Mike remove
"if !hasmapto("<Plug>CalendarH")
"  nmap <unique> <Leader>caL <Plug>CalendarH
"endif
nmap <silent> <Plug>CalendarV :cal GtdCalendar(0)<CR>
nmap <silent> <Plug>CalendarH :cal GtdCalendar(1)<CR>
autocmd BufEnter __Calendar nnoremap <buffer> <silent> <c-y> :close<cr>
"autocmd FileType gtd nnoremap <buffer> <silent> <leader>gt :TaskList<cr>

"*****************************************************************
"* GtdGetToken : get token from source with count
"*----------------------------------------------------------------
"*   src : source
"*   dlm : delimiter
"*   cnt : skip count
"*****************************************************************
function! s:GtdGetToken(src,dlm,cnt)
  let tokn_hit=0     " flag of found
  let tokn_fnd=''    " found path
  let tokn_spl=''    " token
  let tokn_all=a:src " all source

  " safe for end
  let tokn_all = tokn_all.a:dlm
  while 1
    let tokn_spl = strpart(tokn_all,0,match(tokn_all,a:dlm))
    let tokn_hit = tokn_hit + 1
    if tokn_hit == a:cnt
      return tokn_spl
    endif
    let tokn_all = strpart(tokn_all,strlen(tokn_spl.a:dlm))
    if tokn_all == ''
      break
    endif
  endwhile
  return ''
endfunction

"*****************************************************************
"* CalendarDoAction : call the action handler function
"*----------------------------------------------------------------
"*****************************************************************
"function! s:CalendarDoAction(...)
"  " if no action defined return
"  if !exists("g:gtd_calendar_action")
"    return
"  endif
"
"  " for navi
"  if exists('g:gtd_calendar_navi')
"    let navi = (a:0 > 0)? a:1 : expand("<cWORD>")
"    let curl = line(".")
"    if navi == '<' . s:GtdGetToken(g:gtd_calendar_navi_label, ',', 1)
"      exec substitute(maparg('<s-left>', 'n'), '<CR>', '', '')
"    elseif navi == s:GtdGetToken(g:gtd_calendar_navi_label, ',', 3) . '>'
"      exec substitute(maparg('<s-right>', 'n'), '<CR>', '', '')
"    elseif navi == s:GtdGetToken(g:gtd_calendar_navi_label, ',', 2)
"      call GtdCalendar(b:CalendarDir)
"      if exists('g:gtd_calendar_today')
"        exe "call " . g:gtd_calendar_today . "()"
"      endif
"    else
"      let navi = ''
"    endif
"    if navi != ''
"      if g:gtd_calendar_focus_today == 1 && search("\*","w") > 0
"        silent execute "normal! gg/\*\<cr>"
"        return
"      else
"        setlocal ws
"        if curl < line('$')/2
"          silent execute "normal! gg0/".navi."\<cr>"
"        else
"          silent execute "normal! G0/".navi."\<cr>"
"        endif
"        setlocal nows
"        return
"      endif
"    endif
"  endif
"
"  if b:CalendarDir
"    let dir = 'H'
"    if !exists('g:gtd_calendar_monday') && exists('g:gtd_calendar_weeknm')
"      let cnr = col('.') - (col('.')%(24+5)) + 1
"    else
"      let cnr = col('.') - (col('.')%(24)) + 1
"    endif
"    let week = ((col(".") - cnr - 1 + cnr/49) / 3)
"  else
"    let dir = 'V'
"    let cnr = 1
"    let week = ((col(".")+1) / 3) - 1
"  endif
"  let lnr = 1
"  let hdr = 1
"  while 1
"    if lnr > line('.')
"      break
"    endif
"    let sline = getline(lnr)
"    if sline =~ '^\s*$'
"      let hdr = lnr + 1
"    endif
"    let lnr = lnr + 1
"  endwhile
"  let lnr = line('.')
"  if(exists('g:gtd_calendar_monday'))
"      let week = week + 1
"  elseif(week == 0)
"      let week = 7
"  endif
"  if lnr-hdr < 2
"    return
"  endif
"  let sline = substitute(strpart(getline(hdr),cnr,21),'\s*\(.*\)\s*','\1','')
"  if (col(".")-cnr) > 21
"    return
"  endif
"
"  " extract day
"  if g:gtd_calendar_mark == 'right' && col('.') > 1
"    normal! h
"    let day = matchstr(expand("<cword>"), '[^0].*')
"    normal! l
"  else
"    let day = matchstr(expand("<cword>"), '[^0].*')
"  endif
"  if day == 0
"    return
"  endif
"  " extract year and month
"  if exists('g:gtd_calendar_erafmt') && g:gtd_calendar_erafmt !~ "^\s*$"
"    let year = matchstr(substitute(sline, '/.*', '', ''), '\d\+')
"    let month = matchstr(substitute(sline, '.*/\(\d\d\=\).*', '\1', ""), '[^0].*')
"    if g:gtd_calendar_erafmt =~ '.*,[+-]*\d\+'
"      let veranum=substitute(g:gtd_calendar_erafmt,'.*,\([+-]*\d\+\)','\1','')
"      if year-veranum > 0
"        let year=year-veranum
"      endif
"    endif
"  else
"    let year  = matchstr(substitute(sline, '/.*', '', ''), '[^0].*')
"    let month = matchstr(substitute(sline, '\d*/\(\d\d\=\).*', '\1', ""), '[^0].*')
"  endif
"  " call the action function
"  exe "call " . g:gtd_calendar_action . "(day, month, year, week, dir)"
"endfunc

"*****************************************************************
"* CalendarGetCursorDate
"*----------------------------------------------------------------
"* return: [year, month, day, weekday]
"*****************************************************************
function! s:GtdCalendarGetCursorDate()
  if b:CalendarDir
    let dir = 'H'
    if !exists('g:gtd_calendar_monday') && exists('g:gtd_calendar_weeknm')
      let cnr = col('.') - (col('.')%(24+5)) + 1
    else
      let cnr = col('.') - (col('.')%(24)) + 1
    endif
    let week = ((col(".") - cnr - 1 + cnr/49) / 3)
  else
    let dir = 'V'
    let cnr = 1
    let week = ((col(".")+1) / 3) - 1
  endif
  let lnr = 1
  let hdr = 1
  while 1
    if lnr > line('.')
      break
    endif
    let sline = getline(lnr)
    if sline =~ '^\s*$'
      let hdr = lnr + 1
    endif
    let lnr = lnr + 1
  endwhile
  let lnr = line('.')
  if(exists('g:gtd_calendar_monday'))
      let week = week + 1
  elseif(week == 0)
      let week = 7
  endif
  if lnr-hdr < 2
    return
  endif
  let sline = substitute(strpart(getline(hdr),cnr,21),'\s*\(.*\)\s*','\1','')
  if (col(".")-cnr) > 21
    return
  endif

  " extract day
  if g:gtd_calendar_mark == 'right' && col('.') > 1
    normal! h
    let day = matchstr(expand("<cword>"), '[^0].*')
    normal! l
  else
    let day = matchstr(expand("<cword>"), '[^0].*')
  endif
  if day == 0
    return
  endif
  " extract year and month
  if exists('g:gtd_calendar_erafmt') && g:gtd_calendar_erafmt !~ "^\s*$"
    let year = matchstr(substitute(sline, '/.*', '', ''), '\d\+')
    let month = matchstr(substitute(sline, '.*/\(\d\d\=\).*', '\1', ""), '[^0].*')
    if g:gtd_calendar_erafmt =~ '.*,[+-]*\d\+'
      let veranum=substitute(g:gtd_calendar_erafmt,'.*,\([+-]*\d\+\)','\1','')
      if year-veranum > 0
        let year=year-veranum
      endif
    endif
  else
    let year  = matchstr(substitute(sline, '/.*', '', ''), '[^0].*')
    let month = matchstr(substitute(sline, '\d*/\(\d\d\=\).*', '\1', ""), '[^0].*')
  endif

  return [year, month, day, week]
endfunc

"*****************************************************************
"* Return previous window(g:preBufNr) and return selected date(with g:gtdCalendarSelectedDate)
"*----------------------------------------------------------------
"*****************************************************************
function! s:GtdReturnSelecteDate()
    let g:gtdCalendarSelectedDate = <SID>GtdCalendarGetCursorDate()
    "echo g:gtdCalendarSelectedDate

    if exists("g:preBufNr") && g:preBufNr
        "echom 'in cal preBufNr: ' . g:preBufNr
        let wnr = bufwinnr(g:preBufNr)
        "echom 'bname:' . bufname(g:preBufNr)
        "echom 'in cal wnr: ' . wnr
        exe wnr . 'wincmd w'
    endif
endfunc

"execute 'nnoremap <silent> <buffer> <cr> :call <SID>GtdReturnSelecteDate()<cr>'

"*****************************************************************
"* GtdCalendar : build calendar
"*----------------------------------------------------------------
"*   a1 : direction
"*   a2 : month(if given a3, it's year)
"*   a3 : if given, it's month
"*****************************************************************
function! GtdCalendar(...)

  "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  "+++ ready for build
  "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  " remember today
  " divide strftime('%d') by 1 so as to get "1,2,3 .. 9" instead of "01, 02, 03 .. 09"
  let vtoday = strftime('%Y').strftime('%m').strftime('%d')

  " get arguments
  if a:0 == 0
    let dir = 0
    let vyear = strftime('%Y')
    let vmnth = matchstr(strftime('%m'), '[^0].*')
  elseif a:0 == 1
    let dir = a:1
    let vyear = strftime('%Y')
    let vmnth = matchstr(strftime('%m'), '[^0].*')
  elseif a:0 == 2
    let dir = a:1
    let vyear = strftime('%Y')
    let vmnth = matchstr(a:2, '^[^0].*')
  else
    let dir = a:1
    let vyear = a:2
    let vmnth = matchstr(a:3, '^[^0].*')
  endif

  " remember constant
  let vmnth_org = vmnth
  let vyear_org = vyear

  " start with last month
  let vmnth = vmnth - 1
  if vmnth < 1
    let vmnth = 12
    let vyear = vyear - 1
  endif

  " reset display variables
  let vdisplay1 = ''
  let vheight = 1
  let vmcnt = 0

  "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  "+++ build display
  "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  if exists("g:gtd_calendar_begin")
    exe "call " . g:gtd_calendar_begin . "()"
  endif
  while vmcnt < 3
    let vcolumn = 22
    let vnweek = -1
    "--------------------------------------------------------------
    "--- calculating
    "--------------------------------------------------------------
    " set boundary of the month
    if vmnth == 1
      let vmdays = 31
      let vparam = 1
      let vsmnth = 'Jan'
    elseif vmnth == 2
      let vmdays = 28
      let vparam = 32
      let vsmnth = 'Feb'
    elseif vmnth == 3
      let vmdays = 31
      let vparam = 60
      let vsmnth = 'Mar'
    elseif vmnth == 4
      let vmdays = 30
      let vparam = 91
      let vsmnth = 'Apr'
    elseif vmnth == 5
      let vmdays = 31
      let vparam = 121
      let vsmnth = 'May'
    elseif vmnth == 6
      let vmdays = 30
      let vparam = 152
      let vsmnth = 'Jun'
    elseif vmnth == 7
      let vmdays = 31
      let vparam = 182
      let vsmnth = 'Jul'
    elseif vmnth == 8
      let vmdays = 31
      let vparam = 213
      let vsmnth = 'Aug'
    elseif vmnth == 9
      let vmdays = 30
      let vparam = 244
      let vsmnth = 'Sep'
    elseif vmnth == 10
      let vmdays = 31
      let vparam = 274
      let vsmnth = 'Oct'
    elseif vmnth == 11
      let vmdays = 30
      let vparam = 305
      let vsmnth = 'Nov'
    elseif vmnth == 12
      let vmdays = 31
      let vparam = 335
      let vsmnth = 'Dec'
    else
      echo 'Invalid Year or Month'
      return
    endif
    if vyear % 400 == 0
      if vmnth == 2
        let vmdays = 29
      elseif vmnth >= 3
        let vparam = vparam + 1
      endif
    elseif vyear % 100 == 0
      if vmnth == 2
        let vmdays = 28
      endif
    elseif vyear % 4 == 0
      if vmnth == 2
        let vmdays = 29
      elseif vmnth >= 3
        let vparam = vparam + 1
      endif
    endif

    " calc vnweek of the day
    if vnweek == -1
      let vnweek = ( vyear * 365 ) + vparam
      let vnweek = vnweek + ( vyear/4 ) - ( vyear/100 ) + ( vyear/400 )
      if vyear % 4 == 0
        if vyear % 100 != 0 || vyear % 400 == 0
          let vnweek = vnweek - 1
        endif
      endif
      let vnweek = vnweek - 1
    endif

    " fix Gregorian
    if vyear <= 1752
      let vnweek = vnweek - 3
    endif

    let vnweek = vnweek % 7

    if exists('g:gtd_calendar_monday')
      " if given g:gtd_calendar_monday, the week start with monday
      if vnweek == 0
        let vnweek = 7
      endif
      let vnweek = vnweek - 1
    elseif exists('g:gtd_calendar_weeknm')
      " if given g:gtd_calendar_weeknm, show week number(ref:ISO8601)
      let viweek = vparam / 7
      let vfweek = vparam % 7
      if vnweek == 0
        let vfweek = vfweek - 7
        let viweek = viweek + 1
      else
        let vfweek = vfweek - vnweek
      endif
      if vfweek <= 0 && viweek > 0
        let viweek = viweek - 1
        let vfweek = vfweek + 7
      endif
      if vfweek > -4
        let viweek = viweek + 1
      endif
      if vfweek > 3
        let viweek = viweek + 1
      endif
      if viweek == 0
        let viweek = '??'
      elseif viweek > 52
        if vnweek != 0 && vnweek < 4
          let viweek = 1
        endif
      endif
      let vcolumn = vcolumn + 5
    endif

    "--------------------------------------------------------------
    "--- displaying
    "--------------------------------------------------------------
    " build header
    if exists('g:gtd_calendar_erafmt') && g:gtd_calendar_erafmt !~ "^\s*$"
      if g:gtd_calendar_erafmt =~ '.*,[+-]*\d\+'
        let veranum=substitute(g:gtd_calendar_erafmt,'.*,\([+-]*\d\+\)','\1','')
        if vyear+veranum > 0
          let vdisplay2=substitute(g:gtd_calendar_erafmt,'\(.*\),.*','\1','') 
          let vdisplay2=vdisplay2.(vyear+veranum).'/'.vmnth.'('
        else
          let vdisplay2=vyear.'/'.vmnth.'('
        endif
      else
        let vdisplay2=vyear.'/'.vmnth.'('
      endif
      let vdisplay2=strpart("                           ",
        \ 1,(vcolumn-strlen(vdisplay2))/2-2).vdisplay2
    else
      let vdisplay2=vyear.'/'.vmnth.'('
      let vdisplay2=strpart("                           ",
        \ 1,(vcolumn-strlen(vdisplay2))/2-2).vdisplay2
    endif
    if exists('g:gtd_calendar_mruler') && g:gtd_calendar_mruler !~ "^\s*$"
      let vdisplay2=vdisplay2.s:GtdGetToken(g:gtd_calendar_mruler,',',vmnth).')'."\n"
    else
      let vdisplay2=vdisplay2.vsmnth.')'."\n"
    endif
    let vwruler = "Su Mo Tu We Th Fr Sa"
    if exists('g:gtd_calendar_wruler') && g:gtd_calendar_wruler !~ "^\s*$"
      let vwruler = g:gtd_calendar_wruler
    endif
    if exists('g:gtd_calendar_monday')
      let vwruler = strpart(vwruler,stridx(vwruler, ' ') + 1).' '.strpart(vwruler,0,stridx(vwruler, ' '))
    endif
    let vdisplay2 = vdisplay2.' '.vwruler."\n"
    if g:gtd_calendar_mark == 'right'
      let vdisplay2 = vdisplay2.' '
    endif

    " build calendar
    let vinpcur = 0
    while (vinpcur < vnweek)
      let vdisplay2=vdisplay2.'   '
      let vinpcur = vinpcur + 1
    endwhile
    let vdaycur = 1
    while (vdaycur <= vmdays)
      if vmnth < 10
         let vtarget =vyear."0".vmnth
      else
         let vtarget =vyear.vmnth
      endif
      if vdaycur < 10
         let vtarget = vtarget."0".vdaycur
      else
         let vtarget = vtarget.vdaycur
      endif
      if exists("g:gtd_calendar_sign")
        exe "let vsign = " . g:gtd_calendar_sign . "(vdaycur, vmnth, vyear)"
        if vsign != ""
          let vsign = vsign[0]
          if vsign !~ "[+!#$%&@?]"
            let vsign = "+"
          endif
        endif
      else
        let vsign = ''
      endif

      " show mark
      if g:gtd_calendar_mark == 'right'
        if vdaycur < 10
          let vdisplay2=vdisplay2.' '
        endif
        let vdisplay2=vdisplay2.vdaycur
      elseif g:gtd_calendar_mark == 'left-fit'
        if vdaycur < 10
          let vdisplay2=vdisplay2.' '
        endif
      endif
      if vtarget == vtoday
        let vdisplay2=vdisplay2.'*'
      elseif vsign != ''
        let vdisplay2=vdisplay2.vsign
      else
        let vdisplay2=vdisplay2.' '
      endif
      if g:gtd_calendar_mark == 'left'
        if vdaycur < 10
          let vdisplay2=vdisplay2.' '
        endif
        let vdisplay2=vdisplay2.vdaycur
      endif
      if g:gtd_calendar_mark == 'left-fit'
        let vdisplay2=vdisplay2.vdaycur
      endif
      let vdaycur = vdaycur + 1

      " fix Gregorian
      if vyear == 1752 && vmnth == 9 && vdaycur == 3
        let vdaycur = 14
      endif

      let vinpcur = vinpcur + 1
      if vinpcur % 7 == 0
        if !exists('g:gtd_calendar_monday') && exists('g:gtd_calendar_weeknm')
          if g:gtd_calendar_mark != 'right'
            let vdisplay2=vdisplay2.' '
          endif
          " if given g:gtd_calendar_weeknm, show week number
          if viweek < 10
            if g:gtd_calendar_weeknm == 1
              let vdisplay2=vdisplay2.'WK0'.viweek
            elseif g:gtd_calendar_weeknm == 2
              let vdisplay2=vdisplay2.'WK '.viweek
            elseif g:gtd_calendar_weeknm == 3
              let vdisplay2=vdisplay2.'KW0'.viweek
            elseif g:gtd_calendar_weeknm == 4
              let vdisplay2=vdisplay2.'KW '.viweek
            endif
          else
            if g:gtd_calendar_weeknm <= 2
              let vdisplay2=vdisplay2.'WK'.viweek
            else
              let vdisplay2=vdisplay2.'KW'.viweek
            endif
          endif
          let viweek = viweek + 1
        endif
        let vdisplay2=vdisplay2."\n"
        if g:gtd_calendar_mark == 'right'
          let vdisplay2 = vdisplay2.' '
        endif
      endif
    endwhile

    " if it is needed, fill with space
    if vinpcur % 7 
      while (vinpcur % 7 != 0)
        let vdisplay2=vdisplay2.'   '
        let vinpcur = vinpcur + 1
      endwhile
      if !exists('g:gtd_calendar_monday') && exists('g:gtd_calendar_weeknm')
        if g:gtd_calendar_mark != 'right'
          let vdisplay2=vdisplay2.' '
        endif
        if viweek < 10
          if g:gtd_calendar_weeknm == 1
            let vdisplay2=vdisplay2.'WK0'.viweek
          elseif g:gtd_calendar_weeknm == 2
            let vdisplay2=vdisplay2.'WK '.viweek
          elseif g:gtd_calendar_weeknm == 3
            let vdisplay2=vdisplay2.'KW0'.viweek
          elseif g:gtd_calendar_weeknm == 4
            let vdisplay2=vdisplay2.'KW '.viweek
          endif
        else
          if g:gtd_calendar_weeknm <= 2
            let vdisplay2=vdisplay2.'WK'.viweek
          else
            let vdisplay2=vdisplay2.'KW'.viweek
          endif
        endif
      endif
    endif

    " build display
    let vstrline = ''
    if dir
      " for horizontal
      "--------------------------------------------------------------
      " +---+   +---+   +------+
      " |   |   |   |   |      |
      " | 1 | + | 2 | = |  1'  |
      " |   |   |   |   |      |
      " +---+   +---+   +------+
      "--------------------------------------------------------------
      let vtokline = 1
      while 1
        let vtoken1 = s:GtdGetToken(vdisplay1,"\n",vtokline)
        let vtoken2 = s:GtdGetToken(vdisplay2,"\n",vtokline)
        if vtoken1 == '' && vtoken2 == ''
          break
        endif
        while strlen(vtoken1) < (vcolumn+1)*vmcnt
          if strlen(vtoken1) % (vcolumn+1) == 0
            let vtoken1 = vtoken1.'|'
          else
            let vtoken1 = vtoken1.' '
          endif
        endwhile
        let vstrline = vstrline.vtoken1.'|'.vtoken2.' '."\n"
        let vtokline = vtokline + 1
      endwhile
      let vdisplay1 = vstrline
      let vheight = vtokline-1
    else
      " for virtical
      "--------------------------------------------------------------
      " +---+   +---+   +---+
      " | 1 | + | 2 | = |   |
      " +---+   +---+   | 1'|
      "                 |   |
      "                 +---+
      "--------------------------------------------------------------
      let vtokline = 1
      while 1
        let vtoken1 = s:GtdGetToken(vdisplay1,"\n",vtokline)
        if vtoken1 == ''
          break
        endif
        let vstrline = vstrline.vtoken1."\n"
        let vtokline = vtokline + 1
        let vheight = vheight + 1
      endwhile
      if vstrline != ''
        let vstrline = vstrline.' '."\n"
        let vheight = vheight + 1
      endif
      let vtokline = 1
      while 1
        let vtoken2 = s:GtdGetToken(vdisplay2,"\n",vtokline)
        if vtoken2 == ''
          break
        endif
        while strlen(vtoken2) < vcolumn
          let vtoken2 = vtoken2.' '
        endwhile
        let vstrline = vstrline.vtoken2."\n"
        let vtokline = vtokline + 1
        let vheight = vtokline + 1
      endwhile
      let vdisplay1 = vstrline
    endif
    let vmnth = vmnth + 1
    let vmcnt = vmcnt + 1
    if vmnth > 12
      let vmnth = 1
      let vyear = vyear + 1
    endif
  endwhile
  if exists("g:gtd_calendar_end")
    exe "call " . g:gtd_calendar_end . "()"
  endif
  if a:0 == 0
    return vdisplay1
  endif

  "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  "+++ build window
  "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  " make window
  let vwinnum=bufnr('__Calendar')
  if getbufvar(vwinnum, 'GtdCalendar')=='GtdCalendar'
    let vwinnum=bufwinnr(vwinnum)
  else
    let vwinnum=-1
  endif

  if vwinnum >= 0
    " if already exist
    if vwinnum != bufwinnr('%')
      exe "normal \<c-w>".vwinnum."w"
    endif
    setlocal modifiable
    silent %d _
  else
    " make title
    if (!exists('s:bufautocommandsset'))
      auto BufEnter *GtdCalendar let b:sav_titlestring = &titlestring | let &titlestring = '%{strftime("%c")}' | let b:sav_wrapscan = &wrapscan
      auto BufLeave *GtdCalendar let &titlestring = b:sav_titlestring | let &wrapscan = b:sav_wrapscan
      let s:bufautocommandsset=1
    endif

    if exists('g:gtd_calendar_navi') && dir
      if g:gtd_calendar_navi == 'both'
        let vheight = vheight + 4
      else
        let vheight = vheight + 2
      endif
    endif

    " or not
    if dir
      execute 'bo '.vheight.'split __Calendar'
      setlocal winfixheight
    else
      execute 'to '.vcolumn.'vsplit __Calendar'
    endif
    setlocal noswapfile
    setlocal buftype=nowrite
    setlocal bufhidden=delete
    setlocal nonumber
    setlocal nowrap
    setlocal norightleft
    setlocal foldcolumn=0
    setlocal modifiable
    setlocal nolist
    set nowrapscan
    let b:GtdCalendar='GtdCalendar'
    " is this a vertical (0) or a horizontal (1) split?
  endif
  let b:CalendarDir=dir
  let b:CalendarYear = vyear_org
  let b:CalendarMonth = vmnth_org

  " navi
  if exists('g:gtd_calendar_navi')
    let navi_label = '<'
        \.s:GtdGetToken(g:gtd_calendar_navi_label, ',', 1).' '
        \.s:GtdGetToken(g:gtd_calendar_navi_label, ',', 2).' '
        \.s:GtdGetToken(g:gtd_calendar_navi_label, ',', 3).'>'
    if dir
      let navcol = vcolumn + (vcolumn-strlen(navi_label)+2)/2
    else
      let navcol = (vcolumn-strlen(navi_label)+2)/2
    endif
    if navcol < 3
      let navcol = 3
    endif

    if g:gtd_calendar_navi == 'top'
      execute "normal gg".navcol."i "
      silent exec "normal! i".navi_label."\<cr>\<cr>"
      silent put! =vdisplay1
    endif
    if g:gtd_calendar_navi == 'bottom'
      silent put! =vdisplay1
      silent exec "normal! Gi\<cr>"
      execute "normal ".navcol."i "
      silent exec "normal! i".navi_label
    endif
    if g:gtd_calendar_navi == 'both'
      execute "normal gg".navcol."i "
      silent exec "normal! i".navi_label."\<cr>\<cr>"
      silent put! =vdisplay1
      silent exec "normal! Gi\<cr>"
      execute "normal ".navcol."i "
      silent exec "normal! i".navi_label
    endif
  else
    silent put! =vdisplay1
  endif

  setlocal nomodifiable

  let vyear = vyear_org
  let vmnth = vmnth_org

  "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  "+++ build keymap
  "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  " make keymap
  if vmnth > 1
    execute 'nnoremap <silent> <buffer> <s-left> :call GtdCalendar('.dir.','.vyear.','.(vmnth-1).')<cr>'
    execute 'nnoremap <silent> <buffer> H :call GtdCalendar('.dir.','.vyear.','.(vmnth-1).')<cr>'
  else
    execute 'nnoremap <silent> <buffer> <s-left> :call GtdCalendar('.dir.','.(vyear-1).',12)<cr>'
    execute 'nnoremap <silent> <buffer> H :call GtdCalendar('.dir.','.(vyear-1).',12)<cr>'
  endif
  if vmnth < 12
    execute 'nnoremap <silent> <buffer> <s-right> :call GtdCalendar('.dir.','.vyear.','.(vmnth+1).')<cr>'
    execute 'nnoremap <silent> <buffer> L :call GtdCalendar('.dir.','.vyear.','.(vmnth+1).')<cr>'
  else
    execute 'nnoremap <silent> <buffer> <s-right> :call GtdCalendar('.dir.','.(vyear+1).',1)<cr>'
    execute 'nnoremap <silent> <buffer> L :call GtdCalendar('.dir.','.(vyear+1).',1)<cr>'
  endif
  execute 'nnoremap <silent> <buffer> q :close<cr>'

  "execute 'nnoremap <silent> <buffer> <cr> :call <SID>CalendarDoAction()<cr>'
  execute 'nnoremap <silent> <buffer> <cr> :call <SID>GtdReturnSelecteDate()<cr>'
  execute 'nnoremap <silent> <buffer> <2-LeftMouse> :call <SID>CalendarDoAction()<cr>'
  execute 'nnoremap <silent> <buffer> t :call GtdCalendar(b:CalendarDir)<cr>'
  execute 'nnoremap <silent> <buffer> ? :call <SID>GtdCalendarHelp()<cr>'
  execute 'nnoremap <silent> <buffer> r :call GtdCalendar(' . dir . ',' . vyear . ',' . vmnth . ')<cr>'
  let pnav = s:GtdGetToken(g:gtd_calendar_navi_label, ',', 1)
  let nnav = s:GtdGetToken(g:gtd_calendar_navi_label, ',', 3)
  execute 'nnoremap <silent> <buffer> <Up>    :call <SID>CalendarDoAction("<' . pnav . '")<cr>'
  execute 'nnoremap <silent> <buffer> <Left>  :call <SID>CalendarDoAction("<' . pnav . '")<cr>'
  execute 'nnoremap <silent> <buffer> <Down>  :call <SID>CalendarDoAction("' . nnav . '>")<cr>'
  execute 'nnoremap <silent> <buffer> <Right> :call <SID>CalendarDoAction("' . nnav . '>")<cr>'

"  execute 'nnoremap <silent> <buffer> <c-cr> :call <SID>ReturnSelecteDate()<cr>'

  "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  "+++ build highlight
  "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  " today
  syn clear
  if g:gtd_calendar_mark =~ 'left-fit'
    syn match CalToday display "\s*\*\d*"
    syn match CalMemo display "\s*[+!#$%&@?]\d*"
  elseif g:gtd_calendar_mark =~ 'right'
    syn match CalToday display "\d*\*\s*"
    syn match CalMemo display "\d*[+!#$%&@?]\s*"
  else
    syn match CalToday display "\*\s*\d*"
    syn match CalMemo display "[+!#$%&@?]\s*\d*"
  endif
  " header
  syn match CalHeader display "[^ ]*\d\+\/\d\+([^)]*)"

  " navi
  if exists('g:gtd_calendar_navi')
    exec "silent! syn match CalNavi display \"\\(<"
        \.s:GtdGetToken(g:gtd_calendar_navi_label, ',', 1)."\\|"
        \.s:GtdGetToken(g:gtd_calendar_navi_label, ',', 3).">\\)\""
    exec "silent! syn match CalNavi display \"\\s"
        \.s:GtdGetToken(g:gtd_calendar_navi_label, ',', 2)."\\s\"hs=s+1,he=e-1"
  endif

  " saturday, sunday
  let dayorspace = '\(\*\|\s\)\(\s\|\d\)\(\s\|\d\)'
  if !exists('g:gtd_calendar_weeknm') || g:gtd_calendar_weeknm <= 2
    let wknmstring = '\(\sWK[0-9\ ]\d\)*'
  else
    let wknmstring = '\(\sKW[0-9\ ]\d\)*'
  endif
  let eolnstring = '\s\(|\|$\)'
  if exists('g:gtd_calendar_monday')
    execute "syn match CalSaturday display \'"
      \.dayorspace.dayorspace.wknmstring.eolnstring."\'ms=s+1,me=s+3"
    execute "syn match CalSunday display \'"
      \.dayorspace.wknmstring.eolnstring."\'ms=s+1,me=s+3"
  else
    if dir
      execute "syn match CalSaturday display \'"
        \.dayorspace.wknmstring.eolnstring."\'ms=s+1,me=s+3"
      execute "syn match CalSunday display \'\|"
        \.dayorspace."\'ms=s+2,me=s+4"
    else
      execute "syn match CalSaturday display \'"
        \.dayorspace.wknmstring.eolnstring."\'ms=s+1,me=s+3"
      execute "syn match CalSunday display \'^"
        \.dayorspace."\'ms=s+1,me=s+3"
    endif
  endif

  " week number
  if !exists('g:gtd_calendar_weeknm') || g:gtd_calendar_weeknm <= 2
    syn match CalWeeknm display "WK[0-9\ ]\d"
  else
    syn match CalWeeknm display "KW[0-9\ ]\d"
  endif

  " ruler
  execute 'syn match CalRuler "'.vwruler.'"'

  if search("\*","w") > 0
    silent execute "normal! gg/\*\<cr>"
  endif

  return ''
endfunction
 
"*****************************************************************
"* GtdCalendarSign : calendar sign function
"*----------------------------------------------------------------
"*   day   : day of sign
"*   month : month of sign
"*   year  : year of sign
"*****************************************************************
function! s:GtdCalendarSign(day, month, year)
  let sfile = g:gtd_calendar_diary."/".a:year."/".a:month."/".a:day.".cal"
  return filereadable(expand(sfile))
endfunction

"*****************************************************************
"* CalendarVar : get variable
"*----------------------------------------------------------------
"*****************************************************************
"function! s:CalendarVar(var)
"  if !exists(a:var)
"    return ''
"  endif
"  exec 'return ' . a:var
"endfunction

"*****************************************************************
"* GtdCalendarHelp : show help for GtdCalendar
"*----------------------------------------------------------------
"*****************************************************************
function! s:GtdCalendarHelp()
  echohl None
  echo 'GtdCalendar version ' . g:gtd_calendar_version
  echohl SpecialKey
  echo '<s-left>  : goto prev month'
  echo '<s-right> : goto next month'
  echo 't         : goto today'
  echo 'q         : close window'
  echo 'r         : re-display window'
  echo '?         : show this help'
  echo ''
  echohl Question
"  echo 'calendar_erafmt=' . s:CalendarVar('g:gtd_calendar_erafmt')
"  echo 'calendar_mruler=' . s:CalendarVar('g:gtd_calendar_mruler')
"  echo 'calendar_wruler=' . s:CalendarVar('g:gtd_calendar_wruler')
"  echo 'calendar_weeknm=' . s:CalendarVar('g:gtd_calendar_weeknm')
"  echo 'calendar_navi_label=' . s:CalendarVar('g:gtd_calendar_navi_label')
"  echo 'calendar_diary=' . s:CalendarVar('g:gtd_calendar_diary')
"  echo 'calendar_mark=' . s:CalendarVar('g:gtd_calendar_mark')
"  echo 'calendar_navi=' . s:CalendarVar('g:gtd_calendar_navi')
  echohl MoreMsg
  echo "[Hit any key]"
  echohl None
  call getchar()
  redraw!
endfunction

hi def link CalNavi     Search
hi def link CalSaturday Statement
hi def link CalSunday   Type
hi def link CalRuler    StatusLine
hi def link CalWeeknm   Comment
hi def link CalToday    Directory
hi def link CalHeader   Special
hi def link CalMemo     Identifier
