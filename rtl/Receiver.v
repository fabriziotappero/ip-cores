//File name=Module=Receiver  2005-2-18      btltz@mail.china.com    btltz from CASIC  
//Description:   Receiver of the SpaceWire encoder-decoder.    
//Abbreviations: dsc  : disconnect
//Origin:        SpaceWire Std - Draft-1(Clause 8)of ECSS(European Cooperation for Space Standardization),ESTEC,ESA.
//--     TODO:	  make rtl faster
////////////////////////////////////////////////////////////////////////////////////
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
`define reset  1	 // WISHBONE standard reset
`define XIL_DEVICE //if use Xilinx Device
//`define HAS_FIFO_VECTOR_IN
`define HAS_RecCLK_O		//the recovery clock

module Receiver  //#(parameter DW=8)
                (output reg  gotBIT_o,
                             gotFCT_o,                        //Output to Transmitter and/or the FSM(PPU)
                             gotNchar_o,gotTIME_o,gotNULL_o,    //gotNull is a level,others are pulse
//5 receive error outputs.Note the err_sqc is formed in the PPU and err_crd is formed in Tx.Note that these are all "Receiver error".            
                 output reg err_par,err_esc,err_dsc,  //Pulse generated when has err                           
//  output RxErr_o,
                 output [5:0] osd_cnt_o,
					  input Si,Di,  //Input from the LVDS's Receiver
                 input EnRx_i,  //from PPU
//Rx vs. Tx
                 input C_Send_FCT_i,   //for osd_cnt operation 
					  output reg nedsFCT_o,	//need sending FCT to info Tx
//interface to the FIFO
                 output reg wrtbuf_o,
                 output reg type_o,  //0(data) or 1(EOP or EEP)      
                 output reg[7:0] RxData_o,  //8 bit width parallel received data or control flag
                 input full_i,  //Indicate the buffer is ready to write
					  `ifdef HAS_FIFO_VECTOR_IN
                 input[7:0] Vec_Rxfifo, //the number of the vector of the Rx fifo
					  `endif  
//Control and clk output
                 output reg Lnk_dsc_o,
					  `ifdef HAS_RecCLK_O
                 output RecClk_o,   //the clk signal from the "RX clock recovery" unit which had been mergeed to the Receiver
					  `endif  
					  output rx_strb_o,         
//output time interface       
                 output reg TICK_OUT,
                 output reg [1:0] CtrlFlg_o, //two-bit control flag output.Reserved for future use.
                 output reg [5:0] TIMEout,    
//global signal input
                 input[5:0] state_i,
                 input reset,   //this reset is from the CODEC FSM(the PPU)
                 input gclk /* synthesis syn_isclock = 1 */
                 );
         //At a link data signalling rate of 10 Mb/s the establish of linking can take just	2 ¦Ìs.
               parameter StateNum =3;
               parameter RESET         = 3'b001;
               parameter HUNTING       = 3'b010;               
               parameter CHECK_CHAR    = 3'b100;
               parameter DEFLT = 'bx;

     parameter CrdCntW = 6;     //"hold a maximum credit count of 56" for 7 FCTs
     parameter RCVW = 14;       //width of the receiver internal register  
	  parameter NUM_NES_FCT = 16;//osd_cnt number that indicate Rx buf has enough space and Tx need to send FCT.For better performence,this parameter may be changed 
	  parameter True = 1;
     parameter False = 0;
   //Control characters.Go with a parity bit as their prefix(LSB).
     parameter FCT  = 3'b001, ESC  = 3'b111,   //"L-Char":Link-characters. 
               EOP  = 3'b101, EEP  = 3'b011;   //or Data-Char are all "N-Char":Normal-characters
     parameter NULL      = 7'b0010_111;
	  parameter isESC_EEP = 7'b0110_111,
	            isESC_EOP = 7'b1010_111,
	            isESC_ESC = 7'b1110_111;
     parameter TIME_PATTERN = 5'b01111; //Go with a parity bit before and 8 bits time value from LSB 2 MSB after
     parameter NUM_DSC = 9;

reg [RCVW-1:0] rereg;  //posthouse,is the front end of the Rx to receive signal ceaselessly;
              // P /Flag/...data .../
//reg rereg1;  //Trace of the rereg[1]


reg [3:0] mccnt;
reg scover_pre;  //overflow of the model control counter	  
reg scover; //1 clk later
//reg err_dsc;  //disconnect err.When no new data bit is received within a link disconnect timeoutwindow (850 ns)

reg p;  //register for parity generate
reg p_1;//keep the result of the Parity Generate  
//reg C_ParCheck;

reg [5:0] osd_cnt;   //count of the number of outstanding N-Chars it expects to receive
                  //Max(6bits) = 64,so crd_cnt[max] = 56 
assign  osd_cnt_o = osd_cnt;
reg CcTIME,CcNchar;       //command to collect time/Nchar from rereg for send
reg wrtbuf_itl;	//wire in true
reg [StateNum-1:0] state,next_state/*synthesis syn_encoding="safe,onehot"*/;

wire isTIME= (rereg[5:1]==TIME_PATTERN) ?   1'b1  :  1'b0;	
wire isEOP =  (rereg[3:1]==EOP ) ?  1'b1  :  1'b0;
wire isEEP =  (rereg[3:1]==EEP ) ?  1'b1  :  1'b0;
wire isFCT =  (rereg[3:1]==FCT ) ?  1'b1  :  1'b0;
wire isDATA = (rereg[1]==0)      ?  1'b1  :  1'b0;
wire isNULL    = (rereg[6:0]==NULL) ?  1'b1  :  1'b0; //quik combinatorial output for "mccnt" operation
wire isESC_ERR = (rereg[6:0]==isESC_EOP 
                ||rereg[6:0]==isESC_EEP
					 ||rereg[6:0]==isESC_ESC ) ?  1'b1  :  1'b0;
reg    isNULL_1,
       isEOP_1,
       isEEP_1,
       isFCT_1,
       isDATA_1,
       isTIME_1;    

//wire pre_par_ok = (p==rereg[0])  ?  1'b1  :  1'b0; 

//..............................................................................
///////////////////////
// Rx clk recovery:    
//    Provides all the clock signals used by the receiver with the exception of the local clock signal use
//         for disconnect timeout.
//    Note that the "Si" and "Di" are all SYNchronoused to avoid the metastable
//   	     in FPGA so they are all orderly now !!!
reg strobe;
reg Si1,Di1;
wire RecClk = Si ^ Di;  //1 XOR
assign RecClk_o = RecClk;

always @(posedge gclk)
if(reset)
  {strobe,Si1,Di1} <= 0;
else 
  begin
  Si1 <= Si;
  Di1 <= Di;
  strobe <= 0;
  if( (Si1 != Si) 			//   XOR 
     || (Di1 != Di) )		//			\ OR---> strobe  
  strobe <= 1'b1;				//	  	   /
      							//	  XOR
  end

assign rx_strb_o = strobe;

// wire LocalRx_err = err_dsc || err_esc || err_par;   


//////////////////////
// Receive data 
//    and take that
always @(posedge  gclk )  //As long as RecCLK presences,store the received scan beam to the temp reg "rereg"
begin
 if(reset)   
   rereg <= 0;   
 else if(EnRx_i && strobe)
   begin
   rereg[mccnt] <= Di;
   // rereg1 <= rereg[1];   
   end
end

////////////////////////////////////////////////////////
//Parity Gen
//    and parity okey

//The new received parity bit is ready when scover==1 and is
//  reposited in rereg[0]
//The local generated p is ready when "CHECK_CHAR"
assign par_ok = (EnRx_i==1 && scover==1)  ? (p_1==rereg[0] ? 1 :0 ) :  0 ;
					         //Preliminary Check
always @(posedge gclk)
if(reset || scover_pre)
  p <= 1'b1;           //when scover_pre,refresh p,and the local parity result is stored in p_1
else if(strobe==True)
  begin
     p <= p ^ rereg[mccnt];
     p_1 <= p;  
  end      

//////////////////////
// osd_cnt assignment
//	 
always @(posedge gclk)
begin
   if(reset || Lnk_dsc_o)
   begin
	  nedsFCT_o <= 1;
	  osd_cnt <= 0;		  //After a link reset or after a link disconnect, the initial value of the outstanding
                         //count shall be zero. Means that the transmitter need to 
   end
	else begin
	     if(osd_cnt>48) 
		    nedsFCT_o <= 1'b0;      //level
        else	if(osd_cnt <= NUM_NES_FCT)
		    nedsFCT_o <= 1'b1;      //This event start the Tx to send FCTs
	     
		  if(C_Send_FCT_i &&(osd_cnt < 49) )   //osd_cnt[max] <= 56  because 56+8>63   
        osd_cnt <= osd_cnt + 8;               
        else if(gotNchar_o)	               //decrement by one each time an N-Char is received
        osd_cnt <= osd_cnt - 1;
		  end
end

//////////////////////////////////////
//RECEIVE model control counter
// for receive operation control
reg start_mccnt;

always @(posedge gclk)
if(reset) //reset from PPU when global reset or state_i==`ErrorReset
  {scover_pre,scover,mccnt,start_mccnt} <= 0;
