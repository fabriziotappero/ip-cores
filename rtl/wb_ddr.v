//----------------------------------------------------------------------------
// Wishbone DDR Controller
// 
// (c) Joerg Bornschein (<jb@capsec.org>)
//----------------------------------------------------------------------------

`include "ddr_include.v"

module wb_ddr
#(
	parameter clk_freq     = 100000000,
	parameter clk_multiply = 12,
	parameter clk_divide   = 5,
	parameter phase_shift  = 0,
	parameter wait200_init = 26
) (
	input                    clk, 
	input                    reset,
	//  DDR ports
	output             [2:0] ddr_clk,
	output             [2:0] ddr_clk_n,
	input                    ddr_clk_fb,
	output                   ddr_ras_n,
	output                   ddr_cas_n,
	output                   ddr_we_n,
	output             [1:0] ddr_cke,
	output             [1:0] ddr_cs_n,
	output        [  `A_RNG] ddr_a,
	output        [ `BA_RNG] ddr_ba,
	inout         [ `DQ_RNG] ddr_dq,
	inout         [`DQS_RNG] ddr_dqs,
	output        [ `DM_RNG] ddr_dm,
	// Wishbone Slave Interface
	input      [`WB_ADR_RNG] wb_adr_i,
	input      [`WB_DAT_RNG] wb_dat_i,
	output reg [`WB_DAT_RNG] wb_dat_o,
	input      [`WB_SEL_RNG] wb_sel_i,
	input                    wb_cyc_i,
	input                    wb_stb_i,
	input                    wb_we_i,
	output reg               wb_ack_o,
	// XXX Temporary DCM control input XXX
	output                   ps_ready,
	input                    ps_up,
	input                    ps_down,
	// XXX probe wires XXX
	output                   probe_clk,
	input              [7:0] probe_sel,
	output reg         [7:0] probe
);

//----------------------------------------------------------------------------
// Wishbone handling
//----------------------------------------------------------------------------
wire wb_rd = wb_stb_i & wb_cyc_i & ~wb_we_i;
wire wb_wr = wb_stb_i & wb_cyc_i &  wb_we_i;

wire [`WB_WORD_RNG] wb_adr_word = wb_adr_i[`WB_WORD_RNG]; // word in bufferline
wire [`WB_SET_RNG]  wb_adr_set  = wb_adr_i[`WB_SET_RNG];  // index into wayX_ram
wire [`WB_TAG_RNG]  wb_adr_tag  = wb_adr_i[`WB_TAG_RNG];  // more significant bits

//----------------------------------------------------------------------------
// TAG RAM (2-way set assioziative)
//----------------------------------------------------------------------------
wire [`TAG_LINE_RNG] tag_load;
wire [`TAG_LINE_RNG] tag_store;
wire                 tag_we;

wire [`WB_TAG_RNG] tag_load_set0   = tag_load[`TAG_LINE_TAG0_RNG];
wire [`WB_TAG_RNG] tag_load_set1   = tag_load[`TAG_LINE_TAG1_RNG];
wire               tag_load_dirty0 = tag_load[`TAG_LINE_DIRTY0_RNG];
wire               tag_load_dirty1 = tag_load[`TAG_LINE_DIRTY1_RNG];
wire               tag_load_lru    = tag_load[`TAG_LINE_LRU_RNG];

reg [`WB_TAG_RNG] tag_store_set0;
reg [`WB_TAG_RNG] tag_store_set1;
reg               tag_store_dirty0;
reg               tag_store_dirty1;
reg               tag_store_lru;

assign tag_store[`TAG_LINE_TAG0_RNG]   = tag_store_set0;
assign tag_store[`TAG_LINE_TAG1_RNG]   = tag_store_set1;
assign tag_store[`TAG_LINE_DIRTY0_RNG] = tag_store_dirty0;
assign tag_store[`TAG_LINE_DIRTY1_RNG] = tag_store_dirty1;
assign tag_store[`TAG_LINE_LRU_RNG]    = tag_store_lru;

