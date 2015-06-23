// port from univeristy project for an ALU in VHDL
//
module alu_barrel_shifter	(
                            x          ,
                            y          ,
                            z          ,
                            c          ,
                            direction
			                    );

  parameter SHIFTER_WIDTH	= 8;

  input	  [SHIFTER_WIDTH - 1 : 0] x          ;
  input	  [SHIFTER_WIDTH - 1 : 0] y          ;
  output  [SHIFTER_WIDTH - 1 : 0] z          ;
  output                          c          ;
  input	                          direction  ;


  wire	[SHIFTER_WIDTH : 0]     Yor       ;
  wire	[SHIFTER_WIDTH : 0]     Yreg      ;
  wire	[SHIFTER_WIDTH : 0]     Xreg      ;
  reg 	[SHIFTER_WIDTH : 0]     Zreg      ;
  wire	[SHIFTER_WIDTH : 0]     Zout      ;

  wire	[SHIFTER_WIDTH : 0]     Xrev      ;
  wire	[SHIFTER_WIDTH : 0]     Zrev      ;
  
  reg 	[SHIFTER_WIDTH-1 : 0]   Zrev_copy ; //  for missing bits

  wire	                        Xmsb      ;

  reg         Ztmp, update_extra_bits;
  integer     j, k, m;
  
  //initial update_extra_bits = 1'b0;

 function [SHIFTER_WIDTH : 0] reverse;
 input  [SHIFTER_WIDTH : 0] a         ;
 reg	  [0 : SHIFTER_WIDTH] a_reversed;
 reg    [31:0]              i         ;
 begin
	 for (i=0;i<= SHIFTER_WIDTH;i = i + 1)
		 a_reversed[i]	= a[i];
	 reverse = a_reversed;
 end
 endfunction


  wire	[SHIFTER_WIDTH : 0]     value_7  ;
  
  assign value_7 = 'h7;
	////////////////////////////////////////////////////
  // shifter
  ////////////////////////////////////////////////////
  
  ///  theoretical solution for missing bits START ///
  //assign Zrev_copy = {Xreg[SHIFTER_WIDTH-1:SHIFTER_WIDTH-m] ;
  ///  theoretical solution for missing bits END  ///
  
  assign  Yreg	=	{1'b0, y & value_7}                                   ;
	assign  Zrev	=	reverse(Zreg)                                         ;
	assign  Xrev	=	(!direction) ? reverse({1'b0, x}) :	reverse({x, 1'b0});
//	assign  Xmsb	=	x[SHIFTER_WIDTH-1]                                    ;
  	assign  Xmsb	=	(y[2:0]==0) ? x[SHIFTER_WIDTH-1] : 1'b0             ;
	//assign  z		  =	(!direction) ? Zout[SHIFTER_WIDTH-1:0]	: {Xmsb, Zout[SHIFTER_WIDTH-1:1]} ;
  
	assign  z		  =	(!direction) ? Zout[SHIFTER_WIDTH-1:0]	: {Xmsb, Zout[SHIFTER_WIDTH-1:1]} | ((y[2:0]==0) ? 'd0 : Zrev_copy);

	assign  c		  =	(!direction) ? Zout[SHIFTER_WIDTH]	    :	Zout[0]                         ;
  
	assign  Zout	=	(!direction) ? Zreg                     : Zrev                            ;
  
	assign  Xreg	= (!direction) ? {1'b0, x}                : Xrev                            ;


	assign  Yor[0]= (Yreg == 'd0) ? 1'b1 : 1'b0;
	assign  Yor[1]= (Yreg == 'd1) ? 1'b1 : 1'b0;
	assign  Yor[2]= (Yreg == 'd2) ? 1'b1 : 1'b0;
	assign  Yor[3]= (Yreg == 'd3) ? 1'b1 : 1'b0;
	assign  Yor[4]= (Yreg == 'd4) ? 1'b1 : 1'b0;
	assign  Yor[5]= (Yreg == 'd5) ? 1'b1 : 1'b0;
	assign  Yor[6]= (Yreg == 'd6) ? 1'b1 : 1'b0;
	assign  Yor[7]= (Yreg == 'd7) ? 1'b1 : 1'b0;
	assign  Yor[8]= 1'b0;
				

  // shifter       :	process (Xreg, Yreg, Yor)
  // temporary variables but declare as regs
  // for synthesis reasons.
  // They extra unneeded bits should be optimized away
  //
  initial j = 'd0;
  initial k = 'd0;
  
  initial update_extra_bits = 1'b0;
  
  always @(x or y or direction)
  begin
    update_extra_bits = 1'b0;
  end
  
  always @(Xreg or Yreg or Yor)
	begin
    //#1;
		Zreg = 'h0;
    `ifdef DEBUG_BARREL_SHIFTER
      $display("**** BARREL SHIFTER always block stage 1 ****");
    `endif
    for (j=SHIFTER_WIDTH; j>=0 ; j=j-1)
    begin
		  Ztmp = 1'b0;						
			if (j == 0)
      begin
				Zreg[j]	=	Xreg[j] & Yor[0];
        `ifdef DEBUG_BARREL_SHIFTER
          $display("**** BARREL SHIFTER always block stage 2 ****");
          $display("%d %d", j, k);
        `endif
      end
			else
      begin
        `ifdef DEBUG_BARREL_SHIFTER
          $display("**** BARREL SHIFTER always block stage 3 ****");
          $display("%d %d", j, k);
        `endif
				Ztmp	  = Xreg[j] & Yor[0];
				for (k=1 ; k<=j ; k=k+1)
        begin
					Ztmp   =  (Xreg[j-k]  &  Yor[k]) | Ztmp;
          
          if (Yor[k] && direction)
          begin
        		Zrev_copy = 'd0 ;
            for(m=0; m<k ; m=m+1)
            begin
              update_extra_bits = 1'b1;
              Zrev_copy[(SHIFTER_WIDTH-k)+m] = x[m];
        `ifdef DEBUG_BARREL_SHIFTER
              $display("[%0t]Updating Zrev_copy[%d] = %b  Zrev_copy=%b %b %b", $time, m, Zrev_copy[m], Zrev_copy, Xreg, x);
        `endif
            end
          end
        end
      `ifdef DEBUG_BARREL_SHIFTER
        $display("[%0t] Xreg %b Xrev %b x %b", $time, Xreg, Xrev, x); 
      `endif
				Zreg[j]	= Ztmp;
			end // end else
        `ifdef DEBUG_BARREL_SHIFTER
          $display("**** BARREL SHIFTER always block stage LOOP ****");
          $display("%d %d", j, k);
        `endif
		end // end loop
        `ifdef DEBUG_BARREL_SHIFTER
          $display("**** BARREL SHIFTER always block stage END ****");
          $display("%d %d", j, k);
        `endif
	end //end shifter;
  
endmodule
