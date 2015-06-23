////////////////////////////////////////////////////////////////////
//     --------------                                             //
//    /      SOC     \                                            //
//   /       GEN      \                                           //
//  /     COMPONENT    \                                          //
//  ====================                                          //
//  |digital done right|                                          //
//  |__________________|                                          //
//                                                                //
//                                                                //
//                                                                //
//    Copyright (C) <2010>  <Ouabache DesignWorks>                //
//                                                                //
//                                                                //  
//   This source file may be used and distributed without         //  
//   restriction provided that this copyright statement is not    //  
//   removed from the file and that any derivative work contains  //  
//   the original copyright notice and the associated disclaimer. //  
//                                                                //  
//   This source file is free software; you can redistribute it   //  
//   and/or modify it under the terms of the GNU Lesser General   //  
//   Public License as published by the Free Software Foundation; //  
//   either version 2.1 of the License, or (at your option) any   //  
//   later version.                                               //  
//                                                                //  
//   This source is distributed in the hope that it will be       //  
//   useful, but WITHOUT ANY WARRANTY; without even the implied   //  
//   warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //  
//   PURPOSE.  See the GNU Lesser General Public License for more //  
//   details.                                                     //  
//                                                                //  
//   You should have received a copy of the GNU Lesser General    //  
//   Public License along with this source; if not, download it   //  
//   from http://www.opencores.org/lgpl.shtml                     //  
//                                                                //  
////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////									////
//// T6507LP IP Core	 						////
////									////
//// This file is part of the T6507LP project				////
//// http://www.opencores.org/cores/t6507lp/				////
////									////
//// Description							////
//// Implementation of a 6507-compatible microprocessor			////
////									////
//// To Do:								////
//// - Everything							////
////									////
//// Author(s):								////
//// - Gabriel Oshiro Zardo, gabrieloshiro@gmail.com			////
//// - Samuel Nascimento Pagliarini (creep), snpagliarini@gmail.com	////
////									////
////////////////////////////////////////////////////////////////////////////
////									////
//// Copyright (C) 2001 Authors and OPENCORES.ORG			////
////									////
//// This source file may be used and distributed without		////
//// restriction provided that this copyright statement is not		////
//// removed from the file and that any derivative work contains	////
//// the original copyright notice and the associated disclaimer.	////
////									////
//// This source file is free software; you can redistribute it		////
//// and/or modify it under the terms of the GNU Lesser General		////
//// Public License as published by the Free Software Foundation;	////
//// either version 2.1 of the License, or (at your option) any		////
//// later version.							////
////									////
//// This source is distributed in the hope that it will be		////
//// useful, but WITHOUT ANY WARRANTY; without even the implied		////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR		////
//// PURPOSE. See the GNU Lesser General Public License for more	////
//// details.								////
////									////
//// You should have received a copy of the GNU Lesser General		////
//// Public License along with this source; if not, download it		////
//// from http://www.opencores.org/lgpl.shtml				////
////									////
////////////////////////////////////////////////////////////////////////////
// alu_mode
// alu_op_a_sel
// alu_op_b_sel
// alu_op_b_inv
// alu_op_c_sel
// alu_status_update
// dest
// ctrl
// cmd
// ins_type
// idx_sel
////////////////////////////////////////////////////////////////////////////
////									////
////			Processor Status Register			////
////									////
////////////////////////////////////////////////////////////////////////////
////									////
//// C - Carry Flag							////
//// Z - Zero Flag							////
//// I - Interrupt Disable						////
//// D - Decimal Mode							////
//// B - Break Command							////
//// 1 - Constant One							////
//// V - oVerflow Flag							////
//// N - Negative Flag							////
////									////
////////////////////////////////////////////////////////////////////////////
////									////
////	    -------------------------------------------------		////
////	    |  N  |  V  |  1  |  B  |  D  |  I  |  Z  |  C  |		////
////	    -------------------------------------------------		////
////									////
////////////////////////////////////////////////////////////////////////////
 module 
  core_def 
    #( parameter 
      BOOT_VEC=8'hfc,
      VEC_TABLE=8'hff)
     (
 input   wire                 clk,
 input   wire                 enable,
 input   wire                 nmi,
 input   wire                 reset,
 input   wire    [ 15 :  0]        prog_data,
 input   wire    [ 15 :  0]        rdata,
 input   wire    [ 15 :  0]        stk_pull_data,
 input   wire    [ 7 :  0]        pg0_data,
 input   wire    [ 7 :  0]        vec_int,
 output   wire                 pg0_rd,
 output   wire                 pg0_wr,
 output   wire                 rd,
 output   wire                 stk_pull,
 output   wire                 stk_push,
 output   wire                 wr,
 output   wire    [ 15 :  0]        addr,
 output   wire    [ 15 :  0]        prog_counter,
 output   wire    [ 15 :  0]        stk_push_data,
 output   wire    [ 7 :  0]        alu_status,
 output   wire    [ 7 :  0]        pg0_add,
 output   wire    [ 7 :  0]        wdata);
reg [7*8-1:0]  A_instr;
reg [10*8-1:0] A_state;
reg [3*8-1:0]  A_alu_mode;
reg [3*8-1:0]  A_alu_op_a_sel;
reg [3*8-1:0]  A_alu_op_b_inv;
reg [3*8-1:0]  A_alu_op_b_sel;
reg [3*8-1:0]  A_alu_op_c_sel;
reg [4*8-1:0]  A_alu_status_update;
reg [3*8-1:0]  A_dest;
reg [7*8-1:0]  A_ctrl;
reg [8*8-1:0]  A_cmd;
reg [5*8-1:0]  A_ins_type;
reg [3*8-1:0]  A_idx_sel;      
   always@(posedge clk) 
    begin
    if (enable && now_fetch_op)
       begin
        if(prog_counter[0])
         begin
         $display("%t  %h   %h     %h",$realtime,prog_counter,prog_data[15:8],addr);
         end
        else
         begin
         $display("%t  %h   %h     %h",$realtime,prog_counter,prog_data[7:0],addr);
         end
       end
    end
always @(*) begin
   case  (state)
      4'b0100:     A_state = "FETCH_OP  ";
       4'b0101:     A_state = "EXECUTE   ";
         4'b0110:     A_state = "EXE_1     ";
         4'b0011:     A_state = "AXE_1     ";
         4'b0111:     A_state = "AXE_2     ";     
         4'b1000:     A_state = "IDX_1     ";
         4'b1001:     A_state = "IDX_2     ";
         4'b1010:     A_state = "IDX_3     ";
         4'b1011:     A_state = "IDY_1     ";
         4'b1100:     A_state = "IDY_2     ";
         4'b1101:     A_state = "IDY_3     ";
         4'b0000:     A_state = "RESET     ";
          4'b0001:     A_state = "HALT      ";
         4'b1111:     A_state = "INT_2     ";
         4'b1110:     A_state = "INT_1     ";
        default:     A_state = "-XXXXXXXX-";                
   endcase    
end
always @(*) begin
   case  (ir)
     8'h69:
      begin
      A_instr = "ADC_IMM";
      end
     8'h65:
      begin
      A_instr = "ADC_ZPG";
      end 
     8'h75:
      begin
      A_instr = "ADC_ZPX";
      end 
     8'h6D:
      begin
      A_instr = "ADC_ABS";
      end 
     8'h7D:
      begin
      A_instr = "ADC_ABX";
      end 
     8'h79:
      begin
      A_instr = "ADC_ABY";
      end 
     8'h61:
      begin
      A_instr = "ADC_IDX";
      end 
     8'h71:
      begin
      A_instr = "ADC_IDY";
      end 
     8'h29:
      begin
      A_instr = "AND_IMM";
      end 
     8'h25:
      begin
      A_instr = "AND_ZPG";
      end 
     8'h35:
      begin
      A_instr = "AND_ZPX";
      end 
     8'h2D:
      begin
      A_instr = "AND_ABS";
      end 
     8'h3D:
      begin
      A_instr = "AND_ABX";
      end 
     8'h39:
      begin
      A_instr = "AND_ABY";
      end 
     8'h21:
      begin
      A_instr = "AND_IDX";
      end 
     8'h31:
      begin
      A_instr = "AND_IDY";
      end 
     8'h0A:
      begin
      A_instr = "ASL_ACC";
      end 
     8'h06:
      begin
      A_instr = "ASL_ZPG";
      end 
     8'h16:
      begin
      A_instr = "ASL_ZPX";
      end 
     8'h0E:
      begin
      A_instr = "ASL_ABS";
      end 
     8'h1E:
      begin
      A_instr = "ASL_ABX";
      end 
     8'h90:
      begin
      A_instr = "BCC_REL";
      end 
     8'hB0:
      begin
      A_instr = "BCS_REL";
      end 
     8'hF0:
      begin
      A_instr = "BEQ_REL";
      end 
     8'h24:
      begin
      A_instr = "BIT_ZPG";
      end 
     8'h2C:
      begin
      A_instr = "BIT_ABS";
      end 
     8'h30:
      begin
      A_instr = "BMI_REL";
      end 
     8'hD0:
      begin
      A_instr = "BNE_REL";
      end 
     8'h10:
      begin
      A_instr = "BPL_REL";
      end 
     8'h00:
      begin
      A_instr = "BRK_IMP";
      end 
     8'h50:
      begin
      A_instr = "BVC_REL";
      end 
     8'h70:
      begin
      A_instr = "BVS_REL";
      end 
     8'h18:
      begin
      A_instr = "CLC_IMP";
      end 
     8'hD8:
      begin
      A_instr = "CLD_IMP";
      end 
     8'h58:
      begin
      A_instr = "CLI_IMP";
      end 
     8'hB8:
      begin
      A_instr = "CLV_IMP";
      end 
     8'hC9:
      begin
      A_instr = "CMP_IMM";
      end 
     8'hC5:
      begin
      A_instr = "CMP_ZPG";
      end 
     8'hD5:
      begin
      A_instr = "CMP_ZPX";
      end 
     8'hCD:
      begin
      A_instr = "CMP_ABS";
      end 
     8'hDD:
      begin
      A_instr = "CMP_ABX";
      end 
     8'hD9:
      begin
      A_instr = "CMP_ABY";
      end 
     8'hC1:
      begin
      A_instr = "CMP_IDX";
      end 
     8'hD1:
      begin
      A_instr = "CMP_IDY";
      end 
     8'hE0:
      begin
      A_instr = "CPX_IMM";
      end 
     8'hE4:
      begin
      A_instr = "CPX_ZPG";
      end 
     8'hEC:
      begin
      A_instr = "CPX_ABS";
      end 
     8'hC0:
      begin
      A_instr = "CPY_IMM";
      end 
     8'hC4:
      begin
      A_instr = "CPY_ZPG";
      end 
     8'hCC:
      begin
      A_instr = "CPY_ABS";
      end 
     8'hC6:
      begin
      A_instr = "DEC_ZPG";
      end
     8'hD6:
      begin
      A_instr = "DEC_ZPX";
      end 
     8'hCE:
      begin
      A_instr = "DEC_ABS";
      end 
     8'hDE:
      begin
      A_instr = "DEC_ABX";
      end 
     8'hCA:
      begin
      A_instr = "DEX_IMP";
      end 
     8'h88:
      begin
      A_instr = "DEY_IMP";
      end 
     8'h49:
      begin
      A_instr = "EOR_IMM";
      end 
     8'h45:
      begin
      A_instr = "EOR_ZPG";
      end 
     8'h55:
      begin
      A_instr = "EOR_ZPX";
      end 
     8'h4D:
      begin
      A_instr = "EOR_ABS";
      end 
     8'h5D:
      begin
      A_instr = "EOR_ABX";
      end 
     8'h59:
      begin
      A_instr = "EOR_ABY";
      end 
     8'h41:
      begin
      A_instr = "EOR_IDX";
      end 
     8'h51:
      begin
      A_instr = "EOR_IDY";
      end 
     8'hE6:
      begin
      A_instr = "INC_ZPG";
      end 
     8'hF6:
      begin
      A_instr = "INC_ZPX";
      end 
     8'hEE:
      begin
      A_instr = "INC_ABS";
      end 
     8'hFE:
      begin
      A_instr = "INC_ABX";
      end 
     8'hE8:
      begin
      A_instr = "INX_IMP";
      end 
     8'hC8:
      begin
      A_instr = "INY_IMP";
      end 
     8'h4C:
      begin
      A_instr = "JMP_ABS";
      end 
     8'h6C:
      begin
      A_instr = "JMP_IND";
      end 
     8'h20:
      begin
      A_instr = "JSR_ABS";
      end 
     8'hA9:
      begin
      A_instr = "LDA_IMM";
      end 
     8'hA5:
      begin
      A_instr = "LDA_ZPG";
      end 
     8'hB5:
      begin
      A_instr = "LDA_ZPX";
      end 
     8'hAD:
      begin
      A_instr = "LDA_ABS";
      end 
     8'hBD:
      begin
      A_instr = "LDA_ABX";
      end 
     8'hB9:
      begin
      A_instr = "LDA_ABY";
      end 
     8'hA1:
      begin
      A_instr = "LDA_IDX";
      end 
     8'hB1:
      begin
      A_instr = "LDA_IDY";
      end 
     8'hA2:
      begin
      A_instr = "LDX_IMM";
      end 
     8'hA6:
      begin
      A_instr = "LDX_ZPG";
      end 
     8'hB6:
      begin
      A_instr = "LDX_ZPY";
      end 
     8'hAE:
      begin
      A_instr = "LDX_ABS";
      end 
     8'hBE:
      begin
      A_instr = "LDX_ABY";
      end 
     8'hA0:
      begin
      A_instr = "LDY_IMM";
      end 
     8'hA4:
      begin
      A_instr = "LDY_ZPG";
      end 
     8'hB4:
      begin
      A_instr = "LDY_ZPX";
      end 
     8'hAC:
      begin
      A_instr = "LDY_ABS";
      end 
     8'hBC:
      begin
      A_instr = "LDY_ABX";
      end 
     8'h4A:
      begin
      A_instr = "LSR_ACC";
      end 
     8'h46:
      begin
      A_instr = "LSR_ZPG";
      end 
     8'h56:
      begin
      A_instr = "LSR_ZPX";
      end 
     8'h4E:
      begin
      A_instr = "LSR_ABS";
      end 
     8'h5E:
      begin
      A_instr = "LSR_ABX";
      end 
     8'hEA:
      begin
      A_instr = "NOP_IMP";
      end 
     8'h09:
      begin
      A_instr = "ORA_IMM";
      end 
     8'h05:
      begin
      A_instr = "ORA_ZPG";
      end 
     8'h15:
      begin
      A_instr = "ORA_ZPX";
      end 
     8'h0D:
      begin
      A_instr = "ORA_ABS";
      end 
     8'h1D:
      begin
      A_instr = "ORA_ABX";
      end 
     8'h19:
      begin
      A_instr = "ORA_ABY";
      end 
     8'h01:
      begin
      A_instr = "ORA_IDX";
      end 
     8'h11:
      begin
      A_instr = "ORA_IDY";
      end 
     8'h48:
      begin
      A_instr = "PHA_IMP";
      end 
     8'h08:
      begin
      A_instr = "PHP_IMP";
      end 
     8'h68:
      begin
      A_instr = "PLA_IMP";
      end 
     8'h28:
      begin
      A_instr = "PLP_IMP";
      end 
     8'h2A:
      begin
      A_instr = "ROL_ACC";
      end 
     8'h26:
      begin
      A_instr = "ROL_ZPG";
      end 
     8'h36:
      begin
      A_instr = "ROL_ZPX";
      end 
     8'h2E:
      begin
      A_instr = "ROL_ABS";
      end 
     8'h3E:
      begin
      A_instr = "ROL_ABX";
      end 
     8'h6A:
      begin
      A_instr = "ROR_ACC";
      end 
     8'h66:
      begin
      A_instr = "ROR_ZPG";
      end 
     8'h76:
      begin
      A_instr = "ROR_ZPX";
      end 
     8'h6E:
      begin
      A_instr = "ROR_ABS";
      end 
     8'h7E:
      begin
      A_instr = "ROR_ABX";
      end 
     8'h40:
      begin
      A_instr = "RTI_IMP";
      end 
     8'h60:
      begin
      A_instr = "RTS_IMP";
      end 
     8'hE9:
      begin
      A_instr = "SBC_IMM";
      end 
     8'hE5:
      begin
      A_instr = "SBC_ZPG";
      end 
     8'hF5:
      begin
      A_instr = "SBC_ZPX";
      end 
     8'hED:
      begin
      A_instr = "SBC_ABS";
      end 
     8'hFD:
      begin
      A_instr = "SBC_ABX";
      end 
     8'hF9:
      begin
      A_instr = "SBC_ABY";
      end 
     8'hE1:
      begin
      A_instr = "SBC_IDX";
      end 
     8'hF1:
      begin
      A_instr = "SBC_IDY";
      end 
     8'h38:
      begin
      A_instr = "SEC_IMP";
      end 
     8'hF8:
      begin
      A_instr = "SED_IMP";
      end 
     8'h78:
      begin
      A_instr = "SEI_IMP";
      end 
     8'h85:
      begin
      A_instr = "STA_ZPG";
      end 
     8'h95:
      begin
      A_instr = "STA_ZPX";
      end 
     8'h8D:
      begin
      A_instr = "STA_ABS";
      end 
     8'h9D:
      begin
      A_instr = "STA_ABX";
      end 
     8'h99:
      begin
      A_instr = "STA_ABY";
      end 
     8'h81:
      begin
      A_instr = "STA_IDX";
      end 
     8'h91:
      begin
      A_instr = "STA_IDY";
      end 
     8'h86:
      begin
      A_instr = "STX_ZPG";
      end 
     8'h96:
      begin
      A_instr = "STX_ZPY";
      end 
     8'h8E:
      begin
      A_instr = "STX_ABS";
      end 
     8'h84:
      begin
      A_instr = "STY_ZPG";
      end 
     8'h94:
      begin
      A_instr = "STY_ZPX";
      end 
     8'h8C:
      begin
      A_instr = "STY_ABS";
      end 
     8'hAA:
      begin
      A_instr = "TAX_IMP";
      end 
     8'hA8:
      begin
      A_instr = "TAY_IMP";
      end 
     8'h8A:
      begin
      A_instr = "TXA_IMP";
      end 
     8'h98:
      begin
      A_instr = "TYA_IMP";
      end
      default:    A_instr = "XXX_XXX";
   endcase
