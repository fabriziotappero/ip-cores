//************************************************************************************************
// PM RAM for AVR Core
// Version 0.2
// Designed by Ruslan Lepetenok 
// Modified 18.06.2007
//************************************************************************************************

`timescale 1 ns / 1 ns

module p_mem(
   clk,
   ce,
   address,
   din,
   dout,
   weh,
   wel
);

`include "tech_def_pack.vh"

   parameter              tech = 0;
   parameter              pm_size = 1;		// PM size 1..64 KWords
   input                  clk;
   input                  ce;
   input [15:0]           address;
   input [15:0]           din;
   output [15:0]          dout;
   input                  weh;
   input                  wel;
   
   parameter              c_adr_width = (pm_size < 2)    ? 0 + 10 :
                                        (pm_size < 4)    ? 1 + 10 :  
                                        (pm_size < 8)    ? 2 + 10 :  
                                        (pm_size < 16)   ? 3 + 10 :  
                                        (pm_size < 32)   ? 4 + 10 :  
                                        (pm_size < 64)   ? 5 + 10 :  
                                        (pm_size < 128)  ? 6 + 10 :  
                                        (pm_size == 128) ? 7 + 10 : 0;
   
   
   wire [c_adr_width-1:0] addr_tmp;
   wire                   gnd;
   wire                   vcc;
   
   assign gnd = 1'b0;
   assign vcc = 1'b1;
   
   assign addr_tmp = address[c_adr_width-1:0];
   
   generate
      if ((tech == c_tech_virtex && c_adr_width <= 12) | tech != c_tech_virtex)
      begin : normal_mem
         
         snc_ram #(.tech(tech), .adr_width(c_adr_width), .data_width(8)) snc_ram_low_inst(
            .clk(clk),
            .en(ce),
            .we(wel),
            .adr(addr_tmp),
            .din(din[7:0]),
            .dout(dout[7:0])
         );
         
         
         snc_ram #(.tech(tech), .adr_width(c_adr_width), .data_width(8)) snc_ram_high_inst(
            .clk(clk),
            .en(ce),
            .we(weh),
            .adr(addr_tmp),
            .din(din[15:8]),
            .dout(dout[15:8])
         );
      end  // normal_mem

      if (tech == c_tech_virtex && c_adr_width > 12)
      begin : large_virtex_mem
         
         snc_ram_int #(.tech(tech), .adr_width(c_adr_width), .data_width(8)) snc_ram_int_low_inst(
            .clk(clk),
            .en(ce),
            .we(wel),
            .adr(addr_tmp),
            .din(din[7:0]),
            .dout(dout[7:0])
         );
         
         
         snc_ram_int #(.tech(tech), .adr_width(c_adr_width), .data_width(8)) snc_ram_int_high_inst(
            .clk(clk),
            .en(ce),
            .we(weh),
            .adr(addr_tmp),
            .din(din[15:8]),
            .dout(dout[15:8])
         );
      end   // large_virtex_mem
   endgenerate
   
endmodule
											


