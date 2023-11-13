function! CWheel()
	set paste
	let saved_cursor = getpos(".")

	let command = '../cwheel ' . shellescape(expand('%'))
	let output = system(command)
	normal! ggVGd
	execute "normal! i" . output

	call setpos('.', saved_cursor)
	set nopaste
	redraw!
endfunction

command! -nargs=0 CWheel call CWheel()

noremap <F10> :CWheel<CR>

