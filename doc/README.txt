
Generic FIFOs
=============

Status
------
All FIFOs that are release are done. They have been simulated
and most of them have been used in one way or another in one
of my projects.  Some have been verified in real hardware.
There probably will be several more flavors of FIFOs released
in the future.

Test Bench
----------
I have included a very basic test bench. It should be viewed
as a starting point to write a more comprehensive and complete
test bench.

Documentation
-------------
There is nothing beyond this README file and the headers in
each of the modules. I hope that information will be sufficient.

This first release has 3 different FIFOs:

- generic_fifo_sc_a.v
- generic_fifo_sc_b.v
- generic_fifo_dc.v

The first two (generic_fifo_sc_a.v and generic_fifo_sc_b.v)
are essentially equivalent functionality wise. Some internal
are different implemented between the two. Both are single
clock FIFOs (sc), with same input port and output port widths.
The third FIFO, is a dual clock fifo. Read and Write ports have
independent clocks. Otherwise it is similar in functionality
to the single clock FIFOs.
FIFO depth and width are parameterized.

Again, check the headers of each of the FIFOs for more information.

Misc
----
The Generic FIFOs Project Page is:
http://www.opencores.org/cores/generic_fifos/

To find out more about me (Rudolf Usselmann), please visit:
http://www.asics.ws

Directory Structure
-------------------
[core_root]
 |
 +-doc                        Documentation
 |
 +-bench--+                   Test Bench
 |        +-verilog           Verilog Sources
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
