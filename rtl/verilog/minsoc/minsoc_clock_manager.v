
`include "minsoc_defines.v"

module minsoc_clock_manager(
	clk_i, 
	clk_o
);

// 
// Parameters 
// 
parameter    divisor = 5;

input clk_i;
output clk_o;
   
`ifdef NO_CLOCK_DIVISION
assign clk_o = clk_i;

`elsif GENERIC_CLOCK_DIVISION
reg [31:0] clock_divisor;
reg clk_int;
always @ (posedge clk_i)
begin
	clock_divisor <= clock_divisor + 1'b1;
	if ( clock_divisor >= divisor/2 - 1 ) begin
		clk_int <= ~clk_int;
		clock_divisor <= 32'h0000_0000;
	end
end
assign clk_o = clk_int;
`elsif FPGA_CLOCK_DIVISION

`ifdef ALTERA_FPGA
reg [31:0] clock_divisor;
reg clk_int;
always @ (posedge clk_i)
begin
	clock_divisor <= clock_divisor + 1'b1;
	if ( clock_divisor >= divisor/2 - 1 ) begin
		clk_int <= ~clk_int;
		clock_divisor <= 32'h0000_0000;
	end
end
assign clk_o = clk_int;

`elsif XILINX_FPGA

`ifdef SPARTAN2
	`define MINSOC_DLL
`elsif VIRTEX
	`define MINSOC_DLL
`endif	// !SPARTAN2/VIRTEX

`ifdef SPARTAN3
	`define MINSOC_DCM
`elsif VIRTEX2
	`define MINSOC_DCM
`endif	// !SPARTAN3/VIRTEX2

`ifdef SPARTAN3E
	`define MINSOC_DCM_SP
`elsif SPARTAN3A
	`define MINSOC_DCM_SP
`endif	// !SPARTAN3E/SPARTAN3A

`ifdef VIRTEX4
	`define MINSOC_DCM_ADV
	`define MINSOC_DCM_COMPONENT "VIRTEX4"
`elsif VIRTEX5
	`define MINSOC_DCM_ADV
	`define MINSOC_DCM_COMPONENT "VIRTEX5"
`endif  // !VIRTEX4/VIRTEX5

wire CLKIN_IN;
wire CLKDV_OUT;

assign CLKIN_IN = clk_i;
assign clk_o = CLKDV_OUT;

wire CLKIN_IBUFG;
wire CLK0_BUF;
wire CLKFB_IN;
wire CLKDV_BUF;

IBUFG CLKIN_IBUFG_INST (
	.I(CLKIN_IN), 
        .O(CLKIN_IBUFG)
);

BUFG CLK0_BUFG_INST (
	.I(CLK0_BUF), 
        .O(CLKFB_IN)
);

BUFG CLKDV_BUFG_INST (
	.I(CLKDV_BUF), 
        .O(CLKDV_OUT)
);

`ifdef MINSOC_DLL

CLKDLL #(
	.CLKDV_DIVIDE(divisor),     		// Divide by: 1.5,2.0,2.5,3.0,4.0,5.0,8.0 or 16.0
	.DUTY_CYCLE_CORRECTION("TRUE"), 	// Duty cycle correction, TRUE or FALSE
	.FACTORY_JF(16'hC080), 			// FACTORY JF Values
	.STARTUP_WAIT("FALSE") 			// Delay config DONE until DLL LOCK, TRUE/FALSE
) CLKDLL_inst (
	.CLK0(CLK0_BUF),     			// 0 degree DLL CLK output
	.CLK180(), 				// 180 degree DLL CLK output
	.CLK270(), 				// 270 degree DLL CLK output
	.CLK2X(),   				// 2X DLL CLK output
	.CLK90(),   				// 90 degree DLL CLK output
	.CLKDV(CLKDV_BUF),   			// Divided DLL CLK out (CLKDV_DIVIDE)
	.LOCKED(), 				// DLL LOCK status output
	.CLKFB(CLKFB_IN),   			// DLL clock feedback
	.CLKIN(CLKIN_IBUFG),   			// Clock input (from IBUFG, BUFG or DLL)
	.RST(1'b0)        			// DLL asynchronous reset input
);

`elsif MINSOC_DCM

