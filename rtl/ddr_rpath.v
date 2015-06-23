//----------------------------------------------------------------------------
// Wishbone DDR Controller
// 
// (c) Joerg Bornschein (<jb@capsec.org>)
//----------------------------------------------------------------------------

`include "ddr_include.v"

module ddr_rpath
(
	input                  clk,
	input                  reset,
	// sample activate
	input                  sample,
	// RDATA async fifo
	input                  rfifo_clk,
	output                 rfifo_empty,
	output [`RFIFO_RNG]    rfifo_dout,
	input                  rfifo_next,
	// DDR 
	input [ `DQ_RNG]       ddr_dq,
	input [`DQS_RNG]       ddr_dqs
);

//----------------------------------------------------------------------------
// RDATA async. fifo
//----------------------------------------------------------------------------

wire [`RFIFO_RNG]      rfifo_din;
wire                   rfifo_wr;
wire                   rfifo_full;

async_fifo #(
	.DATA_WIDTH( `RFIFO_WIDTH ),
	.ADDRESS_WIDTH( 4 )
) rfifo (
	.Data_out(   rfifo_dout  ),
	.Empty_out(  rfifo_empty ),
	.ReadEn_in(  rfifo_next  ),
	.RClk(       rfifo_clk   ),
	//
	.Data_in(    rfifo_din   ),
	.WriteEn_in( rfifo_wr    ),
	.Full_out(   rfifo_full  ),
	.WClk(      ~clk         ),
	.Clear_in(   reset       )
);


//----------------------------------------------------------------------------
// Clean up incoming 'sample' signal and generate sample_dq
//----------------------------------------------------------------------------

// anti-meta-state
//reg       sample180; 
//always @(negedge clk) sample180 <= sample;
wire sample180 = sample;


reg       sample_dq;          // authoritive sample flag (after cleanup)
reg       sample_dq_delayed;  // write to rfifo?
reg [3:0] sample_count;       // make sure sample_dq is up exactly 
                              // BURSTLENGTH/2 cycles

always @(posedge clk or posedge reset)
begin
	if (reset) begin
		sample_dq         <= 0;
		sample_dq_delayed <= 0;
		sample_count      <= 0;
	end else begin
		sample_dq_delayed <= sample_dq;
		if (sample_count == 0) begin
			if (sample180) begin
				sample_dq    <= 1;
				sample_count <= 1;
			end
		end else if (sample_count == 4) begin
			sample_dq    <= 0;
			sample_count <= 0;
		end else
			sample_count <= sample_count + 1;
			
	end
end

//----------------------------------------------------------------------------
// Sampe DQ and fill RFIFO
//----------------------------------------------------------------------------
reg [15:0] ddr_dq_low, ddr_dq_high;

always @(negedge clk )
begin
	if (reset)
		ddr_dq_low <= 'b0;
	else
		ddr_dq_low <= ddr_dq;
end

always @(posedge clk)
begin
	if (reset)
		ddr_dq_high <= 'b0;
	else
		ddr_dq_high <= ddr_dq;
end

assign rfifo_wr  = sample_dq_delayed;
assign rfifo_din = { ddr_dq_high, ddr_dq_low };

endmodule

