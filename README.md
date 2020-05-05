### Installation

```bash
cd $HOME
git clone git@github.com:jabes/dotfiles.git .dotfiles
git -C .dotfiles submodule update --init --recursive
ln -s $PWD/.dotfiles/.npmrc $HOME/.npmrc
ln -s $PWD/.dotfiles/.zshrc $HOME/.zshrc
ln -s $PWD/.dotfiles/submodules/timelapse-deflicker/timelapse-deflicker.pl $PWD/.dotfiles/bin/scripts/timelapse-deflicker.pl
mkdir -p $HOME/bin/scripts
```

#### Sublime Text (OS X Command Line)

Sublime Text includes a command line tool, subl, to work with files on the command line.
This can be used to open files and projects in Sublime Text, as well working as an EDITOR for unix tools, such as git and subversion.

[https://www.sublimetext.com/docs/3/osx_command_line.html](https://www.sublimetext.com/docs/3/osx_command_line.html)

The first task is to make a symlink to sublime.
Assuming you've placed Sublime Text in the Applications folder, and that you have a `~/bin` directory in your path, you can run:

```bash
ln --symbolic "$(find /Applications -type f -name subl)" $HOME/bin/subl
```

Also some Linux distributions may require a symlink as illustrated below.

```bash
ln --symbolic /usr/bin/subl3 $HOME/bin/subl
```

#### Custom Paths Example

Any bash file created in the `~/bin/scripts` folder will be sourced into the shell environment.

```bash
touch $HOME/bin/scripts/custom-paths.sh
chmod +x $HOME/bin/scripts/custom-paths.sh
cat <<EOT >> $HOME/bin/scripts/custom-paths.sh
CUSTOM_PATHS=(
    \$HOME/.composer/vendor/bin
    \$HOME/.google-cloud-sdk/bin
    \$HOME/.npm-packages/bin
)
CUSTOM_PATH=\$(IFS=:; echo "\${CUSTOM_PATHS[*]}")
export PATH="\$CUSTOM_PATH:\$PATH"
EOT
```
