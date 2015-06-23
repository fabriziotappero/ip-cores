/*
Developed By Subtleware Corporation Pte Ltd 2011
File		:
Description	:	
Remarks		:	
Revision	:
	Date	Author		Description
02/09/12	Jefflieu
*/


`include "SGMIIDefs.v"

module mTransmit(
	input	[02:00]	i3_Xmit,
	input	[15:00]	i16_ConfigReg,
	
	input	i_TxEN,
	input	i_TxER,
	input	[07:00]	i8_TxD,
	
	
	output	reg o_Xmitting,	
	output	reg o_TxEven,
	output	reg [07:00]	o8_TxCodeGroupOut,
	output	o_TxCodeValid,
	output	reg o_TxCodeCtrl,
	input	i_CurrentParity,
	
	input	i_Clk,
	input	i_ARst_L);

/*	
	- Transmit order set Statemachine 	: OSState 	
*/
	
	localparam	stTX_TEST 	= 24'h000001;	//Initial State
	localparam	stCONFIG_C1A= 24'h000002;	//Configuration phase
	localparam 	stCONFIG_C1B= 24'h000004;	//Configuration phase
	localparam 	stCONFIG_C1C= 24'h000008;	//Configuration phase
	localparam	stCONFIG_C1D= 24'h000010;	//Configuration phase
	localparam	stCONFIG_C2A= 24'h000020;	//Configuration phase
	localparam	stCONFIG_C2B= 24'h000040;	//Configuration phase
	localparam	stCONFIG_C2C= 24'h000080;	//Configuration phase
	localparam	stCONFIG_C2D= 24'h000100;	//Configuration phase
	localparam 	stTX_IDLE	= 24'h000200;	//IDLE Phase, Trasmitting Comma Character, this is to wait to sync with the MAC's packet
	localparam  stXMIT_DATA	= 24'h000400;	//Data Phase, Trasmitting Comma Character
	localparam  stIDLE_DATA	= 24'h000800;	//Trasmitting Data Character of /I/ Ordered Set
	localparam 	stTX_SOP	= 24'h001000;	//Transmitting SOP
	localparam 	stTX_PKT	= 24'h002000;	//False state
	localparam	stTX_DATA	= 24'h004000;	//Transmitting Data
	localparam	stTX_EOP	= 24'h008000;	//End of packet without any extension, tramitting T
	localparam  stTX_EOP_EXT= 24'h010000;	//End of packet with extension
	localparam 	stTX_EXT_1	= 24'h020000;	//Extend 1 cycle to align the COMMA to Even Code group
	localparam	stEPD2_NOEXT= 24'h040000;	//Second Cycle of EPD, transmitting /R/
	localparam 	stEPD3		= 24'h080000;	//Third Cycle of EPD, transmitting /R/
	localparam	stCARR_EXT	= 24'h100000;	//Carrier extension
	//localparam	stALIGN_ERR	= 24'h200000;	//Repeater's state, we don't use this, go straight to START ERR
	localparam	stSTART_ERR	= 24'h200000;	//Repeater's state
	localparam	stTX_ERR	= 24'h400000;	//Repeater's state

	
	reg	[22:00]	r13_State;
	reg	[22:00]	w24_NxtState;
	
	
	wire	w_XmitChange;
	reg	[02:00]	r3_LstXmit;
	reg		r_TxEven;
	wire	w_TxOSIndicate;
	
	
	wire	w_FifoTxEn;
	wire	w_FifoTxEr;
	wire [07:00]	w8_FifoData;
	wire	w_UpdateXmitChange;
	wire	w_ResetState;
	reg 	r_ToTxData;				//This signal used in txIDLE_DATA state to comeback to TXIDLE or TXDATA
	wire	w_Disparity;
	wire [09:00] w10_FifoDin;
	wire [09:00] w10_FifoQ;
	wire w_FifoRd,w_FifoEmpty;
	reg	 [07:00] r8_TxData;
	
	assign w_XmitChange = (r3_LstXmit!=i3_Xmit)?1'b1:1'b0;
	assign w_TxOSIndicate = (r13_State==stCONFIG_C1A||r13_State==stCONFIG_C1B||r13_State==stCONFIG_C1C||
								r13_State==stCONFIG_C2A||r13_State==stCONFIG_C2B||r13_State==stCONFIG_C2C||
									r13_State==stTX_IDLE||r13_State==stTX_DATA)?1'b0:1'b1;
	//assign w_UpdateXmitChange = 
	//FIFO
	assign w10_FifoDin = {i_TxEN,i_TxER,i8_TxD};
	assign w_FifoTxEn = w10_FifoQ[9] & (~w_FifoEmpty);
	assign w_FifoTxEr = w10_FifoQ[8] & (~w_FifoEmpty);
	assign w8_FifoData = w10_FifoQ[7:0];
	mSyncFifo #(.pDataWidth(10),.pPtrWidth(2)) u0SyncFifo (
		.iv_Din(w10_FifoDin),
		.i_Wr((i_TxEN|i_TxER)),
		.i_Rd(w_FifoRd),
		.o_Empty(w_FifoEmpty),
		.o_Full(),
		.ov_Q(w10_FifoQ),
		.i_Clk(i_Clk),
		.i_ARst_L(i_ARst_L));	
	//END FIFO
	assign w_FifoRd = ((w_FifoTxEn && (r13_State==stXMIT_DATA||r13_State==stIDLE_DATA)))?1'b0:1'b1;
	
	always@(posedge i_Clk or negedge i_ARst_L)
	if(i_ARst_L==1'b0) begin
		r13_State 	<= stTX_TEST;
		r3_LstXmit  <= `cXmitIDLE;
		r_TxEven	<= 1'b0;
		o_TxEven 	<= 1'b1;
		end
	else
		begin
		if(w_UpdateXmitChange) r3_LstXmit <= i3_Xmit;				
		if(w_ResetState)
			r13_State <= stTX_TEST;
		else 
			r13_State <= w24_NxtState;
		r_TxEven <= ~r_TxEven;
		o_TxEven <= r_TxEven;
		end
	
	// always@(posedge i_Clk or posedge w_ResetState)
	// if(w_ResetState)
		// r13_State <= stTX_TEST;	
	// else 
		// r13_State <= w24_NxtState;
		
	
	assign w_UpdateXmitChange = w_ResetState;
	assign w_ResetState = (i_ARst_L==1'b0)||(w_XmitChange && (o_TxEven==1'b0) && w_TxOSIndicate);
	assign w_Disparity = i_CurrentParity;
	always@(*)
	begin
		
		// else
		case(r13_State)
		stTX_TEST		: 	if(i3_Xmit==`cXmitCONFIG && o_TxEven==1'b0) w24_NxtState <= stCONFIG_C1A; else
							if((i3_Xmit==`cXmitIDLE &&(~o_TxEven)) || ((~o_TxEven) && i3_Xmit==`cXmitDATA && (w_FifoTxEn || w_FifoTxEr))) w24_NxtState <= stTX_IDLE; else
							if(i3_Xmit==`cXmitDATA && (~w_FifoTxEn) && (~w_FifoTxEr)) w24_NxtState <= stXMIT_DATA;
							else w24_NxtState <= stTX_TEST;		
		stCONFIG_C1A	:	w24_NxtState <= stCONFIG_C1B;
		stCONFIG_C1B	:	w24_NxtState <= stCONFIG_C1C;
		stCONFIG_C1C	:	w24_NxtState <= stCONFIG_C1D;
		stCONFIG_C1D	:	if(i3_Xmit==`cXmitCONFIG) w24_NxtState <= stCONFIG_C2A; else
							if(i3_Xmit==`cXmitIDLE || (i3_Xmit==`cXmitDATA && (w_FifoTxEn || w_FifoTxEr))) w24_NxtState <= stTX_IDLE; else
							if(i3_Xmit==`cXmitDATA && (~w_FifoTxEn) && (~w_FifoTxEr)) w24_NxtState <= stXMIT_DATA; else 
							w24_NxtState <= stTX_ERR;
		stCONFIG_C2A	:	w24_NxtState <= stCONFIG_C2B;
		stCONFIG_C2B	:	w24_NxtState <= stCONFIG_C2C;
		stCONFIG_C2C	:	w24_NxtState <= stCONFIG_C2D;
		stCONFIG_C2D	:	if(i3_Xmit==`cXmitCONFIG) w24_NxtState <= stCONFIG_C1A; else
							if(i3_Xmit==`cXmitIDLE || (i3_Xmit==`cXmitDATA && (w_FifoTxEn || w_FifoTxEr))) w24_NxtState <= stTX_IDLE; else
							if(i3_Xmit==`cXmitDATA && (~w_FifoTxEn) && (~w_FifoTxEr)) w24_NxtState <= stXMIT_DATA; else 
							w24_NxtState <= stTX_ERR;
		
		stTX_IDLE		: 	w24_NxtState <= stIDLE_DATA;
		stIDLE_DATA		: 	if(r_ToTxData==1'b0) begin //Data phase of TX_IDLE
								if(i3_Xmit==`cXmitDATA && (~w_FifoTxEn) && (~w_FifoTxEr)) w24_NxtState <= stXMIT_DATA; else
								w24_NxtState <= stTX_IDLE;
								end							
							else 
								begin
									if(w_FifoTxEn & (~w_FifoTxEr)) w24_NxtState <= stTX_SOP; else
									if(w_FifoTxEn & w_FifoTxEr) w24_NxtState <= stSTART_ERR; else
									w24_NxtState <= stXMIT_DATA;							
								end
		stXMIT_DATA		: 	w24_NxtState <= stIDLE_DATA;
		stTX_DATA		: 	if(w_FifoTxEn) w24_NxtState <= stTX_DATA; else
							if((~w_FifoTxEn) & (~w_FifoTxEr)) w24_NxtState <= stTX_EOP; else
							w24_NxtState <= stTX_EOP_EXT; 		
		stTX_SOP		: 	if(w_FifoTxEn) w24_NxtState <= stTX_DATA; else
							if((~w_FifoTxEn) & (~w_FifoTxEr)) w24_NxtState <= stTX_EOP; else
							w24_NxtState <= stTX_EOP_EXT; 
		stTX_EOP		: 	w24_NxtState <= stEPD2_NOEXT; 
		stEPD2_NOEXT	: 	if(r_TxEven) w24_NxtState <= stEPD3; else			
							w24_NxtState <= stXMIT_DATA;
		stEPD3			: 	w24_NxtState <= stXMIT_DATA;
		stTX_EOP_EXT	:	if(~w_FifoTxEr) w24_NxtState <= stTX_EXT_1; else w24_NxtState <= stCARR_EXT;
		stTX_EXT_1		: 	w24_NxtState <= stEPD2_NOEXT;
		stCARR_EXT		: 	if((~w_FifoTxEn) & (~w_FifoTxEr)) w24_NxtState <= stTX_EXT_1; else
							if(w_FifoTxEn & (~w_FifoTxEr)) w24_NxtState <= stTX_SOP; else
							if(w_FifoTxEn & w_FifoTxEr) w24_NxtState <= stSTART_ERR; else
							w24_NxtState <= stCARR_EXT;
		
		//stALIGN_ERR		: 	
		stSTART_ERR		: 	w24_NxtState <= stTX_ERR; 
		stTX_ERR		: 	if(w_FifoTxEn) w24_NxtState <= stTX_DATA; else
							if((~w_FifoTxEn) & (~w_FifoTxEr)) w24_NxtState <= stTX_EOP; else
							w24_NxtState <= stTX_EOP_EXT; 
		endcase
	end
	
	
	assign o_TxCodeValid = 1'b1;
	
	always@(posedge i_Clk or negedge i_ARst_L)
	if(i_ARst_L==1'b0) begin
		o_Xmitting <= 1'b0;
		o_TxCodeCtrl <= 1'b0;
		o8_TxCodeGroupOut <= 8'h00;
	end else begin
		case(w24_NxtState)
		stTX_TEST		: 	begin
							o_Xmitting <= 1'b0;							
							end
		stCONFIG_C1A	:	begin 		
							o8_TxCodeGroupOut <= `K28_5; 
							o_TxCodeCtrl <= 1'b1;							
							end
		stCONFIG_C1B	:	begin 		
							o8_TxCodeGroupOut <= `D21_5; 
							o_TxCodeCtrl <= 1'b0;							
							end
		stCONFIG_C1C	:	o8_TxCodeGroupOut <= i16_ConfigReg[07:00];						
		stCONFIG_C1D	:	o8_TxCodeGroupOut <= i16_ConfigReg[15:08];
							
		stCONFIG_C2A	:	begin 		
							o8_TxCodeGroupOut <= `K28_5; 
							o_TxCodeCtrl <= 1'b1;							
							end
		stCONFIG_C2B	:	begin 		
							o8_TxCodeGroupOut <= `D2_2; 
							o_TxCodeCtrl <= 1'b0;							
							end
		stCONFIG_C2C	:	o8_TxCodeGroupOut <= i16_ConfigReg[07:00];						
		stCONFIG_C2D	:	o8_TxCodeGroupOut <= i16_ConfigReg[15:08];															
		stTX_IDLE		: 	begin 
							o8_TxCodeGroupOut <= `K28_5; 
							o_TxCodeCtrl	<= 1'b1;
							r_ToTxData <= 1'b0;
							end
		stIDLE_DATA		: 	begin
							o8_TxCodeGroupOut <= (w_Disparity==1'b1)?`D5_6:`D16_2;//Disparity = 1 means positive
							o_TxCodeCtrl	<= 1'b0;							
							end
		stXMIT_DATA		: 	begin 
							o8_TxCodeGroupOut <= `K28_5; 
							o_TxCodeCtrl	<= 1'b1;
							r_ToTxData <= 1'b1;
							end
		stTX_DATA		: 	if(((~w_FifoTxEn) & w_FifoTxEr & w8_FifoData != 8'h0F)||(w_FifoTxEn & w_FifoTxEr))
							begin
								o8_TxCodeGroupOut <= `K30_7; 
								o_TxCodeCtrl	<= 1'b1;
							end else							
							begin		
								o8_TxCodeGroupOut <= w8_FifoData;
								o_TxCodeCtrl <= 1'b0;							
							end
		stTX_SOP		: 	begin 
							o_Xmitting	<= 1'b1;
							o8_TxCodeGroupOut <= `K27_7; 
							o_TxCodeCtrl	<= 1'b1;							
							end							
		stTX_EOP		: 	begin 
							o8_TxCodeGroupOut <= `K29_7; 
							o_TxCodeCtrl	<= 1'b1;
							o_Xmitting <= (~r_TxEven);
							end
		stEPD2_NOEXT	: 	begin 
							o8_TxCodeGroupOut <= `K23_7; 
							o_TxCodeCtrl	<= 1'b1;
							o_Xmitting <= 1'b0;
							end
		stEPD3			:	begin 
							o8_TxCodeGroupOut <= `K23_7; 
							o_TxCodeCtrl	<= 1'b1;						
							end
		stTX_EOP_EXT	:	if(((~w_FifoTxEn) & w_FifoTxEr & w8_FifoData != 8'h0F)||(w_FifoTxEn & w_FifoTxEr))
							begin
								o8_TxCodeGroupOut <= `K30_7; 
								o_TxCodeCtrl	<= 1'b1;
							end else
							begin
								o8_TxCodeGroupOut <= `K29_7; 
								o_TxCodeCtrl	<= 1'b1;
							end
		stTX_EXT_1		: 	begin
							o_Xmitting <= (~r_TxEven);
								if(((~w_FifoTxEn) & w_FifoTxEr & w8_FifoData != 8'h0F)||(w_FifoTxEn & w_FifoTxEr))
								begin
									o8_TxCodeGroupOut <= `K30_7; 
									o_TxCodeCtrl	<= 1'b1;
									
								end else
								begin
									o8_TxCodeGroupOut <= `K23_7; 
									o_TxCodeCtrl	<= 1'b1;
								end
							end
		stCARR_EXT		: 	if(((~w_FifoTxEn) & w_FifoTxEr & w8_FifoData != 8'h0F)||(w_FifoTxEn & w_FifoTxEr))
							begin
								o8_TxCodeGroupOut <= `K30_7; 
								o_TxCodeCtrl	<= 1'b1;
							end else
							begin
								o8_TxCodeGroupOut <= `K23_7; 
								o_TxCodeCtrl	<= 1'b1;
							end
		
		//stALIGN_ERR		: 	
		stSTART_ERR		: 	begin 
							o8_TxCodeGroupOut 	<= `K27_7; 
							o_TxCodeCtrl		<= 1'b1;
							o_Xmitting 			<= 1'b1;
							end	
		stTX_ERR		: 	begin 
							o8_TxCodeGroupOut <= `K30_7; 
							o_TxCodeCtrl	<= 1'b1;
							end	
		endcase
	end
	
//synthesis translate_off	
	reg [239:0] r240_TxStateName;
	always@(*)
	case(r13_State)
	stTX_TEST 		: r240_TxStateName<="stTX_TEST 	";
	stCONFIG_C1A    : r240_TxStateName<="stCONFIG_C1A";
	stCONFIG_C1B    : r240_TxStateName<="stCONFIG_C1B";
	stCONFIG_C1C    : r240_TxStateName<="stCONFIG_C1C";
	stCONFIG_C1D    : r240_TxStateName<="stCONFIG_C1D";
	stCONFIG_C2A    : r240_TxStateName<="stCONFIG_C2A";
	stCONFIG_C2B    : r240_TxStateName<="stCONFIG_C2B";
	stCONFIG_C2C    : r240_TxStateName<="stCONFIG_C2C";
	stCONFIG_C2D    : r240_TxStateName<="stCONFIG_C2D";
	stTX_IDLE	    : r240_TxStateName<="stTX_IDLE	 ";
	stXMIT_DATA	    : r240_TxStateName<="stXMIT_DATA";
	stIDLE_DATA	    : r240_TxStateName<="stIDLE_DATA";
	stTX_SOP	    : r240_TxStateName<="stTX_SOP	 ";
	stTX_PKT	    : r240_TxStateName<="stTX_PKT	 ";
	stTX_DATA       : r240_TxStateName<="stTX_DATA   ";
	stTX_EOP	    : r240_TxStateName<="stTX_EOP	 ";
	stTX_EOP_EXT    : r240_TxStateName<="stTX_EOP_EXT";
	stTX_EXT_1	    : r240_TxStateName<="stTX_EXT_1	 ";
	stEPD2_NOEXT    : r240_TxStateName<="stEPD2_NOEXT";
	stEPD3		    : r240_TxStateName<="stEPD3		 ";
	stCARR_EXT	    : r240_TxStateName<="stCARR_EXT	 ";
	//stALIGN_ERR	    : r240_TxStateName<="stALIGN_ERR";
	stSTART_ERR	    : r240_TxStateName<="stSTART_ERR";
	stTX_ERR	    : r240_TxStateName<="stTX_ERR	 ";
	endcase
//synthesis translate_on
endmodule
