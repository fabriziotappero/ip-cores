`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UPT
// Engineer: Oana Boncalo & Alexandru Amaricai
// 
// Create Date:    10:23:39 11/26/2012 
// Design Name: 
// Module Name:    clkGenPLL 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
//parameter CLK_PERIOD_EXT        = 10000;   // External (FPGA board) clk period (in ps)
//localparam real CLK_PERIOD_EXT_NS   = CLK_PERIOD_EXT / 1000.0;
module clkGenPLL(
	input sysClk,
	input sysRst,  //Asynchronous PLL reset
	output clk0_125, //125 Mhz
	output clk0Phase90, //125 MHz clk200 with 90 degree phase
	output clk0Div2, //62.5 MHz
	output clk200,   //200 MHz clk
	output clkTFT10, 
	output clkTFT10_180,
	output locked
    );


//  PLL_BASE   : In order to incorporate this function into the design,
//   Verilog   : the following instance declaration needs to be placed
//  instance   : in the body of the design code.  The instance name
// declaration : (PLL_BASE_inst) and/or the port declarations within the
//    code     : parenthesis may be changed to properly reference and
//             : connect this function to the design.  Unused inputs
//             : and outputs may be removed or commented out.

//  <-----Cut code below this line---->

   // PLL_BASE: Phase-Lock Loop Clock Circuit 
   //           Virtex-5
   // Xilinx HDL Language Template, version 13.1
   wire CLKFBOUT;
	
   PLL_BASE #(
      .BANDWIDTH("OPTIMIZED"),  // "HIGH", "LOW" or "OPTIMIZED" 
      .CLKFBOUT_MULT(10),        // Multiplication factor for all output clocks
      .CLKFBOUT_PHASE(0.0),     // Phase shift (degrees) of all output clocks
      .CLKIN_PERIOD(10.0),     // Clock period (ns) of input clock on CLKIN
      .CLKOUT0_DIVIDE(8),       // Division factor for CLKOUT0 (1 to 128)
      .CLKOUT0_DUTY_CYCLE(0.5), // Duty cycle for CLKOUT0 (0.01 to 0.99)
      .CLKOUT0_PHASE(0.0),      // Phase shift (degrees) for CLKOUT0 (0.0 to 360.0)
      .CLKOUT1_DIVIDE(8),       // Division factor for CLKOUT1 (1 to 128)
      .CLKOUT1_DUTY_CYCLE(0.5), // Duty cycle for CLKOUT1 (0.01 to 0.99)
      .CLKOUT1_PHASE(90.0),      // Phase shift (degrees) for CLKOUT1 (0.0 to 360.0)
      .CLKOUT2_DIVIDE(16),       // Division factor for CLKOUT2 (1 to 128)
      .CLKOUT2_DUTY_CYCLE(0.5), // Duty cycle for CLKOUT2 (0.01 to 0.99)
      .CLKOUT2_PHASE(0.0),      // Phase shift (degrees) for CLKOUT2 (0.0 to 360.0)
      .CLKOUT3_DIVIDE(5),       // Division factor for CLKOUT3 (1 to 128)
      .CLKOUT3_DUTY_CYCLE(0.5), // Duty cycle for CLKOUT3 (0.01 to 0.99)
      .CLKOUT3_PHASE(0.0),      // Phase shift (degrees) for CLKOUT3 (0.0 to 360.0)
      .CLKOUT4_DIVIDE(100),       // Division factor for CLKOUT4 (1 to 128)
      .CLKOUT4_DUTY_CYCLE(0.5), // Duty cycle for CLKOUT4 (0.01 to 0.99)
      .CLKOUT4_PHASE(180.0),      // Phase shift (degrees) for CLKOUT4 (0.0 to 360.0)
      .CLKOUT5_DIVIDE(100),       // Division factor for CLKOUT5 (1 to 128)
      .CLKOUT5_DUTY_CYCLE(0.5), // Duty cycle for CLKOUT5 (0.01 to 0.99)
      .CLKOUT5_PHASE(0.0),      // Phase shift (degrees) for CLKOUT5 (0.0 to 360.0)
      .COMPENSATION("SYSTEM_SYNCHRONOUS"), // "SYSTEM_SYNCHRONOUS", 
                                //   "SOURCE_SYNCHRONOUS", "INTERNAL", "EXTERNAL", 
                                //   "DCM2PLL", "PLL2DCM" 
      .DIVCLK_DIVIDE(1),        // Division factor for all clocks (1 to 52)
      .REF_JITTER(0.100)        // Input reference jitter (0.000 to 0.999 UI%)
   ) PLL_BASE_inst (
      .CLKFBOUT(CLKFBOUT),      // General output feedback signal
      .CLKOUT0(clk0_125),        // One of six general clock output signals
      .CLKOUT1(clk0Phase90),        // One of six general clock output signals
      .CLKOUT2(clk0Div2),        // One of six general clock output signals
      .CLKOUT3(clk200),        // One of six general clock output signals
      .CLKOUT4(clkTFT10_180),        // One of six general clock output signals
      .CLKOUT5(clkTFT10),        // One of six general clock output signals
      .LOCKED(locked),          // Active high PLL lock signal
      .CLKFBIN(CLKFBOUT),        // Clock feedback input
      .CLKIN(sysClk),            // Clock input
      .RST(sysRst)                 // Asynchronous PLL reset
   );

   // End of PLL_BASE_inst instantiation
					

endmodule