end
always @(*) begin
   case  (alu_mode)
      3'b000:          begin    
                              A_alu_mode = "ADD";
                              end
      3'b001:          begin    
                              A_alu_mode = "AND";
                              end
      3'b010:          begin    
                              A_alu_mode = "OR ";
                              end
      3'b011:          begin    
                              A_alu_mode = "EOR";
                              end
      3'b100:          begin    
                              A_alu_mode = "SFL";
                              end
      3'b101:          begin    
                              A_alu_mode = "SFR";
                              end
     default:                begin
                              A_alu_mode = "XXX";
                              end
   endcase
end
// alu_op_a_sel
always @(*) begin
   case  (alu_op_a_sel)
      3'b000:           begin    
                              A_alu_op_a_sel = "00 ";
                              end
      3'b001:          begin    
                              A_alu_op_a_sel = "ACC";
                              end
      3'b010  :          begin    
                              A_alu_op_a_sel = " X ";
                              end
      3'b011  :          begin    
                              A_alu_op_a_sel = " Y ";
                              end
      3'b100 :          begin    
                              A_alu_op_a_sel = " FF ";
                              end
      3'b101:          begin    
                              A_alu_op_a_sel = "PSR";
                              end
      default:                begin
                              A_alu_op_a_sel = "XXX";
                              end
   endcase
end
// alu_op_b_sel
always @(*) begin
   case  (alu_op_b_sel)
      2'b00:           begin    
                              A_alu_op_b_sel = " 0 ";
                              end
      2'b11:         begin    
                              A_alu_op_b_sel = "OPR";
                              end
      2'b10:          begin    
                              A_alu_op_b_sel = "STK";
                              end
      2'b01:          begin    
                              A_alu_op_b_sel = "IMM";
                              end
      default:                begin
                              A_alu_op_b_sel = "XXX";
                              end
   endcase
end
// alu_op_b_inv
always @(*) begin
   case  (alu_op_b_inv)
      1'b1:                   begin    
                              A_alu_op_b_inv = "INV";
                              end
      1'b0:                   begin    
                              A_alu_op_b_inv = "   ";
                              end
      default:                begin
                              A_alu_op_b_inv = "XXX";
                              end
   endcase
end
// alu_op_c_sel
always @(*) begin
   case  (alu_op_c_sel)
      2'b00:          A_alu_op_c_sel = " 0 ";
      2'b01:          A_alu_op_c_sel = " 1 ";
      2'b10:         A_alu_op_c_sel = "CIN";    
      default:               A_alu_op_c_sel = "XXX";
   endcase
end
// alu_status_update
always @(*) begin
   case  (alu_status_update)
      5'b00000:begin    
                              A_alu_status_update = "    ";
                              end
      5'b00001:  begin    
                              A_alu_status_update = "N Z ";
                              end
      5'b00011: begin    
                              A_alu_status_update = "N ZC";
                              end
      5'b00111:begin    
                              A_alu_status_update = "NVZC";
                              end
      5'b01000:  begin    
                              A_alu_status_update = " WR ";
                              end
      5'b10000: begin    
                              A_alu_status_update = "76Z ";
                              end
      5'b11000: begin    
                              A_alu_status_update = "RES ";
                              end
      default:                begin
                              A_alu_status_update = "XXXX";
                              end
   endcase
end
// dest
always @(*) begin
   case  (dest)
      3'b000:          A_dest = "   ";
      3'b001:         A_dest = " A ";
      3'b010:         A_dest = " X ";
      3'b011:         A_dest = " Y ";
      3'b100:           A_dest = "MEM";
       default:            A_dest = "XXX";
   endcase
end
// ctrl
always @(*) begin
   case  (ctrl)
      3'b000:        A_ctrl = "       ";
      3'b001:         A_ctrl = "JMP_SUB";
      3'b010:         A_ctrl = " JUMP  ";
      3'b011:     A_ctrl = "JMP_IND";
      3'b100:         A_ctrl = " BREAK ";
      3'b101:         A_ctrl = "RET INT";
      3'b110:         A_ctrl = "RET SUB";
      3'b111:      A_ctrl = "BRANCH ";
       default:          A_ctrl = " -XXX- ";    
   endcase
end
// cmd
always @(*) begin
   case  (cmd)
      2'b00:        A_cmd = "        ";
      2'b01:         A_cmd = "   RUN  ";
      2'b10:    A_cmd = "LOAD ADD";
      2'b11:    A_cmd = "LOAD VEC";
       default:         A_cmd = " -XXX- ";    
   endcase
end
// ins_type
always @(*) begin
   case  (ins_type)
      2'b00:     A_ins_type = "     ";
      2'b01:     A_ins_type = "READ ";
      2'b10:    A_ins_type = "WRITE";
      2'b11:      A_ins_type = " RMW ";
       default:           A_ins_type = "-XXX-";    
   endcase
end
// idx_sel
always @(*) begin
   case  (idx_sel)
      2'b00:        A_idx_sel = " 0 ";
      2'b01:         A_idx_sel = " X ";
      2'b10:         A_idx_sel = " Y ";
       default:           A_idx_sel = "---";    
   endcase
end   
    localparam STATE_SIZE = 3;
    wire    [7:0]   ir;                       // instruction register
    wire    [1:0]   length;                   // instruction length
    wire    [STATE_SIZE:0]   state;          // current and next state registers
    wire    [2:0]   dest;
    wire    [2:0]   ctrl;
    wire   [7:0]   vector;     
    wire    [7:0]   operand  ;    
    wire    [7:0]   imm_data;     // 
    reg     [7:0]   index;         // will be assigned with either X or Y
    wire    [15:0]  offset;         
   wire     now_fetch_op;
    // wiring that simplifies the FSM logic by simplifying the addressing modes
    wire absolute;
    wire immediate;
    wire implied;
    wire indirectx;
    wire indirecty;
    wire relative;
    wire zero_page;
    wire stack;
    wire fetch_op;
    wire [1:0] ins_type; 
    wire jump;
    wire jump_indirect;
    // regs for the special instructions
    wire brk;
    wire rti;
    wire rts;
    wire jsr;
    wire invalid;
    wire core_reset;
    wire branch_inst;     // a simple reg that is asserted everytime a branch will be executed.            
    wire [7:0] brn_value;
    wire [7:0] brn_enable;
    wire [4:0] alu_status_update;
    wire [2:0]      alu_op_a_sel;
    wire [1:0]      alu_op_b_sel;
    wire     alu_op_b_inv;
    wire [1:0]     alu_op_c_sel;
    wire [2:0]      alu_mode;    
    wire [1:0]     idx_sel;
    wire    [7:0]   alu_result;    // result from alu operation
    wire    [7:0]   alu_a;         // alu accumulator
    wire    [7:0]   alu_x;         // alu x index register
    wire    [7:0]   alu_y;         // alu y index register
     reg    [7:0]   alu_op_b;
    wire            alu_enable;     // a flag that when high tells the alu when to perform the operations
    wire            alu_enable_s;     
    wire        Error;
    wire    [1:0]   cmd;
assign alu_enable =  ((alu_enable_s || implied || stack  ) && !((state == 4'b1110)||  (state == 4'b1111) )              );
core_def_control
#( .BOOT_VEC (BOOT_VEC),
   .STATE_SIZE(STATE_SIZE)
)
control(
   .clk               ( clk               ),
   .reset             ( reset             ), 
   .enable            ( enable            ),
   .state             ( state             ),
   .ir                ( ir                ),
   .nmi               ( nmi               ),
   .vec_int           ( vec_int           ),
   .invalid           ( invalid           ),
   .run_status        ( alu_status[5]     ), 
   .irq_status        ( alu_status[2]     ),
   .brk_status        ( alu_status[4]     ),
   .cmd               ( cmd               ),
   .ctrl              ( ctrl              ),
   .address           ( addr          ),
   .branch_inst       ( branch_inst       ),
   .vector            ( vector            ),
   .core_reset        ( core_reset        )
);
core_def_state_fsm
#(.STATE_SIZE(STATE_SIZE))
state_fsm (
   .clk               ( clk               ),         
   .reset             ( core_reset        ),        
   .enable            ( enable            ),                   
   .cmd               ( cmd               ),
   .now_fetch_op      ( now_fetch_op      ),
   .run               ( alu_status[5]     ),
   .length            ( length            ),
   .immediate         ( immediate         ),
   .absolute          ( absolute          ),
   .stack             ( stack             ),
   .relative          ( relative          ), 
   .implied           ( implied           ),       
   .indirectx         ( indirectx         ),
   .indirecty         ( indirecty         ),
   .brk               ( brk               ),
   .rts               ( rts               ),
   .jump_indirect     ( jump_indirect     ),
   .jump              ( jump              ),
   .jsr               ( jsr               ),
   .rti               ( rti               ),
   .branch_inst       ( branch_inst       ),
   .ins_type          ( ins_type          ),
   .invalid           ( invalid           ),
   .state             ( state             )
);
core_def_inst_decode
#(.STATE_SIZE(STATE_SIZE))
inst_decode (
   .clk               ( clk               ),         
   .reset             ( reset             ),        
   .enable            ( enable            ),
   .disable_ir        ((state == 4'b1110) || (state == 4'b1111) ),     
   .now_fetch_op      ( now_fetch_op      ),                   
   .fetch_op          ( fetch_op          ),
   .state             ( state             ),
   .prog_data         ( prog_counter[0]? prog_data[15:8]:prog_data[7:0]),
   .length            ( length            ),
   .ir                ( ir                ),          
   .absolute          ( absolute          ),
   .immediate         ( immediate         ),
   .implied           ( implied           ),
   .indirectx         ( indirectx         ),
   .indirecty         ( indirecty         ),
   .relative          ( relative          ),
   .zero_page         ( zero_page         ),
   .stack             ( stack             ),
   .jump              ( jump              ),
   .jump_indirect     ( jump_indirect     ),
   .brk               ( brk               ),
   .rti               ( rti               ),
   .rts               ( rts               ),
   .jsr               ( jsr               ),
   .ins_type          ( ins_type          ),
   .alu_mode          ( alu_mode          ),
   .alu_op_a_sel      ( alu_op_a_sel      ),
   .alu_op_b_sel      ( alu_op_b_sel      ),
   .alu_op_b_inv      ( alu_op_b_inv      ),
   .alu_op_c_sel      ( alu_op_c_sel      ),
   .idx_sel           ( idx_sel           ),
   .alu_status_update ( alu_status_update ),
   .brn_value         ( brn_value         ),
   .brn_enable        ( brn_enable        ),
   .dest              ( dest              ),
   .ctrl              ( ctrl              ),
   .invalid           ( invalid           )
 );
   reg     last_prg_cnt_0;
   always@(posedge clk )
          last_prg_cnt_0 <= prog_counter[0];