DCM #(
	.SIM_MODE("SAFE"), 			// Simulation: "SAFE" vs. "FAST", see "Synthesis and Simulation Design Guide" for details
	.CLKDV_DIVIDE(divisor), 		// Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
						//   7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
	.CLKFX_DIVIDE(1),   			// Can be any integer from 1 to 32
	.CLKFX_MULTIPLY(4), 			// Can be any integer from 2 to 32
	.CLKIN_DIVIDE_BY_2("FALSE"), 		// TRUE/FALSE to enable CLKIN divide by two feature
	.CLKIN_PERIOD(0.0), 			// Specify period of input clock
	.CLKOUT_PHASE_SHIFT("NONE"), 		// Specify phase shift of NONE, FIXED or VARIABLE
	.CLK_FEEDBACK("1X"), 			// Specify clock feedback of NONE, 1X or 2X
	.DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"), 	// SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or
						//   an integer from 0 to 15
	.DFS_FREQUENCY_MODE("LOW"), 		// HIGH or LOW frequency mode for frequency synthesis
	.DLL_FREQUENCY_MODE("LOW"), 		// HIGH or LOW frequency mode for DLL
	.DUTY_CYCLE_CORRECTION("TRUE"), 	// Duty cycle correction, TRUE or FALSE
	.FACTORY_JF(16'hC080),   		// FACTORY JF values
	.PHASE_SHIFT(0),     			// Amount of fixed phase shift from -255 to 255
	.STARTUP_WAIT("FALSE")   		// Delay configuration DONE until DCM LOCK, TRUE/FALSE
) DCM_inst (
	.CLK0(CLK0_BUF),     			// 0 degree DCM CLK output
	.CLK180(), 				// 180 degree DCM CLK output
	.CLK270(), 				// 270 degree DCM CLK output
	.CLK2X(),   				// 2X DCM CLK output
	.CLK2X180(), 				// 2X, 180 degree DCM CLK out
	.CLK90(),   				// 90 degree DCM CLK output
	.CLKDV(CLKDV_BUF),   			// Divided DCM CLK out (CLKDV_DIVIDE)
	.CLKFX(),   				// DCM CLK synthesis out (M/D)
	.CLKFX180(), 				// 180 degree CLK synthesis out
	.LOCKED(), 				// DCM LOCK status output
	.PSDONE(), 				// Dynamic phase adjust done output
	.STATUS(), 				// 8-bit DCM status bits output
	.CLKFB(CLKFB_IN),   			// DCM clock feedback
	.CLKIN(CLKIN_IBUFG),   			// Clock input (from IBUFG, BUFG or DCM)
	.PSCLK(1'b0),  				// Dynamic phase adjust clock input
	.PSEN(1'b0),   				// Dynamic phase adjust enable input
	.PSINCDEC(1'b0), 			// Dynamic phase adjust increment/decrement
	.RST(1'b0)        			// DCM asynchronous reset input
);

`elsif MINSOC_DCM_SP

DCM_SP #(
	.CLKDV_DIVIDE(divisor), 		// Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
						//   7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
	.CLKFX_DIVIDE(1),    			// Can be any integer from 1 to 32
	.CLKFX_MULTIPLY(4), 			// Can be any integer from 2 to 32
	.CLKIN_DIVIDE_BY_2("FALSE"), 		// TRUE/FALSE to enable CLKIN divide by two feature
	.CLKIN_PERIOD(0.0), 			// Specify period of input clock
	.CLKOUT_PHASE_SHIFT("NONE"), 		// Specify phase shift of NONE, FIXED or VARIABLE
	.CLK_FEEDBACK("1X"), 			// Specify clock feedback of NONE, 1X or 2X
	.DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"), 	// SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or
						//   an integer from 0 to 15
	.DLL_FREQUENCY_MODE("LOW"), 		// HIGH or LOW frequency mode for DLL
	.DUTY_CYCLE_CORRECTION("TRUE"), 	// Duty cycle correction, TRUE or FALSE
	.PHASE_SHIFT(0),      			// Amount of fixed phase shift from -255 to 255
	.STARTUP_WAIT("FALSE")    		// Delay configuration DONE until DCM LOCK, TRUE/FALSE
) DCM_SP_inst (
	.CLK0(CLK0_BUF),     			// 0 degree DCM CLK output
	.CLK180(), 				// 180 degree DCM CLK output
	.CLK270(), 				// 270 degree DCM CLK output
	.CLK2X(),   				// 2X DCM CLK output
	.CLK2X180(), 				// 2X, 180 degree DCM CLK out
	.CLK90(),   				// 90 degree DCM CLK output
	.CLKDV(CLKDV_BUF),   			// Divided DCM CLK out (CLKDV_DIVIDE)
	.CLKFX(),    				// DCM CLK synthesis out (M/D)
	.CLKFX180(), 				// 180 degree CLK synthesis out
	.LOCKED(), 				// DCM LOCK status output
	.PSDONE(), 				// Dynamic phase adjust done output
	.STATUS(), 				// 8-bit DCM status bits output
	.CLKFB(CLKFB_IN),    			// DCM clock feedback
	.CLKIN(CLKIN_IBUFG),    		// Clock input (from IBUFG, BUFG or DCM)
	.PSCLK(1'b0),   			// Dynamic phase adjust clock input
	.PSEN(1'b0),      			// Dynamic phase adjust enable input
	.PSINCDEC(1'b0), 			// Dynamic phase adjust increment/decrement
	.RST(1'b0)         			// DCM asynchronous reset input
);

`elsif MINSOC_DCM_ADV

DCM_ADV #(
	.CLKDV_DIVIDE(divisor), 		// Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
						//   7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
	.CLKFX_DIVIDE(1),   			// Can be any integer from 1 to 32
	.CLKFX_MULTIPLY(4), 			// Can be any integer from 2 to 32
	.CLKIN_DIVIDE_BY_2("FALSE"), 		// TRUE/FALSE to enable CLKIN divide by two feature
	.CLKIN_PERIOD(10.0), 			// Specify period of input clock in ns from 1.25 to 1000.00
	.CLKOUT_PHASE_SHIFT("NONE"), 		// Specify phase shift mode of NONE, FIXED,
						// VARIABLE_POSITIVE, VARIABLE_CENTER or DIRECT
	.CLK_FEEDBACK("1X"), 			// Specify clock feedback of NONE, 1X or 2X
	.DCM_AUTOCALIBRATION("TRUE"), 		// DCM calibration circuitry "TRUE"/"FALSE"
	.DCM_PERFORMANCE_MODE("MAX_SPEED"), 	// Can be MAX_SPEED or MAX_RANGE
	.DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"), 	// SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or
						//   an integer from 0 to 15
	.DFS_FREQUENCY_MODE("LOW"), 		// HIGH or LOW frequency mode for frequency synthesis
	.DLL_FREQUENCY_MODE("LOW"), 		// LOW, HIGH, or HIGH_SER frequency mode for DLL
	.DUTY_CYCLE_CORRECTION("TRUE"), 	// Duty cycle correction, "TRUE"/"FALSE"
	.FACTORY_JF(16'hf0f0), 			// FACTORY JF value suggested to be set to 16’hf0f0
	.PHASE_SHIFT(0), 			// Amount of fixed phase shift from -255 to 1023
	.SIM_DEVICE(`MINSOC_DCM_COMPONENT), 	// Set target device, "VIRTEX4" or "VIRTEX5"
	.STARTUP_WAIT("FALSE") 			// Delay configuration DONE until DCM LOCK, "TRUE"/"FALSE"
) DCM_ADV_inst (
	.CLK0(CLK0_BUF),         		// 0 degree DCM CLK output
	.CLK180(),     				// 180 degree DCM CLK output
	.CLK270(),     				// 270 degree DCM CLK output
	.CLK2X(),       			// 2X DCM CLK output
	.CLK2X180(), 				// 2X, 180 degree DCM CLK out
	.CLK90(),       			// 90 degree DCM CLK output
	.CLKDV(CLKDV_BUF),       		// Divided DCM CLK out (CLKDV_DIVIDE)
	.CLKFX(),       			// DCM CLK synthesis out (M/D)
	.CLKFX180(), 				// 180 degree CLK synthesis out
	.DO(),             			// 16-bit data output for Dynamic Reconfiguration Port (DRP)
	.DRDY(),         			// Ready output signal from the DRP
	.LOCKED(),     				// DCM LOCK status output
	.PSDONE(),     				// Dynamic phase adjust done output
	.CLKFB(CLKFB_IN),       		// DCM clock feedback
	.CLKIN(CLKIN_IBUFG),       		// Clock input (from IBUFG, BUFG or DCM)
	.DADDR(7'h00),       			// 7-bit address for the DRP
	.DCLK(1'b0),         			// Clock for the DRP
	.DEN(1'b0),           			// Enable input for the DRP
	.DI(16'h0000),         			// 16-bit data input for the DRP
	.DWE(1'b0),           			// Active high allows for writing configuration memory
	.PSCLK(1'b0),       			// Dynamic phase adjust clock input
	.PSEN(1'b0),         			// Dynamic phase adjust enable input
	.PSINCDEC(1'b0), 			// Dynamic phase adjust increment/decrement
	.RST(1'b0)            			// DCM asynchronous reset input
);

`endif	// !MINSOC_DLL/MINSOC_DCM/MINSOC_DCM_SP/MINSOC_DCM_ADV
`endif	// !ALTERA_FPGA/XILINX_FPGA
`endif	// !NO_CLOCK_DIVISION/GENERIC_CLOCK_DIVISION/FPGA_CLOCK_DIVISION


endmodule
