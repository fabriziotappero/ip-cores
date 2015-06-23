

/*****************************************************************************/
// Id ..........plu_modules.v                                                 //
// Author.......Ran Minerbi                                                   //
//                                                                            //
//   Unit Description   :                                                     //
//     plu is the physical layer.                                             //
//     Usually implemented as analog SerDes.                                  //
//     The unit Serialize the frames on transmission                          //
//     And De-Serialize on receive.                                           //
                                                                              //
/*****************************************************************************/




module nibble_2_word(reset,clk , pi1 , Tx7in ,RxStartFrm_out , RxEndFrm_out); 


  input  reset , clk;
  input  [3:0] pi1;
  output [7:0] Tx7in;
  output   RxStartFrm_out ,  RxEndFrm_out ;
  initial begin
   ControlFrmAddressOK = 0;  
 // Tx7in=0;
  end
   //out regs Rxs
  reg Rx_1_Valid ,ControlFrmAddressOK;
  reg  [3:0] pi1_1 , pi1_2, pi1_3;
 // wire  [7:0] Tx7in;
  wire [7:0] RxData;
  wire [15:0] RxByteCnt;
  wire [1:0] RxStateData;
  wire   RxValid ,RxStartFrm ,RxEndFrm ,RxByteCntEq0,RxByteCntGreat2 ,RxByteCntMaxFrame,RxCrcError,RxStateIdle,RxStatePreamble,RxStateSFD ,RxAbort ,AddressMiss ;

   
   always @ (posedge clk or posedge reset)
   begin
       if (reset)
           begin
         //     pi1_w = 0;
          //    pi2_w = 0;
            end
           else
            begin
             pi1_1 <= pi1;
             pi1_2 <= pi1_1;
             pi1_3 <= pi1_2;
             Rx_1_Valid =|( pi1| pi1_1 | pi1_2| pi1_3);
            end
   end


   eth_rxethmac rxethmac1          //need to duplicate 6 time
