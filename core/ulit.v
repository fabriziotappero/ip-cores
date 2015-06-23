/******************************************************************
 *                                                                * 
 *    Author: Liwei                                               * 
 *                                                                * 
 *    This file is part of the "mips789" project.                 * 
 *    Downloaded from:                                            * 
 *    http://www.opencores.org/pdownloads.cgi/list/mips789        * 
 *                                                                * 
 *    If you encountered any problem, please contact me via       * 
 *    Email:mcupro@opencores.org  or mcupro@163.com               * 
 *                                                                * 
 ******************************************************************/

`include "mips789_defs.v"

module cal_cpi (		 	   //just used to calculate CPI(Cycles Per Instruction) for stimulation
        input clk,
        input rst,
        input is_nop,
        output reg [100:0] ins_no,
        output reg [100:0] clk_no);

    always @(posedge clk  )
        if (~rst )clk_no=0;
        else
            clk_no = 1+clk_no;

    always @(posedge clk )
        if (~rst )ins_no=0;
        else if (~is_nop)
            ins_no = 1+ins_no;
endmodule


module add32(
        input [31:0]d_i,
        output [31:0]d_o
    );
    assign d_o = d_i + 4;
endmodule


module jack(
        input [31:0] ins_i ,
        output [4:0] rs_o,
        output [4:0] rt_o,
        output [4:0] rd_o
    );
    assign rs_o = ins_i[25:21];
    assign rt_o = ins_i[20:16];
    assign rd_o = ins_i[15:11];
endmodule



module wb_mux(
        input [31:0]alu_i,
        input [31:0]dmem_i,
        input sel,
        output [31:0]wb_o
    );

    assign wb_o = (sel==`WB_MEM)?dmem_i:alu_i;

endmodule

module or32(
        input [31:0]a,
        input [31:0]b,
        output [31:0]c
    );

    assign c = a|b ;

endmodule

