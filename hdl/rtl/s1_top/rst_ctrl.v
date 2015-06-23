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

`include "s1_defs.h"

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
  reg cluster_cken_o;
  output cmp_grst_o;
  reg cmp_grst_o;
  output cmp_arst_o;
  reg cmp_arst_o;
  output ctu_tst_pre_grst_o;
  reg ctu_tst_pre_grst_o;
  output adbginit_o;
  reg adbginit_o;
  output gdbginit_o;
  reg gdbginit_o;
  output sys_reset_final_o;
  reg sys_reset_final_o;

  /*
   * Registers
   */

  // Counter used as a timer to strobe the reset signals
  reg[`TIMER_BITS-1:0] cycle_counter;

  /*
   * Procedural blocks
   */

  // This process handles the timer counter
  always @(posedge sys_clock_i)
  begin
    if(sys_reset_i==1'b1)
    begin
      cycle_counter = 0;
    end
    else
    begin
      if(cycle_counter[`TIMER_BITS-1]==1'b0)
      begin
        cycle_counter = cycle_counter+1;
      end
    end
  end

  // This other process assigns the proper values to the outputs
  // (that are used as system inputs by the SPARC Core)
  always @(posedge sys_clock_i)
  begin
    if(sys_reset_i==1)
    begin
      cluster_cken_o <= 0;
      cmp_grst_o <= 0;
      cmp_arst_o <= 0;
      ctu_tst_pre_grst_o <= 0;
      adbginit_o <= 0;
      gdbginit_o <= 0;
      sys_reset_final_o <= 1;
    end
    else
    begin
      if(cycle_counter<`RESET_CYCLES_1)
      begin
        cluster_cken_o <= 0;
        cmp_grst_o <= 0;
        cmp_arst_o <= 0;
        ctu_tst_pre_grst_o <= 0;
        adbginit_o <= 0;
        gdbginit_o <= 0;
        sys_reset_final_o <= 1;
      end
      else
      if(cycle_counter<`RESET_CYCLES_2)
      begin
        cluster_cken_o <= 0;
        cmp_grst_o <= 0;
        cmp_arst_o <= 1;  // <--
        ctu_tst_pre_grst_o <= 0;
        adbginit_o <= 1;  // <--
        gdbginit_o <= 0;
        sys_reset_final_o <= 1;
      end
      else
      if(cycle_counter<`RESET_CYCLES_3)
      begin
        cluster_cken_o <= 1;  // <--
        cmp_grst_o <= 0;
        cmp_arst_o <= 1;
        ctu_tst_pre_grst_o <= 1;  // <--
        adbginit_o <= 1;
        gdbginit_o <= 0;
        sys_reset_final_o <= 1;
      end
      else
      if(cycle_counter<`RESET_CYCLES_4)
      begin
        cluster_cken_o <= 1;
        cmp_grst_o <= 1;  // <--
        cmp_arst_o <= 1;
        ctu_tst_pre_grst_o <= 1;
        adbginit_o <= 1;
        gdbginit_o <= 1;  // <--
        sys_reset_final_o <= 1;
      end
      else
      begin
        cluster_cken_o <= 1;
        cmp_grst_o <= 1;
        cmp_arst_o <= 1;
        ctu_tst_pre_grst_o <= 1;
        adbginit_o <= 1;
        gdbginit_o <= 1;
        sys_reset_final_o <= 0;  // <--
      end
    end
  end

  assign gclk_o = (cycle_counter>`GCLK_CYCLES) & sys_clock_i;

endmodule
