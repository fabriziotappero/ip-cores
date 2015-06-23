To create a disk image:

1. Convert a 275-byte sector VGI image to 512-byte sectors:
   vg2flash vgboot.vgi vgboot.bin

2. Convert .bin file to Intel Hex (I used Needham's EMP Device Programming
   Software.)

3. Convert to MCS file, use 'packihx':
   packihx vgboot.hex > vgboot.mcs

4. Add MCS header to first line of the file, use the first line of vgboot.mcs
   as an example.

4. Program vgboot.mcs to FLASH using the s3esk_picoblaze_nor_flash_programmer
   from Xilinx.  This will take long time (~1 hour) and will end with
   address 199FF0.

NOTE: If you run into a problem where the Hyperterminal hangs during
the 'P' command, power-cycle your S3E board, re-load the flash
programmer, and try again.

Other disk images may be obtained from:

wwws.vector-archive.org

The SIMH/AltairZ80 Simulator can emulate a Vector Graphic system.  The
simulator and some sample disk images can be downloaded from:

http://www.schorn.ch/cpm/intro.php

The simulator can be used to create new disk images and copy files to
and from disk images.

