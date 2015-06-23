//File name=Module name=SPW_FSM  2005-2-18      btltz@mail.china.com    btltz from CASIC  
//Description:   The state exit conditions for SpaceWire encoder-decoder state machine:
//               Coder/Decoder FSM,also called the PPU(Protocol Processing Unit) Controls the overall operation of the link interface
//Abbreviations: FCT:     flow control token
//               N-Char:  normal characters(data or EOP or EEP).   L_Chars:Link characters.
//               EOP:     End_of_packet marcker;     EEP: error End_of_packet marcker.      
//Origin:        SpaceWire Std - Draft-1 of ECSS(European Cooperation for Space Standardization),ESTEC,ESA.
//--     TODO:	  make rtl faster
////////////////////////////////////////////////////////////////////////////////////
//
//
/*synthesis translate off*/
`timescale 1ns/100ps
/*synthesis translate on */
`define gFreq  80
`define ErrorReset  6'b000001
`define ErrorWait   6'b000010
`define Ready       6'b000100
`define Started     6'b001000     
`define Connecting  6'b010000
`define Run         6'b100000
`define reset  1	  // WISHBONE standard reset
`define FOR_SIM
//`define FOR_REAL

module SPW_FSM  //#(parameter DW=8)
               (output [5:0] state_o ,    //state is a global vector signal of the CODEC
                output active_o,      //Active interface
                input  lnk_start,lnk_dis, //Link enable interface, set by software or hardware
					 input  AUTOSTART,
					 
					 output reg LINK_ERR_o,             
                output reg err_sqc,   //err_Nchar or err_FCT as sequence err "should be detected by PPU"

//Interface with Transmitter
				    output RST_tx_o,
					 output reg enTx_o,  //control output to Transmitter
					 input err_crd_i,
//Interface with Receiver
				    output RST_rx_o,
					 output reg enRx_o,   //control output to Receiver 
					 input Lnk_dsc_i,
					 input gotBit_i,                      
                      gotFCT_i,gotNchar_i,gotTime_i,gotNULL_i, 
                      err_par_i,err_esc_i,err_dsc_i,       //input from receiver
//global signal input
                input reset,
                input gclk   /* synthesis syn_isclock = 1 */
                 );
                
                parameter StateNum = 6;
                parameter ErrorReset = `ErrorReset;  //6'b000001;
                parameter ErrorWait  = `ErrorWait;   //6'b000010;
                parameter Ready      = `Ready;       //6'b000100;
                parameter Started    = `Started;     //6'b001000;        
                parameter Connecting = `Connecting;  //6'b010000;
                parameter Run        = `Run;         //6'b100000;	
					                
					 parameter DEFLT      = 6'bxxxxxx;//6'bxxxxxx;

                parameter True = 1,  False = 0;
					 `ifdef FOR_SIM
                parameter NUM_T6_4uS = 10 , NUM_T12_8uS = 20; 
					 `else					
                parameter NUM_T6_4uS = (`gFreq==80) ? (64*8-1) :
					                        (`gFreq==100) ? (64*10-1) :
													(`gFreq==120)  ? (64*12-1)	:
													(`gFreq==50)    ? (64*5-1); 
					 parameter NUM_T12_8uS =(`gFreq==80) ? (128*8-1)  :
					                        (`gFreq==100) ? (128*10-1) :
													(`gFreq==120)  ? (128*12-1) :
													(`gFreq==50)    ? (128*5-1); 
					 `endif
                parameter TIMERW = 14;   //Timer width MAX=16,384. *1ns for 16us

reg [StateNum-1:0] state, next_state/* synthesis syn_encoding="safe,onhot" */;
reg t6_4us,t12_8us;          //The output of the timer indicate if adequate time has elapsed

///////////////////
// Output Generate
//
reg HASgotNULL;
reg HASgotBit;
always @(posedge gclk)
if(reset ||state==ErrorReset)
  begin
  HASgotNULL <= 0;
  HASgotBit <= 0;
  end
else begin
     if(gotNULL_i)
     HASgotNULL <= 1'b1;
     if(gotBit_i)
	  HASgotBit <= 1'b1;
     end

assign RST_tx_o = reset || (state == ErrorReset || state==ErrorWait || state==Ready);
assign RST_rx_o = reset || (state == ErrorReset);
assign state_o = state;
assign lnk_en = ~lnk_dis && ( lnk_start || (AUTOSTART && HASgotNULL) );//internal "lnk_en" to enable link

assign active_o = lnk_en && 
                 ( !Lnk_dsc_i  //indicate Rx is receiving
                  || state==Started || state==Connecting  || state==Run );//indicate Tx is transmitting

////////////////////////////
// err_sqc   made
// Charactor sequence error
always @(posedge gclk)
if(reset)
    err_sqc <= 0;
else begin
     err_sqc <= 0;
     if( gotFCT_i && (state==ErrorWait || state==Ready || state==Started) 
	    || gotNchar_i && state!=Run )
     err_sqc <= 1;  //character sequence error can only occur during initialization.
	  end

//////////////////////
// PPU	(fsm)
//
always @(posedge gclk)
begin:STATES_TRANSFER
  if (reset || lnk_dis || Lnk_dsc_i)
     state <= ErrorReset;  //Initialized state
  else                    // state transfer
     state <= next_state;          
end  //end block "STATES_TRANSFER"

//------ next_state assignment
always @(*)
begin:NEXT_ASSIGN
  //Default Values for FSM outputs:
    /*RST_tx_o = 1'b0;                 //not reset
    RST_rx_o = 1'b0;	*/
    enRx_o = 1'b1;
    enTx_o = 1'b0;	
	 LINK_ERR_o = 1'b0;

  //Use "Default next_state" style ->
    next_state = state;

  case(state)  /* synthesis parallel_case */
         ErrorReset    : begin/*Time-lapse*///Entered when the link interface is reset, when the link is disabled [Link Disabled] in the 
                                            //Run state, or when error conditions occur in any other state.
                           enRx_o = 1'b0;	                         
//The error detecting end shall be reset and re-initialized to recover character synchronization and flow control status.
                           if(lnk_en && t6_4us==True)
                           next_state = ErrorWait;
                         end
         ErrorWait:      begin/*Time-lapse*///Entered from ErrorReset state after being in ErrorReset state for 6,4us
                           if(HASgotBit && lnk_dis  
                             || HASgotNULL && (err_par_i || err_esc_i || gotFCT_i || gotNchar_i || gotTime_i) )
                           next_state = ErrorReset;
                           else if(lnk_en && t12_8us==True)
                             next_state = Ready;
                         end
         Ready/*Temp*/ : begin  //Entered from ErrorWait state after being in ErrorWait state for 12,8us
                           if( HASgotBit && err_dsc_i 
                              || HASgotNULL && (err_par_i || err_esc_i || gotFCT_i || gotNchar_i || gotTime_i) )
                           next_state = ErrorReset;
                           else if(lnk_en)
                           next_state = Started; 
                         end
         Started       : begin   //Entered from Ready state when [LinkEnabled] guard is TRUE
                           enTx_o = 1'b1;                                                  
                           if( (t12_8us==True) ||  //after 12,8us
                                HASgotBit && err_dsc_i || 
                                HASgotNULL && (err_par_i || err_esc_i || gotFCT_i || gotNchar_i || gotTime_i) ) 
                             next_state = ErrorReset;   //GotNULL Timeout
                           else if (gotNULL_i ==True)
                             next_state = Connecting;
                         end
         Connecting    : begin    //Entered from Started state on receipt of gotNULL (which also satisfies First Bit Received)
                          enTx_o = 1'b1;
                          if( (t12_8us==True)     ||  //gotFCT Timeout
                              (err_dsc_i==True) ||   //First Bit Received as part of the gotNULL
                                err_par_i       ||    //First NULL Received is already True in order to enter this state
                                err_esc_i          ||     //First NULL Received is already True in order to enter this state
                                gotNchar_i      ||      //First NULL Received is already True in order to enter this state
                                gotTime_i )         //First NULL Received is already True in order to enter this state                                
                          next_state = ErrorReset;    
                          else if(gotFCT_i==True)
                          next_state = Run;   
                         end
         Run           : begin //Entered from Connecting state when FCT received. First Bit Received and
                                     //gotNULL conditions are TRUE since they were True in Connecting state.
                           enTx_o = 1'b1;	                        
                           if(  lnk_dis
									   || err_dsc_i //First Bit Received is already True since passed through Connecting State
                              || err_par_i //First NULL Received is already True since passed through Connecting State
                              || err_esc_i //First NULL Received is already True since passed through Connecting State
                              || err_crd_i //First NULL Received is already True since passed through Connecting State
                              || err_sqc  )//If the escape error occurs in the Run state then the escape error shall be flagged up to the Network Level as a "link error"   
                           begin
									LINK_ERR_o = 1'b1;
                           next_state = ErrorReset;
                           end
								 end        
           /* Default assignment for simulation */ 
         default : next_state = DEFLT;  
   endcase

end //end block NEXT_ASSIGN(and output assignment)


//////////////////////////////////
// The Timer for 6.4us & 12.8us
reg [TIMERW-1:0] timer;
always @(posedge gclk)
begin:TIMER  	        
  if(reset || (state==Run) || (state==Ready) || ( (state==Started) && gotNULL_i ) )
      begin
		t6_4us <= 1'b0;
		t12_8us <= 1'b0;
		timer <= 0;
		end     
  else if (timer == NUM_T12_8uS) 
       begin
		 t12_8us <= 1'b1;   //Timer overflow pulse to trigger states transform
		 t6_4us <= 1'b0;
       timer <= 0; 			 
       end
  else if ( (state==ErrorReset) && (timer ==NUM_T6_4uS ) )
       begin    
		 t6_4us <= 1'b1; 
		 timer <= 0;  			
		 t12_8us <= 1'b0; 
		 end
  else 
      begin
		 t6_4us <= 1'b0;
		 t12_8us <= 1'b0;  
       timer <= timer + 1'b1;
      end
end   //End block "TIMER" ...

//...................................................................................
endmodule

`undef ErrorReset 
`undef ErrorWait  
`undef Ready      
`undef Started     
`undef Connecting  
`undef Run    
`undef reset