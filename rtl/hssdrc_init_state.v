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
// Workfile     : hssdrc_init_state.v
// 
// Description  : sdram chip initialization unit
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

module hssdrc_init_state (
  clk           , 
  reset         , 
  sclr          , 
  init_done     ,
  pre_all       ,
  refr          ,
  lmr           ,
  rowa          
  );

  input wire clk  ;
  input wire reset;
  input wire sclr ;

  output logic  init_done;  
  output logic  pre_all  ;
  output logic  refr     ;
  output logic  lmr      ;
  output rowa_t rowa     ; 

  assign rowa = cInitLmrValue;

  //---------------------------------------------------------------------------------------------------
  // counter based FSM
  // fsm has 1 counter divided by 2 part :
  // cnt_high - decode for wait init interval
  // cnt_low - execute command sequence when wait done. 
  // true init time is ~= (1.1 - 1.2) pInit_time for less logic resource using 
  //---------------------------------------------------------------------------------------------------

  localparam int unsigned cInitPre   = 1;
  localparam int unsigned cInitRefr0 = cInitPre    + cTrp;
  localparam int unsigned cInitRefr1 = cInitRefr0  + cTrfc;
  localparam int unsigned cInitLmr   = cInitRefr1  + cTrfc;
  localparam int unsigned cInitDone  = cInitLmr    + cTmrd + 1; 

  //
  // counter parameters
  // 

  localparam int unsigned cInitCntLowWidth  = clogb2(cInitDone);
  localparam int unsigned cInitCntHighMax   = (cInitTime >> cInitCntLowWidth) + 1;
  localparam int unsigned cInitCntWidth     = clogb2(cInitCntHighMax) + cInitCntLowWidth;

  //-------------------------------------------------------------------------------------------------- 
  //
  //-------------------------------------------------------------------------------------------------- 

  logic [cInitCntWidth-1    : 0]              cnt; 
  logic [cInitCntLowWidth-1 : 0]              cnt_low; 
  logic [cInitCntWidth-1 : cInitCntLowWidth]  cnt_high;

  logic cnt_high_is_max;

  assign cnt_low  = cnt [cInitCntLowWidth-1 : 0];
  assign cnt_high = cnt [cInitCntWidth-1    : cInitCntLowWidth];


  always_ff @(posedge clk or posedge reset) begin : cnt_fsm
    if (reset)
      cnt <= '0; 
    else if (sclr) 
      cnt <= '0; 
    else if (~init_done) 
      cnt <= cnt + 1'b1; 
  end 


  always_ff @(posedge clk or posedge reset) begin : cnt_fsm_comparator 
    if (reset)
      cnt_high_is_max <= 1'b0; 
    else if (sclr) 
      cnt_high_is_max <= 1'b0; 
    else 
      cnt_high_is_max <= (cnt_high == cInitCntHighMax); 
  end 


  always_ff @(posedge clk or posedge reset) begin : cnt_fsm_decode 
    if (reset) begin 
      init_done <= 1'b0; 
      pre_all   <= 1'b0;
      refr      <= 1'b0;
      lmr       <= 1'b0;
    end 
    else if (sclr) begin 
      init_done <= 1'b0; 
      pre_all   <= 1'b0;
      refr      <= 1'b0;
      lmr       <= 1'b0;
    end 
    else begin 

      pre_all <= 1'b0;
      refr    <= 1'b0;
      lmr     <= 1'b0;

      unique case (cnt_low)                    
        cInitPre    : pre_all   <= cnt_high_is_max; 
        cInitRefr0  : refr      <= cnt_high_is_max;
        cInitRefr1  : refr      <= cnt_high_is_max;
        cInitLmr    : lmr       <= cnt_high_is_max; 
        cInitDone   : init_done <= cnt_high_is_max;        
        default     : begin end 
      endcase                                

    end 
  end 

endmodule 
