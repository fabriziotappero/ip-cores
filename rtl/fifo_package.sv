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
   *          $Id: fifo_package.sv 108 2010-03-30 02:56:26Z hiroshi $         *
   ***************************************************************************** */

package fifo_package ;
`ifdef SYN
 /* empty */
`else
   timeunit      1ps ;
   timeprecision 1ps ;
`endif
   // -- read for manual -> 4.4 FIFO Control Register (FCR)
   // -- almost trgger level --
   localparam LEVEL_1 = 5'h1 ;
   localparam LEVEL_2 = 5'h4 ;
   localparam LEVEL_3 = 5'h8 ;
   localparam LEVEL_4 = 5'hE ;
   
   typedef  struct { 
                     logic [10:0] mem [0:15] ;
                     logic [0:0]  err [0:15] ;
                     logic [3:0]  write_pointer ;
                     logic [3:0]  read_pointer ;
                     logic        full ;
                     logic        almost_full ;
                     logic        empty ;
                     } u_fifo_t ;

endpackage : fifo_package
