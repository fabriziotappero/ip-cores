Z80 Computer on Spartan 3E Starter Kit

Arquitecture
------------

ROT_CENTER push button (Knob) - Reserved - Reset

Memory
------
0000H - 3FFFH - ROM
4000H - 4C7FH - VIDEO RAM
4C80H - 547FH - Characters definition RAM
5480h - 5FFFH - Not Used
6000H - BFFFH - RAM memory
FFE0H - FFFFH - LCD Video RAM

Registers
---------
FFDFH         - Z80SOC VERSION  (0 = DE1, 1 = S3E)

IO (Ports)
----------

01H	- Out 	- Green Leds (7-0)
20H	- In	- SW(3-0)
30H	- In	- KEY(3-0)
70H	- In	- Rotary control direction 
80H	- In	- PS/2 Keyboard
90H	- Out 	- Video
91H	- Out 	- Video cursor X
92H	- Out 	- Video cursor Y

--

Reference Sample ROM

It is provided a ROM with a reference application, and the corresponding
Z80 source codes.

To use the application you will need to connect the S3E board to a
VGA monitor and PS/2 keyboard.

The program will show how to use:
	Input push buttons
	Input Switches
	PS/2 keyboard
	Video text out (memory mapped and port mapped)
	Leds
	LCD
	Rotary Knob
	Redefinition of characters

The program starts waiting for keys to be typed in the keyboard.
The characters are shown on the 40x30 video (VGA).
If "A" is pressed, then the program starts another routine,
that will write bytes into RAM. After 255 bytes are written,
the bytes are read sequencially and the byte read displayed in the leds (binary format).
When finished, waits for KEY0 (East on S3E board) and then restart again.

The switches (4-0) are used as input to calculate delays. Try
changing these switches to speed up ou slow down the leds and the LCD text rotation speed.
When you change these switches, it will only take effect after a Z80 reset (press the Knob button).

The Rotary knob can be used at any time to rotate the text in the LCD to the left or to the right.

The looping text inside the box demonstrates how to access the video ram.
To change speed of scrolling, use the switches (SW).

To reset the Z80, press the Knob Button (rotary).

To modify the screen layout (rows x columns), edit the file z80soc_pack.vhd and find the constants:
- vid_cols  = number of columns (maximum is 80)
- vid_lines = number of lines (maximum is 40)
- pixelsxchar = 1 every character will be plotted using 8x8 pixels
- pixelsxchar = 2 every character will be plotter using 16x16 pixels

The column x lines total must not be over 3200, because this is the capacity defined for the video ram.
The characters can be redefined. Every character must have 8 bytes (8 x 8 bits). 

Hope you enjoy.

TO-DO:
----

- (done) 80x40 Video display
- Serial communication
- Monitor program to allow download of programs by serial communication
- Mass storage device (SD/MMC)
- Video colors