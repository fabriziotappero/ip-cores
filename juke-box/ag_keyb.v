`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:   BMSTU
// Engineer:  Oleg Odintsov
// 
// Create Date:    00:26:47 02/26/2012 
// Design Name: 
// Module Name:    ag_keyb 
// Project Name:    Agat Hardware Project
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////


module signal_filter(input clk, input in, output reg out);
	always @(posedge clk) begin
		out <= in;
	end
endmodule


module ps2_keyb_driver(ps2_clk, ps2_data, ps2_code, ps2_up, ps2_ext, ps2_event);
	input wire ps2_clk, ps2_data;
	output reg[7:0] ps2_code = 0;
	output reg ps2_up = 0, ps2_ext = 0, ps2_event = 0;
	
	reg[10:0] shreg = 11'b11111111111;
	wire[10:0] shnew = {ps2_data, shreg[10:1]};
	wire start = shnew[0], stop = shnew[10], parity = shnew[9];
	wire[7:0] data = shnew[8:1];
	
	always @(negedge ps2_clk) begin
		if (!start && stop && (parity == ~^data)) begin
			if (data == 8'hE0) begin
				ps2_ext <= 1;
			end else if (data == 8'hF0) begin
				ps2_up <= 1;
			end else begin
				ps2_code <= data;
				ps2_event <= 1;
			end
			shreg <= 11'b11111111111;
		end else begin
			if (ps2_event) begin
				ps2_up <= 0;
				ps2_ext <= 0;
				ps2_event <= 0;
			end
			shreg <= shnew;
		end
	end
endmodule

module ag_reg_decoder(keyb_in, shift, ctrl, keyb_out);
	input wire[6:0] keyb_in;
	input wire shift, ctrl;
	output wire[6:0] keyb_out;
	
	wire is_alpha = keyb_in[6] && !keyb_in[5];
	wire is_digit = !keyb_in[6] && keyb_in[5] && keyb_in[3:0];
	
	assign keyb_out =
		is_alpha?
			(shift?{1'b1,1'b1,keyb_in[4:0]}:
			 ctrl?{1'b0,1'b0,keyb_in[4:0]}:
			 keyb_in):
		is_digit?
			(shift?{1'b0,1'b1,~keyb_in[4],keyb_in[3:0]}:
			 keyb_in):
			 keyb_in;
endmodule

module ag_keyb_decoder(ps2_code, ps2_ext, shift, ctrl, alt, rus, keyb_code);
	input wire[7:0] ps2_code;
	input wire ps2_ext, shift, ctrl, alt, rus;
	output wire[6:0] keyb_code;
	reg[6:0] keyb_table[0:511]; // eng + rus
	integer i;
	
	wire[6:0] keyb_in;
	
	assign keyb_in = keyb_table[{rus,ps2_code}];
	ag_reg_decoder rd(keyb_in, shift, ctrl, keyb_code);

	initial begin
		for (i = 0; i < 512; i = i + 1) keyb_table[i] = 0;
		
		// eng table
		keyb_table['h15] = 'h51; // Q
		keyb_table['h1D] = 'h57; // W
		keyb_table['h24] = 'h45; // E
		keyb_table['h2D] = 'h52; // R
		keyb_table['h2C] = 'h54; // T
		keyb_table['h35] = 'h59; // Y
		keyb_table['h3C] = 'h55; // U
		keyb_table['h43] = 'h49; // I
		keyb_table['h44] = 'h4F; // O
		keyb_table['h4D] = 'h50; // P
		keyb_table['h54] = 'h5B; // {
		keyb_table['h5B] = 'h5D; // }
		
		keyb_table['h1C] = 'h41; // A
		keyb_table['h1B] = 'h53; // S
		keyb_table['h23] = 'h44; // D
		keyb_table['h2B] = 'h46; // F
		keyb_table['h34] = 'h47; // G
		keyb_table['h33] = 'h48; // H
		keyb_table['h3B] = 'h4A; // J
		keyb_table['h42] = 'h4B; // K
		keyb_table['h4B] = 'h4C; // L
		keyb_table['h4C] = 'h2A; // :
		keyb_table['h52] = 'h22; // "
		keyb_table['h5D] = 'h5C; // \
		keyb_table['h5A] = 'h0D; // enter
		
		keyb_table['h1A] = 'h5A; // Z
		keyb_table['h22] = 'h58; // X
		keyb_table['h21] = 'h43; // C
		keyb_table['h2A] = 'h56; // V
		keyb_table['h32] = 'h42; // B
		keyb_table['h31] = 'h4E; // N
		keyb_table['h3A] = 'h4D; // M
		keyb_table['h41] = 'h2C; // <
		keyb_table['h49] = 'h2E; // >
		keyb_table['h4A] = 'h2F; // ?

		keyb_table['h05] = 'h04; // F1
		keyb_table['h06] = 'h05; // F2
		keyb_table['h04] = 'h06; // F3

		keyb_table['h75] = 'h99; // UP
		keyb_table['h74] = 'h95; // RIGHT
		keyb_table['h6B] = 'h88; // LEFT
		keyb_table['h66] = 'h88; // BS
		keyb_table['h72] = 'h9A; // DOWN
		keyb_table['h76] = 'h9B; // ESC
		keyb_table['h29] = 'h20; // SPACE
		
		keyb_table['h0E] = 'h00; // `
		keyb_table['h16] = 'h31; // 1
		keyb_table['h1E] = 'h32; // 2
		keyb_table['h26] = 'h33; // 3
		keyb_table['h25] = 'h34; // 4
		keyb_table['h2E] = 'h35; // 5
		keyb_table['h36] = 'h36; // 6
		keyb_table['h3D] = 'h37; // 7
		keyb_table['h3E] = 'h38; // 8
		keyb_table['h46] = 'h39; // 9
		keyb_table['h45] = 'h30; // 0
		keyb_table['h4E] = 'h2D; // -
		keyb_table['h55] = 'h3B; // =

		// rus table + 100h
		keyb_table['h115] = 'h4A; // Q
		keyb_table['h11D] = 'h43; // W
		keyb_table['h124] = 'h55; // E
		keyb_table['h12D] = 'h4B; // R
		keyb_table['h12C] = 'h45; // T
		keyb_table['h135] = 'h4E; // Y
		keyb_table['h13C] = 'h47; // U
		keyb_table['h143] = 'h5B; // I
		keyb_table['h144] = 'h5D; // O
		keyb_table['h14D] = 'h5A; // P
		keyb_table['h154] = 'h48; // {
		keyb_table['h15B] = 'h3A; // }, check
		
		keyb_table['h11C] = 'h46; // A
		keyb_table['h11B] = 'h59; // S
		keyb_table['h123] = 'h57; // D
		keyb_table['h12B] = 'h41; // F
		keyb_table['h134] = 'h50; // G
		keyb_table['h133] = 'h52; // H
		keyb_table['h13B] = 'h4F; // J
		keyb_table['h142] = 'h4C; // K
		keyb_table['h14B] = 'h44; // L
		keyb_table['h14C] = 'h56; // :
		keyb_table['h152] = 'h5C; // "
		keyb_table['h15D] = 'h2B; // | -> .
		keyb_table['h15A] = 'h0D; // enter
		
		keyb_table['h11A] = 'h51; // Z
		keyb_table['h122] = 'h5E; // X
		keyb_table['h121] = 'h53; // C
		keyb_table['h12A] = 'h4D; // V
		keyb_table['h132] = 'h49; // B
		keyb_table['h131] = 'h54; // N
		keyb_table['h13A] = 'h58; // M
		keyb_table['h141] = 'h42; // <
		keyb_table['h149] = 'h2C; // >
		keyb_table['h14A] = 'h2F; // ?

		keyb_table['h105] = 'h04; // F1
		keyb_table['h106] = 'h05; // F2
		keyb_table['h104] = 'h06; // F3

		keyb_table['h175] = 'h99; // UP
		keyb_table['h174] = 'h95; // RIGHT
		keyb_table['h16B] = 'h88; // LEFT
		keyb_table['h166] = 'h88; // BS
		keyb_table['h172] = 'h9A; // DOWN
		keyb_table['h176] = 'h9B; // ESC
		keyb_table['h129] = 'h20; // SPACE
		
		keyb_table['h10E] = 'h00; // `
		keyb_table['h116] = 'h31; // 1
		keyb_table['h11E] = 'h32; // 2
		keyb_table['h126] = 'h33; // 3
		keyb_table['h125] = 'h34; // 4
		keyb_table['h12E] = 'h35; // 5
		keyb_table['h136] = 'h36; // 6
		keyb_table['h13D] = 'h37; // 7
		keyb_table['h13E] = 'h38; // 8
		keyb_table['h146] = 'h39; // 9
		keyb_table['h145] = 'h30; // 0
		keyb_table['h14E] = 'h2D; // -
		keyb_table['h155] = 'h3B; // =
	end
endmodule

module ag_keyb(clk, ps2_bus, keyb_reg, keyb_clear, keyb_rus, keyb_rst, keyb_pause);
	input clk;
	input wire[1:0] ps2_bus;
	output wire[7:0] keyb_reg;
	input wire keyb_clear;
	output wire keyb_rus;
	output wire keyb_rst;
	output wire keyb_pause;
	
	
	wire ps2_clk, ps2_data;
	assign {ps2_clk, ps2_data} = ps2_bus;
	
	reg[7:0] keyb_code;
	reg clr = 0, got = 0;
	reg lshift = 0, rshift = 0, ctrl = 0, alt = 0, rus = 0, rst = 0, pause = 0;
	wire[7:0] ps2_code;
	wire ps2_up, ps2_ext, ps2_event;
	
	assign keyb_reg = clr?0:keyb_code;
	assign keyb_rus = rus;
	assign keyb_rst = rst;
	assign keyb_pause = pause;
	
	wire[6:0] dec_code;
	
	ps2_keyb_driver kd(ps2_clk, ps2_data, ps2_code, ps2_up, ps2_ext, ps2_event);
	ag_keyb_decoder dec(ps2_code, ps2_ext, lshift | rshift, ctrl, alt, rus, dec_code);
	
	always @(posedge clk) begin
		if (keyb_clear) clr <= 1;
		if (ps2_event && !got) begin
			if (!ps2_up) begin
				if (ps2_code == 8'h12 && ctrl) rus <= 0;
				else if (ps2_code == 8'h14 && lshift) rus <= 0;
				else if (ps2_code == 8'h59 && ctrl) rus <= 1;
				else if (ps2_code == 8'h14 && rshift) rus <= 1;
				clr <= 0;
				keyb_code <= {|dec_code, dec_code};
			end
			if (ps2_code == 8'h12) lshift <= ~ps2_up;
			else if (ps2_code == 8'h59) rshift <= ~ps2_up;
			else if (ps2_code == 8'h14 || ps2_code == 8'h0D) ctrl <= ~ps2_up; // ctrl or tab
			else if (ps2_code == 8'h11) alt <= ~ps2_up;
			else if (ps2_code == 8'h7E) pause <= ~ps2_up;
			
			if (ps2_code == 8'h76 && ctrl) rst <= ~ps2_up;
			got <= 1;
		end
		if (!ps2_event) got <= 0;
	end
endmodule
