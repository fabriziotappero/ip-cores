// --------------------------------------------------------------------
//
// --------------------------------------------------------------------

`timescale 1ns/10ps


module 
  tb_clk  
  #(
    parameter CLK_PERIOD = 32
  ) 
  (
    output        clk_out
  );
    
  reg tb_clk;

  initial 
      tb_clk <= 1'b1;      

  always
    #(CLK_PERIOD/2) tb_clk <= ~tb_clk;
    
  assign clk_out = tb_clk;

endmodule

