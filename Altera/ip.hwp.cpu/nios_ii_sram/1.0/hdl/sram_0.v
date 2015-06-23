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
 * This module chipselects reads and writes to the sram, with 2-cycle         *
 *  read latency and one cycle write latency.                                 *
 *                                                                            *
 ******************************************************************************/


module sram_0 (
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

	// Outputs
	readdata,

	SRAM_ADDR,
	SRAM_LB_N,
	SRAM_UB_N,
	SRAM_CE_N,
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

input		[17:0]	address;
input		[1:0]	byteenable;
input				read;
input				write;
input		[15:0]	writedata;

// Bi-Directional
inout		[15:0]	SRAM_DQ;		// SRAM Data bus 16 Bits

// Outputs
output	reg	[15:0]	readdata;

output	reg	[17:0]	SRAM_ADDR;		// SRAM Address bus 18 Bits
output	reg			SRAM_LB_N;		// SRAM Low-byte Data Mask 
output	reg			SRAM_UB_N;		// SRAM High-byte Data Mask 
output	reg			SRAM_CE_N;		// SRAM Chip chipselect
output	reg			SRAM_OE_N;		// SRAM Output chipselect
output	reg			SRAM_WE_N;		// SRAM Write chipselect

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/

// Internal Wires

// Internal Registers
reg					is_write;
reg			[15: 0]	writedata_reg;

// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential logic                              *
 *****************************************************************************/

// Output Registers
always @(posedge clk)
begin
	if (reset)
	begin
		readdata		<= 16'h0000;

		SRAM_ADDR		<= 18'h00000;
		SRAM_LB_N		<= 1'b1;
		SRAM_UB_N		<= 1'b1;
		SRAM_CE_N		<= 1'b1;
		SRAM_OE_N		<= 1'b1;
		SRAM_WE_N		<= 1'b1;
	end
	else
	begin
		readdata		<= SRAM_DQ;

		SRAM_ADDR		<= address;
		SRAM_LB_N		<= ~(byteenable[0] & (read | write));
		SRAM_UB_N		<= ~(byteenable[1] & (read | write));
		SRAM_CE_N		<= ~(read | write);
		SRAM_OE_N		<= ~read;
		SRAM_WE_N		<= ~write;
	end
end

// Internal Registers
always @(posedge clk)
begin
	if (reset)
		is_write		<= 1'b0;
	else
		is_write		<= write;
end

always @(posedge clk)
begin
	if (reset)
		writedata_reg	<= 16'h0000;
	else
		writedata_reg	<= writedata;
end

/*****************************************************************************
 *                            Combinational logic                            *
 *****************************************************************************/

// Output Assignments
assign SRAM_DQ	= (is_write) ? writedata_reg : 16'hzzzz;

// Internal Assignments

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/


endmodule

