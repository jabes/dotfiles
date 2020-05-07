### Introduction

This is a cross platform (osx/linux) environment setup for developers.

It will install and configure the following:
- [Git](https://git-scm.com/)
- [Brew](https://brew.sh/)
- [Sublime](https://www.sublimetext.com/)
- [oh-my-zsh](https://ohmyz.sh/)
- [awesome-vim](https://github.com/amix/vimrc)
- [diff-so-fancy](https://github.com/so-fancy/diff-so-fancy)

It will also install several scripts that can be used on a command line:
- `batch-photo-rename`
- `batch-photo-resize`
- `github-backup`
- `make-timelapse-video`
- `search-file-contents`

It will also install a script that will ask to upgrade system packages once a day when you start a new shell.

### Installation

#### via curl

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/jabes/dotfiles/master/install.sh)"
```

#### via wget

```bash
bash -c "$(wget -O- https://raw.githubusercontent.com/jabes/dotfiles/master/install.sh)"
```
