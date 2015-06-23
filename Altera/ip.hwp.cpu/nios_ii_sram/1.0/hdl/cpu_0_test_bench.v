//Legal Notice: (C)2012 Altera Corporation. All rights reserved.  Your
//use of Altera Corporation's design tools, logic functions and other
//software and tools, and its AMPP partner logic functions, and any
//output files any of the foregoing (including device programming or
//simulation files), and any associated documentation or information are
//expressly subject to the terms and conditions of the Altera Program
//License Subscription Agreement or other applicable license agreement,
//including, without limitation, that your use is for the sole purpose
//of programming logic devices manufactured by Altera and sold by Altera
//or its authorized distributors.  Please refer to the applicable
//agreement for further details.

// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module cpu_0_test_bench (
                          // inputs:
                           A_bstatus_reg,
                           A_cmp_result,
                           A_ctrl_exception,
                           A_ctrl_ld_non_bypass,
                           A_dst_regnum,
                           A_en,
                           A_estatus_reg,
                           A_ienable_reg,
                           A_ipending_reg,
                           A_iw,
                           A_mem_byte_en,
                           A_op_hbreak,
                           A_op_intr,
                           A_pcb,
                           A_st_data,
                           A_status_reg,
                           A_valid,
                           A_wr_data_unfiltered,
                           A_wr_dst_reg,
                           E_add_br_to_taken_history_unfiltered,
                           E_logic_result,
                           E_valid,
                           M_bht_ptr_unfiltered,
                           M_bht_wr_data_unfiltered,
                           M_bht_wr_en_unfiltered,
                           M_mem_baddr,
                           M_target_pcb,
                           M_valid,
                           W_dst_regnum,
                           W_iw,
                           W_iw_op,
                           W_iw_opx,
                           W_pcb,
                           W_valid,
                           W_vinst,
                           W_wr_dst_reg,
                           clk,
                           d_address,
                           d_byteenable,
                           d_read,
                           d_write,
                           i_address,
                           i_read,
                           i_readdatavalid,
                           reset_n,

                          // outputs:
                           A_wr_data_filtered,
                           E_add_br_to_taken_history_filtered,
                           E_src1_eq_src2,
                           M_bht_ptr_filtered,
                           M_bht_wr_data_filtered,
                           M_bht_wr_en_filtered,
                           test_has_ended
                        )
