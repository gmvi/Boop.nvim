
fun! boop#neovim#init()
    if !exists('*jobstart')
        throw "Fatal: failed to find nvim jobstart()"
    endif
    let s:boop_jobid = jobstart([g:boop#util#bin_path], {'rpc': v:true })
endfun
