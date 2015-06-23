//-----------------------------------------------------------------
//                           AltOR32 
//                Alternative Lightweight OpenRisc 
//                            V2.0
//                     Ultra-Embedded.com
//                   Copyright 2011 - 2013
//
//               Email: admin@ultra-embedded.com
//
//                       License: LGPL
//-----------------------------------------------------------------
//
// Copyright (C) 2011 - 2013 Ultra-Embedded.com
//
// This source file may be used and distributed without         
// restriction provided that this copyright statement is not    
// removed from the file and that any derivative work contains  
// the original copyright notice and the associated disclaimer. 
//
// This source file is free software; you can redistribute it   
// and/or modify it under the terms of the GNU Lesser General   
// Public License as published by the Free Software Foundation; 
// either version 2.1 of the License, or (at your option) any   
// later version.
//
// This source is distributed in the hope that it will be       
// useful, but WITHOUT ANY WARRANTY; without even the implied   
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
// PURPOSE.  See the GNU Lesser General Public License for more 
// details.
//
// You should have received a copy of the GNU Lesser General    
// Public License along with this source; if not, write to the 
// Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
// Boston, MA  02111-1307  USA
//-----------------------------------------------------------------

//-----------------------------------------------------------------
// Module: ram - dual port block RAM
//-----------------------------------------------------------------
module ram
(
    // Port A
    input clka_i /*verilator public*/,
    input rsta_i /*verilator public*/,
    input stba_i /*verilator public*/,
    input wea_i /*verilator public*/,
    input [3:0] sela_i /*verilator public*/,
    input [31:2] addra_i /*verilator public*/,
    input [31:0] dataa_i /*verilator public*/,
    output [31:0] dataa_o /*verilator public*/,
    output reg acka_o /*verilator public*/,

    // Port B
    input clkb_i /*verilator public*/,
    input rstb_i /*verilator public*/,
    input stbb_i /*verilator public*/,
    input web_i /*verilator public*/,
    input [3:0] selb_i /*verilator public*/,
    input [31:2] addrb_i /*verilator public*/,
    input [31:0] datab_i /*verilator public*/,
    output [31:0] datab_o /*verilator public*/,
    output reg ackb_o /*verilator public*/
);

//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
parameter  [31:0]       block_count  = 6;
parameter  [31:0]       SIZE         = 14;

//-----------------------------------------------------------------
// Instantiation
//-----------------------------------------------------------------

wire [3:0] wr_a = {4{stba_i}} & {4{wea_i}} & sela_i;
wire [3:0] wr_b = {4{stbb_i}} & {4{web_i}} & selb_i;

ram_dp8  
#(
    .WIDTH(8),
    .SIZE(SIZE)
) 
u0
(
    .aclk_i(clka_i), 
    .aadr_i(addra_i[SIZE+2-1:2]), 
    .adat_o(dataa_o[7:0]), 
    .adat_i(dataa_i[7:0]),
    .awr_i(wr_a[0]),
    
    .bclk_i(clkb_i), 
    .badr_i(addrb_i[SIZE+2-1:2]), 
    .bdat_o(datab_o[7:0]), 
    .bdat_i(datab_i[7:0]),
    .bwr_i(wr_b[0])
);

ram_dp8  
#(
    .WIDTH(8),
    .SIZE(SIZE)
) 
u1
(
    .aclk_i(clka_i), 
    .aadr_i(addra_i[SIZE+2-1:2]), 
    .adat_o(dataa_o[15:8]), 
    .adat_i(dataa_i[15:8]),
    .awr_i(wr_a[1]),
    
    .bclk_i(clkb_i), 
    .badr_i(addrb_i[SIZE+2-1:2]), 
    .bdat_o(datab_o[15:8]), 
    .bdat_i(datab_i[15:8]),
    .bwr_i(wr_b[1])
);

ram_dp8  
#(
    .WIDTH(8),
    .SIZE(SIZE)
) 
u2
(
    .aclk_i(clka_i), 
    .aadr_i(addra_i[SIZE+2-1:2]), 
    .adat_o(dataa_o[23:16]), 
    .adat_i(dataa_i[23:16]),
    .awr_i(wr_a[2]),
    
    .bclk_i(clkb_i), 
    .badr_i(addrb_i[SIZE+2-1:2]), 
    .bdat_o(datab_o[23:16]), 
    .bdat_i(datab_i[23:16]),
    .bwr_i(wr_b[2])
);

ram_dp8  
#(
    .WIDTH(8),
    .SIZE(SIZE)
) 
u3
(
    .aclk_i(clka_i), 
    .aadr_i(addra_i[SIZE+2-1:2]), 
    .adat_o(dataa_o[31:24]), 
    .adat_i(dataa_i[31:24]),
    .awr_i(wr_a[3]),
    
    .bclk_i(clkb_i), 
    .badr_i(addrb_i[SIZE+2-1:2]), 
    .bdat_o(datab_o[31:24]), 
    .bdat_i(datab_i[31:24]),
    .bwr_i(wr_b[3])    
);

// AckA
always @(posedge clka_i or posedge rsta_i) 
begin
    if (rsta_i == 1'b1) 
    begin
        acka_o  <= 1'b0;
    end 
    else 
    begin
        acka_o  <= stba_i;
    end
end

// AckB
always @(posedge clkb_i or posedge rstb_i) 
begin
    if (rstb_i == 1'b1) 
    begin
        ackb_o  <= 1'b0;
    end 
    else 
    begin
        ackb_o  <= stbb_i;
    end
end

endmodule
