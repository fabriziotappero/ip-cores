//
// Project      : High-Speed SDRAM Controller with adaptive bank management and command pipeline
// 
// Project Nick : HSSDRC
// 
// Version      : 1.0-beta 
//  
// Revision     : $Revision: 1.1 $ 
// 
// Date         : $Date: 2008-03-06 13:51:55 $ 
// 
// Workfile     : hssdrc_tb_sys_if.vh
// 
// Description  : system interface to memory controller
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


`include "hssdrc_define.vh"

`ifndef __HSSDRC_TB_SYS_IF_VH__

  `define __HSSDRC_TB_SYS_IF_VH__

  interface hssdrc_tb_sys_if (clk, reset, sclr); 
    input wire clk  ;
    input wire reset;
    input wire sclr ; 
    //
    logic   write; 
    logic   read; 
    logic   refr; 
    rowa_t  rowa; 
    cola_t  cola; 
    ba_t    ba; 
    burst_t burst; 
    chid_t  chid_i;
    data_t  wdata; 
    datam_t wdatam; 
    //
    logic   ready;
    logic   use_wdata; 
    logic   vld_rdata;
    chid_t  chid_o;
    data_t  rdata; 
    //
    modport master  ( output  rowa, cola, ba, burst, chid_i, write, read, refr, wdata, wdatam,
                      input   ready, use_wdata, vld_rdata, chid_o, rdata);
    modport slave   ( input   rowa, cola, ba, burst, chid_i, write, read, refr, wdata, wdatam, 
                      output  ready, use_wdata, vld_rdata, chid_o, rdata);
    // synthesis translate_off 
    clocking cb @(posedge clk);
      default input #1ns output #1ns;
      output  rowa, cola, ba, burst, chid_i, write, read, refr, wdata, wdatam;
      input   ready, use_wdata, vld_rdata, chid_o, rdata;
    endclocking
    //
    modport tb (input clk, reset, sclr, clocking cb); 
    //
    wire [2:0] cmd_vect = {write, read, refr}; 
    wire      sys_reset = reset | sclr; 
    //
    property cmd_onehot;                         
      @(cb) disable iff (sys_reset) (cmd_vect != 0) |-> $onehot(cmd_vect);
    endproperty 
    //
    property rst_output(logic signal);
      @(cb) (sys_reset) |-> not (signal);
    endproperty
    //
    assert property (cmd_onehot)            else $error ("command         overlaped violation error");     
    assert property (rst_output(ready))     else $error ("hssdc reaady    output reset violation error");
    assert property (rst_output(use_wdata)) else $error ("hssdc use_wdata output reset violation error");
    assert property (rst_output(vld_rdata)) else $error ("hssdc vld_rdata output reset violation error");
    // synthesis translate_on 

  endinterface 

`endif 
