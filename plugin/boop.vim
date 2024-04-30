""" User Settings
if !exists('g:Boop_use_oldscratch')
    let g:Boop_use_oldscratch = 0
endif
if !exists('g:Boop_use_oldsystem')
    let g:Boop_use_oldsystem = 0
endif
"if !exists('g:Boop_use_palette')
"    let g:Boop_use_palette = 1
"endif
if !exists('g:Boop_use_default_mappings')
    let g:Boop_use_default_mappings = 1
endif

""" Select features based on vim/neovim version
if has('nvim-0.6') && has('job') && !g:Boop_use_oldsystem
    let s:boop_engine_interface = 'job'
else
    let s:boop_engine_interface = 'system'
endif
if has('nvim-0.5') && !g:Boop_use_oldscratch
    let s:boop_pad_ui = 'floating'
else
    let s:boop_pad_ui = 'scratch'
endif
"if has('nvim-0.5') && g:Boop_use_palette
"    let s:boop_palette = 'floating'
"elseif v:version >= 802 && g:Boop_use_palette
"    let s:boop_palette = 'popup'
"else
"    let s:boop_palette = 'none'
"endif

" These overrides are for features not yet built
let s:boop_engine_interface = 'system'
let s:boop_palette = 'none'

" Configure the selected features
if s:boop_engine_interface == 'system'
    call boop#oldvim#init()
else " s:boop_engine_interface == 'job'
    throw "s:boop_engine_interface == 'job' not implemented yet"
    call boop#neovim#init()
endif
" Required for refocusing the scratch pad implementation
" TODO: implement use of window ID like in NERDTree/NERDTreeFocus
"let s:scratch_window = -1
if s:boop_pad_ui == 'scratch'
    set switchbuf +=useopen
endif


""" Main functions 
fun! s:BoopPad(mods) abort
    if !boop#check_engine()
        return
    endif
    if s:boop_pad_ui == 'floating'
        call boop#floating#open_scratch()
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
    if g:Boop_use_default_mappings
        nnoremap <buffer> <c-b> :BoopBuffer<space>
    endif
endfun

" Open the boop pad with the most recent selection (using :normal! gv)
fun! s:BoopPadFromSelection(mods) abort
    if !boop#check_engine()
        return
    endif
    " remember the user's old register contents
    let l:reg_old = getreg(s:boop_reg)
    try
        silent exec "normal!" "gv\""..s:boop_reg.."y"
        BoopPad
        exec "normal!" "ggVG\""..s:boop_reg.."p"
    endtry
    call setreg(s:boop_reg, l:reg_old)
endfun


""" Do the booping (core functions; user-facing commands below)

