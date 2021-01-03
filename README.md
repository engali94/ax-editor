

# AX Editor

  

A light weigt text editor with syntax highlighting. It is written completly in Swift using ANSI Escape Sequnces. **It is still not complete and buggy (work in progress) contributions are warmly welcomed 🙌**

  ![enter image description here](https://github.com/engali94/ax-editor/blob/master/assets/demo.png)
  

# Installation

- Clone and `cd` into the repository

- Run `swift package generate-xcodeproj`

- Run the following command to try it out:

  

```bash

swift run XMLJson --help

```

# Usage

<!-- USAGE EXAMPLES -->

  

#### Opening files in Ax

  

At the moment, you can open ax editor by using the command

```sh

swift run ax

```

  

This will open up an empty document.

  

If you wish to open a file straight from the command line, you can run

```sh

swift run ax /path/to/file

```

To open and edit a file.

  
  

#### Moving the cursor around

  

You can use the arrow keys to move the cursor around

  

You can also use:

- <kbd>PageUp</kbd> - Go to the top of the document

- <kbd>PageDown</kbd> - Go to the bottom of the document

- <kbd>Home</kbd> - Go to the start of the current line

- <kbd>End</kbd> - Go to the end of the current line

  

#### Editing the file

  

You can use the keys <kbd>Backspace</kbd> and <kbd>Return</kbd> / <kbd>Enter</kbd> as well as all the characters on your keyboard to edit files!

  
  

OAx is controlled via your keyboard shortcuts. Here are the default shortcuts that you can use:

  

| Keybinding | What it does |

| Keybinding  | What it does  |
| ------------ | ------------ |
| `Ctrl + D` | Exits the the editor. |
| `Ctrl + S` | Saves the open file to the disk **(To be Implemented)**. |
| `Ctrl + F` | Searches the document for a search query. Allows pressing of <kbd>↑</kbd> and <kbd>←</kbd> to move the cursor to the previous occurance fof the query and <kbd>↓</kbd> and <kbd>→</kbd> to move to the next occurance of the query. Press <kbd>Return</kbd> to cancel the search at the current cursor position or <kbd>Esc</kbd> to cancel the search and return to the initial location of the cursor. Note: this allows you to use regular expressions. **(To be Implemented)**. |
| `Ctrl + U` | Undoes your last action. The changes are committed to the undo stack every time you press the space bar, create / destroy a new line and when there is no activity after a certain period of time which can be used to capture points where you pause for thought or grab a coffee etc... |
| `Ctrl + R` | Redoes your last action. The changes are committed to the undo stack every time you press the space bar, create / destroy a new line and when there is no activity after a certain period of time which can be used to capture points where you pause for thought or grab a coffee etc... |
| `Ctrl + F` | Allows replacing of occurances in the document. Uses the same keybindings as the search feature: <kbd>↑</kbd> and <kbd>←</kbd> to move the cursor to the previous occurance fof the query and <kbd>↓</kbd> and <kbd>→</kbd> to move to the next occurance of the query. You can also press <kbd>Return</kbd>, <kbd>y</kbd> or <kbd>Space</kbd> to carry out the replace action. To exit replace mode once you're finished, you can press <kbd>Esc</kbd> to cancel and return back to your initial cursor position. Note: this allows you to use regular expressions.**(To be Implemented)**.|
| `Ctrl + A` | Carries out a batch replace option. It will prompt you for a target to replace and what you want to replace it with and will then replace every occurance in the document. Note: this allows you to use regular expressions. **(To be Implemented)**.|

  

# TODO

-  [X] Basic editing functions

-  [X] Line numbers

-  [X] Undo and Redo

-  [X] Syntax highlighting

-  [X] Loading files

- [ ] Saving files

- [ ] Searching and replacing

- [ ] Command line bar

- [ ] Status bar

- [ ] Config files

- [ ] Tabs for multitasking

- [ ] Auto indentation

- [ ] Prettifier / Automatic code formatter

- [ ] Built In linters

- [ ] Auto brackets

- [ ] Auto complete

- [ ] File tree

- [ ] Start page

# Contributing

Contributions are warmly welcomed 🙌

  

# Credits
Thanks to all the authors and contributers of the following tools:
[ColorizeSwift](https://github.com/mtynior/ColorizeSwift)
[CrossTerm](https://github.com/crossterm-rs/crossterm) 
[Ox Editor](https://github.com/curlpipe/ox) 

# Licence

It is released under the MIT license, see [Licence]()
