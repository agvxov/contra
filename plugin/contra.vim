function! Contra()
	let saved_cursor = getpos(".")

	let current_file = expand('%')
	
	let basename = expand('%:t:r')
	if current_file =~ '\.csml$'
		execute 'set wildignore+=' . current_file
		let candidates = glob( basename . '.*', 0, 1)
		if !empty(candidates)
			let output_file = candidates[0]
		else
			let output_file = basename . '.html'
			let input = input("Press Enter or override the output name '" . output_file . "': ")
			if !empty(input)
				output_file = input
			endif
		endif

		let force_flag = ' -c '
	else
		let output_file = basename . '.csml'
		let force_flag = ' -x '
	endif

	let command = 'contra -s ' . shellescape('html') . ' ' . force_flag . ' -o ' . shellescape(output_file) . ' ' . shellescape(current_file)
	echo command
	let output =  system(command, v:true)

	if v:shell_error
		echo v:shell_error
		return
	endif

	execute 'edit ' . output_file

	call setpos('.', saved_cursor)
	redraw!
endfunction

command! -nargs=0 Contra call Contra()

noremap <F10> :Contra<CR>

