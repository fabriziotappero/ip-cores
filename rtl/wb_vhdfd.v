//////////////////////////////////////////////////////////////////////
////                                                              ////
////  $Id: wb_vhdfd.v,v 1.4 2008-12-13 21:12:01 hharte Exp $      ////
////  wb_vhdfd.v - Vector Graphic HD/FD Disk Controller with      ////
////               Wishbone Slave interface.                      ////
////                                                              ////
////  This file is part of the Vector Graphic Z80 SBC Project     ////
////  http://www.opencores.org/projects/vg_z80_sbc/               ////
////                                                              ////
////  Author:                                                     ////
////      - Howard M. Harte (hharte@opencores.org)                ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 Howard M. Harte                           ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

//| Write           Read
//| C0 - CTRL0      STATUS0
//| C1 - CTRL1      STATUS1
//| C2 - DATA_PORT  DATA_PORT
//| C3 - START      RESET

`define CTRL0       4'b0001
`define CTRL1       4'b0010
`define DATA_PORT   4'b0100
`define START_CMD   4'b1000

`define STATUS0     4'b0001
`define STATUS1     4'b0010
`define RESET       4'b1000

module wb_vhdfd (clk_i, nrst_i, wbs_adr_i, wbs_dat_o, wbs_dat_i, wbs_sel_i, wbs_we_i,
				 wbs_stb_i, wbs_cyc_i, wbs_ack_o,
                 flash_adr_o,flash_dat_o, flash_dat_i, flash_oe, flash_ce, flash_we
                 );

    input             clk_i;
    input             nrst_i;
    input       [2:0] wbs_adr_i;
    output reg  [7:0] wbs_dat_o;
  	input 	    [7:0] wbs_dat_i;
    input 	    [3:0] wbs_sel_i;
  	input 	          wbs_we_i;
    input 	          wbs_stb_i;
    input 	          wbs_cyc_i;
    output reg        wbs_ack_o;

    // FLASH Interface
    output     [23:0] flash_adr_o;
    output      [7:0] flash_dat_o;
    input       [7:0] flash_dat_i;
    output            flash_oe;
    output            flash_ce;
    output            flash_we;

    reg         [7:0] ctrl0;
    reg         [7:0] ctrl1;
    reg               start_cmd;
    
    reg        [10:0] curr_track[0:3];
    reg         [8:0] sector_ram_ptr;

    // CTRL0 bits
    wire        [1:0] ds = ctrl0[1:0];    
    wire        [2:0] hds = ctrl0[4:2];
    wire              step_track = ctrl0[5];
    wire              step_dir = ctrl0[6];

    // CTRL1 bits
    wire        [4:0] sector = ctrl1[4:0];
    wire              disk_read = ctrl1[5];

    // STATUS0 bits
    wire     wp = 1'b0;     // Write protected, controller can't write to FLASH
    wire     track0 = (curr_track[ds] == 11'h0);

    // STATUS1 bits
    wire     fd_sel = (ds != 2'b00);  // Bit 0, floppy disk selected
    wire     ctrl_busy;     // Bit 1, Controller is busy.
    wire     motor_on = fd_sel;  // Bit 2, Motor On
    wire     hd_type = 1'b1; // Bit 3, Hard Disk Type, 1=10MB, 0=5MB


    wire  [7:0] sector_ram_dat_o;

    wire  [8:0] disk_adr;
    wire  [7:0] disk_dat_o;
    wire  [7:0] disk_dat_i;
    wire        disk_ram_wr;

    // generate wishbone register bank writes
    wire wbs_acc = wbs_cyc_i & wbs_stb_i;    // WISHBONE access
    wire wbs_wr  = wbs_acc & wbs_we_i & !wbs_ack_o;       // WISHBONE write access
    wire wbs_rd  = wbs_acc & !wbs_we_i & !wbs_ack_o;      // WISHBONE read access

    wire sector_ram_wr = (wbs_wr & (wbs_adr_i == 3'h2));

	always @(posedge clk_i or negedge nrst_i)
		if (~nrst_i)				// reset registers
			begin
                sector_ram_ptr <= 9'h0;
                start_cmd <= 1'b0;
                curr_track[0] <= 11'h010;
                curr_track[1] <= 11'h020;
                curr_track[2] <= 11'h030;
                curr_track[3] <= 11'h040;
			end
		else begin
            if(ctrl_busy == 1'b1) begin
                start_cmd <= 1'b0;
            end
            if(wbs_wr)          // wishbone write cycle
                case(wbs_adr_i)
                    3'h0: begin   // CTRL0
                        ctrl0 <= wbs_dat_i;
                        if(wbs_dat_i[5] == 1'b1) begin  // STEP
                            if(wbs_dat_i[6] == 1'b1) begin // Step In
                                curr_track[ds] <= curr_track[ds] + 11'h1;
                            end 
                            else begin  // Step Out
                                curr_track[ds] <= curr_track[ds] - 11'h1;
                            end
                        end
                    end
                    3'h1: begin   // CTRL1
                        ctrl1 <= wbs_dat_i;
                    end
                    3'h2: begin   // DATA_PORT
                        sector_ram_ptr <= sector_ram_ptr + 9'h001;
                    end
                    3'h3: begin   // START
                        start_cmd <= 1'b1;
                    end
			    endcase
            if(wbs_rd) begin
                case(wbs_adr_i) // Wishbone Read, decode byte enables to determine register offset.
                    3'h0: begin   // STATUS0 Register
                        wbs_dat_o <= {2'b11, 3'b000, track0, 1'b0,wp };
                    end
                    3'h1: begin   // STATUS1 Register
                        wbs_dat_o <= {4'hF, hd_type, motor_on, ctrl_busy, fd_sel };
                    end
                    3'h2: begin   // DATA_PORT
                        wbs_dat_o <= sector_ram_dat_o;
                        sector_ram_ptr <= sector_ram_ptr + 9'h001;
                    end
                    3'h3: begin   // RESET
                        wbs_dat_o <= 8'h0F;
                        sector_ram_ptr <= 9'h0;
                        start_cmd <= 1'b0;
                    end
                    3'h4: begin   // DIAG0
                        wbs_dat_o <= sector_ram_ptr[7:0];
                    end
                    3'h5: begin   // DIAG1
                        wbs_dat_o <= disk_adr[7:0];
                    end
                    3'h6: begin   // DIAG2
                        wbs_dat_o <= { 6'h00, start_cmd, ds };
                    end
                    3'h7: begin   // DIAG3
                        wbs_dat_o <= { curr_track[ds][7:0] };
                    end
                    
                endcase
            end
        end

    //
    // generate ack_o
    always @(posedge clk_i)
        wbs_ack_o <= wbs_acc & !wbs_ack_o;

// Instantiate the module
vhdfd_disk disks (
    .clk_i(clk_i), 
    .nrst_i(nrst_i), 
    .ds(ds), 
    .hds(hds), 
    .curr_track(curr_track[ds]), 
    .sector(sector), 
    .start_cmd(start_cmd), 
    .disk_read(disk_read), 
    .ctrl_busy(ctrl_busy),
    .disk_adr(disk_adr),
    .disk_dat_o(disk_dat_o),
    .disk_dat_i(disk_dat_i),
    .disk_ram_wr(disk_ram_wr),
    .flash_adr_o(flash_adr_o),
    .flash_dat_o(flash_dat_o),
    .flash_dat_i(flash_dat_i),
    .flash_oe(flash_oe),
    .flash_ce(flash_ce),
    .flash_we(flash_we));

// Instantiate the Sector RAM (512 bytes)
// synthesis attribute ram_style of sector_ram is block
vga_dpram #(
    .mem_file_name("../mon43/sector0.mem"),
    .adr_width(9),
    .dat_width(8)
) sector_ram (
    .clk1(clk_i),
    .clk2(clk_i),
    //
    .adr0(sector_ram_ptr),
    .dout0(sector_ram_dat_o),
    .din0(wbs_dat_i),  
    .we0(sector_ram_wr),
    //
    .adr1(disk_adr),
    .dout1(disk_dat_i),
    .din1(disk_dat_o),  
    .we1(disk_ram_wr)
);

endmodule

module vhdfd_disk (clk_i, nrst_i, ds, hds, curr_track, sector, start_cmd, disk_read, ctrl_busy,
                   disk_adr, disk_dat_o, disk_dat_i, disk_ram_wr,
                   flash_adr_o,flash_dat_o, flash_dat_i, flash_oe, flash_ce, flash_we
                   );

	input		      clk_i;
	input 	          nrst_i;
	input 	    [1:0] ds;
    input       [2:0] hds;
    input      [10:0] curr_track;
    input       [4:0] sector;
    input             start_cmd;
    input             disk_read;
    output reg        ctrl_busy;
    
    output reg  [8:0] disk_adr;
    output reg  [7:0] disk_dat_o;
    input       [7:0] disk_dat_i;
    output reg        disk_ram_wr;

    // FLASH Interface
    output     [23:0] flash_adr_o;
    output      [7:0] flash_dat_o;
    input       [7:0] flash_dat_i;
    output            flash_oe;
    output            flash_ce;
    output            flash_we;
    reg         [3:0] waitstate;

    reg         [13:0] state;

    wire        [23:0] sector_flash_adr;

assign sector_flash_adr = { 3'b000, hds[0], curr_track[6:0], sector[3:0], 9'h0 };

`define DISK_ST_IDLE            14'h000          // Disk Idle
`define DISK_ST_READ_SECTOR     14'h001          // Disk Read Sector
`define DISK_ST_WRITE_SECTOR    14'h002          // Disk Write Sector
`define DISK_ST_READ_WAIT       14'h004          // Disk Waitstate for FLASH read
`define DISK_ST_READ_WAIT2      14'h008          // Disk Waitstate for FLASH read
`define DISK_ST_READ_WAIT3      14'h010          // Disk Waitstate for FLASH read
`define DISK_ST_READ_WAIT4      14'h020          // Disk Waitstate for FLASH read

	always @(posedge clk_i or negedge nrst_i)
		if (~nrst_i)				// reset registers
			begin
                ctrl_busy <= 1'b0;
                disk_adr <= 9'h000;
                state <= `DISK_ST_IDLE;
			end
		else begin
            case(state)
                `DISK_ST_IDLE:
                    begin
                        if(start_cmd & disk_read) begin    // Wishbone access starts LPC transaction
                            state <= `DISK_ST_READ_SECTOR;
                            ctrl_busy <= 1'b1;
                        end
                        else if(start_cmd & !disk_read) begin
                            state <= `DISK_ST_WRITE_SECTOR;
                            ctrl_busy <= 1'b1;
                        end
                        else begin
                            state <= `DISK_ST_IDLE;
                            ctrl_busy <= 1'b0;
                            disk_adr <= 9'h000;
                        end
                    end
                `DISK_ST_READ_SECTOR:
                    begin
                        if(disk_adr != 9'h1FF) begin
                            disk_ram_wr <= 1'b1;
                            disk_adr <= disk_adr + 9'h001;
                            state <= `DISK_ST_READ_WAIT;
                        end
                        else begin
                            disk_ram_wr <= 1'b0;
                            state <= `DISK_ST_IDLE;
                        end
                    end
                `DISK_ST_READ_WAIT:
                    begin
                        state <= `DISK_ST_READ_WAIT2;
                    end
                `DISK_ST_READ_WAIT2:
                    begin
                        state <= `DISK_ST_READ_WAIT3;
                    end
                `DISK_ST_READ_WAIT3:
                    begin
                        state <= `DISK_ST_READ_WAIT4;
                    end
                `DISK_ST_READ_WAIT4:
                    begin
                        if(disk_adr > 9'h10E)
                            disk_dat_o <= 8'h00;
                        else
                            disk_dat_o <= flash_dat_i;
                        state <= `DISK_ST_READ_SECTOR;
                    end
                `DISK_ST_WRITE_SECTOR:
                    begin
                        if(disk_adr != 9'h1FF) begin
                            disk_ram_wr <= 1'b0;
                            disk_adr <= disk_adr + 9'h001;
                        end
                        else begin
                            state <= `DISK_ST_IDLE;
                        end
                    end
            endcase
        end

assign flash_adr_o = { sector_flash_adr[23:9], disk_adr[8:0] };
assign flash_oe = 1'b0;
assign flash_we = 1'b1;
assign flash_ce = 1'b0;
assign flash_dat_o = 8'hAA;

endmodule 
