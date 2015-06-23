//****************************************************************************************************
// RAM
// Version 0.2
// Modified 17.06.2007
// Designed by Ruslan Lepetenok
//**************************************************************************************************

`timescale 1 ns / 1 ns

module snc_ram(
   clk,
   en,
   we,
   adr,
   din,
   dout
);

`include "tech_def_pack.vh"

   parameter                 tech       = 0;
   parameter                 adr_width  = 10;
   parameter                 data_width = 8;
   
   input                     clk;
   input                     en;
   input                     we;
   input [(adr_width-1):0]   adr;
   input [(data_width-1):0]  din;
   output [(data_width-1):0] dout;
   
   
   // !!!TBD!!!	
   generate
      if (tech == c_tech_virtex)
      begin : x_virtex_sncram
         
         xcv_snc_ram #(.adr_width(adr_width), .data_width(data_width)) xcv_snc_ram_inst(
            .clk(clk),
            .en(en),
            .we(we),
            .adr(adr),
            .din(din),
            .dout(dout)
         );
      end // x_virtex_sncram

      if (tech == c_tech_virtex_ii | tech == c_tech_virtex_4 | tech == c_tech_spartan_3)
      begin : x_virtex24spartan3_sncram
         
         xcv24s3_snc_ram #(.adr_width(adr_width), .data_width(data_width)) xcv24s3_snc_ram_inst(
            .clk(clk),
            .en(en),
            .we(we),
            .adr(adr),
            .din(din),
            .dout(dout)
         );
      end // x_virtex24spartan3_sncram

      // Altera
      if (tech == c_tech_acex) /* TBD ???*/
      begin : altera_sncram
         
         altera_snc_ram #(.adr_width(adr_width), .data_width(data_width)) altera_snc_ram_inst(
            .clk  (clk),
            .en   (en),
            .we   (we),
            .adr  (adr),
            .din  (din),
            .dout (dout)
         );
      end // altera_sncram




   endgenerate
   
endmodule
