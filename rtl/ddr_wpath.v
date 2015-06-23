//----------------------------------------------------------------------------
// Wishbone DDR Controller -- fast write data-path
// 
// (c) Joerg Bornschein (<jb@capsec.org>)
//----------------------------------------------------------------------------
`include "ddr_include.v"

module ddr_wpath (
	input                  clk,
	input                  clk90,
	input                  reset,
	// CBA async fifo
	input                  cba_clk,
	input [`CBA_RNG]       cba_din,
	input                  cba_wr,
	output                 cba_full,
	// WDATA async fifo
	input                  wdata_clk,
	input [`WFIFO_RNG]     wdata_din,
	input                  wdata_wr,
	output                 wdata_full,
	// sample to rdata
	output                 sample,
	// DDR 
	output           [2:0] ddr_clk,
	output           [2:0] ddr_clk_n,
	output                 ddr_ras_n,
	output                 ddr_cas_n,
	output                 ddr_we_n,
	output      [  `A_RNG] ddr_a,
	output      [ `BA_RNG] ddr_ba,
	output      [ `DM_RNG] ddr_dm,
	output      [ `DQ_RNG] ddr_dq,
	output      [`DQS_RNG] ddr_dqs,
 	output                 ddr_dqs_oe
);

wire gnd = 1'b0;
wire vcc = 1'b1;

//----------------------------------------------------------------------------
// CBA async. fifo
//----------------------------------------------------------------------------
wire [`CBA_RNG]        cba_data;
wire                   cba_empty;
wire                   cba_ack;

wire                   cba_avail = ~cba_empty;

async_fifo #(
	.DATA_WIDTH( `CBA_WIDTH ),
	.ADDRESS_WIDTH( 4 )
) cba_fifo (
	.Data_out(   cba_data  ),
	.Empty_out(  cba_empty ),
	.ReadEn_in(  cba_ack   ),
	.RClk(       clk       ),
	//
	.Data_in(    cba_din   ),
	.WriteEn_in( cba_wr    ),
	.Full_out(   cba_full  ),
	.WClk(       cba_clk   ),
	.Clear_in(   reset     )
);

//----------------------------------------------------------------------------
// WDATA async. fifo
//----------------------------------------------------------------------------
wire [`WFIFO_RNG]      wdata_data;
wire                   wdata_empty;
wire                   wdata_ack;

wire                   wdata_avail = ~wdata_empty;

async_fifo #(
	.DATA_WIDTH( `WFIFO_WIDTH ),
	.ADDRESS_WIDTH( 4 )
) wdata_fifo (
	.Data_out(   wdata_data  ),
	.Empty_out(  wdata_empty ),
	.ReadEn_in(  wdata_ack   ),
	.RClk(      ~clk90       ),
	//
	.Data_in(    wdata_din   ),
	.WriteEn_in( wdata_wr    ),
	.Full_out(   wdata_full  ),
	.WClk(       wdata_clk   ),
	.Clear_in(   reset       )
);


//----------------------------------------------------------------------------
// Handle CBA 
//----------------------------------------------------------------------------
reg  [3:0]      delay_count;

reg [`CBA_RNG]  ddr_cba;
wire [`CBA_RNG] CBA_NOP = { `DDR_CMD_NOP, 15'b0 };

assign cba_ack = cba_avail & (delay_count == 0);

wire [`CMD_RNG] cba_cmd = cba_data[(`CBA_WIDTH-1):(`CBA_WIDTH-3)];

always @(posedge clk)
begin
	if (reset) begin
		delay_count <= 0;
		ddr_cba     <= CBA_NOP;
	end else begin
		if (delay_count != 0) begin
			delay_count <= delay_count - 1;
			ddr_cba     <= CBA_NOP;
        end

		if (!cba_ack) begin
			ddr_cba  <= CBA_NOP;
		end else begin
			ddr_cba <= cba_data;

			case (cba_cmd)
				`DDR_CMD_MRS   : delay_count <= 2;
				`DDR_CMD_AR    : delay_count <= 14;
				`DDR_CMD_ACT   : delay_count <= 4;
				`DDR_CMD_PRE   : delay_count <= 2;
				`DDR_CMD_READ  : delay_count <= 6;   // XXX
				`DDR_CMD_WRITE : delay_count <= 8;   // XXX
			endcase
		end
	end
end
			

