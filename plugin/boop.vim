let s:bin_dir = expand('%:p:h') . '/bin/'
if has('linux')
    let s:boop_bin = s:bin_dir . 'boop-Linux'
elseif has('mac')
    let s:boop_bin = s:bin_dir . 'boop-macOS'
elseif has('win32')
    let s:boop_bin = s:bin_dir . 'boop.exe'
else
    throw "boop.vim: unsupported platform"
endif

""" User Settings
if !exists('g:Boop_use_floating')
    let g:Boop_use_floating = 1
endif
"if !exists('g:Boop_use_palette')
"    let g:Boop_use_palette = 1
"endif
if !exists('g:Boop_default_mappings')
    let g:Boop_default_mappings = 1
endif

""" Select Implementation Details
"if has('nvim-0.6') || has('job')
"    let s:boop_engine_interface = 'job'
"else
"    let s:boop_engine_interface = 'system'
"endif
if has('nvim-0.5') && g:Boop_use_floating
    let s:boop_pad_ui = 'floating'
else
    let s:boop_pad_ui = 'scratch'
endif
"if !g:Boop_use_pallette
"    let s:boop_palette = 'none'
"elseif has('nvim-0.5')
"    let s:boop_palette = 'floating'
"elseif v:version >= 802
"    let s:boop_palette = 'popup'
"else
"    let s:boop_palette = 'none'
"endif

" Set values here for development testing
let s:boop_engine_interface = 'system'
"let s:boop_pad_ui = 'floating'
let s:boop_palette = 'none'



""" functions for floating and popup windows
fun! s:OpenFloatingWindow() abort
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

fun! s:OpenBoopPalette() abort
    if s:boop_palette == 'floating'
        throw "s:boop_palette == 'floating' not implemented yet"
    elseif s:boop_palette == 'popup'
        throw "s:boop_palette == 'popup' not implemented yet"
    else " s:boop_palette == 'none'
        throw "Boop.vim: s:OpenBoopPalette() called with s:boop_palette == 'none'"
    endif
endfun



""" The Boop Pad
if s:boop_engine_interface == 'system'
    let s:boop_info_file = tempname()
    let s:boop_error_file = tempname()
    let s:boop_scratch_window = -1
else " s:boop_engine_interface == 'job'
    " json vs msgpack is determined by an if has('nvim')
    throw "s:boop_engine_interface == 'job' not implemented yet"
endif

" Required for refocusing the scratch pad implementation
" TODO: implement use of window ID like in NERDTree/NERDTreeFocus
let s:scratch_window = -1
if s:boop_engine_interface == 'scratch'
    set swtichbuf +=useopen
endif

fun! s:BoopPad(mods) abort
    if s:boop_pad_ui == 'floating'
        call s:OpenFloatingWindow()
        try
            b \[Boop]
            return
        catch
            " new buffer, continue on to set local options and mappings
        endtry
    else " s:boop_pad_ui == 'scratch'
        try
            exec a:mods "sbuffer \\[Boop]"
            return
        catch
            exec a:mods "new"
            " new buffer, continue on to set local options and mappings
        endtry
    endif
    file \[Boop]
    setlocal nobuflisted buftype=nofile bufhidden=hide noswapfile
    setlocal filetype=boop
    if g:Boop_default_mappings
        nnoremap <buffer> <c-b> :BoopBuffer<space>
        xnoremap <buffer> <c-b> :Boop<space>
    endif
endfun

" Open the boop pad with the most recent selection (i.e. :normal! gv)
fun! s:BoopPadSelection(mods) abort
    " remember the user's old register contents
    let l:reg_old = getreg(s:boop_reg)
    try
        silent exec "normal!" "gv\""..s:boop_reg.."y"
        BoopPad
        exec "normal!" "ggVG\""..s:boop_reg.."p"
    endtry
    call setreg(s:boop_reg, l:reg_old)
endfun



