// 45678901234567890123456789012345678901234567890123456789012345678901234567890
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// SVN tag: None

January 27,2013
RTL - Commited changes to detect PC underflow/overflow as an OP-code error.

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// SVN tag: None

November 21,2011
RTL - No Change

Code cleanup, converted tabs to blanks. Added code to instruction test to cover
a few base instructions that weren't being tested. Changed instance name of
semaphore registers from "bit" to "sbit" to be compatible with System Verilog.

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

My current idea list for enhancements is:

Add to the software apps:
a - It should be possible to write software to emulate some simple hardware
      modules such as I2C, SPI and UART.
b - DMA controller software
c - Find open source C compiler for Xgate
d - ???

It would be interesting to integrate the Xgate with some of the other OpenCores
  peripheral modules. Again there would be some related software development for
  verification. The ultimate goal would be to to create full-blown drivers for
  these modules.
a - Integrate Xgate with I2C controller and develop software to support
     SMBus and PMBus protocols.
b - ???

Another interesting integration project would be to build a processor core with
  the OpenRISC as the host and the Xgate working as a co-processor. Some type of
  memory controller module would need to be developed so the Xgate could have
  some semiprivate RAM to run code from. Also a separate slave bus would be
  nice to isolate peripherals that could be managed mostly by the Xgate. Some
  software development would be required for both OpenRISC and Xgate to verify
  the functionality.

Develop hardware debug module. Survey Freescale debugger and other debugger
  specifications and develop hardware debugger/specification that can optionally
  be connected to the Xgate module. The debugger should be broken into at least
  two modules, one the actual debug interface and the second a flexible serial
  interface adaptor. There are already JTAG modules in the design database that
  I had thought might be used as one possible interface to the debugger.
  (A great project on it's own would be to develop a JTAG module that meets the
  latest JTAG specification including the single wire interface.)

Upgrade Xgate to the enhanced version that Freescale now ships. This includes
  an alternate register set so the Xgate can switch in a few cycles from a low
  priority interrupt to a higher priority interrupt and then return to the low
  priority interrupt process.

Improvements to the architecture to support high speed operation. The current
  code was developed in a piecemeal fashion without much pre-planing on the
  data path from/to RAM and the internal registers.

System Verilog class based constrained random verification environment.

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// SVN tag: None

August 11,2010
RTL - No Change

Applications - Added the "application" directory to the "sw" directory. The
    first application code added is the SKIPJACK encrypt/decrypt function. This
    algorithm works on a 64 bit block of data and uses an 80 bit key. See the
    "sw/applications/skipjack/README.txt" file for more information.

Testbench - To aid in software development a simple debug module was added to
    the testbench. The debugger loads watchpoint addresses stored in RAM after
    the first RAM initialization. The debugger generates trigger signals that
    can be watched in the waveform viewer and captures a copy of the CPU
    registers at each trigger event. The watch point addresses are captured by
    the assembler and stored in RAM addresses reserved for the test bench.
    There are enable registers in the testbench that can enable or disable any
    of the eight individual watchpoints under testbench control. 

Doc - Made corrections to some of the example code in the detailed instruction
    descriptions.

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// SVN tag: None

June 10,2010
RTL - No Change

Testbench - No Change.

Doc - Added descriptions for interrupt bypass registers. Added Appendix B for
    testbench description.

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// SVN tag: None

May 18,2010
RTL - Fixed xlink synthesis warnings noted by Nachiket Jugade,
    missing else statment for chid_sm_ns line 393,
    missing default on shifter lines 2382 (Although all cases are covered).

Testbench - No Change.

Doc - No Change.

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// SVN tag: None

May 13,2010
RTL - Code cleanup. Eliminated index [0] of "xgif" and "chan_req_i" output and
    input pins along with assoicated status and and control registers. This
    channel has never been usable.

Testbench - Changes to match changes in RTL .

Doc - No Change.

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// SVN tag: None

May 12,2010
RTL - Added new control registers for interrupt bypass function. Out of reset
    all input interrupts are bypassed directly to the Xgate interrupt outputs.
    The interrupts are also disabled from effecting the Xgate till the bypass
    is disabled. The interrupt priority has been flipped so that now the lowest
    index input interrupt has the highest priority.

Testbench - Added semaphore register and read only registers to observe irq
    outputs of Xgate to testbench slave module. Added parameters to support new
    Xgate registers and testbench registers. Added new test to checkout
    bypass functionality and interrupt priority encoding.

Doc - Updated with additions of IRQ Bypass registers.

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// SVN tag: None

Apr 22,2010
RTL - Fixed bug when entering DEBUG by command from the slave WISHBONE bus.
    All tests now pass when the RAM wait states are set from zero to four. Five
    wait states times out in simulation while running the last test which is
    a simple register test otherwise I expect it would pass.

Testbench - Many of the failures while testing wait states were due to fixed
    delays coded in the testbench. As necessary, delays were changed to be a
    function of a parameter that is based on the number of RAM wait states.

