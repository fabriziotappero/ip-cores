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

module mReceive(

	input	[07:00]	i8_RxCodeGroupIn,
	input	i_RxCodeInvalid,
	input	i_RxCodeCtrl,
	input	i_RxEven,
	input	i_IsComma,
	input	[02:00] i3_Xmit,
	
	input	i_OrderedSetValid,
	input	i_IsI1Set,
	input	i_IsI2Set,
	input	i_IsC1Set,
	input	i_IsC2Set,
	input	i_IsTSet,
	input	i_IsVSet,
	input	i_IsSSet,
	input	i_IsRSet,
	
	input	i_CheckEndKDK,
	input	i_CheckEndKD21_5D0_0,
	input	i_CheckEndKD2_2D0_0,
	input	i_CheckEndTRK,
	input	i_CheckEndTRR,
	input	i_CheckEndRRR,
	input	i_CheckEndRRK,
	input	i_CheckEndRRS,
	
	
	output	reg	[15:00] o16_RxConfigReg,
	output	o_RUDIConfig,
	output	o_RUDIIdle,
	output	o_RUDIInvalid,
	
	output	reg o_RxDV,
	output	reg o_RxER,
	output	reg [07:00] o8_RxD,
	output	reg o_Invalid,
	output	reg o_Receiving,
	
	
	input	i_Clk,
	input	i_ARst_L
);

localparam 	stWAIT_FOR_K 	= 21'h000001,
			stRX_K 			= 21'h000002,
			stRX_CB			= 21'h000004,
			stRX_CC			= 21'h000008,
			stRX_CD			= 21'h000010,
			stRX_INVALID	= 21'h000020,
			stIDLE_D		= 21'h000040,
			stFALSE_CARRIER = 21'h000080,
			stSTART_OF_PKT	= 21'h000100,
			stEARLY_END		= 21'h000200,
			stTRI_RRI		= 21'h000400,
			stTRR_EXTEND	= 21'h000800,
			stPKT_BURST_RRS	= 21'h001000,
			stRX_DATA_ERR	= 21'h002000,
			stRX_DATA		= 21'h004000,
			stEARLY_END_EXT	= 21'h008000,
			stEXT_ERROR		= 21'h010000;
			
			
			
			
reg		[16:00]	r17_State;
reg		[16:00] r21_NxtState;

wire 	wSUDIK28_5;
wire	wSUDID21_5;
wire	wSUDID2_2;
wire	wCarrierDtect;//what is this
wire	wSUDI;

