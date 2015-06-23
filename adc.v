`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  Bauman Moscow University
// Engineer: Oleg A. Odintsov
// 
// Create Date:    21:44:06 02/28/2012 
// Design Name: 
// Module Name:    Main module
// Project Name:   Oscilloscope
// Target Devices: Xilinx Spartan 3E
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
module adc(input clk,
			input[1:0] flags, // enable or disable phases
			input[3:0] gain_A,
			input[3:0] gain_B,
			output reg[13:0] val_A,
			output reg[13:0] val_B,
			output reg upd,
			output SPI_MOSI,
			output AMP_CS,
			output SPI_SCK,
			output AMP_SHDN,
			input  AMP_DOUT,
			output AD_CONV,
			input  SPI_MISO);

	parameter
		STATE_IDLE = 2'd0,
		STATE_G = 2'd1,
		STATE_V  = 2'd3,
		FLAG_G = 0,
		FLAG_V = 1;
		
	reg[1:0] state = STATE_IDLE;
	reg[8:0] val;
	reg[13:0] out;
	integer cnt = 0;
	
	wire state_amp = (state == STATE_G);
	wire state_adc = (state == STATE_V);
	
	assign AD_CONV = state_adc && (cnt == 34);
	assign SPI_MOSI = state_amp?val[8]:1'bZ;
	assign AMP_CS = ~state_amp;
	assign SPI_SCK = state_amp?((cnt==9||cnt==0)?1'b0:~clk): state_adc?((cnt == 34)?1'b0:~clk): 1'bZ;
	assign AMP_SHDN = 1'b0;
	
	
	
	function[1:0] next_state;
		input[1:0] state;
		input[2:0] flags;
		case (state)
		STATE_IDLE:
			next_state = flags[FLAG_G]?STATE_G:(flags[FLAG_V]?STATE_V:STATE_IDLE);
		STATE_G:
			next_state = flags[FLAG_V]?STATE_V:(flags[FLAG_G]?STATE_G:STATE_IDLE);
		STATE_V:
			next_state = flags[FLAG_G]?STATE_G:(flags[FLAG_V]?STATE_V:STATE_IDLE);
		endcase
	endfunction
	
	always @(posedge clk) begin
		if (cnt) begin
			cnt <= cnt - 1;
			case (state)
			STATE_G: val <= {val[7:0], 1'b0};
			STATE_V:	begin
				if (cnt <= 31 && cnt >= 18) out <= {out[12:0], ~SPI_MISO};
				else if (cnt == 17) val_A <= out;
				else if (cnt <= 15 && cnt >= 2) out <= {out[12:0], ~SPI_MISO};
				else if (cnt == 1) begin val_B <= out; upd <= 1; end
				end
			endcase
		end else begin
			state = next_state(state, flags);
			upd <= 0;
			case (state)
			STATE_G: begin cnt <= 9; val <= {1'b0, gain_B, gain_A}; end
			STATE_V:  begin cnt <= 34; end
			endcase
		end
	end
endmodule


module clk_div(input clk, output clk1);
	parameter divide = 16;
	wire clk0;

   DCM_SP #(
      .CLKDV_DIVIDE(divide) // Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
                          //   7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
   ) DCM_SP_inst (
      .CLKDV(clk1),   // Divided DCM CLK out (CLKDV_DIVIDE)
      .CLKIN(clk),   // Clock input (from IBUFG, BUFG or DCM)
		.CLK0(clk0),
		.CLKFB(clk0),
		.RST(0)
   );

endmodule

module my_clk_div(input clk, output reg clk1 = 0);
	parameter divide = 16;
	integer cnt = 0;
	always @(posedge clk) begin
		cnt <= (cnt?cnt:(divide/2)) - 1;
		if (!cnt) clk1 <= ~clk1;
	end
	
endmodule


module video_counters(
		input clk,
		output reg video_vsync = 1,
		output reg video_hsync = 1,
		output video_on,
		output reg [10:1] hpos = 0,
		output reg [9:1] vpos = 0);
		
	integer hcnt = 0, vcnt = 0;

	reg video_von = 0, video_hon = 0;
	assign video_on = video_von & video_hon;
		
	always @(posedge video_hsync) begin
		vcnt <= vcnt + 1;
		vpos <= video_von?vpos + 1: 0;
		case (vcnt)
		2: video_vsync = 1;
		31: video_von = 1;
		511: video_von = 0;
		521: begin vcnt <=0; video_vsync = 0; end
		endcase
	end

	always @(posedge clk) begin
		if (!video_hon) hcnt <= hcnt - 1;
		else hpos <= hpos + 1;
		
		if (hpos == 639) video_hon <= 0;
		
		if (hpos == 640) begin
			if (!hcnt) begin
				hcnt <= 96;
				video_hsync <= 0;
				hpos <= 0;
			end
		end else if (!hcnt) begin
			if (!video_hsync) begin
				video_hsync <= 1;
				hcnt <= 48;
			end else if (!video_hon) begin
				video_hon <= 1;
				hcnt <= 16;
			end
		end
	end
endmodule



module rot_driver(input clk,
				input rot_a, input rot_b, 
				output wire rot_dir, output wire rot_event_out);

	reg rot_a_latch = 0, rot_b_latch = 0;
	assign rot_dir = rot_b_latch, rot_event_out = rot_a_latch;
	always @(posedge clk) begin
		case ({rot_a, rot_b})
		2'b00: rot_a_latch <= 1;
		2'b11: rot_a_latch <= 0;
		2'b10: rot_b_latch <= 1;
		2'b01: rot_b_latch <= 0;
		endcase
	end
endmodule

module btn_driver(input clk, input btn, output reg sig = 0);
	parameter nskip = 'hfff;
	integer counter = 0;
	wire lock = counter?1:0;
	
	always @(posedge clk) begin
		if (counter) counter <= counter - 1;
		if (!lock && sig != btn) begin
			sig <= btn;
			counter <= nskip;
		end
	end
endmodule


module main(input CLK_50MHZ,
			output SPI_MOSI,
			output AMP_CS,
			output SPI_SCK,
			output AMP_SHDN,
			input  AMP_DOUT,
			output AD_CONV,
			input  SPI_MISO,
			output SPI_SS_B,
			output DAC_CS,
			output SF_CE0,
			output FPGA_INIT_B,
			output[7:0] LED,
			output VGA_RED, VGA_GREEN, VGA_BLUE,
			output VGA_HSYNC, VGA_VSYNC,
			input ROT_A, ROT_B,
			input BTN_EAST, BTN_NORTH, BTN_SOUTH, BTN_WEST
			);

	reg[3:0] amp_A = 4'b0001, amp_B = 4'b0001;
	wire[13:0] val_A, val_B;
	wire upd;
	
	assign SPI_SS_B = 1'b1, DAC_CS = 1'b1, SF_CE0 = 1'b1, FPGA_INIT_B = 1'b0;
	
	assign LED = val_A[13:6];
	//assign LED = {SPI_SCK, AMP_CS, SPI_MOSI, AMP_DOUT, AD_CONV, SPI_MISO, 2'b0};
	
	wire CLK, CLK_25MHZ, CLK_5HZ;
	wire video_on;
	wire[10:1] hpos;
	wire[9:1] vpos;
	reg[2:0] color;
	assign {VGA_RED, VGA_GREEN, VGA_BLUE} = video_on?color: 3'b0;
	
	reg[13:0] memA[0:639];
	reg[13:0] memB[0:639];
	reg[10:1] regpos = 0;
	
	reg[13:0] curA, curB;
	reg[13:0] lastA, lastB;
	wire[13:0] ncurA = ~curA, ncurB = ~curB;
	wire[13:0] nlastA = ~lastA, nlastB = ~lastB;
	wire[9:1] posA, posB, lposA, lposB;
	
	reg[10:0] div = 1, dcnt = 0;
	reg CLK1 = 0;
	assign CLK = CLK1;
	
	assign posA = curA[13]? (241 + ncurA[12:6]): (240 - curA[12:6]);
	assign posB = curB[13]? (241 + ncurB[12:6]): (240 - curB[12:6]);

	assign lposA = lastA[13]? (241 + nlastA[12:6]): (240 - lastA[12:6]);
	assign lposB = lastB[13]? (241 + nlastB[12:6]): (240 - lastB[12:6]);
	
//	wire a_on = (vpos - 240 == val_A[13:7]);
//	wire b_on = (vpos - 240 == val_B[13:7]);
	wire a_on = ((vpos >= posA) && (vpos <= lposA)) || ((vpos >= lposA) && (vpos <= posA));
	wire b_on = ((vpos >= posB) && (vpos <= lposB)) || ((vpos >= lposB) && (vpos <= posB));
	wire x_on = (vpos == 240);
	
	clk_div#2.0 div2(CLK_50MHZ, CLK_25MHZ);
	clk_div#5  div5(CLK_50MHZ, CLK0);
	my_clk_div#2000000  div5hz(CLK0, CLK_5HZ);
	
	wire btns[3:0];
	
	btn_driver b0(CLK0, BTN_EAST, btns[0]);
	btn_driver b1(CLK0, BTN_NORTH, btns[1]);
	btn_driver b2(CLK0, BTN_SOUTH, btns[2]);
	btn_driver b3(CLK0, BTN_WEST, btns[3]);
	
	always @(posedge CLK0) begin
		dcnt <= (dcnt?dcnt:div) - 1;
		if (!dcnt) CLK1 <= ~CLK1;
	end
	
	always @(posedge CLK_5HZ) begin
		if (btns[3]) if (amp_A != 4'b0001) amp_A <= amp_A - 1;
		if (btns[0]) if (amp_A != 4'b0111) amp_A <= amp_A + 1;
		if (btns[2]) if (amp_B != 4'b0001) amp_B <= amp_B - 1;
		if (btns[1]) if (amp_B != 4'b0111) amp_B <= amp_B + 1;
	end
	
	
//	my_clk_div#25000000 div16_1(CLK_25MHZ, CLK);
	
	always @(negedge upd) begin
		memA[regpos] <= val_A;
		memB[regpos] <= val_B;
		regpos <= (regpos == 639)?0:(regpos + 1);
	end
	
	video_counters cnt(CLK_25MHZ, VGA_VSYNC, VGA_HSYNC, video_on, hpos, vpos);
	always @(posedge CLK_25MHZ) begin
		curA <= memA[hpos];
		curB <= memB[hpos];
		if (hpos) begin
			lastA <= curA;
			lastB <= curB;
		end else begin
			lastA <= memA[hpos];
			lastB <= memB[hpos];
		end
		color <= {a_on, x_on, b_on};
	end
	
	wire rot_dir, rot_event;
	
	rot_driver rot(CLK_25MHZ, ROT_A, ROT_B, rot_dir, rot_event);
	
	always @(posedge rot_event) begin
		div <= rot_dir?(div + 1): ((div>1)?(div - 1):div);
	end
	
	adc a1(CLK, 2'b11, amp_A, amp_B, val_A, val_B, upd,
			SPI_MOSI, AMP_CS, SPI_SCK, AMP_SHDN, AMP_DOUT, AD_CONV, SPI_MISO);
endmodule
