/*

MODULE: openfire_fetch

DESCRIPTION: The fetch module interfaces with the instruction memory and
fetches the next instruction.

TO DO:
- Add prefetch buffer
- Add LMB interface

AUTHOR: 
Stephen Douglas Craven
Configurable Computing Lab
Virginia Tech
scraven@vt.edu

REVISION HISTORY:
Revision 0.2, 8/10/2005 SDC
Initial release

Revision 0.3, 12/17/2005 SDC
Fixed PC size bug

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


module openfire_fetch(
	stall, clock, reset, 				// top level
	branch_taken, pc_branch, idata,			// inputs
	instruction, imem_addr, pc_decode);		// outputs
	
// From top level -- all active high unless otherwise noted
input		stall;
input		reset;
input		clock;

// From EXECUTE module
input 			branch_taken;	// strobe for latching in new pc
input 	[`D_WIDTH-1:0]	pc_branch;	// PC of branch

// From Instr Mem
input 	[31:0]		idata;

output 	[31:0]		imem_addr;
output	[`D_WIDTH-1:0]	pc_decode;
output 	[31:0]		instruction;

reg	[`D_WIDTH-1:0]	pc_fetch;	// PCs only need to contain addressable instr mem
reg	[`D_WIDTH-1:0]	pc_decode;	// delayed PC for DECODE
reg	[31:0]		instruction;

assign imem_addr = pc_fetch;

always@(posedge clock)
	if (reset)
	begin
		pc_fetch 	<= 0;
		pc_decode 	<= 0;
		instruction 	<= 32'h80000000;		// Execute NoOp on reset
	end
	else if (!stall)
	begin
		pc_fetch 	<= branch_taken ? pc_branch : pc_fetch + 4;	// update PC to branch or increment pc
		pc_decode 	<= pc_fetch;
		instruction 	<= idata;
	end
endmodule
