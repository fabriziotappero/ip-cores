// --------------------------------------------------------------------
//
// --------------------------------------------------------------------

`timescale 1ns/10ps


module tb_top();

  parameter CLK_PERIOD = 10;

  reg tb_clk, tb_rst;

  initial 
    begin
      tb_clk <= 1'b1;      
      tb_rst <= 1'b1;
      
      #(CLK_PERIOD); #(CLK_PERIOD/3);
      tb_rst = 1'b0;
      
    end

  always
    #(CLK_PERIOD/2) tb_clk = ~tb_clk;
    
// --------------------------------------------------------------------
// tb_dut
  tb_dut dut( tb_clk, tb_rst );
  

// --------------------------------------------------------------------
// insert test below

  initial
    begin
    
      wait( ~tb_rst );
      
      repeat(2) @(posedge tb_clk);
      
      //     
      $display("\n^^^- \n");
      
      
      dut.async_mem.async_mem_write( 32'h83000000, 32'habbabeef, 4'b0000 );
      repeat(2) @(posedge tb_clk); 
      
      dut.async_mem.async_mem_cmp( 32'h83000000, 32'habbabeef, 4'b0000 );
      repeat(4) @(posedge tb_clk); 
      
      
      $display("\n^^^---------------------------------\n");
      $display("^^^- Testbench done. %t.\n", $time);
      
      $stop();
    
    end
  
endmodule

