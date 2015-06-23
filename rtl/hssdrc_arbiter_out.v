//
// Project      : High-Speed SDRAM Controller with adaptive bank management and command pipeline
// 
// Project Nick : HSSDRC
// 
// Version      : 1.0-beta 
//  
// Revision     : $Revision: 1.1 $ 
// 
// Date         : $Date: 2008-03-06 13:52:43 $ 
// 
// Workfile     : hssdrc_arbiter_out.v
// 
// Description  : output 3 way decode arbiter
// 
// HSSDRC is licensed under MIT License
// 
// Copyright (c) 2007-2008, Denis V.Shekhalev (des00@opencores.org) 
// 
// Permission  is hereby granted, free of charge, to any person obtaining a copy of
// this  software  and  associated documentation files (the "Software"), to deal in
// the  Software  without  restriction,  including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the  Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
// 
// The  above  copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE  SOFTWARE  IS  PROVIDED  "AS  IS",  WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR  A  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT  HOLDERS  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN  AN  ACTION  OF  CONTRACT,  TORT  OR  OTHERWISE,  ARISING  FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//


`include "hssdrc_timescale.vh"

`include "hssdrc_define.vh"

module hssdrc_arbiter_out (
  clk                , 
  reset              , 
  sclr               ,                       
  //
  dec0_pre_all       , 
  dec0_refr          , 
  dec0_pre           , 
  dec0_act           , 
  dec0_read          , 
  dec0_write         , 
  dec0_pre_all_enable, 
  dec0_refr_enable   , 
  dec0_pre_enable    , 
  dec0_act_enable    , 
  dec0_read_enable   , 
  dec0_write_enable  , 
  dec0_locked        , 
  dec0_last          , 
  dec0_rowa          , 
  dec0_cola          , 
  dec0_ba            , 
  dec0_chid          , 
  dec0_burst         , 
  //
  dec1_pre_all       , 
  dec1_refr          , 
  dec1_pre           , 
  dec1_act           , 
  dec1_read          , 
  dec1_write         , 
  dec1_pre_all_enable, 
  dec1_refr_enable   , 
  dec1_pre_enable    , 
  dec1_act_enable    , 
  dec1_read_enable   , 
  dec1_write_enable  , 
  dec1_locked        , 
  dec1_last          , 
  dec1_rowa          , 
  dec1_cola          , 
  dec1_ba            , 
  dec1_chid          , 
  dec1_burst         , 
  //
  dec2_pre_all       , 
  dec2_refr          , 
  dec2_pre           , 
  dec2_act           , 
  dec2_read          , 
  dec2_write         , 
  dec2_pre_all_enable, 
  dec2_refr_enable   , 
  dec2_pre_enable    , 
  dec2_act_enable    , 
  dec2_read_enable   , 
  dec2_write_enable  , 
  dec2_locked        , 
  dec2_last          , 
  dec2_rowa          , 
  dec2_cola          , 
  dec2_ba            , 
  dec2_chid          , 
  dec2_burst         , 
  //
  am_pre_all_enable  , 
  am_refr_enable     ,
  am_pre_enable      ,
  am_act_enable      ,
  am_read_enable     ,
  am_write_enable    ,
  //                 
  arb_pre_all        ,
  arb_refr           ,
  arb_pre            ,
  arb_act            ,
  arb_read           ,
  arb_write          ,
  arb_rowa           ,
  arb_cola           ,
  arb_ba             ,
  arb_chid           ,
  arb_burst    
  );
  
  input wire clk  ;
  input wire reset;
  input wire sclr ;

  //-------------------------------------------------------------------------------------------------- 
  // interface from sequence decoders 
  //-------------------------------------------------------------------------------------------------- 

  input  wire           dec0_pre_all       ;   
  input  wire           dec0_refr          ;   
  input  wire           dec0_pre           ;   
  input  wire           dec0_act           ;   
  input  wire           dec0_read          ;   
  input  wire           dec0_write         ;   
  output logic          dec0_pre_all_enable;
  output logic          dec0_refr_enable   ;
  output logic          dec0_pre_enable    ;
  output logic          dec0_act_enable    ;
  output logic          dec0_read_enable   ;
  output logic          dec0_write_enable  ;
  input  wire           dec0_locked        ;     
  input  wire           dec0_last          ;     
  input  rowa_t         dec0_rowa          ;     
  input  cola_t         dec0_cola          ;     
  input  ba_t           dec0_ba            ;     
  input  chid_t         dec0_chid          ;     
  input  sdram_burst_t  dec0_burst         ; 
  //
  input  wire           dec1_pre_all       ;   
  input  wire           dec1_refr          ;   
  input  wire           dec1_pre           ;   
  input  wire           dec1_act           ;   
  input  wire           dec1_read          ;   
  input  wire           dec1_write         ;   
  output logic          dec1_pre_all_enable;
  output logic          dec1_refr_enable   ;
  output logic          dec1_pre_enable    ;
  output logic          dec1_act_enable    ;
  output logic          dec1_read_enable   ;
  output logic          dec1_write_enable  ;
  input  wire           dec1_locked        ;     
  input  wire           dec1_last          ;     
  input  rowa_t         dec1_rowa          ;     
  input  cola_t         dec1_cola          ;     
  input  ba_t           dec1_ba            ;     
  input  chid_t         dec1_chid          ;     
  input  sdram_burst_t  dec1_burst         ;
  //
  input  wire           dec2_pre_all       ;   
  input  wire           dec2_refr          ;   
  input  wire           dec2_pre           ;   
  input  wire           dec2_act           ;   
  input  wire           dec2_read          ;   
  input  wire           dec2_write         ;   
  output logic          dec2_pre_all_enable;
  output logic          dec2_refr_enable   ;
  output logic          dec2_pre_enable    ;
  output logic          dec2_act_enable    ;
  output logic          dec2_read_enable   ;
  output logic          dec2_write_enable  ;
  input  wire           dec2_locked        ;     
  input  wire           dec2_last          ;     
  input  rowa_t         dec2_rowa          ;     
  input  cola_t         dec2_cola          ;     
  input  ba_t           dec2_ba            ;     
  input  chid_t         dec2_chid          ;     
  input  sdram_burst_t  dec2_burst         ;

  //-------------------------------------------------------------------------------------------------- 
  // interface from access manager 
  //-------------------------------------------------------------------------------------------------- 

  input wire       am_pre_all_enable  ;
  input wire       am_refr_enable     ;
  input wire [0:3] am_pre_enable      ;
  input wire [0:3] am_act_enable      ;
  input wire [0:3] am_read_enable     ;
  input wire [0:3] am_write_enable    ;

  //-------------------------------------------------------------------------------------------------- 
  // interface to multiplexer 
  //-------------------------------------------------------------------------------------------------- 

  output logic         arb_pre_all  ;
  output logic         arb_refr     ;
  output logic         arb_pre      ;
  output logic         arb_act      ;
  output logic         arb_read     ;
  output logic         arb_write    ;
  output rowa_t        arb_rowa     ;
  output cola_t        arb_cola     ;
  output ba_t          arb_ba       ;
  output chid_t        arb_chid     ;
  output sdram_burst_t arb_burst    ;

  //-------------------------------------------------------------------------------------------------- 
  // 
  //-------------------------------------------------------------------------------------------------- 
  enum bit [1:0] {ARB0, ARB1, ARB2} arb, ba_rowa_mux;  

  logic       arb_ack; 

  logic       dec0_access_enable;
  logic       dec1_access_enable;
  logic       dec2_access_enable;

  logic       dec0_bank_access_enable;
  logic       dec1_bank_access_enable;
  logic       dec2_bank_access_enable;

  logic dec1_can_have_access_when_arb_is_0  ;
  logic dec2_can_have_access_when_arb_is_0  ; 
                                          
  logic dec2_can_have_access_when_arb_is_1  ;  
  logic dec0_can_have_access_when_arb_is_1  ; 
                                          
  logic dec0_can_have_access_when_arb_is_2  ;  
  logic dec1_can_have_access_when_arb_is_2  ; 

  logic       dec0_access_done; 
  logic       dec1_access_done; 
  logic       dec2_access_done; 

  //-------------------------------------------------------------------------------------------------- 
  // 
  //-------------------------------------------------------------------------------------------------- 

  always_ff @(posedge clk or posedge reset) begin : arbiter_logic 
    if (reset)
      arb <= ARB0; 
    else if (sclr) 
      arb <= ARB0; 
    else if (arb_ack) 
      unique case (arb)
        ARB0 : arb <= ARB1; 
        ARB1 : arb <= ARB2; 
        ARB2 : arb <= ARB0;
      endcase 
  end 

  //
  //
  //
  `ifndef HSSDRC_NOT_SHARE_ACT_COMMAND
    // use act command sharing 
    assign dec0_bank_access_enable = (dec0_pre & am_pre_enable [dec0_ba] ) |
                                     (dec0_act & am_act_enable [dec0_ba] ) ;
  
    assign dec1_bank_access_enable = (dec1_pre & am_pre_enable [dec1_ba] ) |
                                     (dec1_act & am_act_enable [dec1_ba] ) ;
  
    assign dec2_bank_access_enable = (dec2_pre & am_pre_enable [dec2_ba] ) |
                                     (dec2_act & am_act_enable [dec2_ba] ) ;
  `else 
    // not use act command sharing
    assign dec0_bank_access_enable = (dec0_pre & am_pre_enable [dec0_ba] ) ;
  
    assign dec1_bank_access_enable = (dec1_pre & am_pre_enable [dec1_ba] ) ;
  
    assign dec2_bank_access_enable = (dec2_pre & am_pre_enable [dec2_ba] ) ;
  `endif 
  //
  // 
  // 
  assign dec0_access_enable = (dec0_read   & am_read_enable   [dec0_ba] ) | 
                              (dec0_write  & am_write_enable  [dec0_ba] ) |
                              (dec0_pre    & am_pre_enable    [dec0_ba] ) |
                              (dec0_act    & am_act_enable    [dec0_ba] ) ;

  assign dec1_access_enable = (dec1_read   & am_read_enable   [dec1_ba] ) | 
                              (dec1_write  & am_write_enable  [dec1_ba] ) | 
                              (dec1_pre    & am_pre_enable    [dec1_ba] ) |
                              (dec1_act    & am_act_enable    [dec1_ba] ) ;


  assign dec2_access_enable = (dec2_read   & am_read_enable   [dec2_ba] ) | 
                              (dec2_write  & am_write_enable  [dec2_ba] ) | 
                              (dec2_pre    & am_pre_enable    [dec2_ba] ) |
                              (dec2_act    & am_act_enable    [dec2_ba] ) ;
  //
  //
  //
  assign dec0_access_done   = (dec0_refr  & dec0_refr_enable) | 
                              (dec0_last & 
                                ((dec0_read  & dec0_read_enable  ) | 
                                ( dec0_write & dec0_write_enable ))
                                );

  assign dec1_access_done   = (dec1_refr  & dec1_refr_enable) | 
                              (dec1_last & 
                                ((dec1_read  & dec1_read_enable  ) | 
                                ( dec1_write & dec1_write_enable ))
                                );

  assign dec2_access_done   = (dec2_refr  & dec2_refr_enable) | 
                              (dec2_last & 
                                ((dec2_read  & dec2_read_enable  ) | 
                                ( dec2_write & dec2_write_enable ))
                                );
  //
  //
  //
  assign arb_ack = (dec0_access_done && (arb == ARB0)) |
                   (dec1_access_done && (arb == ARB1)) |
                   (dec2_access_done && (arb == ARB2));  
  //-------------------------------------------------------------------------------------------------- 
  // decoder roundabout : dec0 -> dec1 -> dec2 -> dec0 -> dec1
  //
  // arbiter for command pipeline need in folow comparators : 
  // 0  : dec0 - dec1 -> select dec1
  //    : dec0 - dec2 & dec1 - dec2 -> select dec2
  // 1  : dec1 - dec2 -> select dec2
  //    : dec1 - dec2 & dec2 - dec0 -> select dec0
  // 2  : dec2 - dec0 -> select dec0
  //    : dec2 - dec1 & dec0 - dec1 -> select dec1
  // we can reclock it. becouse "ba" and "locked" is valid 1 tick before command 
  //-------------------------------------------------------------------------------------------------- 
  
  always_ff @(posedge clk) begin : locked_and_bank_access_comparator
    dec1_can_have_access_when_arb_is_0  <= ~dec0_locked & (dec1_ba != dec0_ba);
    dec2_can_have_access_when_arb_is_0  <= ~dec0_locked & (dec2_ba != dec0_ba) & ~dec1_locked & (dec2_ba != dec1_ba);

    dec2_can_have_access_when_arb_is_1  <= ~dec1_locked & (dec2_ba != dec1_ba); 
    dec0_can_have_access_when_arb_is_1  <= ~dec1_locked & (dec0_ba != dec1_ba) & ~dec2_locked & (dec0_ba != dec2_ba); 

    dec0_can_have_access_when_arb_is_2  <= ~dec2_locked & (dec0_ba != dec2_ba);  
    dec1_can_have_access_when_arb_is_2  <= ~dec2_locked & (dec1_ba != dec2_ba) & ~dec0_locked & (dec1_ba != dec0_ba);
  end 

  //
  //
  //

  always_comb begin : control_path_arbiter 

    dec0_pre_all_enable = 1'b0;
    dec0_refr_enable    = 1'b0;
    dec0_pre_enable     = 1'b0;
    dec0_act_enable     = 1'b0;
    dec0_read_enable    = 1'b0;
    dec0_write_enable   = 1'b0;

    dec1_pre_all_enable = 1'b0;
    dec1_refr_enable    = 1'b0;
    dec1_pre_enable     = 1'b0;
    dec1_act_enable     = 1'b0;
    dec1_read_enable    = 1'b0;
    dec1_write_enable   = 1'b0;

    dec2_pre_all_enable = 1'b0;
    dec2_refr_enable    = 1'b0;
    dec2_pre_enable     = 1'b0;
    dec2_act_enable     = 1'b0;
    dec2_read_enable    = 1'b0;
    dec2_write_enable   = 1'b0;

    arb_pre_all = 1'b0;    
    arb_refr    = 1'b0;    
    arb_pre     = 1'b0;    
    arb_act     = 1'b0;    
    arb_read    = 1'b0;    
    arb_write   = 1'b0; 

    ba_rowa_mux = arb; 

    unique case (arb)
      ARB0 : begin : dec0_is_master 

        dec0_pre_all_enable = am_pre_all_enable             ;
        dec0_refr_enable    = am_refr_enable                ;
        dec0_pre_enable     = am_pre_enable     [dec0_ba];
        dec0_act_enable     = am_act_enable     [dec0_ba];
        dec0_read_enable    = am_read_enable    [dec0_ba];
        dec0_write_enable   = am_write_enable   [dec0_ba];

        arb_pre_all = dec0_pre_all & dec0_pre_all_enable ;
        arb_refr    = dec0_refr    & dec0_refr_enable    ;
        arb_pre     = dec0_pre     & dec0_pre_enable     ;
        arb_act     = dec0_act     & dec0_act_enable     ;
        arb_read    = dec0_read    & dec0_read_enable    ;
        arb_write   = dec0_write   & dec0_write_enable   ;

`ifndef HSSDRC_SHARE_NONE_DECODER        

        if (~dec0_access_enable) begin 

          if (dec1_can_have_access_when_arb_is_0) begin 

            ba_rowa_mux = ARB1; 
            //            
            dec1_pre_enable  = am_pre_enable [dec1_ba];

            arb_pre          = dec1_pre & dec1_pre_enable ;
            //
            `ifndef HSSDRC_NOT_SHARE_ACT_COMMAND 
              dec1_act_enable  = am_act_enable [dec1_ba];   
              
              arb_act          = dec1_act & dec1_act_enable ;
            `endif
                 
          end 

    `ifndef HSSDRC_SHARE_ONE_DECODER 
          if (~dec1_bank_access_enable & dec2_can_have_access_when_arb_is_0) begin 
    `else 
          else if (dec2_can_have_access_when_arb_is_0) begin
    `endif 
            ba_rowa_mux = ARB2; 
            //
            dec2_pre_enable  = am_pre_enable [dec2_ba];

            arb_pre          = dec2_pre & dec2_pre_enable ;
            // 
            `ifndef HSSDRC_NOT_SHARE_ACT_COMMAND
              dec2_act_enable  = am_act_enable [dec2_ba];   
            
              arb_act          = dec2_act & dec2_act_enable ;
            `endif 
     
          end 
        end 
`endif // HSSDRC_SHARE_NONE_DECODER
      end 

      ARB1 : begin : dec1_is_master

        dec1_pre_all_enable = am_pre_all_enable             ;
        dec1_refr_enable    = am_refr_enable                ;
        dec1_pre_enable     = am_pre_enable     [dec1_ba];
        dec1_act_enable     = am_act_enable     [dec1_ba];
        dec1_read_enable    = am_read_enable    [dec1_ba];
        dec1_write_enable   = am_write_enable   [dec1_ba];

        arb_pre_all = dec1_pre_all & dec1_pre_all_enable ;
        arb_refr    = dec1_refr    & dec1_refr_enable    ;
        arb_pre     = dec1_pre     & dec1_pre_enable     ;
        arb_act     = dec1_act     & dec1_act_enable     ;
        arb_read    = dec1_read    & dec1_read_enable    ;
        arb_write   = dec1_write   & dec1_write_enable   ;

