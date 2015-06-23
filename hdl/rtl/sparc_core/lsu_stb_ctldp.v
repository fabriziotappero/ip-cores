// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: lsu_stb_ctldp.v
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
//FPGA_SYN enables all FPGA related modifications
 




module lsu_stb_ctldp (/*AUTOARG*/
   // Outputs
   so, stb_state_si_0, stb_state_si_1, stb_state_si_2, 
   stb_state_si_3, stb_state_si_4, stb_state_si_5, stb_state_si_6, 
   stb_state_si_7, stb_state_rtype_0, stb_state_rtype_1, 
   stb_state_rtype_2, stb_state_rtype_3, stb_state_rtype_4, 
   stb_state_rtype_5, stb_state_rtype_6, stb_state_rtype_7, 
   stb_state_rmo, 
   // Inputs
   rclk, si, se, stb_clk_en_l, lsu_stb_va_m, lsu_st_rq_type_m, 
   lsu_st_rmo_m
   );
   
   input rclk;
   input si;
   input se;
//   input tmb_l;

   output so;
   
   input [7:0] stb_clk_en_l;

   input [7:6] lsu_stb_va_m;
   input [2:1] lsu_st_rq_type_m;
   input       lsu_st_rmo_m;

   output [3:2] stb_state_si_0;
   output [3:2] stb_state_si_1;
   output [3:2] stb_state_si_2;
   output [3:2] stb_state_si_3;
   output [3:2] stb_state_si_4;
   output [3:2] stb_state_si_5;
   output [3:2] stb_state_si_6;
   output [3:2] stb_state_si_7;

   output [2:1] stb_state_rtype_0;
   output [2:1] stb_state_rtype_1;
   output [2:1] stb_state_rtype_2;
   output [2:1] stb_state_rtype_3;
   output [2:1] stb_state_rtype_4;
   output [2:1] stb_state_rtype_5;
   output [2:1] stb_state_rtype_6;
   output [2:1] stb_state_rtype_7;

   output [7:0] stb_state_rmo;
   

   wire [7:0] stb_clk;

   wire       clk;
   assign     clk = rclk;
   
















































































   
   

  dffe #(5)  ff_spec_write_0         (
        .din    ({lsu_stb_va_m[7:6], lsu_st_rq_type_m[2:1], 
		                      lsu_st_rmo_m}),
        .q      ({stb_state_si_0[3:2], stb_state_rtype_0[2:1],     
		                       stb_state_rmo[0]}    ),
        .en (~(stb_clk_en_l[0])), .clk(clk),
        .se     (se), .si (), .so ()
        );












  dffe #(5)  ff_spec_write_1         (
        .din    ({lsu_stb_va_m[7:6], lsu_st_rq_type_m[2:1], 
		                      lsu_st_rmo_m}),
        .q      ({stb_state_si_1[3:2], stb_state_rtype_1[2:1],     
		                   stb_state_rmo[1]}    ),
        .en (~(stb_clk_en_l[1])), .clk(clk),
        .se     (se), .si (), .so ()
        );












  dffe #(5)  ff_spec_write_2         (
        .din    ({lsu_stb_va_m[7:6], lsu_st_rq_type_m[2:1], 
		                    lsu_st_rmo_m}),
        .q      ({stb_state_si_2[3:2], stb_state_rtype_2[2:1],     
		                   stb_state_rmo[2]}    ),
        .en (~(stb_clk_en_l[2])), .clk(clk),
        .se     (se), .si (), .so ()
        );











  dffe #(5)  ff_spec_write_3         (
        .din    ({lsu_stb_va_m[7:6], lsu_st_rq_type_m[2:1], 
		                    lsu_st_rmo_m}),
        .q      ({stb_state_si_3[3:2], stb_state_rtype_3[2:1],     
		                   stb_state_rmo[3]}    ),
        .en (~(stb_clk_en_l[3])), .clk(clk),
        .se     (se), .si (), .so ()
        );











  dffe #(5)  ff_spec_write_4         (
        .din    ({lsu_stb_va_m[7:6], lsu_st_rq_type_m[2:1], 
		                    lsu_st_rmo_m}),
        .q      ({stb_state_si_4[3:2], stb_state_rtype_4[2:1],     
		                   stb_state_rmo[4]}    ),
        .en (~(stb_clk_en_l[4])), .clk(clk),
        .se     (se), .si (), .so ()
        );











  dffe #(5)  ff_spec_write_5         (
        .din    ({lsu_stb_va_m[7:6], lsu_st_rq_type_m[2:1], 
		                    lsu_st_rmo_m}),
        .q      ({stb_state_si_5[3:2], stb_state_rtype_5[2:1],     
		                   stb_state_rmo[5]}    ),
        .en (~(stb_clk_en_l[5])), .clk(clk),
        .se     (se), .si (), .so ()
        );











  dffe #(5)  ff_spec_write_6         (
        .din    ({lsu_stb_va_m[7:6], lsu_st_rq_type_m[2:1], 
		                    lsu_st_rmo_m}),
        .q      ({stb_state_si_6[3:2], stb_state_rtype_6[2:1],     
		                   stb_state_rmo[6]}    ),
        .en (~(stb_clk_en_l[6])), .clk(clk),
        .se     (se), .si (), .so ()
        );












  dffe #(5)  ff_spec_write_7         (
        .din    ({lsu_stb_va_m[7:6], lsu_st_rq_type_m[2:1], 
		                    lsu_st_rmo_m}),
        .q      ({stb_state_si_7[3:2], stb_state_rtype_7[2:1],     
              		     stb_state_rmo[7]}    ),
        .en (~(stb_clk_en_l[7])), .clk(clk),
        .se     (se), .si (), .so ()
        );












endmodule // lsu_stb_ctldp