wire [`WB_SET_RNG]   ls_tag_adr;
wire [`TAG_LINE_RNG] ls_tag_load;
reg  [`TAG_LINE_RNG] ls_tag_store;
reg                  ls_tag_we;

dpram #(
	.adr_width(   7 ),
	.dat_width(  33 )
) tag_ram (
	.clk (     clk         ),
	//
	.adr0(     wb_adr_set  ),
	.dout0(    tag_load    ),
	.din0(     tag_store   ),  
	.we0(      tag_we      ),
	//
	.adr1(     ls_tag_adr   ),
	.dout1(    ls_tag_load  ),
	.din1(     ls_tag_store ),  
	.we1(      ls_tag_we    )
);

wire tag_load_match0 = (tag_load_set0 == wb_adr_tag);
wire tag_load_match1 = (tag_load_set1 == wb_adr_tag);
wire tag_load_match  = tag_load_match0 | tag_load_match1;

//----------------------------------------------------------------------------
// Buffer cache ram (2 ways)
//----------------------------------------------------------------------------
wire [8:0] wayX_adr = { wb_adr_set, wb_adr_word };

wire [`WAY_LINE_RNG]  way0_load, way1_load;
wire [`WAY_LINE_RNG]  wayX_store;

wire [31:0]   way0_load_dat   = way0_load[`WAY_DAT_RNG];
wire [31:0]   way1_load_dat   = way1_load[`WAY_DAT_RNG];
wire [3:0]    way0_load_valid = way0_load[`WAY_VALID_RNG];
wire [3:0]    way1_load_valid = way1_load[`WAY_VALID_RNG];

wire          way0_we;
wire          way1_we;
reg  [31:0]   wayX_store_dat;
reg  [3:0]    wayX_store_valid;

assign wayX_store[`WAY_DAT_RNG]   = wayX_store_dat;
assign wayX_store[`WAY_VALID_RNG] = wayX_store_valid;

wire [8:0]            ls_wayX_adr;
wire [`WAY_LINE_RNG]  ls_way0_load;
wire [`WAY_LINE_RNG]  ls_way1_load;
wire [`WAY_LINE_RNG]  ls_wayX_store;
wire                  ls_way0_we;
wire                  ls_way1_we;
reg                   ls_wayX_we;

wire way0_sel_valid = ( (~way0_load_valid & wb_sel_i) == 'b0);
wire way1_sel_valid = ( (~way1_load_valid & wb_sel_i) == 'b0);
wire wayX_sel_valid = (tag_load_match0) ? way0_sel_valid : way1_sel_valid;

// synthesis attribute ram_style of way0_ram is block
dpram #(
	.adr_width(   9 ),
	.dat_width(  36 )
) way0_ram (
	.clk(    clk         ),
	//
	.adr0(   wayX_adr    ),
	.dout0(  way0_load   ),
	.din0(   wayX_store  ),
	.we0(    way0_we     ),
	//
	.adr1(   ls_wayX_adr   ),
	.dout1(  ls_way0_load  ),
	.we1(    ls_way0_we    ),
	.din1(   ls_wayX_store )
);

// synthesis attribute ram_style of way1_ram is block
dpram #(
	.adr_width(   9 ),
	.dat_width(  36 )
) way1_ram (
	.clk(    clk         ),
	//
	.adr0(   wayX_adr    ),
	.dout0(  way1_load   ),
	.din0(   wayX_store  ),
	.we0(    way1_we     ),
	//
	.adr1(   ls_wayX_adr   ),
	.dout1(  ls_way1_load  ),
	.we1(    ls_way1_we    ),
	.din1(   ls_wayX_store )
);

//----------------------------------------------------------------------------
// Write/update buffer cache from wishbone side
//----------------------------------------------------------------------------
wire store_to_way0 =  tag_load_lru & ~tag_load_dirty0;   // store new data into way0?  XXX spill_done XXX
wire store_to_way1 = ~tag_load_lru & ~tag_load_dirty1;   // store new data into way1?  XXX spill_done XXX
wire store_to_way  =  store_to_way0 | store_to_way1;

reg update_lru0;  // 
reg update_lru1;  

reg update_way0;  //
reg update_way1;

assign way0_we = update_way0;
assign way1_we = update_way1;
assign tag_we  = way0_we | way1_we | update_lru0 | update_lru1;

//----------------------------------------------------------------------------
// MUX wayX_store input
//----------------------------------------------------------------------------

