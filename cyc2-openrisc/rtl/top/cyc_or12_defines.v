//
// Definitions for OR1K minimal configuration for Spartan-3E
// Starter Kit board. Interrupts and address map is compatible
// with OR1K Test Application for XESS XSV800 board.
//
// Author(s):
// - Serge Vakulenko, vak@cronyx.ru
//
// This source file may be used and distributed without
// restriction provided that this copyright statement is not
// removed from the file and that any derivative work contains
// the original copyright notice and the associated disclaimer.
//
// This source file is free software; you can redistribute it
// and/or modify it under the terms of the GNU Lesser General
// Public License as published by the Free Software Foundation;
// either version 2.1 of the License, or (at your option) any
// later version.
//
// This source is distributed in the hope that it will be
// useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
// PURPOSE.  See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General
// Public License along with this source; if not, download it
// from http://www.opencores.org/lgpl.shtml
//

//----------------------
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.1  2006/12/22 17:05:23  vak
// Added README and s3esk_defines.v, some cleanup.
//
// Revision 1.1  2006/12/21 16:46:58  vak
// Initial revision imported from
// http://www.opencores.org/cvsget.cgi/or1k/orp/orp_soc/rtl/verilog.
//

//
// Define to target to Xilinx Virtex (actually Spartan-3E)
//
//`define TARGET_VIRTEX
`define CYCLONE

//
// Define NXP ISP1105 USB PHY
//
//`define PHY_ISP1105

//
// Interrupts
//
`define APP_INT_RES1	1:0
`define APP_INT_UART	2
`define APP_INT_RES2	3
`define APP_INT_ETH	4
`define APP_INT_PS2	5
`define APP_INT_RES3	19:6

//
// Address map
//
`define APP_ADDR_DEC_W	8
`define APP_ADDR_SRAM	`APP_ADDR_DEC_W'h00
`define APP_ADDR_DEC_DRAM_W  2
`define APP_ADDR_DRAM	`APP_ADDR_DEC_DRAM_W'b01
`define APP_ADDR_DECP_W  4
`define APP_ADDR_PERIP  `APP_ADDR_DEC_W'h9
`define APP_ADDR_VGA	`APP_ADDR_DEC_W'h97
`define APP_ADDR_ETH	`APP_ADDR_DEC_W'h92
`define APP_ADDR_USB1	`APP_ADDR_DEC_W'h9d
`define APP_ADDR_SD_CARD	`APP_ADDR_DEC_W'h9d
`define APP_ADDR_UART	`APP_ADDR_DEC_W'h90
`define APP_ADDR_USB2	`APP_ADDR_DEC_W'h94
`define APP_ADDR_SD	`APP_ADDR_DEC_W'h9e
`define APP_ADDR_RES2	`APP_ADDR_DEC_W'h9f
//`define APP_ADDR_FAKEMC	4'h6
