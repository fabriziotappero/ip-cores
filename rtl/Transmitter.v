//File name=Module=Transmitter  2005-2-18      btltz@mail.china.com    btltz from CASIC  
//Description:   Transmitter of the SpaceWire encoder-decoder.    
//Origin:        SpaceWire Std - Draft-1(Clause 8) of ECSS(European Cooperation for Space Standardization),ESTEC,ESA.
//--     TODO:   make the rtl faster
////////////////////////////////////////////////////////////////////////////////////
//
/*synthesis translate off*/
`timescale 1ns/100ps
/*synthesis translate on */
`define gFreq  80	  //low frequence for fpga 
`define ErrorReset  6'b000001
`define ErrorWait   6'b000010
`define Ready       6'b000100
`define Started     6'b001000     
`define Connecting  6'b010000
`define Run         6'b100000
`define reset  1	  // WISHBONE standard reset

module Transmitter  //#(parameter DW=8)
                   (output reg Do,So,    //Transmitter data out & strobe out to LVDS driver                    
                 	  output reg err_crd_o,    
// special input from the receiver
                    input gotFCT_i,   //Input from the Receiver
                                     //The transmitter is responsible for keeping track of the FCTs received
                    input nedsFCT_i,
                    output C_SEND_FCT_o, //output to the osd_cnt in the Rx	
                    input EnTx, //enable tx | disable tx
                    /*input Send_NULLS, Send_FCTs, Send_N_chars, Send_TIME_PATTERNs,*///Input from the PPU
   /***************  input AUTOSTART,	********************/
//interface to the fifo
                    output rdbuf_o, //Output to the fifo
                    input empty_i,
                    input type_i,  //0(data) or 1(EOP or EEP)      
                    input [7:0] TxData_i,   //the data or control flag that need to be transmitted
                 //   input[7:0] Vec_Txfifo,  //the number of the vector of the Tx fifo 
//Time interface                   
                    input TICK_IN,//Only one node in a SpaceWire network should have an active TICK_IN signal.
                    input [1:0] CtrlFlg_i/* synthesis syn_keep=1 */, //two-bit control flag input.Reserved for future use.
                    input [5:0] TIMEin,
//Interface with register to show status or for control
		              output [5:0] CRD_CNT_O,
						  output [6:0]	STATE_O,
						//  input [31:0]SPE_CTL,
						                      
//global signal input
                    input[5:0] state_i,                
                    input reset,   //this reset is from the CODEC FSM(the PPU)
                    input gclk /* synthesis syn_isclock = 1 */
                    );

parameter PaseW  = 14;   //The Width of the parallel-series convert register
                         //Reserve some to further
parameter True = 1;
parameter False = 0;

//Control characters.Go with a parity bit as their prefix(LSB).
parameter FCT  = 3'b001, ESC  = 3'b111,   //"L-Char":Link-characters. 
          EOP  = 3'b101, EEP  = 3'b011;   //or Data-Char are all "N-Char":Normal-characters
parameter NULL = 7'b0010_111;
parameter TIME_PATTERN = 5'b01111; //Go with a parity bit before and 8 bits time value from LSB 2 MSB after

               parameter StateNum = 7;
               parameter RESET        = 7'b0000001;               
               parameter SEND_NULL    = 7'b0000010;           
               parameter SEND_FCT     = 7'b0000100; 
               parameter SEND_DATA    = 7'b0001000;
               parameter SEND_TIME	  = 7'b0010000;
					parameter SEND_EOP     = 7'b0100000;              
               parameter SEND_EEP     = 7'b1000000;  //EEP may be written into the transmitter interface
               parameter DEFLT        =    'bx;
               
               parameter CntW = 10;   //Max:1024.   This width could manipulate from 1G to 1M

                 parameter gFreq = `gFreq;                 
                 parameter RQ = 10;  //Required frequence for transmitting.
                 parameter divNum =  (gFreq==80 && RQ==10) ? 7  : 
					                      ( (gFreq==100 && RQ==10) ? 9  :
												  ( (gFreq==120 && RQ==10) ? 11  :
												   ( (gFreq==50  && RQ==10) ?  4 : 'bx  )))  ;

reg [PaseW-1:0] Pase;     //the parallel-series convert register
//reg [PaseW-1:0] Pase_;  //defined as reg for assignment.Synthesised as wire.Output of combinatorial logic

reg C_SEND_TIME;  //pulse command for sending a time code(2 byte)
reg C_SEND_FCT;   //pulse command for sending a FCT(1 byte)
reg C_SEND_DATA;  //pulse command for sending a DATA(read from fifo,1 byte)
reg C_SEND_EOP;   //pulse command for sending a EOP with a type indication from host "type_i"
reg C_SEND_EEP;   //pulse command for sending a EEP with a type indication from host "type_i"
reg C_SEND_NULL;  //pulse command for sending a NULL for link activation(1 byte)
assign C_SEND_FCT_o = C_SEND_FCT; 

reg [5:0] crd_cnt; //a credit count of the number of characters it has been given permission to send.
                   //indicates the buffer space of the opposite Rx buffer in annother node 
reg p;             //The parity bit
reg StartSend;
reg [StateNum-1:0] state, next_state/* synthesis syn_encoding="safe,onhot" */;
assign STATE_O = state;

wire Sending = StartSend && ( (state_i == `Run)||(state == `Connecting)||(state == `Started ));
wire C_SEND_Nchar = C_SEND_DATA || C_SEND_EOP || C_SEND_EEP;
//................................................................................................
////////////////////////
//The Tx clk generator: 
// Responsible for producing the variable data signalling clock signals used by the transmitter.    
// Due to the use of a global clock in FPGAs , this block is really generating pulse for operation.
//
reg strobe;  //output pulse to the internal of this transmitter  
reg [CntW-1:0] divcnt;	

//After a reset or disconnect initially commence operating at (10¡À1) Mb/s.
//Once in the Run state the transmitter operating rate can be set at any rate between max and min
always @(posedge gclk)   
begin  
 if(reset)  
   begin {divcnt,strobe} <= 0; end
 else if(state_i==`Run || state_i==`Connecting || state_i==`Started)
        begin
		      if(divcnt == divNum)
               begin   divcnt <= 0;  strobe <= 1;   end  
            else
               begin   divcnt <= divcnt + 1; strobe <= 0;  end
        end
end
/*...............................................................................................
///////////////////////////
// Input Signal Processing
//			
wire gotFCT;				 //wire is output of this Unit  								
reg Pro_gotFCT; 
always @(posedge gclk)
begin
if(reset) begin
  Pro_gotFCT <= 1'b0;
  Pro_nedsFCT <= 1'b1;  end
else 
  begin 
  Pro_gotFCT <= gotFCT_i;
  Pro_nedsFCT <= nedsFCT_i;
  end		
assign nedsFCT = nedsFCT_i && !Pro_ceasFCT;
assign gotFCT  = got_FCT_i && !Pro_gotFCT; */
wire gotFCT = gotFCT_i;		    //gotFCT_i is a pulse
wire nedsFCT = nedsFCT_i; 		 //nedsFCT_i is a level 

/////////////////////////////
//Send model control counter
//all data send behavior is controlled 
//
reg [3:0] mccnt;
reg scover_pre;  //overflow of the model control counter
always @(posedge gclk)
begin
  if (reset)
      begin  
		mccnt <= 0;   
		scover_pre <= 0;  
		end 
  else    begin
          scover_pre <= 0;		 
			 if  (strobe &&
			       mccnt==(     (state==SEND_TIME) ?  12   :   //14 bit time-code
                           ( (state==SEND_FCT)  ?   2   :   //4 bit FCT
                           ( (state==SEND_NULL) ?   6   :   //8 bit NULL
                           ( (state==SEND_DATA) ?   8   :    
							      ( (state==SEND_EOP || state==SEND_EEP) ? 2  : 'bx  //4 bit EOP/EEP or 10 bit data 
                           ))))) )
          scover_pre <= 1;  //this overflow signal is just 1 gclk width
			 //else
			 //scover_pre <= 0;

         if(strobe && (state_i != `ErrorWait || state_i != `ErrorReset || state_i != `Ready) ) //if strobe ,count
			    begin 
				 if( mccnt==( (state==SEND_TIME) ?  13   :   //14 bit time-code
                     ( (state==SEND_FCT)  ?   3   :   //4 bit FCT
                     ( (state==SEND_NULL) ?   7   :   //8 bit NULL
                     ( (state==SEND_DATA) ?   9   :	3 )	 //4 bit EOP/EEP or 10 bit data 
							  //(state==SEND_EOP || state==SEND_EEP) 9  
                      ))) )             
             mccnt <= 0;          
             else 
             mccnt <= mccnt + 1'b1;
				 end          
         end
end

//////////////////////////////
// Read synfifo synchronously
//
wire BUF_HAS_NCHAR = !empty_i;
assign rdbuf_o = (state_i==`Run &&  !TICK_IN && crd_cnt==0 && BUF_HAS_NCHAR) ? scover_pre : 0;

///////////////////////////
// DS Output and DS Encode 
//
reg Do_;
always @(posedge gclk)
begin
if(reset || state==RESET)
StartSend <=0;
else if(C_SEND_NULL)
StartSend <= 1'b1;
end

wire Do_gen = (scover_pre==True)  ? p : omux(mccnt,Pase);

always @(posedge gclk)
 if(reset) begin 
          Do <= 1'b0;//After reset or link error the Data and Strobe signals shall be set to zero.
                    //avoiding simultaneous transitions of Data and Strobe signals.
          So <= 1'b0;    end
 else  begin
       Do_ <= Do;    //Do_ is a IMMEDIATE trace of Do 
       if(EnTx && StartSend && strobe)   //to avoid send unwritten "Pase"(blank "Pase")
         begin
			Do <= Do_gen;   //ref the function at bottom 
		   if(Do_gen==Do_) 
         So <= !So;   //Data-Strobe (DS) encoding.The Strobe signal.Change state whenever the Data does not change from one bit to the next.
         end
		 end
/////////////////////
//Parity Gen
//		  
always @(posedge gclk)
if(reset) // fisrt p is 0
 p <= 1'b0;
else if(  (state_i==`Started || state_i==`Connecting || state_i==`Run) && scover_pre)
 p <= 1'b1;
//if(C_SEND_TIME || C_SEND_FCT || C_SEND_Nchar || C_SEND_NULL) 
else if(strobe && Sending)
 p <= p ^ Pase[mccnt];  // <- |0|1|2|3|4|5|6|7|

   /////////////////////////////
  // crd_cnt:   Credit Counter
 //        and err_crd_o made
////////////////////////////////
//If the credit error occurs in the Run state then the credit error shall be flagged up to the Network Level as a "link error"
wire ceasNchar = (crd_cnt==0);          //cease sending Normal char if the opsite Rx has no space any more
always @(posedge gclk)
begin
if(reset)
  begin  
  crd_cnt <= 0; //In PPUstate== ErrorReset the credit count shall be set to zero
  err_crd_o <= 0;
  end 			 //And if PPUstate==ErrorWait	or Started,a FCT also reset the PPU and Tx 
else begin
     if(gotFCT)
     begin 
       err_crd_o <= 0;
       if(crd_cnt>48) /*48+8=56*/ //because 56+8>63
       err_crd_o <= 1;
       else
       crd_cnt <= crd_cnt + 8;//..receives an FCT the transmitter shall increment the credit count by eight.
     end   
     else if(crd_cnt != 0 && ( C_SEND_Nchar ) )
          begin
          crd_cnt <= crd_cnt - 1;  //If the credit count reaches zero the transmitter shall cease sending N_char(and the cnt keep on zero)
          err_crd_o <= 0;
	       end
     end
end
assign CRD_CNT_O = crd_cnt;

///////////////////////////////
//Parallelly write Pase 
//
always@(posedge gclk)
begin:WRT_Pase
if(reset || state==RESET) 
   Pase <= 0;//after reset the first bit that is sent shall be a parity bit, this bit shall be set to zero
else if(EnTx && (C_SEND_TIME || C_SEND_FCT || C_SEND_Nchar || C_SEND_NULL)  )
  begin //When writing to the transmit interface the remaining data bits should be set to zero.
	 case(1'b1)   /* synthesis parallel_case*/
   C_SEND_TIME    :  Pase[13:0] <= {CtrlFlg_i,TIMEin[5:0],TIME_PATTERN,p};  //send system time. TIME = ESC + time code
                  //The MSB two bits of the time input are the two control-flag inputs and are reserved for future use.
   C_SEND_DATA    :  Pase[9:0] <= {TxData_i,1'b0,p};     //10 bit
	C_SEND_FCT     :  Pase[3:0] <= {FCT,p};  //4 bit "L-Char":
	C_SEND_EEP     :  Pase[3:0] <= {EOP,p};  //4 bit
   C_SEND_EOP     :  Pase[3:0] <= {EEP,p};  //4 bit
   C_SEND_NULL    :  Pase[7:0] <= {NULL,p}; //4 bit + 4 bit = 7+1; a NULL = a ESC + a FCT
    default       :  Pase[13:0] <=  'bx;    //for simulation 
    endcase
  end 
end //end WRT_Pase		
  
////////////////////////
//Fsm for control
//          Moore style
always @(posedge gclk)
if(reset==`reset)
  state <= RESET;   //Initialized state
else if(scover_pre)	// Too fast	state gen will cause problems
  state <= next_state;
//------ next_state assignment
always @(*)
begin:NEXT_ASSIGN
  //Default Values for FSM outputs:
    C_SEND_TIME = 0;
	 C_SEND_DATA = 0;    
    C_SEND_FCT = 0;  
    C_SEND_EOP = 0;
    C_SEND_EEP = 0;
	 C_SEND_NULL = 0;  
   //rdbuf_o = 0;
  //Use "Default next_state" style ->
    next_state = state;
      case(state)   /* synthesis parallel_case */
  RESET        :     begin
                       if(state_i==`Started)                       
                         next_state = SEND_NULL;
                      end
  SEND_NULL/*4th*/: begin  //This state only send NULL on the link and doing nothing else
          /*output*/ C_SEND_NULL = 1'b0;
			           if(scover_pre)  
                       C_SEND_NULL = 1'b1;  //when has sended 8, send another NULL
   /*state control*/if(state_i==`Run)
                       begin
                          if(TICK_IN==True) 									   
                             next_state = SEND_TIME;  //1st		                             
								  else if(nedsFCT)								     
                             next_state = SEND_FCT;   //2nd	
                          else if( empty_i==False && ceasNchar==False )
								       begin 
										 if(type_i==0)                                									                                     
                                  next_state = SEND_DATA;												 
                               else if(TxData_i[0]==0)	 										    									
                                  next_state = SEND_EOP;
                               else if(TxData_i[0]==1)	 												 
											 next_state = SEND_EEP;	
										 end											
                       	  //else  no time,no fct,no data, keep send "NULL"
                       end//end "state_i==Run"
                     else if(state_i==`Connecting && nedsFCT)
                             next_state = SEND_FCT;  //higher priority 
									  //else no FCT,keep send "NULL" to wait a "FCT" coming  
                     else if(state_i==`Ready || state_i==`ErrorWait)
                             next_state = RESET;  //err recovery                   
                     end
  SEND_FCT/*2nd*/:   begin   //each FCT = 8 N_char   
                     C_SEND_FCT = 1'b0;                  
          /*output*/ if(scover_pre)  //***
                        C_SEND_FCT = 1'b1;  //command for wrt reg "Pase"
   /*state control*/ if(state_i==`Run)
	                     begin 
                     	if(TICK_IN==True)	
	                     next_state = SEND_TIME; //1st                        
                        else if(nedsFCT==False) 
								     begin
								     if(ceasNchar || empty_i==True)
								     next_state = SEND_NULL; 
								     else if(type_i==0)  //empty_i==False
                             next_state = SEND_DATA; 
								     else if(TxData_i[0]==0)  //type_i==1	 										    									
                             next_state = SEND_EOP;
                             else //TxData_i[0]==1	 												 
								     next_state = SEND_EEP;
									  end	
								end
                      else if(state_i==`Connecting)
							      begin
									if(nedsFCT==False)//needn't to send FCT any more 
								     next_state = SEND_NULL;  
									end                        
                      else	//state != Run or Connecting 
                           next_state = RESET; //if not in Run || Connecting and enter this state,there must be a err
                     end 
  SEND_TIME/*1st*/:    begin                        
             /*output*/if(scover_pre)  //***
                            C_SEND_TIME = 1'b1;   //command for wrt reg "PaSe".priority 1
   /*state control*/   if(state_i == `Run)
                       begin
                         if(TICK_IN == False) 
                           begin 
                             if( nedsFCT )   //needn't send FCTs or data any more
                               next_state = SEND_FCT;    //2nd  
                             else if (ceasNchar || empty_i==True)
									  next_state = SEND_NULL; 
                             else if(type_i==0)	 //crd_cnt==0 && empty_i==False 
									  next_state = SEND_DATA;
                             else if(TxData_i[0]==0)//type_i==1 
                             next_state = SEND_EOP;
                             else //(TxData_i[0]==1)	 												 
									  next_state = SEND_EEP;	                    	                                      
                            end
                          //else if TICK_IN==True, keep send time
                       end //end  state_i == Run
                       else //if not in Run state and enter this state,return to RESET
                           next_state = RESET;	                       
                     end
  SEND_DATA/*3rd*/: begin  //data or EOP or EEP from host interface 
          /*output*/C_SEND_DATA = 1'b0;
				        if(scover_pre)                           
                    C_SEND_DATA = 1'b1;                              
      /*state control*/if(state_i==`Run)
                          begin
                             if(TICK_IN==True)
                                next_state = SEND_TIME;  //1st
                             else if(nedsFCT)
                             next_state = SEND_FCT;  //higher priority
                             else if ( ceasNchar || empty_i==True)
									  next_state = SEND_NULL;
                             else if(type_i==1)
									       begin
                                  if(TxData_i[0]==0)  //if not TICK_IN and crd_cnt==0 and empty
                                    next_state = SEND_EOP;
                                  else //(TxData_i[0]==1)	 												 
										      next_state = SEND_EEP;	 
											 end 
                             //else,keep                          
                           end //end state_i==Run
                        else  //if not in Run and enter this state, there must be a error
                           next_state = RESET;  
                     end
  SEND_EOP		 :  begin
            /*output*/ C_SEND_EOP = 1'b0; 
				           if(scover_pre)                           
                           C_SEND_EOP = 1'b1;                              
      /*state control*/if(state_i==`Run)
                          begin
                             if(TICK_IN==True)
                             next_state = SEND_TIME;  //1st
                             else if(nedsFCT)
                             next_state = SEND_FCT;  //higher priority
                             else if(ceasNchar || empty_i==True)
									  next_state = SEND_NULL;									  
                             else if(type_i==0)
									     next_state = SEND_DATA;
                             else if(TxData_i[0]==1)
									     next_state = SEND_EEP;                            
                             //else,keep                          
                           end  //end state_i == Run
                        else  //if not in Run and enter this state, there must be a error
                           next_state = RESET; 
                   end
  SEND_EEP      :  begin
                      C_SEND_EEP = 1'b0;    
                     if(scover_pre)
							    C_SEND_EEP = 1'b1;                              
      /*state control*/if(state_i==`Run)
                          begin
                             if(TICK_IN==True)
                                next_state = SEND_TIME;  //1st
                             else if(nedsFCT)
                                next_state = SEND_FCT;  //2nd
                             else if(ceasNchar || empty_i==True) //if not TICK_IN and crd_cnt==0 and empty
                                next_state = SEND_NULL;  
                             else if(type_i==0)
									     next_state = SEND_DATA;
                             else if(TxData_i[0]==0)
									     next_state = SEND_EOP;                            
                             //else,keep                          
                           end  //end state_i == Run
                        else  //if not in Run and enter this state, there must be a error
                           next_state = RESET; 
                   end

    default     :    next_state = DEFLT;
   endcase
end //end combinatorial block "NEXT_ASSIGN"


function omux; //parellel to serial conversion,use a mux
   input [3:0] mccnt;
   input [PaseW-1:0] Pase;
begin
   omux = Pase[mccnt];
end
endfunction

/*
                 //   //1. Time-Code, highest priority;
                //   //2. FCTs, high priority;                
                   //   //3. N-Chars,low priority;
                  //   //4. NULL, lowest priority.         */
endmodule

`undef gFreq  
`undef ErrorReset  
`undef ErrorWait   
`undef Ready      
`undef Started         
`undef Connecting  
`undef Run       
`undef reset