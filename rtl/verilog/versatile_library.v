`ifndef BASE
`define BASE vl_
`endif
 
// default SYN_KEEP definition
`define SYN_KEEP /*synthesis syn_keep = 1*/

`ifdef ACTEL
`undef SYN_KEEP
`define SYN_KEEP /*synthesis syn_keep = 1*/
`endif

`ifdef ACTEL
    // ACTEL FPGA should not use logic to handle rw collision
    `define SYN_NO_RW_CHECK /*synthesis syn_ramstyle = "no_rw_check"*/
`else
    `define SYN_NO_RW_CHECK 
`endif

`ifdef ALL

`define GBUF
`define SYNC_RST
`define PLL

`define MULTS
`define MULTS18X18
`define MULT
`define ARITH_UNIT
`define SHIFT_UNIT_32
`define LOGIC_UNIT
`define COUNT_UNIT
`define EXT_UNIT

`define CNT_SHREG_WRAP
`define CNT_SHREG_CE_WRAP
`define CNT_SHREG_CLEAR
`define CNT_SHREG_CE_CLEAR
`define CNT_SHREG_CE_CLEAR_WRAP

`define CNT_BIN
`define CNT_BIN_CE
`define CNT_BIN_CLEAR
`define CNT_BIN_CE_CLEAR
`define CNT_BIN_CE_CLEAR_L1_L2
`define CNT_BIN_CE_CLEAR_SET_REW
`define CNT_BIN_CE_REW_L1
`define CNT_BIN_CE_REW_ZQ_L1
`define CNT_BIN_CE_REW_Q_ZQ_L1
`define CNT_GRAY
`define CNT_GRAY_CE
`define CNT_GRAY_CE_BIN
`define CNT_LFSR_ZQ
`define CNT_LFSR_CE
`define CNT_LFSR_CE_CLEAR_Q
`define CNT_LFSR_CE_Q
`define CNT_LFSR_CE_ZQ
`define CNT_LFSR_CE_Q_ZQ
`define CNT_LFSR_CE_REW_L1

`define MUX_ANDOR
`define MUX2_ANDOR
`define MUX3_ANDOR
`define MUX4_ANDOR
`define MUX5_ANDOR
`define MUX6_ANDOR
`define PARITY

`define ROM_INIT
`define RAM
`define RAM_BE
`define DPRAM_1R1W
`define DPRAM_2R1W
`define DPRAM_1R2W
`define DPRAM_2R2W
`define DPRAM_BE_2R2W
`define FIFO_1R1W_FILL_LEVEL_SYNC
`define FIFO_2R2W_SYNC_SIMPLEX
`define FIFO_CMP_ASYNC
`define FIFO_1R1W_ASYNC
`define FIFO_2R2W_ASYNC
`define FIFO_2R2W_ASYNC_SIMPLEX
`define REG_FILE

`define DFF
`define DFF_ARRAY
`define DFF_CE
`define DFF_CE_CLEAR
`define DF_CE_SET
`define SPR
`define SRP
`define DFF_SR
`define LATCH
`define SHREG
`define SHREG_CE
`define DELAY
`define DELAY_EMPTYFLAG
`define PULSE2TOGGLE
`define TOGGLE2PULSE
`define SYNCHRONIZER
`define CDC

`define WB3AVALON_BRIDGE
`define WB3WB3_BRIDGE
`define WB3_ARBITER_TYPE1
`define WB_ADR_INC
`define WB_RAM
`define WB_SHADOW_RAM
`define WB_B4_ROM
`define WB_BOOT_ROM
`define WB_DPRAM
`define WB_CACHE
`define WB_AVALON_BRIDGE
`define WB_AVALON_MEM_CACHE
`define WB_SDR_SDRAM_CTRL

`define IO_DFF_OE
`define O_DFF
`define O_DDR
`define O_CLK

`endif

///////////////////////////////////////
// dependencies
///////////////////////////////////////

`ifdef PLL
`ifndef SYNC_RST
`define SYNC_RST
`endif
`endif

`ifdef SYNC_RST
`ifndef GBUF
`define GBUF
`endif
`endif

`ifdef WB_SDR_SDRAM_CTRL
`ifndef WB_SHADOW_RAM
`define WB_SHADOW_RAM
`endif
`ifndef WB_CACHE
`define WB_CACHE
`endif
`ifndef WB_SDR_SDRAM
`define WB_SDR_SDRAM
`endif
`ifndef IO_DFF_OE
`define IO_DFF_OE
`endif
`ifndef O_DFF
`define O_DFF
`endif
`ifndef O_CLK
`define O_CLK
`endif
`endif

`ifdef WB_SDR_SDRAM
`ifndef CNT_SHREG_CLEAR
`define CNT_SHREG_CLEAR
`endif
`ifndef CNT_LFSR_ZQ
`define CNT_LFSR_ZQ
`endif
`ifndef DELAY_EMPTYFLAG
`define DELAY_EMPTYFLAG
`endif
`endif

`ifdef WB_DPRAM
`ifndef WB_ADR_INC
`define WB_ADR_INC
`endif
`ifndef DFF
`define DFF
`endif
`ifndef DPRAM_BE_2R2W
`define DPRAM_BE_2R2W
`endif
`endif

`ifdef WB3_ARBITER_TYPE1
`ifndef SPR
`define SPR
`endif
`ifndef MUX_ANDOR
`define MUX_ANDOR
`endif
`endif

`ifdef WB3AVALON_BRIDGE
`ifndef WB3WB3_BRIDGE
`define WB3WB3_BRIDGE
`endif
`endif

`ifdef WB3WB3_BRIDGE
`ifndef CNT_SHREG_CE_CLEAR
`define CNT_SHREG_CE_CLEAR
`endif
`ifndef DFF
`define DFF
`endif
`ifndef DFF_CE
`define DFF_CE
`endif
`ifndef CNT_SHREG_CE_CLEAR
`define CNT_SHREG_CE_CLEAR
`endif
`ifndef FIFO_2R2W_ASYNC_SIMPLEX
`define FIFO_2R2W_ASYNC_SIMPLEX
`endif
`endif


`ifdef WB_AVALON_MEM_CACHE
`ifndef WB_SHADOW_RAM
`define WB_SHADOW_RAM
`endif
`ifndef WB_CACHE
`define WB_CACHE
`endif
`ifndef WB_AVALON_BRIDGE
`define WB_AVALON_BRIDGE
`endif
`endif

`ifdef WB_CACHE
`ifndef RAM
`define RAM
`endif
`ifndef WB_ADR_INC
`define WB_ADR_INC
`endif
`ifndef DPRAM_1R1W
`define DPRAM_1R1W
`endif
`ifndef DPRAM_1R2W
`define DPRAM_1R2W
`endif
`ifndef DPRAM_BE_2R2W
`define DPRAM_BE_2R2W
`endif
`ifndef CDC
`define CDC
`endif
`ifndef O_DFF
`define O_DFF
`endif
`ifndef O_CLK
`define O_CLK
`endif
`endif

`ifdef WB_SHADOW_RAM
`ifndef WB_RAM
`define WB_RAM
`endif
`endif

`ifdef WB_RAM
`ifndef WB_ADR_INC
`define WB_ADR_INC
`endif
`ifndef RAM_BE
`define RAM_BE
`endif
`endif

`ifdef MULTS18X18
`ifndef MULTS
`define MULTS
`endif
`endif

`ifdef SHIFT_UNIT_32
`ifndef MULTS
`define MULTS
`endif
`endif

`ifdef MUX2_ANDOR
`ifndef MUX_ANDOR
`define MUX_ANDOR
`endif
`endif

`ifdef MUX3_ANDOR
`ifndef MUX_ANDOR
`define MUX_ANDOR
`endif
`endif

`ifdef MUX4_ANDOR
`ifndef MUX_ANDOR
`define MUX_ANDOR
`endif
`endif

`ifdef MUX5_ANDOR
`ifndef MUX_ANDOR
`define MUX_ANDOR
`endif
`endif

`ifdef MUX6_ANDOR
`ifndef MUX_ANDOR
`define MUX_ANDOR
`endif
`endif

`ifdef FIFO_1R1W_FILL_LEVEL_SYNC
`ifndef CNT_BIN_CE
`define CNT_BIN_CE
`endif
`ifndef DPRAM_1R1W
`define DPRAM_1R1W
`endif
`ifndef CNT_BIN_CE_REW_Q_ZQ_L1
`define CNT_BIN_CE_REW_Q_ZQ_L1
`endif
`endif

`ifdef FIFO_1R1W_FILL_LEVEL_SYNC
`ifndef CNT_LFSR_CE
`define CNT_LFSR_CE
`endif
`ifndef DPRAM_2R2W
`define DPRAM_2R2W
`endif
`ifndef CNT_BIN_CE_REW_ZQ_L1
`define CNT_BIN_CE_REW_ZQ_L1
`endif
`endif

`ifdef FIFO_2R2W_ASYNC_SIMPLEX
`ifndef CNT_GRAY_CE_BIN
`define CNT_GRAY_CE_BIN
`endif
`ifndef DPRAM_2R2W
`define DPRAM_2R2W
`endif
`ifndef FIFO_CMP_ASYNC
`define FIFO_CMP_ASYNC
`endif
`endif

`ifdef FIFO_2R2W_ASYNC
`ifndef FIFO_1R1W_ASYNC
`define FIFO_1R1W_ASYNC
`endif
`endif

`ifdef FIFO_1R1W_ASYNC
`ifndef CNT_GRAY_CE_BIN
`define CNT_GRAY_CE_BIN
`endif
`ifndef DPRAM_1R1W
`define DPRAM_1R1W
`endif
`ifndef FIFO_CMP_ASYNC
`define FIFO_CMP_ASYNC
`endif
`endif

`ifdef FIFO_CMP_ASYNC
`ifndef DFF_SR
`define DFF_SR
`endif
`ifndef DFF
`define DFF
`endif
`endif

`ifdef REG_FILE
`ifndef DPRAM_1R1W
`define DPRAM_1R1W
`endif
`endif

`ifdef CDC
`ifndef PULSE2TOGGLE
`define PULSE2TOGGLE
`endif
`ifndef TOGGLE2PULSE
`define TOGGLE2PULSE
`endif
`ifndef SYNCHRONIZER
`define SYNCHRONIZER
`endif
`endif

`ifdef O_CLK
`ifndef O_DDR
`define O_DDR
`endif
`endif

// size to width
`define SIZE2WIDTH_EXPR = (`SIZE2WIDTH==1) ? 0 : (`SIZE2WIDTH==2) ? 1 : (`SIZE2WIDTH==4) ? 2 : (`SIZE2WIDTH==8) ? 3 : (`SIZE2WIDTH==16) ? 4 : (`SIZE2WIDTH==32) ? 5 : (`SIZE2WIDTH==64) ? 6 : (`SIZE2WIDTH==128) ? 7 : 8;
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
`ifdef SIM_GBUF
assign o=i;
`else
gbuf gbuf_i0 ( .CLK(i), .GL(o));
`endif
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

`ifdef SIM_PLL

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
`else
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
`endif
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

`ifdef SIM_PLL

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
`else

`ifdef VL_PLL0
`ifdef VL_PLL0_CLK1
    pll0 pll0_i0 (.areset(rst_n_i), .inclk0(clk_i), .locked(lock), .c0(clk_o[0]));
`endif
`ifdef VL_PLL0_CLK2
    pll0 pll0_i0 (.areset(rst_n_i), .inclk0(clk_i), .locked(lock), .c0(clk_o[0]), .c1(clk_o[1]));
`endif
`ifdef VL_PLL0_CLK3
    pll0 pll0_i0 (.areset(rst_n_i), .inclk0(clk_i), .locked(lock), .c0(clk_o[0]), .c1(clk_o[1]), .c2(clk_o[2]));
`endif
`ifdef VL_PLL0_CLK4
    pll0 pll0_i0 (.areset(rst_n_i), .inclk0(clk_i), .locked(lock), .c0(clk_o[0]), .c1(clk_o[1]), .c2(clk_o[2]), .c3(clk_o[3]));
`endif
`ifdef VL_PLL0_CLK5
    pll0 pll0_i0 (.areset(rst_n_i), .inclk0(clk_i), .locked(lock), .c0(clk_o[0]), .c1(clk_o[1]), .c2(clk_o[2]), .c3(clk_o[3]), .c4(clk_o[4]));
`endif
`endif

`ifdef VL_PLL1
`ifdef VL_PLL1_CLK1
    pll1 pll1_i0 (.areset(rst_n_i), .inclk0(clk_i), .locked(lock), .c0(clk_o[0]));
`endif
`ifdef VL_PLL1_CLK2
    pll1 pll1_i0 (.areset(rst_n_i), .inclk0(clk_i), .locked(lock), .c0(clk_o[0]), .c1(clk_o[1]));
`endif
`ifdef VL_PLL1_CLK3
    pll1 pll1_i0 (.areset(rst_n_i), .inclk0(clk_i), .locked(lock), .c0(clk_o[0]), .c1(clk_o[1]), .c2(clk_o[2]));
`endif
`ifdef VL_PLL1_CLK4
    pll1 pll1_i0 (.areset(rst_n_i), .inclk0(clk_i), .locked(lock), .c0(clk_o[0]), .c1(clk_o[1]), .c2(clk_o[2]), .c3(clk_o[3]));
`endif
`ifdef VL_PLL1_CLK5
    pll1 pll1_i0 (.areset(rst_n_i), .inclk0(clk_i), .locked(lock), .c0(clk_o[0]), .c1(clk_o[1]), .c2(clk_o[2]), .c3(clk_o[3]), .c4(clk_o[4]));
`endif
`endif

`ifdef VL_PLL2
`ifdef VL_PLL2_CLK1
    pll2 pll2_i0 (.areset(rst_n_i), .inclk0(clk_i), .locked(lock), .c0(clk_o[0]));
`endif
`ifdef VL_PLL2_CLK2
    pll2 pll2_i0 (.areset(rst_n_i), .inclk0(clk_i), .locked(lock), .c0(clk_o[0]), .c1(clk_o[1]));
`endif
`ifdef VL_PLL2_CLK3
    pll2 pll2_i0 (.areset(rst_n_i), .inclk0(clk_i), .locked(lock), .c0(clk_o[0]), .c1(clk_o[1]), .c2(clk_o[2]));
`endif
`ifdef VL_PLL2_CLK4
    pll2 pll2_i0 (.areset(rst_n_i), .inclk0(clk_i), .locked(lock), .c0(clk_o[0]), .c1(clk_o[1]), .c2(clk_o[2]), .c3(clk_o[3]));
`endif
`ifdef VL_PLL2_CLK5
    pll2 pll2_i0 (.areset(rst_n_i), .inclk0(clk_i), .locked(lock), .c0(clk_o[0]), .c1(clk_o[1]), .c2(clk_o[2]), .c3(clk_o[3]), .c4(clk_o[4]));
`endif
`endif

`ifdef VL_PLL3
`ifdef VL_PLL3_CLK1
    pll3 pll3_i0 (.areset(rst_n_i), .inclk0(clk_i), .locked(lock), .c0(clk_o[0]));
`endif
`ifdef VL_PLL3_CLK2
    pll3 pll3_i0 (.areset(rst_n_i), .inclk0(clk_i), .locked(lock), .c0(clk_o[0]), .c1(clk_o[1]));
`endif
`ifdef VL_PLL3_CLK3
    pll3 pll3_i0 (.areset(rst_n_i), .inclk0(clk_i), .locked(lock), .c0(clk_o[0]), .c1(clk_o[1]), .c2(clk_o[2]));
`endif
`ifdef VL_PLL3_CLK4
    pll3 pll3_i0 (.areset(rst_n_i), .inclk0(clk_i), .locked(lock), .c0(clk_o[0]), .c1(clk_o[1]), .c2(clk_o[2]), .c3(clk_o[3]));
`endif
`ifdef VL_PLL3_CLK5
    pll3 pll3_i0 (.areset(rst_n_i), .inclk0(clk_i), .locked(lock), .c0(clk_o[0]), .c1(clk_o[1]), .c2(clk_o[2]), .c3(clk_o[3]), .c4(clk_o[4]));
`endif
`endif

genvar i;
generate for (i=0;i<number_of_clk;i=i+1) begin: clock
`define MODULE sync_rst
	`BASE`MODULE rst_i0 ( .rst_n_i(rst_n_i | lock), .rst_o(rst_o[i]), .clk(clk_o[i]));
`undef MODULE
end
endgenerate
endmodule
`endif
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
`endif//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Versatile library, registers                                ////
////                                                              ////
////  Description                                                 ////
////  Different type of registers                                 ////
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

`ifdef DFF
`define MODULE dff
module `BASE`MODULE ( d, q, clk, rst);
`undef MODULE
	parameter width = 1;	
	parameter reset_value = {width{1'b0}};

	input [width-1:0] d; 
	input clk, rst;
	output reg [width-1:0] q;
	
	always @ (posedge clk or posedge rst)
	if (rst)
		q <= reset_value;
	else
		q <= d;

endmodule
`endif

`ifdef DFF_ARRAY
`define MODULE dff_array
module `BASE`MODULE ( d, q, clk, rst);
`undef MODULE

	parameter width = 1;
        parameter depth = 2;
	parameter reset_value = 1'b0;

	input [width-1:0] d; 
	input clk, rst;
	output [width-1:0] q;
        reg  [0:depth-1] q_tmp [width-1:0];
	integer i;
	always @ (posedge clk or posedge rst)
	if (rst) begin
            for (i=0;i<depth;i=i+1)
		q_tmp[i] <= {width{reset_value}};
	end else begin
            q_tmp[0] <= d;
            for (i=1;i<depth;i=i+1)
		q_tmp[i] <= q_tmp[i-1];
        end
        
    assign q = q_tmp[depth-1];
    
endmodule
`endif

`ifdef DFF_CE
`define MODULE dff_ce
module `BASE`MODULE ( d, ce, q, clk, rst);
`undef MODULE

	parameter width = 1;	
	parameter reset_value = {width{1'b0}};
	
	input [width-1:0] d; 
	input ce, clk, rst;
	output reg [width-1:0] q;

	always @ (posedge clk or posedge rst)
	if (rst)
		q <= reset_value;
	else
		if (ce)
			q <= d;

endmodule
`endif

`ifdef DFF_CE_CLEAR
`define MODULE dff_ce_clear
module `BASE`MODULE ( d, ce, clear, q, clk, rst);
`undef MODULE

	parameter width = 1;	
	parameter reset_value = {width{1'b0}};
	
	input [width-1:0] d; 
	input ce, clear, clk, rst;
	output reg [width-1:0] q;

	always @ (posedge clk or posedge rst)
	if (rst)
	    q <= reset_value;
	else
            if (ce)
                if (clear)
                    q <= {width{1'b0}};
                else
                    q <= d;

endmodule
`endif

`ifdef DF_CE_SET
`define MODULE dff_ce_set
module `BASE`MODULE ( d, ce, set, q, clk, rst);
`undef MODULE

	parameter width = 1;	
	parameter reset_value = {width{1'b0}};
	
	input [width-1:0] d; 
	input ce, set, clk, rst;
	output reg [width-1:0] q;

	always @ (posedge clk or posedge rst)
	if (rst)
	    q <= reset_value;
	else
            if (ce)
                if (set)
                    q <= {width{1'b1}};
                else
                    q <= d;

endmodule
`endif

`ifdef SPR
`define MODULE spr
module `BASE`MODULE ( sp, r, q, clk, rst);
`undef MODULE

        //parameter width = 1;
        parameter reset_value = 1'b0;
        
        input sp, r;
        output reg q;
        input clk, rst;
        
        always @ (posedge clk or posedge rst)
        if (rst)
            q <= reset_value;
        else
            if (sp)
                q <= 1'b1;
            else if (r)
                q <= 1'b0;

endmodule
`endif

`ifdef SRP
`define MODULE srp
module `BASE`MODULE ( s, rp, q, clk, rst);
`undef MODULE

        parameter width = 1;
        parameter reset_value = 0;
        
        input s, rp;
        output reg q;
        input clk, rst;
        
        always @ (posedge clk or posedge rst)
        if (rst)
            q <= reset_value;
        else
            if (rp)
                q <= 1'b0;
            else if (s)
                q <= 1'b1;

endmodule
`endif

`ifdef ALTERA

`ifdef DFF_SR
// megafunction wizard: %LPM_FF%
// GENERATION: STANDARD
// VERSION: WM1.0
// MODULE: lpm_ff 

// ============================================================
// File Name: dff_sr.v
// Megafunction Name(s):
// 			lpm_ff
//
// Simulation Library Files(s):
// 			lpm
// ============================================================
// ************************************************************
// THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
//
// 9.1 Build 304 01/25/2010 SP 1 SJ Full Version
// ************************************************************


//Copyright (C) 1991-2010 Altera Corporation
//Your use of Altera Corporation's design tools, logic functions 
//and other software and tools, and its AMPP partner logic 
//functions, and any output files from any of the foregoing 
//(including device programming or simulation files), and any 
//associated documentation or information are expressly subject 
//to the terms and conditions of the Altera Program License 
//Subscription Agreement, Altera MegaCore Function License 
//Agreement, or other applicable license agreement, including, 
//without limitation, that your use is for the sole purpose of 
//programming logic devices manufactured by Altera and sold by 
//Altera or its authorized distributors.  Please refer to the 
//applicable agreement for further details.


// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
`define MODULE dff_sr
module `BASE`MODULE (
`undef MODULE

	aclr,
	aset,
	clock,
	data,
	q);

	input	  aclr;
	input	  aset;
	input	  clock;
	input	  data;
	output	  q;

	wire [0:0] sub_wire0;
	wire [0:0] sub_wire1 = sub_wire0[0:0];
	wire  q = sub_wire1;
	wire  sub_wire2 = data;
	wire  sub_wire3 = sub_wire2;

	lpm_ff	lpm_ff_component (
				.aclr (aclr),
				.clock (clock),
				.data (sub_wire3),
				.aset (aset),
				.q (sub_wire0)
				// synopsys translate_off
				,
				.aload (),
				.enable (),
				.sclr (),
				.sload (),
				.sset ()
				// synopsys translate_on
				);
	defparam
		lpm_ff_component.lpm_fftype = "DFF",
		lpm_ff_component.lpm_type = "LPM_FF",
		lpm_ff_component.lpm_width = 1;


endmodule

// ============================================================
// CNX file retrieval info
// ============================================================
// Retrieval info: PRIVATE: ACLR NUMERIC "1"
// Retrieval info: PRIVATE: ALOAD NUMERIC "0"
// Retrieval info: PRIVATE: ASET NUMERIC "1"
// Retrieval info: PRIVATE: ASET_ALL1 NUMERIC "1"
// Retrieval info: PRIVATE: CLK_EN NUMERIC "0"
// Retrieval info: PRIVATE: DFF NUMERIC "1"
// Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Cyclone IV E"
// Retrieval info: PRIVATE: SCLR NUMERIC "0"
// Retrieval info: PRIVATE: SLOAD NUMERIC "0"
// Retrieval info: PRIVATE: SSET NUMERIC "0"
// Retrieval info: PRIVATE: SSET_ALL1 NUMERIC "1"
// Retrieval info: PRIVATE: SYNTH_WRAPPER_GEN_POSTFIX STRING "0"
// Retrieval info: PRIVATE: UseTFFdataPort NUMERIC "0"
// Retrieval info: PRIVATE: nBit NUMERIC "1"
// Retrieval info: CONSTANT: LPM_FFTYPE STRING "DFF"
// Retrieval info: CONSTANT: LPM_TYPE STRING "LPM_FF"
// Retrieval info: CONSTANT: LPM_WIDTH NUMERIC "1"
// Retrieval info: USED_PORT: aclr 0 0 0 0 INPUT NODEFVAL aclr
// Retrieval info: USED_PORT: aset 0 0 0 0 INPUT NODEFVAL aset
// Retrieval info: USED_PORT: clock 0 0 0 0 INPUT NODEFVAL clock
// Retrieval info: USED_PORT: data 0 0 0 0 INPUT NODEFVAL data
// Retrieval info: USED_PORT: q 0 0 0 0 OUTPUT NODEFVAL q
// Retrieval info: CONNECT: @clock 0 0 0 0 clock 0 0 0 0
// Retrieval info: CONNECT: q 0 0 0 0 @q 0 0 1 0
// Retrieval info: CONNECT: @aclr 0 0 0 0 aclr 0 0 0 0
// Retrieval info: CONNECT: @aset 0 0 0 0 aset 0 0 0 0
// Retrieval info: CONNECT: @data 0 0 1 0 data 0 0 0 0
// Retrieval info: LIBRARY: lpm lpm.lpm_components.all
// Retrieval info: GEN_FILE: TYPE_NORMAL dff_sr.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL dff_sr.inc FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL dff_sr.cmp FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL dff_sr.bsf FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL dff_sr_inst.v FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL dff_sr_bb.v FALSE
// Retrieval info: LIB_FILE: lpm
`endif

`else

`ifdef DFF_SR
`define MODULE dff_sr
module `BASE`MODULE ( aclr, aset, clock, data, q);
`undef MODULE

    input	  aclr;
    input	  aset;
    input	  clock;
    input	  data;
    output reg	  q;

   always @ (posedge clock or posedge aclr or posedge aset)
     if (aclr)
       q <= 1'b0;
     else if (aset)
       q <= 1'b1;
     else
       q <= data;

endmodule
`endif

`endif

// LATCH
// For targtes not supporting LATCH use dff_sr with clk=1 and data=1
`ifdef ALTERA

`ifdef LATCH
`define MODULE latch
module `BASE`MODULE ( d, le, q, clk);
`undef MODULE
input d, le;
output q;
input clk;
dff_sr i0 (.aclr(), .aset(), .clock(1'b1), .data(1'b1), .q(q));
endmodule
`endif

`else

`ifdef LATCH
`define MODULE latch
module `BASE`MODULE ( d, le, q, clk);
`undef MODULE
input d, le;
input clk;
always @ (le or d)
if (le)
    d <= q;
endmodule
`endif

`endif

`ifdef SHREG
`define MODULE shreg
module `BASE`MODULE ( d, q, clk, rst);
`undef MODULE

parameter depth = 10;
input d;
output q;
input clk, rst;

reg [1:depth] dffs;

always @ (posedge clk or posedge rst)
if (rst)
    dffs <= {depth{1'b0}};
else
    dffs <= {d,dffs[1:depth-1]};
assign q = dffs[depth];
endmodule
`endif

`ifdef SHREG_CE
`define MODULE shreg_ce
module `BASE`MODULE ( d, ce, q, clk, rst);
`undef MODULE
parameter depth = 10;
input d, ce;
output q;
input clk, rst;

reg [1:depth] dffs;

always @ (posedge clk or posedge rst)
if (rst)
    dffs <= {depth{1'b0}};
else
    if (ce)
        dffs <= {d,dffs[1:depth-1]};
assign q = dffs[depth];
endmodule
`endif

`ifdef DELAY
`define MODULE delay
module `BASE`MODULE ( d, q, clk, rst);
`undef MODULE
parameter depth = 10;
input d;
output q;
input clk, rst;

reg [1:depth] dffs;

always @ (posedge clk or posedge rst)
if (rst)
    dffs <= {depth{1'b0}};
else
    dffs <= {d,dffs[1:depth-1]};
assign q = dffs[depth];
endmodule
`endif

`ifdef DELAY_EMPTYFLAG
`define MODULE delay_emptyflag
module `BASE`MODULE ( d, q, emptyflag, clk, rst);
`undef MODULE
parameter depth = 10;
input d;
output q, emptyflag;
input clk, rst;

reg [1:depth] dffs;

always @ (posedge clk or posedge rst)
if (rst)
    dffs <= {depth{1'b0}};
else
    dffs <= {d,dffs[1:depth-1]};
assign q = dffs[depth];
assign emptyflag = !(|dffs);
endmodule
`endif

`ifdef PULSE2TOGGLE
`define MODULE pulse2toggle
module `BASE`MODULE ( pl, q, clk, rst);
`undef MODULE
input pl;
output reg q;
input clk, rst;
always @ (posedge clk or posedge rst)
if (rst)
    q <= 1'b0;
else
    q <= pl ^ q;
endmodule
`endif

`ifdef TOGGLE2PULSE
`define MODULE toggle2pulse
module `BASE`MODULE (d, pl, clk, rst);
`undef MODULE
input d;
output pl;
input clk, rst;
reg dff;
always @ (posedge clk or posedge rst)
if (rst)
    dff <= 1'b0;
else
    dff <= d;
assign pl = d ^ dff;
endmodule
`endif

`ifdef SYNCHRONIZER
`define MODULE synchronizer
module `BASE`MODULE (d, q, clk, rst);
`undef MODULE
input d;
output reg q;
input clk, rst;
reg dff;
always @ (posedge clk or posedge rst)
if (rst)
    {q,dff} <= 2'b00;
else
    {q,dff} <= {dff,d};
endmodule
`endif

