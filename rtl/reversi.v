`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:08:07 05/13/2009 
// Design Name:    glue logic for reversi game.
// Module Name:    reversi 
// Project Name:   The FPGA Othello Game
// Target Devices: Spartan3E
// Tool versions: 
// Description: 
//
// Dependencies: all
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//     Marius TIVADAR
//
//////////////////////////////////////////////////////////////////////////////////
module reversi(
    input  clk,				// global clock
    input  RST,				// global RESET
	 output vga_h_sync, 		// H sync out
	 output vga_v_sync, 		// V sync out
	 output vga_R, 			// vga R
	 output vga_G, 			// vga G
	 output vga_B, 			// vga B
	 input  west,				// pushbutton west
	 input  north,				// pushbutton north
	 input  east,				// pushbutton east
	 input  south,				// pushbutton south
	 input  knob,				// pushbutton knob
	 output pass_led,			// player has to pass LED
	 output gameover_led, 	// gameover LED
	 output thinking_led, 	// thinking LED
	 output TxD					// RS232 Tx
    );

 
 

   wire [9:0] cntX;
  wire [8:0] cntY;
  wire inWin;
  wire ok;
  
  reg [31:0] time_cnt_d;
  reg [31:0] time_cnt_q;
  
  reg [31:0] think_time_q;
  reg [31:0] think_time_d;

  reg [0:0] nodes_sent_d;
  reg [0:0] nodes_sent_q;

  wire [63:0] M;
  wire [0:0] enter_btn;
  
  
  

 wire [2:0] X;
 wire [2:0] Y;

 
 reg [63:0] board_R_d;
 reg [63:0] board_R_q;

 reg [63:0] board_B_d;
 reg [63:0] board_B_q;
 
 reg go_d;
 reg go_q;

 reg pl_d;
 reg pl_q;

 reg [3:0] state_d;
 reg [3:0] state_q;
 
 reg [2:0] move_x_d;
 reg [2:0] move_x_q;
 
 reg [2:0] move_y_d;
 reg [2:0] move_y_q;
 
 wire [2:0] bmove_in_x;
 wire [2:0] bmove_in_y;
 
 wire [63:0] bmove_out_Rw; 
 wire [63:0] bmove_out_Bw;
 
 wire [63:0] bmove_in_Rw; 
 wire [63:0] bmove_in_Bw;
 
 
 wire [63:0] gai_out_Rw;
 wire [63:0] gai_out_Bw;
 
 wire [2:0] gai_out_x;
 wire [2:0] gai_out_y;
 
 wire [2:0] gai_out_best_x;
 wire [2:0] gai_out_best_y;
 
 // DEBUG
 wire [31:0] dbg_node_cnt_w;
 
 wire gai_out_pl;
 
 wire done;
 wire pass;
 wire thinking;
 wire gameover;
 wire ai_pass;
 wire TxD_busy;
 
 wire [19:0] dbg_w;



 parameter HUMAN            = 4'b0000;
 parameter HUMAN_MOVE		 = 4'b0001;	
 parameter HUMAN_MOVE_WAIT  = 4'b0010;
 parameter START_AI         = 4'b0011;
 parameter AI               = 4'b0101;
 parameter MOVE_BEST_WAIT   = 4'b0110;
 parameter MOVE_BEST        = 4'b0111;
 parameter RS232_0			 = 4'b1000;
 parameter RS232_1			 = 4'b1001; 
 parameter RS232_00         = 4'b1010;
 
 
 assign pass = (M[63:0] == 64'h0);
 assign pass_led = pass;
 assign gameover = ( ai_pass && pass );//~(board_R_q | board_B_q) == 64'b0);
 assign gameover_led = gameover;
 assign thinking_led = thinking;
 
 assign bmove_in_Rw     = ((state_q == AI) || (state_q == START_AI)) ? gai_out_Rw : board_R_q;
 assign bmove_in_Bw     = ((state_q == AI) || (state_q == START_AI)) ? gai_out_Bw : board_B_q;
 assign bmove_in_player = ((state_q == AI) || (state_q == START_AI)) ? gai_out_pl : pl_q;
 
 assign bmove_in_x = ((state_q == AI) || (state_q == START_AI)) ? gai_out_x : move_x_q;
 assign bmove_in_y = ((state_q == AI) || (state_q == START_AI)) ? gai_out_y : move_y_q; 
 
 moves_map mm(.clk(clk), 
				  .RST(RST), 
				  .R_(board_R_q), 
				  .B_(board_B_q), 
				  .M_(M), 
				  .player(pl_q) 
				  );
 
 b_move bm   (.clk(clk), 
				  .RST(RST), 
				  .B_(bmove_in_Bw), 
				  .R_(bmove_in_Rw), 
				  .X(bmove_in_x), 
				  .Y(bmove_in_y), 
				  .R_OUT(bmove_out_Rw), 
				  .B_OUT(bmove_out_Bw), 
				  .player(bmove_in_player) 
				  );
 
 game_ai gai (.clk(clk), 
				  .RST(RST), 
				  .go(go_q), 
				  .init_red(board_R_q),
				  .init_blue(board_B_q),
				  .red_in(bmove_out_Rw), 
				  .blue_in(bmove_out_Bw), 
				  .n_blue(gai_out_Bw), 
				  .n_red(gai_out_Rw), 
				  .o_pl(gai_out_pl), 
				  .m_x(gai_out_x), 
				  .m_y(gai_out_y), 
				  .bestX(gai_out_best_x), 
				  .bestY(gai_out_best_y), 
			     .thinking(thinking),
				  .ai_pass(ai_pass),
				  .done(done),
				  .dbg_heur(dbg_w),
				  .dbg_node_cnt(dbg_node_cnt_w)
				  );

 xy_calculate xy(.clk(clk), 
					  .RST(RST), 
					  .enter(enter_btn), 
					  .X(X), 
					  .Y(Y), 
					  .east(east), 
					  .west(west), 
					  .north(north), 
					  .south(south), 
					  .knob(knob) 
					  ); 
  
 time_analysis ta(
						.clk(clk),
						.RST(RST),
						.start(state_q == RS232_0),
						.time_cnt(time_cnt_q),
						.busy(TxD_busy),
						.TxD(TxD)
					 );
					 
					 
 vga_controller vga_ctrl(.clk(clk),
								 .vga_h_sync(vga_h_sync),
								 .vga_v_sync(vga_v_sync), 
								 .vga_R(vga_R),
								 .vga_G(vga_G),
								 .vga_B(vga_B),
								 .boardR(board_R_q),
								 .boardB(board_B_q),
								 .boardM(M),
								 .coordX(X),
								 .coordY(Y)
								);

 always @( * ) 
 begin
   move_x_d = move_x_q;
	move_y_d = move_y_q;
	state_d  = state_q;
	board_R_d = board_R_q;
	board_B_d = board_B_q;
	pl_d      = pl_q;
	go_d      = go_q;
	nodes_sent_d = nodes_sent_q;
	
	time_cnt_d = time_cnt_q;
	think_time_d = think_time_q;
	
	case ( state_q )
	   RS232_00 : begin
		                // sa se stabilizeze intrarile
							state_d = RS232_0;
					  end
		RS232_0 : begin
		
					// transmit
					state_d = RS232_1;
					end
					
		RS232_1 : begin
						if ( TxD_busy ) begin
							state_d = RS232_1;
						end
						else begin
						   if ( nodes_sent_q == 1'b1) 
							begin
								nodes_sent_d = 1'b0;
								state_d = HUMAN;
							end
							else begin
								nodes_sent_d = 1'b1;
								state_d = RS232_00;
								time_cnt_d = think_time_q;
							end
							//state_d = HUMAN;
						end
		
					 end
		HUMAN: begin
					if ( enter_btn ) begin
						if ( gameover ) begin
							state_d = HUMAN;
						end
						else
						if ( pass ) begin
							state_d = HUMAN_MOVE;
						end
						else
						if ( M[Y*8 + X] ) begin
							move_x_d = X;
							move_y_d = Y;
							state_d = HUMAN_MOVE;
						end
						else begin
							state_d = HUMAN;
						end
					end
			    end
		HUMAN_MOVE: begin
							// inputs for bmove prepared
							state_d = HUMAN_MOVE_WAIT;
					   end
						
		HUMAN_MOVE_WAIT: begin
								// bmove completed
								state_d = START_AI;
								if ( ~pass ) begin
									board_R_d = bmove_out_Rw;
									board_B_d = bmove_out_Bw;
								end
								pl_d = ~pl_q;
								go_d = 1'b1;								
							  end
				
		START_AI: begin
		            // board_R_q, board_B_q  au noile valori
						// move_q_x,y  au valorile ok
						// pl_q = oponent
						// go_q = 1
						// bmove e conectat la game_ai
						state_d = AI;
						time_cnt_d = 32'b0;
						think_time_d = 32'b0;
					 end
		AI: begin
			   if ( ai_pass) begin
					state_d = RS232_0;
					pl_d    = ~pl_q;
				end
				else
				if ( done ) begin
					move_x_d = gai_out_best_x;
					move_y_d = gai_out_best_y;
					state_d  = MOVE_BEST_WAIT;
					//time_cnt_d = dbg_w;
					// aquire nodes
					time_cnt_d = dbg_node_cnt_w;
				end 
				else begin
					state_d = AI;
					//time_cnt_d = time_cnt_q + 1;
					// thinking time
					think_time_d = think_time_q + 1;
					
				end
			
				go_d = 1'b0;							
			 end
			 
		MOVE_BEST_WAIT: begin
							   // prepare inputs for bmove
								// move_x_q move_y_q prepared
								state_d   = MOVE_BEST;
							 end
		MOVE_BEST:	begin
							// am mutat
							board_R_d = bmove_out_Rw;
							board_B_d = bmove_out_Bw;
							
							state_d = RS232_0;
							pl_d    = ~pl_q;
						end
		default: begin
						state_d = HUMAN;
					end
	endcase
 end

 always @(posedge clk) 
 begin
	if ( RST ) begin
		state_q   <= HUMAN;
		pl_q      <= 1'b0;
		move_x_q  <= 3'b0;
		move_y_q  <= 3'b0;
		go_q      <= 1'b0;
		time_cnt_q <= 32'b0;
		think_time_q <= 32'b0;
		nodes_sent_q <= 1'b0;
		
		board_R_q <= 64'b00000000_00000000_00000000_00010000_00001000_00000000_00000000_00000000;
		board_B_q <= 64'b00000000_00000000_00000000_00001000_00010000_00000000_00000000_00000000;
//		board_R_q <= 64'b00000111_00000011_00000001_00000011_00001001_00100001_00110011_01111111;
//		board_B_q <= 64'b00001000_00001100_00011110_01111100_01110110_00011110_00001100_00000000;	

	end
	else begin
		//time_cnt_q <= 32'b0010_0000_1010_1110_1000_1111_1010_0001;//time_cnt_d;
		time_cnt_q <= time_cnt_d;
		nodes_sent_q <= nodes_sent_d;
		think_time_q <= think_time_d;
		state_q   <= state_d;
		pl_q      <= pl_d;
		move_x_q  <= move_x_d;
		move_y_q  <= move_y_d;
		board_R_q <= board_R_d;
		board_B_q <= board_B_d;
		go_q      <= go_d;
	end
 end


endmodule
