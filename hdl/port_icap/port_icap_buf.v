module port_icap_buf (
// ICAP Module for PATLPP port interface

	// Inputs:
	clk,
	rst,
	en_wr,			// Write Module Enable
	en_rd,			// Read Module Enable
	in_data,			// Input Data
	in_sof,			// Input Start of Frame
	in_eof,			// Input End of Frame
	in_src_rdy,		// Input Source Ready
	out_dst_rdy,	// Output Destination Ready

	// Outputs:
	out_data,		// Output Data
	out_sof,			// Output Start of Frame
	out_eof,			// Output End of Frame
	out_src_rdy,	// Output Source Ready
	in_dst_rdy//,	// Input Destination Ready
	//chipscope_data
);

// Port mode declarations:
	// Inputs:
input	clk;
input	rst;
input	en_wr;
input	en_rd;
input	[7:0]	in_data;
input	in_sof;
input	in_eof;
input	in_src_rdy;
input	out_dst_rdy;

	// Outputs:
output	[7:0]	out_data;
output	out_sof;
output	out_eof;
output	out_src_rdy;
output	in_dst_rdy;
//output	[19:0] chipscope_data;


// Signals --------------------------------------------------------------------------------
//ICAP
wire				icap_en_n;		// ICAP enable
wire				icap_wr_n;		// ICAP write (0: write, 1: read)
wire	[7:0]		icap_din;		// ICAP Data In
wire	[7:0]		icap_dout;		// ICAP Data Out
wire				icap_busy;		// ICAP Busy
//Read FIFO
wire				rfifo_rd_en;	// Read enable
wire				rfifo_wr_en;	// Write enable
wire	[7:0]		rfifo_din;		// Data In
wire	[7:0]		rfifo_dout;		// Data Out
wire				rfifo_full;		// FIFO Full
wire				rfifo_empty;	// FIFO Empty
//Registers
reg				icap_en_r;		// ICAP Enable Register
reg				icap_wr_r;		// ICAP Write Register
reg	[7:0]		count_low_r;	// Count low bits
reg	[7:0]		count_high_r;	// Count high bits
reg	[10:0]	counter;			// Counter
reg				count_en;		// Counter Enable
reg				can_write;		// Can write to the icap
//FSM
parameter	[2:0]		IDLE = 3'b000;
parameter	[2:0]		S_WRITE = 3'b001;
parameter	[2:0]		WRITE = 3'b010;
parameter	[2:0]		E_WRITE = 3'b011;
parameter	[2:0]		I_READ = 3'b100;
parameter	[2:0]		S_READ = 3'b101;
parameter	[2:0]		READ = 3'b110;
reg	[2:0]		state;			// Current state
reg	[2:0]		next_state;		// Next State

// Instantiations -------------------------------------------------------------------------
shiftr_bram the_fifo
(
	.clk(clk),
	.rst(rst),
	.en_in(rfifo_wr_en),
	.en_out(rfifo_rd_en),
	.empty(rfifo_empty),
	.full(rfifo_full),
	.data_in(rfifo_din),
	.data_out(rfifo_dout)
);

assign rfifo_wr_en = ((state == READ) && ~icap_wr_r && ~icap_busy) ? 1'b1 : 1'b0;
assign rfifo_rd_en = en_rd & out_dst_rdy;
assign rfifo_din = icap_dout;

/* V5 Primitive */
 ICAP_VIRTEX5 #(
	.ICAP_WIDTH("X8")
) icap_inst (
	.CLK(clk),
	.CE(icap_en_n),
	.WRITE(icap_wr_n),
	.I({icap_din[0], icap_din[1], icap_din[2], icap_din[3], icap_din[4], icap_din[5], icap_din[6], icap_din[7]}),
	.BUSY(icap_busy),
	.O({icap_dout[0], icap_dout[1], icap_dout[2], icap_dout[3], icap_dout[4], icap_dout[5], icap_dout[6], icap_dout[7]})
);
/**/

