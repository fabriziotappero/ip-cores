/*
 * WISHBONE to SystemACE MPU + CY7C67300 bridge
 * Copyright (C) 2008 Sebastien Bourdeauducq - http://lekernel.net
 * This file is part of Milkymist.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

module aceusb_access(
	/* Control */
	input ace_clkin,
	input rst,
	input [5:0] a,
	input [15:0] di,
	output reg [15:0] do,
	input read,
	input write,
	output reg ack,

	/* SystemACE/USB interface */
	output [6:1] aceusb_a,
	inout [15:0] aceusb_d,
	output reg aceusb_oe_n,
	output reg aceusb_we_n,

	output reg ace_mpce_n,

	output usb_cs_n,
	output usb_hpi_reset_n
);

/* USB is not supported yet. Disable the chip. */
assign usb_cs_n = 1'b1;
assign usb_hpi_reset_n = 1'b1;

/* 16-bit mode only */
assign aceusb_a = a;

reg d_drive;
assign aceusb_d = d_drive ? di : 16'hzz;

reg d_drive_r;
reg aceusb_oe_n_r;
reg aceusb_we_n_r;
reg ace_mpce_n_r;
always @(posedge ace_clkin) begin
	d_drive <= d_drive_r;
	aceusb_oe_n <= aceusb_oe_n_r;
	aceusb_we_n <= aceusb_we_n_r;
	ace_mpce_n <= ace_mpce_n_r;
end

reg d_in_sample;
always @(posedge ace_clkin)
	if(d_in_sample)
		do <= aceusb_d;

reg [2:0] state;
reg [2:0] next_state;

localparam
	IDLE = 3'd0,
	READ = 3'd1,
	READ1 = 3'd2,
	READ2 = 3'd3,
	WRITE = 3'd4,
	ACK = 3'd5;

always @(posedge ace_clkin) begin
	if(rst)
		state <= IDLE;
	else
		state <= next_state;
end

always @(state or read or write) begin
	d_drive_r = 1'b0;
	aceusb_oe_n_r = 1'b1;
	aceusb_we_n_r = 1'b1;
	ace_mpce_n_r = 1'b1;
	d_in_sample = 1'b0;
	ack = 1'b0;
	
	next_state = state;
	
	case(state)
		IDLE: begin
			if(read) begin
				ace_mpce_n_r = 1'b0;
				next_state = READ;
			end
			if(write) begin
				ace_mpce_n_r = 1'b0;
				next_state = WRITE;
			end
		end
		
		READ: begin
			ace_mpce_n_r = 1'b0;
			next_state = READ1;
		end
		READ1: begin
			ace_mpce_n_r = 1'b0;
			aceusb_oe_n_r = 1'b0;
			next_state = READ2;
		end
		READ2: begin
			d_in_sample = 1'b1;
			next_state = ACK;
		end
		
		WRITE: begin
			d_drive_r = 1'b1;
			ace_mpce_n_r = 1'b0;
			aceusb_we_n_r = 1'b0;
			next_state = ACK;
		end
		
		ACK: begin
			ack = 1'b1;
			next_state = IDLE;
		end
	endcase
end

endmodule
