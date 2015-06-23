// PATLPP - PATL Packet Processor
// Application Specific Processor for packet processing
// 
// Instruction set is limited to data movement, FIFO operations, and compares
//

`timescale 1ns / 100ps

module patlpp
(
	input				en, // module enable
	input				clk, // module clock
	input				rst, // module reset

	input				in_sof, // start of frame input
	input				in_eof, // end of frame input
	input				in_src_rdy, // source of input ready
	output			in_dst_rdy, // this module destination ready

	output			out_sof, // start of frame output
	output			out_eof, // end of frame output
	output			out_src_rdy, // this module source ready
	input				out_dst_rdy, // destination of output ready

	input		[7:0]	in_data, // data input
	output	[7:0]	out_data, // data output / port output
	output	[3:0] outport_addr, // Output Port address
	output	[3:0] inport_addr//, // Input Port address
	//output	[11:0] chipscope_data
);

// Parameters ----------------------------------------------------------------


// Internal wires ------------------------------------------------------------
// - Instruction wires
wire				srst; // Soft reset
wire				high_byte_reg_en; // High byte register enable
wire				output_byte_s; // Output byte select
wire				outport_reg_en; // Output Port Register Enable
wire				inport_reg_en; // Input Port Register Enable
wire	[2:0]		data_mux_s; // data mux select
wire	[1:0]		op_0_s; // Operand 0 Select
wire				op_1_s; // Operand 1 Select

wire	[3:0]		reg_addr; // register file address
wire	[1:0]		reg_wen; // write enable of higher and lower order byte in register file
wire				fcs_add; // add to checksum
wire				fcs_clear; // clear checksum

wire				sr1_in_en; // shift register 1 input enable
wire				sr2_in_en; // shift register 2 input enable
wire				sr1_out_en; // shift register 1 output enable
wire				sr2_out_en; // shift register 2 output enable

wire				flag_reg_en; // Flag register enable
wire	[2:0]		comp_mode; // Compare mode
wire	[1:0]		alu_op; // ALU Operation

wire	[7:0]		const_byte; // byte constant
wire	[15:0]	const_word; // word constant

// - Intruction logic inputs
wire				comp_res; // comparator result
wire				fcs_check; // asserted if checksum == 0

// - Datapath wires
wire	[15:0]		op0_data; // operand 0 data
wire	[15:0]		op1_data; // operand 1 data
wire	[15:0]		alu_res_data; // ALU result

wire	[7:0]			sr1_data_in; // shift register 1 data input
wire	[7:0]			sr2_data_in; // shift register 2 data input
wire	[7:0]			sr1_data_out; // shift register 1 data output
wire	[7:0]			sr2_data_out; // shift register 2 data output

wire	[7:0]			sr_data_out; // Muxed shift register data

wire	[15:0]		word_data; // word data line
wire	[15:0]		mux_output_data; // output data line

wire	[15:0]		reg_data_out; // register file output
wire	[15:0]		reg_data_in;

wire	[15:0]		checksum_data_in;
wire	[15:0]		checksum_data_out;

wire	[15:0]		alu_op0;
wire	[15:0]		alu_op1;

wire	[7:0]			output_high_byte;
wire	[7:0]			output_low_byte;

reg	[7:0]			flag_reg;
reg	[3:0]			outport_reg;
reg	[3:0]			inport_reg;

// Wire Connections ----------------------------------------------------------

// Chipscope
//assign chipscope_data[11:8] = port_addr;


// Block Instantiations ------------------------------------------------------
microcodelogic mcodelogic_inst 
(
	.clk(clk),
	.rst(rst),
	.srst(srst),

	.sof_in(in_sof),
	.eof_in(in_eof),
	.src_rdy_in(in_src_rdy),
	.dst_rdy_in(in_dst_rdy),

	.sof_out(out_sof),
	.eof_out(out_eof),
	.src_rdy_out(out_src_rdy),
	.dst_rdy_out(out_dst_rdy),

	.high_byte_reg_en(high_byte_reg_en),
	.output_byte_s(output_byte_s),
	.outport_reg_en(outport_reg_en),
	.inport_reg_en(inport_reg_en),
	.data_mux_s(data_mux_s),
	.op_0_s(op_0_s),
	.op_1_s(op_1_s),
	
	.reg_addr(reg_addr),
	.reg_wen(reg_wen),
	
	.fcs_add(fcs_add),
	.fcs_clear(fcs_clear),
	.fcs_check(fcs_check),
	
	.sr1_in_en(sr1_in_en),
	.sr2_in_en(sr2_in_en),
	.sr1_out_en(sr1_out_en),
	.sr2_out_en(sr2_out_en),
	
	.flag_reg_en(flag_reg_en),
	.comp_mode(comp_mode),
	.comp_res(comp_res),
	
	.alu_op(alu_op),
	.const_byte(const_byte),
	.const_word(const_word)//,
	//.chipscope_data(chipscope_data[7:0])
);

comparelogic comp_inst
(
	.data(alu_res_data),
	.mode(comp_mode[1:0]),
	.result(comp_res)
);

lpm_stopar #(
	.WIDTH(8),
	.DEPTH(2)
) in_sr (
	.clk(clk),
	.rst(rst),
	.en(high_byte_reg_en),
	.sin(in_data),
	.pout(word_data)
);

regfile regfile_inst
(
	.clk(clk),
	.rst(rst),
	.wren_low(reg_wen[0]),
	.wren_high(reg_wen[1]),
	.address(reg_addr),
	.data_in(reg_data_in),
	.data_out(reg_data_out)
);

shiftr sr1
(
	.en_in(sr1_in_en),
	.en_out(sr1_out_en),
	.clk(clk),
	.rst(rst),
	.srst(srst),
	.data_in(sr1_data_in),
	.data_out(sr1_data_out)
);

shiftr sr2
(
	.en_in(sr2_in_en),
	.en_out(sr2_out_en),
	.clk(clk),
	.rst(rst),
	.srst(srst),
	.data_in(sr2_data_in),
	.data_out(sr2_data_out)
);

checksum checksum_inst
(
	.clk(clk),
	.rst(rst),

	.data_in(checksum_data_in),
	.checksum_add(fcs_add),
	.checksum_clear(fcs_clear),

	.checksum_check(fcs_check),
	.checksum_out(checksum_data_out)
);

assign alu_op0 = { ( {8{~comp_mode[2]}} & op0_data[15:8] ), op0_data[7:0] };
assign alu_op1 = { ( {8{~comp_mode[2]}} & op1_data[15:8] ), op1_data[7:0] };

alunit alunit_inst
(
	.op0(alu_op0),
	.op1(alu_op1),
	.op(alu_op),
	.res(alu_res_data)
);

lpm_mux8 #(
	.WIDTH(16)
) main_mux
(
	.in0(const_word),
	.in1(checksum_data_out),
	.in2(reg_data_out),
	.in3(word_data),
	.in4({ 8'd0, sr_data_out}),
	.in5(alu_res_data),
	.in6({ 8'd0, flag_reg}),
	.in7(16'd0),
	.s(data_mux_s),
	.out(mux_output_data)
);

lpm_mux4 #(
	.WIDTH(16)
) mux_op0
(
	.in0(const_word),
	.in1(word_data),
	.in2({ 8'd0, flag_reg}),
	.in3(reg_data_out),
	.s(op_0_s),
	.out(op0_data)
);

lpm_mux2 #(
	.WIDTH(16)
) mux_op1
(
	.in0(const_word),
	.in1(reg_data_out),
	.s(op_1_s),
	.out(op1_data)
);

lpm_mux2 #(
	.WIDTH(8)
) mux_byte_select
(
	.in0(output_low_byte),
	.in1(output_high_byte),
	.s(output_byte_s),
	.out(out_data)
);

lpm_mux2 #(
	.WIDTH(8)
) sr_data_mux
(
	.in0(sr1_data_out),
	.in1(sr2_data_out),
	.s(sr2_out_en),
	.out(sr_data_out)
);

// Block Connections ---------------------------------------------------------
//

assign checksum_data_in = mux_output_data;
assign reg_data_in = mux_output_data;
assign sr1_data_in = mux_output_data[7:0];
assign sr2_data_in = mux_output_data[7:0];
assign output_low_byte = mux_output_data[7:0];
assign output_high_byte = mux_output_data[15:8];

// Flag Register -------------------------------------------------------------
//

always @(posedge clk)
begin
	if (rst || srst)
		flag_reg <= 0;
	else if (flag_reg_en)
	begin
		flag_reg <= {4'b0000, fcs_check, comp_res, in_eof, in_sof};
	end
end

// Port Address Registers ----------------------------------------------------
//
always @(posedge clk)
begin
	if (rst || srst)
	begin
		outport_reg <= 0;
		inport_reg <= 0;
	end
	else
	begin
		if (outport_reg_en)
			outport_reg <= mux_output_data[3:0];
		if (inport_reg_en)
			inport_reg <= mux_output_data[3:0];
	end
end

assign outport_addr = outport_reg;
assign inport_addr = inport_reg;

// Simulation Code -----------------------------------------------------------
//
integer file;

initial
begin
	file = $fopen("outframe.hex");
end

always @(posedge clk)
begin
	if (data_mux_s == 2 || op_1_s == 1)
	begin
		$display("Read from Reg %d: %h", reg_addr, reg_data_out);
	end
	if (reg_wen)
	begin
		$display("Written to Reg %d: %h", reg_addr, reg_data_in);
	end
	if (srst)
		$display("Reset Occured");
	if (out_src_rdy && out_dst_rdy)
	begin
		$display("Output to Port %d: %h", outport_addr, out_data);
		if (outport_addr == 0)
			$fdisplay(file, "%h", out_data);
	end
	if (in_src_rdy && in_dst_rdy)
	begin
		$display("Input From Port %d: %h", inport_addr, in_data);
	end
	if (data_mux_s == 5)
	begin
		$display("ALU Function: %d on Op0: %d and Op1: %d", alu_op, op_0_s, op_1_s);
	end
end


endmodule 
