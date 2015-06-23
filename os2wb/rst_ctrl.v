/*
 * Reset Controller
 *
 * (C) Copyleft 2007 Simply RISC LLP
 * AUTHOR: Fabrizio Fazzino <fabrizio.fazzino@srisc.com>
 *
 * LICENSE:
 * This is a Free Hardware Design; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * version 2 as published by the Free Software Foundation.
 * The above named program is distributed in the hope that it will
 * be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * DESCRIPTION:
 * This block implements the Reset Controller used by the S1 Core
 * to wake up the SPARC Core of the OpenSPARC T1; its behavior was
 * reverse-engineered from the OpenSPARC waveforms.
 */

module rst_ctrl (
    sys_clock_i, sys_reset_i,
    cluster_cken_o, gclk_o, cmp_grst_o, cmp_arst_o,
    ctu_tst_pre_grst_o, adbginit_o, gdbginit_o,
    sys_reset_final_o
  );

  /*
   * Inputs
   */

  // System inputs
  input sys_clock_i;                            // System Clock
  input sys_reset_i;                            // System Reset

  /*
   * Registered Outputs
   */

  output gclk_o;

  /*
   * Registered Outputs
   */

  // SPARC Core inputs
  output cluster_cken_o;
  output cmp_grst_o;
  output cmp_arst_o;
  output ctu_tst_pre_grst_o;
  output adbginit_o;
  output gdbginit_o;
  output sys_reset_final_o;

  /*
   * Registers
   */

  // Counter used as a timer to strobe the reset signals
  reg [12:0] cycle_counter;

  /*
   * Procedural blocks
   */

  // This process handles the timer counter
  
  reg rst_sync;
  reg sys_reset;
  
  always @(posedge sys_clock_i)
     begin
        rst_sync<=sys_reset_i;
        sys_reset<=rst_sync;
        if(sys_reset==1'b1)
           cycle_counter<=0;
        else
           if(cycle_counter[12]==1'b0)
              cycle_counter<=cycle_counter+1;
     end
     
assign cmp_arst_o        =!sys_reset;
assign adbginit_o        =!sys_reset;
assign cluster_cken_o    =cycle_counter<'d20  ? 0:1;
assign ctu_tst_pre_grst_o=cycle_counter<'d60  ? 0:1;
assign gdbginit_o        =cycle_counter<'d120 ? 0:1;
assign cmp_grst_o        =cycle_counter<'d120 ? 0:1;
assign sys_reset_final_o =cycle_counter<'d126 ? 1:0;
assign gclk_o = sys_clock_i;

endmodule
