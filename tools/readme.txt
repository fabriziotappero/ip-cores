This directory contains various tools:

Arduino
=======
The Arduino Mega firmware to be run with a dongle described at:
http://www.baltazarstudios.com


dongle
======
Several scripts and files that run Z80 instructions through the Arduino
dongle to collect timing and functional data.

Some instructions (daa, neg, sbc) have separate simulation scripts
that contain functional implementation which is then compared to
the response of a physical Z80 CPU (through the dongle).


z80_pla_checker
===============
A Visual Studio 2010 project that loads PLA table and provides interactive
simulation of opcodes and logic responses. The program also generates a
Verilog PLA table source code to be included in the A-Z80 project.


zmac
====
A handy Z80 assember.
Assembly source files that test and verify A-Z80 processor.
