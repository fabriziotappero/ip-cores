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


module wb_slave_model(  clk_i, rst_i, dat_o, dat_i, adr_i,
                        cyc_i, stb_i, we_i, sel_i,
                        ack_o, err_o, rty_o );

  parameter DWIDTH    = 8;
  parameter AWIDTH    = 8;
  parameter ACK_DELAY = 2;
  parameter SLAVE_RAM_INIT = "wb_slave_model.txt";
  
  input                         clk_i;
  input                         rst_i;
  output [DWIDTH-1:0]           dat_o;
  input  [DWIDTH-1:0]           dat_i;
  input  [AWIDTH-1:0]           adr_i;
  input                         cyc_i;
  input                         stb_i;
  input                         we_i;
  input  [( (DWIDTH/8) - 1 ):0] sel_i;
  output                        ack_o;
  output                        err_o;
  output                        rty_o;
  
  
  
  
  
  // --------------------------------------------------------------------
  //  slave ram
  reg [7:0] ram[2**AWIDTH-1:0];
  
  initial
    $readmemh( SLAVE_RAM_INIT, ram );

  // --------------------------------------------------------------------
  //  
  generate
    case( DWIDTH )
      8:        begin
                  initial 
                    $display( "###- wb_slave_model(): WISHBONE 8 BIT SLAVE MODEL INSTANTIATED " );
                    
                  always @ (posedge clk_i)
                    if (we_i & cyc_i & stb_i & sel_i[0]) 
                      ram[adr_i] <= dat_i[7:0];
                  
                  assign dat_o = ram[adr_i];
                  
                end
                
      16:       begin
                  initial 
                    $display( "###- wb_slave_model(): WISHBONE 16 BIT SLAVE MODEL INSTANTIATED " );
                    
                  always @ (posedge clk_i)
                    if (we_i & cyc_i & stb_i & sel_i[0]) 
                      ram[{adr_i[AWIDTH-1:1], 1'b0}] <= dat_i[7:0];
                      
                  always @ (posedge clk_i)
                    if (we_i & cyc_i & stb_i & sel_i[1]) 
                      ram[{adr_i[AWIDTH-1:1], 1'b1}] <= dat_i[15:8];
                      
                  assign dat_o = { ram[{adr_i[AWIDTH-1:1], 1'b1}], ram[{adr_i[AWIDTH-1:1], 1'b0}] };
                  
                end
                
      32:       begin
                  initial 
                    $display( "###- wb_slave_model(): WISHBONE 32 BIT SLAVE MODEL INSTANTIATED " );
                    
                  always @ (posedge clk_i)
                    if (we_i & cyc_i & stb_i & sel_i[0]) 
                      ram[{adr_i[AWIDTH-1:2], 2'b00}] <= dat_i[7:0];
                      
                  always @ (posedge clk_i)
                    if (we_i & cyc_i & stb_i & sel_i[1]) 
                      ram[{adr_i[AWIDTH-1:2], 2'b01}] <= dat_i[15:8];
                      
                  always @ (posedge clk_i)
                    if (we_i & cyc_i & stb_i & sel_i[2]) 
                      ram[{adr_i[AWIDTH-1:2], 2'b10}] <= dat_i[23:16];
                      
                  always @ (posedge clk_i)
                    if (we_i & cyc_i & stb_i & sel_i[3]) 
                      ram[{adr_i[AWIDTH-1:2], 2'b11}] <= dat_i[31:24];
                      
                  assign dat_o = { ram[{adr_i[AWIDTH-1:2], 2'b11}], ram[{adr_i[AWIDTH-1:2], 2'b10}], ram[{adr_i[AWIDTH-1:2], 2'b01}], ram[{adr_i[AWIDTH-1:2], 2'b00}] };
                    
                end
                
      default:  begin
                  localparam SLAVE_SIZE = -1;
                  initial 
                    begin
                      $display( "!!!- wb_slave_model(): invalad DWIDTH parameter" );
                      $stop();
                    end
                end
    endcase
  endgenerate

        
  // --------------------------------------------------------------------
  //  ack delay
  reg ack_delayed;
  
  initial
    ack_delayed = 1'b0;
  
  always @(posedge clk_i or cyc_i or stb_i)
    begin
      if(cyc_i & stb_i)
        begin
          ack_delayed = 1'b0;
          repeat(ACK_DELAY) @(posedge clk_i);
          if(cyc_i & stb_i)
            ack_delayed = 1'b1;
          else
            ack_delayed = 1'b0;
        end
      else
        ack_delayed = 1'b0;
    end
    
  // --------------------------------------------------------------------
  //  assign outputs  
  assign ack_o = ack_delayed;
  assign err_o = 1'b0;
  assign rty_o = 1'b0;
  

endmodule