fun! s:BoopCompletion(ArgLead, CmdLine, CursorPos) abort
    if !boop#check_engine(v:false)
        return
    endif
    let l:idx_first_space = stridx(a:CmdLine, ' ')
    let l:left_of_cursor = a:CmdLine[l:idx_first_space+1:a:CursorPos]
    let l:len_prev_args = a:CursorPos - strlen(a:ArgLead) - l:idx_first_space - 1
    " get the list of scripts
    if s:boop_engine_interface == "system"
        let l:script_list = split(system(g:boop#util#bin_path.." -l"), '\n')
    else "s:boop_engine_interface == 'job'
        throw "s:boop_engine_interface == 'job' not implemented yet"
    endif
    let l:matches = filter(l:script_list, 'v:val =~ "^"..l:left_of_cursor')
    " because the completion engine only understands space-separated
    " arguments, trim the previous arguments off each match
    return map(l:matches, 'v:val[l:len_prev_args:]')
endfun

let s:boop_reg = 'x'
fun! s:DoBoop(args) abort
    " the `, 1, 1` below is to not translate NULs to newlines -- VimL is weird
    let l:input = getreg(s:boop_reg, 1, 1)
    if s:boop_engine_interface == "system"
        " Try to init again in case the user fixed a system issue (e.g.
        " filesystem permissions). This will exit early if init already
        " succeeded.
        if !boop#oldvim#init()
            return 0
        endif

        if g:boop#util#unixlike
            let l:stderr_mute = '2>/dev/null'
        else " has('win32')
            let l:stderr_mute = '2>NUL'
        endif
        " info and error files will be overwritten
        let l:cmd_list = [ g:boop#util#bin_path,
                         \ '--info-file', g:boop#oldvim#info_file,
                         \ '--error-file', g:boop#oldvim#error_file,
                         \ shellescape(a:args),
                         \ l:stderr_mute,
                         \ ]

        let l:output = system(join(l:cmd_list), l:input)
        if v:shell_error != 0
            echohl ErrorMsg
            echom "Boop.vim: boop invocation failed ("..v:shell_error..")"
            echohl None
        endif
        try
            let l:error_output = readfile(g:boop#oldvim#error_file)
            if len(l:error_output) > 0
                echohl ErrorMsg
                echom trim(join(l:error_output, "\n"))
                echohl None
            endif
        endtry

        if v:shell_error != 0
            return 0
        endif

        try
            let l:info_output = readfile(g:boop#oldvim#info_file)
            if len(l:info_output) > 0
                echohl MoreMsg
                echom trim(join(l:info_output, "\n"))
                echohl None
            endif
        endtry

        call setreg(s:boop_reg, l:output)
        return l:input !=# split(l:output, '\r\?\n', 1)

    else "s:boop_engine_interface == 'job'
        throw "s:boop_engine_interface == 'job' not implemented yet"
        return 0
    endif
endfun

" Boops the entire buffer
fun! s:BoopBuffer(args) abort
    if !boop#check_engine()
        return
    endif
    let script = len(a:args) ? a:args : boop#floating#open_scratch()
    " remember the user's old register contents
    let l:reg_old = getreg(s:boop_reg)
    try
        silent exec "%yank" s:boop_reg
        if s:DoBoop(a:args)
            silent exec "normal!" "gg\"_dG\""..s:boop_reg.."P"
        endif
    endtry
    call setreg(s:boop_reg, l:reg_old)
endfun

" Boops the current line. Does not affect the recent selection (gv)
" TODO: make this work linewise instead of just one single line
fun! s:BoopLine(args) abort
    if !boop#check_engine()
        return
    endif
    let script = len(a:args) ? a:args : boop#floating#open_scratch()
    " remember the user's old register contents
    let l:reg_old_contents = getreg(s:boop_reg)
    try
        silent exec "yank" s:boop_reg
        if s:DoBoop(a:args)
            " do a `substitute` instead of some normal! dd/P command, cause it
            " wasn't working for me.
            let l:search_reg = getreg('/')
            silent exec "substitute" "/.*/\\=@"..s:boop_reg.."/"
            call setreg('/', l:search_reg)
        endif
    endtry
    call setreg(s:boop_reg, l:reg_old_contents)
endfun

" Boops the most recent selection (i.e. the current selection if triggered from visual mode)
" TODO: bugfix: `vap:boop [script]<cr>` removes a trailing newline
fun! s:BoopSelection(args) abort
    if !boop#check_engine()
        return
    endif
    let script = len(a:args) ? a:args : boop#floating#open_scratch()
    " remember the user's old register contents
    let l:reg_old = getreg(s:boop_reg)
    try
        silent exec "normal!" "gv\""..s:boop_reg.."y"
        if s:DoBoop(script)
            silent exec "normal!" "gv\""..s:boop_reg.."p"
        endif
    endtry
    call setreg(s:boop_reg, l:reg_old)
endfun

" Boop pad commands
" In vim the boop pad opens as a split, so apply <q-mods>
command! BoopPad call s:BoopPad(<q-mods>)
command! -range BoopPadFromSelection call s:BoopPadFromSelection(<q-mods>)
" Boop commands
if s:boop_palette == 'none'
    " If you invoke Boop with no arguments in oldvim, have it press tab for you
    command! -nargs=* -complete=customlist,s:BoopCompletion -range Boop 
        \ eval <q-args>=="" ? feedkeys(":Boop \<Tab>", 't') : s:BoopSelection(<q-args>)
    command! -nargs=* -complete=customlist,s:BoopCompletion BoopBuffer
        \ eval <q-args>=="" ? feedkeys(":BoopBuffer \<Tab>", 't') : s:BoopBuffer(<q-args>)
    "command! -nargs=* -complete=custom,s:BoopCompletion BoopLine
    "    \ eval <q-args>=="" ? feedkeys(":BoopLine \<Tab>", 't') : s:BoopLine(<q-args>)
else
    " In neovim, calling these commands with no arguments will open the floating palette
    command! -nargs=* -complete=customlist,s:BoopCompletion -range Boop call s:BoopSelection(<q-args>)
    command! -nargs=* -complete=customlist,s:BoopCompletion BoopBuffer call s:BoopBuffer(<q-args>)
    "command! -nargs=* -complete=custom,s:BoopCompletion BoopLine call s:BoopLine(<q-args>)
endif
" Command to display the list of available scripts
if has('unix') || has('osxunix')
    " You may prefer a different value than -3 below
    command! ListBoopScripts !echo; boop -l | pr -3 -t
elseif has('win32')
    command! ListBoopScripts !echo.& boop -l
endif

if g:Boop_use_default_mappings
    nnoremap <c-b> :BoopPad<CR>
    xnoremap <c-b> :Boop<Space>
endif
