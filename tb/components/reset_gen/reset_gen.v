module reset_gen (clk, reset, duration);

  input           clk       ;
  output          reset     ;
  input   [63:0]  duration  ;
  
  reg             reset     ;
  
  initial reset = 1'b0;
  
  always @(posedge clk)
  begin
    if ($time > duration)
      reset = 1'b1;
    else
      reset = 1'b0;
  end


endmodule
