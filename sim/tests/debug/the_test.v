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


module the_test(
                input tb_clk,
                input tb_rst
              );


  task run_the_test;
    begin
    
// --------------------------------------------------------------------
// insert test below

      dut.i2c.start();
      dut.i2c.write_byte( 8'hf1 );
      dut.i2c.read_byte(0);
      dut.i2c.read_byte(0);
      dut.i2c.read_byte(0);
      dut.i2c.read_byte(0);
      dut.i2c.read_byte(0);
      dut.i2c.read_byte(0);
      dut.i2c.read_byte(1);
      
      dut.i2c.start();
      dut.i2c.write_byte( 8'h10 );
      dut.i2c.write_byte( 8'hab );
      dut.i2c.write_byte( 8'hba );
      
      dut.i2c.start();
      dut.i2c.write_byte( 8'hf0 );
      dut.i2c.write_byte( 8'hbe );
      dut.i2c.write_byte( 8'hef );
      
      dut.i2c.start();
      dut.i2c.write_byte( 8'hcb );
      dut.i2c.read_byte(0);
      dut.i2c.read_byte(1);
      
      dut.i2c.start();
      dut.i2c.write_byte( 8'hf1 );
      dut.i2c.read_byte(0);
      dut.i2c.read_byte(1);
      
      dut.i2c.start();
      dut.i2c.write_byte( 8'hdb );
      dut.i2c.read_byte(0);
      dut.i2c.read_byte(1);
      dut.i2c.stop();
      
      
      repeat(100) @(posedge tb_clk); 
      
    end  
  endtask
      

endmodule

