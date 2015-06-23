
Altair Basic is an early implementation of Basic (1975) for the 8080-based
Altair computer. I have included in the project a demo running the unmodified
binaries on the light8080 core. See instructions and status log below.

Assuming you are using Quartus-2 and targetting a Terasic DE-1 dev board (for
which the demo is tailored), you need to follow these steps:

1.- Create a new project for the DE-1 board, (device EP2C20F484C7, etc.).
2.- Add all the vhdl files in /vhdl/demos/4kbasic, plus the main cpu file
        light8080.vhdl, to your project.
3.- Select file c2sb_4kbasic_cpu.vhdl as 'top' entity.
4.- Configure dual-purpose pin nCEO as regular i/o (Device settings->Device and
    pin options->Dual-purpose pins)
5.- Import the pin location constraints from file /vhdl/demos/4kbasic/
    c2sb_4kbasic.csv

Ready to go. Synthesize and program. It is advisable to have a terminal
connected before loading the FPGA (19200/8/N/1).

Since the demo does not use any external resources other than an oscillator, a
reset pushbutton and a serial port, it should be easy to port this demo to
almost any other hardware platform. Only the top file needs changing, all other
files should be vendor agnostic, though I have only tested them with Xilinx and
Altera synthesis tools.

Note that resetting the CPU does not reload the program (the program is stored
in an initialized 4K RAM which is all the CPU can see). Once the program has
started, the only way to cleanly restart it is reprogramming the FPGA. This is
why the terminal should be connected before programming.
I admit this is a nasty hack but it saves me the need to build a bootloader. For
this quick-and-dirty demo this limitation is acceptable.

Right after startup the program will ask you a few configuration questions. See
the picture below for a sample session. Remember the 4K Basic only uses caps
letters and is a bit unforgiving by today's standards.
