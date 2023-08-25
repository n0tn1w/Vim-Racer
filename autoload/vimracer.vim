" Start as client
function! vr#Join()

	if g:game_state == 1
		return
	endif

	g:type = 'client'
	g:game_state = 1;

	let command = "../communication/client"
	g:clientJobId =  job_start(l:command, { 'out_cb': function('HandleCommunication'), 'err_cb': function('HandleCommunication')})

endfunction

" Start as server
function! vr#Start()

	if g:game_state == 1
		return
	endif

	g:type = 'server'
	g:game_state = 1;

	let command = "../communication/server"
	g:serverJobId =  job_start(l:command, { 'out_cb': function('HandleCommunication'), 'err_cb': function('HandleCommunication')})

endfunction


" Have the task to process the data that is sent from the server
function! s:HandleCommunication(job, line)

	if g:game_state == 0 
		return
	endif
`
	if CheckForContentMessage()	
		g:game_content = strpart(a:line, 5)
		call OpenGameBuffer()	
	endif
	
	if CheckForEndMessage()	
		g:game_state = 0
		echomsg 'You lost'
		call CloseGameBuffer()	
	endif

endfunction

" Open the buffer that is designed for the text
function! s:OpenGameBuffer()

	execute 'new ' . g:game_buff_name
	call append(0, g:content)
        
	setlocal nomodifiable
        wincmd p

endfunction

" Closes the buffer that is designed for the text
function! s:CloseGameBuffer()
	
	execute 'bd! ' . g:game_buff_name

endfunction

" Check if the message contains a command
function! s:CheckForContentMessage(line)

    	return strpart(a:line, 0, 5) == "open:"

endfunction

" Disables visual and visual block mode so that the player cannot copy paste
function! vr#DisableVisualAndVBlockMode()

	if g:game_state == 0 
		return
	endif
	
	if expand('%') == g:game_buff_name
		map <buffer> v <Nop>
		map <buffer> <C-v> <Nop>	
	endif

endfunction

" Check if the buffer cotent matches 
function! vr#CheckBufferContent()
	
	let lines = getline(1, '$')
        let cnt = len(l:lines)
        
	if cnt != 1
        
		echomsg 'Your text is not corret'
		return
        endif

        if l:lines[0] == g:game_content 
        
		echomsg 'You won'
	
		g:game_state = 0
		call SendSignalForGameOver()
		call CloseGameBuffer()		
        else 
        
		echomsg 'Your text is not corret'
        
	endif

endfunction

" Send signal for game over
function! s:SendSignalForGameOver()

	if g:type == 'server'
		call ch_sendraw(g:serverJob, a:input . "\n")
	else if g:type == 'client'
		call ch_sendraw(g:clientJob, a:input . "\n")
	endif

endfunction


