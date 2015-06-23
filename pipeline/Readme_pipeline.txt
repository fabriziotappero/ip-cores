The verilog files, fpu_addsub.v and fpu_mul.v, are pipelined versions of
floating point operators.  The four rounding modes (Nearest, To Zero, To
Positive Infintiy, To Negative Infinity) are supported by these operators. 
Denormalized numbers are not supported, but instead are treated as 0.  
If infinity or NaN is on either of the inputs,
then infinity will be the output.  Addition and subtraction have a latency
of 24 clock cycles, and then an output is available on each clock cycle after the latency.
Multiplication has a latency of 21 clock cycles, and 
then an output is available on each clock cycle after the latency.

For addition and subtraction, fpu_addsub.v was synthesized with an estimated 
frequency of 259 MHz for a Virtex5 device.  The synthesis results are below.  
The file, fpu_addsub_TB.v, is the testbench used to simulate fpu_addsub.v.

For multiplication, fpu_mul.v was synthesized with an estimated 
frequency of 393 MHz for a Virtex5 device.  The synthesis results are below.  
The file, fpu_mul_TB.v, is the testbench used to simulate fpu_mul.v. 

Please email me any questions.

David Lundgren
davidklun@gmail.com

addsub synthesis results:

---------------------------------------
Resource Usage Report for fpu_addsub 

Mapping to part: xc5vsx95tff1136-2
Cell usage:
FDE             55 uses
FDR             6 uses
FDRE            2848 uses
GND             1 use
MUXCY           8 uses
MUXCY_L         293 uses
VCC             1 use
XORCY           240 uses
XORCY_L         5 uses
LUT1            98 uses
LUT2            377 uses
LUT3            522 uses
LUT4            151 uses
LUT5            101 uses
LUT6            517 uses

I/O ports: 199
I/O primitives: 198
IBUF           133 uses
OBUF           65 uses

BUFGP          1 use

SRL primitives:
SRLC32E        1 use
SRL16E         54 uses

I/O Register bits:                  0
Register bits not including I/Os:   2909 (4%)

Global Clock Buffers: 1 of 32 (3%)

Total load per clock:
   fpu_addsub|clk: 2964

Mapping Summary:
Total  LUTs: 1821 (3%)

------------------------------

multiply synthesis results:

---------------------------------------
Resource Usage Report for fpu_mul 

Mapping to part: xc5vsx95tff1136-2
Cell usage:
DSP48E          9 uses
FDE             83 uses
FDRE            1536 uses
FDRSE           11 uses
GND             1 use
MUXCY           7 uses
MUXCY_L         164 uses
VCC             1 use
XORCY           128 uses
XORCY_L         5 uses
LUT1            82 uses
LUT2            215 uses
LUT3            170 uses
LUT4            48 uses
LUT5            13 uses
LUT6            32 uses

I/O ports: 198
I/O primitives: 197
IBUF           132 uses
OBUF           65 uses

BUFGP          1 use

SRL primitives:
SRL16E         83 uses

I/O Register bits:                  0
Register bits not including I/Os:   1630 (2%)

Global Clock Buffers: 1 of 32 (3%)

Total load per clock:
   fpu_mul|clk: 1722

Mapping Summary:
Total  LUTs: 643 (1%)
