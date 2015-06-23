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
   *          $Id: fifo_interface.sv 108 2010-03-30 02:56:26Z hiroshi $         *
   ***************************************************************************** */

`ifdef SYN
/* empty */
`else
timeunit      1ps ;
timeprecision 1ps ;
`endif

import fifo_package::* ;
interface fifo_bus(input clk_i) ;
   //   wire [DATA_WIDTH-1:0] push_dat ;
   //   wire [DATA_WIDTH-1:0] pop_dat ;
   wire [10:0]           push_dat ;
   wire [10:0]           pop_dat ;
   wire                  push ;
   wire                  pop ;
   wire                  empty ;
   wire                  full ;
   wire                  almost_full ;
   
   modport push_master_mp (
                           output push_dat, push,
                           input  full, almost_full
                           ) ;
   
   modport push_slave_mp (
                          input  push_dat, push,
                          output full, almost_full, empty
                          ) ;
   
   modport pop_master_mp (
                          output pop,
                          input  pop_dat, empty, almost_full, full
                          ) ;
   
   modport pop_slave_mp (
                         input  pop,
                         output pop_dat, empty, almost_full, full
                         ) ;
   
`ifdef SIM
   import fifo_be_package:: * ;
   
   logic [10:0]                 pop_d ;
   logic [10:0]                 push_d ;
   logic                        pop_en;
   logic                        push_en ;
   logic [10:0]                 data ;
   
   assign push_dat = push_d ;
   assign push     = push_en ;
   assign pop_d    = pop_dat ;
   assign pop      = pop_en ;
   
   initial begin
      push_d = 0 ;
      pop_en = 0 ;
      push_en = 0 ;
   end
   
   task burst_read(output logic [10:0] data) ;
      @(posedge clk_i) ;
      #(STEP*0.1) ;
      data = pop_d ;
      pop_en = 1'b1 ;
   endtask // read
   
   task burst_write(input logic [10:0] data) ;
      @(posedge clk_i) ;
      #(STEP*0.1) ;
      push_d  = data ;
      push_en = 1'b1 ;
   endtask // write

   task read(output logic [10:0] data) ;
      @(posedge clk_i) ;
      #(STEP*0.1) ;
      data = pop_d ;
      pop_en = 1'b1 ;
      @(posedge clk_i) ;
      #(STEP*0.1) ;
      pop_en = 1'b0 ;
   endtask // read
   
   task write(input logic [10:0] data) ;
      @(posedge clk_i) ;
      #(STEP*0.1) ;
      push_d  = data ;
      push_en = 1'b1 ;
      @(posedge clk_i) ;
      #(STEP*0.1) ;
      push_d  = 'hxx ;
      push_en = 1'b0 ;
   endtask // write

   task nop() ;
      @(posedge clk_i) ;
      #(STEP*0.1) ;
      push_d  = 11'hxxx ;
      pop_en  = 1'b0 ;
      push_en = 1'b0 ;
   endtask // write

`endif //  `ifdef SIM
   
endinterface : fifo_bus

