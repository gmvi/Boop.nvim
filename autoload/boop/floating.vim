fun! boop#floating#open_scratch() abort
    let ui = nvim_list_uis()[0]
    let l:width = 100
    let l:height = 25
    let l:opts = {
        \ 'relative': 'editor',
        \ 'width': l:width,
        \ 'height': l:height,
        \ 'col': 10,
        \ 'row': 5,
        \ 'border': 'double',
        \ 'title': '[Boop]',
        \ }
    let l:buf = nvim_create_buf(0, 1)
    let l:win = nvim_open_win(l:buf, 0, opts)
    call nvim_set_current_win(l:win)
    augroup BoopFloat
        autocmd! * <buffer>
        autocmd WinLeave <buffer> call nvim_win_close(0, 1)
    augroup END
endfun

fun! boop#floating#open_palette()
    if has('nvim')
        throw "floating palette not implemented yet"
    else " s:boop_palette == 'none'
        throw "floating palette not supported in vim"
    endif
endfun
