

The USB 1.1 Function IP Core
============================================

Status
------
This core is done. It was tested on a XESS XCV800 board with
a Philips USB transceiver.

Test Bench
----------
I have uploaded a very basic test bench. It should be viewed
as a starting point to write a more comprehensive and complete
test bench.

Documentation
-------------
Sorry, there is none. I just don't have the time to write it (yet).

However, since this core is derived from my USB 2.0 Function
IP core, you might find something useful in there. Main
difference is that all the high speed support features have
been ripped out, and the interface was changed from a shared
memory model to a FIFO based model. Further there is no need
for a micro-controller interface and/or register file.


Here is the quick info:

The core will perform all USB enumeration in hardware. Meaning
it will automatically respond to the hosts SETUP packets and
send back appropriate information (which you must enter in to
the ROM). The enumeration process is usually very simple. The
host first requests a device Descriptor, which tells the host
some basic information about the device. Then it gets the
configuration descriptor, which descries the entire configuration
including all interfaces and endpoints. In this implementation
no descriptor may be larger than 64 bytes.

I have created anew top level since last check-in. Here is the
hierarchical view of the USB core:

usb1_core
    |
    +-- usb_phy
    |      |
    |      +-- usb_tx_phy
    |      |
    |      +-- usb_rx_phy
    |
    +-- usb1_utmi_if
    |
    +-- usb1_pl
    |      |
    |      +-- usb1_pd
    |      |
    |      +-- usb1_pa
    |      |
    |      +-- usb1_idma
    |      |
    |      +-- usb1_pe
    |
    +-- usb1_ctrl
    |
    +-- usb1_rom1
    |
    +-- 2x generic_fifo_sc_a
           |
           +-- generic_dpram

The following files have been removed and are no longer needed:
	usb1_top.v
	usb1_ep_in.v
	usb1_ep_out.v
	usb1_ep.v
	usb1_fifo.v

This new release is a more generic and user friendly version of the
first release. You can now easy configure the endpoints and other
features. FIFOs are external to the core, you can chose the fifo
that best fits you from the "generfic_fifos" projects at OpenCores.
This includes choosing a dual clock fifo if you need to.

The new top level (usb1_core.v) has now a brief description of the
IO signals. Hopefully that description and the test bench will be
sufficient to get you started.

Also remember that you MUST edit the ROM to properly configure the
settings for your implementation and enter proper vendor IDs, etc.

I will try to write a more complete documentation as I get the time.

Misc
----
The USB 1.1 Function Project Page is:
http://www.opencores.org/cores/usb1_funct/

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
