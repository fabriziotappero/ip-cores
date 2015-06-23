// --------------------------------------------------------------------
//
// --------------------------------------------------------------------

`timescale 10ps/1ps


module 
  tb_reset  
  #(
    parameter ASSERT_TIME = 32
  ) 
  (
    output reg reset
  );
  
// --------------------------------------------------------------------
//
  initial 
    reset <= 1'b1;

// --------------------------------------------------------------------
//
  task assert_reset;
    begin
    
    reset = 1'b1;
    $display( "-#- %16.t | %m: reset asserted!", $time );
    #ASSERT_TIME;
    
    $display( "-#- %16.t | %m: reset deasserted!", $time );
    reset = 1'b0;
      
    end
  endtask  
  
  
// --------------------------------------------------------------------
//
  task assert_delayed_reset;
  input integer delay;
    begin
    
    #delay;
    
    reset = 1'b1;
    $display( "-#- %16.t | %m: reset asserted!", $time );
    #ASSERT_TIME;
    
    $display( "-#- %16.t | %m: reset deasserted!", $time );
    reset = 1'b0;
      
    end
  endtask  
  
  
// --------------------------------------------------------------------
//

  
endmodule

