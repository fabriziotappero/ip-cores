/*
 *                              .--------------. .----------------. .------------.
 *                             | .------------. | .--------------. | .----------. |
 *                             | | ____  ____ | | | ____    ____ | | |   ______ | |
 *                             | ||_   ||   _|| | ||_   \  /   _|| | | .' ___  || |
 *       ___  _ __   ___ _ __  | |  | |__| |  | | |  |   \/   |  | | |/ .'   \_|| |
 *      / _ \| '_ \ / _ \ '_ \ | |  |  __  |  | | |  | |\  /| |  | | || |       | |
 *       (_) | |_) |  __/ | | || | _| |  | |_ | | | _| |_\/_| |_ | | |\ `.___.'\| |
 *      \___/| .__/ \___|_| |_|| ||____||____|| | ||_____||_____|| | | `._____.'| |
 *           | |               | |            | | |              | | |          | |
 *           |_|               | '------------' | '--------------' | '----------' |
 *                              '--------------' '----------------' '------------'
 *
 *  openHMC - An Open Source Hybrid Memory Cube Controller
 *  (C) Copyright 2014 Computer Architecture Group - University of Heidelberg
 *  www.ziti.uni-heidelberg.de
 *  B6, 26
 *  68159 Mannheim
 *  Germany
 *
 *  Contact: openhmc@ziti.uni-heidelberg.de
 *  http://ra.ziti.uni-heidelberg.de/openhmc
 *
 *   This source file is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU Lesser General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This source file is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Lesser General Public License for more details.
 *
 *   You should have received a copy of the GNU Lesser General Public License
 *   along with this source file.  If not, see <http://www.gnu.org/licenses/>.
 *
 *
 *  Module name: rx_link
 *
 */

`default_nettype none

module rx_link #(
    parameter LOG_FPW           = 2,
    parameter FPW               = 4,
    parameter DWIDTH            = FPW*128,
    parameter LOG_NUM_LANES     = 3,
    parameter NUM_LANES         = 2**LOG_NUM_LANES,
    parameter HMC_PTR_SIZE      = 8,
    parameter HMC_RF_RWIDTH     = 64,
    //Configure functionality
    parameter LOG_MAX_RTC        = 8,
    parameter CTRL_LANE_POLARITY = 1,
    parameter CTRL_LANE_REVERSAL = 1,
    parameter BITSLIP_SHIFT_RIGHT= 1
) (

    //----------------------------------
    //----SYSTEM INTERFACE
    //----------------------------------
    input   wire                        clk,
    input   wire                        res_n,

    //----------------------------------
    //----TO HMC PHY
    //----------------------------------
    input   wire    [DWIDTH-1:0]        phy_scrambled_data_in,
    output  reg     [NUM_LANES-1:0]     init_bit_slip,               //bit slip per lane

    //----------------------------------
    //----TO RX HTAX FIFO
    //----------------------------------
    output  reg     [DWIDTH-1:0]        d_out_fifo_data,
    input   wire                        d_out_fifo_full,
    input   wire                        d_out_fifo_a_full,
    output  reg                         d_out_fifo_shift_in,
    output  reg     [4*FPW-1:0]         d_out_fifo_ctrl,


    //----------------------------------
    //----TO TX Block
    //----------------------------------
    output  reg                         tx_link_retry,
    output  reg                         tx_error_abort_mode,
    output  reg                         tx_error_abort_mode_cleared,
    output  reg     [7:0]               tx_hmc_frp,
    output  reg     [7:0]               tx_rrp,
    output  reg     [7:0]               tx_returned_tokens,
    output  reg     [LOG_FPW:0]         tx_hmc_tokens_to_return,
    output  reg     [LOG_FPW:0]         tx_hmc_poisoned_tokens_to_return,

    //----------------------------------
    //----RF
    //----------------------------------
    //Monitoring    1-cycle set to increment
    output  reg     [HMC_RF_RWIDTH-1:0] rf_cnt_poisoned,
    output  reg     [HMC_RF_RWIDTH-1:0] rf_cnt_rsp,
    //Status
    output  reg     [1:0]               rf_link_status,
    output  reg     [2:0]               rf_hmc_init_status,
    input   wire                        rf_tx_sends_ts1,
    input   wire                        rf_hmc_sleep,
    //Init Status
    output  wire    [NUM_LANES-1:0]     rf_descrambler_part_aligned,
    output  wire    [NUM_LANES-1:0]     rf_descrambler_aligned,
    output  wire                        rf_all_descramblers_aligned,
    //Control
    input   wire    [5:0]               rf_bit_slip_time,
    input   wire                        rf_hmc_init_cont_set,
    output  reg     [NUM_LANES-1:0]     rf_lane_polarity,
    input   wire                        rf_scrambler_disable,
    output  reg                         rf_lane_reversal_detected,
    output  reg     [NUM_LANES-1:0]     rf_descramblers_locked,
    input   wire    [4:0]               rf_irtry_received_threshold

);
`include "hmc_field_functions.h"

//=====================================================================================================
//-----------------------------------------------------------------------------------------------------
//---------WIRING AND SIGNAL STUFF---------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------
//=====================================================================================================

//------------------------------------------------------------------------------------Some general things
//Link state
localparam              HMC_DOWN        = 3'b000;
localparam              HMC_NULL        = 3'b001;
localparam              HMC_TS1         = 3'b010;
localparam              HMC_UP          = 3'b100;

//Commands
localparam              CMD_IRTRY       = 3'b011;
localparam              CMD_FLOW        = 3'b000;
localparam              CMD_RSP         = 3'b111;
localparam              CMD_RSP_ERROR   = 6'b111110;

//Other helpful defines
localparam              WIDTH_PER_LANE          = (DWIDTH/NUM_LANES);

//16 bits is a ts1, so the init seq number is incremented according to the lane size
localparam              INIT_SEQ_INC_PER_CYCLE  = WIDTH_PER_LANE/16;

//MISC
integer i_f;    //counts to FPW
integer i_l;    //counts to NUM_LANES
integer i_c;    //counts to CYCLES_TO_COMPLETE_FULL_PACKET

genvar f;   //Counts to FPW
genvar n;   //Counts to NUM_LANES
genvar w;   //Counts to WIDTH_PER_LANE

//------------------------------------------------------------------------------------DESCRAMBLER AND DATA ORDERING
reg [NUM_LANES-1:0]     init_descrambler_part_aligned;
reg [NUM_LANES-1:0]     init_descrambler_aligned;
assign                  rf_descrambler_part_aligned = init_descrambler_part_aligned;
assign                  rf_descrambler_aligned      = init_descrambler_aligned;

//DATA and REORDERING
reg  [WIDTH_PER_LANE-1:0]   init_data_per_lane          [NUM_LANES-1:0];
wire [DWIDTH-1:0]           init_d_in;
wire [128-1:0]              init_d_in_flit              [FPW-1:0];
wire [WIDTH_PER_LANE-1:0]   descrambled_data_per_lane   [NUM_LANES-1:0];
wire [DWIDTH-1:0]           d_in;
wire [128-1:0]              d_in_flit                   [FPW-1:0];

//Valid FLIT sources. A FLIT is valid when it is not NULL
wire [FPW-1:0]              valid_flit_src;     //bit0 = flit0, ...
wire [FPW-1:0]              init_valid_flit_src;     //bit0 = flit0, ...

