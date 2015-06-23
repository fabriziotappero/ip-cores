// --------------------------------------------------------------------
//
// --------------------------------------------------------------------

`timescale 1ns/10ps


module the_test(
                input tb_clk,
                input tb_rst
              );

  reg [31:0] d_out;

  task run_the_test;
    begin
    
// --------------------------------------------------------------------
// insert test below
// --------------------------------------------------------------------

      repeat(6) @(posedge tb_clk); 
      
//       wbm.wb_write(0, 0, 32'h6000_0004, 32'habba_beef);
//       wbm.wb_write(0, 0, 32'h6000_0000, 32'h0000_0001); 
//       wbm.wb_write(0, 0, 32'h6000_0000, 32'h0000_0000); 
//       repeat(2) @(posedge tb_clk); 
//       
//       wbm.wb_write(0, 0, 32'h6000_0004, 32'hcafe_1a7a);
//       wbm.wb_write(0, 0, 32'h6000_0000, 32'h0000_0001); 
//       wbm.wb_write(0, 0, 32'h6000_0000, 32'h0000_0000); 
//       repeat(2) @(posedge tb_clk); 
//       
//       wbm.wb_write(0, 0, 32'h6000_0004, 32'h3333_3333);
//       wbm.wb_write(0, 0, 32'h6000_0000, 32'h0000_0001); 
//       wbm.wb_write(0, 0, 32'h6000_0000, 32'h0000_0000); 
//       repeat(2) @(posedge tb_clk); 
//       
//       
//       wbm.wb_write(0, 0, 32'h6000_0004, 32'hffff_ffff);
//       wbm.wb_write(0, 0, 32'h6000_0000, 32'h0000_0001); 
//       wbm.wb_write(0, 0, 32'h6000_0000, 32'h0000_0000); 
//       repeat(2) @(posedge tb_clk); 

      wbm.wb_write(0, 0, 32'h6000_0010, 32'h8001_0000);
      repeat(2) @(posedge tb_clk); 
      
      // enable i2s
      repeat(2) @(posedge tb_clk); 
      rx_bfm.enable_bfm();
      
      repeat(2) @(posedge tb_clk); 
      wbm.wb_write(0, 0, 32'h6000_0000, 32'h0000_0001); 

//       repeat(6*32) @(posedge tb_clk); 

      
      repeat('h72) @(posedge i_i2s_to_wb_top.i2s_ws_i); 
      
      
// --------------------------------------------------------------------
// insert test above
// --------------------------------------------------------------------

   end  
  endtask
      

endmodule

