# Contra
> The Contra utility converts so called the "C Style Markup Language" to HTML/XML and back.
> The primary aim is to maximize both editability and readability by dynamizing the markup representation.

The Contra utility itself is meant to serve as a backbone other tools,
such as text editor or IDE extensions.

For a complete explanation see documentation/specification.md.

### Gallery

    // TODO

### Installantion
For any of the below plugins to work,
the Contra executable will have to be installed on your system.
##### Build from source
Contra is written in C,
it must be compiled.

Make sure you have the following dependencies:
 + a C compiler (e.g. gcc)
 + Make (e.g. GNU Make)
 + Flex

After navigating to the root directory, run:
```Bash
$ make
```
This will result in a new file called `contra`,
place it in your $PATH.
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
```
$ make vim_install
```
#### Visual Studio Code
The VS Code extension is written in TypeScript,
so it has to be compiled too.
This will require a million node modules.
You are advised to run:
```
$ make code_install
```