else 
   begin
     scover_pre <= 0;
     scover <= scover_pre;  //scover is the real overflow of "mccnt"
      if( (mccnt==2)&&( isFCT ||isEOP || isEEP ) 
         || (mccnt==6)&&( isNULL )//scover_pre is 1 clock earlier than the real overflow of the "mccnt"
         || (mccnt==8)&&( isDATA )//to quikly indicate that data in "rereg" is ready to check
         || (mccnt==12)&&( isTIME )  )
         
         scover_pre <= 1;

     start_mccnt <= 1;  //start_mccnt is 1 clock latency so "mccnt" can count as a normal counter and "0" indicates a data
     if( strobe &&
	      ( (mccnt==3)&&( isFCT ||isEOP || isEEP ) 
         || (mccnt==7)&&( isNULL )
         || (mccnt==9)&&( isDATA )
         || (mccnt==13)&&( isTIME )  )
		 )
        
          mccnt <= 0;       
     else if(start_mccnt && strobe)
       mccnt <= mccnt + 1'b1;
   end

   ///////////////////////////////////////////////////////
  //err_dsc  Generate      //when the length of time since the last transition on the D or S lines was
 //                       // longer than 850 ns nominal
////////////////////////////////////////////////////////
//If the disconnect error occurs in the Run state then the disconnect error shall
//be flagged up to the network level as a link error

