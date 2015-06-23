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
   *          $Id: uart_top.sv 108 2010-03-30 02:56:26Z hiroshi $         *
   ***************************************************************************** */

`ifdef SYN
/* empty */
`else
timeunit      1ps ;
timeprecision 1ps ;
`endif
// import uart_top_package:: * ;
module uart_top
  (
   input   wire         clk_i,   // clock 
   input   wire         nrst_i,  // reset 
   input   wire [15:0]  adr_i,   // address
   input   wire [31:0]  dat_i,   // data input
   output  wire [31:0]  dat_o,   // clk_rst_manager
   input   wire         we_i,    // write enable
   input   wire [3:0]   sel_i,   // select
   input   wire         stb_i,   // 
   output  wire         ack_o,   // acknowledge accept
   input   wire         cyc_i,   // cycle assrted
   output  wire         intr_o,  // 
   
   output wire          stx_o,
   output wire          rts_o,
   output wire          dtr_o,
   input  wire          srx_i,
   input  wire          cts_i,
   input  wire          dsr_i,
   input  wire          ri_i,
   input  wire          dcd_i
   ) ;
   
   uart_bus uart_bus() ;
   wb_bus   wb_bus() ;

   assign wb_bus.clk_i   = clk_i ;
   assign wb_bus.nrst_i  = nrst_i ;
   assign wb_bus.adr_i   = adr_i ;
   assign wb_bus.dat_i   = dat_i ;
   assign dat_o          = wb_bus.dat_o ;
   assign wb_bus.we_i    = we_i  ;
   assign wb_bus.sel_i   = sel_i ;
   assign wb_bus.stb_i   = stb_i ;
   assign ack_o          = wb_bus.ack_o ;
   assign wb_bus.cyc_i   = cyc_i ;
   assign intr_o         = wb_bus.intr_o ;
   assign stx_o          = uart_bus.stx_o ;
   assign rts_o          = uart_bus.rts_o ;
   assign dtr_o          = uart_bus.dtr_o ;

   assign uart_bus.srx_i = srx_i ;
   assign uart_bus.cts_i = cts_i ;
   assign uart_bus.dsr_i = dsr_i ;
   assign uart_bus.ri_i  = ri_i ;
   assign uart_bus.dcd_i = dcd_i ;
   
   uart_16550_rll um(.wb_bus(wb_bus.slave_mp), .uart_bus(uart_bus)) ;
   
endmodule
