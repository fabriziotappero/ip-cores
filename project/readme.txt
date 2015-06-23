8080 Compatible CPU: Overview

Details

Name: cpu8080
Created: 04-Oct-2006 23:44:45
Updated: 06-Oct-2006 22:16:26
	
Project maintainer

Scott A. Moore

Description

This is an 8080 core I created as a project to get to know Verilog.

The 8080 was the second in the series 8008->8080->Z80. It was the first 
commercially available single chip CPU (disregarding the required clock and
demultiplexor chips). Besides being an interesting project, it also can serve as
a very compact core, suitable for a supervisor role on an FPGA with other
blocks. It has extensive support, all freely available, including assemblers,
compilers, an operating system (CP/M).

Although the Z80 is a more popular core due to being a superset of the 8080, the
Z80 takes considerably more chip real estate. Its likely that more than 50% of
available software is 8080 only, since the Z80 was often used to run 8080 code.
For example, the CP/M OS itself was 8080 only code.

This means that the 8080 can be an attractive core if you want the great support
of this processor series, but need it to fit in less space.

The core is fully instruction compatible with 8080, but not signal compatible.
The original 8080 was a multiplexed nightmare. one of the original selling
points of the Z80 was its cleanup of the signals, and the 8080 itself had a
companion chip that demultiplexed it.

There are a few other similar chips on opencores. This one is a bit different
because it is only 8080, and is in native Verilog (not a translation). Further,
the goal was to get it down to the minimum in both source size and synthesized
size.

I also suspect there is a preverse advantage to running this core: its original
manufacturer no longer makes it, or any compatible chip, and it has probally
passed from any IP protection long ago. However, as usual, Should warn that I
have not verified any legal status on this processor and do not speak from any
knowledge or authority on the matter.

Features

Instruction set: 8080
Data size: 8 bit
Address: 16 bit
Instruction: 8 bit
Language: Verilog
License: BSD
Created under: Xilinx ISE, free webpack edition
Device: xc3c1000-4ft256
Slices: 1104
Slice flip flops: 296
4 input LUTs: 2082
Bonded IOBs: 33
GCLKs: 1

The CPU works entirely on positive clock edges and signals, but could be
reconfigured easily. It has wait state ability, and simple interrupt
request/acknowledge structure. The original 8080 method of fetching an external
instruction to satisfy the interrupt is preserved, and it is left up to an
external interrupt controller to provide vectoring.

I have no problem with, and in fact encourage, commercial use, modifications
(public and private), etc.

Status

This project was synthesized and simulated, but has not yet been tried on real
hardware, I am going to obtain a FPGA evaluator board for that step.

The wait state and interrupt capability, as of this writing, have not been
verified.

It includes an elementary test bench with an instruction ROM, and RAM. Each of
the instructions of the 8080 has been given a walkthrough in simulation, and
verified to give the correct flags and results. Not all registers have been
tried with all instructions. The next step is I will make a full instruction
test that will go through all modes, to be loaded into the testbench rom, then
simulated, and (hopefully) used to create an automated regression test for the
CPU.

I expect to do several more edits to merge code in the CPU in attempts to make
it use less real estate and less source lines. I also plan to create an interrupt
controller, select controller and other add-ons towards the goal of a system
that runs on the target eval board. I am thinking towards running this on the
eval board, which includes VGA and keyboard boards, as a "virtual Altair" (an
early home computer using the 8080), that includes a serial I/O emulator and
enough resources to run CP/M.

I have no plans to extend the processor after that. The Z80 appears to be well
served here, so I won't be extending the core to cover that space. The 12
instructions that remain undefined in the 8080 can be useful to the embedded
designer to implement custom instructions.

If the core seems to be written by someone versed in CPU design, but stunningly
ignorant on Verilog matters, its because that is essentially the situation. I
used to design ICs at the schematic level, before all this HDL stuff, and
figgured I would try it out.

If you can see areas in the design where gates can be saved, by all means let me
know, and I'll get it put in there.

Development systems

There is TONS of software available for the 8080. The best way to go about it is
to run a CP/M simulator on your host machine. Here are a few:

http://www.schorn.ch/cpm/intro.html
http://www.moria.de/~michael/yaze-cpm3/

For development systems, try these forums:

http://www.retroarchive.org
http://www.cpm.z80.de/

This includes CP/M, assemblers, a basic compiler, the original Microsoft Basic
interpreter, Fortan compilers, Cobol, C (of course), Pascal, Modula, Algol, and
Ada.

You can find a lot more with a simple search.

CP/M itself is a good, small operating system to run on your target if you wish.
It can be adapted to your target hardware with a very simple BIOS, which can run
using a flash memory as the "disk" for it. The entire system fits in less than
256kb (yes, actually less than a meg), which was the common size of a floppy
disk back when this CPU was popular.

Documentation

Here are some locations that have the original 8080 documentation:

http://vt100.net/mirror/harte/Intel%208080%20Manual/
http://www.hartetechnologies.com/manuals/Intel%208080%20Manual/
http://www.imsai.net/whatsnew.htm
http://www.classiccmp.org/dunfield/heath/index.htm

That last link contains the "8080 Assembly language programming manual", which
is the book that I used to construct cpu8080, from my original coffee stained
edition, bought in 1977.

For people interested in the difference between the 8080 and its predecessor,
the 8008, the following site is available:

http://www.bitsavers.org/pdf/intel/MCS8/

Legal notice

The 8080 CPU implemented here was created as a not for profit student project.
I don't know if its use will violate patents, copyrights, trademark rights or
other rights. The source files were created entirely by me, but their use,
commercial or otherwise, and any legal, consequences that arise, are entirely
the responsibility of the user. I specifically deny that this core is usable for
life support systems, or any other system that can or will cause, directly or
indirectly, any harm to persons or property.

THESE SOURCE FILES ARE PROVIDED "AS IS" AND WITHOUT ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, WITHOUT
LIMITATION, THE IMPLIED WARRANTIES OF MERCHANTIBILITY AND
FITNESS FOR A PARTICULAR PURPOSE.

CVS Format

The CVS repository is under cpu8080.

I'll apologize in advance, but repository is basically a dump of my Xilinx ISE
directory. This is not the clean way to do it, but it does have the advantage
that if you are running ISE, you can download the entire thing and just go. Here
is a list of the important files in the directory:

readme.txt - A copy of this text
cpu8080.txt - The documentation for the project, in plain ASCII.
cpu8080.v - The 8080 core
testbench.v - The testbench for the core. Also contains the peripherals for the
core, such as the peripheral select controller, the interrupt controller, the
test ROM, RAM, and anything else required.

The other files are the testbench running files, like the stimulus package. I
don't even know what half of them are, sorry, I only started using the system 2
weeks ago!

Shameless plug

For people who want ask me questions, or find out more about what I am doing, my
information is:

Email: samiam95124@m...
Web page: www.moorecad.com

Disclaimer: The above web page does include commercial content, ads, rants, etc.