generate

    //-- Apply lane reversal if detected
    for(n = 0; n < NUM_LANES; n = n + 1) begin : apply_lane_reversal
        for(w = 0; w < WIDTH_PER_LANE; w = w + 1) begin
            if(CTRL_LANE_REVERSAL==1)begin
                assign d_in[w*NUM_LANES+n]      = rf_lane_reversal_detected ? descrambled_data_per_lane[NUM_LANES-1-n][w] : descrambled_data_per_lane[n][w];
                assign init_d_in[w*NUM_LANES+n] = rf_lane_reversal_detected ? init_data_per_lane[NUM_LANES-1-n][w] : init_data_per_lane[n][w];
            end else begin
                assign d_in[w*NUM_LANES+n]      = descrambled_data_per_lane[n][w];
                assign init_d_in[w*NUM_LANES+n] = init_data_per_lane[n][w];
            end
        end
    end


    for(f = 0; f < FPW; f = f + 1) begin : reorder_input_data
        //-- Reorder the descrambled data to FLITs
        assign d_in_flit[f]       = d_in[128-1+(f*128):f*128];
        assign init_d_in_flit[f]  = init_d_in[128-1+(f*128):f*128];
        //-- Generate valid flit positions for the init sequence
        assign valid_flit_src[f]        = (|d_in_flit[f] == 1'b0) ? 1'b0 : 1'b1;
        assign init_valid_flit_src[f]   = (|init_d_in_flit[f] == 1'b0) ? 1'b0 : 1'b1;
    end

endgenerate


//------------------------------------------------------------------------------------INIT
localparam                  LINK_DOWN   = 2'b00;
localparam                  LINK_INIT   = 2'b01;
localparam                  LINK_UP     = 2'b10;

reg     [5:0]               init_bit_slip_cnt;
reg     [4:0]               init_wait_time;
wire    [NUM_LANES-1:0]     init_descrambler_locked;           //locked from the descrambler
wire                        link_is_up;
reg     [3:0]               init_tmp_seq;
reg                         init_prbs_seen;

assign                      link_is_up                  = rf_link_status[1];
assign                      rf_all_descramblers_aligned = &init_descrambler_aligned;

//--------------TS1 recognition
localparam                  ts1_independent_portion = {4'hF,4'h0};
localparam                  ts1_lanex_portion       = {4'h5};
localparam                  ts1_lane7or15_portion   = 4'hc;
localparam                  ts1_lane0_portion       = 4'h3;

localparam                  ts1_per_cycle_and_lane = DWIDTH/NUM_LANES/16;

wire    [NUM_LANES-1:0]     init_lane_has_correct_ts1;
wire    [ts1_per_cycle_and_lane-1:0]     init_lane_has_correct_ts1_vec   [NUM_LANES-1:0];

genvar t;
generate
    //Make sure that the lanes have valid ts1 sequences throughout the entire data stream
    for(n=0;n<NUM_LANES;n=n+1) begin : lane_has_correct_ts1_gen

        assign init_lane_has_correct_ts1[n] = &init_lane_has_correct_ts1_vec[n];

        for(t=0;t<ts1_per_cycle_and_lane;t=t+1) begin
            if(n==0 || n==NUM_LANES-1) begin
                assign init_lane_has_correct_ts1_vec[n][t] = (init_data_per_lane[n][(t*16)+16-1:(t*16)+4] == {ts1_independent_portion,ts1_lane7or15_portion})
                                                             ||
                                                             (init_data_per_lane[n][(t*16)+16-1:(t*16)+4] == {ts1_independent_portion,ts1_lane0_portion});            
            end else begin
                assign init_lane_has_correct_ts1_vec[n][t] = (init_data_per_lane[n][(t*16)+16-1:(t*16)+4] == {ts1_independent_portion,ts1_lanex_portion});
            end
        end
    end
endgenerate

//--------------Align the lanes, scan for the ts1 seq
reg  [LOG_NUM_LANES-1:0]    init_lane_cnt;
wire [3:0]                  init_seq_diff;

//If one of the descramblers is already partially aligned search for other lanes with their ts1 sequence number close this lane. 
assign                      init_seq_diff = |init_descrambler_part_aligned ? 
                                                (BITSLIP_SHIFT_RIGHT==1 ? (init_data_per_lane[init_lane_cnt][3:0] - init_tmp_seq) 
                                                : init_tmp_seq - init_data_per_lane[init_lane_cnt][3:0])
                                            : 0;

//------------------------------------------------------------------------------------Input Stage: Scan for Packets, Headers, Tails ...
reg  [DWIDTH-1:0]       data2crc;
reg  [FPW-1:0]          data2crc_hdr;
reg  [FPW-1:0]          data2crc_tail;
reg  [FPW-1:0]          data2crc_valid;
wire [(FPW*4)-1:0]      data2crc_lng;
reg  [3:0]              data2crc_lng_per_flit [FPW-1:0];
reg  [3:0]              data2crc_payload_remain;

reg  [FPW-1:0]          data2crc_hdr_comb;
reg  [FPW-1:0]          data2crc_tail_comb;
reg  [FPW-1:0]          data2crc_valid_comb;
reg  [3:0]              data2crc_lng_per_flit_comb [FPW-1:0];
reg  [3:0]              data2crc_payload_remain_comb;

generate
        for(f = 0; f < (FPW); f = f + 1) begin
            assign data2crc_lng[(f*4)+4-1:(f*4)] = data2crc_lng_per_flit[f];
        end
endgenerate

//------------------------------------------------------------------------------------CRC
wire [DWIDTH-1:0]       crc_d_out_data;
wire [128-1:0]          crc_d_out_flit              [FPW-1:0];
wire [FPW-1:0]          crc_d_out_flit_is_hdr;
wire [FPW-1:0]          crc_d_out_flit_is_tail;
wire [FPW-1:0]          crc_d_out_flit_is_valid;
wire [FPW-1:0]          crc_d_out_flit_is_error;
wire [FPW-1:0]          crc_d_out_flit_is_poisoned;
wire [FPW-1:0]          crc_d_out_flit_has_rtc;
wire [FPW-1:0]          crc_d_out_flit_is_flow;

generate
        for(f=0;f<FPW;f=f+1) begin : reorder_crc_output
            assign crc_d_out_flit[f] = crc_d_out_data[128-1+(f*128):f*128];
        end
endgenerate

//------------------------------------------------------------------------------------LNG and DLN stage
reg     [128-1:0]       flit_after_lng_check                   [FPW-1:0];
reg     [FPW-1:0]       flit_after_lng_check_is_hdr;
reg     [FPW-1:0]       flit_after_lng_check_is_tail;
reg     [FPW-1:0]       flit_after_lng_check_is_valid;
reg     [FPW-1:0]       flit_after_lng_check_is_error;
reg     [FPW-1:0]       flit_after_lng_check_is_poisoned;
reg     [FPW-1:0]       flit_after_lng_check_is_flow;
reg     [FPW-1:0]       flit_after_lng_check_has_rtc;

//------------------------------------------------------------------------------------Start TX retry Stage
reg     [128-1:0]       flit_after_retry_stage                   [FPW-1:0];
reg     [FPW-1:0]       flit_after_retry_stage_is_hdr;
reg     [FPW-1:0]       flit_after_retry_stage_is_tail;
reg     [FPW-1:0]       flit_after_retry_stage_is_valid;
reg     [FPW-1:0]       flit_after_retry_stage_is_valid_mask_msb;
reg     [FPW-1:0]       flit_after_retry_stage_is_valid_mask_lsb;
reg     [FPW-1:0]       flit_after_retry_stage_is_error;
reg     [FPW-1:0]       flit_after_retry_stage_is_poisoned;
reg     [FPW-1:0]       flit_after_retry_stage_is_flow;
reg     [FPW-1:0]       flit_after_retry_stage_has_rtc;
reg     [FPW-1:0]       flit_after_retry_stage_is_start_retry;
reg     [FPW-1:0]       flit_after_retry_stage_is_start_retry_comb;

//------------------------------------------------------------------------------------SeqStage and Seqnum
reg     [128-1:0]       flit_after_seq_check                   [FPW-1:0];
reg     [FPW-1:0]       flit_after_seq_check_is_hdr;
reg     [FPW-1:0]       flit_after_seq_check_is_tail;
reg     [FPW-1:0]       flit_after_seq_check_is_valid;
reg     [FPW-1:0]       flit_after_seq_check_is_error;
reg     [FPW-1:0]       flit_after_seq_check_is_error_comb;
reg     [FPW-1:0]       flit_after_seq_check_is_poisoned;
reg     [FPW-1:0]       flit_after_seq_check_is_flow;
reg     [FPW-1:0]       flit_after_seq_check_has_rtc;
reg     [FPW-1:0]       flit_after_seq_check_is_start_retry;

reg     [2:0]           next_seqnum;
reg     [2:0]           next_seqnum_comb; //use param instead
reg     [2:0]           first_seq_after_error;

//------------------------------------------------------------------------------------Invalidation Stage
localparam CYCLES_TO_COMPLETE_FULL_PACKET   =   (FPW == 2) ? 5 :
                                                (FPW == 4) ? 3 : //Assuming Max Pkt size = 9 FLITs
                                                (FPW == 6) ? 3 :
                                                (FPW == 8) ? 2 :
                                                1;

//Regs to retrieve the pkt length, assign the length to correspoding tail. The packet will be invalidated then
reg     [3:0]        lng_per_tail      [FPW-1:0] ;
reg     [3:0]        lng_per_tail_comb [FPW-1:0] ;
reg     [3:0]        lng_temp;
reg     [3:0]        lng_comb;
//Signal that an error was detected. Invalid all FLITs after
reg                  error_detected;

//Assign FLITs to word, necessary for the invalidation stage pipeline
wire   [DWIDTH-1:0]            flit_after_seq_check_word;
generate
        for(f = 0; f < (FPW); f = f + 1) begin : reorder_flits_after_seq_to_word
            assign flit_after_seq_check_word[(f*128)+128-1:(f*128)] = flit_after_seq_check[f];
        end
endgenerate

reg     [DWIDTH-1:0]    flit_in_invalidation_data          [CYCLES_TO_COMPLETE_FULL_PACKET-1:0];
reg     [FPW-1:0]       flit_in_invalidation_is_hdr        [CYCLES_TO_COMPLETE_FULL_PACKET-1:0];
reg     [FPW-1:0]       flit_in_invalidation_is_tail       [CYCLES_TO_COMPLETE_FULL_PACKET-1:0];
reg     [FPW-1:0]       flit_in_invalidation_is_valid      [CYCLES_TO_COMPLETE_FULL_PACKET-1:0];
reg     [FPW-1:0]       flit_in_invalidation_mask_error;
reg     [FPW-1:0]       flit_in_invalidation_is_poisoned   [CYCLES_TO_COMPLETE_FULL_PACKET-1:0];
reg     [FPW-1:0]       flit_in_invalidation0_is_poisoned_comb;
reg     [FPW-1:0]       flit_in_invalidation_is_flow       [CYCLES_TO_COMPLETE_FULL_PACKET-1:0];
reg     [FPW-1:0]       flit_in_invalidation_has_rtc       [CYCLES_TO_COMPLETE_FULL_PACKET-1:0];
reg     [FPW-1:0]       flit_in_invalidation_is_start_retry[CYCLES_TO_COMPLETE_FULL_PACKET-1:0];

//------------------------------------------------------------------------------------Checked FLITs
wire     [128-1:0]      checked_flit             [FPW-1:0];
wire     [FPW-1:0]      checked_flit_is_poisoned;
wire     [FPW-1:0]      checked_flit_is_valid;
wire     [FPW-1:0]      checked_flit_is_hdr;
wire     [FPW-1:0]      checked_flit_is_tail;
wire     [FPW-1:0]      checked_flit_has_rtc;
wire     [FPW-1:0]      checked_flit_is_flow;
wire     [FPW-1:0]      checked_flit_is_start_retry;

assign checked_flit_is_hdr         = flit_in_invalidation_is_hdr       [CYCLES_TO_COMPLETE_FULL_PACKET-1] & flit_in_invalidation_is_valid     [CYCLES_TO_COMPLETE_FULL_PACKET-1];
assign checked_flit_is_tail        = flit_in_invalidation_is_tail      [CYCLES_TO_COMPLETE_FULL_PACKET-1] & flit_in_invalidation_is_valid     [CYCLES_TO_COMPLETE_FULL_PACKET-1];
assign checked_flit_is_valid       = flit_in_invalidation_is_valid     [CYCLES_TO_COMPLETE_FULL_PACKET-1] ;
assign checked_flit_is_poisoned    = flit_in_invalidation_is_poisoned  [CYCLES_TO_COMPLETE_FULL_PACKET-1] & flit_in_invalidation_is_valid     [CYCLES_TO_COMPLETE_FULL_PACKET-1];
assign checked_flit_is_flow        = flit_in_invalidation_is_flow      [CYCLES_TO_COMPLETE_FULL_PACKET-1] & flit_in_invalidation_is_valid     [CYCLES_TO_COMPLETE_FULL_PACKET-1];
assign checked_flit_has_rtc        = flit_in_invalidation_has_rtc      [CYCLES_TO_COMPLETE_FULL_PACKET-1] & flit_in_invalidation_is_valid     [CYCLES_TO_COMPLETE_FULL_PACKET-1];
assign checked_flit_is_start_retry = flit_in_invalidation_is_start_retry[CYCLES_TO_COMPLETE_FULL_PACKET-1];

generate
        for(f = 0; f < (FPW); f = f + 1) begin : reorder_invalidation_word_back_to_flits
            assign checked_flit[f] = flit_in_invalidation_data[CYCLES_TO_COMPLETE_FULL_PACKET-1][128-1+(f*128):f*128];
        end
endgenerate

//------------------------------------------------------------------------------------Counter
reg [LOG_FPW:0]         rf_cnt_poisoned_comb;
reg [LOG_FPW:0]         rf_cnt_rsp_comb;

//------------------------------------------------------------------------------------Input Buffer
reg     [LOG_FPW:0]          tokens_out_of_fifo_sum_comb;
reg     [LOG_FPW:0]          tokens_poisoned;
reg     [7:0]                rtc_sum_comb; //for 8 FLIT config, maximum 8*31 tokens will be returned per cycle

reg     [128-1:0]            input_buffer_d_in_flit    [FPW-1:0];
reg     [FPW-1:0]            input_buffer_valid;
reg     [FPW-1:0]            input_buffer_is_hdr;
reg     [FPW-1:0]            input_buffer_is_tail;
reg     [FPW-1:0]            input_buffer_is_error_rsp;
wire    [DWIDTH+(4*FPW)-1:0] input_buffer_d_in;
wire    [DWIDTH+(4*FPW)-1:0] input_buffer_d_out;
wire                         input_buffer_empty;
reg                          input_buffer_shift_in;
wire                         input_buffer_shift_out;
assign                       input_buffer_shift_out    =   ~(input_buffer_empty || d_out_fifo_a_full);

generate
        for(f = 0; f < (FPW); f = f + 1) begin : assign_flits_to_input_buffer_to_a_single_reg
            assign input_buffer_d_in[f*128+128-1:f*128] = input_buffer_d_in_flit[f];
            assign input_buffer_d_in[DWIDTH+f]          = input_buffer_valid[f];
            assign input_buffer_d_in[DWIDTH+f+FPW]      = input_buffer_is_hdr[f];
            assign input_buffer_d_in[DWIDTH+f+(2*FPW)]  = input_buffer_is_tail[f];
            assign input_buffer_d_in[DWIDTH+f+(3*FPW)]  = input_buffer_is_error_rsp[f];
        end
endgenerate

//------------------------------------------------------------------------------------LINK RETRY
reg  [5:0]     irtry_start_retry_cnt;
reg  [5:0]     irtry_clear_error_cnt;
reg  [5:0]     irtry_start_retry_cnt_comb;
reg  [5:0]     irtry_clear_error_cnt_comb;
reg            irtry_clear_trig;
reg            irtry_clear_trig_comb;

//=====================================================================================================
//-----------------------------------------------------------------------------------------------------
//---------ACTUAL LOGIC STARTS HERE--------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------
//=====================================================================================================

//========================================================================================================================================
//------------------------------------------------------------------INIT
//========================================================================================================================================
always @(posedge clk)  begin
    for(i_l = 0;i_l<NUM_LANES;i_l=i_l+1)begin
        init_data_per_lane[i_l] <= descrambled_data_per_lane[i_l];
    end
end

`ifdef ASYNC_RES
always @(posedge clk or negedge res_n)  begin `else
always @(posedge clk)  begin `endif
if(!res_n) begin
    //----Misc
    init_descrambler_aligned         <= {NUM_LANES{1'b0}};
    init_descrambler_part_aligned    <= {NUM_LANES{1'b0}};
    init_bit_slip               <= {NUM_LANES{1'b0}};
    init_bit_slip_cnt           <= 6'h0;
    init_wait_time              <= 5'h0;
    init_tmp_seq                <= 4'h0;
    init_lane_cnt               <= {LOG_NUM_LANES{1'b0}};
    init_prbs_seen              <= 1'b0;
    rf_hmc_init_status          <= HMC_DOWN;
    rf_link_status              <= LINK_DOWN;
    rf_lane_polarity            <= {NUM_LANES{1'b0}};
    rf_lane_reversal_detected   <= 1'b0;
    rf_descramblers_locked      <= {NUM_LANES{1'b0}};
end
else begin

    rf_descramblers_locked  <= init_descrambler_locked;
    init_bit_slip           <= {NUM_LANES{1'b0}};


    if(rf_hmc_sleep || !rf_hmc_init_cont_set) begin
        rf_link_status <= LINK_DOWN;
    end else if(rf_link_status == LINK_DOWN) begin
        //Begin (Re-)Init
        init_descrambler_aligned         <= {NUM_LANES{1'b0}};
        init_descrambler_part_aligned    <= {NUM_LANES{1'b0}};
        init_wait_time              <= 5'h1f;
        init_tmp_seq                <= 4'h0;
        init_lane_cnt               <= {LOG_NUM_LANES{1'b0}};
        init_prbs_seen              <= 1'b0;
        rf_hmc_init_status          <= HMC_DOWN;
        rf_link_status              <= LINK_INIT;
        rf_lane_polarity            <= {NUM_LANES{1'b0}};
        rf_lane_reversal_detected   <= 1'b0;
        rf_descramblers_locked      <= {NUM_LANES{1'b0}};
    end

    //Detect Lane polarity when HMC is sending first NULLs
    if(&rf_descramblers_locked && rf_link_status == LINK_INIT) begin
        for(i_l = 0;i_l<NUM_LANES;i_l=i_l+1)begin
            if(init_data_per_lane[i_l] == {WIDTH_PER_LANE{1'b1}})begin
                rf_lane_polarity[i_l] <=  1'b1;
            end
        end
    end

    if(rf_hmc_init_status == HMC_DOWN) begin
        if(|init_valid_flit_src) begin
            init_prbs_seen <= 1'b1;
        end 
        if(!init_valid_flit_src && init_prbs_seen && &rf_descramblers_locked) begin
            rf_hmc_init_status <= HMC_NULL;
        end
    end

    //When TX block sends ts1, start init process
    if(rf_tx_sends_ts1 && &init_valid_flit_src) begin
        rf_hmc_init_status      <= HMC_TS1;
    end

    if(rf_hmc_init_status==HMC_TS1) begin
        // -------------------------------------------------------------------------TS1 AND DESCRAMBLER SYNCHRONIZATION
        if(!rf_all_descramblers_aligned) begin      // repeat this until all descramblers are aligned !!

            if(|init_wait_time == 1'b0)begin

                init_tmp_seq    <= init_tmp_seq + INIT_SEQ_INC_PER_CYCLE;

                if(|init_bit_slip_cnt == 1'b0)begin

                    init_lane_cnt        <= init_lane_cnt + 1;

                    if(!init_descrambler_part_aligned[init_lane_cnt])begin     
                        init_bit_slip[init_lane_cnt]                     <= ~init_lane_has_correct_ts1[init_lane_cnt];
                        //if the current lane is more advanced than the current reference lane, set this lane as new reference
                        if(init_seq_diff < 2 && init_lane_has_correct_ts1[init_lane_cnt]) begin
                            init_tmp_seq                            <= init_data_per_lane[init_lane_cnt][3:0] + INIT_SEQ_INC_PER_CYCLE;
                        end
                    end

                    if(&init_descrambler_part_aligned) begin
                        if(|init_seq_diff==1'b0 && init_lane_has_correct_ts1[init_lane_cnt])begin
                            init_descrambler_aligned[init_lane_cnt] <= 1'b1;
                        end else begin
                            init_bit_slip[init_lane_cnt] <= 1'b1;
                        end
                    end else begin
                        init_descrambler_part_aligned[init_lane_cnt]          <= init_lane_has_correct_ts1[init_lane_cnt];
                    end

                    if(init_lane_cnt == NUM_LANES-1)begin
                        init_bit_slip_cnt <= rf_bit_slip_time;
                    end

                end else begin
                    init_bit_slip_cnt <= init_bit_slip_cnt -1;
                end

            end else begin
                init_wait_time <= init_wait_time -1;
            end
        // -------------------------------------------------------------------------SECOND NULL SEQUENCE
        end else begin  // now that all is synchronized continue with NULL and TRET

            //lane reversal detected, reverse the input stream lane by lane
            if(init_data_per_lane[0][7:4] ==  ts1_lane7or15_portion)begin
                rf_lane_reversal_detected   <= 1'b1;
            end

            //when received NULLs again, init done (initial TRETs are treated as normal packets)
            if(|init_valid_flit_src == 1'b0)begin
                rf_link_status      <= LINK_UP;
                rf_hmc_init_status  <= HMC_UP;
            end
        end
    end
end
end

//========================================================================================================================================
//------------------------------------------------------------------Packet Processing
//========================================================================================================================================
//==================================================================================
//---------------------------------Detect HDR,Tail,Valid Flits and provide to CRC logic
//==================================================================================
always @(*)  begin
    //Use the remaining payload from last cycle
    data2crc_payload_remain_comb = data2crc_payload_remain;

    data2crc_hdr_comb    = {FPW{1'b0}};
    data2crc_tail_comb   = {FPW{1'b0}};
    data2crc_valid_comb  = {FPW{1'b0}};

    for(i_f=0;i_f<FPW;i_f=i_f+1) begin

        data2crc_lng_per_flit_comb[i_f] = {128{1'b0}};

        if(data2crc_payload_remain_comb ==4'h1) begin
            data2crc_tail_comb[i_f]  = 1'b1;
        end

        if(data2crc_payload_remain_comb) begin
            data2crc_valid_comb[i_f]     = 1'b1;
            data2crc_payload_remain_comb = data2crc_payload_remain_comb - 1;
        end else if(valid_flit_src[i_f])begin

            data2crc_hdr_comb[i_f]   = 1'b1;
            data2crc_valid_comb[i_f] = 1'b1;

            if(lng(d_in_flit[i_f]) < 2 || lng(d_in_flit[i_f]) > 9) begin
                //Treat false lng values as single FLIT packets which will force error abort mode
                data2crc_tail_comb[i_f]         = 1'b1;
                data2crc_lng_per_flit_comb[i_f] = 1;
            end else begin
                data2crc_payload_remain_comb    = lng(d_in_flit[i_f]) -1;
                data2crc_lng_per_flit_comb[i_f] = lng(d_in_flit[i_f]);
            end
        end

    end
end

//Register the combinational logic from previous stage
`ifdef ASYNC_RES
always @(posedge clk or negedge res_n)  begin `else
always @(posedge clk)  begin `endif
if(!res_n) begin

    data2crc_hdr    <= {FPW{1'b0}};
    data2crc_tail   <= {FPW{1'b0}};
    data2crc_valid  <= {FPW{1'b0}};

    data2crc_payload_remain  <= {4{1'b0}};

    for(i_f=0;i_f<FPW;i_f=i_f+1) begin
        data2crc_lng_per_flit[i_f] <= {128{1'b0}};
    end

    data2crc <= {DWIDTH{1'b0}};

end else begin
    if(link_is_up) begin
        data2crc_hdr    <= data2crc_hdr_comb;
        data2crc_tail   <= data2crc_tail_comb;
        data2crc_valid  <= data2crc_valid_comb;
    end

    data2crc_payload_remain  <= data2crc_payload_remain_comb;

    for(i_f=0;i_f<FPW;i_f=i_f+1) begin
        data2crc_lng_per_flit[i_f] <= data2crc_lng_per_flit_comb[i_f];
    end

    data2crc  <= d_in;

end
end

//==================================================================================
//---------------------------------LNG/DLN check
//==================================================================================
`ifdef ASYNC_RES
always @(posedge clk or negedge res_n)  begin `else
always @(posedge clk)  begin `endif
if(!res_n) begin

    flit_after_lng_check_is_hdr       <= {FPW{1'b0}};
    flit_after_lng_check_is_tail      <= {FPW{1'b0}};
    flit_after_lng_check_is_valid     <= {FPW{1'b0}};
    flit_after_lng_check_is_poisoned  <= {FPW{1'b0}};
    flit_after_lng_check_is_flow      <= {FPW{1'b0}};
    flit_after_lng_check_has_rtc      <= {FPW{1'b0}};
    flit_after_lng_check_is_error     <= {FPW{1'b0}};

    for(i_f = 0; i_f < FPW; i_f = i_f + 1) begin
        flit_after_lng_check[i_f]     <= {128{1'b0}};
    end

end else begin
    flit_after_lng_check_is_hdr       <= crc_d_out_flit_is_hdr;
    flit_after_lng_check_is_tail      <= crc_d_out_flit_is_tail;
    flit_after_lng_check_is_valid     <= crc_d_out_flit_is_valid;
    flit_after_lng_check_is_poisoned  <= crc_d_out_flit_is_poisoned;
    flit_after_lng_check_is_flow      <= crc_d_out_flit_is_flow;
    flit_after_lng_check_has_rtc      <= crc_d_out_flit_has_rtc;
    flit_after_lng_check_is_error     <= crc_d_out_flit_is_error;

    for(i_f = 0; i_f < FPW; i_f = i_f + 1) begin
        flit_after_lng_check[i_f]     <= crc_d_out_flit[i_f];
    end

    //perform lng/dln check
    for(i_f = 0; i_f < FPW; i_f = i_f + 1) begin
        if(crc_d_out_flit_is_hdr[i_f] && (lng(crc_d_out_flit[i_f]) != dln(crc_d_out_flit[i_f]))) begin
            flit_after_lng_check_is_error[i_f]  <= 1'b1;
        end
    end
end
end

//====================================================================
//---------------------------------Start Retry Stage
//====================================================================
//-- Count all types of IRTRY packets
always @(*)  begin

    //Set the lower bit mask for the next stage: Mask out all error FLITs
    flit_after_retry_stage_is_valid_mask_lsb   = {FPW{1'b1}};
    for(i_f = FPW-1; i_f >=0; i_f = i_f - 1) begin
        if(flit_after_lng_check_is_error[i_f])begin
            //Pass the tail in case it is an crc error so that the corresponding FLITs of the packet can be invalidated
            //but mask out single flit packets!
            flit_after_retry_stage_is_valid_mask_lsb = {FPW{1'b1}} >> (FPW-i_f-(flit_after_lng_check_is_tail[i_f] & !flit_after_lng_check_is_hdr[i_f]));
        end
    end

    //Next up, count both types of irtry packets and set the mask accordingly for irtry start packets in error abort mode and the
    //final clear abort FLIT that reaches the threshold

    flit_after_retry_stage_is_start_retry_comb = {FPW{1'b0}};

    if( (tx_error_abort_mode && !irtry_clear_trig) ||
        |(flit_after_retry_stage_is_error) ||
        |(flit_after_seq_check_is_error)
    )begin
        flit_after_retry_stage_is_valid_mask_msb = {FPW{1'b0}};
    end else begin
        flit_after_retry_stage_is_valid_mask_msb = {FPW{1'b1}};
    end

    irtry_clear_trig_comb      = 1'b0;

    irtry_clear_error_cnt_comb = irtry_clear_error_cnt;
    irtry_start_retry_cnt_comb = irtry_start_retry_cnt;


    for(i_f = 0; i_f < (FPW); i_f = i_f + 1) begin

        if( flit_after_lng_check_is_flow[i_f] &&
            cmd(flit_after_lng_check[i_f]) == {CMD_FLOW,CMD_IRTRY} &&
            !flit_after_lng_check_is_error[i_f]
        ) begin

            if(irtry_start_retry_flag(flit_after_lng_check[i_f])) begin
                //it's a start tx retry pkt
                irtry_start_retry_cnt_comb   = irtry_start_retry_cnt_comb + 6'h1;
                irtry_clear_error_cnt_comb   = 6'h0;
            end else begin
                //must be clear error pkt
                irtry_clear_error_cnt_comb   = irtry_clear_error_cnt_comb + 6'h1;
                irtry_start_retry_cnt_comb   = 6'h0;
            end

            if(irtry_start_retry_cnt_comb == rf_irtry_received_threshold) begin
                //The start retry packet that reaches the trehold is treated as valid and will trigger tx retry
                flit_after_retry_stage_is_valid_mask_msb[i_f]   = 1'b1;
                flit_after_retry_stage_is_start_retry_comb[i_f] = 1'b1;
            end

            //Clear error abort when threshold reached, allow following FLITs to be valid
            if(irtry_clear_error_cnt_comb == rf_irtry_received_threshold) begin
                irtry_clear_trig_comb                    = 1'b1;
                flit_after_retry_stage_is_valid_mask_msb = {FPW{1'b1}} << (i_f);
            end

        end else begin
            //Reset both counters when received a non-irtry packet
            irtry_start_retry_cnt_comb = 6'h0;
            irtry_clear_error_cnt_comb = 6'h0;
        end
    end
end

//Save the temporary counts to be re-used in the next cycle and register the clear trigger
`ifdef ASYNC_RES
always @(posedge clk or negedge res_n)  begin `else
always @(posedge clk)  begin `endif
if(!res_n) begin
    irtry_clear_trig      <= 1'b0;

    irtry_clear_error_cnt <= {6{1'b0}};
    irtry_start_retry_cnt <= {6{1'b0}};

end else begin
    irtry_clear_trig      <= irtry_clear_trig_comb;

    irtry_clear_error_cnt <= irtry_clear_error_cnt_comb;
    irtry_start_retry_cnt <= irtry_start_retry_cnt_comb;
end
end

//Propagate data and apply the valid masks
`ifdef ASYNC_RES
always @(posedge clk or negedge res_n)  begin `else
always @(posedge clk)  begin `endif
if(!res_n) begin
    for(i_f = 0;i_f<(FPW);i_f=i_f+1) begin
        flit_after_retry_stage[i_f]       <= {128{1'b0}};
    end
    flit_after_retry_stage_is_hdr         <= {FPW{1'b0}};
    flit_after_retry_stage_is_tail        <= {FPW{1'b0}};
    flit_after_retry_stage_is_poisoned    <= {FPW{1'b0}};
    flit_after_retry_stage_is_flow        <= {FPW{1'b0}};
    flit_after_retry_stage_has_rtc        <= {FPW{1'b0}};
    flit_after_retry_stage_is_error       <= {FPW{1'b0}};
    flit_after_retry_stage_is_valid       <= {FPW{1'b0}};
    flit_after_retry_stage_is_start_retry <= 1'b0;
end else begin

    for(i_f = 0;i_f<(FPW);i_f=i_f+1) begin
        flit_after_retry_stage[i_f] <= flit_after_lng_check[i_f];
    end
    flit_after_retry_stage_is_hdr         <= flit_after_lng_check_is_hdr;
    flit_after_retry_stage_is_tail        <= flit_after_lng_check_is_tail;
    flit_after_retry_stage_is_poisoned    <= flit_after_lng_check_is_poisoned &
                                             flit_after_retry_stage_is_valid_mask_msb &
                                             flit_after_retry_stage_is_valid_mask_lsb;
    flit_after_retry_stage_is_flow        <= flit_after_lng_check_is_flow;
    flit_after_retry_stage_has_rtc        <= flit_after_lng_check_has_rtc;
    flit_after_retry_stage_is_error       <= flit_after_lng_check_is_error;
    flit_after_retry_stage_is_valid       <= flit_after_lng_check_is_valid &
                                             flit_after_retry_stage_is_valid_mask_msb &
                                             flit_after_retry_stage_is_valid_mask_lsb;
    flit_after_retry_stage_is_start_retry <= flit_after_retry_stage_is_start_retry_comb;
end
end

//-------------------------------------------Error abort mode
`ifdef ASYNC_RES
always @(posedge clk or negedge res_n)  begin `else
always @(posedge clk)  begin `endif
if(!res_n) begin

    //TX signaling
    tx_error_abort_mode             <= 1'b0;
    tx_error_abort_mode_cleared     <= 1'b0;

end else begin

    tx_error_abort_mode_cleared <= 1'b0;

    if(irtry_clear_trig) begin
        tx_error_abort_mode         <= 1'b0;
        tx_error_abort_mode_cleared <= 1'b1;
    end

    //Set error abort mode again if error detected
    if(|flit_after_lng_check_is_error || flit_after_seq_check_is_error)begin
        tx_error_abort_mode <= 1'b1;
    end

end
end

//==================================================================================
//---------------------------------SEQ check
//==================================================================================
//Check the seqnum FLIT by FLIT. Assign the last received seqnum when error abort mode is cleared
//!Lots of logic levels for 8FLIT config
always @(*)  begin

    next_seqnum_comb                    = 3'h0;
    flit_after_seq_check_is_error_comb  = {FPW{1'b0}};

    for(i_f = 0; i_f < (FPW); i_f = i_f + 1) begin
        if(flit_after_retry_stage_has_rtc[i_f]) begin
        //All packets that have an RTC also have a valid seqnum
            if(seq(flit_after_retry_stage[i_f]) == next_seqnum + next_seqnum_comb) begin
                next_seqnum_comb = next_seqnum_comb + 3'h1;
            end else begin
                flit_after_seq_check_is_error_comb[i_f]  = 1'b1;
            end
        end
    end
end

`ifdef ASYNC_RES
always @(posedge clk or negedge res_n)  begin `else
always @(posedge clk)  begin `endif
if(!res_n) begin

    //We expect the first packet to have the seqnum 1
    next_seqnum                         <= 3'h1;

    flit_after_seq_check_is_hdr         <= {FPW{1'b0}};
    flit_after_seq_check_is_tail        <= {FPW{1'b0}};
    flit_after_seq_check_is_valid       <= {FPW{1'b0}};
    flit_after_seq_check_is_poisoned    <= {FPW{1'b0}};
    flit_after_seq_check_is_flow        <= {FPW{1'b0}};
    flit_after_seq_check_has_rtc        <= {FPW{1'b0}};
    flit_after_seq_check_is_error       <= {FPW{1'b0}};
    flit_after_seq_check_is_start_retry <= {FPW{1'b0}};
    for(i_f = 0; i_f < (FPW); i_f = i_f + 1) begin
        flit_after_seq_check[i_f]     <= {128{1'b0}};
    end

end else begin

    //Set the expected sequence number to the first one after error abort mode was cleared
    //otherwise apply the last seqnum + combinatioanl offset
    if(irtry_clear_trig_comb) begin
        next_seqnum     <= first_seq_after_error + next_seqnum_comb;
    end else begin
        next_seqnum     <= next_seqnum + next_seqnum_comb;
    end

    //propage data to next stage and include any error bits that were detected during sequence number check
    flit_after_seq_check_is_hdr         <= flit_after_retry_stage_is_hdr;
    flit_after_seq_check_is_tail        <= flit_after_retry_stage_is_tail;
    flit_after_seq_check_is_valid       <= flit_after_retry_stage_is_valid;
    flit_after_seq_check_is_poisoned    <= flit_after_retry_stage_is_poisoned;
    flit_after_seq_check_is_flow        <= flit_after_retry_stage_is_flow;
    flit_after_seq_check_has_rtc        <= flit_after_retry_stage_has_rtc;
    flit_after_seq_check_is_error       <= flit_after_retry_stage_is_error |
                                           flit_after_seq_check_is_error_comb;
    flit_after_seq_check_is_start_retry <= flit_after_retry_stage_is_start_retry;
    for(i_f = 0; i_f < (FPW); i_f = i_f + 1) begin
        flit_after_seq_check[i_f]     <= flit_after_retry_stage[i_f];
    end

end
end

//==================================================================================
//---------------------------------Retrieve the lengths to invalide FLITs
//==================================================================================
always @(*)  begin
//Retrieve the length from the header and assign it to the tail. This information will be used in the
//invalidation stage to mask out FLITs that belong to the faulty packet

    lng_comb = lng_temp;

    for(i_f = 0; i_f < (FPW); i_f = i_f + 1) begin

        if(flit_after_retry_stage_is_hdr[i_f]) begin
            if( lng(flit_after_retry_stage[i_f]) < 2 ||
                lng(flit_after_retry_stage[i_f]) > 9
            ) begin
                lng_comb = 1;
            end else begin
                lng_comb = lng(flit_after_retry_stage[i_f]);
            end
        end

        if(flit_after_retry_stage_is_tail[i_f]) begin
            lng_per_tail_comb[i_f] = lng_comb;
        end else begin
            lng_per_tail_comb[i_f] = {4{1'b0}};
        end

    end
end

//Register combinational values
`ifdef ASYNC_RES
always @(posedge clk or negedge res_n)  begin `else
always @(posedge clk)  begin `endif
if(!res_n) begin
    for(i_f = 0; i_f < (FPW); i_f = i_f + 1) begin
        lng_per_tail[i_f] <= 0;
    end
    lng_temp    <= {4{1'b0}};
end else begin
    for(i_f = 0; i_f < (FPW); i_f = i_f + 1) begin
        lng_per_tail[i_f] <= lng_per_tail_comb[i_f];
    end
    lng_temp    <= lng_comb;
end
end

//==================================================================================
//---------------------------------FLIT Invalidation Stage
//==================================================================================
//Constant propagation for some parts of the invalidation stage
`ifdef ASYNC_RES
always @(posedge clk or negedge res_n)  begin `else
always @(posedge clk)  begin `endif
if(!res_n) begin

    for(i_c=0; i_c<(CYCLES_TO_COMPLETE_FULL_PACKET); i_c=i_c+1) begin
        flit_in_invalidation_data[i_c]            <= {DWIDTH{1'b0}};
        flit_in_invalidation_is_hdr[i_c]          <= {FPW{1'b0}};
        flit_in_invalidation_is_tail[i_c]         <= {FPW{1'b0}};
        flit_in_invalidation_is_flow[i_c]         <= {FPW{1'b0}};
        flit_in_invalidation_has_rtc[i_c]         <= {FPW{1'b0}};
        flit_in_invalidation_is_start_retry[i_c]  <= {FPW{1'b0}};
    end
end else begin
    flit_in_invalidation_data[0]            <= flit_after_seq_check_word;
    flit_in_invalidation_is_hdr[0]          <= flit_after_seq_check_is_hdr;
    flit_in_invalidation_is_tail[0]         <= flit_after_seq_check_is_tail;
    flit_in_invalidation_is_flow[0]         <= flit_after_seq_check_is_flow;
    flit_in_invalidation_has_rtc[0]         <= flit_after_seq_check_has_rtc;
    flit_in_invalidation_is_start_retry[0]  <= flit_after_seq_check_is_start_retry;

    for(i_c=0; i_c<(CYCLES_TO_COMPLETE_FULL_PACKET-1); i_c=i_c+1) begin
        flit_in_invalidation_data[i_c+1]            <= flit_in_invalidation_data[i_c];
        flit_in_invalidation_is_hdr[i_c+1]          <= flit_in_invalidation_is_hdr[i_c];
        flit_in_invalidation_is_tail[i_c+1]         <= flit_in_invalidation_is_tail[i_c];
        flit_in_invalidation_is_flow[i_c+1]         <= flit_in_invalidation_is_flow[i_c];
        flit_in_invalidation_has_rtc[i_c+1]         <= flit_in_invalidation_has_rtc[i_c];
        flit_in_invalidation_is_start_retry[i_c+1]  <= flit_in_invalidation_is_start_retry[i_c];
    end
end
end

//Mark all poisoned FLITs
always @(*)  begin
    flit_in_invalidation0_is_poisoned_comb  = {FPW{1'b0}};
    for(i_f = FPW-1; i_f>=0; i_f = i_f-1) begin
        if(flit_after_seq_check_is_poisoned[i_f])begin
            flit_in_invalidation0_is_poisoned_comb =flit_in_invalidation0_is_poisoned_comb | 
                                                    (({FPW{1'b1}} >> (FPW-i_f-1)) & ~({FPW{1'b1}} >> lng_per_tail[i_f]+(FPW-i_f-1)));
        end
    end
end
`ifdef ASYNC_RES
always @(posedge clk or negedge res_n)  begin `else
always @(posedge clk)  begin `endif
if(!res_n) begin

    for(i_c = 0; i_c < (CYCLES_TO_COMPLETE_FULL_PACKET); i_c = i_c + 1) begin
        flit_in_invalidation_is_poisoned[i_c]  <= 0;
    end

end else begin
    flit_in_invalidation_is_poisoned[0]     <= flit_in_invalidation0_is_poisoned_comb;

    for(i_c = 0; i_c < (CYCLES_TO_COMPLETE_FULL_PACKET-1); i_c = i_c + 1) begin
        flit_in_invalidation_is_poisoned[i_c+1] <= flit_in_invalidation_is_poisoned[i_c];
    end

    //If there is a poisoned packet mark all FLITs as such
    for(i_f = FPW-1; i_f>=0; i_f = i_f-1) begin
        if(flit_after_seq_check_is_poisoned[i_f]) begin

            // flit_in_invalidation_is_poisoned[0] <= ({FPW{1'b1}} >> (FPW-i_f-1)) & ~({FPW{1'b1}} >> lng_per_tail[i_f]+(FPW-i_f-1));

            for(i_c = 0; i_c < (CYCLES_TO_COMPLETE_FULL_PACKET-1); i_c = i_c + 1) begin
                if(lng_per_tail[i_f] > ((i_c)*FPW)+i_f+1) begin
                    flit_in_invalidation_is_poisoned[i_c+1] <= flit_in_invalidation_is_poisoned[i_c] | ~({FPW{1'b1}} >> lng_per_tail[i_f]-(i_c*FPW)-i_f-1);
                end
            end

        end
    end
end
end


//Invalidate FLITs that belong to errorenous packets
`ifdef ASYNC_RES
always @(posedge clk or negedge res_n)  begin `else
always @(posedge clk)  begin `endif
if(!res_n) begin

    for(i_c = 0; i_c < (CYCLES_TO_COMPLETE_FULL_PACKET); i_c = i_c + 1) begin
        flit_in_invalidation_is_valid[i_c]     <= 0;
    end
    error_detected                  <= 0;
    flit_in_invalidation_mask_error <= {FPW{1'b1}};

end else begin

    //Reset the masks for invalidation stages
    flit_in_invalidation_mask_error         <= {FPW{1'b1}};

    if(irtry_clear_trig) begin
        error_detected <= 0;
    end

    //Propate invalidation stages but apply error and poisoned masks to the second stage
    for(i_c = 1; i_c < (CYCLES_TO_COMPLETE_FULL_PACKET-1); i_c = i_c + 1) begin
        flit_in_invalidation_is_valid[i_c+1] <= flit_in_invalidation_is_valid[i_c];
    end
    flit_in_invalidation_is_valid[1] <= flit_in_invalidation_is_valid[0] & flit_in_invalidation_mask_error;

    if(error_detected) begin
        //There is no valid FLIT when an error was detected
        flit_in_invalidation_is_valid[0] <= {FPW{1'b0}};
    end else begin
        //First apply valids from previous stage
        flit_in_invalidation_is_valid[0] <= flit_after_seq_check_is_valid;

        //At least one FLIT contained an error in its tail. Leave all FLITs before the error untouched
        for(i_f = FPW-1; i_f>=0; i_f = i_f-1) begin
            if(flit_after_seq_check_is_error[i_f] && flit_after_seq_check_is_tail[i_f]) begin
                error_detected <= 1'b1;
                flit_in_invalidation_mask_error <= {FPW{1'b1}} >> (FPW-i_f-1+lng_per_tail[i_f]);
            end
        end

        //Now use the length of the packet to invalidate FLITs that may reside in the next stages already
        for(i_f = FPW-1; i_f>=0; i_f = i_f-1) begin
            if(flit_after_seq_check_is_error[i_f] && flit_after_seq_check_is_tail[i_f]) begin
                for(i_c = 0; i_c < (CYCLES_TO_COMPLETE_FULL_PACKET-1); i_c = i_c + 1) begin
                    if(lng_per_tail[i_f] > ((i_c)*FPW)+i_f+1) begin
                        flit_in_invalidation_is_valid[i_c+1] <= flit_in_invalidation_is_valid[i_c] &
                                                                ({FPW{1'b1}} >> lng_per_tail[i_f]-(i_c*FPW)-i_f-1);
                    end
                end
            end
        end
    end

end
end

//====================================================================
//---------------------------------FRP/RRP/RTC
//====================================================================
//Count Tokens that were returned
always @(*)  begin
    rtc_sum_comb                  = {8{1'b0}};
    for(i_f = 0; i_f < (FPW); i_f = i_f + 1) begin
        if(checked_flit_has_rtc[i_f])begin
            rtc_sum_comb                  =  rtc_sum_comb + rtc(checked_flit[i_f]);
        end
    end
end

//Extract FRP/RRP + last seq (which is necessary to check packets after error_abort_mode is cleared)
`ifdef ASYNC_RES
always @(posedge clk or negedge res_n)  begin `else
always @(posedge clk)  begin `endif
if(!res_n) begin

    tx_hmc_frp                      <= {8{1'b0}};
    tx_rrp                          <= {8{1'b0}};
    tx_returned_tokens              <= {8{1'b0}};
    first_seq_after_error           <= 3'h1;

    tx_link_retry                   <= 1'b0;

end else begin
    //Return tokens
    tx_returned_tokens              <= rtc_sum_comb;

    //Process FLITs and extract frp/seq/rrp if applicable
    for(i_f = 0; i_f < (FPW); i_f = i_f + 1) begin

        if(checked_flit_is_tail[i_f] || checked_flit_is_start_retry[i_f]) begin
            tx_rrp                  <=  rrp(checked_flit[i_f]);

            if(checked_flit_has_rtc[i_f])begin
                tx_hmc_frp                      <= frp(checked_flit[i_f]);
                first_seq_after_error           <= seq(checked_flit[i_f]) + 3'h1;
            end
        end
    end

    //-------------------------------------------TX retry
    tx_link_retry   <= 1'b0;

    if(|checked_flit_is_start_retry)begin
        tx_link_retry              <= 1'b1;
    end

end
end

//==================================================================================
//---------------------------------Fill the input buffer with all response packets
//==================================================================================
`ifdef ASYNC_RES
always @(posedge clk or negedge res_n)  begin `else
always @(posedge clk)  begin `endif
if(!res_n) begin

    input_buffer_shift_in     <= 1'b0;
    input_buffer_valid        <= {FPW{1'b0}};
    input_buffer_is_hdr       <= {FPW{1'b0}};
    input_buffer_is_tail      <= {FPW{1'b0}};
    input_buffer_is_error_rsp <= {FPW{1'b0}};

    for(i_f = 0; i_f < (FPW); i_f = i_f + 1) begin
        input_buffer_d_in_flit[i_f]     <= {128{1'b0}};
    end

end else begin

    input_buffer_shift_in       <= 1'b0;
    input_buffer_is_error_rsp   <= {FPW{1'b0}};

    for(i_f = 0; i_f < (FPW); i_f = i_f + 1) begin
        input_buffer_d_in_flit[i_f]        <= {128{1'b0}};

        //Flow and poisoned packets are not forwarded
        if(checked_flit_is_valid[i_f]) begin
            if(!checked_flit_is_flow[i_f] && !checked_flit_is_poisoned[i_f])begin
                input_buffer_d_in_flit[i_f]           <= checked_flit[i_f];
            end
            if(checked_flit_is_hdr[i_f] && (cmd(checked_flit[i_f])==CMD_RSP_ERROR)) begin
                input_buffer_is_error_rsp[i_f]  <= 1'b1;
            end
        end
    end

    //Mask out any flow or poisoned packets
    input_buffer_valid      <=  checked_flit_is_valid &
                                ~checked_flit_is_flow &
                                ~checked_flit_is_poisoned;
    input_buffer_is_hdr     <=  checked_flit_is_hdr   &
                                ~checked_flit_is_flow &
                                ~checked_flit_is_poisoned;
    input_buffer_is_tail    <=  checked_flit_is_tail  &
                                ~checked_flit_is_flow &
                                ~checked_flit_is_poisoned;

    //If there is still a valid packet remaining after applying the mask
    if(|(checked_flit_is_valid  & ~checked_flit_is_flow & ~checked_flit_is_poisoned))begin
       input_buffer_shift_in    <= 1'b1;
    end

end
end

always @(*)  begin
    tokens_poisoned          = {LOG_FPW+1{1'b0}};

    for(i_f=0; i_f<FPW; i_f=i_f+1) begin
        tokens_poisoned  =   tokens_poisoned + checked_flit_is_poisoned[i_f];
    end
end

`ifdef ASYNC_RES
always @(posedge clk or negedge res_n)  begin `else
always @(posedge clk)  begin `endif
if(!res_n) begin
    tx_hmc_poisoned_tokens_to_return    <= {LOG_FPW+1{1'b0}};
end else begin
    tx_hmc_poisoned_tokens_to_return    <= tokens_poisoned;
end
end

//==================================================================================
//---------------------------------Count responses and poisoned packets
//==================================================================================
always @(*)  begin
    rf_cnt_poisoned_comb = {LOG_FPW+1{1'b0}};
    rf_cnt_rsp_comb      = {LOG_FPW+1{1'b0}};

    for(i_f = 0; i_f < (FPW); i_f = i_f + 1) begin
        if(checked_flit_is_poisoned[i_f] && checked_flit_is_hdr[i_f])begin
            rf_cnt_poisoned_comb = rf_cnt_poisoned_comb + {{LOG_FPW{1'b0}},1'b1};
        end
        if(input_buffer_is_tail[i_f] && !input_buffer_is_error_rsp[i_f])begin
            //if its a tail but not error response
            rf_cnt_rsp_comb = rf_cnt_rsp_comb + {{LOG_FPW{1'b0}},1'b1};
        end
    end
end

`ifdef ASYNC_RES
always @(posedge clk or negedge res_n)  begin `else
always @(posedge clk)  begin `endif
if(!res_n) begin
    rf_cnt_poisoned <= {HMC_RF_RWIDTH{1'b0}};
    rf_cnt_rsp      <= {HMC_RF_RWIDTH{1'b0}};
end else begin
    rf_cnt_poisoned <= rf_cnt_poisoned + {{HMC_RF_RWIDTH-LOG_FPW-1{1'b0}},rf_cnt_poisoned_comb};
    rf_cnt_rsp      <= rf_cnt_rsp + {{HMC_RF_RWIDTH-LOG_FPW-1{1'b0}},rf_cnt_rsp_comb};
end
end

//==================================================================================
//---------------------------------Shift response packets into the output fifo, return a token for each processed FLIT
//==================================================================================
always @(*)  begin
    tokens_out_of_fifo_sum_comb          = {LOG_FPW+1{1'b0}};

    if(input_buffer_shift_out)begin
        for(i_f=0; i_f<FPW; i_f=i_f+1) begin
            tokens_out_of_fifo_sum_comb  =   tokens_out_of_fifo_sum_comb + 
                                             (input_buffer_d_out[DWIDTH+i_f] && 
                                             !input_buffer_d_out[DWIDTH+i_f+(3*FPW)]);    //increment if there's a valid FLIT, but not an error response
        end
    end
end

`ifdef ASYNC_RES
always @(posedge clk or negedge res_n)  begin `else
always @(posedge clk)  begin `endif
if(!res_n) begin
    tx_hmc_tokens_to_return    <= {LOG_FPW+1{1'b0}};
end else begin
    tx_hmc_tokens_to_return    <= tokens_out_of_fifo_sum_comb;
end
end

`ifdef ASYNC_RES
always @(posedge clk or negedge res_n)  begin `else
always @(posedge clk)  begin `endif
if(!res_n) begin
    //----FIFO
    d_out_fifo_shift_in          <= 1'b0;
    d_out_fifo_ctrl              <= {4*FPW{1'b0}};
    d_out_fifo_data              <= {DWIDTH{1'b0}};

end else begin
    d_out_fifo_shift_in          <= 1'b0;
    d_out_fifo_ctrl              <= {4*FPW{1'b0}};


    if(input_buffer_shift_out)begin
        d_out_fifo_data             <= input_buffer_d_out[DWIDTH-1:0];
        d_out_fifo_shift_in         <= 1'b1;
        d_out_fifo_ctrl             <= input_buffer_d_out[DWIDTH+(4*FPW)-1:DWIDTH];
    end
end
end



//=====================================================================================================
//-----------------------------------------------------------------------------------------------------
//---------INSTANTIATIONS HERE-------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------
//=====================================================================================================

wire   res_n_lanes;
assign res_n_lanes = ((rf_link_status == LINK_DOWN) || !rf_hmc_init_cont_set) ? 1'b0 : 1'b1;

//Lane Init
genvar i;
generate
for(i=0;i<NUM_LANES;i=i+1)begin : lane_gen
    rx_lane_logic #(
        .DWIDTH(DWIDTH),
        .NUM_LANES(NUM_LANES),
        .CTRL_LANE_POLARITY(CTRL_LANE_POLARITY),
        .BITSLIP_SHIFT_RIGHT(BITSLIP_SHIFT_RIGHT)
    ) rx_lane_I (
        .clk(clk),
        .res_n(res_n_lanes),
        .bit_slip(init_bit_slip[i]),
        .descrambler_locked(init_descrambler_locked[i]),
        .descrambler_disable(rf_scrambler_disable),
        .lane_polarity(rf_lane_polarity[i]),
        .scrambled_data_in(phy_scrambled_data_in[i*WIDTH_PER_LANE+WIDTH_PER_LANE-1:i*WIDTH_PER_LANE]),
        .descrambled_data_out(descrambled_data_per_lane[i])
    );
end
endgenerate

//HMC CRC Logic
rx_crc_compare #(
    .DWIDTH(DWIDTH),
    .FPW(FPW),
    .LOG_FPW(LOG_FPW)
)
rx_crc_compare
(
    .clk(clk),
    .res_n(res_n),
    //input
    .d_in_data(data2crc),
    .d_in_hdr(data2crc_hdr),
    .d_in_tail(data2crc_tail),
    .d_in_valid(data2crc_valid),
    .d_in_lng(data2crc_lng),
    //output
    .d_out_data(crc_d_out_data),
    .d_out_hdr(crc_d_out_flit_is_hdr),
    .d_out_tail(crc_d_out_flit_is_tail),
    .d_out_valid(crc_d_out_flit_is_valid),
    .d_out_error(crc_d_out_flit_is_error),
    .d_out_poisoned(crc_d_out_flit_is_poisoned),
    .d_out_rtc(crc_d_out_flit_has_rtc),
    .d_out_flow(crc_d_out_flit_is_flow)
);

//Buffer Fifo - Depth = Max Tokens
openhmc_sync_fifo #(
        .DATASIZE(DWIDTH+(4*FPW)),   //+4*FPW for header/tail/valid/error response information -> AXI-4 TUSER signal
        .ADDRSIZE(LOG_MAX_RTC)
    ) input_buffer_I(
        .clk(clk),
        .res_n(res_n),
        .d_in(input_buffer_d_in),
        .shift_in(input_buffer_shift_in),
        .d_out(input_buffer_d_out),
        .shift_out(input_buffer_shift_out),
        .next_stage_full(1'b1), // Dont touch!
        .empty(input_buffer_empty)
    );

endmodule
`default_nettype wire
