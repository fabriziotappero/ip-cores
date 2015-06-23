`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:   BMSTU
// Engineer:  Oleg Odintsov
// 
// Create Date:    11:44:32 02/24/2012 
// Design Name: 
// Module Name:    ag_video 
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


module FONT_ROM(input[10:0] adr, input cs, output[7:0] DO);
	reg[7:0] mem[0:2047];
	assign DO = cs?mem[adr]:8'bZ;
	initial begin
		`include "agathe7.v"
	end
endmodule


module ag_video(input clk50,
			input[7:0] vmode,
			output clk_vram,
			output[13:0] AB2, input[15:0] DI2,
			output[4:0] vga_bus);
	parameter
		HGR_WHITE = 4'b1111, // RGBX
		HGR_BLACK = 4'b0000,
		TEXT_COLOR= 4'b1111,
		TEXT_BACK = 4'b0000;
		
	wire clk25;
	assign clk_vram = ~clk25;
	
	wire[0:15] rDI2 = DI2;
	
//	assign AB2 = 14'b0;
	
	clk_div#2 cd2(clk50, clk25);
	
	
	wire [9:0] hpos;
	wire [8:0] vpos;
	wire video_on;
	
	reg[8:0] hpos1;
	reg[7:0] vpos1;
	
	wire[1:0] VTYPE = vmode[1:0];
	// for 64K+ - variant
//	wire[2:0] PAGE_ADDR = {vmode[6], vmode[6]? 1'b0: vmode[5], vmode[4]};
	// for 32K-variant
	wire[2:0] PAGE_ADDR = {0, vmode[5], vmode[4]};
	wire[1:0] SUBPAGE_ADDR = vmode[3:2];
	
	wire VTYPE_HGR = (VTYPE == 2'b11);
	wire VTYPE_MGR = (VTYPE == 2'b01);
	wire VTYPE_LGR = (VTYPE == 2'b00);
	wire VTYPE_TXT = (VTYPE == 2'b10);
	wire VTYPE_T32 = VTYPE_TXT && !vmode[7];
	wire VTYPE_T64 = VTYPE_TXT && vmode[7];
	wire VTYPE_T64_INV = VTYPE_T64 && !SUBPAGE_ADDR[0];
	
	wire[13:0] HGR_ADDR = {PAGE_ADDR[1:0], vpos1, hpos1[8:5]};
	wire[3:0] HGR_BITNO = hpos1[4:1];
	wire HGR_BIT = rDI2[HGR_BITNO];
	wire[3:0] HGR_COLOR = HGR_BIT? HGR_WHITE: HGR_BLACK;

	wire[13:0] MGR_ADDR = {PAGE_ADDR[1:0], vpos1[7:1], hpos1[8:4]};
	wire[1:0] MGR_BLOCKNO = hpos1[3:2];

	wire[13:0] LGR_ADDR = {PAGE_ADDR[1:0], SUBPAGE_ADDR, vpos1[7:2], hpos1[8:5]};
	wire[1:0] LGR_BLOCKNO = hpos1[4:3];
	
	wire[1:0] GR_BLOCKNO = VTYPE_MGR?MGR_BLOCKNO:
												LGR_BLOCKNO;
	
	wire[3:0] GR_COLOR = (GR_BLOCKNO == 2'b00)? {DI2[12], DI2[13], DI2[14], DI2[15]}:
								(GR_BLOCKNO == 2'b01)? {DI2[8], DI2[9], DI2[10], DI2[11]}:
								(GR_BLOCKNO == 2'b10)? {DI2[4], DI2[5], DI2[6], DI2[7]}:
																{DI2[0], DI2[1], DI2[2], DI2[3]};

	wire[13:0] TEXT_ADDR = {PAGE_ADDR[1:0], SUBPAGE_ADDR, vpos1[7:3], hpos1[8:4]};
	
	
	wire h_phase = hpos1[1:0]?0:1;
	reg[0:0] h_cnt = 0;
	wire[0:0] h_delay = h_phase?1'd1:1'd0;
	
	wire v_phase = vpos1[2:0]?1:0;
	reg[0:0] v_cnt = 0;
	wire[0:0] v_delay = v_phase?1'd1:1'd0;
	
	wire[7:0] font_char;
	wire[2:0] font_y, font_x;
	wire[10:0] font_ab = {font_char, font_y};
	wire[0:7] font_db;
	wire font_pix = font_db[font_x];

	FONT_ROM font(font_ab, 1, font_db);
	
	integer flash_cnt = 0;
	reg flash_reg = 0;
	wire	inverse = VTYPE_T64?VTYPE_T64_INV:!{DI2[5],DI2[3]},
			flash = VTYPE_T64?font_db[7]:!{DI2[5],~DI2[3]};
	wire inv_mode = inverse || (flash && flash_reg);

	
	assign font_x = VTYPE_T64?hpos1[2:0]:hpos1[3:1];
	assign font_y = vpos1[2:0];
	assign font_char = (VTYPE_T64 && hpos1[3])? DI2[7:0]: DI2[15:8];
	wire[3:0] T_COLOR = VTYPE_T64? TEXT_COLOR: {DI2[0], DI2[1], DI2[2], DI2[4]};

	assign AB2 = VTYPE_HGR? HGR_ADDR:
					VTYPE_MGR? MGR_ADDR:
					VTYPE_LGR? LGR_ADDR:
					TEXT_ADDR;
					
	wire[2:0] color = VTYPE_HGR? HGR_COLOR[3:1]:
							(VTYPE_MGR | VTYPE_LGR)? GR_COLOR[3:1]:
							((font_pix^inv_mode)?T_COLOR[3:1]: TEXT_BACK);
	
	reg[2:0] color_reg;
	
	always @(posedge clk25) begin
		if (!vga_bus[1]) begin
			hpos1 <= 0;
			h_cnt <= 1;
		end else if (video_on) begin
			if (!h_cnt) begin
				h_cnt <= h_delay;
				hpos1 <= hpos1 + 1;
			end else h_cnt <= h_cnt - 1;
		end
	end
	
	always @(posedge clk25) color_reg <= color;
	
	always @(posedge video_on) begin
		if (!vpos) begin
			vpos1 <= 0;
			v_cnt <= 1;
		end else begin
			if (!v_cnt) begin
				v_cnt <= v_delay;
				vpos1 <= vpos1 + 1;
			end else v_cnt <= v_cnt - 1;
		end
	end
	
	always @(posedge vga_bus[0]) begin
		if (flash_cnt) flash_cnt <= flash_cnt - 1;
		else begin
			flash_cnt <= 11;
			flash_reg <= ~flash_reg;
		end
	end
	
	assign {vga_bus[4], vga_bus[3], vga_bus[2]} = video_on?color_reg:3'b000;
	 
	video_counters cnt(clk25, vga_bus[0], vga_bus[1], video_on, hpos, vpos);
endmodule
