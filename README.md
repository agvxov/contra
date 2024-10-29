# Contra
> The Contra utility converts the so called [C Style Markup Language](documentation/csml.5.md) to HTML/XML and back.

### Rationale
Contra removes visual clutter from HTML/XML
and makes editing the markup easier,
especially for people with a background in C style languages
(including Javascript).

The preference for this kind of syntax can be observed else where too.
QML and the Groovy XmlTemplateEngine markup syntaxes are similar and
served as inspiration for Contra.
However,
they require altering your tech stack.
Contra can be used seamlessly with your web projects,
since it can dynamically convert within your editor.

### Example

![demo](documentation/media/demo.GIF)

If someone is used to writing \*script,
this should be more comfortable to type out:

```C
p {
    foo br;
    bar br;
}
```

And press `Alt + Shift + C` (in VScode),
then to type out this with:

```HTML
<p>
    foo <br/>
    bar <br/>
</p>
```

Yet, the two are equivalent using Contra.

### Notes
The Contra utility itself is meant to serve as a backbone for other tools,
such as text editor or IDE extensions.

More documentation is available at `documentation/*`.

### Installantion
For any of the below plugins to work,
the Contra executable will have to be installed on your system.

##### Build from source
Contra is written in C++,
it must be compiled.

Make sure you have the following compile time dependencies:
 + a C++ compiler (e.g. g++)
 + Make (e.g. GNU Make)
 + Flex

After navigating to the root directory, run:
```Bash
$ make
```
This will result in a new executable file called `contra`,
place it in your `$PATH`.
The easiest way to do so is by running:
```Bash
$ make install
```

#### Vim
Place the file "plugin/contra.vim" inside "~/.vim/plugin/".
You might have to create the directory yourself.
Or,
assuming your setup actually matches with the above,
you could run:
```Bash
$ make vim_install
```

#### Visual Studio Code
The VS Code extension is written in TypeScript,
so it has to be compiled too.
This will require a million node modules.
You are advised to run:
```Bash
$ make code_install
```
