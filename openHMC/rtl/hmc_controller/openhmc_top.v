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
 *  Module name: hmc_controller_top
 *
 */

`default_nettype none

module openhmc_top #(
    //Define width of the datapath
    parameter LOG_FPW               = 2,        //Legal Values: 1,2,3
    parameter FPW                   = 4,        //Legal Values: 2,4,6,8
    parameter DWIDTH                = FPW*128,  //Leave untouched
    //Define HMC interface width
    parameter LOG_NUM_LANES         = 3,                //Set 3 for half-width, 4 for full-width
    parameter NUM_LANES             = 2**LOG_NUM_LANES, //Leave untouched
    parameter NUM_DATA_BYTES        = FPW*16,           //Leave untouched
    //Define width of the register file
    parameter HMC_RF_WWIDTH         = 64,
    parameter HMC_RF_RWIDTH         = 64,
    parameter HMC_RF_AWIDTH         = 4,
    //Configure the Functionality
    parameter LOG_MAX_RTC           = 8,    //Set the depth of the RX input buffer. Must be >= LOG(rf_rx_buffer_rtc) in the RF
    parameter HMC_RX_AC_COUPLED     = 1,    //Set to 0 to remove the run length limiter, saves logic and 1 cycle delay
    parameter CTRL_LANE_POLARITY    = 1,    //Set to 0 if lane polarity is not applicable or performed by the transceivers, saves logic and 1 cycle delay
    parameter CTRL_LANE_REVERSAL    = 1,    //Set to 0 if lane reversal is not applicable or performed by the transceivers, saves logic
    //Set the direction of bitslip. Set to 1 if bitslip performs a shift right, otherwise set to 0 (see the corresponding transceiver user guide)
    parameter BITSLIP_SHIFT_RIGHT   = 1,    
    //Debug Params
    parameter DBG_RX_TOKEN_MON      = 1     //Remove the RX Link token monitor, saves logic
) (
    //----------------------------------
    //----SYSTEM INTERFACES
    //----------------------------------
    input  wire                         clk_user,
    input  wire                         clk_hmc,
    input  wire                         res_n_user,
    input  wire                         res_n_hmc,

    //----------------------------------
    //----Connect AXI Ports
    //----------------------------------
    //From AXI to HMC Ctrl TX
    input  wire                         s_axis_tx_TVALID,
    output wire                         s_axis_tx_TREADY,
    input  wire [DWIDTH-1:0]            s_axis_tx_TDATA,
    input  wire [NUM_DATA_BYTES-1:0]    s_axis_tx_TUSER,
    //From HMC Ctrl RX to AXI
    output wire                         m_axis_rx_TVALID,
    input  wire                         m_axis_rx_TREADY,
    output wire [DWIDTH-1:0]            m_axis_rx_TDATA,
    output wire [NUM_DATA_BYTES-1:0]    m_axis_rx_TUSER,

    //----------------------------------
    //----Connect Transceiver
    //----------------------------------
    output wire  [DWIDTH-1:0]           phy_data_tx_link2phy,
    input  wire  [DWIDTH-1:0]           phy_data_rx_phy2link,
    output wire  [NUM_LANES-1:0]        phy_bit_slip,
    output wire  [NUM_LANES-1:0]        phy_lane_polarity,  //All 0 if CTRL_LANE_POLARITY=1
    input  wire                         phy_ready,

    //----------------------------------
    //----Connect HMC
    //----------------------------------
    output wire                         P_RST_N,
    output wire                         hmc_LxRXPS,
    input  wire                         hmc_LxTXPS,
    input  wire                         FERR_N, //Not connected

    //----------------------------------
    //----Connect RF
    //----------------------------------
    input  wire  [HMC_RF_AWIDTH-1:0]    rf_address,
    output wire  [HMC_RF_RWIDTH-1:0]    rf_read_data,
    output wire                         rf_invalid_address,
    output wire                         rf_access_complete,
    input  wire                         rf_read_en,
    input  wire                         rf_write_en,
    input  wire  [HMC_RF_WWIDTH-1:0]    rf_write_data

    );

//=====================================================================================================
//-----------------------------------------------------------------------------------------------------
//---------WIRING AND SIGNAL STUFF---------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------
//=====================================================================================================

// ----Assign AXI interface wires
wire [4*FPW-1:0]            m_axis_rx_TUSER_temp;
assign                      m_axis_rx_TUSER = {{NUM_DATA_BYTES-(4*FPW){1'b0}}, m_axis_rx_TUSER_temp};

wire                        s_axis_tx_TREADY_n;
assign s_axis_tx_TREADY =   ~s_axis_tx_TREADY_n;

wire                        m_axis_rx_TVALID_n;
assign m_axis_rx_TVALID =   ~m_axis_rx_TVALID_n;

// ----TX FIFO Wires
wire    [DWIDTH-1:0]        tx_d_in_data;
wire                        tx_shift_out;
wire                        tx_empty;
wire                        tx_a_empty;
wire    [3*FPW-1:0]         tx_d_in_ctrl;

// ----RX FIFO Wires
wire    [DWIDTH-1:0]        rx_d_in_data;
wire                        rx_shift_in;
wire                        rx_full;
wire                        rx_a_full;
wire    [4*FPW-1:0]         rx_d_in_ctrl;

// ----RX LINK TO TX LINK
wire                        rx2tx_link_retry;
wire                        rx2tx_error_abort_mode;
wire                        rx2tx_error_abort_mode_cleared;
wire    [7:0]               rx2tx_hmc_frp;
wire    [7:0]               rx2tx_rrp;
wire    [7:0]               rx2tx_returned_tokens;
wire    [LOG_FPW:0]         rx2tx_hmc_tokens_to_return;
wire    [LOG_FPW:0]         rx2tx_hmc_poisoned_tokens_to_return;

// ----Register File
//Counter
wire                        rf_cnt_retry;
wire                        rf_run_length_bit_flip;
wire                        rf_error_abort_not_cleared;
wire  [HMC_RF_RWIDTH-1:0]   rf_cnt_poisoned;
wire  [HMC_RF_RWIDTH-1:0]   rf_cnt_p;
wire  [HMC_RF_RWIDTH-1:0]   rf_cnt_np;
wire  [HMC_RF_RWIDTH-1:0]   rf_cnt_r;
wire  [HMC_RF_RWIDTH-1:0]   rf_cnt_rsp_rcvd;
//Status
wire [1:0]                  rf_link_status;
wire [2:0]                  rf_hmc_init_status;
wire [1:0]                  rf_tx_init_status;
wire [9:0]                  rf_hmc_tokens_av;
wire [9:0]                  rf_rx_tokens_av;
wire                        rf_hmc_sleep;
//Init Status
wire                        rf_all_descramblers_aligned;
wire [NUM_LANES-1:0]        rf_descrambler_aligned;
wire [NUM_LANES-1:0]        rf_descrambler_part_aligned;
//Control
wire [5:0]                  rf_bit_slip_time;
wire                        rf_hmc_init_cont_set;
wire                        rf_set_hmc_sleep;
wire                        rf_scrambler_disable;
wire [NUM_LANES-1:0]        rf_lane_polarity;
wire [NUM_LANES-1:0]        rf_descramblers_locked;
wire [9:0]                  rf_rx_buffer_rtc;
wire                        rf_lane_reversal_detected;
wire [4:0]                  rf_irtry_received_threshold;
wire [4:0]                  rf_irtry_to_send;
wire                        rf_run_length_enable;
wire [2:0]                  rf_first_cube_ID;
//Debug
wire                        rf_dbg_dont_send_tret;
wire                        rf_dbg_halt_on_error_abort;
wire                        rf_dbg_halt_on_tx_retry;

// ----Assign PHY wires
assign phy_lane_polarity = (CTRL_LANE_POLARITY==1) ? {NUM_LANES{1'b0}} : rf_lane_polarity;

//=====================================================================================================
//-----------------------------------------------------------------------------------------------------
//---------INSTANTIATIONS HERE-------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------
//=====================================================================================================
//----------------------------------------------------------------------
//-----TX-----TX-----TX-----TX-----TX-----TX-----TX-----TX-----TX-----TX
//----------------------------------------------------------------------

openhmc_async_fifo #(
    .DWIDTH(DWIDTH+(FPW*3)),
    .ENTRIES(16)
) fifo_tx_data (
    //System
    .si_clk(clk_user),
    .so_clk(clk_hmc),
    .si_res_n(res_n_user),
    .so_res_n(res_n_hmc),

    //From AXI-4 TX IF
    .d_in({s_axis_tx_TUSER[(FPW*3)-1:0],s_axis_tx_TDATA}),
    .shift_in(s_axis_tx_TVALID && s_axis_tx_TREADY),
    .full(s_axis_tx_TREADY_n),
    .almost_full(),

    //To TX Link Logic
    .d_out({tx_d_in_ctrl,tx_d_in_data}),
    .shift_out(tx_shift_out),
    .empty(tx_empty),
    .almost_empty(tx_a_empty)
);

tx_link #(
    .LOG_FPW(LOG_FPW),
    .FPW(FPW),
    .NUM_LANES(NUM_LANES),
    .HMC_PTR_SIZE(8),
    .HMC_RF_RWIDTH(HMC_RF_RWIDTH),
    .HMC_RX_AC_COUPLED(HMC_RX_AC_COUPLED),
    //Debug
    .DBG_RX_TOKEN_MON(DBG_RX_TOKEN_MON)
) tx_link_I(

    //----------------------------------
    //----SYSTEM INTERFACE
    //----------------------------------
    .clk(clk_hmc),
    .res_n(res_n_hmc),

    //----------------------------------
    //----TO HMC PHY
    //----------------------------------
    .phy_scrambled_data_out(phy_data_tx_link2phy),

    //----------------------------------
    //----HMC IF
    //----------------------------------
    .hmc_LxRXPS(hmc_LxRXPS),
    .hmc_LxTXPS(hmc_LxTXPS),

    //----------------------------------
    //----FROM HMC_TX_HTAX_LOGIC
    //----------------------------------
    .d_in_data(tx_d_in_data),
    .d_in_flit_is_valid(tx_d_in_ctrl[FPW-1:0]),
    .d_in_flit_is_hdr(tx_d_in_ctrl[(2*FPW)-1:1*FPW]),
    .d_in_flit_is_tail(tx_d_in_ctrl[(3*FPW)-1:(2*FPW)]),
    .d_in_empty(tx_empty),
    .d_in_a_empty(tx_a_empty),
    .d_in_shift_out(tx_shift_out),

    //----------------------------------
    //----RX Block
    //----------------------------------
    .rx_force_tx_retry(rx2tx_link_retry),
    .rx_error_abort_mode(rx2tx_error_abort_mode),
    .rx_error_abort_mode_cleared(rx2tx_error_abort_mode_cleared),
    .rx_hmc_frp(rx2tx_hmc_frp),
    .rx_rrp(rx2tx_rrp),
    .rx_returned_tokens(rx2tx_returned_tokens),
    .rx_hmc_tokens_to_return(rx2tx_hmc_tokens_to_return),
    .rx_hmc_poisoned_tokens_to_return(rx2tx_hmc_poisoned_tokens_to_return),

    //----------------------------------
    //----RF
    //----------------------------------
    //Monitoring    1-cycle set to increment
    .rf_cnt_retry(rf_cnt_retry),
    .rf_sent_p(rf_cnt_p),
    .rf_sent_np(rf_cnt_np),
    .rf_sent_r(rf_cnt_r),
    .rf_run_length_bit_flip(rf_run_length_bit_flip),
    .rf_error_abort_not_cleared(rf_error_abort_not_cleared),
    //Status
    .rf_hmc_is_in_sleep(rf_hmc_sleep),
    .rf_hmc_received_init_null(rf_hmc_init_status[0]),
    .rf_link_is_up(rf_link_status[1]),
    .rf_descramblers_aligned(rf_all_descramblers_aligned),
    .rf_tx_init_status(rf_tx_init_status),
    .rf_hmc_tokens_av(rf_hmc_tokens_av),
    .rf_rx_tokens_av(rf_rx_tokens_av),
    //Control
    .rf_hmc_sleep_requested(rf_set_hmc_sleep),
    .rf_hmc_init_cont_set(rf_hmc_init_cont_set),
    .rf_scrambler_disable(rf_scrambler_disable),
    .rf_rx_buffer_rtc(rf_rx_buffer_rtc),
    .rf_first_cube_ID(rf_first_cube_ID),
    .rf_irtry_to_send(rf_irtry_to_send),
    .rf_run_length_enable(rf_run_length_enable),
    //Debug
    .rf_dbg_dont_send_tret(rf_dbg_dont_send_tret),
    .rf_dbg_halt_on_error_abort(rf_dbg_halt_on_error_abort),
    .rf_dbg_halt_on_tx_retry(rf_dbg_halt_on_tx_retry)

);

//----------------------------------------------------------------------
//-----RX-----RX-----RX-----RX-----RX-----RX-----RX-----RX-----RX-----RX
//----------------------------------------------------------------------
rx_link #(
    .LOG_FPW(LOG_FPW),
    .FPW(FPW),
    .LOG_NUM_LANES(LOG_NUM_LANES),
    .HMC_RF_RWIDTH(HMC_RF_RWIDTH),
    //Configure the functionality
    .LOG_MAX_RTC(LOG_MAX_RTC),
    .CTRL_LANE_POLARITY(CTRL_LANE_POLARITY),
    .CTRL_LANE_REVERSAL(CTRL_LANE_REVERSAL),
    .BITSLIP_SHIFT_RIGHT(BITSLIP_SHIFT_RIGHT)
) rx_link_I (

    //----------------------------------
    //----SYSTEM INTERFACE
    //----------------------------------
    .clk(clk_hmc),
    .res_n(res_n_hmc),

    //----------------------------------
    //----TO HMC PHY
    //----------------------------------
    .phy_scrambled_data_in(phy_data_rx_phy2link),
    .init_bit_slip(phy_bit_slip),

    //----------------------------------
    //----FROM TO RX HTAX FIFO
    //----------------------------------
    .d_out_fifo_data(rx_d_in_data),
    .d_out_fifo_full(rx_full),
    .d_out_fifo_a_full(rx_a_full),
    .d_out_fifo_shift_in(rx_shift_in),
    .d_out_fifo_ctrl(rx_d_in_ctrl),

    //----------------------------------
    //----TO TX Block
    //----------------------------------
    .tx_link_retry(rx2tx_link_retry),
    .tx_error_abort_mode(rx2tx_error_abort_mode),
    .tx_error_abort_mode_cleared(rx2tx_error_abort_mode_cleared),
    .tx_hmc_frp(rx2tx_hmc_frp),
    .tx_rrp(rx2tx_rrp),
    .tx_returned_tokens(rx2tx_returned_tokens),
    .tx_hmc_tokens_to_return(rx2tx_hmc_tokens_to_return),
    .tx_hmc_poisoned_tokens_to_return(rx2tx_hmc_poisoned_tokens_to_return),

    //----------------------------------
    //----RF
    //----------------------------------
    //Monitoring    1-cycle set to increment
    .rf_cnt_poisoned(rf_cnt_poisoned),
    .rf_cnt_rsp(rf_cnt_rsp_rcvd),
    //Status
    .rf_link_status(rf_link_status),
    .rf_hmc_init_status(rf_hmc_init_status),
    .rf_hmc_sleep(rf_hmc_sleep),
    //Init Status
    .rf_all_descramblers_aligned(rf_all_descramblers_aligned),
    .rf_descrambler_aligned(rf_descrambler_aligned),
    .rf_descrambler_part_aligned(rf_descrambler_part_aligned),
    .rf_descramblers_locked(rf_descramblers_locked),
    .rf_tx_sends_ts1(rf_tx_init_status[1] && !rf_tx_init_status[0]),
    //Control
    .rf_bit_slip_time(rf_bit_slip_time),
    .rf_hmc_init_cont_set(rf_hmc_init_cont_set),
    .rf_lane_polarity(rf_lane_polarity),
    .rf_scrambler_disable(rf_scrambler_disable),
    .rf_lane_reversal_detected(rf_lane_reversal_detected),
    .rf_irtry_received_threshold(rf_irtry_received_threshold)
);

openhmc_async_fifo #(
    .DWIDTH(DWIDTH+(FPW*4)),
    .ENTRIES(16)
) fifo_rx_data(
    //System
    .si_clk(clk_hmc),
    .so_clk(clk_user),
    .si_res_n(res_n_hmc),
    .so_res_n(res_n_user),

    //To RX LINK Logic
    .d_in({rx_d_in_ctrl,rx_d_in_data}),
    .shift_in(rx_shift_in),
    .full(rx_full),
    .almost_full(rx_a_full),

    //AXI-4 RX IF
    .d_out({m_axis_rx_TUSER_temp,m_axis_rx_TDATA}),
    .shift_out(m_axis_rx_TVALID && m_axis_rx_TREADY),
    .empty(m_axis_rx_TVALID_n),
    .almost_empty()

);

//----------------------------------------------------------------------
//---Register File---Register File---Register File---Register File---Reg
//----------------------------------------------------------------------
//Instantiate register file depending on the number of lanes
generate 
    if(NUM_LANES==8) begin : register_file_8x
        openhmc_8x_rf openhmc_rf_I (
            //system IF
            .res_n(res_n_hmc),
            .clk(clk_hmc),

            //rf access
            .address(rf_address),
            .read_data(rf_read_data),
            .invalid_address(rf_invalid_address),
            .access_complete(rf_access_complete),
            .read_en(rf_read_en),
            .write_en(rf_write_en),
            .write_data(rf_write_data),

            //status registers
            .status_general_link_up_next(rf_link_status[1]),
            .status_general_link_training_next(rf_link_status[0]),
            .status_general_sleep_mode_next(rf_hmc_sleep),
            .status_general_phy_ready_next(phy_ready),
            .status_general_lanes_reversed_next(rf_lane_reversal_detected),
            .status_general_hmc_tokens_remaining_next(rf_hmc_tokens_av),
            .status_general_rx_tokens_remaining_next(rf_rx_tokens_av),
            .status_general_lane_polarity_reversed_next(rf_lane_polarity),

            //init status
            .status_init_lane_descramblers_locked_next(rf_descramblers_locked),
            .status_init_descrambler_part_aligned_next(rf_descrambler_part_aligned),
            .status_init_descrambler_aligned_next(rf_descrambler_aligned),
            .status_init_all_descramblers_aligned_next(rf_all_descramblers_aligned),
            .status_init_tx_init_status_next(rf_tx_init_status),
            .status_init_hmc_init_TS1_next(rf_hmc_init_status[0]),

            //counters
            .sent_np_cnt_next(rf_cnt_np),
            .sent_p_cnt_next(rf_cnt_p),
            .sent_r_cnt_next(rf_cnt_r),
            .poisoned_packets_cnt_next(rf_cnt_poisoned),
            .rcvd_rsp_cnt_next(rf_cnt_rsp_rcvd),

            //Single bit counter
            .tx_link_retries_count_countup(rf_cnt_retry),
            .errors_on_rx_count_countup(rx2tx_error_abort_mode_cleared),
            .run_length_bit_flip_count_countup(rf_run_length_bit_flip),
            .error_abort_not_cleared_count_countup(rf_error_abort_not_cleared),

            //control
            .control_p_rst_n(P_RST_N),
            .control_hmc_init_cont_set(rf_hmc_init_cont_set),
            .control_set_hmc_sleep(rf_set_hmc_sleep),
            .control_scrambler_disable(rf_scrambler_disable),
            .control_run_length_enable(rf_run_length_enable),
            .control_first_cube_ID(rf_first_cube_ID),
            .control_debug_dont_send_tret(rf_dbg_dont_send_tret),
            .control_debug_halt_on_error_abort(rf_dbg_halt_on_error_abort),
            .control_debug_halt_on_tx_retry(rf_dbg_halt_on_tx_retry),            
            .control_rx_token_count(rf_rx_buffer_rtc),
            .control_irtry_received_threshold(rf_irtry_received_threshold),
            .control_irtry_to_send(rf_irtry_to_send),
            .control_bit_slip_time(rf_bit_slip_time)

        );
    end else begin  : register_file_16x
        openhmc_16x_rf openhmc_rf_I (
            //system IF
            .res_n(res_n_hmc),
            .clk(clk_hmc),

            //rf access
            .address(rf_address),
            .read_data(rf_read_data),
            .invalid_address(rf_invalid_address),
            .access_complete(rf_access_complete),
            .read_en(rf_read_en),
            .write_en(rf_write_en),
            .write_data(rf_write_data),

            //status registers
            .status_general_link_up_next(rf_link_status[1]),
            .status_general_link_training_next(rf_link_status[0]),
            .status_general_sleep_mode_next(rf_hmc_sleep),
            .status_general_phy_ready_next(phy_ready),
            .status_general_lanes_reversed_next(rf_lane_reversal_detected),
            .status_general_hmc_tokens_remaining_next(rf_hmc_tokens_av),
            .status_general_rx_tokens_remaining_next(rf_rx_tokens_av),
            .status_general_lane_polarity_reversed_next(rf_lane_polarity),

            //init status
            .status_init_lane_descramblers_locked_next(rf_descramblers_locked),
            .status_init_descrambler_part_aligned_next(rf_descrambler_part_aligned),
            .status_init_descrambler_aligned_next(rf_descrambler_aligned),
            .status_init_all_descramblers_aligned_next(rf_all_descramblers_aligned),
            .status_init_tx_init_status_next(rf_tx_init_status),
            .status_init_hmc_init_TS1_next(rf_hmc_init_status[0]),

            //counters
            .sent_np_cnt_next(rf_cnt_np),
            .sent_p_cnt_next(rf_cnt_p),
            .sent_r_cnt_next(rf_cnt_r),
            .poisoned_packets_cnt_next(rf_cnt_poisoned),
            .rcvd_rsp_cnt_next(rf_cnt_rsp_rcvd),

            //Single bit counter
            .tx_link_retries_count_countup(rf_cnt_retry),
            .errors_on_rx_count_countup(rx2tx_error_abort_mode_cleared),
            .run_length_bit_flip_count_countup(rf_run_length_bit_flip),
            .error_abort_not_cleared_count_countup(rf_error_abort_not_cleared),

            //control
            .control_p_rst_n(P_RST_N),
            .control_hmc_init_cont_set(rf_hmc_init_cont_set),
            .control_set_hmc_sleep(rf_set_hmc_sleep),
            .control_scrambler_disable(rf_scrambler_disable),
            .control_run_length_enable(rf_run_length_enable),
            .control_first_cube_ID(rf_first_cube_ID),
            .control_debug_dont_send_tret(rf_dbg_dont_send_tret),
            .control_debug_halt_on_error_abort(rf_dbg_halt_on_error_abort),
            .control_debug_halt_on_tx_retry(rf_dbg_halt_on_tx_retry),            
            .control_rx_token_count(rf_rx_buffer_rtc),
            .control_irtry_received_threshold(rf_irtry_received_threshold),
            .control_irtry_to_send(rf_irtry_to_send),
            .control_bit_slip_time(rf_bit_slip_time)
        );       
    end 
endgenerate

endmodule

`default_nettype wire
