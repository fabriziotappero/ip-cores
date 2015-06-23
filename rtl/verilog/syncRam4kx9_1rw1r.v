/* ===============================================================
	2008,2011  Robert Finch
	robfinch@sympatico.ca

	syncRam4kx9_1rw1r.v

	This source code is free for use and modification for
	non-commercial or evaluation purposes, provided this
	copyright statement and disclaimer remains present in
	the file.

	If you do modify the code, please state the origin and
	note that you have modified the code.

	NO WARRANTY.
	THIS Work, IS PROVIDEDED "AS IS" WITH NO WARRANTIES OF
	ANY KIND, WHETHER EXPRESS OR IMPLIED. The user must assume
	the entire risk of using the Work.

	IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
	ANY INCIDENTAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES
	WHATSOEVER RELATING TO THE USE OF THIS WORK, OR YOUR
	RELATIONSHIP WITH THE AUTHOR.

	IN ADDITION, IN NO EVENT DOES THE AUTHOR AUTHORIZE YOU
	TO USE THE WORK IN APPLICATIONS OR SYSTEMS WHERE THE
	WORK'S FAILURE TO PERFORM CAN REASONABLY BE EXPECTED
	TO RESULT IN A SIGNIFICANT PHYSICAL INJURY, OR IN LOSS
	OF LIFE. ANY SUCH USE BY YOU IS ENTIRELY AT YOUR OWN RISK,
	AND YOU AGREE TO HOLD THE AUTHOR AND CONTRIBUTORS HARMLESS
	FROM ANY CLAIMS OR LOSSES RELATING TO SUCH UNAUTHORIZED
	USE.


=============================================================== */