(
  .MRxClk(clk),
  .MRxDV(Rx_1_Valid),
  .MRxD(pi1),
  .Transmitting(1'b0),
  .HugEn(1'b0),
  .DlyCrcEn(1'b0),
  .MaxFL(32'h0600),
  .r_IFG(1'b1),
  .Reset(reset),
  .RxData(Tx7in),
  .RxValid(RxValid),
  .RxStartFrm(RxStartFrm_out),
  .RxEndFrm(RxEndFrm_out),
  .ByteCnt(RxByteCnt),
  .ByteCntEq0(RxByteCntEq0),
  .ByteCntGreat2(RxByteCntGreat2),
  .ByteCntMaxFrame(RxByteCntMaxFrame),
  .CrcError(RxCrcError),
  .StateIdle(RxStateIdle),
  .StatePreamble(RxStatePreamble),
  .StateSFD(RxStateSFD),
  .StateData(RxStateData),
  .MAC(48'h0),
  .r_Pro(1'b1),
  .r_Bro(1'b1),
  .r_HASH0(32'h0),
  .r_HASH1(32'h0),
  .RxAbort(RxAbort),
  .AddressMiss(AddressMiss),
  .PassAll(1'b1),
  .ControlFrmAddressOK(ControlFrmAddressOK)
);

 

    
endmodule




module plu_serdes(reset,clk , pi1 , po1 ,RxStartFrm_out , RxEndFrm_out);

  input  reset , clk;
  input  [3:0] pi1;
  output [3:0] po1;
  output   RxStartFrm_out ,  RxEndFrm_out ;
  initial  ControlFrmAddressOK = 0;  
  
   //out regs Rxs
  reg Rx_1_Valid ,ControlFrmAddressOK;
  reg  [3:0] pi1_1 , pi1_2, pi1_3;
  wire [7:0] RxData;
  wire [15:0] RxByteCnt;
  wire [1:0] RxStateData;
  wire   RxValid ,RxStartFrm ,RxEndFrm ,RxByteCntEq0,RxByteCntGreat2 ,RxByteCntMaxFrame,RxCrcError,RxStateIdle,RxStatePreamble,RxStateSFD ,RxAbort ,AddressMiss ;

   
   always @ (posedge clk or posedge reset)
   begin
       if (reset)
           begin
         //     pi1_w = 0;
          //    pi2_w = 0;
            end
           else
            begin
             pi1_1 <= pi1;
             pi1_2 <= pi1_1;
             pi1_3 <= pi1_2;
             Rx_1_Valid =|( pi1| pi1_1 | pi1_2| pi1_3);
            end
   end


   eth_rxethmac rxethmac1          //need to duplicate 6 time
(
  .MRxClk(clk),
  .MRxDV(Rx_1_Valid),
  .MRxD(pi1),
  .Transmitting(1'b0),
  .HugEn(1'b0),
  .DlyCrcEn(1'b0),
  .MaxFL(32'h0600),
  .r_IFG(1'b1),
  .Reset(reset),
  .RxData(RxData),
  .RxValid(RxValid),
  .RxStartFrm(RxStartFrm),
  .RxEndFrm(RxEndFrm),
  .ByteCnt(RxByteCnt),
  .ByteCntEq0(RxByteCntEq0),
  .ByteCntGreat2(RxByteCntGreat2),
  .ByteCntMaxFrame(RxByteCntMaxFrame),
  .CrcError(RxCrcError),
  .StateIdle(RxStateIdle),
  .StatePreamble(RxStatePreamble),
  .StateSFD(RxStateSFD),
  .StateData(RxStateData),
  .MAC(48'h0),
  .r_Pro(1'b1),
  .r_Bro(1'b1),
  .r_HASH0(32'h0),
  .r_HASH1(32'h0),
  .RxAbort(RxAbort),
  .AddressMiss(AddressMiss),
  .PassAll(1'b1),
  .ControlFrmAddressOK(ControlFrmAddressOK)
);

 //Tx 
   initial 
  begin
     TxCarrierSense = 1'b0;
     TxUnderRun = 1'b0;
     for_under_run = 1'b0;
     // #7160   Rx_1_Valid = 1'b0;PadOut = 1;
     r_MinFL = 16'h0040;
     r_MaxFL = 16'h0600;
     CrcEnOut = 1;
     r_FullD =1;
     r_HugEn = 0;
     r_DlyCrcEn = 0;
     r_IPGT= 7'h12;
     r_IPGR1 = 7'hc;
     r_IPGR2 = 7'h12;
     r_CollValid = 6'h3f;
     r_MaxRet = 4'hf;
     r_NoBckof = 1'b0;
     r_ExDfrEn =1'b0;
     Collision <= 1'b0;
       #67027   Rx_1_Valid = 1'b1;  
  end
  initial begin
      #74940   TxUnderRun = 1'b1;  //74940
      #360   TxUnderRun = 1'b0;     
      #9960   TxUnderRun = 1'b1;   // 84240
      #360   TxUnderRun = 1'b0;
      #11400   TxUnderRun = 1'b1;    //96000
      #360   TxUnderRun = 1'b0;
      #10760   TxUnderRun = 1'b1;    //107120
      #360   TxUnderRun = 1'b0;
      #10840   TxUnderRun = 1'b1;    //107120
      #360   TxUnderRun = 1'b0;


      end
      
       always @ (posedge RxEndFrm)
           begin
             # 560 for_under_run = 1'b1;
              # 360 for_under_run = 1'b0;
           end
    
    reg   TxCarrierSense ,Collision,PadOut ,CrcEnOut,r_FullD ,r_HugEn,r_DlyCrcEn,r_ExDfrEn, r_NoBckof , TxUnderRun ,for_under_run ;
    reg [15:0] r_MinFL;
    reg [15:0] r_MaxFL;
    reg [6:0] r_IPGT ,r_IPGR1 ,r_IPGR2;
    reg [5:0] r_CollValid;
    reg [3:0] r_MaxRet;
    wire [3:0] RetryCnt;
    wire [1:0] StateData;
    wire [7:0] Tx7in;
    wire RxStartFrm_out ,RxEndFrm_out;
   StartFrmExtender Extender(.reset(reset),.clk(clk) , .in(RxData),.extOut(Tx7in) ,.RxStartFrm(RxStartFrm) ,.RxEndFrm(RxEndFrm),.RxStartFrm_out(RxStartFrm_out),.RxEndFrm_out(RxEndFrm_out) ); 
    
eth_txethmac txethmac1
(
  .MTxClk(clk),                      //
  .Reset(reset),                     //
  .CarrierSense(TxCarrierSense),     //
  .Collision(Collision),             //
  .TxData(Tx7in),                   //
  .TxStartFrm(RxStartFrm_out),           //
  .TxUnderRun(for_under_run),           //
  .TxEndFrm(RxEndFrm_out),               //
  .Pad(PadOut),                      //
  .MinFL(r_MinFL),                   //
  .CrcEn(CrcEnOut),                  //
  .FullD(r_FullD),                   //
  .HugEn(r_HugEn),                   //
  .DlyCrcEn(r_DlyCrcEn),             //
  .IPGT(r_IPGT),                     //
  .IPGR1(r_IPGR1),                   //
  .IPGR2(r_IPGR2),                   //
  .CollValid(r_CollValid),           //
  .MaxRet(r_MaxRet),                 //
  .NoBckof(r_NoBckof),               //
  .ExDfrEn(r_ExDfrEn),               //
  .MaxFL(r_MaxFL),                   //
  .MTxEn(mtxen_pad_o),
  .MTxD(po1),                        //  plu output [3:0]
  .MTxErr(mtxerr_pad_o),
  .TxUsedData(TxUsedDataIn),
  .TxDone(TxDoneIn),
  .TxRetry(TxRetry),
  .TxAbort(TxAbortIn),
  .WillTransmit(WillTransmit),
  .ResetCollision(ResetCollision),
  .RetryCnt(RetryCnt),               //
  .StartTxDone(StartTxDone),
  .StartTxAbort(StartTxAbort),
  .MaxCollisionOccured(MaxCollisionOccured),
  .LateCollision(LateCollision),
  .DeferIndication(DeferIndication),
  .StatePreamble(StatePreamble),
  .StateData(StateData)              //
);
   



    
endmodule


module word_2_nibble(reset,clk , po1 , RxData ,RxStartFrm , RxEndFrm);

    input  reset , clk;
  output  [3:0] po1;
  input [7:0] RxData;
  input   RxStartFrm ,  RxEndFrm ;

    //Tx 
   initial 
  begin
     TxCarrierSense = 1'b0;
     TxUnderRun = 1'b0;
     for_under_run = 1'b0;
     r_MinFL = 16'h0040;
     r_MaxFL = 16'h0600;
     CrcEnOut = 1;
     r_FullD =1;
     r_HugEn = 0;
     r_DlyCrcEn = 0;
     r_IPGT= 7'h12;
     r_IPGR1 = 7'hc;
     r_IPGR2 = 7'h12;
     r_CollValid = 6'h3f;
     r_MaxRet = 4'hf;
     r_NoBckof = 1'b0;
     r_ExDfrEn =1'b0;
     Collision <= 1'b0;
    // RxStartFrm_out = 0;
    
  end
        
       always @ (posedge RxEndFrm)
           begin
             # 560 for_under_run = 1'b1;
              # 360 for_under_run = 1'b0;
           end
    
    reg   TxCarrierSense ,Collision,PadOut ,CrcEnOut,r_FullD ,r_HugEn,r_DlyCrcEn,r_ExDfrEn, r_NoBckof , TxUnderRun ,for_under_run ;
    reg [15:0] r_MinFL;
    reg [15:0] r_MaxFL;
    reg [6:0] r_IPGT ,r_IPGR1 ,r_IPGR2;
    reg [5:0] r_CollValid;
    reg [3:0] r_MaxRet;
    wire [3:0] RetryCnt;
    wire [1:0] StateData;
    wire [7:0] Tx7in;
    wire RxStartFrm ,RxEndFrm;
    wire RxStartFrm_out;
   StartFrmExtender Extender(.reset(reset),.clk(clk) , .in(RxData),.extOut(Tx7in) ,.RxStartFrm(RxStartFrm) ,.RxEndFrm(RxEndFrm),.RxStartFrm_out(RxStartFrm_out),.RxEndFrm_out(RxEndFrm_out) ); 
    
eth_txethmac txethmac1
(
  .MTxClk(clk),                      //
  .Reset(reset),                     //
  .CarrierSense(TxCarrierSense),     //
  .Collision(Collision),             //
  .TxData(Tx7in),                   //
  .TxStartFrm(RxStartFrm_out),           //
  .TxUnderRun(for_under_run),           //
  .TxEndFrm(RxEndFrm_out),               //
  .Pad(PadOut),                      //
  .MinFL(r_MinFL),                   //
  .CrcEn(CrcEnOut),                  //
  .FullD(r_FullD),                   //
  .HugEn(r_HugEn),                   //
  .DlyCrcEn(r_DlyCrcEn),             //
  .IPGT(r_IPGT),                     //
  .IPGR1(r_IPGR1),                   //
  .IPGR2(r_IPGR2),                   //
  .CollValid(r_CollValid),           //
  .MaxRet(r_MaxRet),                 //
  .NoBckof(r_NoBckof),               //
  .ExDfrEn(r_ExDfrEn),               //
  .MaxFL(r_MaxFL),                   //
  .MTxEn(mtxen_pad_o),
  .MTxD(po1),                        //  plu output [3:0]
  .MTxErr(mtxerr_pad_o),
  .TxUsedData(TxUsedDataIn),
  .TxDone(TxDoneIn),
  .TxRetry(TxRetry),
  .TxAbort(TxAbortIn),
  .WillTransmit(WillTransmit),
  .ResetCollision(ResetCollision),
  .RetryCnt(RetryCnt),               //
  .StartTxDone(StartTxDone),
  .StartTxAbort(StartTxAbort),
  .MaxCollisionOccured(MaxCollisionOccured),
  .LateCollision(LateCollision),
  .DeferIndication(DeferIndication),
  .StatePreamble(StatePreamble),
  .StateData(StateData)              //
  );

    
endmodule


module Dword_to_byte(reset,clk ,byte ,Dword , TxStartFrm , TxEndFrm ,TxStartFrm_0,TxEndFrm_1 );

    output [7:0] byte;
    input [31:0] Dword;
    input reset ,clk , TxStartFrm , TxEndFrm;
    output TxStartFrm_0 , TxEndFrm_1;
   // output TxStartFrm_ , TxEndFrm_;
     reg  clk_div2 ,clk_div4 ;
     reg [1:0] mod4;
     reg [1:0] mod4_;
     reg [7:0] byte;
     reg TxStartFrm_ , TxEndFrm_ ,TxStartFrm_1,TxStartFrm_2, start_en , start_en_ ,end_en , start_signal_detect;
     reg [9:0] counter;
     reg [1:0] FSMState;
     wire   TxStartFrm_0 , TxEndFrm_1;
     initial begin
        FSMState = 0;
         mod4=0;
         mod4_=0;
         counter =0;
         clk_div2=0;
         byte=0;
         clk_div4=0;
         start_en=0;
         TxStartFrm_1=0;
         TxStartFrm_2=0;
         
         end_en=0  ;
         start_en_=0;
         start_signal_detect=0;
         TxStartFrm_=0;
         end

      always @(posedge TxEndFrm )
        begin
            end_en<=1;
       //     mod4 <=0 ;
         end
      always @(posedge TxStartFrm )
        begin
           mod4_ <= 0;
         //  mod4 <= 0;
           counter=0;
          // start_en<=1;      //push simultaneously
           //clk_div2=1;
         end
     
     always @(posedge clk)
            begin
              clk_div2 <= clk^clk_div2;  
              clk_div4 <= (~clk_div2)^clk_div4;
       /*    TxStartFrm_2<=TxStartFrm_1;
            TxStartFrm_<=(mod4_ ==2'b01)?TxStartFrm_:0;      */
            // TxEndFrm_1<=TxEndFrm_;        
             end
      assign  TxStartFrm_0=TxStartFrm_ & start_signal_detect & clk_div2;
      assign TxEndFrm_1 = end_en & (mod4==5);
      always @ (posedge clk_div2)
      begin
           TxEndFrm_<=(mod4==4)?(~clk_div2)&end_en:TxEndFrm;
           end_en<= (mod4==5)?0:end_en;
           
          mod4_<=mod4_+1;
          start_signal_detect = |Dword;
          TxStartFrm_=start_signal_detect & clk_div2;
          if (start_signal_detect & clk_div2)
              begin
                  counter<=counter+1;
                  end
                  if (counter >0)
                      begin
                       TxStartFrm_ =0;
                      end
          
                    
                            
       end
        always @(negedge clk_div2)
        begin
        case(mod4)

            2'h0:  byte<= Dword[31:24] ;
            2'h1:  byte<= Dword[23:16] ;
            2'h2:  byte<= Dword[15:8] ;
            2'h3:  byte<= Dword[7:0] ;
          endcase
        end
        always @ (posedge clk_div2)
        begin
            case (FSMState)
            2'b00: begin    // this is non recieving frame state
                    if (start_signal_detect == 0)
                        begin
                        //FSMState <= 2'b00;
                        mod4 <= 0;
                        end
                    else if (start_signal_detect == 1)
                        begin
                        FSMState <= 2'b11;
                        mod4 <= mod4+1;
                        end
                    end
        //    2'b01:  begin
         //           if (start_signal_detect == 1)
          //              begin
           //             FSMState <= 2'b11;
           //             mod4 <= 0;
           //             end
            //        end 
            2'b11: begin 
                    if (start_signal_detect == 1)
                        begin
                        //FSMState <= 2'b11;
                        mod4 <= mod4 +1;
                        end
                        else if (start_signal_detect==0)
                        begin
                        FSMState<= 2'b00;
                        end
                    end
            endcase
        end     
    endmodule

    
module byte_to_Dword(reset,clk ,byte ,Dword , RxStartFrm_ ,RxEndFrm_);
   input [9:0] byte;
    output [31:0] Dword;
    input reset ,clk;
    output RxStartFrm_ ,RxEndFrm_;
     reg [31:0] Dword, Dword1;
     reg [1:0] mod4 , mod4_;
     reg [7:0] RxData;
     reg  RxStartFrm ,RxEndFrm, RxStartFrm_ ,RxEndFrm_ , signal_detect;
     reg  clk_div2 ,clk_div4 ,shift_start;     
     initial  begin
     mod4 = 0;
     RxData =0 ; clk_div2 = 0 ; RxStartFrm=0 ;RxEndFrm=0;
     clk_div4=0 ; shift_start=0;  
     Dword=0; Dword1=0; 
     end 

    always @(negedge clk_div2 )
    begin
                  

                case(mod4_)    
              
                2'h0:      Dword1[31:24] <= RxData;
                2'h1:      Dword1[23:16] <= RxData;
                2'h2:      Dword1[15:8]  <= RxData;
                2'h3:      Dword1[7:0]   <= RxData;
              endcase
                mod4 <= mod4 + 1;
     end

      always @(posedge clk)
          begin
              clk_div2 <= clk^clk_div2;  
              mod4_<=mod4;   
              clk_div4 <= clk_div2^clk_div4;
              RxStartFrm <= byte[1];        
              RxEndFrm   <= byte[0];        
              RxData <=  byte[9:2];
              RxStartFrm_ <= byte[1];
              RxEndFrm_   <= byte[0];          
           end
           
      always @(posedge clk_div2)
          begin
              if (mod4==0)
                begin
                Dword<=Dword1;
                signal_detect=|Dword1;
           //     RxStartFrm =1;
                end
                if (mod4 == 3)
                 begin
              //      RxStartFrm_<= clk_div2; 
              //      RxEndFrm_<= clk_div2;
             //     RxStartFrm=0;
                    shift_start<=0;     
                end else begin
               //      RxStartFrm=0;
                    end
                
           end
       always @ (posedge RxStartFrm )
              begin
                mod4 <= 0;
                shift_start<=1;
                clk_div2=1;
              end  
                 
    
endmodule

module word_to_Dword (reset,clk ,in1,in2,in3,in4,in5,in6,out1,out2,out3,out4,out5,out6,
                      RxStartFrm1 ,RxStartFrm2,RxStartFrm3,RxStartFrm4,RxStartFrm5,RxStartFrm6,
                      RxEndFrm1,RxEndFrm2,RxEndFrm3,RxEndFrm4,RxEndFrm5,RxEndFrm6
                      );
    input [9:0] in1,in2,in3,in4,in5,in6;
    output [31:0] out1,out2,out3,out4,out5,out6;
    input reset ,clk;
     output RxStartFrm1 ,RxStartFrm2,RxStartFrm3,RxStartFrm4,RxStartFrm5,RxStartFrm6;
     output RxEndFrm1,RxEndFrm2,RxEndFrm3,RxEndFrm4,RxEndFrm5,RxEndFrm6;
   byte_to_Dword  byte_to_Dword1(.reset(reset),.clk(clk) ,.byte(in1) ,.Dword(out1),.RxStartFrm_(RxStartFrm1) ,.RxEndFrm_(RxEndFrm1)); 
   byte_to_Dword  byte_to_Dword2(.reset(reset),.clk(clk) ,.byte(in2) ,.Dword(out2),.RxStartFrm_(RxStartFrm2) ,.RxEndFrm_(RxEndFrm2)); 
   byte_to_Dword  byte_to_Dword3(.reset(reset),.clk(clk) ,.byte(in3) ,.Dword(out3),.RxStartFrm_(RxStartFrm3) ,.RxEndFrm_(RxEndFrm3)); 
   byte_to_Dword  byte_to_Dword4(.reset(reset),.clk(clk) ,.byte(in4) ,.Dword(out4),.RxStartFrm_(RxStartFrm4) ,.RxEndFrm_(RxEndFrm4)); 
   byte_to_Dword  byte_to_Dword5(.reset(reset),.clk(clk) ,.byte(in5) ,.Dword(out5),.RxStartFrm_(RxStartFrm5) ,.RxEndFrm_(RxEndFrm5)); 
   byte_to_Dword  byte_to_Dword6(.reset(reset),.clk(clk) ,.byte(in6) ,.Dword(out6),.RxStartFrm_(RxStartFrm6) ,.RxEndFrm_(RxEndFrm6));   
  
    
endmodule

module StartFrmExtender (reset,clk , in,extOut ,RxStartFrm ,RxEndFrm,RxStartFrm_out ,RxEndFrm_out );
   input  reset , clk ,RxStartFrm ,RxEndFrm;
   input [7:0] in;
   output [7:0] extOut ;
   output RxStartFrm_out ,RxEndFrm_out;
   reg [7:0] first_sample ;
   reg div_2_clk;
   reg [6:0] counter;
   reg [1:0] state;
   reg [7:0] extOut ;
   reg RxStartFrm_out ,RxEndFrm_out;
   reg write_fifo , read_fifo , TxFifoClear ;
   wire            TxBufferFull;       
   wire            TxBufferAlmostFull; 
   wire            TxBufferAlmostEmpty;
   wire            TxBufferEmpty;      
   wire [7:0] queue_out;
   wire [4:0] txfifo_cnt;
    eth_fifo #(
           .DATA_WIDTH(8),
           .DEPTH(32),
           .CNT_WIDTH(5))
 ext_fifo (
         .clk            (~div_2_clk),
         .reset          (reset),      
         // Inputs
         .data_in        (in),
         .write          (write_fifo),
         .read           (read_fifo),
         .clear          (TxFifoClear),
         // Outputs
         .data_out       (queue_out), 
         .full           (TxBufferFull),
         .almost_full    (TxBufferAlmostFull),
         .almost_empty   (TxBufferAlmostEmpty), 
         .empty          (TxBufferEmpty),
         .cnt            (txfifo_cnt)
        );
    
    initial begin
    div_2_clk=0;
    RxEndFrm_out = 0;
    read_fifo =0;  
    RxStartFrm_out = 0;  
  // #67800  write_fifo=1;
    end

   always @(posedge  RxStartFrm)
   begin
         div_2_clk=1;
       end
   always @ (posedge clk or posedge reset )
   begin
       if (reset)
           begin
             extOut <= 0;
            end
           else
            begin
               div_2_clk <= div_2_clk^clk;
            end
   end
   always @(negedge reset)
   begin
        RxStartFrm_out <= 0;
    end

   always @ (posedge clk)
          begin 
              if (RxStartFrm)
               begin
                  counter=0; 
                  first_sample <= in;
                  state <= 2'h0;
                  assign   write_fifo=1;
              end
         
              if (RxEndFrm)
              begin
                 assign  write_fifo=0;
                   state<=2'h2;
              end
      end //clk 

    always @(negedge RxStartFrm)      //negedge
     begin
         RxStartFrm_out <= 1;
     end
   always @ (posedge div_2_clk)
      begin
       counter <= counter + 1;
       if (counter < 7 & state ==0)
         begin
              extOut <= first_sample;                            
              assign   write_fifo=1;
              assign   read_fifo =0;
         end 
       else if (counter>=7 & state ==0)
             begin
                 extOut <= queue_out;
                    RxStartFrm_out = 0;    
              assign   write_fifo=1;
              assign   read_fifo =1;
             end
       else if (state ==2 & ~TxBufferEmpty)
           begin
              extOut <= queue_out;
            assign  write_fifo=0;      
            assign  read_fifo =1;      
           end
        else if (state ==2 & TxBufferEmpty)  
            begin                             
               extOut <= in;            
             assign  write_fifo=0;                  
             assign  read_fifo =0; 
             state <= 2'h3; 
             assign TxFifoClear = 1;
             assign RxEndFrm_out = 1;
            end               
            else if (state == 3)
                begin
                    assign TxFifoClear = 0;
                    assign RxEndFrm_out = 0;
                end

      end
     
   
endmodule