`ifndef HSSDRC_SHARE_NONE_DECODER        

        if (~dec1_access_enable) begin 

          if (dec2_can_have_access_when_arb_is_1) begin 

            ba_rowa_mux = ARB2;
            //
            dec2_pre_enable  = am_pre_enable   [dec2_ba];

            arb_pre          = dec2_pre & dec2_pre_enable ; 
            //
            `ifndef HSSDRC_NOT_SHARE_ACT_COMMAND
              dec2_act_enable  = am_act_enable   [dec2_ba];  

              arb_act          = dec2_act & dec2_act_enable ; 
            `endif 

          end 

    `ifndef HSSDRC_SHARE_ONE_DECODER
          if (~dec2_bank_access_enable & dec0_can_have_access_when_arb_is_1) begin 
    `else 
          else if (dec0_can_have_access_when_arb_is_1) begin
    `endif
            ba_rowa_mux = ARB0;
            //
            dec0_pre_enable  = am_pre_enable   [dec0_ba];

            arb_pre          = dec0_pre & dec0_pre_enable ; 
            // 
            `ifndef HSSDRC_NOT_SHARE_ACT_COMMAND
              dec0_act_enable  = am_act_enable   [dec0_ba]; 

              arb_act          = dec0_act & dec0_act_enable ; 
            `endif 

          end 
        end 
