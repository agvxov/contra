syn match	contraTag "[:ident:]+\s*;"
syn region	contraTagWithBody		matchgroup=contraTag 		start="[:ident:]+\s*{" end="[^\\]}" transparent fold

syn match	contraComment "//.*$"
syn region	contraMultilineComment	matchgroup=contraComment	start="/\*"	end="\*/"

syn match	contraEscape "\\."

" ---

hi link contraComment			Comment
hi link contraMultilineComment	Comment
hi link contraEscape			Special
