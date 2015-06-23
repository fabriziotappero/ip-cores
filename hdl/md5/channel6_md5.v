// MD5 FCP Channel Interface

`timescale 1ns/100ps

module channel6(
	input					clk,
	input					rst,
	input					wen,
	input					ren,
	input					in_sof,
	input					in_eof,
	input					in_src_rdy,
	output				in_dst_rdy,
	input		[7:0]		in_data,
	
	output				out_sof,
	output				out_eof,
	input					out_dst_rdy,
	output				out_src_rdy,
	output	[7:0]		out_data
);


//------------------------------------------------------------------
//---------------- Functions
//------------------------------------------------------------------

function [31:0] littleEndianize;
	input [31:0] in_word;
	begin
		littleEndianize[7:0] = in_word[31:24];
		littleEndianize[15:8] = in_word[23:16];
		littleEndianize[23:16] = in_word[15:8];
		littleEndianize[31:24] = in_word[7:0];
	end
endfunction

//------------------------------------------------------------------
//---------------- MD5 Signals 
//------------------------------------------------------------------

wire	[127:0]	md5_data_i;
wire	[127:0]	md5_data_o;
wire				md5_load_i;
wire				md5_newtext_i;
wire				md5_ready_o;
wire				md5_reset_n;

//------------------------------------------------------------------
//---------------- Control Signals
//------------------------------------------------------------------

wire				load_next_byte;
wire				in_byte_en;
wire				out_byte_en;
reg	[127:0]	in_word_reg;
reg	[127:0]	out_word_reg;
wire				ready;


//------------------------------------------------------------------
//---------------- Write FSM Signals
//------------------------------------------------------------------

reg rdy, wload;
reg [3:0]	wcount;
reg wcount_en, newtext_en, wcount_rst;
reg [1:0]	wrdcount;
reg 			wrdcount_en;
reg [2:0] wfsm_state;
reg [2:0] wnext_state;

`define INIT			3'd0
`define NEW_TEXT		3'd1
`define LOAD_WORD		3'd2
`define FILL_WORD		3'd3
`define LOAD_MD5		3'd4

//------------------------------------------------------------------
//---------------- Read FSM Signals
//------------------------------------------------------------------

reg [3:0]	rcount;
reg rcount_rst, rcount_dec, res_byte_en, rload;
reg [1:0]	rfsm_state;
reg [1:0]	rnext_state;

`define WAIT_READ		2'd0
`define RDY_READ		2'd1
`define READING		2'd2

//------------------------------------------------------------------
//---------------- Read FSM
//------------------------------------------------------------------

assign out_byte_en = ren & out_dst_rdy;

// Next State
always @(rfsm_state or ready or rcount or out_byte_en)
begin
	case (rfsm_state)
	`WAIT_READ: rnext_state = ready ? `RDY_READ : `WAIT_READ;
	`RDY_READ: rnext_state = out_byte_en ? `READING : `RDY_READ;
	`READING: rnext_state = (rcount == 0 && out_byte_en == 1) ? `WAIT_READ : `READING;
	default: rnext_state = `WAIT_READ;
	endcase
end

always @(posedge clk or posedge rst)
begin
	if (rst) rfsm_state <= 0;
	else rfsm_state <= rnext_state;
end

// Mealy Outputs
always @(rfsm_state or ready or out_byte_en or rcount)
begin
	rcount_dec = 0;
	rcount_rst = 0;
	rload = 0;
	case (rfsm_state)
	`WAIT_READ: begin
		if (ready)
		begin
			rload = 1;
			rcount_rst = 1;
		end
	end
	`RDY_READ: begin
		if (out_byte_en) rcount_dec = 1;
	end
	`READING: begin
		if (rcount > 0 && out_byte_en == 1) rcount_dec = 1;
	end
	endcase
end

// Moore Output
always @(rfsm_state)
begin
	case (rfsm_state)
	`WAIT_READ: res_byte_en = 0;
	`RDY_READ: res_byte_en = 1;
	`READING: res_byte_en = 1;
	default: res_byte_en = 0;
	endcase
end

//------------------------------------------------------------------
//---------------- Write FSM
//------------------------------------------------------------------

assign load_next_byte = wcount_en;
assign in_byte_en = wen & in_src_rdy;

// Next State
always @(wfsm_state or in_byte_en or wcount or ready)
begin
	case (wfsm_state)
	`INIT: wnext_state = in_byte_en ? `NEW_TEXT : `INIT;
	`NEW_TEXT: wnext_state = (in_byte_en == 1) ? `LOAD_WORD : `NEW_TEXT;
	`LOAD_WORD: wnext_state = (in_byte_en == 1 && wcount == 15) ? `FILL_WORD : `LOAD_WORD;
	`FILL_WORD: wnext_state = `LOAD_MD5;
	`LOAD_MD5: wnext_state = (ready == 1 || wrdcount != 0) ? `INIT : `LOAD_MD5;
	default: wnext_state = `INIT;
	endcase
end

always @(posedge clk or posedge rst)
begin
	if (rst) wfsm_state <= 0;
	else wfsm_state <= wnext_state;
end

