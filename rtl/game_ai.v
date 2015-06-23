`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:55:11 04/23/2009 
// Design Name: 
// Module Name:    game_ai 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
// Marius TIVADAR.
//
//////////////////////////////////////////////////////////////////////////////////
module game_ai( clk, RST, go, init_red, init_blue, red_in, blue_in, n_red, n_blue, ok_move, o_pl, done, m_x, m_y, bestX, bestY, M_wq , fake_state, M_wram, dbg_DATA_w, dbg_max_p_q, dbg_DATA_q, thinking, ai_pass, dbg_heur, dbg_node_cnt);
input clk;
input RST;
input go;
input [63:0] red_in;
input [63:0] blue_in;

input [63:0] init_red;
input [63:0] init_blue;


output [63:0] n_red;
output [63:0] n_blue;
output [2:0] m_x;
output [2:0] m_y;
output [2:0] bestX;
output [2:0] bestY;
output done;
output o_pl;
output ok_move;
output thinking;
output ai_pass;


output [63:0] M_wq;
output [63:0] M_wram;

output [3:0] fake_state;

//parameter MAX_DEPTH 			= 4'b0110;
parameter MAX_DEPTH 			= 6;
parameter HEUR_WIDTH       = 19;

/*
wire [63:0] red;
wire [63:0] blue;


reg ok_move_d;
reg ok_move_q;
*/

//reg [63:0] red_d;
//reg [63:0] blue_d;
wire [63:0] red_w;
wire [63:0] blue_w;
wire [HEUR_WIDTH:0] heur_w;


wire we;
wire ok_move;

reg thinking_d;
reg thinking_q;

reg [63:0] red_q;
reg [63:0] blue_q;

reg [63:0] red_d;
reg [63:0] blue_d;

reg [3:0] sp_q;
reg [3:0] sp_d;

reg [3:0] state_q;
reg [3:0] state_d;

reg [2:0] X_d;
reg [2:0] X_q;

reg [2:0] Y_d;
reg [2:0] Y_q;

reg [2:0] best_X_d;
reg [2:0] best_X_q;

reg [2:0] best_Y_d;
reg [2:0] best_Y_q;

reg [2:0] last_X_d;
reg [2:0] last_X_q;

reg [2:0] last_Y_d;
reg [2:0] last_Y_q;

reg [31:0] node_count_d;
reg [31:0] node_count_q;

reg go_q;

wire [63:0] M_w;
//DEBUG
wire [63:0] M_wq;
reg [3:0] fake_state_d;
reg [3:0] fake_state_q;

reg pass_q;
reg pass_d;
wire have_to_pass;

output [HEUR_WIDTH:0] dbg_max_p_q;
output [63:0] dbg_DATA_w;
output [63:0] dbg_DATA_q;
output [31:0] dbg_node_cnt;

//DEBUG


wire [63:0] M_w2;
reg [63:0] M_d;
reg [63:0] M_q;

parameter RESET_BITS = 64 - 3*(HEUR_WIDTH + 1) - 1;
wire [RESET_BITS-1:0] DATA_w;
 reg [RESET_BITS-1:0] DATA_d;
 reg [RESET_BITS-1:0] DATA_q;

wire [HEUR_WIDTH:0] alfa_w;
 reg signed [HEUR_WIDTH:0] alfa_d;
 reg signed [HEUR_WIDTH:0] alfa_q;

wire [HEUR_WIDTH:0] beta_w;
 reg signed [HEUR_WIDTH:0] beta_d;
 reg signed [HEUR_WIDTH:0] beta_q;

wire [HEUR_WIDTH:0] best_value_w;
 reg signed [HEUR_WIDTH:0] best_value_d;
 reg signed [HEUR_WIDTH:0] best_value_q;

wire [0:0]          first_explore_w;
 reg [0:0]          first_explore_d;
 reg [0:0]          first_explore_q;


//reg [10:0] min_d;
//reg [10:0] max_d;
//reg [10:0] min_q;
//reg [10:0] max_q;

//reg [10:0] min_p_d;
reg signed [HEUR_WIDTH:0] max_p_d;
//reg [10:0] min_p_q;
reg signed [HEUR_WIDTH:0] max_p_q;

reg pl_d;
reg pl_q;
reg done_d;
reg done_q;


parameter RESET   			= 4'b0000;
parameter EXPLORE 			= 4'b0001;
parameter EXPLORE_0 			= 4'b0010;
parameter EXPLORE_M 			= 4'b0011;
parameter EXPLORE_M2 		= 4'b0100;
parameter EXPLORE_STORED 	= 4'b0101;
parameter EXPLORE_STORED_0 = 4'b0110;
parameter EXPLORE_FETCH 	= 4'b0111;
parameter EXPLORE_FETCH_0  = 4'b1000;
parameter FINISH 				= 4'b1001;
parameter LEAF   				= 4'b1010;
parameter GAME_OVER_TEST1  = 4'b1011;
//parameter EXPLORE_M3       = 4'b1011;
parameter LEAF_0           = 4'b1100;
parameter EXPLORE_PASS_M2  = 4'b1101;
parameter EXPLORE_PASS_STORED = 4'b1110;

/*
assign red  = () ? red_in : red_bram;
assign blue = () ? blue_in : blue_bram;
*/
assign thinking = thinking_q;
assign we = ((state_q == EXPLORE_M2) || (state_q == EXPLORE_PASS_M2));
assign n_red = red_q;
assign n_blue = blue_q;
assign m_x = X_q;
assign m_y = Y_q;
assign bestX = best_X_q;
assign bestY = best_Y_q;
assign o_pl = pl_q;
assign done = done_q;
//assign ok_move = ok_move_q;
assign ok_move = (state_q == EXPLORE_M2);
assign fake_state = fake_state_q;

assign dbg_max_p_q = max_p_q;
assign M_wq = M_w;
assign M_wram = M_w2;
assign dbg_DATA_w = DATA_w;
assign dbg_DATA_q = DATA_q;

assign have_to_pass = ( (state_q == EXPLORE_0) && (M_w[63:0] == 64'b0) && (sp_q == 0));
assign ai_pass = pass_q;

//DEBUG
assign dbg_node_cnt = node_count_q;
// combinational process

output [19:0] dbg_heur;
assign dbg_heur = best_value_q;

wire [6:0] cnt_score_R;
wire [6:0] cnt_score_B;
memory_bram bram(.clk(clk), 
					  .we(we), 
					  .addr(sp_q), 
					  .DIN( {red_q, blue_q, M_q, DATA_q, alfa_q, beta_q, first_explore_q, best_value_q} ), 
					  .DOUT( {red_w, blue_w, M_w2, DATA_w, alfa_w, beta_w, first_explore_w, best_value_w }) 
					  );
					  
moves_map   map2(.clk(clk), .RST(RST), .R_(red_q), .B_(blue_q), .M_(M_w), .player(pl_q) );

heuristics  heur(.clk(clk), .RST(RST), .R(red_q), .B(blue_q), .M(M_w), .value(heur_w) );

RB_cnt score_cnt(.clk(clk), 
					  .RST(RST), 
					  .R(red_q), 
					  .B(blue_q), 
					  .cntR(cnt_score_R), 
					  .cntB(cnt_score_B) 
					  );

always @( * ) 
	begin

//	red_n_d = red;
//	blue_n_d = blue;
   thinking_d = thinking_q;
	pl_d = pl_q;
	done_d = done_q;	
	best_X_d = best_X_q;
	best_Y_d = best_Y_q;
   max_p_d = max_p_q;	
	M_d = M_q;
	DATA_d = DATA_q;
	best_value_d = best_value_q;
	alfa_d = alfa_q;
	beta_d = beta_q;
	first_explore_d = first_explore_q;
	X_d = X_q;
	Y_d = Y_q;

	last_X_d = last_X_q;
	last_Y_d = last_Y_q;

	sp_d = sp_q;
	red_d = red_q;
	blue_d = blue_q;
	pass_d = pass_q;
	fake_state_d = fake_state_q;
	node_count_d = node_count_q;
	
//	ok_move_d = ok_move_q;
	
	case ( state_q )
		RESET: begin
					if ( go_q ) begin
						state_d = EXPLORE;
						thinking_d = 1'b1;
						fake_state_d = EXPLORE;
						sp_d = 0;
						best_X_d = 0;
						best_Y_d = 0;
						last_X_d = 0;
						last_Y_d = 0;
						X_d      = 0;
						Y_d      = 0;
						pl_d     = 1;
						
						alfa_d = 20'b10000000000000000001;
						beta_d = 20'b01111111111111111111;
						node_count_d = 0;
					
						
						// trebuie aduse toate la zero
//						red_d = red_in;
//						blue_d = blue_in;
					end
					else begin
						state_d = RESET;
						fake_state_d = RESET;
					end
					done_d = 1'b0;
					pass_d = 1'b0;					
				 end
		EXPLORE_M: begin
		
						// aici trebuie sa avem pe M_q completat cu harta corespunzatoare tablei curente
						// gen by game_ai.py
						//X_d = 0;
						//Y_d = 0;
						state_d = EXPLORE_M2;
						fake_state_d = EXPLORE_M2;
						
						/* implemented killer moves */
						if ( M_q[0] ) begin
							X_d = 0;
							Y_d = 0;
						end
						else
						if ( M_q[7] ) begin
							X_d = 7;
							Y_d = 0;
						end
						else
						if ( M_q[63] ) begin
							X_d = 7;
							Y_d = 7;
						end
						else
						if ( M_q[57] ) begin
							X_d = 1;
							Y_d = 7;
						end
						else
						if ( M_q[1] ) begin
							X_d = 1;
							Y_d = 0;
						end
						else
						if ( M_q[2] ) begin
							X_d = 2;
							Y_d = 0;
						end
						else
						if ( M_q[3] ) begin
							X_d = 3;
							Y_d = 0;
						end
						else
						if ( M_q[4] ) begin
							X_d = 4;
							Y_d = 0;
						end
						else
						if ( M_q[5] ) begin
							X_d = 5;
							Y_d = 0;
						end
						else
						if ( M_q[6] ) begin
							X_d = 6;
							Y_d = 0;
						end
						else
						if ( M_q[8] ) begin
							X_d = 0;
							Y_d = 1;
						end
						else
						if ( M_q[9] ) begin
							X_d = 1;
							Y_d = 1;
						end
						else
						if ( M_q[10] ) begin
							X_d = 2;
							Y_d = 1;
						end
						else
						if ( M_q[11] ) begin
							X_d = 3;
							Y_d = 1;
						end
						else
						if ( M_q[12] ) begin
							X_d = 4;
							Y_d = 1;
						end
						else
						if ( M_q[13] ) begin
							X_d = 5;
							Y_d = 1;
						end
						else
						if ( M_q[14] ) begin
							X_d = 6;
							Y_d = 1;
						end
						else
						if ( M_q[15] ) begin
							X_d = 7;
							Y_d = 1;
						end
						else
						if ( M_q[16] ) begin
							X_d = 0;
							Y_d = 2;
						end
						else
						if ( M_q[17] ) begin
							X_d = 1;
							Y_d = 2;
						end
						else
						if ( M_q[18] ) begin
							X_d = 2;
							Y_d = 2;
						end
						else
						if ( M_q[19] ) begin
							X_d = 3;
							Y_d = 2;
						end
						else
						if ( M_q[20] ) begin
							X_d = 4;
							Y_d = 2;
						end
						else
						if ( M_q[21] ) begin
							X_d = 5;
							Y_d = 2;
						end
						else
						if ( M_q[22] ) begin
							X_d = 6;
							Y_d = 2;
						end
						else
						if ( M_q[23] ) begin
							X_d = 7;
							Y_d = 2;
						end
						else
						if ( M_q[24] ) begin
							X_d = 0;
							Y_d = 3;
						end
						else
						if ( M_q[25] ) begin
							X_d = 1;
							Y_d = 3;
						end
						else
						if ( M_q[26] ) begin
							X_d = 2;
							Y_d = 3;
						end
						else
						if ( M_q[27] ) begin
							X_d = 3;
							Y_d = 3;
						end
						else
						if ( M_q[28] ) begin
							X_d = 4;
							Y_d = 3;
						end
						else
						if ( M_q[29] ) begin
							X_d = 5;
							Y_d = 3;
						end
						else
						if ( M_q[30] ) begin
							X_d = 6;
							Y_d = 3;
						end
						else
						if ( M_q[31] ) begin
							X_d = 7;
							Y_d = 3;
						end
						else
						if ( M_q[32] ) begin
							X_d = 0;
							Y_d = 4;
						end
						else
						if ( M_q[33] ) begin
							X_d = 1;
							Y_d = 4;
						end
						else
						if ( M_q[34] ) begin
							X_d = 2;
							Y_d = 4;
						end
						else
						if ( M_q[35] ) begin
							X_d = 3;
							Y_d = 4;
						end
						else
						if ( M_q[36] ) begin
							X_d = 4;
							Y_d = 4;
						end
						else
						if ( M_q[37] ) begin
							X_d = 5;
							Y_d = 4;
						end
						else
						if ( M_q[38] ) begin
							X_d = 6;
							Y_d = 4;
						end
						else
						if ( M_q[39] ) begin
							X_d = 7;
							Y_d = 4;
						end
						else
						if ( M_q[40] ) begin
							X_d = 0;
							Y_d = 5;
						end
						else
						if ( M_q[41] ) begin
							X_d = 1;
							Y_d = 5;
						end
						else
						if ( M_q[42] ) begin
							X_d = 2;
							Y_d = 5;
						end
						else
						if ( M_q[43] ) begin
							X_d = 3;
							Y_d = 5;
						end
						else
						if ( M_q[44] ) begin
							X_d = 4;
							Y_d = 5;
						end
						else
						if ( M_q[45] ) begin
							X_d = 5;
							Y_d = 5;
						end
						else
						if ( M_q[46] ) begin
							X_d = 6;
							Y_d = 5;
						end
						else
						if ( M_q[47] ) begin
							X_d = 7;
							Y_d = 5;
						end
						else
						if ( M_q[48] ) begin
							X_d = 0;
							Y_d = 6;
						end
						else
						if ( M_q[49] ) begin
							X_d = 1;
							Y_d = 6;
						end
						else
						if ( M_q[50] ) begin
							X_d = 2;
							Y_d = 6;
						end
						else
						if ( M_q[51] ) begin
							X_d = 3;
							Y_d = 6;
						end
						else
						if ( M_q[52] ) begin
							X_d = 4;
							Y_d = 6;
						end
						else
						if ( M_q[53] ) begin
							X_d = 5;
							Y_d = 6;
						end
						else
						if ( M_q[54] ) begin
							X_d = 6;
							Y_d = 6;
						end
						else
						if ( M_q[55] ) begin
							X_d = 7;
							Y_d = 6;
						end
						else
						if ( M_q[56] ) begin
							X_d = 0;
							Y_d = 7;
						end
						else
						if ( M_q[58] ) begin
							X_d = 2;
							Y_d = 7;
						end
						else
						if ( M_q[59] ) begin
							X_d = 3;
							Y_d = 7;
						end
						else
						if ( M_q[60] ) begin
							X_d = 4;
							Y_d = 7;
						end
						else
						if ( M_q[61] ) begin
							X_d = 5;
							Y_d = 7;
						end
						else
						if ( M_q[62] ) begin
							X_d = 6;
							Y_d = 7;
						end
						else begin
							if (sp_q == 0) begin
							    sp_d = sp_q;
								 state_d = FINISH;
								 fake_state_d  = FINISH;
								 done_d = 1'b1;								 
						   end
							else begin
								if ( first_explore_q ) begin
									// PASS
									
									/*
									if (pl_q) begin  // me
										max_p_d = 20'b0; //-INF
									end
									else begin       // oponent
										max_p_d = 20'b1111111111111111;  // big value
									end
									*/
									state_d = EXPLORE_PASS_M2;
									fake_state_d = EXPLORE_PASS_M2;
								end
								else begin
									sp_d = sp_q - 1;
									pl_d = ~pl_q;
									state_d = EXPLORE_FETCH;
									fake_state_d = EXPLORE_FETCH;
								end
							end
							//max_p_d = DATA_q[10:0];  // pass max to the upper level
							// no more moves
						end
						
						first_explore_d = 1'b0;
						
						if ( sp_q == 0 ) begin
							last_X_d = X_d;
							last_Y_d = Y_d;
						end
						

						// adauga conditie ca best_move sa nu fie NULL
						
						// min-max
						if ( pl_q ) begin //me
							if (max_p_q > best_value_q ) begin
								best_value_d = max_p_q;
								max_p_d = max_p_q;
								if ( sp_q == 0 ) begin
									best_X_d = last_X_q;
									best_Y_d = last_Y_q;
								end
							end
							else begin
								best_value_d = best_value_q;
								// we return best_value on upper level
								max_p_d = best_value_q;
							end
							
							if ( best_value_q > alfa_q ) begin
								alfa_d = best_value_q;
							end
							
							if ( best_value_q >= beta_q )  begin
									sp_d = sp_q - 1;
									pl_d = ~pl_q;
									state_d = EXPLORE_FETCH;
									fake_state_d = EXPLORE_FETCH;	
									max_p_d = best_value_q;
									// return
							end
						end
						else begin	// oponent
							if ( max_p_q < best_value_q ) begin
								best_value_d = max_p_q;
								max_p_d = max_p_q;
							end
							else begin
								best_value_d = best_value_q;
								// we return best_value on upper level
								max_p_d = best_value_q;
							end
							

							if ( best_value_q < beta_q ) begin
								beta_d = best_value_q;
							end
							
							if ( best_value_q <= alfa_q )  begin
									sp_d = sp_q - 1;
									pl_d = ~pl_q;
									state_d = EXPLORE_FETCH;
									fake_state_d = EXPLORE_FETCH;	
									max_p_d = best_value_q;
									// return
							end
							
						end

						//M_d = M;
						M_d[Y_d*8 + X_d] = 1'b0;

						//state_d = EXPLORE_M2;						
					  end
		EXPLORE_M2: begin
						// write to BRAM {R,B,M,DATA}
//						memory_bram bram(.clk(clk), .we(we), .addr(sp_q), .DIN( {red_q, blue_q, M_q, DATA_q} ), .DOUT( {red_d, blue_d, M_d, DATA_d }) );

						state_d = EXPLORE_STORED;
						fake_state_d = EXPLORE_STORED;
						end
						

		EXPLORE_PASS_M2: begin
								  state_d = EXPLORE_PASS_STORED;
								  fake_state_d = EXPLORE_PASS_STORED;
								  pl_d = ~pl_q;								  
							  end
							  
		EXPLORE_PASS_STORED: begin
										// data written to BRAM
//										state_d = EXPLORE_STORED_0;
//										fake_state_d = EXPLORE_STORED_0;
										state_d = GAME_OVER_TEST1;
										fake_state_d = GAME_OVER_TEST1;

									end
									
		GAME_OVER_TEST1: begin
									if ( M_w[63:0] == 64'b0 )  begin
										// we have game over!

										// maximize the score
										
										//DEBUG
										node_count_d = node_count_q + 1;
										// ! player dependent
										if ( cnt_score_R >= cnt_score_B ) 
										begin
											max_p_d = 15000 + (cnt_score_R - cnt_score_B);
										end
										else begin
										// we loose
										// 21.06.2009 -> vs Zebra, pierde cu scor cat mai mare
											max_p_d = -15000 + (cnt_score_R - cnt_score_B);
										end
	
// nu trebuie, pentru ca e fix playerul la care o sa revenim	
//										pl_d = ~pl_q;
										sp_d = sp_q - 1;
										state_d = EXPLORE_FETCH;
										fake_state_d = EXPLORE_FETCH;
										
									end
									else begin
										// nu e game over
										state_d = EXPLORE_STORED_0;
										fake_state_d = EXPLORE_STORED_0;
									end
									
								end

		EXPLORE_STORED: begin
								// data written to BRAM
								// red_in blue_in, NEW values
								// b_move, completed, results in red_in blue_in
								red_d = red_in;
								blue_d = blue_in;	
								
								pl_d = ~pl_q;
								
//								M_d = M_w2;
						//		ok_move_d = 1'b0;
								state_d = EXPLORE_STORED_0;
								fake_state_d = EXPLORE_STORED_0;
							 end
		EXPLORE_STORED_0: begin
									// read_q, blue_q, pl_q cu noile valori
									if ( sp_q < MAX_DEPTH - 1) begin
										sp_d = sp_q + 1;
//										pl_d = ~pl_q;
										state_d = EXPLORE;
										fake_state_d = EXPLORE;
										
										//explore signal
									end
									else begin
										state_d = LEAF;
										fake_state_d = LEAF;
										
// si aici se schimba playerul, de aia am schimbat in starae anterioara										
									end

								end
		EXPLORE_FETCH:   begin
								// waits for heuristics to complete or sp_q (when going up the tree)
								  state_d = EXPLORE_FETCH_0;
								  fake_state_d = EXPLORE_FETCH_0;
							  end
		EXPLORE_FETCH_0: begin
								// read data from BRAM
								/*
								if (sp_q == 0) begin
									state_d = FINISH;
									done_d = 1'b1;
								end
								else begin
									state_d = EXPLORE_M;
								end
								*/
								state_d = EXPLORE_M;
								fake_state_d  = EXPLORE_M;
								// la iesirile ram-ului , exista deja valoarea
								M_d = M_w2;
								best_value_d = best_value_w;
								DATA_d = DATA_w;
								first_explore_d = first_explore_w;
								red_d = red_w;
								blue_d = blue_w;	
								
								alfa_d = alfa_w;
								beta_d = beta_w;
//								memory_bram bram(.clk(clk), .we(we), .addr(sp_q), .DIN( {red_q, blue_q, M_q, DATA_q} ), .DOUT( {red_d, blue_d, M_d, DATA_d }) );
							end
							
		EXPLORE: begin
//						moves_map map2(.clk(clk), .R(red_in), .B(blue_in), .M(M_d), .RST(~ok_map), .player(pl_q) );
						state_d = EXPLORE_0;
						fake_state_d = EXPLORE_0;
					end
		EXPLORE_0: begin
						//waits for move_map to complete
						M_d = M_w;
						state_d = EXPLORE_M;
						fake_state_d = EXPLORE_M;
						first_explore_d = 1;

						if ( have_to_pass ) begin
							state_d = FINISH;
							pass_d = 1'b1;
						end
						else
						if ( pl_q ) begin
							// play as max						

                     // -INF
							best_value_d       = 20'b10000000000000000001;
							max_p_d              = 20'b10000000000000000001; 
						end
						else begin
							// play as min
                     // +INF
							best_value_d       = 20'b01111111111111111111;
							max_p_d              = 20'b01111111111111111111;
						end
					  end
		LEAF: begin
		         // intrarile pentru heur sunt pregatite. asteptam rezultat.
					state_d = LEAF_0;
				   fake_state_d = LEAF_0;
				end
		LEAF_0: begin
				  // heuristics
				  node_count_d = node_count_q + 1;
				  state_d = EXPLORE_FETCH;
				  fake_state_d = EXPLORE_FETCH;
				  max_p_d = heur_w;
		        pl_d = ~pl_q;				  
//				  sp_d = sp_q - 1;
				end
		FINISH: begin
					state_d = RESET;
					done_d = 1'b1;
					thinking_d = 1'b0;
				  end
		default: begin
						sp_d = sp_q;
						X_d = X_q;
						Y_d = Y_q;
						state_d = state_q;
					end
	endcase
end

//output logic
/*
always @() begin
end
*/
// clocked process
always @(posedge clk) begin
	if ( RST ) begin
		state_q <= RESET;
		done_q  <= 0;
		sp_q    <= 0;
		M_q     <= 0;
		X_q     <= 0;
		Y_q     <= 0;

		last_X_q     <= 0;
		last_Y_q     <= 0;

		best_X_q     <= 0;
		best_Y_q     <= 0;
		
		DATA_q       <= 0;
		best_value_q <= 0;
		alfa_q <= 0;
		beta_q <= 0;
		first_explore_q  <= 1;
//		ok_move_q <= 0;
		red_q <= init_red;
		blue_q <= init_blue;

		pl_q <= 1;
		max_p_q <= 0;
		
		fake_state_q <= RESET;
		thinking_q <= 0;
		
		pass_q <= 0;
		go_q <= 0;
		node_count_q <= 32'b0;
	end
	else begin
	   node_count_q <= node_count_d;
	   go_q <= go;
		state_q <= state_d;
		fake_state_q <= fake_state_d;
		X_q <= X_d;
		Y_q <= Y_d;

		last_X_q <= last_X_d;
		last_Y_q <= last_Y_d;

		best_X_q <= best_X_d;
		best_Y_q <= best_Y_d;
		M_q <= M_d;
		sp_q <= sp_d;
		done_q <= done_d;
		thinking_q <= thinking_d;
//		ok_move_q <= ok_move_d;
		if ( go ) begin
			red_q <= init_red;
			blue_q <= init_blue;
		end
		else begin
			red_q <= red_d;
			blue_q <= blue_d;
		end
		DATA_q <= DATA_d;
		best_value_q <= best_value_d;
		alfa_q <= alfa_d;
		beta_q <= beta_d;
		first_explore_q <= first_explore_d;
		
		max_p_q <= max_p_d;
//		min_q <= min_d;
//		max_q <= max_d;
		pl_q <= pl_d;
		pass_q <= pass_d;
	end
end



endmodule
