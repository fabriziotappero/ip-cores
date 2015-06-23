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
   *          $Id: uart_noize_shaver.sv 108 2010-03-30 02:56:26Z hiroshi $         *
   ***************************************************************************** */

`ifdef SYN
/* empty */
`else
timeunit      1ps ;
timeprecision 1ps ;
`endif

module uart_noize_shaver
  (
   input wire clk_i,
   input wire nrst_i,
   input wire rxd_i,
   output rxd_clean
   ) ;
   // -- receiver baud --
   logic [3:0] count ;
   logic [3:0] shift ;
   
   always_ff @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0)
        count <= #1 0 ;
      else
        count <= #1 count + 4'h1 ;
   end
   
   always_ff @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0)
        shift <= #1 4'b1111 ;
      else if(count == 4'h0)
        shift <= #1 {shift[2:0], rxd_i} ;
      else
        shift <= #1 shift ;
   end
   
   assign rxd_clean = shift == 4'hf ||
                      shift == 4'he ||
                      shift == 4'hd ||
                      shift == 4'hb ||
                      shift == 4'h7 ;
endmodule
