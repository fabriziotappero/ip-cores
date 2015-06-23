//----------------------------------------------------------------------------
// Pipelined, asyncronous DDR Controller
//
// (c) Joerg Bornschein (<jb@capsec.org>)
//----------------------------------------------------------------------------
`include "ddr_include.v"

module ddr_ctrl 
#(
	parameter phase_shift  = 0,
	parameter clk_multiply = 12,
	parameter clk_divide   = 5,
	parameter wait200_init = 26
) (
	input                   clk, 
	input                   reset,
	// Temporary DCM control input
	input  [2:0]            rot,     // XXX
	//  DDR ports
	output                  ddr_clk,
	output                  ddr_clk_n,
	input                   ddr_clk_fb,
	output                  ddr_ras_n,
	output                  ddr_cas_n,
	output                  ddr_we_n,
	output                  ddr_cke,
	output                  ddr_cs_n,
	output [  `A_RNG]       ddr_a,
	output [ `BA_RNG]       ddr_ba,
	inout  [ `DQ_RNG]       ddr_dq,
	inout  [`DQS_RNG]       ddr_dqs,
	output [ `DM_RNG]       ddr_dm,
	// FML (FastMemoryLink)
	output reg              fml_done,
	input  [`FML_ADR_RNG]   fml_adr,
	input                   fml_rd,
	input                   fml_wr,
	input  [`FML_DAT_RNG]   fml_wdat,
	input  [`FML_BE_RNG]    fml_wbe,
	input                   fml_wnext,
	output                  fml_rempty,
	input                   fml_rnext,
	output [`FML_DAT_RNG]   fml_rdat
);

wire [ `DQ_RNG]       ddr_dq_i,  ddr_dq_o;
wire [`DQS_RNG]       ddr_dqs_i, ddr_dqs_o;
wire                  ddr_dqs_oe;

//----------------------------------------------------------------------------
// clock generator
//----------------------------------------------------------------------------
wire clk_locked;
wire write_clk, write_clk90;
wire read_clk;

wire reset_int = reset | ~clk_locked;

ddr_clkgen #(
	.phase_shift(  phase_shift  ),
	.clk_multiply( clk_multiply ),
	.clk_divide(   clk_divide   )
) clkgen (
	.clk(             clk            ),
	.reset(           reset          ),
	.locked(          clk_locked     ),
	// ddr-clk 
	.write_clk(       write_clk      ),
	.write_clk90(     write_clk90    ),
	// ddr-read-clk
	.ddr_clk_fb(      ddr_clk_fb     ),
	.read_clk(        read_clk       ),
	// phase shift control
	.rot(             rot            )      // XXX
);

//----------------------------------------------------------------------------
// async_fifos (cmd, wdata, rdata)
//----------------------------------------------------------------------------
wire                  cba_fifo_full;
reg  [`CBA_RNG]       cba_fifo_din;
reg                   cba_fifo_we;

wire                  wfifo_full;
wire  [`WFIFO_RNG]    wfifo_din;
wire                  wfifo_we;

