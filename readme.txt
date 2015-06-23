This is the VTACH simulator of the CARDIAC computer.

You can read more at:
http://www.drdobbs.com/embedded-systems/cardiac-to-fpga/240155599
http://www.drdobbs.com/embedded-systems/paper-to-fpga/240155922
http://www.drdobbs.com/embedded-systems/expanding-vtach/240155198
http://www.drdobbs.com/embedded-systems/troubleshooting-verilog/240154701
http://www.drdobbs.com/embedded-systems/the-cpu-crawl/240154406?
http://www.drdobbs.com/embedded-systems/the-heart-of-a-cpu/240153772

More info on CARDIAC
http://en.wikipedia.org/wiki/CARDboard_Illustrative_Aid_to_Computation

You can find a simple cross assembler in the asm directory. 

To assemble code in test asm:

axasm -p cardiac -x -o test.coe test.asm

Then set the block ram to initialize from test.coe (in the 
block memory wizard) and rebuild.

Expanded opcodes:
480 - Read toggle switches to accumulator
490, 408, 409 - Read pushbutton to accumulator (-1 for pressed, 1 for not pressed)

Changed opcodes:
INP - Read toggle switches (up to you to obey BCD and yes you can't enter >99)
OUT - Output to the LED display

Author - Al Williams al.williams@awce.com

If you use this in an educational setting, I'd enjoy hearing about it.
Actually, if you use this at all, I'd probably enjoy hearing about it :-)


