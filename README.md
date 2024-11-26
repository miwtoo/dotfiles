#+TITLE: dotfiles

I manage the various configuration files in this repo using [[https://www.gnu.org/software/stow/][GNU Stow]].  This allows me to set up symlinks for all of my dotfiles using a single command:

#+begin_src sh
stow .
#+end_src

* Inspiration

The inspiration for this configuration comes from the [[https://github.com/elliottminns/dotfiles][dotfiles by elliottminns]].