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
   *          $Id: uart_fifo.sv 108 2010-03-30 02:56:26Z hiroshi $         *
   ***************************************************************************** */

`ifdef SYN
/* empty */
`else
timeunit      1ps ;
timeprecision 1ps ;
`endif

  // module uart_fifo #(parameter DATA_WIDTH = 8, parameter ADDR_WIDTH = 2)
  import fifo_package:: * ;
  module uart_fifo
    (input wire clk_i,
     input wire nrst_i,
     input wire clear,
     input wire [1:0] almost_empty_level,
     fifo_bus   fifo_pop,
     fifo_bus   fifo_push,
     output wire all_error
     ) ;

   parameter ADDR_WIDTH = 2 ;
   parameter DATA_WIDTH = 2 ;
   
   //   u_fifo_t  #(DATA_WIDTH(8), ADDR_WIDTH(4)) u_fifo ;
   u_fifo_t    u_fifo ;
   wire [ADDR_WIDTH-1:0] r_c1 ;
   reg                   f_fr ;
   wire                  pop    = fifo_pop.pop ;
   wire                  push   = fifo_push.push ;
   wire [DATA_WIDTH-1:0] push_dat = fifo_push.push_dat ;
   logic  almost_full ;
   
   assign fifo_push.empty = (u_fifo.write_pointer == u_fifo.read_pointer) & ~f_fr ;
   assign fifo_push.full  = (u_fifo.write_pointer == u_fifo.read_pointer) &  f_fr ;
   
   assign fifo_pop.empty = (u_fifo.write_pointer == u_fifo.read_pointer) & ~f_fr ;
   assign fifo_pop.full  = (u_fifo.write_pointer == u_fifo.read_pointer) &  f_fr ;
   assign fifo_push.almost_full = almost_full ;
   
   always_comb begin
      case (almost_empty_level)
        2'b00   : begin
           almost_full = f_fr == 1'b1
                                ? (u_fifo.write_pointer - u_fifo.read_pointer) == LEVEL_1
                                : (u_fifo.write_pointer + u_fifo.read_pointer) == LEVEL_1 ;
        end
        2'b01   : begin
           almost_full = f_fr == 1'b1
                                ? (u_fifo.write_pointer - u_fifo.read_pointer) == LEVEL_2
                                : (u_fifo.write_pointer + u_fifo.read_pointer) == LEVEL_2 ;
        end
        2'b10   : begin
           almost_full = f_fr == 1'b1
                                ? (u_fifo.write_pointer - u_fifo.read_pointer) == LEVEL_3
                                : (u_fifo.write_pointer + u_fifo.read_pointer) == LEVEL_3 ;
        end
        2'b11   : begin
           almost_full = f_fr == 1'b1
                                ? (u_fifo.write_pointer - u_fifo.read_pointer) == LEVEL_4
                                : (u_fifo.write_pointer + u_fifo.read_pointer) == LEVEL_4 ;
        end
      endcase // case (almost_empty_level)
   end // always_comb begin
   
   assign #100 fifo_pop.pop_dat   =  u_fifo.mem[u_fifo.read_pointer] ;
   assign  all_error = u_fifo.err[0] |
                       u_fifo.err[1] |
                       u_fifo.err[2] |
                       u_fifo.err[3] |
                       u_fifo.err[4] |
                       u_fifo.err[5] |
                       u_fifo.err[6] |
                       u_fifo.err[7] |
                       u_fifo.err[8] |
                       u_fifo.err[9] |
                       u_fifo.err[10] |
                       u_fifo.err[11] |
                       u_fifo.err[12] |
                       u_fifo.err[13] |
                       u_fifo.err[14] |
                       u_fifo.err[15] ;



   always @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0) begin
         u_fifo.err[0] <= #1 1'b0 ;
         u_fifo.err[1] <= #1 1'b0 ;
         u_fifo.err[2] <= #1 1'b0 ;
         u_fifo.err[3] <= #1 1'b0 ;
         u_fifo.err[4] <= #1 1'b0 ;
         u_fifo.err[5] <= #1 1'b0 ;
         u_fifo.err[6] <= #1 1'b0 ;
         u_fifo.err[7] <= #1 1'b0 ;
         u_fifo.err[8] <= #1 1'b0 ;
         u_fifo.err[9] <= #1 1'b0 ;
         u_fifo.err[10] <= #1 1'b0 ;
         u_fifo.err[11] <= #1 1'b0 ;
         u_fifo.err[12] <= #1 1'b0 ;
         u_fifo.err[13] <= #1 1'b0 ;
         u_fifo.err[14] <= #1 1'b0 ;
         u_fifo.err[15] <= #1 1'b0 ;
         u_fifo.mem[4'h0] <= #1 11'h000 ; // initial addr:'h0->data::'h0
      end
      else
        case ({push, pop})
          2'b01 : u_fifo.err[u_fifo.read_pointer] <= #1 1'b0 ;
          2'b10 : begin
             u_fifo.mem[u_fifo.write_pointer] <= #1 push_dat[10:0] ;
             u_fifo.err[u_fifo.write_pointer] <= #1 |(push_dat[10:8]) ;
          end
          2'b11 : begin
             u_fifo.mem[u_fifo.write_pointer] <= #1 push_dat[10:0] ;
             u_fifo.err[u_fifo.write_pointer] <= #1 |(push_dat[10:8]) ;
             u_fifo.err[u_fifo.read_pointer]  <= #1 1'b0 ;
          end
          default : u_fifo.err <= #1 u_fifo.err ;
        endcase // case ({push, pop})
   end // always @ (posedge clk_i, negedge nrst_i)
   
   assign r_c1 = u_fifo.read_pointer - 'h01 ;
   
   always @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0)
        f_fr <= #1 1'b0 ;
      else if(r_c1 == u_fifo.write_pointer)
        f_fr <= #1 1'b1 ;
      else if(pop == 1'b1 || clear == 1'b1)
        f_fr <= #1 1'b0 ;
      else
        f_fr <= #1 f_fr ;
   end
   
   always @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0)
        u_fifo.write_pointer <= #1 'h00 ;
      else if(clear == 1'b1)
        u_fifo.write_pointer <= #1 'h00 ;
      else if(push == 1'b1)
        u_fifo.write_pointer <= #1 u_fifo.write_pointer + 'h01 ;
      else
        u_fifo.write_pointer <= #1 u_fifo.write_pointer ;
   end

   // -- read pinter inc & clear to current error bit --
   always @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0)
        u_fifo.read_pointer <= #1 'h00 ;
      else if(clear == 1'b1)
        u_fifo.read_pointer <= #1 'h00 ;
      else if(pop == 1'b1)
        u_fifo.read_pointer <= #1 u_fifo.read_pointer + 'h01 ;
      else
        u_fifo.read_pointer <= #1 u_fifo.read_pointer ;
   end

endmodule
