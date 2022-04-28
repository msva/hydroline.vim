" 02.04.2021: Adding some things inspired by "lightline", made by "itchyny"

if exists('g:mva_lines_loaded')
  finish
endif
let g:mva_lines_loaded=1

"set tabline=%!statusline#TL()
set statusline=%!statusline#SL()

"augroup lines
"  autocmd!
"  autocmd WinEnter,BufEnter,BufDelete,SessionLoadPost,FileChangedShellPost,CursorMoved,CursorMovedI,CursorHold,CursorHoldI,Mode * call statusline#Up()
"  autocmd SessionLoadPost * call statusline#Up()
"  autocmd ColorScheme * if !has('vim_starting') || expand('<amatch>') !=# 'macvim' | call statusline#Up() | endif
"augroup END

let &titlestring = substitute(&titlestring,'expand("%:t")','statusline#get_filename()',"g")
