//**********************************************************************************************
// RAM data register for the AVR Core
// Version 0.4
// Modified 09.01.2007
// Designed by Ruslan Lepetenok
//**********************************************************************************************

`timescale 1 ns / 1 ns

module ram_data_rg(ireset, cp2, cpuwait, data_in, data_out);
   // Clock and Reset 
   input        ireset;
   input        cp2;
   // Data and Control
   input        cpuwait;
   input [7:0]  data_in;
   output [7:0] data_out;
   
   reg  [7:0]    data_rg_current;
   wire [7:0]    data_rg_next;
   
   assign data_rg_next = (cpuwait) ? data_rg_current : data_in;  
   
   
   always @(posedge cp2 or negedge ireset)
   begin: data_reg_seq_prc
      if (!ireset)		// Reset
         data_rg_current <= {8{1'b0}};
      else 		// Clock
         data_rg_current <= data_rg_next;
   end
   
   assign data_out = data_rg_current;
   
endmodule // ram_data_rg
