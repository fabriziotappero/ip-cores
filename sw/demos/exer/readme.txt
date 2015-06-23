
8080EXER is an instruction exerciser that runs all the 8080 opcodes with a large
number of parameter combinations. The program computes a CRC value for the CPU
state after testing each block of CPU opcodes. that CRC value is then compared
against the CRC value produced by an original, silicon i8080.
If the CRC values match, it can safely be assumed that the core and the original
8080 behavior is identical.

The program was taken from this web:

http://www.idb.me.uk/sunhillow/8080.html

Here you can find a more detailed explaination.

I have made the following modifications to the original 8080EXEC:

- Added code that emulates a few CP/M BDOS functions needed to output text.
- Adapted the code to work on the C2SB demo board within the l80soc module.
- Added the original Intel CRC values for comparison.

The source code is in a format compatible to CP/M M80 assembler and incompatible
to TASM, AS80 and all other Windows and Linux 8080-compatible assemblers that
I know about. Therefore it can only be compiled from within CP/M. You can use
SIMH for that. I will not include instructions but you can find plenty in SIMH
web site.

File 'MAC.SUB' is a CP/M 'batch' file that you can use to assemble the source
with:
    DO MAC 8080EXER

I hope this saves you the trouble to find and read M80 documentation...

At any rate, i have included the compiled HEX file so all you have to do is
run the build.bat script. Or just use the pre-built obj_code_pkg.vhdl included.

Synthesis instructions:
=======================

Assuming you are using Quartus-2 and targetting a Terasic DE-1 dev board (for
which the demo is tailored), you need to follow these steps:

1.- Create a new project for the DE-1 board, (device EP2C20F484C7, etc.).
2.- Add the following vhdl files to the project:
        -# /vhdl/light8080.vhdl
        -# /vhdl/demos/c2sb/c2sb_soc.vhdl
        -# /vhdl/soc/*.vhdl
3.- Select file c2sb_soc.vhdl as 'top' entity.
4.- Configure dual-purpose pin nCEO as regular i/o (Device settings->Device and
    pin options->Dual-purpose pins)
5.- Import pin location constraints from file /vhdl/demos/c2sb/c2sb_pins.csv.

That's all. Synthesize and have a terminal (19200/8/N/1) connected to the UART
connector. Reset pin is button 1 (rightmost).


Execution instructions:
=======================

You need to run this with a terminal connected to the SoC UART (19200/8/N/1).
The tests will take quite a long time to run at 50MHz (about 11 minutes).
All you have to do is watch the messages.

In the present version of the core, all tests should succeed except for the
special opcode block (<daa,cma,stc,cmc>): one of those instructions is
incompatible to the original intel silicon.

Note that ALL instructions have been tested for compatibility to the
DOCUMENTATION. We're talking about replicating undocumented behavior here.

