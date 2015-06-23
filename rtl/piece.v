module piece(/*AUTOARG*/
   // Outputs
   changed, done, curr_value, error,
   // Inputs
   clk, rst, start, clr, start_value, my_row, my_col, my_square
   );
   input clk;
   input rst;
   input start;
   input clr;
   
   output changed;
   output done;
   output error;
   
   input [8:0] start_value;
   output [8:0] curr_value;
      
   input [71:0] my_row;
   input [71:0] my_col;
   input [71:0] my_square;
   
   wire [8:0] 	row2d [7:0];
   wire [8:0] 	col2d [7:0];
   wire [8:0] 	sqr2d [7:0];

   wire [8:0] 	row2d_solv [7:0];
   wire [8:0] 	col2d_solv [7:0];
   wire [8:0] 	sqr2d_solv [7:0];

   reg [8:0] 	r_curr_value;
   reg [8:0] 	t_next_value;
   assign curr_value = r_curr_value;

   reg [2:0] 	r_state, n_state;
   reg 		r_solved, t_solved;
   reg 		t_changed,r_changed;
   reg 		t_error,r_error;
   
   assign done = r_solved;
   assign changed = r_changed;
   assign error = r_error;
      
   wire [8:0] 	w_solved;
   wire 	w_piece_solved = (w_solved != 9'd0);
   one_set s0 (r_curr_value, w_solved);
   
   
   always@(posedge clk)
     begin
	if(rst)
	  begin
	     r_curr_value <= 9'd0;
	     r_state <= 3'd0;
	     r_solved <= 1'b0;
	     r_changed <= 1'b0;
	     r_error <= 1'b0;
	  end
	else
	  begin
	     r_curr_value <= clr ? 9'd0 : t_next_value;
	     r_state <= clr ? 3'd0 : n_state;
	     r_solved <= clr ? 1'b0 : t_solved;
	     r_changed <= clr ? 1'b0 : t_changed;
	     r_error <= clr ? 1'b0 : t_error;
	  end
     end // always@ (posedge clk)
   

   
   genvar 	i;
   generate
      for(i=0;i<8;i=i+1)
	begin: unflatten
	   assign row2d[i] = my_row[(9*(i+1))-1:9*i];
	   assign col2d[i] = my_col[(9*(i+1))-1:9*i];
	   assign sqr2d[i] = my_square[(9*(i+1))-1:9*i];
	end
   endgenerate

   generate
      for(i=0;i<8;i=i+1)
	begin: unique_rows
	   one_set rs (row2d[i], row2d_solv[i]);
	   one_set cs (col2d[i], col2d_solv[i]);
	   one_set ss (sqr2d[i], sqr2d_solv[i]);
	end
   endgenerate

   /* OR output of one_set to find cells
    * that are already set in col, grid, row */

   
   wire [8:0] set_row = 
	      row2d_solv[0] | row2d_solv[1] | row2d_solv[2] |
   	      row2d_solv[3] | row2d_solv[4] | row2d_solv[5] |
   	      row2d_solv[6] | row2d_solv[7];
   
   wire [8:0] set_col = 
	      col2d_solv[0] | col2d_solv[1] | col2d_solv[2] |
	      col2d_solv[3] | col2d_solv[4] | col2d_solv[5] |
	      col2d_solv[6] | col2d_solv[7];
      
   wire [8:0] set_sqr = 
	      sqr2d_solv[0] | sqr2d_solv[1] | sqr2d_solv[2] |
	      sqr2d_solv[3] | sqr2d_solv[4] | sqr2d_solv[5] |
	      sqr2d_solv[6] | sqr2d_solv[7];
   

   integer    ii;
   
   always@(posedge clk)
     begin
	if(rst==1'b0)
	  begin
	     for(ii=0;ii<8;ii=ii+1)
	       begin
		  if(row2d_solv[ii] === 9'dx)
		    begin
		       $display("row %d", ii);
		       $stop();
		    end
	       end
	  end
	//$display("row2d_solv[0] = %x", row2d_solv[0]);
     end

   

   /* finding unique */
   wire [8:0] row_or = 
	      row2d[0] | row2d[1] | row2d[2] |
	      row2d[3] | row2d[4] | row2d[5] |
	      row2d[6] | row2d[7] ;

   wire [8:0] col_or = 
	      col2d[0] | col2d[1] | col2d[2] |
	      col2d[3] | col2d[4] | col2d[5] |
	      col2d[6] | col2d[7] ;
   
   wire [8:0] sqr_or = 
	      sqr2d[0] | sqr2d[1] | sqr2d[2] |
	      sqr2d[3] | sqr2d[4] | sqr2d[5] |
	      sqr2d[6] | sqr2d[7] ;
   


   wire [8:0] row_nor = ~row_or;
   wire [8:0] col_nor = ~col_or;
   wire [8:0] sqr_nor = ~sqr_or;

   wire [8:0] row_singleton;
   wire [8:0] col_singleton;
   wire [8:0] sqr_singleton;
   
   one_set s1 (r_curr_value & row_nor, row_singleton);
   one_set s2 (r_curr_value & col_nor, col_singleton);
   one_set s3 (r_curr_value & sqr_nor, sqr_singleton);
   
   /* these are the values of the set rows, columns, and 
    * squares */
   
   wire [8:0] not_poss = set_row | set_col | set_sqr;
   
   wire [8:0] new_poss = r_curr_value & (~not_poss);
   wire       w_piece_zero = (r_curr_value == 9'd0);
   
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
		    if(row_singleton != 9'd0)
		      begin
			 //$display("used row singleton");
			 t_next_value = row_singleton;
			 t_changed = 1'b1;
			 t_solved = 1'b1;
			 n_state = 3'd7;
		      end
		    else if(col_singleton != 9'd0)
		      begin
			 //$display("used col singleton");
			 t_next_value = col_singleton;
			 t_changed = 1'b1;
		      	 t_solved = 1'b1;
			 n_state = 3'd7;
		      end
		    else if(sqr_singleton != 9'd0)
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

module one_set(input [8:0] in, output [8:0] out);
   wire is_pow2 = 
	(in == 9'd1) | (in == 9'd2) | (in == 9'd4) |
	(in == 9'd8) | (in == 9'd16)  | (in == 9'd32) |
	(in == 9'd64) | (in == 9'd128) | (in == 9'd256);
   
   assign out = {9{is_pow2}} & in;
endmodule // one_set

module two_set(input [8:0] in, output [8:0] out);
   wire [3:0] c;
   one_count9 oc (.in(in), .out(c));
   assign out = (c==4'd2) ? in : 9'd0;
endmodule

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

module one_count9(input [8:0] in, output [3:0] out);
   
   wire [2:0] o0, o1;
   
   one_count4 m0 (in[3:0], o0);
   one_count4 m1 (in[7:4], o1);

   assign out = {3'd0,in[8]} + {1'd0,o1} + {1'd0,o0};

endmodule