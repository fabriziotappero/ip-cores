The following describes the IEEE-Standard-754 compliant, double-precision floating point unit, 
written in Verilog.  The module consists of the following files:

1.	fpu_double.v (top level)
2.	fpu_add.v
3.	fpu_sub.v
4.	fpu_mul.v
5.	fpu_div.v
6.	fpu_round.v
7.	fpu_exceptions.v
	
And a testbench file is included, containing 50 test-case operations:
1.	fpu_tb.v

This unit has been extensively simulated, covering all operations, rounding modes, exceptions
like underflow and overflow, and even the obscure corner cases, like when overflowing from 
denormalized to normalized, and vice-versa.  

The floating point unit supports denormalized numbers, 
4 operations (add, subtract, multiply, divide), and 4 rounding 
modes (nearest, zero, + inf, - inf).  The unit was synthesized with an 
estimated frequency of 230 MHz, for a Virtex5 target device.  The synthesis results 
are below.  fpu_double.v is the top-level module, and it contains the input 
and output signals from the unit.  The unit was designed to be synchronous with 
one global clock, and all of the registers can be reset with an synchronous global reset. 
When the inputs signals (a and b operands, fpu operation code, rounding mode code) are 
available, set the enable input high, then set it low after 2 clock cycles.  When the 
operation is complete and the output is available, the ready signal will go high.  To start
the next operation, set the enable input high.

Each operation takes the following amount of clock cycles to complete:
1.	addition : 		20 clock cycles
2.	subtraction: 		21 clock cycles
3.	multiplication: 	24 clock cycles
4.	division:		71 clock cycles

This is longer than other floating point units, but supporting denormalized numbers 
requires more signals and logic levels to accommodate gradual underflow.  The supported 
clock speed of 230 MHz makes up for the large number of clock cycles required for each 
operation to complete.  If you have a lower clock speed, the code can be changed to 
reduce the number of registers and latency of each operation. I purposely increased the
number of logic levels to get the code to synthesize to a faster clock frequency, but of course,
this led to longer latency.  I guess it depends on your application what is more important.

The following output signals are also available: underflow, overflow, inexact, exception,
and invalid.  They are compliant with the IEEE-754 definition of each signal.  The unit
will handle QNaN and SNaN inputs per the standard. 

I'm planning on adding more operations, like square root, sin, cos, tan, etc.,
so check back for updates.

Multiply:  
The multiply module is written specifically for a Virtex5 target device.  The DSP48E slices
can perform a 25-bit by 18-bit Twos-complement multiply (24 by 17 unsigned multiply).  I broke up the multiply to 
fit these DSP48E slices.  The breakdown is similar to the design in Figure 4-15 of the
Xilinx User Guide Document, "Virtex-5 FPGA XtremeDSP Design Considerations", also known as UG193.
You can find this document at xilinx.com by searching for "UG193".
Depending on your device, the multiply can be changed to match the bit-widths of the available
multipliers.  A total of 9 DSP48E slices are used to do the 53-bit by 53-bit multiply of 2
floating point numbers.

If you have any questions, please email me at: davidklun@gmail.com

Thanks,
David Lundgren

-----

Synthesis Results:




Performance Summary 
*******************


Worst slack in design: -0.971

                   Requested     Estimated     Requested     Estimated                Clock        Clock              
Starting Clock     Frequency     Frequency     Period        Period        Slack      Type         Group              
-----------------------------------------------------------------------------------------------------------
fpu|clk            300.0 MHz     232.3 MHz     3.333         4.304         -0.971     inferred     
==========================================================================

---------------------------------------
Resource Usage Report for fpu 

Mapping to part: xc5vsx95tff1136-2
Cell usage:
DSP48E          9 uses
FD              5 uses
FDR             519 uses
FDRE            3920 uses
FDRSE           1 use
GND             6 uses
LD              6 uses
MUXCY           35 uses
MUXCY_L         704 uses
MUXF7           1 use
VCC             5 uses
XORCY           491 uses
XORCY_L         12 uses
LUT1            185 uses
LUT2            725 uses
LUT3            1523 uses
LUT4            738 uses
LUT5            604 uses
LUT6            2506 uses

I/O ports: 206
I/O primitives: 205
IBUF           135 uses
OBUF           70 uses

BUFGP          1 use

I/O Register bits:                  0
Register bits not including I/Os:   4445 (7%)
Latch bits not including I/Os:      6 (0%)

Global Clock Buffers: 1 of 32 (3%)

Total load per clock:
   fpu|clk: 4454

Mapping Summary:
Total  LUTs: 6281 (10%)


