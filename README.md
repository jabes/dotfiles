### Installation

```bash
cd ~
git clone git@github.com:jabes/dotfiles.git .dotfiles
git submodule update --init --recursive
ln -s $PWD/.dotfiles/.zshrc $HOME/.zshrc
ln -s $PWD/.dotfiles/submodules/timelapse-deflicker/timelapse-deflicker.pl $PWD/.dotfiles/bin/scripts/timelapse-deflicker.pl
mkdir -p $HOME/bin
```

#### OSX Specific

```bash
ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" $HOME/bin/subl
```
