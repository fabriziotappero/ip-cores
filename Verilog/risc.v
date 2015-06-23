/*********************************************************
 MODULE:		Sub Level RISC uProcessor Block

 FILE NAME:	risc.v
 VERSION:	1.0
 DATE:		May 7th, 2002
 AUTHOR:		Hossein Amidi
 COMPANY:	
 CODE TYPE:	Register Transfer Level

 DESCRIPTION:	This module is the top level RTL code of RISC uProcessor verilog code. 
 
 It will instantiate the following blocks in the ASIC:

 1) Program Counter
 2) Instruction Register
 3) Accumulator
 4) Arithmatic Logic Unit
 5) Multiplexer
 6) Multiplexer
 7) Control Unit

 Hossein Amidi
 (C) April 2002

*********************************************************/

// DEFINES
`timescale 1ns / 10ps
 
// TOP MODULE
module risc(// Inputs
				reset,
				clk0,
				pll_lock,
				interrupt,
				cmdack,
				dcache_datain,
				dcache_hit,
				dcache_miss,
				icache_datain,
				icache_hit,
				icache_miss,
				dma_datain,
				dma_busy,
				timer_host_datain,
				flash_host_datain,
				uart_host_datain,
				mem_datain,
				// Outputs
				paddr,
				cmd,
				dm,
				dcache_request,
				icache_request,
				dma_dataout,
				dcache_dataout,
				icache_dataout,
				timer_host_dataout,
				flash_host_dataout,
				uart_host_dataout,
				mem_dataout,
				mem_req,
				mem_rdwr,
				halted
				);


// Parameter
`include        "parameter.v"


// Inputs
input reset;
input clk0;
input pll_lock;
input [irq_size - 1 : 0]interrupt;
input cmdack;
input [data_size - 1 : 0]dcache_datain;
input dcache_hit;
input dcache_miss;
input [data_size - 1 : 0]icache_datain;
input icache_hit;
input icache_miss;
input [data_size - 1 : 0]dma_datain;
input dma_busy;
input [data_size - 1 : 0]timer_host_datain;
input [data_size - 1 : 0]flash_host_datain;
input [data_size - 1 : 0]uart_host_datain;
input [data_size - 1 : 0]mem_datain;

// Outputs
output [padd_size - 1 : 0]paddr;
output [cmd_size  - 1 : 0]cmd;
output [dqm_size  - 1 : 0]dm;
output dcache_request;
output icache_request;
output [data_size - 1 : 0]dma_dataout;
output [data_size - 1 : 0]dcache_dataout;
output [data_size - 1 : 0]icache_dataout;
output [data_size - 1 : 0]timer_host_dataout;
output halted;
output [data_size - 1 : 0]flash_host_dataout;
output [data_size - 1 : 0]uart_host_dataout;
output [data_size - 1 : 0]mem_dataout;
output mem_req;
output mem_rdwr;

// Signal Declarations
wire reset;
wire clk0;
wire pll_lock;
wire [irq_size - 1 : 0]interrupt;
wire cmdack;
wire [data_size - 1 : 0]dcache_datain; 
wire dcache_hit;
wire dcache_miss;
wire [data_size - 1 : 0]icache_datain; 
wire icache_hit;
wire icache_miss;
wire [data_size - 1 : 0]dma_datain;
wire dma_busy;
wire [data_size - 1 : 0]timer_host_datain;
wire [data_size - 1 : 0]flash_host_datain;
wire [data_size - 1 : 0]uart_host_datain;
wire [data_size - 1 : 0]mem_datain;
wire ready;


wire [padd_size - 1 : 0]paddr;
reg [cmd_size  - 1 : 0]cmd;
reg [dqm_size  - 1 : 0]dm;
wire dcache_request;
wire icache_request;
wire [data_size - 1 : 0]dma_dataout;
wire [data_size - 1 : 0]dcache_dataout;
wire [data_size - 1 : 0]icache_dataout;
wire [data_size - 1 : 0]timer_host_dataout;
wire halted;
wire [data_size - 1 : 0]flash_host_dataout;
wire [data_size - 1 : 0]uart_host_dataout;
wire [data_size - 1 : 0]mem_dataout;
wire mem_req;
wire mem_rdwr;

reg [data_size - 1 : 0]rdma_datain;
reg rdcache_miss;
reg rdcache_hit;
reg [data_size - 1 : 0]rdcache_datain; 
reg ricache_miss;
reg ricache_hit;
reg [data_size - 1 : 0]ricache_datain; 
reg [irq_size - 1 : 0]rinterrupt;


// Assignment statments


// Signal Declerations
wire [AddrWidth - 1 : 0] instraddress;
wire [DataWidth - 1 : 0] aludataout;
wire pcinen;
wire [AddrWidth - 1 : 0] operandaddress;
wire [OpcodeWidth - 1 : 0] opcode;
wire [DataWidth - 1 : 0] datain;
wire irinen;
wire [DataWidth - 1 : 0] accdataout;
wire accneg;
wire acczero;
wire accinen;
wire [StateSize - 1 : 0] currentstate;
wire [DataWidth - 1 : 0] mux16out;
wire [AddrWidth - 1 : 0] address;
wire addresssel;
wire alusrcbsel;
wire walusrcbsel;
wire accouten;

wire memreq;
wire rdwrbar;

