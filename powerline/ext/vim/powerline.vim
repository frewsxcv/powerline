if ! has('python')
	echohl ErrorMsg
	echomsg 'You need vim compiled with Python 2 support for Powerline to work. Please consult the documentation for more details.'
	echohl None
	finish
endif

python import sys, vim, os
python sys.path.append(vim.eval('expand("<sfile>:h:h:h:h")'))
python import uuid
python from powerline.core import Powerline
python pl = Powerline('vim')

if exists('*pyeval')
	let s:pyeval = function('pyeval')
else
	python import json
	function! s:pyeval(e)
		python vim.command('return ' + json.dumps(eval(vim.eval('a:e'))))
	endfunction
endif

function! Powerline(winnr, current)
	return s:pyeval('pl.renderer.render('. a:winnr .', '. a:current .')')
endfunction

function! s:UpdateWindows()
	if ! exists('w:window_id')
		let w:window_id = s:pyeval('str(uuid.uuid4())')
	endif
	for winnr in range(1, winnr('$'))
		call setwinvar(winnr, '&statusline', '%!Powerline('. winnr .', '. (w:window_id == getwinvar(winnr, 'window_id')) .')')
	endfor
	redrawstatus
endfunction

augroup Powerline
	autocmd!
	autocmd BufEnter,BufWinEnter,WinEnter * call s:UpdateWindows()
augroup END
