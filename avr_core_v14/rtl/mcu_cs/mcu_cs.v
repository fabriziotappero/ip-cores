//**********************************************************************************************
// MCU Control/Status register(s)
// Version 0.1
// Modified 10.01.2007
// Designed by Ruslan Lepetenok (lepetenokr@yahoo.com)
// Modified 09.06.12 (Verilog version)
//**********************************************************************************************

`timescale 1 ns / 1 ns

module mcu_cs(
   ireset,
   cp2,
   adr,
   dbus_in,
   dbus_out,
   iore,
   iowe,
   out_en,
   sleep_en,
   sleep_mode
);
 
 `include "bit_def_pack.vh"
 
   // Clock and Reset
   input        ireset;
   input        cp2;
   // AVR Control
   input [5:0]  adr;
   input [7:0]  dbus_in;
   output [7:0] dbus_out;
   input        iore;
   input        iowe;
   output       out_en;
   // Control/Status lines
   output       sleep_en;
   output [2:0] sleep_mode;
   
   reg [7:0]    mcucr_current;
   reg [7:0]    mcucr_next;
   
   
   always @(negedge ireset or posedge cp2)
   begin: seq_prc
      if (!ireset)		//Reset
         mcucr_current <= {8{1'b0}};
      else 		// Clock
         mcucr_current <= mcucr_next;
   end
   
   
   always @(adr or dbus_in or iore or iowe)
   begin: comb_prc
      mcucr_next = mcucr_current;
      if (adr == MCUCR_Address && iowe)
         mcucr_next = dbus_in;
   end
   
   assign out_en = (adr == MCUCR_Address && iore ) ? 1'b1 : 1'b0;
   assign dbus_out = mcucr_current;
   
   assign sleep_en = mcucr_current[SE_bit];
   assign sleep_mode[0] = mcucr_current[SM0_bit];
   assign sleep_mode[1] = mcucr_current[SM1_bit];
   assign sleep_mode[2] = mcucr_current[SM2_bit];
   
endmodule
