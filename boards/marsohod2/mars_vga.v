

module MARS_VGA(
	CLK100MHZ,
	FTDI_BD0,
	FTDI_BD2,
	FTDI_BD3,
	KEY0,
	KEY1,
	DATA0,
	ADC_D,
	VGA_HSYNC,
	VGA_VSYNC,
	SDRAM_LDQM,
	SDRAM_UDQM,
	SDRAM_CLK,
	SDRAM_RAS,
	SDRAM_CAS,
	SDRAM_WE,
	ADC_CLK,
	FTDI_BD1,
	SDRAM_BA0,
	SDRAM_BA1,
	DCLK,
	NCSO,
	ASDO,
	IO,
	LED,
	SDRAM_A,
	SDRAM_DQ,
	VGA_BLUE,
	VGA_GREEN,
	VGA_RED
);


input wire	CLK100MHZ;
input wire	FTDI_BD0;
input wire	FTDI_BD2;
input wire	FTDI_BD3;
input wire	KEY0;
input wire	KEY1;
input wire	DATA0;
input wire	[7:0] ADC_D;
output wire	VGA_HSYNC;
output wire	VGA_VSYNC;
output wire	SDRAM_LDQM;
output wire	SDRAM_UDQM;
output wire	SDRAM_CLK;
output wire	SDRAM_RAS;
output wire	SDRAM_CAS;
output wire	SDRAM_WE;
output wire	ADC_CLK;
output wire	FTDI_BD1;
output wire	SDRAM_BA0;
output wire	SDRAM_BA1;
output wire	DCLK;
output wire	NCSO;
output wire	ASDO;
output wire	[15:0] IO;
output wire	[3:0] LED;
output wire	[11:0] SDRAM_A;
inout wire	[15:0] SDRAM_DQ;
output wire	[4:0] VGA_BLUE;
output wire	[5:0] VGA_GREEN;
output wire	[4:0] VGA_RED;

wire	[31:0] q;
wire	serial_RX;
wire	serial_TX;

assign			LED			=	4'h0;

wire			VGA_CTRL_CLK;
wire	[11:0]	mVGA_X;
wire	[11:0]	mVGA_Y;
wire	[9:0]	mVGA_R;
wire	[9:0]	mVGA_G;
wire	[9:0]	mVGA_B;

wire	[9:0]	sVGA_R;
wire	[9:0]	sVGA_G;
wire	[9:0]	sVGA_B;
assign	VGA_RED	=	sVGA_R[7:3];
assign	VGA_GREEN=	sVGA_G[7:2];
assign	VGA_BLUE	=	sVGA_B[7:3];

//=======================================================
//  Structural coding
//=======================================================

////////////////////////	VGA			////////////////////////////


VGA_CLK		u1_1240x1024
		(	.inclk0(CLK100MHZ),
			.c0(VGA_CTRL_CLK)
		);
		defparam u1_1240x1024.PLL_MUL= 27;
		defparam u1_1240x1024.PLL_DIV= 25;


VGA_Ctrl	u2_1240x1024
		(	//	Host Side
			.oCurrent_X(mVGA_X),
			.oCurrent_Y(mVGA_Y),
			.iRed(mVGA_R),
			.iGreen(mVGA_G),
			.iBlue(mVGA_B),
			//	VGA Side
			.oVGA_R(sVGA_R),
			.oVGA_G(sVGA_G),
			.oVGA_B(sVGA_B),
			.oVGA_HS(VGA_HSYNC),
			.oVGA_VS(VGA_VSYNC),
			.oVGA_SYNC(),
			.oVGA_BLANK(),
			.oVGA_CLOCK(),
			//	Control Signal
			.iCLK(VGA_CTRL_CLK),
			.iRST_N( KEY0 ),
			.les_btn(0)
		);
		defparam	u2_1240x1024.H_FRONT	=	48;
		defparam	u2_1240x1024.H_SYNC	=	112;
		defparam	u2_1240x1024.H_BACK	=	248;
		defparam	u2_1240x1024.H_ACT	=	1280;
		defparam	u2_1240x1024.V_FRONT	=	1;
		defparam	u2_1240x1024.V_SYNC	=	3;
		defparam	u2_1240x1024.V_BACK	=	38;
		defparam	u2_1240x1024.V_ACT	=	1024;

wire [63:0] dbg_val;
		
VGA_Pattern	u3
		(	//	Read Out Side
			.oRed(mVGA_R),
			.oGreen(mVGA_G),
			.oBlue(mVGA_B),
			.iVGA_X(mVGA_X),
			.iVGA_Y(mVGA_Y),
			.iVGA_CLK(VGA_CTRL_CLK),
			//	Control Signals
			.iRST_n( KEY0 ),
			.iColor_SW( 0 ),
			.endFrame(VGA_VSYNC),
			.dbg_val(dbg_val)
		);
		
		
endmodule



//assign	SDRAM_LDQM = 0;
//assign	SDRAM_UDQM = 0;
//assign	SDRAM_CLK = 0;
//assign	SDRAM_RAS = 0;
//assign	SDRAM_CAS = 0;
//assign	SDRAM_WE = 0;
//assign	ADC_CLK = 0;
//assign	SDRAM_BA0 = 0;
//assign	SDRAM_BA1 = 0;
//assign	DCLK = 0;
//assign	NCSO = 0;
//assign	ASDO = 0;
//assign	IO = 16'b0000000000000000;
//assign	SDRAM_A = 12'b000000000000;
//assign	SDRAM_DQ = 16'b0000000000000000;
//
//
//
//
//
//hvsync	b2v_inst1(
//	.pixel_clock(SYNTHESIZED_WIRE_0),
//	.hsync(VGA_HSYNC),
//	.vsync(VGA_VSYNC),
//	.b(VGA_BLUE),
//	.g(VGA_GREEN),
//	.r(VGA_RED));
//	defparam	b2v_inst1.horz_addr_time = 1280;
//	defparam	b2v_inst1.horz_back_porch = 248;
//	defparam	b2v_inst1.horz_front_porch = 48;
//	defparam	b2v_inst1.horz_sync = 112;
//	defparam	b2v_inst1.vert_addr_time = 1024;
//	defparam	b2v_inst1.vert_back_porch = 38;
//	defparam	b2v_inst1.vert_front_porch = 1;
//	defparam	b2v_inst1.vert_sync = 3;
//
//
//
//
//lpm_counter_0	b2v_inst15(
//	.clock(CLK100MHZ),
//	.aclr(SYNTHESIZED_WIRE_1),
//	.cnt_en(KEY1),
//	.q(q));
//
//
//assign	serial_TX = serial_RX;
//
//
//
//
//
//altpll0	b2v_inst5(
//	.inclk0(CLK100MHZ),
//	.c0(SYNTHESIZED_WIRE_0));
//
//assign	SYNTHESIZED_WIRE_1 =  ~KEY0;
//
//assign	FTDI_BD1 = serial_TX;
//assign	serial_RX = FTDI_BD0;
//assign	LED[3:0] = q[25:22];
//
//endmodule
//
//module lpm_counter_0(clock,aclr,cnt_en,q);
///* synthesis black_box */
//
//input clock;
//input aclr;
//input cnt_en;
//output [31:0] q;
//
//endmodule
