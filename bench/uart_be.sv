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
   *          $Id: uart_be.sv 108 2010-03-30 02:56:26Z hiroshi $         *
   ***************************************************************************** */

`ifdef SYN
/* empty */
`else
timeunit      1ps ;
timeprecision 1ps ;
`endif
import uart_top_package:: * ;
import uart_package:: * ;
module top ;

   u_reg_t UART_R ;

   logic        clk_sys ;
   logic        rst_p ;
   logic        intr_o, bench_intr_o ;
   logic [31:0] rdat, rdat1, rdat2, dat, wdat ;
   integer      i, j, k ;
   logic        ri, dcd ;
   
   logic [31:0] file_a ;
`ifdef ALIGN_4B
   localparam   UART_RXD               =  'h0 ;
   localparam   UART_TXD               =  'h0 ;
   localparam   UART_INTERRUPT_ENABLE  =  'h4 ;
   localparam   UART_INTERRUPT_IDENT   =  'h8 ;
   localparam   UART_FIFO_CONTROL      =  'hA ;
   localparam   UART_LINE_CONTROL      =  'hC ;
   localparam   UART_MODEM_CONTROL     =  'h10 ;
   localparam   UART_LINE_STATUS       =  'h14 ;
   localparam   UART_MODEM_STATUS      =  'h18 ;
   localparam   UART_SCRATCH           =  'h1C ;
   localparam   UART_BAUD              =  'h0 ;
`else
   localparam   UART_RXD               =  'h0 ;
   localparam   UART_TXD               =  'h0 ;
   localparam   UART_INTERRUPT_ENABLE  =  'h1 ;
   localparam   UART_INTERRUPT_IDENT   =  'h2 ;
   localparam   UART_FIFO_CONTROL      =  'h2 ;
   localparam   UART_LINE_CONTROL      =  'h3 ;
   localparam   UART_MODEM_CONTROL     =  'h4 ;
   localparam   UART_LINE_STATUS       =  'h5 ;
   localparam   UART_MODEM_STATUS      =  'h6 ;
   localparam   UART_SCRATCH           =  'h7 ;
   localparam   UART_BAUD              =  'h0 ;
`endif
   uart_bus    uart_bus_DUT() ;
   uart_bus    uart_bus_BENCH() ;
   wb_ext_bus  wb_DUT() ;
   wb_ext_bus  wb_BENCH() ;
   
   assign wb_DUT.clk_i    = clk_sys ;
   assign wb_DUT.nrst_i   = ~rst_p ;
   assign wb_BENCH.clk_i  = clk_sys ;
   assign wb_BENCH.nrst_i = ~rst_p ;

   // --------------
   // -  initial   -
   // --------------
   initial begin
      fork
         clock_sys ;
         test_pat(file_a) ;
      join
   end
   
   // ------------
   // -   task   -
   // ------------
   task test_pat(logic [31:0] file_a) ;
      integer i ;
      file_a = $fopen("uar_16550_rll.dump") ;
      ri = 1'b0 ;
      dcd = 1'b0 ;
      
      rst_p = 1'b1 ;
      #(STEP*20) ;
      rst_p = 1'b0 ;

 `include "uart_test.sv"

      $display(" ----------- happy end SIM !!!  --------------") ;
      
      $fclose(file_a) ;
      
      $stop ;
      //      $finish ;
   endtask
   task clock_sys ;
      clk_sys = 0 ;
      #(STEP) ;
      forever #(STEP/2) clk_sys = ~clk_sys ;
   endtask
   
   assign intr_o = wb_DUT.intr_o ;
   assign bench_intr_o = wb_BENCH.intr_o ;

   assign uart_bus_DUT.srx_i   = uart_bus_BENCH.stx_o ;
   assign uart_bus_BENCH.srx_i = uart_bus_DUT.stx_o ;
   assign uart_bus_DUT.cts_i   = uart_bus_BENCH.rts_o ;
   assign uart_bus_BENCH.cts_i = uart_bus_DUT.rts_o ;
   assign uart_bus_DUT.dsr_i   = uart_bus_BENCH.dtr_o ;
   assign uart_bus_BENCH.dsr_i = uart_bus_DUT.dtr_o ;

   assign uart_bus_DUT.ri_i    = ri ;
   assign uart_bus_DUT.dcd_i   = dcd ;
   assign uart_bus_BENCH.ri_i  = 1'b0 ;
   assign uart_bus_BENCH.dcd_i = 1'b0 ;

   // ----------
   // -   DUT  -
   // ----------
   uart_wrapper DUT(.wb_ext_bus(wb_DUT),
                    .uart_bus(uart_bus_DUT)) ;

   uart_wrapper BENCH(.uart_bus(uart_bus_BENCH),
                      .wb_ext_bus(wb_BENCH)) ;
endmodule
