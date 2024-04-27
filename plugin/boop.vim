let s:boop_register = 'x'

" These overrides are for features not yet built
let g:boop#use_engine = 'system'
let g:boop#use_palette = 'none'

" Initialize the engine
if g:boop#use_engine == 'system'
    call boop#oldvim#init()
else " g:boop#use_engine == 'job'
    throw "g:boop#use_engine == 'job' not implemented yet"
    call boop#neovim#init()
endif
" Required for refocusing the scratch pad implementation
" TODO: implement use of window ID like in NERDTree/NERDTreeFocus
"let s:scratch_window = -1
if !g:boop#use_floating
    set switchbuf +=useopen
endif


""" Main functions 
fun! s:CmdBoopPad(mods, range) abort
    if !boop#check_engine() | return | endif
    " if the default is a floating window, then ignore that if a directional
    " split modifier is present
    let l:use_floating = g:boop#use_floating
    if l:use_floating && a:mods
        for m in [ 'aboveleft', 'belowright', 'botright', 'horizontal',
                 \ 'leftabove', 'rightbelow', 'tab', 'topleft', 'vertical',
                 \ ]
            if stridx(a:mods, m) >= 0
                let l:use_floating = 0
                break
            endif
        endfor
    endif
    " if invoked from visual mode, copy the selection into the scratch pad
    let l:from_visual = 0
    let l:reg_old_contents = getreg(s:boop_register)
    if a:range == 2 && histget(':', -1)[:4] ==# "'<,'>"
        let l:from_visual = 1
        silent exec "normal!" "gv\""..s:boop_register.."y"
    endif
    call s:open_boop_pad(a:mods)
    if l:from_visual
        silent exec "%delete _ | %put" s:boop_register "| 0delete _"
        call setreg(s:boop_register, l:reg_old_contents)
    endif
endfun

fun! s:open_boop_pad(mods) abort
    if g:boop#use_floating
        call boop#floating#open_scratch()
        try
            buffer \[Boop]
            return
        catch
            " new buffer, continue on to set local options and mappings
        endtry
    else
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
        nnoremap <buffer> <c-b> :%Boop<space>
    endif
endfun

" Open the boop pad with the most recent selection (using :normal! gv)
fun! s:BoopPadFromSelection(mods) abort
    if !boop#check_engine() | return | endif
    " remember the user's old register contents
    let l:reg_old = getreg(s:boop_register)
    try
        silent exec "normal!" "gv\""..s:boop_register.."y"
        BoopPad
        exec "normal!" "ggVG\""..s:boop_register.."p"
    endtry
    call setreg(s:boop_register, l:reg_old)
endfun


fun! s:BoopCompletion(ArgLead, CmdLine, CursorPos) abort
    if !boop#check_engine(v:false) | return | endif
    let l:idx_first_space = stridx(a:CmdLine, ' ')
    let l:left_of_cursor = a:CmdLine[l:idx_first_space+1:a:CursorPos]
    let l:len_prev_args = a:CursorPos - strlen(a:ArgLead) - l:idx_first_space - 1
    " get the list of scripts
    if g:boop#use_engine == "system"
        let l:script_list = split(system(g:boop#util#bin_path.." -l"), '\n')
    else "g:boop#use_engine == 'job'
        throw "g:boop#use_engine == 'job' not implemented yet"
    endif
    let l:matches = filter(l:script_list, 'v:val =~ "^"..l:left_of_cursor')
    " because the completion engine only understands space-separated
    " arguments, trim the previous arguments off each match
    return map(l:matches, 'v:val[l:len_prev_args:]')
endfun

fun! s:DoBoop(args) abort
    " the additional arguments to getreg tell it not to translate NULs to newlines
    let l:input = getreg(s:boop_register, 1, 1)
    if g:boop#use_engine == "system"
        if !boop#oldvim#init()
            " Abort if init failed
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

        call setreg(s:boop_register, l:output)
        " return success if input and output are different lines
        return l:input !=# split(l:output, '\r\?\n', 1)

    else "s:boop_engine_interface == 'job'
        throw "s:boop_engine_interface == 'job' not implemented yet"
        return 0
    endif
endfun

" Boops either a range of lines, or (from visual mode) the most recent selection
fun! s:CmdBoop(args, mods, range, line1, line2) abort
    " TODO: bugfix: `vap:boop [script]<cr>` removes a preceding newline
    if !boop#check_engine()
        return
    endif
    let l:from_visual = 0
    if a:range == 2 && histget(':', -1)[:4] ==# "'<,'>"
        let l:from_visual = 1
        " if invoked from visual mode with no script and g:Boop_default_action
        " is 'fromselection', then load the selection into the Boop pad
        if !strlen(a:args) && g:Boop_default_action =~ '^\.\?fromselection$'
            return s:BoopPadFromSelection('')
        endif
    else
        " if invoked from normal mode with no script and g:Boop_default_action is
        " 'pad' or 'fromselection', then open the Boop pad
        if !strlen(a:args) && g:Boop_default_action =~ '^\.\?\(pad\|fromselection\)$'
            return s:BoopPad(a:mods, a:range)
        endif
    endif
    " If you invoke :Boop with no arguments in oldvim, start completion
    if g:boop#use_palette == 'none' && !strlen(a:args)
        return boop#oldvim#press_tab('Boop')
    endif
    let script = strlen(a:args) ? a:args : boop#floating#open_palette()
    if !strlen(script)
        echohl ErrorMsg | echom "[Boop.nvim] Error: no script selected" | echohl None
        return
    endif
    " remember the old register contents
    let l:reg_old_contents = getreg(s:boop_register)
    try
        if l:from_visual
            " if the command was triggered from visual mode, then boop the selection
            silent exec 'normal!' 'gv"'..s:boop_register..'y'
            let l:boop_success = s:DoBoop(script)
            if l:boop_success
                " only paste if the script succeeded
                silent exec 'normal!' 'gv"'..s:boop_register..'p'
            endif
        else " normal mode
            if a:line1==0 && a:line2==line('$')
                " if the range is the whole buffer, track it as % for later
                let l:range = '%'
            else
                let l:range = a:line1..','..a:line2
            endif
            " if no range was given and '.' is not the default range, boop the whole buffer
            if a:range == 0 && g:Boop_default_action[0] != '.'
                let l:range = '%'
            endif
            silent exec l:range 'yank' s:boop_register
            let l:boop_success = s:DoBoop(script)
            if l:boop_success
                " only paste if the script succeeded
                silent exec l:range 'delete _'
                silent exec line('.')-1 'put' s:boop_register
                " %delete creates an extra newline
                if l:range == '%' && line('$') > 1
                    silent exec '$delete _'
                endif
                "TODO: return to the original cursor position
            endif
        endif
    finally
        call setreg(s:boop_register, l:reg_old_contents)
    endtry
endfun

" Command definitions
command! -range BoopPad call s:CmdBoopPad(<q-mods>, <range>)
command! -range -nargs=? -complete=customlist,s:BoopCompletion Boop
            \ call s:CmdBoop(<q-args>, <q-mods>, <range>, <line1>, <line2>)
command! ListBoopScripts call boop#oldvim#ListBoopScripts()



fun! s:apply_default_mappings()
    " TODO: what effect would using <cmd> mappings have here?
    nnoremap <c-b> :BoopPad<CR>
    if g:boop#use_palette == 'none'
        vnoremap <c-b> :Boop<Space>
    else
        vnoremap <c-b> :Boop<CR>
    endif
endfun
if g:Boop_use_default_mappings
    call s:apply_default_mappings()
endif
