`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// IBM 650 Reconstruction in Verilog (i650)
// 
// This file is part of the IBM 650 Reconstruction in Verilog (i650) project
// http:////www.opencores.org/project,i650
//
// Description: Table look-up.
// 
// Additional Comments: See US 2959351, Fig. 86.
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

module tlu (
    input rst,
    input ap, bp,
    input dx, d0, d4, d5, d10,
    input dxl, d0l, d10u,
    input w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, 
    input wl, wu,
    input s0, s1, s2, s3, s4,
    
    input tlu_sig,
    input upper_sig, lower_sig, divide_on, mult_nozero_edxl,
    input carry_test_latch, tlu_or_acc_zero_check,
    input man_acc_reset, reset_sig, no_reset_sig,
    input acc_minus_sign, compl_adj, quot_digit_on,
    input dist_compl_add,
    input any_left_shift_on, right_shift_on, left_shift_on, mult_div_left_shift,
    input sig_digit_on, hc_add_5, mult_on, acc_true_add_gate,
    
    output tlu_on, early_dist_zero_entry, early_dist_zero_control,
    output reg prog_to_acc_add, prog_add,
    output prog_add_d0,
    output prog_ped_regen,
    output [0:9] special_digit,
    output tlu_band_change, dist_blank_gate, sel_stor_add_gate,
           ontime_dist_add_gate, upper_lower_check
    );

   //-----------------------------------------------------------------------------
   // Distributor zero entry and control gates
   //
   // On operations such as add or subtract lower, add or subtract upper,
   // multiply, divide, etc., the entire two words of the accumulator enter the
   // adder via adder entry A. The contents of the distributor enters adder entry
   // B, in place of the distributor early outputs, during the time that the upper
   // word is entering the adder. On an add lower operation, zeroes must be
   // substituted for the distributor values during upper word time.
   //
   // This is accomplised by the early distributor zero control gate and the early
   // distributor zero entry gate. The zero control gate blocks the early
   // distributor outputs and the zero entry gate raises the B0-Q0 lines to allow
   // a true or complement zero entry to adder entry B.
   //
   // These gates are developed by switch-mix circuitry under control of the upper
   // and lower word control latches 926 and 927 (Fig. 86a). These latches are
   // turned on at the beginning of a lower word interval by an upper, lower,
   // divide or multiply signal from the Op. code analysis circuits or by a TLU
   // signal (ed. via prog_acc_add latch). They remain on until the next DXL.
   // While on, their outputs switch with upper word or lower word timing gates as
   // shown in Figs. 86a, 86b, 86c and 86d to provide the zero control and zero
   // entry gates.
   //
   // A parallel circuit develops these gates for each D10 interval. This supplies
   // a zero to fill the gap created by the missing DX position of the distributor
   // (if there were a DX position it would be read out at D10 time).
   //
   // Another parallel circuit develops these gates for each DX interval to
   // substitute a zero early output in place of the sign indication (8 or 9)
   // contained in the D0 position for entry to the adder. The sign is only used
   // when the distributor word is sent to general storage or displayed.
   //-----------------------------------------------------------------------------
   reg upper_control, lower_control;
   assign early_dist_zero_entry   =   (lower_control & wu) | (upper_control & wl) 
                                                           | dx | d10;
   assign early_dist_zero_control = ~((lower_control & wu) | (upper_control & wl) 
                                                           | dx | d10);
   
   always @(posedge ap)
      if (rst) begin
         upper_control <= 0;
         lower_control <= 0;
      end else if (dxl) begin // in lieu of wpl
         upper_control <= 0;
         lower_control <= 0;
      end else begin
         if (upper_sig | divide_on)
            upper_control <= 1;
         if (lower_sig | mult_nozero_edxl | prog_to_acc_add)
            lower_control <= 1;
      end;
   
   //-----------------------------------------------------------------------------
   // Program to accumulator control latch
   //
   // [125:10] Program to accumulator control latch 1195 (Fig. 86d). On when TLU
   // carry latch goes off at end of address adjustment cycle. Off next NWPU. When
   // on, causes entry of the program register contents to adder A during a lower
   // word interval; the entry of a special digit zeros to adder B to merge with
   // the program register values and the development of a distributor blanking
   // gate; the entry of the D5 through D8 adder outputs into the corresponding
   // lower accumulator positions and the entry of all adder outputs back into the
   // program register.
   //-----------------------------------------------------------------------------  
   always @(posedge ap)
      if (rst) begin
         prog_to_acc_add <= 0;
      end else if (dx & wu) begin
         prog_to_acc_add <= 0;
      end else if (tlu_carry_off_sig) begin
         prog_to_acc_add <= 1;
      end;
   
   //-----------------------------------------------------------------------------
   // TLU program add latch
   //
   // [124:65] TLU program add latch 1037 (Fig. 86b). On, DX and TLU band change
   // signal (S4, W8), or DX and TLU carry latch on, or DX and coincidence of
   // program to accumulator latch on and lower control latch on. Off next NWP.
   // Develops gates which allow program register early outputs to enter adder and
   // adder outputs to control program register pedistals. Also control no-carry
   // insert on program add.
   //-----------------------------------------------------------------------------
   assign prog_add_d0 = prog_add & d0;
   
   wire prog_add_on_p = tlu_carry | tlu_band_change 
                                  | (prog_to_acc_add & lower_control);
   always @(posedge bp)
      if (rst) begin
         prog_add <= 0;
      end else if (dx) begin // in lieu of wp
         prog_add <= prog_add_on_p;
      end;
   
   //-----------------------------------------------------------------------------
   // TLU program register regeneration control
   //
   // [124:75] TLU program regeneration control latch 1194 (Fig. 86b). Off with
   // same conditions which turn TLU program add latch on. On with the next WP.
   // When off, interrupts program register regeneration by blocking the path
   // between program on time latch outputs and pedistal lines.
   //-----------------------------------------------------------------------------
   reg prog_ped_regen_latch;
   assign prog_ped_regen = prog_ped_regen_latch; // & ~ap;
   
   always @(posedge bp)
      if (rst) begin
         prog_ped_regen_latch <= 0;
      end else if (prog_add_on_p) begin
         prog_ped_regen_latch <= 0;
      end else if (dx) begin
         prog_ped_regen_latch <= 1;
      end;
   
   //-----------------------------------------------------------------------------
   // TLU Carry Latch
   //
   // [125:5] TLU carry latch 918 (Fig. 86d). On, DX, A-C gate and adder carry.
   // Off next NWP. Controls addition of proper number to program register D5 and
   // D6 position, depending on which word time it is turned on.
   //-----------------------------------------------------------------------------
   reg tlu_carry;
   
   always @(posedge ap)
      if (rst) begin
         tlu_carry <= 0;
      end else if (dx) begin
         tlu_carry <= tlu_control & (carry_test_latch | tlu_or_acc_zero_check);
      end;
   
   wire tlu_carry_off_sig;
   digit_pulse tc_sig (rst, bp, ~tlu_carry, 1'b1, tlu_carry_off_sig);
   
   //-----------------------------------------------------------------------------
   // TLU Control Latch
   // 
   // [124:60] TLU control latch 916 (Fig. 86c). On, TLU signal, D0, S4, W9. Off
   // when TLU carry latch comes on. Sets up TLU operation.
   //-----------------------------------------------------------------------------
   reg tlu_control;
   wire tlu_control_on_p  = tlu_sig & s4 & w9 & d0;
   wire tlu_control_off_p = man_acc_reset | tlu_carry;
   assign tlu_on = tlu_control;
   
   always @(posedge bp)
      if (rst) begin
         tlu_control <= 0;
      end else if (tlu_control_off_p) begin
         tlu_control <= 0;
      end else if (tlu_control_on_p) begin
         tlu_control <= 1;
      end;

   //-----------------------------------------------------------------------------
   // TLU band change signal
   //
   // [125:45] If an adder DX carry is not detected by S4, W8 time, a TLU band
   // change signal is developed. This signal resets the address register,
   // develops an address register read-in gate for D5 through D8 of the next word
   // interval, operates add zeros and add 5 circuits, turns on the program add
   // latch and turns off the TLU program regeneration control latch.
   //-----------------------------------------------------------------------------
   assign tlu_band_change = tlu_control & s4 & w8;
   
   //-----------------------------------------------------------------------------
   // Special digit gates
   //
   // [97:70] The special digit circuits provide a means of supplying specific
   // digit values to adder entry B. They are used to change the value contained
   // in an accumulator position as necessary to accomplish the operation. The
   // special digit circuits are used primarily in the shifting and TLU
   // operations.
   //-----------------------------------------------------------------------------
   wire d5_tlu_carry_no_w0 = tlu_carry & d5 & ~w0;
   wire d5_tlu_carry_w0    = tlu_carry & d5 & w0;
   wire tlu_carry_d4       = tlu_carry & d4;
   
   wire add_0 =  (tlu_band_change & ~d5)
               | (tlu_carry & ~(d4 | d5))
               | (tlu_carry_d4 & w1)
               | (d5_tlu_carry_no_w0 & s0)
               | (d5_tlu_carry_w0 & s1)
               | prog_to_acc_add
               | (acc_minus_sign & compl_adj)
               | (quot_digit_on & dxl)
               | (dxl & dist_compl_add)
               | (~add_1 & any_left_shift_on & ~dxl);
   wire add_1 =  (tlu_carry_d4 & w2)
               | (d5_tlu_carry_no_w0 & s1)
               | (d5_tlu_carry_w0 & s2)
               | (dxl & (right_shift_on | left_shift_on | mult_div_left_shift))
               | (dist_compl_add & quot_digit_on & d0l)
               | sig_digit_on;
   wire add_2 =  (tlu_carry_d4 & w3)
               | (d5_tlu_carry_no_w0 & s2)
               | (d5_tlu_carry_w0 & s3);
   wire add_3 =  (tlu_carry_d4 & w4)
               | (d5_tlu_carry_no_w0 & s3)
               | (d5_tlu_carry_w0 & s4);
   wire add_4 =  (tlu_carry_d4 & w5)
               | (d5_tlu_carry_no_w0 & s4);
   wire add_5 =  (tlu_band_change & d5)
               | (tlu_carry_d4 & w6)
               | (dxl & hc_add_5);
   wire add_6 =  (tlu_carry_d4 & w7);
   wire add_7 =  (tlu_carry_d4 & w8);
   wire add_8 =  (tlu_carry_d4 & w9);
   wire add_9 =  (tlu_carry_d4 & w0)
               | (d10u & mult_on & acc_true_add_gate);
   
   assign special_digit = {add_0, add_1, add_2, add_3, add_4,
                           add_5, add_6, add_7, add_8, add_9};
   
   //-----------------------------------------------------------------------------
   // Distributor blanking gate
   //
   // [97:70] The distributor blanking gate controls the distributor true and
   // distributor complement gates to allow early distributor outputs or
   // substituted through, to the adder B entry lines. This distributor blanking
   // gate is up for all operations where the distributor early outputs or
   // substituted zeros are used and is down for all operations where special
   // digits values are substituted in place of distributor outputs. It is
   // necessary to prevent a conflict of information from the two sources on the
   // adder input lines.
   //
   // The gate, which is normally up, is lowered by the inverted switch and mix
   // cicuitry output shown at Fig. 86h. It is lowered by all special digit gates,
   // by the right shift gate, left shift gate, left shift latch, complement
   // adjust gate, TLU selected storage add gate and the M-D left shift latch.
   //-----------------------------------------------------------------------------
   assign dist_blank_gate =  |special_digit; // TODO: finish logic
   
   //-----------------------------------------------------------------------------
   // Table look-up selected storage add gate and table look-up on time
   //  distributor add gate
   //
   // [96:65] On a table look-up operation (Fig 120), the contents of the first
   // 48 storage locations of a general storage band are successively compared
   // with the contents of the distributor. When a number in a general storage
   // location equals or exceeds the searching argument in the distributor, the
   // address of this location is placed in the "D" address positions of the
   // lower accumulator. The comparison is made by merging, in the adder, the
   // complement of the distributor on time outputs with the successive general
   // storage outputs and checking for a carry from the D10U position (at DXL
   // time). A TLU selected storage add gate and a TLU distributor add gate allow
   // these adder entries to be made.
   //
   // These control gates are developed when the TLU latch 916 (Fig. 86c) is on.
   // The latch output is switched at switch 1034 with a D1 through D10 gate and
   // a negative S4, W8, and 9 gate to provide the TLU selected storage add gate
   // from the output of cathode follower 1035 and TLU on time distributor add
   // gate from cathode follower 1036 for D1 through D10 of each word of the band
   // except words 48 and 49.
   //-----------------------------------------------------------------------------
   assign sel_stor_add_gate = 1'b0;
   assign ontime_dist_add_gate = 1'b0;
   assign upper_lower_check = 1'b0;
   
endmodule
