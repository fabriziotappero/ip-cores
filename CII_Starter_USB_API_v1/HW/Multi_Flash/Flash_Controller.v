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

module Flash_Controller(	//	Control Interface
							oDATA,iDATA,iADDR,iCMD,
							oReady,iStart,iCLK,iRST_n,
							//	Flash Interface
							FL_DQ,FL_ADDR,FL_WE_n,FL_CE_n,FL_OE_n,FL_RST_n);

/////////////	Control Interface	////////////////////////
input [21:0] iADDR;
input [7:0]	iDATA;
input [2:0] iCMD;
input iStart,iCLK,iRST_n;
output reg [7:0] oDATA;
output oReady;
/////////////	Flash Interface	////////////////////////
output reg [21:0] FL_ADDR;
inout [7:0] FL_DQ;
output FL_OE_n,FL_CE_n,FL_WE_n,FL_RST_n;
/////////////	Internal Register	////////////////////////
reg [21:0] Cont_Finish,CMD_Period;
reg [7:0] mDATA;
reg [10:0] Cont_DIV,WE_CLK_Delay,Start_Delay;
reg [3:0] ST;
reg mCLK,mStart,preStart,pre_mCLK,mACT;
reg mFinish;
reg [2:0] r_CMD;
reg [21:0] r_ADDR;
reg [7:0] r_DATA;
/////////////	Internal Wire	////////////////////////////
wire WE_CLK;
/////////////////////////////////////////////////////////

