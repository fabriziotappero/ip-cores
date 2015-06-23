//////////////////////////////////////////////////////////////////
//                                                              //
//  Wrapper for Xilinx Spartan-6 RAM Block                      //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  256 words x 32 bits with a write enable per byte            //
//                                                              //
//  Author(s):                                                  //
//      - Conor Santifort, csantifort.amber@gmail.com           //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2010 Authors and OPENCORES.ORG                 //
//                                                              //
// This source file may be used and distributed without         //
// restriction provided that this copyright statement is not    //
// removed from the file and that any derivative work contains  //
// the original copyright notice and the associated disclaimer. //
//                                                              //
// This source file is free software; you can redistribute it   //
// and/or modify it under the terms of the GNU Lesser General   //
// Public License as published by the Free Software Foundation; //
// either version 2.1 of the License, or (at your option) any   //
// later version.                                               //
//                                                              //
// This source is distributed in the hope that it will be       //
// useful, but WITHOUT ANY WARRANTY; without even the implied   //
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //
// PURPOSE.  See the GNU Lesser General Public License for more //
// details.                                                     //
//                                                              //
// You should have received a copy of the GNU Lesser General    //
// Public License along with this source; if not, download it   //
// from http://www.opencores.org/lgpl.shtml                     //
//                                                              //
//////////////////////////////////////////////////////////////////


module xs6_sram_256x32_byte_en
#(
parameter DATA_WIDTH    = 32,
parameter ADDRESS_WIDTH = 8
)

(
input                           i_clk,
input      [DATA_WIDTH-1:0]     i_write_data,
input                           i_write_enable,
input      [ADDRESS_WIDTH-1:0]  i_address,
input      [3:0]                i_byte_enable,
output     [DATA_WIDTH-1:0]     o_read_data
);                                                     


wire [2:0] nc31, nc32, nc33;
wire [1:0] nc22;
wire [3:0]  wea;
assign wea = {4{i_write_enable}} & i_byte_enable;

 
RAMB8BWER #(
    .DATA_WIDTH_A        ( 36                   ),
    .DATA_WIDTH_B        ( 36                   ),
    .RAM_MODE            ( "SDP"                ),
    .SIM_COLLISION_CHECK ( "GENERATE_X_ONLY"    ),
    .WRITE_MODE_A        ( "READ_FIRST"         ),
    .WRITE_MODE_B        ( "READ_FIRST"         )
 ) 
u_ramb8bwer (
    .CLKAWRCLK           ( i_clk                  ),  
    .CLKBRDCLK           ( i_clk                  ),
    .ADDRAWRADDR         ( {i_address, 5'd0}      ),
    .ADDRBRDADDR         ( {i_address, 5'd0}      ),
    .ENAWREN             ( i_write_enable         ),  
    .ENBRDEN             ( ~i_write_enable        ),
    .WEAWEL              ( wea[1:0]               ),  
    .WEBWEU              ( wea[3:2]               ),
    .DIADI               ( i_write_data[15:0]     ), 
    .DOADO               ( o_read_data [15:0]     ),
    .DIBDI               ( i_write_data[31:16]    ),
    .DOBDO               ( o_read_data [31:16]    ),

    // These guys are not used, so they are just tied off
    // ----------------------------------------------------
    .DIPBDIP        (2'd0),
    .DIPADIP        (2'd0),        
    .DOPADOP        (),
    .DOPBDOP        (),
  
    .REGCEA         (1'd0),
    .REGCEBREGCE    (1'd0),
    .RSTA           (1'd0),
    .RSTBRST        (1'd0)
);


//synopsys translate_off
initial
    begin
    if ( DATA_WIDTH    != 32  ) 
        $display("%M (xx_sram_256x32_byte_en) Warning: Incorrect parameter DATA_WIDTH");
    if ( ADDRESS_WIDTH != 8   ) 
        $display("%M (xx_sram_256x32_byte_en) Warning: Incorrect parameter ADDRESS_WIDTH");
    end
//synopsys translate_on

endmodule


