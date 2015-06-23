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

module mips_core (
        clk,rst,cop_dout,
          din,  ins_i,iack_o,cop_addr_o,
        cop_data_o,cop_mem_ctl_o,  addr_o,
          dout,  pc_o,  wr_en_o
    );

    input clk;
    wire clk;
   /// input irq_i;
    wire irq_i = 0;
    input rst;
    wire rst;
    input [31:0] cop_dout;
    wire [31:0] cop_dout;
  ///  input [31:0] irq_addr;
    wire [31:0] irq_addr=0;
    input [31:0]   din;
    wire [31:0]   din;
    input [31:0]   ins_i;
    wire [31:0]   ins_i;
    output [31:0]   addr_o;
    wire [31:0]   addr_o;
    output [31:0]   dout;
    wire [31:0]   dout;
    output [31:0]   pc_o;
    wire [31:0]   pc_o;
    output [3:0]   wr_en_o;
    wire [3:0]   wr_en_o;
    output iack_o;
    wire iack_o;
    output [31:0] cop_addr_o;
    wire [31:0] cop_addr_o;
    output [31:0] cop_data_o;
    wire [31:0] cop_data_o;
    output [3:0] cop_mem_ctl_o;
    wire [3:0] cop_mem_ctl_o;


    wire NET1375;
    wire NET1572;
    wire NET1606;
    wire NET1640;
    wire NET21531;
    wire NET457;
    wire NET767;
    wire [2:0] BUS109;
    wire [2:0] BUS1158;
    wire [2:0] BUS117;
    wire [2:0] BUS1196;
    wire [31:0] BUS15471;
    wire [4:0] BUS1724;
    wire [4:0] BUS1726;
    wire [4:0] BUS18211;
    wire [2:0] BUS197;
    wire [2:0] BUS2140;
    wire [2:0] BUS2156;
    wire [31:0] BUS22401;
    wire [31:0] BUS24839;
    wire [31:0] BUS27031;
    wire [2:0] BUS271;
    wire [31:0] BUS28013;
    wire [1:0] BUS371;
    wire [31:0] BUS422;
    wire [1:0] BUS5832;
    wire [1:0] BUS5840;
    wire [3:0] BUS5985;
    wire [2:0] BUS5993;
    wire [4:0] BUS6275;
    wire [31:0] BUS7101;
    wire [31:0] BUS7117;
    wire [31:0] BUS7160;
    wire [31:0] BUS7219;
    wire [31:0] BUS7231;
    wire [4:0] BUS748;
    wire [4:0] BUS756;
    wire [4:0] BUS775;
    wire [31:0] BUS7772;
    wire [31:0] BUS7780;
    wire [31:0] BUS9589;
    wire [31:0] BUS9884;
