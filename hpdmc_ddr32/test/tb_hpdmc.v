/*
 * Milkymist VJ SoC
 * Copyright (C) 2007, 2008, 2009, 2010 Sebastien Bourdeauducq
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

`timescale 1ns / 1ps

//`define ENABLE_VCD
`define TEST_SOMETRANSFERS
//`define TEST_RANDOMTRANSFERS

module tb_hpdmc();

/* 100MHz system clock */
reg clk;
initial clk = 1'b0;
always #5 clk = ~clk;

/* DQS clock is phased out by 90 degrees, resulting in 2.5ns delay */
reg dqs_clk;
always @(clk) #2.5 dqs_clk = clk;

wire sdram_cke;
wire sdram_cs_n;
wire sdram_we_n;
wire sdram_cas_n;
wire sdram_ras_n;
wire [3:0] sdram_dm;
wire [12:0] sdram_adr;
wire [1:0] sdram_ba;
wire [31:0] sdram_dq;
wire [3:0] sdram_dqs;

ddr sdram1(
	.Addr(sdram_adr),
	.Ba(sdram_ba),
	.Clk(clk),
	.Clk_n(~clk),
	.Cke(sdram_cke),
	.Cs_n(sdram_cs_n),
	.Ras_n(sdram_ras_n),
	.Cas_n(sdram_cas_n),
	.We_n(sdram_we_n),
	
	.Dm(sdram_dm[3:2]),
	.Dqs(sdram_dqs[3:2]),
	.Dq(sdram_dq[31:16])
);

ddr sdram0(
	.Addr(sdram_adr),
	.Ba(sdram_ba),
	.Clk(clk),
	.Clk_n(~clk),
	.Cke(sdram_cke),
	.Cs_n(sdram_cs_n),
	.Ras_n(sdram_ras_n),
	.Cas_n(sdram_cas_n),
	.We_n(sdram_we_n),
	
	.Dm(sdram_dm[1:0]),
	.Dqs(sdram_dqs[1:0]),
	.Dq(sdram_dq[15:0])
);

reg rst;

reg [13:0] csr_a;
reg csr_we;
reg [31:0] csr_di;
wire [31:0] csr_do;

reg [25:0] fml_adr;
reg fml_stb;
reg fml_we;
wire fml_ack;
reg [7:0] fml_sel;
reg [63:0] fml_di;
wire [63:0] fml_do;

