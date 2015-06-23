/******************************************************************************
 * License Agreement                                                          *
 *                                                                            *
 * Copyright (c) 1991-2013 Altera Corporation, San Jose, California, USA.     *
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
 *   This module generates the clocks needed for the I/O devices on           *
 * Altera's DE-series boards.                                                 *
 *                                                                            *
 ******************************************************************************/

module sdram_up_clocks_0 (
	// Inputs
	CLOCK_50,
	reset,

	// Bidirectional

	// Outputs
	SDRAM_CLK,
	sys_clk,
	sys_reset_n
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input						CLOCK_50;
input						reset;

// Bidirectionals

// Outputs
output					SDRAM_CLK;
output					sys_clk;
output					sys_reset_n;

/*****************************************************************************
 *                           Constant Declarations                           *
 *****************************************************************************/

localparam SYS_CLK_MULT	= 1;
localparam SYS_CLK_DIV	= 1;


/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
// Internal Wires
wire			[ 2: 0]	sys_mem_clks;

wire						clk_locked;

wire						video_in_clk;
wire						VGA_CLK;

// Internal Registers

// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

// Output Registers

// Internal Registers

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/

assign sys_reset_n	= clk_locked;

assign sys_clk			= sys_mem_clks[0];
assign SDRAM_CLK		= sys_mem_clks[1];
assign VGA_CLK			= sys_mem_clks[2];


/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

altpll DE_Clock_Generator_System (
	// Inputs
	.inclk			({1'b0, CLOCK_50}),

	// Outputs
	.clk				(sys_mem_clks),
	.locked			(clk_locked),

	// Unused
	.activeclock	(),
	.areset			(1'b0),
	.clkbad			(),
	.clkena			({6{1'b1}}),
	.clkloss			(),
	.clkswitch		(1'b0),
	.enable0			(),
	.enable1			(),
	.extclk			(),
	.extclkena		({4{1'b1}}),
	.fbin				(1'b1),
	.pfdena			(1'b1),
	.pllena			(1'b1),
	.scanaclr		(1'b0),
	.scanclk			(1'b0),
	.scandata		(1'b0),
	.scandataout	(),
	.scandone		(),
	.scanread		(1'b0),
	.scanwrite		(1'b0),
	.sclkout0		(),
	.sclkout1		()
);
defparam
	DE_Clock_Generator_System.clk0_divide_by				= SYS_CLK_DIV,
	DE_Clock_Generator_System.clk0_duty_cycle				= 50,
	DE_Clock_Generator_System.clk0_multiply_by			= SYS_CLK_MULT,
	DE_Clock_Generator_System.clk0_phase_shift			= "0",
	DE_Clock_Generator_System.clk1_divide_by				= SYS_CLK_DIV,
	DE_Clock_Generator_System.clk1_duty_cycle				= 50,
	DE_Clock_Generator_System.clk1_multiply_by			= SYS_CLK_MULT,
	DE_Clock_Generator_System.clk1_phase_shift			= "-3000",
	DE_Clock_Generator_System.clk2_divide_by				= 2,
	DE_Clock_Generator_System.clk2_duty_cycle				= 50,
	DE_Clock_Generator_System.clk2_multiply_by			= 1,
	DE_Clock_Generator_System.clk2_phase_shift			= "20000",
	DE_Clock_Generator_System.compensate_clock			= "CLK0",
	DE_Clock_Generator_System.gate_lock_signal			= "NO",
	DE_Clock_Generator_System.inclk0_input_frequency	= 20000,
	DE_Clock_Generator_System.intended_device_family	= "Cyclone IV",
	DE_Clock_Generator_System.invalid_lock_multiplier	= 5,
	DE_Clock_Generator_System.lpm_type						= "altpll",
	DE_Clock_Generator_System.operation_mode				= "NORMAL",
	DE_Clock_Generator_System.pll_type						= "FAST",
	DE_Clock_Generator_System.port_activeclock			= "PORT_UNUSED",
	DE_Clock_Generator_System.port_areset					= "PORT_UNUSED",
	DE_Clock_Generator_System.port_clkbad0					= "PORT_UNUSED",
	DE_Clock_Generator_System.port_clkbad1					= "PORT_UNUSED",
	DE_Clock_Generator_System.port_clkloss					= "PORT_UNUSED",
	DE_Clock_Generator_System.port_clkswitch				= "PORT_UNUSED",
	DE_Clock_Generator_System.port_fbin						= "PORT_UNUSED",
	DE_Clock_Generator_System.port_inclk0					= "PORT_USED",
	DE_Clock_Generator_System.port_inclk1					= "PORT_UNUSED",
	DE_Clock_Generator_System.port_locked					= "PORT_USED",
	DE_Clock_Generator_System.port_pfdena					= "PORT_UNUSED",
	DE_Clock_Generator_System.port_pllena					= "PORT_UNUSED",
	DE_Clock_Generator_System.port_scanaclr				= "PORT_UNUSED",
	DE_Clock_Generator_System.port_scanclk					= "PORT_UNUSED",
	DE_Clock_Generator_System.port_scandata				= "PORT_UNUSED",
	DE_Clock_Generator_System.port_scandataout			= "PORT_UNUSED",
	DE_Clock_Generator_System.port_scandone				= "PORT_UNUSED",
	DE_Clock_Generator_System.port_scanread				= "PORT_UNUSED",
	DE_Clock_Generator_System.port_scanwrite				= "PORT_UNUSED",
	DE_Clock_Generator_System.port_clk0						= "PORT_USED",
	DE_Clock_Generator_System.port_clk1						= "PORT_USED",
	DE_Clock_Generator_System.port_clk2						= "PORT_USED",
	DE_Clock_Generator_System.port_clk3						= "PORT_UNUSED",
	DE_Clock_Generator_System.port_clk4						= "PORT_UNUSED",
	DE_Clock_Generator_System.port_clk5						= "PORT_UNUSED",
	DE_Clock_Generator_System.port_clkena0					= "PORT_UNUSED",
	DE_Clock_Generator_System.port_clkena1					= "PORT_UNUSED",
	DE_Clock_Generator_System.port_clkena2					= "PORT_UNUSED",
	DE_Clock_Generator_System.port_clkena3					= "PORT_UNUSED",
	DE_Clock_Generator_System.port_clkena4					= "PORT_UNUSED",
	DE_Clock_Generator_System.port_clkena5					= "PORT_UNUSED",
	DE_Clock_Generator_System.port_enable0					= "PORT_UNUSED",
	DE_Clock_Generator_System.port_enable1					= "PORT_UNUSED",
	DE_Clock_Generator_System.port_extclk0					= "PORT_UNUSED",
	DE_Clock_Generator_System.port_extclk1					= "PORT_UNUSED",
	DE_Clock_Generator_System.port_extclk2					= "PORT_UNUSED",
	DE_Clock_Generator_System.port_extclk3					= "PORT_UNUSED",
	DE_Clock_Generator_System.port_extclkena0				= "PORT_UNUSED",
	DE_Clock_Generator_System.port_extclkena1				= "PORT_UNUSED",
	DE_Clock_Generator_System.port_extclkena2				= "PORT_UNUSED",
	DE_Clock_Generator_System.port_extclkena3				= "PORT_UNUSED",
	DE_Clock_Generator_System.port_sclkout0				= "PORT_UNUSED",
	DE_Clock_Generator_System.port_sclkout1				= "PORT_UNUSED",
	DE_Clock_Generator_System.valid_lock_multiplier		= 1;


endmodule

