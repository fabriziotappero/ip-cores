/*

MODULE: openfire_top

DESCRIPTION: This is the top level module for simulation.
Debugging statements produce statements on all register and memory writes as 
well as opcode and unaligned memory write exceptions. 

AUTHOR: 
Stephen Douglas Craven
Configurable Computing Lab
Virginia Tech
scraven@vt.edu

REVISION HISTORY:
Revision 0.2, 8/10/2005 SDC
Initial release

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



// BREAKPOINT stops simulation and displays register contents.
// Set to unreachable address to disable.
`define BREAKPOINT 32'hc0

// TIMEOUT stops the simulation after TIMEOUT/2 number of clock
// cycles.
`define TIMEOUT 1000000

`include "openfire_define.v"
`include "openfire_cpu.v"
`include "openfire_primitives.v"
`include "openfire_regfile.v"
`include "openfire_execute.v"
`include "openfire_decode.v"
`include "openfire_fetch.v"
`include "openfire_pipeline_ctrl.v"

module openfire_top_single ();
wire	[31:0]	imem_data;
wire	[31:0]	imem_addr;
wire	[31:0]	dmem_data2mem;
wire	[31:0]	dmem_data2cpu;
wire	[31:0]	dmem_addr;
wire		dmem_we;

reg	[31:0] fsl_s_data;
wire	[31:0] fsl_m_data;
wire	[31:0] pc_wire;

reg		fsl_s_exists;
reg		fsl_m_full;
reg		fsl_s_control;

reg		clock;
reg		reset;
reg		stall;
reg	[31:0]	counter;	// counter used soley for debugging

`ifdef FSL_LINK
openfire_cpu	OPENFIRE0 (
	.clock(clock), .reset(reset), .stall(stall), 
	.dmem_data_in(dmem_data2cpu), .imem_data_in(imem_data),
	.dmem_addr(dmem_addr), .imem_addr(imem_addr),		// outputs
	.fsl_s_data(fsl_s_data), .fsl_s_control(fsl_s_control),
	.fsl_s_exists(fsl_s_exists), .fsl_m_full(fsl_m_full),	// FSL
	.fsl_m_data(fsl_m_data), .fsl_m_control(fsl_m_control),
	.fsl_m_write(fsl_m_write), .fsl_s_read(fsl_s_read),
	.dmem_data_out(dmem_data2mem), .dmem_we(dmem_we), .pc(pc_wire));
`else
openfire_cpu	OPENFIRE0 (.clock(clock), .reset(reset), .stall(stall), 
	.dmem_data_in(dmem_data2cpu), .imem_data_in(imem_data),
	.dmem_addr(dmem_addr), .imem_addr(imem_addr), 
	.dmem_data_out(dmem_data2mem), .dmem_we(dmem_we));
`endif
// Instruction SRAM contains $initial statement for simulation
// Note inverted clock inverted.  Needed for single-cycle FETCH with sync memories.

openfire_dual_sram	MEM ( .clock(~clock), .wr_clock(clock), .enable(!stall),	// invert clock
	.read_addr(imem_addr[`IM_SIZE - 1:0]), .write_addr(dmem_addr[`DM_SIZE - 1:0]), .data_in(dmem_data2mem), .we(dmem_we),
	.data_out(imem_data), .wr_data_out(dmem_data2cpu));

integer j;
initial begin
	clock = 1;
	reset = 1;	// reset the processor (active high)
	stall = 0;	// external stall signal (active high)
	
`ifdef FSL_LINK
	fsl_s_data = 32'h666;
	fsl_s_exists = 1;
	fsl_s_control = 1;
	fsl_m_full = 0;
`endif
	
	// Dump all variables
	//$dumpfile("dump.vcd");
	//$dumpvars;
	
	#5 reset = 0;
	#`TIMEOUT reset = 0;
	$finish;	// finish after TIMEOUT
end

// Toggle clock every time unit
always clock= #1 ~clock;

// Define clock counter for debugging
integer i;
initial begin
	counter =  32'b0;
	for (i = 0; i >= 0; i = i + 1)
		@(posedge clock) if (~reset) counter <= counter + 1;
end

// Debug Statements
always@(negedge clock)
begin
	if(OPENFIRE0.branch_taken)
	// Branch instructions
		begin
				$display("*** PC: %x Branching to %x", {{(30 - `A_SPACE) {1'b0}},OPENFIRE0.EXECUTE.pc_exe},
				{{(30 - `A_SPACE) {1'b0}},OPENFIRE0.pc_branch});
		end	
	if (OPENFIRE0.REGFILE.write_en)
	// Register File writes
`ifdef DATAPATH_16
		begin
			if(OPENFIRE0.EXECUTE.we_load_dly)
				$display("*** PC: %x Writing %x to Register %d from DMEM addr 0x%x", {{(30 - `A_SPACE) {1'b0}},OPENFIRE0.EXECUTE.pc_exe}, 
					{{(32 - `D_WIDTH) {1'b0}}, OPENFIRE0.REGFILE.input_data}, OPENFIRE0.REGFILE.regD_addr, {{(30 - `DM_SIZE){1'b0}}, MEM.write_addr, 2'b0});
			else
				$display("*** PC: %x Writing %x to Register %d", {{(30 - `A_SPACE) {1'b0}},OPENFIRE0.EXECUTE.pc_exe}, 
					{{(32 - `D_WIDTH) {1'b0}}, OPENFIRE0.REGFILE.input_data}, OPENFIRE0.REGFILE.regD_addr);			
		end
`else
		begin
			if(OPENFIRE0.EXECUTE.we_load_dly)
				$display("*** PC: %x Writing %x to Register %d from DMEM addr 0x%x", {{(30 - `A_SPACE) {1'b0}},OPENFIRE0.EXECUTE.pc_exe}, 
					{OPENFIRE0.REGFILE.input_data}, OPENFIRE0.REGFILE.regD_addr, {{(30 - `DM_SIZE){1'b0}}, MEM.write_addr, 2'b0});
			else
				$display("*** PC: %x Writing %x to Register %d", {{(30 - `A_SPACE) {1'b0}},OPENFIRE0.EXECUTE.pc_exe}, 
					{OPENFIRE0.REGFILE.input_data}, OPENFIRE0.REGFILE.regD_addr);			
		end
`endif
	if (MEM.we)
	// Memory writes
		begin
				$display("*** PC: %x Writing %x to DMem location %x", {{(30 - `A_SPACE) {1'b0}},OPENFIRE0.EXECUTE.pc_exe}, 
					MEM.data_in, {{(30 - `DM_SIZE) {1'b0}}, MEM.write_addr, 2'b0});
		end			

`ifdef FSL_LINK
	// Debug FSL Reads and Writes
	if (fsl_m_write)
		$display("*** PC: %x Writing %x to FSL0", {{(30 - `A_SPACE) {1'b0}},OPENFIRE0.EXECUTE.pc_exe}, fsl_m_data);
	else if (fsl_s_read)
		$display("*** PC: %x Reading %x from FSL0", {{(30 - `A_SPACE) {1'b0}},OPENFIRE0.EXECUTE.pc_exe}, fsl_s_data);
`endif

end


// Stop at Breakpoint
always@(posedge clock)
begin
	if(OPENFIRE0.DECODE.pc_exe == `BREAKPOINT)
		begin
		// Uncomment to display register file contents at breakpoint
		/*	$display(" PC is %x", OPENFIRE0.EXECUTE.pc_exe);
			$display(" Clock Counter is %d", counter);
			for(j = 0; j < 8; j = j + 1) 
				$display("    %d: %x      %d %x     %d: %x       %d %x", j, OPENFIRE0.REGFILE.RF_BANK0.MEM[j], j + 8, 
					OPENFIRE0.REGFILE.RF_BANK0.MEM[j + 8],j+16, OPENFIRE0.REGFILE.RF_BANK0.MEM[j+16],j+24, 
					OPENFIRE0.REGFILE.RF_BANK0.MEM[j+24]);
		*/
			$finish;
		end
end

endmodule
