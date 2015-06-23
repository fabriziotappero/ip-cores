`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   22:19:47 03/18/2012
// Design Name:   system
// Module Name:   D:/work/xilinx/ddr_186/ddr_186/test.v
// Project Name:  ddr_186
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: system
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test;

	// Inputs
	reg cntrl0_rst_dqs_div_in;
	reg sys_clk_in;
	reg CLK_50MHZ;
	reg BTN_SOUTH;
	reg RS232_DCE_RXD;

	// Outputs
	wire [12:0] cntrl0_ddr2_a;
	wire [1:0] cntrl0_ddr2_ba;
	wire cntrl0_ddr2_cke;
	wire cntrl0_ddr2_cs_n;
	wire cntrl0_ddr2_ras_n;
	wire cntrl0_ddr2_cas_n;
	wire cntrl0_ddr2_we_n;
	wire cntrl0_ddr2_odt;
	wire [1:0] cntrl0_ddr2_dm;
	wire cntrl0_ddr2_ck;
	wire cntrl0_ddr2_ck_n;
	wire cntrl0_rst_dqs_div_out;
	wire [3:0] VGA_R;
	wire [3:0] VGA_G;
	wire [3:0] VGA_B;
	wire VGA_HSYNC;
	wire VGA_VSYNC;
	wire [7:0] LED;
	wire FPGA_AWAKE;
	wire RS232_DCE_TXD;
	wire [47:0]CPU_INSTR;

	// Bidirs
	wire [15:0] cntrl0_ddr2_dq;
	wire [1:0] cntrl0_ddr2_dqs;
	wire [1:0] cntrl0_ddr2_dqs_n;

	// Instantiate the Unit Under Test (UUT)
	system uut (
		.cntrl0_ddr2_dq(cntrl0_ddr2_dq), 
		.cntrl0_ddr2_a(cntrl0_ddr2_a), 
		.cntrl0_ddr2_ba(cntrl0_ddr2_ba), 
		.cntrl0_ddr2_cke(cntrl0_ddr2_cke), 
		.cntrl0_ddr2_cs_n(cntrl0_ddr2_cs_n), 
		.cntrl0_ddr2_ras_n(cntrl0_ddr2_ras_n), 
		.cntrl0_ddr2_cas_n(cntrl0_ddr2_cas_n), 
		.cntrl0_ddr2_we_n(cntrl0_ddr2_we_n), 
		.cntrl0_ddr2_odt(cntrl0_ddr2_odt), 
		.cntrl0_ddr2_dm(cntrl0_ddr2_dm), 
		.cntrl0_ddr2_dqs(cntrl0_ddr2_dqs), 
		.cntrl0_ddr2_dqs_n(cntrl0_ddr2_dqs_n), 
		.cntrl0_ddr2_ck(cntrl0_ddr2_ck), 
		.cntrl0_ddr2_ck_n(cntrl0_ddr2_ck_n), 
		.cntrl0_rst_dqs_div_in(cntrl0_rst_dqs_div_in), 
		.cntrl0_rst_dqs_div_out(cntrl0_rst_dqs_div_out), 
		.sys_clk_in(sys_clk_in), 
		.CLK_50MHZ(CLK_50MHZ), 
		.VGA_R(VGA_R), 
		.VGA_G(VGA_G), 
		.VGA_B(VGA_B), 
		.VGA_HSYNC(VGA_HSYNC), 
		.VGA_VSYNC(VGA_VSYNC), 
		.BTN_SOUTH(BTN_SOUTH), 
		.LED(LED), 
		.FPGA_AWAKE(FPGA_AWAKE), 
		.RS232_DCE_RXD(RS232_DCE_RXD), 
		.RS232_DCE_TXD(RS232_DCE_TXD),
		.CPU_INSTR(CPU_INSTR),
		.CE(CE),
		.CPU_CE(CPU_CE) 
	);

	initial begin
		// Initialize Inputs
		cntrl0_rst_dqs_div_in = 0;
		sys_clk_in = 0;
		CLK_50MHZ = 0;
		BTN_SOUTH = 1;
		RS232_DCE_RXD = 0;

		// Wait 100 ns for global reset to finish
		#300;
        
		// Add stimulus here
		BTN_SOUTH = 0;
	end
	
	always begin
		#3.76	sys_clk_in = 1;
		#3.76	sys_clk_in = 0;
	end

	always begin
		#10	CLK_50MHZ = 1;
		#10	CLK_50MHZ = 0;
	end
      
endmodule