`ifdef CDC
`define MODULE cdc
module `BASE`MODULE ( start_pl, take_it_pl, take_it_grant_pl, got_it_pl, clk_src, rst_src, clk_dst, rst_dst);
`undef MODULE
input start_pl;
output take_it_pl;
input take_it_grant_pl; // note: connect to take_it_pl to generate automatic ack
output got_it_pl;
input clk_src, rst_src;
input clk_dst, rst_dst;
wire take_it_tg, take_it_tg_sync;
wire got_it_tg, got_it_tg_sync;
// src -> dst
`define MODULE pulse2toggle
`BASE`MODULE p2t0 (
`undef MODULE
    .pl(start_pl),
    .q(take_it_tg),
    .clk(clk_src),
    .rst(rst_src));

`define MODULE synchronizer
`BASE`MODULE sync0 (
`undef MODULE
    .d(take_it_tg),
    .q(take_it_tg_sync),
    .clk(clk_dst),
    .rst(rst_dst));
    
`define MODULE toggle2pulse
`BASE`MODULE t2p0 (
`undef MODULE
    .d(take_it_tg_sync),
    .pl(take_it_pl),
    .clk(clk_dst),
    .rst(rst_dst));

// dst -> src
`define MODULE pulse2toggle
`BASE`MODULE p2t1 (
`undef MODULE
    .pl(take_it_grant_pl),
    .q(got_it_tg),
    .clk(clk_dst),
    .rst(rst_dst));

`define MODULE synchronizer
`BASE`MODULE sync1 (
`undef MODULE
    .d(got_it_tg),
    .q(got_it_tg_sync),
    .clk(clk_src),
    .rst(rst_src));

`define MODULE toggle2pulse
`BASE`MODULE t2p1 (
`undef MODULE
    .d(got_it_tg_sync),
    .pl(got_it_pl),
    .clk(clk_src),
    .rst(rst_src));

endmodule
`endif
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Logic functions                                             ////
////                                                              ////
////  Description                                                 ////
////  Logic functions such as multiplexers                        ////
////                                                              ////
////                                                              ////
////  To Do:                                                      ////
////   -                                                          ////
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
`ifdef MUX_ANDOR
`define MODULE mux_andor
module `BASE`MODULE ( a, sel, dout);
`undef MODULE

parameter width = 32;
parameter nr_of_ports = 4;

input [nr_of_ports*width-1:0] a;
input [nr_of_ports-1:0] sel;
output reg [width-1:0] dout;

integer i,j;

always @ (a, sel)
begin
    dout = a[width-1:0] & {width{sel[0]}};
    for (i=1;i<nr_of_ports;i=i+1)
        for (j=0;j<width;j=j+1)
            dout[j] = (a[i*width + j] & sel[i]) | dout[j];
end

endmodule
`endif

`ifdef MUX2_ANDOR
`define MODULE mux2_andor
module `BASE`MODULE ( a1, a0, sel, dout);
`undef MODULE

parameter width = 32;
localparam nr_of_ports = 2;
input [width-1:0] a1, a0;
input [nr_of_ports-1:0] sel;
output [width-1:0] dout;

`define MODULE mux_andor
`BASE`MODULE
    # ( .width(width), .nr_of_ports(nr_of_ports))
    mux0( .a({a1,a0}), .sel(sel), .dout(dout));
`undef MODULE

endmodule
`endif

`ifdef MUX3_ANDOR
`define MODULE mux3_andor
module `BASE`MODULE ( a2, a1, a0, sel, dout);
`undef MODULE

parameter width = 32;
localparam nr_of_ports = 3;
input [width-1:0] a2, a1, a0;
input [nr_of_ports-1:0] sel;
output [width-1:0] dout;

`define MODULE mux_andor
`BASE`MODULE
    # ( .width(width), .nr_of_ports(nr_of_ports))
    mux0( .a({a2,a1,a0}), .sel(sel), .dout(dout));
`undef MODULE    
endmodule
`endif

`ifdef MUX4_ANDOR
`define MODULE mux4_andor
module `BASE`MODULE ( a3, a2, a1, a0, sel, dout);
`undef MODULE

parameter width = 32;
localparam nr_of_ports = 4;
input [width-1:0] a3, a2, a1, a0;
input [nr_of_ports-1:0] sel;
output [width-1:0] dout;

`define MODULE mux_andor
`BASE`MODULE
    # ( .width(width), .nr_of_ports(nr_of_ports))
    mux0( .a({a3,a2,a1,a0}), .sel(sel), .dout(dout));
`undef MODULE

endmodule
`endif

`ifdef MUX5_ANDOR
`define MODULE mux5_andor
module `BASE`MODULE ( a4, a3, a2, a1, a0, sel, dout);
`undef MODULE

parameter width = 32;
localparam nr_of_ports = 5;
input [width-1:0] a4, a3, a2, a1, a0;
input [nr_of_ports-1:0] sel;
output [width-1:0] dout;

`define MODULE mux_andor
`BASE`MODULE
    # ( .width(width), .nr_of_ports(nr_of_ports))
    mux0( .a({a4,a3,a2,a1,a0}), .sel(sel), .dout(dout));
`undef MODULE

endmodule
`endif

`ifdef MUX6_ANDOR
`define MODULE mux6_andor
module `BASE`MODULE ( a5, a4, a3, a2, a1, a0, sel, dout);
`undef MODULE

parameter width = 32;
localparam nr_of_ports = 6;
input [width-1:0] a5, a4, a3, a2, a1, a0;
input [nr_of_ports-1:0] sel;
output [width-1:0] dout;

`define MODULE mux_andor
`BASE`MODULE
    # ( .width(width), .nr_of_ports(nr_of_ports))
    mux0( .a({a5,a4,a3,a2,a1,a0}), .sel(sel), .dout(dout));
`undef MODULE

endmodule
`endif

`ifdef PARITY

`define MODULE parity_generate
module `BASE`MODULE (data, parity);
`undef MODULE
parameter word_size = 32;
parameter chunk_size = 8;
parameter parity_type = 1'b0; // 0 - even, 1 - odd parity
input [word_size-1:0] data;
output reg [word_size/chunk_size-1:0] parity;
integer i,j;
always @ (data)
for (i=0;i<word_size/chunk_size;i=i+1) begin
    parity[i] = parity_type;
    for (j=0;j<chunk_size;j=j+1) begin
        parity[i] = data[i*chunk_size+j] ^ parity[i];
    end
end
endmodule

`define MODULE parity_check
module `BASE`MODULE( data, parity, parity_error);
`undef MODULE
parameter word_size = 32;
parameter chunk_size = 8;
parameter parity_type = 1'b0; // 0 - even, 1 - odd parity
input [word_size-1:0] data;
input [word_size/chunk_size-1:0] parity;
output parity_error;
reg [word_size/chunk_size-1:0] error_flag;
integer i,j;
always @ (data or parity)
for (i=0;i<word_size/chunk_size;i=i+1) begin
    error_flag[i] = parity[i] ^ parity_type;
    for (j=0;j<chunk_size;j=j+1) begin
        error_flag[i] = data[i*chunk_size+j] ^ error_flag[i];
    end
end
assign parity_error = |error_flag;
endmodule

`endif//////////////////////////////////////////////////////////////////////
////                                                              ////
////  IO functions                                                ////
////                                                              ////
////  Description                                                 ////
////  IO functions such as IOB flip-flops                         ////
////                                                              ////
////                                                              ////
////  To Do:                                                      ////
////   -                                                          ////
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
`ifdef O_DFF
`timescale 1ns/1ns
`define MODULE o_dff
module `BASE`MODULE (d_i, o_pad, clk, rst);
`undef MODULE
parameter width = 1;
parameter reset_value = {width{1'b0}};
input  [width-1:0]  d_i;
output [width-1:0] o_pad;
input clk, rst;
wire [width-1:0] d_i_int `SYN_KEEP;
reg  [width-1:0] o_pad_int;
assign d_i_int = d_i;
genvar i;
generate
for (i=0;i<width;i=i+1) begin : dffs
    always @ (posedge clk or posedge rst)
    if (rst)
        o_pad_int[i] <= reset_value[i];
    else
        o_pad_int[i] <= d_i_int[i];
    assign #1 o_pad[i] = o_pad_int[i];
end
endgenerate
endmodule
`endif

`ifdef IO_DFF_OE
`timescale 1ns/1ns
`define MODULE io_dff_oe
module `BASE`MODULE ( d_i, d_o, oe, io_pad, clk, rst);
`undef MODULE
parameter width = 1;
parameter reset_value = 1'b0;
input  [width-1:0] d_o;
output reg [width-1:0] d_i;
input oe;
inout [width-1:0] io_pad;
input clk, rst;
wire [width-1:0] oe_d `SYN_KEEP;
reg [width-1:0] oe_q;
reg [width-1:0] d_o_q;
assign oe_d = {width{oe}};
genvar i;
generate
for (i=0;i<width;i=i+1) begin : dffs
    always @ (posedge clk or posedge rst)
    if (rst)
        oe_q[i] <= 1'b0;
    else
        oe_q[i] <= oe_d[i];
    always @ (posedge clk or posedge rst)
    if (rst)
        d_o_q[i] <= reset_value;
    else
        d_o_q[i] <= d_o[i];
    always @ (posedge clk or posedge rst)
    if (rst)
        d_i[i] <= reset_value;
    else
        d_i[i] <= io_pad[i];
    assign #1 io_pad[i] = (oe_q[i]) ? d_o_q[i] : 1'bz;
end
endgenerate
endmodule
`endif

`ifdef O_DDR
`ifdef ALTERA
`define MODULE o_ddr
module `BASE`MODULE (d_h_i, d_l_i, o_pad, clk, rst);
`undef MODULE
parameter width = 1;
input  [width-1:0] d_h_i, d_l_i;
output [width-1:0] o_pad;
input clk, rst;
genvar i;
generate
for (i=0;i<width;i=i+1) begin : ddr
    ddio_out ddio_out0( .aclr(rst), .datain_h(d_h_i[i]), .datain_l(d_l_i[i]), .outclock(clk), .dataout(o_pad[i]) );
end
endgenerate
endmodule
`else
`define MODULE o_ddr
module `BASE`MODULE (d_h_i, d_l_i, o_pad, clk, rst);
`undef MODULE
parameter width = 1;
input  [width-1:0] d_h_i, d_l_i;
output [width-1:0] o_pad;
input clk, rst;
reg [width-1:0] ff1;
reg [width-1:0] ff2;
genvar i;
generate
for (i=0;i<width;i=i+1) begin : ddr
    always @ (posedge clk or posedge rst)
    if (rst)
        ff1[i] <= 1'b0;
    else
        ff1[i] <= d_h_i[i];
    always @ (posedge clk or posedge rst)
    if (rst)
        ff2[i] <= 1'b0;
    else
        ff2[i] <= d_l_i[i];
    assign o_pad = (clk) ? ff1 : ff2;
end
endgenerate
endmodule
`endif
`endif

`ifdef O_CLK
`define MODULE o_clk
module `BASE`MODULE ( clk_o_pad, clk, rst);
`undef MODULE
input clk, rst;
output clk_o_pad;
`define MODULE o_ddr
`BASE`MODULE o_ddr0( .d_h_i(1'b1), .d_l_i(1'b0), .o_pad(clk_o_pad), .clk(clk), .rst(rst));
`undef MODULE
endmodule
`endif`ifdef CNT_BIN
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Versatile counter                                           ////
////                                                              ////
////  Description                                                 ////
////  Versatile counter, a reconfigurable binary, gray or LFSR    ////
////  counter                                                     ////
////                                                              ////
////  To Do:                                                      ////
////   - add LFSR with more taps                                  ////
////                                                              ////
////  Author(s):                                                  ////
////      - Michael Unneback, unneback@opencores.org              ////
////        ORSoC AB                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 Authors and OPENCORES.ORG                 ////
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

// binary counter

`define MODULE cnt_bin
module `BASE`MODULE (
`undef MODULE
 q, rst, clk);

   parameter length = 4;
   output [length:1] q;
   input rst;
   input clk;

   parameter clear_value = 0;
   parameter set_value = 1;
   parameter wrap_value = 0;
   parameter level1_value = 15;

   reg  [length:1] qi;
   wire [length:1] q_next;
   assign q_next = qi + {{length-1{1'b0}},1'b1};

   always @ (posedge clk or posedge rst)
     if (rst)
       qi <= {length{1'b0}};
     else
       qi <= q_next;

   assign q = qi;

endmodule
`endif
`ifdef CNT_BIN_CLEAR
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Versatile counter                                           ////
////                                                              ////
////  Description                                                 ////
////  Versatile counter, a reconfigurable binary, gray or LFSR    ////
////  counter                                                     ////
////                                                              ////
////  To Do:                                                      ////
////   - add LFSR with more taps                                  ////
////                                                              ////
////  Author(s):                                                  ////
////      - Michael Unneback, unneback@opencores.org              ////
////        ORSoC AB                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 Authors and OPENCORES.ORG                 ////
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

// binary counter

`define MODULE cnt_bin_clear
module `BASE`MODULE (
`undef MODULE
 clear, q, rst, clk);

   parameter length = 4;
   input clear;
   output [length:1] q;
   input rst;
   input clk;

   parameter clear_value = 0;
   parameter set_value = 1;
   parameter wrap_value = 0;
   parameter level1_value = 15;

   reg  [length:1] qi;
   wire [length:1] q_next;
   assign q_next =  clear ? {length{1'b0}} :qi + {{length-1{1'b0}},1'b1};

   always @ (posedge clk or posedge rst)
     if (rst)
       qi <= {length{1'b0}};
     else
       qi <= q_next;

   assign q = qi;

endmodule
`endif
`ifdef CNT_BIN_CE
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Versatile counter                                           ////
////                                                              ////
////  Description                                                 ////
////  Versatile counter, a reconfigurable binary, gray or LFSR    ////
////  counter                                                     ////
////                                                              ////
////  To Do:                                                      ////
////   - add LFSR with more taps                                  ////
////                                                              ////
////  Author(s):                                                  ////
////      - Michael Unneback, unneback@opencores.org              ////
////        ORSoC AB                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 Authors and OPENCORES.ORG                 ////
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

// binary counter

`define MODULE cnt_bin_ce
module `BASE`MODULE (
`undef MODULE
 cke, q, rst, clk);

   parameter length = 4;
   input cke;
   output [length:1] q;
   input rst;
   input clk;

   parameter clear_value = 0;
   parameter set_value = 1;
   parameter wrap_value = 0;
   parameter level1_value = 15;

   reg  [length:1] qi;
   wire [length:1] q_next;
   assign q_next = qi + {{length-1{1'b0}},1'b1};

   always @ (posedge clk or posedge rst)
     if (rst)
       qi <= {length{1'b0}};
     else
     if (cke)
       qi <= q_next;

   assign q = qi;

endmodule
`endif
`ifdef CNT_BIN_CE_CLEAR
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Versatile counter                                           ////
////                                                              ////
////  Description                                                 ////
////  Versatile counter, a reconfigurable binary, gray or LFSR    ////
////  counter                                                     ////
////                                                              ////
////  To Do:                                                      ////
////   - add LFSR with more taps                                  ////
////                                                              ////
////  Author(s):                                                  ////
////      - Michael Unneback, unneback@opencores.org              ////
////        ORSoC AB                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 Authors and OPENCORES.ORG                 ////
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

// binary counter

`define MODULE cnt_bin_ce_clear
module `BASE`MODULE (
`undef MODULE
 clear, cke, q, rst, clk);

   parameter length = 4;
   input clear;
   input cke;
   output [length:1] q;
   input rst;
   input clk;

   parameter clear_value = 0;
   parameter set_value = 1;
   parameter wrap_value = 0;
   parameter level1_value = 15;

   reg  [length:1] qi;
   wire [length:1] q_next;
   assign q_next =  clear ? {length{1'b0}} :qi + {{length-1{1'b0}},1'b1};

   always @ (posedge clk or posedge rst)
     if (rst)
       qi <= {length{1'b0}};
     else
     if (cke)
       qi <= q_next;

   assign q = qi;

endmodule
`endif
`ifdef CNT_BIN_CE_CLEAR_L1_L2
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Versatile counter                                           ////
////                                                              ////
////  Description                                                 ////
////  Versatile counter, a reconfigurable binary, gray or LFSR    ////
////  counter                                                     ////
////                                                              ////
////  To Do:                                                      ////
////   - add LFSR with more taps                                  ////
////                                                              ////
////  Author(s):                                                  ////
////      - Michael Unneback, unneback@opencores.org              ////
////        ORSoC AB                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 Authors and OPENCORES.ORG                 ////
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

// binary counter

`define MODULE cnt_bin_ce_clear_l1_l2
module `BASE`MODULE (
`undef MODULE
 clear, cke, q, level1, level2, rst, clk);

   parameter length = 4;
   input clear;
   input cke;
   output [length:1] q;
   output reg level1;
   output reg level2;
   input rst;
   input clk;

   parameter clear_value = 0;
   parameter set_value = 1;
   parameter wrap_value = 15;
   parameter level1_value = 8;
   parameter level2_value = 15;

   wire rew;
   assign rew = 1'b0;
   reg  [length:1] qi;
   wire [length:1] q_next;
   assign q_next =  clear ? {length{1'b0}} :qi + {{length-1{1'b0}},1'b1};

   always @ (posedge clk or posedge rst)
     if (rst)
       qi <= {length{1'b0}};
     else
     if (cke)
       qi <= q_next;

   assign q = qi;


    always @ (posedge clk or posedge rst)
    if (rst)
        level1 <= 1'b0;
    else
    if (cke)
    if (clear)
        level1 <= 1'b0;
    else if (q_next == level1_value)
        level1 <= 1'b1;
    else if (qi == level1_value & rew)
        level1 <= 1'b0;

    always @ (posedge clk or posedge rst)
    if (rst)
        level2 <= 1'b0;
    else
    if (cke)
    if (clear)
        level2 <= 1'b0;
    else if (q_next == level2_value)
        level2 <= 1'b1;
    else if (qi == level2_value & rew)
        level2 <= 1'b0;
endmodule
`endif
`ifdef CNT_BIN_CE_CLEAR_SET_REW
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Versatile counter                                           ////
////                                                              ////
////  Description                                                 ////
////  Versatile counter, a reconfigurable binary, gray or LFSR    ////
////  counter                                                     ////
////                                                              ////
////  To Do:                                                      ////
////   - add LFSR with more taps                                  ////
////                                                              ////
////  Author(s):                                                  ////
////      - Michael Unneback, unneback@opencores.org              ////
////        ORSoC AB                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 Authors and OPENCORES.ORG                 ////
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

// binary counter

`define MODULE cnt_bin_ce_clear_set_rew
module `BASE`MODULE (
`undef MODULE
 clear, set, cke, rew, q, rst, clk);

   parameter length = 4;
   input clear;
   input set;
   input cke;
   input rew;
   output [length:1] q;
   input rst;
   input clk;

   parameter clear_value = 0;
   parameter set_value = 1;
   parameter wrap_value = 0;
   parameter level1_value = 15;

   reg  [length:1] qi;
   wire  [length:1] q_next, q_next_fw, q_next_rew;
   assign q_next_fw  =  clear ? {length{1'b0}} : set ? set_value :qi + {{length-1{1'b0}},1'b1};
   assign q_next_rew =  clear ? clear_value : set ? set_value :qi - {{length-1{1'b0}},1'b1};
   assign q_next = rew ? q_next_rew : q_next_fw;

   always @ (posedge clk or posedge rst)
     if (rst)
       qi <= {length{1'b0}};
     else
     if (cke)
       qi <= q_next;

   assign q = qi;

endmodule
`endif
`ifdef CNT_BIN_CE_REW_L1
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Versatile counter                                           ////
////                                                              ////
////  Description                                                 ////
////  Versatile counter, a reconfigurable binary, gray or LFSR    ////
////  counter                                                     ////
////                                                              ////
////  To Do:                                                      ////
////   - add LFSR with more taps                                  ////
////                                                              ////
////  Author(s):                                                  ////
////      - Michael Unneback, unneback@opencores.org              ////
////        ORSoC AB                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 Authors and OPENCORES.ORG                 ////
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

// binary counter

`define MODULE cnt_bin_ce_rew_l1
module `BASE`MODULE (
`undef MODULE
 cke, rew, level1, rst, clk);

   parameter length = 4;
   input cke;
   input rew;
   output reg level1;
   input rst;
   input clk;

   parameter clear_value = 0;
   parameter set_value = 1;
   parameter wrap_value = 1;
   parameter level1_value = 15;

   wire clear;
   assign clear = 1'b0;
   reg  [length:1] qi;
   wire  [length:1] q_next, q_next_fw, q_next_rew;
   assign q_next_fw  = qi + {{length-1{1'b0}},1'b1};
   assign q_next_rew = qi - {{length-1{1'b0}},1'b1};
   assign q_next = rew ? q_next_rew : q_next_fw;

   always @ (posedge clk or posedge rst)
     if (rst)
       qi <= {length{1'b0}};
     else
     if (cke)
       qi <= q_next;



    always @ (posedge clk or posedge rst)
    if (rst)
        level1 <= 1'b0;
    else
    if (cke)
    if (clear)
        level1 <= 1'b0;
    else if (q_next == level1_value)
        level1 <= 1'b1;
    else if (qi == level1_value & rew)
        level1 <= 1'b0;
endmodule
`endif
`ifdef CNT_BIN_CE_REW_ZQ_L1
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Versatile counter                                           ////
////                                                              ////
////  Description                                                 ////
////  Versatile counter, a reconfigurable binary, gray or LFSR    ////
////  counter                                                     ////
////                                                              ////
////  To Do:                                                      ////
////   - add LFSR with more taps                                  ////
////                                                              ////
////  Author(s):                                                  ////
////      - Michael Unneback, unneback@opencores.org              ////
////        ORSoC AB                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 Authors and OPENCORES.ORG                 ////
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

// binary counter

`define MODULE cnt_bin_ce_rew_zq_l1
module `BASE`MODULE (
`undef MODULE
 cke, rew, zq, level1, rst, clk);

   parameter length = 4;
   input cke;
   input rew;
   output reg zq;
   output reg level1;
   input rst;
   input clk;

   parameter clear_value = 0;
   parameter set_value = 1;
   parameter wrap_value = 1;
   parameter level1_value = 15;

   wire clear;
   assign clear = 1'b0;
   reg  [length:1] qi;
   wire  [length:1] q_next, q_next_fw, q_next_rew;
   assign q_next_fw  = qi + {{length-1{1'b0}},1'b1};
   assign q_next_rew = qi - {{length-1{1'b0}},1'b1};
   assign q_next = rew ? q_next_rew : q_next_fw;

   always @ (posedge clk or posedge rst)
     if (rst)
       qi <= {length{1'b0}};
     else
     if (cke)
       qi <= q_next;



   always @ (posedge clk or posedge rst)
     if (rst)
       zq <= 1'b1;
     else
     if (cke)
       zq <= q_next == {length{1'b0}};

    always @ (posedge clk or posedge rst)
    if (rst)
        level1 <= 1'b0;
    else
    if (cke)
    if (clear)
        level1 <= 1'b0;
    else if (q_next == level1_value)
        level1 <= 1'b1;
    else if (qi == level1_value & rew)
        level1 <= 1'b0;
endmodule
`endif
`ifdef CNT_BIN_CE_REW_Q_ZQ_L1
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Versatile counter                                           ////
////                                                              ////
////  Description                                                 ////
////  Versatile counter, a reconfigurable binary, gray or LFSR    ////
////  counter                                                     ////
////                                                              ////
////  To Do:                                                      ////
////   - add LFSR with more taps                                  ////
////                                                              ////
////  Author(s):                                                  ////
////      - Michael Unneback, unneback@opencores.org              ////
////        ORSoC AB                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 Authors and OPENCORES.ORG                 ////
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

// binary counter

`define MODULE cnt_bin_ce_rew_q_zq_l1
module `BASE`MODULE (
`undef MODULE
 cke, rew, q, zq, level1, rst, clk);

   parameter length = 4;
   input cke;
   input rew;
   output [length:1] q;
   output reg zq;
   output reg level1;
   input rst;
   input clk;

   parameter clear_value = 0;
   parameter set_value = 1;
   parameter wrap_value = 1;
   parameter level1_value = 15;

   wire clear;
   assign clear = 1'b0;
   reg  [length:1] qi;
   wire  [length:1] q_next, q_next_fw, q_next_rew;
   assign q_next_fw  = qi + {{length-1{1'b0}},1'b1};
   assign q_next_rew = qi - {{length-1{1'b0}},1'b1};
   assign q_next = rew ? q_next_rew : q_next_fw;

   always @ (posedge clk or posedge rst)
     if (rst)
       qi <= {length{1'b0}};
     else
     if (cke)
       qi <= q_next;

   assign q = qi;


   always @ (posedge clk or posedge rst)
     if (rst)
       zq <= 1'b1;
     else
     if (cke)
       zq <= q_next == {length{1'b0}};

    always @ (posedge clk or posedge rst)
    if (rst)
        level1 <= 1'b0;
    else
    if (cke)
    if (clear)
        level1 <= 1'b0;
    else if (q_next == level1_value)
        level1 <= 1'b1;
    else if (qi == level1_value & rew)
        level1 <= 1'b0;
endmodule
`endif
`ifdef CNT_LFSR_ZQ
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Versatile counter                                           ////
////                                                              ////
////  Description                                                 ////
////  Versatile counter, a reconfigurable binary, gray or LFSR    ////
////  counter                                                     ////
////                                                              ////
////  To Do:                                                      ////
////   - add LFSR with more taps                                  ////
////                                                              ////
////  Author(s):                                                  ////
////      - Michael Unneback, unneback@opencores.org              ////
////        ORSoC AB                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 Authors and OPENCORES.ORG                 ////
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

// LFSR counter

`define MODULE cnt_lfsr_zq
module `BASE`MODULE (
`undef MODULE
 zq, rst, clk);

   parameter length = 4;
   output reg zq;
   input rst;
   input clk;

   parameter clear_value = 0;
   parameter set_value = 1;
   parameter wrap_value = 8;
   parameter level1_value = 15;

   reg  [length:1] qi;
   reg lfsr_fb;
   wire [length:1] q_next;
   reg [32:1] polynom;
   integer i;

   always @ (qi)
   begin
        case (length) 
         2: polynom = 32'b11;                               // 0x3
         3: polynom = 32'b110;                              // 0x6
         4: polynom = 32'b1100;                             // 0xC
         5: polynom = 32'b10100;                            // 0x14
         6: polynom = 32'b110000;                           // 0x30
         7: polynom = 32'b1100000;                          // 0x60
         8: polynom = 32'b10111000;                         // 0xb8
         9: polynom = 32'b100010000;                        // 0x110
        10: polynom = 32'b1001000000;                       // 0x240
        11: polynom = 32'b10100000000;                      // 0x500
        12: polynom = 32'b100000101001;                     // 0x829
        13: polynom = 32'b1000000001100;                    // 0x100C
        14: polynom = 32'b10000000010101;                   // 0x2015
        15: polynom = 32'b110000000000000;                  // 0x6000
        16: polynom = 32'b1101000000001000;                 // 0xD008
        17: polynom = 32'b10010000000000000;                // 0x12000
        18: polynom = 32'b100000010000000000;               // 0x20400
        19: polynom = 32'b1000000000000100011;              // 0x40023
        20: polynom = 32'b10010000000000000000;             // 0x90000
        21: polynom = 32'b101000000000000000000;            // 0x140000
        22: polynom = 32'b1100000000000000000000;           // 0x300000
        23: polynom = 32'b10000100000000000000000;          // 0x420000
        24: polynom = 32'b111000010000000000000000;         // 0xE10000
        25: polynom = 32'b1001000000000000000000000;        // 0x1200000
        26: polynom = 32'b10000000000000000000100011;       // 0x2000023
        27: polynom = 32'b100000000000000000000010011;      // 0x4000013
        28: polynom = 32'b1100100000000000000000000000;     // 0xC800000
        29: polynom = 32'b10100000000000000000000000000;    // 0x14000000
        30: polynom = 32'b100000000000000000000000101001;   // 0x20000029
        31: polynom = 32'b1001000000000000000000000000000;  // 0x48000000
        32: polynom = 32'b10000000001000000000000000000011; // 0x80200003
        default: polynom = 32'b0;
        endcase
        lfsr_fb = qi[length];
        for (i=length-1; i>=1; i=i-1) begin
            if (polynom[i])
                lfsr_fb = lfsr_fb  ~^ qi[i];
        end
    end
   assign q_next = (qi == wrap_value) ? {length{1'b0}} :{qi[length-1:1],lfsr_fb};

   always @ (posedge clk or posedge rst)
     if (rst)
       qi <= {length{1'b0}};
     else
       qi <= q_next;



   always @ (posedge clk or posedge rst)
     if (rst)
       zq <= 1'b1;
     else
       zq <= q_next == {length{1'b0}};
endmodule
`endif
`ifdef CNT_LFSR_CE
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Versatile counter                                           ////
////                                                              ////
////  Description                                                 ////
////  Versatile counter, a reconfigurable binary, gray or LFSR    ////
////  counter                                                     ////
////                                                              ////
////  To Do:                                                      ////
////   - add LFSR with more taps                                  ////
////                                                              ////
////  Author(s):                                                  ////
////      - Michael Unneback, unneback@opencores.org              ////
////        ORSoC AB                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 Authors and OPENCORES.ORG                 ////
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

// LFSR counter

`define MODULE cnt_lfsr_ce
module `BASE`MODULE (
`undef MODULE
 cke, zq, rst, clk);

   parameter length = 4;
   input cke;
   output reg zq;
   input rst;
   input clk;

   parameter clear_value = 0;
   parameter set_value = 1;
   parameter wrap_value = 0;
   parameter level1_value = 15;

   reg  [length:1] qi;
   reg lfsr_fb;
   wire [length:1] q_next;
   reg [32:1] polynom;
   integer i;

   always @ (qi)
   begin
        case (length) 
         2: polynom = 32'b11;                               // 0x3
         3: polynom = 32'b110;                              // 0x6
         4: polynom = 32'b1100;                             // 0xC
         5: polynom = 32'b10100;                            // 0x14
         6: polynom = 32'b110000;                           // 0x30
         7: polynom = 32'b1100000;                          // 0x60
         8: polynom = 32'b10111000;                         // 0xb8
         9: polynom = 32'b100010000;                        // 0x110
        10: polynom = 32'b1001000000;                       // 0x240
        11: polynom = 32'b10100000000;                      // 0x500
        12: polynom = 32'b100000101001;                     // 0x829
        13: polynom = 32'b1000000001100;                    // 0x100C
        14: polynom = 32'b10000000010101;                   // 0x2015
        15: polynom = 32'b110000000000000;                  // 0x6000
        16: polynom = 32'b1101000000001000;                 // 0xD008
        17: polynom = 32'b10010000000000000;                // 0x12000
        18: polynom = 32'b100000010000000000;               // 0x20400
        19: polynom = 32'b1000000000000100011;              // 0x40023
        20: polynom = 32'b10010000000000000000;             // 0x90000
        21: polynom = 32'b101000000000000000000;            // 0x140000
        22: polynom = 32'b1100000000000000000000;           // 0x300000
        23: polynom = 32'b10000100000000000000000;          // 0x420000
        24: polynom = 32'b111000010000000000000000;         // 0xE10000
        25: polynom = 32'b1001000000000000000000000;        // 0x1200000
        26: polynom = 32'b10000000000000000000100011;       // 0x2000023
        27: polynom = 32'b100000000000000000000010011;      // 0x4000013
        28: polynom = 32'b1100100000000000000000000000;     // 0xC800000
        29: polynom = 32'b10100000000000000000000000000;    // 0x14000000
        30: polynom = 32'b100000000000000000000000101001;   // 0x20000029
        31: polynom = 32'b1001000000000000000000000000000;  // 0x48000000
        32: polynom = 32'b10000000001000000000000000000011; // 0x80200003
        default: polynom = 32'b0;
        endcase
        lfsr_fb = qi[length];
        for (i=length-1; i>=1; i=i-1) begin
            if (polynom[i])
                lfsr_fb = lfsr_fb  ~^ qi[i];
        end
    end
   assign q_next = (qi == wrap_value) ? {length{1'b0}} :{qi[length-1:1],lfsr_fb};

   always @ (posedge clk or posedge rst)
     if (rst)
       qi <= {length{1'b0}};
     else
     if (cke)
       qi <= q_next;



   always @ (posedge clk or posedge rst)
     if (rst)
       zq <= 1'b1;
     else
     if (cke)
       zq <= q_next == {length{1'b0}};
endmodule
`endif
`ifdef CNT_LFSR_CE_ZQ
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Versatile counter                                           ////
////                                                              ////
////  Description                                                 ////
////  Versatile counter, a reconfigurable binary, gray or LFSR    ////
////  counter                                                     ////
////                                                              ////
////  To Do:                                                      ////
////   - add LFSR with more taps                                  ////
////                                                              ////
////  Author(s):                                                  ////
////      - Michael Unneback, unneback@opencores.org              ////
////        ORSoC AB                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 Authors and OPENCORES.ORG                 ////
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

// LFSR counter

`define MODULE cnt_lfsr_ce_zq
module `BASE`MODULE (
`undef MODULE
 cke, zq, rst, clk);

   parameter length = 4;
   input cke;
   output reg zq;
   input rst;
   input clk;

   parameter clear_value = 0;
   parameter set_value = 1;
   parameter wrap_value = 8;
   parameter level1_value = 15;

   reg  [length:1] qi;
   reg lfsr_fb;
   wire [length:1] q_next;
   reg [32:1] polynom;
   integer i;

   always @ (qi)
   begin
        case (length) 
         2: polynom = 32'b11;                               // 0x3
         3: polynom = 32'b110;                              // 0x6
         4: polynom = 32'b1100;                             // 0xC
         5: polynom = 32'b10100;                            // 0x14
         6: polynom = 32'b110000;                           // 0x30
         7: polynom = 32'b1100000;                          // 0x60
         8: polynom = 32'b10111000;                         // 0xb8
         9: polynom = 32'b100010000;                        // 0x110
        10: polynom = 32'b1001000000;                       // 0x240
        11: polynom = 32'b10100000000;                      // 0x500
        12: polynom = 32'b100000101001;                     // 0x829
        13: polynom = 32'b1000000001100;                    // 0x100C
        14: polynom = 32'b10000000010101;                   // 0x2015
        15: polynom = 32'b110000000000000;                  // 0x6000
        16: polynom = 32'b1101000000001000;                 // 0xD008
        17: polynom = 32'b10010000000000000;                // 0x12000
        18: polynom = 32'b100000010000000000;               // 0x20400
        19: polynom = 32'b1000000000000100011;              // 0x40023
        20: polynom = 32'b10010000000000000000;             // 0x90000
        21: polynom = 32'b101000000000000000000;            // 0x140000
        22: polynom = 32'b1100000000000000000000;           // 0x300000
        23: polynom = 32'b10000100000000000000000;          // 0x420000
        24: polynom = 32'b111000010000000000000000;         // 0xE10000
        25: polynom = 32'b1001000000000000000000000;        // 0x1200000
        26: polynom = 32'b10000000000000000000100011;       // 0x2000023
        27: polynom = 32'b100000000000000000000010011;      // 0x4000013
        28: polynom = 32'b1100100000000000000000000000;     // 0xC800000
        29: polynom = 32'b10100000000000000000000000000;    // 0x14000000
        30: polynom = 32'b100000000000000000000000101001;   // 0x20000029
        31: polynom = 32'b1001000000000000000000000000000;  // 0x48000000
        32: polynom = 32'b10000000001000000000000000000011; // 0x80200003
        default: polynom = 32'b0;
        endcase
        lfsr_fb = qi[length];
        for (i=length-1; i>=1; i=i-1) begin
            if (polynom[i])
                lfsr_fb = lfsr_fb  ~^ qi[i];
        end
    end
   assign q_next = (qi == wrap_value) ? {length{1'b0}} :{qi[length-1:1],lfsr_fb};

   always @ (posedge clk or posedge rst)
     if (rst)
       qi <= {length{1'b0}};
     else
     if (cke)
       qi <= q_next;



   always @ (posedge clk or posedge rst)
     if (rst)
       zq <= 1'b1;
     else
     if (cke)
       zq <= q_next == {length{1'b0}};
endmodule
`endif
`ifdef CNT_LFSR_CE_Q
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Versatile counter                                           ////
////                                                              ////
////  Description                                                 ////
////  Versatile counter, a reconfigurable binary, gray or LFSR    ////
////  counter                                                     ////
////                                                              ////
////  To Do:                                                      ////
////   - add LFSR with more taps                                  ////
////                                                              ////
////  Author(s):                                                  ////
////      - Michael Unneback, unneback@opencores.org              ////
////        ORSoC AB                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 Authors and OPENCORES.ORG                 ////
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

// LFSR counter

`define MODULE cnt_lfsr_ce_q
module `BASE`MODULE (
`undef MODULE
 cke, q, rst, clk);

   parameter length = 4;
   input cke;
   output [length:1] q;
   input rst;
   input clk;

   parameter clear_value = 0;
   parameter set_value = 1;
   parameter wrap_value = 8;
   parameter level1_value = 15;

   reg  [length:1] qi;
   reg lfsr_fb;
   wire [length:1] q_next;
   reg [32:1] polynom;
   integer i;

   always @ (qi)
   begin
        case (length) 
         2: polynom = 32'b11;                               // 0x3
         3: polynom = 32'b110;                              // 0x6
         4: polynom = 32'b1100;                             // 0xC
         5: polynom = 32'b10100;                            // 0x14
         6: polynom = 32'b110000;                           // 0x30
         7: polynom = 32'b1100000;                          // 0x60
         8: polynom = 32'b10111000;                         // 0xb8
         9: polynom = 32'b100010000;                        // 0x110
        10: polynom = 32'b1001000000;                       // 0x240
        11: polynom = 32'b10100000000;                      // 0x500
        12: polynom = 32'b100000101001;                     // 0x829
        13: polynom = 32'b1000000001100;                    // 0x100C
        14: polynom = 32'b10000000010101;                   // 0x2015
        15: polynom = 32'b110000000000000;                  // 0x6000
        16: polynom = 32'b1101000000001000;                 // 0xD008
        17: polynom = 32'b10010000000000000;                // 0x12000
        18: polynom = 32'b100000010000000000;               // 0x20400
        19: polynom = 32'b1000000000000100011;              // 0x40023
        20: polynom = 32'b10010000000000000000;             // 0x90000
        21: polynom = 32'b101000000000000000000;            // 0x140000
        22: polynom = 32'b1100000000000000000000;           // 0x300000
        23: polynom = 32'b10000100000000000000000;          // 0x420000
        24: polynom = 32'b111000010000000000000000;         // 0xE10000
        25: polynom = 32'b1001000000000000000000000;        // 0x1200000
        26: polynom = 32'b10000000000000000000100011;       // 0x2000023
        27: polynom = 32'b100000000000000000000010011;      // 0x4000013
        28: polynom = 32'b1100100000000000000000000000;     // 0xC800000
        29: polynom = 32'b10100000000000000000000000000;    // 0x14000000
        30: polynom = 32'b100000000000000000000000101001;   // 0x20000029
        31: polynom = 32'b1001000000000000000000000000000;  // 0x48000000
        32: polynom = 32'b10000000001000000000000000000011; // 0x80200003
        default: polynom = 32'b0;
        endcase
        lfsr_fb = qi[length];
        for (i=length-1; i>=1; i=i-1) begin
            if (polynom[i])
                lfsr_fb = lfsr_fb  ~^ qi[i];
        end
    end
   assign q_next = (qi == wrap_value) ? {length{1'b0}} :{qi[length-1:1],lfsr_fb};

   always @ (posedge clk or posedge rst)
     if (rst)
       qi <= {length{1'b0}};
     else
     if (cke)
       qi <= q_next;

   assign q = qi;

endmodule
`endif
`ifdef CNT_LFSR_CE_CLEAR_Q
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Versatile counter                                           ////
////                                                              ////
////  Description                                                 ////
////  Versatile counter, a reconfigurable binary, gray or LFSR    ////
////  counter                                                     ////
////                                                              ////
////  To Do:                                                      ////
////   - add LFSR with more taps                                  ////
////                                                              ////
////  Author(s):                                                  ////
////      - Michael Unneback, unneback@opencores.org              ////
////        ORSoC AB                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 Authors and OPENCORES.ORG                 ////
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

// LFSR counter

`define MODULE cnt_lfsr_ce_clear_q
module `BASE`MODULE (
`undef MODULE
 clear, cke, q, rst, clk);

   parameter length = 4;
   input clear;
   input cke;
   output [length:1] q;
   input rst;
   input clk;

   parameter clear_value = 0;
   parameter set_value = 1;
   parameter wrap_value = 8;
   parameter level1_value = 15;

   reg  [length:1] qi;
   reg lfsr_fb;
   wire [length:1] q_next;
   reg [32:1] polynom;
   integer i;

   always @ (qi)
   begin
        case (length) 
         2: polynom = 32'b11;                               // 0x3
         3: polynom = 32'b110;                              // 0x6
         4: polynom = 32'b1100;                             // 0xC
         5: polynom = 32'b10100;                            // 0x14
         6: polynom = 32'b110000;                           // 0x30
         7: polynom = 32'b1100000;                          // 0x60
         8: polynom = 32'b10111000;                         // 0xb8
         9: polynom = 32'b100010000;                        // 0x110
        10: polynom = 32'b1001000000;                       // 0x240
        11: polynom = 32'b10100000000;                      // 0x500
        12: polynom = 32'b100000101001;                     // 0x829
        13: polynom = 32'b1000000001100;                    // 0x100C
        14: polynom = 32'b10000000010101;                   // 0x2015
        15: polynom = 32'b110000000000000;                  // 0x6000
        16: polynom = 32'b1101000000001000;                 // 0xD008
        17: polynom = 32'b10010000000000000;                // 0x12000
        18: polynom = 32'b100000010000000000;               // 0x20400
        19: polynom = 32'b1000000000000100011;              // 0x40023
        20: polynom = 32'b10010000000000000000;             // 0x90000
        21: polynom = 32'b101000000000000000000;            // 0x140000
        22: polynom = 32'b1100000000000000000000;           // 0x300000
        23: polynom = 32'b10000100000000000000000;          // 0x420000
        24: polynom = 32'b111000010000000000000000;         // 0xE10000
        25: polynom = 32'b1001000000000000000000000;        // 0x1200000
        26: polynom = 32'b10000000000000000000100011;       // 0x2000023
        27: polynom = 32'b100000000000000000000010011;      // 0x4000013
        28: polynom = 32'b1100100000000000000000000000;     // 0xC800000
        29: polynom = 32'b10100000000000000000000000000;    // 0x14000000
        30: polynom = 32'b100000000000000000000000101001;   // 0x20000029
        31: polynom = 32'b1001000000000000000000000000000;  // 0x48000000
        32: polynom = 32'b10000000001000000000000000000011; // 0x80200003
        default: polynom = 32'b0;
        endcase
        lfsr_fb = qi[length];
        for (i=length-1; i>=1; i=i-1) begin
            if (polynom[i])
                lfsr_fb = lfsr_fb  ~^ qi[i];
        end
    end
   assign q_next =  clear ? {length{1'b0}} :(qi == wrap_value) ? {length{1'b0}} :{qi[length-1:1],lfsr_fb};

   always @ (posedge clk or posedge rst)
     if (rst)
       qi <= {length{1'b0}};
     else
     if (cke)
       qi <= q_next;

   assign q = qi;

endmodule
`endif
`ifdef CNT_LFSR_CE_Q_ZQ
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Versatile counter                                           ////
////                                                              ////
////  Description                                                 ////
////  Versatile counter, a reconfigurable binary, gray or LFSR    ////
////  counter                                                     ////
////                                                              ////
////  To Do:                                                      ////
////   - add LFSR with more taps                                  ////
////                                                              ////
////  Author(s):                                                  ////
////      - Michael Unneback, unneback@opencores.org              ////
////        ORSoC AB                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 Authors and OPENCORES.ORG                 ////
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

// LFSR counter

`define MODULE cnt_lfsr_ce_q_zq
module `BASE`MODULE (
`undef MODULE
 cke, q, zq, rst, clk);

   parameter length = 4;
   input cke;
   output [length:1] q;
   output reg zq;
   input rst;
   input clk;

   parameter clear_value = 0;
   parameter set_value = 1;
   parameter wrap_value = 8;
   parameter level1_value = 15;

   reg  [length:1] qi;
   reg lfsr_fb;
   wire [length:1] q_next;
   reg [32:1] polynom;
   integer i;

   always @ (qi)
   begin
        case (length) 
         2: polynom = 32'b11;                               // 0x3
         3: polynom = 32'b110;                              // 0x6
         4: polynom = 32'b1100;                             // 0xC
         5: polynom = 32'b10100;                            // 0x14
         6: polynom = 32'b110000;                           // 0x30
         7: polynom = 32'b1100000;                          // 0x60
         8: polynom = 32'b10111000;                         // 0xb8
         9: polynom = 32'b100010000;                        // 0x110
        10: polynom = 32'b1001000000;                       // 0x240
        11: polynom = 32'b10100000000;                      // 0x500
        12: polynom = 32'b100000101001;                     // 0x829
        13: polynom = 32'b1000000001100;                    // 0x100C
        14: polynom = 32'b10000000010101;                   // 0x2015
        15: polynom = 32'b110000000000000;                  // 0x6000
        16: polynom = 32'b1101000000001000;                 // 0xD008
        17: polynom = 32'b10010000000000000;                // 0x12000
        18: polynom = 32'b100000010000000000;               // 0x20400
        19: polynom = 32'b1000000000000100011;              // 0x40023
        20: polynom = 32'b10010000000000000000;             // 0x90000
        21: polynom = 32'b101000000000000000000;            // 0x140000
        22: polynom = 32'b1100000000000000000000;           // 0x300000
        23: polynom = 32'b10000100000000000000000;          // 0x420000
        24: polynom = 32'b111000010000000000000000;         // 0xE10000
        25: polynom = 32'b1001000000000000000000000;        // 0x1200000
        26: polynom = 32'b10000000000000000000100011;       // 0x2000023
        27: polynom = 32'b100000000000000000000010011;      // 0x4000013
        28: polynom = 32'b1100100000000000000000000000;     // 0xC800000
        29: polynom = 32'b10100000000000000000000000000;    // 0x14000000
        30: polynom = 32'b100000000000000000000000101001;   // 0x20000029
        31: polynom = 32'b1001000000000000000000000000000;  // 0x48000000
        32: polynom = 32'b10000000001000000000000000000011; // 0x80200003
        default: polynom = 32'b0;
        endcase
        lfsr_fb = qi[length];
        for (i=length-1; i>=1; i=i-1) begin
            if (polynom[i])
                lfsr_fb = lfsr_fb  ~^ qi[i];
        end
    end
   assign q_next = (qi == wrap_value) ? {length{1'b0}} :{qi[length-1:1],lfsr_fb};

   always @ (posedge clk or posedge rst)
     if (rst)
       qi <= {length{1'b0}};
     else
     if (cke)
       qi <= q_next;

   assign q = qi;


   always @ (posedge clk or posedge rst)
     if (rst)
       zq <= 1'b1;
     else
     if (cke)
       zq <= q_next == {length{1'b0}};
endmodule
`endif
`ifdef CNT_LFSR_CE_REW_L1
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Versatile counter                                           ////
////                                                              ////
////  Description                                                 ////
////  Versatile counter, a reconfigurable binary, gray or LFSR    ////
////  counter                                                     ////
////                                                              ////
////  To Do:                                                      ////
////   - add LFSR with more taps                                  ////
////                                                              ////
////  Author(s):                                                  ////
////      - Michael Unneback, unneback@opencores.org              ////
////        ORSoC AB                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 Authors and OPENCORES.ORG                 ////
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

// LFSR counter

`define MODULE cnt_lfsr_ce_rew_l1
module `BASE`MODULE (
`undef MODULE
 cke, rew, level1, rst, clk);

   parameter length = 4;
   input cke;
   input rew;
   output reg level1;
   input rst;
   input clk;

   parameter clear_value = 0;
   parameter set_value = 1;
   parameter wrap_value = 8;
   parameter level1_value = 15;

   wire clear;
   assign clear = 1'b0;
   reg  [length:1] qi;
   reg lfsr_fb, lfsr_fb_rew;
   wire  [length:1] q_next, q_next_fw, q_next_rew;
   reg [32:1] polynom_rew;
   integer j;
   reg [32:1] polynom;
   integer i;

   always @ (qi)
   begin
        case (length) 
         2: polynom = 32'b11;                               // 0x3
         3: polynom = 32'b110;                              // 0x6
         4: polynom = 32'b1100;                             // 0xC
         5: polynom = 32'b10100;                            // 0x14
         6: polynom = 32'b110000;                           // 0x30
         7: polynom = 32'b1100000;                          // 0x60
         8: polynom = 32'b10111000;                         // 0xb8
         9: polynom = 32'b100010000;                        // 0x110
        10: polynom = 32'b1001000000;                       // 0x240
        11: polynom = 32'b10100000000;                      // 0x500
        12: polynom = 32'b100000101001;                     // 0x829
        13: polynom = 32'b1000000001100;                    // 0x100C
        14: polynom = 32'b10000000010101;                   // 0x2015
        15: polynom = 32'b110000000000000;                  // 0x6000
        16: polynom = 32'b1101000000001000;                 // 0xD008
        17: polynom = 32'b10010000000000000;                // 0x12000
        18: polynom = 32'b100000010000000000;               // 0x20400
        19: polynom = 32'b1000000000000100011;              // 0x40023
        20: polynom = 32'b10010000000000000000;             // 0x90000
        21: polynom = 32'b101000000000000000000;            // 0x140000
        22: polynom = 32'b1100000000000000000000;           // 0x300000
        23: polynom = 32'b10000100000000000000000;          // 0x420000
        24: polynom = 32'b111000010000000000000000;         // 0xE10000
        25: polynom = 32'b1001000000000000000000000;        // 0x1200000
        26: polynom = 32'b10000000000000000000100011;       // 0x2000023
        27: polynom = 32'b100000000000000000000010011;      // 0x4000013
        28: polynom = 32'b1100100000000000000000000000;     // 0xC800000
        29: polynom = 32'b10100000000000000000000000000;    // 0x14000000
        30: polynom = 32'b100000000000000000000000101001;   // 0x20000029
        31: polynom = 32'b1001000000000000000000000000000;  // 0x48000000
        32: polynom = 32'b10000000001000000000000000000011; // 0x80200003
        default: polynom = 32'b0;
        endcase
        lfsr_fb = qi[length];
        for (i=length-1; i>=1; i=i-1) begin
            if (polynom[i])
                lfsr_fb = lfsr_fb  ~^ qi[i];
        end
    end
   assign q_next_fw  = (qi == wrap_value) ? {length{1'b0}} :{qi[length-1:1],lfsr_fb};
   always @ (qi)
   begin
        case (length) 
         2: polynom_rew = 32'b11;
         3: polynom_rew = 32'b110;
         4: polynom_rew = 32'b1100;
         5: polynom_rew = 32'b10100;
         6: polynom_rew = 32'b110000;
         7: polynom_rew = 32'b1100000;
         8: polynom_rew = 32'b10111000;
         9: polynom_rew = 32'b100010000;
        10: polynom_rew = 32'b1001000000;
        11: polynom_rew = 32'b10100000000;
        12: polynom_rew = 32'b100000101001;
        13: polynom_rew = 32'b1000000001100;
        14: polynom_rew = 32'b10000000010101;
        15: polynom_rew = 32'b110000000000000;
        16: polynom_rew = 32'b1101000000001000;
        17: polynom_rew = 32'b10010000000000000;
        18: polynom_rew = 32'b100000010000000000;
        19: polynom_rew = 32'b1000000000000100011;
        20: polynom_rew = 32'b10000010000000000000;
        21: polynom_rew = 32'b101000000000000000000;
        22: polynom_rew = 32'b1100000000000000000000;
        23: polynom_rew = 32'b10000100000000000000000;
        24: polynom_rew = 32'b111000010000000000000000;
        25: polynom_rew = 32'b1001000000000000000000000;
        26: polynom_rew = 32'b10000000000000000000100011;
        27: polynom_rew = 32'b100000000000000000000010011;
        28: polynom_rew = 32'b1100100000000000000000000000;
        29: polynom_rew = 32'b10100000000000000000000000000;
        30: polynom_rew = 32'b100000000000000000000000101001;
        31: polynom_rew = 32'b1001000000000000000000000000000;
        32: polynom_rew = 32'b10000000001000000000000000000011;
        default: polynom_rew = 32'b0;
        endcase
        // rotate left
        polynom_rew[length:1] = { polynom_rew[length-2:1],polynom_rew[length] };
        lfsr_fb_rew = qi[length];
        for (i=length-1; i>=1; i=i-1) begin
            if (polynom_rew[i])
                lfsr_fb_rew = lfsr_fb_rew  ~^ qi[i];
        end
    end
   assign q_next_rew = (qi == wrap_value) ? {length{1'b0}} :{lfsr_fb_rew,qi[length:2]};
   assign q_next = rew ? q_next_rew : q_next_fw;

   always @ (posedge clk or posedge rst)
     if (rst)
       qi <= {length{1'b0}};
     else
     if (cke)
       qi <= q_next;



    always @ (posedge clk or posedge rst)
    if (rst)
        level1 <= 1'b0;
    else
    if (cke)
    if (clear)
        level1 <= 1'b0;
    else if (q_next == level1_value)
        level1 <= 1'b1;
    else if (qi == level1_value & rew)
        level1 <= 1'b0;
endmodule
`endif
`ifdef CNT_GRAY
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Versatile counter                                           ////
////                                                              ////
////  Description                                                 ////
////  Versatile counter, a reconfigurable binary, gray or LFSR    ////
////  counter                                                     ////
////                                                              ////
////  To Do:                                                      ////
////   - add LFSR with more taps                                  ////
////                                                              ////
////  Author(s):                                                  ////
////      - Michael Unneback, unneback@opencores.org              ////
////        ORSoC AB                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 Authors and OPENCORES.ORG                 ////
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

// GRAY counter

`define MODULE cnt_gray
module `BASE`MODULE (
`undef MODULE
 q, rst, clk);

   parameter length = 4;
   output reg [length:1] q;
   input rst;
   input clk;

   parameter clear_value = 0;
   parameter set_value = 1;
   parameter wrap_value = 8;
   parameter level1_value = 15;

   reg  [length:1] qi;
   wire [length:1] q_next;
   assign q_next = qi + {{length-1{1'b0}},1'b1};

   always @ (posedge clk or posedge rst)
     if (rst)
       qi <= {length{1'b0}};
     else
       qi <= q_next;

   always @ (posedge clk or posedge rst)
     if (rst)
       q <= {length{1'b0}};
     else
         q <= (q_next>>1) ^ q_next;

endmodule
`endif
`ifdef CNT_GRAY_CE
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Versatile counter                                           ////
////                                                              ////
////  Description                                                 ////
////  Versatile counter, a reconfigurable binary, gray or LFSR    ////
////  counter                                                     ////
////                                                              ////
////  To Do:                                                      ////
////   - add LFSR with more taps                                  ////
////                                                              ////
////  Author(s):                                                  ////
////      - Michael Unneback, unneback@opencores.org              ////
////        ORSoC AB                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 Authors and OPENCORES.ORG                 ////
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

// GRAY counter

`define MODULE cnt_gray_ce
module `BASE`MODULE (
`undef MODULE
 cke, q, rst, clk);

   parameter length = 4;
   input cke;
   output reg [length:1] q;
   input rst;
   input clk;

   parameter clear_value = 0;
   parameter set_value = 1;
   parameter wrap_value = 8;
   parameter level1_value = 15;

   reg  [length:1] qi;
   wire [length:1] q_next;
   assign q_next = qi + {{length-1{1'b0}},1'b1};

   always @ (posedge clk or posedge rst)
     if (rst)
       qi <= {length{1'b0}};
     else
     if (cke)
       qi <= q_next;

   always @ (posedge clk or posedge rst)
     if (rst)
       q <= {length{1'b0}};
     else
       if (cke)
         q <= (q_next>>1) ^ q_next;

endmodule
`endif
`ifdef CNT_GRAY_CE_BIN
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Versatile counter                                           ////
////                                                              ////
////  Description                                                 ////
////  Versatile counter, a reconfigurable binary, gray or LFSR    ////
////  counter                                                     ////
////                                                              ////
////  To Do:                                                      ////
////   - add LFSR with more taps                                  ////
////                                                              ////
////  Author(s):                                                  ////
////      - Michael Unneback, unneback@opencores.org              ////
////        ORSoC AB                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 Authors and OPENCORES.ORG                 ////
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

// GRAY counter

`define MODULE cnt_gray_ce_bin
module `BASE`MODULE (
`undef MODULE
 cke, q, q_bin, rst, clk);

   parameter length = 4;
   input cke;
   output reg [length:1] q;
   output [length:1] q_bin;
   input rst;
   input clk;

   parameter clear_value = 0;
   parameter set_value = 1;
   parameter wrap_value = 8;
   parameter level1_value = 15;

   reg  [length:1] qi;
   wire [length:1] q_next;
   assign q_next = qi + {{length-1{1'b0}},1'b1};

   always @ (posedge clk or posedge rst)
     if (rst)
       qi <= {length{1'b0}};
     else
     if (cke)
       qi <= q_next;

   always @ (posedge clk or posedge rst)
     if (rst)
       q <= {length{1'b0}};
     else
       if (cke)
         q <= (q_next>>1) ^ q_next;

   assign q_bin = qi;

endmodule
`endif
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Versatile library, counters                                 ////
////                                                              ////
////  Description                                                 ////
////  counters                                                    ////
////                                                              ////
////                                                              ////
////  To Do:                                                      ////
////   - add more counters                                        ////
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

`ifdef CNT_SHREG_WRAP
`define MODULE cnt_shreg_wrap
module `BASE`MODULE ( q, rst, clk);
`undef MODULE

   parameter length = 4;
   output reg [0:length-1] q;
   input rst;
   input clk;

    always @ (posedge clk or posedge rst)
    if (rst)
        q <= {1'b1,{length-1{1'b0}}};
    else
        q <= {q[length-1],q[0:length-2]};
            
endmodule
`endif

`ifdef CNT_SHREG_CE_WRAP
`define MODULE cnt_shreg_ce_wrap
module `BASE`MODULE ( cke, q, rst, clk);
`undef MODULE

   parameter length = 4;
   input cke;
   output reg [0:length-1] q;
   input rst;
   input clk;

    always @ (posedge clk or posedge rst)
    if (rst)
        q <= {1'b1,{length-1{1'b0}}};
    else
        if (cke)
            q <= {q[length-1],q[0:length-2]};
            
endmodule
`endif

`ifdef CNT_SHREG_CLEAR
`define MODULE cnt_shreg_clear
module `BASE`MODULE ( clear, q, rst, clk);
`undef MODULE

   parameter length = 4;
   input clear;
   output reg [0:length-1] q;
   input rst;
   input clk;

    always @ (posedge clk or posedge rst)
    if (rst)
        q <= {1'b1,{length-1{1'b0}}};
    else
        if (clear)
            q <= {1'b1,{length-1{1'b0}}};
        else
            q <= q >> 1;
            
endmodule
`endif

`ifdef CNT_SHREG_CE_CLEAR
`define MODULE cnt_shreg_ce_clear
module `BASE`MODULE ( cke, clear, q, rst, clk);
`undef MODULE

   parameter length = 4;
   input cke, clear;
   output reg [0:length-1] q;
   input rst;
   input clk;

    always @ (posedge clk or posedge rst)
    if (rst)
        q <= {1'b1,{length-1{1'b0}}};
    else
        if (cke)
            if (clear)
                q <= {1'b1,{length-1{1'b0}}};
            else
                q <= q >> 1;
            
endmodule
`endif

`ifdef CNT_SHREG_CE_CLEAR_WRAP
`define MODULE cnt_shreg_ce_clear_wrap
module `BASE`MODULE ( cke, clear, q, rst, clk);
`undef MODULE

   parameter length = 4;
   input cke, clear;
   output reg [0:length-1] q;
   input rst;
   input clk;

    always @ (posedge clk or posedge rst)
    if (rst)
        q <= {1'b1,{length-1{1'b0}}};
    else
        if (cke)
            if (clear)
                q <= {1'b1,{length-1{1'b0}}};
            else
            q <= {q[length-1],q[0:length-2]};
            
endmodule
`endif
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Versatile library, memories                                 ////
////                                                              ////
////  Description                                                 ////
////  memories                                                    ////
////                                                              ////
////                                                              ////
////  To Do:                                                      ////
////   - add more memory types                                    ////
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

`ifdef ROM_INIT
/// ROM
`define MODULE rom_init
module `BASE`MODULE ( adr, q, clk);
`undef MODULE

   parameter data_width = 32;
   parameter addr_width = 8;
   parameter mem_size = 1<<addr_width;
   input [(addr_width-1):0] 	 adr;
   output reg [(data_width-1):0] q;
   input 			 clk;
   reg [data_width-1:0] rom [mem_size-1:0];
   parameter memory_file = "vl_rom.vmem";
   initial
     begin
	$readmemh(memory_file, rom);
     end
   
   always @ (posedge clk)
     q <= rom[adr];

endmodule
`endif

`ifdef RAM
`define MODULE ram
// Single port RAM
module `BASE`MODULE ( d, adr, we, q, clk);
`undef MODULE

   parameter data_width = 32;
   parameter addr_width = 8;
   parameter mem_size = 1<<addr_width;
   parameter debug = 0;
   input [(data_width-1):0]      d;
   input [(addr_width-1):0] 	 adr;
   input 			 we;
   output reg [(data_width-1):0] q;
   input 			 clk;
   reg [data_width-1:0] ram [mem_size-1:0];
   
    parameter memory_init = 0;
    parameter memory_file = "vl_ram.vmem";
    generate
    if (memory_init == 1) begin : init_mem
        initial
            $readmemh(memory_file, ram);
   end else if (memory_init == 2) begin : init_zero
        integer k;
        initial
            for (k = 0; k < mem_size; k = k + 1)
                ram[k] = 0;
   end
   endgenerate 
   
    generate
    if (debug==1) begin : debug_we
        always @ (posedge clk)
        if (we)
            $display ("Value %h written at address %h : time %t", d, adr, $time);
        
    end
    endgenerate
    
   always @ (posedge clk)
   begin
   if (we)
     ram[adr] <= d;
   q <= ram[adr];
   end

endmodule
`endif

`ifdef RAM_BE
`define MODULE ram_be
module `BASE`MODULE ( d, adr, be, we, q, clk);
`undef MODULE

   parameter data_width = 32;
   parameter addr_width = 6;
   parameter mem_size = 1<<addr_width;
   input [(data_width-1):0]      d;
   input [(addr_width-1):0] 	 adr;
   input [(data_width/8)-1:0]    be;
   input 			 we;
   output reg [(data_width-1):0] q;
   input 			 clk;

    
`ifdef SYSTEMVERILOG
    // use a multi-dimensional packed array
    //t o model individual bytes within the word
    logic [data_width/8-1:0][7:0] ram [0:mem_size-1];// # words = 1 << address width
`else
    reg [data_width-1:0] ram [mem_size-1:0];
    wire [data_width/8-1:0] cke;
`endif

    parameter memory_init = 0;
    parameter memory_file = "vl_ram.vmem";
    generate
    if (memory_init == 1) begin : init_mem
        initial
            $readmemh(memory_file, ram);
    end else if (memory_init == 2) begin : init_zero
        integer k;
        initial
            for (k = 0; k < mem_size; k = k + 1)
                ram[k] = 0;
    end
   endgenerate 

`ifdef SYSTEMVERILOG

always_ff@(posedge clk)
begin
    if(we) begin
        if(be[3]) ram[adr][3] <= d[31:24];
        if(be[2]) ram[adr][2] <= d[23:16];
        if(be[1]) ram[adr][1] <= d[15:8];
        if(be[0]) ram[adr][0] <= d[7:0];
    end
        q <= ram[adr];
end

`else

assign cke = {data_width/8{we}} & be;
   genvar i;
   generate for (i=0;i<data_width/8;i=i+1) begin : be_ram
      always @ (posedge clk)
      if (cke[i])
        ram[adr][(i+1)*8-1:i*8] <= d[(i+1)*8-1:i*8];
   end
   endgenerate

   always @ (posedge clk)
      q <= ram[adr];

`endif

`ifdef verilator
   // Function to access RAM (for use by Verilator).
   function [31:0] get_mem;
      // verilator public
      input [addr_width-1:0] 		addr;
      get_mem = ram[addr];
   endfunction // get_mem

   // Function to write RAM (for use by Verilator).
   function set_mem;
      // verilator public
      input [addr_width-1:0] 		addr;
      input [data_width-1:0] 		data;
      ram[addr] = data;
   endfunction // set_mem
`endif

endmodule
`endif

`ifdef DPRAM_1R1W
`define MODULE dpram_1r1w
module `BASE`MODULE ( d_a, adr_a, we_a, clk_a, q_b, adr_b, clk_b );
`undef MODULE
   parameter data_width = 32;
   parameter addr_width = 8;
   parameter mem_size = 1<<addr_width;
   input [(data_width-1):0]      d_a;
   input [(addr_width-1):0] 	 adr_a;
   input [(addr_width-1):0] 	 adr_b;
   input 			 we_a;
   output reg [(data_width-1):0] 	 q_b;
   input 			 clk_a, clk_b;
   reg [data_width-1:0] ram [0:mem_size-1] `SYN_NO_RW_CHECK;

    parameter memory_init = 0;
    parameter memory_file = "vl_ram.vmem";
    parameter debug = 0;
    
    generate
    if (memory_init == 1) begin : init_mem
        initial
            $readmemh(memory_file, ram);
    end else if (memory_init == 2) begin : init_zero
        integer k;
        initial
            for (k = 0; k < mem_size; k = k + 1)
                ram[k] = 0;
    end
   endgenerate 

    generate
    if (debug==1) begin : debug_we
        always @ (posedge clk_a)
        if (we_a)
            $display ("Debug: Value %h written at address %h : time %t", d_a, adr_a, $time);
        
    end
    endgenerate

   always @ (posedge clk_a)
   if (we_a)
     ram[adr_a] <= d_a;

   always @ (posedge clk_b)
      q_b = ram[adr_b];
   
endmodule
`endif

`ifdef DPRAM_2R1W
`define MODULE dpram_2r1w
module `BASE`MODULE ( d_a, q_a, adr_a, we_a, clk_a, q_b, adr_b, clk_b );
`undef MODULE

   parameter data_width = 32;
   parameter addr_width = 8;
   parameter mem_size = 1<<addr_width;
   input [(data_width-1):0]      d_a;
   input [(addr_width-1):0] 	 adr_a;
   input [(addr_width-1):0] 	 adr_b;
   input 			 we_a;
   output [(data_width-1):0] 	 q_b;
   output reg [(data_width-1):0] q_a;
   input 			 clk_a, clk_b;
   reg [(data_width-1):0] 	 q_b;   
   reg [data_width-1:0] ram [0:mem_size-1] `SYN_NO_RW_CHECK;

    parameter memory_init = 0;
    parameter memory_file = "vl_ram.vmem";
    parameter debug = 0;
    
    generate
    if (memory_init == 1) begin : init_mem
        initial
            $readmemh(memory_file, ram);
    end else if (memory_init == 2) begin : init_zero
        integer k;
        initial
            for (k = 0; k < mem_size; k = k + 1)
                ram[k] = 0;
    end
   endgenerate 

    generate
    if (debug==1) begin : debug_we
        always @ (posedge clk_a)
        if (we_a)
            $display ("Debug: Value %h written at address %h : time %t", d_a, adr_a, $time);
        
    end
    endgenerate

   always @ (posedge clk_a)
     begin 
	q_a <= ram[adr_a];
	if (we_a)
	     ram[adr_a] <= d_a;
     end 
   always @ (posedge clk_b)
	  q_b <= ram[adr_b];
endmodule
`endif

`ifdef DPRAM_1R2W
`define MODULE dpram_1r2w
module `BASE`MODULE ( d_a, q_a, adr_a, we_a, clk_a, d_b, adr_b, we_b, clk_b );
`undef MODULE

   parameter data_width = 32;
   parameter addr_width = 8;
   parameter mem_size = 1<<addr_width;
   input [(data_width-1):0]      d_a;
   input [(addr_width-1):0] 	 adr_a;
   input [(addr_width-1):0] 	 adr_b;
   input 			 we_a;
   input [(data_width-1):0] 	 d_b;
   output reg [(data_width-1):0] q_a;
   input 			 we_b;
   input 			 clk_a, clk_b;
   reg [(data_width-1):0] 	 q_b;   
   reg [data_width-1:0] ram [0:mem_size-1] `SYN_NO_RW_CHECK;

    parameter memory_init = 0;
    parameter memory_file = "vl_ram.vmem";
    parameter debug = 0;
    
    generate
    if (memory_init == 1) begin : init_mem
        initial
            $readmemh(memory_file, ram);
    end else if (memory_init == 2) begin : init_zero
        integer k;
        initial
            for (k = 0; k < mem_size; k = k + 1)
                ram[k] = 0;
    end
   endgenerate 

    generate
    if (debug==1) begin : debug_we
        always @ (posedge clk_a)
        if (we_a)
            $display ("Debug: Value %h written at address %h : time %t", d_a, adr_a, $time);
        always @ (posedge clk_b)
        if (we_b)
            $display ("Debug: Value %h written at address %h : time %t", d_b, adr_b, $time);        
    end
    endgenerate

   always @ (posedge clk_a)
     begin 
	q_a <= ram[adr_a];
	if (we_a)
	     ram[adr_a] <= d_a;
     end 
   always @ (posedge clk_b)
     begin 
	if (we_b)
	  ram[adr_b] <= d_b;
     end
endmodule
`endif

`ifdef DPRAM_2R2W
`define MODULE dpram_2r2w
module `BASE`MODULE ( d_a, q_a, adr_a, we_a, clk_a, d_b, q_b, adr_b, we_b, clk_b );
`undef MODULE

   parameter data_width = 32;
   parameter addr_width = 8;
   parameter mem_size = 1<<addr_width;
   input [(data_width-1):0]      d_a;
   input [(addr_width-1):0] 	 adr_a;
   input [(addr_width-1):0] 	 adr_b;
   input 			 we_a;
   output [(data_width-1):0] 	 q_b;
   input [(data_width-1):0] 	 d_b;
   output reg [(data_width-1):0] q_a;
   input 			 we_b;
   input 			 clk_a, clk_b;
   reg [(data_width-1):0] 	 q_b;   
   reg [data_width-1:0] ram [0:mem_size-1] `SYN_NO_RW_CHECK;

    parameter memory_init = 0;
    parameter memory_file = "vl_ram.vmem";
    parameter debug = 0;
    
    generate
    if (memory_init) begin : init_mem
        initial
            $readmemh(memory_file, ram);
    end else if (memory_init == 2) begin : init_zero
        integer k;
        initial
            for (k = 0; k < mem_size; k = k + 1)
                ram[k] = 0;
    end
   endgenerate 

    generate
    if (debug==1) begin : debug_we
        always @ (posedge clk_a)
        if (we_a)
            $display ("Debug: Value %h written at address %h : time %t", d_a, adr_a, $time);
        always @ (posedge clk_b)
        if (we_b)
            $display ("Debug: Value %h written at address %h : time %t", d_b, adr_b, $time);        
    end
    endgenerate

   always @ (posedge clk_a)
     begin 
	q_a <= ram[adr_a];
	if (we_a)
	     ram[adr_a] <= d_a;
     end 
   always @ (posedge clk_b)
     begin 
	q_b <= ram[adr_b];
	if (we_b)
	  ram[adr_b] <= d_b;
     end
endmodule
`endif


`ifdef DPRAM_BE_2R2W
`define MODULE dpram_be_2r2w
module `BASE`MODULE ( d_a, q_a, adr_a, be_a, we_a, clk_a, d_b, q_b, adr_b, be_b, we_b, clk_b );
`undef MODULE

   parameter a_data_width = 32;
   parameter a_addr_width = 8;
   parameter b_data_width = 64; //a_data_width;
   //localparam b_addr_width = a_data_width * a_addr_width / b_data_width;
   localparam b_addr_width = 
	(a_data_width==b_data_width) ? a_addr_width : 
	(a_data_width==b_data_width*2) ? a_addr_width+1 : 
	(a_data_width==b_data_width*4) ? a_addr_width+2 : 
	(a_data_width==b_data_width*8) ? a_addr_width+3 : 
	(a_data_width==b_data_width*16) ? a_addr_width+4 : 
	(a_data_width==b_data_width*32) ? a_addr_width+5 : 
	(a_data_width==b_data_width/2) ? a_addr_width-1 : 
	(a_data_width==b_data_width/4) ? a_addr_width-2 : 
	(a_data_width==b_data_width/8) ? a_addr_width-3 : 
	(a_data_width==b_data_width/16) ? a_addr_width-4 : 
	(a_data_width==b_data_width/32) ? a_addr_width-5 : 0;

   localparam ratio = (a_addr_width>b_addr_width) ? (a_addr_width/b_addr_width) : (b_addr_width/a_addr_width);
   parameter mem_size = (a_addr_width>b_addr_width) ? (1<<b_addr_width) : (1<<a_addr_width);

   parameter memory_init = 0;
   parameter memory_file = "vl_ram.vmem";
   parameter debug = 0;
   
   input [(a_data_width-1):0]      d_a;
   input [(a_addr_width-1):0] 	   adr_a;
   input [(a_data_width/8-1):0]    be_a;
   input 			   we_a;
   output reg [(a_data_width-1):0] q_a;
   input [(b_data_width-1):0] 	   d_b;
   input [(b_addr_width-1):0] 	   adr_b;
   input [(b_data_width/8-1):0]    be_b;
   input 			   we_b;
   output reg [(b_data_width-1):0] 	   q_b;
   input 			   clk_a, clk_b;

    generate
    if (debug==1) begin : debug_we
        always @ (posedge clk_a)
        if (we_a)
            $display ("Debug: Value %h written on port A at address %h : time %t", d_a, adr_a, $time);
        always @ (posedge clk_b)
        if (we_b)
            $display ("Debug: Value %h written on port B at address %h : time %t", d_b, adr_b, $time);        
    end
    endgenerate


`ifdef SYSTEMVERILOG
// use a multi-dimensional packed array
//to model individual bytes within the word

generate
if (a_data_width==32 & b_data_width==32) begin : dpram_3232

    logic [0:3][7:0] ram [0:mem_size-1] `SYN_NO_RW_CHECK;
    
    initial
        if (memory_init==1)
            $readmemh(memory_file, ram);
            
    integer k;
    initial
        if (memory_init==2)
            for (k = 0; k < mem_size; k = k + 1)
                ram[k] = 0;

    always_ff@(posedge clk_a)
    begin
        if(we_a) begin
            if(be_a[3]) ram[adr_a][0] <= d_a[31:24];
            if(be_a[2]) ram[adr_a][1] <= d_a[23:16];
            if(be_a[1]) ram[adr_a][2] <= d_a[15:8];
            if(be_a[0]) ram[adr_a][3] <= d_a[7:0];
        end
    end
    
    always@(posedge clk_a)
        q_a = ram[adr_a];
    
    always_ff@(posedge clk_b)
    begin
        if(we_b) begin
            if(be_b[3]) ram[adr_b][0] <= d_b[31:24];
            if(be_b[2]) ram[adr_b][1] <= d_b[23:16];
            if(be_b[1]) ram[adr_b][2] <= d_b[15:8];
            if(be_b[0]) ram[adr_b][3] <= d_b[7:0];
        end
    end
    
    always@(posedge clk_b)
        q_b = ram[adr_b];

end
endgenerate

generate
if (a_data_width==64 & b_data_width==64) begin : dpram_6464

    logic [0:7][7:0] ram [0:mem_size-1] `SYN_NO_RW_CHECK;
    
    initial
        if (memory_init==1)
            $readmemh(memory_file, ram);
            
    integer k;
    initial
        if (memory_init==2)
            for (k = 0; k < mem_size; k = k + 1)
                ram[k] = 0;

    always_ff@(posedge clk_a)
    begin
        if(we_a) begin
            if(be_a[7]) ram[adr_a][7] <= d_a[63:56];
            if(be_a[6]) ram[adr_a][6] <= d_a[55:48];
            if(be_a[5]) ram[adr_a][5] <= d_a[47:40];
            if(be_a[4]) ram[adr_a][4] <= d_a[39:32];
            if(be_a[3]) ram[adr_a][3] <= d_a[31:24];
            if(be_a[2]) ram[adr_a][2] <= d_a[23:16];
            if(be_a[1]) ram[adr_a][1] <= d_a[15:8];
            if(be_a[0]) ram[adr_a][0] <= d_a[7:0];
        end
    end
    
    always@(posedge clk_a)
        q_a = ram[adr_a];
    
    always_ff@(posedge clk_b)
    begin
        if(we_b) begin
            if(be_b[7]) ram[adr_b][7] <= d_b[63:56];
            if(be_b[6]) ram[adr_b][6] <= d_b[55:48];
            if(be_b[5]) ram[adr_b][5] <= d_b[47:40];
            if(be_b[4]) ram[adr_b][4] <= d_b[39:32];
            if(be_b[3]) ram[adr_b][3] <= d_b[31:24];
            if(be_b[2]) ram[adr_b][2] <= d_b[23:16];
            if(be_b[1]) ram[adr_b][1] <= d_b[15:8];
            if(be_b[0]) ram[adr_b][0] <= d_b[7:0];
        end
    end
    
    always@(posedge clk_b)
        q_b = ram[adr_b];

end
endgenerate

generate
if (a_data_width==32 & b_data_width==16) begin : dpram_3216
logic [31:0] temp;
`define MODULE dpram_be_2r2w
`BASE`MODULE # (.a_data_width(32), .b_data_width(32), .a_addr_width(a_addr_width), .mem_size(mem_size), .memory_init(memory_init), .memory_file(memory_file))
`undef MODULE
dpram3232 (
    .d_a(d_a),
    .q_a(q_a),
    .adr_a(adr_a),
    .be_a(be_a),
    .we_a(we_a),
    .clk_a(clk_a),
    .d_b({d_b,d_b}),
    .q_b(temp),
    .adr_b(adr_b[b_addr_width-1:1]),
    .be_b({be_b,be_b} & {{2{!adr_b[0]}},{2{adr_b[0]}}}),
    .we_b(we_b),
    .clk_b(clk_b)
);

always @ (adr_b[0] or temp)
    if (adr_b[0])
        q_b = temp[31:16];
    else
        q_b = temp[15:0];
        
end
endgenerate

generate
if (a_data_width==32 & b_data_width==64) begin : dpram_3264
logic [63:0] temp;
`define MODULE dpram_be_2r2w
`BASE`MODULE # (.a_data_width(32), .b_data_width(64), .a_addr_width(a_addr_width), .mem_size(mem_size), .memory_init(memory_init), .memory_file(memory_file))
`undef MODULE
dpram6464 (
    .d_a({d_a,d_a}),
    .q_a(temp),
    .adr_a(adr_a[a_addr_width-1:1]),
    .be_a({be_a,be_a} & {{4{adr_a[0]}},{4{!adr_a[0]}}}),
    .we_a(we_a),
    .clk_a(clk_a),
    .d_b(d_b),
    .q_b(q_b),
    .adr_b(adr_b),
    .be_b(be_b),
    .we_b(we_b),
    .clk_b(clk_b)
);

always @ (adr_a[0] or temp)
    if (adr_a[0])
        q_a = temp[63:32];
    else
        q_a = temp[31:0];
        
end
endgenerate

`else
    // This modules requires SystemVerilog
    // at this point anyway
`endif
endmodule
`endif

`ifdef CAM
// Content addresable memory, CAM
`endif

`ifdef FIFO_1R1W_FILL_LEVEL_SYNC
// FIFO
`define MODULE fifo_1r1w_fill_level_sync
module `BASE`MODULE (
`undef MODULE
    d, wr, fifo_full,
    q, rd, fifo_empty,
    fill_level,
    clk, rst
    );
    
parameter data_width = 18;
parameter addr_width = 4;

// write side
input  [data_width-1:0] d;
input                   wr;
output                  fifo_full;
// read side
output [data_width-1:0] q;
input                   rd;
output                  fifo_empty;
// common
output [addr_width:0]   fill_level;
input rst, clk;

wire [addr_width:1] wadr, radr;

`define MODULE cnt_bin_ce
`BASE`MODULE
    # ( .length(addr_width))
    fifo_wr_adr( .cke(wr), .q(wadr), .rst(rst), .clk(clk));
`BASE`MODULE
    # (.length(addr_width))
    fifo_rd_adr( .cke(rd), .q(radr), .rst(rst), .clk(clk));
`undef MODULE

`define MODULE dpram_1r1w
`BASE`MODULE
    # (.data_width(data_width), .addr_width(addr_width))
    dpram ( .d_a(d), .adr_a(wadr), .we_a(wr), .clk_a(clk), .q_b(q), .adr_b(radr), .clk_b(clk));
`undef MODULE

`define MODULE cnt_bin_ce_rew_q_zq_l1
`BASE`MODULE
    # (.length(addr_width+1), .level1_value(1<<addr_width))
    fill_level_cnt( .cke(rd ^ wr), .rew(rd), .q(fill_level), .zq(fifo_empty), .level1(fifo_full), .rst(rst), .clk(clk));
`undef MODULE
endmodule
`endif

`ifdef FIFO_2R2W_SYNC_SIMPLEX
// Intended use is two small FIFOs (RX and TX typically) in one FPGA RAM resource
// RAM is supposed to be larger than the two FIFOs
// LFSR counters used adr pointers
`define MODULE fifo_2r2w_sync_simplex
module `BASE`MODULE (
`undef MODULE
    // a side
    a_d, a_wr, a_fifo_full,
    a_q, a_rd, a_fifo_empty,
    a_fill_level,
    // b side
    b_d, b_wr, b_fifo_full,
    b_q, b_rd, b_fifo_empty,
    b_fill_level,
    // common
    clk, rst	
    );
parameter data_width = 8;
parameter addr_width = 5;
parameter fifo_full_level = (1<<addr_width)-1;

// a side
input  [data_width-1:0] a_d;
input                   a_wr;
output                  a_fifo_full;
output [data_width-1:0] a_q;
input                   a_rd;
output                  a_fifo_empty;
output [addr_width-1:0] a_fill_level;

// b side
input  [data_width-1:0] b_d;
input                   b_wr;
output                  b_fifo_full;
output [data_width-1:0] b_q;
input                   b_rd;
output                  b_fifo_empty;
output [addr_width-1:0] b_fill_level;

input                   clk;
input                   rst;

// adr_gen
wire [addr_width:1] a_wadr, a_radr;
wire [addr_width:1] b_wadr, b_radr;
// dpram
wire [addr_width:0] a_dpram_adr, b_dpram_adr;

`define MODULE cnt_lfsr_ce
`BASE`MODULE
    # ( .length(addr_width))
    fifo_a_wr_adr( .cke(a_wr), .q(a_wadr), .rst(rst), .clk(clk));
    
`BASE`MODULE
    # (.length(addr_width))
    fifo_a_rd_adr( .cke(a_rd), .q(a_radr), .rst(rst), .clk(clk));

`BASE`MODULE
    # ( .length(addr_width))
    fifo_b_wr_adr( .cke(b_wr), .q(b_wadr), .rst(rst), .clk(clk));
    
`BASE`MODULE
    # (.length(addr_width))
    fifo_b_rd_adr( .cke(b_rd), .q(b_radr), .rst(rst), .clk(clk));
`undef MODULE

// mux read or write adr to DPRAM
assign a_dpram_adr = (a_wr) ? {1'b0,a_wadr} : {1'b1,a_radr};
assign b_dpram_adr = (b_wr) ? {1'b1,b_wadr} : {1'b0,b_radr};

`define MODULE dpram_2r2w
`BASE`MODULE
    # (.data_width(data_width), .addr_width(addr_width+1))
    dpram ( .d_a(a_d), .q_a(a_q), .adr_a(a_dpram_adr), .we_a(a_wr), .clk_a(a_clk), 
            .d_b(b_d), .q_b(b_q), .adr_b(b_dpram_adr), .we_b(b_wr), .clk_b(b_clk));
`undef MODULE

`define MODULE cnt_bin_ce_rew_zq_l1
`BASE`MODULE
    # (.length(addr_width), .level1_value(fifo_full_level))
    a_fill_level_cnt( .cke(a_rd ^ a_wr), .rew(a_rd), .q(a_fill_level), .zq(a_fifo_empty), .level1(a_fifo_full), .rst(rst), .clk(clk));

`BASE`MODULE
    # (.length(addr_width), .level1_value(fifo_full_level))
    b_fill_level_cnt( .cke(b_rd ^ b_wr), .rew(b_rd), .q(b_fill_level), .zq(b_fifo_empty), .level1(b_fifo_full), .rst(rst), .clk(clk));
`undef MODULE

endmodule
`endif

`ifdef FIFO_CMP_ASYNC
`define MODULE fifo_cmp_async
module `BASE`MODULE ( wptr, rptr, fifo_empty, fifo_full, wclk, rclk, rst );
`undef MODULE

   parameter addr_width = 4;   
   parameter N = addr_width-1;

   parameter Q1 = 2'b00;
   parameter Q2 = 2'b01;
   parameter Q3 = 2'b11;
   parameter Q4 = 2'b10;

   parameter going_empty = 1'b0;
   parameter going_full  = 1'b1;
   
   input [N:0]  wptr, rptr;   
   output 	fifo_empty;
   output       fifo_full;
   input 	wclk, rclk, rst;   

`ifndef GENERATE_DIRECTION_AS_LATCH   
   wire direction;
`endif
`ifdef GENERATE_DIRECTION_AS_LATCH
   reg direction;
`endif
   reg 	direction_set, direction_clr;
   
   wire async_empty, async_full;
   wire fifo_full2;
   wire fifo_empty2;   
   
   // direction_set
   always @ (wptr[N:N-1] or rptr[N:N-1])
     case ({wptr[N:N-1],rptr[N:N-1]})
       {Q1,Q2} : direction_set <= 1'b1;
       {Q2,Q3} : direction_set <= 1'b1;
       {Q3,Q4} : direction_set <= 1'b1;
       {Q4,Q1} : direction_set <= 1'b1;
       default : direction_set <= 1'b0;
     endcase

   // direction_clear
   always @ (wptr[N:N-1] or rptr[N:N-1] or rst)
     if (rst)
       direction_clr <= 1'b1;
     else
       case ({wptr[N:N-1],rptr[N:N-1]})
	 {Q2,Q1} : direction_clr <= 1'b1;
	 {Q3,Q2} : direction_clr <= 1'b1;
	 {Q4,Q3} : direction_clr <= 1'b1;
	 {Q1,Q4} : direction_clr <= 1'b1;
	 default : direction_clr <= 1'b0;
       endcase

`define MODULE dff_sr
`ifndef GENERATE_DIRECTION_AS_LATCH
    `BASE`MODULE dff_sr_dir( .aclr(direction_clr), .aset(direction_set), .clock(1'b1), .data(1'b1), .q(direction));
`endif

`ifdef GENERATE_DIRECTION_AS_LATCH
   always @ (posedge direction_set or posedge direction_clr)
     if (direction_clr)
       direction <= going_empty;
     else
       direction <= going_full;
`endif

   assign async_empty = (wptr == rptr) && (direction==going_empty);
   assign async_full  = (wptr == rptr) && (direction==going_full);

    `BASE`MODULE dff_sr_empty0( .aclr(rst), .aset(async_full), .clock(wclk), .data(async_full), .q(fifo_full2));
    `BASE`MODULE dff_sr_empty1( .aclr(rst), .aset(async_full), .clock(wclk), .data(fifo_full2), .q(fifo_full));
`undef MODULE

/*
   always @ (posedge wclk or posedge rst or posedge async_full)
     if (rst)
       {fifo_full, fifo_full2} <= 2'b00;
     else if (async_full)
       {fifo_full, fifo_full2} <= 2'b11;
     else
       {fifo_full, fifo_full2} <= {fifo_full2, async_full};
*/
/*   always @ (posedge rclk or posedge async_empty)
     if (async_empty)
       {fifo_empty, fifo_empty2} <= 2'b11;
     else
       {fifo_empty,fifo_empty2} <= {fifo_empty2,async_empty}; */
`define MODULE dff
    `BASE`MODULE # ( .reset_value(1'b1)) dff0 ( .d(async_empty), .q(fifo_empty2), .clk(rclk), .rst(async_empty));
    `BASE`MODULE # ( .reset_value(1'b1)) dff1 ( .d(fifo_empty2), .q(fifo_empty),  .clk(rclk), .rst(async_empty));
`undef MODULE
endmodule // async_compb
`endif

`ifdef FIFO_1R1W_ASYNC
`define MODULE fifo_1r1w_async
module `BASE`MODULE (
`undef MODULE
    d, wr, fifo_full, wr_clk, wr_rst,
    q, rd, fifo_empty, rd_clk, rd_rst
    );
    
parameter data_width = 18;
parameter addr_width = 4;

// write side
input  [data_width-1:0] d;
input                   wr;
output                  fifo_full;
input                   wr_clk;
input                   wr_rst;
// read side
output [data_width-1:0] q;
input                   rd;
output                  fifo_empty;
input                   rd_clk;
input                   rd_rst;

wire [addr_width:1] wadr, wadr_bin, radr, radr_bin;

`define MODULE cnt_gray_ce_bin
`BASE`MODULE
    # ( .length(addr_width))
    fifo_wr_adr( .cke(wr), .q(wadr), .q_bin(wadr_bin), .rst(wr_rst), .clk(wr_clk));
    
`BASE`MODULE
    # (.length(addr_width))
    fifo_rd_adr( .cke(rd), .q(radr), .q_bin(radr_bin), .rst(rd_rst), .clk(rd_clk));
`undef MODULE

`define MODULE dpram_1r1w
`BASE`MODULE
    # (.data_width(data_width), .addr_width(addr_width))
    dpram ( .d_a(d), .adr_a(wadr_bin), .we_a(wr), .clk_a(wr_clk), .q_b(q), .adr_b(radr_bin), .clk_b(rd_clk));
`undef MODULE

`define MODULE fifo_cmp_async
`BASE`MODULE
    # (.addr_width(addr_width))
    cmp ( .wptr(wadr), .rptr(radr), .fifo_empty(fifo_empty), .fifo_full(fifo_full), .wclk(wr_clk), .rclk(rd_clk), .rst(wr_rst) );
`undef MODULE

endmodule
`endif

`ifdef FIFO_2R2W_ASYNC
`define MODULE fifo_2r2w_async
module `BASE`MODULE (
`undef MODULE
    // a side
    a_d, a_wr, a_fifo_full,
    a_q, a_rd, a_fifo_empty, 
    a_clk, a_rst,
    // b side
    b_d, b_wr, b_fifo_full,
    b_q, b_rd, b_fifo_empty, 
    b_clk, b_rst	
    );
    
parameter data_width = 18;
parameter addr_width = 4;

// a side
input  [data_width-1:0] a_d;
input                   a_wr;
output                  a_fifo_full;
output [data_width-1:0] a_q;
input                   a_rd;
output                  a_fifo_empty;
input                   a_clk;
input                   a_rst;

// b side
input  [data_width-1:0] b_d;
input                   b_wr;
output                  b_fifo_full;
output [data_width-1:0] b_q;
input                   b_rd;
output                  b_fifo_empty;
input                   b_clk;
input                   b_rst;

`define MODULE fifo_1r1w_async
`BASE`MODULE # (.data_width(data_width), .addr_width(addr_width))
vl_fifo_1r1w_async_a (
    .d(a_d), .wr(a_wr), .fifo_full(a_fifo_full), .wr_clk(a_clk), .wr_rst(a_rst),
    .q(b_q), .rd(b_rd), .fifo_empty(b_fifo_empty), .rd_clk(b_clk), .rd_rst(b_rst)
    );

`BASE`MODULE # (.data_width(data_width), .addr_width(addr_width))
vl_fifo_1r1w_async_b (
    .d(b_d), .wr(b_wr), .fifo_full(b_fifo_full), .wr_clk(b_clk), .wr_rst(b_rst),
    .q(a_q), .rd(a_rd), .fifo_empty(a_fifo_empty), .rd_clk(a_clk), .rd_rst(a_rst)
    );
`undef MODULE

endmodule
`endif

`ifdef FIFO_2R2W_ASYNC_SIMPLEX
`define MODULE fifo_2r2w_async_simplex
module `BASE`MODULE (
`undef MODULE
    // a side
    a_d, a_wr, a_fifo_full,
    a_q, a_rd, a_fifo_empty, 
    a_clk, a_rst,
    // b side
    b_d, b_wr, b_fifo_full,
    b_q, b_rd, b_fifo_empty, 
    b_clk, b_rst	
    );
    
parameter data_width = 18;
parameter addr_width = 4;

// a side
input  [data_width-1:0] a_d;
input                   a_wr;
output                  a_fifo_full;
output [data_width-1:0] a_q;
input                   a_rd;
output                  a_fifo_empty;
input                   a_clk;
input                   a_rst;

// b side
input  [data_width-1:0] b_d;
input                   b_wr;
output                  b_fifo_full;
output [data_width-1:0] b_q;
input                   b_rd;
output                  b_fifo_empty;
input                   b_clk;
input                   b_rst;

// adr_gen
wire [addr_width:1] a_wadr, a_wadr_bin, a_radr, a_radr_bin;
wire [addr_width:1] b_wadr, b_wadr_bin, b_radr, b_radr_bin;
// dpram
wire [addr_width:0] a_dpram_adr, b_dpram_adr;

`define MODULE cnt_gray_ce_bin
`BASE`MODULE
    # ( .length(addr_width))
    fifo_a_wr_adr( .cke(a_wr), .q(a_wadr), .q_bin(a_wadr_bin), .rst(a_rst), .clk(a_clk));
    
`BASE`MODULE
    # (.length(addr_width))
    fifo_a_rd_adr( .cke(a_rd), .q(a_radr), .q_bin(a_radr_bin), .rst(a_rst), .clk(a_clk));

`BASE`MODULE
    # ( .length(addr_width))
    fifo_b_wr_adr( .cke(b_wr), .q(b_wadr), .q_bin(b_wadr_bin), .rst(b_rst), .clk(b_clk));
    
`BASE`MODULE
    # (.length(addr_width))
    fifo_b_rd_adr( .cke(b_rd), .q(b_radr), .q_bin(b_radr_bin), .rst(b_rst), .clk(b_clk));
`undef MODULE

// mux read or write adr to DPRAM
assign a_dpram_adr = (a_wr) ? {1'b0,a_wadr_bin} : {1'b1,a_radr_bin};
assign b_dpram_adr = (b_wr) ? {1'b1,b_wadr_bin} : {1'b0,b_radr_bin};

`define MODULE dpram_2r2w
`BASE`MODULE
    # (.data_width(data_width), .addr_width(addr_width+1))
    dpram ( .d_a(a_d), .q_a(a_q), .adr_a(a_dpram_adr), .we_a(a_wr), .clk_a(a_clk), 
            .d_b(b_d), .q_b(b_q), .adr_b(b_dpram_adr), .we_b(b_wr), .clk_b(b_clk));
`undef MODULE

`define MODULE fifo_cmp_async
`BASE`MODULE
    # (.addr_width(addr_width))
    cmp1 ( .wptr(a_wadr), .rptr(b_radr), .fifo_empty(b_fifo_empty), .fifo_full(a_fifo_full), .wclk(a_clk), .rclk(b_clk), .rst(a_rst) );

`BASE`MODULE
    # (.addr_width(addr_width))
    cmp2 ( .wptr(b_wadr), .rptr(a_radr), .fifo_empty(a_fifo_empty), .fifo_full(b_fifo_full), .wclk(b_clk), .rclk(a_clk), .rst(b_rst) );
`undef MODULE

endmodule
`endif

`ifdef REG_FILE
`define MODULE reg_file
module `BASE`MODULE (
`undef MODULE
    a1, a2, a3, wd3, we3, rd1, rd2, clk, rst );
parameter dw = 32;
parameter aw = 5;
parameter debug = 0;
input [aw-1:0] a1, a2, a3;
input [dw-1:0] wd3;
input we3;
output [dw-1:0] rd1, rd2;
input clk, rst;
wire [dw-1:0] rd1mem, rd2mem;
reg [dw-1:0] wreg;
reg sel1, sel2;

generate
if (debug==1) begin : debug_we
    always @ (posedge clk)
        if (we3)
            $display ("Value %h written at register %h : time %t", wd3, a3, $time);
end
endgenerate

`define MODULE dpram_1r1w
`BASE`MODULE
    # ( .data_width(dw), .addr_width(aw))
    ram1 (
        .d_a(wd3),
        .adr_a(a3),
        .we_a(we3),
        .clk_a(clk),
        .q_b(rd1mem),
        .adr_b(a1),
        .clk_b(clk) );
        
`BASE`MODULE
    # ( .data_width(dw), .addr_width(aw))
    ram2 (
        .d_a(wd3),
        .adr_a(a3),
        .we_a(we3),
        .clk_a(clk),
        .q_b(rd2mem),
        .adr_b(a2),
        .clk_b(clk) );
`undef MODULE

always @ (posedge clk or posedge rst)
if (rst)
    {sel1, sel2, wreg} <= {1'b0,1'b0,{dw{1'b0}}};
else
    {sel1,sel2,wreg} <= {we3 & a1==a3, we3 & a2==a3,wd3};
assign rd1 = (sel1) ? wreg : rd1mem;
assign rd2 = (sel2) ? wreg : rd2mem;

endmodule
`endif
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Versatile library, wishbone stuff                           ////
////                                                              ////
////  Description                                                 ////
////  Wishbone compliant modules                                  ////
////                                                              ////
////                                                              ////
////  To Do:                                                      ////
////   -                                                          ////
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

`ifdef WB_ADR_INC
`timescale 1ns/1ns
`define MODULE wb_adr_inc
module `BASE`MODULE ( cyc_i, stb_i, cti_i, bte_i, adr_i, we_i, ack_o, adr_o, clk, rst);
`undef MODULE
parameter adr_width = 10;
parameter max_burst_width = 4;
input cyc_i, stb_i, we_i;
input [2:0] cti_i;
input [1:0] bte_i;
input [adr_width-1:0] adr_i;
output [adr_width-1:0] adr_o;
output ack_o;
input clk, rst;

reg [adr_width-1:0] adr;
wire [max_burst_width-1:0] to_adr;
reg [max_burst_width-1:0] last_adr;
reg last_cycle;
localparam idle_or_eoc = 1'b0;
localparam cyc_or_ws   = 1'b1;

always @ (posedge clk or posedge rst)
if (rst)
    last_adr <= {max_burst_width{1'b0}};
else
    if (stb_i)
        last_adr <=adr_o[max_burst_width-1:0];

generate
if (max_burst_width==0) begin : inst_0   

        reg ack_o;
        assign adr_o = adr_i;
        always @ (posedge clk or posedge rst)
        if (rst)
            ack_o <= 1'b0;
        else
            ack_o <= cyc_i & stb_i & !ack_o;

end else begin

    always @ (posedge clk or posedge rst)
    if (rst)
        last_cycle <= idle_or_eoc;
    else
        last_cycle <= (!cyc_i) ? idle_or_eoc : //idle
                      (cyc_i & ack_o & (cti_i==3'b000 | cti_i==3'b111)) ? idle_or_eoc : // eoc
                      (cyc_i & !stb_i) ? cyc_or_ws : //ws
                      cyc_or_ws; // cyc
    assign to_adr = (last_cycle==idle_or_eoc) ? adr_i[max_burst_width-1:0] : adr[max_burst_width-1:0];
    assign adr_o[max_burst_width-1:0] = (we_i) ? adr_i[max_burst_width-1:0] :
                                        (!stb_i) ? last_adr :
                                        (last_cycle==idle_or_eoc) ? adr_i[max_burst_width-1:0] :
                                        adr[max_burst_width-1:0];
    assign ack_o = (last_cycle==cyc_or_ws) & stb_i;

end
endgenerate

generate
if (max_burst_width==2) begin : inst_2
    always @ (posedge clk or posedge rst)
    if (rst)
        adr <= 2'h0;
    else
        if (cyc_i & stb_i)
            adr[1:0] <= to_adr[1:0] + 2'd1;
        else
            adr <= to_adr[1:0];
end
endgenerate

generate
if (max_burst_width==3) begin : inst_3    
    always @ (posedge clk or posedge rst)
    if (rst)
        adr <= 3'h0;
    else
        if (cyc_i & stb_i)
            case (bte_i)
            2'b01: adr[2:0] <= {to_adr[2],to_adr[1:0] + 2'd1};
            default: adr[3:0] <= to_adr[2:0] + 3'd1;
            endcase
        else
            adr <= to_adr[2:0];
end
endgenerate

generate
if (max_burst_width==4) begin : inst_4    
    always @ (posedge clk or posedge rst)
    if (rst)
        adr <= 4'h0;
    else
        if (stb_i) // | (!stb_i & last_cycle!=ws)) // for !stb_i restart with adr_i +1, only inc once
            case (bte_i)
            2'b01: adr[3:0] <= {to_adr[3:2],to_adr[1:0] + 2'd1};
            2'b10: adr[3:0] <= {to_adr[3],to_adr[2:0] + 3'd1};
            default: adr[3:0] <= to_adr + 4'd1;
            endcase
        else
            adr <= to_adr[3:0];
end
endgenerate

generate
if (adr_width > max_burst_width) begin : pass_through
    assign adr_o[adr_width-1:max_burst_width] = adr_i[adr_width-1:max_burst_width];
end
endgenerate

endmodule
`endif

`ifdef WB_B4_EOC
`define MODULE wb_b4_eoc
module `BASE`MODULE ( cyc_i, stb_i, stall_o, ack_o, busy, eoc, clk, rst);
`undef MODULE
input cyc_i, stb_i, ack_o;
output busy, eoc;
input clk, rst;

`define MODULE cnt_bin_ce_rew_zq_l1
`BASE`MODULE # ( .length(4), level1_value(1))
cnt0 (
    .cke(), .rew(), .zq(), .level1(), .rst(), clk);
`undef MODULE

endmodule
`endif

`ifdef WB3WB3_BRIDGE
// async wb3 - wb3 bridge
`timescale 1ns/1ns
`define MODULE wb3wb3_bridge
module `BASE`MODULE ( 
`undef MODULE
	// wishbone slave side
	wbs_dat_i, wbs_adr_i, wbs_sel_i, wbs_bte_i, wbs_cti_i, wbs_we_i, wbs_cyc_i, wbs_stb_i, wbs_dat_o, wbs_ack_o, wbs_clk, wbs_rst,
	// wishbone master side
	wbm_dat_o, wbm_adr_o, wbm_sel_o, wbm_bte_o, wbm_cti_o, wbm_we_o, wbm_cyc_o, wbm_stb_o, wbm_dat_i, wbm_ack_i, wbm_clk, wbm_rst);

parameter style = "FIFO"; // valid: simple, FIFO
parameter addr_width = 4;

input [31:0] wbs_dat_i;
input [31:2] wbs_adr_i;
input [3:0]  wbs_sel_i;
input [1:0]  wbs_bte_i;
input [2:0]  wbs_cti_i;
input wbs_we_i, wbs_cyc_i, wbs_stb_i;
output [31:0] wbs_dat_o;
output wbs_ack_o;
input wbs_clk, wbs_rst;

output [31:0] wbm_dat_o;
output reg [31:2] wbm_adr_o;
output [3:0]  wbm_sel_o;
output reg [1:0]  wbm_bte_o;
output reg [2:0]  wbm_cti_o;
output reg wbm_we_o;
output wbm_cyc_o;
output wbm_stb_o;
input [31:0]  wbm_dat_i;
input wbm_ack_i;
input wbm_clk, wbm_rst;

// bte
parameter linear       = 2'b00;
parameter wrap4        = 2'b01;
parameter wrap8        = 2'b10;
parameter wrap16       = 2'b11;
// cti
parameter classic      = 3'b000;
parameter incburst     = 3'b010;
parameter endofburst   = 3'b111;

localparam wbs_adr  = 1'b0;
localparam wbs_data = 1'b1;

localparam wbm_adr0      = 2'b00;
localparam wbm_adr1      = 2'b01;
localparam wbm_data      = 2'b10;
localparam wbm_data_wait = 2'b11;

reg [1:0] wbs_bte_reg;
reg wbs;
wire wbs_eoc_alert, wbm_eoc_alert;
reg wbs_eoc, wbm_eoc;
reg [1:0] wbm;

wire [1:16] wbs_count, wbm_count;

wire [35:0] a_d, a_q, b_d, b_q;
wire a_wr, a_rd, a_fifo_full, a_fifo_empty, b_wr, b_rd, b_fifo_full, b_fifo_empty;
reg a_rd_reg;
wire b_rd_adr, b_rd_data;
wire b_rd_data_reg;
wire [35:0] temp;

`define WE 5
`define BTE 4:3
`define CTI 2:0  

assign wbs_eoc_alert = (wbs_bte_reg==wrap4 & wbs_count[3]) | (wbs_bte_reg==wrap8 & wbs_count[7]) | (wbs_bte_reg==wrap16 & wbs_count[15]);
always @ (posedge wbs_clk or posedge wbs_rst)
if (wbs_rst)
	wbs_eoc <= 1'b0;
else
	if (wbs==wbs_adr & wbs_stb_i & !a_fifo_full)
		wbs_eoc <= (wbs_bte_i==linear) | (wbs_cti_i==3'b111);
	else if (wbs_eoc_alert & (a_rd | a_wr))
		wbs_eoc <= 1'b1;

`define MODULE cnt_shreg_ce_clear
`BASE`MODULE # ( .length(16))
`undef MODULE
    cnt0 (
        .cke(wbs_ack_o),
        .clear(wbs_eoc),
        .q(wbs_count),
        .rst(wbs_rst),
        .clk(wbs_clk));

always @ (posedge wbs_clk or posedge wbs_rst)
if (wbs_rst)
	wbs <= wbs_adr;
else
	if ((wbs==wbs_adr) & wbs_cyc_i & wbs_stb_i & a_fifo_empty)
		wbs <= wbs_data;
	else if (wbs_eoc & wbs_ack_o)
		wbs <= wbs_adr;

// wbs FIFO
assign a_d = (wbs==wbs_adr) ? {wbs_adr_i[31:2],wbs_we_i,((wbs_cti_i==3'b111) ? {2'b00,3'b000} : {wbs_bte_i,wbs_cti_i})} : {wbs_dat_i,wbs_sel_i};
assign a_wr = (wbs==wbs_adr)  ? wbs_cyc_i & wbs_stb_i & a_fifo_empty :
              (wbs==wbs_data) ? wbs_we_i  & wbs_stb_i & !a_fifo_full :
              1'b0;
assign a_rd = !a_fifo_empty;
always @ (posedge wbs_clk or posedge wbs_rst)
if (wbs_rst)
	a_rd_reg <= 1'b0;
else
	a_rd_reg <= a_rd;
assign wbs_ack_o = a_rd_reg | (a_wr & wbs==wbs_data);

assign wbs_dat_o = a_q[35:4];
	
always @ (posedge wbs_clk or posedge wbs_rst)
if (wbs_rst)
	wbs_bte_reg <= 2'b00;
else
	wbs_bte_reg <= wbs_bte_i;

// wbm FIFO
assign wbm_eoc_alert = (wbm_bte_o==wrap4 & wbm_count[3]) | (wbm_bte_o==wrap8 & wbm_count[7]) | (wbm_bte_o==wrap16 & wbm_count[15]);
always @ (posedge wbm_clk or posedge wbm_rst)
if (wbm_rst)
	wbm_eoc <= 1'b0;
else
	if (wbm==wbm_adr0 & !b_fifo_empty)
		wbm_eoc <= b_q[`BTE] == linear;
	else if (wbm_eoc_alert & wbm_ack_i)
		wbm_eoc <= 1'b1;
	
always @ (posedge wbm_clk or posedge wbm_rst)
if (wbm_rst)
	wbm <= wbm_adr0;
else
/*
    if ((wbm==wbm_adr0 & !b_fifo_empty) |
        (wbm==wbm_adr1 & !b_fifo_empty & wbm_we_o) |
        (wbm==wbm_adr1 & !wbm_we_o) |
        (wbm==wbm_data & wbm_ack_i & wbm_eoc))
        wbm <= {wbm[0],!(wbm[1] ^ wbm[0])};  // count sequence 00,01,10
*/
    case (wbm)
    wbm_adr0:
        if (!b_fifo_empty)
            wbm <= wbm_adr1;
    wbm_adr1:
        if (!wbm_we_o | (!b_fifo_empty & wbm_we_o))
            wbm <= wbm_data;
    wbm_data:
        if (wbm_ack_i & wbm_eoc)
            wbm <= wbm_adr0;
        else if (b_fifo_empty & wbm_we_o & wbm_ack_i)
            wbm <= wbm_data_wait;
    wbm_data_wait:
        if (!b_fifo_empty)
            wbm <= wbm_data;
    endcase

assign b_d = {wbm_dat_i,4'b1111};
assign b_wr = !wbm_we_o & wbm_ack_i;
assign b_rd_adr  = (wbm==wbm_adr0 & !b_fifo_empty);
assign b_rd_data = (wbm==wbm_adr1 & !b_fifo_empty & wbm_we_o) ? 1'b1 : // b_q[`WE]
                   (wbm==wbm_data & !b_fifo_empty & wbm_we_o & wbm_ack_i & !wbm_eoc) ? 1'b1 :
                   (wbm==wbm_data_wait & !b_fifo_empty) ? 1'b1 : 
                   1'b0;
assign b_rd = b_rd_adr | b_rd_data;

`define MODULE dff
`BASE`MODULE dff1 ( .d(b_rd_data), .q(b_rd_data_reg), .clk(wbm_clk), .rst(wbm_rst));
`undef MODULE
`define MODULE dff_ce
`BASE`MODULE # ( .width(36)) dff2 ( .d(b_q), .ce(b_rd_data_reg), .q(temp), .clk(wbm_clk), .rst(wbm_rst));
`undef MODULE

assign {wbm_dat_o,wbm_sel_o} = (b_rd_data_reg) ? b_q : temp;

`define MODULE cnt_shreg_ce_clear
`BASE`MODULE # ( .length(16))
`undef MODULE
    cnt1 (
        .cke(wbm_ack_i),
        .clear(wbm_eoc),
        .q(wbm_count),
        .rst(wbm_rst),
        .clk(wbm_clk));

assign wbm_cyc_o = (wbm==wbm_data | wbm==wbm_data_wait);
assign wbm_stb_o = (wbm==wbm_data);

always @ (posedge wbm_clk or posedge wbm_rst)
if (wbm_rst)
	{wbm_adr_o,wbm_we_o,wbm_bte_o,wbm_cti_o} <= {30'h0,1'b0,linear,classic};
else begin
	if (wbm==wbm_adr0 & !b_fifo_empty)
		{wbm_adr_o,wbm_we_o,wbm_bte_o,wbm_cti_o} <= b_q;
	else if (wbm_eoc_alert & wbm_ack_i)
		wbm_cti_o <= endofburst;
end	

//async_fifo_dw_simplex_top
`define MODULE fifo_2r2w_async_simplex
`BASE`MODULE
`undef MODULE
# ( .data_width(36), .addr_width(addr_width))
fifo (
    // a side
    .a_d(a_d), 
    .a_wr(a_wr), 
    .a_fifo_full(a_fifo_full),
    .a_q(a_q),
    .a_rd(a_rd),
    .a_fifo_empty(a_fifo_empty), 
    .a_clk(wbs_clk), 
    .a_rst(wbs_rst),
    // b side
    .b_d(b_d), 
    .b_wr(b_wr), 
    .b_fifo_full(b_fifo_full),
    .b_q(b_q), 
    .b_rd(b_rd), 
    .b_fifo_empty(b_fifo_empty), 
    .b_clk(wbm_clk), 
    .b_rst(wbm_rst)	
    );
    
endmodule
`undef WE
`undef BTE
`undef CTI
`endif

`ifdef WB3AVALON_BRIDGE
`define MODULE wb3avalon_bridge
module `BASE`MODULE ( 
`undef MODULE
	// wishbone slave side
	wbs_dat_i, wbs_adr_i, wbs_sel_i, wbs_bte_i, wbs_cti_i, wbs_we_i, wbs_cyc_i, wbs_stb_i, wbs_dat_o, wbs_ack_o, wbs_clk, wbs_rst,
	// avalon master side
	readdata, readdatavalid, address, read, be, write, burstcount, writedata, waitrequest, beginbursttransfer, clk, rst);

parameter linewrapburst = 1'b0;

input [31:0] wbs_dat_i;
input [31:2] wbs_adr_i;
input [3:0]  wbs_sel_i;
input [1:0]  wbs_bte_i;
input [2:0]  wbs_cti_i;
input wbs_we_i;
input wbs_cyc_i;
input wbs_stb_i;
output [31:0] wbs_dat_o;
output wbs_ack_o;
input wbs_clk, wbs_rst;

input [31:0] readdata;
output [31:0] writedata;
output [31:2] address;
output [3:0]  be;
output write;
output read;
output beginbursttransfer;
output [3:0] burstcount;
input readdatavalid;
input waitrequest;
input clk;
input rst;

wire [1:0] wbm_bte_o;
wire [2:0] wbm_cti_o;
wire wbm_we_o, wbm_cyc_o, wbm_stb_o, wbm_ack_i;
reg last_cyc;
reg [3:0] counter;
reg read_busy;

always @ (posedge clk or posedge rst)
if (rst)
    last_cyc <= 1'b0;
else
    last_cyc <= wbm_cyc_o;

always @ (posedge clk or posedge rst)
if (rst)
    read_busy <= 1'b0;
else
    if (read & !waitrequest)
        read_busy <= 1'b1;
    else if (wbm_ack_i & wbm_cti_o!=3'b010)
        read_busy <= 1'b0;
assign read = wbm_cyc_o & wbm_stb_o & !wbm_we_o & !read_busy;

assign beginbursttransfer = (!last_cyc & wbm_cyc_o) & wbm_cti_o==3'b010;
assign burstcount = (wbm_bte_o==2'b01) ? 4'd4 :
                    (wbm_bte_o==2'b10) ? 4'd8 :
                    (wbm_bte_o==2'b11) ? 4'd16:
                    4'd1;
assign wbm_ack_i = (readdatavalid) | (write & !waitrequest);

always @ (posedge clk or posedge rst)
if (rst) begin
    counter <= 4'd0;
end else
    if (wbm_we_o) begin
        if (!waitrequest & !last_cyc & wbm_cyc_o) begin
            counter <= burstcount -4'd1;
        end else if (waitrequest & !last_cyc & wbm_cyc_o) begin
            counter <= burstcount;
        end else if (!waitrequest & wbm_stb_o) begin
            counter <= counter - 4'd1;
        end
    end 
assign write = wbm_cyc_o & wbm_stb_o & wbm_we_o & counter!=4'd0;

`define MODULE wb3wb3_bridge
`BASE`MODULE wbwb3inst (
`undef MODULE
    // wishbone slave side
    .wbs_dat_i(wbs_dat_i),
    .wbs_adr_i(wbs_adr_i),
    .wbs_sel_i(wbs_sel_i),
    .wbs_bte_i(wbs_bte_i),
    .wbs_cti_i(wbs_cti_i),
    .wbs_we_i(wbs_we_i),
    .wbs_cyc_i(wbs_cyc_i),
    .wbs_stb_i(wbs_stb_i),
    .wbs_dat_o(wbs_dat_o),
    .wbs_ack_o(wbs_ack_o),
    .wbs_clk(wbs_clk),
    .wbs_rst(wbs_rst),
    // wishbone master side
    .wbm_dat_o(writedata),
    .wbm_adr_o(address),
    .wbm_sel_o(be),
    .wbm_bte_o(wbm_bte_o),
    .wbm_cti_o(wbm_cti_o),
    .wbm_we_o(wbm_we_o),
    .wbm_cyc_o(wbm_cyc_o),
    .wbm_stb_o(wbm_stb_o),
    .wbm_dat_i(readdata),
    .wbm_ack_i(wbm_ack_i),
    .wbm_clk(clk),
    .wbm_rst(rst));


endmodule
`endif

`ifdef WB_ARBITER
`define MODULE wb_arbiter
module `BASE`MODULE (
`undef MODULE
    wbm_dat_o, wbm_adr_o, wbm_sel_o, wbm_cti_o, wbm_bte_o, wbm_we_o, wbm_stb_o, wbm_cyc_o,
    wbm_dat_i, wbm_stall_i, wbm_ack_i, wbm_err_i, wbm_rty_i,
    wbs_dat_i, wbs_adr_i, wbs_sel_i, wbs_cti_i, wbs_bte_i, wbs_we_i, wbs_stb_i, wbs_cyc_i,
    wbs_dat_o, wbs_stall_o, wbs_ack_o, wbs_err_o, wbs_rty_o,
    wb_clk, wb_rst
);

parameter nr_of_ports = 3;
parameter adr_size = 26;
parameter adr_lo   = 2;
parameter dat_size = 32;
parameter sel_size = dat_size/8;

localparam aw = (adr_size - adr_lo) * nr_of_ports;
localparam dw = dat_size * nr_of_ports;
localparam sw = sel_size * nr_of_ports;
localparam cw = 3 * nr_of_ports;
localparam bw = 2 * nr_of_ports;

input  [dw-1:0] wbm_dat_o;
input  [aw-1:0] wbm_adr_o;
input  [sw-1:0] wbm_sel_o;
input  [cw-1:0] wbm_cti_o;
input  [bw-1:0] wbm_bte_o;
input  [nr_of_ports-1:0] wbm_we_o, wbm_stb_o, wbm_cyc_o;
output [dw-1:0] wbm_dat_i;
output [nr_of_ports-1:0] wbm_stall_o, wbm_ack_i, wbm_err_i, wbm_rty_i;

output [dat_size-1:0] wbs_dat_i;
output [adr_size-1:adr_lo] wbs_adr_i;
output [sel_size-1:0] wbs_sel_i;
output [2:0] wbs_cti_i;
output [1:0] wbs_bte_i;
output wbs_we_i, wbs_stb_i, wbs_cyc_i;
input  [dat_size-1:0] wbs_dat_o;
input  wbs_stall_o, wbs_ack_o, wbs_err_o, wbs_rty_o;

input wb_clk, wb_rst;

reg  [nr_of_ports-1:0] select;
wire [nr_of_ports-1:0] state;
wire [nr_of_ports-1:0] eoc; // end-of-cycle
wire [nr_of_ports-1:0] sel;
wire idle;

genvar i;

assign idle = !(|state);

generate
if (nr_of_ports == 2) begin

    wire [2:0] wbm1_cti_o, wbm0_cti_o;

    assign {wbm1_cti_o,wbm0_cti_o} = wbm_cti_o;
    
    //assign select = (idle) ? {wbm_cyc_o[1],!wbm_cyc_o[1] & wbm_cyc_o[0]} : {nr_of_ports{1'b0}};
    
    always @ (idle or wbm_cyc_o)
    if (idle)
        casex (wbm_cyc_o)
        2'b1x : select = 2'b10;
        2'b01 : select = 2'b01;
        default : select = {nr_of_ports{1'b0}};
        endcase
    else
        select = {nr_of_ports{1'b0}};
        
    assign eoc[1] = (wbm_ack_i[1] & (wbm1_cti_o == 3'b000 | wbm1_cti_o == 3'b111)) | !wbm_cyc_o[1];
    assign eoc[0] = (wbm_ack_i[0] & (wbm0_cti_o == 3'b000 | wbm0_cti_o == 3'b111)) | !wbm_cyc_o[0];
    
end
endgenerate

generate
if (nr_of_ports == 3) begin

    wire [2:0] wbm2_cti_o, wbm1_cti_o, wbm0_cti_o;

    assign {wbm2_cti_o,wbm1_cti_o,wbm0_cti_o} = wbm_cti_o;
    
    always @ (idle or wbm_cyc_o)
    if (idle)
        casex (wbm_cyc_o)
        3'b1xx : select = 3'b100;
        3'b01x : select = 3'b010;
        3'b001 : select = 3'b001;
        default : select = {nr_of_ports{1'b0}};
        endcase
    else
        select = {nr_of_ports{1'b0}};

//    assign select = (idle) ? {wbm_cyc_o[2],!wbm_cyc_o[2] & wbm_cyc_o[1],wbm_cyc_o[2:1]==2'b00 & wbm_cyc_o[0]} : {nr_of_ports{1'b0}};
    assign eoc[2] = (wbm_ack_i[2] & (wbm2_cti_o == 3'b000 | wbm2_cti_o == 3'b111)) | !wbm_cyc_o[2];
    assign eoc[1] = (wbm_ack_i[1] & (wbm1_cti_o == 3'b000 | wbm1_cti_o == 3'b111)) | !wbm_cyc_o[1];
    assign eoc[0] = (wbm_ack_i[0] & (wbm0_cti_o == 3'b000 | wbm0_cti_o == 3'b111)) | !wbm_cyc_o[0];
    
end
endgenerate

generate
if (nr_of_ports == 4) begin

    wire [2:0] wbm3_cti_o, wbm2_cti_o, wbm1_cti_o, wbm0_cti_o;

    assign {wbm3_cti_o, wbm2_cti_o,wbm1_cti_o,wbm0_cti_o} = wbm_cti_o;
    
    //assign select = (idle) ? {wbm_cyc_o[3],!wbm_cyc_o[3] & wbm_cyc_o[2],wbm_cyc_o[3:2]==2'b00 & wbm_cyc_o[1],wbm_cyc_o[3:1]==3'b000 & wbm_cyc_o[0]} : {nr_of_ports{1'b0}};
    
    always @ (idle or wbm_cyc_o)
    if (idle)
        casex (wbm_cyc_o)
        4'b1xxx : select = 4'b1000;
        4'b01xx : select = 4'b0100;
        4'b001x : select = 4'b0010;
        4'b0001 : select = 4'b0001;
        default : select = {nr_of_ports{1'b0}};
        endcase
    else
        select = {nr_of_ports{1'b0}};
    
    assign eoc[3] = (wbm_ack_i[3] & (wbm3_cti_o == 3'b000 | wbm3_cti_o == 3'b111)) | !wbm_cyc_o[3];
    assign eoc[2] = (wbm_ack_i[2] & (wbm2_cti_o == 3'b000 | wbm2_cti_o == 3'b111)) | !wbm_cyc_o[2];
    assign eoc[1] = (wbm_ack_i[1] & (wbm1_cti_o == 3'b000 | wbm1_cti_o == 3'b111)) | !wbm_cyc_o[1];
    assign eoc[0] = (wbm_ack_i[0] & (wbm0_cti_o == 3'b000 | wbm0_cti_o == 3'b111)) | !wbm_cyc_o[0];
    
end
endgenerate

generate
if (nr_of_ports == 5) begin

    wire [2:0] wbm4_cti_o, wbm3_cti_o, wbm2_cti_o, wbm1_cti_o, wbm0_cti_o;

    assign {wbm4_cti_o, wbm3_cti_o, wbm2_cti_o,wbm1_cti_o,wbm0_cti_o} = wbm_cti_o;
    
    //assign select = (idle) ? {wbm_cyc_o[3],!wbm_cyc_o[3] & wbm_cyc_o[2],wbm_cyc_o[3:2]==2'b00 & wbm_cyc_o[1],wbm_cyc_o[3:1]==3'b000 & wbm_cyc_o[0]} : {nr_of_ports{1'b0}};
    
    always @ (idle or wbm_cyc_o)
    if (idle)
        casex (wbm_cyc_o)
        5'b1xxxx : select = 5'b10000;
        5'b01xxx : select = 5'b01000;
        5'b001xx : select = 5'b00100;
        5'b0001x : select = 5'b00010;
        5'b00001 : select = 5'b00001;
        default : select = {nr_of_ports{1'b0}};
        endcase
    else
        select = {nr_of_ports{1'b0}};
    
    assign eoc[4] = (wbm_ack_i[4] & (wbm4_cti_o == 3'b000 | wbm4_cti_o == 3'b111)) | !wbm_cyc_o[4];
    assign eoc[3] = (wbm_ack_i[3] & (wbm3_cti_o == 3'b000 | wbm3_cti_o == 3'b111)) | !wbm_cyc_o[3];
    assign eoc[2] = (wbm_ack_i[2] & (wbm2_cti_o == 3'b000 | wbm2_cti_o == 3'b111)) | !wbm_cyc_o[2];
    assign eoc[1] = (wbm_ack_i[1] & (wbm1_cti_o == 3'b000 | wbm1_cti_o == 3'b111)) | !wbm_cyc_o[1];
    assign eoc[0] = (wbm_ack_i[0] & (wbm0_cti_o == 3'b000 | wbm0_cti_o == 3'b111)) | !wbm_cyc_o[0];
    
end
endgenerate

generate
if (nr_of_ports == 6) begin

    wire [2:0] wbm5_cti_o, wbm4_cti_o, wbm3_cti_o, wbm2_cti_o, wbm1_cti_o, wbm0_cti_o;

    assign {wbm5_cti_o, wbm4_cti_o, wbm3_cti_o, wbm2_cti_o,wbm1_cti_o,wbm0_cti_o} = wbm_cti_o;
    
    //assign select = (idle) ? {wbm_cyc_o[3],!wbm_cyc_o[3] & wbm_cyc_o[2],wbm_cyc_o[3:2]==2'b00 & wbm_cyc_o[1],wbm_cyc_o[3:1]==3'b000 & wbm_cyc_o[0]} : {nr_of_ports{1'b0}};
    
    always @ (idle or wbm_cyc_o)
    if (idle)
        casex (wbm_cyc_o)
        6'b1xxxxx : select = 6'b100000;
        6'b01xxxx : select = 6'b010000;
        6'b001xxx : select = 6'b001000;
        6'b0001xx : select = 6'b000100;
        6'b00001x : select = 6'b000010;
        6'b000001 : select = 6'b000001;
        default : select = {nr_of_ports{1'b0}};
        endcase
    else
        select = {nr_of_ports{1'b0}};
    
    assign eoc[5] = (wbm_ack_i[5] & (wbm5_cti_o == 3'b000 | wbm5_cti_o == 3'b111)) | !wbm_cyc_o[5];
    assign eoc[4] = (wbm_ack_i[4] & (wbm4_cti_o == 3'b000 | wbm4_cti_o == 3'b111)) | !wbm_cyc_o[4];
    assign eoc[3] = (wbm_ack_i[3] & (wbm3_cti_o == 3'b000 | wbm3_cti_o == 3'b111)) | !wbm_cyc_o[3];
    assign eoc[2] = (wbm_ack_i[2] & (wbm2_cti_o == 3'b000 | wbm2_cti_o == 3'b111)) | !wbm_cyc_o[2];
    assign eoc[1] = (wbm_ack_i[1] & (wbm1_cti_o == 3'b000 | wbm1_cti_o == 3'b111)) | !wbm_cyc_o[1];
    assign eoc[0] = (wbm_ack_i[0] & (wbm0_cti_o == 3'b000 | wbm0_cti_o == 3'b111)) | !wbm_cyc_o[0];
    
end
endgenerate

generate
if (nr_of_ports == 7) begin

    wire [2:0] wbm6_cti_o, wbm5_cti_o, wbm4_cti_o, wbm3_cti_o, wbm2_cti_o, wbm1_cti_o, wbm0_cti_o;

    assign {wbm6_cti_o, wbm5_cti_o, wbm4_cti_o, wbm3_cti_o, wbm2_cti_o,wbm1_cti_o,wbm0_cti_o} = wbm_cti_o;
    
    //assign select = (idle) ? {wbm_cyc_o[3],!wbm_cyc_o[3] & wbm_cyc_o[2],wbm_cyc_o[3:2]==2'b00 & wbm_cyc_o[1],wbm_cyc_o[3:1]==3'b000 & wbm_cyc_o[0]} : {nr_of_ports{1'b0}};
    
    always @ (idle or wbm_cyc_o)
    if (idle)
        casex (wbm_cyc_o)
        7'b1xxxxxx : select = 7'b1000000;
        7'b01xxxxx : select = 7'b0100000;
        7'b001xxxx : select = 7'b0010000;
        7'b0001xxx : select = 7'b0001000;
        7'b00001xx : select = 7'b0000100;
        7'b000001x : select = 7'b0000010;
        7'b0000001 : select = 7'b0000001;
        default : select = {nr_of_ports{1'b0}};
        endcase
    else
        select = {nr_of_ports{1'b0}};
    
    assign eoc[6] = (wbm_ack_i[6] & (wbm6_cti_o == 3'b000 | wbm6_cti_o == 3'b111)) | !wbm_cyc_o[6];
    assign eoc[5] = (wbm_ack_i[5] & (wbm5_cti_o == 3'b000 | wbm5_cti_o == 3'b111)) | !wbm_cyc_o[5];
    assign eoc[4] = (wbm_ack_i[4] & (wbm4_cti_o == 3'b000 | wbm4_cti_o == 3'b111)) | !wbm_cyc_o[4];
    assign eoc[3] = (wbm_ack_i[3] & (wbm3_cti_o == 3'b000 | wbm3_cti_o == 3'b111)) | !wbm_cyc_o[3];
    assign eoc[2] = (wbm_ack_i[2] & (wbm2_cti_o == 3'b000 | wbm2_cti_o == 3'b111)) | !wbm_cyc_o[2];
    assign eoc[1] = (wbm_ack_i[1] & (wbm1_cti_o == 3'b000 | wbm1_cti_o == 3'b111)) | !wbm_cyc_o[1];
    assign eoc[0] = (wbm_ack_i[0] & (wbm0_cti_o == 3'b000 | wbm0_cti_o == 3'b111)) | !wbm_cyc_o[0];
    
end
endgenerate

generate
if (nr_of_ports == 8) begin

    wire [2:0] wbm7_cti_o, wbm6_cti_o, wbm5_cti_o, wbm4_cti_o, wbm3_cti_o, wbm2_cti_o, wbm1_cti_o, wbm0_cti_o;

    assign {wbm7_cti_o, wbm6_cti_o, wbm5_cti_o, wbm4_cti_o, wbm3_cti_o, wbm2_cti_o,wbm1_cti_o,wbm0_cti_o} = wbm_cti_o;
    
    //assign select = (idle) ? {wbm_cyc_o[3],!wbm_cyc_o[3] & wbm_cyc_o[2],wbm_cyc_o[3:2]==2'b00 & wbm_cyc_o[1],wbm_cyc_o[3:1]==3'b000 & wbm_cyc_o[0]} : {nr_of_ports{1'b0}};
    
    always @ (idle or wbm_cyc_o)
    if (idle)
        casex (wbm_cyc_o)
        8'b1xxxxxxx : select = 8'b10000000;
        8'b01xxxxxx : select = 8'b01000000;
        8'b001xxxxx : select = 8'b00100000;
        8'b0001xxxx : select = 8'b00010000;
        8'b00001xxx : select = 8'b00001000;
        8'b000001xx : select = 8'b00000100;
        8'b0000001x : select = 8'b00000010;
        8'b00000001 : select = 8'b00000001;
        default : select = {nr_of_ports{1'b0}};
        endcase
    else
        select = {nr_of_ports{1'b0}};
    
    assign eoc[7] = (wbm_ack_i[7] & (wbm7_cti_o == 3'b000 | wbm7_cti_o == 3'b111)) | !wbm_cyc_o[7];
    assign eoc[6] = (wbm_ack_i[6] & (wbm6_cti_o == 3'b000 | wbm6_cti_o == 3'b111)) | !wbm_cyc_o[6];
    assign eoc[5] = (wbm_ack_i[5] & (wbm5_cti_o == 3'b000 | wbm5_cti_o == 3'b111)) | !wbm_cyc_o[5];
    assign eoc[4] = (wbm_ack_i[4] & (wbm4_cti_o == 3'b000 | wbm4_cti_o == 3'b111)) | !wbm_cyc_o[4];
    assign eoc[3] = (wbm_ack_i[3] & (wbm3_cti_o == 3'b000 | wbm3_cti_o == 3'b111)) | !wbm_cyc_o[3];
    assign eoc[2] = (wbm_ack_i[2] & (wbm2_cti_o == 3'b000 | wbm2_cti_o == 3'b111)) | !wbm_cyc_o[2];
    assign eoc[1] = (wbm_ack_i[1] & (wbm1_cti_o == 3'b000 | wbm1_cti_o == 3'b111)) | !wbm_cyc_o[1];
    assign eoc[0] = (wbm_ack_i[0] & (wbm0_cti_o == 3'b000 | wbm0_cti_o == 3'b111)) | !wbm_cyc_o[0];
    
end
endgenerate

generate
for (i=0;i<nr_of_ports;i=i+1) begin : spr0
`define MODULE spr
    `BASE`MODULE sr0( .sp(select[i]), .r(eoc[i]), .q(state[i]), .clk(wb_clk), .rst(wb_rst));
`undef MODULE
end
endgenerate

    assign sel = select | state;

`define MODULE mux_andor
    `BASE`MODULE # ( .nr_of_ports(nr_of_ports), .width(32)) mux0 ( .a(wbm_dat_o), .sel(sel), .dout(wbs_dat_i));
    `BASE`MODULE # ( .nr_of_ports(nr_of_ports), .width(adr_size-adr_lo)) mux1 ( .a(wbm_adr_o), .sel(sel), .dout(wbs_adr_i));
    `BASE`MODULE # ( .nr_of_ports(nr_of_ports), .width(sel_size)) mux2 ( .a(wbm_sel_o), .sel(sel), .dout(wbs_sel_i));
    `BASE`MODULE # ( .nr_of_ports(nr_of_ports), .width(3)) mux3 ( .a(wbm_cti_o), .sel(sel), .dout(wbs_cti_i));
    `BASE`MODULE # ( .nr_of_ports(nr_of_ports), .width(2)) mux4 ( .a(wbm_bte_o), .sel(sel), .dout(wbs_bte_i));
    `BASE`MODULE # ( .nr_of_ports(nr_of_ports), .width(1)) mux5 ( .a(wbm_we_o), .sel(sel), .dout(wbs_we_i));
    `BASE`MODULE # ( .nr_of_ports(nr_of_ports), .width(1)) mux6 ( .a(wbm_stb_o), .sel(sel), .dout(wbs_stb_i));
`undef MODULE
    assign wbs_cyc_i = |sel;
    
    assign wbm_dat_i = {nr_of_ports{wbs_dat_o}};
    assign wbm_ack_i = {nr_of_ports{wbs_ack_o}} & sel;
    assign wbm_err_i = {nr_of_ports{wbs_err_o}} & sel;
    assign wbm_rty_i = {nr_of_ports{wbs_rty_o}} & sel;

endmodule
`endif

`ifdef WB_RAM
// WB RAM with byte enable
`define MODULE wb_ram
module `BASE`MODULE (
`undef MODULE
    wbs_dat_i, wbs_adr_i, wbs_cti_i, wbs_bte_i, wbs_sel_i, wbs_we_i, wbs_stb_i, wbs_cyc_i, 
    wbs_dat_o, wbs_ack_o, wbs_stall_o, wb_clk, wb_rst);

parameter adr_width = 16;
parameter mem_size = 1<<adr_width;
parameter dat_width = 32;
parameter max_burst_width = 4; // only used for B3
parameter mode = "B3"; // valid options: B3, B4
parameter memory_init = 1;
parameter memory_file = "vl_ram.vmem";

input [dat_width-1:0] wbs_dat_i;
input [adr_width-1:0] wbs_adr_i;
input [2:0] wbs_cti_i;
input [1:0] wbs_bte_i;
input [dat_width/8-1:0] wbs_sel_i;
input wbs_we_i, wbs_stb_i, wbs_cyc_i;
output [dat_width-1:0] wbs_dat_o;
output wbs_ack_o;
output wbs_stall_o;
input wb_clk, wb_rst;

wire [adr_width-1:0] adr;
wire we;

generate
if (mode=="B3") begin : B3_inst
`define MODULE wb_adr_inc 
`BASE`MODULE # ( .adr_width(adr_width), .max_burst_width(max_burst_width)) adr_inc0 (
    .cyc_i(wbs_cyc_i),
    .stb_i(wbs_stb_i),
    .cti_i(wbs_cti_i),
    .bte_i(wbs_bte_i),
    .adr_i(wbs_adr_i),
    .we_i(wbs_we_i),
    .ack_o(wbs_ack_o),
    .adr_o(adr),
    .clk(wb_clk),
    .rst(wb_rst));
`undef MODULE
assign we = wbs_we_i & wbs_ack_o;
end else if (mode=="B4") begin : B4_inst
reg wbs_ack_o_reg;
always @ (posedge wb_clk or posedge wb_rst)
    if (wb_rst)
        wbs_ack_o_reg <= 1'b0;
    else
        wbs_ack_o_reg <= wbs_stb_i & wbs_cyc_i;
assign wbs_ack_o = wbs_ack_o_reg;
assign wbs_stall_o = 1'b0;
assign adr = wbs_adr_i;
assign we = wbs_we_i & wbs_cyc_i & wbs_stb_i;
end
endgenerate

`define MODULE ram_be
`BASE`MODULE # (
    .data_width(dat_width),
    .addr_width(adr_width),
    .mem_size(mem_size),
    .memory_init(memory_init),
    .memory_file(memory_file))
ram0(
`undef MODULE
    .d(wbs_dat_i),
    .adr(adr),
    .be(wbs_sel_i),
    .we(we),
    .q(wbs_dat_o),
    .clk(wb_clk)
);

endmodule
`endif

`ifdef WB_SHADOW_RAM
// A wishbone compliant RAM module that can be placed in front of other memory controllers
`define MODULE wb_shadow_ram
module `BASE`MODULE (
`undef MODULE
    wbs_dat_i, wbs_adr_i, wbs_cti_i, wbs_bte_i, wbs_sel_i, wbs_we_i, wbs_stb_i, wbs_cyc_i, 
    wbs_dat_o, wbs_ack_o, wbs_stall_o,
    wbm_dat_o, wbm_adr_o, wbm_cti_o, wbm_bte_o, wbm_sel_o, wbm_we_o, wbm_stb_o, wbm_cyc_o, 
    wbm_dat_i, wbm_ack_i, wbm_stall_i,
    wb_clk, wb_rst);

parameter dat_width = 32;
parameter mode = "B4";
parameter max_burst_width = 4; // only used for B3

parameter shadow_mem_adr_width = 10;
parameter shadow_mem_size = 1024;
parameter shadow_mem_init = 2;
parameter shadow_mem_file = "vl_ram.v";

parameter main_mem_adr_width = 24;

input [dat_width-1:0] wbs_dat_i;
input [main_mem_adr_width-1:0] wbs_adr_i;
input [2:0] wbs_cti_i;
input [1:0] wbs_bte_i;
input [dat_width/8-1:0] wbs_sel_i;
input wbs_we_i, wbs_stb_i, wbs_cyc_i;
output [dat_width-1:0] wbs_dat_o;
output wbs_ack_o;
output wbs_stall_o;

output [dat_width-1:0] wbm_dat_o;
output [main_mem_adr_width-1:0] wbm_adr_o;
output [2:0] wbm_cti_o;
output [1:0] wbm_bte_o;
output [dat_width/8-1:0] wbm_sel_o;
output wbm_we_o, wbm_stb_o, wbm_cyc_o;
input [dat_width-1:0] wbm_dat_i;
input wbm_ack_i, wbm_stall_i;

input wb_clk, wb_rst;

generate
if (shadow_mem_size>0) begin : shadow_ram_inst

wire cyc;
wire [dat_width-1:0] dat;
wire stall, ack;

assign cyc = wbs_cyc_i & (wbs_adr_i<=shadow_mem_size);
`define MODULE wb_ram
`BASE`MODULE # (
    .dat_width(dat_width),
    .adr_width(shadow_mem_adr_width),
    .mem_size(shadow_mem_size),
    .memory_init(shadow_mem_init),
    .memory_file(shadow_mem_file),
    .mode(mode))
shadow_mem0 (
    .wbs_dat_i(wbs_dat_i),
    .wbs_adr_i(wbs_adr_i[shadow_mem_adr_width-1:0]),
    .wbs_sel_i(wbs_sel_i),
    .wbs_we_i (wbs_we_i),
    .wbs_bte_i(wbs_bte_i),
    .wbs_cti_i(wbs_cti_i),
    .wbs_stb_i(wbs_stb_i),
    .wbs_cyc_i(cyc), 
    .wbs_dat_o(dat),
    .wbs_stall_o(stall),
    .wbs_ack_o(ack),
    .wb_clk(wb_clk),
    .wb_rst(wb_rst));
`undef MODULE

assign {wbm_dat_o, wbm_adr_o, wbm_cti_o, wbm_bte_o, wbm_sel_o, wbm_we_o, wbm_stb_o} =
       {wbs_dat_i, wbs_adr_i, wbs_cti_i, wbs_bte_i, wbs_sel_i, wbs_we_i, wbs_stb_i};
assign wbm_cyc_o = wbs_cyc_i & (wbs_adr_i>shadow_mem_size);

assign wbs_dat_o = (dat & {dat_width{cyc}}) | (wbm_dat_i & {dat_width{wbm_cyc_o}});
assign wbs_ack_o = (ack & cyc) | (wbm_ack_i & wbm_cyc_o);
assign wbs_stall_o = (stall & cyc) | (wbm_stall_i & wbm_cyc_o);

end else begin : no_shadow_ram_inst

assign {wbm_dat_o, wbm_adr_o, wbm_cti_o, wbm_bte_o, wbm_sel_o, wbm_we_o, wbm_stb_o, wbm_cyc_o} =
       {wbs_dat_i, wbs_adr_i, wbs_cti_i, wbs_bte_i, wbs_sel_i, wbs_we_i, wbs_stb_i, wbs_cyc_i};
assign {wbs_dat_o, wbs_ack_o, wbs_stall_o} = {wbm_dat_i, wbm_ack_i, wbm_stall_i};

end
endgenerate

endmodule
`endif

`ifdef WB_B4_ROM
// WB ROM
`define MODULE wb_b4_rom
module `BASE`MODULE (
`undef MODULE
    wb_adr_i, wb_stb_i, wb_cyc_i, 
    wb_dat_o, stall_o, wb_ack_o, wb_clk, wb_rst);

    parameter dat_width = 32;
    parameter dat_default = 32'h15000000;
    parameter adr_width = 32;

/*
`ifndef ROM
`define ROM "rom.v"
`endif
*/   
    input [adr_width-1:2]   wb_adr_i;
    input 		    wb_stb_i;
    input 		    wb_cyc_i;
    output [dat_width-1:0]  wb_dat_o;
    reg [dat_width-1:0]     wb_dat_o;
    output  		    wb_ack_o;
    reg                     wb_ack_o;
    output                  stall_o;
    input 		    wb_clk;
    input 		    wb_rst;

always @ (posedge wb_clk or posedge wb_rst)
    if (wb_rst)
        wb_dat_o <= {dat_width{1'b0}};
    else
	 case (wb_adr_i[adr_width-1:2])
`ifdef ROM
`include `ROM
`endif
	   default:
	     wb_dat_o <= dat_default;
	     
	 endcase // case (wb_adr_i)

   
always @ (posedge wb_clk or posedge wb_rst)
    if (wb_rst)
        wb_ack_o <= 1'b0;
    else
        wb_ack_o <= wb_stb_i & wb_cyc_i;

assign stall_o = 1'b0;

endmodule
`endif


`ifdef WB_BOOT_ROM
// WB ROM
`define MODULE wb_boot_rom
module `BASE`MODULE (
`undef MODULE
    wb_adr_i, wb_stb_i, wb_cyc_i, 
    wb_dat_o, wb_ack_o, hit_o, wb_clk, wb_rst);

    parameter adr_hi = 31;
    parameter adr_lo = 28;
    parameter adr_sel = 4'hf;
    parameter addr_width = 5;
/*
`ifndef BOOT_ROM
`define BOOT_ROM "boot_rom.v"
`endif
*/   
    input [adr_hi:2]    wb_adr_i;
    input 		wb_stb_i;
    input 		wb_cyc_i;
    output [31:0] 	wb_dat_o;
    output  		wb_ack_o;
    output              hit_o;
    input 		wb_clk;
    input 		wb_rst;

    wire hit;
    reg [31:0] wb_dat;
    reg wb_ack;
    
assign hit = wb_adr_i[adr_hi:adr_lo] == adr_sel;
   
always @ (posedge wb_clk or posedge wb_rst)
    if (wb_rst)
        wb_dat <= 32'h15000000;
    else
	 case (wb_adr_i[addr_width-1:2])
`ifdef BOOT_ROM
`include `BOOT_ROM
`endif
	   /*	 
	    // Zero r0 and jump to 0x00000100
	    0 : wb_dat <= 32'h18000000;
	    1 : wb_dat <= 32'hA8200000;
	    2 : wb_dat <= 32'hA8C00100;
	    3 : wb_dat <= 32'h44003000;
	    4 : wb_dat <= 32'h15000000;
	    */
	   default:
	     wb_dat <= 32'h00000000;
	     
	 endcase // case (wb_adr_i)

   
always @ (posedge wb_clk or posedge wb_rst)
    if (wb_rst)
        wb_ack <= 1'b0;
    else
        wb_ack <= wb_stb_i & wb_cyc_i & hit & !wb_ack;

assign hit_o = hit;
assign wb_dat_o = wb_dat & {32{wb_ack}};
assign wb_ack_o = wb_ack;

endmodule
`endif

`ifdef WB_DPRAM
`define MODULE wb_dpram
module `BASE`MODULE ( 
`undef MODULE
	// wishbone slave side a
	wbsa_dat_i, wbsa_adr_i, wbsa_sel_i, wbsa_cti_i, wbsa_bte_i, wbsa_we_i, wbsa_cyc_i, wbsa_stb_i, wbsa_dat_o, wbsa_ack_o, wbsa_stall_o,
        wbsa_clk, wbsa_rst,
	// wishbone slave side b
	wbsb_dat_i, wbsb_adr_i, wbsb_sel_i, wbsb_cti_i, wbsb_bte_i, wbsb_we_i, wbsb_cyc_i, wbsb_stb_i, wbsb_dat_o, wbsb_ack_o, wbsb_stall_o,
        wbsb_clk, wbsb_rst);

parameter data_width_a = 32;
parameter data_width_b = data_width_a;
parameter addr_width_a = 8;
localparam addr_width_b = data_width_a * addr_width_a / data_width_b;
parameter mem_size = (addr_width_a>addr_width_b) ? (1<<addr_width_a) : (1<<addr_width_b);
parameter max_burst_width_a = 4;
parameter max_burst_width_b = max_burst_width_a;
parameter mode = "B3";
parameter memory_init = 0;
parameter memory_file = "vl_ram.v";
parameter debug = 0;
input [data_width_a-1:0] wbsa_dat_i;
input [addr_width_a-1:0] wbsa_adr_i;
input [data_width_a/8-1:0] wbsa_sel_i;
input [2:0] wbsa_cti_i;
input [1:0] wbsa_bte_i;
input wbsa_we_i, wbsa_cyc_i, wbsa_stb_i;
output [data_width_a-1:0] wbsa_dat_o;
output wbsa_ack_o;
output wbsa_stall_o;
input wbsa_clk, wbsa_rst;

input [data_width_b-1:0] wbsb_dat_i;
input [addr_width_b-1:0] wbsb_adr_i;
input [data_width_b/8-1:0] wbsb_sel_i;
input [2:0] wbsb_cti_i;
input [1:0] wbsb_bte_i;
input wbsb_we_i, wbsb_cyc_i, wbsb_stb_i;
output [data_width_b-1:0] wbsb_dat_o;
output wbsb_ack_o;
output wbsb_stall_o;
input wbsb_clk, wbsb_rst;

wire [addr_width_a-1:0] adr_a;
wire [addr_width_b-1:0] adr_b;
wire we_a, we_b;
generate
if (mode=="B3") begin : b3_inst
`define MODULE wb_adr_inc 
`BASE`MODULE # ( .adr_width(addr_width_a), .max_burst_width(max_burst_width_a)) adr_inc0 (
    .cyc_i(wbsa_cyc_i),
    .stb_i(wbsa_stb_i),
    .cti_i(wbsa_cti_i),
    .bte_i(wbsa_bte_i),
    .adr_i(wbsa_adr_i),
    .we_i(wbsa_we_i),
    .ack_o(wbsa_ack_o),
    .adr_o(adr_a),
    .clk(wbsa_clk),
    .rst(wbsa_rst));
assign we_a = wbsa_we_i & wbsa_ack_o;
`BASE`MODULE # ( .adr_width(addr_width_b), .max_burst_width(max_burst_width_b)) adr_inc1 (
    .cyc_i(wbsb_cyc_i),
    .stb_i(wbsb_stb_i),
    .cti_i(wbsb_cti_i),
    .bte_i(wbsb_bte_i),
    .adr_i(wbsb_adr_i),
    .we_i(wbsb_we_i),
    .ack_o(wbsb_ack_o),
    .adr_o(adr_b),
    .clk(wbsb_clk),
    .rst(wbsb_rst));
`undef MODULE
assign we_b = wbsb_we_i & wbsb_ack_o;
end else if (mode=="B4") begin : b4_inst
assign adr_a = wbsa_adr_i;
`define MODULE dff
`BASE`MODULE dffacka ( .d(wbsa_stb_i & wbsa_cyc_i), .q(wbsa_ack_o), .clk(wbsa_clk), .rst(wbsa_rst));
assign wbsa_stall_o = 1'b0;
assign we_a = wbsa_we_i & wbsa_cyc_i & wbsa_stb_i;
assign adr_b = wbsb_adr_i;
`BASE`MODULE dffackb ( .d(wbsb_stb_i & wbsb_cyc_i), .q(wbsb_ack_o), .clk(wbsb_clk), .rst(wbsb_rst));
`undef MODULE
assign wbsb_stall_o = 1'b0;
assign we_b = wbsb_we_i & wbsb_cyc_i & wbsb_stb_i;
end
endgenerate

`define MODULE dpram_be_2r2w
`BASE`MODULE # ( .a_data_width(data_width_a), .a_addr_width(addr_width_a), .mem_size(mem_size),
                 .b_data_width(data_width_b),
                 .memory_init(memory_init), .memory_file(memory_file),
                 .debug(debug))
`undef MODULE
ram_i (
    .d_a(wbsa_dat_i),
    .q_a(wbsa_dat_o),
    .adr_a(adr_a),
    .be_a(wbsa_sel_i),
    .we_a(we_a),
    .clk_a(wbsa_clk),
    .d_b(wbsb_dat_i),
    .q_b(wbsb_dat_o),
    .adr_b(adr_b),
    .be_b(wbsb_sel_i),
    .we_b(we_b),
    .clk_b(wbsb_clk) );

endmodule
`endif

`ifdef WB_CACHE
`define MODULE wb_cache
module `BASE`MODULE (
    wbs_dat_i, wbs_adr_i, wbs_sel_i, wbs_cti_i, wbs_bte_i, wbs_we_i, wbs_stb_i, wbs_cyc_i, wbs_dat_o, wbs_ack_o, wbs_stall_o, wbs_clk, wbs_rst,
    wbm_dat_o, wbm_adr_o, wbm_sel_o, wbm_cti_o, wbm_bte_o, wbm_we_o, wbm_stb_o, wbm_cyc_o, wbm_dat_i, wbm_ack_i, wbm_stall_i, wbm_clk, wbm_rst
);
`undef MODULE

parameter dw_s = 32;
parameter aw_s = 24;
parameter dw_m = dw_s;
//localparam aw_m = dw_s * aw_s / dw_m;
localparam aw_m = 
	(dw_s==dw_m) ? aw_s : 
	(dw_s==dw_m*2) ? aw_s+1 : 
	(dw_s==dw_m*4) ? aw_s+2 : 
	(dw_s==dw_m*8) ? aw_s+3 : 
	(dw_s==dw_m*16) ? aw_s+4 : 
	(dw_s==dw_m*32) ? aw_s+5 : 
	(dw_s==dw_m/2) ? aw_s-1 : 
	(dw_s==dw_m/4) ? aw_s-2 : 
	(dw_s==dw_m/8) ? aw_s-3 : 
	(dw_s==dw_m/16) ? aw_s-4 : 
	(dw_s==dw_m/32) ? aw_s-5 : 0;

parameter wbs_max_burst_width = 4;
parameter wbs_mode = "B3";

parameter async = 1; // wbs_clk != wbm_clk

parameter nr_of_ways = 1;
parameter aw_offset = 4; // 4 => 16 words per cache line
parameter aw_slot = 10;

parameter valid_mem = 0;
parameter debug = 0;

localparam aw_b_offset = aw_offset * dw_s / dw_m;
localparam aw_tag = aw_s - aw_slot - aw_offset;
parameter wbm_burst_size = 4; // valid options 4,8,16
localparam bte = (wbm_burst_size==4) ? 2'b01 : (wbm_burst_size==8) ? 2'b10 : 2'b11;
`define SIZE2WIDTH wbm_burst_size
localparam wbm_burst_width `SIZE2WIDTH_EXPR
`undef SIZE2WIDTH
localparam nr_of_wbm_burst = ((1<<aw_offset)/wbm_burst_size) * dw_s / dw_m; 
`define SIZE2WIDTH nr_of_wbm_burst
localparam nr_of_wbm_burst_width `SIZE2WIDTH_EXPR
`undef SIZE2WIDTH

input [dw_s-1:0] wbs_dat_i;
input [aw_s-1:0] wbs_adr_i; // dont include a1,a0
input [dw_s/8-1:0] wbs_sel_i;
input [2:0] wbs_cti_i;
input [1:0] wbs_bte_i;
input wbs_we_i, wbs_stb_i, wbs_cyc_i;
output [dw_s-1:0] wbs_dat_o;
output wbs_ack_o;
output wbs_stall_o;
input wbs_clk, wbs_rst;

output [dw_m-1:0] wbm_dat_o;
output [aw_m-1:0] wbm_adr_o;
output [dw_m/8-1:0] wbm_sel_o;
output [2:0] wbm_cti_o;
output [1:0] wbm_bte_o;
output wbm_stb_o, wbm_cyc_o, wbm_we_o;
input [dw_m-1:0] wbm_dat_i;
input wbm_ack_i;
input wbm_stall_i;
input wbm_clk, wbm_rst;

wire valid, dirty, hit;
wire [aw_tag-1:0] tag;
wire tag_mem_we;
wire [aw_tag-1:0] wbs_adr_tag;
wire [aw_slot-1:0] wbs_adr_slot;
wire [aw_offset-1:0] wbs_adr_word;
wire [aw_s-1:0] wbs_adr;

reg [1:0] state;
localparam idle = 2'h0;
localparam rdwr = 2'h1;
localparam push = 2'h2;
localparam pull = 2'h3;
wire eoc;
wire we;

// cdc
wire done, mem_alert, mem_done;

// wbm side
reg [aw_m-1:0] wbm_radr;
reg [aw_m-1:0] wbm_wadr;
//wire [aw_slot-1:0] wbm_adr;
wire [aw_m-1:0] wbm_adr;
wire wbm_radr_cke, wbm_wadr_cke;

reg [2:0] phase;
// phase = {we,stb,cyc}
localparam wbm_wait     = 3'b000;
localparam wbm_wr       = 3'b111;
localparam wbm_wr_drain = 3'b101;
localparam wbm_rd       = 3'b011;
localparam wbm_rd_drain = 3'b001;

assign {wbs_adr_tag, wbs_adr_slot, wbs_adr_word} = wbs_adr_i;

generate
if (valid_mem==0) begin : no_valid_mem
assign valid = 1'b1;
end else begin : valid_mem_inst
`define MODULE dpram_1r1w
`BASE`MODULE
    # ( .data_width(1), .addr_width(aw_slot), .memory_init(2), .debug(debug))
    valid_mem ( .d_a(1'b1), .adr_a(wbs_adr_slot), .we_a(mem_done), .clk_a(wbm_clk),
                .q_b(valid), .adr_b(wbs_adr_slot), .clk_b(wbs_clk));
`undef MODULE
end
endgenerate

`define MODULE dpram_1r1w
`BASE`MODULE
    # ( .data_width(aw_tag), .addr_width(aw_slot), .memory_init(2), .debug(debug))
    tag_mem ( .d_a(wbs_adr_tag), .adr_a(wbs_adr_slot), .we_a(mem_done), .clk_a(wbm_clk),
              .q_b(tag), .adr_b(wbs_adr_slot), .clk_b(wbs_clk));
assign hit = wbs_adr_tag == tag;
`undef MODULE

`define MODULE dpram_1r2w
`BASE`MODULE
    # ( .data_width(1), .addr_width(aw_slot), .memory_init(2), .debug(debug))
    dirty_mem (
        .d_a(1'b1), .q_a(dirty), .adr_a(wbs_adr_slot), .we_a(wbs_cyc_i & wbs_we_i & wbs_ack_o), .clk_a(wbs_clk),
        .d_b(1'b0), .adr_b(wbs_adr_slot), .we_b(mem_done), .clk_b(wbm_clk));
`undef MODULE

generate
if (wbs_mode=="B3") begin : inst_b3
`define MODULE wb_adr_inc 
`BASE`MODULE # ( .adr_width(aw_s), .max_burst_width(wbs_max_burst_width)) adr_inc0 (
    .cyc_i(wbs_cyc_i & (state==rdwr) & hit & valid),
    .stb_i(wbs_stb_i & (state==rdwr) & hit & valid), // throttle depending on valid
    .cti_i(wbs_cti_i),
    .bte_i(wbs_bte_i),
    .adr_i(wbs_adr_i),
    .we_i (wbs_we_i),
    .ack_o(wbs_ack_o),
    .adr_o(wbs_adr),
    .clk(wbs_clk),
    .rst(wbs_rst));
`undef MODULE
assign eoc = (wbs_cti_i==3'b000 | wbs_cti_i==3'b111) & wbs_ack_o;
assign we = wbs_cyc_i &  wbs_we_i & wbs_ack_o;
end else if (wbs_mode=="B4") begin : inst_b4
end

endgenerate
localparam cache_mem_b_aw =
    (dw_s==dw_m) ? aw_slot+aw_offset :
    (dw_s==dw_m/2) ? aw_slot+aw_offset-1 :
    (dw_s==dw_m/4) ? aw_slot+aw_offset-2 :
    (dw_s==dw_m/8) ? aw_slot+aw_offset-3 :
    (dw_s==dw_m/16) ? aw_slot+aw_offset-4 :
    (dw_s==dw_m*2) ? aw_slot+aw_offset+1 :
    (dw_s==dw_m*4) ? aw_slot+aw_offset+2 :
    (dw_s==dw_m*8) ? aw_slot+aw_offset+3 :
    (dw_s==dw_m*16) ? aw_slot+aw_offset+4 : 0;

`define MODULE dpram_be_2r2w
`BASE`MODULE
    # ( .a_data_width(dw_s), .a_addr_width(aw_slot+aw_offset), .b_data_width(dw_m), .debug(debug))
    cache_mem ( .d_a(wbs_dat_i), .adr_a(wbs_adr[aw_slot+aw_offset-1:0]),   .be_a(wbs_sel_i), .we_a(we), .q_a(wbs_dat_o), .clk_a(wbs_clk),
                .d_b(wbm_dat_i), .adr_b(wbm_adr[cache_mem_b_aw-1:0]), .be_b(wbm_sel_o), .we_b(wbm_cyc_o & !wbm_we_o & wbm_ack_i), .q_b(wbm_dat_o), .clk_b(wbm_clk));
`undef MODULE    

always @ (posedge wbs_clk or posedge wbs_rst)
if (wbs_rst)
    state <= idle;
else
    case (state)
    idle:
        if (wbs_cyc_i)
            state <= rdwr;
    rdwr:
        casex ({valid, hit, dirty, eoc})
        4'b0xxx: state <= pull;
        4'b11x1: state <= idle;
        4'b101x: state <= push;
        4'b100x: state <= pull;
        endcase
    push:
        if (done)
            state <= rdwr;
    pull:
        if (done)
            state <= rdwr;
    default: state <= idle;
    endcase

// cdc
generate
if (async==1) begin : cdc0
`define MODULE cdc
`BASE`MODULE cdc0 ( .start_pl(state==rdwr & (!valid | !hit)), .take_it_pl(mem_alert), .take_it_grant_pl(mem_done), .got_it_pl(done), .clk_src(wbs_clk), .rst_src(wbs_rst), .clk_dst(wbm_clk), .rst_dst(wbm_rst));
`undef MODULE
end
else begin : nocdc
    assign mem_alert = state==rdwr & (!valid | !hit);
    assign done = mem_done;
end
endgenerate

// FSM generating a number of bursts 4 cycles
// actual number depends on data width ratio
// nr_of_wbm_burst
reg [nr_of_wbm_burst_width+wbm_burst_width-1:0]       cnt_rw, cnt_ack;

always @ (posedge wbm_clk or posedge wbm_rst)
if (wbm_rst)
    cnt_rw <= {wbm_burst_width{1'b0}};
else
    if (wbm_cyc_o & wbm_stb_o & !wbm_stall_i)
        cnt_rw <= cnt_rw + 1;

always @ (posedge wbm_clk or posedge wbm_rst)
if (wbm_rst)
    cnt_ack <= {wbm_burst_width{1'b0}};
else
    if (wbm_ack_i)
        cnt_ack <= cnt_ack + 1;

generate
if (nr_of_wbm_burst==1) begin : one_burst

always @ (posedge wbm_clk or posedge wbm_rst)
if (wbm_rst)
    phase <= wbm_wait;
else
    case (phase)
    wbm_wait:
        if (mem_alert)
            if (state==push)
                phase <= wbm_wr;
            else
                phase <= wbm_rd;
    wbm_wr:
        if (&cnt_rw)
            phase <= wbm_wr_drain;
    wbm_wr_drain:
        if (&cnt_ack)
            phase <= wbm_rd;
    wbm_rd:
        if (&cnt_rw)
            phase <= wbm_rd_drain;
    wbm_rd_drain:
        if (&cnt_ack)
            phase <= wbm_wait;
    default: phase <= wbm_wait;
    endcase

end else begin : multiple_burst

always @ (posedge wbm_clk or posedge wbm_rst)
if (wbm_rst)
    phase <= wbm_wait;
else
    case (phase)
    wbm_wait:
        if (mem_alert)
            if (state==push)
                phase <= wbm_wr;
            else
                phase <= wbm_rd;
    wbm_wr:
        if (&cnt_rw[wbm_burst_width-1:0])
            phase <= wbm_wr_drain;
    wbm_wr_drain:
        if (&cnt_ack)
            phase <= wbm_rd;
        else if (&cnt_ack[wbm_burst_width-1:0])
            phase <= wbm_wr;
    wbm_rd:
        if (&cnt_rw[wbm_burst_width-1:0])
            phase <= wbm_rd_drain;
    wbm_rd_drain:
        if (&cnt_ack)
            phase <= wbm_wait;
        else if (&cnt_ack[wbm_burst_width-1:0])
            phase <= wbm_rd;
    default: phase <= wbm_wait;
    endcase


end
endgenerate

assign mem_done = phase==wbm_rd_drain & (&cnt_ack) & wbm_ack_i;

assign wbm_adr_o = (phase[2]) ? {tag, wbs_adr_slot, cnt_rw} : {wbs_adr_tag, wbs_adr_slot, cnt_rw};
assign wbm_adr   = (phase[2]) ? {wbs_adr_slot, cnt_rw} : {wbs_adr_slot, cnt_ack};
assign wbm_sel_o = {dw_m/8{1'b1}};
assign wbm_cti_o = (&cnt_rw | !wbm_stb_o) ? 3'b111 : 3'b010;
assign wbm_bte_o = bte;
assign {wbm_we_o, wbm_stb_o, wbm_cyc_o}  = phase;

endmodule
`endif

`ifdef WB_AVALON_BRIDGE
// Wishbone to avalon bridge supporting one type of burst transfer only
// intended use is together with cache above
// WB B4 -> pipelined avalon
`define MODULE wb_avalon_bridge
module `BASE`MODULE ( 
`undef MODULE
	// wishbone slave side
	wbs_dat_i, wbs_adr_i, wbs_sel_i, wbs_bte_i, wbs_cti_i, wbs_we_i, wbs_cyc_i, wbs_stb_i, wbs_dat_o, wbs_ack_o, wbs_stall_o,
	// avalon master side
	readdata, readdatavalid, address, read, be, write, burstcount, writedata, waitrequest, beginbursttransfer,
        init_done,
        // common
        clk, rst);

parameter adr_width = 30;
parameter dat_width = 32;
parameter burst_size = 4;

input [dat_width-1:0] wbs_dat_i;
input [adr_width-1:0] wbs_adr_i;
input [dat_width/8-1:0]  wbs_sel_i;
input [1:0]  wbs_bte_i;
input [2:0]  wbs_cti_i;
input wbs_we_i;
input wbs_cyc_i;
input wbs_stb_i;
output [dat_width-1:0] wbs_dat_o;
output wbs_ack_o;
output wbs_stall_o;

input [dat_width-1:0] readdata;
input readdatavalid;
output [dat_width-1:0] writedata;
output [adr_width-1:0] address;
output [dat_width/8-1:0]  be;
output write;
output read;
output beginbursttransfer;
output [3:0] burstcount;
input waitrequest;
input init_done;
input clk, rst;

// cnt1 - initiated read or writes
// cnt2 - # of read or writes in pipeline
reg [3:0] cnt1;
reg [3:0] cnt2;

reg next_state, state;
localparam s0 = 1'b0;
localparam s1 = 1'b1;

wire eoc;

always @ *
begin
    case (state)
    s0: if (init_done & wbs_cyc_i) next_state <= s1;
    s1: 
    default: next_state <= state;
    end
end

always @ (posedge clk or posedge rst)
if (rst)
    state <= s0;
else
    state <= next_state;

assign eoc = state==s1 & !(read | write) & (& !waitrequest & cnt2=;
always @ (posedge clk or posedge rst)
if (rst)
    cnt1 <= 4'h0;
else
    if (read & !waitrequest & init_done)
        cnt1 <= burst_size - 1;
    else if (write & !waitrequest & init_done)
        cnt1 <= cnt1 + 4'h1;
    else if (next_state==idle)
        cnt1 <= 4'h0;

always @ (posedge clk or posedge rst)
if (rst)
    cnt2 <= 4'h0;
else
    if (read & !waitrequest & init_done)
        cnt2 <= burst_size - 1;
    else if (write & !waitrequest & init_done & )
        cnt2 <= cnt1 + 4'h1;
    else if (next_state==idle)
        cnt2 <= 4'h0;

reg wr_ack;
always @ (posedge clk or posedge rst)
if (rst)
    wr_ack <= 1'b0;
else
    wr_ack <=  (wbs_we_i & wbs_cyc_i & wbs_stb_i & !wbs_stall_o);

// to avalon
assign writedata = wbs_dat_i;
assign address = wbs_adr_i;
assign be = wbs_sel_i;
assign write = cnt!=4'h0 & wbs_cyc_i &  wbs_we_i;
assign read  = cnt!=4'h0 & wbs_cyc_i & !wbs_we_i;
assign beginbursttransfer = state==s0 & next_state==s1;
assign burstcount = burst_size;

// to wishbone
assign wbs_dat_o = readdata;
assign wbs_ack_o = wr_ack | readdatavalid;
assign wbs_stall_o = waitrequest;

endmodule
`endif

`ifdef WB_AVALON_MEM_CACHE
`define MODULE wb_avalon_mem_cache
module `BASE`MODULE (
    wbs_dat_i, wbs_adr_i, wbs_sel_i, wbs_cti_i, wbs_bte_i, wbs_we_i, wbs_stb_i, wbs_cyc_i, wbs_dat_o, wbs_ack_o, wbs_stall_o, wbs_clk, wbs_rst,
    readdata, readdatavalid, address, read, be, write, burstcount, writedata, waitrequest, beginbursttransfer, clk, rst
);
`undef MODULE

// wishbone
parameter wb_dat_width = 32;
parameter wb_adr_width = 22;
parameter wb_max_burst_width = 4;
parameter wb_mode = "B4";
// avalon
parameter avalon_dat_width = 32;
//localparam avalon_adr_width = wb_dat_width * wb_adr_width / avalon_dat_width;
localparam avalon_adr_width = 
	(wb_dat_width==avalon_dat_width) ? wb_adr_width : 
	(wb_dat_width==avalon_dat_width*2) ? wb_adr_width+1 : 
	(wb_dat_width==avalon_dat_width*4) ? wb_adr_width+2 : 
	(wb_dat_width==avalon_dat_width*8) ? wb_adr_width+3 : 
	(wb_dat_width==avalon_dat_width*16) ? wb_adr_width+4 : 
	(wb_dat_width==avalon_dat_width*32) ? wb_adr_width+5 : 
	(wb_dat_width==avalon_dat_width/2) ? wb_adr_width-1 : 
	(wb_dat_width==avalon_dat_width/4) ? wb_adr_width-2 : 
	(wb_dat_width==avalon_dat_width/8) ? wb_adr_width-3 : 
	(wb_dat_width==avalon_dat_width/16) ? wb_adr_width-4 : 
	(wb_dat_width==avalon_dat_width/32) ? wb_adr_width-5 : 0;
parameter avalon_burst_size = 4;
// cache
parameter async = 1;
parameter nr_of_ways = 1;
parameter aw_offset = 4;
parameter aw_slot = 10;
parameter valid_mem = 1;
// shadow RAM
parameter shadow_ram = 0;
parameter shadow_ram_adr_width = 10;
parameter shadow_ram_size = 1024;
parameter shadow_ram_init = 2; // 0: no init, 1: from file, 2: with zero
parameter shadow_ram_file = "vl_ram.v";

input [wb_dat_width-1:0] wbs_dat_i;
input [wb_adr_width-1:0] wbs_adr_i; // dont include a1,a0
input [wb_dat_width/8-1:0] wbs_sel_i;
input [2:0] wbs_cti_i;
input [1:0] wbs_bte_i;
input wbs_we_i, wbs_stb_i, wbs_cyc_i;
output [wb_dat_width-1:0] wbs_dat_o;
output wbs_ack_o;
output wbs_stall_o;
input wbs_clk, wbs_rst;

input [avalon_dat_width-1:0] readdata;
input readdatavalid;
output [avalon_dat_width-1:0] writedata;
output [avalon_adr_width-1:0] address;
output [avalon_dat_width/8-1:0]  be;
output write;
output read;
output beginbursttransfer;
output [3:0] burstcount;
input waitrequest;
input clk, rst;

`define DAT_WIDTH wb_dat_width
`define ADR_WIDTH wb_adr_width
`define WB wb1
`include "wb_wires.v"
`undef DAT_WIDTH
`undef ADR_WIDTH
`define DAT_WIDTH avalon_dat_width
`define ADR_WIDTH avalon_adr_width
`define WB wb2
`include "wb_wires.v"
`undef DAT_WIDTH
`undef ADR_WIDTH

`define MODULE wb_shadow_ram
`BASE`MODULE # ( .dat_width(wb_dat_width), .mode(wb_mode), .max_burst_width(wb_max_burst_width),
                 .shadow_mem_adr_width(shadow_ram_adr_width), .shadow_mem_size(shadow_ram_size), .shadow_mem_init(shadow_ram_init), .shadow_mem_file(shadow_ram_file),
                 .main_mem_adr_width(wb_adr_width))
shadow_ram0 (
    .wbs_dat_i(wbs_dat_i), .wbs_adr_i(wbs_adr_i), .wbs_cti_i(wbs_cti_i), .wbs_bte_i(wbs_bte_i), .wbs_sel_i(wbs_sel_i), .wbs_we_i(wbs_we_i), .wbs_stb_i(wbs_stb_i), .wbs_cyc_i(wbs_cyc_i), 
    .wbs_dat_o(wbs_dat_o), .wbs_ack_o(wbs_ack_o), .wbs_stall_o(wbs_stall_o),
    .wbm_dat_o(wb1_dat_o), .wbm_adr_o(wb1_adr_o), .wbm_cti_o(wb1_cti_o), .wbm_bte_o(wb1_bte_o), .wbm_sel_o(wb1_sel_o), .wbm_we_o(wb1_we_o), .wbm_stb_o(wb1_stb_o), .wbm_cyc_o(wb1_cyc_o), 
    .wbm_dat_i(wb1_dat_i), .wbm_ack_i(wb1_ack_i), .wbm_stall_i(wb1_stall_i),
    .wb_clk(wbs_clk), .wb_rst(wbs_rst));
`undef MODULE

`define MODULE wb_cache
`BASE`MODULE
# ( .dw_s(wb_dat_width), .aw_s(wb_adr_width), .dw_m(avalon_dat_width), .wbs_mode(wb_mode), .wbs_max_burst_width(wb_max_burst_width), .async(async), .nr_of_ways(nr_of_ways), .aw_offset(aw_offset), .aw_slot(aw_slot), .valid_mem(valid_mem))
cache0 (
    .wbs_dat_i(wb1_dat_o), .wbs_adr_i(wb1_adr_o), .wbs_sel_i(wb1_sel_o), .wbs_cti_i(wb1_cti_o), .wbs_bte_i(wb1_bte_o), .wbs_we_i(wb1_we_o), .wbs_stb_i(wb1_stb_o), .wbs_cyc_i(wb1_cyc_o),
    .wbs_dat_o(wb1_dat_i), .wbs_ack_o(wb1_ack_i), .wbs_stall_o(wb1_stall_i), .wbs_clk(wbs_clk), .wbs_rst(wbs_rst),
    .wbm_dat_o(wb2_dat_o), .wbm_adr_o(wb2_adr_o), .wbm_sel_o(wb2_sel_o), .wbm_cti_o(wb2_cti_o), .wbm_bte_o(wb2_bte_o), .wbm_we_o(wb2_we_o), .wbm_stb_o(wb2_stb_o), .wbm_cyc_o(wb2_cyc_o),
    .wbm_dat_i(wb2_dat_i), .wbm_ack_i(wb2_ack_i), .wbm_stall_i(wb2_stall_i), .wbm_clk(clk), .wbm_rst(rst));
`undef MODULE

`define MODULE wb_avalon_bridge
`BASE`MODULE # ( .adr_width(avalon_adr_width), .dat_width(avalon_dat_width), .burst_size(avalon_burst_size))
bridge0 ( 
	// wishbone slave side
	.wbs_dat_i(wb2_dat_o), .wbs_adr_i(wb2_adr_o), .wbs_sel_i(wb2_sel_o), .wbs_bte_i(wb2_bte_o), .wbs_cti_i(wb2_cti_o), .wbs_we_i(wb2_we_o), .wbs_cyc_i(wb2_cyc_o), .wbs_stb_i(wb2_stb_o),
        .wbs_dat_o(wb2_dat_i), .wbs_ack_o(wb2_ack_i), .wbs_stall_o(wb2_stall_i),
	// avalon master side
	.readdata(readdata), .readdatavalid(readdatavalid), .address(address), .read(read), .be(be), .write(write), .burstcount(burstcount), .writedata(writedata), .waitrequest(waitrequest), .beginbursttransfer(beginbursttransfer),
        // common
        .clk(clk), .rst(rst));
`undef MODULE

endmodule
`endif

`ifdef WB_SDR_SDRAM
`define MODULE wb_sdr_sdram
module `BASE`MODULE (
`undef MODULE
    // wisbone i/f
    dat_i, adr_i, sel_i, we_i, cyc_i, stb_i, dat_o, ack_o, stall_o,
    // SDR SDRAM
    ba, a, cmd, cke, cs_n, dqm, dq_i, dq_o, dq_oe,
    // system
    clk, rst);

    // external data bus size
    parameter dat_size = 16;
    // memory geometry parameters
    parameter ba_size  = 2;   
    parameter row_size = 13;
    parameter col_size = 9;
    parameter cl = 2;
    // memory timing parameters
    parameter tRFC = 9;
    parameter tRP  = 2;
    parameter tRCD = 2;
    parameter tMRD = 2;
   
    // LMR
    // [12:10] reserved
    // [9]     WB, write burst; 0 - programmed burst length, 1 - single location
    // [8:7]   OP Mode, 2'b00
    // [6:4]   CAS Latency; 3'b010 - 2, 3'b011 - 3
    // [3]     BT, Burst Type; 1'b0 - sequential, 1'b1 - interleaved
    // [2:0]   Burst length; 3'b000 - 1, 3'b001 - 2, 3'b010 - 4, 3'b011 - 8, 3'b111 - full page
    localparam init_wb = 1'b1;
    localparam init_cl = (cl==2) ? 3'b010 : 3'b011;
    localparam init_bt = 1'b0;
    localparam init_bl = 3'b000;
	
    input [dat_size-1:0] dat_i;
    input [ba_size+col_size+row_size-1:0] adr_i;
    input [dat_size/8-1:0] sel_i;
    input we_i, cyc_i, stb_i;
    output [dat_size-1:0] dat_o;
    output ack_o;
    output reg stall_o;
    
    output [ba_size-1:0]    ba;
    output reg [12:0]   a;
    output reg [2:0]    cmd; // {ras,cas,we}
    output cke, cs_n;
    output reg [dat_size/8-1:0]    dqm;
    output [dat_size-1:0]       dq_o;
    output reg          dq_oe;
    input  [dat_size-1:0]       dq_i;

    input clk, rst;

    wire [ba_size-1:0] 	bank;
    wire [row_size-1:0] row;
    wire [col_size-1:0] col;
    wire [0:31] 	shreg; 
    wire 		ref_cnt_zero;
    reg                 refresh_req; 

    wire ack_rd, rd_ack_emptyflag;
    wire ack_wr;

    // to keep track of open rows per bank
    reg [row_size-1:0] 	open_row[0:3];
    reg [0:3] 		open_ba;
    reg 		current_bank_closed, current_row_open;  

    parameter rfr_length = 10;
    parameter rfr_wrap_value = 1010;

    parameter [2:0] cmd_nop = 3'b111,
                    cmd_act = 3'b011,
                    cmd_rd  = 3'b101,
                    cmd_wr  = 3'b100,
                    cmd_pch = 3'b010,
                    cmd_rfr = 3'b001,
                    cmd_lmr = 3'b000;

// ctrl FSM
`define FSM_INIT 3'b000
`define FSM_IDLE 3'b001
`define FSM_RFR  3'b010
`define FSM_ADR  3'b011
`define FSM_PCH  3'b100
`define FSM_ACT  3'b101
`define FSM_RW   3'b111

    assign cke = 1'b1;
    assign cs_n = 1'b0;
	   
    reg [2:0] state, next;

    function [12:0] a10_fix;
        input [col_size-1:0] a;
        integer i;
    begin
	for (i=0;i<13;i=i+1) begin
            if (i<10)
              if (i<col_size)
                a10_fix[i] = a[i];
              else
                a10_fix[i] = 1'b0;
            else if (i==10)
              a10_fix[i] = 1'b0;
            else
              if (i<col_size)
                a10_fix[i] = a[i-1];
              else
                a10_fix[i] = 1'b0;
	end
    end
    endfunction

    assign {bank,row,col} = adr_i;

    always @ (posedge clk or posedge rst)
    if (rst)
       state <= `FSM_INIT;
    else
       state <= next;
   
    always @*
    begin
	next = state;
	case (state)
	`FSM_INIT:
            if (shreg[3+tRP+tRFC+tRFC+tMRD]) next = `FSM_IDLE;
        `FSM_IDLE:   
	    if (refresh_req) next = `FSM_RFR;
            else if (cyc_i & stb_i & rd_ack_emptyflag) next = `FSM_ADR;
        `FSM_RFR: 
            if (shreg[tRP+tRFC-2]) next = `FSM_IDLE; // take away two cycles because no cmd will be issued in idle and adr
	`FSM_ADR:
            if (current_bank_closed) next = `FSM_ACT;
	    else if (current_row_open) next = `FSM_RW;
	    else next = `FSM_PCH;
	`FSM_PCH: 
            if (shreg[tRP]) next = `FSM_ACT;
	`FSM_ACT:
            if (shreg[tRCD]) next = `FSM_RW;
	`FSM_RW:
            if (!stb_i) next = `FSM_IDLE;
	endcase
    end

    // counter
`define MODULE cnt_shreg_clear 
    `BASE`MODULE # ( .length(32))
`undef MODULE
        cnt0 (
            .clear(state!=next),
            .q(shreg),
            .rst(rst),
            .clk(clk));

    // ba, a, cmd
    // outputs dependent on state vector
    always @ (*)
        begin
   	    {a,cmd} = {13'd0,cmd_nop};
            dqm = 2'b11;
            dq_oe = 1'b0;
            stall_o = 1'b1;
            case (state)
            `FSM_INIT:
                if (shreg[3]) begin
                    {a,cmd} = {13'b0010000000000, cmd_pch};
                end else if (shreg[3+tRP] | shreg[3+tRP+tRFC])
                    {a,cmd} = {13'd0, cmd_rfr};
                else if (shreg[3+tRP+tRFC+tRFC])
                    {a,cmd} = {3'b000,init_wb,2'b00,init_cl,init_bt,init_bl,cmd_lmr};
            `FSM_RFR:
        	if (shreg[0])
                    {a,cmd} = {13'b0010000000000, cmd_pch};
        	else if (shreg[tRP])
                    {a,cmd} = {13'd0, cmd_rfr};
	    `FSM_PCH:
        	if (shreg[0])
                    {a,cmd} = {13'd0,cmd_pch};
            `FSM_ACT:
                if (shreg[0])
                    {a[row_size-1:0],cmd} = {row,cmd_act};
            `FSM_RW:
                begin
                    if (we_i)
                        cmd = cmd_wr;
                    else
                        cmd = cmd_rd;
                    if (we_i)
                        dqm = ~sel_i;
                    else
                        dqm = 2'b00;
                    if (we_i)
                        dq_oe = 1'b1;
                    a = a10_fix(col);
                    stall_o = 1'b0;
                end
            endcase
        end

    assign ba = bank;
    
    // precharge individual bank A10=0
    // precharge all bank A10=1
    genvar i;
    generate
    for (i=0;i<2<<ba_size-1;i=i+1) begin : open_ba_logic
    
        always @ (posedge clk or posedge rst)
        if (rst)
            {open_ba[i],open_row[i]} <= {1'b0,{row_size{1'b0}}};
        else
            if (cmd==cmd_pch & (a[10] | bank==i))
                open_ba[i] <= 1'b0;
            else if (cmd==cmd_act & bank==i)
                {open_ba[i],open_row[i]} <= {1'b1,row};

    end
    endgenerate

    // bank and row open ?
    always @ (posedge clk or posedge rst)
    if (rst)
       {current_bank_closed, current_row_open} <= {1'b1, 1'b0};
    else
       {current_bank_closed, current_row_open} <= {!(open_ba[bank]), open_row[bank]==row};

    // refresh counter
`define MODULE cnt_lfsr_zq  
    `BASE`MODULE # ( .length(rfr_length), .wrap_value (rfr_wrap_value)) ref_counter0( .zq(ref_cnt_zero), .rst(rst), .clk(clk));
`undef MODULE

    always @ (posedge clk or posedge rst)
    if (rst)
    	refresh_req <= 1'b0;
    else
    	if (ref_cnt_zero)
            refresh_req <= 1'b1;
       	else if (state==`FSM_RFR)
            refresh_req <= 1'b0;

    assign dat_o = dq_i;
    
    assign ack_wr = (state==`FSM_RW & we_i);
`define MODULE delay_emptyflag  
    `BASE`MODULE # ( .depth(cl+2)) delay0 ( .d(state==`FSM_RW & stb_i & !we_i), .q(ack_rd), .emptyflag(rd_ack_emptyflag), .clk(clk), .rst(rst));
`undef MODULE
    assign ack_o = ack_rd | ack_wr;

    assign dq_o = dat_i;

endmodule
`endif

`ifdef WB_SDR_SDRAM_CTRL
`define MODULE wb_sdr_sdram_ctrl
module `BASE`MODULE (
    // WB i/f
    wbs_dat_i, wbs_adr_i, wbs_cti_i, wbs_bte_i, wbs_sel_i, wbs_we_i, wbs_stb_i, wbs_cyc_i, 
    wbs_dat_o, wbs_ack_o, wbs_stall_o,
    // SDR SDRAM
    mem_ba, mem_a, mem_cmd, mem_cke, mem_cs_n, mem_dqm, mem_dq_i, mem_dq_o, mem_dq_oe,
    // system
    wb_clk, wb_rst, mem_clk, mem_rst);
`undef MODULE

    // WB slave
    parameter wbs_dat_width = 32;
    parameter wbs_adr_width = 24;
    parameter wbs_mode = "B3";
    parameter wbs_max_burst_width = 4;

    // Shadow RAM
    parameter shadow_mem_adr_width = 10;
    parameter shadow_mem_size = 1024;
    parameter shadow_mem_init = 2;
    parameter shadow_mem_file = "vl_ram.v";

    // Cache
    parameter cache_async = 1; // wbs_clk != wbm_clk
    parameter cache_nr_of_ways = 1;
    parameter cache_aw_offset = 4; // 4 => 16 words per cache line
    parameter cache_aw_slot = 10;
    parameter cache_valid_mem = 0;
    parameter cache_debug = 0;
    
    // SDRAM parameters
    parameter mem_dat_size = 16;
    parameter mem_ba_size  = 2;   
    parameter mem_row_size = 13;
    parameter mem_col_size = 9;
    parameter mem_cl = 2;
    parameter mem_tRFC = 9;
    parameter mem_tRP  = 2;
    parameter mem_tRCD = 2;
    parameter mem_tMRD = 2;
    parameter mem_rfr_length = 10;
    parameter mem_rfr_wrap_value = 1010;

    input [wbs_dat_width-1:0] wbs_dat_i;
    input [wbs_adr_width-1:0] wbs_adr_i;
    input [2:0] wbs_cti_i;
    input [1:0] wbs_bte_i;
    input [wbs_dat_width/8-1:0] wbs_sel_i;
    input wbs_we_i, wbs_stb_i, wbs_cyc_i;
    output [wbs_dat_width-1:0] wbs_dat_o;
    output wbs_ack_o;
    output wbs_stall_o;
    
    output [mem_ba_size-1:0]    mem_ba;
    output reg [12:0]           mem_a;
    output reg [2:0]            mem_cmd; // {ras,cas,we}
    output                      mem_cke, mem_cs_n;
    output reg [mem_dat_size/8-1:0] mem_dqm;
    output [mem_dat_size-1:0]       mem_dq_o;
    output reg                  mem_dq_oe;
    input  [mem_dat_size-1:0]       mem_dq_i;

    input wb_clk, wb_rst, mem_clk, mem_rst;

    // wbm1
    wire [wbs_dat_width-1:0] wbm1_dat_o;
    wire [wbs_adr_width-1:0] wbm1_adr_o;
    wire [2:0] wbm1_cti_o;
    wire [1:0] wbm1_bte_o;
    wire [wbs_dat_width/8-1:0] wbm1_sel_o;
    wire wbm1_we_o, wbm1_stb_o, wbm1_cyc_o;
    wire [wbs_dat_width-1:0] wbm1_dat_i;
    wire wbm1_ack_i, wbm1_stall_i;
    // wbm2
    wire [mem_dat_size-1:0] wbm2_dat_o;
    wire [mem_ba_size+mem_row_size+mem_col_size-1:0] wbm2_adr_o;
    wire [2:0] wbm2_cti_o;
    wire [1:0] wbm2_bte_o;
    wire [mem_dat_size/8-1:0] wbm2_sel_o;
    wire wbm2_we_o, wbm2_stb_o, wbm2_cyc_o;
    wire [mem_dat_size-1:0] wbm2_dat_i;
    wire wbm2_ack_i, wbm2_stall_i;

`define MODULE wb_shadow_ram
`BASE`MODULE # (
    .shadow_mem_adr_width(shadow_mem_adr_width), .shadow_mem_size(shadow_mem_size), .shadow_mem_init(shadow_mem_init), .shadow_mem_file(shadow_mem_file), .main_mem_adr_width(wbs_adr_width), .dat_width(wbs_dat_width), .mode(wbs_mode), .max_burst_width(wbs_max_burst_width) )
shadow_ram0 (
    .wbs_dat_i(wbs_dat_i),
    .wbs_adr_i(wbs_adr_i),
    .wbs_cti_i(wbs_cti_i),
    .wbs_bte_i(wbs_bte_i),
    .wbs_sel_i(wbs_sel_i),
    .wbs_we_i (wbs_we_i),
    .wbs_stb_i(wbs_stb_i),
    .wbs_cyc_i(wbs_cyc_i), 
    .wbs_dat_o(wbs_dat_o),
    .wbs_ack_o(wbs_ack_o),
    .wbs_stall_o(wbs_stall_o),
    .wbm_dat_o(wbm1_dat_o),
    .wbm_adr_o(wbm1_adr_o),
    .wbm_cti_o(wbm1_cti_o),
    .wbm_bte_o(wbm1_bte_o),
    .wbm_sel_o(wbm1_sel_o),
    .wbm_we_o(wbm1_we_o),
    .wbm_stb_o(wbm1_stb_o),
    .wbm_cyc_o(wbm1_cyc_o), 
    .wbm_dat_i(wbm1_dat_i),
    .wbm_ack_i(wbm1_ack_i),
    .wbm_stall_i(wbm1_stall_i),
    .wb_clk(wb_clk),
    .wb_rst(wb_rst) );
`undef MODULE

`define MODULE wb_cache
`BASE`MODULE # (
    .dw_s(wbs_dat_width), .aw_s(wbs_adr_width), .dw_m(mem_dat_size), .wbs_max_burst_width(cache_aw_offset), .wbs_mode(wbs_mode), .async(cache_async), .nr_of_ways(cache_nr_of_ways), .aw_offset(cache_aw_offset), .aw_slot(cache_aw_slot), .valid_mem(cache_valid_mem) )
cache0 (
    .wbs_dat_i(wbm1_dat_o),
    .wbs_adr_i(wbm1_adr_o),
    .wbs_sel_i(wbm1_sel_o),
    .wbs_cti_i(wbm1_cti_o),
    .wbs_bte_i(wbm1_bte_o),
    .wbs_we_i (wbm1_we_o),
    .wbs_stb_i(wbm1_stb_o),
    .wbs_cyc_i(wbm1_cyc_o),
    .wbs_dat_o(wbm1_dat_i),
    .wbs_ack_o(wbm1_ack_i),
    .wbs_stall_o(wbm1_stall_i),
    .wbs_clk(wb_clk),
    .wbs_rst(wb_rst),
    .wbm_dat_o(wbm2_dat_o),
    .wbm_adr_o(wbm2_adr_o),
    .wbm_sel_o(wbm2_sel_o),
    .wbm_cti_o(wbm2_cti_o),
    .wbm_bte_o(wbm2_bte_o),
    .wbm_we_o (wbm2_we_o),
    .wbm_stb_o(wbm2_stb_o),
    .wbm_cyc_o(wbm2_cyc_o),
    .wbm_dat_i(wbm2_dat_i),
    .wbm_ack_i(wbm2_ack_i),
    .wbm_stall_i(wbm2_stall_i),
    .wbm_clk(mem_clk),
    .wbm_rst(mem_rst) );
`undef MODULE

`define MODULE wb_sdr_sdram
`BASE`MODULE # (
    .dat_size(mem_dat_size), .ba_size(mem_ba_size), .row_size(mem_row_size), .col_size(mem_col_size), .cl(mem_cl), .tRFC(mem_tRFC), .tRP(mem_tRP), .tRCD(mem_tRCD), .tMRD(mem_tMRD), .rfr_length(mem_rfr_length), .rfr_wrap_value(mem_rfr_wrap_value) )
ctrl0(
    // wisbone i/f
    .dat_i(wbm2_dat_o),
    .adr_i(wbm2_adr_o),
    .sel_i(wbm2_sel_o),
    .we_i (wbm2_we_o),
    .cyc_i(wbm2_cyc_o),
    .stb_i(wbm2_stb_o),
    .dat_o(wbm2_dat_i),
    .ack_o(wbm2_ack_i),
    .stall_o(wbm2_stall_i),
    // SDR SDRAM
    .ba(mem_ba),
    .a(mem_a),
    .cmd(mem_cmd),
    .cke(mem_cke),
    .cs_n(mem_cs_n),
    .dqm(mem_dqm),
    .dq_i(mem_dq_i),
    .dq_o(mem_dq_o),
    .dq_oe(mem_dq_oe),
    // system
    .clk(mem_clk),
    .rst(mem_rst) );
`undef MODULE

endmodule
`endif
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Arithmetic functions                                        ////
////                                                              ////
////  Description                                                 ////
////  Arithmetic functions for ALU and DSP                        ////
////                                                              ////
////                                                              ////
////  To Do:                                                      ////
////   -                                                          ////
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

`ifdef MULTS
// signed multiplication
`define MODULE mults
module `BASE`MODULE (a,b,p);
`undef MODULE
parameter operand_a_width = 18;
parameter operand_b_width = 18;
parameter result_hi = 35;
parameter result_lo = 0;
input [operand_a_width-1:0] a;
input [operand_b_width-1:0] b;
output [result_hi:result_lo] p;
wire signed [operand_a_width-1:0] ai;
wire signed [operand_b_width-1:0] bi;
wire signed [operand_a_width+operand_b_width-1:0] result;

    assign ai = a;
    assign bi = b;
    assign result = ai * bi;
    assign p = result[result_hi:result_lo];
    
endmodule
`endif
`ifdef MULTS18X18
`define MODULE mults18x18
module `BASE`MODULE (a,b,p);
`undef MODULE
input [17:0] a,b;
output [35:0] p;
vl_mult
    # (.operand_a_width(18), .operand_b_width(18))
    mult0 (.a(a), .b(b), .p(p));
endmodule
`endif

`ifdef MULT
`define MODULE mult
// unsigned multiplication
module `BASE`MODULE (a,b,p);
`undef MODULE
parameter operand_a_width = 18;
parameter operand_b_width = 18;
parameter result_hi = 35;
parameter result_lo = 0;
input [operand_a_width-1:0] a;
input [operand_b_width-1:0] b;
output [result_hi:result_hi] p;

wire [operand_a_width+operand_b_width-1:0] result;

    assign result = a * b;
    assign p = result[result_hi:result_lo];
    
endmodule
`endif

`ifdef SHIFT_UNIT_32
`define MODULE shift_unit_32
// shift unit
// supporting the following shift functions
//   SLL
//   SRL
//   SRA
`define SHIFT_UNIT_MULT # ( .operand_a_width(25), .operand_b_width(16), .result_hi(14), .result_lo(7))
module `BASE`MODULE( din, s, dout, opcode);
`undef MODULE
input [31:0] din; // data in operand
input [4:0] s; // shift operand
input [1:0] opcode;
output [31:0] dout;

parameter opcode_sll = 2'b00;
parameter opcode_srl = 2'b01;
parameter opcode_sra = 2'b10;
parameter opcode_ror = 2'b11;

parameter mult=0; // if set to 1 implemented based on multipliers which saves LUT

generate
if (mult==1) begin : impl_mult
wire sll, sra;
assign sll = opcode == opcode_sll;
assign sra = opcode == opcode_sra;

wire [15:1] s1;
wire [3:0] sign;
wire [7:0] tmp [0:3];

// first stage is multiplier based
// shift operand as fractional 8.7
assign s1[15] = sll & s[2:0]==3'd7;
assign s1[14] = sll & s[2:0]==3'd6;
assign s1[13] = sll & s[2:0]==3'd5;
assign s1[12] = sll & s[2:0]==3'd4;
assign s1[11] = sll & s[2:0]==3'd3;
assign s1[10] = sll & s[2:0]==3'd2;
assign s1[ 9] = sll & s[2:0]==3'd1;
assign s1[ 8] = s[2:0]==3'd0;
assign s1[ 7] = !sll & s[2:0]==3'd1;
assign s1[ 6] = !sll & s[2:0]==3'd2;
assign s1[ 5] = !sll & s[2:0]==3'd3;
assign s1[ 4] = !sll & s[2:0]==3'd4;
assign s1[ 3] = !sll & s[2:0]==3'd5;
assign s1[ 2] = !sll & s[2:0]==3'd6;
assign s1[ 1] = !sll & s[2:0]==3'd7;

assign sign[3] = din[31] & sra;
assign sign[2] = sign[3] & (&din[31:24]);
assign sign[1] = sign[2] & (&din[23:16]);
assign sign[0] = sign[1] & (&din[15:8]);
`define MODULE mults
`BASE`MODULE `SHIFT_UNIT_MULT mult_byte3 ( .a({sign[3], {8{sign[3]}},din[31:24], din[23:16]}), .b({1'b0,s1}), .p(tmp[3]));
`BASE`MODULE `SHIFT_UNIT_MULT mult_byte2 ( .a({sign[2], din[31:24]  ,din[23:16],  din[15:8]}), .b({1'b0,s1}), .p(tmp[2]));
`BASE`MODULE `SHIFT_UNIT_MULT mult_byte1 ( .a({sign[1], din[23:16]  ,din[15:8],   din[7:0]}), .b({1'b0,s1}), .p(tmp[1]));
`BASE`MODULE `SHIFT_UNIT_MULT mult_byte0 ( .a({sign[0], din[15:8]   ,din[7:0],    8'h00}),      .b({1'b0,s1}), .p(tmp[0]));
`undef MODULE
// second stage is multiplexer based
// shift on byte level

// mux byte 3
assign dout[31:24] = (s[4:3]==2'b00) ? tmp[3] :
                     (sll & s[4:3]==2'b01) ? tmp[2] :
                     (sll & s[4:3]==2'b10) ? tmp[1] :
                     (sll & s[4:3]==2'b11) ? tmp[0] :
                     {8{sign[3]}};

// mux byte 2
assign dout[23:16] = (s[4:3]==2'b00) ? tmp[2] :
                     (sll & s[4:3]==2'b01) ? tmp[1] :
                     (sll & s[4:3]==2'b10) ? tmp[0] :
                     (sll & s[4:3]==2'b11) ? {8{1'b0}} :
                     (s[4:3]==2'b01) ? tmp[3] :
                     {8{sign[3]}};

// mux byte 1
assign dout[15:8]  = (s[4:3]==2'b00) ? tmp[1] :
                     (sll & s[4:3]==2'b01) ? tmp[0] :
                     (sll & s[4:3]==2'b10) ? {8{1'b0}} :
                     (sll & s[4:3]==2'b11) ? {8{1'b0}} :
                     (s[4:3]==2'b01) ? tmp[2] :
                     (s[4:3]==2'b10) ? tmp[3] :
                     {8{sign[3]}};

// mux byte 0
assign dout[7:0]   = (s[4:3]==2'b00) ? tmp[0] :
                     (sll) ?  {8{1'b0}}:
                     (s[4:3]==2'b01) ? tmp[1] :
                     (s[4:3]==2'b10) ? tmp[2] :
                     tmp[3];
end else begin : impl_classic

assign dout =
    (opcode==opcode_sll) ? din << s :
    (opcode==opcode_srl) ? din >> s :
    (opcode==opcode_sra) ? (din >> s) | ({32{din[31]}} << (6'd32-{1'b0,s})) :
    din << s;
    
end
endgenerate

endmodule
`endif

`ifdef LOGIC_UNIT
// logic unit
// supporting the following logic functions
//    a and b
//    a or  b
//    a xor b
//    not b
`define MODULE logic_unit
module `BASE`MODULE( a, b, result, opcode);
`undef MODULE
parameter width = 32;
parameter opcode_and = 2'b00;
parameter opcode_or  = 2'b01;
parameter opcode_xor = 2'b10;
input [width-1:0] a,b;
output [width-1:0] result;
input [1:0] opcode;

assign result = (opcode==opcode_and) ? a & b :
                (opcode==opcode_or)  ? a | b :
                (opcode==opcode_xor) ? a ^ b :
                b;

endmodule
`endif

`ifdef ARITH_UNIT
`define MODULE arith_unit
module `BASE`MODULE ( a, b, c_in, add_sub, sign, result, c_out, z, ovfl);
`undef MODULE
parameter width = 32;
parameter opcode_add = 1'b0;
parameter opcode_sub = 1'b1;
input [width-1:0] a,b;
input c_in, add_sub, sign;
output [width-1:0] result;
output c_out, z, ovfl;

assign {c_out,result} = {(a[width-1] & sign),a} + ({a[width-1] & sign,b} ^ {(width+1){(add_sub==opcode_sub)}}) + {{(width-1){1'b0}},(c_in | (add_sub==opcode_sub))};
assign z = (result=={width{1'b0}});
assign ovfl = ( a[width-1] &  b[width-1] & ~result[width-1]) |
               (~a[width-1] & ~b[width-1] &  result[width-1]);
endmodule
`endif

`ifdef COUNT_UNIT
`define MODULE count_unit
module `BASE`MODULE (din, dout, opcode);
`undef MODULE
parameter width = 32;
input [width-1:0] din;
output [width-1:0] dout;
input opcode;

integer i;
wire [width/32+4:0] ff1, fl1;

/*
always @(din) begin
    ff1 = 0; i = 0;
    while (din[i] == 0 && i < width) begin // complex condition
        ff1 = ff1 + 1;
        i = i + 1;
    end
end

always @(din) begin
    fl1 = width; i = width-1;
    while (din[i] == 0 && i >= width) begin // complex condition
        fl1 = fl1 - 1;
        i = i - 1;
    end
end
*/

generate
if (width==32) begin

    assign ff1 = din[0] ? 6'd1 :
                 din[1] ? 6'd2 :
                 din[2] ? 6'd3 :
                 din[3] ? 6'd4 :
                 din[4] ? 6'd5 :
                 din[5] ? 6'd6 :
                 din[6] ? 6'd7 :
                 din[7] ? 6'd8 :
                 din[8] ? 6'd9 :
                 din[9] ? 6'd10 :
                 din[10] ? 6'd11 :
                 din[11] ? 6'd12 :
                 din[12] ? 6'd13 :
                 din[13] ? 6'd14 :
                 din[14] ? 6'd15 :
                 din[15] ? 6'd16 :
                 din[16] ? 6'd17 :
                 din[17] ? 6'd18 :
                 din[18] ? 6'd19 :
                 din[19] ? 6'd20 :
                 din[20] ? 6'd21 :
                 din[21] ? 6'd22 :
                 din[22] ? 6'd23 :
                 din[23] ? 6'd24 :
                 din[24] ? 6'd25 :
                 din[25] ? 6'd26 :
                 din[26] ? 6'd27 :
                 din[27] ? 6'd28 :
                 din[28] ? 6'd29 :
                 din[29] ? 6'd30 :
                 din[30] ? 6'd31 :
                 din[31] ? 6'd32 :
                 6'd0;

    assign fl1 = din[31] ? 6'd32 :
                 din[30] ? 6'd31 :
                 din[29] ? 6'd30 :
                 din[28] ? 6'd29 :
                 din[27] ? 6'd28 :
                 din[26] ? 6'd27 :
                 din[25] ? 6'd26 :
                 din[24] ? 6'd25 :
                 din[23] ? 6'd24 :
                 din[22] ? 6'd23 :
                 din[21] ? 6'd22 :
                 din[20] ? 6'd21 :
                 din[19] ? 6'd20 :
                 din[18] ? 6'd19 :
                 din[17] ? 6'd18 :
                 din[16] ? 6'd17 :
                 din[15] ? 6'd16 :
                 din[14] ? 6'd15 :
                 din[13] ? 6'd14 :
                 din[12] ? 6'd13 :
                 din[11] ? 6'd12 :
                 din[10] ? 6'd11 :
                 din[9] ? 6'd10 :
                 din[8] ? 6'd9 :
                 din[7] ? 6'd8 :
                 din[6] ? 6'd7 :
                 din[5] ? 6'd6 :
                 din[4] ? 6'd5 :
                 din[3] ? 6'd4 :
                 din[2] ? 6'd3 :
                 din[1] ? 6'd2 :
                 din[0] ? 6'd1 :
                 6'd0;
                 
    assign dout = (!opcode) ? {{26{1'b0}}, ff1} : {{26{1'b0}}, fl1};
end
endgenerate

generate
if (width==64) begin
    assign ff1 = 7'd0;
    assign fl1 = 7'd0;
    assign dout = (!opcode) ? {{57{1'b0}}, ff1} : {{57{1'b0}}, fl1};
end
endgenerate

endmodule
`endif

`ifdef EXT_UNIT
`define MODULE ext_unit
module `BASE`MODULE ( a, b, F, result, opcode);
`undef MODULE
parameter width = 32;
input [width-1:0] a, b;
input F;
output reg [width-1:0] result;
input [2:0] opcode;

generate
if (width==32) begin
always @ (a or b or F or opcode)
begin
    case (opcode)
    3'b000: result = {{24{1'b0}},a[7:0]};
    3'b001: result = {{24{a[7]}},a[7:0]};
    3'b010: result = {{16{1'b0}},a[7:0]};
    3'b011: result = {{16{a[15]}},a[15:0]};
    3'b110: result = (F) ? a : b;
    default: result = {b[15:0],16'h0000};
    endcase
end
end
endgenerate

generate
if (width==64) begin
always @ (a or b or F or opcode)
begin
    case (opcode)
    3'b000: result = {{56{1'b0}},a[7:0]};
    3'b001: result = {{56{a[7]}},a[7:0]};
    3'b010: result = {{48{1'b0}},a[7:0]};
    3'b011: result = {{48{a[15]}},a[15:0]};
    3'b110: result = (F) ? a : b;
    default: result = {32'h00000000,b[15:0],16'h0000};
    endcase
end
end
endgenerate
endmodule
`endif
