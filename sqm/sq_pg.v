/*
	SQmusic

  (c) Jose Tejada Gomez, 9th May 2013
  You can use this file following the GNU GENERAL PUBLIC LICENSE version 3
  Read the details of the license in:
  http://www.gnu.org/licenses/gpl.txt
  
  Send comments to: jose.tejada@ieee.org

*/

`timescale 1ns/1ps

module sq_slot(
	input  clk,
	input  reset_n,
	input  [10:0] fnumber,
	input  [2:0]  block,
  input  [3:0]  multiple,
  input  [6:0]  totallvl, // total level
  output [13:0] linear
);

reg [7:0]state;

parameter st_pg_count  = 8'h01;
parameter st_pow_read  = 8'h04;
	
wire [9:0]phase;
wire [13:0] sin_log, sin_linear;
reg  pg_ce_n, pow_rd_n;

always @(posedge clk or negedge reset_n ) begin
  if (!reset_n) begin
    state   <= 8'b0;
    pg_ce_n <= 1'b1;
    pow_rd_n<= 1'b1;
  end
  else begin
    if( state == 8'd143 )
      state <= 8'd0;
    else
      state <= state+1;
    pg_ce_n <=  state == st_pg_count ? 1'b0 : 1'b1;
    pow_rd_n<=  state == st_pow_read ? 1'b0 : 1'b1;
  end
end

sq_pg pg( 
  .clk     (clk), 
  .reset_n (reset_n), 
  .fnumber (fnumber), 
  .block   (block),
  .multiple(multiple),
  .ce_n    (pg_ce_n),
  .phase   (phase) );

sq_sin sin(
  .clk     (clk), 
  .reset_n (reset_n), 
  .phase   (phase),
  .gain    (totallvl),
  .val     (sin_log) );
  
sq_pow pow(
  .clk     (clk), 
  .reset_n (reset_n), 
  .rd_n    (pow_rd_n),
  .x       (sin_log),
  .y       (linear) );

endmodule

///////////////////////////////////////////////////////////////////
module sq_pg(
	input clk,
	input reset_n,
	input [10:0] fnumber,
	input [2:0] block,
  input [3:0] multiple,
  input ce_n, // count enable, active low
	output [9:0]phase );

reg [19:0] count;
assign phase = count[19:10];

wire [19:0]fmult = fnumber << (block-1);

always @(posedge clk or negedge reset_n ) begin
	if( !reset_n )
		count <= 20'b0;
	else begin
	  if( !ce_n )
  	  count <= count + ( multiple==4'b0 ? fmult>> 1 : fmult*multiple);
  	else 
  	  count <= count;
	end
end

endmodule

///////////////////////////////////////////////////////////////////
module sq_sin(
  input clk,
  input reset_n,
  input [6:0]gain, // gain factor in log scale
  input [9:0]phase,
  output [13:0] val // LSB is the sign. 0=positive, 1=negative
);

reg [12:0] sin_table[1023:0];

initial begin
  $readmemh("../tables/sin_table.hex", sin_table);
end
reg [9:0]last_phase;
assign val = sin_table[last_phase] + { gain, 6'h0 };

always @(posedge clk or negedge reset_n ) begin
	if( !reset_n )
		last_phase <= 10'b0;
	else begin
	  last_phase <= phase;
	end
end
endmodule
///////////////////////////////////////////////////////////////////
// sq_pow => reverse the log2 conversion
module sq_pow(
  input clk,
  input reset_n,
  input rd_n, // read enable, active low
  input [13:0]x, // LSB is the sign. 0=positive, 1=negative
  output reg [13:0]y 
);

parameter st_input    = 3'b000;
parameter st_lut_read = 3'b001;
parameter st_shift    = 3'b010;
parameter st_sign     = 3'b011;
parameter st_output   = 3'b100;

reg [2:0] state;
reg [12:0] pow_table[255:0];

initial begin
  $readmemh("../tables/pow_table.hex", pow_table);
end
reg [7:0]index;
reg [4:0]exp;
reg sign;

reg [13:0] raw, shifted, final;

always @(posedge clk or negedge reset_n ) begin
	if( !reset_n ) begin
		index   <=  8'b0;
		exp     <=  3'b0;
		sign    <=  1'b0;
		raw     <= 14'b0;
		shifted <= 14'b0;
		y       <= 14'b0;
		state <= st_input;
	end
	else begin
	  case ( state )
	    st_input: begin
	      if( !rd_n ) begin
	        exp   <= x[13:9];
	        index <= x[8:1];
	        sign  <= x[0];
	        state <= st_lut_read;
	      end
	      else state <= st_input;
	      end
	   st_lut_read: begin
	      raw   <= pow_table[index];
	      state <= st_shift;
	      end
	   st_shift: begin
	      shifted <= raw >> exp;
	      state   <= st_sign;
	      end
	   st_sign: begin
	      final <= sign ? ~shifted + 1'b1 : shifted;
	      state <= st_output;
	      end
	   st_output: begin
	      y     <= final;
	      state <= st_input;
	      end
	   default: begin
	      state <= st_input;
	      end
	  endcase
	end
end

always @(posedge clk or negedge reset_n ) begin
	if( !reset_n ) 
	  raw <= 13'b0;
	else 
	  raw <= pow_table[index];
end

always @(posedge clk or negedge reset_n ) begin
	if( !reset_n ) 
	  shifted <= 13'b0;
	else 
	  shifted <= raw >> exp;
end

endmodule

///////////////////////////////////////////////////////////////////
// sq_opn_eg => Envelope generator
module sq_opn_eg(
	input clk,
	input reset_n,
	input ce_n, // count enable, active low
	input key_on,
	input key_off,
  input [1:0] ks, // key scale
  input [5:0] ar, // attack rate
  input [5:0] dr, // decay rate
  input [5:0] sr, // sustain rate 
  input [3:0] rr, // release rate   
  input [3:0] sl, // sustain level
  input [3:0] block,
  input [1:0] note,
  input [6:0] tl, // total level
  output reg [6:0] env, // envelope
  output onwait // EG is on wait state
);

reg [2:0] state;
/*
reg [6:0] f_ar, // final attack rate
  f_dr, // final decay rate
  f_sr, // final sustain rate
  f_rr; // final release rate
*/
parameter st_wait   = 3'd0; // wait for key_on
parameter st_attack = 3'd1;
parameter st_decay  = 3'd2;
parameter st_sustain= 3'd3;
parameter st_release= 3'd4;

assign onwait = state == st_wait;

reg [7:0] cr; // current rate used for calculations
reg [7:0] f_sl; // final sustain level: f_sl = tl+sl
wire [7:0] next_env =  { 1'b0, env } + cr;
wire attack_over = next_env <= tl || next_env>env;
wire decay_over  = next_env >= f_sl;
wire sustain_over= next_env >= 8'h7F;
//wire neg  = next_env[7];

always @(posedge clk or negedge reset_n ) begin
	if( !reset_n ) begin
	  state <= st_wait;
	  env   <= 7'h7F;
	end
	else begin
	  case( state )
	  st_wait:
      if( key_on ) begin
        state <= st_attack;
        cr    <= ~ { 2'b0, ar, ar[0] } + 1'b1; 
        env   <= 7'h7F; // is it ok to reset it?
        f_sl  <= { 2'b0, sl, 2'b0 } + {1'b0, tl }; // f_sl = sl + tl
      end
      else begin
        state <=st_wait;
        env   <= 7'h7F;
	    end
    st_attack:
      if( !ce_n )
        if( attack_over ) begin
          env   <= tl;
          cr    <= { 2'b0, dr, dr[0] };
          state <= st_decay;
          f_sl  <= f_sl[7] ? 8'h7F : f_sl; // clamp the result to 7F
        end
        else begin      
          env   <= next_env;
          state <= st_attack;
        end
    st_decay: 
      if( !ce_n )
        if( decay_over ) begin
          env   <= f_sl;
          cr    <= { 2'b0, sr, sr[0] };
          state <= st_sustain;
        end
        else begin
          env   <= next_env;
          state <= st_decay;
        end
    st_sustain:
      if( key_off ) begin
        env   <= next_env;
        cr    <= { 1'b0, rr, 3'b0 };
        state <= st_release;
      end
      else
      if( sustain_over ) begin
        if( !ce_n ) begin
          env   <= 7'h7F;
          state <= st_wait;
        end
      end
      else if( !ce_n ) begin
        env   <= next_env;
        state <= st_sustain;
      end
    st_release:
      if( sustain_over ) begin
        env   <= 7'h7F;
        state <= st_wait;
      end
      else if( !ce_n ) begin
        env   <= next_env;
        state <= st_release;
      end      
	    default: begin
	      state <=st_wait;
	      env   <= 7'h7F;
	    end
	  endcase
  end
end

endmodule