`endif // HSSDRC_SHARE_NONE_DECODER
      end 

      ARB2 : begin : dec2_is_master

        dec2_pre_all_enable = am_pre_all_enable               ;
        dec2_refr_enable    = am_refr_enable                  ;
        dec2_pre_enable     = am_pre_enable     [dec2_ba]  ;
        dec2_act_enable     = am_act_enable     [dec2_ba]  ;
        dec2_read_enable    = am_read_enable    [dec2_ba]  ;
        dec2_write_enable   = am_write_enable   [dec2_ba]  ;

        arb_pre_all = dec2_pre_all & dec2_pre_all_enable ;
        arb_refr    = dec2_refr    & dec2_refr_enable    ;
        arb_pre     = dec2_pre     & dec2_pre_enable     ;
        arb_act     = dec2_act     & dec2_act_enable     ;
        arb_read    = dec2_read    & dec2_read_enable    ;
        arb_write   = dec2_write   & dec2_write_enable   ;

`ifndef HSSDRC_SHARE_NONE_DECODER

        if (~dec2_access_enable) begin 

          if (dec0_can_have_access_when_arb_is_2) begin 

            ba_rowa_mux = ARB0; 
            //
            dec0_pre_enable  = am_pre_enable   [dec0_ba];

            arb_pre          = dec0_pre & dec0_pre_enable ;
            //
            `ifndef HSSDRC_NOT_SHARE_ACT_COMMAND
              dec0_act_enable  = am_act_enable   [dec0_ba];

              arb_act          = dec0_act & dec0_act_enable ;
            `endif 
                    
          end 

    `ifndef HSSDRC_SHARE_ONE_DECODER
          if (~dec0_bank_access_enable & dec1_can_have_access_when_arb_is_2) begin 
    `else 
          else if (dec1_can_have_access_when_arb_is_2) begin
    `endif 
            ba_rowa_mux = ARB1;
            //
            dec1_pre_enable  = am_pre_enable   [dec1_ba];

            arb_pre          = dec1_pre & dec1_pre_enable  ;
            //
            `ifndef HSSDRC_NOT_SHARE_ACT_COMMAND
              dec1_act_enable  = am_act_enable   [dec1_ba];    

              arb_act          = dec1_act & dec1_act_enable  ;
            `endif

          end 
        end 
`endif // HSSDRC_SHARE_NONE_DECODER
      end 
    endcase 
  end 



  always_comb begin : mux_addr_path2arbiter 

    //
    // no complex mux : used in read/write command 
    //

    arb_cola   = dec0_cola; 
    arb_chid   = dec0_chid;
    arb_burst  = dec0_burst; 

    unique case (arb) 
      ARB0 : begin 
        arb_cola   = dec0_cola;
        arb_chid   = dec0_chid;
        arb_burst  = dec0_burst; 
        end 
      ARB1 : begin 
        arb_cola   = dec1_cola;
        arb_chid   = dec1_chid;
        arb_burst  = dec1_burst; 
        end 
      ARB2 : begin 
        arb_cola   = dec2_cola;      
        arb_chid   = dec2_chid;
        arb_burst  = dec2_burst; 
        end 
      default : begin end 
    endcase

    //
    // complex mux used in pre command
    //

    arb_ba     = dec0_ba;  

    unique case (ba_rowa_mux) 
      ARB0 : arb_ba = dec0_ba; 
      ARB1 : arb_ba = dec1_ba; 
      ARB2 : arb_ba = dec2_ba; 
    endcase 

    //
    // complex mux used in act command
    //

    arb_rowa   = dec0_rowa;

`ifndef HSSDRC_NOT_SHARE_ACT_COMMAND
      unique case (ba_rowa_mux) 
`else 
      unique case (arb) 
`endif 
      ARB0 : arb_rowa = dec0_rowa;  
      ARB1 : arb_rowa = dec1_rowa;  
      ARB2 : arb_rowa = dec2_rowa;  
    endcase

  end 

endmodule 
