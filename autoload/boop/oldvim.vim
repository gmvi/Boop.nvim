fun! boop#oldvim#init() abort
    fun! s:f()
        let s:oldvim_init_success = 0
        let l:touch = g:boop#util#unixlike ? 'touch' : 'copy nul'
        if !exists("g:boop#oldvim#info_file")
            let g:boop#oldvim#info_file = tempname()
        endif
        if !exists("g:boop#oldvim#error_file")
            let g:boop#oldvim#error_file = tempname()
        endif
        if !exists("g:boop#oldvim#boop_scratch_window")
            let g:boop#oldvim#boop_scratch_window = -1
        endif
        call system(touch.." "..shellescape(g:boop#oldvim#info_file))
        if v:shell_error != 0
            return
        endif
        call system(touch.." "..shellescape(g:boop#oldvim#error_file))
        if v:shell_error != 0
            return
        endif
        let s:oldvim_init_success = 1
    endfun
    call s:f()
    if !s:oldvim_init_success
        echohl ErrorMsg
        echom "Boop.nvim: vim compatibility setup failed"
        echohl None
        return 0
    endif
    return 1
endfun

fun! boop#oldvim#cleanup() abort
    if exists("g:boop#oldvim#info_file")
        call delete(g:boop#oldvim#info_file)
    endif
    if exists("g:boop#oldvim#error_file")
        call delete(g:boop#oldvim#error_file)
    endif
endfun

" Rewrites the previous command in history and then presses the tab key
" This function enables commands in oldvim to open completion
fun! boop#oldvim#press_tab(command)
    let l:cmd_history_latest = histget(':', -1)
    if l:cmd_history_latest[-1:] != ' '
        let l:cmd_history_latest ..= ' '
    endif
    call histdel(':', -1)
    call feedkeys(':'..l:cmd_history_latest.."\<Tab>", 't')
endfun

" Enables a command that prints all the script names
fun! boop#oldvim#ListBoopScripts()
    if g:boop#use_engine == 'system'
        let l:scripts = split(system(g:boop#util#bin_path ..' -l'), '\r\?\n')
    else " g:boop#use_engine == 'job'
        throw "g:boop#use_engine == 'job' not implemented yet"
    endif
    let l:n_columns = 3
    let l:columns = s:cut_into_columns(l:scripts, l:n_columns)
    let l:width = (81/l:n_columns)-1
    for j in range(len(l:columns[0]))
        echo ''
        for i in range(l:n_columns)
            try | let l:item = l:columns[i][j] | catch | break | endtry
            echon printf('%-'..l:width..'S', l:item[:l:width-1])
            if i < l:n_columns-1 | echon ' ' | endif
        endfor
    endfor
endfun

fun! s:cut_into_columns(list, n_columns) abort
    let l:remainder = len(a:list) % a:n_columns
    let l:height = (len(a:list) / a:n_columns) + (l:remainder > 0)
    let l:columns = []
    let j = 0
    for i in range(a:n_columns)
        let k = j+l:height
        if i >= l:remainder | let k = k-1 | endif
        call add(l:columns, a:list[j:k-1])
        let j = k
    endfor
    return l:columns
endfun

