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
// Workfile     : hssdrc_addr_path.v
// 
// Description  : coder for translate logical onehot command to sdram command
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


module hssdrc_addr_path(
  clk         , 
  reset       , 
  sclr        ,
  //        
  arb_pre_all ,
  arb_refr    ,
  arb_pre     ,
  arb_act     ,
  arb_read    ,
  arb_write   ,
  arb_lmr     ,
  arb_rowa    ,
  arb_cola    ,
  arb_ba      ,
  //
  addr        , 
  ba          , 
  cke         , 
  cs_n        , 
  ras_n       , 
  cas_n       , 
  we_n
  );
  
  input wire clk; 
  input wire reset; 
  input wire sclr; 

  //-------------------------------------------------------------------------------------------------- 
  // interface from output arbiter 
  //-------------------------------------------------------------------------------------------------- 

  input wire    arb_pre_all  ;
  input wire    arb_refr     ;
  input wire    arb_pre      ;
  input wire    arb_act      ;
  input wire    arb_read     ;
  input wire    arb_write    ;
  input wire    arb_lmr      ;
  input rowa_t  arb_rowa     ;
  input cola_t  arb_cola     ;
  input ba_t    arb_ba       ;

  //-------------------------------------------------------------------------------------------------- 
  // interface to sdram 
  //-------------------------------------------------------------------------------------------------- 
  
  output  sdram_addr_t  addr;
  output  ba_t          ba; 
  output  logic         cke;
  output  logic         cs_n;
  output  logic         ras_n;
  output  logic         cas_n;
  output  logic         we_n;

  //-------------------------------------------------------------------------------------------------- 
  //
  //--------------------------------------------------------------------------------------------------  
  
  logic [3:0] cs_n__ras_n__cas_n__we_n;

  // synthesis translate_off 
  wire [6:0] arb_cmd = {arb_pre_all, arb_refr, arb_pre, arb_act, arb_write, arb_read, arb_lmr};  
  arb_cmd_assert : assert property (@(posedge clk) disable iff (reset) (arb_cmd !== 0) |-> $onehot(arb_cmd)); 
  // synthesis translate_on 

  always_comb begin : logical_command_decode 

    cs_n__ras_n__cas_n__we_n = 4'b0111; // nop

    unique case (1'b1) 
      arb_pre_all  : cs_n__ras_n__cas_n__we_n = 4'b0010; // Pre
      arb_refr     : cs_n__ras_n__cas_n__we_n = 4'b0001; // Refr
      arb_pre      : cs_n__ras_n__cas_n__we_n = 4'b0010; // Pre
      arb_act      : cs_n__ras_n__cas_n__we_n = 4'b0011; // Act
      arb_write    : cs_n__ras_n__cas_n__we_n = 4'b0100; // Write
      arb_read     : cs_n__ras_n__cas_n__we_n = 4'b0101; // Read
      arb_lmr      : cs_n__ras_n__cas_n__we_n = 4'b0000; // Lmr (data == address) 
      default      : begin end 
    endcase
  end

  //
  // don't use clocking disable 
  //

  assign cke = 1'b1;

  // synthesis translate_off 
  initial begin 
    {cs_n, ras_n, cas_n, we_n} <= 4'b1111;  // only to disable mt48lc2m warnings
  end 
  // synthesis translate_on
    
  always_ff @(posedge clk or posedge reset) begin : sdram_control_register 
    if (reset)      {cs_n, ras_n, cas_n, we_n} <= 4'b1111;  // inheribit nop
    else if (sclr)  {cs_n, ras_n, cas_n, we_n} <= 4'b1111;  // inheribit nop
    else            {cs_n, ras_n, cas_n, we_n} <= cs_n__ras_n__cas_n__we_n;
  end

  always_ff @(posedge clk) begin : sdram_mux_addr_path

    ba <= arb_ba; 

    if (arb_act | arb_lmr)
      addr <= ResizeRowa(arb_rowa); 
    else 
      addr <= ResizeCola(arb_cola, arb_pre_all); 

  end 

  //-------------------------------------------------------------------------------------------------- 
  // function to get sdram address from row address. row address is transfered during 
  // act/lmr sdram command and is directly mapped to row address.
  //--------------------------------------------------------------------------------------------------  

  function sdram_addr_t ResizeRowa (input rowa_t rowa); 
    int i;
    sdram_addr_t addr_resized; 

    for (i = 0; i < pSdramAddrBits; i++) begin
      if (pRowaBits > i) 
          addr_resized[i] = rowa[i];
        else 
          addr_resized[i] = 1'b0;
    end 

    return addr_resized;
  endfunction 

  //--------------------------------------------------------------------------------------------------  
  // function to get sdram address from column address. column address is transfered during :
  // 1. read/write sdram command and A10 is autoprecharge bit and if pColaBits > 10 then 
  //    cola [$:10] is mapped to addr [$:11]. 
  // 2. pre sdram command and A10 is select all banks bit 
  //--------------------------------------------------------------------------------------------------  

  function sdram_addr_t ResizeCola (input cola_t cola, input bit pre_all); 
    int i;
    sdram_addr_t addr_resized; 

    for (i = 0; i < pSdramAddrBits; i++) begin
      if (i < 10) begin  
        if (pColaBits > i) 
          addr_resized[i] = cola[i];
        else 
          addr_resized[i] = 1'b0;
      end 
      else if (i == 10) begin 
        addr_resized[i] = pre_all; // Autoprecharge is not used -> A10 is always 1'b0 then read/write active
      end 
      else begin 
        if (pColaBits > i) 
          addr_resized[i] = cola[i-1];
        else 
          addr_resized[i] = 1'b0;
      end 
    end 

    return addr_resized;
  endfunction 

endmodule
