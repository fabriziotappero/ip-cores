
USB 1.1 PHY
==========

Status
------
This core is done. It was tested with a USB 1.1 core I have written on
a XESS XCV800 board with a a Philips PDIUSBP11A transceiver.
I have NOT yet tested it with my USB 2.0 Function IP core.

Test Bench
----------
There is no test bench, period !  As I said above I have tested this core
in real hardware and it works just fine.

Documentation
-------------
Sorry, there is none. I just don't have the time to write it. I have tried
to follow the UTMI interface specification from USB 2.0.
'phy_mode' selects between single ended and differential tx_phy output. See
Philips ISP 1105 transceiver data sheet for an explanation of it's MODE
select pin (see Note below).
Currently this PHY only operates in Full-Speed mode. Required clock frequency
is 48MHz, from which the 12MHz USB transmit and receive clocks are derived.

RxError reports the following errors:
  - sync errors
    Could not synchronize to incoming bit stream
  - Bit Stuff Error
    Stuff bit had the wrong value (expected '0' got '1')
  - Byte Error
    Got a EOP (se0) before finished assembling a full byteAll of those errors
    are or'ed together and reported via RxError.

Note:
1) "phy_tx_mode" selects the PHY Transmit Mode:
When phy_tx_mode is '0' the outputs are encoded as:
	txdn, txdp
	 0	0	Differential Logic '0'
	 0	1	Differential Logic '1'
	 1	0	Single Ended '0'
	 1	1	Single Ended '0'

When phy_tx_mode is '1' the outputs are encoded as:
	txdn, txdp
	 0	0	Single Ended '0'
	 0	1	Differential Logic '1'
	 1	0	Differential Logic '0'
	 1	1	Illegal State

See PHILIPS Transceiver Data Sheet for: ISP1105, ISP1106 and ISP1107
for more details.

2) "usb_rst" Indicates a USB Bus Reset (this output is also or'ed with
   the reset input).

Misc
----
The USB 1.1 Phy Project Page is:
http://www.opencores.org/cores/usb_phy

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
