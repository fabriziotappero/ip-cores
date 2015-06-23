/* 
 * Copyright 2010, Aleksander Osman, alfik@poczta.fm. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are
 * permitted provided that the following conditions are met:
 *
 *  1. Redistributions of source code must retain the above copyright notice, this list of
 *     conditions and the following disclaimer.
 *
 *  2. Redistributions in binary form must reproduce the above copyright notice, this list
 *     of conditions and the following disclaimer in the documentation and/or other materials
 *     provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*! \file
 * \brief WISHBONE priority and round-robin SYSCON.
 */

/*! \brief \copybrief bus_syscon.v
*/
module bus_syscon(
    //% \name Clock and reset
    //% @{
    input CLK_I,
    input reset_n,
    input halt_switch,
    //% @}
    
    //% \name Priority WISHBONE master interfaces
    //% @{
    input           masterP_cyc_o,
    input           masterP_stb_o,
    input           masterP_we_o,
    input   [31:2]  masterP_adr_o,
    input   [3:0]   masterP_sel_o,
    input   [31:0]  masterP_dat_o,
    output          masterP_ack_i,
    output          masterP_rty_i,
    output          masterP_err_i,
    //% @}
    
    //% \name Round-robin WISHBONE master interfaces
    //% @{
    input           masterR1_cyc_o,
    input           masterR1_stb_o,
    input           masterR1_we_o,
    input   [31:2]  masterR1_adr_o,
    input   [3:0]   masterR1_sel_o,
    input   [31:0]  masterR1_dat_o,
    output          masterR1_ack_i,
    output          masterR1_rty_i,
    output          masterR1_err_i,
    
    input           masterR2_cyc_o,
    input           masterR2_stb_o,
    input           masterR2_we_o,
    input   [31:2]  masterR2_adr_o,
    input   [3:0]   masterR2_sel_o,
    input   [31:0]  masterR2_dat_o,
    output          masterR2_ack_i,
    output          masterR2_rty_i,
    output          masterR2_err_i,
    
    input           masterR3_cyc_o,
    input           masterR3_stb_o,
    input           masterR3_we_o,
    input   [31:2]  masterR3_adr_o,
    input   [3:0]   masterR3_sel_o,
    input   [31:0]  masterR3_dat_o,
    output          masterR3_ack_i,
    output          masterR3_rty_i,
    output          masterR3_err_i,
    
    input           masterR4_cyc_o,
    input           masterR4_stb_o,
    input           masterR4_we_o,
    input   [31:2]  masterR4_adr_o,
    input   [3:0]   masterR4_sel_o,
    input   [31:0]  masterR4_dat_o,
    output          masterR4_ack_i,
    output          masterR4_rty_i,
    output          masterR4_err_i,
    
    input           masterR5_cyc_o,
    input           masterR5_stb_o,
    input           masterR5_we_o,
    input   [31:2]  masterR5_adr_o,
    input   [3:0]   masterR5_sel_o,
    input   [31:0]  masterR5_dat_o,
    output          masterR5_ack_i,
    output          masterR5_rty_i,
    output          masterR5_err_i,
    
    input           masterR6_cyc_o,
    input           masterR6_stb_o,
    input           masterR6_we_o,
    input   [31:2]  masterR6_adr_o,
    input   [3:0]   masterR6_sel_o,
    input   [31:0]  masterR6_dat_o,
    output          masterR6_ack_i,
    output          masterR6_rty_i,
    output          masterR6_err_i,
    
    input           masterR7_cyc_o,
    input           masterR7_stb_o,
    input           masterR7_we_o,
    input   [31:2]  masterR7_adr_o,
    input   [3:0]   masterR7_sel_o,
    input   [31:0]  masterR7_dat_o,
    output          masterR7_ack_i,
    output          masterR7_rty_i,
    output          masterR7_err_i,
    //% @}
    
    //% \name Common WISHBONE master signals
    //% @{
    output  [31:2]  master_adr_o,
    output          master_we_o,
    output  [3:0]   master_sel_o,
    output  [31:0]  master_dat_o,
    output  [31:0]  slave_dat_o,
    //% @}
    
    //% \name AND/OR master address mask signals
    //% @{
    output  [31:2]  master_adr_early_o,
    input   [31:2]  master_adr_and_mask,
    input   [31:2]  master_adr_or_mask,
    //% @}
    
    //% \name WISHBONE slave interfaces
    //% @{
    output          slave0_cyc_i,
    output          slave0_stb_i,
    input           slave0_ack_o,
    input           slave0_rty_o,
    input           slave0_err_o,
    input   [31:0]  slave0_dat_o,
    
    input           slave1_selected,
    output          slave1_cyc_i,
    output          slave1_stb_i,
    input           slave1_ack_o,
    input           slave1_rty_o,
    input           slave1_err_o,
    input   [31:0]  slave1_dat_o,
    
    input           slave2_selected,
    output          slave2_cyc_i,
    output          slave2_stb_i,
    input           slave2_ack_o,
    input           slave2_rty_o,
    input           slave2_err_o,
    input   [31:0]  slave2_dat_o,
    
    input           slave3_selected,
    output          slave3_cyc_i,
    output          slave3_stb_i,
    input           slave3_ack_o,
    input           slave3_rty_o,
    input           slave3_err_o,
    input   [31:0]  slave3_dat_o,
    
    input           slave4_selected,
    output          slave4_cyc_i,
    output          slave4_stb_i,
    input           slave4_ack_o,
    input           slave4_rty_o,
    input           slave4_err_o,
    input   [31:0]  slave4_dat_o,
    
    input           slave5_selected,
    output          slave5_cyc_i,
    output          slave5_stb_i,
    input           slave5_ack_o,
    input           slave5_rty_o,
    input           slave5_err_o,
    input   [31:0]  slave5_dat_o,
    
    input           slave6_selected,
    output          slave6_cyc_i,
    output          slave6_stb_i,
    input           slave6_ack_o,
    input           slave6_rty_o,
    input           slave6_err_o,
    input   [31:0]  slave6_dat_o,
    
    input           slave7_selected,
    output          slave7_cyc_i,
    output          slave7_stb_i,
    input           slave7_ack_o,
    input           slave7_rty_o,
    input           slave7_err_o,
    input   [31:0]  slave7_dat_o,
    
    input           slave8_selected,
    output          slave8_cyc_i,
    output          slave8_stb_i,
    input           slave8_ack_o,
    input           slave8_rty_o,
    input           slave8_err_o,
    input   [31:0]  slave8_dat_o,
    
    input           slave9_selected,
    output          slave9_cyc_i,
    output          slave9_stb_i,
    input           slave9_ack_o,
    input           slave9_rty_o,
    input           slave9_err_o,
    input   [31:0]  slave9_dat_o,
    
    input           slave10_selected,
    output          slave10_cyc_i,
    output          slave10_stb_i,
    input           slave10_ack_o,
    input           slave10_rty_o,
    input           slave10_err_o,
    input   [31:0]  slave10_dat_o,
    
    input           slave11_selected,
    output          slave11_cyc_i,
    output          slave11_stb_i,
    input           slave11_ack_o,
    input           slave11_rty_o,
    input           slave11_err_o,
    input   [31:0]  slave11_dat_o,
    
    input           slave12_selected,
    output          slave12_cyc_i,
    output          slave12_stb_i,
    input           slave12_ack_o,
    input           slave12_rty_o,
    input           slave12_err_o,
    input   [31:0]  slave12_dat_o,
    
    input           slave13_selected,
    output          slave13_cyc_i,
    output          slave13_stb_i,
    input           slave13_ack_o,
    input           slave13_rty_o,
    input           slave13_err_o,
    input   [31:0]  slave13_dat_o,
    
    input           slave14_selected,
    output          slave14_cyc_i,
    output          slave14_stb_i,
    input           slave14_ack_o,
    input           slave14_rty_o,
    input           slave14_err_o,
    input   [31:0]  slave14_dat_o,
    
    input           slave15_selected,
    output          slave15_cyc_i,
    output          slave15_stb_i,
    input           slave15_ack_o,
    input           slave15_rty_o,
    input           slave15_err_o,
    input   [31:0]  slave15_dat_o,
    
    //% \name Debug signals
    //% @{
    output [7:0]    debug_syscon
    //% @}
);
assign debug_syscon = { 3'b0, last_master_reg };

assign master_adr_early_o =
    (last_master_reg == 5'd1)?  masterP_adr_o :
    (last_master_reg == 5'd2)?  masterR1_adr_o :
    (last_master_reg == 5'd3)?  masterR2_adr_o :
    (last_master_reg == 5'd4)?  masterR3_adr_o :
    (last_master_reg == 5'd5)?  masterR4_adr_o :
    (last_master_reg == 5'd6)?  masterR5_adr_o :
    (last_master_reg == 5'd7)?  masterR6_adr_o :
                                masterR7_adr_o;

assign master_adr_o = (master_adr_early_o & master_adr_and_mask) | master_adr_or_mask;

assign master_we_o =
    (last_master_reg == 5'd1)?  masterP_we_o :
    (last_master_reg == 5'd2)?  masterR1_we_o :
    (last_master_reg == 5'd3)?  masterR2_we_o :
    (last_master_reg == 5'd4)?  masterR3_we_o :
    (last_master_reg == 5'd5)?  masterR4_we_o :
    (last_master_reg == 5'd6)?  masterR5_we_o :
    (last_master_reg == 5'd7)?  masterR6_we_o :
                                masterR7_we_o;
assign master_sel_o =
    (last_master_reg == 5'd1)?  masterP_sel_o :
    (last_master_reg == 5'd2)?  masterR1_sel_o :
    (last_master_reg == 5'd3)?  masterR2_sel_o :
    (last_master_reg == 5'd4)?  masterR3_sel_o :
    (last_master_reg == 5'd5)?  masterR4_sel_o :
    (last_master_reg == 5'd6)?  masterR5_sel_o :
    (last_master_reg == 5'd7)?  masterR6_sel_o :
                                masterR7_sel_o;
assign master_dat_o =
    (last_master_reg == 5'd1)?  masterP_dat_o :
    (last_master_reg == 5'd2)?  masterR1_dat_o :
    (last_master_reg == 5'd3)?  masterR2_dat_o :
    (last_master_reg == 5'd4)?  masterR3_dat_o :
    (last_master_reg == 5'd5)?  masterR4_dat_o :
    (last_master_reg == 5'd6)?  masterR5_dat_o :
    (last_master_reg == 5'd7)?  masterR6_dat_o :
                                masterR7_dat_o;
wire master_cyc_stb_o =
    (last_master_reg == 5'd1    && masterP_stb_o == 1'b1  && masterP_cyc_o == 1'b1) ||
    (last_master_reg == 5'd2    && masterR1_stb_o == 1'b1 && masterR1_cyc_o == 1'b1) ||
    (last_master_reg == 5'd3    && masterR2_stb_o == 1'b1 && masterR2_cyc_o == 1'b1) ||
    (last_master_reg == 5'd4    && masterR3_stb_o == 1'b1 && masterR3_cyc_o == 1'b1) ||
    (last_master_reg == 5'd5    && masterR4_stb_o == 1'b1 && masterR4_cyc_o == 1'b1) ||
    (last_master_reg == 5'd6    && masterR5_stb_o == 1'b1 && masterR5_cyc_o == 1'b1) ||
    (last_master_reg == 5'd7    && masterR6_stb_o == 1'b1 && masterR6_cyc_o == 1'b1) ||
    (last_master_reg == 5'd8    && masterR7_stb_o == 1'b1 && masterR7_cyc_o == 1'b1);

assign masterP_ack_i = master_ack_i && last_master_reg == 5'd1;
assign masterP_rty_i = master_rty_i && last_master_reg == 5'd1;
assign masterP_err_i = master_err_i && last_master_reg == 5'd1;

assign masterR1_ack_i = master_ack_i && last_master_reg == 5'd2;
assign masterR1_rty_i = master_rty_i && last_master_reg == 5'd2;
assign masterR1_err_i = master_err_i && last_master_reg == 5'd2;

assign masterR2_ack_i = master_ack_i && last_master_reg == 5'd3;
assign masterR2_rty_i = master_rty_i && last_master_reg == 5'd3;
assign masterR2_err_i = master_err_i && last_master_reg == 5'd3;

assign masterR3_ack_i = master_ack_i && last_master_reg == 5'd4;
assign masterR3_rty_i = master_rty_i && last_master_reg == 5'd4;
assign masterR3_err_i = master_err_i && last_master_reg == 5'd4;

assign masterR4_ack_i = master_ack_i && last_master_reg == 5'd5;
assign masterR4_rty_i = master_rty_i && last_master_reg == 5'd5;
assign masterR4_err_i = master_err_i && last_master_reg == 5'd5;

assign masterR5_ack_i = master_ack_i && last_master_reg == 5'd6;
assign masterR5_rty_i = master_rty_i && last_master_reg == 5'd6;
assign masterR5_err_i = master_err_i && last_master_reg == 5'd6;

assign masterR6_ack_i = master_ack_i && last_master_reg == 5'd7;
assign masterR6_rty_i = master_rty_i && last_master_reg == 5'd7;
assign masterR6_err_i = master_err_i && last_master_reg == 5'd7;

assign masterR7_ack_i = master_ack_i && last_master_reg == 5'd8;
assign masterR7_rty_i = master_rty_i && last_master_reg == 5'd8;
assign masterR7_err_i = master_err_i && last_master_reg == 5'd8;

wire slave0_selected = 
    slave1_selected == 1'b0 &&
    slave2_selected == 1'b0 &&
    slave3_selected == 1'b0 &&
    slave4_selected == 1'b0 &&
    slave5_selected == 1'b0 &&
    slave6_selected == 1'b0 &&
    slave7_selected == 1'b0 &&
    slave8_selected == 1'b0 &&
    slave9_selected == 1'b0 &&
    slave10_selected == 1'b0 &&
    slave11_selected == 1'b0 &&
    slave12_selected == 1'b0 &&
    slave13_selected == 1'b0 &&
    slave14_selected == 1'b0 &&
    slave15_selected == 1'b0;

assign { slave0_cyc_i, slave0_stb_i }   = { 2{(master_cyc_stb_o == 1'b1) && (slave0_selected == 1'b1)} };
assign { slave1_cyc_i, slave1_stb_i }   = { 2{(master_cyc_stb_o == 1'b1) && (slave1_selected == 1'b1)} };
assign { slave2_cyc_i, slave2_stb_i }   = { 2{(master_cyc_stb_o == 1'b1) && (slave2_selected == 1'b1)} };
assign { slave3_cyc_i, slave3_stb_i }   = { 2{(master_cyc_stb_o == 1'b1) && (slave3_selected == 1'b1)} };
assign { slave4_cyc_i, slave4_stb_i }   = { 2{(master_cyc_stb_o == 1'b1) && (slave4_selected == 1'b1)} };
assign { slave5_cyc_i, slave5_stb_i }   = { 2{(master_cyc_stb_o == 1'b1) && (slave5_selected == 1'b1)} };
assign { slave6_cyc_i, slave6_stb_i }   = { 2{(master_cyc_stb_o == 1'b1) && (slave6_selected == 1'b1)} };
assign { slave7_cyc_i, slave7_stb_i }   = { 2{(master_cyc_stb_o == 1'b1) && (slave7_selected == 1'b1)} };
assign { slave8_cyc_i, slave8_stb_i }   = { 2{(master_cyc_stb_o == 1'b1) && (slave8_selected == 1'b1)} };
assign { slave9_cyc_i, slave9_stb_i }   = { 2{(master_cyc_stb_o == 1'b1) && (slave9_selected == 1'b1)} };
assign { slave10_cyc_i, slave10_stb_i } = { 2{(master_cyc_stb_o == 1'b1) && (slave10_selected == 1'b1)} };
assign { slave11_cyc_i, slave11_stb_i } = { 2{(master_cyc_stb_o == 1'b1) && (slave11_selected == 1'b1)} };
assign { slave12_cyc_i, slave12_stb_i } = { 2{(master_cyc_stb_o == 1'b1) && (slave12_selected == 1'b1)} };
assign { slave13_cyc_i, slave13_stb_i } = { 2{(master_cyc_stb_o == 1'b1) && (slave13_selected == 1'b1)} };
assign { slave14_cyc_i, slave14_stb_i } = { 2{(master_cyc_stb_o == 1'b1) && (slave14_selected == 1'b1)} };
assign { slave15_cyc_i, slave15_stb_i } = { 2{(master_cyc_stb_o == 1'b1) && (slave15_selected == 1'b1)} };

assign slave_dat_o =
    (slave0_selected == 1'b1) ?     slave0_dat_o :
    (slave1_selected == 1'b1) ?     slave1_dat_o :
    (slave2_selected == 1'b1) ?     slave2_dat_o :
    (slave3_selected == 1'b1) ?     slave3_dat_o :
    (slave4_selected == 1'b1) ?     slave4_dat_o :
    (slave5_selected == 1'b1) ?     slave5_dat_o :
    (slave6_selected == 1'b1) ?     slave6_dat_o :
    (slave7_selected == 1'b1) ?     slave7_dat_o :
    (slave8_selected == 1'b1) ?     slave8_dat_o :
    (slave9_selected == 1'b1) ?     slave9_dat_o :
    (slave10_selected == 1'b1) ?    slave10_dat_o :
    (slave11_selected == 1'b1) ?    slave11_dat_o :
    (slave12_selected == 1'b1) ?    slave12_dat_o :
    (slave13_selected == 1'b1) ?    slave13_dat_o :
    (slave14_selected == 1'b1) ?    slave14_dat_o :
    slave15_dat_o;
    

wire master_ack_i = 
    (slave0_selected == 1'b1) ?     slave0_ack_o :
    (slave1_selected == 1'b1) ?     slave1_ack_o :
    (slave2_selected == 1'b1) ?     slave2_ack_o :
    (slave3_selected == 1'b1) ?     slave3_ack_o :
    (slave4_selected == 1'b1) ?     slave4_ack_o :
    (slave5_selected == 1'b1) ?     slave5_ack_o :
    (slave6_selected == 1'b1) ?     slave6_ack_o :
    (slave7_selected == 1'b1) ?     slave7_ack_o :
    (slave8_selected == 1'b1) ?     slave8_ack_o :
    (slave9_selected == 1'b1) ?     slave9_ack_o :
    (slave10_selected == 1'b1) ?    slave10_ack_o :
    (slave11_selected == 1'b1) ?    slave11_ack_o :
    (slave12_selected == 1'b1) ?    slave12_ack_o :
    (slave13_selected == 1'b1) ?    slave13_ack_o :
    (slave14_selected == 1'b1) ?    slave14_ack_o :
                                    slave15_ack_o;
wire master_rty_i = 
    (slave0_selected == 1'b1) ?     slave0_rty_o :
    (slave1_selected == 1'b1) ?     slave1_rty_o :
    (slave2_selected == 1'b1) ?     slave2_rty_o :
    (slave3_selected == 1'b1) ?     slave3_rty_o :
    (slave4_selected == 1'b1) ?     slave4_rty_o :
    (slave5_selected == 1'b1) ?     slave5_rty_o :
    (slave6_selected == 1'b1) ?     slave6_rty_o :
    (slave7_selected == 1'b1) ?     slave7_rty_o :
    (slave8_selected == 1'b1) ?     slave8_rty_o :
    (slave9_selected == 1'b1) ?     slave9_rty_o :
    (slave10_selected == 1'b1) ?    slave10_rty_o :
    (slave11_selected == 1'b1) ?    slave11_rty_o :
    (slave12_selected == 1'b1) ?    slave12_rty_o :
    (slave13_selected == 1'b1) ?    slave13_rty_o :
    (slave14_selected == 1'b1) ?    slave14_rty_o :
                                    slave15_rty_o;
wire master_err_i = 
    (slave0_selected == 1'b1) ?     slave0_err_o :
    (slave1_selected == 1'b1) ?     slave1_err_o :
    (slave2_selected == 1'b1) ?     slave2_err_o :
    (slave3_selected == 1'b1) ?     slave3_err_o :
    (slave4_selected == 1'b1) ?     slave4_err_o :
    (slave5_selected == 1'b1) ?     slave5_err_o :
    (slave6_selected == 1'b1) ?     slave6_err_o :
    (slave7_selected == 1'b1) ?     slave7_err_o :
    (slave8_selected == 1'b1) ?     slave8_err_o :
    (slave9_selected == 1'b1) ?     slave9_err_o :
    (slave10_selected == 1'b1) ?    slave10_err_o :
    (slave11_selected == 1'b1) ?    slave11_err_o :
    (slave12_selected == 1'b1) ?    slave12_err_o :
    (slave13_selected == 1'b1) ?    slave13_err_o :
    (slave14_selected == 1'b1) ?    slave14_err_o :
                                    slave15_err_o;

wire [4:0] last_master =
    (last_master_reg == 5'd0) ?
    (
        (halt_switch == 1'b1) ?                                                         5'd0 :
            (masterP_stb_o == 1'b1 && masterP_cyc_o == 1'b1) ?                          5'd1 :
        (masterR1_stb_o == 1'b1 && masterR1_cyc_o == 1'b1) ?                            5'd2 :
        (masterR2_stb_o == 1'b1 && masterR2_cyc_o == 1'b1) ?                            5'd3 :
        (masterR3_stb_o == 1'b1 && masterR3_cyc_o == 1'b1) ?                            5'd4 :
        (masterR4_stb_o == 1'b1 && masterR4_cyc_o == 1'b1) ?                            5'd5 :
        (masterR5_stb_o == 1'b1 && masterR5_cyc_o == 1'b1) ?                            5'd6 :
        (masterR6_stb_o == 1'b1 && masterR6_cyc_o == 1'b1) ?                            5'd7 :
        (masterR7_stb_o == 1'b1 && masterR7_cyc_o == 1'b1) ?                            5'd8 :
                                                                                        5'd0
    ) :
    
    (last_master_reg == 5'd1) ?
    (
        (master_cyc_stb_o == 1'b1) ?                                                    5'd1 :
        (halt_switch == 1'b1) ?                                                         5'd0 :
            (masterP_stb_o == 1'b1 && masterP_cyc_o == 1'b1) ?                          5'd1 :
        (masterR1_stb_o == 1'b1 && masterR1_cyc_o == 1'b1) ?                            5'd2 :
        (masterR2_stb_o == 1'b1 && masterR2_cyc_o == 1'b1) ?                            5'd3 :
        (masterR3_stb_o == 1'b1 && masterR3_cyc_o == 1'b1) ?                            5'd4 :
        (masterR4_stb_o == 1'b1 && masterR4_cyc_o == 1'b1) ?                            5'd5 :
        (masterR5_stb_o == 1'b1 && masterR5_cyc_o == 1'b1) ?                            5'd6 :
        (masterR6_stb_o == 1'b1 && masterR6_cyc_o == 1'b1) ?                            5'd7 :
        (masterR7_stb_o == 1'b1 && masterR7_cyc_o == 1'b1) ?                            5'd8 :
                                                                                        5'd1
    ) :
    
    (last_master_reg == 5'd2) ?
    (
        (master_cyc_stb_o == 1'b1) ?                                                    5'd2 :
        (halt_switch == 1'b1) ?                                                         5'd0 :
            (masterP_stb_o == 1'b1 && masterP_cyc_o == 1'b1) ?                          5'd1 :
        (masterR2_stb_o == 1'b1 && masterR2_cyc_o == 1'b1) ?                            5'd3 :
        (masterR3_stb_o == 1'b1 && masterR3_cyc_o == 1'b1) ?                            5'd4 :
        (masterR4_stb_o == 1'b1 && masterR4_cyc_o == 1'b1) ?                            5'd5 :
        (masterR5_stb_o == 1'b1 && masterR5_cyc_o == 1'b1) ?                            5'd6 :
        (masterR6_stb_o == 1'b1 && masterR6_cyc_o == 1'b1) ?                            5'd7 :
        (masterR7_stb_o == 1'b1 && masterR7_cyc_o == 1'b1) ?                            5'd8 :
        (masterR1_stb_o == 1'b1 && masterR1_cyc_o == 1'b1) ?                            5'd2 :
                                                                                        5'd2
    ) :
    
    (last_master_reg == 5'd3) ?
    (
        (master_cyc_stb_o == 1'b1) ?                                                    5'd3 :
        (halt_switch == 1'b1) ?                                                         5'd0 :
            (masterP_stb_o == 1'b1 && masterP_cyc_o == 1'b1) ?                          5'd1 :
        (masterR3_stb_o == 1'b1 && masterR3_cyc_o == 1'b1) ?                            5'd4 :
        (masterR4_stb_o == 1'b1 && masterR4_cyc_o == 1'b1) ?                            5'd5 :
        (masterR5_stb_o == 1'b1 && masterR5_cyc_o == 1'b1) ?                            5'd6 :
        (masterR6_stb_o == 1'b1 && masterR6_cyc_o == 1'b1) ?                            5'd7 :
        (masterR7_stb_o == 1'b1 && masterR7_cyc_o == 1'b1) ?                            5'd8 :
        (masterR1_stb_o == 1'b1 && masterR1_cyc_o == 1'b1) ?                            5'd2 :
        (masterR2_stb_o == 1'b1 && masterR2_cyc_o == 1'b1) ?                            5'd3 :
                                                                                        5'd3
    ) :
    
    (last_master_reg == 5'd4) ?
    (
        (master_cyc_stb_o == 1'b1) ?                                                    5'd4 :
        (halt_switch == 1'b1) ?                                                         5'd0 :
            (masterP_stb_o == 1'b1 && masterP_cyc_o == 1'b1) ?                          5'd1 :
        (masterR4_stb_o == 1'b1 && masterR4_cyc_o == 1'b1) ?                            5'd5 :
        (masterR5_stb_o == 1'b1 && masterR5_cyc_o == 1'b1) ?                            5'd6 :
        (masterR6_stb_o == 1'b1 && masterR6_cyc_o == 1'b1) ?                            5'd7 :
        (masterR7_stb_o == 1'b1 && masterR7_cyc_o == 1'b1) ?                            5'd8 :
        (masterR1_stb_o == 1'b1 && masterR1_cyc_o == 1'b1) ?                            5'd2 :
        (masterR2_stb_o == 1'b1 && masterR2_cyc_o == 1'b1) ?                            5'd3 :
        (masterR3_stb_o == 1'b1 && masterR3_cyc_o == 1'b1) ?                            5'd4 :
                                                                                        5'd4
    ) :
    
    (last_master_reg == 5'd5) ?
    (
        (master_cyc_stb_o == 1'b1) ?                                                    5'd5 :
        (halt_switch == 1'b1) ?                                                         5'd0 :
            (masterP_stb_o == 1'b1 && masterP_cyc_o == 1'b1) ?                          5'd1 :
        (masterR5_stb_o == 1'b1 && masterR5_cyc_o == 1'b1) ?                            5'd6 :
        (masterR6_stb_o == 1'b1 && masterR6_cyc_o == 1'b1) ?                            5'd7 :
        (masterR7_stb_o == 1'b1 && masterR7_cyc_o == 1'b1) ?                            5'd8 :
        (masterR1_stb_o == 1'b1 && masterR1_cyc_o == 1'b1) ?                            5'd2 :
        (masterR2_stb_o == 1'b1 && masterR2_cyc_o == 1'b1) ?                            5'd3 :
        (masterR3_stb_o == 1'b1 && masterR3_cyc_o == 1'b1) ?                            5'd4 :
        (masterR4_stb_o == 1'b1 && masterR4_cyc_o == 1'b1) ?                            5'd5 :
                                                                                        5'd5
    ) :
    
    (last_master_reg == 5'd6) ?
    (
        (master_cyc_stb_o == 1'b1) ?                                                    5'd6 :
        (halt_switch == 1'b1) ?                                                         5'd0 :
            (masterP_stb_o == 1'b1 && masterP_cyc_o == 1'b1) ?                          5'd1 :
        (masterR6_stb_o == 1'b1 && masterR6_cyc_o == 1'b1) ?                            5'd7 :
        (masterR7_stb_o == 1'b1 && masterR7_cyc_o == 1'b1) ?                            5'd8 :
        (masterR1_stb_o == 1'b1 && masterR1_cyc_o == 1'b1) ?                            5'd2 :
        (masterR2_stb_o == 1'b1 && masterR2_cyc_o == 1'b1) ?                            5'd3 :
        (masterR3_stb_o == 1'b1 && masterR3_cyc_o == 1'b1) ?                            5'd4 :
        (masterR4_stb_o == 1'b1 && masterR4_cyc_o == 1'b1) ?                            5'd5 :
        (masterR5_stb_o == 1'b1 && masterR5_cyc_o == 1'b1) ?                            5'd6 :
                                                                                        5'd6
    ) :
    
    (last_master_reg == 5'd7) ?
    (
        (master_cyc_stb_o == 1'b1) ?                                                    5'd7 :
        (halt_switch == 1'b1) ?                                                         5'd0 :
            (masterP_stb_o == 1'b1 && masterP_cyc_o == 1'b1) ?                          5'd1 :
        (masterR7_stb_o == 1'b1 && masterR7_cyc_o == 1'b1) ?                            5'd8 :
        (masterR1_stb_o == 1'b1 && masterR1_cyc_o == 1'b1) ?                            5'd2 :
        (masterR2_stb_o == 1'b1 && masterR2_cyc_o == 1'b1) ?                            5'd3 :
        (masterR3_stb_o == 1'b1 && masterR3_cyc_o == 1'b1) ?                            5'd4 :
        (masterR4_stb_o == 1'b1 && masterR4_cyc_o == 1'b1) ?                            5'd5 :
        (masterR5_stb_o == 1'b1 && masterR5_cyc_o == 1'b1) ?                            5'd6 :
        (masterR6_stb_o == 1'b1 && masterR6_cyc_o == 1'b1) ?                            5'd7 :
                                                                                        5'd7
    ) :
    
    (last_master_reg == 5'd8) ?
    (
        (master_cyc_stb_o == 1'b1) ?                                                    5'd8 :
        (halt_switch == 1'b1) ?                                                         5'd0 :
            (masterP_stb_o == 1'b1 && masterP_cyc_o == 1'b1) ?                          5'd1 :
        (masterR1_stb_o == 1'b1 && masterR1_cyc_o == 1'b1) ?                            5'd2 :
        (masterR2_stb_o == 1'b1 && masterR2_cyc_o == 1'b1) ?                            5'd3 :
        (masterR3_stb_o == 1'b1 && masterR3_cyc_o == 1'b1) ?                            5'd4 :
        (masterR4_stb_o == 1'b1 && masterR4_cyc_o == 1'b1) ?                            5'd5 :
        (masterR5_stb_o == 1'b1 && masterR5_cyc_o == 1'b1) ?                            5'd6 :
        (masterR6_stb_o == 1'b1 && masterR6_cyc_o == 1'b1) ?                            5'd7 :
        (masterR7_stb_o == 1'b1 && masterR7_cyc_o == 1'b1) ?                            5'd8 :
                                                                                        5'd8
    ) :
    
    5'd0;
    
reg [4:0] last_master_reg;

always @(posedge CLK_I or negedge reset_n) begin
    if(reset_n == 1'b0) last_master_reg <= 5'd0;
    else                last_master_reg <= last_master;
end

endmodule

