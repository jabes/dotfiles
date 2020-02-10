### Installation

```bash
cd ~
git clone git@github.com:jabes/dotfiles.git .dotfiles
git submodule update --init --recursive
ln -s $PWD/.dotfiles/.zshrc $HOME/.zshrc
mkdir -p $HOME/bin
```

#### OSX (optional)

Create a symbolic link to use the `subl` command in your terminal to open files.

```bash
ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" $HOME/bin/subl
```

Note: *You must have [sublime text](https://www.sublimetext.com/) installed for this to be relevant.*
