//=============================================================================
//	2005-2010 Robert T Fingh
//	robfinch@FPGAfield.ca
//
//	rtf68kSysClkgen.v
//
//
//	This source code is available only for viewing, testing and evaluation
//	purposes. Any commercial use requires a license. This copyright
//	statement and disclaimer must remain present in the file.
//
//
//	NO WARRANTY.
//  THIS Work, IS PROVIDEDED "AS IS" WITH NO WARRANTIES OF ANY KIND, WHETHER
//	EXPRESS OR IMPLIED. The user must assume the entire risk of using the
//	Work.
//
//	IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY
//  INCIDENTAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES WHATSOEVER RELATING TO
//  THE USE OF THIS WORK, OR YOUR RELATIONSHIP WITH THE AUTHOR.
//
//	IN ADDITION, IN NO EVENT DOES THE AUTHOR AUTHORIZE YOU TO USE THE WORK
//	IN APPLICATIONS OR SYSTEMS WHERE THE WORK'S FAILURE TO PERFORM CAN
//	REASONABLY BE EXPECTED TO RESULT IN A SIGNIFICANT PHYSICAL INJURY, OR IN
//	LOSS OF LIFE. ANY SUCH USE BY YOU IS ENTIRELY AT YOUR OWN RISK, AND YOU
//	AGREE TO HOLD THE AUTHOR AND CONTRIBUTORS HARMLESS FROM ANY CLAIMS OR
//	LOSSES RELATING TO SUCH UNAUTHORIZED USE.
//
//
//	System clock generator. Generates clock enables for various parts of the
//	system.
//
//=============================================================================

module rtf68kSysClkgen(xreset, xclk, rst, clk50, clk25, vclk, vclk5, pulse1000Hz);
input xreset;		// external reset
input xclk;			// external clock source (50 MHz)
output rst;
output clk50;		// cpu (system clock - eg. 50.000 MHz)
output clk25;
output vclk;		// video clock 
output vclk5;		// 5x vidoe clock
output pulse1000Hz;	// 1000 Hz pulse

wire gnd;
wire clk39u;
wire clk39ub;
wire clk100u;
wire clkfb;
wire clk2x;
wire clk50u;		// unbuffered 60MHz
wire clk73u;		// unbuffered 73MHz
wire clkvu;
wire locked0;
wire clk25u;
wire clk147u;
wire clk367u;

assign gnd = 1'b0;

BUFG bg0 (.I(clk50u), 	.O(clk50) );
BUFG bg1 (.I(clk73u), 	.O(vclk) );
BUFG bg2 (.I(clk25u), 	.O(clk25) );
BUFG bg3 (.I(clk367u),  .O(vclk5) );

// Reset:
//
// Hold the reset line active for a few thousand clock cycles
// to allow the clock generator and other devices to stabilize.

reg [14:0] rst_ctr;
assign rst = xreset | !locked0;// | !rst_ctr[14];

always @(posedge xclk)
	if (xreset)
		rst_ctr <= 0;
	else if (!rst_ctr[14])
		rst_ctr <= rst_ctr + 1;


// 1000Hz pulse generator
reg [15:0] cnt;
assign pulse1000Hz = cnt==16'd25000;

always @(posedge clk25)
	if (rst)
		cnt <= 16'd1;
	else begin
		if (pulse1000Hz)
			cnt <= 16'd1;
		else
			cnt <= cnt + 16'd1;
	end


// connect rst to global network
//STARTUP_SPARTAN3 su0(.GSR(rst));

// Generate 73.529 MHz source from 100 MHz
DCM dcm0(
	.RST(xreset),
	.PSCLK(gnd),
	.PSEN(gnd),
	.PSINCDEC(gnd),
	.DSSEN(gnd),
	.CLKIN(xclk),
	.CLKFB(clk100u),	// 100.000 MHz
	.CLKDV(clk25u),
	.CLKFX(clk73u),		// 73.728 MHz unbuffered
	.CLKFX180(),
	.CLK0(clk50u),
	.CLK2X(clk100u),	// 100.000 MHz
	.CLK2X180(),
	.CLK90(),
	.CLK180(),
	.CLK270(),
	.LOCKED(locked0),
	.PSDONE(),
	.STATUS()
);
defparam dcm0.CLK_FEEDBACK = "2x";
defparam dcm0.CLKDV_DIVIDE = 3.0;
defparam dcm0.CLKFX_DIVIDE = 17;	// (25/17)*50 = 73.529 MHz
defparam dcm0.CLKFX_MULTIPLY = 25;
defparam dcm0.CLKIN_DIVIDE_BY_2 = "FALSE";
defparam dcm0.CLKIN_PERIOD = 20.000;
defparam dcm0.CLKOUT_PHASE_SHIFT = "NONE";
defparam dcm0.DESKEW_ADJUST = "SYSTEM_SYNCHRONOUS";
defparam dcm0.DFS_FREQUENCY_MODE = "LOW";
defparam dcm0.DLL_FREQUENCY_MODE = "LOW";
defparam dcm0.DUTY_CYCLE_CORRECTION = "FALSE";
//	defparam dcm0.FACTORY_JF = 16'h8080;
defparam dcm0.PHASE_SHIFT = 0;
defparam dcm0.STARTUP_WAIT = "FALSE";

wire clkfb1;

DCM dcm1(
	.RST(xreset),
	.PSCLK(gnd),
	.PSEN(gnd),
	.PSINCDEC(gnd),
	.DSSEN(gnd),
	.CLKIN(vclk),
	.CLKFB(clkfb1),		// 73.529 MHz
	.CLKDV(),
	.CLKFX(clk367u),		// 367.645 MHz unbuffered
	.CLKFX180(),
	.CLK0(),
	.CLK2X(clkfb1),	// 100.000 MHz
	.CLK2X180(),
	.CLK90(),
	.CLK180(),
	.CLK270(),
	.LOCKED(),
	.PSDONE(),
	.STATUS()
);
defparam dcm1.CLK_FEEDBACK = "2x";
defparam dcm1.CLKDV_DIVIDE = 2.0;
defparam dcm1.CLKFX_DIVIDE = 2;	// (10/2)*73.529 = 367.645 MHz
defparam dcm1.CLKFX_MULTIPLY = 10;
defparam dcm1.CLKIN_DIVIDE_BY_2 = "FALSE";
defparam dcm1.CLKIN_PERIOD = 13.600;
defparam dcm1.CLKOUT_PHASE_SHIFT = "NONE";
defparam dcm1.DESKEW_ADJUST = "SYSTEM_SYNCHRONOUS";
defparam dcm1.DFS_FREQUENCY_MODE = "LOW";
defparam dcm1.DLL_FREQUENCY_MODE = "LOW";
defparam dcm1.DUTY_CYCLE_CORRECTION = "FALSE";
//	defparam dcm0.FACTORY_JF = 16'h8080;
defparam dcm1.PHASE_SHIFT = 0;
defparam dcm1.STARTUP_WAIT = "FALSE";

endmodule
