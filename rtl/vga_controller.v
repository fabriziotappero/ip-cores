`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:41:15 04/12/2009 
// Design Name: 
// Module Name:    vga_controller 
// Project Name: The FPGA Othello Game
// Target Devices: Spartan3E
// Tool versions: 
// Description: 
//      ro: Acest modul va desena tabla de joc: Va primi la intrare tabelele R,B,M
//          -- cele 3 dimensiuni ale jocului Reversi :) ,si va genera valorile RGB 
//          corespunzatoare, si doar in momentul in care hv_sync permite asta.
//
// Dependencies: hv_sync
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//      Marius TIVADAR.
//////////////////////////////////////////////////////////////////////////////////
module vga_controller(clk, 
							 vga_h_sync, 
							 vga_v_sync, 
							 vga_R, 
							 vga_G, 
							 vga_B, 
							 boardR, 
							 boardB, 
							 boardM, 
							 coordX, 
							 coordY);

/* global clock */ 
input clk;
/* Reversi board: R, B, M */
input [63:0] boardR;
input [63:0] boardB;
input [63:0] boardM;
/* pozition in board X,Y */
input [2:0] coordX;
input [2:0] coordY;
 
/* outputs vga H/V sync, and R,G,B */
output vga_h_sync, vga_v_sync, vga_R, vga_G, vga_B;
 
 
/* X,Y screen counters */
wire [9:0] cntX;
wire [8:0] cntY;

/* registers for R,G,B */
reg R, G, B;

reg [2:0] i;
reg [2:0] j; 

parameter SQUARE_SIZE     = 32;
parameter SQUARES         = 8;
parameter SQUARE_X_BORDER = 29;
parameter SQUARE_Y_BORDER = 28;
parameter BOARD_X_OFFSET  = 0;
parameter BOARD_Y_OFFSET  = 0;


/* we instantiate H/V generator */				  
hvsync_gen vga_sync(
					   .clk(clk), 
						.h_sync(vga_h_sync), 
						.v_sync(vga_v_sync), 
						.wcntX(cntX),  // screen counters
						.wcntY(cntY)
						); 
							 
 
 /* draw the board */
 always @ (posedge clk)
 begin
	if ( 
		   (cntX > BOARD_X_OFFSET) 
		&& (cntX < SQUARES * SQUARE_SIZE) 
		&& (cntY > BOARD_Y_OFFSET) 
		&& (cntY < SQUARES * SQUARE_SIZE) 
		&& (cntX % SQUARE_SIZE < SQUARE_X_BORDER) 
		&& (cntY % SQUARE_SIZE < SQUARE_Y_BORDER) 
	
		) 
	  begin
		i  <= cntX / SQUARE_SIZE;
		j  <= cntY / SQUARE_SIZE;

      /* of course, this could be done all in one equation, but is more visible like this */
      /* if i,j = our position, draw the white square */
		if ( i == coordX && j == coordY ) begin
			R <= 1;
			B <= 1;
			G <= 1;
		end
		/* else, draw yellow squares (where current player is allowed to move */
		else if ( boardM[j*8 + i] == 1'b1 ) begin
			R <= 1;
			B <= 0;
			G <= 1;
		end
		/* draw empty squares and/or blue/red squares */
		else begin
			R <=  boardR[j*8 + i];
			B <=  boardB[j*8 + i];
			G <= (boardR[j*8 + i] == 0) && (boardB[j*8 + i] == 0);
		end
	end
	/* nothing */
	else begin
		R <= 0;
		B <= 0;
		G <= 0;
	end
 end

/* assign output */
assign vga_R = R;
assign vga_G = G;
assign vga_B = B;


endmodule