Doc - No change.

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// SVN tag: None

Apr 5,2010
RTL - First pass at fixing bug when entering DEBUG by command from the slave
    WISHBONE bus. All tests now pass when the RAM wait states are set to zero,
    although there are errors in DEBUG mode when RAM wait states are increased.
    Icarus Verilog version 0.9.2 now supports the "generate" command. This is
    now used to instantiate the semaphore registers.

Testbench - Added capability to insert wait states on RAM access.

Doc - No change.

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// SVN tag: None

Feb 12,2010
RTL - Update to the WISHBONE interface when wait states are enabled to trade
   16 data flops for 5 address registers. This change now also requires single
   cycle timing on the WISHBONE address bus, multi-cycle timing is still
   allowed on the WISHBONE write data bus. In the old design WISHBONE read
   cycles required the address to be decoded and the read data to be latched
   in the first cycle and the there was a whole cycle to drive the read data
   bus. The new design latches the address in the first cycle then decodes the
   address and outputs the data in the second cycle. (The WISHBONE bus doesn't
   require the address or data to be latched for multi-cycle operation but by
   doing this it is hoped some power will be saved in the combinational logic
   by reducing the decoding activity at each address change.)

Testbench - No change.

Doc - No change.

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// SVN tag: None

Jan 27,2010
RTL - 85% done -- Fixed error in wbs_ack_o signal when Xgate wait states were
   enabled. If a slave bus transaction was started but not completed in the
   second cycle a wbs_ack_o output was still generated. Added a wbs_err_o output
   signal to flag this input condition but not sure if it is really needed.
  The old testbench was "helping" the Xgate module by sending an almost
   continuous wbm_ack_i signal which allowed the RISC state machine to advance
   when it shouldn't. Changes were made to the WISHBONE master bus interface
   and the RISC control logic.

Updates to testbench -- Extensive changes to testbench. The bus arbitration
   module has been completely rewritten. It now completely controls access to the
   system bus and RAM. It internally generates a WISHBONE ack signal for the RAM.
   The test control registers have been moved out of the top level and put into
   a new WISHBONE slave module which also attaches to the system bus. The Xgate
   modules master and slave buses are fully integrated with the bus arbitration
   module and the system bus. The new testbench looks a lot more like a real
   system environment.
  To Do: Add back "random" wait state generation for RAM access.

Updates to User Guide -- Minor corrections to instruction set details. Needs more
  review on condition code settings.

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// SVN tag: None

Jan 11,2010
RTL - 85% done -- Fix error in Zero Flag calculation for ADC and SBC instructions
  Fix Error in loading R2 durning cpu_state == BOOT_3.
  There is a bug in DEBUG mode that is sensitive to number of preceding
   instructions and wait states that needs to be resolved.

Updates to testbench -- 

Updates to User Guide -- First pass with instruction set details. Needs more
  review on condition code settings.

////////////////////////////////////////////////////////////////////////////////
// SVN tag: None

Dec 08,2009
RTL - 85% done -- Updated code so there is only one program counter adder.
   Updated WISHBONE Slave bus for word addressability and byte selection.
   Deleted two stack pointer registers.

Updates to testbench -- 

Updates to User Guide -- Minor cleanup.

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// SVN tag: None

Nov 09,2009
RTL - 85% done - Minor changes to Mastermode bus.

Updates to testbench, Moved RAM.to submodule, Added bus arbitration module
   but this is not fully functional. Causes timing problems when master is
   polling Xgate registers durning debug mode tests. Will probably change RAM
   model to dual port in next revision.
   Updated master module to include WISHBONE select inputs.

Updates to User Guide.

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// SVN tag: None

Oct 07,2009
RTL - 85% done
All debug commands now working, including writes to XGCHID register.

Updates to testbench, added timeout and total error count.

Updates to User Guide --.

Created the sw directory and copied over the software stuff from the bench
directory.

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// SVN tag: None

Sept 23,2009
BRK instruction working. Single Step Command in debug mode working.
Software error interrupt added.

Updates to testbench.
New assembly code directory: debug_test

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// SVN tag: None

Sept 10,2009
Added WISHBONE master bus submodule and some related top level signals but still
  not much real functionality.
  
Added code to allow for memory access stalls.

Upgraded testbench to insert memory wait states. Added more error detection
  and summery.

Improved instruction decoder. Still needs more work to remove redundant adders
  to improve synthesis results.

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// SVN tag: None

Sept 1, 2009
This is a prerelease checkin and should be looked at as an incremental backup
and not representative of what may be in the final release.

RTL - 75% done
What works:
  Basic instruction set execution simulated and verified. Condition code
  operation on instructions partially verified.

  Basic WISHBONE slave bus operation used, full functionality not verified.

What's broken or unimplemented:
  All things related to debug mode.
  WISHBONE master bus interface.

User Documentation - 30% done

