//////////////////////////////////////////////////////////////////
//                                                              //
//  Register Bank for Amber Core                                //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Contains 37 32-bit registers, 16 of which are visible       //
//  ina any one operating mode. Registers use real flipflops,   //
//  rather than SRAM. This makes sense for an FPGA              //
//  implementation, where flipflops are plentiful.              //
//                                                              //
//  Author(s):                                                  //
//      - Conor Santifort, csantifort.amber@gmail.com           //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2010 Authors and OPENCORES.ORG                 //
//                                                              //
// This source file may be used and distributed without         //
// restriction provided that this copyright statement is not    //
// removed from the file and that any derivative work contains  //
// the original copyright notice and the associated disclaimer. //
//                                                              //
// This source file is free software; you can redistribute it   //
// and/or modify it under the terms of the GNU Lesser General   //
// Public License as published by the Free Software Foundation; //
// either version 2.1 of the License, or (at your option) any   //
// later version.                                               //
//                                                              //
// This source is distributed in the hope that it will be       //
// useful, but WITHOUT ANY WARRANTY; without even the implied   //
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //
// PURPOSE.  See the GNU Lesser General Public License for more //
// details.                                                     //
//                                                              //
// You should have received a copy of the GNU Lesser General    //
// Public License along with this source; if not, download it   //
// from http://www.opencores.org/lgpl.shtml                     //
//                                                              //
//////////////////////////////////////////////////////////////////

module a23_register_bank (

input                       i_clk,
input                       i_fetch_stall,

input       [1:0]           i_mode_idec,            // user, supervisor, irq_idec, firq_idec etc.
                                                    // Used for register writes
input       [1:0]           i_mode_exec,            // 1 periods delayed from i_mode_idec
                                                    // Used for register reads
input       [3:0]           i_mode_rds_exec,        // Use one-hot version specifically for rds, 
                                                    // includes i_user_mode_regs_store
input                       i_user_mode_regs_load,
input                       i_firq_not_user_mode,
input       [3:0]           i_rm_sel,
input       [3:0]           i_rds_sel,
input       [3:0]           i_rn_sel,

input                       i_pc_wen,
input       [14:0]          i_reg_bank_wen,

input       [23:0]          i_pc,                   // program counter [25:2]
input       [31:0]          i_reg,

input       [3:0]           i_status_bits_flags,
input                       i_status_bits_irq_mask,
input                       i_status_bits_firq_mask,

output      [31:0]          o_rm,
output reg  [31:0]          o_rs,
output reg  [31:0]          o_rd,
output      [31:0]          o_rn,
output      [31:0]          o_pc

);

`include "a23_localparams.vh"
`include "a23_functions.vh"


// User Mode Registers
reg  [31:0] r0  = 32'hdead_beef;
reg  [31:0] r1  = 32'hdead_beef;
reg  [31:0] r2  = 32'hdead_beef;
reg  [31:0] r3  = 32'hdead_beef;
reg  [31:0] r4  = 32'hdead_beef;
reg  [31:0] r5  = 32'hdead_beef;
reg  [31:0] r6  = 32'hdead_beef;
reg  [31:0] r7  = 32'hdead_beef;
reg  [31:0] r8  = 32'hdead_beef;
reg  [31:0] r9  = 32'hdead_beef;
reg  [31:0] r10 = 32'hdead_beef;
reg  [31:0] r11 = 32'hdead_beef;
reg  [31:0] r12 = 32'hdead_beef;
reg  [31:0] r13 = 32'hdead_beef;
reg  [31:0] r14 = 32'hdead_beef;
reg  [23:0] r15 = 24'hc0_ffee;

wire  [31:0] r0_out;
wire  [31:0] r1_out;
wire  [31:0] r2_out;
wire  [31:0] r3_out;
wire  [31:0] r4_out;
wire  [31:0] r5_out;
wire  [31:0] r6_out;
wire  [31:0] r7_out;
wire  [31:0] r8_out;
wire  [31:0] r9_out;
wire  [31:0] r10_out;
wire  [31:0] r11_out;
wire  [31:0] r12_out;
wire  [31:0] r13_out;
wire  [31:0] r14_out;
wire  [31:0] r15_out_rm;
wire  [31:0] r15_out_rm_nxt;
wire  [31:0] r15_out_rn;