reg Rd_req;
reg Wr_req;
wire [DataWidth - 1 : 0] dataout;
wire Halted;
//wire [DataWidth - 1 : 0] datain;


// Assignments
assign halted = Halted;
assign ready = cmdack;
assign paddr = address;
assign datain = dcache_hit ? datain : 32'bz;
assign mem_dataout = accouten? accdataout: 32'bz;
assign Halted = (opcode == 7) ? 1'b1 : 1'b0;

assign walusrcbsel = alusrcbsel;

assign dcache_request = Rd_req | Wr_req;
assign icache_request = Rd_req | Wr_req;


assign mem_req = memreq;
assign mem_rdwr = rdwrbar;

assign dma_dataout = mem_dataout;
assign flash_host_dataout = mem_dataout;
assign dcache_dataout = mem_dataout;
assign icache_dataout = mem_dataout;
assign timer_host_dataout = mem_dataout;
assign uart_host_dataout = mem_dataout;

always @(rdwrbar or memreq)
begin
	if((memreq == 1'b1) && (rdwrbar == 1'b1))
	begin
		Rd_req = 1'b1;
		Wr_req = 1'b0;
	end
	else
	if((memreq == 1'b1) && (rdwrbar == 1'b0))
	begin
		Rd_req = 1'b0;
		Wr_req = 1'b1;
	end
	else
	begin
		Rd_req = 1'b0;
		Wr_req = 1'b0;
	end
end


always @(memreq or Wr_req or Rd_req)
begin
	case({memreq, Wr_req, Rd_req})

		3'b100:	cmd <= 3'b000;	// NOP
		3'b101:	cmd <= 3'b001;	// ReadA
		3'b110:	cmd <= 3'b010;	// WriteA
		3'b111:	cmd <= 3'b011;	// Refresh
		3'b000:	cmd <= 3'b100;	// Preacharge
		3'b001:	cmd <= 3'b101;	// Load Mode Register
		3'b010:	cmd <= 3'b110;	// Load Timing Register
		3'b011:	cmd <= 3'b111;	// Load Refresh Counter
	endcase

end

always @(posedge reset or posedge clk0)
begin
	if (reset == 1'b1)
	begin
		dm <= 4'h0;
	end
	else
	begin
		dm <= {1'b1,rinterrupt};
	end
end


always @(posedge reset or posedge clk0)
begin
	if(reset == 1'b1)
	begin
		rdma_datain <= 32'h0;
		rdcache_miss <= 1'b0;
		rdcache_hit <= 1'b0;
		rdcache_datain <= 32'h0;
		ricache_miss <= 1'b0;
		ricache_hit <= 1'b0;
		ricache_datain <= 32'h0;
		rinterrupt <= 3'b0;
	end
	else
	begin
		rdma_datain <= dma_datain;
		rdcache_miss <= dcache_miss;
		rdcache_hit <= dcache_hit & rdcache_hit;
		rdcache_datain <= dcache_datain;
		ricache_miss <= icache_miss;
		ricache_hit <= icache_hit & ricache_hit;
		ricache_datain <= icache_datain;
		rinterrupt <= interrupt;
	end
end





/***************************** Instantiation **************************/

// RISC CPU's Program Counter Instantiation
PC ProgramCounter (	// INPUT
							.clock(clk0),
							.reset(reset),
							.PCInEn(pcinen),
							.PCDataIn(aludataout[23:0]),
							// OUTPUT
							.PCDataOut(instraddress)
							);


// RISC CPU's Instruction Register Instantiation
IR InstructionRegister (	// Input
									.clock(clk0),
									.reset(reset),
									.IRInEn(irinen),
									.IRDataIn(mem_datain),
									// Output
									.OperandOut(operandaddress),
									.OpCodeOut(opcode)
									);


// RISC CPU's Accumulator Instantiation
ACC Accumulator (	// Input
						.clock(clk0),
						.reset(reset),
						.ACCInEn(accinen),
						.ACCDataIn(aludataout),
						// Output
						.ACCNeg(accneg),
						.ACCZero(acczero),
						.ACCDataOut(accdataout)
					);

	

// RISC CPU's Arithmatic Logic Unit Instantiation
ALU ALU 			(	// Input
						.ALUSrcA(accdataout),
						.ALUSrcB(mux16out),
						.OpCode(opcode),
						.CurrentState(currentstate),
						// Output
						.ALUDataOut(aludataout)
					);


MUX12 Mux12 		(	// Input
							.A_in(operandaddress),
							.B_in(instraddress),
							.A_Select(addresssel),
							// Output
							.Out(address)
						);


MUX16 Mux16 		(	// Input
							.A_in(address),
							.B_in(mem_datain),
							.A_Select(walusrcbsel),
							// Output
							.Out(mux16out)
						);



// RISC CPU's Control Unit Instantiation
CNTRL ControlUnit (	// Input
							.clock(clk0),
							.reset(reset),
							.OpCode(opcode),
							.ACCNeg(accneg),
							.ACCZero(acczero),
							.Grant(pll_lock),
							// Output
							.NextState(currentstate),
							.PCInEn(pcinen),
							.IRInEn(irinen),
							.ACCInEn(accinen),
							.ACCOutEn(accouten),
							.MemReq(memreq),
							.RdWrBar(rdwrbar),
							.AddressSel(addresssel),
							.ALUSrcBSel(alusrcbsel)
							);

endmodule
