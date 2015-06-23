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

module Sdram_Multiplexer	(	//	Host Side
							oHS_DATA,iHS_DATA,iHS_ADDR,iHS_RD,iHS_WR,oHS_Done,
							//	Async Side 1
							oAS1_DATA,iAS1_DATA,iAS1_ADDR,iAS1_WR_n,
							//	Async Side 2
							oAS2_DATA,iAS2_DATA,iAS2_ADDR,iAS2_WR_n,
							//	Async Side 3
							oAS3_DATA,iAS3_DATA,iAS3_ADDR,iAS3_WR_n,
							//	SDRAM Side
							oSDR_DATA,iSDR_DATA,oSDR_ADDR,oSDR_RD,oSDR_WR,iSDR_Done,
							//	Control Signals
							iSelect,iCLK,iRST_n	);
//	Host Side
input	[21:0]	iHS_ADDR;
input	[15:0]	iHS_DATA;
input			iHS_RD;
input			iHS_WR;
output	[15:0]	oHS_DATA;
output			oHS_Done;
//	Async Side 1
input	[21:0]	iAS1_ADDR;
input	[15:0]	iAS1_DATA;
input			iAS1_WR_n;
output	[15:0]	oAS1_DATA;
//	Async Side 2
input	[21:0]	iAS2_ADDR;
input	[15:0]	iAS2_DATA;
input			iAS2_WR_n;
output	[15:0]	oAS2_DATA;
//	Async Side 3
input	[21:0]	iAS3_ADDR;
input	[15:0]	iAS3_DATA;
input			iAS3_WR_n;
output	[15:0]	oAS3_DATA;
//	SDRAM Side
input	[15:0]	iSDR_DATA;
input			iSDR_Done;
output	[21:0]	oSDR_ADDR;
output	[15:0]	oSDR_DATA;
output			oSDR_RD;
output			oSDR_WR;
//	Control Signals
input	[1:0]	iSelect;
input			iCLK;
input			iRST_n;
//	Internal Register
reg		[15:0]	mSDR_DATA;
reg		[1:0]	ST;
reg				mSDR_RD;
reg				mSDR_WR;
wire			mAS_WR_n;


//	Host Side Select
assign	oHS_DATA	=	(iSelect==0)	?	iSDR_DATA	:	16'h0000;
assign	oHS_Done	=	(iSelect==0)	?	iSDR_Done	:	1'b1	;
//	ASync Side
assign	oAS1_DATA	=	(iSelect==1)	?	mSDR_DATA	:	16'h0000;
assign	oAS2_DATA	=	(iSelect==2)	?	mSDR_DATA	:	16'h0000;
assign	oAS3_DATA	=	(iSelect==3)	?	mSDR_DATA	:	16'h0000;
//	SDRAM Side
assign	oSDR_DATA	=	(iSelect==0)	?	iHS_DATA	:
						(iSelect==1)	?	iAS1_DATA	:
						(iSelect==2)	?	iAS2_DATA	:
											iAS3_DATA	;
assign	oSDR_ADDR	= 	(iSelect==0)	?	iHS_ADDR	:
						(iSelect==1)	?	iAS1_ADDR	:
						(iSelect==2)	?	iAS2_ADDR	:
											iAS3_ADDR	;
assign	oSDR_RD		=	(iSelect==0)	?	iHS_RD		:	mSDR_RD	;
assign	oSDR_WR		=	(iSelect==0)	?	iHS_WR		:	mSDR_WR	;
//	Internal Async Write/Read Select
assign	mAS_WR_n	=	(iSelect==0)	?	1'b0		:
						(iSelect==1)	?	iAS1_WR_n	:
						(iSelect==2)	?	iAS2_WR_n	:
											iAS3_WR_n	;

//	Async Control & SDRAM Data Lock
always@(posedge iCLK or negedge iRST_n)
begin
	if(!iRST_n)
	begin
		mSDR_DATA<=0;
		mSDR_RD<=0;
		mSDR_WR<=0;
		ST<=0;
	end
	else
	begin
		if(iSelect!=0)
		begin
			case(ST)
			0:	begin
					if(mAS_WR_n)
					begin
						mSDR_RD<=0;
						mSDR_WR<=1;
					end
					else
					begin
						mSDR_RD<=1;
						mSDR_WR<=0;						
					end
					ST<=1;
				end
			1:	begin
					if(iSDR_Done)
					begin
						mSDR_DATA<=iSDR_DATA;
						mSDR_RD<=0;
						mSDR_WR<=0;
						ST<=2;
					end
				end
			2:	ST<=3;
			3:	ST<=0;
			endcase
		end
		else
		begin
			mSDR_RD<=0;
			mSDR_WR<=0;
			ST<=0;		
		end
	end
end
endmodule