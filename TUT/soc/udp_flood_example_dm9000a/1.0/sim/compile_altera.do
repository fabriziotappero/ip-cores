# Script compiles all vhdl-files and generates a makefile for them
# This script is tested for Modelsim version 6.6a 

.main clear

echo " Generating libraries for files"
vlib altera_mf

echo "Processing Altera's sim modles needed by pll"
vcom -reportprogress 300 -work altera_mf -check_synthesis  C:/altera/11.0/quartus/eda/sim_lib/altera_mf_components.vhd
vcom -reportprogress 300 -work altera_mf -check_synthesis  C:/altera/11.0/quartus/eda/sim_lib/altera_mf.vhd

echo " Script has been executed "
