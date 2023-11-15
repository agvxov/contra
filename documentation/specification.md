# Contra specification
> The Contra utility converts so called the "C Style Markup Language" to HTML/XML and back.
> The primary aim is to maximize both editability and readability by dynamizing the markup representation.

## C Style Markup Language
The C Style Markup Language -CSML for short- is a markup language
that can be 1 to 1 translated into traditional markup languages such as XML or HTML.
It's syntax -as the name suggests- is engineered to be similar to
the syntax of the C programming language
(and thereby it is also similar to derived languages such as Javascript).
It also happens to closely resemble Groovy's advanced templating language.

The rational behind it's creation is the realizations that:
 1. languages which have giant blocks (say thousands of lines) tend to be more readable if the block closing token explicitly states the block type being closed.
```ADA
procedure exaple is
begin
    ;
end
```
 2. languges with implicit block closing contain less redundant text and as a result, are easier to edit
```C
void exaple() {
    ;
}
```

So,
CSML is indended to be a temporary representation of other markup languages
for the duration of their directed editing.
In practice,
the developer would open a -say HTML- file,
find the relevant section to modify,
convert the document to CSML,
perform the update,
then convert it back
-without loosing any data in the process of course.
Or alternatively one could rapidly type out a webpage in CSML
and seemlessly translate it in the end.

### Syntax

#### Tags
```
    <tag> [(<head>)] {<body>}
```
```
    <tag>;
```
Example:
```
    textarea (readonly) { lorem ipsum }
```
```
    br;
```

The last __identifier__,
defined by this regular expression: `[A-z][A-z0-9]*`,
before a (optional) _head_, _body_ or semi-colon
is considered to be a __tag__.
CSML by itself does not enforce any (sub)set of words to be "valid"
(however, related tools might).
Each _tag_ is pushed into a stack and later popped by the end of a body being found.

If the _tag_ is followed by a semi-colon (';'),
it's a self-closing tag.

The __head__ holds _attributes_.
A missing _head_ signals that there are no attributes to be translated.
Any text may be a valid __attribute__.
_Attributes_ can be given _values_ by placing a colon (':') after them.

The __value__ is parsed until the first non-escaped comma (',')
or until the end of the _head_ (closing ')').

The __body__ is everything enclosed by curly braces ("{}").
It may contain more _tags_ or _comments_.

#### Escaping
Any special character may be escaped by prepending it with a backslash ('\').
This will prevent it from being parsed as a significant token to the syntax.
List of escaped special characters:
    + \(
    + \)
    + \{
    + \}
    + \,
    + \:
    + \;
    + \<
    + \>
Note, that they are not requred to be always escaped,
but are highly advised.

#### Comments
CSML supports C99 comments,
both single and multi line.
That is:
```C
//single line

/*multi-
line*/
```

#### Echoing
Anything not holding special meaning (tags, heads, comments) is considered regular text,
which is significant.
This includes whitespace too.


## Translation
Contra translates both ways in a single step,
from top to bottom,
perserving formatting.

Example:
```
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
```
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


See the man pages for further documentation.