wire	w_IsC1Set;
wire	w_IsC2Set;
wire	w_IsI1Set;
wire	w_IsI2Set;
wire	w_IsRSet;
wire	w_IsSSet;
wire	w_IsTSet;
wire	w_IsVSet;

	//synthesis translate_off
	reg [8*30-1:0] rvStateName;
	always@(*)
	begin
		case(r17_State)
		stWAIT_FOR_K 	:	rvStateName <= "Wait For K";
		stRX_K 			:	rvStateName <= "RX K";
		stRX_CB			:	rvStateName <= "RX CB";
		stRX_CC			:	rvStateName <= "RX CC";
		stRX_CD			:	rvStateName <= "RX CD";
		stRX_INVALID	:	rvStateName <= "RX Invalid";
		stIDLE_D		:	rvStateName <= "IDLE D";
		//stCARRIER_DTEC	:	rvStateName <= "CARRIER DETECT";
		stFALSE_CARRIER :	rvStateName <= "FALSE CARRIER";
		stSTART_OF_PKT	:	rvStateName <= "Start of Packet";
		//stRECEIVE		:	rvStateName <= "Receiving";
		stEARLY_END		:	rvStateName <= "Early End";
		stTRI_RRI		:	rvStateName <= "TRI RRI";
		stTRR_EXTEND	:	rvStateName <= "TRR Extend";
		//stEPD2_CHK_END	:	rvStateName <= "EPD2 Check End";
		stPKT_BURST_RRS	:	rvStateName <= "PKT BURST RRS";
		stRX_DATA_ERR	:	rvStateName <= "RX DATA Error";
		stRX_DATA		:	rvStateName <= "RX DATA";
		stEARLY_END_EXT	:	rvStateName <= "Early End Ext";
		stEXT_ERROR		:	rvStateName <= "Ext Error";
		//stLINK_FAILED	:	rvStateName <= "Link Failed";
		endcase
		//$display("mReceive State: %s",rvStateName);
	end
	//synthesis translate_on
	

	assign w_IsSSet = i_OrderedSetValid && i_IsRSet;
	assign wSUDI	= ~i_RxCodeInvalid;
	assign wCarrierDtect = i_IsRSet|i_IsSSet|i_IsTSet|i_IsVSet;
	
	always@(posedge i_Clk or negedge i_ARst_L)
	if(i_ARst_L==1'b0) begin
		r17_State <= stWAIT_FOR_K;
	end else begin	
		r17_State <= r21_NxtState;
	end
	
	assign wSUDIK28_5 = (!i_RxCodeInvalid) && (i_RxCodeCtrl) && (i8_RxCodeGroupIn==`K28_5);
	assign wSUDID21_5 = (!i_RxCodeInvalid) && (!i_RxCodeCtrl) && (i8_RxCodeGroupIn==`D21_5);
	assign wSUDID2_2 = (!i_RxCodeInvalid) && (!i_RxCodeCtrl) && (i8_RxCodeGroupIn==`D2_2);
	always@(*)
	begin
		case(r17_State)
		stWAIT_FOR_K: if(i_IsComma && i_RxEven) r21_NxtState <= stRX_K; else r21_NxtState<=stWAIT_FOR_K;
		stRX_K		: if(wSUDID21_5||wSUDID2_2)
						r21_NxtState <= stRX_CB; else
						if((!i_RxCodeInvalid) && (i_RxCodeCtrl) && i3_Xmit!=`cXmitDATA)
						r21_NxtState <= stRX_INVALID; else
							if(((!i_RxCodeInvalid) && (!i_RxCodeCtrl) && i3_Xmit!=`cXmitDATA && i8_RxCodeGroupIn!=`D21_5 && i8_RxCodeGroupIn!=`D2_2)||
								((!i_RxCodeInvalid) && i3_Xmit==`cXmitDATA && ((i8_RxCodeGroupIn!=`D21_5 && i8_RxCodeGroupIn!=`D2_2 && (!i_RxCodeCtrl))||i_RxCodeCtrl)))
								r21_NxtState <= stIDLE_D; else
								r21_NxtState <= stRX_K;
		stRX_CB		: 	if((!i_RxCodeInvalid) && (!i_RxCodeCtrl)) r21_NxtState <= stRX_CC; else r21_NxtState <= stRX_INVALID;
		stRX_CC		: 	if((!i_RxCodeInvalid) && (!i_RxCodeCtrl)) r21_NxtState <= stRX_CD; else r21_NxtState <= stRX_INVALID;
		stRX_CD		: 	if((!i_RxCodeInvalid) && (i_RxCodeCtrl) && i8_RxCodeGroupIn==`K28_5 && i_RxEven) 
							r21_NxtState <= stRX_K;
							else 
							r21_NxtState <= stRX_INVALID;
		
		stRX_INVALID: 	if(wSUDIK28_5 && i_RxEven) 
							r21_NxtState <= stRX_K;
							else
							r21_NxtState <= stWAIT_FOR_K;
		
		stIDLE_D	:	if(!wSUDIK28_5 && (i3_Xmit!=`cXmitDATA))
							r21_NxtState <= stRX_INVALID;
						else if(!i_RxCodeInvalid && i3_Xmit==`cXmitDATA && i_IsSSet)
							r21_NxtState <= stSTART_OF_PKT;
						else if((!i_RxCodeInvalid && i3_Xmit==`cXmitDATA && (~wCarrierDtect)) || (wSUDIK28_5 && i_RxEven))
							r21_NxtState <= stRX_K;
						else
							r21_NxtState <= stFALSE_CARRIER;
						
		/*stCARRIER_DTEC: if(i_OrderedSetValid && i_IsSSet)
							r21_NxtState <= stSTART_OF_PKT;
						else
							r21_NxtState <= stFALSE_CARRIER;*/
		stFALSE_CARRIER : if(wSUDIK28_5 && i_RxEven) r21_NxtState <= stRX_K; else r21_NxtState <= stFALSE_CARRIER;
		
		stSTART_OF_PKT	: if(wSUDI)	
							begin 
								if(~i_RxCodeCtrl) r21_NxtState <= stRX_DATA; else
								if((i_CheckEndKDK||i_CheckEndKD21_5D0_0||i_CheckEndKD2_2D0_0) &&i_RxEven)
									r21_NxtState <= stEARLY_END; else
								if(i_CheckEndTRK && i_RxEven) r21_NxtState <= stTRI_RRI; else
								if(i_CheckEndTRR) r21_NxtState <= stTRR_EXTEND; else
								if(i_CheckEndRRR) r21_NxtState <= stEARLY_END_EXT; else																
								r21_NxtState <= stRX_DATA_ERR;					
							end
						  else r21_NxtState <= stRX_DATA_ERR;						  
		//stRECEIVE		: //zero cycle state
		stRX_DATA		: if(wSUDI)	
							begin 
								if(~i_RxCodeCtrl) r21_NxtState <= stRX_DATA; else
								if((i_CheckEndKDK||i_CheckEndKD21_5D0_0||i_CheckEndKD2_2D0_0) &&i_RxEven)
									r21_NxtState <= stEARLY_END; else
								if(i_CheckEndTRK && i_RxEven) r21_NxtState <= stTRI_RRI; else
								if(i_CheckEndTRR) r21_NxtState <= stTRR_EXTEND; else
								if(i_CheckEndRRR) r21_NxtState <= stEARLY_END_EXT; else																
								r21_NxtState <= stRX_DATA_ERR;					
							end
						  else r21_NxtState <= stRX_DATA_ERR;
		stRX_DATA_ERR	: if(wSUDI)	
							begin 
								if(~i_RxCodeCtrl) r21_NxtState <= stRX_DATA; else
								if((i_CheckEndKDK||i_CheckEndKD21_5D0_0||i_CheckEndKD2_2D0_0) &&i_RxEven)
									r21_NxtState <= stEARLY_END; else
								if(i_CheckEndTRK && i_RxEven) r21_NxtState <= stTRI_RRI; else
								if(i_CheckEndTRR) r21_NxtState <= stTRR_EXTEND; else
								if(i_CheckEndRRR) r21_NxtState <= stEARLY_END_EXT; else							
								r21_NxtState <= stRX_DATA_ERR;					
							end
						  else r21_NxtState <= stRX_DATA_ERR;
		stEARLY_END		: if(wSUDID21_5||wSUDID2_2) r21_NxtState <= stRX_CB; else r21_NxtState <= stIDLE_D;
		stTRI_RRI		: if(wSUDIK28_5) r21_NxtState <= stRX_K; else r21_NxtState <= stTRI_RRI;
		stTRR_EXTEND	: if(i_CheckEndRRR) r21_NxtState <= stTRR_EXTEND; else
							if(i_CheckEndRRK && i_RxEven) r21_NxtState <= stTRI_RRI; else
							 if(i_CheckEndRRS) r21_NxtState <= stPKT_BURST_RRS; else
							  if(i_IsVSet) r21_NxtState <= stEXT_ERROR; else
								r21_NxtState <= stTRR_EXTEND;
		stEARLY_END_EXT	: if(i_CheckEndRRR) r21_NxtState <= stTRR_EXTEND; else
							if(i_CheckEndRRK && i_RxEven) r21_NxtState <= stTRI_RRI; else
							 if(i_CheckEndRRS) r21_NxtState <= stPKT_BURST_RRS; else
							  if(i_IsVSet) r21_NxtState <= stEXT_ERROR; else
								r21_NxtState <= stEARLY_END_EXT;
		//This is zero cycle state
		//stEPD2_CHK_END	: if(i_CheckEndRRR) r21_NxtState <= stTRR_EXTEND; else
		//					if(i_CheckEndRRK && i_RxEven) r21_NxtState <= stTRI_RRI; else
		//					 if(i_CheckEndRRS) r21_NxtState <= stPKT_BURST_RRS; else
		//					  r21_NxtState <= stEXT_ERROR; 
		stPKT_BURST_RRS	: if(i_IsSSet && i_OrderedSetValid && wSUDI) r21_NxtState <= stSTART_OF_PKT; else r21_NxtState <= stPKT_BURST_RRS;
		stEXT_ERROR		: if(i_IsSSet && i_OrderedSetValid && wSUDI) r21_NxtState <= stSTART_OF_PKT; else 
							if(wSUDIK28_5 && i_RxEven) r21_NxtState <= stRX_K; else 
								if(i_CheckEndRRR) r21_NxtState <= stTRR_EXTEND; else
								if(i_CheckEndRRK && i_RxEven) r21_NxtState <= stTRI_RRI; else
								if(i_CheckEndRRS) r21_NxtState <= stPKT_BURST_RRS; else
								r21_NxtState <= stEXT_ERROR;
		endcase
	end

	assign o_RUDIConfig = (r17_State==stRX_CD		)?1'b1:1'b0;
	assign o_RUDIIdle 	= (r17_State==stIDLE_D		)?1'b1:1'b0;
	assign o_RUDIInvalid= (r17_State==stRX_INVALID && i3_Xmit==`cXmitCONFIG)?1'b1:1'b0;

	always@(posedge i_Clk or negedge i_ARst_L)
	if(i_ARst_L==1'b0) begin
		o_Receiving <= 1'b0;
		o_RxDV		<= 1'b0;
		o_RxER		<= 1'b0;	
		o8_RxD		<= 8'h0;
		o16_RxConfigReg <= 16'h00;
	end else begin
	
		case(r21_NxtState)
		//stWAIT_FOR_K 	:	
		stRX_K 			:	begin
							o_Receiving <= 1'b0;
							o_RxDV		<= 1'b0;
							o_RxER		<= 1'b0;							
							end			
		//stRX_CB			:  
		stRX_CC			:   o16_RxConfigReg[07:00] <= i8_RxCodeGroupIn;
		stRX_CD			:  	o16_RxConfigReg[15:08] <= i8_RxCodeGroupIn;
		stRX_INVALID	: 	if(i3_Xmit==`cXmitDATA) o_Receiving <= 1'b1;
		stIDLE_D		:	begin
							o_Receiving <= 1'b0;
							o_RxDV		<= 1'b0;
							o_RxER		<= 1'b0;							
							end					
		
		//stCARRIER_DTEC:	o_Receiving <= 1'b1;
		stFALSE_CARRIER :	begin
							o_RxER 		<= 1'b1;
							o8_RxD		<= 8'h0E;
							end
		stSTART_OF_PKT	:	begin
							o_Receiving <= 1'b1;
							o_RxDV		<= 1'b1;
							o_RxER		<= 1'b0;
							o8_RxD		<= 8'h55;							
							end						
		//stRECEIVE		:	
		stEARLY_END		:	o_RxER <= 1'b1;
		stTRI_RRI		:	begin
							o_Receiving <= 1'b0;
							o_RxER		<= 1'b0;
							o_RxDV		<= 1'b0;
							end
		stTRR_EXTEND	:	begin							
							o_RxER		<= 1'b1;
							o_RxDV		<= 1'b0;
							o8_RxD		<= 8'h0F;
							end		
		//stEPD2_CHK_END	:	
		stPKT_BURST_RRS	:	begin
							o_RxDV		<= 1'b0;
							o8_RxD		<= 8'b0000_1111;							
							end							
		stRX_DATA_ERR	:	o_RxER 		<= 1'b1;
		stRX_DATA		:	begin								
							o_RxER		<= 1'b0;
							o8_RxD		<= i8_RxCodeGroupIn;
							end
		stEARLY_END_EXT	:	o_RxER		<= 1'b1;
		stEXT_ERROR		:	begin
							o_RxDV		<= 1'b0;
							o8_RxD		<= 8'b0001_1111;							
							end
		// stLINK_FAILED	:	begin
							// if(o_Receiving==1'b1) 
								// begin 
								// o_Receiving <= 1'b0;
								// o_RxER <= 1'b1; 
								// end else
								// begin
								// o_RxDV <= 1'b0;
								// o_RxER <= 1'b0;
								// end
							// if(i3_Xmit!=`cXmitDATA) 	o_Invalid <= 1'b1;
							// end
		endcase
	end
	
endmodule
