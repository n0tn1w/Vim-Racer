command Server :call OutputC()
command GetCurrent echo g:keyCount

function! OutputC()
	let l:result = system('./dt' .. ' 10.86.11.222')
	echomsg l:result
endfunction

let g:keyCount = 0

function! IncrementKeyCount()
    let g:keyCount += 1
endfunction

autocmd CursorMoved,CursorMovedI * call IncrementKeyCount()

let g:buff_name = "fileGame.txt"
let g:content = "Gum"
command Buvv :call OpenBuff()
command CloseBuvv :call CloseBuff()
autocmd BufEnter * call DisableVisualMode()

function! OpenBuff() 
	execute 'new ' . g:buff_name	
	call append(0, g:content)
	setlocal nomodifiable
	wincmd p
command Server :call OutputC()
command GetCurrent echo g:keyCount

function! OutputC()
        let l:result = system('./dt' .. ' 10.86.11.222')
        echomsg l:result
endfunction

let g:keyCount = 0

function! IncrementKeyCount()
    let g:keyCount += 1
endfunction

endfunction

function! CloseBuff()
	"Check if there is a open file
	execute 'bd! ' . g:buff_name
endfunction

function! DisableVisualMode()
  if expand('%') == g:buff_name
    map <buffer> v <Nop>
  endif
endfunction

"===========
command StartServer :call StartServer()
	let g:serverCommand = './serverNew'
	let g:serverJob = {}
	let g:serverJobStarted = 0


function! StartServer()
		let g:serverJob = job_start(['./serverNew'], {
		    \ 'out_cb': 'CServerOut',
		    \ })
endfunction

function! SendInputToServer(input)
   call ch_sendraw(g:serverJob, a:input . "\n")
endfunction

function! CServerOut(job_id, data)

    call writefile(data, "file.txt")
        echo a:data
endfunction

function! CloseServerJob()
    if g:serverJobStarted
        call job_stop(g:serverJob)
        let g:serverJobStarted = 0
    endif
endfunction

function! OnClose(job_id, exit_code)
    echo 'Server exited with code: ' . a:exit_code
endfunction


function! HandleJobOutput(job_id, data)
  " Process the output here
    call writefile(data, "file.txt")
  echo a:data
endfunction

function! RunJobAndCaptureOutput()
  " Start the job
  let job_id = job_start(['ls'], {
        \ "callback": 'HandleJobOutput',
        \ })
endfunction

command StartClient  :call StartClient()
	let g:clientCommand = './client'
	let g:clientJob = {}
	let g:clientJobStarted = 0


function! StartClient()
	if !g:clientJobStarted
		let g:clientJob = job_start([g:clientCommand], {
		    \ 'out_cb': {clientJob, line -> ClientOut(line) },
		    \ })
		let g:clientJobStarted = 1
        endif 
endfunction

function! SendInputClient(input)
   call ch_sendraw(g:clientJob, a:input . "\n")
endfunction

function! Test()
  " Start the job
  let job_id = job_start(['./test'], {
        \ "out_cb": 'HandleJobOutput',
        \ })
endfunction


