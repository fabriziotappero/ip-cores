/*
 * This file is subject to the terms and conditions of the BSD License. See
 * the file "LICENSE" in the main directory of this archive for more details.
 *
 * Copyright (C) 2014 Aleksander Osman
 */

module card_read(
    input               clk,
    input               rst_n,
    
    //
    input               operation_read,
    
    input               operation_sector_last,
    output              operation_sector_update,
    
    output              operation_finished_ok,
    output              operation_finished_with_error,
    
    //
    output              cmd_ready,
    output      [5:0]   cmd_index,
    output      [31:0]  cmd_arg,
    output      [7:0]   cmd_resp_length,
    output              cmd_resp_has_crc7,
    
    input               reply_ready,
    input       [135:0] reply_contents,
    input               reply_error,
    
    //
    output              write_start,
    output              write_next,
    output      [31:0]  write_data,
    input               write_done,
    
    //
    output              rd_async_start,
    output              rd_async_abort,
    input               rd_data_done,
    input               rd_data_last_in_sector,
    input       [31:0]  rd_data,
    input               rd_error,
    
    //
    input       [31:0]  sd_address,
    
    //
    input               current_dat0,
    
    //
    output              stop_sd_clk
);

//------------------------------------------------------------------------------

localparam [2:0] S_IDLE             = 3'd0;
localparam [2:0] S_CMD18            = 3'd1;
localparam [2:0] S_WAIT_FOR_DATA    = 3'd2;
localparam [2:0] S_CMD12            = 3'd3;
localparam [2:0] S_WAIT_FOR_DAT0    = 3'd4;
localparam [2:0] S_FAILED_CMD12     = 3'd5;

wire prepare_cmd18 = state == S_IDLE && operation_read;
wire valid_cmd18   = reply_contents[45:40] == 6'd18 && reply_contents[39:27] == 13'd0 && reply_contents[24:21] == 4'b0; //command index; R1[31:19] no errors; R1[16:13] no errors

wire stop_because_of_error = (state == S_CMD18 && (reply_error || (reply_ready && ~(valid_cmd18)))) || ((state == S_CMD18 || state == S_WAIT_FOR_DATA) && rd_error);
wire prepare_cmd12         = stop_because_of_error || (operation_sector_update && operation_sector_last);
wire valid_cmd12_common    = reply_contents[45:40] == 6'd12 && reply_contents[39:27] == 13'd0 && reply_contents[24:21] == 4'b0; //command index; R1[31:19] no errors; R1[16:13] no errors
wire valid_cmd12           = valid_cmd12_common && current_dat0; 
wire valid_cmd12_but_busy  = valid_cmd12_common && ~(current_dat0);

wire prepare_failed_cmd12  = state == S_CMD12 && (reply_error || (reply_ready && ~(valid_cmd12_common))); 

reg [2:0] state;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                   state <= S_IDLE;
    
    else if(operation_finished_with_error)                              state <= S_IDLE;
    
    else if(prepare_cmd18)                                              state <= S_CMD18;
    else if(state == S_CMD18 && reply_ready && valid_cmd18)             state <= S_WAIT_FOR_DATA;
    
    else if(prepare_cmd12)                                              state <= S_CMD12;
    else if(state == S_CMD12 && reply_ready && valid_cmd12_but_busy)    state <= S_WAIT_FOR_DAT0;
    else if(prepare_failed_cmd12)                                       state <= S_FAILED_CMD12;
    
    else if(operation_finished_ok)                                      state <= S_IDLE;
end

reg was_error;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                   was_error <= 1'b0;
    else if(prepare_cmd18)                                              was_error <= 1'b0;
    else if(stop_because_of_error || rd_error || prepare_failed_cmd12)  was_error <= 1'b1;
end

wire finishing = (state == S_CMD12 && reply_ready && valid_cmd12) || (state == S_WAIT_FOR_DAT0 && current_dat0) || state == S_FAILED_CMD12;

assign operation_finished_ok         = finishing && ~(was_error);
assign operation_finished_with_error = finishing && was_error;

//------------------------------------------------------------------------------

reg first_write;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       first_write <= 1'b0;
    else if(prepare_cmd18)  first_write <= 1'b1;
    else if(write_start)    first_write <= 1'b0;
end

reg [3:0] write_cnt;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               write_cnt <= 4'd0;
    else if(write_start || write_next)              write_cnt <= 4'd1;
    else if(write_done)                             write_cnt <= 4'd0;
    else if(write_cnt > 4'd0 && write_cnt < 4'd14)  write_cnt <= write_cnt + 4'd1;
end

assign stop_sd_clk = write_cnt == 4'd14;

assign write_start = first_write    && rd_data_done && (state == S_CMD18 || state == S_WAIT_FOR_DATA);
assign write_next  = ~(first_write) && rd_data_done && (state == S_CMD18 || state == S_WAIT_FOR_DATA);
assign write_data  = rd_data;

assign rd_async_start = prepare_cmd18;
assign rd_async_abort = operation_finished_ok || operation_finished_with_error;

assign operation_sector_update = rd_data_done && rd_data_last_in_sector;

//------------------------------------------------------------------------------

assign cmd_ready = prepare_cmd18 || prepare_cmd12;

assign cmd_index         = (prepare_cmd18)? 6'd18      : 6'd12;
assign cmd_arg           = (prepare_cmd18)? sd_address : 32'd0; //cmd18: sector address; cmd12: stuff bits
assign cmd_resp_length   = 8'd48;                               //cmd18: R1; cmd12: R1b
assign cmd_resp_has_crc7 = 1'b1;

//------------------------------------------------------------------------------
// synthesis translate_off
wire _unused_ok = &{ 1'b0, reply_contents[135:46], reply_contents[26:25], reply_contents[20:0], 1'b0 };
// synthesis translate_on
//------------------------------------------------------------------------------

endmodule
