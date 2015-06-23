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
// Workfile     : hssdrc_ba_map.v
// 
// Description  : bank & row map unit
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

module hssdrc_ba_map (
  clk         , 
  reset       ,
  sclr        ,  
  //
  update      ,
  clear       ,
  ba          ,
  rowa        ,
  //
  pre_act_rw  ,
  act_rw      ,
  rw          ,
  all_close 
  
  );

  input wire clk    ;
  input wire reset  ;
  input wire sclr   ;

  //-------------------------------------------------------------------------------------------------- 
  // interface from sequence decoders 
  //-------------------------------------------------------------------------------------------------- 

  input   wire    update      ;
  input   wire    clear       ;
  input   ba_t    ba          ;
  input   rowa_t  rowa        ;

  //-------------------------------------------------------------------------------------------------- 
  // interface to sequence decoders 
  //-------------------------------------------------------------------------------------------------- 

  output  logic   pre_act_rw  ; 
  output  logic   act_rw      ; 
  output  logic   rw          ; 
  output  logic   all_close   ;  

  //-------------------------------------------------------------------------------------------------- 
  // 
  //-------------------------------------------------------------------------------------------------- 

  logic [3:0] bank_open;
  rowa_t      row_open [0:3];
  wire        bank_is_open;
  wire        row_is_open; 

  //-------------------------------------------------------------------------------------------------- 
  // 
  //-------------------------------------------------------------------------------------------------- 

  always_ff @(posedge clk or posedge reset) begin : bank_open_map_process
    if (reset)
      bank_open <= '0; 
    else if (sclr) 
      bank_open <= '0; 
    else begin 
      if (clear) 
        bank_open <= '0; 
      else if (update) 
        bank_open [ba] <= 1'b1;
      else begin         
      end 
    end 
  end 

  //
  //
  //

  always_ff @(posedge clk) begin : row_open_map_process 
    if (update)
      row_open[ba] <= rowa;
  end 

  //
  //
  //

  assign bank_is_open = bank_open [ba];
  assign row_is_open  = (row_open [ba] == rowa);

  //
  //
  //
   
  assign rw         = bank_is_open &  row_is_open;
  assign pre_act_rw = bank_is_open & ~row_is_open;
  assign act_rw     = ~bank_is_open; 
  assign all_close  = (bank_open == 0);
  
endmodule 
