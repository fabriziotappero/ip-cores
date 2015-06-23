/*
ORSoC GFX accelerator core
Copyright 2012, ORSoC, Per Lenander, Anton Fosselius.

WBM reader arbiter

Loosely based on the arbiter_dbus.v (LGPL) in orpsocv2 by Julius Baxter, julius@opencores.org

 This file is part of orgfx.

 orgfx is free software: you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version. 

 orgfx is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public License
 along with orgfx.  If not, see <http://www.gnu.org/licenses/>.

*/

// 3 Masters, one slave
module gfx_wbm_read_arbiter
  (
   master_busy_o,
   // Interface against the wbm read module
   read_request_o,
   addr_o,
   sel_o,
   dat_i,
   ack_i,
   // Interface against masters (clip)
   m0_read_request_i,
   m0_addr_i,
   m0_sel_i,
   m0_dat_o,
   m0_ack_o,
   // Interface against masters (fragment processor)
   m1_read_request_i,
   m1_addr_i,
   m1_sel_i,
   m1_dat_o,
   m1_ack_o,
   // Interface against masters (blender)
   m2_read_request_i,
   m2_addr_i,
   m2_sel_i,
   m2_dat_o,
   m2_ack_o
   );

output        master_busy_o;
// Interface against the wbm read module
output        read_request_o;
output [31:2] addr_o;
output  [3:0] sel_o;
input  [31:0] dat_i;
input         ack_i;
// Interface against masters (clip)
input         m0_read_request_i;
input  [31:2] m0_addr_i;
input   [3:0] m0_sel_i;
output [31:0] m0_dat_o;
output        m0_ack_o;
// Interface against masters (fragment processor)
input         m1_read_request_i;
input  [31:2] m1_addr_i;
input   [3:0] m1_sel_i;
output [31:0] m1_dat_o;
output        m1_ack_o;
// Interface against masters (blender)
input         m2_read_request_i;
input  [31:2] m2_addr_i;
input   [3:0] m2_sel_i;
output [31:0] m2_dat_o;
output        m2_ack_o;

// Master ins -> |MUX> -> these wires
wire        rreq_w;
wire [31:2] addr_w;
wire  [3:0] sel_w;
// Slave ins -> |MUX> -> these wires
wire [31:0] dat_w;
wire        ack_w;

// Master select (MUX controls)
wire [2:0] master_sel;

assign master_busy_o = m0_read_request_i | m1_read_request_i | m2_read_request_i;

// priority to wbm1, the blender master
assign master_sel[0] = m0_read_request_i & !m1_read_request_i & !m2_read_request_i;
assign master_sel[1] = m1_read_request_i & !m2_read_request_i;
assign master_sel[2] = m2_read_request_i;

// Master input mux, priority to blender master
assign m0_dat_o = dat_i;
assign m0_ack_o = ack_i & master_sel[0];

assign m1_dat_o = dat_i;
assign m1_ack_o = ack_i & master_sel[1];

assign m2_dat_o = dat_i;
assign m2_ack_o = ack_i & master_sel[2];

assign read_request_o = master_sel[2] |
                        master_sel[1] |
                        master_sel[0];

assign addr_o = master_sel[2] ? m2_addr_i :
                master_sel[1] ? m1_addr_i :
	                              m0_addr_i;
assign sel_o  = master_sel[2] ? m2_sel_i :
                master_sel[1] ? m1_sel_i :
	                              m0_sel_i;
   
endmodule // gfx_wbm_read_arbiter

