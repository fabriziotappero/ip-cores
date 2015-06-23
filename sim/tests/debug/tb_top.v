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
      
      dut.i_bfm_ahb.bfm_ahb_read32( 32'h00000000, 1'b1, 32'h00000000 );
      dut.i_bfm_ahb.bfm_ahb_read32( 32'h00000004, 1'b1, 32'h11111111 );
      dut.i_bfm_ahb.bfm_ahb_read32( 32'h00000008, 1'b1, 32'h22222222 );
      dut.i_bfm_ahb.bfm_ahb_read32( 32'h0000000c, 1'b1, 32'h33333333 );
      dut.i_bfm_ahb.bfm_ahb_read32( 32'h00000010, 1'b1, 32'h44444444 );
      dut.i_bfm_ahb.bfm_ahb_read32( 32'h00000014, 1'b1, 32'h55555555 );
      dut.i_bfm_ahb.bfm_ahb_read32( 32'h00000018, 1'b1, 32'h66666666 );
      dut.i_bfm_ahb.bfm_ahb_read32( 32'h0000001c, 1'b1, 32'h77777777 );
      
      dut.i_bfm_ahb.bfm_ahb_write32( 32'h000000000, 32'habbabeef );
      dut.i_bfm_ahb.bfm_ahb_read32( 32'h00000000, 1'b1, 32'habbabeef );
      
      dut.i_bfm_ahb.bfm_ahb_write16( 32'h000000004, 16'habcd );
      dut.i_bfm_ahb.bfm_ahb_read16( 32'h00000004, 1'b1, 16'habcd );
      
      dut.i_bfm_ahb.bfm_ahb_write16( 32'h000000006, 16'h1234 );
      dut.i_bfm_ahb.bfm_ahb_read16( 32'h00000006, 1'b1, 16'h1234 );
      
      dut.i_bfm_ahb.bfm_ahb_read32( 32'h00000004, 1'b1, 32'h1234abcd );
      
      dut.i_bfm_ahb.bfm_ahb_write8( 32'h000000008, 8'ha1 );
      dut.i_bfm_ahb.bfm_ahb_read8( 32'h00000008, 1'b1, 8'ha1 );
      
      dut.i_bfm_ahb.bfm_ahb_write8( 32'h000000009, 8'hb2 );
      dut.i_bfm_ahb.bfm_ahb_read8( 32'h00000009, 1'b1, 8'hb2 );
      
      dut.i_bfm_ahb.bfm_ahb_write8( 32'h00000000a, 8'hc3 );
      dut.i_bfm_ahb.bfm_ahb_read8( 32'h0000000a, 1'b1, 8'hc3 );
      
      dut.i_bfm_ahb.bfm_ahb_write8( 32'h00000000b, 8'hd4 );
      dut.i_bfm_ahb.bfm_ahb_read8( 32'h0000000b, 1'b1, 8'hd4 );
      
      dut.i_bfm_ahb.bfm_ahb_read32( 32'h00000008, 1'b1, 32'hd4c3b2a1 );
      
      repeat(2) @(posedge tb_clk); 
      
      
      if( dut.i_bfm_ahb.read_error )
        $display("-!- Read mismatch. Testbench Failed. %t.\n", $time);
      
      $display("\n^^^---------------------------------\n");
      $display("^^^- Testbench done. %t.\n", $time);
      
      $stop();
    
    end
  
endmodule

