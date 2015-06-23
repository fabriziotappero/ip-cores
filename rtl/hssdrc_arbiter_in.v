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
// Workfile     : hssdrc_arbiter_in.v
// 
// Description  : input 3 way decode arbiter
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

module hssdrc_arbiter_in (
  clk               ,
  reset             ,
  sclr              ,
  //
  sys_write         ,
  sys_read          ,
  sys_refr          ,
  sys_rowa          ,
  sys_cola          ,
  sys_ba            ,
  sys_burst         ,
  sys_chid_i        ,
  sys_ready         ,
  //
  refr_cnt_ack      ,
  refr_cnt_hi_req   ,
  refr_cnt_low_req  ,
  //
  dec0_write        ,
  dec0_read         ,
  dec0_refr         ,
  dec0_rowa         ,
  dec0_cola         ,
  dec0_ba           ,
  dec0_burst        ,
  dec0_chid         ,
  dec0_ready        ,
  //                        
  dec1_write        ,
  dec1_read         ,
  dec1_refr         ,
  dec1_rowa         ,
  dec1_cola         ,
  dec1_ba           ,
  dec1_burst        ,
  dec1_chid         ,
  dec1_ready        ,
  //                    
  dec2_write        ,
  dec2_read         ,
  dec2_refr         ,
  dec2_rowa         ,
  dec2_cola         ,
  dec2_ba           ,
  dec2_burst        ,
  dec2_chid         ,
  dec2_ready     
  );

  input   wire  clk   ; 
  input   wire  reset ; 
  input   wire  sclr  ; 

  //-------------------------------------------------------------------------------------------------- 
  // interface from refresh cycle generator 
  //-------------------------------------------------------------------------------------------------- 

  output  logic refr_cnt_ack      ;
  input   wire  refr_cnt_hi_req   ;
  input   wire  refr_cnt_low_req  ;

  //-------------------------------------------------------------------------------------------------- 
  // interface from system 
  //-------------------------------------------------------------------------------------------------- 

  input   wire    sys_write  ;
  input   wire    sys_read   ; 
  input   wire    sys_refr   ; 
  input   rowa_t  sys_rowa   ; 
  input   cola_t  sys_cola   ; 
  input   ba_t    sys_ba     ;   
  input   burst_t sys_burst  ;
  input   chid_t  sys_chid_i ;
  output  logic   sys_ready  ;

  //-------------------------------------------------------------------------------------------------- 
  // interface to sdram sequence decoders
  //-------------------------------------------------------------------------------------------------- 

  output  logic   dec0_write ; 
  output  logic   dec0_read  ; 
  output  logic   dec0_refr  ; 
  output  rowa_t  dec0_rowa  ; 
  output  cola_t  dec0_cola  ; 
  output  ba_t    dec0_ba    ;   
  output  burst_t dec0_burst ;
  output  chid_t  dec0_chid  ; 
  input   wire    dec0_ready ;                 
  //
  output  logic   dec1_write ; 
  output  logic   dec1_read  ; 
  output  logic   dec1_refr  ; 
  output  rowa_t  dec1_rowa  ; 
  output  cola_t  dec1_cola  ; 
  output  ba_t    dec1_ba    ;   
  output  burst_t dec1_burst ;
  output  chid_t  dec1_chid  ; 
  input   wire    dec1_ready ;                 
  //
  output  logic   dec2_write ; 
  output  logic   dec2_read  ; 
  output  logic   dec2_refr  ; 
  output  rowa_t  dec2_rowa  ; 
  output  cola_t  dec2_cola  ; 
  output  ba_t    dec2_ba    ;   
  output  burst_t dec2_burst ;
  output  chid_t  dec2_chid  ; 
  input   wire    dec2_ready ;                 

  //-------------------------------------------------------------------------------------------------- 
  // 
  //-------------------------------------------------------------------------------------------------- 

  wire sys_lock     ; 
  wire low_req_lock ; 
  wire arb_write    ; 
  wire arb_read     ; 
  wire arb_refr     ; 
  wire arb_ready    ;
  wire arb_ack      ;
  wire arb_refr_ack ;
  logic [2:0] arb;

  //-------------------------------------------------------------------------------------------------- 
  // 
  //-------------------------------------------------------------------------------------------------- 

  assign sys_lock     = refr_cnt_hi_req;
  assign low_req_lock = sys_write | sys_read | sys_refr;

  //
  //
  //

  assign arb_write    = sys_write & ~sys_lock; 
  assign arb_read     = sys_read  & ~sys_lock;
  assign arb_refr     = sys_refr | refr_cnt_hi_req | (refr_cnt_low_req & ~low_req_lock);  
  assign arb_ready    = dec0_ready | dec1_ready | dec2_ready;

  //
  //
  //

  assign arb_ack      = arb_ready & (arb_write | arb_read | arb_refr);
  assign arb_refr_ack = arb_ready & arb_refr ;

  //  
  //
  //

  assign refr_cnt_ack = arb_refr_ack; 

  //
  //
  //

  assign sys_ready = arb_ready & ~sys_lock; 

  //
  // 
  // 

  always_ff @(posedge clk or posedge reset) begin : arbiter_logic 
    if (reset)          
      arb <= 3'b001; 
    else if (sclr)
      arb <= 3'b001;
    else if (arb_ack) 
      arb <= {arb[1:0], arb[2]};
  end 

  //
  //
  // 

  assign  dec0_write   = arb_write & arb[0];
  assign  dec0_read    = arb_read  & arb[0];
  assign  dec0_refr    = arb_refr  & arb[0];                 
  assign  dec0_rowa    = sys_rowa  ;
  assign  dec0_cola    = sys_cola  ;
  assign  dec0_ba      = sys_ba    ;
  assign  dec0_burst   = sys_burst ;
  assign  dec0_chid    = sys_chid_i;

  //
  //
  //

  assign  dec1_write   = arb_write & arb[1];
  assign  dec1_read    = arb_read  & arb[1];
  assign  dec1_refr    = arb_refr  & arb[1];                 
  assign  dec1_rowa    = sys_rowa  ;
  assign  dec1_cola    = sys_cola  ;
  assign  dec1_ba      = sys_ba    ;
  assign  dec1_burst   = sys_burst ;
  assign  dec1_chid    = sys_chid_i;

  //
  //
  //

  assign  dec2_write   = arb_write & arb[2];
  assign  dec2_read    = arb_read  & arb[2];
  assign  dec2_refr    = arb_refr  & arb[2];                 
  assign  dec2_rowa    = sys_rowa  ;
  assign  dec2_cola    = sys_cola  ;
  assign  dec2_ba      = sys_ba    ;
  assign  dec2_burst   = sys_burst ;
  assign  dec2_chid    = sys_chid_i;

endmodule 