;

  output  [ 31: 0] A_wr_data_filtered;
  output           E_add_br_to_taken_history_filtered;
  output           E_src1_eq_src2;
  output  [  7: 0] M_bht_ptr_filtered;
  output  [  1: 0] M_bht_wr_data_filtered;
  output           M_bht_wr_en_filtered;
  output           test_has_ended;
  input   [ 31: 0] A_bstatus_reg;
  input            A_cmp_result;
  input            A_ctrl_exception;
  input            A_ctrl_ld_non_bypass;
  input   [  4: 0] A_dst_regnum;
  input            A_en;
  input   [ 31: 0] A_estatus_reg;
  input   [ 31: 0] A_ienable_reg;
  input   [ 31: 0] A_ipending_reg;
  input   [ 31: 0] A_iw;
  input   [  3: 0] A_mem_byte_en;
  input            A_op_hbreak;
  input            A_op_intr;
  input   [ 20: 0] A_pcb;
  input   [ 31: 0] A_st_data;
  input   [ 31: 0] A_status_reg;
  input            A_valid;
  input   [ 31: 0] A_wr_data_unfiltered;
  input            A_wr_dst_reg;
  input            E_add_br_to_taken_history_unfiltered;
  input   [ 31: 0] E_logic_result;
  input            E_valid;
  input   [  7: 0] M_bht_ptr_unfiltered;
  input   [  1: 0] M_bht_wr_data_unfiltered;
  input            M_bht_wr_en_unfiltered;
  input   [ 20: 0] M_mem_baddr;
  input   [ 20: 0] M_target_pcb;
  input            M_valid;
  input   [  4: 0] W_dst_regnum;
  input   [ 31: 0] W_iw;
  input   [  5: 0] W_iw_op;
  input   [  5: 0] W_iw_opx;
  input   [ 20: 0] W_pcb;
  input            W_valid;
  input   [ 55: 0] W_vinst;
  input            W_wr_dst_reg;
  input            clk;
  input   [ 20: 0] d_address;
  input   [  3: 0] d_byteenable;
  input            d_read;
  input            d_write;
  input   [ 20: 0] i_address;
  input            i_read;
  input            i_readdatavalid;
  input            reset_n;

  reg     [ 20: 0] A_mem_baddr;
  reg     [ 20: 0] A_target_pcb;
  wire    [ 31: 0] A_wr_data_filtered;
  wire             A_wr_data_unfiltered_0_is_x;
  wire             A_wr_data_unfiltered_10_is_x;
  wire             A_wr_data_unfiltered_11_is_x;
  wire             A_wr_data_unfiltered_12_is_x;
  wire             A_wr_data_unfiltered_13_is_x;
  wire             A_wr_data_unfiltered_14_is_x;
  wire             A_wr_data_unfiltered_15_is_x;
  wire             A_wr_data_unfiltered_16_is_x;
  wire             A_wr_data_unfiltered_17_is_x;
  wire             A_wr_data_unfiltered_18_is_x;
  wire             A_wr_data_unfiltered_19_is_x;
  wire             A_wr_data_unfiltered_1_is_x;
  wire             A_wr_data_unfiltered_20_is_x;
  wire             A_wr_data_unfiltered_21_is_x;
  wire             A_wr_data_unfiltered_22_is_x;
  wire             A_wr_data_unfiltered_23_is_x;
  wire             A_wr_data_unfiltered_24_is_x;
  wire             A_wr_data_unfiltered_25_is_x;
  wire             A_wr_data_unfiltered_26_is_x;
  wire             A_wr_data_unfiltered_27_is_x;
  wire             A_wr_data_unfiltered_28_is_x;
  wire             A_wr_data_unfiltered_29_is_x;
  wire             A_wr_data_unfiltered_2_is_x;
  wire             A_wr_data_unfiltered_30_is_x;
  wire             A_wr_data_unfiltered_31_is_x;
  wire             A_wr_data_unfiltered_3_is_x;
  wire             A_wr_data_unfiltered_4_is_x;
  wire             A_wr_data_unfiltered_5_is_x;
  wire             A_wr_data_unfiltered_6_is_x;
  wire             A_wr_data_unfiltered_7_is_x;
  wire             A_wr_data_unfiltered_8_is_x;
  wire             A_wr_data_unfiltered_9_is_x;
  wire             E_add_br_to_taken_history_filtered;
  wire             E_src1_eq_src2;
  wire    [  7: 0] M_bht_ptr_filtered;
  wire    [  1: 0] M_bht_wr_data_filtered;
  wire             M_bht_wr_en_filtered;
  wire             W_op_add;
  wire             W_op_addi;
  wire             W_op_and;
  wire             W_op_andhi;
  wire             W_op_andi;
  wire             W_op_beq;
  wire             W_op_bge;
  wire             W_op_bgeu;
  wire             W_op_blt;
  wire             W_op_bltu;
  wire             W_op_bne;
  wire             W_op_br;
  wire             W_op_break;
  wire             W_op_bret;
  wire             W_op_call;
  wire             W_op_callr;
  wire             W_op_cmpeq;
  wire             W_op_cmpeqi;
  wire             W_op_cmpge;
  wire             W_op_cmpgei;
  wire             W_op_cmpgeu;
  wire             W_op_cmpgeui;
  wire             W_op_cmplt;
  wire             W_op_cmplti;
  wire             W_op_cmpltu;
  wire             W_op_cmpltui;
  wire             W_op_cmpne;
  wire             W_op_cmpnei;
  wire             W_op_crst;
  wire             W_op_custom;
  wire             W_op_div;
  wire             W_op_divu;
  wire             W_op_eret;
  wire             W_op_flushd;
  wire             W_op_flushda;
  wire             W_op_flushi;
  wire             W_op_flushp;
  wire             W_op_hbreak;
  wire             W_op_initd;
  wire             W_op_initda;
  wire             W_op_initi;
  wire             W_op_intr;
  wire             W_op_jmp;
  wire             W_op_jmpi;
  wire             W_op_ldb;
  wire             W_op_ldbio;
  wire             W_op_ldbu;
  wire             W_op_ldbuio;
  wire             W_op_ldh;
  wire             W_op_ldhio;
  wire             W_op_ldhu;
  wire             W_op_ldhuio;
  wire             W_op_ldl;
  wire             W_op_ldw;
  wire             W_op_ldwio;
  wire             W_op_mul;
  wire             W_op_muli;
  wire             W_op_mulxss;
  wire             W_op_mulxsu;
  wire             W_op_mulxuu;
  wire             W_op_nextpc;
  wire             W_op_nor;
  wire             W_op_opx;
  wire             W_op_or;
  wire             W_op_orhi;
  wire             W_op_ori;
  wire             W_op_rdctl;
  wire             W_op_rdprs;
  wire             W_op_ret;
  wire             W_op_rol;
  wire             W_op_roli;
  wire             W_op_ror;
  wire             W_op_rsv02;
  wire             W_op_rsv09;
  wire             W_op_rsv10;
  wire             W_op_rsv17;
  wire             W_op_rsv18;
  wire             W_op_rsv25;
  wire             W_op_rsv26;
  wire             W_op_rsv33;
  wire             W_op_rsv34;
  wire             W_op_rsv41;
  wire             W_op_rsv42;
  wire             W_op_rsv49;
  wire             W_op_rsv57;
  wire             W_op_rsv61;
  wire             W_op_rsv62;
  wire             W_op_rsv63;
  wire             W_op_rsvx00;
  wire             W_op_rsvx10;
  wire             W_op_rsvx15;
  wire             W_op_rsvx17;
  wire             W_op_rsvx21;
  wire             W_op_rsvx25;
  wire             W_op_rsvx33;
  wire             W_op_rsvx34;
  wire             W_op_rsvx35;
  wire             W_op_rsvx42;
  wire             W_op_rsvx43;
  wire             W_op_rsvx44;
  wire             W_op_rsvx47;
  wire             W_op_rsvx50;
  wire             W_op_rsvx51;
  wire             W_op_rsvx55;
  wire             W_op_rsvx56;
  wire             W_op_rsvx60;
  wire             W_op_rsvx63;
  wire             W_op_sll;
  wire             W_op_slli;
  wire             W_op_sra;
  wire             W_op_srai;
  wire             W_op_srl;
  wire             W_op_srli;
  wire             W_op_stb;
  wire             W_op_stbio;
  wire             W_op_stc;
  wire             W_op_sth;
  wire             W_op_sthio;
  wire             W_op_stw;
  wire             W_op_stwio;
  wire             W_op_sub;
  wire             W_op_sync;
  wire             W_op_trap;
  wire             W_op_wrctl;
  wire             W_op_wrprs;
  wire             W_op_xor;
  wire             W_op_xorhi;
  wire             W_op_xori;
  wire             test_has_ended;
  assign W_op_call = W_iw_op == 0;
  assign W_op_jmpi = W_iw_op == 1;
  assign W_op_ldbu = W_iw_op == 3;
  assign W_op_addi = W_iw_op == 4;
  assign W_op_stb = W_iw_op == 5;
  assign W_op_br = W_iw_op == 6;
  assign W_op_ldb = W_iw_op == 7;
  assign W_op_cmpgei = W_iw_op == 8;
  assign W_op_ldhu = W_iw_op == 11;
  assign W_op_andi = W_iw_op == 12;
  assign W_op_sth = W_iw_op == 13;
  assign W_op_bge = W_iw_op == 14;
  assign W_op_ldh = W_iw_op == 15;
  assign W_op_cmplti = W_iw_op == 16;
  assign W_op_initda = W_iw_op == 19;
  assign W_op_ori = W_iw_op == 20;
  assign W_op_stw = W_iw_op == 21;
  assign W_op_blt = W_iw_op == 22;
  assign W_op_ldw = W_iw_op == 23;
  assign W_op_cmpnei = W_iw_op == 24;
  assign W_op_flushda = W_iw_op == 27;
  assign W_op_xori = W_iw_op == 28;
  assign W_op_stc = W_iw_op == 29;
  assign W_op_bne = W_iw_op == 30;
  assign W_op_ldl = W_iw_op == 31;
  assign W_op_cmpeqi = W_iw_op == 32;
  assign W_op_ldbuio = W_iw_op == 35;
  assign W_op_muli = W_iw_op == 36;
  assign W_op_stbio = W_iw_op == 37;
  assign W_op_beq = W_iw_op == 38;
  assign W_op_ldbio = W_iw_op == 39;
  assign W_op_cmpgeui = W_iw_op == 40;
  assign W_op_ldhuio = W_iw_op == 43;
  assign W_op_andhi = W_iw_op == 44;
  assign W_op_sthio = W_iw_op == 45;
  assign W_op_bgeu = W_iw_op == 46;
  assign W_op_ldhio = W_iw_op == 47;
  assign W_op_cmpltui = W_iw_op == 48;
  assign W_op_initd = W_iw_op == 51;
  assign W_op_orhi = W_iw_op == 52;
  assign W_op_stwio = W_iw_op == 53;
  assign W_op_bltu = W_iw_op == 54;
  assign W_op_ldwio = W_iw_op == 55;
  assign W_op_rdprs = W_iw_op == 56;
  assign W_op_flushd = W_iw_op == 59;
  assign W_op_xorhi = W_iw_op == 60;
  assign W_op_rsv02 = W_iw_op == 2;
  assign W_op_rsv09 = W_iw_op == 9;
  assign W_op_rsv10 = W_iw_op == 10;
  assign W_op_rsv17 = W_iw_op == 17;
  assign W_op_rsv18 = W_iw_op == 18;
  assign W_op_rsv25 = W_iw_op == 25;
  assign W_op_rsv26 = W_iw_op == 26;
  assign W_op_rsv33 = W_iw_op == 33;
  assign W_op_rsv34 = W_iw_op == 34;
  assign W_op_rsv41 = W_iw_op == 41;
  assign W_op_rsv42 = W_iw_op == 42;
  assign W_op_rsv49 = W_iw_op == 49;
  assign W_op_rsv57 = W_iw_op == 57;
  assign W_op_rsv61 = W_iw_op == 61;
  assign W_op_rsv62 = W_iw_op == 62;
  assign W_op_rsv63 = W_iw_op == 63;
  assign W_op_eret = W_op_opx & (W_iw_opx == 1);
  assign W_op_roli = W_op_opx & (W_iw_opx == 2);
  assign W_op_rol = W_op_opx & (W_iw_opx == 3);
  assign W_op_flushp = W_op_opx & (W_iw_opx == 4);
  assign W_op_ret = W_op_opx & (W_iw_opx == 5);
  assign W_op_nor = W_op_opx & (W_iw_opx == 6);
  assign W_op_mulxuu = W_op_opx & (W_iw_opx == 7);
  assign W_op_cmpge = W_op_opx & (W_iw_opx == 8);
  assign W_op_bret = W_op_opx & (W_iw_opx == 9);
  assign W_op_ror = W_op_opx & (W_iw_opx == 11);
  assign W_op_flushi = W_op_opx & (W_iw_opx == 12);
  assign W_op_jmp = W_op_opx & (W_iw_opx == 13);
  assign W_op_and = W_op_opx & (W_iw_opx == 14);
  assign W_op_cmplt = W_op_opx & (W_iw_opx == 16);
  assign W_op_slli = W_op_opx & (W_iw_opx == 18);
  assign W_op_sll = W_op_opx & (W_iw_opx == 19);
  assign W_op_wrprs = W_op_opx & (W_iw_opx == 20);
  assign W_op_or = W_op_opx & (W_iw_opx == 22);
  assign W_op_mulxsu = W_op_opx & (W_iw_opx == 23);
  assign W_op_cmpne = W_op_opx & (W_iw_opx == 24);
  assign W_op_srli = W_op_opx & (W_iw_opx == 26);
  assign W_op_srl = W_op_opx & (W_iw_opx == 27);
  assign W_op_nextpc = W_op_opx & (W_iw_opx == 28);
  assign W_op_callr = W_op_opx & (W_iw_opx == 29);
  assign W_op_xor = W_op_opx & (W_iw_opx == 30);
  assign W_op_mulxss = W_op_opx & (W_iw_opx == 31);
  assign W_op_cmpeq = W_op_opx & (W_iw_opx == 32);
  assign W_op_divu = W_op_opx & (W_iw_opx == 36);
  assign W_op_div = W_op_opx & (W_iw_opx == 37);
  assign W_op_rdctl = W_op_opx & (W_iw_opx == 38);
  assign W_op_mul = W_op_opx & (W_iw_opx == 39);
  assign W_op_cmpgeu = W_op_opx & (W_iw_opx == 40);
  assign W_op_initi = W_op_opx & (W_iw_opx == 41);
  assign W_op_trap = W_op_opx & (W_iw_opx == 45);
  assign W_op_wrctl = W_op_opx & (W_iw_opx == 46);
  assign W_op_cmpltu = W_op_opx & (W_iw_opx == 48);
  assign W_op_add = W_op_opx & (W_iw_opx == 49);
  assign W_op_break = W_op_opx & (W_iw_opx == 52);
  assign W_op_hbreak = W_op_opx & (W_iw_opx == 53);
  assign W_op_sync = W_op_opx & (W_iw_opx == 54);
  assign W_op_sub = W_op_opx & (W_iw_opx == 57);
  assign W_op_srai = W_op_opx & (W_iw_opx == 58);
  assign W_op_sra = W_op_opx & (W_iw_opx == 59);
  assign W_op_intr = W_op_opx & (W_iw_opx == 61);
  assign W_op_crst = W_op_opx & (W_iw_opx == 62);
  assign W_op_rsvx00 = W_op_opx & (W_iw_opx == 0);
  assign W_op_rsvx10 = W_op_opx & (W_iw_opx == 10);
  assign W_op_rsvx15 = W_op_opx & (W_iw_opx == 15);
  assign W_op_rsvx17 = W_op_opx & (W_iw_opx == 17);
  assign W_op_rsvx21 = W_op_opx & (W_iw_opx == 21);
  assign W_op_rsvx25 = W_op_opx & (W_iw_opx == 25);
  assign W_op_rsvx33 = W_op_opx & (W_iw_opx == 33);
  assign W_op_rsvx34 = W_op_opx & (W_iw_opx == 34);
  assign W_op_rsvx35 = W_op_opx & (W_iw_opx == 35);
  assign W_op_rsvx42 = W_op_opx & (W_iw_opx == 42);
  assign W_op_rsvx43 = W_op_opx & (W_iw_opx == 43);
  assign W_op_rsvx44 = W_op_opx & (W_iw_opx == 44);
  assign W_op_rsvx47 = W_op_opx & (W_iw_opx == 47);
  assign W_op_rsvx50 = W_op_opx & (W_iw_opx == 50);
  assign W_op_rsvx51 = W_op_opx & (W_iw_opx == 51);
  assign W_op_rsvx55 = W_op_opx & (W_iw_opx == 55);
  assign W_op_rsvx56 = W_op_opx & (W_iw_opx == 56);
  assign W_op_rsvx60 = W_op_opx & (W_iw_opx == 60);
  assign W_op_rsvx63 = W_op_opx & (W_iw_opx == 63);
  assign W_op_opx = W_iw_op == 58;
  assign W_op_custom = W_iw_op == 50;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          A_target_pcb <= 0;
      else if (A_en)
          A_target_pcb <= M_target_pcb;
    end


  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          A_mem_baddr <= 0;
      else if (A_en)
          A_mem_baddr <= M_mem_baddr;
    end


  assign E_src1_eq_src2 = E_logic_result == 0;
  //Propagating 'X' data bits
  assign E_add_br_to_taken_history_filtered = E_add_br_to_taken_history_unfiltered;

  //Propagating 'X' data bits
  assign M_bht_wr_en_filtered = M_bht_wr_en_unfiltered;

  //Propagating 'X' data bits
  assign M_bht_wr_data_filtered = M_bht_wr_data_unfiltered;

  //Propagating 'X' data bits
  assign M_bht_ptr_filtered = M_bht_ptr_unfiltered;

  assign test_has_ended = 1'b0;

