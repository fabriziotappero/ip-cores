//---------------------------------------------------------------------------
// Wishbone DDR Controller
// 
// (c) Joerg Bornschein (<jb@capsec.org>)
//---------------------------------------------------------------------------

`timescale 1ns / 1ps
`include "ddr_include.v"

module ddr_clkgen
#(
	parameter phase_shift  = 0,
	parameter clk_multiply = 13,
	parameter clk_divide   = 5
) (
	input        clk,
	input        reset,
	output       locked,
	//
	output       read_clk,
	output       write_clk,
	output       write_clk90,
	// DCM phase shift control 
	output   reg ps_ready,
	input        ps_up,
	input        ps_down
);


//----------------------------------------------------------------------------
// ~133 MHz DDR Clock generator
//----------------------------------------------------------------------------
wire  read_clk_u;
wire  dcm_fx_locked;

DCM #(
	.CLKDV_DIVIDE(2.0),          // Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
                                 //   7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
	.CLKFX_DIVIDE(clk_divide),   // Can be any integer from 1 to 32
	.CLKFX_MULTIPLY(clk_multiply), // Can be any integer from 2 to 32
	.CLKIN_DIVIDE_BY_2("FALSE"), // TRUE/FALSE to enable CLKIN divide by two feature
	.CLKIN_PERIOD(),             // Specify period of input clock
	.CLKOUT_PHASE_SHIFT("NONE"), // Specify phase shift of NONE, FIXED or VARIABLE
	.CLK_FEEDBACK("NONE"),       // Specify clock feedback of NONE, 1X or 2X
	.DESKEW_ADJUST("SOURCE_SYNCHRONOUS"), // SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or
                                 //   an integer from 0 to 15
	.DFS_FREQUENCY_MODE("LOW"),  // HIGH or LOW frequency mode for frequency synthesis
	.DLL_FREQUENCY_MODE("LOW"),  // HIGH or LOW frequency mode for DLL
	.DUTY_CYCLE_CORRECTION("TRUE"), // Duty cycle correction, TRUE or FALSE
	.FACTORY_JF(16'hC080),       // FACTORY JF values
	.PHASE_SHIFT(0),             // Amount of fixed phase shift from -255 to 255
	.STARTUP_WAIT("FALSE")       // Delay configuration DONE until DCM LOCK, TRUE/FALSE
) dcm_fx (
	.DSSEN(),
	.CLK0(),                   // 0 degree DCM CLK output
	.CLK180(),                 // 180 degree DCM CLK output
	.CLK270(),                 // 270 degree DCM CLK output
	.CLK2X(),                  // 2X DCM CLK output
	.CLK2X180(),               // 2X, 180 degree DCM CLK out
	.CLK90(),                  // 90 degree DCM CLK output
	.CLKDV(),                  // Divided DCM CLK out (CLKDV_DIVIDE)
	.CLKFX(    read_clk_u ),   // DCM CLK synthesis out (M/D)
	.CLKFX180(),               // 180 degree CLK synthesis out
	.LOCKED(   dcm_fx_locked), // DCM LOCK status output
	.PSDONE(),                 // Dynamic phase adjust done output
	.STATUS(),                 // 8-bit DCM status bits output
	.CLKFB(),                  // DCM clock feedback
	.CLKIN(    clk   ),        // Clock input (from IBUFG, BUFG or DCM)
	.PSCLK(    gnd   ),        // Dynamic phase adjust clock input
	.PSEN(     gnd   ),        // Dynamic phase adjust enable input
	.PSINCDEC( gnd   ),        // Dynamic phase adjust increment/decrement
	.RST(      reset )         // DCM asynchronous reset input
);

//----------------------------------------------------------------------------
// BUFG read clock
//----------------------------------------------------------------------------
BUFG bufg_fx_clk (
	.O(read_clk),             // Clock buffer output
	.I(read_clk_u)            // Clock buffer input
);

//----------------------------------------------------------------------------
// Phase shifted clock for write path 
//----------------------------------------------------------------------------
wire  phase_dcm_reset;
wire  phase_dcm_locked;
wire  write_clk_u, write_clk90_u, write_clk180_u, write_clk270_u;
reg   psen, psincdec; 
wire  psdone;

