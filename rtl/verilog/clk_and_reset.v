//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Versatile library, clock and reset                          ////
////                                                              ////
////  Description                                                 ////
////  Logic related to clock and reset                            ////
////                                                              ////
////                                                              ////
////  To Do:                                                      ////
////   - add more different registers                             ////
////                                                              ////
////  Author(s):                                                  ////
////      - Michael Unneback, unneback@opencores.org              ////
////        ORSoC AB                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2010 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`ifdef ACTEL
`ifdef GBUF
`timescale 1 ns/100 ps
// Global buffer
// usage:
// use to enable global buffers for high fan out signals such as clock and reset
// Version: 8.4 8.4.0.33
module gbuf(GL,CLK);
output GL;
input  CLK;

    wire GND;
    
    GND GND_1_net(.Y(GND));
    CLKDLY Inst1(.CLK(CLK), .GL(GL), .DLYGL0(GND), .DLYGL1(GND), 
        .DLYGL2(GND), .DLYGL3(GND), .DLYGL4(GND)) /* synthesis black_box */;
    
endmodule
`timescale 1 ns/1 ns
`define MODULE gbuf
module `BASE`MODULE ( i, o);
`undef MODULE
input i;
output o;
//E2_ifdef SIM_GBUF
assign o=i;
//E2_else
gbuf gbuf_i0 ( .CLK(i), .GL(o));
//E2_endif
endmodule
`endif

`else

`ifdef ALTERA
`ifdef GBUF
//altera
`define MODULE gbuf
module `BASE`MODULE ( i, o);
`undef MODULE
input i;
output o;
assign o = i;
endmodule
`endif

`else

`ifdef GBUF
`timescale 1 ns/100 ps
`define MODULE
module `BASE`MODULE ( i, o);
`undef MODULE
input i;
output o;
assign o = i;
endmodule
`endif
`endif // ALTERA
`endif //ACTEL

`ifdef SYNC_RST
// sync reset
// input active lo async reset, normally from external reset generator and/or switch
// output active high global reset sync with two DFFs 
`timescale 1 ns/100 ps
`define MODULE sync_rst
module `BASE`MODULE ( rst_n_i, rst_o, clk);
`undef MODULE
input rst_n_i, clk;
output rst_o;
reg [1:0] tmp;
always @ (posedge clk or negedge rst_n_i)
if (!rst_n_i)
	tmp <= 2'b11;
