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
   *          $Id: uart_interface.sv 108 2010-03-30 02:56:26Z hiroshi $         *
   ***************************************************************************** */
// --- uart16550 interface signale ---
`ifdef SYN
/* empty */
`else
timeunit      1ps ;
timeprecision 1ps ;
`endif
interface uart_bus ;
   
   
   wire  stx_o ;
   wire  srx_i ;
   wire  rts_o ;
   wire  cts_i ;
   wire  dtr_o ;
   wire  dsr_i ;
   wire  ri_i ;
   wire  dcd_i ;
endinterface : uart_bus

interface wb_bus() ;
   wire  clk_i ;   // clock 
   wire  nrst_i ;  // reset 
   wire [31:0] adr_i ;   // address
   wire [31:0] dat_i ;   // data input
   wire [31:0]  dat_o ;   // data output
   wire         we_i  ;   // write enable
   wire [3:0]   sel_i ;   // select
   wire         stb_i ;   // strobe signal
   wire         ack_o ;   // acknowledge
   wire         cyc_i ;   // cycle assrted
   wire         intr_o ;  // interrupt output
   
   modport master_mp(
                     output  clk_i, nrst_i, adr_i, dat_i, we_i, sel_i, cyc_i, stb_i,
                     input  dat_o, ack_o, intr_o
                     ) ;
   
   modport slave_mp(
                    input  clk_i, nrst_i, adr_i, dat_i, we_i, sel_i, stb_i, cyc_i,
                    output dat_o, ack_o, intr_o) ;
   
endinterface : wb_bus

