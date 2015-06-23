//File name=Module name=SPW_CODEC  2005-2-18      btltz@mail.china.com      btltz from CASIC  
//Description:   SpaceWire Coder/Decoder,     Approximate area: ?
//Abbreviations: COMI -- Communication Memory Interface
//               HOCI -- Host Control Inerface
//               PRCI -- Protocol Command Interface
//   \_______________________||__________________________/
//    |_____Encoding_________||_______Transmission______|
//    |DS -- (Data/Strobe)   ||SE --(Single Ended)      | 
//    |TS -- (Three of six)  ||DE --(Differential Ended)|
//    |HS -- High Speed      ||FO --(Fibre Optic)       | 
//    |______________________||_________________________|
//Origin:        SpaceWire Std - Draft-1 of ECSS(European Cooperation for Space Standardization),ESTEC,ESA
//--     TODO:   Make the rtl faster
////////////////////////////////////////////////////////////////////////////////////
//
/*synthesis translate off*/
`timescale 1ns/100ps
/*synthesis translate on */
`define gFreq  80  //the frequence of the global clock input to the CODEC as the system clk
                   //You may need to change it to meet your own board. 
                   //This set could affect the Module"Tx_ClkGen".You could open that module for more details.
`define ErrorReset  6'b000001
`define ErrorWait   6'b000010
`define Ready       6'b000100
`define Started     6'b001000     
`define Connecting  6'b010000
`define Run         6'b100000
`define reset   1  // WISHBONE standard reset

module SPW_CODEC  #(parameter DW=8)
                (output Do, So,  //Transmitter data out & strobe out
                 input  Di, Si,   //Receiver data in & strobe in 	  
   		        
					  output [5:0] PPUstate, 
					  output LINK_ERR_o,
					  output reg err_int_o,
					//  output nor_int_o,	              
   //Transmitter & ack signals  	 
	              output tx_drvclk_o,
	              output rdbuf_o,             
					  input Tx_type_i,   					   
                 input [DW-1:0] data_i,  //data to send 
					  input Txbuf_Empty,

	//Receiver & ack signals 
	              output Rx_DLL_LOCKED,
	              output rx_drvclk_o,
	              output wrbuf_o,          
                 output Rx_type_o,  //Type of character received
                 output [DW-1:0] data_o,  //data received  
					  input Rxbuf_Full,     
					  
   //time & control input & output
                 output [5:0] TIMEout, 
					  output [1:0] CtrlFlg_o,       
                 output  TICK_OUT,
                 //+			          
                 input [5:0] TIMEin,                 
					  input[1:0] CtrlFlg_i,
					  input TICK_IN,
   //status and Control(Link Enable) 
                 output active,   //indicate the Codec is active
                 input lnk_start,lnk_dis,  // enable Codec or disable Codec 
                 input AUTOSTART,   //AUTOSTART input 
   //reset ,global clock in                
                 input reset,
                 input clk10,gclk    /* synthesis syn_isclock = 1 */
                  );
               //  parameter DW = 8; 
                 parameter True  = 1;
                 parameter False = 0;

/*
output Do, So,  //Transmitter data out & strobe out
input  Di, Si,  //Receiver data in & strobe out 
input  C_send_i,  //Commands to send characters    
input [DW-1:0] data_s_i,  //data to send 
output Send_ack_o,   //Acknowledgement       
output  Type_c_o,  //Type of character received
output [DW-1:0] data_r_o,  //data received
input   Type_ack_i,
input program_i,
input gclk //global clock in
*/
wire err_crd;  //err from Tx
wire err_sqc;	//err from PPU
//err from Rx
wire err_par;
wire err_esc;
wire err_dsc;	

wire gotBit;
wire gotFCT;
wire gotNULL;
wire gotNchar;
wire gotTIME;
wire C_SEND_FCT;
wire EnTx;
wire EnRx;
wire RST_rx;
wire RST_tx;
//wire Rx_DLL_LOCKED;
//wire RxErr;

 //Vector wire
wire [5:0] state;
assign PPUstate = state;

always @(posedge gclk)
begin:INT_GEN
if(reset)
  err_int_o <= 0;
else if(err_int_o==True)
  err_int_o <= 0;
else if(err_sqc ||err_crd || err_par || err_esc || err_dsc )
  err_int_o <= 1'b1;
end  //end block "INT_GEN"

Transmitter    inst_tx(
    .Do(Do), 
    .So(So), 

	 .type_i(Tx_type_i), 
    .TxData_i(data_i), 
	 .rdbuf_o(rdbuf_o),  
	 .CtrlFlg_i(CtrlFlg_i), 
	 .empty_i(Txbuf_Empty), 
	 .TICK_IN(TICK_IN),
	 .TIMEin(TIMEin),
	 .tx_drvclk_o(tx_drvclk_o),

	/*** .AUTOSTART(AUTOSTART),***/	
  //  .Sending(), 
    .err_crd_o(err_crd), 
    .gotFCT_i(gotFCT), 
    .C_SEND_FCT_o(C_SEND_FCT), 
    .EnTx(EnTx),           
    .state_i(state), 
    .reset(RST_tx), 
    .gclk(gclk), 
    .clk10(clk10)
    );

SPW_FSM  inst_fsm   //The PPU
                  (     
    .active_o(active),
	 .lnk_start(lnk_start), 
    .lnk_dis(lnk_dis), 
    .AUTOSTART(AUTOSTART), 

	 .state_o(state),     
    .LINK_ERR_o(LINK_ERR_o), 
    .err_sqc(err_sqc), 
    .RST_tx_o(RST_tx), 
    .enTx_o(EnTx), 
    .err_crd_i(err_crd), 
    .RST_rx_o(RST_rx), 
    .enRx_o(EnRx), 
    .Lnk_dsc_i(Lnk_dsc), 
    .gotBit_i(gotBit), 
    .gotFCT_i(gotFCT), 
    .gotNchar_i(gotNchar), 
    .gotTime_i(gotTIME), 
    .gotNULL_i(gotNULL), 
    .err_par_i(err_par), 
    .err_esc_i(err_esc), 
    .err_dsc_i(err_dsc), 
    .reset(reset), 
    .gclk(gclk), 
    .clk10(clk10)
    );

Receiver    inst_rx(	
    .Si(Si), 
    .Di(Di),

	 .RxData_o(data_o),
	 .wrtbuf_o(wrbuf_o), 
    .type_o(Rx_type_o),           	
    //.RxClk_o(RxClk_o), 
    .CtrlFlg_o(CtrlFlg_o), 
    .TIMEout(TIMEout),
	 .full_i(Rxbuf_Full),
	 .TICK_OUT(TICK_OUT), 
	 .rx_drvclk_o(rx_drvclk_o),	 
	 	
    .gotBIT_o(gotBit), 
    .gotFCT_o(gotFCT), 
    .gotNchar_o(gotNchar), 
    .gotTIME_o(gotTIME), 
    .gotNULL_o(gotNULL), 
    .err_par(err_par), 
    .err_esc(err_esc), 
    .err_dsc(err_dsc), 
   // .RxErr_o(RxErr),      
    .EnRx_i(EnRx), 
	 .Lnk_dsc_o(Lnk_dsc), 
    .C_Send_FCT_i(C_SEND_FCT),      
   // .Vec_Rxfifo( ),     
    .DLL_LOCKED(Rx_DLL_LOCKED), 
    .state_i(state), 
    .reset(RST_rx), 
    .clk10(clk10)	   
    ); 

regFile  inst_regFile (
                          );

endmodule