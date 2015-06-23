
Xilinx Flash/PROM - Write bitfile to SPI serial flash
The included file boot-loader-ethmac.mcs is a flash configuration file
for the SPI (serial) flash on the SP605 FPGA development board.
It contains the boot-loader-ethmac design. Here are instructions on how to create an mcs file
and how to load it onto the SP605 board. These instructions are for Xilinx ISE 14.5.


1. Start impact. Select Prepare a PROM file
Step 1. Select Storage Target
SPI Flash -> Configure single FPGA

Step 2. Add Storage Device
64M

Step 3
File Format MCS
Add Non_Configuration Files No

Select the bitfile to write
Would you like to add another device file to Revision:0 ? No

Impact Process->Generate File...
Impact creates an MCS file and says Generate Succeeded.

Then restart impact and select Boundary Scan flow
Right mouse on the FPGA and select Add SPI/BPI Flash

Select Attached SPI/BPI dialogue
SPI PROM -> W25Q64FV
Data Width: 1

Then a Flash device appears in the Boundary scan window attached the tje xc6slx45t FPGA.
Right mouse on the Flash and select Program
This takes a couple of minutes.

To use that image, you need the following switch settings on the SP605 board;
SW1 (the 2-switch block box near the red on/off power switch in the upper right corner of the board)
 M0=on, M1=off
Then press the PROG button just below it to load that bitfile from the SPI flash into the FPGA.

To use the Parallel flash
 M0=off, M1=off


Online tutorial for instructions with pictures -
http://www.digilentinc.com/Data/Documents/Tutorials/MCS%20File%20Creation%20with%20Xilinx%20ISE%20Tutorial.pdf