//File name=Module name=WB_COMI_HOCI   2005-3-18      btltz@mail.china.com      btltz from CASIC,China  
//Description:   SpaceWire WISHBONE interface for communication mem(COMI) and Host controller(HOCI)  
//Spec       :   Use Little Endian internal
//Abbreviations: WB     --- WISHBONE (SoC interconnection architecture)
//               COMI   --- COmmunication Memory Interface
//               HOCI   --- HOst Control Interface 
//Origin:        WISHBONE Specification Revision B.3; SpaceWire Std - Draft-1 of ESTEC,ESA
//--     TODO:
////////////////////////////////////////////////////////////////////////////////////
//
/*synthesis translate_off*/
`include "timescale.v"
/*synthesis translate_on */
`define reset    1        // WISHBONE Style reset 

module WB_COMI_HOCI #(parameter CM_AW=16,CM_DW=32,
                                H_DW=32,H_AW=5,    // width==3 to select max 16 registers(include 2*3 transceiver FIFO) 
                                IOBUF_DW=9)
                 ( 
// COMI interface(WISHBONE MASTER interface) to a "communication memory",a dpRAM		     
                                     output [CM_AW-1:0] CM_ADR_o,	 
                                     output [CM_DW-1:0] CM_DAT_o, //because some FPGA and ASIC devices do not support bi-directional signals so have not use "inout" 
                                     output [3:0] CM_SEL_o,
                                     output CM_WE_o,
						 //output CM_STB0_o,
                                     //output CM_STB1_o, 
                                     output CM_STB_o,                                    					 				
						 input [CM_DW-1:0]  CM_DAT_i, 				
						 input CM_ACK_i,
                                  // Pins to Support sharing a communication memory between 2 SpW interfaces. 
                                     output COC_o,
                                     input COC_i,                              		           
                                     // note that memory circuit does not have a reset input.	

// HOCI interface(WISHBONE SLAVE interface) to host such as a uP 
			          output [H_DW-1:0] H_DAT_o, 
                            output [3:0] TGD_o,                         // data tag type output
                                     output reg H_ACK_o, 		
                                     output reg H_ERR_o,
                                     output reg H_RTY_o,
                                     input  [H_AW-1:0] H_ADR_i,
                                     input  [H_DW-1:0] H_DAT_i,
                                     input  [3:0] H_TGD_i,                 // data tag type input
                                     input  [3:0] H_SEL_i,                                     
						 input  H_WE_i,	
                                     input  H_CYC_i,  								
						 input  H_STB_i, 					 							 

						 output reg H_INT_o,                     // TAG. interrupt request line
  
// interface to 3 channels( CODEC + Glue Logic ) 
                               output     wr_tx1buf_o,
					     output [IOBUF_DW-1:0] tx1buf_data_o,
					     input  tx1buf_full_i,
                               output     wr_tx2buf_o,
					     output [IOBUF_DW-1:0] tx2buf_data_o,
					     input  tx2buf_full_i,
                               output     wr_tx3buf_o,
					     output [IOBUF_DW-1:0] tx3buf_data_o,
					     input  tx3buf_full_i,

					 output    rd_rx1buf_o,
					     input [IOBUF_DW-1:0] rx1buf_data_i,
					     input rx1buf_empty_i,
                                   input rx1buf_Afull_i,
                               output    rd_rx2buf_o,
					     input [IOBUF_DW-1:0] rx2buf_data_i,
					     input rx2buf_empty_i,
                                   input rx2buf_Afull_i,
                               output    rd_rx3buf_o,
					     input [IOBUF_DW-1:0] rx3buf_data_i,
					     input rx3buf_empty_i,
                                   input rx3buf_Afull_i,
// global input signals
                   input RST_i, CLK_i
						 );
                             
                             parameter DFLT_LOC_LOC = 16'h10;
                             parameter DFLT_SPE = 40;                             
                             parameter DFLT_CTR_TX = ;                                       
                             parameter DFLT_CTR_RX = ;
                             parameter DFLT_WB_CTR = ;
                             parameter DFLT_COMI_ACR = ;
                             parameter DFLT_PKT_SIZE = 8;
                             parameter DFLT_COMI_CH_SEL = 0;

                             parameter ADDR_LOC_LOC   = 4'h00;
                             parameter ADDR_SPE1      = 4'h01;                                       
                             parameter ADDR_CTR_STA1  = 4'h02;
                             parameter ADDR_SPE2      = 4'h03;                                       
                             parameter ADDR_CTR_STA2  = 4'h04;
                             parameter ADDR_SPE3      = 4'h05;                                       
                             parameter ADDR_CTR_STA3  = 4'h06;
                             parameter ADDR_WB_CTR    = 4'h07;
                             parameter ADDR_CH1T_FIFO = 4'h0A;
                             parameter ADDR_CH1R_FIFO = 4'h0B;
                             parameter ADDR_CH2T_FIFO = 4'h0C;
                             parameter ADDR_CH2R_FIFO = 4'h0D;
                             parameter ADDR_CH3T_FIFO = 4'h0E;
                             parameter ADDR_CH3R_FIFO = 4'h0F;  
                             paremeter ADDR_CH1TXSE   = 4'h11;
                             parameter ADDR_CH1RXSE   = 4'h12;
                             parameter ADDR_CH2TXSE   = 4'h13;
                             parameter ADDR_CH2RXSE   = 4'h14;
                             parameter ADDR_CH3TXSE   = 4'h15;
                             parameter ADDR_CH3RXSE   = 4'h16;
                        parameter EOP = 9'b1_0000_0000;
                        parameter EEP = 9'b1_0000_0001;     
