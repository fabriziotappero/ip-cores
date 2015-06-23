// --------------------------------------------------------------------
//
// --------------------------------------------------------------------

`timescale 1ns/10ps


module 
  tb_reset  
  #(
    parameter ASSERT_TIME = 32
  ) 
  (
    output        rst_out
  );
  
  reg tb_rst;

  initial 
      tb_rst <= 1'b1;

  task assert_reset;
    begin
    
    tb_rst = 1'b1;
    #ASSERT_TIME;
    tb_rst = 1'b0;

    $display( "-#- %15.t | %m: tb_rst asserted!", $time );
      
    end
  endtask  
  
  assign rst_out = tb_rst;

endmodule

