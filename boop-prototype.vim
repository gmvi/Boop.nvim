"
" from visual mode, press <ctrl-b> to get a prompt to choose a boop script
" from normal mode, press <ctrl-b> to open or focus the boop scratch pad
" within the scratch pad, press <ctrl-b> to run a script for the whole pad
" press <ctrl-l> to print the list of boop scripts

nnoremap <c-b> :call BoopPad()<cr>
xnoremap <c-b> :Boop 
" You may prefer a different value than 3 below
nnoremap <c-l> :!boop -l \| pr -3 -t<cr>

" Required for refocusing the scratch pad
set switchbuf +=useopen
function! BoopPad()
    try
        sbuffer \[Boop\]
    catch
        new
        setlocal nobuflisted buftype=nofile bufhidden=delete noswapfile
        file \[Boop\]
    endtry
    " add two convenience uses of <c-b> in the [Boop] buffer
    nnoremap <buffer> <c-b> ggVG:Boop 
    xnoremap <buffer> <c-b> :Boop 
endfunction

" Make a simple command wrapper around !boop with autocompletion
function! BoopCompletion(ArgLead, CmdLine, CursorPos)
    return system("boop -l")
endfunction
command! -range -nargs=1 -complete=custom,BoopCompletion Boop '<,'>!boop <f-args>
