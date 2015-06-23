Z80 Computer on DE1 Development board

Arquitecture
------------

SW9 	- Reserved - Reset
SW8 	- Reserved
LEDR9 	- Reserved
LEDR8 	- Reserved

Memory
------
0000H - 3FFFH - ROM		(0 	- 16383)
4000H - 5FFFH - VIDEO RAM	(16384 	- 24575)
8000H - FFFFH - RAM memory      (32768 	- 65535)

Registers
---------
7FDDH         - Z80SOC VERSION  (0 = DE1, 1 = S3E)
7FDEH - 7FDFH - STACK ADDRESS   (should be loaded with "ld sp,(7FDEh)" in the beginning of program

IO (Ports)
----------

01H	- Out 	- Green Leds (7-0)
02H	- Out 	- Red Leds (7-0)

10H	- Out 	- HEX1 - HEX0
11H	- Out 	- HEX3 - HEX2
20H	- In	- SW(7-0)
30H	- In	- KEY(3-0)
80H	- In	- PS/2 keyboard
90H	- Out	- Video
91H	- InOut	- Video cursor X
92H	- InOut	- Video cursor Y

GPIO Expansion pins
-------------------
All write operations to GPIO are buffered.
To write the buffered signals to the pins, the Z80 must
write any value to port C0 (GPIO0) or C1 (GPIO1)

A0	- GPIO0 (7-0)
A1	- GPIO0 (15-8)
A2	- GPIO0 (23-16)
A3	- GPIO0 (31-24)
A4	- GPIO0 (35-32)

B0	- GPIO1 (7-0)
B1	- GPIO1 (15-8)
B2	- GPIO1 (23-16)
B3	- GPIO1 (31-24)
B4	- GPIO1 (35-32)

C0	- GPIO0 Write
C1	- GPIO1 Write


--

Reference Sample ROM

It is provided a ROM with a reference application, and the correspnding
Z80 source codes.

To use the application you will need to connect the DE1 board to a
VGA monitor and PS/2 keyboard.

The program will show how to use:
	Input push buttons
	Input Switches
	PS/2 keyboard
	Video text out (memory mapped and port mapped io)
	Leds
	7seg display

The program starts waiting for keys to be typed in the keyboard.
The characters are shown on the 40x30 video (VGA).
If "A" is pressed, then the program starts another routine,
that will write bytes into SRAM. After 255 bytes are written,
the bytes are read sequencially.
The address read are displayed in the seven seg display, and
the byte read displayed in the leds (binary format).
When finished, waits for KEY0 (DE1 board) and then restart again.

The switches (7-0) are used as input to calculate delays. Try
changing these switches to speed up ou slow down the leds. It only
takes effect after a Z80 reset. 
To reset the Z80, use SW9.

The looping text inside the box demonstrates how to access the video ram.
To change speed of scrolling, use the switches (SW).

Hope you enjoy.

TO-DO:
----

- 80x40 Video display
- Serial communication
- Monitor program to allow download of programs by serial communication
- Mass storage device (SD/MMC)
- Video colors
