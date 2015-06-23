/******************************************************************************
 * License Agreement                                                          *
 *                                                                            *
 * Copyright (c) 1991-2009 Altera Corporation, San Jose, California, USA.     *
 * All rights reserved.                                                       *
 *                                                                            *
 * Any megafunction design, and related net list (encrypted or decrypted),    *
 *  support information, device programming or simulation file, and any other *
 *  associated documentation or information provided by Altera or a partner   *
 *  under Altera's Megafunction Partnership Program may be used only to       *
 *  program PLD devices (but not masked PLD devices) from Altera.  Any other  *
 *  use of such megafunction design, net list, support information, device    *
 *  programming or simulation file, or any other related documentation or     *
 *  information is prohibited for any other purpose, including, but not       *
 *  limited to modification, reverse engineering, de-compiling, or use with   *
 *  any other silicon devices, unless such use is explicitly licensed under   *
 *  a separate agreement with Altera or a megafunction partner.  Title to     *
 *  the intellectual property, including patents, copyrights, trademarks,     *
 *  trade secrets, or maskworks, embodied in any such megafunction design,    *
 *  net list, support information, device programming or simulation file, or  *
 *  any other related documentation or information provided by Altera or a    *
 *  megafunction partner, remains with Altera, the megafunction partner, or   *
 *  their respective licensors.  No other licenses, including any licenses    *
 *  needed under any third party's intellectual property, are provided herein.*
 *  Copying or modifying any file, or portion thereof, to which this notice   *
 *  is attached violates this copyright.                                      *
 *                                                                            *
 * THIS FILE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR    *
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,   *
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL    *
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER *
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING    *
 * FROM, OUT OF OR IN CONNECTION WITH THIS FILE OR THE USE OR OTHER DEALINGS  *
 * IN THIS FILE.                                                              *
 *                                                                            *
 * This agreement shall be governed in all respects by the laws of the State  *
 *  of California and by the laws of the United States of America.            *
 *                                                                            *
 ******************************************************************************/

/******************************************************************************
 *                                                                            *
 * This module reads and writes to the ssram chip on the DE2-70 board,        *
 *  with 2-cycle read latency and one cycle write latency.                    *
 *                                                                            *
 ******************************************************************************/


module Altera_UP_Avalon_SSRAM (
	// Inputs
	clk,
	reset,

	address,
	byteenable,
	read,
	write,
	writedata,

	// Bi-Directional
	SRAM_DQ,
	SRAM_DPA,

	// Outputs
	readdata,

	SRAM_CLK,
	SRAM_ADDR,
	SRAM_ADSC_N,
	SRAM_ADSP_N,
	SRAM_ADV_N,
	SRAM_BE_N,
	SRAM_CE1_N,
	SRAM_CE2,
	SRAM_CE3_N,
	SRAM_GW_N,
	SRAM_OE_N,
	SRAM_WE_N	
);


/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input				clk;
input				reset;

input		[18: 0]	address;
input		[ 3: 0]	byteenable;
input				read;
input				write;
input		[31: 0]	writedata;

// Bi-Directional
inout		[31: 0]	SRAM_DQ;		//	SRAM Data Bus 32 Bits
inout		[ 3: 0]	SRAM_DPA; 		//  SRAM Parity Data Bus

// Outputs
output		[31: 0]	readdata;

output				SRAM_CLK;		//	SRAM Clock
output		[18: 0]	SRAM_ADDR;		//	SRAM Address bus 21 Bits
output				SRAM_ADSC_N;	//	SRAM Controller Address Status 	
output				SRAM_ADSP_N;	//	SRAM Processor Address Status
output				SRAM_ADV_N;		//	SRAM Burst Address Advance
output		[ 3: 0]	SRAM_BE_N;		//	SRAM Byte Write Enable
output				SRAM_CE1_N;		//	SRAM Chip Enable
output				SRAM_CE2;		//	SRAM Chip Enable
output				SRAM_CE3_N;		//	SRAM Chip Enable
output				SRAM_GW_N;		//  SRAM Global Write Enable
output				SRAM_OE_N;		//	SRAM Output Enable
output				SRAM_WE_N;		//	SRAM Write Enable

/*****************************************************************************
 *                           Constant Declarations                           *
 *****************************************************************************/

// states
localparam	STATE_0_SET_ADSC		= 2'h0,
			STATE_1_WAIT			= 2'h1,
			STATE_2_READ_COMPLETE	= 2'h2;

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/

// Internal Wires

// Internal Registers

// State Machine Registers
reg			[ 1: 0] preset_state;
reg			[ 1: 0] next_state;

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/

always @(posedge clk)
begin
	if (reset)
		preset_state <= STATE_0_SET_ADSC;
	else
		preset_state <= next_state;
end

always @(*)
begin
	// Defaults
	next_state = STATE_0_SET_ADSC;

    case (preset_state)
	STATE_0_SET_ADSC:
	begin
		if (read | write)
			next_state = STATE_1_WAIT;
		else
			next_state = STATE_0_SET_ADSC;
	end
	STATE_1_WAIT:
	begin
		next_state = STATE_2_READ_COMPLETE;
	end
	STATE_2_READ_COMPLETE:
	begin
		next_state = STATE_0_SET_ADSC;
	end
	default:
	begin
		next_state = STATE_0_SET_ADSC;
	end
	endcase
end

/*****************************************************************************
 *                             Sequential logic                              *
 *****************************************************************************/

// Output Registers

// Internal Registers

/*****************************************************************************
 *                            Combinational logic                            *
 *****************************************************************************/

// Output Assignments
assign readdata			= SRAM_DQ;

assign SRAM_DQ[31:24]	= (byteenable[3] & write) ? writedata[31:24] : 8'hzz;
assign SRAM_DQ[23:16]	= (byteenable[2] & write) ? writedata[23:16] : 8'hzz;
assign SRAM_DQ[15: 8]	= (byteenable[1] & write) ? writedata[15: 8] : 8'hzz;
assign SRAM_DQ[ 7: 0]	= (byteenable[0] & write) ? writedata[ 7: 0] : 8'hzz;

assign SRAM_DPA			= 4'hz;

assign SRAM_CLK			= clk;
assign SRAM_ADDR		= address;
assign SRAM_ADSC_N		= ~((preset_state == STATE_0_SET_ADSC) & (read|write));
assign SRAM_ADSP_N		= 1'b1;
assign SRAM_ADV_N		= 1'b1;
assign SRAM_BE_N[3]		= ~(byteenable[3] & write);
assign SRAM_BE_N[2]		= ~(byteenable[2] & write);
assign SRAM_BE_N[1]		= ~(byteenable[1] & write);
assign SRAM_BE_N[0]		= ~(byteenable[0] & write);
assign SRAM_CE1_N		= ~(read | write);
assign SRAM_CE2			= (read | write);
assign SRAM_CE3_N		= ~(read | write);
assign SRAM_GW_N		= 1'b1;
assign SRAM_OE_N		= ~read;
assign SRAM_WE_N		= ~write;

// Internal Assignments

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/


endmodule