""" Core Boop functionality
fun! s:BoopCompletion(ArgLead, CmdLine, CursorPos)
    " TODO: implement this with the rpc interface, and do it correctly using the completion parameters
    return system("boop -l")
endfun

let s:boop_reg = 'x'
fun! s:DoBoop(args) abort
    " the `, 1, 1` below is to not translate NULs to newlines -- VimL is weird
    let l:input = getreg(s:boop_reg, 1, 1)
    if s:boop_engine_interface == "system"
        let l:cmd_list = [
            \ s:boop_bin,
            \ '--info-file', s:boop_info_file, '--error-file', s:boop_error_file,
            \ shellescape(a:args)
            \ ]
        "if has('unix') || has('macosunix')
        "    let l:cmd_list = l:cmd_list + ['2>/dev/null']
        "elseif has('win32')
        "    let l:cmd_list = l:cmd_list + ['2>NUL']
        "else
        "    throw "boop.vim: unsupported platform"
        "endif
        let l:output = system(join(l:cmd_list), l:input)
        if v:shell_error != 0
            echohl ErrorMsg
            echom "Boop.vim: boop command failed with exit code " . v:shell_error
            echohl None
            call setreg(s:boop_reg, l:output)
            return
        endif
        try
            let l:info_output = readfile(s:boop_info_file)
            if len(l:info_output) > 0
                echohl MoreMsg
                echom trim(join(l:info_output, "\n"))
                echohl None
            endif
        endtry
        try
            let l:error_output = readfile(s:boop_error_file)
            if len(l:error_output) > 0
                echohl ErrorMsg
                echom trim(join(l:error_output, "\n"))
                echohl None
            endif
        endtry
        call setreg(s:boop_reg, l:output)
    else "s:boop_engine_interface == 'job'
        throw "s:boop_engine_interface == 'job' not implemented yet"
    endif
endfun

" Boops the entire buffer
fun! s:BoopBuffer(args) abort
    let script = len(a:args) ? a:args : s:OpenBoopPalette()
    " remember the user's old register contents
    let l:reg_old = getreg(s:boop_reg)
    try
        silent exec "%yank" s:boop_reg
        call s:DoBoop(a:args)
        silent exec "normal!" "gg\"_dG\""..s:boop_reg.."P"
    endtry
    call setreg(s:boop_reg, l:reg_old)
endfun

" Boops the current line. Does not affect the recent selection (gv)
" TODO: make this work linewise instead of just one single line
function! s:BoopLine(args) abort
    let script = len(a:args) ? a:args : s:OpenBoopPalette()
    " remember the user's old register contents
    let l:reg_old = getreg(s:boop_reg)
    try
        silent exec "yank" s:boop_reg
        call s:DoBoop(a:args)
        " do a `substitute` instead of some normal! dd/P command, cause it
        " wasn't working for me.
        let l:search_reg = getreg('/')
        silent exec "substitute" "/.*/\\=@"..s:boop_reg.."/"
        call setreg('/', l:search_reg)
    endtry
    call setreg(s:boop_reg, l:reg_old)
endfunction

" Boops the most recent selection (i.e. the current selection if triggered from visual mode)
" TODO: bugfix: `vap:boop [script]<cr>` removes a trailing newline
function! s:BoopSelection(args) abort
    let script = len(a:args) ? a:args : s:OpenBoopPalette()
    " remember the user's old register contents
    let l:reg_old = getreg(s:boop_reg)
    try
        silent exec "normal!" "gv\""..s:boop_reg.."y"
        call s:DoBoop(script)
        silent exec "normal!" "gv\""..s:boop_reg.."p"
    endtry
    call setreg(s:boop_reg, l:reg_old)
endfunction

" Boop pad commands
command! BoopPad call s:BoopPad(<q-mods>)
command! -range BoopPadFromSelection call s:BoopPadSelection(<q-mods>)
" Boop commands
if s:boop_palette == 'none'
    " If you invoke Boop with no arguments in oldvim, have it press tab for you
    command! -nargs=* -complete=custom,s:BoopCompletion -range Boop 
        \ eval <q-args>=="" ? feedkeys(":Boop \<Tab>", 't') : s:BoopSelection(<q-args>)
    command! -nargs=* -complete=custom,s:BoopCompletion BoopBuffer
        \ eval <q-args>=="" ? feedkeys(":BoopBuffer \<Tab>", 't') : s:BoopBuffer(<q-args>)
    "command! -nargs=* -complete=custom,s:BoopCompletion BoopLine
    "    \ eval <q-args>=="" ? feedkeys(":BoopLine \<Tab>", 't') : s:BoopLine(<q-args>)
else
    command! -nargs=* -complete=custom,s:BoopCompletion -range Boop call s:BoopSelection(<q-args>)
    command! -nargs=* -complete=custom,s:BoopCompletion BoopBuffer call s:BoopBuffer(<q-args>)
    "command! -nargs=* -complete=custom,s:BoopCompletion BoopLine call s:BoopLine(<q-args>)
endif
" Command to display the list of available scripts
if has('unix') || has('osxunix')
    " You may prefer a different value than -3 below
    command! ListBoopScripts !echo; boop -l | pr -3 -t
elseif has('win32')
    command! ListBoopScripts !echo.& boop -l
endif
