module piece(/*AUTOARG*/
   // Outputs
   changed, done, curr_value, error,
   // Inputs
   clk, rst, start, clr, start_value, my_row, my_col, my_square
   );
   parameter DIM_S = 9;

   input clk;
   input rst;
   input start;
   input clr;
   
   output changed;
   output done;
   output error;
      
   input [(DIM_S-1):0] start_value;
   output [(DIM_S-1):0] curr_value;
      
   input [(DIM_S*(DIM_S-1)-1):0] my_row;
   input [(DIM_S*(DIM_S-1)-1):0] my_col;
   input [(DIM_S*(DIM_S-1)-1):0] my_square;
   
   wire [(DIM_S-1):0] 	row2d [(DIM_S-2):0];
   wire [(DIM_S-1):0] 	col2d [(DIM_S-2):0];
   wire [(DIM_S-1):0] 	sqr2d [(DIM_S-2):0];

   wire [(DIM_S-1):0] 	row2d_solv [(DIM_S-2):0];
   wire [(DIM_S-1):0] 	col2d_solv [(DIM_S-2):0];
   wire [(DIM_S-1):0] 	sqr2d_solv [(DIM_S-2):0];

   reg [(DIM_S-1):0] 	r_curr_value;
   reg [(DIM_S-1):0] 	t_next_value;
   assign curr_value = r_curr_value;

   reg [2:0] 	r_state, n_state;
   reg 		r_solved, t_solved;
   reg 		t_changed,r_changed;
   reg 		t_error,r_error;
   
   assign done = r_solved;
   assign changed = r_changed;
   assign error = r_error;
      
   wire [(DIM_S-1):0] 	w_solved;
   
   wire 	w_piece_solved = (w_solved != 'd0);
   one_set #(.DIM_S(DIM_S))  s0 (r_curr_value, w_solved);
      
   always@(posedge clk)
     begin
	if(rst)
	  begin
	     r_curr_value <= 'd0;
	     r_state <= 3'd0;
	     r_solved <= 1'b0;
	     r_changed <= 1'b0;
	     r_error <= 1'b0;
	  end
	else
	  begin
	     r_curr_value <= clr ? 'd0 : t_next_value;
	     r_state <= clr ? 3'd0 : n_state;
	     r_solved <= clr ? 1'b0 : t_solved;
	     r_changed <= clr ? 1'b0 : t_changed;
	     r_error <= clr ? 1'b0 : t_error;
	  end
     end // always@ (posedge clk)
   
   
   genvar 	i;
   generate
      for(i=0;i<(DIM_S-1);i=i+1)
	begin: unflatten
	   assign row2d[i] = my_row[(DIM_S*(i+1))-1:DIM_S*i];
	   assign col2d[i] = my_col[(DIM_S*(i+1))-1:DIM_S*i];
	   assign sqr2d[i] = my_square[(DIM_S*(i+1))-1:DIM_S*i];
	end
   endgenerate

   generate
      for(i=0;i<(DIM_S-1);i=i+1)
	begin: unique_rows
	   one_set #(.DIM_S(DIM_S)) rs (row2d[i], row2d_solv[i]);
	   one_set #(.DIM_S(DIM_S)) cs (col2d[i], col2d_solv[i]);
	   one_set #(.DIM_S(DIM_S)) ss (sqr2d[i], sqr2d_solv[i]);
	end
   endgenerate

   /* OR output of one_set to find cells
    * that are already set in col, grid, row */
   wire [(DIM_S-1):0] set_row, set_col, set_sqr;
   wire [(DIM_S-1):0] row_or, col_or, sqr_or;
   
   wire [(DIM_S-1):0] w_accum_row2d [(DIM_S-2):0];
   wire [(DIM_S-1):0] w_accum_col2d [(DIM_S-2):0];
   wire [(DIM_S-1):0] w_accum_sqr2d [(DIM_S-2):0];

   wire [(DIM_S-1):0] w_accum_row_or [(DIM_S-2):0];
   wire [(DIM_S-1):0] w_accum_col_or [(DIM_S-2):0];
   wire [(DIM_S-1):0] w_accum_sqr_or [(DIM_S-2):0];

   generate
      for(i=0;i<(DIM_S-1);i=i+1)
	begin: set_accums
	   if(i==0)
	     begin
		assign w_accum_row2d[i] = row2d_solv[i];
		assign w_accum_col2d[i] = col2d_solv[i];
		assign w_accum_sqr2d[i] = sqr2d_solv[i];

		assign w_accum_row_or[i] = row2d[i];
		assign w_accum_col_or[i] = col2d[i];
		assign w_accum_sqr_or[i] = sqr2d[i];
	     end
	   else
	     begin
		assign w_accum_row2d[i] = w_accum_row2d[i-1] | row2d_solv[i];
		assign w_accum_col2d[i] = w_accum_col2d[i-1] | col2d_solv[i];
		assign w_accum_sqr2d[i] = w_accum_sqr2d[i-1] | sqr2d_solv[i];

		assign w_accum_row_or[i] = w_accum_row_or[i-1] | row2d[i];
		assign w_accum_col_or[i] = w_accum_col_or[i-1] | col2d[i];
		assign w_accum_sqr_or[i] = w_accum_sqr_or[i-1] | sqr2d[i];
	     end
	end
   endgenerate
   
   assign set_row = w_accum_row2d[DIM_S-2];
   assign set_col = w_accum_col2d[DIM_S-2];
   assign set_sqr = w_accum_sqr2d[DIM_S-2];

   assign row_or = w_accum_row_or[DIM_S-2];
   assign col_or = w_accum_col_or[DIM_S-2];
   assign sqr_or = w_accum_sqr_or[DIM_S-2];
   

   integer ii;
   always@(posedge clk)
     begin
	if(rst==1'b0)
	  begin
	     for(ii=0;ii<(DIM_S-1);ii=ii+1)
	       begin
		  if(row2d_solv[ii] === 'dx)
		    begin
		       $display("row %d", ii);
		       $stop();
		    end
	       end
	  end
     end


   wire [(DIM_S-1):0] row_nor = ~row_or;
   wire [(DIM_S-1):0] col_nor = ~col_or;
   wire [(DIM_S-1):0] sqr_nor = ~sqr_or;

   wire [(DIM_S-1):0] row_singleton;
   wire [(DIM_S-1):0] col_singleton;
   wire [(DIM_S-1):0] sqr_singleton;
   
   one_set #(.DIM_S(DIM_S)) s1 (r_curr_value & row_nor, row_singleton);
   one_set #(.DIM_S(DIM_S)) s2 (r_curr_value & col_nor, col_singleton);
   one_set #(.DIM_S(DIM_S)) s3 (r_curr_value & sqr_nor, sqr_singleton);
   
   /* these are the values of the set rows, columns, and 
    * squares */
   
   wire [(DIM_S-1):0] not_poss = set_row | set_col | set_sqr;
   wire [(DIM_S-1):0] new_poss = r_curr_value & (~not_poss);
   
   wire 	      w_piece_zero = (r_curr_value == 'd0);
   
   always@(*)
     begin
	t_next_value = r_curr_value;
	n_state = r_state;
	t_solved = r_solved;
	t_changed = 1'b0;
	t_error = r_error;
	
	case(r_state)
	  3'd0:
	    begin
	       if(start)
		 begin
		    t_next_value = start_value;
		    n_state = 3'd1;
		    t_changed = 1'b1;
		    t_error = 1'b0;
		 end
	    end
	  3'd1:
	    begin
	       if(w_piece_solved | w_piece_zero)
		 begin
		    t_solved = 1'b1;
		    n_state = 3'd7;
		    t_changed = 1'b1;
		    t_error = w_piece_zero;
		 end
	       else
		 begin
		    t_changed = (new_poss != r_curr_value);
		    t_next_value = new_poss;
		    n_state = 3'd2;
		 end
	    end // case: 3'd1
	  3'd2:
	    begin
	       if(w_piece_solved | w_piece_zero)
		 begin
		    t_solved = 1'b1;
		    n_state = 3'd7;
		    t_error = w_piece_zero;
		 end
	       else
		 begin
		    if(row_singleton != 'd0)
		      begin
			 //$display("used row singleton");
			 t_next_value = row_singleton;
			 t_changed = 1'b1;
			 t_solved = 1'b1;
			 n_state = 3'd7;
		      end
		    else if(col_singleton != 'd0)
		      begin
			 //$display("used col singleton");
			 t_next_value = col_singleton;
			 t_changed = 1'b1;
		      	 t_solved = 1'b1;
			 n_state = 3'd7;
		      end
		    else if(sqr_singleton != 'd0)
		      begin
			 //$display("used sqr singleton");
			 t_next_value = sqr_singleton;
			 t_changed = 1'b1;
		      	 t_solved = 1'b1;
			 n_state = 3'd7;
		      end
		    else
		      begin
			 n_state = 3'd1;
		      end
		 end
	    end
	  3'd7:
	    begin
	       t_solved = 1'b1;
	       n_state = 3'd7;
	    end

	endcase // case (r_state)
     end
endmodule // piece

module one_set(in, out);
   parameter DIM_S = 9;
   input [(DIM_S-1):0] in;
   output [(DIM_S-1):0] out;

   wire [(DIM_S-1):0] 	w_ones = ~('d0);
   wire [(DIM_S-1):0] 	w_m = in + w_ones;
   wire 		w_pow2 = ((w_m & in) == 'd0) && (in != 'd0);
   
   assign out = {DIM_S{w_pow2}} & in;
endmodule // one_set

module ones_count(in, out);
   parameter LG_IN_WIDTH = 4;
   localparam IN_WIDTH= (1 << LG_IN_WIDTH);
   localparam OUT_WIDTH = LG_IN_WIDTH;
   
   input [(IN_WIDTH-1):0] in;
   output [(OUT_WIDTH-1):0] out;

   localparam NUM_COUNT4 = IN_WIDTH/4;
   wire [2:0] 		    w_cnt4 [(NUM_COUNT4-1):0];
   wire [(OUT_WIDTH-1):0]   w_sum  [(NUM_COUNT4-1):0];
   genvar 		    i;
   
   generate
      for(i=0;i<NUM_COUNT4;i=i+1)
	begin: count4z
	   one_count4 cc (in[(4*(i+1))-1:4*(i)], w_cnt4[i]);
	end
   endgenerate

   generate
      for(i=0;i<NUM_COUNT4;i=i+1)
	begin: sumz
	   if(i==0)
	     begin
		assign w_sum[i] = { {(OUT_WIDTH-3){1'b0}}, w_cnt4[i]};
	     end
	   else
	     begin
		assign w_sum[i] = w_sum[i-1] + { {(OUT_WIDTH-3){1'b0}}, w_cnt4[i]};
	     end
	end
   endgenerate

   assign out = w_sum[NUM_COUNT4-1];
      
endmodule // ones_count

/*
module ones_count81(input [80:0] in, output [6:0] out);
   wire [83:0] w_in = {3'd0, in};
   wire [2:0]  ps [20:0];

   integer     x;
   reg [6:0]   t_sum;
   genvar      i;
   generate
      for(i=0;i<21;i=i+1)
	begin : builders
	   one_count4 os (w_in[(4*(i+1)) - 1 : 4*i], ps[i]);
	end
   endgenerate
   always@(*)
		   begin
		      t_sum = 7'd0;
		      for(x = 0; x < 21; x=x+1)
			begin
			   t_sum = t_sum + {3'd0, ps[x]};
			end
		   end
   assign out = t_sum;
      
endmodule // ones_count81
*/

module one_count4(input [3:0] in, output [2:0] out);
   assign out = 
		(in == 4'b0000) ? 3'd0 :
		(in == 4'b0001) ? 3'd1 :
		(in == 4'b0010) ? 3'd1 :
		(in == 4'b0011) ? 3'd2 :
		(in == 4'b0100) ? 3'd1 :
		(in == 4'b0101) ? 3'd2 :
		(in == 4'b0110) ? 3'd2 :
		(in == 4'b0111) ? 3'd3 :
		(in == 4'b1000) ? 3'd1 :
		(in == 4'b1001) ? 3'd2 :
		(in == 4'b1010) ? 3'd2 :
		(in == 4'b1011) ? 3'd3 :
		(in == 4'b1100) ? 3'd2 :
		(in == 4'b1101) ? 3'd3 :
		(in == 4'b1110) ? 3'd3 :
		3'd4;
endmodule // one_count4