`define SYNTHESIS
`define VENDOR_XILINX
`define SPARTAN3

module syncRam4kx9_1rw1r(
	input wrst,
	input wclk,
	input wce,
	input we,
	input [11:0] wadr,
	input [8:0] i,
	output [8:0] wo,
	input rrst,
	input rclk,
	input rce,
	input [11:0] radr,
	output [8:0] o
);

`ifdef SYNTHESIS
`ifdef VENDOR_XILINX

`ifdef SPARTAN3
	wire [8:0] o0;
	wire [8:0] o1;
	wire [8:0] wo0;
	wire [8:0] wo1;
	wire rrst0 =  radr[11];
	wire rrst1 = ~radr[11];
	wire wrst0 =  wadr[11];
	wire wrst1 = ~wadr[11];
	wire we0 = we & ~wadr[11];
	wire we1 = we &  wadr[11];

	RAMB16_S9_S9 ram0(
		.CLKA(wclk), .ADDRA(wadr), .DIA(i[7:0]), .DIPA(i[8]), .DOA(wo0[7:0]), .DOPA(wo0[8]), .ENA(wce), .WEA(we0), .SSRA(wrst0),
		.CLKB(rclk), .ADDRB(radr), .DIB(8'hFF), .DIPB(1'b1), .DOB(o0[7:0]), .DOPB(o0[8]), .ENB(rce), .WEB(1'b0), .SSRB(rrst0)  );
	RAMB16_S9_S9 ram1(
		.CLKA(wclk), .ADDRA(wadr), .DIA(i[7:0]), .DIPA(i[8]), .DOA(wo1[7:0]), .DOPA(wo1[8]), .ENA(wce), .WEA(we1), .SSRA(wrst1),
		.CLKB(rclk), .ADDRB(radr), .DIB(8'hFF), .DIPB(1'b1), .DOB(o1[7:0]), .DOPB(o1[8]), .ENB(rce), .WEB(1'b0), .SSRB(rrst1)  );

	assign o = o0|o1;
	assign wo = wo0|wo1;

`endif

`ifdef SPARTAN2
	RAMB4_S1_S1 ram0(
		.CLKA(wclk), .ADDRA(wadr), .DIA(i[0]), .DOA(wo[0]), .ENA(wce), .WEA(we), .RSTA(wrst),
		.CLKB(rclk), .ADDRB(radr), .DIB(1'b1), .DOB(o[0]), .ENB(rce), .WEB(1'b0), .RSTB(rrst)  );
	RAMB4_S1_S1 ram1(
		.CLKA(wclk), .ADDRA(wadr), .DIA(i[1]), .DOA(wo[1]), .ENA(wce), .WEA(we), .RSTA(wrst),
		.CLKB(rclk), .ADDRB(radr), .DIB(1'b1), .DOB(o[1]), .ENB(rce), .WEB(1'b0), .RSTB(rrst)  );
	RAMB4_S1_S1 ram2(
		.CLKA(wclk), .ADDRA(wadr), .DIA(i[2]), .DOA(wo[2]), .ENA(wce), .WEA(we), .RSTA(wrst),
		.CLKB(rclk), .ADDRB(radr), .DIB(1'b1), .DOB(o[2]), .ENB(rce), .WEB(1'b0), .RSTB(rrst)  );
	RAMB4_S1_S1 ram3(
		.CLKA(wclk), .ADDRA(wadr), .DIA(i[3]), .DOA(wo[3]), .ENA(wce), .WEA(we), .RSTA(wrst),
		.CLKB(rclk), .ADDRB(radr), .DIB(1'b1), .DOB(o[3]), .ENB(rce), .WEB(1'b0), .RSTB(rrst)  );
	RAMB4_S1_S1 ram4(
		.CLKA(wclk), .ADDRA(wadr), .DIA(i[4]), .DOA(wo[4]), .ENA(wce), .WEA(we), .RSTA(wrst),
		.CLKB(rclk), .ADDRB(radr), .DIB(1'b1), .DOB(o[4]), .ENB(rce), .WEB(1'b0), .RSTB(rrst)  );
	RAMB4_S1_S1 ram5(
		.CLKA(wclk), .ADDRA(wadr), .DIA(i[5]), .DOA(wo[5]), .ENA(wce), .WEA(we), .RSTA(wrst),
		.CLKB(rclk), .ADDRB(radr), .DIB(1'b1), .DOB(o[5]), .ENB(rce), .WEB(1'b0), .RSTB(rrst)  );
	RAMB4_S1_S1 ram6(
		.CLKA(wclk), .ADDRA(wadr), .DIA(i[6]), .DOA(wo[6]), .ENA(wce), .WEA(we), .RSTA(wrst),
		.CLKB(rclk), .ADDRB(radr), .DIB(1'b1), .DOB(o[6]), .ENB(rce), .WEB(1'b0), .RSTB(rrst)  );
	RAMB4_S1_S1 ram7(
		.CLKA(wclk), .ADDRA(wadr), .DIA(i[7]), .DOA(wo[7]), .ENA(wce), .WEA(we), .RSTA(wrst),
		.CLKB(rclk), .ADDRB(radr), .DIB(1'b1), .DOB(o[7]), .ENB(rce), .WEB(1'b0), .RSTB(rrst)  );
`endif

`endif

`ifdef VENDOR_ALTERA

	reg [8:0] mem [4095:0];
	reg [10:0] rradr;
	reg [10:0] rwadr;

	// register read addresses
	always @(posedge rclk)
		if (rce) rradr <= radr;

	assign o = mem[rradr];

	// write side
	always @(posedge wclk)
		if (wce) rwadr <= wadr;

	always @(posedge wclk)
		if (wce) mem[wadr] <= i;

	assign wo = mem[rwadr];

`endif

`else

	reg [8:0] mem [4095:0];
	reg [10:0] rradr;
	reg [10:0] rwadr;

	// register read addresses
	always @(posedge rclk)
		if (rce) rradr <= radr;

	assign o = mem[rradr];

	// write side
	always @(posedge wclk)
		if (wce) rwadr <= wadr;

	always @(posedge wclk)
		if (wce) mem[wadr] <= i;

	assign wo = mem[rwadr];

`endif

endmodule
