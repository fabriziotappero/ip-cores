module tb_search();
   reg clk;
   reg rst;
   reg start;
   wire done;

   reg [1023:0] puz_filename;
   integer 	fh;

   wire [728:0] outGrid;
   wire [728:0] inGrid;

   reg [8:0] 	mem [80:0];

        
   initial
     begin
	clk = 0;
	rst = 1;

	if($value$plusargs("puz=%s", puz_filename))
	  begin
	     $readmemh(puz_filename, mem);	     
	  end
	else
	  begin
	     $display("no puzzle filename, use +puz=!");
	     $finish();
	  end
	
      	#1000
	  rst = 0;
     end

   always@(posedge clk)
     begin
	if(rst)
	  start <= 1'b1;
	else
	  start <= start ? 1'b0 : start;
     end
   
   always
     clk = #5 !clk;

  
         
   sudoku_search uut (
	       // Outputs
	       .outGrid			(outGrid[728:0]),
	       .done                    (done),
	       .error                   (),
	       // Inputs
	       .clk			(clk),
	       .rst			(rst),
	       .start			(start),
	       .inGrid			(inGrid[728:0])
	       );

   genvar     i;
   generate
      for(i=0;i<81;i=i+1)
	begin: inGridGen
	   assign inGrid[(9*(i+1)-1):(9*i)] = mem[i];
	   
	end
   endgenerate
   

   reg [31:0] r_cnt;
  

   wire [8:0] result [80:0];
   wire [8:0] result_dec [80:0];
   

   integer    y,x;
     
   generate
      for(i=0;i<81;i=i+1)
	begin: unflatten
	   assign result[i] = outGrid[(9*(i+1))-1:9*i];
	   hot2dec h (.hot(result[i]), .dec(result_dec[i]));
	end
   endgenerate

  
   always@(posedge clk)
     begin
	if(rst)
	  begin
	     r_cnt <= 32'd0;
	  end
	else
	  begin
	     r_cnt <= start ? 32'd0 : r_cnt + 32'd1;
	     if(done)
	       begin
		  $write("\n");
		  for(y=0;y<9;y=y+1)
		    begin
		       for(x=0;x<9;x=x+1)
			 begin
			    $write("%d ", result_dec[y*9+x]);
			 end
		       $write("\n");
		    end
		  $display("solved in %d cycles", r_cnt);
		  $finish();
	       end // if (done)
	  end // else: !if(rst)
     end // always@ (posedge clk)
 
      
endmodule // tb_search


module hot2dec(input [8:0] hot, output [8:0] dec);
   assign dec = (hot == 9'd1) ? 9'd1 :
		(hot == 9'd2) ? 9'd2 :
		(hot == 9'd4) ? 9'd3 :
		(hot == 9'd8) ? 9'd4 :
		(hot == 9'd16) ? 9'd5 :
		(hot == 9'd32) ? 9'd6 :
		(hot == 9'd64) ? 9'd7 :
		(hot == 9'd128) ? 9'd8 :
		(hot == 9'd256) ? 9'd9 :
		9'd0;
endmodule