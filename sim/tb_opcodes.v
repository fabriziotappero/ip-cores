/* MC6809/HD6309 Compatible core
 * (c) 2013 R.A. Paz Schmidt rapazschmidt@gmail.com
 *
 * Distributed under the terms of the Lesser GPL
 *
 * Opcode tester
 * taken from http://lennartb.home.xs4all.nl/m6809.html
 */
`timescale 1ns/1ns

module tb(output wire [15:0] addr_o, output wire [7:0] data_o_o);

reg clk, reset;

assign addr_o = addr;
assign data_o_o = data_o;
wire [15:0] addr;
wire [7:0] data_o, data_i;
wire oe, we;
always 
	#5 clk = ~clk;
	
MC6809_cpu cpu(
	.cpu_clk(clk),
	.cpu_reset(reset),
	.cpu_we_o(we),
	.cpu_oe_o(oe),
	.cpu_addr_o(addr),
	.cpu_data_i(data_i),
	.cpu_data_o(data_o)
	);

memory imem(addr, !oe, !we, data_i, data_o);
	
initial
	begin
		$dumpvars;
		clk = 0;
		reset = 1;
		#0
		#46
		reset = 0;
		#111500
		$finish;
	end

endmodule

module memory(
	input wire [15:0] addr,
	input wire oe,
	input wire we,
	output wire [7:0] data_o,
	input wire [7:0] data_i
	);
	
reg [7:0] mem[65535:0];
reg [7:0] latecheddata;
wire [7:0] mem0, mem1, mem2, mem3;

assign mem0 = mem[0];
assign mem1 = mem[1];
assign mem2 = mem[2];
assign mem3 = mem[3];

assign data_o = latecheddata;
always @(negedge oe)
	latecheddata <= mem[addr];
	
always @(negedge we)
	begin
		mem[addr] <= data_i;
		$display("W %04x = %02x %t", addr, data_i, $time);
	end

always @(negedge oe)
	begin
		if (addr == 16'h0003)
			begin
				$display("*** EEEEE  RRRR   RRRR    OOOO   RRRR  ***");
				$display("*** E      R   R  R   R  O    O  R   R ***");
				$display("*** EEEE   RRRR   RRRR   O    O  RRRR  ***");
				$display("*** E      R R    R R    O    O  R R   ***");
				$display("*** EEEEE  R  R   R  R    OOOO   R  R  ***");
				$finish;
			end
		if (addr == 16'h1000)
			begin
				$display("");
				$display("*** All tests  OOOO   K  K ***");
				$display("*** All tests O    O  K K  ***");
				$display("*** All tests O    O  KK   ***");
				$display("*** All tests O    O  K K  ***");
				$display("*** All tests  OOOO   K  K ***");
				$display("");
				$finish;
			end
		$display("R %04x = %02x %t", addr, mem[addr], $time);
	end
`define READTESTBIN
integer i;
initial
	begin
		$readmemh("test09.hex", mem);
		$display("test09.hex read");
		mem[16'hfffe] = 8'h00; // setup reset
		mem[16'hffff] = 8'h00;
	end
	
endmodule
