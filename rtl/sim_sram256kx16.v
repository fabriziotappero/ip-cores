/*	MODULE: sram 256k x 16
	DESCRIPTION: Contains simulation model for the 256K x 16 bit SRAM
	 in spartan 3 starter kit

AUTHOR: 
Antonio J. Anton
Anro Ingenieros (www.anro-ingenieros.com)
aj@anro-ingenieros.com

REVISION HISTORY:
Revision 1.0, 26/03/2007
Initial release

COPYRIGHT:
Copyright (c) 2007 Antonio J. Anton

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in 
the Software without restriction, including without limitation the rights to 
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
of the Software, and to permit persons to whom the Software is furnished to do 
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
SOFTWARE.*/

/* sram256Kx16.v -- external async 256Kx16 SRAM Verilog model (simulation only) */ 
`timescale 1ns/100ps
`include "openfire_define.v"

module SRAM256KX16(ce_n, we_n, oe_n, ub_n, lb_n, addr, io);

	parameter MAX_RAM = `MAX_SIMULATION_SRAM;		// max. memoria simulada
	parameter DELAY	= 12;			// retraso de acceso (lectura/escritura) a memoria

	input				ce_n;		// active low chip enable
	input				we_n;		// active low write enable
	input				oe_n;		// active low output enable
	input				ub_n;		// byte alto activo (negado)
	input				lb_n;		// byte bajo activo (negado)
	input	[17:0]	addr;		// address (18 bits=256k)
	inout	[15:0]	io;		// tri-state data I/O

	reg		[7:0] memh [0:MAX_RAM - 1];	// no simulamos toda la memoria
	reg		[7:0]	meml [0:MAX_RAM - 1];

	integer	n;			// contador para memoria
	initial begin
	  $display("Inicializando %d bytes de RAM...", MAX_RAM);
	  for(n = 0; n < MAX_RAM; n = n + 1)	// inicializar la memoria
	  begin
	    memh[n] = n / 256;
		 meml[n] = n % 256;
     end
	  $display("RAM inicializada");
	end

	// lectura
	wire [7:0] #DELAY lectura_meml = meml[addr % MAX_RAM];
	wire [7:0] #DELAY lectura_memh = memh[addr % MAX_RAM];

	// tristate buffers
	assign io[7:0]  = (~oe_n & we_n & ~ce_n & ~lb_n) ? lectura_meml : 8'bz;
	assign io[15:8] = (~oe_n & we_n & ~ce_n & ~ub_n) ? lectura_memh : 8'bz;

	// escritura
	always @(we_n or ce_n or lb_n or ub_n)
	begin
	   #1			// glitch filter
		if(~we_n & ~ce_n & ~lb_n)
		begin
			meml[addr % MAX_RAM] = io[7:0];
			`ifdef SHOW_SRAM_DATA
			$display(" write LOW:  meml[%d(%d)]=%d", addr, addr % MAX_RAM, meml[addr % MAX_RAM]);
			`endif
      end
      if(~we_n & ~ce_n & ~ub_n)
		begin
			memh[addr % MAX_RAM] = io[15:8];
			`ifdef SHOW_SRAM_DATA
			$display(" write HIGH:  memh[%d(%d)]=%d", addr, addr % MAX_RAM, memh[addr % MAX_RAM]);
			`endif
		end   
	end

endmodule

