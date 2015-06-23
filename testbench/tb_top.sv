//
// Project      : High-Speed SDRAM Controller with adaptive bank management and command pipeline
// 
// Project Nick : HSSDRC
// 
// Version      : 1.0-beta 
//  
// Revision     : $Revision: 1.1 $ 
// 
// Date         : $Date: 2008-03-06 13:54:00 $ 
// 
// Workfile     : tb_top.sv
// 
// Description  : testbench top level
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
`include "hssdrc_timing.vh"
`include "hssdrc_tb_sys_if.vh"

module tb_top; 

  parameter cPeriod     = 1000.0/pClkMHz; 
  parameter cHalfPeriod = cPeriod/2.0;

  wire [pDataBits-1:0]        dq;   
  wire [pDatamBits-1:0]       dqm;  
  wire [pSdramAddrBits-1 :0]  addr; 
  wire [pBaBits-1   :0]       ba;                               
  wire                        cke   ;  
  wire                        cs_n  ; 
  wire                        ras_n ;
  wire                        cas_n ;
  wire                        we_n  ; 

  logic   sys_write;      
  logic   sys_read  ;     
  logic   sys_refr  ;     
  rowa_t  sys_rowa  ;     
  cola_t  sys_cola  ;     
  ba_t    sys_ba    ;     
  burst_t sys_burst ;     
  chid_t  sys_chid_i;     
  data_t  sys_wdata ;     
  datam_t sys_wdatam;     
  logic   sys_ready     ; 
  logic   sys_use_wdata ; 
  logic   sys_vld_rdata ; 
  chid_t  sys_chid_o    ; 
  data_t  sys_rdata     ; 


  bit clk_main ;  
  bit clk; 
  bit nclk; 

  bit reset ;
  bit sclr  ; 

  hssdrc_tb_sys_if sys_if (clk, reset, sclr);

  assign sys_write  = sys_if.write ;      
  assign sys_read   = sys_if.read  ;     
  assign sys_refr   = sys_if.refr  ;     
  assign sys_rowa   = sys_if.rowa  ;     
  assign sys_cola   = sys_if.cola  ;     
  assign sys_ba     = sys_if.ba    ;     
  assign sys_burst  = sys_if.burst ;     
  assign sys_chid_i = sys_if.chid_i;     
  assign sys_wdata  = sys_if.wdata ;     
  assign sys_wdatam = sys_if.wdatam;    
   
  assign sys_if.ready     =  sys_ready     ; 
  assign sys_if.use_wdata =  sys_use_wdata ; 
  assign sys_if.vld_rdata =  sys_vld_rdata ; 
  assign sys_if.chid_o    =  sys_chid_o    ; 
  assign sys_if.rdata     =  sys_rdata     ; 


  mt48lc2m32b2 sdram_chip (
    .Dq    (dq   ), 
    .Addr  (addr ), 
    .Ba    (ba   ), 
    .Clk   (nclk ), 
    .Cke   (cke  ), 
    .Cs_n  (cs_n ), 
    .Ras_n (ras_n), 
    .Cas_n (cas_n), 
    .We_n  (we_n ), 
    .Dqm   (dqm  )
    );

  sdram_interpretator inter (
    .ba   (ba), 
    .cs_n (cs_n ), 
    .ras_n(ras_n), 
    .cas_n(cas_n), 
    .we_n (we_n ), 
    .a10  (addr [10] )
    );

  hssdrc_top top(
    .clk    (clk  ), 
    .reset  (reset), 
    .sclr   (sclr ), 
    //
    .sys_write     (sys_write    ),
    .sys_read      (sys_read     ),
    .sys_refr      (sys_refr     ),
    .sys_rowa      (sys_rowa     ),
    .sys_cola      (sys_cola     ),
    .sys_ba        (sys_ba       ),
    .sys_burst     (sys_burst    ),
    .sys_chid_i    (sys_chid_i   ),
    .sys_wdata     (sys_wdata    ),
    .sys_wdatam    (sys_wdatam   ),  
    .sys_ready     (sys_ready    ),
    .sys_use_wdata (sys_use_wdata), 
    .sys_vld_rdata (sys_vld_rdata),
    .sys_chid_o    (sys_chid_o   ),
    .sys_rdata     (sys_rdata    ),
    //
    .dq     (dq   ), 
    .dqm    (dqm  ), 
    .addr   (addr ), 
    .ba     (ba   ), 
    .cke    (cke  ), 
    .cs_n   (cs_n ), 
    .ras_n  (ras_n), 
    .cas_n  (cas_n), 
    .we_n   (we_n )
  );

  initial begin : clock_generator 
    clk_main = 1'b0;
    #(cHalfPeriod); 
    forever clk_main = #(cHalfPeriod) ~clk_main;
  end 

  always_comb begin 
    clk  <= clk_main;     
    nclk <= #2 ~clk_main; // model output buffer delay 
  end 

  assign sclr = 1'b0;

  initial begin : reset_generator 
    reset = 1'b1; 

    repeat (4) @(posedge clk); 
    @(negedge clk); 

    reset = 1'b0;
  end 

  tb_prog prog (sys_if.tb);

endmodule
