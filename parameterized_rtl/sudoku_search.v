module sudoku_search(/*AUTOARG*/
   // Outputs
   outGrid, done, error,
   // Inputs
   clk, rst, start, inGrid
   );

   function integer my_clog2;
      input integer value;
      begin
	 value = value-1;
	 for (my_clog2=0; value>0; my_clog2=my_clog2+1)
	   value = value>>1;
      end
   endfunction // for

   parameter LG_DEPTH = 6;
   parameter DIM = 3;
   localparam DIM_S = (DIM*DIM);
   localparam DIM_Q = (DIM_S*DIM_S);
   localparam LG_DIM_S = my_clog2(DIM_S);
   localparam LG_DIM_Q = my_clog2(DIM_Q);
      
   
   localparam DEPTH = 1 << LG_DEPTH;
   
   input clk;
   input rst;
   input start;
   
   input [(DIM_S*DIM_S*DIM_S -1):0] inGrid;
   output [(DIM_S*DIM_S*DIM_S - 1):0] outGrid;
   
   output 	  done;
   output 	  error;
   

   reg [4:0] 	  r_state, n_state;
   reg [31:0] 	  r_stack_pos, t_stack_pos;
   reg [31:0] 	  t_stack_addr;

   
   reg 		  t_write_stack, t_read_stack;
   reg 		  t_clr, t_start;
   
   reg [(LG_DIM_Q-1):0] r_minIdx, t_minIdx;
   
   reg [(DIM_S-1):0] r_cell, t_cell;
   wire [(DIM_S-1):0] w_ffs_mask;
         
   reg [(DIM_S*DIM_S*DIM_S-1):0] r_board;
   reg [(DIM_S*DIM_S*DIM_S-1):0] n_board;
   wire [(DIM_S*DIM_S*DIM_S -1):0] w_stack_out;
   reg [(DIM_S*DIM_S*DIM_S -1):0]  t_stack_in;


   wire [(DIM_S*DIM_S*DIM_S -1):0] s_outGrid;
   wire [(DIM_S-1):0] 		   s_outGrid2d[(DIM_Q-1):0];
   wire [(DIM_S*DIM_S*DIM_S -1):0] w_nGrid;
   reg [(DIM_S-1):0] 		   t_outGrid2d[(DIM_Q-1):0];

   reg 		  t_done, r_done;
   reg 		  t_error, r_error;
   
   assign done = r_done;
   assign error = r_error;
   
   genvar 	  i;

   assign outGrid = s_outGrid;
         
   wire [(LG_DIM_Q-1):0] w_minIdx, w_unsolvedCells;
   
   wire [(LG_DIM_S-1):0] w_minPoss;
   wire 		 w_allDone, w_anyChanged, w_anyError, w_timeOut;

   generate
      for(i=0;i<DIM_Q;i=i+1)
	begin: unflatten
	   assign s_outGrid2d[i] = s_outGrid[(DIM_S*(i+1))-1:DIM_S*i];
	end
   endgenerate

   integer j;
   always@(*)
     begin
	for(j=0;j<DIM_Q;j=j+1)
	  begin
	     t_outGrid2d[j] = s_outGrid2d[j];
	  end
	t_outGrid2d[r_minIdx] = w_ffs_mask;
     end

   generate
      for(i=0;i<DIM_Q;i=i+1)
	begin: flatten
	   assign w_nGrid[(DIM_S*(i+1)-1):(DIM_S*i)] = t_outGrid2d[i];
	end
   endgenerate
   
   
   find_first_set #(.DIM_S(DIM_S)) ffs0
     (
      .in(r_cell),
      .out_mask(w_ffs_mask)
      );
   
   always@(*)
     begin
	t_clr = 1'b0;
	t_start = 1'b0;
		
	t_write_stack = 1'b0;
	t_read_stack = 1'b0;
	t_stack_in = 'd0;
	
	t_stack_pos = r_stack_pos;
	t_stack_addr = t_stack_pos;
	
	n_state = r_state;
	n_board = r_board;

	t_minIdx = r_minIdx;
	t_cell = r_cell;

	t_done = r_done;
	t_error = r_error;
	
	case(r_state)
	  /* copy input to stack */
	  5'd0:
	    begin
	       if(start)
		 begin
		    t_write_stack = 1'b1;
		    t_stack_pos = r_stack_pos + 32'd1;
		    n_state = 5'd1;
		    t_stack_in = inGrid;
		 end
	       else
		 begin
		    n_state = 5'd0;
		 end
	    end
	  /* pop state off the top of the stack,
	   * data valid in the next state */
	  5'd1:
	    begin
	       t_read_stack = 1'b1;
	       //$display("reading new board");
	       
	       t_stack_pos = r_stack_pos - 32'd1;
	       t_stack_addr = t_stack_pos;
	       	       
	       n_state = (r_stack_pos == 32'd0) ? 5'd31 : 5'd2;
	    end
	  /* data out of stack ram is 
	   * valid .. save in register */
	  5'd2:
	    begin
	       t_clr = 1'b1;
	       
	       n_board = w_stack_out;
	       n_state = 5'd3;
	    end

	  /* stack read..valid in r_state */
	  5'd3:
	    begin
	       t_start = 1'b1;
	       n_state = 5'd4;
	       if(r_board === 'dx)
		 begin
		    $display("GOT X!");
		    $display("%b", r_board);
		    
		    $finish();
		 end
	    end
	  
	  /* wait for exact cover
	   * hardware to complete */
	  5'd4:
	    begin
	       if(w_allDone)
		 begin
		    n_state = w_anyError ? 5'd1 : 5'd8;
		 end
	       else if(w_timeOut)
		 begin
		    $display("got time out, min cell in %d", w_minIdx);
		    t_minIdx = w_minIdx;
		    n_state = 5'd5;
		 end
	       else
		 begin
		    n_state = 5'd4;
		 end
	    end // case: 5'd4

	  5'd5:
	    begin
	       /* extra cycle */
	       t_cell = s_outGrid2d[r_minIdx];
	       n_state = 5'd6;
	    end
	  
	  /* timeOut -> push next states onto the stack */
	  5'd6:
	    begin
	       /* if min cell is zero, the board is incorrect
		* and we have no need to push successors */
	       if(r_cell == 9'd0)
		 begin
		    n_state = 5'd1;
		 end
	       else
		 begin
		    t_cell = r_cell & (~w_ffs_mask);
	       	    t_stack_in = w_nGrid;
		    t_write_stack = 1'b1;
		    t_stack_pos = r_stack_pos + 32'd1;
	            n_state = (t_stack_pos == (DEPTH-1)) ? 5'd31: 5'd7;
		 end
	    end

	  5'd7:
	    begin
	       n_state = (r_cell == 9'd0) ? 5'd1 : 5'd6;
	    end

	  5'd8:
	    begin
	       t_done = 1'b1;
	       n_state = 5'd8;
	    end
	  
	  5'd31:
	    begin
	       n_state = 5'd31;
	       t_error = 1'b1;
	    end
	  
	  default:
	    begin
	       n_state = 5'd0;
	    end
	endcase // case (r_state)
     end
   

   always@(posedge clk)
     begin
	if(rst)
	  begin
	     r_board <= 'd0;
	     r_state <= 5'd0;
	     r_stack_pos <= 32'd0;
	     r_minIdx <= 7'd0;
	     r_cell <= 9'd0;
	     r_done <= 1'b0;
	     r_error <= 1'b0;
	  end
	else
	  begin
	     r_board <= n_board;
	     r_state <= n_state;
	     r_stack_pos <= t_stack_pos;
	     r_minIdx <= t_minIdx;
	     r_cell <= t_cell;
	     r_done <= t_done;
	     r_error <= t_error;
	  end
     end // always@ (posedge clk)

   /* stack ram */
 
   stack_ram #(.LG_DEPTH(LG_DEPTH), .WIDTH(DIM_Q*DIM_S)) 
   stack0 
     (
      // Outputs
      .d_out		(w_stack_out),
      // Inputs
      .clk		(clk),
      .w			(t_write_stack),
      .addr		(t_stack_addr[(LG_DEPTH-1):0] ),
      .d_in		(t_stack_in)
      );

   
   sudoku #(.DIM(DIM))
   cover0 (
	   // Outputs
	   .outGrid		(s_outGrid),
	   .unsolvedCells	(w_unsolvedCells),
	   .timeOut		(w_timeOut),
	   .allDone		(w_allDone),
	   .anyChanged		(w_anyChanged),
	   .anyError		(w_anyError),
	   .minIdx		(w_minIdx),
	   .minPoss		(w_minPoss),
	   // Inputs
	   .clk			(clk),
	   .rst			(rst),
	   .clr			(t_clr),
	   .start		(t_start),
	   .inGrid		(r_board)
	   );
         
endmodule // sudoku_search



module stack_ram(/*AUTOARG*/
   // Outputs
   d_out,
   // Inputs
   clk, w, addr, d_in
   );
   parameter LG_DEPTH = 4;
   parameter WIDTH = 16;
   
   localparam DEPTH = 1 << LG_DEPTH;
   
   input clk;
   input w;
   input [(LG_DEPTH-1):0] addr;
   
   input [(WIDTH-1):0] d_in;
   output [(WIDTH-1):0] d_out;

   reg [(WIDTH-1):0] 	r_dout;
   assign d_out = r_dout;

   reg [(WIDTH-1):0] 	mem [(DEPTH-1):0];
   
   always@(posedge clk)
     begin
	if(w)
	  begin
	     if(d_in == 'dx)
	       begin
		  $display("pushing X!!!");
		  $finish();
	       end
	     mem[addr] <= d_in;
	  end
	else
	  begin
	     r_dout <= mem[addr];
	  end
     end // always@ (posedge clk)

endmodule // stack_ram

module find_first_set(out_mask,in);
   parameter DIM_S = 9;
   
   input [(DIM_S-1):0] in;
   output [(DIM_S-1):0] out_mask;
   
   genvar 	i;
   wire [(DIM_S-1):0] w_fz;
   wire [(DIM_S-1):0] w_fzo;
   assign w_fz[0] = in[0];
   assign w_fzo[0] = in[0];

   assign out_mask = w_fzo;
      
   generate
      for(i=1;i<DIM_S;i=i+1)
	begin : www
	   fz fzN (
		   .out(w_fzo[i]),
		   .f_out(w_fz[i]),
		   .f_in(w_fz[i-1]),
		   .in(in[i])
		   );
	end
   endgenerate
endmodule // find_first_set

module fz(/*AUTOARG*/
   // Outputs
   out, f_out,
   // Inputs
   f_in, in
   );
   input f_in;
   input in;
   output out;
   output f_out;
   
   assign out = in & (~f_in);
   assign f_out = f_in | in;
   
endmodule
   
module chk_pow2(in, out);
   parameter DIM_S = 9;
   input [(DIM_S-1):0] in;
   output 	       out;

   wire [(DIM_S-1):0] 	w_ones = ~('d0);
   wire [(DIM_S-1):0] 	w_m = in + w_ones;
   assign out = ((w_m & in) == 'd0) && (in != 'd0);
   
endmodule // one_set

module checkCorrect(/*AUTOARG*/
   // Outputs
   y,
   // Inputs
   in
   );
   parameter DIM_S = 9;
   localparam DIM_Q = DIM_S*DIM_S;
   
   input [(DIM_Q-1):0] in;
   
   output 	       y;
   
   wire [(DIM_S-1):0]  grid1d [(DIM_S-1):0];
   wire [(DIM_S-1):0]  w_set;

   wire [(DIM_S-1):0]  w_mask = ~('d0);
      
   wire [(DIM_S-1):0]  w_accum_or [(DIM_S-1):0];
   genvar 	       i;
   generate
     for(i=0;i<DIM_S;i=i+1)
	begin: accum_or
	   if(i==0)
	     begin
		assign w_accum_or[i] = grid1d[i];
	     end
	   else
	     begin
		assign w_accum_or[i] = w_accum_or[i-1] | grid1d[i];
	     end
	end
   endgenerate

   wire [(DIM_S-1):0] w_gridOR = w_accum_or[(DIM_S-1)];
      
   wire       w_allSet = (w_gridOR == w_mask);
   wire       w_allAssign = (w_set == w_mask);
   
   assign y = w_allSet & w_allAssign;
   
   generate
      for(i=0;i<DIM_S;i=i+1)
	begin: unflatten
	   assign grid1d[i] = in[(DIM_S*(i+1))-1:DIM_S*i];
	   chk_pow2 #(.DIM_S(DIM_S)) pchk (.in(grid1d[i]), .out(w_set[i]));
	end
   endgenerate
endmodule // checkCorrect

