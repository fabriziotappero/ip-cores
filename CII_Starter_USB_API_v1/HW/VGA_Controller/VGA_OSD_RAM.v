//Legal Notice: (C)2006 Altera Corporation. All rights reserved. Your
//use of Altera Corporation's design tools, logic functions and other
//software and tools, and its AMPP partner logic functions, and any
//output files any of the foregoing (including device programming or
//simulation files), and any associated documentation or information are
//expressly subject to the terms and conditions of the Altera Program
//License Subscription Agreement or other applicable license agreement,
//including, without limitation, that your use is for the sole purpose
//of programming logic devices manufactured by Altera and sold by Altera
//or its authorized distributors.  Please refer to the applicable
//agreement for further details.

module	VGA_OSD_RAM	(	//	Read Out Side
						oRed,
						oGreen,
						oBlue,
						iVGA_ADDR,
						iVGA_X,
						iVGA_Y,
						iVGA_CLK,
						//	Write In Side
						iWR_DATA,
						iWR_ADDR,
						iWR_EN,
						iWR_CLK,
						//	CLUT
						iON_R,
						iON_G,
						iON_B,
						iOFF_R,
						iOFF_G,
						iOFF_B,
						//	Control Signals
						iRST_N	);
//	Read Out Side
output	reg	[9:0]	oRed;
output	reg	[9:0]	oGreen;
output	reg	[9:0]	oBlue;
input	[18:0]		iVGA_ADDR;
input	[9:0]		iVGA_X;
input	[9:0]		iVGA_Y;
input				iVGA_CLK;
//	Write In Side
input	[18:0]		iWR_ADDR;
input				iWR_DATA;
input				iWR_EN;
input				iWR_CLK;
//	CLUT
input	[9:0]	iON_R;
input	[9:0]	iON_G;
input	[9:0]	iON_B;
input	[9:0]	iOFF_R;
input	[9:0]	iOFF_G;
input	[9:0]	iOFF_B;
//	Control Signals
input				iRST_N;
//	Internal Registers/Wires
reg		[2:0]		ADDR_d;
reg		[2:0]		ADDR_dd;
wire	[7:0]		ROM_DATA;
wire	[18:0]		mVGA_ADDR;

parameter	START_X	=	60;
parameter	START_Y	=	50;
parameter	END_X	=	640-60;
parameter	END_Y	=	480-30;

assign	mVGA_ADDR	=	iVGA_ADDR-(iVGA_Y*120)-521*50;

always@(posedge iVGA_CLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		oRed	<=	0;
		oGreen	<=	0;
		oBlue	<=	0;
		ADDR_d	<=	0;
		ADDR_dd	<=	0;
	end
	else
	begin
		ADDR_d	<=	mVGA_ADDR[2:0];
		ADDR_dd	<=	~ADDR_d;
		oRed	<=	~(iVGA_X>=START_X && iVGA_X<END_X && iVGA_Y>=START_Y && iVGA_Y<END_Y)	?	iOFF_R	:
					ROM_DATA[ADDR_dd]?	iON_R:iOFF_R;
		oGreen	<=	~(iVGA_X>=START_X && iVGA_X<END_X && iVGA_Y>=START_Y && iVGA_Y<END_Y)	?	iOFF_G	:
					ROM_DATA[ADDR_dd]?	iON_G:iOFF_G;
		oBlue	<=	~(iVGA_X>=START_X && iVGA_X<END_X && iVGA_Y>=START_Y && iVGA_Y<END_Y)	?	iOFF_B	:
					ROM_DATA[ADDR_dd]?	iON_B:iOFF_B;
	end
end

Img_RAM 	u0	(	//	Write In Side
					.data(iWR_DATA),
					.wren(iWR_EN),
					.wraddress({iWR_ADDR[18:3],~iWR_ADDR[2:0]}),
					.wrclock(iWR_CLK),
					//	Read Out Side
					.rdaddress(mVGA_ADDR[18:3]),
					.rdclock(iVGA_CLK),
					.q(ROM_DATA));

endmodule
