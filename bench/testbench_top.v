//////////////////////////////////////////////////////////////////////
////                                                              ////
////  weigand_tx_top.v                                            ////
////                                                              ////
////                                                              ////
////  This file is part of the Time Triggered Protocol Controller ////
////  http://www.opencores.org/projects/weigand/                  ////
////                                                              ////
////                                                              ////
////  Author(s):                                                  ////
////       Jeff Anderson                                          ////
////       jeaander@opencores.org                                 ////
////                                                              ////
////                                                              ////
////  All additional information is available in the README.txt   ////
////  file.                                                       ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2013 Authors                                   ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//// The Weigand protocol is maintained by                        ////
//// This product has been tested to interoperate with certified  ////
//// devices, but has not been certified itself.  This product    ////
//// should be certified through prior to claiming strict         ////
//// adherence to the standard.                                   ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
//  Revisions at end of file
//

`include "timescale.v"
`include "wiegand_defines.v"

module testbench_top;
  reg [5:0]   wb_addr_i;
  reg [31:0]  wb_dat_i;
  wire [31:0] wb_dat_o;
  wire [31:0] wb_dat_o_rx;
  reg         wb_cyc_i;
  reg         wb_stb_i;
  reg [2:0]   wb_cti_i;
  reg [3:0]   wb_sel_i;
  reg         wb_we_i;
  reg         wb_rst_i;
  reg         wb_clk_i;
  reg         one_i, zero_i;
  
  //DUTs
  wiegand_tx_top wiegand_tx_top(one_o,zero_o,wb_clk_i,wb_rst_i,wb_dat_i,wb_dat_o,wb_cyc_i,wb_stb_i,wb_cti_i,wb_sel_i,wb_we_i,wb_addr_i,
                                wb_ack_o,wb_err_o,wb_rty_o);
  
  wiegand_rx_top wiegand_rx_top(one_i,zero_i,wb_clk_i,wb_rst_i,wb_dat_i,wb_dat_o_rx,wb_cyc_i,wb_stb_i,wb_cti_i,wb_sel_i,wb_we_i,wb_addr_i,
                                wb_ack_o_rx,wb_err_o_rx,wb_rty_o_rx);
  
  //tasks for simulation
  
  initial begin
    wb_addr_i = 6'h0;
    wb_dat_i = 32'h0;
    wb_cyc_i = 1'b0;
    wb_stb_i = 1'b0;
    wb_we_i = 1'b0;
    wb_rst_i = 1'b0;
    wb_clk_i = 1'b0;
    one_i = 1'b1;
    zero_i = 1'b1;
  end
  
  always 
    #5 wb_clk_i = !wb_clk_i;
  
  /**********************   tasks run by testcases for this testbench ******************/
  //Wiegand bus write tasks
  task wiegand_write;
    input [63:0] wiegand_data;
    input [5:0]  word_length;
    input [5:0]  p2p;
    input [5:0]  pw;
    integer i;
    integer j;
    begin  
      j = 0;
      repeat (word_length) begin
        @ (posedge wb_clk_i) begin
          if (wiegand_data[j] == 1'b0) begin
            wiegand0(pw);
          end
          else begin
            wiegand1(pw);
          end
          j=j+1;
          i = 0;
          while(i <= p2p) begin
            @ (posedge wb_clk_i) begin i=i+1; end
          end
        end
      end
    end
  endtask
  
  task wiegand0;
    input [5:0] pw;
    integer i;
    begin
      for (i = 0; i <= pw; i=i+1) begin
        @(posedge wb_clk_i)  zero_i = 1'b0;
      end
      zero_i = 1'b1;
    end
  endtask
  
  task wiegand1;
    input [5:0] pw;
    integer i;
    begin
      for (i = 0; i <= pw; i=i+1) begin
        @(posedge wb_clk_i)  one_i = 1'b0;
      end
      one_i = 1'b1;
    end
  endtask
  
  //Wishbone readn adn write tasks
  task wb_rst;
    begin
          wb_rst_i = 1'b1;
      #20 wb_rst_i = 1'b0;
    end
  endtask
  
  task wb_write_async;
    input [31:0] wb_data;
    begin
      @ (posedge wb_clk_i) begin
        wb_addr_i = `WIEGAND_ADDR;
        wb_dat_i = wb_data;
        wb_stb_i = 1'b1;
        wb_cyc_i = 1'b1;
        wb_we_i = 1'b1;
      end
      @ (posedge wb_clk_i) begin
        wb_addr_i = 6'h0;
        wb_dat_i = 32'h0;
        wb_stb_i = 1'b0;
        wb_cyc_i = 1'b0;
        wb_we_i = 1'b0;
      end
    end
  endtask
  
  task wb_write_sync;
    input [31:0] wb_data;
    begin
      @ (posedge wb_clk_i) begin
        wb_addr_i = `WIEGAND_ADDR;
        wb_dat_i = wb_data;
        wb_stb_i = 1'b1;
        wb_cyc_i = 1'b1;
        wb_we_i = 1'b1;
      end
      @ (posedge wb_clk_i) begin
        wb_addr_i = `WIEGAND_ADDR;
        wb_dat_i = wb_data;
        wb_stb_i = 1'b1;
        wb_cyc_i = 1'b1;
        wb_we_i = 1'b1;
      end
      @ (posedge wb_clk_i) begin
        wb_addr_i = 6'h0;
        wb_dat_i = 32'h0;
        wb_stb_i = 1'b0;
        wb_cyc_i = 1'b0;
        wb_we_i = 1'b0;
      end
    end
  endtask
  
  task wb_writep2p_async;
    input [31:0] p2p;
    begin
      @ (posedge wb_clk_i) begin
        wb_addr_i = `WB_CNFG_P2P;
        wb_dat_i = p2p;
        wb_stb_i = 1'b1;
        wb_cyc_i = 1'b1;
        wb_we_i = 1'b1;
      end
      @ (posedge wb_clk_i) begin
        wb_addr_i = 6'h0;
        wb_dat_i = 32'h0;
        wb_stb_i = 1'b0;
        wb_cyc_i = 1'b0;
        wb_we_i = 1'b0;
      end
    end
  endtask
  
  task wb_writepw_async;
    input [31:0] pw;
    begin
      @ (posedge wb_clk_i) begin
        wb_addr_i = `WB_CNFG_PW;
        wb_dat_i = pw;
        wb_stb_i = 1'b1;
        wb_cyc_i = 1'b1;
        wb_we_i = 1'b1;
      end
      @ (posedge wb_clk_i) begin
        wb_addr_i = 6'h0;
        wb_dat_i = 32'h0;
        wb_stb_i = 1'b0;
        wb_cyc_i = 1'b0;
        wb_we_i = 1'b0;
      end
    end
  endtask
  
  task wb_writesize_async;
    input [31:0] size;
    begin
      @ (posedge wb_clk_i) begin
        wb_addr_i = `WB_CNFG_MSGSIZE;
        wb_dat_i = (size & 32'h7F);
        wb_stb_i = 1'b1;
        wb_cyc_i = 1'b1;
        wb_we_i = 1'b1;
      end
      @ (posedge wb_clk_i) begin
        wb_addr_i = 6'h0;
        wb_dat_i = 32'h0;
        wb_stb_i = 1'b0;
        wb_cyc_i = 1'b0;
        wb_we_i = 1'b0;
      end
    end
  endtask
  
  task wb_writesend_async;
    input [31:0] size;
    begin
      @ (posedge wb_clk_i) begin
        wb_addr_i = `WB_CNFG_MSGSIZE;
        wb_dat_i = (size | 32'h80);
        wb_stb_i = 1'b1;
        wb_cyc_i = 1'b1;
        wb_we_i = 1'b1;
      end
      @ (posedge wb_clk_i) begin
        wb_addr_i = 6'h0;
        wb_dat_i = 32'h0;
        wb_stb_i = 1'b0;
        wb_cyc_i = 1'b0;
        wb_we_i = 1'b0;
      end
    end
  endtask
  
  task wb_read_async;
    begin
      @ (posedge wb_clk_i) begin
        wb_stb_i = 1'b1;
        wb_cyc_i = 1'b1;
        wb_we_i = 1'b0;
      end
      @ (posedge wb_clk_i) begin
        wb_stb_i = 1'b0;
        wb_cyc_i = 1'b0;
      end
    end
  endtask
  
  task wb_read_sync;
    begin
      @ (posedge wb_clk_i) begin
        wb_stb_i = 1'b1;
        wb_cyc_i = 1'b1;
        wb_we_i = 1'b0;
      end
      @ (posedge wb_clk_i) begin
        wb_stb_i = 1'b1;
        wb_cyc_i = 1'b1;
      end
      @ (posedge wb_clk_i) begin
        wb_stb_i = 1'b0;
        wb_cyc_i = 1'b0;
      end
    end
  endtask
  
endmodule
