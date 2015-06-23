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
 *  Module name: openhmc_8x_rf
 *
 *
 */

module openhmc_8x_rf (
    input wire clk,
    input wire res_n,
    input wire[6:3] address,
    output reg invalid_address,
    output reg access_complete,
    input wire read_en,
    output reg[63:0] read_data,
    input wire write_en,
    input wire[63:0] write_data,
    input wire status_general_link_up_next,
    input wire status_general_link_training_next,
    input wire status_general_sleep_mode_next,
    input wire status_general_lanes_reversed_next,
    input wire status_general_phy_ready_next,
    input wire[9:0] status_general_hmc_tokens_remaining_next,
    input wire[9:0] status_general_rx_tokens_remaining_next,
    input wire[7:0] status_general_lane_polarity_reversed_next,
    input wire[7:0] status_init_lane_descramblers_locked_next,
    input wire[7:0] status_init_descrambler_part_aligned_next,
    input wire[7:0] status_init_descrambler_aligned_next,
    input wire status_init_all_descramblers_aligned_next,
    input wire[1:0] status_init_tx_init_status_next,
    input wire status_init_hmc_init_TS1_next,
    output reg control_p_rst_n,
    output reg control_hmc_init_cont_set,
    output reg control_set_hmc_sleep,
    output reg control_scrambler_disable,
    output reg control_run_length_enable,
    output reg[2:0] control_first_cube_ID,
    output reg control_debug_dont_send_tret,
    output reg control_debug_halt_on_error_abort,
    output reg control_debug_halt_on_tx_retry,
    output reg[9:0] control_rx_token_count,
    output reg[4:0] control_irtry_received_threshold,
    output reg[4:0] control_irtry_to_send,
    output reg[5:0] control_bit_slip_time,
    input wire[63:0] sent_p_cnt_next,
    input wire[63:0] sent_np_cnt_next,
    input wire[63:0] sent_r_cnt_next,
    input wire[63:0] poisoned_packets_cnt_next,
    input wire[63:0] rcvd_rsp_cnt_next,
    input wire tx_link_retries_count_countup,
    input wire errors_on_rx_count_countup,
    input wire run_length_bit_flip_count_countup,
    input wire error_abort_not_cleared_count_countup
);
    reg status_general_link_up;
    reg status_general_link_training;
    reg status_general_sleep_mode;
    reg status_general_lanes_reversed;
    reg status_general_phy_ready;
    reg[9:0] status_general_hmc_tokens_remaining;
    reg[9:0] status_general_rx_tokens_remaining;
    reg[7:0] status_general_lane_polarity_reversed;
    reg[7:0] status_init_lane_descramblers_locked;
    reg[7:0] status_init_descrambler_part_aligned;
    reg[7:0] status_init_descrambler_aligned;
    reg status_init_all_descramblers_aligned;
    reg[1:0] status_init_tx_init_status;
    reg status_init_hmc_init_TS1;
    reg[63:0] sent_p_cnt;
    reg[63:0] sent_np_cnt;
    reg[63:0] sent_r_cnt;
    reg[63:0] poisoned_packets_cnt;
    reg[63:0] rcvd_rsp_cnt;
    reg rreinit;
    wire[31:0] tx_link_retries_count;
    wire[31:0] errors_on_rx_count;
    wire[31:0] run_length_bit_flip_count;
    wire[31:0] error_abort_not_cleared_count;
    
    counter48 #(
        .DATASIZE(32)
    ) tx_link_retries_count_I (
        .clk(clk),
        .res_n(res_n),
        .increment(tx_link_retries_count_countup),
     .load(32'b0),
        .load_enable(rreinit),
        .value(tx_link_retries_count)
    );
    
    
    counter48 #(
        .DATASIZE(32)
    ) errors_on_rx_count_I (
        .clk(clk),
        .res_n(res_n),
        .increment(errors_on_rx_count_countup),
     .load(32'b0),
        .load_enable(rreinit),
        .value(errors_on_rx_count)
    );
    
    
    counter48 #(
        .DATASIZE(32)
    ) run_length_bit_flip_count_I (
        .clk(clk),
        .res_n(res_n),
        .increment(run_length_bit_flip_count_countup),
     .load(32'b0),
        .load_enable(rreinit),
        .value(run_length_bit_flip_count)
    );
    
    
    counter48 #(
        .DATASIZE(32)
    ) error_abort_not_cleared_count_I (
        .clk(clk),
        .res_n(res_n),
        .increment(error_abort_not_cleared_count_countup),
     .load(32'b0),
        .load_enable(rreinit),
        .value(error_abort_not_cleared_count)
    );
    
    
    //Register: status_general
    `ifdef ASYNC_RES
    always @(posedge clk or negedge res_n) `else
    always @(posedge clk) `endif
    begin
        
        if(!res_n)
        begin
            status_general_link_up <= 1'h0;
            status_general_link_training <= 1'h0;
            status_general_sleep_mode <= 1'h0;
            status_general_lanes_reversed <= 1'h0;
            status_general_phy_ready <= 1'h0;
            status_general_hmc_tokens_remaining <= 10'h0;
            status_general_rx_tokens_remaining <= 10'h0;
            status_general_lane_polarity_reversed <= 0;
        end
        else
        begin
            status_general_link_up <= status_general_link_up_next;
            status_general_link_training <= status_general_link_training_next;
            status_general_sleep_mode <= status_general_sleep_mode_next;
            status_general_lanes_reversed <= status_general_lanes_reversed_next;
            status_general_phy_ready <= status_general_phy_ready_next;
            status_general_hmc_tokens_remaining <= status_general_hmc_tokens_remaining_next;
            status_general_rx_tokens_remaining <= status_general_rx_tokens_remaining_next;
            status_general_lane_polarity_reversed <= status_general_lane_polarity_reversed_next;
        end

    end
    
    //Register: status_init
    `ifdef ASYNC_RES
    always @(posedge clk or negedge res_n) `else
    always @(posedge clk) `endif
    begin
        
        if(!res_n)
        begin
            status_init_lane_descramblers_locked <= 0;
            status_init_descrambler_part_aligned <= 0;
            status_init_descrambler_aligned <= 0;
            status_init_all_descramblers_aligned <= 1'h0;
            status_init_tx_init_status <= 2'h0;
            status_init_hmc_init_TS1 <= 1'h0;
        end
        else
        begin
            status_init_lane_descramblers_locked <= status_init_lane_descramblers_locked_next;
            status_init_descrambler_part_aligned <= status_init_descrambler_part_aligned_next;
            status_init_descrambler_aligned <= status_init_descrambler_aligned_next;
            status_init_all_descramblers_aligned <= status_init_all_descramblers_aligned_next;
            status_init_tx_init_status <= status_init_tx_init_status_next;
            status_init_hmc_init_TS1 <= status_init_hmc_init_TS1_next;
        end

    end
    
    //Register: control
    `ifdef ASYNC_RES
    always @(posedge clk or negedge res_n) `else
    always @(posedge clk) `endif
    begin
        
        if(!res_n)
        begin
            control_p_rst_n <= 1'h0;
            control_hmc_init_cont_set <= 1'b0;
            control_set_hmc_sleep <= 1'h0;
            control_scrambler_disable <= 1'h0;
            control_run_length_enable <= 1'h0;
            control_first_cube_ID <= 3'h0;
            control_debug_dont_send_tret <= 1'h0;
            control_debug_halt_on_error_abort <= 1'h0;
            control_debug_halt_on_tx_retry <= 1'h0;
            control_rx_token_count <= 100;
            control_irtry_received_threshold <= 5'h10;
            control_irtry_to_send <= 5'h16;
            control_bit_slip_time <= 6'h28;
        end
        else
        begin
            
            if((address[6:3] == 2) && write_en)
            begin
                control_p_rst_n <= write_data[0:0];
            end
            
            if((address[6:3] == 2) && write_en)
            begin
                control_hmc_init_cont_set <= write_data[1:1];
            end
            
            if((address[6:3] == 2) && write_en)
            begin
                control_set_hmc_sleep <= write_data[2:2];
            end
            
            if((address[6:3] == 2) && write_en)
            begin
                control_scrambler_disable <= write_data[3:3];
            end
            
            if((address[6:3] == 2) && write_en)
            begin
                control_run_length_enable <= write_data[4:4];
            end
            
            if((address[6:3] == 2) && write_en)
            begin
                control_first_cube_ID <= write_data[7:5];
            end
            
            if((address[6:3] == 2) && write_en)
            begin
                control_debug_dont_send_tret <= write_data[8:8];
            end
            
            if((address[6:3] == 2) && write_en)
            begin
                control_debug_halt_on_error_abort <= write_data[9:9];
            end
            
            if((address[6:3] == 2) && write_en)
            begin
                control_debug_halt_on_tx_retry <= write_data[10:10];
            end
            
            if((address[6:3] == 2) && write_en)
            begin
                control_rx_token_count <= write_data[25:16];
            end
            
            if((address[6:3] == 2) && write_en)
            begin
                control_irtry_received_threshold <= write_data[36:32];
            end
            
            if((address[6:3] == 2) && write_en)
            begin
                control_irtry_to_send <= write_data[44:40];
            end
            
            if((address[6:3] == 2) && write_en)
            begin
                control_bit_slip_time <= write_data[53:48];
            end
        end

    end
    
    //Register: sent_p
    `ifdef ASYNC_RES
    always @(posedge clk or negedge res_n) `else
    always @(posedge clk) `endif
    begin
        
        if(!res_n)
        begin
            sent_p_cnt <= 64'h0;
        end
        else
        begin
            sent_p_cnt <= sent_p_cnt_next;
        end

    end
    
    //Register: sent_np
    `ifdef ASYNC_RES
    always @(posedge clk or negedge res_n) `else
    always @(posedge clk) `endif
    begin
        
        if(!res_n)
        begin
            sent_np_cnt <= 64'h0;
        end
        else
        begin
            sent_np_cnt <= sent_np_cnt_next;
        end

    end
    
    //Register: sent_r
    `ifdef ASYNC_RES
    always @(posedge clk or negedge res_n) `else
    always @(posedge clk) `endif
    begin
        
        if(!res_n)
        begin
            sent_r_cnt <= 64'h0;
        end
        else
        begin
            sent_r_cnt <= sent_r_cnt_next;
        end

    end
    
    //Register: poisoned_packets
    `ifdef ASYNC_RES
    always @(posedge clk or negedge res_n) `else
    always @(posedge clk) `endif
    begin
        
        if(!res_n)
        begin
            poisoned_packets_cnt <= 64'h0;
        end
        else
        begin
            poisoned_packets_cnt <= poisoned_packets_cnt_next;
        end

    end
    
    //Register: rcvd_rsp
    `ifdef ASYNC_RES
    always @(posedge clk or negedge res_n) `else
    always @(posedge clk) `endif
    begin
        
        if(!res_n)
        begin
            rcvd_rsp_cnt <= 64'h0;
        end
        else
        begin
            rcvd_rsp_cnt <= rcvd_rsp_cnt_next;
        end

    end
    
    //Register: counter_reset
    `ifdef ASYNC_RES
    always @(posedge clk or negedge res_n) `else
    always @(posedge clk) `endif
    begin
        
        if(!res_n)
        begin
            rreinit <= 1'b0;
        end
        else
        begin
            
            if((address[6:3] == 8) && write_en)
            begin
                rreinit <= 1'b1;
            end
            else
            begin
                rreinit <= 1'b0;
            end
        end

    end
    
    //Address Decoder Software Read:
    `ifdef ASYNC_RES
    always @(posedge clk or negedge res_n) `else
    always @(posedge clk) `endif
    begin
        
        if(!res_n)
        begin
            invalid_address <= 1'b0;
            access_complete <= 1'b0;
            read_data <= 64'b0;
        end
        else
        begin
            
            casex(address[6:3])
                4'h0:
                begin
                    read_data[0:0] <= status_general_link_up;
                    read_data[1:1] <= status_general_link_training;
                    read_data[2:2] <= status_general_sleep_mode;
                    read_data[3:3] <= status_general_lanes_reversed;
                    read_data[8:8] <= status_general_phy_ready;
                    read_data[25:16] <= status_general_hmc_tokens_remaining;
                    read_data[41:32] <= status_general_rx_tokens_remaining;
                    read_data[55:48] <= status_general_lane_polarity_reversed;
                    read_data[63:56] <= 8'b0;
                    invalid_address <= write_en;
                    access_complete <= read_en || write_en;
                end
                4'h1:
                begin
                    read_data[7:0] <= status_init_lane_descramblers_locked;
                    read_data[23:16] <= status_init_descrambler_part_aligned;
                    read_data[39:32] <= status_init_descrambler_aligned;
                    read_data[48:48] <= status_init_all_descramblers_aligned;
                    read_data[50:49] <= status_init_tx_init_status;
                    read_data[51:51] <= status_init_hmc_init_TS1;
                    read_data[63:52] <= 12'b0;
                    invalid_address <= write_en;
                    access_complete <= read_en || write_en;
                end
                4'h2:
                begin
                    read_data[0:0] <= control_p_rst_n;
                    read_data[1:1] <= control_hmc_init_cont_set;
                    read_data[2:2] <= control_set_hmc_sleep;
                    read_data[3:3] <= control_scrambler_disable;
                    read_data[4:4] <= control_run_length_enable;
                    read_data[7:5] <= control_first_cube_ID;
                    read_data[8:8] <= control_debug_dont_send_tret;
                    read_data[9:9] <= control_debug_halt_on_error_abort;
                    read_data[10:10] <= control_debug_halt_on_tx_retry;
                    read_data[25:16] <= control_rx_token_count;
                    read_data[36:32] <= control_irtry_received_threshold;
                    read_data[44:40] <= control_irtry_to_send;
                    read_data[53:48] <= control_bit_slip_time;
                    read_data[63:54] <= 10'b0;
                    invalid_address <= 1'b0;
                    access_complete <= read_en || write_en;
                end
                4'h3:
                begin
                    read_data[63:0] <= sent_p_cnt;
                    invalid_address <= write_en;
                    access_complete <= read_en || write_en;
                end
                4'h4:
                begin
                    read_data[63:0] <= sent_np_cnt;
                    invalid_address <= write_en;
                    access_complete <= read_en || write_en;
                end
                4'h5:
                begin
                    read_data[63:0] <= sent_r_cnt;
                    invalid_address <= write_en;
                    access_complete <= read_en || write_en;
                end
                4'h6:
                begin
                    read_data[63:0] <= poisoned_packets_cnt;
                    invalid_address <= write_en;
                    access_complete <= read_en || write_en;
                end
                4'h7:
                begin
                    read_data[63:0] <= rcvd_rsp_cnt;
                    invalid_address <= write_en;
                    access_complete <= read_en || write_en;
                end
                4'h8:
                begin
                    read_data[63:0] <= 64'b0;
                    invalid_address <= read_en;
                    access_complete <= read_en || write_en;
                end
                4'h9:
                begin
                    read_data[31:0] <= tx_link_retries_count;
                    read_data[63:32] <= 32'b0;
                    invalid_address <= write_en;
                    access_complete <= read_en || write_en;
                end
                4'ha:
                begin
                    read_data[31:0] <= errors_on_rx_count;
                    read_data[63:32] <= 32'b0;
                    invalid_address <= write_en;
                    access_complete <= read_en || write_en;
                end
                4'hb:
                begin
                    read_data[31:0] <= run_length_bit_flip_count;
                    read_data[63:32] <= 32'b0;
                    invalid_address <= write_en;
                    access_complete <= read_en || write_en;
                end
                4'hc:
                begin
                    read_data[31:0] <= error_abort_not_cleared_count;
                    read_data[63:32] <= 32'b0;
                    invalid_address <= write_en;
                    access_complete <= read_en || write_en;
                end
                default:
                begin
                    invalid_address <= read_en || write_en;
                    access_complete <= read_en || write_en;
                end

            endcase
        end

    end

endmodule