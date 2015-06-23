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

module Flash_Multiplexer(	//	Host Side
							oHS_DATA,iHS_DATA,iHS_ADDR,iHS_CMD,oHS_Ready,iHS_Start,
							//	Async Side 1
							oAS1_DATA,iAS1_ADDR,
							//	Async Side 2
							oAS2_DATA,iAS2_ADDR,
							//	Async Side 3
							oAS3_DATA,iAS3_ADDR,
							//	Flash Side
							oFL_DATA,iFL_DATA,oFL_ADDR,oFL_CMD,iFL_Ready,oFL_Start,
							//	Control Signals
							iSelect,iCLK,iRST_n);
//	Host Side
input	[21:0]	iHS_ADDR;	
input	[7:0]	iHS_DATA;
input	[2:0]	iHS_CMD;
input			iHS_Start;
output	[7:0]	oHS_DATA;
output			oHS_Ready;
//	Async Side 1
input	[21:0]	iAS1_ADDR;
output	[7:0]	oAS1_DATA;
//	Async Side 2
input	[21:0]	iAS2_ADDR;
output	[7:0]	oAS2_DATA;
//	Async Side 3
input	[21:0]	iAS3_ADDR;
output	[7:0]	oAS3_DATA;
//	Flash Side
input	[7:0]	iFL_DATA;
input			iFL_Ready;
output	[21:0]	oFL_ADDR;
output	[7:0]	oFL_DATA;
output	[2:0]	oFL_CMD;
output			oFL_Start;
//	Control	Signals
input	[1:0]	iSelect;
input			iCLK;
input			iRST_n;
//	Internal Register
reg		[7:0]	mFL_DATA;
reg		[1:0]	ST;
reg				mFL_Start;

//	Host Side Select
assign	oHS_DATA	=	(iSelect==0)	?	iFL_DATA	:	8'h00	;
assign	oHS_Ready	=	(iSelect==0)	?	iFL_Ready	:	1'b1	;
//	ASync Side
assign	oAS1_DATA	=	(iSelect==1)	?	mFL_DATA	:	8'h00	;
assign	oAS2_DATA	=	(iSelect==2)	?	mFL_DATA	:	8'h00	;
assign	oAS3_DATA	=	(iSelect==3)	?	mFL_DATA	:	8'h00	;
//	Flash Side
assign	oFL_DATA	=	(iSelect==0)	?	iHS_DATA	:	8'hFF	;
assign	oFL_ADDR	= 	(iSelect==0)	?	iHS_ADDR	:
						(iSelect==1)	?	iAS1_ADDR	:
						(iSelect==2)	?	iAS2_ADDR	:
											iAS3_ADDR	;				
assign	oFL_CMD		= 	(iSelect==0)	?	iHS_CMD		:	3'b000	;
assign	oFL_Start	=	(iSelect==0)	?	iHS_Start	:	mFL_Start;

//	mFL_Start Control & Flash Data Lock
always@(posedge iCLK or negedge iRST_n)
begin
	if(!iRST_n)
	begin
		mFL_DATA	<=0;
		mFL_Start	<=0;
		ST			<=0;
	end
	else
	begin
		if(iSelect!=0)
		begin
			case(ST)
			0:	begin
					mFL_Start<=1;
					ST<=1;
				end
			1:	begin
					if(iFL_Ready)
					begin
						mFL_DATA<=iFL_DATA;
						mFL_Start<=0;
						ST<=2;
					end
				end
			2:	ST<=3;
			3:	ST<=0;
			endcase
		end
		else
		begin
			mFL_Start<=0;
			ST<=0;
		end
	end
end				
endmodule
							