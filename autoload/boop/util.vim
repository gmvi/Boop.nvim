" check that we're on a supported platform
let g:boop#util#unixlike = has('linux') || has('mac')
if g:boop#util#unixlike
    let s:bin_name = 'boop'
elseif has('win32')
    let s:bin_name = 'boop.exe'
else
    throw "boop.vim: unsupported platform"
endif
" define paths
let g:boop#util#plugin_root = expand('<sfile>:p:h:h:h') . '/'
let g:boop#util#bin_path = g:boop#util#plugin_root . 'bin/' . s:bin_name

fun! boop#util#strip(str)
    if v:version >= 801
        return trim(str)
    else
        substitute(str, '^\s*\(.\{-}\)\s*$', '\1', '')
    endif
endfun
