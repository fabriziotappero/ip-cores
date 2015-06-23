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
// Workfile     : hssdrc_decoder.v
// 
// Description  : sdram command sequence decoder's array
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

module hssdrc_decoder (
  clk               ,
  reset             ,
  sclr              ,
  //
  ba_map_update     ,
  ba_map_clear      ,
  ba_map_ba         ,
  ba_map_rowa       ,
  ba_map_pre_act_rw ,
  ba_map_act_rw     ,
  ba_map_rw         ,
  ba_map_all_close  ,
  //
  arb0_write        ,
  arb0_read         ,
  arb0_refr         ,
  arb0_rowa         ,
  arb0_cola         ,
  arb0_ba           ,
  arb0_burst        ,
  arb0_chid         ,
  arb0_ready        ,
  //
  arb1_write        ,
  arb1_read         ,
  arb1_refr         ,
  arb1_rowa         ,
  arb1_cola         ,
  arb1_ba           ,
  arb1_burst        ,
  arb1_chid         ,
  arb1_ready        ,
  //
  arb2_write        ,
  arb2_read         ,
  arb2_refr         ,
  arb2_rowa         ,
  arb2_cola         ,
  arb2_ba           ,
  arb2_burst        ,
  arb2_chid         ,
  arb2_ready        ,
  //
  dec0_pre_all        ,
  dec0_refr           ,
  dec0_pre            ,
  dec0_act            ,
  dec0_read           ,
  dec0_write          ,
  dec0_pre_all_enable ,
  dec0_refr_enable    ,
  dec0_pre_enable     ,
  dec0_act_enable     ,
  dec0_read_enable    ,
  dec0_write_enable   ,
  dec0_locked         ,
  dec0_last           ,
  dec0_rowa           ,
  dec0_cola           ,
  dec0_ba             ,
  dec0_chid           ,
  dec0_burst          ,
  //
  dec1_pre_all        ,
  dec1_refr           ,
  dec1_pre            ,
  dec1_act            ,
  dec1_read           ,
  dec1_write          ,
  dec1_pre_all_enable ,
  dec1_refr_enable    ,
  dec1_pre_enable     ,
  dec1_act_enable     ,
  dec1_read_enable    ,
  dec1_write_enable   ,
  dec1_locked         ,
  dec1_last           ,
  dec1_rowa           ,
  dec1_cola           ,
  dec1_ba             ,
  dec1_chid           ,
  dec1_burst          ,
  //
  dec2_pre_all        ,
  dec2_refr           ,
  dec2_pre            ,
  dec2_act            ,
  dec2_read           ,
  dec2_write          ,
  dec2_pre_all_enable ,
  dec2_refr_enable    ,
  dec2_pre_enable     ,
  dec2_act_enable     ,
  dec2_read_enable    ,
  dec2_write_enable   ,
  dec2_locked         ,
  dec2_last           ,
  dec2_rowa           ,
  dec2_cola           ,
  dec2_ba             ,
  dec2_chid           ,
  dec2_burst                                
  );

  input  wire   clk  ;
  input  wire   reset;
  input  wire   sclr ;

  //-------------------------------------------------------------------------------------------------- 
  // bank map interface 
  //-------------------------------------------------------------------------------------------------- 

  output wire   ba_map_update    ;    
  output wire   ba_map_clear     ;     
  output ba_t   ba_map_ba        ;        
  output rowa_t ba_map_rowa      ;                           
  input  wire   ba_map_pre_act_rw;
  input  wire   ba_map_act_rw    ;    
  input  wire   ba_map_rw        ;        
  input  wire   ba_map_all_close ; 

  //-------------------------------------------------------------------------------------------------- 
  // interface from input arbiter 
  //-------------------------------------------------------------------------------------------------- 

  input   logic   arb0_write ; 
  input   logic   arb0_read  ; 
  input   logic   arb0_refr  ; 
  input   rowa_t  arb0_rowa  ; 
  input   cola_t  arb0_cola  ; 
  input   ba_t    arb0_ba    ;   
  input   burst_t arb0_burst ;
  input   chid_t  arb0_chid  ; 
  output  wire    arb0_ready ;
  //
  input   logic   arb1_write ; 
  input   logic   arb1_read  ; 
  input   logic   arb1_refr  ; 
  input   rowa_t  arb1_rowa  ; 
  input   cola_t  arb1_cola  ; 
  input   ba_t    arb1_ba    ;   
  input   burst_t arb1_burst ;
  input   chid_t  arb1_chid  ; 
  output  wire    arb1_ready ;
  //
  input   logic   arb2_write ; 
  input   logic   arb2_read  ; 
  input   logic   arb2_refr  ; 
  input   rowa_t  arb2_rowa  ; 
  input   cola_t  arb2_cola  ; 
  input   ba_t    arb2_ba    ;   
  input   burst_t arb2_burst ;
  input   chid_t  arb2_chid  ; 
  output  wire    arb2_ready ;

  //-------------------------------------------------------------------------------------------------- 
  // inteface to output arbiter 
  //-------------------------------------------------------------------------------------------------- 

  output logic         dec0_pre_all       ;   
  output logic         dec0_refr          ;   
  output logic         dec0_pre           ;   
  output logic         dec0_act           ;   
  output logic         dec0_read          ;   
  output logic         dec0_write         ;   
  input  wire          dec0_pre_all_enable;
  input  wire          dec0_refr_enable   ;
  input  wire          dec0_pre_enable    ;
  input  wire          dec0_act_enable    ;
  input  wire          dec0_read_enable   ;
  input  wire          dec0_write_enable  ;
  output logic         dec0_locked        ;     
  output logic         dec0_last          ;     
  output rowa_t        dec0_rowa          ;     
  output cola_t        dec0_cola          ;     
  output ba_t          dec0_ba            ;     
  output chid_t        dec0_chid          ;     
  output sdram_burst_t dec0_burst         ; 
  //
  output logic         dec1_pre_all       ;   
  output logic         dec1_refr          ;   
  output logic         dec1_pre           ;   
  output logic         dec1_act           ;   
  output logic         dec1_read          ;   
  output logic         dec1_write         ;   
  input  wire          dec1_pre_all_enable;
  input  wire          dec1_refr_enable   ;
  input  wire          dec1_pre_enable    ;
  input  wire          dec1_act_enable    ;
  input  wire          dec1_read_enable   ;
  input  wire          dec1_write_enable  ;
  output logic         dec1_locked        ;     
  output logic         dec1_last          ;     
  output rowa_t        dec1_rowa          ;     
  output cola_t        dec1_cola          ;     
  output ba_t          dec1_ba            ;     
  output chid_t        dec1_chid          ;     
  output sdram_burst_t dec1_burst         ; 
  //
  output logic         dec2_pre_all       ;   
  output logic         dec2_refr          ;   
  output logic         dec2_pre           ;   
  output logic         dec2_act           ;   
  output logic         dec2_read          ;   
  output logic         dec2_write         ;   
  input  wire          dec2_pre_all_enable;
  input  wire          dec2_refr_enable   ;
  input  wire          dec2_pre_enable    ;
  input  wire          dec2_act_enable    ;
  input  wire          dec2_read_enable   ;
  input  wire          dec2_write_enable  ;
  output logic         dec2_locked        ;     
  output logic         dec2_last          ;     
  output rowa_t        dec2_rowa          ;     
  output cola_t        dec2_cola          ;     
  output ba_t          dec2_ba            ;     
  output chid_t        dec2_chid          ;     
  output sdram_burst_t dec2_burst         ; 
   
  //-------------------------------------------------------------------------------------------------- 
  //
  //-------------------------------------------------------------------------------------------------- 

  ba_t    ba_latched  ;
  rowa_t  rowa_latched;

  //
  // local state ba_map signals 
  // 

  wire state0__ba_map_update      ;
  wire state0__ba_map_clear       ;
  wire state0__ba_map_pre_act_rw  ;
  wire state0__ba_map_act_rw      ;
  wire state0__ba_map_rw          ;
  wire state0__ba_map_all_close   ;

  wire state1__ba_map_update      ;
  wire state1__ba_map_clear       ;
  wire state1__ba_map_pre_act_rw  ;
  wire state1__ba_map_act_rw      ;
  wire state1__ba_map_rw          ;
  wire state1__ba_map_all_close   ;

  wire state2__ba_map_update      ;
  wire state2__ba_map_clear       ;
  wire state2__ba_map_pre_act_rw  ;
  wire state2__ba_map_act_rw      ;
  wire state2__ba_map_rw          ;
  wire state2__ba_map_all_close   ;

  //-------------------------------------------------------------------------------------------------- 
  // we can capture bank map data into register, becouse we have +1 tick in FSM 
  // for bank map decoding we can take data from any arbiter channel 
  //-------------------------------------------------------------------------------------------------- 

  always_ff @(posedge clk) begin : ba_map_data_register 
    ba_latched    <= arb0_ba; 
    rowa_latched  <= arb0_rowa; 
  end 

  //
  //
  //

  assign ba_map_ba     = ba_latched; 
  assign ba_map_rowa   = rowa_latched;
  assign ba_map_update = state0__ba_map_update | state1__ba_map_update | state2__ba_map_update ; 
  assign ba_map_clear  = state0__ba_map_clear  | state1__ba_map_clear  | state2__ba_map_clear  ; 

  assign state0__ba_map_pre_act_rw  = ba_map_pre_act_rw  ;
  assign state0__ba_map_act_rw      = ba_map_act_rw      ;
  assign state0__ba_map_rw          = ba_map_rw          ;
  assign state0__ba_map_all_close   = ba_map_all_close   ;

  assign state1__ba_map_pre_act_rw  = ba_map_pre_act_rw  ;
  assign state1__ba_map_act_rw      = ba_map_act_rw      ;
  assign state1__ba_map_rw          = ba_map_rw          ;
  assign state1__ba_map_all_close   = ba_map_all_close   ;
                
  assign state2__ba_map_pre_act_rw  = ba_map_pre_act_rw  ;
  assign state2__ba_map_act_rw      = ba_map_act_rw      ;
  assign state2__ba_map_rw          = ba_map_rw          ;
  assign state2__ba_map_all_close   = ba_map_all_close   ;

  //-------------------------------------------------------------------------------------------------- 
  //
  //-------------------------------------------------------------------------------------------------- 
  hssdrc_decoder_state state0 (
    .clk               (clk  ),  
    .reset             (reset),
    .sclr              (sclr ),
    //
    .ba_map_update     (state0__ba_map_update    ),
    .ba_map_clear      (state0__ba_map_clear     ),
    .ba_map_pre_act_rw (state0__ba_map_pre_act_rw),
    .ba_map_act_rw     (state0__ba_map_act_rw    ),
    .ba_map_rw         (state0__ba_map_rw        ),
    .ba_map_all_close  (state0__ba_map_all_close ),
    //                 
    .arb_write         (arb0_write),
    .arb_read          (arb0_read ),
    .arb_refr          (arb0_refr ),
    .arb_rowa          (arb0_rowa ),
    .arb_cola          (arb0_cola ),
    .arb_ba            (arb0_ba   ),
    .arb_burst         (arb0_burst),
    .arb_chid          (arb0_chid ),
    .arb_ready         (arb0_ready),
    //                 
    .dec_pre_all       (dec0_pre_all),
    .dec_refr          (dec0_refr   ),
    .dec_pre           (dec0_pre    ),
    .dec_act           (dec0_act    ),
    .dec_read          (dec0_read   ),
    .dec_write         (dec0_write  ),
    //                 
    .dec_pre_all_enable(dec0_pre_all_enable),
    .dec_refr_enable   (dec0_refr_enable   ),
    .dec_pre_enable    (dec0_pre_enable    ),
    .dec_act_enable    (dec0_act_enable    ),
    .dec_read_enable   (dec0_read_enable   ),
    .dec_write_enable  (dec0_write_enable  ),
    //                 
    .dec_locked        (dec0_locked),
    .dec_last          (dec0_last  ),
    //                 
    .dec_rowa          (dec0_rowa ),
    .dec_cola          (dec0_cola ),
    .dec_ba            (dec0_ba   ),
    .dec_chid          (dec0_chid ),
    //                 
    .dec_burst         (dec0_burst) 
  ); 
  //-------------------------------------------------------------------------------------------------- 
  //
  //-------------------------------------------------------------------------------------------------- 
  hssdrc_decoder_state state1 (
    .clk               (clk  ),  
    .reset             (reset),
    .sclr              (sclr ),
    //
    .ba_map_update     (state1__ba_map_update    ),
    .ba_map_clear      (state1__ba_map_clear     ),
    .ba_map_pre_act_rw (state1__ba_map_pre_act_rw),
    .ba_map_act_rw     (state1__ba_map_act_rw    ),
    .ba_map_rw         (state1__ba_map_rw        ),
    .ba_map_all_close  (state1__ba_map_all_close ),
    //                 
    .arb_write         (arb1_write),
    .arb_read          (arb1_read ),
    .arb_refr          (arb1_refr ),
    .arb_rowa          (arb1_rowa ),
    .arb_cola          (arb1_cola ),
    .arb_ba            (arb1_ba   ),
    .arb_burst         (arb1_burst),
    .arb_chid          (arb1_chid ),
    .arb_ready         (arb1_ready),
    //                 
    .dec_pre_all       (dec1_pre_all),
    .dec_refr          (dec1_refr   ),
    .dec_pre           (dec1_pre    ),
    .dec_act           (dec1_act    ),
    .dec_read          (dec1_read   ),
    .dec_write         (dec1_write  ),
    //                 
    .dec_pre_all_enable(dec1_pre_all_enable),
    .dec_refr_enable   (dec1_refr_enable   ),
    .dec_pre_enable    (dec1_pre_enable    ),
    .dec_act_enable    (dec1_act_enable    ),
    .dec_read_enable   (dec1_read_enable   ),
    .dec_write_enable  (dec1_write_enable  ),
    //                 
    .dec_locked        (dec1_locked),
    .dec_last          (dec1_last  ),
    //                 
    .dec_rowa          (dec1_rowa ),
    .dec_cola          (dec1_cola ),
    .dec_ba            (dec1_ba   ),
    .dec_chid          (dec1_chid ),
    //                 
    .dec_burst         (dec1_burst)      
  ); 
  //-------------------------------------------------------------------------------------------------- 
  //
  //-------------------------------------------------------------------------------------------------- 
  hssdrc_decoder_state state2 (
    .clk               (clk  ),  
    .reset             (reset),
    .sclr              (sclr ), 
    //
    .ba_map_update     (state2__ba_map_update    ),
    .ba_map_clear      (state2__ba_map_clear     ),
    .ba_map_pre_act_rw (state2__ba_map_pre_act_rw),
    .ba_map_act_rw     (state2__ba_map_act_rw    ),
    .ba_map_rw         (state2__ba_map_rw        ),
    .ba_map_all_close  (state2__ba_map_all_close ),
    //                 
    .arb_write         (arb2_write),
    .arb_read          (arb2_read ),
    .arb_refr          (arb2_refr ),
    .arb_rowa          (arb2_rowa ),
    .arb_cola          (arb2_cola ),
    .arb_ba            (arb2_ba   ),
    .arb_burst         (arb2_burst),
    .arb_chid          (arb2_chid ),
    .arb_ready         (arb2_ready),
    //                 
    .dec_pre_all       (dec2_pre_all),
    .dec_refr          (dec2_refr   ),
    .dec_pre           (dec2_pre    ),
    .dec_act           (dec2_act    ),
    .dec_read          (dec2_read   ),
    .dec_write         (dec2_write  ),
    //                 
    .dec_pre_all_enable(dec2_pre_all_enable),
    .dec_refr_enable   (dec2_refr_enable   ),
    .dec_pre_enable    (dec2_pre_enable    ),
    .dec_act_enable    (dec2_act_enable    ),
    .dec_read_enable   (dec2_read_enable   ),
    .dec_write_enable  (dec2_write_enable  ),
    //                 
    .dec_locked        (dec2_locked),
    .dec_last          (dec2_last  ),
    //                 
    .dec_rowa          (dec2_rowa ),
    .dec_cola          (dec2_cola ),
    .dec_ba            (dec2_ba   ),
    .dec_chid          (dec2_chid ),
    //                 
    .dec_burst         (dec2_burst) 
  ); 

endmodule 
