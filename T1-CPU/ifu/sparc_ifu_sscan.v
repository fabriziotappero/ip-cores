// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: sparc_ifu_sscan.v
// Copyright (c) 2006 Sun Microsystems, Inc.  All Rights Reserved.
// DO NOT ALTER OR REMOVE COPYRIGHT NOTICES.
// 
// The above named program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public
// License version 2 as published by the Free Software Foundation.
// 
// The above named program is distributed in the hope that it will be 
// useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
// 
// You should have received a copy of the GNU General Public
// License along with this work; if not, write to the Free Software
// Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
// 
// ========== Copyright Header End ============================================
module sparc_ifu_sscan( ctu_sscan_snap, ctu_sscan_se, ctu_tck, lsu_sscan_test_data, 
tlu_sscan_test_data, swl_sscan_thrstate, ifq_sscan_test_data, sparc_sscan_so, rclk, si, so, se);

input ctu_sscan_snap;
input ctu_sscan_se;
input ctu_tck;
input si;
input se;
input [10:0] swl_sscan_thrstate;
input [3:0] ifq_sscan_test_data;
input [15:0] lsu_sscan_test_data;
input [62:0] tlu_sscan_test_data;
input rclk;

output sparc_sscan_so;
output so;

//////////////////////////////////////////////////////////////////

wire snap_f;
wire [93:0] snap_data, snap_data_f, snap_data_ff;

`ifdef CONNECT_SHADOW_SCAN
wire [92:0] sscan_shift_data;
`endif

////////

dff_s #(1) snap_inst0(.q(snap_f), .din(ctu_sscan_snap), .clk(rclk), .se(se), .si(), .so());

assign snap_data = {ifq_sscan_test_data, tlu_sscan_test_data, lsu_sscan_test_data, swl_sscan_thrstate};

dffe_s #(94) snap_inst1(.q(snap_data_f), .din(snap_data), .clk(rclk), .en(snap_f), .se(se), .si(), .so());

`ifdef CONNECT_SHADOW_SCAN
dff_sscan #(94) snap_inst2(.q(snap_data_ff), .din(snap_data_f), .clk(ctu_tck), .se(ctu_sscan_se), 
		     .si({sscan_shift_data, 1'b0}),
		     .so({sparc_sscan_so, sscan_shift_data}));
`else
dff_s #(94) snap_inst2(.q(snap_data_ff), .din(snap_data_f), .clk(ctu_tck), .se(ctu_sscan_se), 
		     .si(), .so());

assign sparc_sscan_so = 1'b0;
`endif

sink #(94) s0(.in (snap_data_ff));
   

endmodule     
