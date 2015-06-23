/*
 * This file is subject to the terms and conditions of the BSD License. See
 * the file "LICENSE" in the main directory of this archive for more details.
 *
 * Copyright (C) 2014 Aleksander Osman
 */

module dat(
    input               clk,
    input               rst_n,
    
    //
    input               sd_clk_is_one,
    
    //
    input               wr_async_data_ready,
    input       [31:0]  wr_async_data,
    output reg          wr_data_done,
    output reg          wr_data_last_in_sector,
    output reg          wr_error,
    output reg          wr_finished_sector,
    
    //
    input               rd_async_start,
    input               rd_async_abort,
    output reg          rd_data_done,
    output reg          rd_data_last_in_sector,
    output reg  [31:0]  rd_data,
    output reg          rd_error,
    
    //
    output              current_dat0,
    
    //
    inout       [3:0]   sd_dat   
);

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

reg sd_dat_enable;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       sd_dat_enable <= 1'b0;
    else if(sd_clk_is_one)  sd_dat_enable <= wr_start || wr_cnt > 11'd0;
end

reg [3:0] sd_dat_output;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       sd_dat_output <= 4'hF;
    else if(sd_clk_is_one)  sd_dat_output <= (wr_start)? 4'h0 : (wr_cnt <= 11'd17 && wr_cnt >= 11'd2)? { wr_crc_3[0], wr_crc_2[0], wr_crc_1[0], wr_crc_0[0] } : { wr_val_3[7], wr_val_2[7], wr_val_1[7], wr_val_0[7] };
end

assign sd_dat = (sd_dat_enable)? sd_dat_output : 4'bZ;

reg [3:0] sd_dat_input;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           sd_dat_input <= 4'b1111;
    else if(~(sd_clk_is_one))   sd_dat_input <= sd_dat;
end

assign current_dat0 = sd_dat_input[0];

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

/*
input               wr_async_data_ready,
input       [31:0]  wr_async_data,
output reg          wr_data_done,
output reg          wr_error,
output reg          wr_finished,
*/