wire  [31:0] r8_rds;
wire  [31:0] r9_rds;
wire  [31:0] r10_rds;
wire  [31:0] r11_rds;
wire  [31:0] r12_rds;
wire  [31:0] r13_rds;
wire  [31:0] r14_rds;

// Supervisor Mode Registers
reg  [31:0] r13_svc = 32'hdead_beef;
reg  [31:0] r14_svc = 32'hdead_beef;

// Interrupt Mode Registers
reg  [31:0] r13_irq = 32'hdead_beef;
reg  [31:0] r14_irq = 32'hdead_beef;

// Fast Interrupt Mode Registers
reg  [31:0] r8_firq  = 32'hdead_beef;
reg  [31:0] r9_firq  = 32'hdead_beef;
reg  [31:0] r10_firq = 32'hdead_beef;
reg  [31:0] r11_firq = 32'hdead_beef;
reg  [31:0] r12_firq = 32'hdead_beef;
reg  [31:0] r13_firq = 32'hdead_beef;
reg  [31:0] r14_firq = 32'hdead_beef;

wire        usr_exec;
wire        svc_exec;
wire        irq_exec;
wire        firq_exec;

wire        usr_idec;
wire        svc_idec;
wire        irq_idec;
wire        firq_idec;

    // Write Enables from execute stage
assign usr_idec  =  i_user_mode_regs_load || i_mode_idec == USR;
assign svc_idec  = !i_user_mode_regs_load && i_mode_idec == SVC;
assign irq_idec  = !i_user_mode_regs_load && i_mode_idec == IRQ;

// pre-encoded in decode stage to speed up long path
assign firq_idec = i_firq_not_user_mode;

    // Read Enables from stage 1 (fetch)
assign usr_exec  = i_mode_exec == USR;
assign svc_exec  = i_mode_exec == SVC;
assign irq_exec  = i_mode_exec == IRQ;
assign firq_exec = i_mode_exec == FIRQ;


// ========================================================
// Register Update
// ========================================================
always @ ( posedge i_clk )
    if (!i_fetch_stall)
        begin
        r0       <=  i_reg_bank_wen[0 ]              ? i_reg : r0;  
        r1       <=  i_reg_bank_wen[1 ]              ? i_reg : r1;  
        r2       <=  i_reg_bank_wen[2 ]              ? i_reg : r2;  
        r3       <=  i_reg_bank_wen[3 ]              ? i_reg : r3;  
        r4       <=  i_reg_bank_wen[4 ]              ? i_reg : r4;  
        r5       <=  i_reg_bank_wen[5 ]              ? i_reg : r5;  
        r6       <=  i_reg_bank_wen[6 ]              ? i_reg : r6;  
        r7       <=  i_reg_bank_wen[7 ]              ? i_reg : r7;  
        
        r8       <= (i_reg_bank_wen[8 ] && !firq_idec) ? i_reg : r8;  
        r9       <= (i_reg_bank_wen[9 ] && !firq_idec) ? i_reg : r9;  
        r10      <= (i_reg_bank_wen[10] && !firq_idec) ? i_reg : r10; 
        r11      <= (i_reg_bank_wen[11] && !firq_idec) ? i_reg : r11; 
        r12      <= (i_reg_bank_wen[12] && !firq_idec) ? i_reg : r12; 
        
        r8_firq  <= (i_reg_bank_wen[8 ] &&  firq_idec) ? i_reg : r8_firq;
        r9_firq  <= (i_reg_bank_wen[9 ] &&  firq_idec) ? i_reg : r9_firq;
        r10_firq <= (i_reg_bank_wen[10] &&  firq_idec) ? i_reg : r10_firq;
        r11_firq <= (i_reg_bank_wen[11] &&  firq_idec) ? i_reg : r11_firq;
        r12_firq <= (i_reg_bank_wen[12] &&  firq_idec) ? i_reg : r12_firq;

        r13      <= (i_reg_bank_wen[13] &&  usr_idec)  ? i_reg : r13;
        r14      <= (i_reg_bank_wen[14] &&  usr_idec)  ? i_reg : r14;
     
        r13_svc  <= (i_reg_bank_wen[13] &&  svc_idec)  ? i_reg : r13_svc;
        r14_svc  <= (i_reg_bank_wen[14] &&  svc_idec)  ? i_reg : r14_svc;   
       
        r13_irq  <= (i_reg_bank_wen[13] &&  irq_idec)  ? i_reg : r13_irq;
        r14_irq  <= (i_reg_bank_wen[14] &&  irq_idec)  ? i_reg : r14_irq;       
      
        r13_firq <= (i_reg_bank_wen[13] &&  firq_idec) ? i_reg : r13_firq;
        r14_firq <= (i_reg_bank_wen[14] &&  firq_idec) ? i_reg : r14_firq;  
        
        r15      <=  i_pc_wen                          ?  i_pc : r15;
        end
    
    
