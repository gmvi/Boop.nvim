""" This file contains functions for installing the scripting engine

if !exists('g:Boop_force_build')
    let g:Boop_force_build = 0
endif

fun! boop#check_engine()
    if glob(g:boop#util#bin_path) ==# ""
        call s:install_engine()
    endif
endfun

fun! boop#reinstall_engine()
    " TODO: is there any value in keeping this rm/del call?
    if g:boop#util#unixlike
        call system("rm "..g:boop#util#bin_path)
    else
        call system("del "..g:boop#util#bin_path)
    endif
    call s:install_engine()
endfun

fun! s:install_engine()
    if !g:Boop_force_build
        echo "Boop.nvim: installing javascript engine..."
        if g:boop#util#unixlike
            let l:output = system(g:boop#util#plugin_root..'install_scripts/boop-nvim-install.sh')
        else
            let l:output = system(g:boop#util#plugin_root..'install_scripts/boop-nvim-install.bat')
        endif
        if v:shell_error == 0
            return 1
        else
            " Explain what's going on and ask if the user wants to build from source
            echom "It looks like this is your first time using Boop.nvim! Unfortunately a suitable prebuilt binary was not found and you will have to build the Javascript engine from source."
            if v:shell_error == 164
                echom "[INFO] Prebuilt binaries are not currently available for MacOS on ARM architecture. If you'd like to help: https://github.com/gmvi/Boop.nvim/issues/9"
            elseif v:shell_error == 107
                " Win64 but curl.exe was not found
            elseif v:shell_error != 132
                echom "[ERROR] Download script failed with error code ("..v:shell_error..")"
            endif
            " ask if the user wants to install from source
            let do_build = input("Build from source now? This requires the rust build tools and should take a few minutes (y/n) ")
            while 1
                let do_build = boop#util#strip(do_build)
                if do_build ==? 'y' || do_build ==? 'yes'
                    break
                elseif do_build ==? 'n' || do_build ==? 'no'
                    echom "To to initiate build from source, run :call boop#build_from_source()"
                    return 0
                endif
                let do_build = input("Didn't catch that. Build from source now? Requires rust and takes a few minutes (y/n) ")
            endwhile
        endif
    endif
    return boop#build_from_source()
endfun

fun! boop#build_from_source()
    let l:msg_pre = "Boop.nvim: building javascript engine from source"
    if g:boop#util#unixlike
        echo l:msg_pre.." (this may take a few minutes)..."
        let l:output = system(g:boop#util#plugin_root..'install_scripts/boop-nvim-build.sh')
    else
        echo l:msg_pre.." (this will take a while)..."
        let l:output = system(g:boop#util#plugin_root..'install_scripts/boop-nvim-build.bat')
    endif
    if v:shell_error == 0
        echo "Boop.nvim: build succeeded!"
        return 1
    endif
    " TODO add a way to re-run after a failed build, and add a friendly
    " message about installing the requisite MSVC build tools on Windows.
    echohl ErrorMsg
    echom "[ERROR] Boop.nvim: build from source failed. Re-run with :call boop#build_from_source()"
    echom l:output
    echohl None
endfun