reg [1:0] wr_start_delay_cnt;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                                                   wr_start_delay_cnt <= 2'd2;
    else if(sd_clk_is_one && wr_async_data_ready && wr_cnt == 11'd0 && ~(wr_in_progress) && wr_start_delay_cnt > 2'd0)  wr_start_delay_cnt <= wr_start_delay_cnt - 2'd1;
    else if(wr_cnt > 11'd0)                                                                                             wr_start_delay_cnt <= 2'd2;
end

wire wr_start = sd_clk_is_one && wr_async_data_ready && wr_cnt == 11'd0 && ~(wr_in_progress) && wr_start_delay_cnt == 2'd0;
wire wr_load  = wr_start || (sd_clk_is_one && wr_async_data_ready && wr_cnt >= 11'd26 && wr_cnt[2:0] == 3'b010) || (wr_missed && wr_async_data_ready);

reg wr_missed;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                               wr_missed <= 1'b0;
    else if(sd_clk_is_one && ~(wr_async_data_ready) && wr_cnt >= 11'd26 && wr_cnt[2:0] == 3'b010)   wr_missed <= 1'b1;
    else if(wr_async_data_ready)                                                                    wr_missed <= 1'b0;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   wr_data_done <= 1'b0;
    else                wr_data_done <= wr_load;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   wr_data_last_in_sector <= 1'b0;
    else                wr_data_last_in_sector <= wr_load && (wr_cnt == 11'd26 || wr_cnt == 11'd25);
end

reg [10:0] wr_cnt;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                           wr_cnt <= 11'd0;
    else if(wr_start)                           wr_cnt <= 11'd1041;
    else if(sd_clk_is_one && wr_cnt > 11'd0)    wr_cnt <= wr_cnt - 11'd1;
end

wire wr_resp_start = sd_clk_is_one && wr_cnt == 11'd1;

reg wr_resp_awaiting;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                       wr_resp_awaiting <= 1'b0;
    else if(wr_resp_start)                                                  wr_resp_awaiting <= 1'b1;
    else if(sd_clk_is_one && wr_resp_awaiting && sd_dat_input[0] == 1'b0)   wr_resp_awaiting <= 1'b0;
end

reg [2:0] wr_resp_cnt;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                       wr_resp_cnt <= 3'd0;
    else if(sd_clk_is_one && wr_resp_awaiting && sd_dat_input[0] == 1'b0)   wr_resp_cnt <= 3'd4;
    else if(sd_clk_is_one && wr_resp_cnt > 3'd0)                            wr_resp_cnt <= wr_resp_cnt - 3'd1;
end

wire wr_in_progress_end = wr_in_progress && ((sd_clk_is_one && wr_error_cnt == 27'h7FFFFFF) || (sd_clk_is_one && wr_cnt == 11'd0 && ~(wr_resp_awaiting) && wr_resp_cnt == 3'd0 && sd_dat_input[0] == 1'b1));

reg wr_in_progress;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               wr_in_progress <= 1'b0;
    else if(wr_start)               wr_in_progress <= 1'b1;
    else if(wr_in_progress_end)     wr_in_progress <= 1'b0;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   wr_finished_sector <= 1'b0;
    else                wr_finished_sector <= wr_in_progress_end;
end

//------------------------------------------------------------------------------

wire wr_resp_now_in_error = sd_clk_is_one && (
    (wr_resp_cnt == 3'd4 && sd_dat_input[0] == 1'b1) || //crc status invalid
    (wr_resp_cnt == 3'd3 && sd_dat_input[0] == 1'b0) || //crc status invalid
    (wr_resp_cnt == 3'd2 && sd_dat_input[0] == 1'b1) || //crc status invalid
    (wr_resp_cnt == 3'd1 && sd_dat_input[0] == 1'b0)    //end bit is '0'
);

reg [26:0] wr_error_cnt;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               wr_error_cnt <= 27'd0;
    else if(~(wr_in_progress))                      wr_error_cnt <= 27'd0;
    else if(wr_resp_start)                          wr_error_cnt <= 27'd1;
    else if(sd_clk_is_one && wr_error_cnt > 27'd0)  wr_error_cnt <= wr_error_cnt + 27'd1;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                       wr_error <= 1'b0;
    else if(wr_start)                                       wr_error <= 1'b0;
    else if(wr_resp_now_in_error)                           wr_error <= 1'b1;
    else if(sd_clk_is_one && wr_error_cnt == 27'h7FFFFFF)   wr_error <= 1'b1;
end

//------------------------------------------------------------------------------

reg [7:0] wr_val_0;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       wr_val_0 <= 8'd0;
    else if(wr_load)        wr_val_0 <= { wr_async_data[4], wr_async_data[0], wr_async_data[12], wr_async_data[8], wr_async_data[20], wr_async_data[16], wr_async_data[28], wr_async_data[24] };
    else if(sd_clk_is_one)  wr_val_0 <= { wr_val_0[6:0], 1'b1 }; //fill with 1 important
end

reg [7:0] wr_val_1;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       wr_val_1 <= 8'd0;
    else if(wr_load)        wr_val_1 <= { wr_async_data[5], wr_async_data[1], wr_async_data[13], wr_async_data[9], wr_async_data[21], wr_async_data[17], wr_async_data[29], wr_async_data[25] };
    else if(sd_clk_is_one)  wr_val_1 <= { wr_val_1[6:0], 1'b1 }; //fill with 1 important
end

reg [7:0] wr_val_2;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       wr_val_2 <= 8'd0;
    else if(wr_load)        wr_val_2 <= { wr_async_data[6], wr_async_data[2], wr_async_data[14], wr_async_data[10], wr_async_data[22], wr_async_data[18], wr_async_data[30], wr_async_data[26] };
    else if(sd_clk_is_one)  wr_val_2 <= { wr_val_2[6:0], 1'b1 }; //fill with 1 important
end

reg [7:0] wr_val_3;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       wr_val_3 <= 8'd0;
    else if(wr_load)        wr_val_3 <= { wr_async_data[7], wr_async_data[3], wr_async_data[15], wr_async_data[11], wr_async_data[23], wr_async_data[19], wr_async_data[31], wr_async_data[27] };
    else if(sd_clk_is_one)  wr_val_3 <= { wr_val_3[6:0], 1'b1 }; //fill with 1 important
end

reg [15:0] wr_crc_0;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                           wr_crc_0 <= 16'd0;
    else if(sd_clk_is_one && wr_cnt >= 11'd18)  wr_crc_0 <= { wr_val_0[7] ^ wr_crc_0[0], wr_crc_0[15:12], wr_crc_0[11] ^ wr_val_0[7] ^ wr_crc_0[0], wr_crc_0[10:5], wr_crc_0[4] ^ wr_val_0[7] ^ wr_crc_0[0], wr_crc_0[3:1] };
    else if(sd_clk_is_one)                      wr_crc_0 <= { 1'b0, wr_crc_0[15:1] }; //fill with 0 important
end

reg [15:0] wr_crc_1;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                           wr_crc_1 <= 16'd0;
    else if(sd_clk_is_one && wr_cnt >= 11'd18)  wr_crc_1 <= { wr_val_1[7] ^ wr_crc_1[0], wr_crc_1[15:12], wr_crc_1[11] ^ wr_val_1[7] ^ wr_crc_1[0], wr_crc_1[10:5], wr_crc_1[4] ^ wr_val_1[7] ^ wr_crc_1[0], wr_crc_1[3:1] };
    else if(sd_clk_is_one)                      wr_crc_1 <= { 1'b0, wr_crc_1[15:1] }; //fill with 0 important
end

reg [15:0] wr_crc_2;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                           wr_crc_2 <= 16'd0;
    else if(sd_clk_is_one && wr_cnt >= 11'd18)  wr_crc_2 <= { wr_val_2[7] ^ wr_crc_2[0], wr_crc_2[15:12], wr_crc_2[11] ^ wr_val_2[7] ^ wr_crc_2[0], wr_crc_2[10:5], wr_crc_2[4] ^ wr_val_2[7] ^ wr_crc_2[0], wr_crc_2[3:1] };
    else if(sd_clk_is_one)                      wr_crc_2 <= { 1'b0, wr_crc_2[15:1] }; //fill with 0 important
end

reg [15:0] wr_crc_3;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                           wr_crc_3 <= 16'd0;
    else if(sd_clk_is_one && wr_cnt >= 11'd18)  wr_crc_3 <= { wr_val_3[7] ^ wr_crc_3[0], wr_crc_3[15:12], wr_crc_3[11] ^ wr_val_3[7] ^ wr_crc_3[0], wr_crc_3[10:5], wr_crc_3[4] ^ wr_val_3[7] ^ wr_crc_3[0], wr_crc_3[3:1] };
    else if(sd_clk_is_one)                      wr_crc_3 <= { 1'b0, wr_crc_3[15:1] }; //fill with 0 important
end

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

/*
input               rd_async_start,
input               rd_async_abort,
output reg          rd_data_done,
output reg          rd_data_last_in_sector,
output reg  [31:0]  rd_data,
output reg          rd_error,
*/

wire rd_start       = sd_clk_is_one && rd_async_in_progress && ~(rd_now_in_error) && ~(rd_error) && ~(rd_awaiting) && rd_cnt <= 11'd1;
wire rd_start_block = sd_clk_is_one && rd_awaiting && sd_dat_input == 4'h0;
wire rd_active      = sd_clk_is_one && rd_cnt > 11'd0;
wire rd_load        = sd_clk_is_one && rd_cnt >= 11'd18 && rd_cnt[2:0] == 3'b010 && ~(rd_async_abort);

reg rd_async_in_progress;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       rd_async_in_progress <= 1'b0;
    else if(rd_async_abort) rd_async_in_progress <= 1'b0;
    else if(rd_async_start) rd_async_in_progress <= 1'b1;
end

reg rd_awaiting;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       rd_awaiting <= 1'b0;
    else if(rd_async_abort) rd_awaiting <= 1'b0;
    else if(rd_start)       rd_awaiting <= 1'b1;
    else if(rd_start_block) rd_awaiting <= 1'b0;
end

reg [10:0] rd_cnt;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       rd_cnt <= 11'd0;
    else if(rd_async_abort) rd_cnt <= 11'd0;
    else if(rd_start_block) rd_cnt <= 11'd1041;
    else if(rd_active)      rd_cnt <= rd_cnt - 11'd1;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       rd_data_done <= 1'b0;
    else                    rd_data_done <= rd_load;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       rd_data_last_in_sector <= 1'b0;
    else                    rd_data_last_in_sector <= rd_load && rd_cnt == 11'd18;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       rd_data <= 32'b0;
    else if(rd_load)        rd_data <= { rd_val[3:0], sd_dat_input, rd_val[11:4], rd_val[19:12], rd_val[27:20] };
end

//------------------------------------------------------------------------------

reg [26:0] rd_error_cnt;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               rd_error_cnt <= 27'd0;
    else if(rd_async_abort)                         rd_error_cnt <= 27'd0;
    else if(rd_start_block)                         rd_error_cnt <= 27'd0;
    else if(rd_start)                               rd_error_cnt <= 27'd1;
    else if(sd_clk_is_one && rd_error_cnt > 27'd0)  rd_error_cnt <= rd_error_cnt + 27'd1;
end

wire rd_now_in_error = rd_active && (
    (rd_cnt == 11'd1 && sd_dat_input != 4'hF) ||                                                    //end bit is '0'
    (rd_cnt <= 11'd17 && rd_cnt >= 11'd2 && sd_dat_input != { rd_3[0], rd_2[0], rd_1[0], rd_0[0] }) //crc16 invalid
);

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                       rd_error <= 1'b0;
    else if(rd_async_abort)                                 rd_error <= 1'b0;
    else if(rd_now_in_error)                                rd_error <= 1'b1;
    else if(sd_clk_is_one && rd_error_cnt == 27'h7FFFFFF)   rd_error <= 1'b1;
end

//------------------------------------------------------------------------------

reg [27:0] rd_val;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   rd_val <= 28'd0;
    else if(rd_active)  rd_val <= { rd_val[23:0], sd_dat_input };
end

reg [15:0] rd_0;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                           rd_0 <= 16'd0;
    else if(sd_clk_is_one && rd_cnt >= 11'd18)  rd_0 <= { sd_dat_input[0] ^ rd_0[0], rd_0[15:12], rd_0[11] ^ sd_dat_input[0] ^ rd_0[0], rd_0[10:5], rd_0[4] ^ sd_dat_input[0] ^ rd_0[0], rd_0[3:1] };
    else if(sd_clk_is_one)                      rd_0 <= { 1'b0, rd_0[15:1] }; //fill with 0 important
end

reg [15:0] rd_1;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                           rd_1 <= 16'd0;
    else if(sd_clk_is_one && rd_cnt >= 11'd18)  rd_1 <= { sd_dat_input[1] ^ rd_1[0], rd_1[15:12], rd_1[11] ^ sd_dat_input[1] ^ rd_1[0], rd_1[10:5], rd_1[4] ^ sd_dat_input[1] ^ rd_1[0], rd_1[3:1] };
    else if(sd_clk_is_one)                      rd_1 <= { 1'b0, rd_1[15:1] }; //fill with 0 important
end

reg [15:0] rd_2;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                           rd_2 <= 16'd0;
    else if(sd_clk_is_one && rd_cnt >= 11'd18)  rd_2 <= { sd_dat_input[2] ^ rd_2[0], rd_2[15:12], rd_2[11] ^ sd_dat_input[2] ^ rd_2[0], rd_2[10:5], rd_2[4] ^ sd_dat_input[2] ^ rd_2[0], rd_2[3:1] };
    else if(sd_clk_is_one)                      rd_2 <= { 1'b0, rd_2[15:1] }; //fill with 0 important
end

reg [15:0] rd_3;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                           rd_3 <= 16'd0;
    else if(sd_clk_is_one && rd_cnt >= 11'd18)  rd_3 <= { sd_dat_input[3] ^ rd_3[0], rd_3[15:12], rd_3[11] ^ sd_dat_input[3] ^ rd_3[0], rd_3[10:5], rd_3[4] ^ sd_dat_input[3] ^ rd_3[0], rd_3[3:1] };
    else if(sd_clk_is_one)                      rd_3 <= { 1'b0, rd_3[15:1] }; //fill with 0 important
end

//------------------------------------------------------------------------------

endmodule