reg[3:0] edcnt; //850ns = 8.5 * 100ns, so max = 9. (error_disconnect counter)
wire rst_edcnt = reset || RecClk;
always @(posedge gclk)
if(rst_edcnt)  //if Rec2CLK is high,clear "edcnt"
  {edcnt,err_dsc} <= 0;
else if(gotBIT_o==True)
     begin
	  if(!RecClk)     //if Rec2CLK is low,increase the edcnt. If there is signal at D or S,Rec2CLK must appear!
      begin
       err_dsc <= 1'b0;
       if(edcnt==NUM_DSC)
   	  begin
	     err_dsc <= 1'b1;  //if disconnect,pulse periodically
		  edcnt <= 0;
         end
	     else
	     edcnt <= edcnt + 1'b1;
      end
	  end

always @(posedge gclk)
if(rst_edcnt)
  Lnk_dsc_o <= 0;	  //Lnk_dsc_o is a lecel corresponds to the "err_dsc"
else if(err_dsc)
  Lnk_dsc_o <= 1;

///////////////////////////////////////////////
//Register the data pattern identificate result
//
always @(posedge gclk)
if(reset)
  { isNULL_1, isEOP_1, isEEP_1, isFCT_1, isDATA_1, isTIME_1 } <= 0;
else if(scover_pre)
   { isNULL_1, isEOP_1, isEEP_1, isFCT_1, isDATA_1, isTIME_1  } 
<= { isNULL,   isEOP,   isEEP,   isFCT,   isDATA,   isTIME  };

///////////////////////////////////////////////
//Output Time and N_Char(data/EOP/EEP)
//
always @(posedge gclk)  //if Rec2CLK die,use system clk to write.
if(reset)
  {CtrlFlg_o,TIMEout,type_o} <= 0;  
else if (CcTIME==True)
         begin
            CtrlFlg_o <= rereg[13:12];   
            TIMEout <= rereg[11:6];
         end
