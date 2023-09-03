" Start as client
function! vimracer#Join()

	if g:game_state == 1
		return
	endif

	g:type = 'client'
	g:game_state = 1;

	let command = "../communication/client"
	g:clientJobId =  job_start(l:command, { 'out_cb': function('HandleCommunicationClient'), 'err_cb': function('HandleCommunication')})

	call SendMessage('open:')

endfunction

" Start as server
function! vimracer#Start()

	if g:game_state == 1
		return
	endif

	g:type = 'server'
	g:game_state = 1;

	let command = "../communication/server"
	g:serverJobId =  job_start(l:command, { 'out_cb': function('HandleCommunicationServer'), 'err_cb': function('HandleCommunication')})

endfunction

" Have the task to process the data that received from the server
function! s:HandleCommunicationServer(job, line)

	if g:game_state == 0 
		return
	endif

	if CheckForStartMessage(l:line)	

		call GetRandomLine()
		g:game_content = call ExtractStartingMessageFromFile(g:game_data)
		g:game_solution = call ExtractStartingMessageFromFile(g:game_solution)

		call SendMessage(g:game_content)
		call SendMessage(g:game_solution)

		call OpenGameBuffer()	
	endif
	
	if CheckForEndMessage(l:line)	

		g:game_state = 0
		echomsg 'You lost'

		call CloseGameBuffer()	
	endif

endfunction

" Have the task to process the data that received from the client
function! s:HandleCommunicationClient(job, line)
	"TO DO
endfunction

" Get random line from file 
function! s:GetRandomGameLine() 

	let num_lines = len(g:game_line)
	g:line = rand(num_lines);

endfuncti

" Get a line from file 
function! s:ExtractStartingMessageFromFile(file)

	let lines = readfile(a:file)
	let line = lines[g:game_line]
	
	return line

endfunction

" Send message
" Currently doesnt flush until the job is close
function! s:SendMessage(message)

	if g:type == 'server'

		call ch_sendraw(g:serverJob, a:message . "\n")
	else if g:type == 'client'

		call ch_sendraw(g:clientJob, a:message . "\n")
	endif

endfunction

" Open g:game_buff
function! s:OpenGameBuffer()

	execute 'new ' . g:game_buff_name
	call append(0, g:game_content)
        
	setlocal nomodifiable
        wincmd p

endfunction

" Closes g:game_buff 
function! s:CloseGameBuffer()
	
	execute 'bd! ' . g:game_buff_name

endfunction

" Check if the message is start message 
function! s:CheckForStartMessage(line)

    	return strpart(a:line, 0, 5) == "open:"

endfunction

" Check if the message is end message 
function! s:CheckForEndMessage(line)

    	return strpart(a:line, 0, 5) == "close"

endfunction

" Check if the buffer content matches to the final answer 
" CFC command
function! vimracer#CheckBufferContent()
	
	let lines = getline(1, '$')
        let cnt = len(l:lines)
        
	if cnt != 1
        
		echomsg 'Your text is not corret'
		return
        endif

        if l:lines[0] == g:game_solution 
        
		echomsg 'You won'
	
		g:game_state = 0
		call SendMessage('close')
		call CloseGameBuffer()		
        else 
        
		echomsg 'Your text is not corret'        
	endif

endfunction

" Disables visual and visual block mode so that the player cannot copy paste
function! vimracer#DisableVisualAndVBlockMode()

	if g:game_state == 0 

		return
	endif
	
	if expand('%') == g:game_buff_name

		map <buffer> v <Nop>
		map <buffer> <C-v> <Nop>	
	endif

endfunction