module rd_sel(
        input [4:0]rd_i,
        input [4:0]rt_i,
        input[1:0] ctl,
        output reg [4:0]rd_o
    );

    always @(*)
    case (ctl)
        `RD_RD:rd_o=rd_i;
        `RD_RT:rd_o=rt_i;
        `RD_R31:rd_o='d31;
        default :
            rd_o=0;
    endcase
endmodule

//these modules below are genated automaticly by a software written in C language...
//Some of these may not be used

module ext_ctl_reg_clr_cls(input[`EXT_CTL_LEN-1:0] ext_ctl_i,output reg[`EXT_CTL_LEN-1:0] ext_ctl_o,input clk,input clr,input cls);always@(posedge clk)if(clr) ext_ctl_o<=0;else if(cls)ext_ctl_o<=ext_ctl_o;else ext_ctl_o<=ext_ctl_i;endmodule
module rd_sel_reg_clr_cls(input[`RD_SEL_LEN-1:0] rd_sel_i,output reg[`RD_SEL_LEN-1:0] rd_sel_o,input clk,input clr,input cls);always@(posedge clk)if(clr) rd_sel_o<=0;else if(cls)rd_sel_o<=rd_sel_o;else rd_sel_o<=rd_sel_i;endmodule
module cmp_ctl_reg_clr_cls(input[`CMP_CTL_LEN-1:0] cmp_ctl_i,output reg[`CMP_CTL_LEN-1:0] cmp_ctl_o,input clk,input clr,input cls);always@(posedge clk)if(clr) cmp_ctl_o<=0;else if(cls)cmp_ctl_o<=cmp_ctl_o;else cmp_ctl_o<=cmp_ctl_i;endmodule
module pc_gen_ctl_reg_clr_cls(input[`PC_GEN_CTL_LEN-1:0] pc_gen_ctl_i,output reg[`PC_GEN_CTL_LEN-1:0] pc_gen_ctl_o,input clk,input clr,input cls);always@(posedge clk)if(clr) pc_gen_ctl_o<=0;else if(cls)pc_gen_ctl_o<=pc_gen_ctl_o;else pc_gen_ctl_o<=pc_gen_ctl_i;endmodule
module fsm_ctl_reg_clr_cls(input[`FSM_CTL_LEN-1:0] fsm_ctl_i,output reg[`FSM_CTL_LEN-1:0] fsm_ctl_o,input clk,input clr,input cls);always@(posedge clk)if(clr) fsm_ctl_o<=0;else if(cls)fsm_ctl_o<=fsm_ctl_o;else fsm_ctl_o<=fsm_ctl_i;endmodule
module muxa_ctl_reg_clr_cls(input[`MUXA_CTL_LEN-1:0] muxa_ctl_i,output reg[`MUXA_CTL_LEN-1:0] muxa_ctl_o,input clk,input clr,input cls);always@(posedge clk)if(clr) muxa_ctl_o<=0;else if(cls)muxa_ctl_o<=muxa_ctl_o;else muxa_ctl_o<=muxa_ctl_i;endmodule
module muxb_ctl_reg_clr_cls(input[`MUXB_CTL_LEN-1:0] muxb_ctl_i,output reg[`MUXB_CTL_LEN-1:0] muxb_ctl_o,input clk,input clr,input cls);always@(posedge clk)if(clr) muxb_ctl_o<=0;else if(cls)muxb_ctl_o<=muxb_ctl_o;else muxb_ctl_o<=muxb_ctl_i;endmodule
module alu_func_reg_clr_cls(input[`ALU_FUNC_LEN-1:0] alu_func_i,output reg[`ALU_FUNC_LEN-1:0] alu_func_o,input clk,input clr,input cls);always@(posedge clk)if(clr) alu_func_o<=0;else if(cls)alu_func_o<=alu_func_o;else alu_func_o<=alu_func_i;endmodule
module alu_we_reg_clr_cls(input[`ALU_WE_LEN-1:0] alu_we_i,output reg[`ALU_WE_LEN-1:0] alu_we_o,input clk,input clr,input cls);always@(posedge clk)if(clr) alu_we_o<=0;else if(cls)alu_we_o<=alu_we_o;else alu_we_o<=alu_we_i;endmodule
module dmem_ctl_reg_clr_cls(input[`DMEM_CTL_LEN-1:0] dmem_ctl_i,output reg[`DMEM_CTL_LEN-1:0] dmem_ctl_o,input clk,input clr,input cls);always@(posedge clk)if(clr) dmem_ctl_o<=0;else if(cls)dmem_ctl_o<=dmem_ctl_o;else dmem_ctl_o<=dmem_ctl_i;endmodule
module wb_mux_ctl_reg_clr_cls(input[`WB_MUX_CTL_LEN-1:0] wb_mux_ctl_i,output reg[`WB_MUX_CTL_LEN-1:0] wb_mux_ctl_o,input clk,input clr,input cls);always@(posedge clk)if(clr) wb_mux_ctl_o<=0;else if(cls)wb_mux_ctl_o<=wb_mux_ctl_o;else wb_mux_ctl_o<=wb_mux_ctl_i;endmodule
module wb_we_reg_clr_cls(input[`WB_WE_LEN-1:0] wb_we_i,output reg[`WB_WE_LEN-1:0] wb_we_o,input clk,input clr,input cls);always@(posedge clk)if(clr) wb_we_o<=0;else if(cls)wb_we_o<=wb_we_o;else wb_we_o<=wb_we_i;endmodule
module ins_reg_clr_cls(input[`INS_LEN-1:0] ins_i,output reg[`INS_LEN-1:0] ins_o,input clk,input clr,input cls);always@(posedge clk)if(clr) ins_o<=0;else if(cls)ins_o<=ins_o;else ins_o<=ins_i;endmodule
module pc_reg_clr_cls(input[`PC_LEN-1:0] pc_i,output reg[`PC_LEN-1:0] pc_o,input clk,input clr,input cls);always@(posedge clk)if(clr) pc_o<=0;else if(cls)pc_o<=pc_o;else pc_o<=pc_i;endmodule
module spc_reg_clr_cls(input[`SPC_LEN-1:0] spc_i,output reg[`SPC_LEN-1:0] spc_o,input clk,input clr,input cls);always@(posedge clk)if(clr) spc_o<=0;else if(cls)spc_o<=spc_o;else spc_o<=spc_i;endmodule
module r1_reg_clr_cls(input[`R1_LEN-1:0] r1_i,output reg[`R1_LEN-1:0] r1_o,input clk,input clr,input cls);always@(posedge clk)if(clr) r1_o<=0;else if(cls)r1_o<=r1_o;else r1_o<=r1_i;endmodule
module r2_reg_clr_cls(input[`R2_LEN-1:0] r2_i,output reg[`R2_LEN-1:0] r2_o,input clk,input clr,input cls);always@(posedge clk)if(clr) r2_o<=0;else if(cls)r2_o<=r2_o;else r2_o<=r2_i;endmodule
module r3_reg_clr_cls(input[`R3_LEN-1:0] r3_i,output reg[`R3_LEN-1:0] r3_o,input clk,input clr,input cls);always@(posedge clk)if(clr) r3_o<=0;else if(cls)r3_o<=r3_o;else r3_o<=r3_i;endmodule
module r4_reg_clr_cls(input[`R4_LEN-1:0] r4_i,output reg[`R4_LEN-1:0] r4_o,input clk,input clr,input cls);always@(posedge clk)if(clr) r4_o<=0;else if(cls)r4_o<=r4_o;else r4_o<=r4_i;endmodule
module r5_reg_clr_cls(input[`R5_LEN-1:0] r5_i,output reg[`R5_LEN-1:0] r5_o,input clk,input clr,input cls);always@(posedge clk)if(clr) r5_o<=0;else if(cls)r5_o<=r5_o;else r5_o<=r5_i;endmodule
module r32_reg_clr_cls(input[`R32_LEN-1:0] r32_i,output reg[`R32_LEN-1:0] r32_o,input clk,input clr,input cls);always@(posedge clk)if(clr) r32_o<=0;else if(cls)r32_o<=r32_o;else r32_o<=r32_i;endmodule


module ext_ctl_reg_clr(input[`EXT_CTL_LEN-1:0] ext_ctl_i,output reg[`EXT_CTL_LEN-1:0] ext_ctl_o,input clk,input clr);always@(posedge clk)if(clr)ext_ctl_o<=0;else ext_ctl_o<=ext_ctl_i;endmodule
module rd_sel_reg_clr(input[`RD_SEL_LEN-1:0] rd_sel_i,output reg[`RD_SEL_LEN-1:0] rd_sel_o,input clk,input clr);always@(posedge clk)if(clr)rd_sel_o<=0;else rd_sel_o<=rd_sel_i;endmodule
module cmp_ctl_reg_clr(input[`CMP_CTL_LEN-1:0] cmp_ctl_i,output reg[`CMP_CTL_LEN-1:0] cmp_ctl_o,input clk,input clr);always@(posedge clk)if(clr)cmp_ctl_o<=0;else cmp_ctl_o<=cmp_ctl_i;endmodule
module pc_gen_ctl_reg_clr(input[`PC_GEN_CTL_LEN-1:0] pc_gen_ctl_i,output reg[`PC_GEN_CTL_LEN-1:0] pc_gen_ctl_o,input clk,input clr);always@(posedge clk)if(clr)pc_gen_ctl_o<=0;else pc_gen_ctl_o<=pc_gen_ctl_i;endmodule
module fsm_ctl_reg_clr(input[`FSM_CTL_LEN-1:0] fsm_ctl_i,output reg[`FSM_CTL_LEN-1:0] fsm_ctl_o,input clk,input clr);always@(posedge clk)if(clr)fsm_ctl_o<=0;else fsm_ctl_o<=fsm_ctl_i;endmodule
module muxa_ctl_reg_clr(input[`MUXA_CTL_LEN-1:0] muxa_ctl_i,output reg[`MUXA_CTL_LEN-1:0] muxa_ctl_o,input clk,input clr);always@(posedge clk)if(clr)muxa_ctl_o<=0;else muxa_ctl_o<=muxa_ctl_i;endmodule
module muxb_ctl_reg_clr(input[`MUXB_CTL_LEN-1:0] muxb_ctl_i,output reg[`MUXB_CTL_LEN-1:0] muxb_ctl_o,input clk,input clr);always@(posedge clk)if(clr)muxb_ctl_o<=0;else muxb_ctl_o<=muxb_ctl_i;endmodule
module alu_func_reg_clr(input[`ALU_FUNC_LEN-1:0] alu_func_i,output reg[`ALU_FUNC_LEN-1:0] alu_func_o,input clk,input clr);always@(posedge clk)if(clr)alu_func_o<=0;else alu_func_o<=alu_func_i;endmodule
module alu_we_reg_clr(input[`ALU_WE_LEN-1:0] alu_we_i,output reg[`ALU_WE_LEN-1:0] alu_we_o,input clk,input clr);always@(posedge clk)if(clr)alu_we_o<=0;else alu_we_o<=alu_we_i;endmodule
module dmem_ctl_reg_clr(input[`DMEM_CTL_LEN-1:0] dmem_ctl_i,output reg[`DMEM_CTL_LEN-1:0] dmem_ctl_o,input clk,input clr);always@(posedge clk)if(clr)dmem_ctl_o<=0;else dmem_ctl_o<=dmem_ctl_i;endmodule
module wb_mux_ctl_reg_clr(input[`WB_MUX_CTL_LEN-1:0] wb_mux_ctl_i,output reg[`WB_MUX_CTL_LEN-1:0] wb_mux_ctl_o,input clk,input clr);always@(posedge clk)if(clr)wb_mux_ctl_o<=0;else wb_mux_ctl_o<=wb_mux_ctl_i;endmodule
module wb_we_reg_clr(input[`WB_WE_LEN-1:0] wb_we_i,output reg[`WB_WE_LEN-1:0] wb_we_o,input clk,input clr);always@(posedge clk)if(clr)wb_we_o<=0;else wb_we_o<=wb_we_i;endmodule
module ins_reg_clr(input[`INS_LEN-1:0] ins_i,output reg[`INS_LEN-1:0] ins_o,input clk,input clr);always@(posedge clk)if(clr)ins_o<=0;else ins_o<=ins_i;endmodule
module pc_reg_clr(input[`PC_LEN-1:0] pc_i,output reg[`PC_LEN-1:0] pc_o,input clk,input clr);always@(posedge clk)if(clr)pc_o<=0;else pc_o<=pc_i;endmodule
module spc_reg_clr(input[`SPC_LEN-1:0] spc_i,output reg[`SPC_LEN-1:0] spc_o,input clk,input clr);always@(posedge clk)if(clr)spc_o<=0;else spc_o<=spc_i;endmodule
module r1_reg_clr(input[`R1_LEN-1:0] r1_i,output reg[`R1_LEN-1:0] r1_o,input clk,input clr);always@(posedge clk)if(clr)r1_o<=0;else r1_o<=r1_i;endmodule
module r2_reg_clr(input[`R2_LEN-1:0] r2_i,output reg[`R2_LEN-1:0] r2_o,input clk,input clr);always@(posedge clk)if(clr)r2_o<=0;else r2_o<=r2_i;endmodule
module r3_reg_clr(input[`R3_LEN-1:0] r3_i,output reg[`R3_LEN-1:0] r3_o,input clk,input clr);always@(posedge clk)if(clr)r3_o<=0;else r3_o<=r3_i;endmodule
module r4_reg_clr(input[`R4_LEN-1:0] r4_i,output reg[`R4_LEN-1:0] r4_o,input clk,input clr);always@(posedge clk)if(clr)r4_o<=0;else r4_o<=r4_i;endmodule
module r5_reg_clr(input[`R5_LEN-1:0] r5_i,output reg[`R5_LEN-1:0] r5_o,input clk,input clr);always@(posedge clk)if(clr)r5_o<=0;else r5_o<=r5_i;endmodule
module r32_reg_clr(input[`R32_LEN-1:0] r32_i,output reg[`R32_LEN-1:0] r32_o,input clk,input clr);always@(posedge clk)if(clr)r32_o<=0;else r32_o<=r32_i;endmodule


module ext_ctl_reg(input[`EXT_CTL_LEN-1:0] ext_ctl_i,output reg[`EXT_CTL_LEN-1:0] ext_ctl_o,input clk);always@(posedge clk) ext_ctl_o<=ext_ctl_i;endmodule
module rd_sel_reg(input[`RD_SEL_LEN-1:0] rd_sel_i,output reg[`RD_SEL_LEN-1:0] rd_sel_o,input clk);always@(posedge clk) rd_sel_o<=rd_sel_i;endmodule
module cmp_ctl_reg(input[`CMP_CTL_LEN-1:0] cmp_ctl_i,output reg[`CMP_CTL_LEN-1:0] cmp_ctl_o,input clk);always@(posedge clk) cmp_ctl_o<=cmp_ctl_i;endmodule
module pc_gen_ctl_reg(input[`PC_GEN_CTL_LEN-1:0] pc_gen_ctl_i,output reg[`PC_GEN_CTL_LEN-1:0] pc_gen_ctl_o,input clk);always@(posedge clk) pc_gen_ctl_o<=pc_gen_ctl_i;endmodule
module fsm_ctl_reg(input[`FSM_CTL_LEN-1:0] fsm_ctl_i,output reg[`FSM_CTL_LEN-1:0] fsm_ctl_o,input clk);always@(posedge clk) fsm_ctl_o<=fsm_ctl_i;endmodule
module muxa_ctl_reg(input[`MUXA_CTL_LEN-1:0] muxa_ctl_i,output reg[`MUXA_CTL_LEN-1:0] muxa_ctl_o,input clk);always@(posedge clk) muxa_ctl_o<=muxa_ctl_i;endmodule
module muxb_ctl_reg(input[`MUXB_CTL_LEN-1:0] muxb_ctl_i,output reg[`MUXB_CTL_LEN-1:0] muxb_ctl_o,input clk);always@(posedge clk) muxb_ctl_o<=muxb_ctl_i;endmodule
module alu_func_reg(input[`ALU_FUNC_LEN-1:0] alu_func_i,output reg[`ALU_FUNC_LEN-1:0] alu_func_o,input clk);always@(posedge clk) alu_func_o<=alu_func_i;endmodule
module alu_we_reg(input[`ALU_WE_LEN-1:0] alu_we_i,output reg[`ALU_WE_LEN-1:0] alu_we_o,input clk);always@(posedge clk) alu_we_o<=alu_we_i;endmodule
module dmem_ctl_reg(input[`DMEM_CTL_LEN-1:0] dmem_ctl_i,output reg[`DMEM_CTL_LEN-1:0] dmem_ctl_o,input clk);always@(posedge clk) dmem_ctl_o<=dmem_ctl_i;endmodule
module wb_mux_ctl_reg(input[`WB_MUX_CTL_LEN-1:0] wb_mux_ctl_i,output reg[`WB_MUX_CTL_LEN-1:0] wb_mux_ctl_o,input clk);always@(posedge clk) wb_mux_ctl_o<=wb_mux_ctl_i;endmodule
module wb_we_reg(input[`WB_WE_LEN-1:0] wb_we_i,output reg[`WB_WE_LEN-1:0] wb_we_o,input clk);always@(posedge clk) wb_we_o<=wb_we_i;endmodule
module ins_reg(input[`INS_LEN-1:0] ins_i,output reg[`INS_LEN-1:0] ins_o,input clk);always@(posedge clk) ins_o<=ins_i;endmodule
module pc_reg(input[`PC_LEN-1:0] pc_i,output reg[`PC_LEN-1:0] pc_o,input clk);always@(posedge clk) pc_o<=pc_i;endmodule
module spc_reg(input[`SPC_LEN-1:0] spc_i,output reg[`SPC_LEN-1:0] spc_o,input clk);always@(posedge clk) spc_o<=spc_i;endmodule
module r1_reg(input[`R1_LEN-1:0] r1_i,output reg[`R1_LEN-1:0] r1_o,input clk);always@(posedge clk) r1_o<=r1_i;endmodule
module r2_reg(input[`R2_LEN-1:0] r2_i,output reg[`R2_LEN-1:0] r2_o,input clk);always@(posedge clk) r2_o<=r2_i;endmodule
module r3_reg(input[`R3_LEN-1:0] r3_i,output reg[`R3_LEN-1:0] r3_o,input clk);always@(posedge clk) r3_o<=r3_i;endmodule
module r4_reg(input[`R4_LEN-1:0] r4_i,output reg[`R4_LEN-1:0] r4_o,input clk);always@(posedge clk) r4_o<=r4_i;endmodule
module r5_reg(input[`R5_LEN-1:0] r5_i,output reg[`R5_LEN-1:0] r5_o,input clk);always@(posedge clk) r5_o<=r5_i;endmodule
module r32_reg(input[`R32_LEN-1:0] r32_i,output reg[`R32_LEN-1:0] r32_o,input clk);always@(posedge clk) r32_o<=r32_i;endmodule


module ext_ctl_reg_cls(input[`EXT_CTL_LEN-1:0] ext_ctl_i,output reg[`EXT_CTL_LEN-1:0] ext_ctl_o,input clk,input cls);always@(posedge clk)if(cls) ext_ctl_o<=ext_ctl_o;else ext_ctl_o<=ext_ctl_i;endmodule
module rd_sel_reg_cls(input[`RD_SEL_LEN-1:0] rd_sel_i,output reg[`RD_SEL_LEN-1:0] rd_sel_o,input clk,input cls);always@(posedge clk)if(cls) rd_sel_o<=rd_sel_o;else rd_sel_o<=rd_sel_i;endmodule
module cmp_ctl_reg_cls(input[`CMP_CTL_LEN-1:0] cmp_ctl_i,output reg[`CMP_CTL_LEN-1:0] cmp_ctl_o,input clk,input cls);always@(posedge clk)if(cls) cmp_ctl_o<=cmp_ctl_o;else cmp_ctl_o<=cmp_ctl_i;endmodule
module pc_gen_ctl_reg_cls(input[`PC_GEN_CTL_LEN-1:0] pc_gen_ctl_i,output reg[`PC_GEN_CTL_LEN-1:0] pc_gen_ctl_o,input clk,input cls);always@(posedge clk)if(cls) pc_gen_ctl_o<=pc_gen_ctl_o;else pc_gen_ctl_o<=pc_gen_ctl_i;endmodule
module fsm_ctl_reg_cls(input[`FSM_CTL_LEN-1:0] fsm_ctl_i,output reg[`FSM_CTL_LEN-1:0] fsm_ctl_o,input clk,input cls);always@(posedge clk)if(cls) fsm_ctl_o<=fsm_ctl_o;else fsm_ctl_o<=fsm_ctl_i;endmodule
module muxa_ctl_reg_cls(input[`MUXA_CTL_LEN-1:0] muxa_ctl_i,output reg[`MUXA_CTL_LEN-1:0] muxa_ctl_o,input clk,input cls);always@(posedge clk)if(cls) muxa_ctl_o<=muxa_ctl_o;else muxa_ctl_o<=muxa_ctl_i;endmodule
module muxb_ctl_reg_cls(input[`MUXB_CTL_LEN-1:0] muxb_ctl_i,output reg[`MUXB_CTL_LEN-1:0] muxb_ctl_o,input clk,input cls);always@(posedge clk)if(cls) muxb_ctl_o<=muxb_ctl_o;else muxb_ctl_o<=muxb_ctl_i;endmodule
module alu_func_reg_cls(input[`ALU_FUNC_LEN-1:0] alu_func_i,output reg[`ALU_FUNC_LEN-1:0] alu_func_o,input clk,input cls);always@(posedge clk)if(cls) alu_func_o<=alu_func_o;else alu_func_o<=alu_func_i;endmodule
module alu_we_reg_cls(input[`ALU_WE_LEN-1:0] alu_we_i,output reg[`ALU_WE_LEN-1:0] alu_we_o,input clk,input cls);always@(posedge clk)if(cls) alu_we_o<=alu_we_o;else alu_we_o<=alu_we_i;endmodule
module dmem_ctl_reg_cls(input[`DMEM_CTL_LEN-1:0] dmem_ctl_i,output reg[`DMEM_CTL_LEN-1:0] dmem_ctl_o,input clk,input cls);always@(posedge clk)if(cls) dmem_ctl_o<=dmem_ctl_o;else dmem_ctl_o<=dmem_ctl_i;endmodule
module wb_mux_ctl_reg_cls(input[`WB_MUX_CTL_LEN-1:0] wb_mux_ctl_i,output reg[`WB_MUX_CTL_LEN-1:0] wb_mux_ctl_o,input clk,input cls);always@(posedge clk)if(cls) wb_mux_ctl_o<=wb_mux_ctl_o;else wb_mux_ctl_o<=wb_mux_ctl_i;endmodule
module wb_we_reg_cls(input[`WB_WE_LEN-1:0] wb_we_i,output reg[`WB_WE_LEN-1:0] wb_we_o,input clk,input cls);always@(posedge clk)if(cls) wb_we_o<=wb_we_o;else wb_we_o<=wb_we_i;endmodule
module ins_reg_cls(input[`INS_LEN-1:0] ins_i,output reg[`INS_LEN-1:0] ins_o,input clk,input cls);always@(posedge clk)if(cls) ins_o<=ins_o;else ins_o<=ins_i;endmodule
module pc_reg_cls(input[`PC_LEN-1:0] pc_i,output reg[`PC_LEN-1:0] pc_o,input clk,input cls);always@(posedge clk)if(cls) pc_o<=pc_o;else pc_o<=pc_i;endmodule
module spc_reg_cls(input[`SPC_LEN-1:0] spc_i,output reg[`SPC_LEN-1:0] spc_o,input clk,input cls);always@(posedge clk)if(cls) spc_o<=spc_o;else spc_o<=spc_i;endmodule
module r1_reg_cls(input[`R1_LEN-1:0] r1_i,output reg[`R1_LEN-1:0] r1_o,input clk,input cls);always@(posedge clk)if(cls) r1_o<=r1_o;else r1_o<=r1_i;endmodule
module r2_reg_cls(input[`R2_LEN-1:0] r2_i,output reg[`R2_LEN-1:0] r2_o,input clk,input cls);always@(posedge clk)if(cls) r2_o<=r2_o;else r2_o<=r2_i;endmodule
module r3_reg_cls(input[`R3_LEN-1:0] r3_i,output reg[`R3_LEN-1:0] r3_o,input clk,input cls);always@(posedge clk)if(cls) r3_o<=r3_o;else r3_o<=r3_i;endmodule
module r4_reg_cls(input[`R4_LEN-1:0] r4_i,output reg[`R4_LEN-1:0] r4_o,input clk,input cls);always@(posedge clk)if(cls) r4_o<=r4_o;else r4_o<=r4_i;endmodule
module r5_reg_cls(input[`R5_LEN-1:0] r5_i,output reg[`R5_LEN-1:0] r5_o,input clk,input cls);always@(posedge clk)if(cls) r5_o<=r5_o;else r5_o<=r5_i;endmodule
module r32_reg_cls(input[`R32_LEN-1:0] r32_i,output reg[`R32_LEN-1:0] r32_o,input clk,input cls);always@(posedge clk)if(cls) r32_o<=r32_o;else r32_o<=r32_i;endmodule


	 
module portio16(
        inout [15:0] io_port,
        output [15:0] dfport,
        input [15:0] d2port,
        input wr_en
    );

    assign dfport = io_port ;
    assign io_port = wr_en ? d2port : 16'bz;

endmodule