core_def_sequencer
#( .VEC_TABLE (VEC_TABLE),
   .STATE_SIZE(STATE_SIZE))
sequencer (
   .clk               ( clk               ),         
   .reset             ( reset             ),        
   .enable            ( enable            ),
   .now_fetch_op      ( now_fetch_op      ),
   .cmd               ( cmd               ),
   .state             ( state             ),
   .length            ( length            ),         
   .vector            ( vector            ),
   .alu_result        ( alu_result        ),    
   .alu_a             ( alu_a             ),    
   .alu_status        ( alu_status        ),    
   .alu_enable        ( alu_enable_s      ),
   .alu_op_a_sel      ( alu_op_a_sel      ),
   .pg0_data          ( pg0_data          ),
   .data_in           ( addr[0]? rdata[15:8]: rdata[7:0]),
   .prog_data16       ( prog_data         ),
   .index             ( index             ),   
   .prog_data         ( last_prg_cnt_0? prog_data[15:8]:prog_data[7:0]),
   .implied           ( implied           ),
   .fetch_op          ( fetch_op          ),
   .immediate         ( immediate         ),  
   .relative          ( relative          ),
   .absolute          ( absolute          ),
   .zero_page         ( zero_page         ),
   .stack             ( stack             ),
   .indirectx         ( indirectx         ),
   .indirecty         ( indirecty         ),
   .jump_indirect     ( jump_indirect     ),
   .jump              ( jump              ),   
   .jsr               ( jsr               ),
   .brk               ( brk               ),
   .rti               ( rti               ),
   .rts               ( rts               ),
   .branch_inst       ( branch_inst       ), 
   .ins_type          ( ins_type          ),
   .prog_counter      ( prog_counter      ),            
   .address           ( addr          ),       
   .operand           ( operand           ),     
   .imm_data          ( imm_data          ),     
   .pg0_add           ( pg0_add           ), 
   .pg0_rd            ( pg0_rd            ),        
   .pg0_wr            ( pg0_wr            ),         
   .rd            ( rd            ),
   .wr            ( wr            ),
   .data_out          ( wdata         ),      
   .offset            ( offset            ),
   .stk_push          ( stk_push          ),
   .stk_push_data     ( stk_push_data     ),
   .stk_pull          ( stk_pull          ),
   .stk_pull_data     ( stk_pull_data     )
);
always@(*)
  case (idx_sel)
    2'b00:          index  = 8'h00;
    2'b01:           index  = alu_x;
    2'b10:           index  = alu_y;
     default:             index  = 8'bxxxxxxxx;
  endcase
reg [7:0]     mem_dat;
always@(*) mem_dat  = addr[0] ? rdata[15:8] : rdata[7:0];
always@(*)
  case (alu_op_b_sel)
    2'b00:         alu_op_b  = 8'h00;
    2'b01:        alu_op_b  = imm_data;
    2'b10:        alu_op_b  = stk_pull_data[7:0];
    2'b11:       alu_op_b  = mem_dat;
  endcase
core_def_alu  
alu (
    .clk                ( clk                 ),
    .reset              ( reset               ),
    .enable             ( enable              ),
    .alu_enable         ( alu_enable          ),
    .alu_result         ( alu_result          ),
    .alu_status         ( alu_status          ),
    .alu_op_b           ( alu_op_b            ),
    .psp_res            ( stk_pull_data[15:8] ),
    .alu_mode           ( alu_mode            ),
    .alu_op_a_sel       ( alu_op_a_sel        ),
    .alu_op_b_inv       ( alu_op_b_inv        ),
    .alu_op_c_sel       ( alu_op_c_sel        ),
    .alu_status_update  ( alu_status_update   ),
    .branch_inst        ( branch_inst         ),
    .relative           ( relative            ), 
    .dest               ( dest                ),         
    .brn_enable         ( brn_enable          ),
    .brn_value          ( brn_value           ),
    .alu_x              ( alu_x               ),
    .alu_y              ( alu_y               ),
    .alu_a              ( alu_a               )         
    );
  endmodule
module core_def_alu
(
input   wire           clk,
input   wire           reset,
input   wire           enable,
input   wire           alu_enable,
input   wire  [7:0]    alu_op_b,
input   wire  [7:0]    psp_res,
input   wire  [7:0]    brn_value,
input   wire  [7:0]    brn_enable, 
input   wire  [2:0]    dest,
input   wire           relative, 
input   wire  [2:0]    alu_mode,
input   wire  [4:0]    alu_status_update, 
input   wire  [2:0]    alu_op_a_sel,
input   wire 	       alu_op_b_inv,
input   wire  [1:0]    alu_op_c_sel,
output   reg           branch_inst,
output   reg  [7:0]    alu_result,
output   reg  [7:0]    alu_status,
output   reg  [7:0]    alu_x,
output   reg  [7:0]    alu_y,
output   reg  [7:0]    alu_a 
);
reg  [7:0]    alu_op_a;
reg           alu_op_c;   
wire          v_result;
reg           z_result;
reg           c_result;
wire          r_result;
wire [7:0]      result;
wire [7:0]     and_out;
wire [7:0]     orr_out;
wire [7:0]     eor_out;
wire [8:0]     a_sh_left;
wire [8:0]     a_sh_right;
wire [8:0]     b_sh_left;
wire [8:0]     b_sh_right;
always @ (*) begin
   case( alu_op_a_sel)
   3'b000:   alu_op_a     = 8'h00;
   3'b001:  alu_op_a     = alu_a;          
   3'b010:    alu_op_a     = alu_x;         
   3'b011:    alu_op_a     = alu_y;          
   3'b100:   alu_op_a     = 8'hff;
   3'b101:  alu_op_a     = alu_status;          
   default:        alu_op_a     = 8'h00;
   endcase
   end
always @ (*) begin
   case( alu_op_c_sel)
   2'b00:     alu_op_c    = 1'b0;
   2'b01:     alu_op_c    = 1'b1;          
   2'b10:    alu_op_c    = alu_status[3'b000];         
   2'b11:     alu_op_c    = 1'b0;          
   endcase
   end