else if (CcNchar==True)
        begin	
		      wrtbuf_o <= wrtbuf_itl;
            case (1'b1) /* synthesis parallel_case */	              
             isDATA_1 :  begin
       			          type_o <= 0;  //flag == 0
       			          RxData_o <= rereg[9:2];
       			          end
             isEOP_1  :  begin
       				       type_o <= 1;
       				       RxData_o <= 8'b0000_0000;//flag==1 xxxxxxx0 (use 00000000) EOP
        				       end
             isEEP_1  :	//remote EEP
       				       begin
       				       type_o <= 1;
       				       RxData_o <= 8'b0000_0001;//flag==1 xxxxxxx1 (use 00000001) EEP
       				       end               
               default : begin
					            type_o <= 'bx;
									RxData_o <= 'bx;
                         end
             endcase
		 end
/////////////////////////
// control FSM
//
reg gotNULL_itl;  //a wire that has the value of gotNULL_o
always @(posedge gclk)
if(reset==`reset)
    begin
    state <= RESET;   //Initialized state
	 gotNULL_o <= 1'b0;
	 end		   
else 
   begin
     state <= next_state;
     
     gotNULL_o <= gotNULL_itl; //register the gotNULL_itl
   end
//------ next_state assignment
always @(*)
begin:NEXT_ASSIGN
  //Default Values for FSM outputs:
    gotBIT_o  = 1'b0;
    gotTIME_o = 1'b0;
    gotFCT_o  = 1'b0;
    gotNchar_o = 1'b0;  
    gotNULL_itl  = 1'b0;  //gotNULL_o is a level output
    TICK_OUT = 1'b0;
   // C_ParCheck = 1'b0;
    CcTIME = 1'b0;
    CcNchar = 1'b0;
    err_par = 1'b0;
	 err_esc = 1'b0;
    wrtbuf_itl = 1'b0; 
  //Use "Default next_state" style ->
    next_state = state;
      case(state)   /* synthesis parallel_case */
  RESET        :  begin
                    if(state_i==`ErrorWait)
                       next_state = HUNTING;
                  end
  HUNTING      :  begin  //Stay state. //common because the first parity bit is 0,so Si must jump high first
                    gotNULL_itl = gotNULL_o;  //keep a level
                    if(scover_pre) 
                      begin                      
                        gotBIT_o = 1'b1;  //pulse 
                        next_state = CHECK_CHAR;                        
                      end                      
                  end                  
  CHECK_CHAR   :  begin //Temporary state 
                    if(par_ok)
                    begin  
                       next_state = HUNTING;                             
                       if(isFCT_1)
                       gotFCT_o = 1;  //4 bit FCT                                                
                       else if(isNULL_1)   //8 bit NULL
                          begin
                          gotNULL_itl = 1'b1;   //gotNull is a level                           
                          end   
                       else if( isEOP_1 || isEEP_1 || isDATA_1 ) 
                          begin
								  gotNchar_o = 1;  // 10bit data or 4bit EOP/EEP (are all Nchar)                                               
								  CcNchar = 1'b1;  //Command to collect Normal character
								  if(state_i==`Run && !full_i)
								  wrtbuf_itl = 1;      	                            
                          end         
                       else if(isTIME_1) 
                          begin
                          gotTIME_o = 1;  //inform the PPU
								  CcTIME = 1'b1; //Command to collect Time
                          if(state==`Run)  
								  TICK_OUT = 1;  
                          end 
                       else if(isESC_ERR && state_i==`Connecting)
							     begin
								    if(state_i==`Connecting || state_i==`Run) //after	the first NULL is received.
								    begin
								    err_esc = 1'b1;
								    next_state = RESET;
								    end
								  end
							end                       
                    else  //if the preliminary parity bit check is wrong 		
							  if(state_i==`Connecting || state_i==`Run)
							  begin
							  err_par = 1'b1;	//Parity detection shall be enabled whenever the receiver is enabled after the first NULL is received.
//If the parity error occurs in the Run state then the parity error shall be flagged up to the  Network Level as a "link error"                      
							  next_state = RESET;
							  end
                    end	
    default    :    next_state = DEFLT;
   endcase
end //end combinatorial block "NEXT_ASSIGN"


/*
function[RCVW-1:0] rcv_allocate;  //mux instead LSR  
input din;
input [3:0] sel;
begin
   rcv_allocate =0; 
  case(sel)
    4'd0  :  rcv_allocate[0] = din;
	 4'd1  :  rcv_allocate[1] = din;
	 4'd2  :  rcv_allocate[2] = din;
	 4'd3  :  rcv_allocate[3] = din;
	 4'd4  :  rcv_allocate[3] = din;
	 4'd5  :  rcv_allocate[5] = din;
	 4'd6  :  rcv_allocate[6] = din;
	 4'd7  :  rcv_allocate[7] = din;
	 4'd8  :  rcv_allocate[8] = din;
	 4'd9  :  rcv_allocate[9] = din;
	 4'd10 :  rcv_allocate[10] = din;
	 4'd11 :  rcv_allocate[11] = din;
	 4'd12  :  rcv_allocate[12] = din;
	 4'd13  :  rcv_allocate[13] = din;
	 default : rcv_allocate = 'bx;
  endcase
 
end
endfunction	*/

//...................................................................................

endmodule
`undef ErrorReset 
`undef ErrorWait  
`undef Ready      
`undef Started     
`undef Connecting  
`undef Run         
`undef reset  	 
`undef XIL_DEVICE