else
	tmp <= {1'b0,tmp[1]};
`define MODULE gbuf
`BASE`MODULE buf_i0( .i(tmp[0]), .o(rst_o));
`undef MODULE
endmodule
`endif

`ifdef PLL
// vl_pll
`ifdef ACTEL
///////////////////////////////////////////////////////////////////////////////
`timescale 1 ps/1 ps
`define MODULE pll
module `BASE`MODULE ( clk_i, rst_n_i, lock, clk_o, rst_o);
`undef MODULE
parameter index = 0;
parameter number_of_clk = 1;
parameter period_time_0 = 20000;
parameter period_time_1 = 20000;
parameter period_time_2 = 20000;
parameter lock_delay = 2000000;
input clk_i, rst_n_i;
output lock;
output reg [0:number_of_clk-1] clk_o;
output [0:number_of_clk-1] rst_o;

//E2_ifdef SIM_PLL

always
     #((period_time_0)/2) clk_o[0] <=  (!rst_n_i) ? 0 : ~clk_o[0];

generate if (number_of_clk > 1)
always
     #((period_time_1)/2) clk_o[1] <=  (!rst_n_i) ? 0 : ~clk_o[1];
endgenerate

generate if (number_of_clk > 2)
always
     #((period_time_2)/2) clk_o[2] <=  (!rst_n_i) ? 0 : ~clk_o[2];
endgenerate

genvar i;
generate for (i=0;i<number_of_clk;i=i+1) begin: clock
     vl_sync_rst rst_i0 ( .rst_n_i(rst_n_i | lock), .rst_o(rst_o[i]), .clk(clk_o[i]));
end
endgenerate

assign #lock_delay lock = rst_n_i;
	
endmodule
//E2_else
generate if (number_of_clk==1 & index==0) begin
	pll0 pll_i0 (.POWERDOWN(1'b1), .CLKA(clk_i), .LOCK(lock), .GLA(clk_o[0]));
end
endgenerate // index==0
generate if (number_of_clk==1 & index==1) begin
	pll1 pll_i0 (.POWERDOWN(1'b1), .CLKA(clk_i), .LOCK(lock), .GLA(clk_o[0]));
end
endgenerate // index==1
generate if (number_of_clk==1 & index==2) begin
	pll2 pll_i0 (.POWERDOWN(1'b1), .CLKA(clk_i), .LOCK(lock), .GLA(clk_o[0]));
end
endgenerate // index==2
generate if (number_of_clk==1 & index==3) begin
	pll3 pll_i0 (.POWERDOWN(1'b1), .CLKA(clk_i), .LOCK(lock), .GLA(clk_o[0]));
end
endgenerate // index==0

generate if (number_of_clk==2 & index==0) begin
	pll0 pll_i0 (.POWERDOWN(1'b1), .CLKA(clk_i), .LOCK(lock), .GLA(clk_o[0]), .GLB(clk_o[1]));
end
endgenerate // index==0
generate if (number_of_clk==2 & index==1) begin
	pll1 pll_i0 (.POWERDOWN(1'b1), .CLKA(clk_i), .LOCK(lock), .GLA(clk_o[0]), .GLB(clk_o[1]));
end
endgenerate // index==1
generate if (number_of_clk==2 & index==2) begin
	pll2 pll_i0 (.POWERDOWN(1'b1), .CLKA(clk_i), .LOCK(lock), .GLA(clk_o[0]), .GLB(clk_o[1]));
end
endgenerate // index==2
generate if (number_of_clk==2 & index==3) begin
	pll3 pll_i0 (.POWERDOWN(1'b1), .CLKA(clk_i), .LOCK(lock), .GLA(clk_o[0]), .GLB(clk_o[1]));
end
endgenerate // index==0

generate if (number_of_clk==3 & index==0) begin
	pll0 pll_i0 (.POWERDOWN(1'b1), .CLKA(clk_i), .LOCK(lock), .GLA(clk_o[0]), .GLB(clk_o[1]), .GLC(clk_o[2]));
end
endgenerate // index==0
generate if (number_of_clk==3 & index==1) begin
	pll1 pll_i0 (.POWERDOWN(1'b1), .CLKA(clk_i), .LOCK(lock), .GLA(clk_o[0]), .GLB(clk_o[1]), .GLC(clk_o[2]));
end
endgenerate // index==1
generate if (number_of_clk==3 & index==2) begin
	pll2 pll_i0 (.POWERDOWN(1'b1), .CLKA(clk_i), .LOCK(lock), .GLA(clk_o[0]), .GLB(clk_o[1]), .GLC(clk_o[2]));
end
endgenerate // index==2
generate if (number_of_clk==3 & index==3) begin
	pll3 pll_i0 (.POWERDOWN(1'b1), .CLKA(clk_i), .LOCK(lock), .GLA(clk_o[0]), .GLB(clk_o[1]), .GLC(clk_o[2]));
end
endgenerate // index==0

genvar i;
generate for (i=0;i<number_of_clk;i=i+1) begin: clock
`define MODULE sync_rst
	`BASE`MODULE rst_i0 ( .rst_n_i(rst_n_i | lock), .rst_o(rst_o), .clk(clk_o[i]));
`undef MODULE
end
endgenerate
endmodule
//E2_endif
///////////////////////////////////////////////////////////////////////////////

`else

///////////////////////////////////////////////////////////////////////////////
`ifdef ALTERA

`timescale 1 ps/1 ps
`define MODULE pll
module `BASE`MODULE ( clk_i, rst_n_i, lock, clk_o, rst_o);
`undef MODULE
parameter index = 0;
parameter number_of_clk = 1;
parameter period_time_0 = 20000;
parameter period_time_1 = 20000;
parameter period_time_2 = 20000;
parameter period_time_3 = 20000;
parameter period_time_4 = 20000;
parameter lock_delay = 2000000;
input clk_i, rst_n_i;
output lock;
output reg [0:number_of_clk-1] clk_o;
output [0:number_of_clk-1] rst_o;

//E2_ifdef SIM_PLL

always
     #((period_time_0)/2) clk_o[0] <=  (!rst_n_i) ? 0 : ~clk_o[0];

generate if (number_of_clk > 1)
always
     #((period_time_1)/2) clk_o[1] <=  (!rst_n_i) ? 0 : ~clk_o[1];
endgenerate

generate if (number_of_clk > 2)
always
     #((period_time_2)/2) clk_o[2] <=  (!rst_n_i) ? 0 : ~clk_o[2];
endgenerate

generate if (number_of_clk > 3)
always
     #((period_time_3)/2) clk_o[3] <=  (!rst_n_i) ? 0 : ~clk_o[3];
endgenerate

generate if (number_of_clk > 4)
always
     #((period_time_4)/2) clk_o[4] <=  (!rst_n_i) ? 0 : ~clk_o[4];
endgenerate

genvar i;
generate for (i=0;i<number_of_clk;i=i+1) begin: clock
     vl_sync_rst rst_i0 ( .rst_n_i(rst_n_i | lock), .rst_o(rst_o[i]), .clk(clk_o[i]));
end
endgenerate

//assign #lock_delay lock = rst_n_i;
assign lock = rst_n_i;
	
endmodule
//E2_else

//E2_ifdef VL_PLL0
//E2_ifdef VL_PLL0_CLK1
    pll0 pll0_i0 (.areset(rst_n_i), .inclk0(clk_i), .locked(lock), .c0(clk_o[0]));
//E2_endif
//E2_ifdef VL_PLL0_CLK2
    pll0 pll0_i0 (.areset(rst_n_i), .inclk0(clk_i), .locked(lock), .c0(clk_o[0]), .c1(clk_o[1]));
//E2_endif
//E2_ifdef VL_PLL0_CLK3
    pll0 pll0_i0 (.areset(rst_n_i), .inclk0(clk_i), .locked(lock), .c0(clk_o[0]), .c1(clk_o[1]), .c2(clk_o[2]));
//E2_endif
//E2_ifdef VL_PLL0_CLK4
    pll0 pll0_i0 (.areset(rst_n_i), .inclk0(clk_i), .locked(lock), .c0(clk_o[0]), .c1(clk_o[1]), .c2(clk_o[2]), .c3(clk_o[3]));
//E2_endif
//E2_ifdef VL_PLL0_CLK5
    pll0 pll0_i0 (.areset(rst_n_i), .inclk0(clk_i), .locked(lock), .c0(clk_o[0]), .c1(clk_o[1]), .c2(clk_o[2]), .c3(clk_o[3]), .c4(clk_o[4]));
//E2_endif
//E2_endif

//E2_ifdef VL_PLL1
//E2_ifdef VL_PLL1_CLK1
    pll1 pll1_i0 (.areset(rst_n_i), .inclk0(clk_i), .locked(lock), .c0(clk_o[0]));
//E2_endif
//E2_ifdef VL_PLL1_CLK2
    pll1 pll1_i0 (.areset(rst_n_i), .inclk0(clk_i), .locked(lock), .c0(clk_o[0]), .c1(clk_o[1]));
//E2_endif
//E2_ifdef VL_PLL1_CLK3
    pll1 pll1_i0 (.areset(rst_n_i), .inclk0(clk_i), .locked(lock), .c0(clk_o[0]), .c1(clk_o[1]), .c2(clk_o[2]));
//E2_endif
//E2_ifdef VL_PLL1_CLK4
    pll1 pll1_i0 (.areset(rst_n_i), .inclk0(clk_i), .locked(lock), .c0(clk_o[0]), .c1(clk_o[1]), .c2(clk_o[2]), .c3(clk_o[3]));
//E2_endif
//E2_ifdef VL_PLL1_CLK5
    pll1 pll1_i0 (.areset(rst_n_i), .inclk0(clk_i), .locked(lock), .c0(clk_o[0]), .c1(clk_o[1]), .c2(clk_o[2]), .c3(clk_o[3]), .c4(clk_o[4]));
//E2_endif
//E2_endif

//E2_ifdef VL_PLL2
//E2_ifdef VL_PLL2_CLK1
    pll2 pll2_i0 (.areset(rst_n_i), .inclk0(clk_i), .locked(lock), .c0(clk_o[0]));
//E2_endif
//E2_ifdef VL_PLL2_CLK2
    pll2 pll2_i0 (.areset(rst_n_i), .inclk0(clk_i), .locked(lock), .c0(clk_o[0]), .c1(clk_o[1]));
//E2_endif
//E2_ifdef VL_PLL2_CLK3
    pll2 pll2_i0 (.areset(rst_n_i), .inclk0(clk_i), .locked(lock), .c0(clk_o[0]), .c1(clk_o[1]), .c2(clk_o[2]));
//E2_endif
//E2_ifdef VL_PLL2_CLK4
    pll2 pll2_i0 (.areset(rst_n_i), .inclk0(clk_i), .locked(lock), .c0(clk_o[0]), .c1(clk_o[1]), .c2(clk_o[2]), .c3(clk_o[3]));
//E2_endif
//E2_ifdef VL_PLL2_CLK5
    pll2 pll2_i0 (.areset(rst_n_i), .inclk0(clk_i), .locked(lock), .c0(clk_o[0]), .c1(clk_o[1]), .c2(clk_o[2]), .c3(clk_o[3]), .c4(clk_o[4]));
//E2_endif
//E2_endif

//E2_ifdef VL_PLL3
//E2_ifdef VL_PLL3_CLK1
    pll3 pll3_i0 (.areset(rst_n_i), .inclk0(clk_i), .locked(lock), .c0(clk_o[0]));
//E2_endif
//E2_ifdef VL_PLL3_CLK2
    pll3 pll3_i0 (.areset(rst_n_i), .inclk0(clk_i), .locked(lock), .c0(clk_o[0]), .c1(clk_o[1]));
//E2_endif
//E2_ifdef VL_PLL3_CLK3
    pll3 pll3_i0 (.areset(rst_n_i), .inclk0(clk_i), .locked(lock), .c0(clk_o[0]), .c1(clk_o[1]), .c2(clk_o[2]));
//E2_endif
//E2_ifdef VL_PLL3_CLK4
    pll3 pll3_i0 (.areset(rst_n_i), .inclk0(clk_i), .locked(lock), .c0(clk_o[0]), .c1(clk_o[1]), .c2(clk_o[2]), .c3(clk_o[3]));
//E2_endif
//E2_ifdef VL_PLL3_CLK5
    pll3 pll3_i0 (.areset(rst_n_i), .inclk0(clk_i), .locked(lock), .c0(clk_o[0]), .c1(clk_o[1]), .c2(clk_o[2]), .c3(clk_o[3]), .c4(clk_o[4]));
//E2_endif
//E2_endif

genvar i;
generate for (i=0;i<number_of_clk;i=i+1) begin: clock
`define MODULE sync_rst
	`BASE`MODULE rst_i0 ( .rst_n_i(rst_n_i | lock), .rst_o(rst_o[i]), .clk(clk_o[i]));
`undef MODULE
end
endgenerate
endmodule
//E2_endif
///////////////////////////////////////////////////////////////////////////////

`else

// generic PLL
`timescale 1 ps/1 ps
`define MODULE pll
module `BASE`MODULE ( clk_i, rst_n_i, lock, clk_o, rst_o);
`undef MODULE
parameter index = 0;
parameter number_of_clk = 1;
parameter period_time = 20000;
parameter clk0_mult_by = 1;
parameter clk0_div_by  = 1;
parameter clk1_mult_by = 1;
parameter clk1_div_by  = 1;
parameter clk2_mult_by = 1;
parameter clk3_div_by  = 1;
parameter clk3_mult_by = 1;
parameter clk3_div_by  = 1;
parameter clk4_mult_by = 1;
parameter clk4_div_by  = 1;
input clk_i, rst_n_i;
output lock;
output reg [0:number_of_clk-1] clk_o;

initial
    clk_o = {number_of_clk{1'b0}};
    
always
    #((period_time*clk0_div_by/clk0_mult_by)/2) clk_o[0] <=  (!rst_n_i) ? 1'b0 : ~clk_o[0];

generate if (number_of_clk > 1)
always
    #((period_time*clk1_div_by/clk1_mult_by)/2) clk_o[1] <=  (!rst_n_i) ? 1'b0 : ~clk_o[1];
endgenerate

generate if (number_of_clk > 2)
always
    #((period_time*clk2_div_by/clk2_mult_by)/2) clk_o[2] <=  (!rst_n_i) ? 1'b0 : ~clk_o[2];
endgenerate

generate if (number_of_clk > 3)
always
    #((period_time*clk3_div_by/clk3_mult_by)/2) clk_o[3] <=  (!rst_n_i) ? 1'b0 : ~clk_o[3];
endgenerate

generate if (number_of_clk > 4)
always
    #((period_time*clk4_div_by/clk4_mult_by)/2) clk_o[4] <=  (!rst_n_i) ? 1'b0 : ~clk_o[4];
endgenerate

assign #lock_delay lock = rst_n_i;
	
endmodule

`endif //altera
`endif //actel
`undef MODULE
`endif