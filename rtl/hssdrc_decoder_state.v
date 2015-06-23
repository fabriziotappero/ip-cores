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
// Workfile     : hssdrc_decoder_state.v
// 
// Description  : sdram command sequence decoder
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

`include "hssdrc_timing.vh"
`include "hssdrc_define.vh"


module hssdrc_decoder_state (
  clk               ,
  reset             ,
  sclr              ,
  //
  ba_map_update     ,
  ba_map_clear      ,
  ba_map_pre_act_rw ,
  ba_map_act_rw     ,
  ba_map_rw         ,
  ba_map_all_close  ,
  //
  arb_write         ,
  arb_read          ,
  arb_refr          ,
  arb_rowa          ,
  arb_cola          ,
  arb_ba            ,
  arb_burst         ,
  arb_chid          ,
  arb_ready         ,
  //
  dec_pre_all       ,
  dec_refr          ,
  dec_pre           ,
  dec_act           ,
  dec_read          ,
  dec_write         ,  
  //
  dec_pre_all_enable,
  dec_refr_enable   ,
  dec_pre_enable    ,
  dec_act_enable    ,
  dec_read_enable   ,
  dec_write_enable  ,
  //
  dec_locked        ,
  dec_last          ,
  //
  dec_rowa          ,
  dec_cola          ,
  dec_ba            ,
  dec_chid          ,
  //
  dec_burst
  );

  input   wire  clk  ;
  input   wire  reset;
  input   wire  sclr ;

  //-------------------------------------------------------------------------------------------------- 
  // bank map interface 
  //-------------------------------------------------------------------------------------------------- 

  output  logic ba_map_update     ;
  output  logic ba_map_clear      ;
  input   wire  ba_map_pre_act_rw ;
  input   wire  ba_map_act_rw     ;
  input   wire  ba_map_rw         ;
  input   wire  ba_map_all_close  ;

  //-------------------------------------------------------------------------------------------------- 
  // interface from input arbiter 
  //-------------------------------------------------------------------------------------------------- 

  input   wire    arb_write ;
  input   wire    arb_read  ;
  input   wire    arb_refr  ;
  input   rowa_t  arb_rowa  ;
  input   cola_t  arb_cola  ;
  input   ba_t    arb_ba    ;  
  input   burst_t arb_burst ;
  input   chid_t  arb_chid  ;
  output  logic   arb_ready ;

  //-------------------------------------------------------------------------------------------------- 
  // inteface to output arbiter
  //-------------------------------------------------------------------------------------------------- 

  // logical commands 
  output logic          dec_pre_all       ;   
  output logic          dec_refr          ;   
  output logic          dec_pre           ;   
  output logic          dec_act           ;   
  output logic          dec_read          ;   
  output logic          dec_write         ;   
  // logical commands en
  input  wire          dec_pre_all_enable ;
  input  wire          dec_refr_enable    ;
  input  wire          dec_pre_enable     ;
  input  wire          dec_act_enable     ;
  input  wire          dec_read_enable    ;
  input  wire          dec_write_enable   ;
  // addititional signal                  
  output logic         dec_locked         ;     
  output logic         dec_last           ;     
  // control path                         
  output rowa_t        dec_rowa           ;     
  output cola_t        dec_cola           ;     
  output ba_t          dec_ba             ;     
  output chid_t        dec_chid           ;     
  //                                      
  output sdram_burst_t dec_burst          ; 

  //-------------------------------------------------------------------------------------------------- 
  //
  //-------------------------------------------------------------------------------------------------- 

  localparam int cTrp_m1  = cTrp  - 1;
  localparam int cTrcd_m1 = cTrcd - 1; 

  typedef enum {
    STATE_RESET_BIT   ,   // need for create simple true ready condition 
    STATE_IDLE_BIT    , 
    STATE_DECODE_BIT  , 
    STATE_PRE_BIT     , 
    STATE_TRP_BIT     , 
    STATE_ACT_BIT     , 
    STATE_TRCD_BIT    ,
    STATE_RW_BIT      , 
    STATE_ADDR_INC_BIT, 
    STATE_PRE_ALL_BIT , 
    STATE_REFR_BIT      
    } state_bits_e;

  //-------------------------------------------------------------------------------------------------- 
  //
  //-------------------------------------------------------------------------------------------------- 

  enum bit [10:0] {
    STATE_RESET     = (11'h1 << STATE_RESET_BIT)     , 
    STATE_IDLE      = (11'h1 << STATE_IDLE_BIT)      , 
    STATE_DECODE    = (11'h1 << STATE_DECODE_BIT)    , 
    STATE_PRE       = (11'h1 << STATE_PRE_BIT)       , 
    STATE_TRP       = (11'h1 << STATE_TRP_BIT)       , 
    STATE_ACT       = (11'h1 << STATE_ACT_BIT)       , 
    STATE_TRCD      = (11'h1 << STATE_TRCD_BIT)      , 
    STATE_RW        = (11'h1 << STATE_RW_BIT)        , 
    STATE_ADDR_INC  = (11'h1 << STATE_ADDR_INC_BIT)  , 
    STATE_PRE_ALL   = (11'h1 << STATE_PRE_ALL_BIT)   ,
    STATE_REFR      = (11'h1 << STATE_REFR_BIT)
    } state, next_state;

  logic   refr_mode       ; 
  logic   write_mode      ; 

  logic   burst_done      ; 
  logic   early_burst_done;

  cola_t  cola_latched  ;
  rowa_t  rowa_latched  ;
  ba_t    ba_latched    ;  
  chid_t  chid_latched  ;

  logic [3:0] burst_latched   ;
  logic [3:0] burst_shift_cnt ;

  logic [3:0] available_burst ; 

  logic [3:0] remained_burst      ; 
  logic [1:0] remained_burst_high ;
  logic [1:0] remained_burst_low  ;
  logic [1:0] remained_burst_low_latched;

  logic [3:0] last_used_burst; 
    
  wire trp_cnt_done; 
  wire trcd_cnt_done; 

  //-------------------------------------------------------------------------------------------------- 
  // use shift register instead of counter for trp time count 
  //-------------------------------------------------------------------------------------------------- 

  generate
    if (cTrp_m1 <= 1) begin : no_trp_cnt_generate 

      assign trp_cnt_done = 1'b1; 

    end 
    else begin : trp_cnt_generate 

      logic [cTrp_m1-2:0] trp_cnt;

      always_ff @(posedge clk) begin
        if (state [STATE_TRP_BIT])
          trp_cnt <= (trp_cnt << 1) | 1'b1; 
        else 
          trp_cnt <= '0;
      end 

      assign trp_cnt_done = trp_cnt [cTrp_m1-2]; 

    end 
  endgenerate 

  //-------------------------------------------------------------------------------------------------- 
  // use shift register instead of counter for trcd time count 
  //-------------------------------------------------------------------------------------------------- 

  generate
    if (cTrcd_m1 <= 1) begin : no_trcd_cnt_generate

      assign trcd_cnt_done = 1'b1;

    end 
    else begin : trcd_cnt_generate

      logic [cTrcd_m1-2:0] trcd_cnt; 

      always_ff @(posedge clk) begin 
        if (state [STATE_TRCD_BIT])
          trcd_cnt <= (trcd_cnt << 1) | 1'b1; 
        else 
          trcd_cnt <= '0;
      end 

      assign trcd_cnt_done = trcd_cnt [cTrcd_m1-2];

    end 
  endgenerate

  //-------------------------------------------------------------------------------------------------- 
  //
  //-------------------------------------------------------------------------------------------------- 

  always_comb begin : fsm_jump_decode 

    next_state = STATE_RESET; 

    unique case (1'b1) 

      state [STATE_RESET_BIT] : begin 
        next_state = STATE_IDLE; 
      end 
    
      state [STATE_IDLE_BIT] : begin 
        if (arb_write | arb_read | arb_refr)
          next_state = STATE_DECODE; 
        else 
          next_state = STATE_IDLE;
      end 
      //
      // decode branch 
      // 
      state [STATE_DECODE_BIT] : begin 
        if (refr_mode) begin : shorten_refresh_decode

          if (ba_map_all_close) 
            next_state = STATE_REFR; 
          else 
            next_state = STATE_PRE_ALL; 

        end 
        else begin : mode_of_rw_decode

          if (ba_map_pre_act_rw) 
            next_state = STATE_PRE; 
          else if (ba_map_rw) 
            next_state = STATE_RW; 
          else // if (ba_map_act_rw) 
            next_state = STATE_ACT;

        end 
      end 
      //
      // pre branch 
      // 
      state [STATE_PRE_BIT] : begin 
        if (dec_pre_enable) 

          if (cTrp_m1 == 0)
            next_state = STATE_ACT; 
          else 
            next_state = STATE_TRP;

        else 
          next_state = STATE_PRE;
      end 

      state [STATE_TRP_BIT] : begin 
        if (trp_cnt_done) 
          next_state = STATE_ACT; 
        else 
          next_state = STATE_TRP;
      end 
      //
      // act branch
      // 
      state [STATE_ACT_BIT] : begin 
        if (dec_act_enable) 

          if (cTrcd_m1 == 0)
            next_state = STATE_RW; 
          else 
            next_state = STATE_TRCD;

        else 
          next_state = STATE_ACT;
      end 

      state [STATE_TRCD_BIT] : begin 
        if (trcd_cnt_done) 
          next_state = STATE_RW;
        else 
          next_state = STATE_TRCD;
      end 
      //
      // data branch 
      // 
      state [STATE_RW_BIT] : begin 
        if ((dec_write_enable & write_mode) | (dec_read_enable & ~write_mode)) begin : burst_done_decode

          if (burst_done)
            next_state = STATE_IDLE; 
          else 
            next_state = STATE_ADDR_INC;

        end 
        else begin 
          next_state = STATE_RW;
        end           
      end 

      state [STATE_ADDR_INC_BIT] : begin 
        next_state = STATE_RW;
      end 
      //
      // refresh breanch 
      //
      state [STATE_PRE_ALL_BIT] : begin 
        if (dec_pre_all_enable)
          next_state = STATE_REFR; 
        else 
          next_state = STATE_PRE_ALL;
      end 

      state [STATE_REFR_BIT] : begin 
        if (dec_refr_enable)
          next_state = STATE_IDLE; 
        else 
          next_state = STATE_REFR;
      end 

    endcase 
  end 

  //---------------------------------------------------------------------------------------------------
  // 
  //---------------------------------------------------------------------------------------------------

  always_ff @(posedge clk or posedge reset) begin : fsm_register_process
    if (reset)      state <= STATE_RESET;
    else if (sclr)  state <= STATE_RESET; 
    else            state <= next_state; 
  end 
                  
  //---------------------------------------------------------------------------------------------------
  // 
  //---------------------------------------------------------------------------------------------------

  assign arb_ready   = state[STATE_IDLE_BIT];

  assign dec_pre_all = state[STATE_PRE_ALL_BIT]; 
  assign dec_refr    = state[STATE_REFR_BIT];
  assign dec_pre     = state[STATE_PRE_BIT];
  assign dec_act     = state[STATE_ACT_BIT];
  assign dec_read    = state[STATE_RW_BIT] & ~write_mode;
  assign dec_write   = state[STATE_RW_BIT] &  write_mode;
  assign dec_last    = state[STATE_RW_BIT] & burst_done ;

  // 
  // instead of decode state_refr_bit & state_pre_all_bit we can use refresh mode register 
  // 
  
  assign dec_locked = refr_mode;   

  //-------------------------------------------------------------------------------------------------- 
  //
  //-------------------------------------------------------------------------------------------------- 

  assign ba_map_update   = state[STATE_DECODE_BIT] & ~refr_mode;
  assign ba_map_clear    = state[STATE_DECODE_BIT] &  refr_mode;

  always_ff @(posedge clk) begin : mode_logic 
    if (state [STATE_IDLE_BIT]) begin 
      refr_mode   <= arb_refr; 
      write_mode  <= arb_write;
    end 
  end 

  //-------------------------------------------------------------------------------------------------- 
  //
  //-------------------------------------------------------------------------------------------------- 

  always_ff @(posedge clk) begin : addr_chid_logic

    if (state[STATE_IDLE_BIT]) begin 
      rowa_latched <= arb_rowa;
      ba_latched   <= arb_ba;
      chid_latched <= arb_chid;
    end 

    if (state[STATE_IDLE_BIT]) 
      cola_latched <= arb_cola; 
    else if (state[STATE_ADDR_INC_BIT])
      cola_latched <= cola_latched + last_used_burst;

  end 

  assign dec_cola  = cola_latched;
  assign dec_rowa  = rowa_latched;
  assign dec_ba    = ba_latched;
  assign dec_chid  = chid_latched;


  //-------------------------------------------------------------------------------------------------- 
  // alligned burst max cycles is 4 
  // burst [3:2] == 0 & burst[1:0] <= available_burst. 1 cycle is burst 
  // burst [3:2] != 0 & burst[1:0] <= available_burst. 1 cycle is burst             shift_cnt burst_done 
  // burst [ 1.. 4] : encoded with [ 4'd0 :  4'd3] : cycle is 1 : burst_shift_cnt =  4'b0000    1
  // burst [ 5.. 8] : encoded with [ 4'd4 :  4'd7] : cycle is 2 : burst_shift_cnt =  4'b0001    0
  // burst [ 9..12] : encoded with [ 4'd8 : 4'd11] : cycle is 3 : burst_shift_cnt =  4'b0010    0
  // burst [13..16] : encoded with [4'd12 : 4'd15] : cycle is 4 : burst_shift_cnt =  4'b0100    0
  // 

  // not alligned burst max cycles is 5                                             shift_cnt burst_done 
  // burst [ 1.. 4] : encoded with [ 4'd0 :  4'd3] : cycle is 2 : burst_shift_cnt =  4'b0001    0
  // burst [ 5.. 8] : encoded with [ 4'd4 :  4'd7] : cycle is 3 : burst_shift_cnt =  4'b0010    0
  // burst [ 9..12] : encoded with [ 4'd8 : 4'd11] : cycle is 4 : burst_shift_cnt =  4'b0100    0
  // burst [13..16] : encoded with [4'd12 : 4'd15] : cycle is 5 : burst_shift_cnt =  4'b1000    0
  //-------------------------------------------------------------------------------------------------- 

  always_ff @(posedge clk) begin : burst_latch_logic 
    if (state[STATE_IDLE_BIT]) 
      burst_latched  = arb_burst;      
  end 

  // remember that burst has -1 offset 
  // available burst has -1 offset too

  assign available_burst      = 4'b0011 - {2'b00, cola_latched[1:0]}; 

  assign remained_burst       = burst_latched - available_burst - 1'b1; 
  assign remained_burst_high  = remained_burst[3:2];
  assign remained_burst_low   = remained_burst[1:0];

  assign early_burst_done     = burst_shift_cnt[0];
  
  always_ff @(posedge clk) begin : burst_logic 
    if (state[STATE_DECODE_BIT]) begin 

      if (burst_latched <= available_burst) begin 

        burst_shift_cnt <= '0;

        burst_done   <= 1'b1;        // only 1 transaction will be 
        dec_burst    <= burst_latched[1:0];

      end 
      else begin 

        burst_shift_cnt   <= '0;
        burst_shift_cnt[remained_burst_high] <= 1'b1;

        remained_burst_low_latched <= remained_burst_low;

        burst_done <= 1'b0; // more then 2 transaction will be  
                
        dec_burst    <= available_burst[1:0]; 
        last_used_burst <= {2'b00, available_burst[1:0]} + 1'b1; // + 1 is compensation of -1 offset 

      end     
    end 
    else if (state[STATE_ADDR_INC_BIT]) begin 

      burst_shift_cnt <= burst_shift_cnt >> 1;      

      burst_done <= early_burst_done;
      //
      if (early_burst_done)
        dec_burst <= remained_burst_low_latched; // no transaction any more 
      else 
        dec_burst <= 2'b11; 
      // 
      last_used_burst <= 4'b0011 + 1'b1;
    end 
  end 

endmodule 
