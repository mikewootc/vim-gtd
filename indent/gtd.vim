setlocal indentexpr=GetGtdIndent()

function! GetGtdIndent()
    let preLine = getline(v:lnum - 1)

    let preIndent = match(preLine, '\[[ \a]\]')
    if preIndent < 0
        let preIndent = match(preLine, '\(\s*\)\@<=\*')
    endif

    if preIndent > 0
        let ind = preIndent
    else
        let ind = cindent(v:lnum)
    endif

    return ind
endfu