// ========================================================
// Register Read based on Mode
// ========================================================
assign r0_out = r0;
assign r1_out = r1;
assign r2_out = r2;
assign r3_out = r3;
assign r4_out = r4;
assign r5_out = r5;
assign r6_out = r6;
assign r7_out = r7;

assign r8_out  = firq_exec ? r8_firq  : r8;
assign r9_out  = firq_exec ? r9_firq  : r9;
assign r10_out = firq_exec ? r10_firq : r10;
assign r11_out = firq_exec ? r11_firq : r11;
assign r12_out = firq_exec ? r12_firq : r12;

assign r13_out = usr_exec ? r13      :
                 svc_exec ? r13_svc  :
                 irq_exec ? r13_irq  :
                          r13_firq ;
                       
assign r14_out = usr_exec ? r14      :
                 svc_exec ? r14_svc  :
                 irq_exec ? r14_irq  :
                          r14_firq ;
 

assign r15_out_rm     = { i_status_bits_flags, 
                          i_status_bits_irq_mask, 
                          i_status_bits_firq_mask, 
                          r15, 
                          i_mode_exec};

assign r15_out_rm_nxt = { i_status_bits_flags, 
                          i_status_bits_irq_mask, 
                          i_status_bits_firq_mask, 
                          i_pc, 
                          i_mode_exec};
                      
assign r15_out_rn     = {6'd0, r15, 2'd0};


// rds outputs
assign r8_rds  = i_mode_rds_exec[OH_FIRQ] ? r8_firq  : r8;
assign r9_rds  = i_mode_rds_exec[OH_FIRQ] ? r9_firq  : r9;
assign r10_rds = i_mode_rds_exec[OH_FIRQ] ? r10_firq : r10;
assign r11_rds = i_mode_rds_exec[OH_FIRQ] ? r11_firq : r11;
assign r12_rds = i_mode_rds_exec[OH_FIRQ] ? r12_firq : r12;

assign r13_rds = i_mode_rds_exec[OH_USR]  ? r13      :
                 i_mode_rds_exec[OH_SVC]  ? r13_svc  :
                 i_mode_rds_exec[OH_IRQ]  ? r13_irq  :
                                            r13_firq ;
                       
assign r14_rds = i_mode_rds_exec[OH_USR]  ? r14      :
                 i_mode_rds_exec[OH_SVC]  ? r14_svc  :
                 i_mode_rds_exec[OH_IRQ]  ? r14_irq  :
                                            r14_firq ;

// ========================================================
// Program Counter out
// ========================================================
assign o_pc = r15_out_rn;

