		README hello-uart

This directory originates from the hello-uart[1].tar.gz that was attached to the 
openrisc-forum message 2003/06/00075(http://www.opencores.org/forums/openrisc/2003/06/00075)
The reason why I put it on the openrisc repository is because I'm experiencing troubles 
downloading the attachment. Also because in the past this program was a very 
good starting point for me to start programming the openrisc.

ORIGINAL MESSAGE:

From: "Damjan Lampret" <lampret@o... >
Date: Sat, 14 Jun 2003 22:40:58 -0700
Subject: Re: [openrisc] setting the stall bit using GDB

Michael,

try the following, source files attached (it should run on or1ksim or on
your board assuming your SoC on the board uses addresses in board.h, change
board.h as needed):

First build the demo (see attached tgz). If you have all the tools installed
you can build it using:


make clean all


File hello.or32 should be built. Now start jp1-xilinx utility:

./jp1-xilinx 9999


Instead of 9999, any other port address may be used. Then start GDB with our
example:

or32-rtems-gdb hello.or32


Then load the hello.or32 file onto the board, using gdb:

(gdb) target jtag jtag://localhost:9999
(gdb) load


Now program is loaded and we can start it. Before doing that we must connect
serial port cable to our board, start serial port program (e.g. minicom) and
set baud rates (default 9600 8N1 in board.h). OR1k has reset vector located
at 0x100. We will simulate reset using:
(gdb) set $pc=0x100
(gdb) continue



Hello World!!! should be printed on terminal. Instead of just continue
command under gdb we can experiment more with next, step, nexti, stepi,
break and others like print:

(gdb) set $pc = 0x100
(gdb) break uart_putc
(gdb) c
(gdb) next
(gdb) print c


Instead of using command line debugging with gdb we can also use Data
Display Debugger. Start it with:

ddd --debugger or32-uclinux-gdb hello.or32 &


Same commands as above can be entered in console below. After program is
loaded with:

(gdb) target jtag jtag://localhost:9999
(gdb) load
(gdb) set $pc=0x100


We can set breakpoint with mouse clicks and step using step/next buttons.
Program can be run with continue button. We can set watchpoints, observe
data in Data Display Window or simply by moving mouse over the variable.


You can play a bit with hello.c file, e. g. by changing case of entered
characters.

regards,
Damjan

----- Original Message -----
From: <Michael@M... >
To: <openrisc@o... >
Sent: Tuesday, June 10, 2003 2:45 PM
Subject: [openrisc] setting the stall bit using GDB


> Can someone spare a minute to give a pointer for using GDB?  My setup
> includes the OR32 processor running on a Xilinx XCV1000, with some
> SRAM and a UART attached to it. The Debug unit is compiled into the
> core, and I am using a linux box as the host for GDB.  We are using the
> XIlinx Parallel-III JTAG cable, and it's attached to the TDI, TDO, TMS,
> and TCK lines.
>
> So my question is, what GDB command do I use to send the stall/un-
> stall commend to the TAP?
>
> Thanks,
> Michael McAllister
> 
>

hello-uart[1].tar.gz