core_def_alu_logic
alu_logic (
    .alu_op_b_inv  ( alu_op_b_inv   ),
    .alu_op_a      ( alu_op_a       ),
    .alu_op_b      ( alu_op_b       ),
    .alu_op_c      ( alu_op_c       ),
    .result        (   result       ),
    .r_result      (                ),
    .c_result      ( r_result       ),     
    .v_result      ( v_result       ),
    .and_out       ( and_out        ), 
    .orr_out       ( orr_out        ),
    .eor_out       ( eor_out        ),
    .a_sh_left     ( a_sh_left      ),
    .a_sh_right    ( a_sh_right     ),
    .b_sh_left     ( b_sh_left      ),
    .b_sh_right    ( b_sh_right     )
);
always @ (posedge clk )
begin
     if (reset) 
          begin
          alu_status[3'b111] <= 1'b0;
          alu_status[3'b110] <= 1'b0;
          alu_status[5]  <= 1'b1;
          alu_status[3'b100] <= 1'b0;
          alu_status[3'b011] <= 1'b0;
          alu_status[3'b010] <= 1'b0;
          alu_status[3'b001] <= 1'b1;
          alu_status[3'b000] <= 1'b0;
          end
     else 
     if (! (enable && alu_enable    ) )
        begin       
        alu_status[7:6]    <= alu_status[7:6];
        alu_status[5:2]     <= alu_status[5:2];
        alu_status[1]     <= alu_status[1];
        alu_status[0]     <= alu_status[0];
        end
     else
     begin
     case (alu_status_update)
          5'b00000:
                     begin 
                     alu_status[7:6]     <= alu_status[7:6];     
                     end  
           5'b01000: 
                     begin 
                     alu_status[7]  <=  brn_enable[7]?brn_value[7]: alu_status[7];
                     alu_status[6]  <=  brn_enable[6]?brn_value[6]: alu_status[6];
	             end 
           5'b10000: 
                     begin 
                     alu_status[3'b111] <=  alu_op_b[3'b111];
                     alu_status[3'b110] <=  alu_op_b[3'b110];
	             end  
           5'b00001: 
                     begin 
                     alu_status[3'b111] <=  alu_result[7];
                     alu_status[3'b110] <=  alu_status[3'b110];
	             end  
           5'b00011:
                     begin 
                     alu_status[3'b111] <=  alu_result[7];
                     alu_status[3'b110] <=  alu_status[3'b110];
	             end  
          5'b00111:
                     begin 
                     alu_status[3'b111] <=  alu_result[7];
                     alu_status[3'b110] <=  v_result;
	             end  
            5'b11000: 
                     begin 
                     alu_status[7:6]     <=  psp_res[7:6];
	             end  
           default:                     
                     begin 
                     alu_status[3'b111] <=  alu_status[3'b111];
                     alu_status[3'b110] <=  alu_status[3'b110];
	             end  
         endcase
     case (alu_status_update)
          5'b00000:
                     begin 
                     alu_status[5:2]     <= alu_status[5:2];     
                     end  
           5'b01000: 
                     begin 
                     alu_status[5]  <=  brn_enable[5]?brn_value[5]: alu_status[5];
                     alu_status[4]  <=  brn_enable[4]?brn_value[4]: alu_status[4];
                     alu_status[3]  <=  brn_enable[3]?brn_value[3]: alu_status[3];
                     alu_status[2]  <=  brn_enable[2]?brn_value[2]: alu_status[2];
	             end 
           5'b10000: 
                     begin 
                     alu_status[5]  <=  alu_status[5];
                     alu_status[3'b100] <=  alu_status[3'b100];
                     alu_status[3'b011] <=  alu_status[3'b011];
                     alu_status[3'b010] <=  alu_status[3'b010];
	             end  
           5'b00001: 
                     begin 
                     alu_status[5]  <=  alu_status[5];
                     alu_status[3'b100] <=  alu_status[3'b100];
                     alu_status[3'b011] <=  alu_status[3'b011];
                     alu_status[3'b010] <=  alu_status[3'b010];
	             end  
           5'b00011:
                     begin 
                     alu_status[5]  <=  alu_status[5];
                     alu_status[3'b100] <=  alu_status[3'b100];
                     alu_status[3'b011] <=  alu_status[3'b011];
                     alu_status[3'b010] <=  alu_status[3'b010];
	             end  
          5'b00111:
                     begin 
                     alu_status[5]  <=  alu_status[5];
                     alu_status[3'b100] <=  alu_status[3'b100];
                     alu_status[3'b011] <=  alu_status[3'b011];
                     alu_status[3'b010] <=  alu_status[3'b010];
	             end  
            5'b11000: 
                     begin 
                     alu_status[5:2]     <=  psp_res[5:2];
	             end  
           default:                     
                     begin 
                     alu_status[5]  <=  alu_status[5];
                     alu_status[3'b100] <=  alu_status[3'b100];
                     alu_status[3'b011] <=  alu_status[3'b011];
                     alu_status[3'b010] <=  alu_status[3'b010];
	             end  
         endcase
     case (alu_status_update)
          5'b00000:
                     begin 
                     alu_status[1]     <= alu_status[1];     
                     end  
           5'b01000: 
                     begin 
                     alu_status[1]  <=  brn_enable[1]?brn_value[1]: alu_status[1];
	             end 
           5'b10000: 
                     begin 
                     alu_status[3'b001] <=  z_result;
	             end  
           5'b00001: 
                     begin 
                     alu_status[3'b001] <=  z_result;
	             end  
           5'b00011:
                     begin 
                     alu_status[3'b001] <=  z_result;
	             end  
          5'b00111:
                     begin 
                     alu_status[3'b001] <=  z_result;
	             end  
            5'b11000: 
                     begin 
                     alu_status[1]     <=  psp_res[1];
	             end  
           default:                     
                     begin 
                     alu_status[3'b001] <=  alu_status[3'b001];
	             end  
     endcase // case (alu_status_update)
     case (alu_status_update)
          5'b00000:
                     begin 
                     alu_status[0]     <= alu_status[0];     
                     end  
           5'b01000: 
                     begin 
                     alu_status[0]  <=  brn_enable[0]?brn_value[0]: alu_status[0];
	             end 
           5'b10000: 
                     begin 
                     alu_status[3'b000] <=  alu_status[3'b000];
	             end  
           5'b00001: 
                     begin 
                     alu_status[3'b000] <=  alu_status[3'b000];
	             end  
           5'b00011:
                     begin 
                     alu_status[3'b000] <=  c_result;
	             end  
          5'b00111:
                     begin 
                     alu_status[3'b000] <=  c_result;
	             end  
            5'b11000: 
                     begin 
                     alu_status[0]     <=  psp_res[0];
	             end  
           default:                     
                     begin 
                     alu_status[3'b000] <=  alu_status[3'b000];
	             end  
         endcase
        end
end
always @ (posedge clk )
begin
     if (reset) 
          begin
          alu_a          <= 8'd0;
          end
     else 
     if ( enable &&  alu_enable &&   (dest ==   3'b001)) 
          begin
          alu_a          <= alu_result[7:0];
          end
     else 
          begin
          alu_a          <= alu_a;
          end
end
always @ (posedge clk )
begin
     if (reset) 
          begin
          alu_x          <= 8'd0;
          end
     else 
     if (!(enable &&  alu_enable)) 
          begin
          alu_x          <= alu_x;
          end
     else 
     case (dest)
      3'b010:  alu_x          <= alu_result[7:0];
       default : 
                   begin
                   alu_x          <= alu_x;
                   end
     endcase
end
always @ (posedge clk )
begin
     if (reset) 
          begin
          alu_y          <= 8'd0;
          end
     else 
     if (!(enable &&  alu_enable)) 
          begin
          alu_y          <= alu_y;
          end
     else 
     case (dest)
      3'b011:  alu_y          <= alu_result[7:0];
       default : 
                   begin
                   alu_y          <= alu_y;
                   end
     endcase
end
always @ (*) 
        begin
        alu_result      = result[7:0];
        c_result        = r_result;
     if (dest ==   3'b001) 
        case (alu_mode)
          3'b000:{c_result,alu_result[7:0]} = {r_result,result[7:0]};
          3'b001:{c_result,alu_result[7:0]} = {1'b0,and_out[7:0]};
          3'b010:{c_result,alu_result[7:0]} = {1'b0,orr_out[7:0]};
          3'b011:{c_result,alu_result[7:0]} = {1'b0,eor_out[7:0]};
          3'b100:{c_result,alu_result[7:0]} = a_sh_left;
          3'b101:{c_result,alu_result[7:0]} = a_sh_right;
                default:{c_result,alu_result[7:0]} = 9'b111111111;
       endcase
      else
        case (alu_mode)
          3'b000:{c_result,alu_result[7:0]} = {r_result,result[7:0]};
          3'b001:{c_result,alu_result[7:0]} = {1'b0,and_out[7:0]};
          3'b010:{c_result,alu_result[7:0]} = {1'b0,orr_out[7:0]};
          3'b011:{c_result,alu_result[7:0]} = {1'b0,eor_out[7:0]};
          3'b100:{c_result,alu_result[7:0]} = b_sh_left;
          3'b101:{c_result,alu_result[7:0]} = b_sh_right;
                default:{c_result,alu_result[7:0]} = 9'b111111111;   
       endcase
       end
always@(*)
  begin
  z_result      = ~(|alu_result[7:0]);
  end 
always@(*)     branch_inst = relative &&(   | (brn_enable & ( ~ (brn_value ^ alu_status))));
endmodule
module core_def_alu_logic
(
input wire [7:0] alu_op_a,
input wire [7:0] alu_op_b,
input wire       alu_op_c,
input wire       alu_op_b_inv,
output reg [7:0]   result,
output reg       r_result,
output reg       c_result,
output reg       v_result,
output reg [7:0]   and_out,
output reg [7:0]   orr_out,
output reg [7:0]   eor_out,
output reg [8:0]   a_sh_left,
output reg [8:0]   a_sh_right,
output reg [8:0]   b_sh_left,
output reg [8:0]   b_sh_right
);
reg [7:0] alu_op_b_mod;
always@(*)
  begin
  alu_op_b_mod  =    alu_op_b_inv  ? ~alu_op_b  : alu_op_b;
  end 
always@(*)
  begin
  c_result      =    alu_op_b_inv  ? !r_result  : r_result;  
  v_result      =  ((alu_op_a[7] == alu_op_b[7]) && (alu_op_a[7] != result[7]));
  end 
always @ (*) 
        begin
          {r_result,result[7:0]} =  alu_op_a + alu_op_b_mod + {7'b0,alu_op_c};
       end
always @ (*) 
           begin
           a_sh_left   = {alu_op_a, alu_op_c};
           a_sh_right  = {alu_op_a[0],alu_op_c, alu_op_a[7:1]};	      
           b_sh_left   = {alu_op_b, alu_op_c};
           b_sh_right  = {alu_op_b[0],alu_op_c, alu_op_b[7:1]};
           and_out     =  alu_op_a & alu_op_b;
           orr_out     =  alu_op_a | alu_op_b;
           eor_out     =  alu_op_a ^ alu_op_b;
           end
endmodule
module  core_def_control
#( parameter BOOT_VEC =8'hfc,
   parameter STATE_SIZE=3
)
(
input wire                    clk,
input wire                    reset,
input wire                    enable,
input wire                    nmi,
input wire [7:0]              vec_int,
input wire                    invalid,
input wire                    run_status, 
input wire                    irq_status,
input wire                    brk_status,
input wire [STATE_SIZE:0]    state,
input wire   [2:0]            ctrl,
input wire   [7:0]            ir,
input wire  [15:0]            address,
input wire                    branch_inst,
output reg   [7:0]            vector,
output reg   [1:0]            cmd, 
output reg                    core_reset
);
reg nmi_taken   ;   
always @ (posedge clk )
begin
     if (reset)
      begin                                
      nmi_taken      <= 1'b0;
      end
     else
     if (!nmi)       
      begin
      nmi_taken      <= 1'b0;
      end
     else
     if (ir == 8'h40)       
      begin
      nmi_taken      <= 1'b0;
      end
     else
     if (nmi && (state == 4'b1110))           
      begin
      nmi_taken      <= 1'b1;
      end
     else                         
      begin
      nmi_taken      <= nmi_taken;
      end
end
always @ (posedge clk )
begin
     if (reset)             core_reset     <= 1'b1;
     else
     if (!enable)           core_reset     <= core_reset;
     else                   core_reset     <= 1'b0;
end
always @ (posedge clk )
begin
     if (reset)             vector     <= 8'h00;
     else
     if (!enable)           vector     <= vector;
     else
     if(state == 4'b0000)    vector     <= BOOT_VEC;
     else                   vector     <= vec_int;
end
always @ (posedge clk )
begin
     if ( reset)            cmd            <= 2'b00;
     else
     if (!enable)           cmd            <=  cmd;
     else
     if(state == 4'b0000)    cmd            <= 2'b11;
     else
     if(state == 4'b0001)     cmd            <= 2'b11;
     else
     if(nmi &&(!nmi_taken)) cmd            <= 2'b11;
     else                   cmd            <= 2'b01;
end
endmodule
module core_def_inst_decode
#(parameter STATE_SIZE=3)
(
    input  wire                            clk,         
    input  wire                          reset,        
    input  wire                         enable,
    input  wire                         disable_ir,
    input  wire                       fetch_op,
    input  wire  [STATE_SIZE:0]         state,            
    input  wire            [7:0]     prog_data,            
    output  reg 		  now_fetch_op,
    output  reg            [7:0]            ir,            
    output  reg            [1:0]        length,            
    output  reg                      immediate,
    output  reg                       absolute,
    output  reg                      zero_page,
    output  reg                      indirectx,
    output  reg                      indirecty,
    output  reg                        implied,
    output  reg                       relative,
    output  reg                          stack,
    output  reg                            jsr,
    output  reg                           jump,
    output  reg                  jump_indirect,
    output  reg                            brk,
    output  reg                            rti,
    output  reg                            rts,
    output  reg                        invalid,
    output  reg            [1:0]      ins_type,
    output  reg            [2:0]          ctrl,
    output  reg            [2:0]          dest, 
    output  reg            [2:0]  alu_op_a_sel, 
    output  reg            [1:0]  alu_op_b_sel, 
    output  reg                   alu_op_b_inv,
    output  reg            [1:0]  alu_op_c_sel,
    output  reg            [1:0]       idx_sel, 
    output reg             [2:0]      alu_mode,
    output reg             [4:0] alu_status_update,    
    output  reg            [7:0]     brn_value,
    output  reg            [7:0]    brn_enable
);
reg  [1:0]  n_length;
reg  n_immediate;
reg  n_absolute;
reg  n_zero_page;
reg  n_indirectx;
reg  n_indirecty;
reg  n_implied;
reg  n_relative;
reg  n_stack;
reg  n_jsr;
reg  n_jump;
reg  n_jump_indirect;
reg  n_brk;
reg  n_rti;
reg  n_rts;
reg  n_invalid;
reg [1:0]  n_ins_type;
reg [2:0]  n_ctrl;
reg [2:0]  n_dest; 
reg [2:0]  n_alu_op_a_sel; 
reg [1:0]  n_alu_op_b_sel;
reg [1:0]  n_idx_sel;    
reg        n_alu_op_b_inv;
reg [1:0]  n_alu_op_c_sel; 
reg [2:0]  n_alu_mode;
reg [4:0]  n_alu_status_update;    
reg [7:0]  n_brn_value;
reg [7:0]  n_brn_enable;
always@(*)
 now_fetch_op = (state == 4'b0100) ||  fetch_op  ||  implied || stack  ;
always@(posedge clk)
  if (reset || disable_ir)
    begin
    ir                 <= 8'h00;
    length             <= 2'b00;
    absolute           <= 1'b0;
    immediate          <= 1'b0;
    implied            <= 1'b0;
    indirectx          <= 1'b0;
    indirecty          <= 1'b0;
    relative           <= 1'b0;
    zero_page          <= 1'b0;
    stack              <= 1'b0;
    jump               <= 1'b0;
    jump_indirect      <= 1'b0;
    jsr                <= 1'b0;
    brk                <= 1'b0;
    rti                <= 1'b0;
    rts                <= 1'b0;
    ins_type           <= 2'b00;     
    alu_mode           <= 3'b000;
    alu_op_a_sel       <= 3'b000;
    alu_op_b_sel       <= 2'b00;
    alu_op_b_inv       <= 1'b0; 
    alu_op_c_sel       <= 2'b00;   
    idx_sel            <= 2'b00;   
    alu_status_update  <= 5'b00000;  
    brn_value          <= 8'h00;
    brn_enable         <= 8'h00;
    dest               <= 3'b000;   
    ctrl               <= 3'b000;   
    invalid            <= 1'b0;
    end
  else
  if((!enable) || (!now_fetch_op)  )  
   begin
    ir                 <= ir                ;
    length             <= length            ;
    absolute           <= absolute          ;
    immediate          <= immediate         ;
    implied            <= implied           ;
    indirectx          <= indirectx         ;
    indirecty          <= indirecty         ;
    relative           <= relative          ;
    zero_page          <= zero_page         ;
    stack              <= stack             ;
    jump               <= jump              ;
    jump_indirect      <= jump_indirect     ;
    jsr                <= jsr               ;
    brk                <= brk               ;
    rti                <= rti               ;
    rts                <= rts               ;
    ins_type           <= ins_type          ;     
    alu_mode           <= alu_mode          ;
    alu_op_a_sel       <= alu_op_a_sel      ;
    alu_op_b_sel       <= alu_op_b_sel      ;
    alu_op_b_inv       <= alu_op_b_inv      ; 
    alu_op_c_sel       <= alu_op_c_sel      ;
    idx_sel            <= idx_sel           ;
    alu_status_update  <= alu_status_update ;  
    brn_value          <= brn_value         ;
    brn_enable         <= brn_enable        ;
    dest               <= dest              ;   
    ctrl               <= ctrl              ;   
    invalid            <= invalid           ;
    end    
  else
   begin
    ir                 <= prog_data           ;
    length             <= n_length            ;
    absolute           <= n_absolute          ;
    immediate          <= n_immediate         ;
    implied            <= n_implied           ;
    indirectx          <= n_indirectx         ;
    indirecty          <= n_indirecty         ;
    relative           <= n_relative          ;
    zero_page          <= n_zero_page         ;
    stack              <= n_stack             ;
    jump               <= n_jump              ;
    jump_indirect      <= n_jump_indirect     ;
    jsr                <= n_jsr               ;
    brk                <= n_brk               ;
    rti                <= n_rti               ;
    rts                <= n_rts               ;
    ins_type           <= n_ins_type          ;     
    alu_mode           <= n_alu_mode          ;
    alu_op_a_sel       <= n_alu_op_a_sel      ;
    alu_op_b_sel       <= n_alu_op_b_sel      ;
    alu_op_b_inv       <= n_alu_op_b_inv      ; 
    alu_op_c_sel       <= n_alu_op_c_sel      ;   
    idx_sel            <= n_idx_sel           ;   
    alu_status_update  <= n_alu_status_update ;  
    brn_value          <= n_brn_value         ;
    brn_enable         <= n_brn_enable        ;
    dest               <= n_dest              ;   
    ctrl               <= n_ctrl              ;   
    invalid            <= n_invalid           ;
   end
always @ (*) 
  begin  
   n_length             = 2'b00;
   n_absolute           = 1'b0;
   n_immediate          = 1'b0;
   n_implied            = 1'b0;
   n_indirectx          = 1'b0;
   n_indirecty          = 1'b0;
   n_relative           = 1'b0;
   n_zero_page          = 1'b0;
   n_stack              = 1'b0;
   n_jump               = 1'b0;
   n_jump_indirect      = 1'b0;
   n_jsr                = 1'b0;
   n_brk                = 1'b0;
   n_rti                = 1'b0;
   n_rts                = 1'b0;
   n_ins_type           = 2'b00;     
   n_alu_mode           = 3'b000;
   n_alu_op_a_sel       = 3'b000;
   n_alu_op_b_sel       = 2'b00;
   n_alu_op_b_inv       = 1'b0; 
   n_alu_op_c_sel       = 2'b00;
   n_idx_sel            = 2'b00;   
   n_alu_status_update  = 5'b00000;  
   n_brn_value          = 8'h00;
   n_brn_enable         = 8'h00;
   n_dest               = 3'b000;   
   n_ctrl               = 3'b000;   
   n_invalid            = 1'b0;
   case (prog_data)
// implied
       8'h18: 
           begin
           n_length                             = 2'b01;
           n_implied                            = 1'b1;
           n_alu_status_update                  = 5'b01000;  
           n_brn_value                          = 8'h00;
           n_brn_enable                         = 8'h01;
           n_dest                               = 3'b000;
           end
       8'hD8:  
           begin
           n_length                             = 2'b01;	    
           n_implied                            = 1'b1;
           n_alu_status_update                  = 5'b01000;  
           n_brn_value                          = 8'h00;
           n_brn_enable                         = 8'h08;
           n_dest                               = 3'b000;    
           end
       8'h58: 
           begin
           n_length                             = 2'b01;
           n_implied                            = 1'b1;
           n_alu_status_update                  = 5'b01000;  
           n_brn_value                          = 8'h00;
           n_brn_enable                         = 8'h04;
           n_dest                               = 3'b000;    
           end
       8'hB8: 
           begin
           n_length                             = 2'b01;
           n_implied                            = 1'b1;
           n_alu_status_update                  = 5'b01000;  
           n_brn_value                          = 8'h00;
           n_brn_enable                         = 8'h40;
           n_dest                               = 3'b000;    
           end
       8'hCA: 
           begin
           n_length                             = 2'b01;
           n_implied                            = 1'b1;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b010;
           n_alu_op_b_inv                       = 1'b1;        
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;
           n_dest                               = 3'b010;    
           end
       8'h88: 
           begin
           n_length                             = 2'b01;
           n_implied                            = 1'b1;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b011;
           n_alu_op_b_inv                       = 1'b1;        
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;
           n_dest                               = 3'b011;    
           end
       8'hE8: 
           begin
           n_length                             = 2'b01;
           n_implied                            = 1'b1;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b010;
           n_alu_op_b_inv                       = 1'b0;
           n_alu_op_c_sel                       = 2'b01;
           n_alu_status_update                  = 5'b00001;
           n_dest                               = 3'b010;    
           end
       8'hC8: 
           begin
           n_length                             = 2'b01;
           n_implied                            = 1'b1;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b011;
           n_alu_op_b_inv                       = 1'b0;
           n_alu_op_c_sel                       = 2'b01;
           n_alu_status_update                  = 5'b00001;
           n_dest                               = 3'b011;    
           end
       8'h38: 
           begin
           n_length                             = 2'b01;	    
           n_implied                            = 1'b1;
           n_alu_status_update                  = 5'b01000;  
           n_brn_value                          = 8'h01;
           n_brn_enable                         = 8'h01;
           n_dest                               = 3'b000;    
           end
       8'hF8: 
           begin
           n_length                             = 2'b01;
           n_implied                            = 1'b1;
           n_alu_status_update                  = 5'b01000;  
           n_brn_value                          = 8'h08;
           n_brn_enable                         = 8'h08;
           n_dest                               = 3'b000;    
           end
       8'h78: 
           begin
           n_length                             = 2'b01;
           n_implied                            = 1'b1;
           n_alu_status_update                  = 5'b01000;  
           n_brn_value                          = 8'h04;
           n_brn_enable                         = 8'h04;
           n_dest                               = 3'b000;    
           end
       8'hAA:
           begin
           n_length                             = 2'b01;
           n_implied                            = 1'b1;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_inv                       = 1'b0;
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;
           n_dest                               = 3'b010;     
           end
       8'hA8: 
           begin
           n_length                             = 2'b01;
           n_implied                            = 1'b1;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_inv                       = 1'b0;
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;
           n_dest                               = 3'b011;     
           end
       8'h8A: 
           begin
           n_length                             = 2'b01;
           n_implied                            = 1'b1;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b010;
           n_alu_op_b_inv                       = 1'b0;
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;
           n_dest                               = 3'b001;    
           end
       8'h98: 
           begin
           n_length                             = 2'b01;
           n_implied                            = 1'b1;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b011;
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;
           n_dest                               = 3'b001;    
           end
       8'hEA: 
           begin
           n_length                             = 2'b01;
           n_implied                            = 1'b1;
           n_dest                               = 3'b000;    
           end
       8'h0A:
           begin
           n_length                             = 2'b01;
           n_implied                            = 1'b1;   
           n_alu_mode                           = 3'b100;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00011; 
           n_dest                               = 3'b001;        
           end
       8'h4A: 
           begin
           n_length                             = 2'b01;
           n_implied                            = 1'b1;
           n_alu_mode                           = 3'b101;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00011;      
           n_dest                               = 3'b001;                  
           end
       8'h2A:
           begin
           n_length                             = 2'b01;
           n_implied                            = 1'b1;
           n_alu_mode                           = 3'b100;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b10;
           n_alu_status_update                  = 5'b00011;      
           n_dest                               = 3'b001;                  
           end 
       8'h6A: 
           begin
           n_length                             = 2'b01;
           n_implied                            = 1'b1;
           n_alu_mode                           = 3'b101;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b10;
           n_alu_status_update                  = 5'b00011;      
           n_dest                               = 3'b001;                  
           end
// immediate
       8'h69: 
           begin
           n_length                             = 2'b10;
           n_immediate                          = 1'b1;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b01;
           n_alu_op_b_inv                       = 1'b0; 
           n_alu_op_c_sel                       = 2'b10;
           n_alu_status_update                  = 5'b00111;
           n_dest                               = 3'b001;                   
           end
       8'h29: 
           begin
           n_length                             = 2'b10;
           n_immediate                          = 1'b1;
           n_alu_mode                           = 3'b001;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b01;
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;
           n_dest                               = 3'b001;                  
           end
       8'hC9: 
           begin
           n_length                             = 2'b10;
           n_immediate                          = 1'b1;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b01;
           n_alu_op_b_inv                       = 1'b1;        
           n_alu_op_c_sel                       = 2'b01;
           n_alu_status_update                  = 5'b00011;
           n_dest                               = 3'b000;                  
           end
       8'hE0: 
           begin
           n_length                             = 2'b10;
           n_immediate                          = 1'b1;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b010;
           n_alu_op_b_sel                       = 2'b01;
           n_alu_op_b_inv                       = 1'b1;  
           n_alu_op_c_sel                       = 2'b01;
           n_alu_status_update                  = 5'b00011;
           n_dest                               = 3'b000;                 
           end
       8'hC0: 
           begin
           n_length                             = 2'b10;
           n_immediate                          = 1'b1;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b011;
           n_alu_op_b_sel                       = 2'b01;
           n_alu_op_b_inv                       = 1'b1;
           n_alu_op_c_sel                       = 2'b01;
           n_alu_status_update                  = 5'b00011;
           n_dest                               = 3'b000;           
           end
       8'h49: 
           begin
           n_length                             = 2'b10;
           n_immediate                          = 1'b1;
           n_alu_mode                           = 3'b011;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b01;
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;
           n_dest                               = 3'b001;        
           end
       8'hA9: 
           begin
           n_length                             = 2'b10;
           n_immediate                          = 1'b1;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b000;
           n_alu_op_b_sel                       = 2'b01;
           n_alu_op_b_inv                       = 1'b0;  
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;        
           n_dest                               = 3'b001;                   
           end
       8'hA2: 
           begin
           n_length                             = 2'b10;
           n_immediate                          = 1'b1;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b000;
           n_alu_op_b_sel                       = 2'b01;
           n_alu_op_b_inv                       = 1'b0;  
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;       
           n_dest                               = 3'b010;                    
           end
       8'hA0: 
           begin
           n_length                             = 2'b10;
           n_immediate                          = 1'b1;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b000;
           n_alu_op_b_sel                       = 2'b01;
           n_alu_op_b_inv                       = 1'b0;  
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001; 
           n_dest                               = 3'b011;        
           end
       8'h09: 
           begin
           n_length                             = 2'b10;
           n_immediate                          = 1'b1;
           n_alu_mode                           = 3'b010;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b01;
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;
           n_dest                               = 3'b001;                        
           end
       8'hE9: 
           begin
           n_length                             = 2'b10;
           n_immediate                          = 1'b1;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b01;
           n_alu_op_b_inv                       = 1'b1;  
           n_alu_op_c_sel                       = 2'b10;
           n_alu_status_update                  = 5'b00111;     
           n_dest                               = 3'b001;                   
           end
// zero_page
       8'h65: 
           begin
           n_length                             = 2'b10;
           n_zero_page                          = 1'b1;
           n_ins_type                           = 2'b01;  	       
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0; 
           n_alu_op_c_sel                       = 2'b10;
           n_alu_status_update                  = 5'b00111;
           n_dest                               = 3'b001;                  
           end    
       8'h25: 
           begin
           n_length                             = 2'b10;
           n_zero_page                          = 1'b1;
           n_ins_type                           = 2'b01;        
           n_alu_mode                           = 3'b001;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;
           n_dest                               = 3'b001;        
           end    
       8'h06: 
           begin
           n_length                             = 2'b10;
           n_zero_page                          = 1'b1;
           n_ins_type                           = 2'b11;       	      
           n_alu_mode                           = 3'b100;
           n_alu_op_a_sel                       = 3'b000;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00011;
           n_dest                               = 3'b100;                  
           end    
       8'h24: 
           begin
           n_length                             = 2'b10;
           n_zero_page                          = 1'b1;
           n_ins_type                           = 2'b01;   
           n_alu_mode                           = 3'b001;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b10000;
           n_dest                               = 3'b100;        
           end    
       8'hC5: 
           begin
           n_length                             = 2'b10;
           n_zero_page                          = 1'b1;
           n_ins_type                           = 2'b01;         
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b1;        
           n_alu_op_c_sel                       = 2'b01;
           n_alu_status_update                  = 5'b00011;
           n_dest                               = 3'b100;                  
           end    
       8'hE4: 
           begin
           n_length                             = 2'b10;
           n_zero_page                          = 1'b1;
           n_ins_type                           = 2'b01;     	      	       
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b010;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b1;  
           n_alu_op_c_sel                       = 2'b01;
           n_alu_status_update                  = 5'b00011;
           n_dest                               = 3'b100;                        
           end    
       8'hC4: 
           begin
           n_length                             = 2'b10;
           n_zero_page                          = 1'b1;
           n_ins_type                           = 2'b01;     	      	       
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b011;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b1;
           n_alu_op_c_sel                       = 2'b01;
           n_alu_status_update                  = 5'b00011; 
           n_dest                               = 3'b100;                       
           end    
       8'hC6: 
           begin
           n_length                             = 2'b10;
           n_zero_page                          = 1'b1;
           n_ins_type                           = 2'b11;     	      	       
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b100;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;
           n_dest                               = 3'b100;                  
           end    
       8'h45: 
           begin
           n_length                             = 2'b10;
           n_zero_page                          = 1'b1;
           n_ins_type                           = 2'b01;     	      	       
           n_alu_mode                           = 3'b011;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;
           n_dest                               = 3'b100;                            
           end    
       8'hE6: 
           begin
           n_length                             = 2'b10;	    
           n_zero_page                          = 1'b1;
           n_ins_type                           = 2'b11;     	      	       
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b000;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;
           n_alu_op_c_sel                       = 2'b01;
           n_alu_status_update                  = 5'b00001;
           n_dest                               = 3'b100;                            
           end    
       8'hA5: 
           begin
           n_length                             = 2'b10;
           n_zero_page                          = 1'b1;
           n_ins_type                           = 2'b01;     	      	       
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b000;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;  
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;       
           n_dest                               = 3'b001;                     
           end    
       8'hA6: 
           begin
           n_length                             = 2'b10;
           n_zero_page                          = 1'b1;
           n_ins_type                           = 2'b01;     	      	       
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b000;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;  
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;
           n_dest                               = 3'b010;                               
           end    
       8'hA4:
           begin
           n_length                             = 2'b10;
           n_zero_page                          = 1'b1;
           n_ins_type                           = 2'b01;     	      	       
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b000;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;  
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;
           n_dest                               = 3'b011;                                        
           end    
       8'h46: 
           begin
           n_length                             = 2'b10;
           n_zero_page                          = 1'b1;
           n_ins_type                           = 2'b11;     	      	       
           n_alu_mode                           = 3'b101;
           n_alu_op_a_sel                       = 3'b000;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00011;
           n_dest                               = 3'b100;                     
           end    
       8'h05: 
           begin
           n_length                             = 2'b10;
           n_zero_page                          = 1'b1;
           n_ins_type                           = 2'b01;     	      	       
           n_alu_mode                           = 3'b010;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;
           n_dest                               = 3'b100;                               
           end    
       8'h26: 
           begin
           n_length                             = 2'b10;
           n_zero_page                          = 1'b1;
           n_ins_type                           = 2'b11;     	      	       
           n_alu_mode                           = 3'b100;
           n_alu_op_a_sel                       = 3'b000;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b10;
           n_alu_status_update                  = 5'b00011;
           n_dest                               = 3'b100;                               
           end    
       8'h66: 
           begin
           n_length                             = 2'b10;
           n_zero_page                          = 1'b1;
           n_ins_type                           = 2'b11;     	      	       
           n_alu_mode                           = 3'b101;
           n_alu_op_a_sel                       = 3'b000;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b10;
           n_alu_status_update                  = 5'b00011;
           n_dest                               = 3'b100;                               
           end    
       8'hE5: 
           begin
           n_length                             = 2'b10;
           n_zero_page                          = 1'b1;
           n_ins_type                           = 2'b01;     	      	       
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b1;  
           n_alu_op_c_sel                       = 2'b10;
           n_alu_status_update                  = 5'b00111;
           n_dest                               = 3'b100;                               
           end    
       8'h85: 
           begin
           n_length                             = 2'b10;
           n_zero_page                          = 1'b1;
           n_ins_type                           = 2'b10;     	      	       
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_inv                       = 1'b0;
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00000;  
           n_dest                               = 3'b100;                     
           end    
       8'h86: 
           begin
           n_length                             = 2'b10;
           n_zero_page                          = 1'b1;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b010;
           n_alu_op_b_inv                       = 1'b0;
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00000;
           n_dest                               = 3'b100;                     
           end    
       8'h84: 
           begin
           n_length                             = 2'b10;
           n_zero_page                          = 1'b1;
           n_ins_type                           = 2'b10;     	      	       
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b011;
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00000;
           n_dest                               = 3'b100;                     
           end    
// zero_page_indexed
       8'h75: 
           begin
           n_length                             = 2'b10;
           n_zero_page                          = 1'b1;
           n_idx_sel                            = 2'b01;   
           n_ins_type                           = 2'b01;     	      	       
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0; 
           n_alu_op_c_sel                       = 2'b10;
           n_alu_status_update                  = 5'b00111;
           n_dest                               = 3'b001;          
           end
       8'h35: 
           begin
           n_length                             = 2'b10;
           n_zero_page                          = 1'b1;
           n_idx_sel                            = 2'b01;   
           n_ins_type                           = 2'b01;     	      	       
           n_alu_mode                           = 3'b001;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;
           n_dest                               = 3'b001;                               
           end
       8'h16: 
           begin
           n_length                             = 2'b10;
           n_zero_page                          = 1'b1;
           n_idx_sel                            = 2'b01;   
           n_ins_type                           = 2'b11;     	      	       
           n_alu_mode                           = 3'b100;
           n_alu_op_a_sel                       = 3'b000;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00011;
           n_dest                               = 3'b100;                               
           end
       8'hD5: 
           begin
           n_length                             = 2'b10;
           n_zero_page                          = 1'b1;
           n_idx_sel                            = 2'b01;   
           n_ins_type                           = 2'b01;     	      	       
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b1;        
           n_alu_op_c_sel                       = 2'b01;
           n_alu_status_update                  = 5'b00011;
           n_dest                               = 3'b000;                     
           end
       8'hD6: 
           begin
           n_length                             = 2'b10;
           n_zero_page                          = 1'b1;
           n_idx_sel                            = 2'b01;   
           n_ins_type                           = 2'b11;     	      	       
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b100;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;
           n_dest                               = 3'b100;                               
           end
       8'h55: 
           begin
           n_length                             = 2'b10;
           n_zero_page                          = 1'b1;
	   n_idx_sel                            = 2'b01;   
           n_ins_type                           = 2'b01;     	      	       
           n_alu_mode                           = 3'b011;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;
           n_dest                               = 3'b100;                               
           end
       8'hF6: 
           begin
           n_length                             = 2'b10;
           n_zero_page                          = 1'b1;
	   n_idx_sel                            = 2'b01;      
           n_ins_type                           = 2'b11;     	      	       
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b000;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;
           n_alu_op_c_sel                       = 2'b01;
           n_alu_status_update                  = 5'b00001;
           n_dest                               = 3'b100;                               
           end
       8'hB5: 
           begin
           n_length                             = 2'b10;
           n_zero_page                          = 1'b1;
	   n_idx_sel                            = 2'b01;      
           n_ins_type                           = 2'b11;     	      	       
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b000;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;  
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;
           n_dest                               = 3'b001;                               
           end
       8'hB4: 
           begin
           n_length                             = 2'b10;	    
           n_zero_page                          = 1'b1;
	   n_idx_sel                            = 2'b01;      
           n_ins_type                           = 2'b01;     	      	       
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b000;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;  
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;          
           n_dest                               = 3'b011;                     
           end
       8'h56: 
           begin
           n_length                             = 2'b10;
           n_zero_page                          = 1'b1;
	   n_idx_sel                            = 2'b01;   
           n_ins_type                           = 2'b11;     	      	       
           n_alu_mode                           = 3'b101;
           n_alu_op_a_sel                       = 3'b000;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00011;
           n_dest                               = 3'b100;                                     
           end
       8'h15:  
           begin
           n_length                             = 2'b10;
           n_zero_page                          = 1'b1;
	   n_idx_sel                            = 2'b01;   
           n_ins_type                           = 2'b01;     	      	       
           n_alu_mode                           = 3'b010;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;
           n_dest                               = 3'b100;                                               
           end
       8'h36: 
           begin
           n_length                             = 2'b10;
           n_zero_page                          = 1'b1;
	   n_idx_sel                            = 2'b01;   
           n_ins_type                           = 2'b11;	      
           n_alu_mode                           = 3'b100;
           n_alu_op_a_sel                       = 3'b000;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b10;
           n_alu_status_update                  = 5'b00011;
           n_dest                               = 3'b100;                                               
           end
       8'h76:
           begin
           n_length                             = 2'b10;
           n_zero_page                          = 1'b1;
	   n_idx_sel                            = 2'b01;   
           n_ins_type                           = 2'b11;     	      	       
           n_alu_mode                           = 3'b101;
           n_alu_op_a_sel                       = 3'b000;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b10;
           n_alu_status_update                  = 5'b00011;
           n_dest                               = 3'b100;                                               
           end
       8'hF5: 
           begin
           n_length                             = 2'b10;
           n_zero_page                          = 1'b1;
	   n_idx_sel                            = 2'b01;   
           n_ins_type                           = 2'b01;     	      	       
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b1;  
           n_alu_op_c_sel                       = 2'b10;
           n_alu_status_update                  = 5'b00111;
           n_dest                               = 3'b100;                                               
           end
       8'h95: 
           begin
           n_length                             = 2'b10;
           n_zero_page                          = 1'b1;
	   n_idx_sel                            = 2'b01;   
           n_ins_type                           = 2'b10;     	      	       
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_inv                       = 1'b0;
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00000;
           n_dest                               = 3'b100;                                               
           end
       8'h94: 
           begin
           n_length                             = 2'b10;
           n_zero_page                          = 1'b1;
	   n_idx_sel                            = 2'b01;   
           n_ins_type                           = 2'b10;     	      	       
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b011;
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00000;
           n_dest                               = 3'b100;                                               
           end
       8'hB6:
           begin
           n_length                             = 2'b10;
           n_zero_page                          = 1'b1;
	   n_idx_sel                            = 2'b10;   
           n_ins_type                           = 2'b01;     	      	       
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b000;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;  
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;
           n_dest                               = 3'b010;                                               
           end
       8'h96: 
           begin
           n_length                             = 2'b10;
           n_zero_page                          = 1'b1;
	   n_idx_sel                            = 2'b10;      
           n_ins_type                           = 2'b10;     	      	       
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b010;
           n_alu_op_b_inv                       = 1'b0;
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00000;
           n_dest                               = 3'b100;                                               
           end
// Branch
       8'h90: 
           begin
           n_length                             = 2'b10;
           n_relative                           = 1'b1;
           n_ctrl                               = 3'b111;   
           n_brn_enable[3'b000]                     = 1'b1;
           n_brn_value[3'b000]                      = 1'b0;
           n_dest                               = 3'b000;                                               
           end 
       8'hB0: 
           begin
           n_length                             = 2'b10;
           n_relative                           = 1'b1;
           n_ctrl                               = 3'b111;   
           n_brn_enable[3'b000]                     = 1'b1;
           n_brn_value[3'b000]                      = 1'b1;
           n_dest                               = 3'b000;                                               
           end 
       8'hD0: 
           begin
           n_length                             = 2'b10;
           n_relative                           = 1'b1;
           n_ctrl                               = 3'b111;   
           n_brn_enable[3'b001]                     = 1'b1;
           n_brn_value[3'b001]                      = 1'b0;
           n_dest                               = 3'b000;                                               
           end 
       8'hF0: 
           begin
           n_length                             = 2'b10;
           n_relative                           = 1'b1;
           n_ctrl                               = 3'b111;   
           n_brn_enable[3'b001]                     = 1'b1;
           n_brn_value[3'b001]                      = 1'b1; 
           n_dest                               = 3'b000;                                               
           end 
       8'h10: 
           begin
           n_length                             = 2'b10;
           n_relative                           = 1'b1;
           n_ctrl                               = 3'b111;   
           n_brn_enable[3'b111]                     = 1'b1;
           n_brn_value[3'b111]                      = 1'b0;   
           n_dest                               = 3'b000;                                               
           end 
       8'h30: 
           begin
           n_length                             = 2'b10;
           n_relative                           = 1'b1;
           n_ctrl                               = 3'b111;   
           n_brn_enable[3'b111]                     = 1'b1;
           n_brn_value[3'b111]                      = 1'b1;   
           n_dest                               = 3'b000;                  
           end 
       8'h50: 
           begin
           n_length                             = 2'b10;
           n_relative                           = 1'b1;
           n_ctrl                               = 3'b111;   
           n_brn_enable[3'b110]                     = 1'b1;
           n_brn_value[3'b110]                      = 1'b0;   
           n_dest                               = 3'b000;                                                         
           end 
       8'h70: 
           begin
           n_length                             = 2'b10;
           n_relative                           = 1'b1;
           n_ctrl                               = 3'b111;   
           n_brn_enable[3'b110]                     = 1'b1;
           n_brn_value[3'b110]                      = 1'b1;   
           n_dest                               = 3'b000;                                                         
           end 
// absolute
       8'h6D:
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;
           n_ins_type                           = 2'b01;     	      	       
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0; 
           n_alu_op_c_sel                       = 2'b10;
           n_alu_status_update                  = 5'b00111;
           n_dest                               = 3'b001;                                                         
           end 
       8'h2D: 
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;
           n_ins_type                           = 2'b01;     	      	       
           n_alu_mode                           = 3'b001;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b11;	      
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;
           n_dest                               = 3'b001;                                                                   
           end 
       8'h0E: 
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;
           n_ins_type                           = 2'b11;     	      	       
           n_alu_mode                           = 3'b100;
           n_alu_op_a_sel                       = 3'b000;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00011;
           n_dest                               = 3'b100;                                                                   
           end 
       8'h2C: 
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;
           n_ins_type                           = 2'b01;     	      	       
           n_alu_mode                           = 3'b001;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b10000;
           n_dest                               = 3'b000;                                                                   
           end 
       8'hCD: 
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;
           n_ins_type                           = 2'b01;     	      	       
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b1;        
           n_alu_op_c_sel                       = 2'b01;
           n_alu_status_update                  = 5'b00011;
           n_dest                               = 3'b000;                                                                   
           end 
       8'hEC: 
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;
           n_ins_type                           = 2'b01;     	      	       	      
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b010;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b1;  
           n_alu_op_c_sel                       = 2'b01;
           n_alu_status_update                  = 5'b00011; 
           n_dest                               = 3'b000;                                                                        
           end 
       8'hCC: 
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;
           n_ins_type                           = 2'b01;     	      	       
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b011;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b1;
           n_alu_op_c_sel                       = 2'b01;
           n_alu_status_update                  = 5'b00011;
           n_dest                               = 3'b000;                                                                                  
           end 
       8'hCE: 
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;
           n_ins_type                           = 2'b11;     	      	       
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b100;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;
           n_dest                               = 3'b100;                                                                                  
           end 
       8'h4D: 
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;
           n_ins_type                           = 2'b01;     	      	       
           n_alu_mode                           = 3'b011;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;
           n_dest                               = 3'b001;                                                                         
          end 
       8'hEE: 
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;
           n_ins_type                           = 2'b11;     	      	       
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b000;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;
           n_alu_op_c_sel                       = 2'b01;
           n_alu_status_update                  = 5'b00001;
           n_dest                               = 3'b100;                                                                         
           end 
       8'hAD: 
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;
           n_ins_type                           = 2'b01;     	      	       
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b000;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;  
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;          
           n_dest                               = 3'b001;                                                                         
           end 
       8'hAE: 
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;
           n_ins_type                           = 2'b01;     	      	       
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b000;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;  
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;          
           n_dest                               = 3'b010;                                                                         
           end 
       8'hAC: 
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;
           n_ins_type                           = 2'b01;     	      	       
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b000;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;  
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;          
           n_dest                               = 3'b011;                                                                         
           end 
       8'h4E: 
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;
           n_ins_type                           = 2'b11;     	      	       
           n_alu_mode                           = 3'b101;
           n_alu_op_a_sel                       = 3'b000;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00011;       
           n_dest                               = 3'b100;
           end 
       8'h0D: 
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;
           n_ins_type                           = 2'b01;     	      	       
           n_alu_mode                           = 3'b010;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;       
           n_dest                               = 3'b001;
           end 
       8'h2E: 
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;
           n_ins_type                           = 2'b11;     	      	       
           n_alu_mode                           = 3'b100;
           n_alu_op_a_sel                       = 3'b000;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b10;
           n_alu_status_update                  = 5'b00011;       
           n_dest                               = 3'b100;
           end 
       8'h6E: 
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;
           n_ins_type                           = 2'b11;     	      	       
           n_alu_mode                           = 3'b101;
           n_alu_op_a_sel                       = 3'b000;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b10;
           n_alu_status_update                  = 5'b00011;       
           n_dest                               = 3'b100;
           end 
       8'hED: 
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;
           n_ins_type                           = 2'b01;     	      	       
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b11;	      
           n_alu_op_b_inv                       = 1'b1;  
           n_alu_op_c_sel                       = 2'b10;
           n_alu_status_update                  = 5'b00111;       
           n_dest                               = 3'b001; 
           end 
       8'h8D: 
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;
           n_ins_type                           = 2'b10;     	      	       
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_inv                       = 1'b0;
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00000;  
           n_dest                               = 3'b100;
           end 
       8'h8E: 
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;
           n_ins_type                           = 2'b10;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b010;
           n_alu_op_b_inv                       = 1'b0;
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00000;
           n_dest                               = 3'b100;
           end 
       8'h8C: 
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;
           n_ins_type                           = 2'b10;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b011;
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00000;
           n_dest                               = 3'b100;
           end  
// absolute_indexed
       8'h7D: 
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;
	   n_idx_sel                            = 2'b01;      
           n_ins_type                           = 2'b01;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0; 
           n_alu_op_c_sel                       = 2'b10;
           n_alu_status_update                  = 5'b00111;  
           n_dest                               = 3'b001;
           end 
       8'h3D: 
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;
	   n_idx_sel                            = 2'b01;      
           n_ins_type                           = 2'b01;
           n_alu_mode                           = 3'b001;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;
           n_dest                               = 3'b001;
           end 
       8'h1E: 
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;  
	   n_idx_sel                            = 2'b01;      
           n_ins_type                           = 2'b11;
           n_alu_mode                           = 3'b100;
           n_alu_op_a_sel                       = 3'b000;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00011;
           n_dest                               = 3'b100;
           end 
       8'hDD: 
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;
	   n_idx_sel                            = 2'b01;      
           n_ins_type                           = 2'b01;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b1;        
           n_alu_op_c_sel                       = 2'b01;
           n_alu_status_update                  = 5'b00011;
           n_dest                               = 3'b000;
           end 
       8'hDE: 
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;
	   n_idx_sel                            = 2'b01;      
           n_ins_type                           = 2'b11;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b100;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;
           n_dest                               = 3'b100;
           end 
       8'h5D: 
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;
	   n_idx_sel                            = 2'b01;      
           n_ins_type                           = 2'b01;
           n_alu_mode                           = 3'b011;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;
           n_dest                               = 3'b001;
           end 
       8'hFE: 
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;
	   n_idx_sel                            = 2'b01;      
           n_ins_type                           = 2'b11;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b000;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;
           n_alu_op_c_sel                       = 2'b01;
           n_alu_status_update                  = 5'b00001;
           n_dest                               = 3'b100;
           end  
       8'hBD: 
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;
	   n_idx_sel                            = 2'b01;      
           n_ins_type                           = 2'b01;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b000;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;  
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;          
           n_dest                               = 3'b001;
           end 
       8'hBC: 
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;
	   n_idx_sel                            = 2'b01;      
           n_ins_type                           = 2'b01;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b000;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;  
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;          
           n_dest                               = 3'b011;
           end 
       8'h5E: 
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;
	   n_idx_sel                            = 2'b01;      
           n_ins_type                           = 2'b11;
           n_alu_mode                           = 3'b101;
           n_alu_op_a_sel                       = 3'b000;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00011;       
           n_dest                               = 3'b100;
           end 
       8'h1D: 
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;
	   n_idx_sel                            = 2'b01;      
           n_ins_type                           = 2'b01;	      
           n_alu_mode                           = 3'b010;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;       
           n_dest                               = 3'b100;
           end 
       8'h3E: 
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;
	   n_idx_sel                            = 2'b01;      
           n_ins_type                           = 2'b11;
           n_alu_mode                           = 3'b100;
           n_alu_op_a_sel                       = 3'b000;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b10;
           n_alu_status_update                  = 5'b00011;       
           n_dest                               = 3'b100;
           end 
       8'h7E:
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;
	   n_idx_sel                            = 2'b01;      
           n_ins_type                           = 2'b11;
           n_alu_mode                           = 3'b101;
           n_alu_op_a_sel                       = 3'b000;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b10;
           n_alu_status_update                  = 5'b00011;       
           n_dest                               = 3'b100;
           end  
       8'hFD: 
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;
	   n_idx_sel                            = 2'b01;      
           n_ins_type                           = 2'b01;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b1;  
           n_alu_op_c_sel                       = 2'b10;
           n_alu_status_update                  = 5'b00111;       
           n_dest                               = 3'b001;
           end 
       8'h9D: 
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;
	   n_idx_sel                            = 2'b01;      
           n_ins_type                           = 2'b10;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_inv                       = 1'b0;
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00000;  
           n_dest                               = 3'b100;
           end 
       8'h79: 
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;
	   n_idx_sel                            = 2'b10;      
           n_ins_type                           = 2'b01;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0; 
           n_alu_op_c_sel                       = 2'b10;
           n_alu_status_update                  = 5'b00111;  
           n_dest                               = 3'b001;
           end 
       8'h39: 
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;
	   n_idx_sel                            = 2'b10;      
           n_ins_type                           = 2'b01;
           n_alu_mode                           = 3'b001;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b11; 
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;
           n_dest                               = 3'b001;	      
           end  
       8'hD9: 
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;
	   n_idx_sel                            = 2'b10;      
           n_ins_type                           = 2'b01;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b1;        
           n_alu_op_c_sel                       = 2'b01;
           n_alu_status_update                  = 5'b00011;
           n_dest                               = 3'b000;
           end 
       8'h59: 
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;
	   n_idx_sel                            = 2'b10;      
           n_ins_type                           = 2'b01;
           n_alu_mode                           = 3'b011;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;
           n_dest                               = 3'b001;
           end 
       8'hB9: 
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;
	   n_idx_sel                            = 2'b10;   
           n_ins_type                           = 2'b01;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b000;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;  
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;       
           n_dest                               = 3'b001;
           end 
       8'hBE: 
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;
	   n_idx_sel                            = 2'b10;   
           n_ins_type                           = 2'b01;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b000;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;  
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;    
           n_dest                               = 3'b010;
           end 
       8'h19: 
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;
	   n_idx_sel                            = 2'b10;      
           n_ins_type                           = 2'b01;
           n_alu_mode                           = 3'b010;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;      
           n_dest                               = 3'b001;
           end 
       8'hF9: 
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;
	   n_idx_sel                            = 2'b10;      
           n_ins_type                           = 2'b01;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b1;  
           n_alu_op_c_sel                       = 2'b10;
           n_alu_status_update                  = 5'b00111;      
           n_dest                               = 3'b001;
           end 
       8'h99: 
           begin
           n_length                             = 2'b11;
           n_absolute                           = 1'b1;
	   n_idx_sel                            = 2'b10;   
           n_ins_type                           = 2'b10;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_inv                       = 1'b0;
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00000;  
           n_dest                               = 3'b100;
           end 
// indirectx
       8'h61: 
           begin
           n_length                             = 2'b10;	    
           n_indirectx                          = 1'b1;
	   n_idx_sel                            = 2'b01;   
           n_ins_type                           = 2'b01;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0; 
           n_alu_op_c_sel                       = 2'b10;
           n_alu_status_update                  = 5'b00111;  
           n_dest                               = 3'b001;
           end 
       8'h21: 
           begin
           n_length                             = 2'b10;
           n_indirectx                          = 1'b1;
	   n_idx_sel                            = 2'b01;      
           n_ins_type                           = 2'b01;
           n_alu_mode                           = 3'b001;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;
           n_dest                               = 3'b001;
           end 
       8'hC1: 
           begin
           n_length                             = 2'b10;
           n_indirectx                          = 1'b1;
	   n_idx_sel                            = 2'b01;   
           n_ins_type                           = 2'b01;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b1;        
           n_alu_op_c_sel                       = 2'b01;
           n_alu_status_update                  = 5'b00011;
           n_dest                               = 3'b000;
           end 
       8'h41: 
           begin
           n_length                             = 2'b10;
           n_indirectx                          = 1'b1;
	   n_idx_sel                            = 2'b01;   
           n_ins_type                           = 2'b01;
           n_alu_mode                           = 3'b011;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;
           n_dest                               = 3'b001;
           end 
       8'hA1: 
           begin
           n_length                             = 2'b10;
           n_indirectx                          = 1'b1;
	   n_idx_sel                            = 2'b01;   
           n_ins_type                           = 2'b01;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b000;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;  
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;       
           n_dest                               = 3'b001;
           end 
       8'h01: 
           begin
           n_length                             = 2'b10;
           n_indirectx                          = 1'b1;
	   n_idx_sel                            = 2'b01;   
           n_ins_type                           = 2'b01;
           n_alu_mode                           = 3'b010;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;      
           n_dest                               = 3'b001;
           end 
       8'hE1: 
           begin
           n_length                             = 2'b10;
           n_indirectx                          = 1'b1;
	   n_idx_sel                            = 2'b01;   
           n_ins_type                           = 2'b01;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b11; 
           n_alu_op_b_inv                       = 1'b1;  
           n_alu_op_c_sel                       = 2'b10;
           n_alu_status_update                  = 5'b00111;      
           n_dest                               = 3'b001;
           end 
       8'h81: 
           begin
           n_length                             = 2'b10;
           n_indirectx                          = 1'b1;
	   n_idx_sel                            = 2'b01;   
           n_ins_type                           = 2'b10;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_inv                       = 1'b0;
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00000;  
           n_dest                               = 3'b100;
           end 
// indirecty
       8'h71: 
           begin 
           n_length                             = 2'b10;
           n_indirecty                          = 1'b1;
	   n_idx_sel                            = 2'b10;   
           n_ins_type                           = 2'b01;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0; 
           n_alu_op_c_sel                       = 2'b10;
           n_alu_status_update                  = 5'b00111;  
           n_dest                               = 3'b001;
           end 
       8'h31: 
           begin 
           n_length                             = 2'b10;
           n_indirecty                          = 1'b1;
	   n_idx_sel                            = 2'b10;   
           n_ins_type                           = 2'b01;
           n_alu_mode                           = 3'b001;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;
           n_dest                               = 3'b001;
           end 
       8'hD1: 
           begin 
           n_length                             = 2'b10;
           n_indirecty                          = 1'b1;
	   n_idx_sel                            = 2'b10;   
           n_ins_type                           = 2'b01;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b1;        
           n_alu_op_c_sel                       = 2'b01;
           n_alu_status_update                  = 5'b00011;
           n_dest                               = 3'b000;
           end 
       8'h51: 
           begin 
           n_length                             = 2'b10;
           n_indirecty                          = 1'b1;
	   n_idx_sel                            = 2'b10;   
           n_ins_type                           = 2'b01;
           n_alu_mode                           = 3'b011;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b11;	      
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;
           n_dest                               = 3'b001;
           end 
       8'hB1: 
           begin 
           n_length                             = 2'b10;
           n_indirecty                          = 1'b1;
	   n_idx_sel                            = 2'b10;      
           n_ins_type                           = 2'b01;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b000;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;  
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;       
           n_dest                               = 3'b001;
           end 
       8'h11: 
           begin 
           n_length                             = 2'b10;
           n_indirecty                          = 1'b1;
	   n_idx_sel                            = 2'b10;   
           n_ins_type                           = 2'b01;
           n_alu_mode                           = 3'b010;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;      
           n_dest                               = 3'b001;
           end 
       8'hF1: 
           begin 
           n_length                             = 2'b10;
           n_indirecty                          = 1'b1;
           n_idx_sel                            = 2'b10;   
           n_ins_type                           = 2'b01;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b1;  
           n_alu_op_c_sel                       = 2'b10;
           n_alu_status_update                  = 5'b00111;      
           n_dest                               = 3'b001;
           end 
       8'h91: 
           begin 
           n_length                             = 2'b10;
           n_indirecty                          = 1'b1;
	   n_idx_sel                            = 2'b10;   
           n_ins_type                           = 2'b10;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_inv                       = 1'b0;
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00000;  
           n_dest                               = 3'b100;
           end 
// stack
       8'h48: 
           begin
           n_length                             = 2'b01;
           n_stack                              = 1'b1;
           n_ins_type                           = 2'b10;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b001;
           n_alu_op_b_inv                       = 1'b0;
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00000;  
           n_dest                               = 3'b000;	      
           end
       8'h08: 
           begin
           n_length                             = 2'b01;
           n_stack                              = 1'b1;	      
           n_ins_type                           = 2'b10;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b101;
           n_alu_op_b_inv                       = 1'b0;
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00000;  
           n_dest                               = 3'b100;	      
           end
       8'h68: 
           begin
           n_length                             = 2'b01;
           n_stack                              = 1'b1;
           n_ins_type                           = 2'b01;	      
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b000;
           n_alu_op_b_sel                       = 2'b10;
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b00001;
           n_dest                               = 3'b001;	      
           end
       8'h28: 
           begin
           n_length                             = 2'b01;
           n_stack                              = 1'b1;
           n_ins_type                           = 2'b01;  	      
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b000;
           n_alu_op_b_sel                       = 2'b10;	      
           n_alu_op_b_inv                       = 1'b0;        
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b11000;
           n_dest                               = 3'b000;	               
           end
// jump
       8'h4C: 
           begin
           n_length                             = 2'b11;
           n_jump                               = 1'b1;
           n_ctrl                               = 3'b010;   
           end
// jump_indirect     
       8'h6C: 
           begin
           n_length                             = 2'b11;
           n_jump_indirect                      = 1'b1;
           n_ctrl                               = 3'b011;   
           end
// jump_subroutine
       8'h20: 
           begin
           n_length                             = 2'b11;
           n_jsr                                = 1'b1;
           n_ctrl                               = 3'b001;   
           end
// break     
// ??????????  Need to update alu_status at the end of this instruction
       8'h00: 
           begin
           n_length                             = 2'b01;
           n_brk                                = 1'b1;
           n_ctrl                               = 3'b100;   
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b101;
           n_alu_op_b_inv                       = 1'b0;
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b01000;  
           n_brn_value                          = 8'h10; // BRK bit in psr
           n_brn_enable                         = 8'h10;
           n_dest                               = 3'b000;
          end
// return for int
       8'h40: 
           begin
           n_length                             = 2'b01;
           n_rti                                = 1'b1;
           n_ctrl                               = 3'b101;   
           n_ins_type                           = 2'b01;
           n_alu_mode                           = 3'b000;
           n_alu_op_a_sel                       = 3'b000;
           n_alu_op_b_sel                       = 2'b11;
           n_alu_op_b_inv                       = 1'b0;
           n_alu_op_c_sel                       = 2'b00;
           n_alu_status_update                  = 5'b11000; 
           n_dest                               = 3'b000;
         end
// return from sub
       8'h60: 
           begin
           n_length                             = 2'b01;
           n_rts                                = 1'b1;
           n_ctrl                               = 3'b110;   
           end
       default: 
           begin
           n_invalid                            = 1'b1;
           n_ins_type                           = 2'b00;
           end
  endcase
 end // always @ (*)
endmodule
module core_def_sequencer
#(parameter VEC_TABLE = 8'hff,
  parameter STATE_SIZE=3
)
(
    input  wire            clk,         
    input  wire            reset,        
    input  wire            enable,
    input  wire            now_fetch_op,
    input  wire    [STATE_SIZE:0]   state,         // current and next state registers
    input  wire    [1:0]   cmd,         
    input  wire    [7:0]   vector,         
    input  wire    [1:0]   length,         
    input  wire    [7:0]   alu_a,     
    input  wire    [7:0]   alu_result,    // result from alu operation
    input  wire    [7:0]   alu_status,    // 
    input  wire    [7:0]   data_in,       // data that comes from the bus controller
    input  wire    [15:0]  prog_data16,       // data that comes from the bus controller
    input  wire    [7:0]   prog_data,
    input  wire    [7:0]   pg0_data,
    input  wire    [7:0]   index,         // selected index 
    input  wire    [1:0]   ins_type,
    input  wire    [2:0]   alu_op_a_sel,
    input  wire            implied,
    input  wire            immediate,  
    input  wire            relative,
    input  wire            absolute,
    input  wire            zero_page,
    input  wire            indirectx,
    input  wire            indirecty, 
    input  wire            stack,
    input  wire            jump_indirect,
    input  wire            brk,
    input  wire            rti,
    input  wire            rts,
    input  wire            jump,
    input  wire            jsr,
    input  wire            branch_inst, 
    output  reg            fetch_op,
    output  reg   [15:0]   prog_counter,            // program counter
    output  reg   [15:0]   address,       // system bus address
    output  reg            alu_enable,       
    output  reg    [7:0]   pg0_add,       
    output  reg            pg0_wr,       
    output  reg            pg0_rd,       
    output  reg   [7:0]    operand,        
    output  reg   [7:0]    imm_data,       
    output  reg            rd,        // read = 1
    output  reg            wr,        // write = 1
    output  reg    [7:0]   data_out,      // data that will be written somewhere else
    output  reg    [15:0]  offset,
    output  reg            stk_push,
    output  reg  [15:0]    stk_push_data,
    output  reg            stk_pull,
    input  wire  [15:0]    stk_pull_data      
);
  reg 		   stk_push_p;
 wire [15:0]   next_pc;             // a simple logic to add one to the PC
 wire  [8:0]   p_indexed;  
 assign next_pc              = prog_counter + 16'b0000000000000001;
 assign p_indexed            = prog_data +index;
always @ (posedge clk ) 
   if (reset)     stk_push              <= 1'b1;  
   else           stk_push              <= stk_push_p  || 
                                           (stack   &&   !enable &&   (state == 4'b0101 )  &&     (ins_type == 2'b10 )) ||   
                                           (              enable &&   (state != 4'b1110 )  &&     now_fetch_op &&   (cmd == 2'b11))  ;
always @ (posedge clk ) begin 
   if (reset) 
        begin
            stk_push_p      <=  1'b0;
        end 
   else if(!enable)
        begin
            stk_push_p      <=  1'b0;
        end
    else begin
            case (state)
                4'b0101: 
                    begin
		     if( jsr )  
                          begin
			  stk_push_p         <= 1'b1;
                          end            
                    end
                default: 
                  begin
                   stk_push_p      <=  1'b0;
                  end                    
            endcase
        end
    end
always @ (posedge clk ) begin 
   if (reset) 
        begin
            stk_pull        <=  1'b0;
        end 
   else if( enable)
        begin
            stk_pull        <=  1'b0;
        end
    else begin
            case (state)
                4'b0101: 
                    begin
                     if( rts || rti)  
                       begin
		       stk_pull               <= 1'b1;   	  
                       end
                     else
                     if( stack )  
                       begin
			if(ins_type == 2'b01 )
                         begin
		         stk_pull             <= 1'b1;   	  
			 end 
	               end
                    end
                default: 
                  begin
                   stk_pull        <=  1'b0;     
                  end                    
            endcase
        end
    end
always @ (posedge clk ) 
   begin 
   if (reset)                                      stk_push_data      <= 16'h0000;
   else 
   if((state ==  4'b0011)  &&  jsr )                stk_push_data      <= prog_counter;
   else
   if((cmd == 2'b11) && now_fetch_op )     stk_push_data      <= prog_counter;
   else                                            stk_push_data      <= (alu_op_a_sel ==  3'b101)? {alu_status,alu_status}:{alu_a,alu_a};
   end
always @ (posedge clk ) 
   begin 
   if (reset) 
        begin
            prog_counter    <= 16'h0000;  
            alu_enable      <=  1'b0;
            pg0_add         <=  8'h00;
            pg0_wr          <=  1'b0;
            pg0_rd          <=  1'b0;
            fetch_op        <=  1'b0;
            operand         <=  8'h00;        
            imm_data        <=  8'h00;
            address         <= 16'h0000;
            rd          <=  1'b0;       
            wr          <=  1'b0;
            data_out        <=  8'h00;
            offset          <=  16'h0000;
        end // if (reset)
   else if(!enable)
           begin
            case (state)
                4'b0101: 
                    begin
                     if( jump || jsr || absolute)  
                       begin
		       prog_counter           <= next_pc;             	  	  
                       end
                    end
                4'b0011: 
                    begin
		     if( jump || jsr  )  
                       begin
		          prog_counter       <= {prog_data,address[7:0]};
                          end
                     else
		     if( absolute  )  
                       begin
                        address               <= {prog_data,8'h00}  + {7'b0000000,address[8:0]};
                        if((ins_type == 2'b01) || (ins_type == 2'b11))
                           begin
                           rd             <= 1'b1;                           
                           end
                          end                     
                    end 
              default:
             begin
            prog_counter    <=  prog_counter;      
            pg0_add         <=  pg0_add;
            pg0_wr          <=  pg0_wr;
            pg0_rd          <=  pg0_rd;	   
            alu_enable      <=  alu_enable;
            operand         <=  operand;
            imm_data        <=  imm_data;
            address         <=  address;
            rd          <=  rd;
	    fetch_op        <=  fetch_op;
            wr          <=  wr;
            data_out        <=  data_out;
            offset          <=  offset;
        end
	    endcase // case (state)
	   end
    else begin
            case (state)
                4'b0000: 
                    begin 
                     prog_counter             <=  {VEC_TABLE,vector}; 
                    end
                4'b0100:
                    begin 
                     prog_counter             <= next_pc;
                    end
                4'b0101: 
                    begin
                       alu_enable             <= 1'b0;
                       wr                 <= 1'b0;
		       pg0_wr                 <= 1'b0;
                     if(immediate)  
                       begin
		       prog_counter           <= next_pc;             	  
                       imm_data               <= prog_data;
		       alu_enable             <= 1'b1;
                       fetch_op               <= 1'b1;  
                       end          
                     else
                     if(zero_page  )  
                       begin
		       prog_counter           <= next_pc;             	  
                       address                <= {8'h00,p_indexed[7:0]};
                       pg0_add                <= p_indexed[7:0];
                       alu_enable             <= 1'b1;
		       fetch_op               <= 1'b1;  	  
                       if((ins_type == 2'b01) || (ins_type == 2'b11))
                          begin
		          pg0_rd              <= 1'b1;
                          end
                       end
                     else
                     if( absolute || jump  || jsr || jump_indirect)  
                       begin
		       prog_counter           <= next_pc;             	  
                       address                <= {7'b0000000,p_indexed};
		       pg0_add                <= p_indexed[7:0];	  
                       end
                     else
                     if( relative )  
                       begin
                         fetch_op             <= 1'b1;  
			 alu_enable           <= 1'b1; 
                         if(branch_inst)
                         prog_counter         <= prog_counter + 1'b1 + { prog_data[7],prog_data[7],prog_data[7],prog_data[7], 
                                                 prog_data[7],prog_data[7],prog_data[7],prog_data[7],prog_data} ;
                         else
                         prog_counter         <= next_pc;             	   
                       end	    
                     else
                     if( rts || rti)  
                       begin
		       prog_counter           <= stk_pull_data;
                       end
                     else
                     if( stack )  
                       begin
	               prog_counter           <= next_pc;                	  
			if(ins_type == 2'b01 )
                         begin
                         operand              <= stk_pull_data[7:0];	                 
			 end 
	               end
                     else
                     if(indirectx  )  
                       begin
		       prog_counter           <= next_pc;             	  
                       pg0_add                <= p_indexed[7:0];
                       pg0_rd                 <= 1'b1;
                       end 
                     else
                     if(indirecty  )  
                       begin
		       prog_counter           <= next_pc;             	  
                       pg0_add                <= prog_data;
                       pg0_rd                 <= 1'b1;
                       end 
                     else
                      prog_counter            <= next_pc;                
                    end
                4'b0110: 
                    begin
                     if(immediate )  
                       begin
			fetch_op              <=  1'b0;  
                        prog_counter          <= next_pc;             
                        alu_enable            <= 1'b0;
                        end          
                     else
                     if(zero_page  )  
                       begin
			fetch_op              <=  1'b0;    
			prog_counter          <= next_pc;               
                        rd                <= 1'b0;
                        wr                <= 1'b0;
                        pg0_rd                <= 1'b0;
                        operand               <= data_in;
                        alu_enable            <= 1'b0;
                       if((ins_type == 2'b10 ) || (ins_type == 2'b11 ))
                          begin
		          pg0_wr              <= 1'b1;
                          data_out            <= alu_result;               
                          end                 
                        end          
                     else
                     if( relative )  
                       begin
			  fetch_op            <= 1'b0;  
                          alu_enable          <= 1'b0; 
                          prog_counter        <= next_pc;             	   
                          end	    
                     else
                     prog_counter            <= next_pc;             
                    end 
                4'b0011: 
                    begin
                     if(absolute  )  
                       begin
			fetch_op              <=  1'b1;    
			prog_counter          <= prog_counter;           
                        alu_enable            <= 1'b1;
                        end          
                     else
		     if(  jump || jsr)  
                       begin
			  fetch_op           <=  1'b1;  
		          prog_counter       <= prog_counter;
                          end
                     else
		     if( jump_indirect )  
                          begin
		          prog_counter       <= next_pc;
                          address            <= {prog_data,address[7:0]};
                          end            		       
                     else            
                     prog_counter            <= next_pc;             
                    end 
                4'b0111: 
                     begin
                     fetch_op          <= 1'b0;
                     prog_counter      <= next_pc;
                     rd            <= 1'b0;
                     pg0_rd            <= 1'b0;
                     operand           <= data_in;
		     alu_enable        <= 1'b0;  
                     if(absolute  )  
                       begin
                        if((ins_type == 2'b11 ) || (ins_type == 2'b10 ))
                           begin
                           wr       <= 1'b1;
                           data_out     <= alu_result;                                          
                           end                 
                       end			
                     end
                4'b1000: 
                     begin
                     prog_counter     <= prog_counter;
                     address[7:0]     <= pg0_data;
		     pg0_add          <= pg0_add + 1'b1;
                     pg0_rd           <= 1'b1;
                     end
                4'b1001: 
                     begin
                     prog_counter     <= prog_counter;
                     address[15:8]    <= pg0_data;
		     pg0_add          <= address[7:0];
		     alu_enable       <= 1'b1;
       	             fetch_op         <= 1'b1;    			
                     if( ins_type == 2'b01)
                          begin
                          rd      <= 1'b1;
                          pg0_rd      <= 1'b1;
                          end
                     else
                     if(ins_type == 2'b10 )
                          begin
                          wr       <= 1'b1;
			  pg0_rd       <= 1'b0;
                          data_out     <= alu_result;               
                          end                 
                     end
                4'b1010: 
                     begin
       	             fetch_op         <= 1'b0;    
                     prog_counter     <= next_pc;
         	     alu_enable       <= 1'b0;
                     rd           <= 1'b0;
                     wr           <= 1'b0;
                     pg0_rd           <= 1'b0;
                     pg0_wr           <= 1'b0;
                     end
                4'b1011: 
                     begin
                     prog_counter    <= prog_counter;
                     address[8:0]    <= pg0_data + index;
		     pg0_add         <= pg0_add + 1'b1;
                     pg0_rd          <= 1'b1;
                     end
                4'b1100: 
                     begin
                     prog_counter     <= prog_counter;
                     address[15:8]    <= pg0_data + {7'b0,address[8]} ;
		     pg0_add          <= address[7:0];
		     pg0_rd           <= 1'b0;
         	     alu_enable       <= 1'b1;
       	             fetch_op         <=  1'b1;    			
                     if( ins_type == 2'b01)
                          begin
                          rd      <= 1'b1;
                          pg0_rd      <= 1'b1;
                          end
                     else
                     if(ins_type == 2'b10 )
                       begin
	                  pg0_rd      <= 1'b0;
                          wr      <= 1'b1;
                          data_out    <= alu_result;               
                          end                 
                     end
                4'b1101: 
                     begin
       	             fetch_op         <=  1'b0;    
                     prog_counter     <= next_pc;
         	     alu_enable       <= 1'b0;
                     rd           <= 1'b0;
                     wr           <= 1'b0;
                     pg0_rd           <= 1'b0;
                     pg0_wr           <= 1'b0;
                     end
                4'b1110: 
                    begin
                    alu_enable               <= 1'b0;
                    if(cmd == 2'b11)
                       begin 
                       address               <=  16'h0000;
                       rd                <=  1'b0;
                       prog_counter          <=  {VEC_TABLE,vector}; 
                       end
                    else	      
                       begin 
                       prog_counter          <=  prog_data16;
                       end
                    end
                4'b1111: 
                    begin 
                     address               <=  16'h0000;
                     rd                <=  1'b0;               
                     prog_counter          <=  prog_data16;
                    end
                4'b0001: 
                    begin 
                    address                <= 16'h0000;
                    rd                 <= 1'b0;
                    wr                 <= 1'b0;
                    end
                default: 
                  begin
                    address                <= 16'h0000;
                    prog_counter           <= 16'h0000;
                    rd                 <= 1'b0;
                    wr                 <= 1'b0;
                end                    
            endcase
        end
    end
endmodule
module core_def_state_fsm
#(parameter STATE_SIZE=3)
(
    input  wire                 clk,         
    input  wire                 reset,        
    input  wire                 enable,
    input  wire                 run,          
    input  wire [1:0]           cmd,
    input  wire [1:0]           length,
    input  wire                 now_fetch_op,
    input  wire                 absolute,
    input  wire                 immediate,
    input  wire                 implied,    
    input  wire                 indirectx,
    input  wire                 indirecty,
    input  wire                 stack,
    input  wire                 relative, 
    input  wire                 brk,
    input  wire                 rts,
    input  wire                 jump_indirect,
    input  wire                 jump,
    input  wire                 jsr,
    input  wire                 rti,
    input  wire                 branch_inst,
    input  wire [1:0]           ins_type,    
    input  wire                 invalid,
    output reg  [STATE_SIZE:0] state
);
reg [STATE_SIZE:0]   next_state;
    always @ (posedge clk ) 
        begin 
        if (reset) 
              begin
              state            <=  4'b0000;
              end 
        else if(!enable)
              begin
              state            <= state ;
              end
        else  state            <= next_state;
        end 
    always @ (*) 
        begin 
        next_state   = 4'b0000; 
       if (reset) 
            begin
            next_state = 4'b0000;
            end
       else	   
       if (invalid ) 
            begin
            next_state = 4'b0001;
            end
        else 
       if ((cmd == 2'b11) &&  now_fetch_op      ) 
            begin
            if(state != 4'b1110)            next_state = 4'b1110;
	    else                           next_state = 4'b1111;
            end
        else 
        case (state)
            4'b0000: 
                   begin
                   next_state = 4'b1110;
		   end
            4'b0001: 
                   begin
                   next_state = 4'b0001;
                   end
            4'b0100: 
                   begin
                   next_state = 4'b0101;
                   end
            4'b0101: 
              begin
                  if(rts || rti)
		    next_state = 4'b0100;
                  else
                  if(indirectx)
		    next_state = 4'b1000;
                  else
                  if(indirecty)
		    next_state = 4'b1011;
                  else
                  if (absolute || jump || jsr || jump_indirect)
		    next_state = 4'b0011;
                  else		    
                  if(length == 2'b01)  
                     begin
                     next_state = 4'b0101;
                     end
                  else                                   
                     begin
                     next_state = 4'b0110;
	             end
                end
            4'b0110: 
              begin
                  if(length == 2'b10)                       
                    begin
                    next_state = 4'b0101;
                    end
                  else next_state = 4'b0111;
                end
            4'b0011: 
              begin
                 next_state = 4'b0111;
                end
            4'b0111: 
              begin
                  if(length == 2'b11)                       
                    begin
                    next_state = 4'b0101;
                    end
                  else next_state = 4'b0001;	       
                end
            4'b1000: 
                    begin
                    next_state = 4'b1001;          	       
                    end
            4'b1001: 
                    begin
                    next_state = 4'b1010;
                    end
            4'b1010: 
                    begin
                    next_state = 4'b0101;
                    end
            4'b1011: 
                    begin
                    next_state = 4'b1100;          	       
                    end
            4'b1100: 
                    begin
                    next_state = 4'b1101;
                    end
            4'b1101: 
                    begin
                    next_state = 4'b0101;
                    end
            4'b1110: 
                  begin
                  next_state = 4'b1111;
                  end	  
            4'b1111: 
                  begin
                  next_state = 4'b0100;
                  end
            default: 
                begin
                next_state = 4'b0001; 
                end
        endcase
    end
endmodule
