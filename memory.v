`timescale 1us/1us
// Interface to a Xilinx block RAM
// The clk should be 2x what the rest of the system is using
// So that the output is ready at the start of the next cycle.
// Bit 12 is sign, Bits 11-0 are BCD data
module memory(input clk,input [7:0]memaddr, inout [12:0] dbus, input memoe, input memwrite);
// Input address is BCD!
	wire [6:0] binaddress;
   wire [12:0] outdata;   // current output word

// Drive DBUS when asked
   assign dbus=memoe?outdata:13'bz;
// convert BCD address to binary
// binaddress=10*digit1 + digit 0 
//  or 8*digit1+2*digit1+digit0
	assign binaddress=({3'b0, memaddr[7:4]}<<3)+({3'b0, memaddr[7:4]}<<1)+{ 3'b0, memaddr[3:0]};

mainmem ram (
  .clka(clk), // input clka
  .wea(memwrite), // input [0 : 0] wea
  .addra(binaddress), // input [6 : 0] addra
  .dina(dbus), // input [12 : 0] dina
  .douta(outdata) // output [12 : 0] douta
);

   

  
  endmodule

