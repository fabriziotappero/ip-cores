// Microcode support logic
// Author: Peter Lieber
//

module microcodelogic
(
	input		wire				clk,
	input		wire				rst,
	output	wire				srst,

	input		wire				sof_in,
	input		wire				eof_in,
	input		wire				src_rdy_in,
	output	wire				dst_rdy_in, //

	output	wire				sof_out, //
	output	wire				eof_out, //
	output	wire				src_rdy_out, //
	input		wire				dst_rdy_out,
	
	output	wire				high_byte_reg_en, //
	output	wire				output_byte_s,
	output	wire				outport_reg_en,
	output	wire				inport_reg_en,
	output	wire	[2:0]		data_mux_s,
	output	wire	[1:0]		op_0_s,
	output	wire				op_1_s,
	
	output	wire	[3:0]		reg_addr, //
	output	wire	[1:0]		reg_wen, //
	
	output	wire				fcs_add,
	output	wire				fcs_clear,
	input		wire				fcs_check,
	
	output	wire				sr1_in_en, //
	output	wire				sr2_in_en, //
	output	wire				sr1_out_en, //
	output	wire				sr2_out_en, //
	
	output	wire				flag_reg_en,

	output	wire	[2:0]		comp_mode, //
	input		wire				comp_res,
	
	output	wire	[1:0]		alu_op, //

	output	wire	[7:0]		const_byte,
	output	wire	[15:0]	const_word//, // Word Constant
	//output	wire	[7:0]		chipscope_data
);

reg	[8:0]		pc;
wire	[66:0]	instruction_word; // entire instruction word
wire				pred_src_rdy; // source ready predicated execution
wire				pred_dst_rdy; // destination ready predicated execution
wire				pred_comp; // compare true predicated execution
wire				pred_sof; // Start of Frame predicated execution
wire				pred_eof; // End of Frame predicated execution
wire				pred_cs; // Checksum Predicate
wire				pred; // execution enabling predicate composite
wire	[1:0]		pred_type; // type of predication: until(0) or when(1) or if(2)
wire				reset; // reset program to pc=0
wire				jump; // Jump flag
wire	[8:0]		const_jmp;

// Chipscope
//assign chipscope_data = pc[7:0];

microcodesrc codesource (
	.addr(pc),
	.code(instruction_word)
);

assign pred					= ((pred_src_rdy == 0 && pred_dst_rdy == 0 && pred_comp == 0 && pred_sof == 0 && pred_eof == 0 && pred_cs == 0) || 
									!((pred_src_rdy == 1 && src_rdy_in == 0) || 
									  (pred_dst_rdy == 1 && dst_rdy_out == 0) || 
									  (pred_comp == 1 && comp_res == 0) || 
								     (pred_sof == 1 && sof_in == 0) || 
								     (pred_eof == 1 && eof_in == 0) ||
								  	  (pred_cs == 1 && fcs_check == 0)));

assign const_word				= instruction_word[15:0];
assign const_jmp				= instruction_word[24:16];

assign alu_op					= instruction_word[26:25];
assign comp_mode				= instruction_word[29:27];

assign flag_reg_en			= instruction_word[30] & (pred | (pred_type == 1));

assign sr2_out_en				= instruction_word[31] & (pred | (pred_type == 1));
assign sr1_out_en				= instruction_word[32] & (pred | (pred_type == 1));
assign sr2_in_en				= instruction_word[33] & (pred | (pred_type == 1));
assign sr1_in_en				= instruction_word[34] & (pred | (pred_type == 1));

assign fcs_clear				= instruction_word[35] & (pred | (pred_type == 1));
assign fcs_add					= instruction_word[36] & (pred | (pred_type == 1));

assign reg_wen					= instruction_word[38:37] & {2{(pred | (pred_type == 1))}};
assign reg_addr				= instruction_word[42:39];

assign op_1_s					= instruction_word[43];
assign op_0_s					= instruction_word[45:44];
assign data_mux_s				= instruction_word[48:46];
assign inport_reg_en			= instruction_word[49];
assign outport_reg_en		= instruction_word[50];
assign output_byte_s			= instruction_word[51];
assign high_byte_reg_en		= instruction_word[52];

assign pred_src_rdy			= instruction_word[53];
assign pred_dst_rdy			= instruction_word[54];
assign pred_comp				= instruction_word[55];
assign pred_sof				= instruction_word[56];
assign pred_eof				= instruction_word[57];
assign pred_cs					= instruction_word[58];
assign pred_type				= instruction_word[60:59];

assign eof_out					= instruction_word[61];// & (pred);// | pred_type);
assign sof_out					= instruction_word[62];// & (pred);// | pred_type);
assign src_rdy_out			= instruction_word[63];// & (pred | (pred_type == 1));
assign dst_rdy_in				= instruction_word[64];// & (pred | (pred_type == 1));

assign reset					= instruction_word[65] & (pred);
assign jump						= instruction_word[66] & (pred);

assign srst						= reset;
assign const_byte				= const_jmp[7:0];

// Microcode PC control
always@(posedge clk)
begin
	if (rst == 1)
	begin
		pc <= 0;
	end
	else	if (reset)
	begin
		pc <= 0;
	end
	else if (jump)
	begin
		pc <= const_jmp;
	end
	else if (pred || (pred_type == 2))
	begin
		pc <= pc + 1;
	end
end

endmodule
