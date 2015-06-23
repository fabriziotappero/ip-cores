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
// Workfile     : hssdrc_mux.v
// 
// Description  : multiplexer for sdram signals
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

module hssdrc_mux 
  (
  init_done           , 
  //
  init_state_pre_all  ,
  init_state_refr     ,
  init_state_lmr      ,
  init_state_rowa     ,
  //
  arb_pre_all         , 
  arb_refr            , 
  arb_pre             , 
  arb_act             , 
  arb_read            , 
  arb_write           , 
  arb_rowa            , 
  arb_cola            , 
  arb_ba              , 
  arb_chid            , 
  arb_burst           , 
  //
  mux_pre_all         ,
  mux_refr            ,
  mux_pre             ,
  mux_act             ,
  mux_read            ,
  mux_write           ,
  mux_lmr             ,
  mux_rowa            ,
  mux_cola            ,
  mux_ba              ,
  mux_chid            ,
  mux_burst  
  );

  input wire init_done; 

  //-------------------------------------------------------------------------------------------------- 
  // interface from inis state controller 
  //-------------------------------------------------------------------------------------------------- 

  input wire          init_state_pre_all  ;
  input wire          init_state_refr     ;
  input wire          init_state_lmr      ;
  input rowa_t        init_state_rowa     ;  

  //-------------------------------------------------------------------------------------------------- 
  // interface from output arbiter 
  //-------------------------------------------------------------------------------------------------- 

  input wire          arb_pre_all  ;
  input wire          arb_refr     ;
  input wire          arb_pre      ;
  input wire          arb_act      ;
  input wire          arb_read     ;
  input wire          arb_write    ;
  input rowa_t        arb_rowa     ;
  input cola_t        arb_cola     ;
  input ba_t          arb_ba       ;
  input chid_t        arb_chid     ;
  input sdram_burst_t arb_burst    ;

  //-------------------------------------------------------------------------------------------------- 
  // interface to data/addr path units 
  //-------------------------------------------------------------------------------------------------- 

  output logic         mux_pre_all  ;
  output logic         mux_refr     ;
  output logic         mux_pre      ;
  output logic         mux_act      ;
  output logic         mux_read     ;
  output logic         mux_write    ;
  output logic         mux_lmr      ;
  output rowa_t        mux_rowa     ;
  output cola_t        mux_cola     ;
  output ba_t          mux_ba       ;
  output chid_t        mux_chid     ;
  output sdram_burst_t mux_burst    ;

  //------------------------------------------------------------------------------------------------- 
  // there is no reason to mask or mux arbiter_if signals, becouse during init state phase 
  // init_done == 0 and this signals is cleared inside decoders and after init state phase 
  // init_done == 1 and init_state_if signals will be cleared also 
  //-------------------------------------------------------------------------------------------------  

  assign mux_pre_all = arb_pre_all | init_state_pre_all; 
  assign mux_refr    = arb_refr    | init_state_refr   ; 

  // this will be synthesis as simple logic, becouse init_state_rowa is constant  
  assign mux_rowa    = init_done ? arb_rowa  : init_state_rowa   ;

  assign mux_pre     = arb_pre   ; 
  assign mux_act     = arb_act   ; 
  assign mux_read    = arb_read  ; 
  assign mux_write   = arb_write ; 

  assign mux_lmr     = init_state_lmr;  

  // 
  // no mux becouse init state phase not use this sdram ports 
  //

  assign mux_cola    = arb_cola ;
  assign mux_ba      = arb_ba   ;
  assign mux_burst   = arb_burst;
  assign mux_chid    = arb_chid ;

endmodule


  
