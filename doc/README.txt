
SASC (Simple Asynchronous Serial Controller)
============================================

Status
------
This core is done. It was tested on a XESS XCV800 board with
a Maxim transceiver.

Test Bench
----------
There is no test bench, period !
Please don't email me asking for one, unless you want to hire
me to write one ! As I said above I have tested this core in
real hardware and it works just fine.

Documentation
-------------
Sorry, there is none. I just don't have the time to write it.
It's a very simple core, has two 4 byte deep FIFOs, that are
read or written to synchronously by asserting read enable (re)
or write enable (we) while applying or reading data. It does
use flow control, which basically indicates the status of the
internal FIFOs.

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

