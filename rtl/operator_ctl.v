`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// IBM 650 Reconstruction in Verilog (i650)
// 
// This file is part of the IBM 650 Reconstruction in Verilog (i650) project
// http:////www.opencores.org/project,i650
//
// Description: Operator console and external control interface.
// 
// Additional Comments: See US 2959351, Fig. 75, 76, 76 and 77. Also implements
//  a simple command-based control interface.
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

module operator_ctl (
      input rst, clk,
      input ap, dp,
      input dx, d0, d1, d2, d3, d4, d5, d6, d9, d10,
      input wu, wl, hp,
      input [0:3] early_idx, ontime_idx,
   
      input [0:6] cmd_digit_in, io_buffer_in, gs_in, acc_ontime, dist_ontime,
                  prog_ontime,
      input [0:5] command,
      input restart_reset,
   
      output reg[0:6] data_out, addr_out, console_out,
      output [0:6] display_digit,
      output reg console_to_addr, acc_ri_console,
      output reg[0:14] gs_ram_addr,
      output reg read_gs, write_gs,
      output reg pgm_start, pgm_stop, err_reset, err_sense_reset,
      output run_control, half_or_pgm_stop, ri_storage, ro_storage, 
             storage_control, err_restart_sw, ovflw_stop_sw, ovflw_sense_sw,
             pgm_stop_sw,
      output reg man_pgm_reset, man_acc_reset, hard_reset,
      output set_8000, reset_8000,
   
      output reg[0:6] cmd_digit_out,
      output reg busy, digit_ready, restart_reset_busy, 
      output reg punch_card, read_card, card_digit_ready
   );
   
   //-----------------------------------------------------------------------------
   // Operator console switch settings and their control signals.
   //-----------------------------------------------------------------------------
   reg pgm_sw_stop, pgm_sw_run,
       half_cycle_sw_run, half_cycle_sw_half,
       ctl_sw_addr_stop, ctl_sw_run, ctl_sw_manual,
       disp_sw_lacc, disp_sw_uacc, disp_sw_dist, disp_sw_pgm,
       disp_sw_ri, disp_sw_ro,
       ovflw_sw_stop, ovflw_sw_sense, err_sw_stop, err_sw_sense;
   reg [0:6] storage_entry_sw [0:15];
   reg [0:6] addr_sel_sw [0:3];
   assign run_control = disp_sw_lacc | disp_sw_uacc | disp_sw_dist | disp_sw_pgm;
   assign half_or_pgm_stop = half_cycle_sw_half | pgm_stop;
   assign ri_storage = disp_sw_ri;
   assign ro_storage = disp_sw_ro;
   assign storage_control = run_control | disp_sw_ro;
   assign display_digit = (disp_sw_lacc | disp_sw_uacc)? acc_ontime
                        : (disp_sw_dist | disp_sw_ri | disp_sw_ro)? dist_ontime
                        : disp_sw_pgm? prog_ontime
                        : `biq_blank;
   assign set_8000 = man_pgm_reset & (ctl_sw_addr_stop | ctl_sw_run);
   assign reset_8000 = man_pgm_reset & ctl_sw_manual;
   assign err_restart_sw = err_sw_sense;
   assign ovflw_stop_sw  = ovflw_sw_stop;
   assign ovflw_sense_sw = ovflw_sw_sense;
   assign pgm_stop_sw = pgm_sw_stop;
   
   //-----------------------------------------------------------------------------
   // Calculate the RAM address of the general storage word at address gs_addr_.
   //-----------------------------------------------------------------------------
   reg [0:6] gs_addr_th, gs_addr_h, gs_addr_t, gs_addr_u;
   wire [0:14] gs_band_addr;
   wire [0:9] gs_word_offset;
   ram_band_addr rba(gs_addr_th, gs_addr_h, gs_addr_t, gs_band_addr);
   ram_word_offset rwo(gs_addr_t, gs_addr_u, gs_word_offset);
   wire [0:14] gs_word_addr = gs_band_addr + gs_word_offset;

   //-----------------------------------------------------------------------------
   // Operator console state machine
   //-----------------------------------------------------------------------------
   reg do_power_on_reset, do_reset_console, do_err_reset, do_err_sense_reset,
       do_pgm_reset, do_acc_reset, do_hard_reset, do_clear_drum;
   reg [0:5] state;
   
   `define state_idle                  6'd0
   
   `define state_reset_console_1       6'd1
   `define state_reset_console_2       6'd2
   `define state_pgm_reset_1           6'd3
   `define state_pgm_reset_2           6'd4
   `define state_acc_reset_1           6'd5
   `define state_acc_reset_2           6'd6
   `define state_err_reset_1           6'd7
   `define state_err_reset_2           6'd8
   `define state_err_sense_reset_1     6'd9
   `define state_err_sense_reset_2     6'd10
   `define state_hard_reset_1          6'd11

   `define state_storage_entry_sw_1    6'd12
   `define state_storage_entry_sw_2    6'd13
   `define state_addr_sel_sw_1         6'd14
   `define state_addr_sel_sw_2         6'd15
   
   `define state_xfer_key_1            6'd16
   `define state_xfer_key_2            6'd17
   `define state_pgm_start_key_1       6'd18
   `define state_pgm_start_key_2       6'd19
   `define state_pgm_stop_key_1        6'd20
   `define state_pgm_stop_key_2        6'd21
   
   `define state_read_gs_1             6'd30
   `define state_read_gs_2             6'd31
   `define state_read_gs_3             6'd32
   `define state_read_gs_4             6'd33
   `define state_read_gs_5             6'd34
   `define state_read_gs_6             6'd35
   `define state_write_gs_1            6'd36
   `define state_write_gs_2            6'd37
   `define state_write_gs_3            6'd38
   `define state_write_gs_4            6'd39
   `define state_write_gs_5            6'd40
   `define state_read_acc_1            6'd41
   `define state_read_acc_2            6'd42
   `define state_read_acc_3            6'd43
   `define state_read_dist_1           6'd44
   `define state_read_dist_2           6'd45
   `define state_read_dist_3           6'd46
   `define state_read_prog_1           6'd47
   `define state_read_prog_2           6'd48
   `define state_read_prog_3           6'd49
   `define state_write_acc_1           6'd50
   `define state_write_acc_2           6'd51
   `define state_write_acc_3           6'd52
   `define state_clear_drum_1          6'd53
   `define state_clear_drum_2          6'd54
   `define state_clear_drum_3          6'd55
   `define state_load_gs_1             6'd56
   `define state_load_gs_2             6'd57
   `define state_dump_gs_1             6'd58
   `define state_dump_gs_2             6'd59
   `define state_dump_gs_3             6'd60
   `define state_dump_gs_4             6'd61
   
   always @(posedge dp, posedge rst)
      if (rst) begin
         console_to_addr  <= 0;
         pgm_start        <= 0;
         pgm_stop         <= 0;
         err_reset        <= 0;
         err_sense_reset  <= 0;
         man_pgm_reset    <= 0;
         man_acc_reset    <= 0;
         hard_reset       <= 0;
         
         // reset console switches
         pgm_sw_stop      <= 0;
         pgm_sw_run       <= 1;
         half_cycle_sw_run <= 1;
         half_cycle_sw_half <= 0;
         ctl_sw_addr_stop <= 0;
         ctl_sw_run       <= 1;
         ctl_sw_manual    <= 0;
         disp_sw_lacc     <= 0;
         disp_sw_uacc     <= 0;
         disp_sw_dist     <= 1;
         disp_sw_pgm      <= 0;
         disp_sw_ri       <= 0;
         disp_sw_ro       <= 0;
         ovflw_sw_stop    <= 1;
         ovflw_sw_sense   <= 0;
         err_sw_stop      <= 1;
         err_sw_sense     <= 0;
         
         state         <= `state_idle;
         busy          <= 1;
         digit_ready   <= 0;
         cmd_digit_out <= `biq_blank;
         restart_reset_busy <= 0;
         
         do_power_on_reset  <= 1;
         do_reset_console   <= 0;
         do_err_reset       <= 0;
         do_err_sense_reset <= 0;
         do_pgm_reset       <= 0;
         do_acc_reset       <= 0;
         do_hard_reset      <= 0;
         do_clear_drum      <= 0;
         
         gs_ram_addr        <= 15'd0;
         read_gs            <= 0;
         write_gs           <= 0;
         acc_ri_console     <= 0;
         console_out        <= `biq_blank;
      end else begin
         case (state)
            `state_idle: begin
               case (command)
                  `cmd_none: begin
                     if (restart_reset) begin
                        do_pgm_reset       <= 1;
                        do_acc_reset       <= 1;
                        do_err_reset       <= 1;
                        restart_reset_busy <= 1;
                     end else if (do_power_on_reset) begin
                        do_power_on_reset  <= 0;
                        do_reset_console   <= 1;
                        do_pgm_reset       <= 1;
                        do_acc_reset       <= 1;
                        do_err_reset       <= 1;
                        do_err_sense_reset <= 1;
                        do_hard_reset      <= 1;
                        do_clear_drum      <= 1;
                     end else if (do_hard_reset) begin
                        do_hard_reset      <= 0;
                        hard_reset         <= 1;
                        state <= `state_hard_reset_1;
                     end else if (do_reset_console) begin
                        do_reset_console   <= 0;
                        state <= `state_reset_console_1;
                     end else if (do_pgm_reset) begin
                        do_pgm_reset       <= 0;
                        state <= `state_pgm_reset_1;
                     end else if (do_acc_reset) begin
                        do_acc_reset       <= 0;
                        man_acc_reset      <= 1;
                        state <= `state_acc_reset_1;
                     end else if (do_err_reset) begin
                        do_err_reset       <= 0;
                        err_reset          <= 1;
                        state <= `state_err_reset_1;
                     end else if (do_err_sense_reset) begin
                        do_err_sense_reset <= 0;
                        err_sense_reset    <= 1;
                        state <= `state_err_sense_reset_1;
                     end else if (do_clear_drum) begin
                        do_clear_drum      <= 0;
                        state <= `state_clear_drum_1;
                     end else begin
                        busy <= 0;
                        digit_ready <= 0;
                        restart_reset_busy <= 0;
                     end
                  end
                  
                  `cmd_pgm_sw_stop: begin
                     busy <= 1;
                     pgm_sw_stop <= 1;
                     pgm_sw_run  <= 0;
                  end
                  
                  `cmd_pgm_sw_run: begin
                     busy <= 1;
                     pgm_sw_stop <= 0;
                     pgm_sw_run  <= 1;
                  end
                  
                  `cmd_half_cycle_sw_run: begin
                     busy <= 1;
                     half_cycle_sw_run  <= 1;
                     half_cycle_sw_half <= 0;
                  end
                  
                  `cmd_half_cycle_sw_half: begin
                     busy <= 1;
                     half_cycle_sw_run  <= 0;
                     half_cycle_sw_half <= 1;
                  end
                  
                  `cmd_ctl_sw_addr_stop: begin
                     busy <= 1;
                     ctl_sw_addr_stop <= 1;
                     ctl_sw_run       <= 0;
                     ctl_sw_manual    <= 0;
                  end
                  
                  `cmd_ctl_sw_run: begin
                     busy <= 1;
                     ctl_sw_addr_stop <= 0;
                     ctl_sw_run       <= 1;
                     ctl_sw_manual    <= 0;
                  end
                  
                  `cmd_ctl_sw_manual: begin
                     busy <= 1;
                     ctl_sw_addr_stop <= 0;
                     ctl_sw_run       <= 0;
                     ctl_sw_manual    <= 1;
                  end
                  
                  `cmd_disp_sw_lacc: begin
                     busy <= 1;
                     disp_sw_lacc <= 1;
                     disp_sw_uacc <= 0;
                     disp_sw_dist <= 0;
                     disp_sw_pgm  <= 0;
                     disp_sw_ri   <= 0;
                     disp_sw_ro   <= 0;
                  end
                  
                  `cmd_disp_sw_uacc: begin
                     busy <= 1;
                     disp_sw_lacc <= 0;
                     disp_sw_uacc <= 1;
                     disp_sw_dist <= 0;
                     disp_sw_pgm <= 0;
                     disp_sw_ri   <= 0;
                     disp_sw_ro   <= 0;
                  end
                  
                  `cmd_disp_sw_dist: begin
                     busy <= 1;
                     disp_sw_lacc <= 0;
                     disp_sw_uacc <= 0;
                     disp_sw_dist <= 1;
                     disp_sw_pgm <= 0;
                     disp_sw_ri   <= 0;
                     disp_sw_ro   <= 0;
                  end
                  
                  `cmd_disp_sw_prog: begin
                     busy <= 1;
                     disp_sw_lacc <= 0;
                     disp_sw_uacc <= 0;
                     disp_sw_dist <= 0;
                     disp_sw_pgm <= 1;
                     disp_sw_ri   <= 0;
                     disp_sw_ro   <= 0;
                  end
                  
                  `cmd_disp_sw_ri: begin
                     busy <= 1;
                     disp_sw_lacc <= 0;
                     disp_sw_uacc <= 0;
                     disp_sw_dist <= 0;
                     disp_sw_pgm <= 0;
                     disp_sw_ri   <= 1;
                     disp_sw_ro   <= 0;
                  end
                  
                  `cmd_disp_sw_ro: begin
                     busy <= 1;
                     disp_sw_lacc <= 0;
                     disp_sw_uacc <= 0;
                     disp_sw_dist <= 0;
                     disp_sw_pgm <= 0;
                     disp_sw_ri   <= 0;
                     disp_sw_ro   <= 1;
                  end
                  
                  `cmd_ovflw_sw_stop: begin
                     busy <= 1;
                     ovflw_sw_stop  <= 1;
                     ovflw_sw_sense <= 0;
                  end
                  
                  `cmd_ovflw_sw_sense: begin
                     busy <= 1;
                     ovflw_sw_stop  <= 0;
                     ovflw_sw_sense <= 1;
                  end
                  
                  `cmd_err_sw_stop: begin
                     busy <= 1;
                     err_sw_stop  <= 1;
                     err_sw_sense <= 0;
                  end
                  
                  `cmd_err_sw_sense: begin
                     busy <= 1;
                     err_sw_stop  <= 0;
                     err_sw_sense <= 1;
                  end
                  
                  `cmd_storage_entry_sw: begin
                     busy <= 1;
                     state <= `state_storage_entry_sw_1;
                  end
                  
                  `cmd_addr_sel_sw: begin
                     busy <= 1;
                     state <= `state_addr_sel_sw_1;
                  end
                  
                  `cmd_xfer_key: begin
                     if (ctl_sw_manual) begin
                        busy <= 1;
                        state <= `state_xfer_key_1;
                     end
                  end
                  
                  `cmd_pgm_start_key: begin
                     busy <= 1;
                     state <= `state_pgm_start_key_1;
                  end
                  
                  `cmd_pgm_stop_key: begin
                     busy <= 1;
                     pgm_stop <= 1;
                     state <= `state_pgm_stop_key_1;
                  end
                  
                  `cmd_pgm_reset_key: begin
                     busy <= 1;
                     do_pgm_reset <= 1;
                     do_err_reset <= 1;
                  end

                  `cmd_comp_reset_key: begin
                     busy <= 1;
                     do_pgm_reset <= 1;
                     do_acc_reset <= 1;
                     do_err_reset <= 1;
                  end
                  
                  `cmd_acc_reset_key: begin
                     busy <= 1;
                     do_acc_reset <= 1;
                     do_err_reset <= 1;
                  end
                  
                  `cmd_err_reset_key: begin
                     busy <= 1;
                     do_err_reset <= 1;
                  end
                  
                  `cmd_err_sense_reset_key: begin
                     busy <= 1;
                     do_err_sense_reset <= 1;
                  end
                  
                  //--------------------------------------------------------------
                  // Read from general storage:
                  //    --> 4 digits address, little-endian
                  //    <-- 1 digit sign, 10 digits, little-endian
                  // 0 : Ignore if CPU not stopped
                  //     Accept low-order address digit
                  // 1 : Accept remaining address digits
                  // 2 : Calculate word origin in gs RAM
                  //     Validate address
                  //     console_read_gs <= 1;
                  // 3 : Send gs-early digit to out
                  //     digit_ready <= 1;
                  // 4 : digit_ready <= 0;
                  //--------------------------------------------------------------
                  `cmd_read_gs: begin
                     if (ctl_sw_manual) begin
                        busy <= 1;
                        state <= `state_read_gs_1;
                     end
                  end
                  
                  // Write word to general storage:
                  //    --> 4 digits address, little-endian
                  //    <-- dx digit, sign digit, d1-d10
                  // 0: Ignore if not in manual
                  // 1: Readin low-order addr digit
                  // 2: Readin remaining addr digits
                  // 3: Synchronize with d10
                  //    digit_ready <- 1
                  // 4: Readin first digit
                  // 5: Write digit
                  //    Readin next digit
                  // 6: Cleanup
                  `cmd_write_gs: begin
                     if (ctl_sw_manual) begin
                        busy <= 1;
                        state <= `state_write_gs_1;
                     end
                  end
                  
                  `cmd_read_acc: begin
                     busy <= 1;
                     state <= `state_read_acc_1;
                  end
                  
                  `cmd_read_dist: begin
                     busy <= 1;
                     state <= `state_read_dist_1;
                  end
                  
                  `cmd_read_prog: begin
                     busy <= 1;
                     state <= `state_read_prog_1;
                  end
                  
                  `cmd_write_acc: begin
                     busy <= 1;
                     state <= `state_write_acc_1;
                  end
                  
                  // 0 : Ignore if not in manual
                  //     Clear gs_ram_addr
                  // 1 : Synchronize with d10
                  //     Turn on console_write_gs
                  // 2 : Put a digit:
                  //     dx: blank
                  //     d0: minus
                  //     d1-d10: zero
                  //     gs_ram_addr++
                  `cmd_clear_gs: begin
                     if (ctl_sw_manual) begin
                        busy <= 1;
                        do_clear_drum <= 1;
                     end
                  end
                  
                  `cmd_load_gs: begin
                     if (ctl_sw_manual) begin
                        busy <= 1;
                        state <= `state_load_gs_1;
                        digit_ready <= 1;
                     end
                  end
                  
                  `cmd_dump_gs: begin
                     if (ctl_sw_manual) begin
                        busy <= 1;
                        state <= `state_dump_gs_1;
                     end
                  end
                  
                  `cmd_power_on_reset: begin
                     busy <= 1;
                     do_power_on_reset <= 1;
                  end
                  
                  `cmd_reset_console: begin
                     busy <= 1;
                     do_reset_console <= 1;
                  end
                  
                  `cmd_hard_reset: begin
                     busy <= 1;
                     do_hard_reset <= 1;
                  end
                  
               endcase;
            end
            
            // Reset console            
            `state_reset_console_1: begin
               if (d10) state <= `state_reset_console_2;
            end
               
            `state_reset_console_2: begin
               storage_entry_sw[ontime_idx] <= dx? `biq_blank 
                                             : d0? `biq_plus : `biq_0;
               addr_sel_sw[ontime_idx[2:3]] <= `biq_0;
               if (d10) state <= `state_idle;
            end
            
            // Program reset key press
            `state_pgm_reset_1: begin
               if (wu & d10) begin
                  man_pgm_reset <= 1;
                  state <= `state_pgm_reset_2;
               end 
            end
            
            `state_pgm_reset_2: begin
               if (wu & d10) begin
                  man_pgm_reset <= 0;
                  state <= `state_idle;
               end
            end
            
            // Accumulator reset key press
            `state_acc_reset_1: begin
               if (wu & d10) begin
                  man_acc_reset <= 1;
                  state <= `state_acc_reset_2;
               end 
            end
            
            `state_acc_reset_2: begin
               if (wu & d10) begin
                  man_acc_reset <= 0;
                  state <= `state_idle;
               end
            end
            
            // Error reset key press
            `state_err_reset_1: begin
               if (wu & d10) begin
                  err_reset <= 1;
                  state <= `state_err_reset_2;
               end 
            end
            
            `state_err_reset_2: begin
               if (wu & d10) begin
                  err_reset <= 0;
                  state <= `state_idle;
               end
            end
            
            // Error sense reset key press
            `state_err_sense_reset_1: begin
               if (wu & d10) begin
                  err_sense_reset <= 1;
                  state <= `state_err_sense_reset_2;
               end 
            end
            
            `state_err_sense_reset_2: begin
               if (wu & d10) begin
                  err_sense_reset <= 0;
                  state <= `state_idle;
               end
            end
            
            // Hard reset
            `state_hard_reset_1: begin
               hard_reset <= 0;
               state <= `state_idle;
            end
            
            // Set storage entry switches
            `state_storage_entry_sw_1: begin
               if (d0) begin
                  state <= `state_storage_entry_sw_2;
                  digit_ready <= 1;
                  storage_entry_sw[ontime_idx] <= cmd_digit_in;
               end
            end
            
            `state_storage_entry_sw_2: begin
               storage_entry_sw[ontime_idx] <= cmd_digit_in;
               if (d10) begin
                  state <= `state_idle;
                  digit_ready <= 0;
               end
            end
            
            // Set address selection switches
            `state_addr_sel_sw_1: begin
               if (dx) begin
                  state <= `state_addr_sel_sw_2;
                  digit_ready <= 1;
                  addr_sel_sw[ontime_idx[2:3]] <= cmd_digit_in;
               end
            end
            
            `state_addr_sel_sw_2: begin
               addr_sel_sw[ontime_idx[2:3]] <= cmd_digit_in;
               if (d2) begin
                  state <= `state_idle;
                  digit_ready <= 0;
               end
            end
            
            // Transfer key press
            `state_xfer_key_1: begin
               if (d10) begin
                  console_to_addr <= 1;
                  state <= `state_xfer_key_2;
               end
            end
            
            `state_xfer_key_2: begin
               if (d10) begin
                  console_to_addr <= 0;
                  state <= `state_idle;
               end
            end
            
            // Start key press
            `state_pgm_start_key_1: begin
               if (wu & d10) begin
                  pgm_start <= 1;
                  state <= `state_pgm_start_key_2;
               end
            end
            
            `state_pgm_start_key_2: begin
               if (wu & d10) begin
                  pgm_start <= 0;
                  state <= `state_idle;
               end
            end
            
            // Stop key press
            `state_pgm_stop_key_1: begin
               if (hp) state <= `state_pgm_stop_key_2;
            end
            
            `state_pgm_stop_key_2: begin
               if (hp) begin
                  pgm_stop <= 0;
                  state <= `state_idle;
               end
            end
            
            // Read word from general storage
            //    --> 4 digits address, little-endian
            //    <-- 1 digit sign, 10 digits, little-endian
            // 0 : Ignore if CPU not stopped
            // 1 : Accept first address digit
            // 2 : Accept remaining address digits
            // 2 : Calculate word origin in gs RAM
            //     Validate address
            //     console_read_gs <= 1;
            // 3 : Send gs-early digit to out
            //     digit_ready <= 1;
            // 4 : digit_ready <= 0;
            `state_read_gs_1: begin
               if (dx) begin
                  state <= `state_read_gs_2;
                  digit_ready <= 1;
                  gs_addr_u <= cmd_digit_in;
               end
            end
            
            `state_read_gs_2: begin
               if (d0) gs_addr_t <= cmd_digit_in;
               else if (d1) gs_addr_h <= cmd_digit_in;
               else if (d2) begin
                  gs_addr_th <= cmd_digit_in;
                  state <= `state_read_gs_3;
                  digit_ready <= 0;
               end
            end
            
            `state_read_gs_3: begin
               if (d10) begin
                  gs_ram_addr <= gs_word_addr;
                  read_gs <= 1;
                  state <= `state_read_gs_4;
               end
            end
            
            `state_read_gs_4: begin
               state <= `state_read_gs_5;
               gs_ram_addr <= (gs_ram_addr + 1) % 32768;
            end
            
            `state_read_gs_5: begin
               digit_ready <= 1;
               cmd_digit_out <= gs_in;
               gs_ram_addr <= (gs_ram_addr + 1) % 32768;
               if (dx) begin
                  state <= `state_read_gs_6;
                  read_gs <= 0;
               end
            end
            
            `state_read_gs_6: begin
               digit_ready <= 0;
               state <= `state_idle;
            end
 
            // Write word to general storage:
            //    --> 4 digits address, little-endian
            //    <-- dx digit, sign digit, d1-d10
            // 0: Ignore if not in manual
            // 1: Readin low-order addr digit
            // 2: Readin remaining addr digits
            // 3: Synchronize with d10
            //    digit_ready <- 1
            // 4: Readin and write digit
            // 5: Write digit
            //    Readin next digit
            // 6: Cleanup
            
            `state_write_gs_1: begin
               if (dx) begin
                  state <= `state_write_gs_2;
                  digit_ready <= 1;
                  gs_addr_u <= cmd_digit_in;
               end
            end
            
            `state_write_gs_2: begin
               if (d0) gs_addr_t <= cmd_digit_in;
               else if (d1) gs_addr_h <= cmd_digit_in;
               else if (d2) begin
                  gs_addr_th <= cmd_digit_in;
                  state <= `state_write_gs_3;
                  digit_ready <= 0;
               end
            end
            
            `state_write_gs_3: begin
               if (d10) begin
                  gs_ram_addr <= gs_word_addr;
                  digit_ready <= 1;
                  state <= `state_write_gs_4;
               end
            end
            
            `state_write_gs_4: begin
               write_gs <= 1;
               console_out <= cmd_digit_in;
               if (write_gs)
                  gs_ram_addr <= (gs_ram_addr + 1) % 32768;
               if (d10) begin
                  digit_ready <= 0;
                  state <= `state_write_gs_5;
               end
            end
            
            `state_write_gs_5: begin
               write_gs <= 0;
               state <= `state_idle;
            end
            
            `state_read_acc_1: begin
               if (wl & d10) begin
                  state <= `state_read_acc_2;
               end
            end
            
            `state_read_acc_2: begin
               digit_ready <= 1;
               cmd_digit_out <= acc_ontime;
               if (wu & d10) begin
                  state <= `state_read_acc_3;
               end
            end
            
            `state_read_acc_3: begin
               digit_ready <= 0;
               state <= `state_idle;
            end
            
            `state_read_dist_1: begin
               if (d10) begin
                  state <= `state_read_dist_2;
               end
            end
            
            `state_read_dist_2: begin
               digit_ready <= 1;
               cmd_digit_out <= dist_ontime;
               if (d10) begin
                  state <= `state_read_dist_3;
               end
            end
            
            `state_read_dist_3: begin
               digit_ready <= 0;
               state <= `state_idle;
            end
            
            `state_read_prog_1: begin
               if (d10) begin
                  state <= `state_read_prog_2;
               end
            end
            
            `state_read_prog_2: begin
               digit_ready <= 1;
               cmd_digit_out <= prog_ontime;
               if (d10) begin
                  state <= `state_read_prog_3;
               end
            end
            
            `state_read_prog_3: begin
               digit_ready <= 0;
               state <= `state_idle;
            end
            
            `state_write_acc_1: begin
               if (wl & dx) begin
                  console_out <= cmd_digit_in;
                  acc_ri_console <= 1;
                  digit_ready <= 1;
                  state <= `state_write_acc_2;
               end
            end
            
            `state_write_acc_2: begin
               console_out <= cmd_digit_in;
               if (wu & d10) begin
                  digit_ready <= 0;
                  state <= `state_write_acc_3;
               end
            end
            
            `state_write_acc_3: begin
               acc_ri_console <= 0;
               state <= `state_idle;
            end
            
            // 0 : Ignore if not in manual
            // 1 : Synchronize with dx
            //     Put first dx digit
            // 2 : Put a digit:
            //     dx: blank
            //     d0: minus
            //     d1-d10: zero
            `state_clear_drum_1: begin
               if (dx) begin
                  console_out <= `biq_blank;
                  gs_ram_addr <= 15'd0;
                  write_gs <= 1;
                  state <= `state_clear_drum_2;
               end
            end
            
            `state_clear_drum_2: begin
               console_out <= dx? `biq_blank
                            : d0? `biq_minus
                            : `biq_0;
               gs_ram_addr <= (gs_ram_addr + 1) % 32768;
               if (gs_ram_addr == 15'd23999) begin
                  write_gs <= 0;
                  state <= `state_idle;
               end
            end
            
            `state_load_gs_1: begin
               gs_ram_addr <= 15'd0;
               write_gs <= 1;
               console_out <= cmd_digit_in;
               state <= `state_load_gs_2;
            end
            
            `state_load_gs_2: begin
               gs_ram_addr <= (gs_ram_addr + 1) % 32768;
               console_out <= cmd_digit_in;
               if (gs_ram_addr == 15'd23999) begin
                  write_gs <= 0;
                  digit_ready <= 0;
                  state <= `state_idle;
               end
            end
            
            `state_dump_gs_1: begin
               gs_ram_addr <= 15'd0;
               read_gs <= 1;
               state <= `state_dump_gs_2;
            end
            
            `state_dump_gs_2: begin
               gs_ram_addr <= (gs_ram_addr + 1) % 32768;
               state <= `state_dump_gs_3;
            end
            
            `state_dump_gs_3: begin
               digit_ready <= 1;
               gs_ram_addr <= (gs_ram_addr + 1) % 32768;
               cmd_digit_out <= gs_in;
               if (gs_ram_addr == 15'd23999) begin
                  state <= `state_dump_gs_4;
               end
            end
            
            `state_dump_gs_4: begin
               digit_ready <= 0;
               read_gs <= 0;
               state <= `state_idle;
            end
            
         endcase;
      end;
   
   always @(posedge ap)
      if (hard_reset) begin
         data_out <= `biq_blank;
         addr_out <= `biq_blank;
      end else begin
         data_out <= d10? `biq_blank : storage_entry_sw[early_idx];
         addr_out <= (d3 | d4 | d5 | d6)? addr_sel_sw[early_idx[2:3]] : `biq_blank;
      end;
   
   always @(posedge ap)
      if (hard_reset) begin
         punch_card       <= 0;
         read_card        <= 0;
         card_digit_ready <= 0;
      end;
   
endmodule
