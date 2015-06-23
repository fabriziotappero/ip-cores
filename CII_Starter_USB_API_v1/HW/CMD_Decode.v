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

module CMD_Decode(	//	USB JTAG
					iRXD_DATA,oTXD_DATA,iRXD_Ready,iTXD_Done,oTXD_Start,
					//	LED
					oLED_RED,oLED_GREEN,
					//	7-SEG
					oSEG7_DIG,
					//	VGA
					oOSD_CUR_EN,oCursor_X,oCursor_Y,
					oCursor_R,oCursor_G,oCursor_B,			
					//	FLASH
					oFL_DATA,iFL_DATA,oFL_ADDR,iFL_Ready,oFL_Start,oFL_CMD,
					//	SDRAM
					oSDR_DATA,iSDR_DATA,oSDR_ADDR,iSDR_Done,oSDR_WR,oSDR_RD,
					//	SRAM
					oSR_DATA,iSR_DATA,oSR_ADDR,oSR_WE_N,oSR_OE_N,
					//	PS2
					iPS2_ScanCode,iPS2_Ready,
					//	Async Port Select
					oSDR_Select,oFL_Select,oSR_Select,
					//	Control
					iCLK,iRST_n	);
//	USB JTAG
input [7:0] iRXD_DATA;
input iRXD_Ready,iTXD_Done;
output [7:0] oTXD_DATA;
output oTXD_Start;
//	LED
output reg [17:0] oLED_RED;
output reg [8:0]  oLED_GREEN;
//	7-SEG
output reg [31:0] oSEG7_DIG;
//	VGA
output reg [9:0] oCursor_X;
output reg [9:0] oCursor_Y;
output reg [9:0] oCursor_R;
output reg [9:0] oCursor_G;
output reg [9:0] oCursor_B;
output reg [1:0] oOSD_CUR_EN;
//	FLASH
input [7:0] iFL_DATA;
input iFL_Ready;
output reg [21:0] oFL_ADDR;
output reg [7:0] oFL_DATA;
output reg [2:0] oFL_CMD;
output reg oFL_Start;
//	SDRAM
input [15:0] iSDR_DATA;
input iSDR_Done;
output reg [21:0] oSDR_ADDR;
output reg [15:0] oSDR_DATA;
output oSDR_WR,oSDR_RD;
//	SRAM
input	[15:0]	iSR_DATA;
output	reg [15:0]	oSR_DATA;
output	reg	[17:0]	oSR_ADDR;
output	oSR_WE_N,oSR_OE_N;
//	PS2
input [7:0] iPS2_ScanCode;
input iPS2_Ready;
//	Async Port Select
output reg [1:0] oSDR_Select;
output reg [1:0] oFL_Select;
output reg [1:0] oSR_Select;
//	Control
input iCLK,iRST_n;

//	Internal Register
reg [63:0] CMD_Tmp;
reg [2:0] mFL_ST,mSDR_ST,mPS2_ST,mSR_ST,mLCD_ST;
//	SDRAM Control Register
reg mSDR_WRn,mSDR_Start;
//	SRAM Control Register
reg	mSR_WRn,mSR_Start;
//	Active Flag
reg f_SETUP,f_LED,f_SEG7,f_SDR_SEL,f_FL_SEL,f_SR_SEL;
reg	f_FLASH,f_SDRAM,f_PS2,f_SRAM,f_VGA;
//	USB JTAG TXD Output
reg oFL_TXD_Start,oSDR_TXD_Start,oPS2_TXD_Start,oSR_TXD_Start;
reg [7:0] oFL_TXD_DATA,oSDR_TXD_DATA,oPS2_TXD_DATA,oSR_TXD_DATA;
//	TXD Output Select Register
reg sel_FL,sel_SDR,sel_PS2,sel_SR;


