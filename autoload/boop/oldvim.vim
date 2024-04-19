fun! boop#oldvim#init() abort
    fun! s:f()
        let s:oldvim_init_success = 0
        if g:boop#util#unixlike
            let l:touch = "touch"
        else " has('win32')
            let l:touch = "copy nul"
        endif
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