integer  i;
always @(*)
begin
/*
	for(i=0; i<4; i=i+1) begin
		if (wb_sel_i[i]) begin
			wayX_store_dat[8*i+7:8*i] = wb_dat_i[8*i+7:8*i];
			wayX_store_valid[i]       = 1;
		end else if (update_way0) begin
			wayX_store_dat[8*i+7:8*i] = way0_load_dat[8*i+7:8*i];
			wayX_store_valid[i]       = way0_load_valid[i];
		end else begin
			wayX_store_dat[8*i+7:8*i] = way1_load_dat[8*i+7:8*i];
			wayX_store_valid[i]       = way1_load_valid[i];
		end
	end
*/

	if (wb_sel_i[0]) begin
		wayX_store_dat[8*0+7:8*0] = wb_dat_i[8*0+7:8*0];
		wayX_store_valid[0]       = 1;
	end else if (update_way0) begin
		wayX_store_dat[8*0+7:8*0] = way0_load_dat[8*0+7:8*0];
		wayX_store_valid[0]       = way0_load_valid[0];
	end else begin
		wayX_store_dat[8*0+7:8*0] = way1_load_dat[8*0+7:8*0];
		wayX_store_valid[0]       = way1_load_valid[0];
	end

	if (wb_sel_i[1]) begin
		wayX_store_dat[8*1+7:8*1] = wb_dat_i[8*1+7:8*1];
		wayX_store_valid[1]       = 1;
	end else if (update_way0) begin
		wayX_store_dat[8*1+7:8*1] = way0_load_dat[8*1+7:8*1];
		wayX_store_valid[1]       = way0_load_valid[1];
	end else begin
		wayX_store_dat[8*1+7:8*1] = way1_load_dat[8*1+7:8*1];
		wayX_store_valid[1]       = way1_load_valid[1];
	end

	if (wb_sel_i[2]) begin
		wayX_store_dat[8*2+7:8*2] = wb_dat_i[8*2+7:8*2];
		wayX_store_valid[2]       = 1;
	end else if (update_way0) begin
		wayX_store_dat[8*2+7:8*2] = way0_load_dat[8*2+7:8*2];
		wayX_store_valid[2]       = way0_load_valid[2];
	end else begin
		wayX_store_dat[8*2+7:8*2] = way1_load_dat[8*2+7:8*2];
		wayX_store_valid[2]       = way1_load_valid[2];
	end

	if (wb_sel_i[3]) begin
		wayX_store_dat[8*3+7:8*3] = wb_dat_i[8*3+7:8*3];
		wayX_store_valid[3]       = 1;
	end else if (update_way0) begin
		wayX_store_dat[8*3+7:8*3] = way0_load_dat[8*3+7:8*3];
		wayX_store_valid[3]       = way0_load_valid[3];
	end else begin
		wayX_store_dat[8*3+7:8*3] = way1_load_dat[8*3+7:8*3];
		wayX_store_valid[3]       = way1_load_valid[3];
	end
end

always @(*)
begin
	if (update_way0) begin
		tag_store_set0    = wb_adr_tag;
		tag_store_dirty0  = 1;
	end else begin
		tag_store_set0    = tag_load_set0;
		tag_store_dirty0  = tag_load_dirty0;
	end

	if (update_way1) begin
		tag_store_set1    = wb_adr_tag;
		tag_store_dirty1  = 1;
	end else begin
		tag_store_set1    = tag_load_set1;
		tag_store_dirty1  = tag_load_dirty1;
	end

	if (update_lru0)
		tag_store_lru     = 0;
	else if (update_lru1)
		tag_store_lru     = 1;
	else
		tag_store_lru     = tag_load_lru;
end

//----------------------------------------------------------------------------
// Wishbone FSM
//----------------------------------------------------------------------------
reg  ls_fill;
reg  ls_spill;
reg  ls_way;
wire ls_busy;

