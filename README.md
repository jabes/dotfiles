### Installation

```bash
cd $HOME
git clone git@github.com:jabes/dotfiles.git .dotfiles
git submodule update --init --recursive
ln -s $PWD/.dotfiles/.zshrc $HOME/.zshrc
ln -s $PWD/.dotfiles/submodules/timelapse-deflicker/timelapse-deflicker.pl $PWD/.dotfiles/bin/scripts/timelapse-deflicker.pl
mkdir -p $HOME/bin
```

#### Sublime Text (OS X Command Line)

Sublime Text includes a command line tool, subl, to work with files on the command line.
This can be used to open files and projects in Sublime Text, as well working as an EDITOR for unix tools, such as git and subversion.

[https://www.sublimetext.com/docs/3/osx_command_line.html](https://www.sublimetext.com/docs/3/osx_command_line.html)

The first task is to make a symlink to subl.
Assuming you've placed Sublime Text in the Applications folder, and that you have a `~/bin` directory in your path, you can run:

```bash
ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" ~/bin/subl
```