`include "Flash_Command.h"

/////////////	Flash Command Period	////////////////////
parameter PER_READ		=	1;			//	160		ns
parameter PER_WRITE 	= 	5;			//	800 	ns
parameter PER_BLK_ERA	= 	160000;		//	25.6	ms
parameter PER_SEC_ERA 	= 	160000;		//	25.6	ms
parameter PER_CHP_ERA	= 	640000;		//	102.4	ms		
parameter PER_ENTRY_ID	= 	4;			//	480		ns
parameter PER_RESET		= 	1;			//	160		ns
//////////////	 Flash State Machine	////////////////////
parameter IDEL		=	0;
parameter P1	 	= 	1;
parameter P2	 	= 	2;
parameter P3	 	= 	3;
parameter P4	 	=	4;
parameter P5	 	=	5;
parameter P3_PRG	= 	6;
parameter P3_DEV	= 	7;
parameter P4_PRG	=	8;
parameter P6_BLK_ERA=	9;
parameter P6_SEC_ERA=	10;
parameter P6_CHP_ERA=	11;
parameter READ		=	12;
parameter RESET		=	13;
////////////////	Clcok Setting	/////////////////////
//parameter CLK_Divide =	4;
parameter CLK_Divide =	8;
//parameter CLK_Divide =	16;
/////////////////////////////////////////////////////////
////	FL_OE_n  ?  Write =	1 : Read   = 0			/////
////	FL_CE_n  ?  IDEL  = 1 : ACTIVE = 0			/////
////	FL_RST_n ?  ON	  = 1 : RESET  = 0			/////
assign FL_DQ	= FL_OE_n ? mDATA : 8'bzzzzzzzz ;
assign FL_OE_n	= (ST == READ)	?	1'b0 : 1'b1 ;
assign FL_CE_n	= (ST == IDEL)	?	1'b1 : 1'b0 ;
assign FL_WE_n	= (ST == IDEL)	?	1'b1 :
				  (ST == READ)	?	1'b1 : WE_CLK;
assign FL_RST_n	= (ST == RESET) ?	1'b0 : 1'b1 ;
assign oReady	= mStart ?	1'b0 : mFinish;
/////////////////////////////////////////////////////////
//////////	 Flash State & WE Clock Generator	/////////
always@(posedge iCLK or negedge iRST_n)
begin
	if(!iRST_n)
	begin
		Cont_DIV		<=0;
		mCLK			<=0;
	end
	else
	begin
		Cont_DIV		<=Cont_DIV+1;
		mCLK			<=Cont_DIV[CLK_Divide>>2];
	end
end
////////////////////////////////////////////////////////
//////////////	  WE Clock Generator	////////////////
always@(posedge iCLK or negedge iRST_n)
begin
	if(!iRST_n)
	WE_CLK_Delay<=0;
	else
	WE_CLK_Delay<={WE_CLK_Delay[9:0],Cont_DIV[CLK_Divide>>2]};
end
assign	WE_CLK 	=	(CLK_Divide == 4)	?	~WE_CLK_Delay[3]	:
					(CLK_Divide == 8)	?	~WE_CLK_Delay[4]	:
											~WE_CLK_Delay[10]	;
////////////////////////////////////////////////////////
///////////	 Input Signal & Data Latch	////////////////
always@(posedge iCLK or negedge iRST_n)
begin
	if(!iRST_n)
	begin
		mStart			<=0;
		Start_Delay		<=0;
		preStart		<=0;
		pre_mCLK		<=0;
		mACT			<=0;
	end
	else
	begin
		////////	State Active Detect	//////////
		if({pre_mCLK,mCLK}==2'b01)
		mACT<=1;
		else
		mACT<=0;
		pre_mCLK<=mCLK;
		//////////////////////////////////////////
		//////	Input Signal & Data Latch	//////
		if({preStart,iStart}==2'b01)
		begin
			mStart		<=1'b1;
			Start_Delay	<=8'h00;
			r_CMD<=iCMD;
			r_ADDR<=iADDR;
			r_DATA<=iDATA;
		end
		else
		begin
			if(Start_Delay<CLK_Divide)
			Start_Delay<=Start_Delay+1;
			else
			mStart<=1'b0;
		end
		preStart<=iStart;
		//////////////////////////////////////////
	end
end
////////////////////////////////////////////////////////
/////////////	Flash Output Latch	////////////////////
always@(posedge iCLK or negedge iRST_n)
begin
	if(!iRST_n)
	oDATA<=0;
	else
		if( mACT && (ST==READ))
		oDATA<=FL_DQ;
end
////////////////////////////////////////////////////////
//////////////	 Flash State Control	////////////////
always@(posedge iCLK or negedge iRST_n)
begin
	if(!iRST_n)
	ST<=IDEL;
	else
	begin
		if(mACT)	//	State Active Flag
		begin
			if(mStart)
			begin
				case(r_CMD)
				CMD_READ	:	ST<=READ;
				CMD_WRITE	:	ST<=P1;
				CMD_BLK_ERA	:	ST<=P1;
				CMD_SEC_ERA	:	ST<=P1;
				CMD_CHP_ERA	:	ST<=P1;
				CMD_ENTRY_ID:	ST<=P1;
				CMD_RESET	:	ST<=RESET;
				endcase
			end
			else
			begin
				case(ST)
				IDEL:		ST <= IDEL;
				P1:			ST <= P2;
				P2:			begin
								case(r_CMD)
								CMD_WRITE	:	ST <= P3_PRG;
								CMD_ENTRY_ID:	ST <= P3_DEV;
								default		:	ST <= P3;
								endcase
							end
				P3:			ST <= P4;
				P4:			ST <= P5;
				P5:			begin
								case(r_CMD)
								CMD_BLK_ERA	:	ST <= P6_BLK_ERA;
								CMD_SEC_ERA	:	ST <= P6_SEC_ERA;
								CMD_CHP_ERA	:	ST <= P6_CHP_ERA;
								endcase
							end
				P3_PRG:		ST <= P4_PRG;
				P3_DEV:		ST <= IDEL;
				P4_PRG:		ST <= IDEL;
				P6_BLK_ERA:	ST <= IDEL;
				P6_SEC_ERA:	ST <= IDEL;
				P6_CHP_ERA:	ST <= IDEL;
				READ:		ST <= IDEL;
				RESET:		ST <= IDEL;
				endcase
			end
		end
	end
end
////////////////////////////////////////////////////////
//////////////	 Output Finish Control	////////////////
always@(posedge iCLK or negedge iRST_n)
begin
	if(!iRST_n)
	begin
		mFinish<=0;
		Cont_Finish<=0;
	end
	else
	begin
		if(mACT)	//	State Active Flag
		begin
			if(mStart)
			begin
				mFinish		<=1'b0;
				Cont_Finish	<=0;
			end
			else
			begin
				if(Cont_Finish < CMD_Period)
				Cont_Finish	<=	Cont_Finish+1;
				else
				mFinish		<=	1'b1;
			end
		end
	end
end
////////////////////////////////////////////////////////	
//////////////	 Command Period LUT	////////////////////
always@(posedge iCLK)
begin
	case(r_CMD)
	CMD_READ	:	CMD_Period	<=	PER_READ-1;
	CMD_WRITE	:	CMD_Period	<=	PER_WRITE-1;
	CMD_BLK_ERA	:	CMD_Period	<=	PER_BLK_ERA-1;
	CMD_SEC_ERA	:	CMD_Period	<=	PER_SEC_ERA-1;
	CMD_CHP_ERA	:	CMD_Period	<=	PER_CHP_ERA-1;
	CMD_ENTRY_ID:	CMD_Period	<=	PER_ENTRY_ID-1;
	CMD_RESET	:	CMD_Period	<=	PER_RESET-1;
	endcase
end
////////////////////////////////////////////////////////
////////////////	Command State LUT	////////////////
always
begin
	case(ST)
	IDEL:	begin
				FL_ADDR <= 22'h000000;	mDATA 	<= 8'h00;
			end
	P1:		begin
				FL_ADDR <= 22'h000AAA; 	mDATA 	<= 8'hAA;			
			end										
	P2:		begin
				FL_ADDR <= 22'h000555;	mDATA 	<= 8'h55;						
			end	
	P3:		begin
				FL_ADDR <= 22'h000AAA;	mDATA 	<= 8'h80;						 
      		end
	P4:		begin
				FL_ADDR <= 22'h000AAA;	mDATA 	<= 8'hAA;						 
      		end
	P5:		begin
				FL_ADDR <= 22'h000555;	mDATA 	<= 8'h55;						 
     	 	end
	P3_PRG:	begin
				FL_ADDR <= 22'h000AAA;	mDATA 	<= 8'hA0;						 
      		end
	P3_DEV:	begin
				FL_ADDR <= 22'h000AAA;	mDATA 	<= 8'h90;						 
      		end
	P4_PRG:	begin
				FL_ADDR <= r_ADDR;		mDATA 	<= r_DATA;					 
      		end
	P6_BLK_ERA:	
			begin
				FL_ADDR <= r_ADDR<<12;	mDATA 	<= 8'h30;					 
      		end
	P6_SEC_ERA:	
			begin
				FL_ADDR <= r_ADDR<<16;	mDATA 	<= 8'h50;					 
      		end
	P6_CHP_ERA:	
			begin
				FL_ADDR <= 22'h000AAA;	mDATA 	<= 8'h10;					 
      		end
	READ:	begin
				FL_ADDR <= r_ADDR;		mDATA 	<= 8'h00;
			end
	RESET: begin
				FL_ADDR <= 22'h000000;	mDATA 	<= 8'h00;
			end
	endcase
end
////////////////////////////////////////////////////////

endmodule