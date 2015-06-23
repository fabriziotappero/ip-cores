module sudoku(/*AUTOARG*/
   // Outputs
   outGrid, unsolvedCells, timeOut, allDone, anyChanged, anyError,
   minIdx, minPoss,
   // Inputs
   clk, rst, clr, start, inGrid
   );
   function integer my_clog2;
      input integer value;
      begin
	 value = value-1;
	 for (my_clog2=0; value>0; my_clog2=my_clog2+1)
	   value = value>>1;
      end
   endfunction // for
   
   parameter DIM = 3;
   localparam DIM_S = (DIM*DIM);
   localparam DIM_Q = (DIM_S*DIM_S);

   localparam LG_DIM_S = my_clog2(DIM_S);
   localparam LG_DIM_Q = my_clog2(DIM_Q);

   localparam PAD_WIDTH = (1<<LG_DIM_Q);
   localparam PAD = PAD_WIDTH - DIM_Q;
      
   input clk;
   input rst;
   input clr;
   
   input start;
   
   input [(DIM_S*DIM_S*DIM_S -1):0] inGrid;
   output [(DIM_S*DIM_S*DIM_S - 1):0] outGrid;

   /* TODO: PARAMETERIZE */
   output [(LG_DIM_Q-1):0] 		      unsolvedCells;
   output [(LG_DIM_Q-1):0] 		      minIdx;
   output [(LG_DIM_S-1):0] 		      minPoss;
   
   output 	  timeOut;
   output 	  allDone;
   output 	  anyChanged;
   output 	  anyError;

      
   wire [(DIM_S-1):0] grid2d [(DIM_Q-1):0];
   wire [(DIM_S-1):0] currGrid [(DIM_Q-1):0];
   wire [(DIM_Q-1):0] done;
   wire [(DIM_Q-1):0] changed;
   wire [(DIM_Q-1):0] error;
   
   assign allDone = &done;
   assign anyChanged = |changed;
   //assign anyError = |error;
   
   reg [3:0] 	  r_cnt;
   assign timeOut = (r_cnt == 4'b1111);
   always@(posedge clk)
     begin
	if(rst)
	  begin
	     r_cnt <= 4'd0;
	  end
	else
	  begin
	     r_cnt <= start ? 4'd0 : (|changed ? 4'd0 : r_cnt + 4'd1);
	  end
     end // always@ (posedge clk)

   minPiece #(.DIM(DIM)) mP0 
     (
      .minPoss(minPoss),
      .minIdx(minIdx),
      .clk(clk),
      .rst(rst),
      .inGrid(outGrid)
      );
         
   
   genvar 	  i, j;
   genvar 	  ii,jj;
   
   generate
      for(i=0;i<DIM_Q;i=i+1)
	begin: unflatten
	   assign grid2d[i] = inGrid[(DIM_S*(i+1))-1:(DIM_S*i)];
	end
   endgenerate

   wire [(LG_DIM_Q-1):0] w_unSolvedCells;
   reg [(LG_DIM_Q-1):0]  r_unSolvedCells;
   always@(posedge clk)
     begin
	if(rst)
	  begin
	     r_unSolvedCells <= DIM_Q;
	  end
	else
	  begin
	     r_unSolvedCells <= start ? DIM_Q : w_unSolvedCells;
	  end
     end // always@ (posedge clk)
   assign unsolvedCells = r_unSolvedCells;

   
   wire [(PAD_WIDTH-1):0]  w_pad_in;
   generate
      begin: padding
	 if(PAD > 0)
	   begin
	      assign w_pad_in = { {PAD{1'b0}}, (~done)};
	   end
	 else
	   begin
	      assign w_pad_in = ~done;
	   end
      end
  endgenerate

   ones_count #(.LG_IN_WIDTH(LG_DIM_Q)) oc1 (.in(w_pad_in), .out(w_unSolvedCells));
   
   wire [(DIM_S*(DIM_S-1)-1):0] w_rows [(DIM_Q-1):0];
   wire [(DIM_S*(DIM_S-1)-1):0] w_cols [(DIM_Q-1):0];
   wire [(DIM_S*(DIM_S-1)-1):0] w_sqrs [(DIM_Q-1):0];
      
   generate
      for(i=0;i<DIM_Q;i=i+1)
	begin: pieces
	   piece # (.DIM_S(DIM_S)) 
	   pg (
	       // Outputs
	       .changed			(changed[i]),
	       .done			(done[i]),
	       .curr_value			(currGrid[i]),
	       .error                     (error[i]),
	       // Inputs
	       .clk				(clk),
	       .rst				(rst),
	       .clr                               (clr),
	       .start			(start),
	       .start_value			(grid2d[i]),
	       .my_row			(w_rows[i]),
	       .my_col			(w_cols[i]),
	       .my_square			(w_sqrs[i])
	       );
	end // block: pieces
    endgenerate

   
   generate
      for(i=0;i<DIM_S;i=i+1)
	begin: col_outer
	   for(ii=0;ii<DIM_S;ii=ii+1)
	     begin: gen_cols
		for(jj=0;jj<DIM_S;jj=jj+1)
		  begin: gen_col_elem
		     if(i > jj)
		       begin
			  assign w_cols[i*DIM_S+ii][(DIM_S*(jj+1)-1):DIM_S*jj] = currGrid[DIM_S*(jj)+ii];
		       end

		     else if(jj > i)
		       begin
			  assign w_cols[i*DIM_S+ii][ (DIM_S*(jj)-1):DIM_S*(jj-1)] = currGrid[ DIM_S*(jj) + ii];
		       end
		  end
	     end // block: gen_cols
	end // block: col_outer
   endgenerate

  
   generate
      for(i=0;i<DIM_S;i=i+1)
	begin: row_outer
	   for(ii=0;ii<DIM_S;ii=ii+1)
	     begin: rows_cols
		for(jj=0;jj<DIM_S;jj=jj+1)
		  begin: gen_row_elem
		     if(ii > jj)
		       begin
			  assign w_rows[i*DIM_S+ii][(DIM_S*(jj+1)-1):DIM_S*jj] = currGrid[DIM_S*(i)+jj];
		       end

		     else if(jj > ii)
		       begin
			  assign w_rows[i*DIM_S+ii][ (DIM_S*(jj)-1):DIM_S*(jj-1)] = currGrid[ DIM_S*(i)+jj];
		       end
		  end
	     end
	end
   endgenerate


   generate
      for(i=0;i<DIM_S;i=i+1)
	begin: outer_y_sqr
	   for(j=0;j<DIM_S;j=j+1)
	     begin: outer_x_sqr
		for(ii=DIM*(i/DIM); ii < DIM*((i/DIM)+1); ii=ii+1)
		  begin: inner_y_sqr
		     for(jj=DIM*(j/DIM); jj < DIM*((j/DIM)+1); jj=jj+1)
		       begin: inner_x_sqr
			  if((i*DIM_S + j) > (ii*DIM_S + jj))
			    begin
			       assign w_sqrs[i*DIM_S+j][(DIM_S*((ii-(DIM*(i/DIM)))*DIM + (jj-(DIM*(j/DIM)))+1) - 1):(DIM_S*((ii-(DIM*(i/DIM)))*DIM + (jj-(DIM*(j/DIM)))))] = currGrid[DIM_S*(ii)+jj];
			    end

			  else if((i*DIM_S + j) < (ii*DIM_S + jj))
			    begin
			       assign w_sqrs[i*DIM_S+j][(DIM_S*((ii-(DIM*(i/DIM)))*DIM + (jj-(DIM*(j/DIM))-1)+1) - 1):(DIM_S*((ii-(DIM*(i/DIM)))*DIM + (jj-(DIM*(j/DIM))-1)))] = currGrid[DIM_S*(ii)+jj];
			    end
		       end
		  end
	     end
	end // block: outer_y_sqr
   endgenerate

  generate
     for(i=0;i<DIM_Q;i=i+1)
       begin: outGridGen
	  assign outGrid[(DIM_S*(i+1)-1):(DIM_S*i)] = currGrid[i];

       end
  endgenerate
      
   
   wire [(DIM_Q-1):0] c_rows [(DIM_S-1):0];
   wire [(DIM_Q-1):0] c_cols [(DIM_S-1):0];
   wire [(DIM_Q-1):0] c_grds [(DIM_S-1):0];
   
   wire [(3*DIM_S - 1):0] w_correct;
   
   generate
      for(ii=0;ii<DIM_S;ii=ii+1)
	begin: row_check
	   for(jj=0;jj<DIM_S;jj=jj+1)
	     begin: row_elem_check
		assign c_rows[jj][(DIM_S*(ii+1)-1):DIM_S*ii] = currGrid[(DIM_S*jj) + ii];
	     end
	end
   endgenerate
   
   generate
      for(ii=0;ii<DIM_S;ii=ii+1)
	begin: col_check
	   for(jj=0;jj<DIM_S;jj=jj+1)
	     begin: col_elem_check
		assign c_cols[jj][(DIM_S*(ii+1)-1):DIM_S*ii] = currGrid[DIM_S*ii + jj];
	     end
	end
   endgenerate

   genvar iii,jjj;
   generate
      for(ii=0; ii < DIM; ii=ii+1)
	begin: grd_check_y
	   for(jj = 0; jj < DIM; jj=jj+1)
	     begin: grd_check_x
		for(iii=DIM*ii; iii < DIM*(ii+1); iii=iii+1)
		  begin: gg_y
		     for(jjj=DIM*jj; jjj < DIM*(jj+1); jjj=jjj+1)
		       begin: gg_x
			  assign c_grds[DIM*ii+jj][DIM_S*(DIM*(iii-DIM*ii) + (jjj-DIM*jj)+1)-1:DIM_S*(DIM*(iii-DIM*ii) + (jjj-DIM*jj))] = currGrid[DIM_S*iii + jjj];
		       end 
		  end
	     end
	end
   endgenerate
         
   generate
      for(ii=0;ii<DIM_S;ii=ii+1)
	begin: checks
	   checkCorrect #(.DIM_S(DIM_S)) cC_R 
	     (.y(w_correct[0*(DIM_S) + ii]), .in(c_rows[ii]));
	   checkCorrect #(.DIM_S(DIM_S)) cC_C 
	     (.y(w_correct[1*(DIM_S) + ii]), .in(c_cols[ii]));
	   checkCorrect #(.DIM_S(DIM_S)) cC_G 
	     (.y(w_correct[2*(DIM_S) + ii]), .in(c_grds[ii]));
	end
   endgenerate
   
   
   assign anyError = ~(&w_correct);
   
endmodule