DCM #(
	.CLKDV_DIVIDE(2.0),     // Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
                            //   7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
	.CLKFX_DIVIDE(2),       // Can be any integer from 1 to 32
	.CLKFX_MULTIPLY(2),     // Can be any integer from 2 to 32
	.CLKIN_DIVIDE_BY_2("FALSE"), // TRUE/FALSE to enable CLKIN divide by two feature
	.CLKIN_PERIOD(),        // Specify period of input clock
	.CLK_FEEDBACK("1X"),    // Specify clock feedback of NONE, 1X or 2X
	.DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"), // SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or
                                          //   an integer from 0 to 15
	.DFS_FREQUENCY_MODE("LOW"),  // HIGH or LOW frequency mode for frequency synthesis
	.DLL_FREQUENCY_MODE("LOW"),  // HIGH or LOW frequency mode for DLL
	.DUTY_CYCLE_CORRECTION("TRUE"), // Duty cycle correction, TRUE or FALSE
	.FACTORY_JF(16'hC080),   // FACTORY JF values
	.CLKOUT_PHASE_SHIFT("VARIABLE"), // Specify phase shift of NONE, FIXED or VARIABLE
	.PHASE_SHIFT( phase_shift ), // Amount of fixed phase shift from -255 to 255
	.STARTUP_WAIT("FALSE")   // Delay configuration DONE until DCM LOCK, TRUE/FALSE
) dcm_phase (
	.DSSEN(),
	.CLK0(   write_clk_u ),      // 0 degree DCM CLK output
	.CLK90(  write_clk90_u ),    // 90 degree DCM CLK output
	.CLK180( write_clk180_u ),   // 180 degree DCM CLK output
	.CLK270( write_clk270_u ),   // 270 degree DCM CLK output
	.CLK2X(),                    // 2X DCM CLK output
	.CLK2X180(),                 // 2X, 180 degree DCM CLK out
	.CLKDV(),                    // Divided DCM CLK out (CLKDV_DIVIDE)
	.CLKFX(),                    // DCM CLK synthesis out (M/D)
	.CLKFX180(),                 // 180 degree CLK synthesis out
	.LOCKED( phase_dcm_locked ), // DCM LOCK status output
	.STATUS(),                   // 8-bit DCM status bits output
	.CLKFB( write_clk ),         // DCM clock feedback
	.CLKIN( read_clk ),          // Clock input (from IBUFG, BUFG or DCM)
	.PSCLK( clk ),               // Dynamic phase adjust clock input
	.PSEN( psen ),               // Dynamic phase adjust enable input
	.PSINCDEC( psincdec ),       // Dynamic phase adjust increment/decrement
	.PSDONE( psdone ),           // Dynamic phase adjust done output
	.RST( phase_dcm_reset )      // DCM asynchronous reset input
);

// delayed reset for phase shifting DCM
reg [3:0] reset_counter;
assign phase_dcm_reset = reset | (reset_counter != 0);

always @(posedge clk)
begin
	if (reset) 
		reset_counter <= 1;
	else begin
		if (dcm_fx_locked & (reset_counter != 0))
			reset_counter <= reset_counter + 1;
	end
end

//----------------------------------------------------------------------------
// DCM phase shifting state machine
//----------------------------------------------------------------------------
parameter s_init     = 0;
parameter s_idle     = 1;
parameter s_waitdone = 2;
parameter s_waitdone2= 3;

reg [1:0] state;

always @(posedge clk)
begin
	if (reset) begin
		state     <= s_init;
		psen      <= 0;
		ps_ready  <= 0;
	end else begin
		case (state)
		s_init: begin
			if (phase_dcm_locked) begin
				ps_ready  <= 1;
				state     <= s_idle;
			end
		end
		s_idle: begin
			if (ps_up) begin
				ps_ready  <= 0;
				psen      <= 1;
				psincdec  <= 1;
				state     <= s_waitdone;
			end else if (ps_down) begin
				ps_ready  <= 0;
				psen      <= 1;
				psincdec  <= 0;
				state     <= s_waitdone;
			end
		end
		s_waitdone: begin
			psen     <= 0;
			if (psdone) begin
				state     <= s_waitdone2;
			end
		end
		s_waitdone2: begin
			if (~ps_up && ~ps_down) begin
				ps_ready  <= 1;
				state     <= s_idle;
			end
		end
		endcase
	end
end

//----------------------------------------------------------------------------
// BUFG write clock
//----------------------------------------------------------------------------
BUFG bufg_write_clk (
	.O(write_clk  ),          // Clock buffer output
	.I(write_clk_u)           // Clock buffer input
);

BUFG bufg_write_clk90 (
	.O(write_clk90  ),        // Clock buffer output
	.I(write_clk90_u)         // Clock buffer input
);

//----------------------------------------------------------------------------
// LOCKED logic
//----------------------------------------------------------------------------
reg phase_dcm_locked_delayed;

always @(posedge write_clk)
begin
	phase_dcm_locked_delayed <= phase_dcm_locked;
end

assign locked = ~reset & phase_dcm_locked_delayed;


endmodule