hpdmc dut(
	.sys_clk(clk),
	.sys_clk_n(~clk),
	.dqs_clk(dqs_clk),
	.dqs_clk_n(~dqs_clk),
	.sys_rst(rst),

	.csr_a(csr_a),
	.csr_we(csr_we),
	.csr_di(csr_di),
	.csr_do(csr_do),
	
	.fml_adr(fml_adr),
	.fml_stb(fml_stb),
	.fml_we(fml_we),
	.fml_ack(fml_ack),
	.fml_sel(fml_sel),
	.fml_di(fml_di),
	.fml_do(fml_do),
	
	.sdram_cke(sdram_cke),
	.sdram_cs_n(sdram_cs_n),
	.sdram_we_n(sdram_we_n),
	.sdram_cas_n(sdram_cas_n),
	.sdram_ras_n(sdram_ras_n),
	.sdram_dm(sdram_dm),
	.sdram_adr(sdram_adr),
	.sdram_ba(sdram_ba),
	.sdram_dq(sdram_dq),
	.sdram_dqs(sdram_dqs),
	
	.dqs_psen(),
	.dqs_psincdec(),
	.dqs_psdone(1'b1)
);

task waitclock;
begin
	@(posedge clk);
	#1;
end
endtask

task waitnclock;
input [15:0] n;
integer i;
begin
	for(i=0;i<n;i=i+1)
		waitclock;
end
endtask

task csrwrite;
input [31:0] address;
input [31:0] data;
begin
	csr_a = address[16:2];
	csr_di = data;
	csr_we = 1'b1;
	waitclock;
	$display("Configuration Write: %x=%x", address, data);
	csr_we = 1'b0;
end
endtask

task csrread;
input [31:0] address;
begin
	csr_a = address[16:2];
	waitclock;
	$display("Configuration Read : %x=%x", address, csr_do);
end
endtask

real reads;
real read_clocks;

task readburst;
input [31:0] address;
integer i;
begin
	$display("READ  [%x]", address);
	fml_adr = address;
	fml_stb = 1'b1;
	fml_we = 1'b0;
	i = 0;
	while(~fml_ack) begin
		i = i+1;
		waitclock;
	end
	$display("%t: Memory Read : %x=%x acked in %d clocks", $time, address, fml_do, i);
	fml_stb = 1'b0;
	reads = reads + 1;
	read_clocks = read_clocks + i;
	for(i=0;i<3;i=i+1) begin
		waitclock;
		$display("%t: (R burst continuing)    %x", $time, fml_do);
	end
	
	waitclock;
end
endtask

real writes;
real write_clocks;

task writeburst;
input [31:0] address;
integer i;
begin
	$display("WRITE [%x]", address);
	fml_adr = address;
	fml_stb = 1'b1;
	fml_we = 1'b1;
	fml_sel = 8'hff;
	fml_di = {$random, $random};
	i = 0;
	while(~fml_ack) begin
		i = i+1;
		waitclock;
	end
	$display("%t: Memory Write : %x=%x acked in %d clocks", $time, address, fml_di, i);
	fml_stb = 1'b0;
	writes = writes + 1;
	write_clocks = write_clocks + i;
	for(i=0;i<3;i=i+1) begin
		waitclock;
		fml_di = {$random, $random};
		$display("%t: (W burst continuing)    %x", $time, fml_di);
	end

	waitclock;
end
endtask

integer n, addr;

always begin
`ifdef ENABLE_VCD
	$dumpfile("hpdmc.vcd");
`endif

	/* Reset / Initialize our logic */
	rst = 1'b1;
	
	csr_a = 14'd0;
	csr_di = 32'd0;
	csr_we = 1'b0;
	
	fml_adr = 26'd0;
	fml_di = 64'd0;
	fml_sel = 8'd0;
	fml_stb = 1'b0;
	fml_we = 1'b0;
	
	waitclock;
	
	rst = 1'b0;
	
	waitclock;
	
	/* SDRAM initialization sequence. */
	/* The controller already comes up in Bypass mode with CKE disabled. */
	
	/* Wait 200us */
	#200000;
	
	/* Bring CKE high */
	csrwrite(32'h00, 32'h07);
	/* Precharge All:
	 * CS=1
	 * WE=1
	 * CAS=0
	 * RAS=1
	 * A=A10
	 * BA=Don't Care
	 */
	csrwrite(32'h04, 32'b00_0010000000000_1011);
	waitnclock(2);
	
	/* Load Extended Mode Register:
	 * CS=1
	 * WE=1
	 * CAS=1
	 * RAS=1
	 * A=Value
	 * BA=01
	 *
	 * Extended mode register encoding :
	 * A12-A2 reserved, must be 0
	 * A1 weak drive strength
	 * A0 DLL disable
	 */
	csrwrite(32'h04, 32'b01_0000000000000_1111);
	waitnclock(2);
	
	/* Load Mode Register, DLL in Reset:
	 * CS=1
	 * WE=1
	 * CAS=1
	 * RAS=1
	 * A=Value
	 * BA=00
	 *
	 * Mode register encoding :
	 * A12-A7 = 000000 Normal operation w/o DLL reset
	 *          000010 Normal operation in DLL reset
	 * A6-A4  = 010    CL2
	 * A3     = 0      Sequential burst
	 * A2-A0  = 011    Burst length = 8
	 */
	csrwrite(32'h04, 32'b00__000010_010_0_011__1111);
	waitnclock(200);
	
	/* Precharge All */
	csrwrite(32'h04, 32'b00_0010000000000_1011);
	waitnclock(2);
	
	/* Auto Refresh
	 * CS=1
	 * WE=0
	 * CAS=1
	 * RAS=1
	 * A=Don't Care
	 * BA=Don't Care
	 */
	csrwrite(32'h04, 32'b00_0000000000000_1101);
	waitnclock(8);
	
	/* Auto Refresh */
	csrwrite(32'h04, 32'b00_0000000000000_1101);
	waitnclock(8);
	
	/* Load Mode Register, DLL enabled */
	csrwrite(32'h04, 32'b00__000000_010_0_011__1111);
	waitnclock(200);
	
	/* SDRAM initialization completed */
	
`ifdef ENABLE_VCD
	/* Now, we want to know what the controller will send to the SDRAM chips */
	$dumpvars(0, dut);
`endif
	
	/* Bring up the controller ! */
	csrwrite(32'h00, 32'h04);
	
`ifdef TEST_SOMETRANSFERS
	/*
	 * Try some transfers.
	 */
	writeburst(32'h00);
	writeburst(32'h20);
	//writeburst(32'h40);
	
	readburst(32'h00);
	readburst(32'h20);
	/*readburst(32'h40);
	writeburst(32'h40);
	readburst(32'h40);*/
`endif

`ifdef TEST_RANDOMTRANSFERS
	writes = 0;
	write_clocks = 0;
	reads = 0;
	read_clocks = 0;
	for(n=0;n<500;n=n+1) begin
		addr = $random;
		if($random > 32'h80000000) begin
			writeburst(addr);
			//writeburst(addr+32'h20);
			//writeburst(addr+32'h40);
		end else begin
			readburst(addr);
			//readburst(addr+32'h20);
			//readburst(addr+32'h40);
		end
	end
	
	$display("");
	$display("=======================================================");
	$display(" Tested: %.0f reads, %.0f writes ", reads, writes);
	$display("=======================================================");
	$display(" Average read latency:    %f cycles", read_clocks/reads);
	$display(" Average write latency:   %f cycles", write_clocks/writes);
	$display("=======================================================");
	$display(" Average read bandwidth:  %f MBit/s @ 100MHz", (4/(4+read_clocks/reads))*64*100);
	$display(" Average write bandwidth: %f MBit/s @ 100MHz", (4/(4+write_clocks/writes))*64*100);
	$display("=======================================================");

`endif

	$finish;
end

endmodule

