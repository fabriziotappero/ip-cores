/* *****************************************************************************
   * title:         uart_16550_rll module                                      *
   * description:   RS232 Protocol 16550D uart (mostly supported)              *
   * languages:     systemVerilog                                              *
   *                                                                           *
   * Copyright (C) 2010 miyagi.hiroshi                                         *
   *                                                                           *
   * This library is free software; you can redistribute it and/or             *
   * modify it under the terms of the GNU Lesser General Public                *
   * License as published by the Free Software Foundation; either              *
   * version 2.1 of the License, or (at your option) any later version.        *
   *                                                                           *
   * This library is distributed in the hope that it will be useful,           *
   * but WITHOUT ANY WARRANTY; without even the implied warranty of            *
   * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU         *
   * Lesser General Public License for more details.                           *
   *                                                                           *
   * You should have received a copy of the GNU Lesser General Public          *
   * License along with this library; if not, write to the Free Software       *
   * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111*1307  USA *
   *                                                                           *
   *         ***  GNU LESSER GENERAL PUBLIC LICENSE  ***                       *
   *           from http://www.gnu.org/licenses/lgpl.txt                       *
   *****************************************************************************
   *                            redleaflogic,ltd                               *
   *                    miyagi.hiroshi@redleaflogic.biz                        *
   *          $Id: uart_interface_be.sv 108 2010-03-30 02:56:26Z hiroshi $         *
   ***************************************************************************** */

`ifdef SYN
/* empty */
`else
timeunit      1ps ;
timeprecision 1ps ;
`endif
import uart_top_package:: * ;
interface wb_ext_bus() ;
   wire                     clk_i ;   // clock 
   wire                     nrst_i ;  // reset 
   wire [15:0]              adr_i ;   // address
   wire [31:0]              dat_i ;   // data input
   wire [31:0]              dat_o ;   // clk_rst_manager
   wire                     we_i  ;   // write enable
   wire [3:0]               sel_i ;   // select
   wire                     stb_i ;   // 
   wire                     ack_o ;   // acknowledge accept
   wire                     cyc_i ;   // cycle assrted
   wire                     intr_o ;  // 
   
   modport master_mp(
                     output  clk_i, nrst_i, adr_i, dat_i, we_i, sel_i, cyc_i, stb_i,
                     input  dat_o, ack_o, intr_o
                     ) ;
   
   modport slave_mp(
                    input  clk_i, nrst_i, adr_i, dat_i, we_i, sel_i, stb_i, cyc_i,
                    output dat_o, ack_o, intr_o) ;
   
   
   logic [31:0]            bw_data ;
   logic [4:0]             b_addr ;
   logic                   cs3, we ;
   logic [3:0]             be ;
   
   assign adr_i = b_addr ;
   assign dat_i = we == 1'b1 ? bw_data : 'hx ;
   assign stb_i = cs3 ;
   assign cyc_i = cs3 ;
   assign we_i  = we ;
   assign sel_i = be ;
   assign clk_b = clk_i ;
   
   initial begin
      bw_data = 0 ;
      b_addr  = 0;
      cs3  = 1'b0 ;
      we   = 1'b0 ;
      be   = 4'b0000 ;
   end     
   
   task write(
              input logic [31:0] wdat,
              input logic [4:0] adr
              ) ;
      @(posedge clk_b) ;
      #(STEP*0.1) ;
      b_addr   = adr ;
      cs3  = 1'b1 ;
      @(posedge clk_b) ;
      #(STEP*0.1) ;
      bw_data   = wdat ;
      we  = 1'b1 ;
`ifdef ALIGN_4B
      be  = 4'b1111 ;
`else
      be[0]  = adr[1:0] == 2'b00 ;
      be[1]  = adr[1:0] == 2'b01 ;
      be[2]  = adr[1:0] == 2'b10 ;
      be[3]  = adr[1:0] == 2'b11 ;
`endif
      @(posedge clk_b) ;
      #(STEP*0.1) ;
      cs3  = 1'b0 ;
      we   = 1'b0 ;
      be   = 4'b0000 ;
      b_addr   = 'hx ;
      bw_data  = 'hx ;
   endtask
   
   task read(
             output logic [31:0] rdat,
             input logic [4:0] adr
             ) ;
      @(posedge clk_b) ;
      #(STEP*0.1) ;
      b_addr   = adr ;
      cs3  = 1'b1 ;
      we   = 1'b0 ;
      be   = 4'b0000 ;
      @(posedge clk_b) ;
      #(STEP*0.1) ;
      @(posedge clk_b) ;
      #(STEP*0.1) ;
      cs3  = 1'b1 ;
      we   = 1'b0 ;
`ifdef ALIGN_4B
      be  = 4'b1111 ;
`else
      be[0]  = adr[1:0] == 2'b00 ;
      be[1]  = adr[1:0] == 2'b01 ;
      be[2]  = adr[1:0] == 2'b10 ;
      be[3]  = adr[1:0] == 2'b11 ;
`endif
      @(posedge clk_b) ;
      rdat = dat_o ;
      #(STEP*0.1) ;
      cs3  = 1'b0 ;
      we   = 1'b0 ;
      be   = 4'b0000 ;
      b_addr   = 'hx ;
      bw_data  = 'hx ;
   endtask

   task nop() ;
      @(posedge clk_b) ;
      #(STEP*0.1) ;
      b_addr   = 'hx ;
      bw_data  = 'hx ;
      cs3 = 1'b0 ;
      we  = 1'b0 ;
      be  = 4'b0000 ;
   endtask

endinterface : wb_ext_bus

