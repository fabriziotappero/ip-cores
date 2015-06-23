`timescale 1 ns / 1 ns

//**********************************************************************************************
// SPI Peripheral for the AVR Core
// Version 1.2
// Modified 10.01.2007
// Designed by Ruslan Lepetenok
//**********************************************************************************************

module spi_slv_sel(
   ireset,
   cp2,
   adr,
   dbus_in,
   dbus_out,
   iore,
   iowe,
   out_en,
   slv_sel_n
);

`include "avr_adr_pack.vh"

   parameter                num_of_slvs = 7;
   // AVR Control
   input                    ireset;
   input                    cp2;
   input [5:0]              adr;
   input [7:0]              dbus_in;
   output [7:0]             dbus_out;
   input                    iore;
   input                    iowe;
   output                   out_en;
   // Output
   output [num_of_slvs-1:0] slv_sel_n;
   
   parameter                SPISlvDcd_Address = PINF_Address; // TBD -> localparam
   
   reg [num_of_slvs-1:0]    SlvSelRg_Current;
   reg [num_of_slvs-1:0]    SlvSelRg_Next;
   
   
   always @(negedge ireset or posedge cp2)
   begin: RegWrSeqPrc
      if (ireset == 1'b0)		// Reset	
         SlvSelRg_Current <= {num_of_slvs{1'b0}};
      else 		// Clock
         SlvSelRg_Current <= SlvSelRg_Next;
   end
   
   
   always @(adr or iowe or dbus_in or SlvSelRg_Current)
   begin: RegWrComb
      SlvSelRg_Next <= SlvSelRg_Current;
      if (adr == SPISlvDcd_Address & iowe == 1'b1)
         SlvSelRg_Next <= dbus_in[num_of_slvs - 1:0];
   end
   
   assign slv_sel_n = (~SlvSelRg_Current[num_of_slvs-1:0]);
   
   assign out_en = (adr == SPISlvDcd_Address & iore == 1'b1) ? 1'b1 : 
                   1'b0;
   
   assign dbus_out[num_of_slvs - 1:0] = SlvSelRg_Current;
   
   generate
      if (num_of_slvs < 8)
      begin : UnusedBits
         assign dbus_out[7:num_of_slvs] = {8{1'b0}};
      end
   endgenerate
   
endmodule

