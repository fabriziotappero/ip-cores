/*
 * This file is subject to the terms and conditions of the BSD License. See
 * the file "LICENSE" in the main directory of this archive for more details.
 *
 * Copyright (C) 2014 Aleksander Osman
 */

module cmd(
    input               clk,
    input               rst_n,
    
    //
    input               sd_clk_is_one,
    
    //
    input               cmd_ready,
    input       [5:0]   cmd_index,
    input       [31:0]  cmd_arg,
    input       [7:0]   cmd_resp_length,
    input               cmd_resp_has_crc7,
    
    //
    output reg          reply_ready,
    output reg  [135:0] reply_contents,
    output              reply_error,
    
    //
    inout               sd_cmd
);

//------------------------------------------------------------------------------

reg sd_cmd_enable;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       sd_cmd_enable <= 1'b0;
    else if(sd_clk_is_one)  sd_cmd_enable <= cmd_start || cmd_cnt > 6'd0;
end

reg sd_cmd_output;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       sd_cmd_output <= 1'b1;
    else if(sd_clk_is_one)  sd_cmd_output <= (cmd_start)? 1'b0 : (cmd_cnt <= 6'd8 && cmd_cnt >= 6'd2)? cmd_crc7[0] : cmd_value[38];
end

assign sd_cmd = (sd_cmd_enable)? sd_cmd_output : 1'bZ;

reg sd_cmd_input;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           sd_cmd_input <= 1'b1;
    else if(~(sd_clk_is_one))   sd_cmd_input <= sd_cmd;
end

//------------------------------------------------------------------------------

reg [3:0] cmd_start_delay_cnt;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                     cmd_start_delay_cnt <= 4'd0;
    else if(reply_ready || reply_error)                   cmd_start_delay_cnt <= 4'd8;
    else if(sd_clk_is_one && cmd_start_delay_cnt > 4'd0)  cmd_start_delay_cnt <= cmd_start_delay_cnt - 4'd1;
end

reg cmd_start_waiting;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                       cmd_start_waiting <= 1'b0;
    else if(cmd_start)                                                      cmd_start_waiting <= 1'b0;
    else if(cmd_ready && (cmd_start_delay_cnt > 4'd0 || ~(sd_clk_is_one)))  cmd_start_waiting <= 1'b1;
end

wire cmd_start = sd_clk_is_one && (cmd_ready || cmd_start_waiting) && cmd_start_delay_cnt == 4'd0;

reg [5:0] cmd_cnt;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                           cmd_cnt <= 6'd0;
    else if(cmd_start)                          cmd_cnt <= 6'd47;
    else if(sd_clk_is_one && cmd_cnt > 6'd0)    cmd_cnt <= cmd_cnt - 6'd1;
end

reg [38:0] cmd_value;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                           cmd_value <= 39'h7FFFFFFFFF;
    else if(cmd_ready)                          cmd_value <= { 1'b1, cmd_index, cmd_arg };
    else if(sd_clk_is_one && cmd_cnt > 6'd0)    cmd_value <= { cmd_value[37:0], 1'b1 }; //fill with 1 important
end

reg [6:0] cmd_crc7;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                           cmd_crc7 <= 7'd0;
    else if(sd_clk_is_one && cmd_cnt >= 6'd9)   cmd_crc7 <= { cmd_value[38] ^ cmd_crc7[0], cmd_crc7[6:5], cmd_crc7[4] ^ cmd_value[38] ^ cmd_crc7[0], cmd_crc7[3:1] };
    else if(sd_clk_is_one)                      cmd_crc7 <= { 1'b0, cmd_crc7[6:1] };
end

//------------------------------------------------------------------------------

wire resp_active = sd_clk_is_one && resp_cnt > 8'd0 && cmd_cnt == 6'd0 && ~(cmd_start_waiting) && ((resp_awaiting && sd_cmd_input == 1'b0) || ~(resp_awaiting));

reg [7:0] resp_cnt;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       resp_cnt <= 8'd0;
    else if(reply_error)    resp_cnt <= 8'd0;
    else if(cmd_ready)      resp_cnt <= cmd_resp_length;
    else if(resp_active)    resp_cnt <= resp_cnt - 8'd1;
end

reg resp_has_crc7;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   resp_has_crc7 <= 1'b0;
    else if(cmd_ready)  resp_has_crc7 <= cmd_resp_has_crc7;
end

reg resp_awaiting;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                               resp_awaiting <= 1'b0;
    else if(reply_error)                                            resp_awaiting <= 1'b0;
    else if(sd_clk_is_one && cmd_cnt == 6'd1 && resp_cnt > 8'd0)    resp_awaiting <= 1'b1;
    else if(sd_clk_is_one && resp_awaiting && sd_cmd_input == 1'b0) resp_awaiting <= 1'b0;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       reply_contents <= 136'd0;
    else if(resp_active)    reply_contents <= { reply_contents[134:0], sd_cmd_input };
end

reg [6:0] resp_crc7;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                               resp_crc7 <= 7'd0;
    else if(resp_active && resp_cnt >= 8'd9 && resp_cnt <= 8'd128)  resp_crc7 <= { sd_cmd_input ^ resp_crc7[0], resp_crc7[6:5], resp_crc7[4] ^ sd_cmd_input ^ resp_crc7[0], resp_crc7[3:1] };
    else if(resp_active)                                            resp_crc7 <= { 1'b0, resp_crc7[6:1] };
end

//------------------------------------------------------------------------------

reg resp_next_is_trans_bit;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                       resp_next_is_trans_bit <= 1'b0;
    else if(resp_active && resp_awaiting)   resp_next_is_trans_bit <= 1'b1;
    else if(resp_active)                    resp_next_is_trans_bit <= 1'b0;
end

wire resp_now_in_error = resp_active && (
    (resp_next_is_trans_bit && sd_cmd_input == 1'b1) ||                                     //transmission bit is '1'
    (resp_cnt == 8'd1 && sd_cmd_input == 1'b0) ||                                           //end bit is '0'
    (resp_cnt <= 8'd8 && resp_cnt >= 8'd2 && resp_has_crc7 && sd_cmd_input != resp_crc7[0]) //crc7 invalid
);

reg resp_had_error;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           resp_had_error <= 1'b0;
    else if(reply_error)        resp_had_error <= 1'b0;
    else if(resp_now_in_error)  resp_had_error <= 1'b1;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   reply_ready <= 1'b0;
    else                reply_ready <= (sd_clk_is_one && cmd_cnt == 6'd1 && resp_cnt == 8'd0) || (resp_active && resp_cnt == 8'd1 && ~(resp_now_in_error || resp_had_error));
end

//------------------------------------------------------------------------------

wire error_start = (sd_clk_is_one && cmd_cnt == 6'd1 && resp_cnt > 8'd0) || (resp_active && resp_cnt == 8'd1 && (resp_now_in_error || resp_had_error));

reg [6:0] error_delay_cnt;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                               error_delay_cnt <= 7'd0;
    else if(sd_clk_is_one && resp_awaiting && sd_cmd_input == 1'b0) error_delay_cnt <= 7'd0;
    else if(error_start)                                            error_delay_cnt <= 7'd1;
    else if(sd_clk_is_one && error_delay_cnt > 7'd0)                error_delay_cnt <= error_delay_cnt + 7'd1;
end

assign reply_error = error_delay_cnt == 7'd127;

//------------------------------------------------------------------------------

endmodule
