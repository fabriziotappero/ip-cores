////////////////////////////////////////////////////////////////////////////
////									////
//// t2600 IP Core	 						////
////									////
//// This file is part of the t2600 project				////
//// http://www.opencores.org/cores/t2600/				////
////									////
//// Description							////
//// Video module					 		////
////									////
//// TODO:								////
//// - Collision detection						////
//// - Pixel output							////
//// 									////
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

`include "timescale.v"

module video(clk, reset_n, io_lines, enable, mem_rw, address, data, pixel, write_addr, write_data, write_enable_n);
	parameter [3:0] DATA_SIZE = 4'd8;
	parameter [3:0] ADDR_SIZE = 4'd10; // this is the *local* addr_size

	localparam [3:0] DATA_SIZE_ = DATA_SIZE - 4'd1;
	localparam [3:0] ADDR_SIZE_ = ADDR_SIZE - 4'd1;

	input clk; // master clock signal, 1.19mhz
	input reset_n;
	input [15:0] io_lines; // inputs from the keyboard controller
	input enable; // since the address bus is shared an enable signal is used
	input mem_rw; // read == 0, write == 1
	input [ADDR_SIZE_:0] address; // system address bus
	inout [DATA_SIZE_:0] data; // controler <=> video data bus
	output reg [2:0] pixel;
	output reg [10:0] write_addr; // for the video memory
	output reg [2:0] write_data;
	output reg write_enable_n;
	
	reg [DATA_SIZE_:0] data_drv; // wrapper for the data bus

	assign data = (mem_rw || !reset_n) ? 8'bZ : data_drv; // if under writing the bus receives the data from cpu, else local data. 

	reg VSYNC; // vertical sync set-clear
	reg [2:0] VBLANK; // vertical blank set-clear
	reg WSYNC; //  SEMI-strobe wait for leading edge of horizontal blank
	reg RSYNC; //  s t r o b e reset horizontal sync counter
	reg [5:0] NUSIZ0; //  number-size player-missile 0
	reg [5:0] NUSIZ1; //  number-size player-missile 1
	reg [6:0] COLUP0; //  color-lum player 0
	reg [6:0] COLUP1; //  color-lum player 1
	reg [6:0] COLUPF; //  color-lum playfield
	reg [6:0] COLUBK; //  color-lum background
	reg [4:0] CTRLPF; //  control playfield ball size & collisions
		// D0 = REF (reflect playfield)
		// D1 = SCORE (left half of playfield gets color of player 0, right half gets color of player 1)
		// D2 = PFP (playfield gets priority over players so they can move behind the playfield)
		// D4 & D5 = BALL SIZE
	reg REFP0; //  reflect player 0
	reg REFP1; //  reflect player 1
	reg [3:0] PF0; //  playfield register byte 0
	reg [7:0] PF1; //  playfield register byte 1
	reg [7:0] PF2; //  playfield register byte 2
	// all the RES register became combinational logic
	//reg RESP0; //  s t r o b e reset player 0
	//reg RESP1; //  s t r o b e reset player 1
	//reg RESM0; //  s t r o b e reset missile 0
	//reg RESM1; //  s t r o b e reset missile 1
	//reg RESBL; //  s t r o b e reset ball
	reg [3:0] AUDC0; //  audio control 0
	reg [4:0] AUDC1; //  audio control 1
	reg [4:0] AUDF0; //  audio frequency 0
	reg [3:0] AUDF1; //  audio frequency 1
	reg [3:0] AUDV0; //  audio volume 0
	reg [3:0] AUDV1; //  audio volume 1
	reg [7:0] GRP0; //  graphics player 0
	reg [7:0] GRP1; //  graphics player 1
	reg ENAM0; //  graphics (enable) missile 0
	reg ENAM1; //  graphics (enable) missile 1
	reg ENABL; //  graphics (enable) ball
	reg [3:0] HMP0; //  horizontal motion player 0
	reg [3:0] HMP1; //  horizontal motion player 1
	reg [3:0] HMM0; //  horizontal motion missile 0
	reg [3:0] HMM1; //  horizontal motion missile 1
	reg [3:0] HMBL; //  horizontal motion ball
	reg VDELP0; //  vertical delay player 0
	reg VDEL01; //  vertical delay player 1
	reg VDELBL; //  vertical delay ball
	reg RESMP0; //  reset missile 0 to player 0
	reg RESMP1; //  reset missile 1 to player 1
	reg HMOVE; //  s t r o b e apply horizontal motion
	reg HMCLR; //  s t r o b e clear horizontal motion registers

	reg [1:0] CXM0P; // read collision MO P1 M0 P0
	reg [1:0] CXM1P; // read collision M1 P0 M1 P1
	reg [1:0] CXP0FB; // read collision P0 PF P0 BL
	reg [1:0] CXP1FB; // read collision P1 PF P1 BL
	reg [1:0] CXM0FB; // read collision M0 PF M0 BL
	reg [1:0] CXM1FB; // read collision M1 PF M1 BL
	reg CXBLPF; // read collision BL PF unused
	reg [1:0] CXPPMM; // read collision P0 P1 M0 M1
	reg INPT0; // read pot port
	reg INPT1; // read pot port
	reg INPT2; // read pot port
	reg INPT3; // read pot port
	reg INPT4; // read input
	reg INPT5; // read input

	reg [8:0] vert_counter;
	reg [7:0] hor_counter;

	always @(posedge clk  or negedge reset_n) begin
		if (reset_n == 1'b0) begin
			hor_counter <= 8'd0;
			vert_counter <= 9'd0;
		end
		else begin
			if (hor_counter == 8'd227) begin
				hor_counter <= 8'd0;
				WSYNC <= 1'b0; // TODO: check this on stella pdf

				if (vert_counter == 9'd261) begin
					vert_counter <= 9'd0;
				end
				else begin
					vert_counter <= vert_counter + 9'd1;
				end
			end
			else begin
				hor_counter <= hor_counter + 6'd1;
			end
		end
	end

	always @(posedge clk  or negedge reset_n) begin
		if (reset_n == 1'b0) begin
			data_drv <= 8'h00;
			WSYNC <= 1'b0;
		end
		else if (enable == 1'b1) begin
			if (mem_rw == 1'b0) begin // reading! 
				case (address) 
					6'h00: data_drv <= {CXM0P, 6'b000000};
					6'h01: data_drv <= {CXM1P, 6'b000000};
					6'h02: data_drv <= {CXP0FB, 6'b000000};
					6'h03: data_drv <= {CXP1FB, 6'b000000};
					6'h04: data_drv <= {CXM0FB, 6'b000000};
					6'h05: data_drv <= {CXM1FB, 6'b000000};
					6'h06: data_drv <= {CXBLPF, 7'b000000};
					6'h07: data_drv <= {CXPPMM, 6'b000000};
					6'h08: data_drv <= {INPT0, 7'b000000};
					6'h09: data_drv <= {INPT1, 7'b000000};
					6'h0A: data_drv <= {INPT2, 7'b000000};
					6'h0B: data_drv <= {INPT3, 7'b000000};
					6'h0C: data_drv <= {INPT4, 7'b000000};
					6'h0D: data_drv <= {INPT5, 7'b000000};
					default: ;
				endcase
			end  	
			else begin // writing! 
				case (address)
					6'h00: begin
						VSYNC <= data[1];
					end
					6'h01: begin
						VBLANK <= {data[7:6], data[1]};
					end
					6'h02: begin
						WSYNC <= 1'b1; // STROBE
					end
					6'h03: begin
						RSYNC <= 1'b1; // STROBE
					end
					6'h04: begin
						NUSIZ0 <= data[5:0];
					end
					6'h05: begin
						NUSIZ1 <= data[5:0];
					end
					6'h06: begin
						COLUP0 <= data[7:1];
					end
					6'h07: begin
						COLUP1 <= data[7:1];
					end
					6'h08: begin
						COLUPF <= data[7:1];
					end
					6'h09: begin
						COLUBK <= data[7:1];
					end
					6'h0a: begin
						CTRLPF <= {data[5:4], data[2:0]};
					end
					6'h0b: begin
						REFP0 <= data[3];
					end
					6'h0c: begin
						REFP1 <= data[3];
					end
					6'h0d: begin
						PF0 <= data[7:4	];
					end
					6'h0e: begin
						PF1 <= data;
					end
					6'h0f: begin
						PF2 <= data;
					end
					6'h15: begin
						AUDC0 <= data[3:0];
					end
					6'h16: begin
						AUDC1 <= data[4:0];
					end
					6'h17: begin
						AUDF0 <= data[4:0];
					end
					6'h18: begin
						AUDF1 <= data[3:0];
					end
					6'h19: begin
						AUDV0 <= data[3:0];
					end
					6'h1A: begin
						AUDV1 <= data[3:0];
					end
					6'h1B: begin
						GRP0 <= data;
					end
					6'h1C: begin
						GRP1 <= data;
					end
					6'h1D: begin
						ENAM0 <= data[1];
					end
					6'h1E: begin
						ENAM1 <= data[1];
					end
					6'h1F: begin
						ENABL <= data[1];
					end
					6'h20: begin
						HMP0 <= data[7:4];
					end
					6'h21: begin
						HMP1 <= data[7:4];
					end
					6'h22: begin
						HMM0 <= data[7:4];
					end
					6'h23: begin
						HMM1 <= data[7:4];
					end
					6'h24: begin
						HMBL <= data[7:4];
					end
					6'h25: begin
						VDELP0 <= data[0];
					end
					6'h26: begin
						VDEL01 <= data[0];
					end
					6'h27: begin
						VDELBL <= data[0];
					end
					6'h28: begin
						RESMP0 <= data[1];
						ENAM0 <= 1'b0;
					end
					6'h29: begin
						RESMP1 <= data[1];
						ENAM1 <= 1'b0;
					end
					6'h2a: begin
						HMOVE <= 1'b1; // STROBE
					end
					6'h2b: begin
						HMCLR <= 1'b1; // STROBE
					end
					6'h2c: begin // cxclr STROBE
						CXM0P <= 2'b0; // collision MO P1 M0 P0
						CXM1P <= 2'b0; // collision M1 P0 M1 P1
						CXP0FB <= 2'b0; // collision P0 PF P0 BL
						CXP1FB <= 2'b0; // collision P1 PF P1 BL
						CXM0FB <= 2'b0; // collision M0 PF M0 BL
						CXM1FB <= 2'b0; // collision M1 PF M1 BL
						CXBLPF <= 1'b0; // collision BL PF unused
						CXPPMM <= 2'b0; // collision P0 P1 M0 M1
					end
					default: begin
					end
				endcase
			end
		end
	end

reg draw_p0;
reg draw_p1;
reg draw_m0;
reg draw_m1;
reg draw_bl;

reg [8:0] p0_position; // sized in the same way the vert counter is
reg [8:0] p1_position; // sized in the same way the vert counter is
reg [8:0] m0_position; // sized in the same way the vert counter is
reg [8:0] m1_position; // sized in the same way the vert counter is
reg [8:0] bl_position; // sized in the same way the vert counter is

always @(posedge clk or negedge reset_n) begin
	if (reset_n == 1'b0) begin
		p0_position <= 9'b000000000;
		p1_position <= 9'b000000000;
		m0_position <= 9'b000000000;
		m1_position <= 9'b000000000;
		bl_position <= 9'b000000000;
	end
	else begin
		if (draw_p0) begin
			p0_position <= vert_counter;
		end
		if (draw_p1) begin
			p1_position <= vert_counter;
		end

		if (RESMP0) begin
			m0_position <= p0_position;
		end
		else if (draw_m0) begin
			m0_position <= vert_counter;
		end
	
		if (RESMP1) begin
			m1_position <= p1_position;
		end
		else if (draw_m1) begin
			m1_position <= vert_counter;
		end

		if (draw_bl) begin
			bl_position <= vert_counter;
		end

		// collision detection. note that the playfield must be handled differently
		CXM0P[0] <= (m0_position == p0_position);	
		CXM0P[1] <= (m0_position == p1_position);	
		CXM1P[0] <= (m1_position == p1_position);	
		CXM1P[1] <= (m1_position == p0_position);
		CXP0FB[0] <= (p0_position == bl_position);	
		//CXP0FB[1] <= (p0_position == pf_position);		
		CXP1FB[0] <= (p1_position == bl_position);	
		//CXP1FB[1] <= (p1_position == pf_position);	
		CXM0FB[0] <= (m0_position == bl_position);	
		//CXM0FB[1] <= (m0_position == pf_position);	
		CXM1FB[0] <= (m1_position == bl_position);	
		//CXM1FB[1] <= (m1_position == pf_position);
		//CXBLPF <= (bl_position == pf_position);	
		CXPPMM[0] <= (m0_position == m1_position);			
		CXPPMM[1] <= (p0_position == p1_position);			

	end
end

always @ (*) begin // always combinational block that handles strobe registers.
	draw_p0 = 1'b0;
	draw_p1 = 1'b0;
	draw_m0 = 1'b0;
	draw_m1 = 1'b0;
	draw_bl = 1'b0;

	if (enable == 1'b1 && mem_rw == 1'b1) begin //  
		case (address)
			6'h10: begin
				draw_p0 = 1'b1;
			end
			6'h11: begin
				draw_p1 = 1'b1;
			end
			6'h12: begin
				draw_m0 = 1'b1;
			end
			6'h13: begin
				draw_m1 = 1'b1;
			end
			6'h14: begin
				draw_bl = 1'b1;
			end
		endcase
	end
end


always @(*) begin // comb logic
	if (hor_counter < 68 || vert_counter < 40 || vert_counter > 232) begin
		pixel = 3'd0;
		write_enable_n = 1'b1;
		write_addr = 0;
		write_data = vert_counter[2:0];
	end
	else begin
		write_enable_n = 1'b0;
		write_addr = (hor_counter - 68) + (vert_counter - 40)*160;
		write_data = 3'd4;

		if (CTRLPF[2] == 1'b1) begin // playfield gets priority over players so they can move behind the playfield
				// Priority Objects
				// 1 		PF, BL
				// 2 		P0, M0
				// 3 		P1, M1
				// 4 		BK

		end
		else begin // regular priority
				// Priority 	Objects
				// 1 		P0, M0
				// 2 		P1, M1
				// 3 		BL, PF
				// 4 		BK
			if (CTRLPF[0] == 1'b1) begin// reflected PF
				if (vert_counter == p0 || vert_counter == m0) begin
					pixel = COLUP0;
				end
				else if (vert_counter == p1 || vert_counter == m1) begin
					pixel = COLUP1;
				end
				else if (ENABL == 1'b1) begin // the ball is enabled
					if (vert_counter == bl_position) begin
						pixel = COLUPF;
					end	
				end
				else begin 
					if (vert_counter < 4) begin
						pixel = (PF0[vert_counter] == 1'b1) ? COLUPF : COLUBK;
					end
					else if (vert_counter < 12) begin
						pixel = (PF1[vert_counter - 4] == 1'b1) ? COLUPF : COLUBK;
					end
					else if (vert_counter < 20) begin
						pixel = (PF2[vert_counter - 12] == 1'b1) ? COLUPF : COLUBK;
					end
					else if (vert_counter < 28) begin
						pixel = (PF2[vert_counter - 20] == 1'b1) ? COLUPF : COLUBK;
					end
					else if (vert_counter < 36) begin
						pixel = (PF1[vert_counter - 28] == 1'b1) ? COLUPF : COLUBK;
					end
					else begin
						pixel = (PF0[vert_counter - 36] == 1'b1) ? COLUPF : COLUBK;
					end
				end
			end
			else begin
				if (vert_counter < 4) begin
					pixel = (PF0[vert_counter] == 1'b1) ? COLUPF : COLUBK;
				end
				else if (vert_counter < 12) begin
					pixel = (PF1[vert_counter - 4] == 1'b1) ? COLUPF : COLUBK;
				end
				else if (vert_counter < 20) begin
					pixel = (PF2[vert_counter - 12] == 1'b1) ? COLUPF : COLUBK;
				end
				else if (vert_counter < 24) begin
					pixel = (PF0[vert_counter - 20] == 1'b1) ? COLUPF : COLUBK;
				end
				else if (vert_counter < 32) begin
					pixel = (PF1[vert_counter - 24] == 1'b1) ? COLUPF : COLUBK;
				end
				else begin
					pixel = (PF2[vert_counter - 32] == 1'b1) ? COLUPF : COLUBK;
				end
			end
		end

			pixel = 3'd4;

	end
end
	
endmodule