/* V4 Primitive
ICAP_VIRTEX4 #(
	.ICAP_WIDTH("X8")
) icap_inst (
	.CLK(clk),
	.CE(icap_en_n),
	.WRITE(icap_wr_n),
	.I({icap_din[0], icap_din[1], icap_din[2], icap_din[3], icap_din[4], icap_din[5], icap_din[6], icap_din[7]}),
	.BUSY(icap_busy),
	.O({icap_dout[0], icap_dout[1], icap_dout[2], icap_dout[3], icap_dout[4], icap_dout[5], icap_dout[6], icap_dout[7]})
);
*/

// Test V4 ICAP
// icap_virtex4test #(
	// .ICAP_DWIDTH(8)
// ) v4testicap (
	// .clk(clk),
	// .Rst(rst),
	// .ce(icap_en_n),
	// .write(icap_wr_n),
	// .i({icap_din[0], icap_din[1], icap_din[2], icap_din[3], icap_din[4], icap_din[5], icap_din[6], icap_din[7]}),
	// .busy(icap_busy),
	// .o({icap_dout[0], icap_dout[1], icap_dout[2], icap_dout[3], icap_dout[4], icap_dout[5], icap_dout[6], icap_dout[7]})
// );

assign icap_en_n = ~icap_en_r;
assign icap_wr_n = ~icap_wr_r;
assign icap_din = in_data;

// Behavior -------------------------------------------------------------------------------

// Next State
always @(en_wr or in_src_rdy or en_rd or counter or in_eof or en_rd or state)
begin
	case (state)
	IDLE: begin
		if (en_wr & in_src_rdy)
			next_state <= S_WRITE;
		else if (en_rd & in_src_rdy)
			next_state <= I_READ;
		else
			next_state <= IDLE;
	end
	S_WRITE: begin
		if (en_wr & in_src_rdy)
			next_state <= WRITE;
		else
			next_state <= S_WRITE;
	end
	WRITE: begin
		if (en_wr & in_src_rdy & in_eof)
			next_state <= E_WRITE;
		else 
			next_state <= WRITE;
	end
	E_WRITE: begin
		next_state <= IDLE;
	end
	I_READ: begin
		 if (en_rd & in_src_rdy)
			next_state <= S_READ;
		else
			next_state <= I_READ;
	end
	S_READ: begin
		next_state <= READ;
	end
	READ: begin
		if (counter == 1)
			next_state <= IDLE;
		else
			next_state <= READ;
	end
	default: begin
		next_state <= IDLE;
	end
	endcase
end

always @(posedge clk)
begin
	state <= next_state;
end

// Registers
always @(posedge clk)
begin
	if (state == IDLE && en_rd && in_src_rdy)
	begin
		count_high_r <= in_data;
	end
	if (state == I_READ && en_rd && in_src_rdy)
	begin
		count_low_r <= in_data;
	end
	if (state == S_READ)
	begin
		counter <= {count_high_r, count_low_r};
	end
	else if (count_en)
	begin
		counter <= counter - 1;
	end
end

// Outputs
always @(state or en_wr or in_src_rdy or icap_busy or en_rd)
begin
	case (state)
	IDLE: begin
		icap_en_r = 0;
		icap_wr_r = 0;
		count_en = 0;
		can_write = en_rd;
	end
	S_WRITE: begin
		icap_en_r = 0;
		icap_wr_r = 1;
		count_en = 0;
		can_write = 0;
	end
	WRITE: begin
		icap_en_r = en_wr & in_src_rdy;
		icap_wr_r = 1;
		count_en = 0;
		can_write = 1;
	end
	E_WRITE: begin
		icap_en_r = 0;
		icap_wr_r = 1;
		count_en = 0;
		can_write = 0;
	end
	I_READ: begin
		icap_en_r = 0;
		icap_wr_r = 0;
		count_en = 0;
		can_write = 1;
	end
	S_READ: begin
		icap_en_r = 1;
		icap_wr_r = 0;
		count_en = 0;
		can_write = 0;
	end
	READ: begin
		icap_en_r = 1;
		icap_wr_r = 0;
		count_en = ~icap_busy;
		can_write = 0;
	end
	default: begin
		icap_en_r = 0;
		icap_wr_r = 0;
		count_en = 0;
		can_write = 0;
	end
	endcase
end

assign out_data = rfifo_dout;
assign out_sof = 0;
assign out_eof = 0;
assign out_src_rdy = ~rfifo_empty;
assign in_dst_rdy = can_write;


endmodule