reg [`WB_TAG_RNG]  ls_adr_tag;
reg [`WB_SET_RNG]  ls_adr_set;
reg [`WB_WORD_RNG] ls_adr_word;

reg  [2:0] state;

parameter s_idle   = 0;
parameter s_read   = 1;
parameter s_rspill = 2;
parameter s_rfill  = 3;
parameter s_write  = 4;
parameter s_wspill = 5;

// Syncronous part of FSM
always @(posedge clk)
begin
	if (reset) begin
		state    <= s_idle;
		ls_spill <= 0;
		ls_fill  <= 0;
		ls_way   <= 0;
	end else begin
		ls_fill   <=  0;
		ls_spill  <=  0;

		case (state)
		s_idle: begin
			if (wb_rd)
				state      <= s_read;

			if (wb_wr)
				state      <= s_write;
		end
		s_read: begin
			if ((tag_load_match0 & way0_sel_valid) | (tag_load_match1 & way1_sel_valid)) begin
				state      <= s_idle;
			end else if (store_to_way & ~ls_busy) begin
				state      <= s_rfill;
				ls_fill    <=  1;
				ls_way     <= ~tag_load_lru;
				ls_adr_tag <=  wb_adr_tag;
				ls_adr_set <=  wb_adr_set;
			end else if (~ls_busy) begin
				state      <= s_rspill;
				ls_spill   <=  1;
				ls_way     <= ~tag_load_lru;
				ls_adr_set <=  wb_adr_set;
				if (tag_load_lru == 1)
					ls_adr_tag <=  tag_load_set0;
				else
					ls_adr_tag <=  tag_load_set1;
			end
		end
		s_rspill: begin
			if (~ls_busy) begin
				state      <= s_rfill;
				ls_fill    <=  1;
				ls_way     <= ~tag_load_lru;
				ls_adr_tag <=  wb_adr_tag;
				ls_adr_set <=  wb_adr_set;
			end
		end
		s_rfill: begin
			if (tag_load_match & wayX_sel_valid)
				state      <= s_idle;
		end
		s_write: begin
			if (tag_load_match | store_to_way) begin
				state      <= s_idle;
			end else if (~ls_busy) begin
				state      <= s_wspill;
				ls_spill   <=  1;
				ls_way     <= ~tag_load_lru;
				ls_adr_set <=  wb_adr_set;
				if (tag_load_lru == 1)
					ls_adr_tag <=  tag_load_set0;
				else
					ls_adr_tag <=  tag_load_set1;
			end
		end
		s_wspill: begin
			if (tag_load_match | store_to_way) begin
				state      <= s_idle;
			end
		end
		default: 
			state <= s_idle;
		endcase
	end
end

// Asyncronous part of FSM
always @(*)
begin
	update_lru0  <= 0;
	update_lru1  <= 0;
	update_way0  <= 0;
	update_way1  <= 0;
	wb_dat_o     <= 0;
	wb_ack_o     <= 0;

	case (state)
	s_idle: begin end
	s_read: begin
		if (tag_load_match0 & way0_sel_valid) begin
			update_lru0  <= 1;
			wb_dat_o     <= way0_load_dat;
			wb_ack_o     <= 1;
		end else if (tag_load_match1 & way1_sel_valid) begin
			update_lru1  <= 1;
			wb_dat_o     <= way1_load_dat;
			wb_ack_o     <= 1;
		end
	end
	s_write: begin
		if (tag_load_match0 | store_to_way0) begin
			update_lru0  <= 1;
			update_way0  <= 1;
			wb_ack_o     <= 1;
		end else if (tag_load_match1 | store_to_way1) begin
			update_lru1  <= 1;
			update_way1  <= 1;
			wb_ack_o     <= 1;
		end
	end
	endcase
end

	

//----------------------------------------------------------------------------
// DDR Controller Engine (including clkgen, [rw]-path)
//----------------------------------------------------------------------------
reg                 fml_rd;
reg                 fml_wr;
wire                fml_done;
wire [`FML_ADR_RNG] fml_adr;
wire [`FML_DAT_RNG] fml_wdat;
wire [`FML_BE_RNG]  fml_wbe;
reg                 fml_wnext;
reg                 fml_wnext2;
wire                fml_rempty;
reg                 fml_rnext;
wire [`FML_DAT_RNG] fml_rdat;

ddr_ctrl #(
	.phase_shift(  phase_shift  ),
	.clk_multiply( clk_multiply ),
	.clk_divide(   clk_divide   ),
	.wait200_init( wait200_init )
) ctrl0 (
	.clk(          clk         ),
	.reset(        reset       ),
	// DDR Ports
	.ddr_clk(      ddr_clk     ),
	.ddr_clk_n(    ddr_clk_n   ),
	.ddr_clk_fb(   ddr_clk_fb  ),
	.ddr_ras_n(    ddr_ras_n   ),
	.ddr_cas_n(    ddr_cas_n   ),
	.ddr_we_n(     ddr_we_n    ),
	.ddr_cke(      ddr_cke     ),
	.ddr_cs_n(     ddr_cs_n    ),
	.ddr_a(        ddr_a       ),
	.ddr_ba(       ddr_ba      ),
	.ddr_dq(       ddr_dq      ),
	.ddr_dqs(      ddr_dqs     ),
	.ddr_dm(       ddr_dm      ),
	// FML (FastMemoryLink)
	.fml_rd(       fml_rd      ),
	.fml_wr(       fml_wr      ),
	.fml_done(     fml_done    ),
	.fml_adr(      fml_adr     ),
	.fml_wdat(     fml_wdat    ),
	.fml_wbe(      fml_wbe     ),
	.fml_wnext(    fml_wnext2  ),
	.fml_rempty(   fml_rempty  ),
	.fml_rdat(     fml_rdat    ),
	.fml_rnext(    fml_rnext   ),
	// DCM phase shift control
	.ps_ready(     ps_ready   ),
	.ps_up(        ps_up      ),
	.ps_down(      ps_down    )
);

assign fml_adr = { ls_adr_tag, ls_adr_set };

assign fml_wdat  = (ls_way) ? ls_way1_load[`WAY_DAT_RNG] :
                              ls_way0_load[`WAY_DAT_RNG];

assign fml_wbe   = (ls_way) ? ls_way1_load[`WAY_VALID_RNG] :
                              ls_way0_load[`WAY_VALID_RNG];

assign ls_tag_adr    = { ls_adr_set };
assign ls_wayX_adr   = { ls_adr_set, ls_adr_word };
assign ls_way0_we    = ls_wayX_we & ~ls_way;
assign ls_way1_we    = ls_wayX_we &  ls_way;

assign ls_wayX_store[`WAY_DAT_RNG]   = fml_rdat;
assign ls_wayX_store[`WAY_VALID_RNG] = 4'b1111;


//----------------------------------------------------------------------------
// LS (Load and Store) Engine
//----------------------------------------------------------------------------
parameter l_idle     = 0;
parameter l_fill     = 1;
parameter l_spill    = 2;
parameter l_waitdone = 3;

reg [2:0] ls_state;
assign ls_busy = (ls_state != l_idle) || ls_fill || ls_spill;

// Syncronous part FSM
always @(posedge clk)
begin
	if (reset) begin
		ls_state     <= l_idle;
		ls_adr_word  <= 0;
		fml_wr       <= 0;
		fml_rd       <= 0;
	end else begin
		fml_wnext2 <= fml_wnext;

		case (ls_state)
		l_idle: begin
			ls_adr_word <= 0;

			if (ls_spill) begin
				ls_state    <= l_spill;
				ls_adr_word <= ls_adr_word + 1;
			end
			if (ls_fill) begin
				ls_state    <= l_fill;
				fml_rd      <= 1;
			end
		end
		l_spill: begin
			ls_adr_word <= ls_adr_word + 1;

			if (ls_adr_word == 3) begin
				ls_state    <= l_waitdone;
				fml_wr      <= 1;
			end
		end
		l_waitdone: begin
			ls_adr_word <= 0;
			
			if (fml_done) begin
				ls_state    <= l_idle;
				fml_wr      <= 0;
			end
		end
		l_fill: begin
			if (fml_done)
				fml_rd <= 0;

			if (~fml_rempty)
				ls_adr_word <= ls_adr_word + 1;

			if (~fml_rempty & (ls_adr_word == 3))
				ls_state    <= l_idle;
		end
		endcase
	end
end

always @(*)
begin
	fml_wnext      <= 0;
	fml_rnext      <= 0;
	ls_tag_we      <= 0;
	ls_tag_store   <= ls_tag_load;
	ls_wayX_we     <= 0;

	case (ls_state)
	l_idle: begin
		if (ls_spill) begin
			fml_wnext  <= 1;
		end
	end
	l_spill: begin
		fml_wnext      <= 1;
	end
	l_waitdone: begin
		if (ls_way == 0)
			ls_tag_store[`TAG_LINE_DIRTY0_RNG] <= 0;
		else
			ls_tag_store[`TAG_LINE_DIRTY1_RNG] <= 0;

		if (fml_done)
			ls_tag_we    <= 1;
	end
	l_fill: begin
		if (ls_way == 0) begin
			ls_tag_store[`TAG_LINE_DIRTY0_RNG] <= 0;
			ls_tag_store[`TAG_LINE_TAG0_RNG]   <= ls_adr_tag;
		end else begin
			ls_tag_store[`TAG_LINE_DIRTY1_RNG] <= 0;
			ls_tag_store[`TAG_LINE_TAG1_RNG]   <= ls_adr_tag;
		end

		if (~fml_rempty) begin
			ls_wayX_we  <= 1;
			fml_rnext   <= 1;
		end

		if (~fml_rempty & (ls_adr_word == 3))
			ls_tag_we   <= 1;
	end
	endcase
end

always @(posedge clk)
begin
	if (ls_fill)
		$display ("At time %t WB_DDR fill cacheline: TAG = %h, SET = %h)", $time, ls_adr_tag, ls_adr_set);

	if (ls_spill)
		$display ("At time %t WB_DDR spill cacheline: TAG = %h, SET = %h)", $time, ls_adr_tag, ls_adr_set);
end

endmodule
