/* MC6809/HD6309 Compatible core
 * (c) 2013 R.A. Paz Schmidt rapazschmidt@gmail.com
 *
 * Distributed under the terms of the Lesser GPL
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
		$display("R %04x = %02x %t", addr, mem[addr], $time);
	end
`define READTESTBIN
integer i;
initial
	begin
`ifdef READTESTBIN
/*
		$readmemh("test09.hex", mem);//instructions_test.hex", mem);
		$display("instructions_test.hex read");
		mem[16'hfffe] = 8'h00; // setup reset
		mem[16'hffff] = 8'h00;
*/
		$readmemh("monitor.hex", mem);
		$display("monitor.hex read");
		for (i = 0; i < 7168; i=i+1)// move monitor to its new location
			begin
				mem[16'he400+i] = mem[i];
				mem[i] = 8'h0;
			end

`else
		for (i = 0; i < 65536; i=i+1)
			mem[i] = 8'ha5;

		mem[16'h1000] = 8'h8e; // ldx #$100
		mem[16'h1001] = 8'h01; // 
		mem[16'h1002] = 8'h00; // 

		mem[16'h1003] = 8'hbf; // stx $102		
		mem[16'h1004] = 8'h01; // 
		mem[16'h1005] = 8'h02; // 

		mem[16'h1006] = 8'h0f; // clr $10
		mem[16'h1007] = 8'h10; // 
		
		mem[16'h1008] = 8'h7f; // clr $1234
		mem[16'h1009] = 8'h12; // 
		mem[16'h100a] = 8'h34; // 

		mem[16'h100b] = 8'h0c; // inc $10
		mem[16'h100c] = 8'h10; // 
		
		mem[16'h100d] = 8'h7c; // inc $1234
		mem[16'h100e] = 8'h12; // 
		mem[16'h100f] = 8'h34; // 
		
		mem[16'h1010] = 8'h0a; // dec $10
		mem[16'h1011] = 8'h10; // 
		
		mem[16'h1012] = 8'h7a; // dec $1234
		mem[16'h1013] = 8'h12; // 
		mem[16'h1014] = 8'h34; // 
		
		mem[16'h1015] = 8'h20; // bra *
		mem[16'h1016] = 8'hfe; // 
		
		
		
/*
// test indexed store
		mem[16'h1000] = 8'h86; // lda #$02
		mem[16'h1001] = 8'h02; // 
		mem[16'h1002] = 8'h9e; // ldx $00 (direct)
		mem[16'h1003] = 8'h00; // 
		
		mem[16'h1004] = 8'ha7; // lda ,x
		mem[16'h1005] = 8'b10000100; // ofs0
		mem[16'h1006] = 8'ha7; // lda ,x+
		mem[16'h1007] = 8'b10000000; // 
		

		mem[16'h1008] = 8'ha7; // lda ,x++
		mem[16'h1009] = 8'b10000001; // 
		mem[16'h100a] = 8'ha6; // lda ,-x
		mem[16'h100b] = 8'b10000010; // 
		
		mem[16'h100c] = 8'ha7; // lda ,--x
		mem[16'h100d] = 8'b10000011; // 

		mem[16'h100e] = 8'ha7; // lda 0,x ofs 5
		mem[16'h100f] = 8'h00; // 
		
		mem[16'h1010] = 8'ha7; // lda 0,x ofs 8
		mem[16'h1011] = 8'b10001000; // 
		mem[16'h1012] = 8'h00; // 
		
		mem[16'h1013] = 8'ha7; // lda 0,x ofs 16
		mem[16'h1014] = 8'b10001001; // 
		mem[16'h1015] = 8'h00; // 
		mem[16'h1016] = 8'h00; // 
*/

/* test indexed load
		mem[16'h1000] = 8'h86; // lda #$02
		mem[16'h1001] = 8'h02; // 
		mem[16'h1002] = 8'h9e; // ldx $00 (direct)
		mem[16'h1003] = 8'h00; // 
		
		mem[16'h1004] = 8'ha6; // lda ,x
		mem[16'h1005] = 8'b10000100; // ofs0
		mem[16'h1006] = 8'ha6; // lda ,x+
		mem[16'h1007] = 8'b10000000; // 
		

		mem[16'h1008] = 8'ha6; // lda ,x++
		mem[16'h1009] = 8'b10000001; // 
		mem[16'h100a] = 8'ha6; // lda ,-x
		mem[16'h100b] = 8'b10000010; // 
		
		mem[16'h100c] = 8'ha6; // lda ,--x
		mem[16'h100d] = 8'b10000011; // 

		mem[16'h100e] = 8'ha6; // lda 0,x ofs 5
		mem[16'h100f] = 8'h00; // 
		
		mem[16'h1010] = 8'ha6; // lda 0,x ofs 8
		mem[16'h1011] = 8'b10001000; // 
		mem[16'h1012] = 8'h00; // 
		
		mem[16'h1013] = 8'ha6; // lda 0,x ofs 16
		mem[16'h1014] = 8'b10001001; // 
		mem[16'h1015] = 8'h00; // 
		mem[16'h1016] = 8'h00; // 
*/		
		
/* test extended
		mem[16'h1000] = 8'h86; // ldb #$fe
		mem[16'h1001] = 8'h02; // 
		mem[16'h1002] = 8'hc6; // lda #$0
		mem[16'h1003] = 8'h00; // 
		
		mem[16'h1004] = 8'h97; // inca		
		mem[16'h1005] = 8'h00; // sta $0000
		mem[16'h1006] = 8'hd7; //
		mem[16'h1007] = 8'h01; // 
		

		mem[16'h1008] = 8'hb6; // lda $0000
		mem[16'h1009] = 8'h00; // 
		mem[16'h100a] = 8'h00; // 

		mem[16'h100b] = 8'h26; // bne$.-5		
		mem[16'h100c] = 8'hf7; //

		mem[16'h100d] = 8'h5c; // incb

		mem[16'h100e] = 8'hf7; // stb $0001
		mem[16'h100f] = 8'h00; // 
		mem[16'h1010] = 8'h01; // 
		
		mem[16'h1011] = 8'h20; // bra
		mem[16'h1012] = 8'hec; // $.-18
*/		
		mem[16'hfff0] = 8'h20; // reset
		mem[16'hfff1] = 8'h00;
		mem[16'hfff2] = 8'h20; // reset
		mem[16'hfff3] = 8'h02;
		mem[16'hfff4] = 8'h20; // reset
		mem[16'hfff5] = 8'h04;
		mem[16'hfff6] = 8'h20; // reset
		mem[16'hfff7] = 8'h06;
		mem[16'hfff8] = 8'h20; // reset
		mem[16'hfff9] = 8'h08;
		mem[16'hfffa] = 8'h20; // reset
		mem[16'hfffb] = 8'h0a;
		mem[16'hfffc] = 8'h20; // reset
		mem[16'hfffd] = 8'h0c;
		mem[16'hfffe] = 8'h10; // reset
		mem[16'hffff] = 8'h00;
`endif
	end
	
endmodule
