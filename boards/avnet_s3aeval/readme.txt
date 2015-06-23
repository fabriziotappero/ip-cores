
Support files common to all the demos that run on the Spartan-3A Evaluation Kit 
from Avnet, and use the vhdl SoC.

An ISE WebPack 14 project file is included in the /syn/light52_s3aeval 
directory. This project uses the object code from the 'Blinker' demo to 
initialize the XCODE ROM.
Upon reset, you should see LEDs D2..D5 counting seconds.

A constraints file with all the pin definitions for the board is included
(Avnet_Sp3A_Eval.ucf) that can be used from Xilinx' ISE WebPack, in case the
supplied project file is not used.
