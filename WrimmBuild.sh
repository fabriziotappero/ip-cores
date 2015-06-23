#!/bin/sh

# Propery of Tecphos Inc.  See WrimmLicense.txt for license details
# Latest version of all Wrimm project files available at http://opencores.org/project,wrimm
# See WrimmManual.pdf for the Wishbone Datasheet and implementation details.
# See wrimm subversion project for version history

#GHDL simulation script and gtkWave view results

ghdl -i -v --workdir=work *.vhd

ghdl -m --workdir=work WrimmTestBench

ghdl -r WrimmTestBench --wave=wrimm.ghw --assert-level=error --stop-time=1000ns

# gtkwave wrimm.ghw
