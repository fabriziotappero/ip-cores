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
// Workfile     : hssdrc_refr_counter.v
// 
// Description  : refresh time decode, counter based fsm 
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

module hssdrc_refr_counter (
  clk     ,
  reset   ,
  sclr    ,
  ack     ,
  hi_req  ,
  low_req
  );

  input   wire  clk     ;
  input   wire  reset   ;
  input   wire  sclr    ;

  input   wire  ack     ; 
  output  logic hi_req  ;
  output  logic low_req ; 

  //-------------------------------------------------------------------------------------------------- 
  //
  //-------------------------------------------------------------------------------------------------- 

  localparam cCntWidth = clogb2(cRefCounterMaxTime);

  //-------------------------------------------------------------------------------------------------- 
  //
  //-------------------------------------------------------------------------------------------------- 

  logic [cCntWidth-1 : 0] cnt; 

  //
  //
  //

  always_ff @(posedge clk or posedge reset) begin : refresh_interval_counter 
    if (reset)            
      cnt <= '0; 
    else if (sclr | ack)
      cnt <= '0; 
    else
      cnt <= cnt + 1'b1; 
  end 
  
  //-------------------------------------------------------------------------------------------------- 
  //
  //--------------------------------------------------------------------------------------------------  

`ifdef HSSDRC_REFR_LOW_DISABLE  

  assign low_req = 1'b0;

`else 
  
  always_ff @(posedge clk or posedge reset) begin : low_priopity_refresh_request_set
    if (reset)      
      low_req <= 1'b0; 
    else if (sclr | ack)
      low_req <= 1'b0; 
    else if (cnt > cRefrWindowLowPriorityTime) 
      low_req <= 1'b1; 
  end 

`endif 

  //-------------------------------------------------------------------------------------------------- 
  //
  //--------------------------------------------------------------------------------------------------  

`ifdef HSSDRC_REFR_HI_DISABLE

  assign hi_req = 1'b0; 

`else 

  always_ff @(posedge clk or posedge reset) begin : high_priority_refresh_request_set 
    if (reset)
      hi_req <= 1'b0; 
    else if (sclr | ack) 
      hi_req <= 1'b0; 
    else if (cnt > cRefrWindowHighPriorityTime)
      hi_req <= 1'b1;
  end 

`endif 

  //
  //
  //
endmodule 