wire [7:0]	CMD_Action	=	CMD_Tmp[63:56];
wire [7:0]	CMD_Target	=	CMD_Tmp[55:48];
wire [23:0]	CMD_ADDR	=	CMD_Tmp[47:24];
wire [15:0]	CMD_DATA	=	CMD_Tmp[23: 8];
wire [7:0]	CMD_MODE	=	CMD_Tmp[ 7: 0];
wire [7:0] 	Pre_Target	=	CMD_Tmp[47:40];

`include "RS232_Command.h"
`include "Flash_Command.h"

////////////////	 SDRAM Select	/////////////////////
always@(posedge iCLK or negedge iRST_n)
begin
	if(!iRST_n)
	begin
		oSDR_Select	<=0;
		f_SDR_SEL	<=0;
	end
	else
	begin
		if(iRXD_Ready && (Pre_Target == SDRSEL) )
		f_SDR_SEL<=1;
		if(f_SDR_SEL)
		begin
			if( (CMD_Action	== SETUP) && (CMD_MODE	== OUTSEL) && 
				(CMD_ADDR == 24'h123456) )
			oSDR_Select<=CMD_DATA[1:0];
			f_SDR_SEL<=0;
		end
	end
end
/////////////////////////////////////////////////////////
////////////////	 FLASH Select	/////////////////////
always@(posedge iCLK or negedge iRST_n)
begin
	if(!iRST_n)
	begin
		oFL_Select	<=0;
		f_FL_SEL	<=0;
	end
	else
	begin
		if(iRXD_Ready && (Pre_Target == FLSEL) )
		f_FL_SEL<=1;
		if(f_FL_SEL)
		begin
			if( (CMD_Action	== SETUP) && (CMD_MODE	== OUTSEL) && 
				(CMD_ADDR == 24'h123456) )
			oFL_Select<=CMD_DATA[1:0];
			f_FL_SEL<=0;
		end
	end
end
/////////////////////////////////////////////////////////
////////////////	 SRAM Select	/////////////////////
always@(posedge iCLK or negedge iRST_n)
begin
	if(!iRST_n)
	begin
		oSR_Select	<=0;
		f_SR_SEL	<=0;
	end
	else
	begin
		if(iRXD_Ready && (Pre_Target == SRSEL) )
		f_SR_SEL<=1;
		if(f_SR_SEL)
		begin
			if( (CMD_Action	== SETUP) && (CMD_MODE	== OUTSEL) && 
				(CMD_ADDR == 24'h123456) )
			oSR_Select<=CMD_DATA[1:0];
			f_SR_SEL<=0;
		end
	end
end
/////////////////////////////////////////////////////////
/////////////////	TXD	Output Select		/////////////
always@(posedge iCLK or negedge iRST_n)
begin
	if(!iRST_n)
	begin
		sel_FL<=0;
		sel_SDR<=0;
		sel_PS2<=0;
		sel_SR<=0;
		f_SETUP<=0;
	end
	else
	begin
		if(iRXD_Ready && (Pre_Target == SET_REG) )
		f_SETUP<=1;
		if(f_SETUP)
		begin
			if( (CMD_Action	== SETUP) && (CMD_MODE	== OUTSEL) &&
				(CMD_ADDR == 24'h123456) )
			begin
				case(CMD_DATA[7:0])
				FLASH:	begin
							sel_FL	<=1;
							sel_SDR	<=0;
							sel_PS2	<=0;
							sel_SR	<=0;
						end
				SDRAM:	begin
							sel_FL	<=0;
							sel_SDR	<=1;
							sel_PS2	<=0;
							sel_SR	<=0;
						end
				PS2:	begin
							sel_FL	<=0;
							sel_SDR	<=0;
							sel_PS2	<=1;
							sel_SR	<=0;
						end
				SRAM:	begin
							sel_FL	<=0;
							sel_SDR	<=0;
							sel_PS2	<=0;
							sel_SR	<=1;
						end
				endcase
			end
			f_SETUP<=0;
		end
	end
end
assign oTXD_Start	= 	(sel_FL)	?	oFL_TXD_Start	:
						(sel_SDR)	?	oSDR_TXD_Start	:
						(sel_SR)	?	oSR_TXD_Start	:
										oPS2_TXD_Start	;
assign oTXD_DATA	=	(sel_FL)	?	oFL_TXD_DATA	:
						(sel_SDR)	?	oSDR_TXD_DATA	:
						(sel_SR)	?	oSR_TXD_DATA	:
										oPS2_TXD_DATA	;
/////////////////////////////////////////////////////////
///////		Shift Register For Command Temp	/////////////
always@(posedge iCLK or negedge iRST_n)
begin
	if(!iRST_n)
	CMD_Tmp<=0;
	else
	begin
		if(iRXD_Ready)
		CMD_Tmp<={CMD_Tmp[55:0],iRXD_DATA};
	end
end
/////////////////////////////////////////////////////////
////////////////	 LED Control	/////////////////////
always@(posedge iCLK or negedge iRST_n)
begin
	if(!iRST_n)
	begin
		oLED_RED	<=0;
		oLED_GREEN	<=0;
		f_LED		<=0;
	end
	else
	begin
		if(iRXD_Ready && (Pre_Target == LED) )
		f_LED<=1;
		if(f_LED)
		begin
			if( (CMD_Action	== WRITE) && (CMD_MODE	== DISPLAY) )
			begin
				oLED_RED	<=CMD_ADDR;
				oLED_GREEN	<=CMD_DATA;
			end
			f_LED<=0;
		end
	end
end
/////////////////////////////////////////////////////////
////////////////	7-SEG Control	/////////////////////
always@(posedge iCLK or negedge iRST_n)
begin
	if(!iRST_n)
	begin
		oSEG7_DIG<=0;
		f_SEG7<=0;
	end
	else
	begin
		if(iRXD_Ready  && (Pre_Target == SEG7) )
		f_SEG7<=1;
		if(f_SEG7)
		begin
			if( (CMD_Action	== WRITE) && (CMD_MODE	== DISPLAY) )
			oSEG7_DIG<={CMD_ADDR[15:0],CMD_DATA};
			f_SEG7<=0;			
		end
	end
end
/////////////////////////////////////////////////////////
////////////////	Flash Control	/////////////////////
always@(posedge iCLK or negedge iRST_n)
begin
	if(!iRST_n)
	begin
		oFL_TXD_Start	<=0;
		oFL_Start		<=0;
		f_FLASH			<=0;
		mFL_ST			<=0;
	end
	else
	begin
		if( CMD_Action == READ )
		oFL_CMD		<=	CMD_READ;
		else if( CMD_Action == WRITE )
		oFL_CMD		<=	CMD_WRITE;
		else if( CMD_Action == ERASE )
		oFL_CMD		<=	CMD_CHP_ERA;
		else
		oFL_CMD		<=	3'b000;
		
		if(iRXD_Ready && (Pre_Target == FLASH))
		f_FLASH<=1;
		if(f_FLASH)
		begin
			case(mFL_ST)
			0:	begin
					if( (CMD_MODE	== NORMAL) && (CMD_Target == FLASH) && (CMD_DATA[15:8] == 8'hFF) )
					begin
						oFL_ADDR	<=	CMD_ADDR;
						oFL_DATA	<=	CMD_DATA;
						oFL_Start<=	1;
						mFL_ST	<=	1;
					end
					else
					begin
						mFL_ST	<=	0;
						f_FLASH	<=	0;
					end
				end	
			1:	begin
					if(iFL_Ready)
					begin
						mFL_ST<=2;
						oFL_Start<=0;
					end	
				end
			2:	begin
					oFL_Start<=1;
					mFL_ST<=3;
				end
			3:	begin
					if(iFL_Ready)
					begin
						mFL_ST<=4;
						oFL_Start<=0;
					end	
				end
			4:	begin
					oFL_Start<=1;
					mFL_ST<=5;
				end			
			5:	begin
					if(iFL_Ready)
					begin
						if( (oFL_CMD == CMD_READ) )
							mFL_ST	<=	6;
						else
						begin
							mFL_ST	<=	0;
							f_FLASH	<=	0;							
						end
						oFL_Start	<=	0;
					end				
				end
			6:	begin
					oFL_TXD_DATA	<=	iFL_DATA;
					oFL_TXD_Start	<=	1;
					mFL_ST			<=	7;
				end
			7:	begin
					if(iTXD_Done)
					begin
						oFL_TXD_Start<=0;
						mFL_ST	<=	0;
						f_FLASH	<=	0;
					end
				end
			endcase
		end
	end
end
/////////////////////////////////////////////////////////
/////////////////	PS2 Control		/////////////////////
always@(posedge iCLK or negedge iRST_n)
begin
	if(!iRST_n)
	begin
		oPS2_TXD_Start<=0;
		f_PS2<=0;
		mPS2_ST<=0;
	end
	else
	begin
		if(iPS2_Ready && iPS2_ScanCode!=8'h2e)
		begin
			f_PS2<=1;
			oPS2_TXD_DATA<=iPS2_ScanCode;
		end
		if(f_PS2)
		begin
			case(mPS2_ST)
			0:	begin
					oPS2_TXD_Start	<=1;
					mPS2_ST			<=1;
				end
			1:	begin
					if(iTXD_Done)
					begin
						oPS2_TXD_Start	<=0;
						mPS2_ST			<=0;
						f_PS2			<=0;
					end
				end
			endcase
		end
	end
end
/////////////////////////////////////////////////////////
////////////////	Sdram Control	/////////////////////
always@(posedge iCLK or negedge iRST_n)
begin
	if(!iRST_n)
	begin
		oSDR_TXD_Start	<=0;
		mSDR_WRn		<=0;
		mSDR_Start		<=0;
		f_SDRAM			<=0;
		mSDR_ST			<=0;
	end
	else
	begin
		if( CMD_Action == READ )
		mSDR_WRn	<=	1'b0;
		else if( CMD_Action == WRITE )
		mSDR_WRn	<=	1'b1;
		
		if(iRXD_Ready && (Pre_Target == SDRAM))
		f_SDRAM<=1;
		if(f_SDRAM)
		begin
			case(mSDR_ST)
			0:	begin
					if( (CMD_MODE	== NORMAL) && (CMD_Target == SDRAM) )
					begin
						oSDR_ADDR	<=	CMD_ADDR;
						oSDR_DATA	<=	CMD_DATA;
						mSDR_Start	<= 	1;
						mSDR_ST		<=	1;
					end
					else
					begin
						mSDR_ST	<=	0;
						f_SDRAM	<=	0;
					end
				end
			1:	begin
					if(iSDR_Done)
					begin
						if(mSDR_WRn == 1'b0)
							mSDR_ST	<=	2;
						else
						begin
							mSDR_ST	<=	0;
							f_SDRAM	<=	0;							
							mSDR_Start	<=	0;
						end
					end				
				end
			2:	begin
					oSDR_TXD_DATA	<= iSDR_DATA[7:0];
					oSDR_TXD_Start	<=	1;
					mSDR_ST			<=	3;
				end
			3:	begin
					if(iTXD_Done)
					begin
						oSDR_TXD_Start<=0;
						mSDR_ST	<=	4;
					end											
				end
			4:	begin
					oSDR_TXD_DATA	<= 	iSDR_DATA[15:8];
					oSDR_TXD_Start	<=	1;
					mSDR_ST			<=	5;
				end
			5:	begin
					if(iTXD_Done)
					begin
						mSDR_Start	<=	0;
						oSDR_TXD_Start<=0;
						mSDR_ST	<=	0;
						f_SDRAM	<=	0;
					end				
				end
			endcase
		end
	end
end

assign	oSDR_WR	=	mSDR_WRn & mSDR_Start;
assign	oSDR_RD	=	~mSDR_WRn & mSDR_Start;
/////////////////////////////////////////////////////////
////////////////	SRAM Control	/////////////////////
always@(posedge iCLK or negedge iRST_n)
begin
	if(!iRST_n)
	begin
		oSR_TXD_Start	<=0;
		mSR_WRn			<=0;
		mSR_Start		<=0;
		f_SRAM			<=0;
		mSR_ST			<=0;
	end
	else
	begin
		if( CMD_Action == READ )
		mSR_WRn	<=	1'b0;
		else if( CMD_Action == WRITE )
		mSR_WRn	<=	1'b1;
		
		if(iRXD_Ready && (Pre_Target == SRAM))
		f_SRAM<=1;
		if(f_SRAM)
		begin
			case(mSR_ST)
			0:	begin
					if( (CMD_MODE	== NORMAL) && (CMD_Target == SRAM) )
					begin
						oSR_ADDR	<=	CMD_ADDR;
						oSR_DATA	<=	CMD_DATA;
						mSR_Start	<= 	1;
						mSR_ST		<=	1;
					end
					else
					begin
						mSR_ST	<=	0;
						f_SRAM	<=	0;
					end
				end
			1:	begin
					if(mSR_WRn == 1'b0)
						mSR_ST	<=	2;
					else
					begin
						mSR_ST	<=	0;
						f_SRAM	<=	0;							
						mSR_Start	<=	0;
					end
				end
			2:	begin
					oSR_TXD_DATA	<= 	iSR_DATA[7:0];
					oSR_TXD_Start	<=	1;
					mSR_ST			<=	3;
				end
			3:	begin
					if(iTXD_Done)
					begin
						oSR_TXD_Start<=0;
						mSR_ST	<=	4;
					end											
				end
			4:	begin
					oSR_TXD_DATA	<= 	iSR_DATA[15:8];
					oSR_TXD_Start	<=	1;
					mSR_ST			<=	5;
				end
			5:	begin
					if(iTXD_Done)
					begin
						mSR_Start	<=	0;
						oSR_TXD_Start<=	0;
						mSR_ST		<=	0;
						f_SRAM		<=	0;
					end				
				end
			endcase
		end
	end
end

assign	oSR_OE_N	=	~(~mSR_WRn & mSR_Start );
assign	oSR_WE_N	=	~( mSR_WRn & mSR_Start );

/////////////////////////////////////////////////////////
////////////////////   VGA Control	/////////////////////
always@(posedge iCLK or negedge iRST_n)
begin
	if(!iRST_n)
	begin
		oCursor_X	<=	0;
		oCursor_Y	<=	0;
		oCursor_R	<=	0;
		oCursor_G	<=	0;
		oCursor_B	<=	0;
		oOSD_CUR_EN	<=	0;
		f_VGA		<=	0;
	end
	else
	begin
		if(iRXD_Ready  && (Pre_Target == VGA) )
		f_VGA<=1;
		if(f_VGA)
		begin
			if( (CMD_Action	== WRITE) && (CMD_MODE	== DISPLAY) )
			begin
				case(CMD_ADDR[2:0])
				0:	oOSD_CUR_EN	<=	CMD_DATA[1:0];
				1:	oCursor_X	<=	CMD_DATA[9:0];
				2:	oCursor_Y	<=	CMD_DATA[9:0];
				3:	oCursor_R	<=	CMD_DATA[9:0];	
				4:	oCursor_G	<=	CMD_DATA[9:0];
				5:	oCursor_B	<=	CMD_DATA[9:0];
				endcase
			end
			f_VGA<=0;			
		end
	end
end
/////////////////////////////////////////////////////////

endmodule