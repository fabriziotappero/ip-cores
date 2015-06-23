`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:14:24 03/08/2009 
// Design Name: 
// Module Name:    board_move 
// Project Name:   The FPGA Othello Game
// Target Devices: spartan3E
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
module board_move(clk, B, R, X, Y, player, MB, MR, RST);
/* Input: Othello 64bit board R - red player, B - blue player*/
input [63:0] R;
input [63:0] B;

/* Input: clock signal */
input clk;

/* Input: reset signal: initializes FSM adn outputs */
input RST;

/* Input: X, Y coordinates in Othello board 8x8 */
input [2:0]  X;
input [2:0]  Y;

/* Input: current player color RED or BLUE */
input player;

/* Output: New 64bit Othello board for BLUE player (MB) and for RED player (MR)*/
output [63:0] MB;
output [63:0] MR;

/* internal: flip-flops */
/*
reg [7:0] oponent_ff_d[7:0];
reg [7:0] current_ff_d[7:0];

reg [7:0] oponent_ff_q[7:0];
reg [7:0] current_ff_q[7:0];
*/

reg [63:0] oponent_ff_d;
reg [63:0] current_ff_d;

reg [63:0] oponent_ff_q;
reg [63:0] current_ff_q;


reg [2:0] countx_ff_d;
reg [2:0] countx_ff_q;

reg [2:0] county_ff_d;
reg [2:0] county_ff_q;

reg [2:0] count2x_ff_d;
reg [2:0] count2x_ff_q;

reg [2:0] count2y_ff_d;
reg [2:0] count2y_ff_q;

/* internal: FSM state ff */
reg [1:0] state_ff_q;
reg [1:0] state_ff_d;

reg [1:0] state2_ff_q;
reg [1:0] state2_ff_d;

/* internal: FSM states */
parameter RESET  = 2'b00;
parameter FLIP   = 2'b01;
parameter WRONG  = 2'b10;
parameter FINISH = 2'b11;

/* constants */
parameter DISC_ON  = 1'b1;
parameter DISC_OFF = 1'b0;
parameter LIMIT    = 3'd7;
parameter NO_DISC  = 1'b0;
parameter RED		 = 1'b1;

/* FSM Output logic */
always @(state_ff_q or countx_ff_q or county_ff_q)
   begin
		/* oponent */
		oponent_ff_d = oponent_ff_q;
		
		/* current player */
		current_ff_d = current_ff_q;
		
		case (state_ff_q)			

			/* FLIP state: flip the pieces */
			FLIP: begin
						/* oponent will remain with no disc on that position */
						oponent_ff_d[county_ff_q*8 + countx_ff_q] = DISC_OFF;
						/* disc is ours */
						current_ff_d[county_ff_q*8 + countx_ff_q] = DISC_ON;
					end

			/* WRONG state: flip back the pieces */
			WRONG: begin
						/* give the disc back to oponent */
						oponent_ff_d[county_ff_q*8 + countx_ff_q] = DISC_ON;
						current_ff_d[county_ff_q*8 + countx_ff_q] = DISC_OFF;
					 end
						
			/* mantain the outputs */
			default: begin
							oponent_ff_d = oponent_ff_q;
							current_ff_d = current_ff_q;
						end
			 
		endcase
		
		case (state2_ff_q)			

			/* FLIP state: flip the pieces */
			FLIP: begin
						/* oponent will remain with no disc on that position */
						oponent_ff_d[count2y_ff_q*8 + count2x_ff_q] = DISC_OFF;
						/* disc is ours */
						current_ff_d[count2y_ff_q*8 + count2x_ff_q] = DISC_ON;
					end

			/* WRONG state: flip back the pieces */
			WRONG: begin
						/* give the disc back to oponent */
						oponent_ff_d[count2y_ff_q*8 + count2x_ff_q] = DISC_ON;
						current_ff_d[count2y_ff_q*8 + count2x_ff_q] = DISC_OFF;
					 end
						
			/* mantain the outputs */
			default: begin
							oponent_ff_d = oponent_ff_q;
							current_ff_d = current_ff_q;
						end
			 
		endcase
		
	end


/* FSM next state logic */
always @(state_ff_q or countx_ff_q or county_ff_q)
begin

case (state_ff_q)
	 /* RESET state, prepare to flip the discs */
	 RESET: begin
			     if ( (oponent_ff_q[county_ff_q*8 + countx_ff_q] | current_ff_q[county_ff_q*8 + countx_ff_q]) == NO_DISC )
				  /* if the square is empty */
				  begin
						if ( countx_ff_q == LIMIT )
						/* if this is the last square, nothing to flip on this direction */
						begin	
							state_ff_d = FINISH;
							countx_ff_d = countx_ff_q;
							county_ff_d = county_ff_q;
						end
						else begin
							if ( oponent_ff_q[county_ff_q*8 + countx_ff_q + 1] == DISC_ON )
							/* check if there is an oponent disc */
							begin
								/* yes, go to FLIP state, and increment X */
								state_ff_d = FLIP;	
								countx_ff_d = countx_ff_q + 1;
								county_ff_d = county_ff_q;								
							end
							else begin
								/* if no, means that we have nothing to flip => FINISH */
								state_ff_d = FINISH;
								countx_ff_d = countx_ff_q;
								county_ff_d = county_ff_q;
							end
						end
				  end
				  else begin
						/* error: should happen */
						state_ff_d = RESET;
						countx_ff_d = countx_ff_q;
						county_ff_d = county_ff_q;
				  end
			  end
	 /* FLIP state: in this state we flip the discs, and see if we still have to flip or we are finished */
    FLIP: begin
				 if (countx_ff_q == LIMIT) begin
							/* if we are here, it means that we have no disc to flanc with */
							state_ff_d = WRONG;
							countx_ff_d = countx_ff_q;
							county_ff_d = county_ff_q;
				 end
             else begin
	 				if ( oponent_ff_q[county_ff_q*8 + countx_ff_q + 1] == DISC_ON ) 
					/* if next to us is an oponent disc, mantain FLIP */
					begin
						state_ff_d = state_ff_q;						
						countx_ff_d = countx_ff_q + 1;
						county_ff_d = county_ff_q;						
					end
					else begin
						if ( current_ff_q[county_ff_q*8 + countx_ff_q + 1] == DISC_ON )
						/* if it's our color the disc next to us, we can flanc all the oponent discs, so we are finish */
						begin
							state_ff_d = FINISH;
							countx_ff_d = countx_ff_q;
							county_ff_d = county_ff_q;							
						end
						else begin
							/* if it's niether our disc or oponent's disc, means square is empty, so nothing to flip  */
							state_ff_d = WRONG;
							countx_ff_d = countx_ff_q;
							county_ff_d = county_ff_q;							
						end
					end
				 end	
			  end
	 /* WRONG state: we flip the discs back in this state */	 
	 WRONG:
			 begin
				if (countx_ff_q - 1  == X)
				/* check if we are finished */
				begin
					state_ff_d = FINISH;
					countx_ff_d = countx_ff_q;
					county_ff_d = county_ff_q;					
				end
				else begin
				/* we mantain the state, keep flipping back */
				   state_ff_d = WRONG;
					countx_ff_d = countx_ff_q - 1;
					county_ff_d = county_ff_q;					
				end
			 end
	 
    /* default state, mantain counters and state */
	 default:
	     begin
			state_ff_d = state_ff_q;
			countx_ff_d = countx_ff_q;
			county_ff_d = county_ff_q;
		  end
endcase
end

/* FSM next state logic */
always @(state2_ff_q or count2x_ff_q or count2y_ff_q)
begin

case (state2_ff_q)
	 /* RESET state, prepare to flip the discs */
	 RESET: begin
			     if ( (oponent_ff_q[count2y_ff_q*8 + count2x_ff_q] | current_ff_q[count2y_ff_q*8 + count2x_ff_q]) == NO_DISC )
				  /* if the square is empty */
				  begin
						if ( count2x_ff_q == LIMIT )
						/* if this is the last square, nothing to flip on this direction */
						begin	
							state2_ff_d = FINISH;
							count2x_ff_d = count2x_ff_q;
							count2y_ff_d = count2y_ff_q;
						end
						else begin
							if ( oponent_ff_q[count2y_ff_q*8 + count2x_ff_q - 1] == DISC_ON )
							/* check if there is an oponent disc */
							begin
								/* yes, go to FLIP state, and increment X */
								state2_ff_d = FLIP;	
								count2x_ff_d = count2x_ff_q - 1;
								count2y_ff_d = count2y_ff_q;								
							end
							else begin
								/* if no, means that we have nothing to flip => FINISH */
								state2_ff_d = FINISH;
								count2x_ff_d = count2x_ff_q;
								count2y_ff_d = count2y_ff_q;
							end
						end
				  end
				  else begin
						/* error: should happen */
						state2_ff_d = RESET;
						count2x_ff_d = count2x_ff_q;
						count2y_ff_d = count2y_ff_q;
				  end
			  end
	 /* FLIP state: in this state we flip the discs, and see if we still have to flip or we are finished */
    FLIP: begin
				 if (count2x_ff_q == 3'b0) begin
							/* if we are here, it means that we have no disc to flanc with */
							state2_ff_d = WRONG;
							count2x_ff_d = count2x_ff_q;
							count2y_ff_d = count2y_ff_q;
				 end
             else begin
	 				if ( oponent_ff_q[count2y_ff_q*8 + count2x_ff_q - 1] == DISC_ON ) 
					/* if next to us is an oponent disc, mantain FLIP */
					begin
						state2_ff_d = state2_ff_q;						
						count2x_ff_d = count2x_ff_q + 1;
						count2y_ff_d = count2y_ff_q;						
					end
					else begin
						if ( current_ff_q[count2y_ff_q*8 + count2x_ff_q - 1] == DISC_ON )
						/* if it's our color the disc next to us, we can flanc all the oponent discs, so we are finish */
						begin
							state2_ff_d = FINISH;
							count2x_ff_d = count2x_ff_q;
							count2y_ff_d = count2y_ff_q;							
						end
						else begin
							/* if it's niether our disc or oponent's disc, means square is empty, so nothing to flip  */
							state2_ff_d = WRONG;
							count2x_ff_d = count2x_ff_q;
							count2y_ff_d = count2y_ff_q;							
						end
					end
				 end	
			  end
	 /* WRONG state: we flip the discs back in this state */	 
	 WRONG:
			 begin
				if (count2x_ff_q + 1  == X)
				/* check if we are finished */
				begin
					state2_ff_d = FINISH;
					count2x_ff_d = count2x_ff_q;
					count2y_ff_d = count2y_ff_q;					
				end
				else begin
				/* we mantain the state, keep flipping back */
				   state2_ff_d = WRONG;
					count2x_ff_d = count2x_ff_q + 1;
					count2y_ff_d = count2y_ff_q;					
				end
			 end
	 
    /* default state, mantain counters and state */
	 default:
	     begin
			state2_ff_d = state2_ff_q;
			count2x_ff_d = count2x_ff_q;
			count2y_ff_d = count2y_ff_q;
		  end
endcase
end



/* clocked procedure */
always @(posedge clk)
begin
	if (RST)
	/* reset signal */
	begin
 		 state_ff_q <= RESET;
		 state2_ff_q <= RESET;
       /* we prepare the board */		
		 current_ff_q <= B;
		 oponent_ff_q <= R;

		 /* if second player is the current one, switch the matrices */
		 if ( player == RED ) begin
			 current_ff_q <= R;
			 oponent_ff_q <= B;
			

		 end

		/* prepare the counters (directions) */
		countx_ff_q <= X;
		county_ff_q <= Y;		
		
		count2x_ff_q <= X;
		count2y_ff_q <= Y;		
		
	end
	else begin
	   /* go to next state */
		state_ff_q  <= state_ff_d;
		
		/* go to next square */
		countx_ff_q <= countx_ff_d;
		county_ff_q <= county_ff_d;		

		state2_ff_q  <= state2_ff_d;
		
		/* go to next square */
		count2x_ff_q <= count2x_ff_d;
		count2y_ff_q <= count2y_ff_d;		
		
		
		/* validate outputs */
		oponent_ff_q <= oponent_ff_d;
		current_ff_q <= current_ff_d;
	
	end
end


/* continuous assignments, output Othello board 128bit */
assign MB = current_ff_q;
assign MR = oponent_ff_q;

endmodule
