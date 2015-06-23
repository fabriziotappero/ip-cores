########################################################
#### This file is part of the yaVGA project         ####
#### http://www.opencores.org/?do=project&who=yavga ####
########################################################

FIles:

charmaps_ROM.vhd
  This file is the char map rom initialization. If you like you can modify it using
  ../charmaps/convert.sh (it read chars.map and write on the standard output a BRAM 
  vhdl initialization chunk to be completed...)

chars_RAM.vhd
  This file is the char ram

README.txt
  This file

s3e_starter_1600k.ucf
  The ucf constraint to be used with the DIGILENT s3e_starter_1600k kit

s3e_starter_1600k.vhd
  The top vhdl to use to test the vga controller with the DIGILENT s3e_starter_1600k kit.
  The test write random chars to the screen each few seconds (currently the random write
   is replaced by some ?debug? char write and by some config params write...).

vga_ctrl.vhd
  The vga controller main file

waveform_RAM.vhd
  This file is the waveform ram

yavga_pkg.vhd
  yavga package
