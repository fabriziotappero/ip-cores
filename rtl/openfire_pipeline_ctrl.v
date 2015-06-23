/*	MODULE: openfire_pipeline_ctrl

	DESCRIPTION: Pipeline controller to stall various modules.  FETCH and DECODE
are stalled on multicycle instructions (currently only loads & stores & MULs). 
DECODE and EXECUTE cycles are stalled on branchs.  See below for timing.

AUTHOR: 
Stephen Douglas Craven
Configurable Computing Lab
Virginia Tech
scraven@vt.edu

REVISION HISTORY:
Revision 0.2, 8/10/2005 SDC
Initial release

Revision 0.3, 27/03/2007 Antonio J Anton
Handling of instruction memory stall
data memory stall is handled by the multicycle instruction not completed

COPYRIGHT:
Copyright (c) 2005 Stephen Douglas Craven

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in 
the Software without restriction, including without limitation the rights to 
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
of the Software, and to permit persons to whom the Software is furnished to do 
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
SOFTWARE.

*/

`include "openfire_define.v"

module openfire_pipeline_ctrl(
	clock, reset,
	branch_taken, instr_complete, delay_bit,
	stall_fetch, stall_decode, stall_exe, flush,
	imem_done, imem_re
);
// From top level	
input		clock;
input		reset;
input		imem_done;
input		imem_re;

// From DECODE/EXECUTE
input		delay_bit;
input		branch_taken;
input		instr_complete;

output	stall_fetch;
output	stall_decode;
output	stall_exe;
output	flush;	// flush DECODE instruction

reg	[1:0]	branch_cnt;
wire   stall 			= (~imem_done & imem_re);	// stall if fetch is not completed

assign stall_fetch 	= ~instr_complete | stall;
assign stall_decode 	= ~instr_complete | branch_cnt[1] | stall ;
assign stall_exe 		= branch_cnt[0]   | stall;
assign flush 			= branch_taken & ~delay_bit;

always@(posedge clock)
begin
	if (reset)
		branch_cnt <= 0;
	else if (~stall)
	begin
		if (branch_taken)
			branch_cnt <= 2;
		else if (instr_complete & |branch_cnt)
			branch_cnt <= branch_cnt - 1;
	end
	
end

endmodule

/* TIMING DIAGRAM
Branch with Delay (F = Fetch, D = Decode, E = Execute)
        |--------|--------|--------|--------|--------|--------|
         ____     ____     ____     ____     ____     ____ 
clock   |    |___|    |___|    |___|    |___|    |___|    |___

           F - BRD   D - BRD  E - BRD
                     F - ADD  D - ADD  E - ADD
                              F - AND  S - AND  S - AND
                                       F - XOR  D - XOR  E - XOR
                                 ________
branch_taken ___________________|        |_____________________
                                       _______
branch_cnt ___________________________|       |________________
                                       _______
stall_decode _________________________|       |________________
               ________________________________________________
instr_complete 
                             ________
delay_bit __________________|        |_________________________
                                       ___
flush    _____________________________|   |____________________


Branch without Delay (S = Stall)
        |--------|--------|--------|--------|--------|--------|
         ____     ____     ____     ____     ____     ____ 
clock	  |    |___|    |___|    |___|    |___|    |___|    |___

         F - BRA   D - BRA  E - BRA
                   F - ADD  D - ADD  S - ADD
                            F - AND  S - AND  S - AND
                                     F - XOR  D - XOR  E - XOR
	 	                 			   ________
branch_taken ___________________|        |_____________________
                                       _______
branch_cnt ___________________________|       |________________
                                       _______
stall_decode _________________________|       |________________
               ________________________________________________
instr_complete 
*/
