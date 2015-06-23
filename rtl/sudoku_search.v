module sudoku_search(/*AUTOARG*/
   // Outputs
   outGrid, done, error,
   // Inputs
   clk, rst, start, inGrid
   );
   parameter LG_DEPTH = 6;
   localparam DEPTH = 1 << LG_DEPTH;
   
   input clk;
   input rst;
   input start;
   
   input [728:0] inGrid;
   output [728:0] outGrid;
   output 	  done;
   output 	  error;
   

   reg [4:0] 	  r_state, n_state;
   reg [31:0] 	  r_stack_pos, t_stack_pos;
   reg [31:0] 	  t_stack_addr;

   
   reg 		  t_write_stack, t_read_stack;
   reg 		  t_clr, t_start;
   reg [6:0] 	  r_minIdx, t_minIdx;
   reg [8:0] 	  r_cell, t_cell;
   wire [3:0] 	  w_ffs;
   wire [8:0] 	  w_ffs_mask;
   
      
   reg [728:0] 	  r_board, n_board;
   wire [728:0]   w_stack_out;
   reg [728:0] 	  t_stack_in;


   wire [728:0]   s_outGrid;
   wire [8:0] 	  s_outGrid2d[80:0];
   wire [728:0]   w_nGrid;
   
   reg [8:0] 	  t_outGrid2d[80:0];

   reg 		  t_done, r_done;
   reg 		  t_error, r_error;
   
   assign done = r_done;
   assign error = r_error;
   
   genvar 	  i;

   assign outGrid = s_outGrid;
         
   wire [6:0] 	  w_minIdx, w_unsolvedCells;
   wire [3:0] 	  w_minPoss;
   wire 	  w_allDone, w_anyChanged, w_anyError, w_timeOut;

   generate
      for(i=0;i<81;i=i+1)
	begin: unflatten
	   assign s_outGrid2d[i] = s_outGrid[(9*(i+1))-1:9*i];
	end
   endgenerate

   integer j;
   always@(*)
     begin
	for(j=0;j<81;j=j+1)
	  begin
	     t_outGrid2d[j] = s_outGrid2d[j];
	  end
	t_outGrid2d[r_minIdx] = w_ffs_mask;
     end

   generate
      for(i=0;i<81;i=i+1)
	begin: flatten
	   assign w_nGrid[(9*(i+1)-1):(9*i)] = t_outGrid2d[i];
	end
   endgenerate
   

   
   find_first_set ffs0
     (
      .in(r_cell),
      .out(w_ffs),
      .out_mask(w_ffs_mask)
      );
   
   always@(*)
     begin
	t_clr = 1'b0;
	t_start = 1'b0;
		
	t_write_stack = 1'b0;
	t_read_stack = 1'b0;
	t_stack_in = 729'd0;
	
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
	       if(r_board === 729'dx)
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
	     r_board <= 729'd0;
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
 
   stack_ram #(.LG_DEPTH(LG_DEPTH)) stack0 
     (
      // Outputs
      .d_out		(w_stack_out),
      // Inputs
      .clk		(clk),
      .w			(t_write_stack),
      .addr		(t_stack_addr[(LG_DEPTH-1):0] ),
      .d_in		(t_stack_in)
      );

   
   sudoku cover0 (
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
   localparam DEPTH = 1 << LG_DEPTH;
   
   input clk;
   input w;
   input [(LG_DEPTH-1):0] addr;
   
   input [728:0] d_in;
   output [728:0] d_out;

   reg [728:0] 	  r_dout;
   assign d_out = r_dout;

   reg [728:0] 	  mem [(DEPTH-1):0];
      
   always@(posedge clk)
     begin
	if(w)
	  begin
	     if(d_in == 729'dx)
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

module find_first_set(out,out_mask,in);
   input [8:0] in;
   output [3:0] out;
   output [8:0] out_mask;
   
   genvar 	i;
   wire [8:0] 	w_fz;
   wire [8:0] 	w_fzo;
   assign w_fz[0] = in[0];
   assign w_fzo[0] = in[0];

   assign out = (w_fzo == 9'd1) ? 4'd1 :
		(w_fzo == 9'd2) ? 4'd2 :
		(w_fzo == 9'd4) ? 4'd3 :
		(w_fzo == 9'd8) ? 4'd4 :
		(w_fzo == 9'd16) ? 4'd5 :
		(w_fzo == 9'd32) ? 4'd6 :
		(w_fzo == 9'd64) ? 4'd7 :
		(w_fzo == 9'd128) ? 4'd8 :
		(w_fzo == 9'd256) ? 4'd9 :
		4'hf;

   assign out_mask = w_fzo;
      
   generate
      for(i=1;i<9;i=i+1)
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
   


module checkCorrect(/*AUTOARG*/
   // Outputs
   y,
   // Inputs
   in
   );
   input [80:0] in;
      
   output 	y;
   
   wire [8:0] 	grid1d [8:0];
   wire [8:0] 	w_set;
   
   
   wire [8:0] w_gridOR = 
	      grid1d[0] |
	      grid1d[1] |
	      grid1d[2] |
	      grid1d[3] |
	      grid1d[4] |
	      grid1d[5] |
	      grid1d[6] |
	      grid1d[7] |
	      grid1d[8];
   
   wire       w_allSet = (w_gridOR == 9'b111111111);
   wire       w_allAssign = (w_set == 9'b111111111);
   
   assign y = w_allSet & w_allAssign;

   genvar     i;
   
   generate
      for(i=0;i<9;i=i+1)
	begin: unflatten
	   assign grid1d[i] = in[(9*(i+1))-1:9*i];
	   assign w_set[i] = 	
			     (grid1d[i] == 9'd1)   | 
			     (grid1d[i] == 9'd2)   | 
			     (grid1d[i] == 9'd4)   |
			     (grid1d[i] == 9'd8)   | 
			     (grid1d[i] == 9'd16)  | 
			     (grid1d[i] == 9'd32)  |
			     (grid1d[i] == 9'd64)  |
			     (grid1d[i] == 9'd128) | 
			     (grid1d[i] == 9'd256);
	end
   endgenerate
endmodule // correct
