// --------------------------------------------------------------------
//
// --------------------------------------------------------------------


module
  tb_clk
  #(
    parameter PERIOD = 0
  )
  (
    output clock
  );
  
  tb_clk_class tb_clk_c;
  tb_clk_if tb_clk_driver();
  assign clock = tb_clk_driver.clk;
  
  initial
    begin
    
    tb_clk_c = new( tb_clk_driver );
    
    if( PERIOD != 0 )
      tb_clk_c.init_basic_clock( PERIOD );
      
    end
    
endmodule
      
  
  