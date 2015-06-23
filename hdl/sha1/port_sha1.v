// sha1 FCP Channel Interface

`timescale 1ns/100ps

module port_sha1(
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
//---------------- sha1 Signals 
//------------------------------------------------------------------

wire	[31:0]	sha1_data_in;
wire	[159:0]	sha1_cv_next;
wire	[159:0]	sha1_cv;
wire				sha1_load_in;
wire				sha1_start;
wire				sha1_use_prev_cv;
wire				sha1_busy;
wire				sha1_out_valid;


//------------------------------------------------------------------
//---------------- Write FSM Signals
//------------------------------------------------------------------

reg				in_sof_d;
wire				in_byte_en;
reg				in_byte_en_d;
reg				in_byte_en_dd;
reg	[159:0]	in_data_d;
reg				in_eof_d;

reg				load_byte_en;
reg				load_word_en;
reg				start;
reg				use_prev_cv;
reg				rdy;

reg [3:0]	wfsm_state;
reg [3:0]	wnext_state;

reg [3:0]	word_count;
reg			word_count_en;
reg			word_count_rst;
wire			wc_rst;
reg	[23:0]	in_word_reg;

`define WAIT			4'd0
`define LD_BYTE_0		4'd1
`define LD_BYTE_1		4'd2
`define LD_BYTE_2		4'd3
`define LD_WORD		4'd4
`define WAIT_BSY		4'd5
`define WAIT_BSY_VLD	4'd6
`define START			4'd7

//------------------------------------------------------------------
//---------------- Read FSM Signals
//------------------------------------------------------------------

reg [4:0]	rcount;
reg rcount_rst, rcount_dec, res_byte_en, rload;
reg [1:0]	rfsm_state;
reg [1:0]	rnext_state;
reg	[159:0]	out_word_reg;

`define WAIT_READ		2'd0
`define RDY_READ		2'd1
`define READING		2'd2

//------------------------------------------------------------------
//---------------- Read FSM
//------------------------------------------------------------------

assign out_byte_en = ren & out_dst_rdy;

// Next State
always @(rfsm_state or sha1_out_valid or rcount or out_byte_en)
begin
	case (rfsm_state)
	`WAIT_READ: rnext_state = sha1_out_valid ? `RDY_READ : `WAIT_READ;
	`RDY_READ: rnext_state = out_byte_en ? `READING : `RDY_READ;
	`READING: rnext_state = (rcount == 0) ? `WAIT_READ : `READING;
	default: rnext_state = `WAIT_READ;
	endcase
end

always @(posedge clk or posedge rst)
begin
	if (rst) rfsm_state <= 0;
	else rfsm_state <= rnext_state;
end

