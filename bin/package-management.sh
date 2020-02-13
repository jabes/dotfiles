#!/usr/bin/env bash

function update-packages {
  yay -Syu --noconfirm
}

function list-package-updates {
  yay -Pu
}

function remove-unused-packages {
  yay -Yc
}

function clear-package-cache {
  yay -Sc
}

function search-remote-package {
  yay -Ss $1
}

function search-local-package {
  yay -Q | grep $1
}
