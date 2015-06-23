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
module decoder(
        input [31:0]ins_i,
        output reg [`EXT_CTL_LEN-1:0] ext_ctl,
        output reg [`RD_SEL_LEN-1:0] rd_sel,
        output reg [`CMP_CTL_LEN-1:0]cmp_ctl,
        output reg [`PC_GEN_CTL_LEN-1:0]pc_gen_ctl,
        output reg [`FSM_CTL_LEN-1:0]fsm_dly,
        output reg [`MUXA_CTL_LEN-1:0]muxa_ctl,
        output reg [`MUXB_CTL_LEN-1:0]muxb_ctl,
        output reg [`ALU_FUNC_LEN-1:0]alu_func,
        output reg [`DMEM_CTL_LEN-1:0]dmem_ctl,
        output reg [`ALU_WE_LEN-1:0] alu_we,
        output reg [`WB_MUX_CTL_LEN-1:0]wb_mux,
        output reg [`WB_WE_LEN-1:0]wb_we
    );

    wire [5:0]  inst_op,inst_func;
    wire [4:0]  inst_regimm;//,inst_rs,inst_rt,inst_rd,inst_sa;
    wire [4:0]  inst_cop0_func;//cop0's function code filed
    wire [25:0] inst_cop0_code;//cop0's code field

    assign inst_op        = ins_i[31:26];
    assign inst_func      = ins_i[5:0];
    assign inst_regimm    = ins_i[20:16];
    assign inst_cop0_func = ins_i[25:21];
    assign inst_cop0_code = ins_i[25:0];

    always @(*)
    begin
        case (inst_op)//synthesis parallel_case
            'd0://special operation
            begin
                case (inst_func) //synthesis parallel_case
                    'd0://SLL rd,rt,sa
                    begin
                        //replaceID  = `SLL ;
                        ext_ctl = `EXT_SA;
                        rd_sel = `RD_RD;
                        cmp_ctl = `CMP_NOP;
                        pc_gen_ctl = `PC_NEXT;
                        fsm_dly = `FSM_NOP;
                        muxa_ctl = `MUXA_EXT;
                        muxb_ctl = `MUXB_RT;
                        alu_func = `ALU_SLL;
                        alu_we = `EN;
                        dmem_ctl = `DMEM_NOP;
                        wb_we =  `DIS;
                        wb_mux = `WB_ALU;
                        //end of `SLL ;
                    end
                    'd2://SRL rd,rt,sa
                    begin
                        //replaceID  = `SRL ;
                        ext_ctl = `EXT_SA;
                        rd_sel = `RD_RD;
                        cmp_ctl = `CMP_NOP;
                        pc_gen_ctl = `PC_NEXT;
                        fsm_dly = `FSM_NOP;
                        muxa_ctl = `MUXA_EXT;
                        muxb_ctl = `MUXB_RT;
                        alu_func = `ALU_SRL;
                        alu_we = `EN;
                        dmem_ctl = `DMEM_NOP;
                        wb_we =  `DIS;
                        wb_mux = `WB_ALU;
                        //end of `SRL ;
                    end
                    'd3://SRA rd,rt,sa
                    begin
                        //replaceID  = `SRA ;
                        ext_ctl = `EXT_SA;
                        rd_sel = `RD_RD;
                        cmp_ctl = `CMP_NOP;
                        pc_gen_ctl = `PC_NEXT;
                        fsm_dly = `FSM_NOP;
                        muxa_ctl = `MUXA_EXT;
                        muxb_ctl = `MUXB_RT;
                        alu_func = `ALU_SRA;
                        alu_we = `EN;
                        dmem_ctl = `DMEM_NOP;
                        wb_we =  `DIS;
                        wb_mux = `WB_ALU;
                        //end of `SRA ;
                    end
                    'd4://SLLV rd,rt,rs
                    begin
                        //replaceID  = `SLLV ;
                        ext_ctl = `IGN;
                        rd_sel = `IGN;
                        cmp_ctl = `IGN;
                        pc_gen_ctl = `IGN;
                        fsm_dly = `IGN;
                        muxa_ctl = `IGN;
                        muxb_ctl = `IGN;
                        alu_func = `IGN;
                        alu_we = `IGN;
                        dmem_ctl = `IGN;
                        wb_we =  `IGN;
                        wb_mux = 1'bx;//`IGN;
                        //end of `SLLV ;
                    end
                    'd6://SRLV rd,rt,rs
                    begin
                        //replaceID  = `SRLV ;
                        ext_ctl = `IGN;
                        rd_sel = `IGN;
                        cmp_ctl = `IGN;
                        pc_gen_ctl = `IGN;
                        fsm_dly = `IGN;
                        muxa_ctl = `IGN;
                        muxb_ctl = `IGN;
                        alu_func = `IGN;
                        alu_we = `IGN;
                        dmem_ctl = `IGN;
                        wb_we =  `IGN;
                        wb_mux = `IGN;
                        //end of `SRLV ;
                    end
                    'd7://SRAV rd,rt,rs
                    begin
                        //replaceID  = `SRAV ;
                        ext_ctl = `IGN;
                        rd_sel = `IGN;
                        cmp_ctl = `IGN;
                        pc_gen_ctl = `IGN;
                        fsm_dly = `IGN;
                        muxa_ctl = `IGN;
                        muxb_ctl = `IGN;
                        alu_func = `IGN;
                        alu_we = `IGN;
                        dmem_ctl = `IGN;
                        wb_we =  `IGN;
                        wb_mux = `IGN;
                        //end of `SRAV ;
                    end
                    'd8://JR rs
                    begin
                        //replaceID  = `JR ;
                        ext_ctl = `EXT_NOP;
                        rd_sel = `RD_NOP;
                        cmp_ctl = `CMP_NOP;
                        pc_gen_ctl = `PC_JR;
                        fsm_dly = `FSM_CUR;
                        muxa_ctl = `MUXA_NOP;
                        muxb_ctl = `MUXB_NOP;
                        alu_func = `ALU_NOP;
                        alu_we = `DIS;
                        dmem_ctl = `DMEM_NOP;
                        wb_we =  `DIS;
                        wb_mux = `WB_NOP;
                        //end of `JR ;
                    end
                    'd9://JALR jalr rs(rd=31) or jalr rd,rs
                    begin
                        //replaceID  = `JALR ;
                        ext_ctl = `IGN;
                        rd_sel = `IGN;
                        cmp_ctl = `IGN;
                        pc_gen_ctl = `IGN;
                        fsm_dly = `IGN;
                        muxa_ctl = `IGN;
                        muxb_ctl = `IGN;
                        alu_func = `IGN;
                        alu_we = `IGN;
                        dmem_ctl = `IGN;
                        wb_we =  `IGN;
                        wb_mux = `IGN;
                        //end of `JALR ;
                    end
                    'd12://SYSCALL
                    begin
                        //replaceID  = `SYSCALL ;
                        ext_ctl = `IGN;
                        rd_sel = `IGN;
                        cmp_ctl = `IGN;
                        pc_gen_ctl = `IGN;
                        fsm_dly = `IGN;
                        muxa_ctl = `IGN;
                        muxb_ctl = `IGN;
                        alu_func = `IGN;
                        alu_we = `IGN;
                        dmem_ctl = `IGN;
                        wb_we =  `IGN;
                        wb_mux = `IGN;
                        //end of `SYSCALL ;
                    end
                    'd13://BREAK
                    begin
                        //replaceID  = `BREAK ;
                        ext_ctl = `IGN;
                        rd_sel = `IGN;
                        cmp_ctl = `IGN;
                        pc_gen_ctl = `IGN;
                        fsm_dly = `IGN;
                        muxa_ctl = `IGN;
                        muxb_ctl = `IGN;
                        alu_func = `IGN;
                        alu_we = `IGN;
                        dmem_ctl = `IGN;
                        wb_we =  `IGN;
                        wb_mux = `IGN;
                        //end of `BREAK ;
                    end
                    'd16://MFHI rd
                    begin
                        //replaceID  = `MFHI ;
                        ext_ctl = `EXT_NOP;
                        rd_sel = `RD_RD;
                        cmp_ctl = `CMP_NOP;
                        pc_gen_ctl = `PC_NEXT;
                        fsm_dly = `FSM_NOP;
                        muxa_ctl = `MUXA_NOP;
                        muxb_ctl = `MUXB_NOP;
                        alu_func = `ALU_MFHI;
                        alu_we = `EN;
                        dmem_ctl = `DMEM_NOP;
                        wb_we =  `DIS;
                        wb_mux = `WB_ALU;
                        //end of `MFHI ;
                    end
                    'd17://MTHI rs
                    begin
                        //replaceID  = `MTHI ;
                        ext_ctl = `EXT_NOP	;
                        rd_sel = `RD_NOP;
                        cmp_ctl = `CMP_NOP;
                        pc_gen_ctl = `PC_NEXT;
                        fsm_dly = `FSM_NOP;
                        muxa_ctl = `MUXA_RS;
                        muxb_ctl = `MUXB_NOP;
                        alu_func = `ALU_MTHI;
                        alu_we = `DIS;
                        dmem_ctl = `DMEM_NOP;
                        wb_we =  `DIS;
                        wb_mux = `WB_NOP;
                        //end of `MTHI ;
                    end
                    'd18://MFLO rd
                    begin
                        //replaceID  = `MFLO ;
                        ext_ctl = `EXT_NOP	;
                        rd_sel = `RD_RD;
                        cmp_ctl = `CMP_NOP;
                        pc_gen_ctl = `PC_NEXT;
                        fsm_dly = `FSM_NOP;
                        muxa_ctl = `MUXA_NOP;
                        muxb_ctl = `MUXB_NOP;
                        alu_func = `ALU_MFLO;
                        alu_we = `EN;
                        dmem_ctl = `DMEM_NOP;
                        wb_we =  `DIS;
                        wb_mux = `WB_ALU;
                        //end of `MFLO ;
                    end
                    'd19://MTLO rs
                    begin
                        //replaceID  = `MTLO ;
                        ext_ctl = `EXT_NOP	;
                        rd_sel = `RD_NOP;
                        cmp_ctl = `CMP_NOP;
                        pc_gen_ctl = `PC_NEXT;
                        fsm_dly = `FSM_NOP;
                        muxa_ctl = `MUXA_NOP;
                        muxb_ctl = `MUXB_NOP;
                        alu_func = `ALU_MFLO;
                        alu_we = `DIS;
                        dmem_ctl = `DMEM_NOP;
                        wb_we =  `DIS;
                        wb_mux = `WB_NOP;

                        //end of `MTLO ;
                    end
                    'd24://MULT rs,rt
                    begin
                        //replaceID  = `MULT ;
                        ext_ctl = `EXT_NOP;
                        rd_sel = `RD_NOP;
                        cmp_ctl = `CMP_NOP;
                        pc_gen_ctl = `PC_NEXT;
                        fsm_dly = `FSM_MUL;
                        muxa_ctl = `MUXA_RS;
                        muxb_ctl = `MUXB_RT;
                        alu_func = `ALU_MULT;
                        alu_we = `DIS;
                        dmem_ctl = `DMEM_NOP;
                        wb_we =  `DIS;
                        wb_mux = `WB_NOP;
                        //end of `MULT ;
                    end
                    'd25://MULTU rs,rt
                    begin
                        //replaceID  = `MULTU ;
                        ext_ctl = `EXT_NOP;
                        rd_sel = `RD_NOP;
                        cmp_ctl = `CMP_NOP;
                        pc_gen_ctl = `PC_NEXT;
                        fsm_dly = `FSM_MUL;
                        muxa_ctl = `MUXA_RS;
                        muxb_ctl = `MUXB_RT;
                        alu_func = `ALU_MULTU;
                        alu_we = `DIS;
                        dmem_ctl = `DMEM_NOP;
                        wb_we =  `DIS;
                        wb_mux = `WB_NOP;
                        //end of `MULTU ;
                    end
                    'd26://DIV rs,rt
                    begin
                        //replaceID  = `DIV ;
                        ext_ctl = `EXT_NOP;
                        rd_sel = `RD_NOP;
                        cmp_ctl = `CMP_NOP;
                        pc_gen_ctl = `PC_NEXT;
                        fsm_dly = `FSM_MUL;
                        muxa_ctl = `MUXA_RS;
                        muxb_ctl = `MUXB_RT;
                        alu_func = `ALU_DIV;
                        alu_we = `DIS;
                        dmem_ctl = `DMEM_NOP;
                        wb_we =  `DIS;
                        wb_mux = `WB_NOP;
                        //end of `DIV ;
                    end
                    'd27://DIVU rs,rt
                    begin
                        //replaceID  = `DIVU ;
                        ext_ctl = `EXT_NOP;
                        rd_sel = `RD_NOP;
                        cmp_ctl = `CMP_NOP;
                        pc_gen_ctl = `PC_NEXT;
                        fsm_dly = `FSM_MUL;
                        muxa_ctl = `MUXA_RS;
                        muxb_ctl = `MUXB_RT;
                        alu_func = `ALU_DIVU;
                        alu_we = `DIS;
                        dmem_ctl = `DMEM_NOP;
                        wb_we =  `DIS;
                        wb_mux = `WB_NOP;
                        //end of `DIVU ;
                    end
                    'd32://ADD rd,rs,rt
                    begin
                        //replaceID  = `ADD ;
                        ext_ctl = `EXT_NOP;
                        rd_sel = `RD_RD;
                        cmp_ctl = `CMP_NOP;
                        pc_gen_ctl = `PC_NEXT;
                        fsm_dly = `FSM_NOP;
                        muxa_ctl = `MUXA_RS;
                        muxb_ctl = `MUXB_RT;
                        alu_func = `ALU_ADD;
                        alu_we = `EN;
                        dmem_ctl = `DMEM_NOP;
                        wb_we =  `DIS;
                        wb_mux = `WB_ALU;
                        //end of `ADD ;
                    end
                    'd33://ADDU rd,rs,rt
                    begin
                        //replaceID  = `ADDU ;
                        ext_ctl = `EXT_NOP;
                        rd_sel = `RD_RD;
                        cmp_ctl = `CMP_NOP;
                        pc_gen_ctl = `PC_NEXT;
                        fsm_dly = `FSM_NOP;
                        muxa_ctl = `MUXA_RS;
                        muxb_ctl = `MUXB_RT;
                        alu_func = `ALU_ADD;
                        alu_we = `EN;
                        dmem_ctl = `DMEM_NOP;
                        wb_we =  `DIS;
                        wb_mux = `WB_ALU;
                        //end of `ADDU ;
                    end
                    'd34://SUB rd,rs,rt
                    begin
                        //replaceID  = `SUB ;
                        ext_ctl = `EXT_NOP;
                        rd_sel = `RD_RD;
                        cmp_ctl = `CMP_NOP;
                        pc_gen_ctl = `PC_NEXT;
                        fsm_dly = `FSM_NOP;
                        muxa_ctl = `MUXA_RS;
                        muxb_ctl = `MUXB_RT;
                        alu_func = `ALU_SUB;
                        alu_we = `EN;
                        dmem_ctl = `DMEM_NOP;
                        wb_we =  `DIS;
                        wb_mux = `WB_ALU;
                        //end of `SUB ;
                    end
                    'd35://SUBU rd,rs,rt
                    begin
                        //replaceID  = `SUBU ;
                        ext_ctl = `EXT_NOP;
                        rd_sel = `RD_RD;
                        cmp_ctl = `CMP_NOP;
                        pc_gen_ctl = `PC_NEXT;
                        fsm_dly = `FSM_NOP;
                        muxa_ctl = `MUXA_RS;
                        muxb_ctl = `MUXB_RT;
                        alu_func = `ALU_SUBU;
                        alu_we = `EN;
                        dmem_ctl = `DMEM_NOP;
                        wb_we =  `DIS;
                        wb_mux = `WB_ALU;
                        //end of `SUBU ;
                    end
                    'd36://AND rd,rs,rt
                    begin
                        //replaceID  = `AND ;
                        ext_ctl = `EXT_NOP;
                        rd_sel = `RD_RD;
                        cmp_ctl = `CMP_NOP;
                        pc_gen_ctl = `PC_NEXT;
                        fsm_dly = `FSM_NOP;
                        muxa_ctl = `MUXA_RS;
                        muxb_ctl = `MUXB_RT;
                        alu_func = `ALU_AND;
                        alu_we = `EN;
                        dmem_ctl = `DMEM_NOP;
                        wb_we =  `DIS;
                        wb_mux = `WB_ALU;
                        //end of `AND ;
                    end
                    'd37://OR rd,rs,rt
                    begin
                        //replaceID  = `OR ;
                        ext_ctl = `EXT_NOP;
                        rd_sel = `RD_RD;
                        cmp_ctl = `CMP_NOP;
                        pc_gen_ctl = `PC_NEXT;
                        fsm_dly = `FSM_NOP;
                        muxa_ctl = `MUXA_RS;
                        muxb_ctl = `MUXB_RT;
                        alu_func = `ALU_OR;
                        alu_we = `EN;
                        dmem_ctl = `DMEM_NOP;
                        wb_we =  `DIS;
                        wb_mux = `WB_ALU;
                        //end of `OR ;
                    end
                    'd38://XOR rd,rs,rt
                    begin
                        //replaceID  = `XOR ;
                        ext_ctl = `EXT_NOP;
                        rd_sel = `RD_RD;
                        cmp_ctl = `CMP_NOP;
                        pc_gen_ctl = `PC_NEXT;
                        fsm_dly = `FSM_NOP;
                        muxa_ctl = `MUXA_RS;
                        muxb_ctl = `MUXB_RT;
                        alu_func = `ALU_XOR;
                        alu_we = `EN;
                        dmem_ctl = `DMEM_NOP;
                        wb_we =  `DIS;
                        wb_mux = `WB_ALU;
                        //end of `XOR ;
                    end
                    'd39://NOR rd,rs,rt
                    begin
                        //replaceID  = `NOR ;
                        ext_ctl = `EXT_NOP;
                        rd_sel = `RD_RD;
                        cmp_ctl = `CMP_NOP;
                        pc_gen_ctl = `PC_NEXT;
                        fsm_dly = `FSM_NOP;
                        muxa_ctl = `MUXA_RS;
                        muxb_ctl = `MUXB_RT;
                        alu_func = `ALU_NOR;
                        alu_we = `EN;
                        dmem_ctl = `DMEM_NOP;
                        wb_we =  `DIS;
                        wb_mux = `WB_ALU;
                        //end of `NOR ;
                    end
                    'd42://SLT rd,rs,rt
                    begin
                        //replaceID  = `SLT ;
                        ext_ctl = `EXT_SIGN;
                        rd_sel = `RD_RD;
                        cmp_ctl = `CMP_NOP;
                        pc_gen_ctl = `PC_NEXT;
                        fsm_dly = `FSM_NOP;
                        muxa_ctl = `MUXA_RS;
                        muxb_ctl = `MUXB_RT;
                        alu_func = `ALU_SLT;
                        alu_we = `EN;
                        dmem_ctl = `DMEM_NOP;
                        wb_we =  `DIS;
                        wb_mux = `WB_ALU;
                        //end of `SLT ;
                    end
                    'd43://SLTU rd,rs,rt
                    begin
                        //replaceID  = `SLTU ;
                        ext_ctl = `EXT_NOP;
                        rd_sel = `RD_RD;
                        cmp_ctl = `CMP_NOP;
                        pc_gen_ctl = `PC_NEXT;
                        fsm_dly = `FSM_NOP;
                        muxa_ctl = `MUXA_RS;
                        muxb_ctl = `MUXB_RT;
                        alu_func = `ALU_SLTU;
                        alu_we = `EN;
                        dmem_ctl = `DMEM_NOP;
                        wb_we =  `DIS;
                        wb_mux = `WB_ALU;
                        //end of `SLTU ;
                    end
                    default:
                    begin
                        //replaceID  = `INVALID ;
                        ext_ctl = `IGN;
                        rd_sel = `IGN;
                        cmp_ctl = `IGN;
                        pc_gen_ctl = `IGN;
                        fsm_dly = `IGN;
                        muxa_ctl = `IGN;
                        muxb_ctl = `IGN;
                        alu_func = `IGN;
                        alu_we = `IGN;
                        dmem_ctl = `IGN;
                        wb_we =  `IGN;
                        wb_mux = `IGN;
                        //end of `INVALID ;
                    end
                endcase
            end
            'd1://regimm opreation
            begin
                case (inst_regimm) //synthesis parallel_case
                    'd0://BLTZ rs,offset(signed)
                    begin
                        //replaceID  = `BLTZ ;
                        ext_ctl = `EXT_B;
                        rd_sel = `RD_NOP;
                        cmp_ctl = `CMP_BLTZ;
                        pc_gen_ctl = `PC_BC;
                        fsm_dly = `FSM_CUR;
                        muxa_ctl = `MUXA_NOP;
                        muxb_ctl = `MUXB_NOP;
                        alu_func = `ALU_NOP;
                        alu_we = `DIS;
                        dmem_ctl = `DMEM_NOP;
                        wb_we =  `DIS;
                        wb_mux = `WB_NOP;
                        //end of `BLTZ ;
                    end
                    'd1://BGEZ rs,offset(signed)
                    begin
                        //replaceID  = `BGEZ ;
                        ext_ctl = `EXT_B;
                        rd_sel = `RD_NOP;
                        cmp_ctl = `CMP_BGEZ;
                        pc_gen_ctl = `PC_BC;
                        fsm_dly = `FSM_CUR;
                        muxa_ctl = `MUXA_NOP;
                        muxb_ctl = `MUXB_NOP;
                        alu_func = `ALU_NOP;
                        alu_we = `DIS;
                        dmem_ctl = `DMEM_NOP;
                        wb_we =  `DIS;
                        wb_mux = `WB_NOP;
                        //end of `BGEZ ;
                    end
                    'd16://BLTZAL rs,offset(signed)
                    begin
                        //replaceID  = `BLTZAL ;
                        ext_ctl = `IGN;
                        rd_sel = `IGN;
                        cmp_ctl = `IGN;
                        pc_gen_ctl = `IGN;
                        fsm_dly = `IGN;
                        muxa_ctl = `IGN;
                        muxb_ctl = `IGN;
                        alu_func = `IGN;
                        alu_we = `IGN;
                        dmem_ctl = `IGN;
                        wb_we =  `IGN;
                        wb_mux = `IGN;
                        //end of `BLTZAL ;
                    end
                    'd17://BGEZAL rs,offset(signed)
                    begin
                        //replaceID  = `BGEZAL ;
                        //replaceID  = `INVALID ;
                        ext_ctl = `IGN;
                        rd_sel = `IGN;
                        cmp_ctl = `IGN;
                        pc_gen_ctl = `IGN;
                        fsm_dly = `IGN;
                        muxa_ctl = `IGN;
                        muxb_ctl = `IGN;
                        alu_func = `IGN;
                        alu_we = `IGN;
                        dmem_ctl = `IGN;
                        wb_we =  `IGN;
                        wb_mux = `IGN;
                        //end of `INVALID ;
                    end
                    default:
                    begin
                        //replaceID   = `INVALID ;
                        //replaceID  = `INVALID ;
                        ext_ctl = `IGN;
                        rd_sel = `IGN;
                        cmp_ctl = `IGN;
                        pc_gen_ctl = `IGN;
                        fsm_dly = `IGN;
                        muxa_ctl = `IGN;
                        muxb_ctl = `IGN;
                        alu_func = `IGN;
                        alu_we = `IGN;
                        dmem_ctl = `IGN;
                        wb_we =  `IGN;
                        wb_mux = `IGN;
                        //end of `INVALID ;
                    end
                endcase
            end
            'd2://J imm26({pc[31:28],imm26,00})
            begin
                //replaceID  = `J ;
                ext_ctl = `EXT_J;
                rd_sel = `RD_NOP;
                cmp_ctl = `CMP_NOP;
                pc_gen_ctl = `PC_J;
                fsm_dly = `FSM_NOI;
                muxa_ctl = `MUXA_NOP;
                muxb_ctl = `MUXB_NOP;
                alu_func = `ALU_NOP;
                alu_we = `DIS;
                dmem_ctl = `DMEM_NOP;
                wb_we =  `DIS;
                wb_mux = `WB_NOP;
                //end of `J ;
            end
            'd3://JAL imm26({pc[31:28],imm26,00})
            begin
                //replaceID  = `JAL ;

                ext_ctl = `EXT_J;
                rd_sel = `RD_R31;
                cmp_ctl = `CMP_NOP;
                pc_gen_ctl = `PC_J;
                fsm_dly = `FSM_NOI;
                muxa_ctl = `MUXA_PC;
                muxb_ctl = `MUXB_RT;
                alu_func = `ALU_PA;
                alu_we = `EN;
                dmem_ctl = `DMEM_NOP;
                wb_we =  `DIS;
                wb_mux = `WB_ALU;
                //end of `JAL ;
            end
            'd4://BEQ rs,rt,offset(signed)
            begin
                //replaceID  = `BEQ ;
                ext_ctl = `EXT_B;
                rd_sel = `RD_NOP;
                cmp_ctl = `CMP_BEQ;
                pc_gen_ctl = `PC_BC;
                fsm_dly = `FSM_CUR;
                muxa_ctl = `MUXA_NOP;
                muxb_ctl = `MUXB_NOP;
                alu_func = `ALU_NOP;
                alu_we = `DIS;
                dmem_ctl = `DMEM_NOP;
                wb_we =  `DIS;
                wb_mux = `WB_NOP;
                //end of `BEQ ;
            end
            'd5://BNE rs,rt,offset(signed)
            begin
                //replaceID  = `BNE ;
                ext_ctl = `EXT_B;
                rd_sel = `RD_NOP;
                cmp_ctl = `CMP_BNE;
                pc_gen_ctl = `PC_BC;
                fsm_dly = `FSM_CUR;
                muxa_ctl = `MUXA_NOP;
                muxb_ctl = `MUXB_NOP;
                alu_func = `ALU_NOP;
                alu_we = `DIS;
                dmem_ctl = `DMEM_NOP;
                wb_we =  `DIS;
                wb_mux = `WB_NOP;
                //end of `BNE ;
            end
            'd6://BLEZ rs,offset(signed)
            begin
                //replaceID  = `BLEZ ;
                ext_ctl = `EXT_B;
                rd_sel = `RD_NOP;
                cmp_ctl = `CMP_BLEZ;
                pc_gen_ctl = `PC_BC;
                fsm_dly = `FSM_CUR;
                muxa_ctl = `MUXA_NOP;
                muxb_ctl = `MUXB_NOP;
                alu_func = `ALU_NOP;
                alu_we = `DIS;
                dmem_ctl = `DMEM_NOP;
                wb_we =  `DIS;
                wb_mux = `WB_NOP;
                //end of `BLEZ ;
            end
            'd7://BGTZ rs,offset(signed)
            begin
                //replaceID  = `BGTZ ;
                ext_ctl = `EXT_B;
                rd_sel = `RD_NOP;
                cmp_ctl = `CMP_BGTZ;
                pc_gen_ctl = `PC_BC;
                fsm_dly = `FSM_CUR;
                muxa_ctl = `MUXA_NOP;
                muxb_ctl = `MUXB_NOP;
                alu_func = `ALU_NOP;
                alu_we = `DIS;
                dmem_ctl = `DMEM_NOP;
                wb_we =  `DIS;
                wb_mux = `WB_NOP;
                //end of `BGTZ ;
            end
            'd8://ADDI rt,rs,imm16(singed)
            begin
                //replaceID  = `ADDI ;
                ext_ctl = `EXT_SIGN;
                rd_sel = `RD_RT;
                cmp_ctl = `CMP_NOP;
                pc_gen_ctl = `PC_NEXT;
                fsm_dly = `FSM_NOP;
                muxa_ctl = `MUXA_RS;
                muxb_ctl = `MUXB_EXT;
                alu_func = `ALU_ADD;
                alu_we = `EN;
                dmem_ctl = `DMEM_NOP;
                wb_we =  `DIS;
                wb_mux = `WB_ALU;
                //end of `ADDI ;
            end
            'd9://ADDIU rt,rs,imm16(singed)
            begin
                //replaceID  = `ADDIU ;
                ext_ctl = `EXT_SIGN;
                rd_sel = `RD_RT;
                cmp_ctl = `CMP_NOP;
                pc_gen_ctl = `PC_NEXT;
                fsm_dly = `FSM_NOP;
                muxa_ctl = `MUXA_RS;
                muxb_ctl = `MUXB_EXT;
                alu_func = `ALU_ADD;
                alu_we = `EN;
                dmem_ctl = `DMEM_NOP;
                wb_we =  `DIS;
                wb_mux = `WB_ALU;
                //end of `ADDIU ;
            end
            'd10://SLTI rt,rs,imm16(singed)
            begin
                //replaceID  = `SLTI ;
                ext_ctl = `EXT_SIGN;
                rd_sel = `RD_RT;
                cmp_ctl = `CMP_NOP;
                pc_gen_ctl = `PC_NEXT;
                fsm_dly = `FSM_NOP;
                muxa_ctl = `MUXA_RS;
                muxb_ctl = `MUXB_EXT;
                alu_func = `ALU_SLT;
                alu_we = `EN;
                dmem_ctl = `DMEM_NOP;
                wb_we =  `DIS;
                wb_mux = `WB_ALU;
                //end of `SLTI ;
            end
            'd11://SLTIU rt,rs,imm16(singed)
            begin
                //replaceID  = `SLTIU ;
                ext_ctl = `EXT_UNSIGN;
                rd_sel = `RD_RT;
                cmp_ctl = `CMP_NOP;
                pc_gen_ctl = `PC_NEXT;
                fsm_dly = `FSM_NOP;
                muxa_ctl = `MUXA_RS;
                muxb_ctl = `MUXB_EXT;
                alu_func = `ALU_SLTU;
                alu_we = `EN;
                dmem_ctl = `DMEM_NOP;
                wb_we =  `DIS;
                wb_mux = `WB_ALU;
                //end of `SLTIU ;
            end
            'd12://ANDI rt,rs,imm16(singed)
            begin
                //replaceID  = `ANDI ;
                ext_ctl = `EXT_UNSIGN;
                rd_sel = `RD_RT;
                cmp_ctl = `CMP_NOP;
                pc_gen_ctl = `PC_NEXT;
                fsm_dly = `FSM_NOP;
                muxa_ctl = `MUXA_RS;
                muxb_ctl = `MUXB_EXT;
                alu_func = `ALU_AND;
                alu_we = `EN;
                dmem_ctl = `DMEM_NOP;
                wb_we =  `DIS;
                wb_mux = `WB_ALU;
                //end of `ANDI ;
            end
            'd13://ORI rt,rs,imm16(singed)
            begin
                //replaceID  = `ORI ;
                ext_ctl = `EXT_UNSIGN;
                rd_sel = `RD_RT;
                cmp_ctl = `CMP_NOP;
                pc_gen_ctl = `PC_NEXT;
                fsm_dly = `FSM_NOP;
                muxa_ctl = `MUXA_RS;
                muxb_ctl = `MUXB_EXT;
                alu_func = `ALU_OR;
                alu_we = `EN;
                dmem_ctl = `DMEM_NOP;
                wb_we =  `DIS;
                wb_mux = `WB_NOP;
                //end of `ORI ;
            end
            'd14://XORI rt,rs,imm16(singed)
            begin
                //replaceID  = `XORI ;
                ext_ctl = `EXT_UNSIGN;
                rd_sel = `RD_RT;
                cmp_ctl = `CMP_NOP;
                pc_gen_ctl = `PC_NEXT;
                fsm_dly = `FSM_NOP;
                muxa_ctl = `MUXA_RS;
                muxb_ctl = `MUXB_EXT;
                alu_func = `ALU_XOR;
                alu_we = `EN;
                dmem_ctl = `DMEM_NOP;
                wb_we =  `EN;
                wb_mux = `WB_ALU;
                //end of `XORI ;
            end
            'd15://LUI rt,imm16
            begin
                //replaceID  = `LUI ;
                ext_ctl = `EXT_S2H;
                rd_sel = `RD_RT;
                cmp_ctl = `CMP_NOP;
                pc_gen_ctl = `PC_NEXT;
                fsm_dly = `FSM_NOP;
                muxa_ctl = `MUXA_RS;
                muxb_ctl = `MUXB_EXT;
                alu_func = `ALU_PB;
                alu_we = `EN;
                dmem_ctl = `DMEM_NOP;
                wb_we =  `DIS;
                wb_mux = `WB_ALU;
                //end of `LUI ;
            end
            'd16://COP0 func
            begin
                case(inst_cop0_func) //synthesis parallel_case
                    'd0://mfc0 rt,rd // GPR[rd] = CPR[rt] //differ to mips32 definition
                        //read saved PC
                    begin
                        //replaceID  = `MFC0;
                        ext_ctl = `EXT_NOP;
                        rd_sel = `RD_RD;
                        cmp_ctl = `CMP_NOP;
                        pc_gen_ctl = `PC_NEXT;
                        fsm_dly = `FSM_NOP;
                        muxa_ctl = `MUXA_SPC;
                        muxb_ctl = `MUXB_EXT;
                        alu_func = `ALU_PA;
                        alu_we = `EN;
                        dmem_ctl = `DMEM_LB;
                        wb_we =  `DIS;
                        wb_mux = `WB_ALU;
                    end

                    'd4://mtc0 rt,rd // CPR[rd] = GPR[rt] //follow the mips32 definition
                    begin	 //return from interrupt
                        $display("mtco");
                        //replaceID  = `MTC0;
                        ext_ctl = `EXT_NOP;
                        rd_sel = `RD_NOP;
                        cmp_ctl = `CMP_NOP;
                        pc_gen_ctl = `PC_SPC;
                        fsm_dly = `FSM_RET;
                        muxa_ctl = `MUXA_NOP;
                        muxb_ctl = `MUXB_NOP;
                        alu_func = `ALU_NOP;
                        alu_we = `DIS;
                        dmem_ctl = `DMEM_NOP;
                        wb_we =  `DIS;
                        wb_mux = `WB_NOP;
                    end
                    default:
                    begin
                        //replaceID  = `INVALID ;
                        ext_ctl = `IGN;
                        rd_sel = `IGN;
                        cmp_ctl = `IGN;
                        pc_gen_ctl = `IGN;
                        fsm_dly = `IGN;
                        muxa_ctl = `IGN;
                        muxb_ctl = `IGN;
                        alu_func = `IGN;
                        alu_we = `IGN;
                        dmem_ctl = `IGN;
                        wb_we =  `IGN;
                        wb_mux = `IGN;
                        //end of `INVALID ;
                    end
                endcase
            end
            'd32://LB rt,offset(base) (offset:signed;base:rs)
            begin
                //replaceID  = `LB ;
                ext_ctl = `EXT_SIGN;
                rd_sel = `RD_RT;
                cmp_ctl = `CMP_NOP;
                pc_gen_ctl = `PC_NEXT;
                fsm_dly = `FSM_NOP;
                muxa_ctl = `MUXA_RS;
                muxb_ctl = `MUXB_EXT;
                alu_func = `ALU_ADD;
                alu_we = `DIS;
                dmem_ctl = `DMEM_LBS;
                wb_we =  `EN;
                wb_mux = `WB_MEM;
                //end of `LB ;
            end
            'd33://LH rt,offset(base) (offset:signed;base:rs)
            begin
                //replaceID  = `LH ;
                ext_ctl = `EXT_SIGN;
                rd_sel = `RD_RT;
                cmp_ctl = `CMP_NOP;
                pc_gen_ctl = `PC_NEXT;
                fsm_dly = `FSM_NOP;
                muxa_ctl = `MUXA_RS;
                muxb_ctl = `MUXB_EXT;
                alu_func = `ALU_ADD;
                alu_we = `DIS;
                dmem_ctl = `DMEM_LHS;
                wb_we =  `EN;
                wb_mux = `WB_MEM;
                //end of `LH ;
            end
            'd34://LWL rt,offset(base) (offset:signed;base:rs)
            begin
                //replaceID  = `LWL ;
                ext_ctl = `IGN;
                rd_sel = `IGN;
                cmp_ctl = `IGN;
                pc_gen_ctl = `IGN;
                fsm_dly = `IGN;
                muxa_ctl = `IGN;
                muxb_ctl = `IGN;
                alu_func = `IGN;
                alu_we = `IGN;
                dmem_ctl = `IGN;
                wb_we =  `IGN;
                wb_mux = `IGN;
                //end of `LWL ;
            end
            'd35://LW rt,offset(base) (offset:signed;base:rs)
            begin
                //replaceID  = `LW ;
                ext_ctl = `EXT_SIGN;
                rd_sel = `RD_RT;
                cmp_ctl = `CMP_NOP;
                pc_gen_ctl = `PC_NEXT;
                fsm_dly = `FSM_NOP;
                muxa_ctl = `MUXA_RS;
                muxb_ctl = `MUXB_EXT;
                alu_func = `ALU_ADD;
                alu_we = `DIS;
                dmem_ctl = `DMEM_LW;
                wb_we =  `EN;
                wb_mux = `WB_MEM;
                //end of `LW ;
            end
            'd36://LBU rt,offset(base) (offset:signed;base:rs)
            begin
                //replaceID  = `LBU ;
                ext_ctl = `EXT_SIGN;
                rd_sel = `RD_RT;
                cmp_ctl = `CMP_NOP;
                pc_gen_ctl = `PC_NEXT;
                fsm_dly = `FSM_NOP;
                muxa_ctl = `MUXA_RS;
                muxb_ctl = `MUXB_EXT;
                alu_func = `ALU_ADD;
                alu_we = `DIS;
                dmem_ctl = `DMEM_LBU;
                wb_we =  `EN;
                wb_mux = `WB_MEM;
                //end of `LBU ;
            end
            'd37://LHU rt,offset(base) (offset:signed;base:rs)
            begin
                //replaceID  = `LHU ;
                ext_ctl = `EXT_SIGN;
                rd_sel = `RD_RT;
                cmp_ctl = `CMP_NOP;
                pc_gen_ctl = `PC_NEXT;
                fsm_dly = `FSM_NOP;
                muxa_ctl = `MUXA_RS;
                muxb_ctl = `MUXB_EXT;
                alu_func = `ALU_ADD;
                alu_we = `DIS;
                dmem_ctl = `DMEM_LHU;
                wb_we =  `EN;
                wb_mux = `WB_MEM;
                //end of `LHU ;
            end
            'd38://LWR rt,offset(base) (offset:signed;base:rs)
            begin
                //replaceID  = `LWR ;
                ext_ctl = `IGN;
                rd_sel = `IGN;
                cmp_ctl = `IGN;
                pc_gen_ctl = `IGN;
                fsm_dly = `IGN;
                muxa_ctl = `IGN;
                muxb_ctl = `IGN;
                alu_func = `IGN;
                alu_we = `IGN;
                dmem_ctl = `IGN;
                wb_we =  `IGN;
                wb_mux = `IGN;
                //end of `LWR ;
            end
            'd40://SB rt,offset(base) (offset:signed;base:rs)
            begin
                //replaceID  = `SB ;
                ext_ctl = `EXT_SIGN;
                rd_sel = `RD_NOP;
                cmp_ctl = `CMP_NOP;
                pc_gen_ctl = `PC_NEXT;
                fsm_dly = `FSM_NOP;
                muxa_ctl = `MUXA_RS;
                muxb_ctl = `MUXB_EXT;
                alu_func = `ALU_ADD;
                alu_we = `DIS;
                dmem_ctl = `DMEM_SB;
                wb_we =  `DIS;
                wb_mux = `WB_NOP;
                //end of `SB ;
            end
            'd41://SH rt,offset(base) (offset:signed;base:rs)
            begin
                //replaceID  = `SH ;
                ext_ctl = `EXT_SIGN;
                rd_sel = `RD_RT;
                cmp_ctl = `CMP_NOP;
                pc_gen_ctl = `PC_NEXT;
                fsm_dly = `FSM_NOP;
                muxa_ctl = `MUXA_RS;
                muxb_ctl = `MUXB_EXT;
                alu_func = `ALU_ADD;
                alu_we = `DIS;
                dmem_ctl = `DMEM_SH;
                wb_we =  `DIS;
                wb_mux = `WB_NOP;
                //end of `SH ;
            end
            'd42://SWL rt,offset(base) (offset:signed;base:rs)
            begin
                //replaceID  = `SWL ;
                ext_ctl = `IGN;
                rd_sel = `IGN;
                cmp_ctl = `IGN;
                pc_gen_ctl = `IGN;
                fsm_dly = `IGN;
                muxa_ctl = `IGN;
                muxb_ctl = `IGN;
                alu_func = `IGN;
                alu_we = `IGN;
                dmem_ctl = `IGN;
                wb_we =  `IGN;
                wb_mux = `IGN;
                //end of `SWL ;
            end
            'd43://SW rt,offset(base) (offset:signed;base:rs)
            begin
                //replaceID  = `SW ;
                ext_ctl = `EXT_SIGN;
                rd_sel = `RD_NOP;
                cmp_ctl = `CMP_NOP;
                pc_gen_ctl = `PC_NEXT;
                fsm_dly = `FSM_NOP;
                muxa_ctl = `MUXA_RS;
                muxb_ctl = `MUXB_EXT;
                alu_func = `ALU_ADD;
                alu_we = `DIS;
                dmem_ctl = `DMEM_SW;
                wb_we =  `DIS;
                wb_mux = `WB_NOP;
                //end of `SW ;
            end
            'd46://SWR rt,offset(base) (offset:signed;base:rs)
            begin
                //replaceID  = `SWR ;
                ext_ctl = `IGN;
                rd_sel = `IGN;
                cmp_ctl = `IGN;
                pc_gen_ctl = `IGN;
                fsm_dly = `IGN;
                muxa_ctl = `IGN;
                muxb_ctl = `IGN;
                alu_func = `IGN;
                alu_we = `IGN;
                dmem_ctl = `IGN;
                wb_we =  `IGN;
                wb_mux = `IGN;
                //end of `SWR ;
            end
            default:
            begin
                //replaceID  = `INVALID ;
                ext_ctl = `IGN;
                rd_sel = `IGN;
                cmp_ctl = `IGN;
                pc_gen_ctl = `IGN;
                fsm_dly = `IGN;
                muxa_ctl = `IGN;
                muxb_ctl = `IGN;
                alu_func = `IGN;
                alu_we = `IGN;
                dmem_ctl = `IGN;
                wb_we =  `IGN;
                wb_mux = `IGN;
                //end of `INVALID ;  //replaceID   = `INVALID ;
            end
        endcase
    end