wire [`RFIFO_RNG]     rfifo_dout;
wire                  rfifo_empty;
wire                  rfifo_next;

assign wfifo_din  = { ~fml_wbe, fml_wdat };
assign wfifo_we   = fml_wnext;

assign fml_rdat   = rfifo_dout;
assign fml_rempty = rfifo_empty;
assign rfifo_next = fml_rnext;

//----------------------------------------------------------------------------
// High-speed cmd, write and read datapath
//----------------------------------------------------------------------------
ddr_wpath wpath0 (
	.clk(         write_clk    ),
	.clk90(       write_clk90  ),
	.reset(       reset_int    ),
	// CBA async fifo
	.cba_clk(     clk           ),
	.cba_din(     cba_fifo_din  ),
	.cba_wr(      cba_fifo_we   ),
	.cba_full(    cba_fifo_full ),
	// WDATA async fifo
	.wdata_clk(   clk           ),
	.wdata_din(   wfifo_din     ),
	.wdata_wr(    wfifo_we      ),
	.wdata_full(  wfifo_full    ),
	//
	.sample(     sample      ), 
	// DDR
	.ddr_clk(     ddr_clk    ),
	.ddr_clk_n(   ddr_clk_n  ),
	.ddr_ras_n(   ddr_ras_n  ),
	.ddr_cas_n(   ddr_cas_n  ),
	.ddr_we_n(    ddr_we_n   ),
	.ddr_a(       ddr_a      ),
	.ddr_ba(      ddr_ba     ),
	.ddr_dm(      ddr_dm     ),
	.ddr_dq(      ddr_dq_o   ),
	.ddr_dqs(     ddr_dqs_o  ),
	.ddr_dqs_oe(  ddr_dqs_oe )
);

ddr_rpath rpath0 (
	.clk(         read_clk   ),
	.reset(       reset_int  ),
	// 
	.sample(      sample     ),
	//
	.rfifo_clk(   clk        ),
	.rfifo_empty( rfifo_empty),
	.rfifo_dout(  rfifo_dout ),
	.rfifo_next(  rfifo_next ),
	// DDR
	.ddr_dq(      ddr_dq_i   ),
	.ddr_dqs(     ddr_dqs_i  )
);

//----------------------------------------------------------------------------
// 7.8 us pulse generator
//----------------------------------------------------------------------------
wire pulse78;
reg  ar_req;
reg  ar_done;

ddr_pulse78 pulse79_gen (
	.clk(     clk        ),
	.reset(   reset_int  ),
	.pulse78( pulse78    )
);

//----------------------------------------------------------------------------
// Auto Refresh request generator
//----------------------------------------------------------------------------
always @(posedge clk)
	if (reset_int)
		ar_req <= 0;
	else
		ar_req <= pulse78 | (ar_req & ~ar_done);

// operations we might want to submit
wire [`CBA_RNG] ar_pre_cba;
wire [`CBA_RNG] ar_ar_cba;

assign ar_pre_cba   = { `DDR_CMD_PRE, 2'b00, 13'b1111111111111 };
assign ar_ar_cba    = { `DDR_CMD_AR,  2'b00, 13'b0000000000000 };

//----------------------------------------------------------------------------
// Init & management
//----------------------------------------------------------------------------
wire                 init_req;
reg                  init_ack;
wire [`CBA_RNG]      init_cba;
wire                 init_done;
wire                 wait200;

ddr_init #(
	.wait200_init( wait200_init )
) init (
	.clk(         clk         ),
	.reset(       reset_int   ),
	.pulse78(     pulse78     ),
	.wait200(     wait200     ),
	.init_done(   init_done   ),
	//
	.mngt_req(    init_req    ),
	.mngt_ack(    init_ack    ),
	.mngt_cba(    init_cba    )
);

//----------------------------------------------------------------------------
// Active Bank Information 
//----------------------------------------------------------------------------
reg [`ROW_RNG] ba_row [3:0];
reg [3:0]      ba_active;

//----------------------------------------------------------------------------
// FML decoding
//----------------------------------------------------------------------------
wire [`FML_ADR_BA_RNG]    fml_ba  = fml_adr[`FML_ADR_BA_RNG];
wire [`FML_ADR_ROW_RNG]   fml_row = fml_adr[`FML_ADR_ROW_RNG];
wire [`FML_ADR_COL_RNG]   fml_col = fml_adr[`FML_ADR_COL_RNG];

wire [`FML_ADR_ROW_RNG]   fml_cur_row;   // current active row in sel. bank
assign fml_cur_row    = ba_row[fml_ba];

wire   fml_row_active;  // is row in selected ba really active?
assign fml_row_active = ba_active[fml_ba]; 


/*
wire   fml_row_active = (fml_ba == 0) ? ba0_active :     // is row in selected
                        (fml_ba == 1) ? ba1_active :     // bank really active?
                        (fml_ba == 2) ? ba2_active :
                                        ba3_active ;
*/

