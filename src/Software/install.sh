#!/bin/sh
#this is my install script v2

# This section is to compile all the sources then moves the executables into cli folder for # later
gcc -o cli/brew source/brew3.c
gcc -o cli/ecbrew source/clibrew.c
gcc -o cli/eccheck source/clicheck.c
cp cli/* /usr/bin
# This copies the GUI executable to the “~” directory of the current user (should be root,
# but sudo might place in in home)
cp GUI/EtherCoffee.gambas ~