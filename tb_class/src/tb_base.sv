// --------------------------------------------------------------------
//
// --------------------------------------------------------------------

`timescale 1ps/1ps


module
  tb_base
  #(
    parameter PERIOD = 0,
    parameter ASSERT_TIME = 0
  )
  (
    output      clock,
    output reg  reset
  );

  // --------------------------------------------------------------------
  //
  task assert_reset
  (
    input time reset_assert
  );
  
    reset = 1;
    $display( "-#- %16.t | %m | reset asserted!", $time );
    
    #reset_assert;
    
    reset = 0;
    $display( "-#- %16.t | %m | reset deasserted!", $time );
  
endtask


  // --------------------------------------------------------------------
  //
  tb_clk_class tb_clk_c;
  tb_clk_if tb_clk_driver();
  assign clock = tb_clk_driver.clk;
  time reset_assert = (PERIOD * 5) + (PERIOD / 3);
  logic init_done = 0;
  
  initial
    begin
    
      reset = 1;
      
      tb_clk_c = new( tb_clk_driver );
      
      if( PERIOD != 0 )
        tb_clk_c.init_basic_clock( PERIOD );
  
      if( ASSERT_TIME != 0 )
        assert_reset( ASSERT_TIME );
      else if( reset_assert != 0 )
        assert_reset( reset_assert );
        
      init_done = 1;
      
    end
endmodule
      
  
  