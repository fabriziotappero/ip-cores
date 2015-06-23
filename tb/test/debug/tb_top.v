//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

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
      
      // 8 bit if    
      $display("\n^^^- testing 8 bit interface\n");
      
      dut.wbm.wb_cmp(0, 0, 32'h6000_0000, 32'h3322_1100);
      dut.wbm.wb_cmp(0, 0, 32'h6000_0004, 32'h7766_5544);
      dut.wbm.wb_cmp(0, 0, 32'h6000_0008, 32'hbbaa_9988);
      dut.wbm.wb_cmp(0, 0, 32'h6000_000c, 32'hffee_ddcc);
      
      dut.wbm.wb_write(0, 0, 32'h6000_0010, 32'habba_beef);
      dut.wbm.wb_write(0, 0, 32'h6000_0014, 32'h1a2b_3c4d); 
      dut.wbm.wb_write(0, 0, 32'h6000_0018, 32'hcafe_1a7e);
      dut.wbm.wb_write(0, 0, 32'h6000_001c, 32'h5a5a_0f0f); 
      
      dut.wbm.wb_cmp(0, 0, 32'h6000_0010, 32'habba_beef);
      dut.wbm.wb_cmp(0, 0, 32'h6000_0014, 32'h1a2b_3c4d); 
      dut.wbm.wb_cmp(0, 0, 32'h6000_0018, 32'hcafe_1a7e);
      dut.wbm.wb_cmp(0, 0, 32'h6000_001c, 32'h5a5a_0f0f); 
      
      dut.wbm.wb_write_sel(0, 0, 4'b0001, 32'h6000_0010, 32'hxxxx_xx00);
      dut.wbm.wb_write_sel(0, 0, 4'b0010, 32'h6000_0014, 32'hxxxx_11xx);
      dut.wbm.wb_write_sel(0, 0, 4'b0100, 32'h6000_0018, 32'hxx22_xxxx);
      dut.wbm.wb_write_sel(0, 0, 4'b1000, 32'h6000_001c, 32'h33xx_xxxx);
      
      dut.wbm.wb_cmp_sel(0, 0, 4'b0001, 32'h6000_0010, 32'hxxxx_xx00);
      dut.wbm.wb_cmp_sel(0, 0, 4'b0010, 32'h6000_0014, 32'hxxxx_11xx);
      dut.wbm.wb_cmp_sel(0, 0, 4'b0100, 32'h6000_0018, 32'hxx22_xxxx);
      dut.wbm.wb_cmp_sel(0, 0, 4'b1000, 32'h6000_001c, 32'h33xx_xxxx);
      
      dut.wbm.wb_write_sel(0, 0, 4'b0011, 32'h6000_0000, 32'hxxxx_0ab1);
      dut.wbm.wb_write_sel(0, 0, 4'b1100, 32'h6000_0004, 32'h2cd3_xxxx);
      dut.wbm.wb_write_sel(0, 0, 4'b0011, 32'h6000_0008, 32'hxxxx_4ef5);
      dut.wbm.wb_write_sel(0, 0, 4'b1100, 32'h6000_000c, 32'h0f0f_xxxx);
      
      dut.wbm.wb_cmp_sel(0, 0, 4'b0011, 32'h6000_0000, 32'hxxxx_0ab1);
      dut.wbm.wb_cmp_sel(0, 0, 4'b1100, 32'h6000_0004, 32'h2cd3_xxxx);
      dut.wbm.wb_cmp_sel(0, 0, 4'b0011, 32'h6000_0008, 32'hxxxx_4ef5);
      dut.wbm.wb_cmp_sel(0, 0, 4'b1100, 32'h6000_000c, 32'h0f0f_xxxx);
      
      // 16 bit if
      $display("\n^^^- testing 16 bit interface\n");
      
      dut.wbm.wb_cmp(0, 0, 32'ha000_0000, 32'h3322_1100);
      dut.wbm.wb_cmp(0, 0, 32'ha000_0004, 32'h7766_5544);
      dut.wbm.wb_cmp(0, 0, 32'ha000_0008, 32'hbbaa_9988);
      dut.wbm.wb_cmp(0, 0, 32'ha000_000c, 32'hffee_ddcc);
      
      dut.wbm.wb_write(0, 0, 32'ha000_0010, 32'habba_beef);
      dut.wbm.wb_write(0, 0, 32'ha000_0014, 32'h1a2b_3c4d); 
      dut.wbm.wb_write(0, 0, 32'ha000_0018, 32'hcafe_1a7e);
      dut.wbm.wb_write(0, 0, 32'ha000_001c, 32'h5a5a_0f0f); 
      
      dut.wbm.wb_cmp(0, 0, 32'ha000_0010, 32'habba_beef);
      dut.wbm.wb_cmp(0, 0, 32'ha000_0014, 32'h1a2b_3c4d); 
      dut.wbm.wb_cmp(0, 0, 32'ha000_0018, 32'hcafe_1a7e);
      dut.wbm.wb_cmp(0, 0, 32'ha000_001c, 32'h5a5a_0f0f); 
            
      dut.wbm.wb_write_sel(0, 0, 4'b0011, 32'ha000_0000, 32'hxxxx_0ab1);
      dut.wbm.wb_write_sel(0, 0, 4'b1100, 32'ha000_0004, 32'h2cd3_xxxx);
      dut.wbm.wb_write_sel(0, 0, 4'b0011, 32'ha000_0008, 32'hxxxx_4ef5);
      dut.wbm.wb_write_sel(0, 0, 4'b1100, 32'ha000_000c, 32'h0f0f_xxxx);
      
      dut.wbm.wb_cmp_sel(0, 0, 4'b0011, 32'ha000_0000, 32'hxxxx_0ab1);
      dut.wbm.wb_cmp_sel(0, 0, 4'b1100, 32'ha000_0004, 32'h2cd3_xxxx);
      dut.wbm.wb_cmp_sel(0, 0, 4'b0011, 32'ha000_0008, 32'hxxxx_4ef5);
      dut.wbm.wb_cmp_sel(0, 0, 4'b1100, 32'ha000_000c, 32'h0f0f_xxxx);
      
      dut.wbm.wb_write_sel(0, 0, 4'b0001, 32'h0000_0010, 32'hxxxx_xx00);
      dut.wbm.wb_write_sel(0, 0, 4'b0010, 32'h0000_0014, 32'hxxxx_11xx);
      dut.wbm.wb_write_sel(0, 0, 4'b0100, 32'h0000_0018, 32'hxx22_xxxx);
      dut.wbm.wb_write_sel(0, 0, 4'b1000, 32'h0000_001c, 32'h33xx_xxxx);
      
      dut.wbm.wb_cmp_sel(0, 0, 4'b0001, 32'h0000_0010, 32'hxxxx_xx00);
      dut.wbm.wb_cmp_sel(0, 0, 4'b0010, 32'h0000_0014, 32'hxxxx_11xx);
      dut.wbm.wb_cmp_sel(0, 0, 4'b0100, 32'h0000_0018, 32'hxx22_xxxx);
      dut.wbm.wb_cmp_sel(0, 0, 4'b1000, 32'h0000_001c, 32'h33xx_xxxx);
      
      // do illegal byte boundary access
      $display("\n^^^- testing illegal byte boundary access\n");
      dut.wbm.wb_write_sel(0, 0, 4'b0110, 32'ha000_0020, 32'hxxba_adxx);
      
      repeat(2) @(posedge tb_clk); 
      
      $display("\n^^^---------------------------------\n");
      $display("^^^- Testbench done. %t.\n", $time);
      
      $stop();
    
    end
  
endmodule

