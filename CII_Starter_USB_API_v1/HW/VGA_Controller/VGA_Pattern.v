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

module	VGA_Pattern	(	//	Read Out Side
						oRed,
						oGreen,
						oBlue,
						iVGA_X,
						iVGA_Y,
						iVGA_CLK,
						//	Control Signals
						iRST_N	);
//	Read Out Side
output	reg	[9:0]	oRed;
output	reg	[9:0]	oGreen;
output	reg	[9:0]	oBlue;
input	[9:0]		iVGA_X;
input	[9:0]		iVGA_Y;
input				iVGA_CLK;
//	Control Signals
input				iRST_N;

always@(posedge iVGA_CLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		oRed	<=	0;
		oGreen	<=	0;
		oBlue	<=	0;
	end
	else
	begin
		oRed	<=	(iVGA_Y<120)					?			256	:
					(iVGA_Y>=120 && iVGA_Y<240)		?			512	:
					(iVGA_Y>=240 && iVGA_Y<360)		?			768	:
																1023;
		oGreen	<=	(iVGA_X<80)						?			128	:
					(iVGA_X>=80 && iVGA_X<160)		?			256	:
					(iVGA_X>=160 && iVGA_X<240)		?			384	:
					(iVGA_X>=240 && iVGA_X<320)		?			512	:
					(iVGA_X>=320 && iVGA_X<400)		?			640	:
					(iVGA_X>=400 && iVGA_X<480)		?			768	:
					(iVGA_X>=480 && iVGA_X<560)		?			896	:
																1023;
		oBlue	<=	(iVGA_Y<60)						?			1023:
					(iVGA_Y>=60 && iVGA_Y<120)		?			896	:
					(iVGA_Y>=120 && iVGA_Y<180)		?			768	:
					(iVGA_Y>=180 && iVGA_Y<240)		?			640	:
					(iVGA_Y>=240 && iVGA_Y<300)		?			512	:
					(iVGA_Y>=300 && iVGA_Y<360)		?			384	:
					(iVGA_Y>=360 && iVGA_Y<420)		?			256	:
																128	;
	end
end

endmodule