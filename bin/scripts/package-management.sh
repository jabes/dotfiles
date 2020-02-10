#!/usr/bin/env bash

function update-packages {
  yay -Syu
}

function list-package-updates {
  yay -Pu
}

function remove-unused-packages {
  # sudo pacman -Rsn $(pacman -Qdtq)
  yay -Yc
}

function clear-package-cache {
  # sudo paccache -rk0
  yay -Sc
}
