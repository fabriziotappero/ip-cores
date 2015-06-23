`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// IBM 650 Reconstruction in Verilog (i650)
// 
// This file is part of the IBM 650 Reconstruction in Verilog (i650) project
// http:////www.opencores.org/project,i650
//
// Description: Arithmetic operation control.
// 
// Additional Comments: See US 2959351, Fig. 85.
//
// Copyright (c) 2015 Robert Abeles
//
// This source file is free software; you can redistribute it
// and/or modify it under the terms of the GNU Lesser General
// Public License as published by the Free Software Foundation;
// either version 2.1 of the License, or (at your option) any
// later version.
//
// This source is distributed in the hope that it will be
// useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
// PURPOSE.  See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General
// Public License along with this source; if not, download it
// from http://www.opencores.org/lgpl.shtml
//////////////////////////////////////////////////////////////////////////////////
`include "defines.v"

module arith_ctl (
   input rst,
   input ap, bp, cp,
   input dx, d0, d5, d9, dxl, d0l, d1l,
   input wu,
    
   input [0:6] adder_out,
   input man_acc_reset, overflow_stop,
   input prog_add_d0,
   input half_correct_sig,
    
   output end_of_operation, arith_restart_d5, zero_insert, carry_blank,
          no_carry_blank, carry_insert, no_carry_insert,
   output reg compl_adj, divide, multiply, acc_true_add,
   output reg half_correct, hc_add_5
   );
   
   // registers to be defined:
   // reg compl_adj, divide, multiply;
   reg compl_result, end_mult_div, acc_compl_add, left_shift, shift_count,
       right_shift, dist_true;

   //-----------------------------------------------------------------------------
   // Special control circuits
   //
   // [88:70] Several special control circuits which are not associated with any
   // particular operation or group of operations are energized by the arithmetic
   // controls.
   //
   // These are: (1) Arithmetic operation and arithmetic restart. (2) Upper-lower
   // check (adder control gate). (3) Adder output zero insert control. (4) No
   // carry insert-carry blank and carry insert-no carry blank. (5) Accumulator
   // sign read-out.
   //-----------------------------------------------------------------------------

   //-----------------------------------------------------------------------------
   // Arithmetic operation and arithmetic restart
   //
   // [89:20] On arithmetic operations the restart signal is sent back to program
   // control shortly after the operation signal is received by arithmetic
   // control, before the operation is completed. This allows the control
   // commutator to advance on its "I" half cycle, find the next instruction and
   // begin its interpretation, concurrently with the performance of the operation
   // by arithmetic control. The control commutator's operation interlock will
   // prevent its advance beyond the point where there would be conflict between
   // the arithmetic operation in process and an operation called for by the new
   // instruction. Athe the end of the arithmetic operation in process, and end of
   // operation signal developed by arithmetic control releases the operation
   // interlock and allows the contorl commutator to advance.
   //-----------------------------------------------------------------------------
   reg arith_operation, arith_restart;
   assign arith_restart_d5 = arith_restart & d5;
   wire arith_op_on_p =   compl_adj
                        | divide
                        | multiply
                        | compl_result
                        | acc_true_add
                        | acc_compl_add
                        | hc_add_5
                        | left_shift
                        | shift_count
                        | right_shift
                        | overflow_stop
                        | end_mult_div;
                        
   always @(posedge ap)
      if (rst) begin
         arith_operation <= 0;
         arith_restart   <= 0;
      end else begin
         arith_operation <= arith_op_on_p? 1'b1
                          : dx?            1'b0
                          :                arith_operation;
         arith_restart   <= (arith_op_on_p & ~arith_operation)? 1'b1
                          : d9?                                 1'b0
                          :                                     arith_restart;
      end;
   digit_pulse eop (rst, bp, ~arith_operation, 1'b1, end_of_operation);

`ifdef 0
   //-----------------------------------------------------------------------------
   // Upper-lower check -- adder control gate
   //
   // [90:5] It will be recalled from the description of the one digit adder in
   // the section on basic principles that an upper-lower check gate was required
   // as on of the conditions necessary to allow the distributor early outputs
   // through to the adder, in either true or complement form. The purpose of this
   // gate is to insure that either an upper or a lower signal and not both has
   // been sensed and that both reset and no reset are not present before allowing
   // distributor values to enter the adder.
   //-----------------------------------------------------------------------------
   
   //-----------------------------------------------------------------------------
   // Adder output zero insert control
   //
   // [90:45] 
   //-----------------------------------------------------------------------------
   assign zero_insert =   dxl & right_shift
                        | (dxl | d0l) & left_shift
                        | (dxl | d0l) & acc_true_add & compl_adj
                        | end_mult_div & acc_true_add & dist_true
                                       & div & no_rem & wu
                        | d0l & add_or_subt_sig
                        | dxl & mult_or_div_sig
                        | left_shift & (dxl | (d1l & ~significant_digit))
                        | mult_div_left_shift & d1l
                        | d0l & significant_digit;

   //-----------------------------------------------------------------------------
   // Carry insertion
   //-----------------------------------------------------------------------------
   assign carry_blank     =  dxl 
                           | prog_add_d0 
                           | (d0l & ~compl_acc_or_dist & ~hc_add_5);
   assign no_carry_blank  =  d1 & sel_stor_add_tlu
                           | d1l & quotient_digit & compl_acc_or_dist
                           | d0l & ~quotient_digit & compl_acc_or_dist;
   assign carry_insert    =  d1 & sel_stor_add_tlu
                           | d1l & quotient_digit & compl_acc_or_dist
                           | d0l & ~quotient_digit & compl_acc_or_dist;
   assign no_carry_insert =  dxl
                           | prog_add_d0
                           | (d0l & ~compl_acc_or_dist & ~hc_add_5);

   //-----------------------------------------------------------------------------
   // Sign control
   //-----------------------------------------------------------------------------
   assign acc_plus_out  =   (((~rem & d0u & ~ap) | (d0l & ~ap)) & acc_plus)
                          | (d0u & rem & rem_plus & ~ap);
   assign acc_minus_out =   (((~rem & d0u & ~ap) | (d0l & ~ap)) & acc_plus)
                          | (d0u & rem & rem_minus & ~ap);
   wire acc_sign_reset =   (d1l & add_sign_ctrl & ~divide & ~multiply)
                         | (d0 & mult_or_div_sig & a_c);
   
   reg acc_plus, acc_minus;
   //wire acc_plus_on_p =   (carry_test & compl_result_test_sig)
   //                     | (add_or_subt_sig & reset_op)
   //                     | (rem_minus & 
   //wire acc_minus_on_p =
   

   //-----------------------------------------------------------------------------
   // Adder entry controls
   //-----------------------------------------------------------------------------
   
   
   //-----------------------------------------------------------------------------
   // Arithmetic control
   //-----------------------------------------------------------------------------
   wire end_true_add;
   
   //-----------------------------------------------------------------------------
   // Half correct control
   //-----------------------------------------------------------------------------
   wire hc_ed0l_9 = ed0l & half_correct 
                         & adder_out[`biq_b5] & adder_out[`biq_q4];
   
   always @(posedge rst, posedge cp) begin
      if (rst) begin
         half_correct <= 0;
         hc_add_5 <= 0;
      end else begin
         if (man_acc_reset | end_true_add) begin
            hc_add_5 <= 0;
         end else if (hc_ed0l_9) begin
            hc_add_5 <= 1;
         end
         if (hc_add_5 & ~hc_ed0l_9 & ed0l) begin
            half_correct <= 0;
         end else if (half_correct_sig) begin
            half_correct <= 1;
         end
      end
   end;
`endif
   
endmodule
