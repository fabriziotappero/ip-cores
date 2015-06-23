/*	MODULE: openfire sram controller
	DESCRIPTION: Controls multiple access to SRAM

AUTHOR: 
Antonio J. Anton
Anro Ingenieros (www.anro-ingenieros.com)
aj@anro-ingenieros.com

REVISION HISTORY:
Revision 1.0, 26/03/2007
Initial release

COPYRIGHT:
Copyright (c) 2007 Antonio J. Anton

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
SOFTWARE.*/

`timescale 1ns / 1ps
`include "openfire_define.v"

module sram_controller(
   rst, clk,

	ram_addr, ram_oe_n,  ram_we_n,		// external 2x 256Kx16 sram modules in SP3 Starter Kit
	ram1_io,  ram1_ce_n, ram1_ub_n, ram1_lb_n,
	ram2_io,  ram2_ce_n, ram2_ub_n, ram2_lb_n,

	addr1, data2mem1, data2cpu1, re1, we1, done1, select1,
	addr2, data2cpu2, re2, done2,
	addr3, data2cpu3, re3, done3
);

input					rst;
input					clk;

output 	[17:0]	ram_addr;		// SRAM ADDR (256K @)
output				ram_oe_n;		// OE_N shared by 2 IC
output				ram_we_n;		//	WE_N shared by 2 IC
inout		[15:0]	ram1_io;			//	I/O data port SRAM1
output				ram1_ce_n;		// SRAM1 CE_N	chip enable
output				ram1_ub_n;		// UB_N	upper byte select
output				ram1_lb_n;		// LB_N  lower byte select
inout		[15:0]	ram2_io;			//	I/O data port SRAM2
output				ram2_ce_n;		// SRAM2 CE_N	chip enable
output				ram2_ub_n;		// UB_N	upper byte select
output				ram2_lb_n;		// LB_N  lower byte select

input		[17:0]	addr1;			// port #1 lines
input		[31:0]	data2mem1;
output	[31:0]	data2cpu1;
input					re1;
input					we1;
output				done1;
input		[3:0]		select1;

input		[17:0]	addr2;			// port #2 lines
output	[31:0]	data2cpu2;
input					re2;
output				done2;

input		[17:0]	addr3;			// port #3 lines
output	[31:0]	data2cpu3;
input					re3;
output				done3;

// ----- state machine for arbitrated access ----------

wire		p1 = re1 | we1;	// operation requested on each port
wire		p2 = re2;
wire		p3 = re3;

reg		op_done1;			// operation completed on each port
reg		op_done2;
reg		op_done3;

reg [31:0] data2cpu1;		// register data output to cpu
reg [31:0] data2cpu2;
reg [31:0] data2cpu3;

reg [17:0] addr2_cached;	// cache imem address

assign	done1 = op_done1;
assign 	done2 = (addr2 == addr2_cached) & op_done2;
assign	done3 = op_done3;

//synthesis translate_off
initial begin
	data2cpu1 <= 0;
	data2cpu2 <= 0;
	data2cpu3 <= 0;
end
//synthesis translate_on

parameter [3:0] Idle  = 4'b0001,		// different states
					 Port1 = 4'b0010,
					 Port2 = 4'b0100,
					 Port3 = 4'b1000;

reg	[3:0] state;			// store different states
wire	[3:0] bytesel;			// byte select for the current operation

assign bytesel = (state == Port1) ? select1 : 4'b1111;		// byteselect to the physical ram

always @(posedge clk)
begin
	if(rst)						// reinitialite FSM
	begin
		state <= Idle;
		op_done1 <= 0;
		op_done2 <= 0;
		op_done3 <= 0;
   end
	else
	begin
		case(state)				// process FSM
		 Idle : begin					// IDLE
		 		op_done1	<= 0;			// if any request -> fall associate done
				op_done2 <= 0;
				op_done3 <= 0;
				if(p2) 		state   <= Port2;		// PORT2 in progress
				else if(p1) state   <= Port1;		// PORT1 in progress
				else if(p3)	state   <= Port3;		// PORT3 in progress
			   end

		 Port1 : begin						// PORT1 completed
		 		data2cpu1 <= { ram1_io, ram2_io };
		 		op_done1 <= 1;
				op_done2 <= 0;
				op_done3 <= 0;
				if(p2)	   state <= Port2;
				else if(p3) state <= Port3;
				else 			state <= Idle;
			  end

		 Port2 : begin						// PORT2 completed
		 		data2cpu2 	 <= { ram1_io, ram2_io };
				addr2_cached <= addr2;
				op_done1 <= 0;
				op_done2 <= 1;
				op_done3 <= 0;
				if(p3)		state <= Port3;
				else if(p1) state <= Port1;
				else			state <= Idle;
			  end

		 Port3 : begin						// PORT3 completed
		 		data2cpu3 <= { ram1_io, ram2_io };
				op_done1 <= 0;
				op_done2 <= 0;
				op_done3 <= 1;
				if(p1)		state <= Port1;
				else if(p2)	state <= Port2;
				else 			state <= Idle;
			  end
		endcase
	end	// else
end		// always

// --------- physical sram interface -----------

assign 	ram_oe_n = ~1;					// oe always active (check: power consumption?)
assign 	ram_we_n = ~(state == Port1 & we1);

assign	ram1_ce_n = 0;					// chip select enabled
assign	ram1_ub_n = ~bytesel[3];	// upper/lower byte enabled
assign	ram1_lb_n = ~bytesel[2];

assign	ram2_ce_n = 0;					// chip select enabled
assign	ram2_ub_n = ~bytesel[1];	// upper/lower byte enabled
assign	ram2_lb_n = ~bytesel[0];

assign 	ram_addr	= (state == Port3) ? addr3 :		// address bus
						  (state == Port2) ? addr2 :
						  addr1;

wire	[31:0] data2mem = data2mem1;		// only port #1 can write to memory

assign ram1_io = ~ram_we_n ? data2mem[31:16] : 16'bZ;		// write port (tristate)
assign ram2_io	= ~ram_we_n ? data2mem[15:0]  : 16'bZ;

endmodule
