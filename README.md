# Boop.vim
> [!IMPORTANT]
> This is a prototype. It hasn't been tested on OSX or Windows yet.

## Installing
I haven't looked at (Neo)vim package managers or prebuilt binaries yet. You'll have to build from source.

## Building from source

### Requirements
Linux and Rust.

1. Clone this repo
2. Clone all the submodules: `git submodule update --init --recursive`
3. Install the boop binary: `cargo install --path .`
4. Ensure the boop binary is in your path: `echo "asdf" | boop Rot13`
5. (optional) Install the bash completion script into your .bashrc: `source boop-completion.bash`
6. Source the .vim file from your .vimrc: `source 'boop-prototype.vim'`
7. Add bindings to your .vimrc:
```
"
" The boop pad is a scratch pad emulating some of the Boop app
" From normal mode, press <ctrl-b> to open the boop pad (for vim, will also focus the boop pad).
nnoremap <c-b> :BoopPad<cr>
" If you'd rather open the boop pad vertically, add the vertical modifier (only for vim; nvim uses a floating window)
"nnoremap <c-b> :vertical BoopPad<cr>

" From visual mode, press <ctrl-b> to run a boop script on the selection
xnoremap <c-b> :Boop<space>
" Or, use <ctrl-b> in visual mode to populate the boop pad with the selection
"xnoremap <c-b> :BoopPadFromSelection<cr>


" remap keys within the boop pad
augroup boop_mapping
    autocmd!
    autocmd BufEnter,FileType boop call s:BoopMapping()
augroup END

function! s:BoopMapping()
    " Within the scratch pad, press <ctrl-b> to run a script over the whole pad.
    " Press <ctrl-l> to see a listing of all boop scripts.
    nnoremap <buffer> <c-b> :BoopBuffer<space>
    xnoremap <buffer> <c-b> :Boop<space>
    nnoremap <buffer> <c-l> :ListBoopScripts<cr>
endfunction
```
