/*****************************************************************************/
// Id ..........switch.v                                                 //
// Author.......Ran Minerbi                                                   //
//                                                                            //
//   Unit Description   :                                                     //
//     Top module of MAC Layer Ethernet Switch.                               //
//     The system has 6 ports , each one connected                            //
//     to Network Adapter (in hosts).                                         //
//     The system can  receive and transmit packets                           //
//     Simultaneously in full wire speed (100 MB/s).                          //
//                                                                            //
/*****************************************************************************/


`include "eth_phy_defines.v"
`include "wb_model_defines.v"
`include "tb_eth_defines.v"
`include "ethmac_defines.v"
`include "timescale.v"
`include "iba_modules.v"
`include "dcp_modules.v"
`include "dpq_modules.v"
`include "plu_moduls.v"
//`include "Xbar_modules.v"



//llu (, detect new frame,check crc, s2p) -> 
//parser check correctness , seperate from L2-> 
//iba (packet storage)-> 
//dcp(fdb)-> 
// dpq set in tq
`define NUM_OF_PORTS 6        
module switch(pi1,pi2,pi3,pi4,pi5,pi6,po1,po2,po3,po4,po5,po6);

 //inout
 input [3:0] pi1,pi2,pi3,pi4,pi5,pi6;
 output [3:0] po1,po2,po3,po4,po5,po6;
 //wires
 wire  [31:0] Dw1_iba_i,Dw2_iba_i,Dw3_iba_i,Dw4_iba_i,Dw5_iba_i,Dw6_iba_i , Dw1_iba_o,Dw2_iba_o,Dw3_iba_o,Dw4_iba_o,Dw5_iba_o,Dw6_iba_o;
 wire  plu2iba_start_pack_1 , plu2iba_start_pack_2,plu2iba_start_pack_3,plu2iba_start_pack_4,plu2iba_start_pack_5,plu2iba_start_pack_6;
 wire  iba2plu_start_pack_1 , iba2plu_start_pack_2,iba2plu_start_pack_3,iba2plu_start_pack_4,iba2plu_start_pack_5,iba2plu_start_pack_6;
 wire  plu2iba_end_pack_1 , plu2iba_end_pack_2,plu2iba_end_pack_3,plu2iba_end_pack_4,plu2iba_end_pack_5,plu2iba_end_pack_6;
 wire  iba2plu_end_pack_1 , iba2plu_end_pack_2,iba2plu_end_pack_3,iba2plu_end_pack_4,iba2plu_end_pack_5,iba2plu_end_pack_6; 
 
 
  reg clk , reset;
  
  

 initial 
  begin
    clk=1 ;
   
              reset = 0; 
     #62327   reset = 1; 
     #60   reset = 0; 
     end
always begin         
     #20  clk = ~clk;      
 end
     
 
plu plu1(   // need to add 6 inputs and 6 outputs to plu
     .reset(reset),.clk(clk) ,.pi1(pi1),.po1(po1),.Dw1i(Dw1_iba_o),.Dw1o(Dw1_iba_i),.plu2iba_start_pack_1(plu2iba_start_pack_1),.iba2plu_start_pack_1(iba2plu_start_pack_1),.plu2iba_end_pack_1(plu2iba_end_pack_1),.iba2plu_end_pack_1(iba2plu_end_pack_1),
                              .pi2(pi2),.po2(po2),.Dw2i(Dw2_iba_o),.Dw2o(Dw2_iba_i),.plu2iba_start_pack_2(plu2iba_start_pack_2),.iba2plu_start_pack_2(iba2plu_start_pack_2),.plu2iba_end_pack_2(plu2iba_end_pack_2),.iba2plu_end_pack_2(iba2plu_end_pack_2),
                              .pi3(pi3),.po3(po3),.Dw3i(Dw3_iba_o),.Dw3o(Dw3_iba_i),.plu2iba_start_pack_3(plu2iba_start_pack_3),.iba2plu_start_pack_3(iba2plu_start_pack_3),.plu2iba_end_pack_3(plu2iba_end_pack_3),.iba2plu_end_pack_3(iba2plu_end_pack_3),
                              .pi4(pi4),.po4(po4),.Dw4i(Dw4_iba_o),.Dw4o(Dw4_iba_i),.plu2iba_start_pack_4(plu2iba_start_pack_4),.iba2plu_start_pack_4(iba2plu_start_pack_4),.plu2iba_end_pack_4(plu2iba_end_pack_4),.iba2plu_end_pack_4(iba2plu_end_pack_4),
                              .pi5(pi5),.po5(po5),.Dw5i(Dw5_iba_o),.Dw5o(Dw5_iba_i),.plu2iba_start_pack_5(plu2iba_start_pack_5),.iba2plu_start_pack_5(iba2plu_start_pack_5),.plu2iba_end_pack_5(plu2iba_end_pack_5),.iba2plu_end_pack_5(iba2plu_end_pack_5),
                              .pi6(pi6),.po6(po6),.Dw6i(Dw6_iba_o),.Dw6o(Dw6_iba_i),.plu2iba_start_pack_6(plu2iba_start_pack_6),.iba2plu_start_pack_6(iba2plu_start_pack_6),.plu2iba_end_pack_6(plu2iba_end_pack_6),.iba2plu_end_pack_6(iba2plu_end_pack_6)); 
        
  

     IBA iba1(.reset(reset),.clk(clk),.Dw1_iba_i(Dw1_iba_i),.Dw1_iba_o(Dw1_iba_o),.plu2iba_start_pack_1(plu2iba_start_pack_1),.iba2plu_start_pack_1(iba2plu_start_pack_1),.plu2iba_end_pack_1(plu2iba_end_pack_1),.iba2plu_end_pack_1(iba2plu_end_pack_1),.headers_o1(headers_o1),.start_length1(start_length1),.transmit_done1(transmit_done1),.adr_valid1(adr_valid1),
                                      .Dw2_iba_i(Dw2_iba_i),.Dw2_iba_o(Dw2_iba_o),.plu2iba_start_pack_2(plu2iba_start_pack_2),.iba2plu_start_pack_2(iba2plu_start_pack_2),.plu2iba_end_pack_2(plu2iba_end_pack_2),.iba2plu_end_pack_2(iba2plu_end_pack_2),.headers_o2(headers_o2),.start_length2(start_length2),.transmit_done2(transmit_done2),.adr_valid2(adr_valid2),
                                      .Dw3_iba_i(Dw3_iba_i),.Dw3_iba_o(Dw3_iba_o),.plu2iba_start_pack_3(plu2iba_start_pack_3),.iba2plu_start_pack_3(iba2plu_start_pack_3),.plu2iba_end_pack_3(plu2iba_end_pack_3),.iba2plu_end_pack_3(iba2plu_end_pack_3),.headers_o3(headers_o3),.start_length3(start_length3),.transmit_done3(transmit_done3),.adr_valid3(adr_valid3),
                                      .Dw4_iba_i(Dw4_iba_i),.Dw4_iba_o(Dw4_iba_o),.plu2iba_start_pack_4(plu2iba_start_pack_4),.iba2plu_start_pack_4(iba2plu_start_pack_4),.plu2iba_end_pack_4(plu2iba_end_pack_4),.iba2plu_end_pack_4(iba2plu_end_pack_4),.headers_o4(headers_o4),.start_length4(start_length4),.transmit_done4(transmit_done4),.adr_valid4(adr_valid4),
                                      .Dw5_iba_i(Dw5_iba_i),.Dw5_iba_o(Dw5_iba_o),.plu2iba_start_pack_5(plu2iba_start_pack_5),.iba2plu_start_pack_5(iba2plu_start_pack_5),.plu2iba_end_pack_5(plu2iba_end_pack_5),.iba2plu_end_pack_5(iba2plu_end_pack_5),.headers_o5(headers_o5),.start_length5(start_length5),.transmit_done5(transmit_done5),.adr_valid5(adr_valid5),
                                      .Dw6_iba_i(Dw6_iba_i),.Dw6_iba_o(Dw6_iba_o),.plu2iba_start_pack_6(plu2iba_start_pack_6),.iba2plu_start_pack_6(iba2plu_start_pack_6),.plu2iba_end_pack_6(plu2iba_end_pack_6),.iba2plu_end_pack_6(iba2plu_end_pack_6),.headers_o6(headers_o6),.start_length6(start_length6),.transmit_done6(transmit_done6),.adr_valid6(adr_valid6)); 
             
                                                    
  wire [31:0] headers_o1,headers_o2,headers_o3,headers_o4,headers_o5,headers_o6;
  wire  transmit_done1,transmit_done2,transmit_done3,transmit_done4,transmit_done5,transmit_done6;    // iba -> dpq 
  
    DCP dcp1(.reset(reset),.clk(clk),.headers_i1(headers_o1), .start_addr1(start_addr1), 
                                      .headers_i2(headers_o2),.start_addr2(start_addr2),
                                      .headers_i3(headers_o3),.start_addr3(start_addr3),
                                      .headers_i4(headers_o4),.start_addr4(start_addr4),
                                      .headers_i5(headers_o5),.start_addr5(start_addr5),
                                      .headers_i6(headers_o6),.start_addr6(start_addr6));
                                                                                                                          
  wire [31:0] start_addr1,start_addr2,start_addr3,start_addr4,start_addr5,start_addr6; //to dpq
  
  DPQ dpq1(.reset(reset),.clk(clk),.start_addr1(start_addr1),.T_q1(T_q1),.start_length1(start_length1),.transmit_done1(transmit_done1),.adr_valid1(adr_valid1),
                                   .start_addr2(start_addr2),.T_q2(T_q2),.start_length2(start_length2),.transmit_done2(transmit_done2),.adr_valid2(adr_valid2),
                                   .start_addr3(start_addr3),.T_q3(T_q3),.start_length3(start_length3),.transmit_done3(transmit_done3),.adr_valid3(adr_valid3),
                                   .start_addr4(start_addr4),.T_q4(T_q4),.start_length4(start_length4),.transmit_done4(transmit_done4),.adr_valid4(adr_valid4),
                                   .start_addr5(start_addr5),.T_q5(T_q5),.start_length5(start_length5),.transmit_done5(transmit_done5),.adr_valid5(adr_valid5),
                                   .start_addr6(start_addr6),.T_q6(T_q6),.start_length6(start_length6),.transmit_done6(transmit_done6),.adr_valid6(adr_valid6)); 

   
  
  wire [7:0] T_q1,T_q2,T_q3,T_q4,T_q5,T_q6; // dpq->Xbar     
  wire [15:0] start_length1,start_length2,start_length3,start_length4,start_length5,start_length6,start_length7,start_length8;//to IBA
  wire adr_valid1,adr_valid2,adr_valid3,adr_valid4,adr_valid5,adr_valid6;

  Xbar xbar1 (.reset(reset),.clk(clk),.T_q1(T_q1),.Data_i1(Dw1_iba_o),.Data_o1(xbar_2_plu1),.xbar2plu_start_pack_1(xbar2plu_start_pack_1),.xbar2plu_end_pack_1(xbar2plu_end_pack_1), //  iba2xbar_start_pack_1,iba2xbar_end_pack_1,
                                      .T_q2(T_q2),.Data_i2(Dw2_iba_o),.Data_o2(xbar_2_plu2),.xbar2plu_start_pack_2(xbar2plu_start_pack_2),.xbar2plu_end_pack_2(xbar2plu_end_pack_2), //  iba2xbar_start_pack_2,iba2xbar_end_pack_2,
                                      .T_q3(T_q3),.Data_i3(Dw3_iba_o),.Data_o3(xbar_2_plu3),.xbar2plu_start_pack_3(xbar2plu_start_pack_3),.xbar2plu_end_pack_3(xbar2plu_end_pack_3), //  iba2xbar_start_pack_3,iba2xbar_end_pack_3,
                                      .T_q4(T_q4),.Data_i4(Dw4_iba_o),.Data_o4(xbar_2_plu4),.xbar2plu_start_pack_4(xbar2plu_start_pack_4),.xbar2plu_end_pack_4(xbar2plu_end_pack_4), //  iba2xbar_start_pack_4,iba2xbar_end_pack_4,
                                      .T_q5(T_q5),.Data_i5(Dw5_iba_o),.Data_o5(xbar_2_plu5),.xbar2plu_start_pack_5(xbar2plu_start_pack_5),.xbar2plu_end_pack_5(xbar2plu_end_pack_5), //  iba2xbar_start_pack_5,iba2xbar_end_pack_5,
                                      .T_q6(T_q6),.Data_i6(Dw6_iba_o),.Data_o6(xbar_2_plu6),.xbar2plu_start_pack_6(xbar2plu_start_pack_6),.xbar2plu_end_pack_6(xbar2plu_end_pack_6));//  iba2xbar_start_pack_6,iba2xbar_end_pack_6,

  wire [31:0] xbar_2_plu1,xbar_2_plu2,xbar_2_plu3,xbar_2_plu4,xbar_2_plu5,xbar_2_plu6;
  wire xbar2plu_start_pack_1,xbar2plu_end_pack_1,
       xbar2plu_start_pack_2,xbar2plu_end_pack_2,
       xbar2plu_start_pack_3,xbar2plu_end_pack_3,
       xbar2plu_start_pack_4,xbar2plu_end_pack_4,
       xbar2plu_start_pack_5,xbar2plu_end_pack_5,
       xbar2plu_start_pack_6,xbar2plu_end_pack_6;


  
endmodule


// serial 4 inputs to parallel 32       
//  4 inputs to 4 outputs
module plu (reset,clk , pi1,pi2,pi3,pi4,pi5,pi6, po1, po2,po3, po4,po5, po6, Dw1i,Dw2i,Dw3i,Dw4i,Dw5i,Dw6i , Dw1o,Dw2o,Dw3o,Dw4o,Dw5o,Dw6o,
            plu2iba_start_pack_1 , plu2iba_start_pack_2,plu2iba_start_pack_3,plu2iba_start_pack_4,plu2iba_start_pack_5,plu2iba_start_pack_6,
            iba2plu_start_pack_1 , iba2plu_start_pack_2,iba2plu_start_pack_3,iba2plu_start_pack_4,iba2plu_start_pack_5,iba2plu_start_pack_6,
            plu2iba_end_pack_1 , plu2iba_end_pack_2,plu2iba_end_pack_3,plu2iba_end_pack_4,plu2iba_end_pack_5,plu2iba_end_pack_6,
            iba2plu_end_pack_1 , iba2plu_end_pack_2,iba2plu_end_pack_3,iba2plu_end_pack_4,iba2plu_end_pack_5,iba2plu_end_pack_6
            
);
   input  reset , clk;
   input  [3:0] pi1,pi2,pi3,pi4,pi5,pi6;
   output [3:0] po1, po2,po3, po4,po5, po6;
   output [31:0]  Dw1o,Dw2o,Dw3o,Dw4o,Dw5o,Dw6o;//  to IBA
   input  [31:0] Dw1i,Dw2i,Dw3i,Dw4i,Dw5i,Dw6i;//  from Xbar
   output  plu2iba_start_pack_1 , plu2iba_start_pack_2,plu2iba_start_pack_3,plu2iba_start_pack_4,plu2iba_start_pack_5,plu2iba_start_pack_6;
   input   iba2plu_start_pack_1 , iba2plu_start_pack_2,iba2plu_start_pack_3,iba2plu_start_pack_4,iba2plu_start_pack_5,iba2plu_start_pack_6;
    output    plu2iba_end_pack_1 , plu2iba_end_pack_2,plu2iba_end_pack_3,plu2iba_end_pack_4,plu2iba_end_pack_5,plu2iba_end_pack_6; 
    input    iba2plu_end_pack_1 , iba2plu_end_pack_2,iba2plu_end_pack_3,iba2plu_end_pack_4,iba2plu_end_pack_5,iba2plu_end_pack_6; 
                                                                                                                                  
   wire  RxStartFrm1 , RxEndFrm1;
   wire  RxStartFrm2 , RxEndFrm2;
   wire  RxStartFrm3 , RxEndFrm3;
   wire  RxStartFrm4 , RxEndFrm4;
   wire  RxStartFrm5 , RxEndFrm5;
   wire  RxStartFrm6 , RxEndFrm6;
   
   wire [31:0] Dw1,Dw2,Dw3,Dw4,Dw5,Dw6;
   wire [7:0] word1,word2,word3,word4,word5,word6;
   wire [7:0] word_back1,word_back2,word_back3,word_back4,word_back5,word_back6;

   wire  TxStartFrm1_dw , TxEndFrm1_dw;
   wire  TxStartFrm2_dw , TxEndFrm2_dw;
   wire  TxStartFrm3_dw , TxEndFrm3_dw;
   wire  TxStartFrm4_dw , TxEndFrm4_dw;
   wire  TxStartFrm5_dw , TxEndFrm5_dw;
   wire  TxStartFrm6_dw , TxEndFrm6_dw;  
   // start/ end  frames from Dw_2_word to  word_2_nibble
   wire  TxStartFrm1 , TxEndFrm1; 
   wire  TxStartFrm2 , TxEndFrm2; 
   wire  TxStartFrm3 , TxEndFrm3; 
   wire  TxStartFrm4 , TxEndFrm4; 
   wire  TxStartFrm5 , TxEndFrm5; 
   wire  TxStartFrm6 , TxEndFrm6; 
     
    //  plu_serdes plu_serdes1(.reset(reset),.clk(clk) ,.pi1(pi1),.po1(po1),.RxStartFrm_out(RxStartFrm1) , .RxEndFrm_out(RxEndFrm1));
      // plu_serdes plu_serdes2(.reset(reset),.clk(clk) ,.pi1(pi2),.po1(po2),.RxStartFrm_out(RxStartFrm2) , .RxEndFrm_out(RxEndFrm2));

       nibble_2_word nibble_2_word1(.reset(reset),.clk(clk) , .pi1(pi1),   .Tx7in(word1) ,.RxStartFrm_out(RxStartFrm1) , .RxEndFrm_out(RxEndFrm1));
       word_2_nibble word_2_nibble1(.reset(reset),.clk(clk) , .po1(po1) , .RxData(word_back1) ,    .RxStartFrm(TxStartFrm1) ,     .RxEndFrm(TxEndFrm1));     
       nibble_2_word nibble_2_word2(.reset(reset),.clk(clk) , .pi1(pi2),   .Tx7in(word2) ,.RxStartFrm_out(RxStartFrm2) , .RxEndFrm_out(RxEndFrm2));
       word_2_nibble word_2_nibble2(.reset(reset),.clk(clk) , .po1(po2) , .RxData(word_back2) ,    .RxStartFrm(TxStartFrm2) ,     .RxEndFrm(TxEndFrm2));
       nibble_2_word nibble_2_word3(.reset(reset),.clk(clk)  ,.pi1(pi3),   .Tx7in(word3) ,.RxStartFrm_out(RxStartFrm3) , .RxEndFrm_out(RxEndFrm3));
       word_2_nibble word_2_nibble3(.reset(reset),.clk(clk) , .po1(po3) , .RxData(word3) ,    .RxStartFrm(RxStartFrm3) ,     .RxEndFrm(RxEndFrm3));                                                                                                                                         
       nibble_2_word nibble_2_word4(.reset(reset),.clk(clk)  ,.pi1(pi4),   .Tx7in(word4) ,.RxStartFrm_out(RxStartFrm4) , .RxEndFrm_out(RxEndFrm4));
       word_2_nibble word_2_nibble4(.reset(reset),.clk(clk) , .po1(po4) , .RxData(word4) ,    .RxStartFrm(RxStartFrm4) ,     .RxEndFrm(RxEndFrm4));                                                                                                                                                
       nibble_2_word nibble_2_word5(.reset(reset),.clk(clk)  ,.pi1(pi5),   .Tx7in(word5) ,.RxStartFrm_out(RxStartFrm5) , .RxEndFrm_out(RxEndFrm5));
       word_2_nibble word_2_nibble5(.reset(reset),.clk(clk) , .po1(po5) , .RxData(word5) ,    .RxStartFrm(RxStartFrm5) ,     .RxEndFrm(RxEndFrm5));                                                                                                                                                
       nibble_2_word nibble_2_word6(.reset(reset),.clk(clk)  ,.pi1(pi6),   .Tx7in(word6) ,.RxStartFrm_out(RxStartFrm6) , .RxEndFrm_out(RxEndFrm6));
       word_2_nibble word_2_nibble6(.reset(reset),.clk(clk) , .po1(po6) , .RxData(word6) ,    .RxStartFrm(RxStartFrm6) ,     .RxEndFrm(RxEndFrm6));

       
       word_to_Dword word_to_Dword1(.reset(reset),.clk(clk) ,.in1({word1,RxStartFrm1,RxEndFrm1}),
                                                             .in2({word2,RxStartFrm2,RxEndFrm2}),
                                                             .in3({word3,RxStartFrm3,RxEndFrm3}), 
                                                             .in4({word4,RxStartFrm4,RxEndFrm4}), 
                                                             .in5({word5,RxStartFrm5,RxEndFrm5}), 
                                                             .in6({word6,RxStartFrm6,RxEndFrm6}), 
                                                             .out1(Dw1o),.RxStartFrm1(plu2iba_start_pack_1) ,.RxEndFrm1(plu2iba_end_pack_1),
                                                             .out2(Dw2o),.RxStartFrm2(plu2iba_start_pack_2) ,.RxEndFrm2(plu2iba_end_pack_2),
                                                             .out3(Dw3o),.RxStartFrm3(plu2iba_start_pack_3) ,.RxEndFrm3(plu2iba_end_pack_3),
                                                             .out4(Dw4o),.RxStartFrm4(plu2iba_start_pack_4) ,.RxEndFrm4(plu2iba_end_pack_4),
                                                             .out5(Dw5o),.RxStartFrm5(plu2iba_start_pack_5) ,.RxEndFrm5(plu2iba_end_pack_5),
                                                             .out6(Dw6o),.RxStartFrm6(plu2iba_start_pack_6) ,.RxEndFrm6(plu2iba_end_pack_6));  

        //insert mem   IBA
        
       Dword_to_byte Dword_to_byte1(.reset(reset),.clk(clk), .byte(word_back1) ,.Dword(Dw1i) ,.TxStartFrm(iba2plu_start_pack_1),.TxEndFrm(iba2plu_end_pack_1),.TxStartFrm_0(TxStartFrm1),.TxEndFrm_1(TxEndFrm1));
       Dword_to_byte Dword_to_byte2(.reset(reset),.clk(clk), .byte(word_back2) ,.Dword(Dw2i) ,.TxStartFrm(iba2plu_start_pack_2),.TxEndFrm(iba2plu_end_pack_2),.TxStartFrm_0(TxStartFrm2),.TxEndFrm_1(TxEndFrm2));                                                        
       Dword_to_byte Dword_to_byte3(.reset(reset),.clk(clk), .byte(word_back3) ,.Dword(Dw3i) ,.TxStartFrm(iba2plu_start_pack_3),.TxEndFrm(iba2plu_end_pack_3),.TxStartFrm_0(TxStartFrm3),.TxEndFrm_1(TxEndFrm3));
       Dword_to_byte Dword_to_byte4(.reset(reset),.clk(clk), .byte(word_back4) ,.Dword(Dw4i) ,.TxStartFrm(iba2plu_start_pack_4),.TxEndFrm(iba2plu_end_pack_4),.TxStartFrm_0(TxStartFrm4),.TxEndFrm_1(TxEndFrm4));
       Dword_to_byte Dword_to_byte5(.reset(reset),.clk(clk), .byte(word_back5) ,.Dword(Dw5i) ,.TxStartFrm(iba2plu_start_pack_5),.TxEndFrm(iba2plu_end_pack_5),.TxStartFrm_0(TxStartFrm5),.TxEndFrm_1(TxEndFrm5));
       Dword_to_byte Dword_to_byte6(.reset(reset),.clk(clk), .byte(word_back6) ,.Dword(Dw6i) ,.TxStartFrm(iba2plu_start_pack_6),.TxEndFrm(iba2plu_end_pack_6),.TxStartFrm_0(TxStartFrm6),.TxEndFrm_1(TxEndFrm6));
                                                             
  endmodule

   //need an output of start/end Frm goes to Xbar to PLU           
   module IBA(reset,clk ,Dw1_iba_i,Dw1_iba_o,plu2iba_start_pack_1,iba2plu_start_pack_1,plu2iba_end_pack_1,iba2plu_end_pack_1,headers_o1,start_length1,transmit_done1,adr_valid1,
                         Dw2_iba_i,Dw2_iba_o,plu2iba_start_pack_2,iba2plu_start_pack_2,plu2iba_end_pack_2,iba2plu_end_pack_2,headers_o2,start_length2,transmit_done2,adr_valid2,
                         Dw3_iba_i,Dw3_iba_o,plu2iba_start_pack_3,iba2plu_start_pack_3,plu2iba_end_pack_3,iba2plu_end_pack_3,headers_o3,start_length3,transmit_done3,adr_valid3,
                         Dw4_iba_i,Dw4_iba_o,plu2iba_start_pack_4,iba2plu_start_pack_4,plu2iba_end_pack_4,iba2plu_end_pack_4,headers_o4,start_length4,transmit_done4,adr_valid4,
                         Dw5_iba_i,Dw5_iba_o,plu2iba_start_pack_5,iba2plu_start_pack_5,plu2iba_end_pack_5,iba2plu_end_pack_5,headers_o5,start_length5,transmit_done5,adr_valid5,
                         Dw6_iba_i,Dw6_iba_o,plu2iba_start_pack_6,iba2plu_start_pack_6,plu2iba_end_pack_6,iba2plu_end_pack_6,headers_o6,start_length6,transmit_done6,adr_valid6
                  
                  
                    

   );
       input reset, clk;
       input [31:0] Dw1_iba_i,Dw2_iba_i,Dw3_iba_i,Dw4_iba_i,Dw5_iba_i,Dw6_iba_i;
       output [31:0] Dw1_iba_o,Dw2_iba_o,Dw3_iba_o,Dw4_iba_o,Dw5_iba_o,Dw6_iba_o;
       output [31:0] headers_o1,headers_o2,headers_o3,headers_o4,headers_o5,headers_o6;
       input    plu2iba_start_pack_1 , plu2iba_start_pack_2,plu2iba_start_pack_3,plu2iba_start_pack_4,plu2iba_start_pack_5,plu2iba_start_pack_6;
       output   iba2plu_start_pack_1 , iba2plu_start_pack_2,iba2plu_start_pack_3,iba2plu_start_pack_4,iba2plu_start_pack_5,iba2plu_start_pack_6;        
       input    plu2iba_end_pack_1 , plu2iba_end_pack_2,plu2iba_end_pack_3,plu2iba_end_pack_4,plu2iba_end_pack_5,plu2iba_end_pack_6;
       output   iba2plu_end_pack_1 , iba2plu_end_pack_2,iba2plu_end_pack_3,iba2plu_end_pack_4,iba2plu_end_pack_5,iba2plu_end_pack_6;
       input [15:0] start_length1,start_length2,start_length3,start_length4,start_length5,start_length6;//from DPQ
       input adr_valid1,adr_valid2,adr_valid3,adr_valid4,adr_valid5,adr_valid6;
        output  transmit_done1,
                transmit_done2,
                transmit_done3,
                transmit_done4,
                transmit_done5,
                transmit_done6;
       
       assign  Dw1_iba_o=mem_u_o1;  
       assign  Dw2_iba_o=mem_u_o2;    
       assign  Dw3_iba_o=mem_u_o3; 
       assign  Dw4_iba_o=mem_u_o4; 
       assign  Dw5_iba_o=mem_u_o5; 
       assign  Dw6_iba_o=mem_u_o6; 

       assign iba2plu_start_pack_1 = 0;
       assign iba2plu_start_pack_2 = 0;
       assign iba2plu_start_pack_3 = plu2iba_start_pack_3;
       assign iba2plu_start_pack_4 = plu2iba_start_pack_4;
       assign iba2plu_start_pack_5 = plu2iba_start_pack_5;
       assign iba2plu_start_pack_6 = plu2iba_start_pack_6;

       assign iba2plu_end_pack_1 = 0; 
       assign iba2plu_end_pack_2 = 0; 
       assign iba2plu_end_pack_3 = plu2iba_end_pack_3;
       assign iba2plu_end_pack_4 = plu2iba_end_pack_4;
       assign iba2plu_end_pack_5 = plu2iba_end_pack_5;
       assign iba2plu_end_pack_6 = plu2iba_end_pack_6;
       wire [31:0] mem_u_o1,mem_u_o2,mem_u_o3,mem_u_o4,mem_u_o5,mem_u_o6;
      
        
        mem_units mem_units1(.reset(reset),.clk(clk),
                             .Dw1_iba_i(Dw1_iba_i) ,.Dw2_iba_i(Dw2_iba_i),.Dw3_iba_i(Dw3_iba_i),.Dw4_iba_i(Dw4_iba_i),.Dw5_iba_i(Dw5_iba_i),.Dw6_iba_i(Dw6_iba_i),
                             .mem_u_o1(mem_u_o1), .mem_u_o2(mem_u_o2),.mem_u_o3(mem_u_o3),.mem_u_o4(mem_u_o4),.mem_u_o5(mem_u_o5),.mem_u_o6(mem_u_o6),
                             .StartFrm1(plu2iba_start_pack_1) ,.EndFrm1(plu2iba_end_pack_1),. headers_o1(headers_o1),.start_length1(start_length1),.transmit_done1(transmit_done1),.adr_valid1(adr_valid1),
                             .StartFrm2(plu2iba_start_pack_2) ,.EndFrm2(plu2iba_end_pack_2),. headers_o2(headers_o2),.start_length2(start_length2),.transmit_done2(transmit_done2),.adr_valid2(adr_valid2),
                             .StartFrm3(plu2iba_start_pack_3) ,.EndFrm3(plu2iba_end_pack_3),. headers_o3(headers_o3),.start_length3(start_length3),.transmit_done3(transmit_done3),.adr_valid3(adr_valid3),
                             .StartFrm4(plu2iba_start_pack_4) ,.EndFrm4(plu2iba_end_pack_4),. headers_o4(headers_o4),.start_length4(start_length4),.transmit_done4(transmit_done4),.adr_valid4(adr_valid4),
                             .StartFrm5(plu2iba_start_pack_5) ,.EndFrm5(plu2iba_end_pack_5),. headers_o5(headers_o5),.start_length5(start_length5),.transmit_done5(transmit_done5),.adr_valid5(adr_valid5),
                             .StartFrm6(plu2iba_start_pack_6) ,.EndFrm6(plu2iba_end_pack_6),. headers_o6(headers_o6),.start_length6(start_length6),.transmit_done6(transmit_done6),.adr_valid6(adr_valid6));

                             
   endmodule


   //there is FDB queueing - getting from 6 channels simultaneously .
   // At first we will have 1 fdb per each channel 
   // move to DPQ |00|length|start_addr|T_q|
   module DCP(reset,clk,headers_i1,headers_i2,headers_i3,headers_i4,headers_i5,headers_i6,
                        start_addr1,start_addr2,start_addr3,start_addr4,start_addr5,start_addr6 
                       /* ,T_q1,T_q2,T_q3,T_q4,T_q5,T_q6*/);

         input reset, clk;
         input [31:0] headers_i1,headers_i2,headers_i3,headers_i4,headers_i5,headers_i6;               
         output [31:0] start_addr1,start_addr2,start_addr3,start_addr4,start_addr5,start_addr6; //to dpq
         wire [4:0] T_q1,T_q2,T_q3,T_q4,T_q5,T_q6; // to dpq

         wire[47:0] dmac1,dmac2,dmac3,dmac4,dmac5,dmac6;                                      
         wire[15:0] start_length1,start_length2,start_length3,start_length4,start_length5,start_length6;                                              
         Header_parser header_parser1(.reset(reset),.clk(clk),.header_i(headers_i1),.Dmac(dmac1),.Start_addr(start_length1));
         Header_parser header_parser2(.reset(reset),.clk(clk),.header_i(headers_i2),.Dmac(dmac2),.Start_addr(start_length2));
         Header_parser header_parser3(.reset(reset),.clk(clk),.header_i(headers_i3),.Dmac(dmac3),.Start_addr(start_length3));
         Header_parser header_parser4(.reset(reset),.clk(clk),.header_i(headers_i4),.Dmac(dmac4),.Start_addr(start_length4));
         Header_parser header_parser5(.reset(reset),.clk(clk),.header_i(headers_i5),.Dmac(dmac5),.Start_addr(start_length5));
         Header_parser header_parser6(.reset(reset),.clk(clk),.header_i(headers_i6),.Dmac(dmac6),.Start_addr(start_length6));
        
         FDB fdb1(.reset(reset),.clk(clk),.dmac(dmac1),.T_q(T_q1));                         
         FDB fdb2(.reset(reset),.clk(clk),.dmac(dmac2),.T_q(T_q2));                         
         FDB fdb3(.reset(reset),.clk(clk),.dmac(dmac3),.T_q(T_q3));                         
         FDB fdb4(.reset(reset),.clk(clk),.dmac(dmac4),.T_q(T_q4));                         
         FDB fdb5(.reset(reset),.clk(clk),.dmac(dmac5),.T_q(T_q5));                         
         FDB fdb6(.reset(reset),.clk(clk),.dmac(dmac6),.T_q(T_q6));                         

         assign start_addr1 = {8'b0,start_length1,3'b0,T_q1};
         assign start_addr2 = {8'b0,start_length2,3'b0,T_q2};
         assign start_addr3 = {8'b0,start_length3,3'b0,T_q3};
         assign start_addr4 = {8'b0,start_length4,3'b0,T_q4};
         assign start_addr5 = {8'b0,start_length5,3'b0,T_q5};
         assign start_addr6 = {8'b0,start_length6,3'b0,T_q6};
         
   endmodule   
                  //input from fdb |8'b0|length|start_addr|3'b0|T_q|, out to iba-start_addr+length, to Xb outport                      
  module DPQ(reset,clk, start_addr1,start_length1,T_q1,transmit_done1,adr_valid1,
                        start_addr2,start_length2,T_q2,transmit_done2,adr_valid2,
                        start_addr3,start_length3,T_q3,transmit_done3,adr_valid3,
                        start_addr4,start_length4,T_q4,transmit_done4,adr_valid4,
                        start_addr5,start_length5,T_q5,transmit_done5,adr_valid5,
                        start_addr6,start_length6,T_q6,transmit_done6,adr_valid6);
   
       input reset, clk;
       input [31:0] start_addr1,start_addr2,start_addr3,start_addr4,start_addr5,start_addr6;//from dcp
       output [7:0] T_q1,T_q2,T_q3,T_q4,T_q5,T_q6,T_q7,T_q8;//to Xb
       output [15:0] start_length1,start_length2,start_length3,start_length4,start_length5,start_length6,start_length7,start_length8;//to IBA
       input  transmit_done1,
              transmit_done2,
              transmit_done3,
              transmit_done4,
              transmit_done5,
              transmit_done6;
       output adr_valid1,adr_valid2,adr_valid3,adr_valid4,adr_valid5,adr_valid6;
       
  
       //fifo Qps need to validate addr_valid in the end
    Qp qp1(.reset(reset),.clk(clk),.transmit_done(transmit_done1),.Din(start_addr1),.start_adr(start_length1),.T_q(T_q1),.adr_valid(adr_valid1));    
    Qp qp2(.reset(reset),.clk(clk),.transmit_done(transmit_done2),.Din(start_addr2),.start_adr(start_length2),.T_q(T_q2),.adr_valid(adr_valid2));
    Qp qp3(.reset(reset),.clk(clk),.transmit_done(transmit_done3),.Din(start_addr3),.start_adr(start_length3),.T_q(T_q3),.adr_valid(adr_valid3));
    Qp qp4(.reset(reset),.clk(clk),.transmit_done(transmit_done4),.Din(start_addr4),.start_adr(start_length4),.T_q(T_q4),.adr_valid(adr_valid4));
    Qp qp5(.reset(reset),.clk(clk),.transmit_done(transmit_done5),.Din(start_addr5),.start_adr(start_length5),.T_q(T_q5),.adr_valid(adr_valid5));
    Qp qp6(.reset(reset),.clk(clk),.transmit_done(transmit_done6),.Din(start_addr6),.start_adr(start_length6),.T_q(T_q6),.adr_valid(adr_valid6));
       
   endmodule


   module Xbar(reset,clk,T_q1,Data_i1,Data_o1,xbar2plu_start_pack_1,xbar2plu_end_pack_1,   //  iba2xbar_start_pack_1,iba2xbar_end_pack_1,
                         T_q2,Data_i2,Data_o2,xbar2plu_start_pack_2,xbar2plu_end_pack_2,   //  iba2xbar_start_pack_2,iba2xbar_end_pack_2,
                         T_q3,Data_i3,Data_o3,xbar2plu_start_pack_3,xbar2plu_end_pack_3,   //  iba2xbar_start_pack_3,iba2xbar_end_pack_3,
                         T_q4,Data_i4,Data_o4,xbar2plu_start_pack_4,xbar2plu_end_pack_4,   //  iba2xbar_start_pack_4,iba2xbar_end_pack_4,
                         T_q5,Data_i5,Data_o5,xbar2plu_start_pack_5,xbar2plu_end_pack_5,   //  iba2xbar_start_pack_5,iba2xbar_end_pack_5,
                         T_q6,Data_i6,Data_o6,xbar2plu_start_pack_6,xbar2plu_end_pack_6);  //  iba2xbar_start_pack_6,iba2xbar_end_pack_6,

     input reset,clk;
     input [7:0]    T_q1,T_q2,T_q3,T_q4,T_q5,T_q6;
     input [31:0]   Data_i1,Data_i2,Data_i3,Data_i4,Data_i5,Data_i6;
     output [31:0]  Data_o1,Data_o2,Data_o3,Data_o4,Data_o5,Data_o6;
     input        iba2xbar_start_pack_1,iba2xbar_end_pack_1,
                  iba2xbar_start_pack_2,iba2xbar_end_pack_2,
                  iba2xbar_start_pack_3,iba2xbar_end_pack_3,
                  iba2xbar_start_pack_4,iba2xbar_end_pack_4,
                  iba2xbar_start_pack_5,iba2xbar_end_pack_5,
                  iba2xbar_start_pack_6,iba2xbar_end_pack_6;

     output       xbar2plu_start_pack_1,xbar2plu_end_pack_1,
                  xbar2plu_start_pack_2,xbar2plu_end_pack_2,
                  xbar2plu_start_pack_3,xbar2plu_end_pack_3,
                  xbar2plu_start_pack_4,xbar2plu_end_pack_4,
                  xbar2plu_start_pack_5,xbar2plu_end_pack_5,
                  xbar2plu_start_pack_6,xbar2plu_end_pack_6;
     reg [31:0]  Data_o1,Data_o2,Data_o3,Data_o4,Data_o5,Data_o6;
     
          //create module that create start/end packet signals detect by delay and xor 
          // delimiter_add                                                             
 //   Alignment_marker align1(.reset(reset),.clk(clk),.Data_o(Data_o1),.iba2xbar_start_pack(iba2xbar_start_pack),.iba2xbar_end_pack(iba2xbar_end_pack),.xbar2plu_start_pack(xbar2plu_start_pack),.xbar2plu_end_pack(xbar2plu_end_pack));
         
         always @ (posedge clk)
        begin
            case (T_q1)
                8'h01:  Data_o1 = Data_i1;
                8'h02:  Data_o2=  Data_i1;
                8'h03:  Data_o3=  Data_i1; 
                8'h04:  Data_o4=  Data_i1; 
                8'h05:  Data_o5=  Data_i1; 
                8'h06:  Data_o6=  Data_i1; 
                                                                                                
             endcase
             case (T_q2)
                8'h01:  Data_o1 = Data_i2;
                8'h02:  Data_o2=  Data_i2;
                8'h03:  Data_o3=  Data_i2; 
                8'h04:  Data_o4=  Data_i2; 
                8'h05:  Data_o5=  Data_i2; 
                8'h06:  Data_o6=  Data_i2; 
                                                                                                
             endcase
             case (T_q3)
                8'h01:  Data_o1 = Data_i3;
                8'h02:  Data_o2=  Data_i3;
                8'h03:  Data_o3=  Data_i3; 
                8'h04:  Data_o4=  Data_i3; 
                8'h05:  Data_o5=  Data_i3; 
                8'h06:  Data_o6=  Data_i3; 
                                                                                                
             endcase
             case (T_q4)
                8'h01:  Data_o1 = Data_i4;
                8'h02:  Data_o2=  Data_i4;
                8'h03:  Data_o3=  Data_i4; 
                8'h04:  Data_o4=  Data_i4; 
                8'h05:  Data_o5=  Data_i4; 
                8'h06:  Data_o6=  Data_i4; 
                                                                                                
             endcase
             case (T_q5)
                8'h01:  Data_o1 = Data_i5;
                8'h02:  Data_o2=  Data_i5;
                8'h03:  Data_o3=  Data_i5; 
                8'h04:  Data_o4=  Data_i5; 
                8'h05:  Data_o5=  Data_i5; 
                8'h06:  Data_o6=  Data_i5; 
                                                                                                
             endcase
             case (T_q6)
                8'h01:  Data_o1 = Data_i6;
                8'h02:  Data_o2=  Data_i6;
                8'h03:  Data_o3=  Data_i6; 
                8'h04:  Data_o4=  Data_i6; 
                8'h05:  Data_o5=  Data_i6; 
                8'h06:  Data_o6=  Data_i6; 
                                                                                                
             endcase                                 
                                                      
        end                                          
                                                      
                                                     
         endmodule       