parameter True = 1;
parameter False = 0;


////////////////////
// registers  
//

`inculde  "RegSpW.v"

wire COMI_DIS = (COMI_ACR ==0);                     // disable COMI interface

///////////////////////////////////////////////////////////////////////////////////////////////////////////
// WISHBONE memory interface form "COMI"( COmmunication Memory Interface ).
// The mem may be a dpMEM which could be considered as "FASM":FPGA and ASIC Subset Model(asynchronous read).
//
reg [CM_AW-1:0] Agen_rx;                     // COMI receiver address generator
reg [CM_AW-1:0] Agen_tx;                     // COMI transmitter address generator  
wire CM_wr_txbuf1, CM_wr_txbuf2, CM_wr_txbuf3;
wire CM_rd_rxbuf1, CM_rd_rxbuf2, CM_rd_rxbuf3; 

/////// COMI autonomous accesses to the communication memory or read data to be transmitted //////////////
reg [1:0] gracnt_DI ;                           // granularity = 8  for WISHBONE 'DAT_I'
reg ov_gra_DI;                    
reg CM_STB_RD;


always @(posedge CLK_i)
if(CM_AB2TX_GO ==True)
  gracnt <= 0;
else if(CM_STB_RD ==True)
  begin
    gracnt_DI <= gracnt_DI + 1;
    if(gracnt_DI==3) 
       ov_gra_DI <= 1;
    else
       ov_gra_DI <= 0;
  end

// read data to be transmitted 
always @(posedge CLK_i)
if(reset)
  CM_STB_RD <= 0;
else if( |CM_AB2TX_GO == 1) 
  begin
  CM_AB2TX_GO <= 0;                          // clear first
  CM_RD_itl <= 1'b1;  
  end
else if( (   COMI_CH_SEL ==1 && Agen_tx ==CH1_TX_EAR 
          || COMI_CH_SEL ==2 && Agen_tx ==CH2_TX_EAR 
          || COMI_CH_SEL ==3 && Agen_tx ==Ch3_TX_EAR  
         )  && CM_SEL_o[3] ==1'b1 
       )    
  CM_RD_itl <= 0;
always @(posedge CLK_i)
if(reset)
  CM_STB_RD <= 0;
else if (  (   |CM_AB2TX_GO ==1    ||   CM_RD_itl ==1     )  && 
           (  COMI_CH_SEL ==1 && tx1buf_full_i ==False 
             || COMI_CH_SEL ==2 && tx2buf_full_i ==False
             || COMI_CH_SEL ==3 && tx3buf_full_i ==False  )
        )
     CM_STB_RD <= 1;
else 
     CM_STB_RD <= 0;
       

        // Agen_tx
always @(posedge CLK_i)
if( |CM_AB2TX_GO == 1)   // load 'Agen_tx'
  begin
    case(COMI_CH_SEL)    // synthesis parallel_case full_case
      2'b01    :     Agen_tx <= CH1_TX_SAR;
      2'b10    :     Agen_tx <= CH2_TX_SAR;
      2'b11    :     Agen_tx <= CH3_TX_SAR;
      default  :     Agen_tx <= 'bx;
    endcase
  end
else if(   CM_STB_RD ==True                       // 1 clk latency after 'CM_AB2TX_GO'
        && ov_gra_DI )
     Agen_tx <= Agen_tx + 1;

assign CM_ADDR_o = Agen_tx;                       // address output
assign CM_SEL_o = ( CM_STB_o ==1'b1 )  ?  
                                       ( gracnt_DI ==0   ?   4'b0001  :  
                                           ( gracnt_DI ==1   ?   4'b0010  :
                                           ( gracnt_DI ==2   ?   4'b0100  :
                                           ( gracnt_DI ==3   ?   4'b1000  :   4'hx )))  
                                        )
                                       : 4'b'b0;         // note i assume that the synthesis tool support to translate it to be parallel. Most tools do this now. 

assign CM_wr_txbuf1 = ( COMI_CH_SEL ==1 && CM_STB_RD )  ?  1'b1  :  1'b0;
assign CM_wr_txbuf2 = ( COMI_CH_SEL ==2 && CM_STB_RD )  ?  1'b1  :  1'b0;
assign CM_wr_txbuf3 = ( COMI_CH_SEL ==3 && CM_STB_RD )  ?  1'b1  :  1'b0;


// write to the communication memory from RX FIFO
reg [1:0] gracnt_DO;                          // granularity = 8 for WISHBONE 'DAT_O'
reg ov_gra_DO,
reg CM_STB_WR;
reg CM_WE_itl;     

always @(posedge CLK_i)
if(CM_RX2AB_GO ==True)
  gracnt_DO <= 0;
else if(CM_STB_WR ==True)
  begin
    gracnt_DO <= gracnt_DO + 1;
    if(gracnt_DO==3) 
       ov_gra_DO <= 1;
    else
       ov_gra_DO <= 0;
  end

always @(posedge CLK_i)
if(reset)
  begin
  CM_WE_itl <= 0;
  CM_R <= 0;
  end
else if( |CM_AB2TX_GO == 1) 
  begin
  CM_RX2AB_GO <= 0;                          // clear first
  CM_STB_WR <= 1;
  
  end
else if(  (    COMI_CH_SEL ==1 && Agen_rx ==CH1_RX_EAR  
            || COMI_CH_SEL ==2 && Agen_rx ==CH2_RX_EAR  
            || COMI_CH_SEL ==3 && Agen_rx ==Ch3_RX_EAR 
          ) && CM_SEL_o[3] ==1'b1
         )    
     begin
       CM_WE_itl <= 0;
  CM_STB_WR <= 0;


always @(posedge CLK_i)
if( |CM_RX2AB_GO == 1)   // load 'Agen_tx'
  begin
    case(COMI_CH_SEL)    // synthesis parallel_case full_case
      2'b01    :     Agen_rx <= CH1_RX_SAR;
      2'b10    :     Agen_rx <= CH2_RX_SAR;
      2'b11    :     Agen_rx <= CH3_RX_SAR;
      default  :     Agen_rx <= 'bx;
    endcase
  end
else if(   CM_STB_WR ==True                       // 1 clk latency after 'CM_AB2TX_GO'
        && ov_gra_DO )
     Agen_rx <= Agen_rx + 1;

assign CM_ADDR_o = Agen_tx;                       // address output
assign CM_SEL_o = ( CM_STB_o ==1'b1 )  ?  
                                       ( gracnt_DI ==0   ?   4'b0001  :  
                                           ( gracnt_DI ==1   ?   4'b0010  :
                                           ( gracnt_DI ==2   ?   4'b0100  :
                                           ( gracnt_DI ==3   ?   4'b1000  :   4'hx )))  
                                        )
                                       : 4'b'b0;         

      





assign CM_WE_o = CM_WE_itl;                  // default 'CM_WE_o' is 'read'(low level)
assign CM_DAT_o = (); 
assign CM_STB_o = CM_STB_RD || CM_STB_WR;

function [31:0] SEL_RX2CM_SRC;                      // From Channel ? to COMI; COMI only access FIFOs.  
input [1:0] COMI_CH_SEL;
input [8:0] rxbuf1_data_i;
input [8:0] rxbuf2_data_i;
input [8:0] rxbuf3_data_i;
begin
 case(COMI_CH_SEL)  // synthesis parallel_case 
  2'b01  :    SEL_RX2CM_SRC[31:0]  =  { rxbuf1_data_i[7:0], rxbuf1_data_i[7:0], rxbuf1_data_i[7:0], rxbuf1_data_i[7:0] };
  2'b10  :    SEL_RX2CM_SRC[31:0]  =  { rxbuf2_data_i[7:0], rxbuf2_data_i[7:0], rxbuf2_data_i[7:0], rxbuf2_data_i[7:0] };
  2'b11  :    SEL_RX2CM_SRC[31:0]  =  { rxbuf3_data_i[7:0], rxbuf3_data_i[7:0], rxbuf3_data_i[7:0], rxbuf3_data_i[7:0] };
 default :    SEL_RX2CM_SRC[31:0]  =  32'hxxxx;
end 
endfunction
////////////end channel sel/////////



///////////////////////////////////////////////////////////////////////////////////////////////////////////
// WISHBONE Slave to form "HOCI"( HOst Control Interface ).
// The host may be a uP, FPGA, etc.
//

/*reg [31:0] H_SLV_LATCH;

// latch HOCI WISHBONE Slave DAT&TGD input 
always @(posedge CLK_i)
if( H_CYC_i && H_WE_i && H_STB_i )
  begin
  case(H_SEL_i)    // synthesis parallel_case
  4'b0001    :    H_SLV_LATCH[7:0]   <= H_DAT_i[7:0];
  4'b0010    :    H_SLV_LATCH[15:8]  <= H_DAT_i[15:8];
  4'b0100    :    H_SLV_LATCH[23:16] <= H_DAT_i[23:16];
  4'b1000    :    H_SLV_LATCH[31:24] <= H_DAT_i[31:24];
   default   :    H_SLV_LATCH  <= 'bx;
  end
*/

reg H_wr_txbuf1, H_wr_txbuf2, H_wr_txbuf3;
reg H_rd_rxbuf1, H_rd_rxbuf2, H_rd_rxbuf3;


////////////////////// HOCI Write SpW registers /////////////////////////////////
always @(posedge CLK_i)
begin
  if(RST_i==`reset)
    begin
    LOC_LOC  <= DFLT_LOC_LOC;
    SPE_CTL1 <= DFLT_SPE ;
    SPE_CTL2 <= DFLT_SPE ;
    SPE_CTL3 <= DFLT_SPE ;
         CTL_TX1 <= DFLT_CTR_TX;
         CTL_RX1 <= DFLT_CTR_RX;
                 CTL_TX2 <= DFLT_CTR_TX;
                 CTL_RX2 <= DFLT_CTR_RX;
                         CTL_TX3 <= DFLT_CTR_TX;
                         CTL_RX3 <= DFLT_CTR_RX; 
    WB_CTR <= DFLT_WB_CTR;
    COMI_ACR <= DFLT_COMI_ACR;
    COMI_CH_SEL <= DFLT_COMI_CH_SEL;                
    end   

  else if( H_CYC_i && H_WE_i && H_STB_i )     // Write
       begin
        case( {H_ADR_i,    H_SEL_i} )     // synthesis full_case   parallel_case  // here full_case directive to substitute long default assignment
            {ADDR_LOC_LOC, 4'b0001}    :     LOC_LOC <= H_DAT_i[ 7:0];
            {ADDR_LOC_LOC, 4'b0010}    :     LOC_LOC <= H_DAT_i[15:8];
            {ADDR_SPE1,    4'b0001}    :   SPE_CTL1[7:0] <= H_DAT_i[ 7:0];
            {ADDR_SPE1,    4'b0010}    :   SPE_CTL1[15:8] <= H_DAT_i[15:8];       // write to status register results no effect
            {ADDR_CTR_STA1,4'b0001}    :     CTL_RX1 <= H_DAT_i[ 7:0];  
            {ADDR_CTR_STA1,4'b0010}    :     CTL_TX1 <= H_DAT_i[15:8];
            {ADDR_SPE2,    4'b0001}    :   SPE_CTL2[7:0] <= H_DAT_i[ 7:0];
            {ADDR_SPE2,    4'b0010}    :   SPE_CTL2[15:8] <= H_DAT_i[15:8]; 
            {ADDR_CTR_STA2,4'b0001}    :     CTL_RX2 <= H_DAT_i[ 7:0];  
            {ADDR_CTR_STA2,4'b0010}    :     CTL_TX2 <= H_DAT_i[15:8];
            {ADDR_SPE3    ,4'b0001}    :   SPE_CTL3[7:0] <= H_DAT_i[ 7:0];
            {ADDR_SPE3    ,4'b0010}    :   SPE_CTL3[15:8] <= H_DAT_i[15:8];                                 
            {ADDR_CTR_STA3,4'b0001}    :     CTL_RX3 <= H_DAT_i[ 7:0];  
            {ADDR_CTR_STA3,4'b0010}    :     CTL_TX3 <= H_DAT_i[15:8];
            {ADDR_WB_CTR,  4'b0001}    :   begin                                             
                                             COMI_CH_SEL <= H_DAT_i[ 7:6];
                                             CM_AB2TX_GO <= H_DAT_i[ 3:2];
                                             CM_RX2AB_GO <= H_DAT_i[ 1:0];
                                           end                                             
            {ADDR_WB_CTR,  4'b0010}    :   PKT_SIZE <= H_DAT_i[15:14];
            {ADDR_WB_CTR,  4'b0100}    :   COMI_ACR <= H_DAT_i[23:20];
            {ADDR_WB_CTR,  4'b1000}    :   WB_CTR   <= H_DAT_i[31:30];

            /*writing FIFO is not performed here*/  

            {ADDR_CH1TXSE, 4'b0001}    :   CH1_TX_SAR[ 7:0]  <= H_DAT_i[7:0];
            {ADDR_CH1TXSE, 4'b0010}    :   CH1_TX_SAR[15:8]  <= H_DAT_i[15:8];    
            {ADDR_CH1TXSE, 4'b0100}    :   CH1_TX_SAR[23:16] <= H_DAT_i[23:16];
            {ADDR_CH1TXSE, 4'b1000}    :   CH1_TX_SAR[31:24] <= H_DAT_i[31:24];
            {ADDR_CH1RXSE, 4'b0001}    :   CH1_RX_SAR[ 7:0]  <= H_DAT_i[7:0];
            {ADDR_CH1RXSE, 4'b0010}    :   CH1_RX_SAR[15:8]  <= H_DAT_i[15:8];
            {ADDR_CH1RXSE, 4'b0100}    :   CH1_RX_SAR[23:16] <= H_DAT_i[23:16];
            {ADDR_CH1RXSE, 4'b1000}    :   CH1_RX_SAR[31:24] <= H_DAT_i[31:24]; 

            {ADDR_CH2TXSE, 4'b0001}    :   CH2_TX_SAR[ 7:0]  <= H_DAT_i[7:0];
            {ADDR_CH2TXSE, 4'b0010}    :   CH2_TX_SAR[15:8]  <= H_DAT_i[15:8];    
            {ADDR_CH2TXSE, 4'b0100}    :   CH2_TX_SAR[23:16] <= H_DAT_i[23:16];
            {ADDR_CH2TXSE, 4'b1000}    :   CH2_TX_SAR[31:24] <= H_DAT_i[31:24];
            {ADDR_CH2RXSE, 4'b0001}    :   CH2_RX_SAR[ 7:0]  <= H_DAT_i[7:0];
            {ADDR_CH2RXSE, 4'b0010}    :   CH2_RX_SAR[15:8]  <= H_DAT_i[15:8];
            {ADDR_CH2RXSE, 4'b0100}    :   CH2_RX_SAR[23:16] <= H_DAT_i[23:16];
            {ADDR_CH2RXSE, 4'b1000}    :   CH2_RX_SAR[31:24] <= H_DAT_i[31:24]; 

            {ADDR_CH3TXSE, 4'b0001}    :   CH3_TX_SAR[ 7:0]  <= H_DAT_i[7:0];
            {ADDR_CH3TXSE, 4'b0010}    :   CH3_TX_SAR[15:8]  <= H_DAT_i[15:8];    
            {ADDR_CH3TXSE, 4'b0100}    :   CH3_TX_SAR[23:16] <= H_DAT_i[23:16];
            {ADDR_CH3TXSE, 4'b1000}    :   CH3_TX_SAR[31:24] <= H_DAT_i[31:24];
            {ADDR_CH3RXSE, 4'b0001}    :   CH3_RX_SAR[ 7:0]  <= H_DAT_i[7:0];
            {ADDR_CH3RXSE, 4'b0010}    :   CH3_RX_SAR[15:8]  <= H_DAT_i[15:8];
            {ADDR_CH3RXSE, 4'b0100}    :   CH3_RX_SAR[23:16] <= H_DAT_i[23:16];
            {ADDR_CH3RXSE, 4'b1000}    :   CH3_RX_SAR[31:24] <= H_DAT_i[31:24];  

            default:  $display("Warning : missing write objective. h%, h%", H_ADR_i, H_SEL_i);  

        endcase
       end
end // end always @...

/////////////////////////// HOCI read registers////////////////////////////////////

// Read SpW registers - include FIFOs of RX/TX

always @(*)
if( H_CYC_i && !H_WE_i && H_STB_i )    // Read
       begin
          case (H_ADR_i)   // synthesis parallel_case
            ADDR_SPE1      :    H_DAT_o =  SPE_CTL1;
            ADDR_CTR_STA1  :    H_DAT_o =  { STA_TX1, STA_RX1, CTL_TX1, CTL_RX1 };
            ADDR_SPE2      :    H_DAT_o =  SPE_CTL2;                                    
            ADDR_CTR_STA2  :    H_DAT_o =  { STA_TX2, STA_RX2, CTL_TX2, CTL_RX2 };
            ADDR_SPE3      :    H_DAT_o =  SPE_CTL3;                                                                       
            ADDR_CTR_STA3  :    H_DAT_o =  { STA_TX3, STA_RX3, CTL_TX3, CTL_RX3 };
            ADDR_WB_CTR    :    H_DAT_o =  { WB_CTR, COMI_ACR, PKT_SIZE, COMI_CH_SEL };        
            ADDR_CH1R_FIFO :    H_DAT_o =  { rxbuf1_data_i[7:0], rxbuf1_data_i[7:0], rxbuf1_data_i[7:0], rxbuf1_data_i[7:0] };          
            ADDR_CH2R_FIFO :    H_DAT_o =  { rxbuf2_data_i[7:0], rxbuf2_data_i[7:0], rxbuf2_data_i[7:0], rxbuf2_data_i[7:0] };                   
            ADDR_CH3R_FIFO :    H_DAT_o =  { rxbuf3_data_i[7:0], rxbuf3_data_i[7:0], rxbuF3_data_i[7:0], rxbuf3_data_i[7:0] };          
            ADDR_CH1TXSE   :    H_DAT_o =  { CH1_TX_SAR, CH1_TX_EAR };
            ADDR_CH1RXSE   :    H_DAT_o =  { CH1_RX_SAR, CH1_RX_EAR };
            ADDR_CH2TXSE   :    H_DAT_o =  { CH2_TX_SAR, CH2_TX_EAR };
            ADDR_CH2RXSE   :    H_DAT_o =  { CH2_RX_SAR, CH2_RX_EAR };
            ADDR_CH3TXSE   :    H_DAT_o =  { CH3_TX_SAR, CH3_TX_EAR };
            ADDR_CH3RXSE   :    H_DAT_o =  { CH3_RX_SAR, CH3_RX_EAR };
          default          :    H_DAT_o =  32'hxxxx;
          endcase
       end



                    
                             ///////////////////////////
                             // LET'S TALK ABOUT FIFO //
                             ///////////////////////////
/////////////////////// "H_ACK_o" and Write/read TX/RX FIFO /////////////////////
always @(*)
begin

H_ACK_o = 1'b0;                                              // set default value
H_RTY_o = 1'b0;
                                       
if( H_CYC_i && H_WE_i && H_STB_i )                        // if write                 
begin
  {H_wr_tx1buf, H_wr_tx2buf, H_wr_tx3buf} = 0;            // set default value
  H_ACK_o = 1;                                            // write to regs exclude FIFO is always permitted
     case(H_ADR_i)       // synthesis parallel_case
        ADDR_CH1T_FIFO : begin
                           if(tx1buf_full_i ==False)
                             H_wr_tx1buf = 1'b1;
                           if(tx1buf_full_i ==True)
                             begin
                             H_ACK_o = 1'b0; 
                             H_RTY_o = 1'b1;
                             end
                         end
        ADDR_CH2T_FIFO : begin
                           if(tx32buf_full_i ==False)
                             H_wr_tx2buf = 1'b1;
                           if(tx2buf_full_i ==True)
                             begin
                             H_ACK_o = 1'b0;
                             H_RTY_o = 1'b1;
                             end
                         end
        
        ADDR_CH3T_FIFO : begin
                           if(tx3buf_full_i ==False)
                             H_wr_tx3buf = 1'b1;
                           if(tx3buf_full_i ==True)
                             begin
                             H_ACK_o = 1'b0;
                             H_RTY_o = 1'b1;
                             end
                         end        
        default:         begin
                            {H_rd_rx1buf, H_rd_rx2buf, H_rd_rx3buf} = 3'bx;   
                            H_ACK_o = 1'bx;
                         end
        endcase
end 
else if( H_CYC_i && !H_WE_i && H_STB_i )                  // if read 
begin
  {H_rd_rx1buf, H_rd_rx2buf, H_rd_rx3buf} = 0;            // set default value
  H_ACK_o = 1;                                            // read to regs exclude FIFO is always permitted
  case(H_ADR_i)          // synthesis parallel_case
    
        ADDR_CH1R_FIFO : begin
                           if(rx1buf_empty_i ==False)
                             H_rd_rx1buf = 1'b1;
                           if( rx1buf_empty_i ==True  
                              && rxbuf1_data_i[8] == 1'b1 )// if EOP/EEP, continue read but discard value read
                             begin
                             H_ACK_o = 1'b0;
                             H_RTY_o = 1'b1;
                             end
                         end
        ADDR_CH2R_FIFO : begin
                           if(rx2buf_empty_i ==False)
                             H_rd_rx2buf = 1'b1;
                           if(rx2buf_empty_i ==True)
                             && rxbuf2_data_i[8] == 1'b1 )// if EOP/EEP, continue read but discard value read
                             begin
                             H_ACK_o = 1'b0;
                             H_RTY_o = 1'b1;
                             end
                         end
        ADDR_CH3R_FIFO : begin
                           if(rx3buf_empty_i ==False)
                             H_rd_rx3buf = 1'b1;
                           if(rx3buf_empty_i ==True)
                             && rxbuf3_data_i[8] == 1'b1 )// if EOP/EEP, continue read but discard value read
                             begin
                             H_ACK_o = 1'b0;
                             H_RTY_o = 1'b1;
                             end
                         end
  defult :               begin
                           {H_rd_rx1buf, H_rd_rx2buf, H_rd_rx3buf} = 3'bx;   
                            H_ACK_o = 1'bx;         
                         end
  endcase
end 

end   // end always @...


assign txbuf1_data_o = ADD_CH1_EOP  ?  EOP  :   SEL_TXDAT_SRC(COMI_DIS, 
                                                           H_DAT_i,
                                                           H_SEL_i,
                                                           CM_DAT_i,
                                                           CM_SEL_o );
assign txbuf2_data_o = ADD_CH2_EOP  ?  EOP  :   SEL_TXDAT_SRC(COMI_DIS, 
                                                           H_DAT_i,
                                                           H_SEL_i,
                                                           CM_DAT_i,
                                                           CM_SEL_o );
assign txbuf3_data_o = ADD_Ch3_EOP  ?  EOP  :   SEL_TXDAT_SRC(COMI_DIS, 
                                                           H_DAT_i,
                                                           H_SEL_i,
                                                           CM_DAT_i,
                                                           CM_SEL_o );

function [7:0] SEL_TXDAT_SRC;                      // COMI or HOCI to TX FIFO
input COMI_DIS;
input [31:0] H_DAT_i;
input [3:0] H_SEL_i;
input [31:0] CM_DAT_i;
input [3:0] CM_SEL_o;
begin
  if (COMI_DIS ==True)
    SEL_TXDAT_SRC = SEL_H2TX_SRC(H_SEL_i, H_DAT_i);
  else if (COMI_DIS ==FALSE)
    SEL_TXDAT_SRC = SEL_CM2TX_SRC(CM_SEL_o, CM_DAT_i);    
end
endfunction


///////// byte sel //////////
function [7:0]  SEL_H2TX_SRC;                       // Which byte from HOCI to TX FIFO;
input [3:0] H_SEL_i;
input [31:0] H_DAT_i;
 begin
    case (H_SEL_i)   // synthesis parallel_case
    4'b0001   :    SEL_TXDAT_SRC = H_DAT_i[ 7: 0]; 
    4'b0010   :    SEL_TXDAT_SRC = H_DAT_i[15: 8];
    4'b0100   :    SEL_TXDAT_SRC = H_DAT_i[23:16];
    4'b1000   :    SEL_TXDAT_SRC = H_DAT_i[31:24];
    default   :    SEL_TXDAT_SRC = 8'hxx;
    endcase
 end
endfunction

function [7:0] SEL_CM2TX_SRC;                      // Which byte from COMI to TX FIFO; COMI only access FIFOs. 
input [3:0] CM_SEL_o;
input [31:0] CM_DAT_i;
 begin
      case (CM_SEL_o) // synthesis parallel_case
      4'b0001 :    SEL_CM2TX_SRC = CM_DAT_i[ 7: 0];
      4'b0010 :    SEL_CM2TX_SRC = CM_DAT_i[15: 8];
      4'b0100 :    SEL_CM2TX_SRC = CM_DAT_i[23:16];
      4'b1000 :    SEL_CM2TX_SRC = CM_DAT_i[31:24];
      default :    SEL_CM2TX_SRC = 8'hxx;
      endcase
 end
////////end byte sel//////////
////////////////////////////// End Write/read FIFOs of RX/TX ///////////////////////////////



endmodule