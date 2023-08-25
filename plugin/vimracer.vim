if exists("g:loaded_vimracer") || &cp
  finish
endif

let g:loaded_vimracer = '1.0.0' " version number
let s:keepcpo          = &cpo
set cpo&vim

"Server or client
let g:type = 'server'

" get job ids
let g:clientJobId = 0
let g:serverJobId = 0

" the text that need to be writen 
let g:game_content = ''

" name of the buffer for the content
let g:game_buff_name = "game_content_buff.txt"

" name of the buffer for the content
let g:user_buff_name = "user_content_buff.txt"

" game_state can be 0 for not started and 1 for started
if !exists('g:game_state')
	let g:game_state = 0
endif

autocmd BufEnter * call vr#DisableVisualAndVBlockMode()

command! VimRacerStart call vr#Start()
command! VunRacerJoin call vr#Join()
command! CFC call vr#CheckBufferContent()

nnoremap <silent> <plug>VimRacerStart :<c-u>call vr#Start()<cr>
nnoremap <silent> <plug>CFC :<c-u>call vr#CheckBufferContent<cr>
nnoremap <silent> <plug>VunRacerJoin :<c-u>call vr#Join()<cr>

let &cpo = s:keepcpo
unlet s:keepcpo