endmodule



module pipelinedregs (
        clk,id2ra_ctl_clr,id2ra_ctl_cls,ra2ex_ctl_clr,
        alu_func_i,alu_we_i,cmp_ctl_i,dmem_ctl_i,ext_ctl_i,
        muxa_ctl_i,muxb_ctl_i,pc_gen_ctl_i,rd_sel_i,wb_mux_ctl_i,
        wb_we_i,alu_func_o,alu_we_o,cmp_ctl_o,dmem_ctl_o,dmem_ctl_ur_o,
        ext_ctl,muxa_ctl_o,muxb_ctl_o,pc_gen_ctl_o,rd_sel_o,wb_mux_ctl_o,wb_we_o
    ) ;

    input clk;
    wire clk;
    input id2ra_ctl_clr;
    wire id2ra_ctl_clr;
    input id2ra_ctl_cls;
    wire id2ra_ctl_cls;
    input ra2ex_ctl_clr;
    wire ra2ex_ctl_clr;
    input [4:0] alu_func_i;
    wire [4:0] alu_func_i;
    input [0:0] alu_we_i;
    wire [0:0] alu_we_i;
    input [2:0] cmp_ctl_i;
    wire [2:0] cmp_ctl_i;
    input [3:0] dmem_ctl_i;
    wire [3:0] dmem_ctl_i;
    input [2:0] ext_ctl_i;
    wire [2:0] ext_ctl_i;
    input [1:0] muxa_ctl_i;
    wire [1:0] muxa_ctl_i;
    input [1:0] muxb_ctl_i;
    wire [1:0] muxb_ctl_i;
    input [2:0] pc_gen_ctl_i;
    wire [2:0] pc_gen_ctl_i;
    input [1:0] rd_sel_i;
    wire [1:0] rd_sel_i;
    input [0:0] wb_mux_ctl_i;
    wire [0:0] wb_mux_ctl_i;
    input [0:0] wb_we_i;
    wire [0:0] wb_we_i;
    output [4:0] alu_func_o;
    wire [4:0] alu_func_o;
    output [0:0] alu_we_o;
    wire [0:0] alu_we_o;
    output [2:0] cmp_ctl_o;
    wire [2:0] cmp_ctl_o;
    output [3:0] dmem_ctl_o;
    wire [3:0] dmem_ctl_o;
    output [3:0] dmem_ctl_ur_o;
    wire [3:0] dmem_ctl_ur_o;
    output [2:0] ext_ctl;
    wire [2:0] ext_ctl;
    output [1:0] muxa_ctl_o;
    wire [1:0] muxa_ctl_o;
    output [1:0] muxb_ctl_o;
    wire [1:0] muxb_ctl_o;
    output [2:0] pc_gen_ctl_o;
    wire [2:0] pc_gen_ctl_o;
    output [1:0] rd_sel_o;
    wire [1:0] rd_sel_o;
    output [0:0] wb_mux_ctl_o;
    wire [0:0] wb_mux_ctl_o;
    output [0:0] wb_we_o;
    wire [0:0] wb_we_o;


    wire NET7643;
    wire [0:0] BUS4987;
    wire [1:0] BUS5008;
    wire [1:0] BUS5483;
    wire [0:0] BUS5639;
    wire [0:0] BUS5651;
    wire [3:0] BUS5666;
    wire [4:0] BUS5674;
    wire [0:0] BUS5682;
    wire [0:0] BUS5690;
    wire [0:0] BUS5790;
    wire [0:0] BUS7299;
    wire [0:0] BUS7822;


    muxb_ctl_reg_clr_cls U1
                         (
                             .clk(clk),
                             .clr(id2ra_ctl_clr),
                             .cls(id2ra_ctl_cls),
                             .muxb_ctl_i(muxb_ctl_i),
                             .muxb_ctl_o(BUS5483)
                         );



    wb_mux_ctl_reg_clr_cls U10
                           (
                               .clk(clk),
                               .clr(id2ra_ctl_clr),
                               .cls(id2ra_ctl_cls),
                               .wb_mux_ctl_i(wb_mux_ctl_i),
                               .wb_mux_ctl_o(BUS5651)
                           );



    wb_we_reg_clr_cls U11
                      (
                          .clk(clk),
                          .clr(id2ra_ctl_clr),
                          .cls(id2ra_ctl_cls),
                          .wb_we_i(wb_we_i),
                          .wb_we_o(BUS5639)
                      );



    wb_we_reg U12
              (
                  .clk(clk),
                  .wb_we_i(NET7643),
                  .wb_we_o(wb_we_o)
              );



    wb_mux_ctl_reg_clr U13
                       (
                           .clk(clk),
                           .clr(ra2ex_ctl_clr),
                           .wb_mux_ctl_i(BUS5651),
                           .wb_mux_ctl_o(BUS5690)
                       );



    muxb_ctl_reg_clr U14
                     (
                         .clk(clk),
                         .clr(ra2ex_ctl_clr),
                         .muxb_ctl_i(BUS5483),
                         .muxb_ctl_o(muxb_ctl_o)
                     );



    dmem_ctl_reg_clr U15
                     (
                         .clk(clk),
                         .clr(ra2ex_ctl_clr),
                         .dmem_ctl_i(BUS5666),
                         .dmem_ctl_o(dmem_ctl_ur_o)
                     );



    alu_func_reg_clr U16
                     (
                         .alu_func_i(BUS5674),
                         .alu_func_o(alu_func_o),
                         .clk(clk),
                         .clr(ra2ex_ctl_clr)
                     );



    muxa_ctl_reg_clr U17
                     (
                         .clk(clk),
                         .clr(ra2ex_ctl_clr),
                         .muxa_ctl_i(BUS5008),
                         .muxa_ctl_o(muxa_ctl_o)
                     );



    wb_mux_ctl_reg U18
                   (
                       .clk(clk),
                       .wb_mux_ctl_i(BUS5790),
                       .wb_mux_ctl_o(wb_mux_ctl_o)
                   );



    wb_we_reg_clr U19
                  (
                      .clk(clk),
                      .clr(ra2ex_ctl_clr),
                      .wb_we_i(BUS5639),
                      .wb_we_o(BUS5682)
                  );



    cmp_ctl_reg_clr_cls U2
                        (
                            .clk(clk),
                            .clr(id2ra_ctl_clr),
                            .cls(id2ra_ctl_cls),
                            .cmp_ctl_i(cmp_ctl_i),
                            .cmp_ctl_o(cmp_ctl_o)
                        );



    wb_we_reg U20
              (
                  .clk(clk),
                  .wb_we_i(BUS5682),
                  .wb_we_o(BUS7822)
              );



    wb_mux_ctl_reg U21
                   (
                       .clk(clk),
                       .wb_mux_ctl_i(BUS5690),
                       .wb_mux_ctl_o(BUS5790)
                   );



    wb_we_reg U22
              (
                  .clk(clk),
                  .wb_we_i(BUS7299),
                  .wb_we_o(alu_we_o)
              );



    assign NET7643 = alu_we_o[0] | BUS7822[0];


    alu_we_reg_clr U24
                   (
                       .alu_we_i(BUS4987),
                       .alu_we_o(BUS7299),
                       .clk(clk),
                       .clr(ra2ex_ctl_clr)
                   );



    alu_func_reg_clr_cls U26
                         (
                             .alu_func_i(alu_func_i),
                             .alu_func_o(BUS5674),
                             .clk(clk),
                             .clr(id2ra_ctl_clr),
                             .cls(id2ra_ctl_cls)
                         );



    dmem_ctl_reg_clr_cls U3
                         (
                             .clk(clk),
                             .clr(id2ra_ctl_clr),
                             .cls(id2ra_ctl_cls),
                             .dmem_ctl_i(dmem_ctl_i),
                             .dmem_ctl_o(BUS5666)
                         );



    ext_ctl_reg_clr_cls U4
                        (
                            .clk(clk),
                            .clr(id2ra_ctl_clr),
                            .cls(id2ra_ctl_cls),
                            .ext_ctl_i(ext_ctl_i),
                            .ext_ctl_o(ext_ctl)
                        );



    rd_sel_reg_clr_cls U5
                       (
                           .clk(clk),
                           .clr(id2ra_ctl_clr),
                           .cls(id2ra_ctl_cls),
                           .rd_sel_i(rd_sel_i),
                           .rd_sel_o(rd_sel_o)
                       );



    alu_we_reg_clr_cls U6
                       (
                           .alu_we_i(alu_we_i),
                           .alu_we_o(BUS4987),
                           .clk(clk),
                           .clr(id2ra_ctl_clr),
                           .cls(id2ra_ctl_cls)
                       );



    muxa_ctl_reg_clr_cls U7
                         (
                             .clk(clk),
                             .clr(id2ra_ctl_clr),
                             .cls(id2ra_ctl_cls),
                             .muxa_ctl_i(muxa_ctl_i),
                             .muxa_ctl_o(BUS5008)
                         );



    pc_gen_ctl_reg_clr_cls U8
                           (
                               .clk(clk),
                               .clr(id2ra_ctl_clr),
                               .cls(id2ra_ctl_cls),
                               .pc_gen_ctl_i(pc_gen_ctl_i),
                               .pc_gen_ctl_o(pc_gen_ctl_o)
                           );



    dmem_ctl_reg U9
                 (
                     .clk(clk),
                     .dmem_ctl_i(dmem_ctl_ur_o),
                     .dmem_ctl_o(dmem_ctl_o)
                 );



