module clk_gen (clk, period_lo, period_hi);

  output             clk       ;
  input  [63:0]      period_lo ;
  input  [63:0]      period_hi ;
  
  reg                clk       ; 
  
  `ifdef verilator
    always
    begin
      if (clk === 1'bx)
        clk <= 1'b0;
      clk <= 1'b0;
      #(period_lo);
      clk <= 1'b1;
      #(period_hi);
    end
  `else
    initial
    begin
      clk = 1'b0;
      forever 
      begin
        #(period_lo);
          clk = 1'b1;
        #(period_hi) 
          clk = 1'b0;
      end
    end
  `endif


endmodule

  
