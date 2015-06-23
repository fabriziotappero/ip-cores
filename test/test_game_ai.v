`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:36:11 04/30/2009
// Design Name:   game_ai
// Module Name:   E:/Projects/Diplom/Othello/test_game_ai.v
// Project Name:  Othello
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: game_ai
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_game_ai;

	// Inputs
	reg clk;
	reg RST;
	reg go;

	// Outputs
	wire [63:0] n_red;
	wire [63:0] n_blue;
	wire ok_move;
	wire o_pl;
	wire done;
	wire [2:0] m_x;
	wire [2:0] m_y;
	wire [2:0] bestX;
	wire [2:0] bestY;

	wire [63:0] RED_BMOVE;
	wire [63:0] BLUE_BMOVE;

	wire [63:0] R_in;
	wire [63:0] B_in;
	
	reg [63:0] rosa_d;
	reg [63:0] rosa_q;
	
	reg [63:0] nero_d;
	reg [63:0] nero_q;
	
	wire [63:0] Mw;
	wire [63:0] M_ram;
	wire [63:0] dbg_DATA_w;
	wire [63:0] dbg_DATA_q;	
	wire [10:0] dbg_max_p_q;
	wire [19:0] dbg_heur;
	wire [3:0] fake;
	
	always #100 clk = ~clk;
	
	
//assign R_in = rosa_q;
//assign B_in = nero_q;

//	wire [63:0] init_RED =  64'b11111110_11001100_10000000_10010000_11000000_10000000_11000000_11100000;
//	wire [63:0] init_BLUE = 64'b00000000_00110000_01111110_01101110_00111111_01111000_00110000_00010000;	

	wire [63:0] init_RED =  64'b00000111_00000011_00000001_00000011_00001001_00000001_00110011_01111111;
	wire [63:0] init_BLUE = 64'b00001000_00001100_00011110_01111100_01110110_01111110_00001100_00000000;	


//assign init_RED = 
/*
assign R_in = (RST) ?  64'b00000000_00000000_00000000_00001000_00010000_00000000_00000000_00000000 : n_red;
assign B_in = (RST) ?  64'b00000000_00000000_00000000_00010000_00001000_00000000_00000000_00000000 : n_blue;
*/
/*
assign RED  = 64'b00000000_00000000_00000000_00001000_00010000_00000000_00000000_00000000;
assign BLUE = 64'b00000000_00000000_00000000_00010000_00001000_00000000_00000000_00000000;
*/
	initial begin
		// Initialize Inputs
	//		rosa_q <= 64'b00000000_00000000_00000000_00001000_00010000_00000000_00000000_00000000;
	//		nero_q <= 64'b00000000_00000000_00000000_00010000_00001000_00000000_00000000_00000000;
		
		clk = 0;
		//rst = 0;
		go = 0;
		RST = 1;
		// Wait 100 ns for global reset to finish
		#250;
		RST = 0;	
	   go = 1;		
		#200
		// Add stimulus here

		#200
      go = 0; 

		// Add stimulus here

	end

/*
	always @( * ) begin
		rosa_d = n_red;
		nero_d = n_blue;
	end
	
	
   always @(posedge clk) begin
		if (RST) begin
			rosa_q <= 64'b00000000_00000000_00000000_00001000_00010000_00000000_00000000_00000000;
			nero_q <= 64'b00000000_00000000_00000000_00010000_00001000_00000000_00000000_00000000;
		end
		else begin
			rosa_q <= rosa_d;
			nero_q <= nero_d;
		end
	end
	*/
	b_move uut2 (
		.clk(clk), 
		.RST(RST),
		.player(o_pl),
		.R_(n_red), 
		.B_(n_blue), 
		
		.X(m_x), 
		.Y(m_y), 
		
		.R_OUT(RED_BMOVE), 
		.B_OUT(BLUE_BMOVE)
	);

	// Instantiate the Unit Under Test (UUT)
	game_ai uut (
		.clk(clk), 
		.rst(RST), 
		.go(go), 
		.init_red(init_RED),
		.init_blue(init_BLUE),		
		
		.red_in(RED_BMOVE), 
		.blue_in(BLUE_BMOVE), 
		
		.n_red(n_red), 
		.n_blue(n_blue), 
		
//		.ok_move(ok_move), 
		.o_pl(o_pl), 
		.done(done), 
		.m_x(m_x), 
		.m_y(m_y), 
		
		.bestX(bestX), 
		.bestY(bestY),
		.M_wq(Mw),
		.fake_state(fake),
		.M_wram(M_ram),
//		.dbg_DATA_w(dbg_DATA_w),
//		.dbg_DATA_q(dbg_DATA_q),		
		.dbg_max_p_q(dbg_max_p_q),
		.dbg_heur(dbg_heur)
	);

endmodule