endmodule

module decode_pipe
    (
        clk,id2ra_ctl_clr,id2ra_ctl_cls,
        ra2ex_ctl_clr,ins_i,alu_func_o,alu_we_o,
        cmp_ctl_o,dmem_ctl_o,dmem_ctl_ur_o,ext_ctl_o,
        fsm_dly,muxa_ctl_o,muxb_ctl_o,pc_gen_ctl_o,rd_sel_o,
        wb_mux_ctl_o,wb_we_o
    ) ;

    input clk;
    wire clk;
    input id2ra_ctl_clr;
    wire id2ra_ctl_clr;
    input id2ra_ctl_cls;
    wire id2ra_ctl_cls;
    input ra2ex_ctl_clr;
    wire ra2ex_ctl_clr;
    input [31:0] ins_i;
    wire [31:0] ins_i;
    output [4:0] alu_func_o;
    wire [4:0] alu_func_o;
    output [0:0] alu_we_o;
    wire [0:0] alu_we_o;
    output [2:0] cmp_ctl_o;
    wire [2:0] cmp_ctl_o;
    output [3:0] dmem_ctl_o;
    wire [3:0] dmem_ctl_o;
    output [3:0] dmem_ctl_ur_o;
    wire [3:0] dmem_ctl_ur_o;
    output [2:0] ext_ctl_o;
    wire [2:0] ext_ctl_o;
    output [2:0] fsm_dly;
    wire [2:0] fsm_dly;
    output [1:0] muxa_ctl_o;
    wire [1:0] muxa_ctl_o;
    output [1:0] muxb_ctl_o;
    wire [1:0] muxb_ctl_o;
    output [2:0] pc_gen_ctl_o;
    wire [2:0] pc_gen_ctl_o;
    output [1:0] rd_sel_o;
    wire [1:0] rd_sel_o;
    output [0:0] wb_mux_ctl_o;
    wire [0:0] wb_mux_ctl_o;
    output [0:0] wb_we_o;
    wire [0:0] wb_we_o;


    wire [4:0] BUS2040;
    wire [0:0] BUS2048;
    wire [2:0] BUS2056;
    wire [3:0] BUS2064;
    wire [2:0] BUS2072;
    wire [1:0] BUS2086;
    wire [1:0] BUS2094;
    wire [2:0] BUS2102;
    wire [1:0] BUS2110;
    wire [0:0] BUS2118;
    wire [0:0] BUS2126;


    decoder idecoder
            (
                .alu_func(BUS2040),
                .alu_we(BUS2048),
                .cmp_ctl(BUS2056),
                .dmem_ctl(BUS2064),
                .ext_ctl(BUS2072),
                .fsm_dly(fsm_dly),
                .ins_i(ins_i),
                .muxa_ctl(BUS2086),
                .muxb_ctl(BUS2094),
                .pc_gen_ctl(BUS2102),
                .rd_sel(BUS2110),
                .wb_mux(BUS2118),
                .wb_we(BUS2126)
            );



    pipelinedregs pipereg
                  (
                      .alu_func_i(BUS2040),
                      .alu_func_o(alu_func_o),
                      .alu_we_i(BUS2048),
                      .alu_we_o(alu_we_o),
                      .clk(clk),
                      .cmp_ctl_i(BUS2056),
                      .cmp_ctl_o(cmp_ctl_o),
                      .dmem_ctl_i(BUS2064),
                      .dmem_ctl_o(dmem_ctl_o),
                      .dmem_ctl_ur_o(dmem_ctl_ur_o),
                      .ext_ctl(ext_ctl_o),
                      .ext_ctl_i(BUS2072),
                      .id2ra_ctl_clr(id2ra_ctl_clr),
                      .id2ra_ctl_cls(id2ra_ctl_cls),
                      .muxa_ctl_i(BUS2086),
                      .muxa_ctl_o(muxa_ctl_o),
                      .muxb_ctl_i(BUS2094),
                      .muxb_ctl_o(muxb_ctl_o),
                      .pc_gen_ctl_i(BUS2102),
                      .pc_gen_ctl_o(pc_gen_ctl_o),
                      .ra2ex_ctl_clr(ra2ex_ctl_clr),
                      .rd_sel_i(BUS2110),
                      .rd_sel_o(rd_sel_o),
                      .wb_mux_ctl_i(BUS2118),
                      .wb_mux_ctl_o(wb_mux_ctl_o),
                      .wb_we_i(BUS2126),
                      .wb_we_o(wb_we_o)
                  );



endmodule





