/*	MODULE: openfire_fetch

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

Revision 0.4  27/03/2007 Antonio J Anton
Instruction port wait states

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
SOFTWARE. */

`include "openfire_define.v"

module openfire_fetch(
	stall, clock, reset, 									// top level
	branch_taken, pc_branch, idata,						// inputs
	instruction, imem_addr, pc_decode, imem_re		// outputs
);
	
// From top level -- all active high unless otherwise noted
input		stall;
input		reset;
input		clock;

// From EXECUTE module
input 			branch_taken;	// strobe for latching in new pc
// PCs are A_SPACE + 1 because lower 2 bits are always zero
//	A_SPACE is addr space in words ... 2^A_SPACE * 4 = # Bytes
input 	[`A_SPACE+1:0]	pc_branch;	// PC of branch

// From Instr Mem
input 	[31:0]		idata;

output 	[31:0]		imem_addr;
output					imem_re;
output	[`A_SPACE+1:0]	pc_decode;
output 	[31:0]		instruction;

reg	[`A_SPACE+1:0]	pc_fetch;	// PCs only need to contain addressable instr mem
reg	[`A_SPACE+1:0]	pc_decode;	// delayed PC for DECODE
reg	[31:0]			instruction;
reg						imem_re;

assign imem_addr[31:`A_SPACE+2] = 0;	// pad unused bits with zeros, 
assign imem_addr[`A_SPACE+1:0]  = pc_fetch;

always@(posedge clock)
begin
	if (reset)
	begin
		pc_fetch 	 <= `RESET_PC_ADDRESS;
		pc_decode 	 <= `RESET_PC_ADDRESS;
		imem_re		 <= 1;
		instruction  <= `NoOp;		// Execute NoOp on reset
	end
	else 
	begin									// update PC to branch or increment pc (if stall --> pc on hold)
		if(!stall)
		begin
		  pc_fetch 	  <= branch_taken ? pc_branch : pc_fetch + 4;
		  pc_decode   <= pc_fetch;
		  instruction <= idata;
`ifdef DEBUG_FETCH
		  $display("FETCH : pc_fetch=%x, pc_decode=%x, instruction=%x", pc_fetch, pc_decode, instruction);
`endif
		end
		imem_re <= !stall;
	end 
end

endmodule
