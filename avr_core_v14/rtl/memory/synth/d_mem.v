//************************************************************************************************
// DM RAM for AVR Core
// Version 0.1
// Modified 18.06.2007
// Designed by Ruslan Lepetenok
// cpuwait,ireset was removed 
//************************************************************************************************

`timescale 1 ns / 1 ns

module d_mem(
   cp2,
   cp2n,
   ce,
   address,
   din,
   dout,
   we
);

`include "tech_def_pack.vh"

   parameter              tech = 0;
   parameter              dm_size = 1;		// DM size 1..64 K
   parameter              read_ws = 1;
   
   input                  cp2;
   input                  cp2n;
   input                  ce;
   input [15:0]           address;
   input [7:0]            din;
   output [7:0]           dout;
   input                  we;
   
   localparam             c_adr_width = (dm_size < 2)    ? 0 + 10 :
                                        (dm_size < 4)    ? 1 + 10 :  
                                        (dm_size < 8)    ? 2 + 10 :  
                                        (dm_size < 16)   ? 3 + 10 :  
                                        (dm_size < 32)   ? 4 + 10 :  
                                        (dm_size < 64)   ? 5 + 10 :  
                                        (dm_size == 64)  ? 6 + 10 : 0;  

   
   wire [c_adr_width-1:0] addr_tmp;
   wire [7:0]             mem_o_tmp;
   wire                   wait_st;
   wire                   gnd;
   wire                   vcc;
   
   wire                   cp2_tmp;
      
   assign gnd = 1'b0;
   assign vcc = 1'b1;
   assign addr_tmp = address[c_adr_width-1:0];
   
   
   assign cp2_tmp = (read_ws) ? cp2 : cp2n;
   
         
         generate
            if ((tech == c_tech_virtex & c_adr_width <= 12) | tech != c_tech_virtex)
            begin : normal_mem
               
               snc_ram #(.tech(tech), .adr_width(c_adr_width), .data_width(8)) snc_ram_inst(
                  .clk  (cp2_tmp),
                  .en   (vcc),
                  .we   (we),
                  .adr  (addr_tmp),
                  .din  (din),
                  .dout (dout)
               );
            end // normal_mem

            if (tech == c_tech_virtex & c_adr_width > 12)
            begin : large_virtex_mem
               
               snc_ram_int #(.tech(tech), .adr_width(c_adr_width), .data_width(8)) snc_ram_int_inst(
                  .clk  (cp2_tmp),
                  .en   (vcc),
                  .we   (we),
                  .adr  (addr_tmp),
                  .din  (din),
                  .dout (dout)
               );
            end // large_virtex_mem
         endgenerate
         
endmodule
											
