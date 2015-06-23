
//-----------------------------------------------------------------------------
//
// (c) Copyright 2009-2010 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//-----------------------------------------------------------------------------
// Project    : V5-Block Plus for PCI Express
// File       : cmm_errman_cor.v
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
/***********************************************************************

  Description:   

  This module figures out what to do for correctable errors:
    1) count up or count down,
    2) how much to add or to subtract
  It returns the number and a add/subtract_b signals to the error 
  tracking counter. The outputs are based on how many errors are 
  asserted by the error reporting modules.

***********************************************************************/


module cmm_errman_cor (
                cor_num,                // Output
                inc_dec_b,
                reg_decr_cor,

                add_input_one,      // Inputs
                add_input_two_n,
                add_input_three_n,
                add_input_four_n,
                add_input_five_n,
                add_input_six_n,
                decr_cor,
                rst,
                clk
                );


  output  [2:0] cor_num;
  output        inc_dec_b;              // 1 = increment, 0 = decrement 
  output        reg_decr_cor;

  input         add_input_one;
  input         add_input_two_n;
  input         add_input_three_n;
  input         add_input_four_n;
  input         add_input_five_n;
  input         add_input_six_n;
  input         decr_cor;
  input         rst;
  input         clk;
 

  //******************************************************************//
  // Reality check.                                                   //
  //******************************************************************//

  parameter FFD       = 1;        // clock to out delay model


  //******************************************************************//
  // Figure out how many errors to increment.                         //
  //******************************************************************//


  reg     [2:0] to_incr         /* synthesis syn_romstyle = "logic" */;
  reg           add_sub_b       /* synthesis syn_romstyle = "logic" */;
  reg           add_input_one_d;
  reg           add_input_two_n_d;
  reg           add_input_three_n_d;
  reg           add_input_four_n_d;
  reg           add_input_five_n_d;
  reg           add_input_six_n_d;

  always @(posedge clk)
  begin
    if (rst) begin
      add_input_one_d     <= #FFD 0;
      add_input_two_n_d   <= #FFD 1;
      add_input_three_n_d <= #FFD 1;
      add_input_four_n_d  <= #FFD 1;
      add_input_five_n_d  <= #FFD 1;
      add_input_six_n_d   <= #FFD 1;
    end else begin
      add_input_one_d     <= #FFD add_input_one;
      add_input_two_n_d   <= #FFD add_input_two_n;
      add_input_three_n_d <= #FFD add_input_three_n;
      add_input_four_n_d  <= #FFD add_input_four_n;
      add_input_five_n_d  <= #FFD add_input_five_n;
      add_input_six_n_d   <= #FFD add_input_six_n;
    end
  end

  always @*
  begin
    case ({add_input_six_n_d, add_input_one_d,    
           add_input_two_n_d, add_input_three_n_d, 
           add_input_four_n_d,  add_input_five_n_d})   // synthesis full_case parallel_case
    6'b00_0000: begin   to_incr  = 3'b101;
                        add_sub_b = 1'b1;                         
                end                                               
    6'b00_0001: begin   to_incr  = 3'b100;
                        add_sub_b = 1'b1;                         
                end                                               
    6'b00_0010: begin   to_incr  = 3'b100;
                        add_sub_b = 1'b1;                         
                end                                               
    6'b00_0011: begin   to_incr  = 3'b011;
                        add_sub_b = 1'b1;                         
                end                                               
    6'b00_0100: begin   to_incr  = 3'b100;
                        add_sub_b = 1'b1;                         
                end                                               
    6'b00_0101: begin   to_incr  = 3'b011;
                        add_sub_b = 1'b1;                         
                end                                               
    6'b00_0110: begin   to_incr  = 3'b011;
                        add_sub_b = 1'b1;                         
                end                                               
    6'b00_0111: begin   to_incr  = 3'b010;                      
                        add_sub_b = 1'b1;                         
                end                                               
    6'b00_1000: begin   to_incr  = 3'b100;
                        add_sub_b = 1'b1;                         
                end                                               
    6'b00_1001: begin   to_incr  = 3'b011;
                        add_sub_b = 1'b1;                         
                end                                               
    6'b00_1010: begin   to_incr  = 3'b011;
                        add_sub_b = 1'b1;                         
                end                                               
    6'b00_1011: begin   to_incr  = 3'b010;                      
                        add_sub_b = 1'b1;                         
                end                                               
    6'b00_1100: begin   to_incr  = 3'b011;
                        add_sub_b = 1'b1;                         
                end                                               
    6'b00_1101: begin   to_incr  = 3'b010;                      
                        add_sub_b = 1'b1;                         
                end                                               
    6'b00_1110: begin   to_incr  = 3'b010;                      
                        add_sub_b = 1'b1;                         
                end                                               
    6'b00_1111: begin   to_incr  = 3'b001;                      
                        add_sub_b = 1'b1;                         
                end                                               
    6'b01_0000: begin   to_incr  = 3'b110;
                        add_sub_b = 1'b1;
                end
    6'b01_0001: begin   to_incr  = 3'b101;
                        add_sub_b = 1'b1;
                end
    6'b01_0010: begin   to_incr  = 3'b101;
                        add_sub_b = 1'b1;
                end
    6'b01_0011: begin   to_incr  = 3'b100;
                        add_sub_b = 1'b1;
                end
    6'b01_0100: begin   to_incr  = 3'b101;
                        add_sub_b = 1'b1;
                end
    6'b01_0101: begin   to_incr  = 3'b100;
                        add_sub_b = 1'b1;
                end
    6'b01_0110: begin   to_incr  = 3'b100;
                        add_sub_b = 1'b1;
                end
    6'b01_0111: begin   to_incr  = 3'b011;
                        add_sub_b = 1'b1;
                end
    6'b01_1000: begin   to_incr  = 3'b101;
                        add_sub_b = 1'b1;
                end
    6'b01_1001: begin   to_incr  = 3'b100;
                        add_sub_b = 1'b1;
                end
    6'b01_1010: begin   to_incr  = 3'b100;
                        add_sub_b = 1'b1;
                end
    6'b01_1011: begin   to_incr  = 3'b011;
                        add_sub_b = 1'b1;
                end
    6'b01_1100: begin   to_incr  = 3'b100;
                        add_sub_b = 1'b1;
                end
    6'b01_1101: begin   to_incr  = 3'b011;
                        add_sub_b = 1'b1;
                end
    6'b01_1110: begin   to_incr  = 3'b011;
                        add_sub_b = 1'b1;
                end
    6'b01_1111: begin   to_incr  = 3'b010;
                        add_sub_b = 1'b1;
                end

    6'b10_0000: begin   to_incr  = 3'b100;                      
                        add_sub_b = 1'b1;                         
                end                                               
    6'b10_0001: begin   to_incr  = 3'b011;                      
                        add_sub_b = 1'b1;                         
                end                                               
    6'b10_0010: begin   to_incr  = 3'b011;                      
                        add_sub_b = 1'b1;                         
                end                                               
    6'b10_0011: begin   to_incr  = 3'b010;                      
                        add_sub_b = 1'b1;                         
                end                                               
    6'b10_0100: begin   to_incr  = 3'b011;                      
                        add_sub_b = 1'b1;                         
                end                                               
    6'b10_0101: begin   to_incr  = 3'b010;                      
                        add_sub_b = 1'b1;                         
                end                                               
    6'b10_0110: begin   to_incr  = 3'b010;                      
                        add_sub_b = 1'b1;                         
                end                                               
    6'b10_0111: begin   to_incr  = 3'b001;                      
                        add_sub_b = 1'b1;                         
                end                                               
    6'b10_1000: begin   to_incr  = 3'b011;                      
                        add_sub_b = 1'b1;                         
                end                                               
    6'b10_1001: begin   to_incr  = 3'b010;                      
                        add_sub_b = 1'b1;                         
                end                                               
    6'b10_1010: begin   to_incr  = 3'b010;                      
                        add_sub_b = 1'b1;                         
                end                                               
    6'b10_1011: begin   to_incr  = 3'b001;                      
                        add_sub_b = 1'b1;                         
                end                                               
    6'b10_1100: begin   to_incr  = 3'b010;                      
                        add_sub_b = 1'b1;                         
                end                                               
    6'b10_1101: begin   to_incr  = 3'b001;                      
                        add_sub_b = 1'b1;                         
                end                                               
    6'b10_1110: begin   to_incr  = 3'b001;                      
                        add_sub_b = 1'b1;                         
                end                                               
    //6'b10_1111: begin   to_incr  = 3'b000; JBG: special case where you add instead
    6'b10_1111: begin   to_incr  = 3'b001;                      
                        add_sub_b = 1'b1;                         
                end                                               
    6'b11_0000: begin   to_incr  = 3'b101;
                        add_sub_b = 1'b1;
                end
    6'b11_0001: begin   to_incr  = 3'b100;
                        add_sub_b = 1'b1;
                end
    6'b11_0010: begin   to_incr  = 3'b100;
                        add_sub_b = 1'b1;
                end
    6'b11_0011: begin   to_incr  = 3'b011;
                        add_sub_b = 1'b1;
                end
    6'b11_0100: begin   to_incr  = 3'b100;
                        add_sub_b = 1'b1;
                end
    6'b11_0101: begin   to_incr  = 3'b011;
                        add_sub_b = 1'b1;
                end
    6'b11_0110: begin   to_incr  = 3'b011;
                        add_sub_b = 1'b1;
                end
    6'b11_0111: begin   to_incr  = 3'b010;
                        add_sub_b = 1'b1;
                end
    6'b11_1000: begin   to_incr  = 3'b100;
                        add_sub_b = 1'b1;
                end
    6'b11_1001: begin   to_incr  = 3'b011;
                        add_sub_b = 1'b1;
                end
    6'b11_1010: begin   to_incr  = 3'b011;
                        add_sub_b = 1'b1;
                end
    6'b11_1011: begin   to_incr  = 3'b010;
                        add_sub_b = 1'b1;
                end
    6'b11_1100: begin   to_incr  = 3'b011;
                        add_sub_b = 1'b1;
                end
    6'b11_1101: begin   to_incr  = 3'b010;
                        add_sub_b = 1'b1;
                end
    6'b11_1110: begin   to_incr  = 3'b010;
                        add_sub_b = 1'b1;
                end
    6'b11_1111: begin   to_incr  = 3'b001;
                        add_sub_b = 1'b1;
                end
    default:  begin   to_incr   = 3'b000;
                      add_sub_b = 1'b1;
              end
    endcase
  end


  //******************************************************************//
  // Register the outputs.                                            //
  //******************************************************************//


  reg     [2:0] reg_cor_num;
  reg           reg_inc_dec_b;
  reg           reg_decr_cor;

  always @(posedge clk)
  begin
    if (rst)
    begin
      reg_cor_num   <= #FFD 3'b000;   //remove reset to aid timing
      reg_inc_dec_b <= #FFD 1'b0;
      reg_decr_cor  <= #FFD 1'b0;
    end
    else
    begin
      reg_cor_num   <= #FFD to_incr;

      reg_inc_dec_b <= #FFD ~(add_input_six_n_d && ~add_input_one_d &&
                              add_input_two_n_d && add_input_three_n_d &&
                              add_input_four_n_d && add_input_five_n_d && decr_cor);
      reg_decr_cor  <= #FFD  (add_input_six_n_d && ~add_input_one_d &&
                              add_input_two_n_d && add_input_three_n_d &&
                              add_input_four_n_d && add_input_five_n_d) ?
                             ~decr_cor : decr_cor;
    end
  end

  assign cor_num   = reg_cor_num;
  assign inc_dec_b = reg_inc_dec_b;


  //******************************************************************//
  //                                                                  //
  //******************************************************************//

endmodule
