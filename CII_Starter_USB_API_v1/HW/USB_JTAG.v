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

module USB_JTAG	(	//	HOST
					iTxD_DATA,oTxD_Done,iTxD_Start,
					oRxD_DATA,oRxD_Ready,iRST_n,iCLK,
					//	JTAG
					TDO,TDI,TCS,TCK	);
input [7:0] iTxD_DATA;
input iTxD_Start,iRST_n,iCLK;
output reg [7:0] oRxD_DATA;
output reg oTxD_Done,oRxD_Ready;
input TDI,TCS,TCK;
output TDO;
wire [7:0] mRxD_DATA;
wire mTxD_Done,mRxD_Ready;			
reg Pre_TxD_Done,Pre_RxD_Ready;
reg mTCK;
////////////	JTAG CLK Sync.	///////////////
always@(posedge iCLK)	mTCK<=TCK;
/////////////////	JTAG Receiver	///////////////
JTAG_REC	u0	(mRxD_DATA,mRxD_Ready,TDI,TCS,mTCK);
//	JTAG Receiver Sync.
always@(posedge iCLK or negedge iRST_n)
begin
	if(!iRST_n)
	begin
		oRxD_Ready<=0;
		Pre_RxD_Ready<=0;
	end
	else
	begin
		Pre_RxD_Ready<=mRxD_Ready;
		if({Pre_RxD_Ready,mRxD_Ready}==2'b01 && ~iTxD_Start)
		begin
			oRxD_Ready<=1;
			oRxD_DATA<=mRxD_DATA;
		end
		else
			oRxD_Ready<=0;
	end
end
///////////////////////////////////////////////////
/////////////	JTAG Transmitter	///////////////
JTAG_TRANS	u1	(iTxD_DATA,iTxD_Start,mTxD_Done,TDO,TCK,TCS);
//	JTAG Transmitter Sync.
always@(posedge iCLK or negedge iRST_n)
begin
	if(!iRST_n)
	begin
		oTxD_Done<=0;
		Pre_TxD_Done<=0;
	end
	else
	begin
		Pre_TxD_Done<=mTxD_Done;
		if({Pre_TxD_Done,mTxD_Done}==2'b01)
			oTxD_Done<=1;
		else
			oTxD_Done<=0;
	end
end
///////////////////////////////////////////////////
endmodule

module JTAG_REC	(	//	HOST	
					oRxD_DATA,oRxD_Ready,
					//	JTAG
					TDI,TCS,TCK	);
input TDI,TCS,TCK;
output reg [7:0] oRxD_DATA;
output reg oRxD_Ready;
reg [7:0] rDATA;
reg [2:0] rCont;
always@(posedge TCK or posedge TCS)
begin
	if(TCS)
	begin
		oRxD_Ready<=0;
		rCont<=0;
	end
	else
	begin
		rCont<=rCont+1;
		rDATA<={TDI,rDATA[7:1]};
		if(rCont==0)
		begin
			oRxD_DATA<={TDI,rDATA[7:1]};
			oRxD_Ready<=1;
		end
		else
			oRxD_Ready<=0;
	end
end		
endmodule

module JTAG_TRANS(	//	HOST
					iTxD_DATA,iTxD_Start,oTxD_Done,
					//	JTAG
					TDO,TCK,TCS	);
input [7:0] iTxD_DATA;
input iTxD_Start;
output reg oTxD_Done;
input TCK,TCS;
output reg TDO;
reg [2:0] rCont;
always@(posedge TCK or posedge TCS)
begin
	if(TCS)
	begin
		oTxD_Done<=0;
		rCont<=0;
		TDO<=0;
	end
	else
	begin
		if(iTxD_Start)
		begin
			rCont<=rCont+1;
			TDO<=iTxD_DATA[rCont];
		end
		else
		begin
			rCont<=0;
			TDO<=0;
		end
		if(rCont==7)
		oTxD_Done<=1;
		else
		oTxD_Done<=0;
	end
end

endmodule

