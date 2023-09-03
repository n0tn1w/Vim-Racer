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

" the text that needs to be writen 
let g:game_content = ''

" name of the buffer for the content
let g:game_buff_name = 'game_content_buff.txt'

" name of the buffer for user's content
let g:user_buff_name = 'user_content_buff.txt'

" stored every game promt 
let g:game_data = 'content/game_data.txt'

" solution to every game promt
let g:game_solution = 'content/game_solution.txt'

" code of the line from the g:game_data and g:game_solution 
let g:game_line = 0

" game_state can be 0 for not started and 1 for started
if !exists('g:game_state')
	let g:game_state = 0
endif

autocmd BufEnter * call vimracer#DisableVisualAndVBlockMode()

command! VimRacerStart call vimracer#Start()
command! VunRacerJoin call vimracer#Join()
command! CFC call vimracer#CheckBufferContent()

nnoremap <silent> <plug>VimRacerStart :<c-u>call vimracer#Start()<cr>
nnoremap <silent> <plug>CFC :<c-u>call vimracer#CheckBufferContent<cr>
nnoremap <silent> <plug>VunRacerJoin :<c-u>call vimracer#Join()<cr>

let &cpo = s:keepcpo
unlet s:keepcpo
