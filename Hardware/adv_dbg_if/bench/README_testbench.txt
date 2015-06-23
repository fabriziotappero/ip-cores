README_testbench.txt
Advanced Debug Module (adv_dbg_if)
Nathan Yawn, nathan.yawn@opencores.org

Three testbenches are supplied with the advanced debug interface. The first
uses behavioral simulation of a wishbone bus with a memory attached, and
another behavioral simulation of an OR1200 CPU.  This testbench performs
and tests bus / memory operations, and performs a few CPU operations, The
top-level module is in adv_dbg_tb.v.  Other than the behavioral models, it
instantiates an adv_dbg_if (found in ../rtl/verilog/), and a JTAG TAP
("jtag" module, not included with this module).  Note that the TAP
written by Igor Mohor  will not work correctly; use the version distributed
with the Advanced Debug System (written by Nathan Yawn).

The second testbench includes an actual wishbone/OR1200 system. Its
top-level entity is xsv_fpga_top.  It instantiates a wb_conbus, an OR1200,
an onchipram, a jtag TAP, and a UART16550, along with an adv_dbg_if.  The
testbench is also instantiated here, and is used to drive the inputs to
the JTAG TAP.  This testbench is less polished, but includes a functional
test of the single-step capability of the CPU.

The third testbench is used to test the JTAG serial port function.  Its
top-level entity is adv_dbg_jsp_tb.  This testbench instantiates only
a JTAG TAP and and adv_dbg_if.  The CPU module of the adv_dbg_if should
not be enabled for this testbench.  The WB initiator output of the WB 
module is connected point-to-point to the WB target interface of the JTAG
Serial Port (JSP) module.  The WB interface is used to drive the WB side
of the JSP.

All testbenches were written for use in ModelSim (version 6.4).  A 
wave.do file is also included for each testbench, which will display a
useful collection of signals in the ModelSim wave view.