//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //Clearing 'X' data bits
  assign A_wr_data_unfiltered_0_is_x = ^(A_wr_data_unfiltered[0]) === 1'bx;

  assign A_wr_data_filtered[0] = (A_wr_data_unfiltered_0_is_x & (A_ctrl_ld_non_bypass)) ? 1'b0 : A_wr_data_unfiltered[0];
  assign A_wr_data_unfiltered_1_is_x = ^(A_wr_data_unfiltered[1]) === 1'bx;
  assign A_wr_data_filtered[1] = (A_wr_data_unfiltered_1_is_x & (A_ctrl_ld_non_bypass)) ? 1'b0 : A_wr_data_unfiltered[1];
  assign A_wr_data_unfiltered_2_is_x = ^(A_wr_data_unfiltered[2]) === 1'bx;
  assign A_wr_data_filtered[2] = (A_wr_data_unfiltered_2_is_x & (A_ctrl_ld_non_bypass)) ? 1'b0 : A_wr_data_unfiltered[2];
  assign A_wr_data_unfiltered_3_is_x = ^(A_wr_data_unfiltered[3]) === 1'bx;
  assign A_wr_data_filtered[3] = (A_wr_data_unfiltered_3_is_x & (A_ctrl_ld_non_bypass)) ? 1'b0 : A_wr_data_unfiltered[3];
  assign A_wr_data_unfiltered_4_is_x = ^(A_wr_data_unfiltered[4]) === 1'bx;
  assign A_wr_data_filtered[4] = (A_wr_data_unfiltered_4_is_x & (A_ctrl_ld_non_bypass)) ? 1'b0 : A_wr_data_unfiltered[4];
  assign A_wr_data_unfiltered_5_is_x = ^(A_wr_data_unfiltered[5]) === 1'bx;
  assign A_wr_data_filtered[5] = (A_wr_data_unfiltered_5_is_x & (A_ctrl_ld_non_bypass)) ? 1'b0 : A_wr_data_unfiltered[5];
  assign A_wr_data_unfiltered_6_is_x = ^(A_wr_data_unfiltered[6]) === 1'bx;
  assign A_wr_data_filtered[6] = (A_wr_data_unfiltered_6_is_x & (A_ctrl_ld_non_bypass)) ? 1'b0 : A_wr_data_unfiltered[6];
  assign A_wr_data_unfiltered_7_is_x = ^(A_wr_data_unfiltered[7]) === 1'bx;
  assign A_wr_data_filtered[7] = (A_wr_data_unfiltered_7_is_x & (A_ctrl_ld_non_bypass)) ? 1'b0 : A_wr_data_unfiltered[7];
  assign A_wr_data_unfiltered_8_is_x = ^(A_wr_data_unfiltered[8]) === 1'bx;
  assign A_wr_data_filtered[8] = (A_wr_data_unfiltered_8_is_x & (A_ctrl_ld_non_bypass)) ? 1'b0 : A_wr_data_unfiltered[8];
  assign A_wr_data_unfiltered_9_is_x = ^(A_wr_data_unfiltered[9]) === 1'bx;
  assign A_wr_data_filtered[9] = (A_wr_data_unfiltered_9_is_x & (A_ctrl_ld_non_bypass)) ? 1'b0 : A_wr_data_unfiltered[9];
  assign A_wr_data_unfiltered_10_is_x = ^(A_wr_data_unfiltered[10]) === 1'bx;
  assign A_wr_data_filtered[10] = (A_wr_data_unfiltered_10_is_x & (A_ctrl_ld_non_bypass)) ? 1'b0 : A_wr_data_unfiltered[10];
  assign A_wr_data_unfiltered_11_is_x = ^(A_wr_data_unfiltered[11]) === 1'bx;
  assign A_wr_data_filtered[11] = (A_wr_data_unfiltered_11_is_x & (A_ctrl_ld_non_bypass)) ? 1'b0 : A_wr_data_unfiltered[11];
  assign A_wr_data_unfiltered_12_is_x = ^(A_wr_data_unfiltered[12]) === 1'bx;
  assign A_wr_data_filtered[12] = (A_wr_data_unfiltered_12_is_x & (A_ctrl_ld_non_bypass)) ? 1'b0 : A_wr_data_unfiltered[12];
  assign A_wr_data_unfiltered_13_is_x = ^(A_wr_data_unfiltered[13]) === 1'bx;
  assign A_wr_data_filtered[13] = (A_wr_data_unfiltered_13_is_x & (A_ctrl_ld_non_bypass)) ? 1'b0 : A_wr_data_unfiltered[13];
  assign A_wr_data_unfiltered_14_is_x = ^(A_wr_data_unfiltered[14]) === 1'bx;
  assign A_wr_data_filtered[14] = (A_wr_data_unfiltered_14_is_x & (A_ctrl_ld_non_bypass)) ? 1'b0 : A_wr_data_unfiltered[14];
  assign A_wr_data_unfiltered_15_is_x = ^(A_wr_data_unfiltered[15]) === 1'bx;
  assign A_wr_data_filtered[15] = (A_wr_data_unfiltered_15_is_x & (A_ctrl_ld_non_bypass)) ? 1'b0 : A_wr_data_unfiltered[15];
  assign A_wr_data_unfiltered_16_is_x = ^(A_wr_data_unfiltered[16]) === 1'bx;
  assign A_wr_data_filtered[16] = (A_wr_data_unfiltered_16_is_x & (A_ctrl_ld_non_bypass)) ? 1'b0 : A_wr_data_unfiltered[16];
  assign A_wr_data_unfiltered_17_is_x = ^(A_wr_data_unfiltered[17]) === 1'bx;
  assign A_wr_data_filtered[17] = (A_wr_data_unfiltered_17_is_x & (A_ctrl_ld_non_bypass)) ? 1'b0 : A_wr_data_unfiltered[17];
  assign A_wr_data_unfiltered_18_is_x = ^(A_wr_data_unfiltered[18]) === 1'bx;
  assign A_wr_data_filtered[18] = (A_wr_data_unfiltered_18_is_x & (A_ctrl_ld_non_bypass)) ? 1'b0 : A_wr_data_unfiltered[18];
  assign A_wr_data_unfiltered_19_is_x = ^(A_wr_data_unfiltered[19]) === 1'bx;
  assign A_wr_data_filtered[19] = (A_wr_data_unfiltered_19_is_x & (A_ctrl_ld_non_bypass)) ? 1'b0 : A_wr_data_unfiltered[19];
  assign A_wr_data_unfiltered_20_is_x = ^(A_wr_data_unfiltered[20]) === 1'bx;
  assign A_wr_data_filtered[20] = (A_wr_data_unfiltered_20_is_x & (A_ctrl_ld_non_bypass)) ? 1'b0 : A_wr_data_unfiltered[20];
  assign A_wr_data_unfiltered_21_is_x = ^(A_wr_data_unfiltered[21]) === 1'bx;
  assign A_wr_data_filtered[21] = (A_wr_data_unfiltered_21_is_x & (A_ctrl_ld_non_bypass)) ? 1'b0 : A_wr_data_unfiltered[21];
  assign A_wr_data_unfiltered_22_is_x = ^(A_wr_data_unfiltered[22]) === 1'bx;
  assign A_wr_data_filtered[22] = (A_wr_data_unfiltered_22_is_x & (A_ctrl_ld_non_bypass)) ? 1'b0 : A_wr_data_unfiltered[22];
  assign A_wr_data_unfiltered_23_is_x = ^(A_wr_data_unfiltered[23]) === 1'bx;
  assign A_wr_data_filtered[23] = (A_wr_data_unfiltered_23_is_x & (A_ctrl_ld_non_bypass)) ? 1'b0 : A_wr_data_unfiltered[23];
  assign A_wr_data_unfiltered_24_is_x = ^(A_wr_data_unfiltered[24]) === 1'bx;
  assign A_wr_data_filtered[24] = (A_wr_data_unfiltered_24_is_x & (A_ctrl_ld_non_bypass)) ? 1'b0 : A_wr_data_unfiltered[24];
  assign A_wr_data_unfiltered_25_is_x = ^(A_wr_data_unfiltered[25]) === 1'bx;
  assign A_wr_data_filtered[25] = (A_wr_data_unfiltered_25_is_x & (A_ctrl_ld_non_bypass)) ? 1'b0 : A_wr_data_unfiltered[25];
  assign A_wr_data_unfiltered_26_is_x = ^(A_wr_data_unfiltered[26]) === 1'bx;
  assign A_wr_data_filtered[26] = (A_wr_data_unfiltered_26_is_x & (A_ctrl_ld_non_bypass)) ? 1'b0 : A_wr_data_unfiltered[26];
  assign A_wr_data_unfiltered_27_is_x = ^(A_wr_data_unfiltered[27]) === 1'bx;
  assign A_wr_data_filtered[27] = (A_wr_data_unfiltered_27_is_x & (A_ctrl_ld_non_bypass)) ? 1'b0 : A_wr_data_unfiltered[27];
  assign A_wr_data_unfiltered_28_is_x = ^(A_wr_data_unfiltered[28]) === 1'bx;
  assign A_wr_data_filtered[28] = (A_wr_data_unfiltered_28_is_x & (A_ctrl_ld_non_bypass)) ? 1'b0 : A_wr_data_unfiltered[28];
  assign A_wr_data_unfiltered_29_is_x = ^(A_wr_data_unfiltered[29]) === 1'bx;
  assign A_wr_data_filtered[29] = (A_wr_data_unfiltered_29_is_x & (A_ctrl_ld_non_bypass)) ? 1'b0 : A_wr_data_unfiltered[29];
  assign A_wr_data_unfiltered_30_is_x = ^(A_wr_data_unfiltered[30]) === 1'bx;
  assign A_wr_data_filtered[30] = (A_wr_data_unfiltered_30_is_x & (A_ctrl_ld_non_bypass)) ? 1'b0 : A_wr_data_unfiltered[30];
  assign A_wr_data_unfiltered_31_is_x = ^(A_wr_data_unfiltered[31]) === 1'bx;
  assign A_wr_data_filtered[31] = (A_wr_data_unfiltered_31_is_x & (A_ctrl_ld_non_bypass)) ? 1'b0 : A_wr_data_unfiltered[31];
  always @(posedge clk)
    begin
      if (reset_n)
          if (^(W_wr_dst_reg) === 1'bx)
            begin
              $write("%0d ns: ERROR: cpu_0_test_bench/W_wr_dst_reg is 'x'\n", $time);
              $stop;
            end
    end


  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
        begin
        end
      else if (W_wr_dst_reg)
          if (^(W_dst_regnum) === 1'bx)
            begin
              $write("%0d ns: ERROR: cpu_0_test_bench/W_dst_regnum is 'x'\n", $time);
              $stop;
            end
    end


  always @(posedge clk)
    begin
      if (reset_n)
          if (^(W_valid) === 1'bx)
            begin
              $write("%0d ns: ERROR: cpu_0_test_bench/W_valid is 'x'\n", $time);
              $stop;
            end
    end


  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
        begin
        end
      else if (W_valid)
          if (^(W_pcb) === 1'bx)
            begin
              $write("%0d ns: ERROR: cpu_0_test_bench/W_pcb is 'x'\n", $time);
              $stop;
            end
    end


  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
        begin
        end
      else if (W_valid)
          if (^(W_iw) === 1'bx)
            begin
              $write("%0d ns: ERROR: cpu_0_test_bench/W_iw is 'x'\n", $time);
              $stop;
            end
    end


  always @(posedge clk)
    begin
      if (reset_n)
          if (^(A_en) === 1'bx)
            begin
              $write("%0d ns: ERROR: cpu_0_test_bench/A_en is 'x'\n", $time);
              $stop;
            end
    end


  always @(posedge clk)
    begin
      if (reset_n)
          if (^(E_valid) === 1'bx)
            begin
              $write("%0d ns: ERROR: cpu_0_test_bench/E_valid is 'x'\n", $time);
              $stop;
            end
    end


  always @(posedge clk)
    begin
      if (reset_n)
          if (^(M_valid) === 1'bx)
            begin
              $write("%0d ns: ERROR: cpu_0_test_bench/M_valid is 'x'\n", $time);
              $stop;
            end
    end


  always @(posedge clk)
    begin
      if (reset_n)
          if (^(A_valid) === 1'bx)
            begin
              $write("%0d ns: ERROR: cpu_0_test_bench/A_valid is 'x'\n", $time);
              $stop;
            end
    end


  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
        begin
        end
      else if (A_valid & A_en & A_wr_dst_reg)
          if (^(A_wr_data_unfiltered) === 1'bx)
            begin
              $write("%0d ns: WARNING: cpu_0_test_bench/A_wr_data_unfiltered is 'x'\n", $time);
            end
    end


  always @(posedge clk)
    begin
      if (reset_n)
          if (^(A_status_reg) === 1'bx)
            begin
              $write("%0d ns: ERROR: cpu_0_test_bench/A_status_reg is 'x'\n", $time);
              $stop;
            end
    end


  always @(posedge clk)
    begin
      if (reset_n)
          if (^(A_estatus_reg) === 1'bx)
            begin
              $write("%0d ns: ERROR: cpu_0_test_bench/A_estatus_reg is 'x'\n", $time);
              $stop;
            end
    end


  always @(posedge clk)
    begin
      if (reset_n)
          if (^(A_bstatus_reg) === 1'bx)
            begin
              $write("%0d ns: ERROR: cpu_0_test_bench/A_bstatus_reg is 'x'\n", $time);
              $stop;
            end
    end


  always @(posedge clk)
    begin
      if (reset_n)
          if (^(i_read) === 1'bx)
            begin
              $write("%0d ns: ERROR: cpu_0_test_bench/i_read is 'x'\n", $time);
              $stop;
            end
    end


  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
        begin
        end
      else if (i_read)
          if (^(i_address) === 1'bx)
            begin
              $write("%0d ns: ERROR: cpu_0_test_bench/i_address is 'x'\n", $time);
              $stop;
            end
    end


  always @(posedge clk)
    begin
      if (reset_n)
          if (^(i_readdatavalid) === 1'bx)
            begin
              $write("%0d ns: ERROR: cpu_0_test_bench/i_readdatavalid is 'x'\n", $time);
              $stop;
            end
    end


  always @(posedge clk)
    begin
      if (reset_n)
          if (^(d_write) === 1'bx)
            begin
              $write("%0d ns: ERROR: cpu_0_test_bench/d_write is 'x'\n", $time);
              $stop;
            end
    end


  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
        begin
        end
      else if (d_write)
          if (^(d_byteenable) === 1'bx)
            begin
              $write("%0d ns: ERROR: cpu_0_test_bench/d_byteenable is 'x'\n", $time);
              $stop;
            end
    end


  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
        begin
        end
      else if (d_write | d_read)
          if (^(d_address) === 1'bx)
            begin
              $write("%0d ns: ERROR: cpu_0_test_bench/d_address is 'x'\n", $time);
              $stop;
            end
    end


  always @(posedge clk)
    begin
      if (reset_n)
          if (^(d_read) === 1'bx)
            begin
              $write("%0d ns: ERROR: cpu_0_test_bench/d_read is 'x'\n", $time);
              $stop;
            end
    end


  
  reg [31:0] trace_handle; // for $fopen
  initial  
  begin
    trace_handle = $fopen("cpu_0.tr");
    $fwrite(trace_handle, "version 3\nnumThreads 1\n");
  end
  always @(posedge clk)
    begin
      if ((~reset_n || (A_valid & A_en)) && ~test_has_ended)
          $fwrite(trace_handle, "%0d ns: %0h,%0h,%0h,%0h,%0h,%0h,%0h,%0h,%0h,%0h,%0h,%0h,%0h,%0h,%0h,%0h,%0h,%0h,%0h,%0h,%0h,%0h,%0h,%0h,%0h,%0h,%0h,%0h,%0h,%0h,%0h,%0h,%0h,%0h,%0h,%0h\n", $time, ~reset_n, A_pcb, 0, A_op_intr, A_op_hbreak, A_iw, ~(A_op_intr | A_op_hbreak), A_wr_dst_reg, A_dst_regnum, 0, A_wr_data_filtered, A_mem_baddr, A_st_data, A_mem_byte_en, A_cmp_result, A_target_pcb, A_status_reg, A_estatus_reg, A_bstatus_reg, A_ienable_reg, A_ipending_reg, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, A_ctrl_exception ? 1 : 0, 0, 0, 0, 0);
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on
//synthesis read_comments_as_HDL on
//  
//  assign A_wr_data_filtered = A_wr_data_unfiltered;
//
//synthesis read_comments_as_HDL off

endmodule