// Moore Outputs
always @(wfsm_state)
begin
	case (wfsm_state)
	`INIT: begin
		rdy = 0;
		wload = 0;
		wrdcount_en = 0;
	end
	`NEW_TEXT: begin
		rdy = 1;
		wload = 0;
		wrdcount_en = 0;
	end
	`LOAD_WORD: begin
		rdy = 1;
		wload = 0;
		wrdcount_en = 0;
	end
	`FILL_WORD: begin
		rdy = 0;
		wload = 1;
		wrdcount_en = 1;
	end
	`LOAD_MD5: begin
		rdy = 0;
		wload = 0;
		wrdcount_en = 0;
	end
	endcase
end

// Mealy Outputs
always @(wfsm_state or in_byte_en or wcount or ready)
begin
	wcount_en = 0;
	wcount_rst = 0;
	newtext_en = 0;
	case (wfsm_state)
	`INIT: begin
		if (in_byte_en) begin
			wcount_en = 0;
			newtext_en = 1;
		end
	end
	`NEW_TEXT: begin
		if (in_byte_en) begin
			wcount_en = 1;
		end
	end
	`LOAD_WORD: begin
		if (in_byte_en == 1 && wcount <= 15) begin
			wcount_en = 1;
		end
	end
	`LOAD_MD5: begin
		wcount_rst = 1;
	end
	endcase
end

//------------------------------------------------------------------
//---------------- wcount Register
//------------------------------------------------------------------
wire rst_or_wcount_rst;
assign rst_or_wcount_rst = rst | wcount_rst;

always @(posedge clk or posedge rst_or_wcount_rst)
begin
	if (rst_or_wcount_rst) wcount <= 0;
	else if (wcount_en) wcount <= wcount + 1;
end

//------------------------------------------------------------------
//---------------- wrdcount Register
//------------------------------------------------------------------

always @(posedge clk or posedge rst)
begin
	if (rst) wrdcount <= 0;
	else if (wrdcount_en) wrdcount <= wrdcount + 1;
end

//------------------------------------------------------------------
//---------------- rcount Register
//------------------------------------------------------------------
wire rst_or_rcount_rst;
assign rst_or_rcount_rst = rst | rcount_rst;

always @(posedge clk or posedge rst_or_rcount_rst)
begin
	if (rst_or_rcount_rst) rcount <= 4'hF;
	else if (rcount_dec) rcount <= rcount - 1;
end

//------------------------------------------------------------------
//---------------- In Word Register
//------------------------------------------------------------------

always @(posedge clk or posedge rst)
begin
	if (rst) in_word_reg <= 0;
	else if (load_next_byte)
	begin
		in_word_reg[7:0]		<= in_data;
		in_word_reg[15:8]		<= in_word_reg[7:0];
		in_word_reg[23:16]	<= in_word_reg[15:8];
		in_word_reg[31:24]	<= in_word_reg[23:16];
		in_word_reg[39:32]	<= in_word_reg[31:24];
		in_word_reg[47:40]	<= in_word_reg[39:32];
		in_word_reg[55:48]	<= in_word_reg[47:40];
		in_word_reg[63:56]	<= in_word_reg[55:48];
		in_word_reg[71:64]	<= in_word_reg[63:56];
		in_word_reg[79:72]	<= in_word_reg[71:64];
		in_word_reg[87:80]	<= in_word_reg[79:72];
		in_word_reg[95:88] 	<= in_word_reg[87:80];
		in_word_reg[103:96]	<= in_word_reg[95:88];
		in_word_reg[111:104]	<= in_word_reg[103:96];
		in_word_reg[119:112]	<= in_word_reg[111:104];
		in_word_reg[127:120]	<= in_word_reg[119:112];
	end
end

//------------------------------------------------------------------
//---------------- Out Word Register
//------------------------------------------------------------------

always @(posedge clk or posedge rst)
begin
	if (rst) out_word_reg <= 0;
	else if (rload) out_word_reg <= { littleEndianize(md5_data_o[127:96]), littleEndianize(md5_data_o[95:64]), littleEndianize(md5_data_o[63:32]), littleEndianize(md5_data_o[31:0]) };
	else if (res_byte_en & out_byte_en)
	begin
		out_word_reg[7:0]			<= 0;
		out_word_reg[15:8]		<= out_word_reg[7:0];
		out_word_reg[23:16]		<= out_word_reg[15:8];
		out_word_reg[31:24]		<= out_word_reg[23:16];
		out_word_reg[39:32]		<= out_word_reg[31:24];
		out_word_reg[47:40]		<= out_word_reg[39:32];
		out_word_reg[55:48]		<= out_word_reg[47:40];
		out_word_reg[63:56]		<= out_word_reg[55:48];
		out_word_reg[71:64]		<= out_word_reg[63:56];
		out_word_reg[79:72]		<= out_word_reg[71:64];
		out_word_reg[87:80]		<= out_word_reg[79:72];
		out_word_reg[95:88] 		<= out_word_reg[87:80];
		out_word_reg[103:96]		<= out_word_reg[95:88];	
		out_word_reg[111:104]	<= out_word_reg[103:96];
		out_word_reg[119:112]	<= out_word_reg[111:104];
		out_word_reg[127:120]	<= out_word_reg[119:112];
	end
end

//------------------------------------------------------------------
//---------------- MD5 Instance
//------------------------------------------------------------------

assign md5_data_i = { littleEndianize(in_word_reg[127:96]), littleEndianize(in_word_reg[95:64]), littleEndianize(in_word_reg[63:32]), littleEndianize(in_word_reg[31:0]) };
assign md5_newtext_i = newtext_en & in_sof;
assign md5_load_i = wload;
assign md5_reset_n = ~rst;
assign ready = md5_ready_o;

md5 themd5 (
	.clk(clk),
	.reset(md5_reset_n),
	.load_i(md5_load_i),
	.ready_o(md5_ready_o),
	.newtext_i(md5_newtext_i),
	.data_i(md5_data_i),
	.data_o(md5_data_o)
);

//------------------------------------------------------------------
//---------------- Output Logic
//------------------------------------------------------------------

assign in_dst_rdy = rdy;
assign out_data = out_word_reg[127:120];
assign out_sof = (rfsm_state == `RDY_READ) ? 1 : 0;
assign out_eof = (rfsm_state == `READING && rcount == 0) ? 1 : 0;
assign out_src_rdy = res_byte_en;

endmodule
