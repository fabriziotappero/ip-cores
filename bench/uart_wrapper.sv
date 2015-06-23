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
   *          $Id: uart_wrapper.sv 108 2010-03-30 02:56:26Z hiroshi $         *
   ***************************************************************************** */

`ifdef SYN
/* empty */
`else
timeunit      1ps ;
timeprecision 1ps ;
`endif
import uart_top_package:: * ;
module uart_wrapper (interface wb_ext_bus, interface uart_bus) ;

   logic [31:0] dat_o ;
   logic        ack_o ;
   logic        intr_o ;
   logic        stx_o ;
   logic        rts_o ;
   logic        dtr_o ;
   
   wire        clk_i   = wb_ext_bus.clk_i ;
   wire        nrst_i  = wb_ext_bus.nrst_i ;
   wire [15:0] adr_i   = wb_ext_bus.adr_i ;
   wire [31:0] dat_i   = wb_ext_bus.dat_i ;
   wire        we_i    = wb_ext_bus.we_i  ;
   wire [3:0]  sel_i   = wb_ext_bus.sel_i ;
   wire        stb_i   = wb_ext_bus.stb_i ;
   wire        cyc_i   = wb_ext_bus.cyc_i ;

   assign wb_ext_bus.dat_o  = dat_o ;
   assign wb_ext_bus.ack_o  = ack_o ;
   assign wb_ext_bus.intr_o = intr_o ;
   assign uart_bus.stx_o = stx_o ;
   assign uart_bus.rts_o = rts_o ;
   assign uart_bus.dtr_o = dtr_o ;

   wire        srx_i   = uart_bus.srx_i ;
   wire        cts_i   = uart_bus.cts_i ;
   wire        dsr_i   = uart_bus.dsr_i ;
   wire        ri_i    = uart_bus.ri_i ;
   wire        dcd_i   = uart_bus.dcd_i ;
   
   uart_top ut(.*) ;
   
endmodule