// Mealy Outputs
always @(rfsm_state or sha1_out_valid or out_byte_en or rcount)
begin
	rcount_dec = 0;
	rcount_rst = 0;
	rload = 0;
	case (rfsm_state)
	`WAIT_READ: begin
		if (sha1_out_valid)
		begin
			rload = 1;
			rcount_rst = 1;
		end
	end
	`RDY_READ: begin
		if (out_byte_en) rcount_dec = 1;
	end
	`READING: begin
		if (out_byte_en == 1) rcount_dec = 1;
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

assign in_byte_en = wen & in_src_rdy;

// Next State
always @(wfsm_state or in_byte_en or sha1_out_valid or in_sof or in_eof or word_count or sha1_busy or in_eof_d)
begin
	case (wfsm_state)
	`WAIT: wnext_state = (in_byte_en & in_sof) ? `LD_BYTE_0 : `WAIT;
	`LD_BYTE_0: wnext_state = (in_byte_en) ? `LD_BYTE_1 : `LD_BYTE_0;
	`LD_BYTE_1: wnext_state = (in_byte_en) ? `LD_BYTE_2 : `LD_BYTE_1;
	`LD_BYTE_2: wnext_state = (in_byte_en) ? `LD_WORD : `LD_BYTE_2;
	`LD_WORD: wnext_state = (in_byte_en & ~in_eof & (word_count < 15)) ? `LD_BYTE_0 :
									(in_byte_en & (word_count == 15)) ? `START : `LD_WORD;
	`WAIT_BSY: wnext_state = (~sha1_busy) ? `LD_BYTE_0 : `WAIT_BSY;
	`WAIT_BSY_VLD: wnext_state = (~sha1_busy & sha1_out_valid) ? `WAIT : `WAIT_BSY_VLD;
	`START: wnext_state = (in_eof_d) ? `WAIT_BSY_VLD : `WAIT_BSY;
	default: wnext_state = `WAIT;
	endcase
end

always @(posedge clk or posedge rst)
begin
	if (rst) wfsm_state <= 0;
	else wfsm_state <= wnext_state;
	
	if (rst)
	begin
		in_sof_d <= 0;
	   in_eof_d <= 0;
	   in_byte_en_d <= 0;
	   in_data_d <= 0;
	end
	else
	begin
		in_sof_d <= in_sof;
		in_eof_d <= in_eof;
		in_byte_en_d <= in_byte_en;
		in_data_d <= in_data;
	end
	
	if (rst) use_prev_cv <= 0;
	else if (wfsm_state == `WAIT) use_prev_cv <= 0;
	else if (wfsm_state == `WAIT_BSY) use_prev_cv <= 1;
end

assign wc_rst = rst | word_count_rst;

always @(posedge clk or posedge wc_rst)
begin
	if (wc_rst) word_count <= 0;
	else if (word_count_en) word_count <= word_count + 1;
end

// Moore Outputs
always @(wfsm_state)
begin
	load_byte_en = 0;
	load_word_en = 0;
	start = 0;
	word_count_en = 0;
	word_count_rst = 0;
	rdy = 0;
	case (wfsm_state)
	`WAIT: begin
	end
	`LD_BYTE_0: begin
		load_byte_en = 1;
		rdy = 1;
	end
	`LD_BYTE_1: begin
		load_byte_en = 1;
		rdy = 1;
	end
	`LD_BYTE_2: begin
		load_byte_en = 1;
		rdy = 1;
	end
	`LD_WORD: begin
		load_word_en = 1;
		word_count_en = in_byte_en;
		rdy = 1;
	end
	`WAIT_BSY: begin
	end
	`WAIT_BSY_VLD: begin
	end
	`START: begin
		start = 1;
		word_count_rst = 1;
	end
	endcase
end

//------------------------------------------------------------------
//---------------- rcount Register
//------------------------------------------------------------------
wire rst_or_rcount_rst;
assign rst_or_rcount_rst = rst | rcount_rst;

always @(posedge clk or posedge rst_or_rcount_rst)
begin
	if (rst_or_rcount_rst) rcount <= 5'd20;
	else if (rcount_dec) rcount <= rcount - 1;
end

//------------------------------------------------------------------
//---------------- In Word Register
//------------------------------------------------------------------

always @(posedge clk or posedge rst)
begin
	if (rst) in_word_reg <= 0;
	else if (load_byte_en & in_byte_en)
	begin
		in_word_reg[7:0]		<= in_data;
		in_word_reg[15:8]		<= in_word_reg[7:0];
		in_word_reg[23:16]	<= in_word_reg[15:8];
	end
end

//------------------------------------------------------------------
//---------------- Out Word Register
//------------------------------------------------------------------

always @(posedge clk or posedge rst)
begin
	if (rst) out_word_reg <= 0;
	else if (rload) out_word_reg <= sha1_cv_next;
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
		out_word_reg[135:128]	<= out_word_reg[127:120];
		out_word_reg[143:136]	<= out_word_reg[135:128];
		out_word_reg[151:144]	<= out_word_reg[143:136];
		out_word_reg[159:152]	<= out_word_reg[151:144];
	end
end

//------------------------------------------------------------------
//---------------- sha1 Instance
//------------------------------------------------------------------

assign sha1_start = start;
assign sha1_data_in = {in_word_reg, in_data};
assign sha1_load_in = load_word_en & in_byte_en;
assign sha1_use_prev_cv = use_prev_cv;

sha1_exec thesha1 (
	.clk(clk),
	.reset(rst),
	.start(sha1_start),
	.data_in(sha1_data_in),
	.load_in(sha1_load_in),
	.cv(160'h67452301EFCDAB8998BADCFE10325476C3D2E1F0),
	.use_prev_cv(sha1_use_prev_cv),
	.busy(sha1_busy),
	.out_valid(sha1_out_valid),
	.cv_next(sha1_cv_next)
);

//------------------------------------------------------------------
//---------------- Output Logic
//------------------------------------------------------------------

assign in_dst_rdy = rdy;
assign out_data = out_word_reg[159:152];
assign out_sof = (rfsm_state == `RDY_READ) ? 1 : 0;
assign out_eof = (rfsm_state == `READING && rcount == 0) ? 1 : 0;
assign out_src_rdy = res_byte_en;

endmodule
