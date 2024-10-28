# Contra 1 specification

## DESCRIPTION
The *Contra* utility converts the "C Style Markup Language" to HTML/XML and vice versa.
The primary aim is to maximize both editability and readability by dynamizing the markup representation.

## SYNOPSIS
**Contra** [ *OPTIONS* ] *FILES*+

## OPTIONS

`c`
: the input is to be force interpeted as CSML
```sh
#show an example of using -c
```

`x`
: the input is to be force interpeted as XML/HTML

`s` *\<string\>*
: colon separeted list of option sets

`S` *\<string\>*
: colon separeted list of special asymetric tags starters

`i` *\<string\>*
: colon separeted list of tags which contents should be ignored

`o` *\<file\>*
: specify output file name for the NEXT file

`q` *\<char\>*
: use \<char\> for quoting (default: \"'\")

`v`
: print version and quit

`h`
: print help and quit

## Translation
Contra translates both ways in a single step,
from top to bottom,
perserving formatting.

## Example

```html
<!-- DOCTYPE HTML -->
<html>
	<head>
	</head>
	<body>
		<hr/>
		<div class='myclass'>
			lorem ipsum
		</div>
	</body>
</html>
```

and

```C
// DOCTYPE HTML 
html {
	head {
	}
	body {
		hr;
		div (class: myclass) {
			lorem ipsum
		}
	}
}
```

are different sides of the same coin.
