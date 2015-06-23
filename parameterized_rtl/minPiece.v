module minPiece(/*AUTOARG*/
   // Outputs
   minPoss, minIdx,
   // Inputs
   clk, rst, inGrid
   );

   function integer my_clog2;
   input integer value;
   begin
      value = value-1;
      for (my_clog2=0; value>0; my_clog2=my_clog2+1)
	value = value>>1;
   end
   endfunction
   
   parameter DIM = 3;
   localparam DIM_S = DIM*DIM;
   localparam DIM_Q = DIM_S*DIM_S;

   localparam LG_DIM_S = my_clog2(DIM_S);
   localparam LG_DIM_Q = my_clog2(DIM_Q);

   localparam PAD_WIDTH = (1<<LG_DIM_Q);
   localparam PAD = PAD_WIDTH - DIM_Q;

     
   input clk;
   input rst;
   
   input [(DIM_S*DIM_S*DIM_S -1):0] inGrid;

   output [(LG_DIM_S-1):0] 	    minPoss;
   output [(LG_DIM_Q-1):0] 	    minIdx;
   
   reg [(LG_DIM_S-1):0] 	    r_minPoss;
   reg [(LG_DIM_Q-1):0] 	    r_minIdx;
   
   assign minPoss = r_minPoss;
   assign minIdx = r_minIdx;
   
   wire [(DIM_S-1):0] grid2d [(DIM_Q-1):0];

   wire [(LG_DIM_S-1):0] w_reduce_poss [(LG_DIM_Q):0][(PAD_WIDTH-1):0];
   wire [(LG_DIM_Q-1):0] w_reduce_indices [(LG_DIM_Q):0][(PAD_WIDTH-1):0];
   
   genvar 	 i,j;

   /* unflatten */
   generate
      for(i=0;i<PAD_WIDTH;i=i+1)
	begin: unflatten
	   if(i < DIM_Q)
	     begin
		assign grid2d[i] = inGrid[(DIM_S*(i+1))-1:DIM_S*i];
		countPoss #(.DIM(DIM)) cP1 (.clk(clk), .rst(rst), .in(grid2d[i]), .out(w_reduce_poss[0][i]));
		assign w_reduce_indices[0][i] = i;
	     end
	   else
	     begin
		assign w_reduce_poss[0][i] = ~0;
		assign w_reduce_indices[0][i] = i;
	     end // else: !if(i < DIM_Q)
	   //assign w_reduce_indices[0][i] = i;
	end
   endgenerate

   localparam RIDX=LG_DIM_Q;
   generate
      for(i=1;i<(LG_DIM_Q+1);i=i+1)
	begin: level_reduce
	   for(j=0;j<(1<<(LG_DIM_Q-i));j=j+1)
	     begin: elem_reduce
		cmpPiece #(.DIM(DIM)) cmpr
		 (
		  .outPoss(w_reduce_poss[i][j]),
		  .outIdx(w_reduce_indices[i][j]),
		  .inPoss_0(w_reduce_poss[i-1][2*j]),
		  .inIdx_0(w_reduce_indices[i-1][2*j]),
		  .inPoss_1(w_reduce_poss[i-1][2*j+1]),
		  .inIdx_1(w_reduce_indices[i-1][2*j+1])
		  );
	     end
	end
   endgenerate
      
   always@(posedge clk)
     begin
	if(rst)
	  begin
	     r_minIdx <= 0;
	     r_minPoss <= (~0);
	  end
	else
	  begin
	     r_minIdx <= w_reduce_indices[RIDX][0]; 
	     r_minPoss <= w_reduce_poss[RIDX][0];
	  end
     end // always@ (posedge clk)
      
endmodule // minPiece


module cmpPiece(/*AUTOARG*/
   // Outputs
   outPoss, outIdx,
   // Inputs
   inPoss_0, inIdx_0, inPoss_1, inIdx_1
   );

   function integer my_clog2;
      input integer value;
      begin
	 value = value-1;
	 for (my_clog2=0; value>0; my_clog2=my_clog2+1)
	   value = value>>1;
      end
   endfunction // for
      
   parameter DIM=3;
   localparam DIM_S = DIM*DIM;
   localparam DIM_Q = DIM_S*DIM_S;
   localparam LG_DIM_S = my_clog2(DIM_S);
   localparam LG_DIM_Q = my_clog2(DIM_Q);

   input [(LG_DIM_S-1):0] inPoss_0;
   input [(LG_DIM_Q-1):0] inIdx_0;

   input [(LG_DIM_S-1):0] inPoss_1;
   input [(LG_DIM_Q-1):0] inIdx_1;

   output [(LG_DIM_S-1):0] outPoss;
   output [(LG_DIM_Q-1):0] outIdx;
   
   wire 	w_cmp = (inPoss_0 < inPoss_1);

   assign outPoss = w_cmp ? inPoss_0 : inPoss_1;
   assign outIdx = w_cmp ? inIdx_0 : inIdx_1;
   
endmodule // cmpPiece

module countPoss(clk,rst,in,out);
   function integer my_clog2;
      input integer value;
      begin
	 value = value-1;
	 for (my_clog2=0; value>0; my_clog2=my_clog2+1)
	   value = value>>1;
      end
   endfunction // for
   
   parameter DIM=3;
   localparam DIM_S = DIM*DIM;
   localparam DIM_Q = DIM_S*DIM_S;

   localparam LG_DIM_S = my_clog2(DIM_S);
   localparam LG_DIM_Q = my_clog2(DIM_Q);
   
   localparam PAD = (1<<LG_DIM_S) - DIM_S;
   localparam PAD_WIDTH = (1<<LG_DIM_S);
    
   input [(DIM_S-1):0] in;
   input 	       clk;
   input 	       rst;
   
   output [(LG_DIM_S-1):0] out;
   reg [(LG_DIM_S-1):0]    r_out;
   assign out = r_out;

   
   wire [(PAD_WIDTH-1):0]  w_pad_in;
   generate
      begin: padding
	 if(PAD > 0)
	   begin
	      assign w_pad_in = { {PAD{1'b0}}, in};
	   end
	 else
	   begin
	      assign w_pad_in = in;
	   end
      end
   endgenerate

   wire [(LG_DIM_S-1):0]   w_cnt;
      
   ones_count #(.LG_IN_WIDTH(LG_DIM_S)) c0 (.in(w_pad_in), .out(w_cnt));
      
   wire [(LG_DIM_S-1):0]   w_out = (w_cnt == 'd1) ? ~0 : w_cnt;
   
   always@(posedge clk)
     begin
	r_out <= rst ? ~0 : w_out;
     end
   
endmodule // countPoss

