
The source files in the ./vhdl directory are common to all the demos that run on
the DE-1 board from Terasic, and use the vhdl SoC.

A Quartus-II project file is included in directory ./syn. The demo project uses
the Dhrystone object code package to initialize the code ROM, so once you
connect a 19200-8-N-1 terminal to the DE-1 serial port you'll see the
execution output of the Dhrystone program, which takes about 16 seconds.

An assignment file with all the pin definitions for the DE-1 board is included
(cs2b_pins.csv) than can be imported from Altera's Quartus-II if the included
project file is not used.

Note: The 'c2sb' prefix in the names stands for cyclone-2 Starter Board.

Note: switch SW9 (leftmost) is used as reset; set to 'on' to start the demo.
