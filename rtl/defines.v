//////////////////////////////////////////////////////////////////////////////////
// IBM 650 Reconstruction in Verilog (i650)
// 
// This file is part of the IBM 650 Reconstruction in Verilog (i650) project
// http:////www.opencores.org/project,i650
//
// Description: Global definitions.
// 
// Additional Comments: 
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

//-----------------------------------------------------------------------------
// Bi-quinary binary codes
//-----------------------------------------------------------------------------
`define biq_blank 7'b00_00000
`define biq_0     7'b01_00001
`define biq_1     7'b01_00010
`define biq_2     7'b01_00100
`define biq_3     7'b01_01000
`define biq_4     7'b01_10000
`define biq_5     7'b10_00001
`define biq_6     7'b10_00010
`define biq_7     7'b10_00100
`define biq_8     7'b10_01000
`define biq_9     7'b10_10000
`define biq_plus  7'b10_10000
`define biq_minus 7'b10_01000

//-----------------------------------------------------------------------------
// Bi-quinary bit numbers
//-----------------------------------------------------------------------------
`define biq_b5 0
`define biq_b0 1
`define biq_q4 2
`define biq_q3 3
`define biq_q2 4
`define biq_q1 5
`define biq_q0 6

//-----------------------------------------------------------------------------
// 2 of 5 drum recording codes
//-----------------------------------------------------------------------------
`define drum2of5_blank 5'b00000
`define drum2of5_0     5'b01100
`define drum2of5_1     5'b11000
`define drum2of5_2     5'b10100
`define drum2of5_3     5'b10010
`define drum2of5_4     5'b01010
`define drum2of5_5     5'b00110
`define drum2of5_6     5'b10001
`define drum2of5_7     5'b01001
`define drum2of5_8     5'b00101
`define drum2of5_9     5'b00011

//-----------------------------------------------------------------------------
// Console control commands
//-----------------------------------------------------------------------------
`define cmd_none                 6'd0
// set switch position
`define cmd_pgm_sw_stop          6'd1        
`define cmd_pgm_sw_run           6'd2
`define cmd_half_cycle_sw_run    6'd3
`define cmd_half_cycle_sw_half   6'd4
`define cmd_ctl_sw_addr_stop     6'd5
`define cmd_ctl_sw_run           6'd6
`define cmd_ctl_sw_manual        6'd7
`define cmd_disp_sw_lacc         6'd8
`define cmd_disp_sw_uacc         6'd9
`define cmd_disp_sw_dist         6'd10
`define cmd_disp_sw_prog         6'd11
`define cmd_disp_sw_ri           6'd12
`define cmd_disp_sw_ro           6'd13
`define cmd_ovflw_sw_stop        6'd14
`define cmd_ovflw_sw_sense       6'd15
`define cmd_err_sw_stop          6'd16
`define cmd_err_sw_sense         6'd17
// press key
`define cmd_xfer_key             6'd18
`define cmd_pgm_start_key        6'd19        
`define cmd_pgm_stop_key         6'd20
`define cmd_pgm_reset_key        6'd21
`define cmd_comp_reset_key       6'd22
`define cmd_acc_reset_key        6'd23
`define cmd_err_reset_key        6'd24
`define cmd_err_sense_reset_key  6'd25
// set address select and storage entry switches
`define cmd_storage_entry_sw     6'd26
`define cmd_addr_sel_sw          6'd27
// read/write general storage
`define cmd_read_gs              6'd28
`define cmd_write_gs             6'd29
// read machine registers
`define cmd_read_acc             6'd30
`define cmd_read_dist            6'd31
`define cmd_read_prog            6'd32
// write machine register
`define cmd_write_acc            6'd33
// general storage (drum)
`define cmd_clear_gs             6'd34
`define cmd_load_gs              6'd35
`define cmd_dump_gs              6'd36
// resets
`define cmd_power_on_reset       6'd37
`define cmd_reset_console        6'd38
`define cmd_hard_reset           6'd39