// request operation iff correct bank is active
wire fml_req       = fml_rd | fml_wr;
wire fml_row_match = (fml_row == fml_cur_row) & fml_row_active;
wire fml_pre_req   = fml_req & ~fml_row_match & fml_row_active;
wire fml_act_req   = fml_req & ~fml_row_active;
wire fml_read_req  = fml_rd  &  fml_row_match & ~fml_done;
wire fml_write_req = fml_wr  &  fml_row_match & ~fml_done;

// actual operations we might want to submit
wire [`CBA_RNG] fml_pre_cba;
wire [`CBA_RNG] fml_act_cba;
wire [`CBA_RNG] fml_read_cba;
wire [`CBA_RNG] fml_write_cba;

assign fml_pre_cba   = { `DDR_CMD_PRE,   fml_ba, 13'b0  };
assign fml_act_cba   = { `DDR_CMD_ACT,   fml_ba, fml_row };
assign fml_read_cba  = { `DDR_CMD_READ,  fml_ba, {3'b000}, fml_col, {3'b000} };
assign fml_write_cba = { `DDR_CMD_WRITE, fml_ba, {3'b000}, fml_col, {3'b000} };

//----------------------------------------------------------------------------
// Schedule and issue commands
//----------------------------------------------------------------------------

parameter s_init      = 0;
parameter s_idle      = 1;
parameter s_ar        = 2;
parameter s_reading   = 3;

reg [1:0] state;

always @(posedge clk)
begin
	if (reset_int) begin
		state        <= s_init;
		ba_active    <= 0;
		ba_row[0]    <= 0;
		ba_row[1]    <= 0;
		ba_row[2]    <= 0;
		ba_row[3]    <= 0;

		fml_done     <= 0;
		init_ack     <= 0;
		cba_fifo_we  <= 0;
		ar_done      <= 0;
	end else begin
		fml_done     <= 0;
		init_ack     <= 0;
		cba_fifo_we  <= 0;
		ar_done      <= 0;

		case (state)
			s_init: begin
				if (init_done)
					state <= s_idle;

				if (init_req & ~cba_fifo_full) begin
					cba_fifo_we       <= 1;
					cba_fifo_din      <= init_cba;
					init_ack          <= 1;
				end
			end
			s_idle: begin
				if (fml_read_req & ~cba_fifo_full) begin
					cba_fifo_we       <= 1;
					cba_fifo_din      <= fml_read_cba;
					fml_done          <= 1;
				end else if (fml_write_req & ~cba_fifo_full) begin
					cba_fifo_we       <= 1;
					cba_fifo_din      <= fml_write_cba;
					fml_done          <= 1;
				end else if (ar_req & ~cba_fifo_full) begin
					cba_fifo_we       <= 1;
					cba_fifo_din      <= ar_pre_cba;
					ar_done           <= 1;
					ba_active         <= 'b0;
					state             <= s_ar;
				end else if (fml_pre_req & ~cba_fifo_full) begin
					cba_fifo_we       <= 1;
					cba_fifo_din      <= fml_pre_cba;
					ba_active[fml_ba] <= 0;
				end else if (fml_act_req & ~cba_fifo_full) begin
					cba_fifo_we       <= 1;
					cba_fifo_din      <= fml_act_cba;
					ba_active[fml_ba] <= 1;
					ba_row[fml_ba]    <= fml_row;
				end
			end
			s_ar: begin
				if (~cba_fifo_full) begin
					cba_fifo_we       <= 1;
					cba_fifo_din      <= ar_ar_cba;
					state             <= s_idle;
				end
			end
		endcase
	end
end

//----------------------------------------------------------------------------
// Demux dqs and dq
//----------------------------------------------------------------------------
assign ddr_cke   = ~wait200;     // bring up CKE as soon 200us wait is finished

assign ddr_dqs = ddr_dqs_oe!=1'b0 ? ddr_dqs_o : 'bz;
assign ddr_dq  = ddr_dqs_oe!=1'b0 ? ddr_dq_o  : 'bz;

assign ddr_dqs_i = ddr_dqs;
assign ddr_dq_i  = ddr_dq;

assign ddr_cs_n = 0;

endmodule

// vim: set ts=4
