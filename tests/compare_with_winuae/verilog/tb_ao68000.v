/* 
 * Copyright 2010, Aleksander Osman, alfik@poczta.fm. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are
 * permitted provided that the following conditions are met:
 *
 *  1. Redistributions of source code must retain the above copyright notice, this list of
 *     conditions and the following disclaimer.
 *
 *  2. Redistributions in binary form must reproduce the above copyright notice, this list
 *     of conditions and the following disclaimer in the documentation and/or other materials
 *     provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

`timescale 10ns / 1ns

`define MICROPC_MAIN_LOOP 9'd53

module tb_ao68000();

// inputs
reg clk;
reg rst_n;
reg [31:0] data_in;
reg ack;
wire err;
wire rty;
wire [2:0] ipl;

// outputs
wire cyc;
wire [31:2] addr;
wire [31:0] data_out;
wire [3:0] sel;
wire stb;
wire we;
wire sgl;
wire blk;
wire rmw;
wire [2:0] cti;
wire [1:0] bte;
wire [2:0] fc;
wire reset_output;
wire blocked_output;

ao68000 ao68000_m(
	.CLK_I(clk),
	.reset_n(rst_n),

	.DAT_I(data_in),
	.ACK_I(ack),
	.ERR_I(err),
	.RTY_I(rty),


	.CYC_O(cyc),
	.ADR_O(addr),
	.DAT_O(data_out),
	.SEL_O(sel),
	.STB_O(stb),
	.WE_O(we),

	.SGL_O(sgl),
	.BLK_O(blk),
	.RMW_O(rmw),
	.CTI_O(cti),
	.BTE_O(bte),

	.fc_o(fc),

	.ipl_i(ipl),
	.reset_o(reset_output),
	.blocked_o(blocked_output)
);

initial begin
	clk = 1'b0;
	forever #5 clk = ~clk;
end

reg [87:0] string;
reg [31:0] write_data_selected;

always @(posedge clk) begin
	if(stb == 1'b1 && we == 1'b0 && addr == 30'd0 && ao68000_m.microcode_branch_m.micro_pc_0 == 9'd1) begin
		#5
		data_in = get_argument("SSP");
		ack = 1'b1;
		#10
		data_in = 32'd0;
		ack = 1'b0;
	end
	else if(stb == 1'b1 && we == 1'b0 && addr == 30'd1 && ao68000_m.microcode_branch_m.micro_pc_0 == 9'd1) begin
		#5
		data_in = get_argument("PC");
		ack = 1'b1;
		#10
		data_in = 32'd0;
		ack = 1'b0;
	end

	else if(stb == 1'b1 && we == 1'b0) begin
		$display("memory read: address=%h, select=%h", addr, sel);

		$sformat(string, "MEM%h", addr);

		#5
		data_in = get_argument(string);
		ack = 1'b1;
		#10
		data_in = 32'd0;
		ack = 1'b0;
	end

	else if(stb == 1'b1 && we == 1'b1) begin
		if(sel == 4'd0) write_data_selected = 32'd0;
		else if(sel == 4'd1) write_data_selected = { 24'd0, data_out[7:0] };
		else if(sel == 4'd2) write_data_selected = { 16'd0, data_out[15:8], 8'd0 };
		else if(sel == 4'd3) write_data_selected = { 16'd0, data_out[15:0] };
		else if(sel == 4'd4) write_data_selected = { 8'd0, data_out[23:16], 16'd0 };
		else if(sel == 4'd5) write_data_selected = { 8'd0, data_out[23:16], 8'd0, data_out[7:0] };
		else if(sel == 4'd6) write_data_selected = { 8'd0, data_out[23:8], 8'd0 };
		else if(sel == 4'd7) write_data_selected = { 8'd0, data_out[23:0] };
		else if(sel == 4'd8) write_data_selected = { data_out[31:24], 24'd0 };
		else if(sel == 4'd9) write_data_selected = { data_out[31:24], 16'd0, data_out[7:0] };
		else if(sel == 4'd10) write_data_selected = { data_out[31:24], 8'd0, data_out[15:8], 8'd0 };
		else if(sel == 4'd11) write_data_selected = { data_out[31:24], 8'd0, data_out[15:0] };
		else if(sel == 4'd12) write_data_selected = { data_out[31:16], 16'd0 };
		else if(sel == 4'd13) write_data_selected = { data_out[31:16], 8'd0, data_out[7:0] };
		else if(sel == 4'd14) write_data_selected = { data_out[31:8], 8'd0 };
		else if(sel == 4'd15) write_data_selected = data_out[31:0];

		$display("memory write address=%h, select=%h: value=%h", addr, sel, write_data_selected);

		#5
		ack = 1'b1;
		#10
		ack = 1'b0;
	end

end

function [31:0] get_argument(input [87:0] name);
reg [31:0] result;
begin
	if( $value$plusargs({name, "=%h"}, result) == 0 ) begin
		$display("Missing argument: %s", name);
		$finish_and_return(-1);
	end
	get_argument = result;
end
endfunction

task load_state;
begin
	ao68000_m.memory_registers_m.an_ram_inst.mem_data[0] = get_argument("A0");
	ao68000_m.memory_registers_m.an_ram_inst.mem_data[1] = get_argument("A1");
	ao68000_m.memory_registers_m.an_ram_inst.mem_data[2] = get_argument("A2");
	ao68000_m.memory_registers_m.an_ram_inst.mem_data[3] = get_argument("A3");
	ao68000_m.memory_registers_m.an_ram_inst.mem_data[4] = get_argument("A4");
	ao68000_m.memory_registers_m.an_ram_inst.mem_data[5] = get_argument("A5");
	ao68000_m.memory_registers_m.an_ram_inst.mem_data[6] = get_argument("A6");
	ao68000_m.memory_registers_m.an_ram_inst.mem_data[7] = get_argument("SSP");
	ao68000_m.memory_registers_m.usp = get_argument("USP");

	ao68000_m.memory_registers_m.dn_ram_inst.mem_data[0] = get_argument("D0");
	ao68000_m.memory_registers_m.dn_ram_inst.mem_data[1] = get_argument("D1");
	ao68000_m.memory_registers_m.dn_ram_inst.mem_data[2] = get_argument("D2");
	ao68000_m.memory_registers_m.dn_ram_inst.mem_data[3] = get_argument("D3");
	ao68000_m.memory_registers_m.dn_ram_inst.mem_data[4] = get_argument("D4");
	ao68000_m.memory_registers_m.dn_ram_inst.mem_data[5] = get_argument("D5");
	ao68000_m.memory_registers_m.dn_ram_inst.mem_data[6] = get_argument("D6");
	ao68000_m.memory_registers_m.dn_ram_inst.mem_data[7] = get_argument("D7");

	ao68000_m.registers_m.pc = get_argument("PC");

	ao68000_m.alu_m.sr = 16'd0;
	ao68000_m.alu_m.sr[0] = get_argument("C");
	ao68000_m.alu_m.sr[1] = get_argument("V");
	ao68000_m.alu_m.sr[2] = get_argument("Z");
	ao68000_m.alu_m.sr[3] = get_argument("N");
	ao68000_m.alu_m.sr[4] = get_argument("X");
	ao68000_m.alu_m.sr[10:8] = get_argument("IPM");
	ao68000_m.alu_m.sr[13] = get_argument("S");
	ao68000_m.alu_m.sr[15] = get_argument("T");
end
endtask

task dump_state;
begin
	$write("A0: %h\n", ao68000_m.memory_registers_m.an_ram_inst.mem_data[0]);
	$write("A1: %h\n", ao68000_m.memory_registers_m.an_ram_inst.mem_data[1]);
	$write("A2: %h\n", ao68000_m.memory_registers_m.an_ram_inst.mem_data[2]);
	$write("A3: %h\n", ao68000_m.memory_registers_m.an_ram_inst.mem_data[3]);
	$write("A4: %h\n", ao68000_m.memory_registers_m.an_ram_inst.mem_data[4]);
	$write("A5: %h\n", ao68000_m.memory_registers_m.an_ram_inst.mem_data[5]);
	$write("A6: %h\n", ao68000_m.memory_registers_m.an_ram_inst.mem_data[6]);
	$write("SSP: %h\n", ao68000_m.memory_registers_m.an_ram_inst.mem_data[7]);
	$write("USP: %h\n", ao68000_m.memory_registers_m.usp);

	$write("D0: %h\n", ao68000_m.memory_registers_m.dn_ram_inst.mem_data[0]);
	$write("D1: %h\n", ao68000_m.memory_registers_m.dn_ram_inst.mem_data[1]);
	$write("D2: %h\n", ao68000_m.memory_registers_m.dn_ram_inst.mem_data[2]);
	$write("D3: %h\n", ao68000_m.memory_registers_m.dn_ram_inst.mem_data[3]);
	$write("D4: %h\n", ao68000_m.memory_registers_m.dn_ram_inst.mem_data[4]);
	$write("D5: %h\n", ao68000_m.memory_registers_m.dn_ram_inst.mem_data[5]);
	$write("D6: %h\n", ao68000_m.memory_registers_m.dn_ram_inst.mem_data[6]);
	$write("D7: %h\n", ao68000_m.memory_registers_m.dn_ram_inst.mem_data[7]);

	$write("PC: %h\n", ao68000_m.registers_m.pc_valid);

	$write("C: %h\n", ao68000_m.alu_m.sr[0]);
	$write("V: %h\n", ao68000_m.alu_m.sr[1]);
	$write("Z: %h\n", ao68000_m.alu_m.sr[2]);
	$write("N: %h\n", ao68000_m.alu_m.sr[3]);
	$write("X: %h\n", ao68000_m.alu_m.sr[4]);
	$write("IPM: %h\n", ao68000_m.alu_m.sr[10:8]);
	$write("S: %h\n", ao68000_m.alu_m.sr[13]);
	$write("T: %h\n", ao68000_m.alu_m.sr[15]);
end
endtask

initial begin
    $display("Be sure to set the MICROPC_MAIN_LOOP define to proper value (taken from ao68000.v)");

	$dumpfile("tb_ao68000.vcd");
	$dumpvars(0);
	$dumpon();

	rst_n = 1'b0;
	#10 rst_n = 1'b1;

	while(ao68000_m.microcode_branch_m.micro_pc_0 != `MICROPC_MAIN_LOOP) #10;

	load_state();

	$display("START TEST");
	
	while(ao68000_m.microcode_branch_m.micro_pc_0 == `MICROPC_MAIN_LOOP) #10;
	while(ao68000_m.microcode_branch_m.micro_pc_0 != `MICROPC_MAIN_LOOP) #10;
	
	dump_state();

	$dumpoff();

	$finish();
end

initial begin
	#3000
	if(blocked_output == 1'b1) begin
		dump_state();
		$display("processor blocked: yes");
	end
	else begin
		$display("Time limit exceeded.");
	end
	$finish();
end

endmodule