//----------------------------------------------------------------------------
// READ-SHIFT-REGISTER
//----------------------------------------------------------------------------
reg [7:0] read_shr;
wire      read_cmd = (cba_cmd == `DDR_CMD_READ) & cba_ack;
assign    sample   = read_shr[6];

always @(posedge clk)
begin
	if (reset)
		read_shr <= 'b0;
	else begin
		if (read_cmd)
 			read_shr <= { 8'b00011000 };
 		else
 			read_shr <= { read_shr[6:0], 1'b0 };
 	end
end

//----------------------------------------------------------------------------
// WRITE-SHIFT-REGISTER
//----------------------------------------------------------------------------

reg [0:4] write_shr;
wire      write_cmd = (cba_cmd == `DDR_CMD_WRITE) & cba_ack;

always @(posedge clk)
begin
	if (reset)
		write_shr <= 'b0;
	else begin
		if (write_cmd)
 			write_shr <= { 5'b11111 };
 		else
 			write_shr <= { write_shr[1:4], 1'b0 };
 	end
end

//----------------------------------------------------------------------------
// DDR_DQS, DDR_DQS_OE
//----------------------------------------------------------------------------
genvar i;

reg ddr_dqs_oe_reg;
assign ddr_dqs_oe = ddr_dqs_oe_reg;

always @(negedge clk)
begin
  ddr_dqs_oe_reg <= write_shr[0];
end

generate 
for (i=0; i<3; i=i+1) begin : CLK
	FDDRRSE ddr_clk_reg (
		.Q(   ddr_clk[i]   ),
		.C0(  clk90        ),
		.C1( ~clk90        ),
		.CE(  vcc          ),
		.D0(  vcc          ),
		.D1(  gnd          ),
		.R(   gnd          ),
		.S(   gnd          )
	);

	FDDRRSE ddr_clk_n_reg (
		.Q(   ddr_clk_n[i] ),
		.C0(  clk90        ),
		.C1( ~clk90        ),
		.CE(  vcc          ),
		.D0(  gnd          ),
		.D1(  vcc          ),
		.R(   gnd          ),
		.S(   gnd          )
	);
end
endgenerate

generate 
for (i=0; i<`DQS_WIDTH; i=i+1) begin : DQS
	FDDRRSE ddr_dqs_reg (
		.Q(   ddr_dqs[i]   ),
		.C0(  clk          ),
		.C1( ~clk          ),
		.CE(  vcc          ),
		.D0(  write_shr[1] ),
		.D1(  gnd          ),
		.R(   gnd          ),
		.S(   gnd          )
	);
end
endgenerate


//----------------------------------------------------------------------------
// DQ data output
//----------------------------------------------------------------------------
wire [`DQ_RNG] buf_d0;        
wire [`DM_RNG] buf_m0;
reg  [`DQ_RNG] buf_d1;       // pipleine high word data
reg  [`DM_RNG] buf_m1;       // pipleine high word mask

assign buf_d0 = wdata_data[`WFIFO_D0_RNG];
assign buf_m0 = wdata_data[`WFIFO_M0_RNG];

always @(negedge clk90)
begin
	buf_d1 <= wdata_data[`WFIFO_D1_RNG];
	buf_m1 <= wdata_data[`WFIFO_M1_RNG];
end

assign wdata_ack = write_shr[1];

// generate DDR_DQ register
generate 
for (i=0; i<`DQ_WIDTH; i=i+1) begin : DQ_REG
	FDDRRSE ddr_dq_reg (
		.Q(   ddr_dq[i]    ),
		.C0( ~clk90        ),
		.C1(  clk90        ),
		.CE(  vcc          ),
		.D0(  buf_d0[i]    ),
		.D1(  buf_d1[i]    ),
		.R(   gnd          ),
		.S(   gnd          )
	);
end
endgenerate

// generate DDR_DM register
generate 
for (i=0; i<`DM_WIDTH; i=i+1) begin : DM_REG
	FDDRRSE ddr_dm_reg (
		.Q(   ddr_dm[i]    ),
		.C0( ~clk90        ),
		.C1(  clk90        ),
		.CE(  vcc          ),
		.D0(  buf_m0[i]    ),
		.D1(  buf_m1[i]    ),
		.R(   gnd          ),
		.S(   gnd          )
	);
end
endgenerate

//----------------------------------------------------------------------------
// Connect ddr_cba to actual DDR pins
//----------------------------------------------------------------------------
assign ddr_a     = ddr_cba[(`A_WIDTH-1):0];
assign ddr_ba    = ddr_cba[(`A_WIDTH+`BA_WIDTH-1):(`A_WIDTH)];
assign ddr_ras_n = ddr_cba[(`CBA_WIDTH-1)];
assign ddr_cas_n = ddr_cba[(`CBA_WIDTH-2)];
assign ddr_we_n  = ddr_cba[(`CBA_WIDTH-3)];

endmodule
