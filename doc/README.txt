
SS_PCM (Single Slot Slave PCM Intervace)
============================================

Status
------
This core is done. It was tested on a XESS XCV800 board
interfacing to a proprietary device with a TI DSP, exchanging
PCM streams in both directions.

Test Bench
----------
There is no test bench, period !
Please don't email me asking for one, unless you want to hire
me to write one ! As I said above I have tested this core in
real hardware and it works just fine.

Documentation
-------------
Sorry, there is none. I just don't have the time to write it.

Here is a short how to:

This is a Salve PCM interface, meaning Clock and Sync are input
to the core. To make it a Master interface add a clock and Sync
signal generator (for example a 128KHz clock and 8KHz Sync).

PCM Clock is an external clock source and can really be any
clock rate. It should however be 16 times faster than the PCM
Sync signal rate.

PCM Sync, indicates the start of a PCM frame and in a practical
application would come in 8KHz intervals.

SSEL, indicates how many clock cycles to wait after a Sync
signal before starting to receive and transmit data.

After seeing a the Sync signal, this core will wait 'SSEL'
number of PCM clock cycles and then start receiving and
transmitting. Receiving and transmitting always happens
simultaneously. After it has finished receiving and transmitting
16 bits it will wait for the next Sync signal before repeating
the process.

At the end of receive process data is transferred from a
shift register to a hold register, guaranteeing that the data
will only change once during one Sync period.
After seeing the Sync signal, data is transferred from a transmit
holding register to a transmit shift register. If the transmit
hold register is not updates during one sync period the previous
data is retransmitted.

All of the above behavior is in compliance with general PCM
stream usage.

The core itself has a 8 bit interface. 're_i' selects between
the high and low byte in the holding register:
re_i-1	High byte from the receive holding register is driven
	on dout_o
re_i-0	Low byte from the receive holding register is driven
	on dout_o

To write data to the core:
we_i[0]-1	Stores data from din_i to transmit hold
		register low byte
we_i[1]-1	Stores data from din_i to transmit hold
		register high byte



Misc
----
The SASC Project Page is:
http://www.opencores.org/cores/sasc/

To find out more about me (Rudolf Usselmann), please visit:
http://www.asics.ws


Directory Structure
-------------------
[core_root]
 |
 +-doc                        Documentation
 |
 +-bench--+                   Test Bench
 |        +- verilog          Verilog Sources
 |        +-vhdl              VHDL Sources
 |
 +-rtl----+                   Core RTL Sources
 |        +-verilog           Verilog Sources
 |        +-vhdl              VHDL Sources
 |
 +-sim----+
 |        +-rtl_sim---+       Functional verification Directory
 |        |           +-bin   Makefiles/Run Scripts
 |        |           +-run   Working Directory
 |        |
 |        +-gate_sim--+       Functional & Timing Gate Level
 |                    |       Verification Directory
 |                    +-bin   Makefiles/Run Scripts
 |                    +-run   Working Directory
 |
 +-lint--+                    Lint Directory Tree
 |       +-bin                Makefiles/Run Scripts
 |       +-run                Working Directory
 |       +-log                Linter log & result files
 |
 +-syn---+                    Synthesis Directory Tree
 |       +-bin                Synthesis Scripts
 |       +-run                Working Directory
 |       +-log                Synthesis log files
 |       +-out                Synthesis Output