// ========================================================
// Rm Selector
// ========================================================
assign o_rm = i_rm_sel == 4'd0  ? r0_out  :
              i_rm_sel == 4'd1  ? r1_out  : 
              i_rm_sel == 4'd2  ? r2_out  : 
              i_rm_sel == 4'd3  ? r3_out  : 
              i_rm_sel == 4'd4  ? r4_out  : 
              i_rm_sel == 4'd5  ? r5_out  : 
              i_rm_sel == 4'd6  ? r6_out  : 
              i_rm_sel == 4'd7  ? r7_out  : 
              i_rm_sel == 4'd8  ? r8_out  : 
              i_rm_sel == 4'd9  ? r9_out  : 
              i_rm_sel == 4'd10 ? r10_out : 
              i_rm_sel == 4'd11 ? r11_out : 
              i_rm_sel == 4'd12 ? r12_out : 
              i_rm_sel == 4'd13 ? r13_out : 
              i_rm_sel == 4'd14 ? r14_out : 
                                  r15_out_rm ; 




// ========================================================
// Rds Selector
// ========================================================
always @*
    case (i_rds_sel)
       4'd0  :  o_rs = r0_out  ;
       4'd1  :  o_rs = r1_out  ; 
       4'd2  :  o_rs = r2_out  ; 
       4'd3  :  o_rs = r3_out  ; 
       4'd4  :  o_rs = r4_out  ; 
       4'd5  :  o_rs = r5_out  ; 
       4'd6  :  o_rs = r6_out  ; 
       4'd7  :  o_rs = r7_out  ; 
       4'd8  :  o_rs = r8_rds  ; 
       4'd9  :  o_rs = r9_rds  ; 
       4'd10 :  o_rs = r10_rds ; 
       4'd11 :  o_rs = r11_rds ; 
       4'd12 :  o_rs = r12_rds ; 
       4'd13 :  o_rs = r13_rds ; 
       4'd14 :  o_rs = r14_rds ; 
       default: o_rs = r15_out_rn ; 
    endcase

                                    

// ========================================================
// Rd Selector
// ========================================================
always @*
    case (i_rds_sel)
       4'd0  :  o_rd = r0_out  ;
       4'd1  :  o_rd = r1_out  ; 
       4'd2  :  o_rd = r2_out  ; 
       4'd3  :  o_rd = r3_out  ; 
       4'd4  :  o_rd = r4_out  ; 
       4'd5  :  o_rd = r5_out  ; 
       4'd6  :  o_rd = r6_out  ; 
       4'd7  :  o_rd = r7_out  ; 
       4'd8  :  o_rd = r8_rds  ; 
       4'd9  :  o_rd = r9_rds  ; 
       4'd10 :  o_rd = r10_rds ; 
       4'd11 :  o_rd = r11_rds ; 
       4'd12 :  o_rd = r12_rds ; 
       4'd13 :  o_rd = r13_rds ; 
       4'd14 :  o_rd = r14_rds ; 
       default: o_rd = r15_out_rm_nxt ; 
    endcase

                                    
// ========================================================
// Rn Selector
// ========================================================
assign o_rn = i_rn_sel == 4'd0  ? r0_out  :
              i_rn_sel == 4'd1  ? r1_out  : 
              i_rn_sel == 4'd2  ? r2_out  : 
              i_rn_sel == 4'd3  ? r3_out  : 
              i_rn_sel == 4'd4  ? r4_out  : 
              i_rn_sel == 4'd5  ? r5_out  : 
              i_rn_sel == 4'd6  ? r6_out  : 
              i_rn_sel == 4'd7  ? r7_out  : 
              i_rn_sel == 4'd8  ? r8_out  : 
              i_rn_sel == 4'd9  ? r9_out  : 
              i_rn_sel == 4'd10 ? r10_out : 
              i_rn_sel == 4'd11 ? r11_out : 
              i_rn_sel == 4'd12 ? r12_out : 
              i_rn_sel == 4'd13 ? r13_out : 
              i_rn_sel == 4'd14 ? r14_out : 
                                  r15_out_rn ; 


endmodule


