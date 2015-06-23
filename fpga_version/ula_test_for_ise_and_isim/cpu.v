`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:50:27 05/02/2012 
// Design Name: 
// Module Name:    cpu 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module z80memr (
	input clk,
	output [15:0] a,
	output [7:0] d,
	output mreq,
	output rd
	);
	
	reg rmreq = 1;
	reg rrd = 1;
	assign mreq = rmreq;
	assign rd = rrd;
	reg [1:0] estado = 2;
	assign d = 8'bzzzzzzzz;

	reg [15:0] ra = 16'h7FFF;
	assign a = ra;

	always @(posedge clk) begin
		if (estado==2) begin
			estado <= 0;
			ra <= ~ra;
		end
		else
			estado <= estado + 1;
	end

	always @(*) begin
		if (estado==0 && clk)
			{rmreq,rrd} = 2'b11;
		else if (estado==0 && !clk)
			{rmreq,rrd} = 2'b00;
		else if (estado==1)
			{rmreq,rrd} = 2'b00;
		else if (estado==2 && clk)
			{rmreq,rrd} = 2'b00;
		else
			{rmreq,rrd} = 2'b11;
	end
endmodule


module z80memio (
	input clk,
	output [15:0] a,
	output [7:0] d,
	output mreq_n,
	output iorq_n,
	output wr_n,
	output rfsh_n
	);
	
	reg rmreq = 1;
	reg riorq = 1;
	reg rwr = 1;
	reg rrfsh = 1;
	assign mreq_n = rmreq;
	assign iorq_n = riorq;
	assign wr_n = rwr;
	assign rfsh_n = rrfsh;
	
	reg [1:0] estado = 0;
	
	reg [5:0] memioseq = 6'b011001;
	reg [5:0] io2seq =   5'b011000;
	reg [4:0] hiloseq =  5'b01010;
	wire memio = memioseq[0];  // 0 = mem, 1 = io
	wire hilo = hiloseq[0];   // 0 = access to lower RAM/Port FEh
	wire iohi = io2seq[0];    // 0 = port 00FF/00FE, 1 = port 40FE,40FF
	

	reg [15:0] ra;
	assign a = ra;
	
	reg [7:0] rd;
	assign d = rd;
	
	reg [7:0] iodata = 0;
	reg [7:0] memdata = 0;
	reg [15:0] memaddr = 16384;

	always @(posedge clk) begin
		if (estado==2 && !memio) begin
			estado <= 0;
			memioseq <= { memioseq[0], memioseq[5:1] };
			hiloseq <= { hiloseq[0], hiloseq[4:1] };
			io2seq <= { io2seq[0], io2seq[5:1] };
			memdata <= memdata + 1;
			if (memaddr == 23295)
				memaddr <= 16384;
			else
				memaddr <= memaddr + 1;
		end
		else if (estado==3 && memio) begin
			estado <= 0;
			memioseq <= { memioseq[0], memioseq[5:1] };
			hiloseq <= { hiloseq[0], hiloseq[4:1] };
			io2seq <= { io2seq[0], io2seq[5:1] };
			iodata <= iodata + 1;
		end
		else
			estado <= estado + 1;
	end

	always @(*) begin
		if (memio) begin // if this is an I/O bus cycle...
			case ({estado,clk})
				3'b001 : begin
								{rmreq,riorq,rwr} = 3'b111;
								ra = {1'b0, iohi, 13'b0000001111111, hilo};
								rd = 8'bzzzzzzzz;
							end
				3'b000 : begin
								{rmreq,riorq,rwr} = 3'b111;
								ra = {1'b0, iohi, 13'b0000001111111, hilo};
								rd = iodata;
							end
				3'b011,3'b010,3'b101,3'b100,3'b111 : 
				         begin
								{rmreq,riorq,rwr} = 3'b100;
								ra = {1'b0, iohi, 13'b0000001111111, hilo};
								rd = iodata;
							end
				3'b110 : begin
								{rmreq,riorq,rwr} = 3'b111;
								ra = {1'b0, iohi, 13'b0000001111111, hilo};
								rd = iodata;
							end
			endcase
		end
		else begin	// this is a MEM bus cycle
			case ({estado,clk})
				3'b001 : begin
								{rmreq,riorq,rwr} = 3'b111;
								ra = {hilo,memaddr[14:0]};
								rd = 8'bzzzzzzzz;
							end
				3'b000,3'b011 :
				         begin
								{rmreq,riorq,rwr} = 3'b011;
								ra = {hilo,memaddr[14:0]};
								rd = memdata;
							end
				3'b010,3'b101 :
				         begin
								{rmreq,riorq,rwr} = 3'b010;
								ra = {hilo,memaddr[14:0]};
								rd = memdata;
							end
				3'b100 : begin
								{rmreq,riorq,rwr} = 3'b111;
								ra = {hilo,memaddr[14:0]};
								rd = memdata;
							end
			endcase
		end
	end
endmodule