/*

        clk,din,dmem_addr_i,dmem_ctl,
        zZ_din,Zz_addr,Zz_dout,Zz_wr_en,dout
*/

    mem_module MEM_CTL
               (
                   .Zz_addr(addr_o),
                   .Zz_dout(  dout),
                   .Zz_wr_en(  wr_en_o),
                   .clk(clk),
                   .din(BUS9884),
                   .dmem_addr_i(BUS9589),
                   .dmem_ctl(BUS5985),
                   .dout(BUS22401),
                   .zZ_din(  din)
               );

    assign NET21531 = NET1572 | iack_o;

    rf_stage iRF_stage
             (
                 .clk(clk),
                 .cmp_ctl_i(BUS109),
                 .ext_ctl_i(BUS117),
                 .ext_o(BUS7219),
                 .fw_alu_i(cop_addr_o),
                 .fw_cmp_rs(BUS2140),
                 .fw_cmp_rt(BUS2156),
                 .fw_mem_i(BUS15471),
                 .iack_o(iack_o),
                 .id2ra_ctl_clr_o(NET1606),
                 .id2ra_ctl_cls_o(NET1572),
                 .id_cmd(BUS197),
                 .ins_i(  ins_i),
                 .irq_addr_i(irq_addr),
                 .irq_i(irq_i),
                 .pc_gen_ctl(BUS271),
                 .pc_i(BUS27031),
                 .pc_next(  pc_o),
                 .ra2ex_ctl_clr_o(NET1640),
                 .rd_index_o(BUS775),
                 .rd_sel_i(BUS371),
                 .rs_n_o(BUS748),
                 .rs_o(BUS24839),
                 .rst_i(rst),
                 .rt_n_o(BUS756),
                 .rt_o(BUS7160),
                 .wb_addr_i(BUS18211),
                 .wb_din_i(BUS15471),
                 .wb_we_i(NET1375),
                 .zz_spc_i(BUS28013)
             );



    exec_stage iexec_stage
               (
                   .alu_func(BUS6275),
                   .alu_ur_o(BUS9589),
                   .clk(clk),
                   .dmem_data_ur_o(BUS9884),
                   .dmem_fw_ctl(BUS5993),
                   .ext_i(BUS7231),
                   .fw_alu(cop_addr_o),
                   .fw_dmem(BUS15471),
                   .muxa_ctl_i(BUS5832),
                   .muxa_fw_ctl(BUS1158),
                   .muxb_ctl_i(BUS5840),
                   .muxb_fw_ctl(BUS1196),
                   .pc_i(BUS27031),
                   .rs_i(BUS7101),
                   .rst(rst),
                   .rt_i(BUS7117),
                   .spc_cls_i(NET21531),
                   .zz_spc_o(BUS28013)
               );



    r32_reg alu_pass0
            (
                .clk(clk),
                .r32_i(BUS9589),
                .r32_o(cop_addr_o)
            );



    r32_reg alu_pass1
            (
                .clk(clk),
                .r32_i(cop_addr_o),
                .r32_o(BUS422)
            );



    or32 cop_data_or
         (
             .a(cop_dout),
             .b(BUS7772),
             .c(BUS7780)
         );



    r32_reg cop_data_reg
            (
                .clk(clk),
                .r32_i(BUS9884),
                .r32_o(cop_data_o)
            );



    r32_reg cop_dout_reg
            (
                .clk(clk),
                .r32_i(BUS22401),
                .r32_o(BUS7772)
            );



    decode_pipe decoder_pipe
                (
                    .alu_func_o(BUS6275),
                    .alu_we_o(NET767),
                    .clk(clk),
                    .cmp_ctl_o(BUS109),
                    .dmem_ctl_o(cop_mem_ctl_o),
                    .dmem_ctl_ur_o(BUS5985),
                    .ext_ctl_o(BUS117),
                    .fsm_dly(BUS197),
                    .id2ra_ctl_clr(NET1606),
                    .id2ra_ctl_cls(NET1572),
                    .ins_i(  ins_i),
                    .muxa_ctl_o(BUS5832),
                    .muxb_ctl_o(BUS5840),
                    .pc_gen_ctl_o(BUS271),
                    .ra2ex_ctl_clr(NET1640),
                    .rd_sel_o(BUS371),
                    .wb_mux_ctl_o(NET457),
                    .wb_we_o(NET1375)
                );



    r32_reg ext_reg
            (
                .clk(clk),
                .r32_i(BUS7219),
                .r32_o(BUS7231)
            );



    forward iforward
            (
                .alu_rs_fw(BUS1158),
                .alu_rt_fw(BUS1196),
                .alu_we(NET767),
                .clk(clk),
                .cmp_rs_fw(BUS2140),
                .cmp_rt_fw(BUS2156),
                .dmem_fw(BUS5993),
                .fw_alu_rn(BUS1724),
                .fw_mem_rn(BUS18211),
                .mem_We(NET1375),
                .rns_i(BUS748),
                .rnt_i(BUS756)
            );



    r32_reg pc
            (
                .clk(clk),
                .r32_i(  pc_o),
                .r32_o(BUS27031)
            );



    r5_reg rnd_pass0
           (
               .clk(clk),
               .r5_i(BUS775),
               .r5_o(BUS1726)
           );



    r5_reg rnd_pass1
           (
               .clk(clk),
               .r5_i(BUS1726),
               .r5_o(BUS1724)
           );



    r5_reg rnd_pass2
           (
               .clk(clk),
               .r5_i(BUS1724),
               .r5_o(BUS18211)
           );



    r32_reg rs_reg
            (
                .clk(clk),
                .r32_i(BUS24839),
                .r32_o(BUS7101)
            );



    r32_reg rt_reg
            (
                .clk(clk),
                .r32_i(BUS7160),
                .r32_o(BUS7117)
            );



    wb_mux wb_mux
           (
               .alu_i(BUS422),
               .dmem_i(BUS7780),
               .sel(NET457),
               .wb_o(BUS15471)
           );

endmodule
