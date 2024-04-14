" check that we're on a supported platform
let g:boop#util#unixlike = has('linux') || has('mac')
if g:boop#util#unixlike
    let s:bin_name = 'boop'
elseif has('win32')
    let s:bin_name = 'boop.exe'
else
    throw "boop.vim: unsupported platform"
endif
" define the path to the binary
let s:bin_dir = expand('<sfile>:p:h:h:h') . '/bin/'
let g:boop#util#bin_path = s:bin_dir . s:bin_name
