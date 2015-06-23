/*
 * This file is subject to the terms and conditions of the BSD License. See
 * the file "LICENSE" in the main directory of this archive for more details.
 *
 * Copyright (C) 2014 Aleksander Osman
 */

module card_init(
    input               clk,
    input               rst_n,
    
    //
    input               operation_init,
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
    input               current_dat0
);

//------------------------------------------------------------------------------

reg [23:0] initial_delay;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   initial_delay <= 24'd0;
    else if(initial_delay[23] == 1'b0)  initial_delay <= initial_delay + 24'd1;
end

assign operation_finished_with_error = 
    (reply_error && (state == S_CMD0 || state == S_CMD8 || state == S_CMD55_FOR_41 || state == S_ACMD41 || state == S_CMD2 || state == S_CMD3 || state == S_CMD7 || state == S_CMD55_FOR_6 || state == S_ACMD6)) ||
    (state == S_CMD0         && reply_ready && ~(valid_cmd0))  ||
    (state == S_CMD8         && reply_ready && ~(valid_cmd8))  ||
    (state == S_CMD55_FOR_41 && reply_ready && ~(valid_cmd55)) ||
    (state == S_ACMD41       && reply_ready && ~(valid_acmd41) && ~(valid_acmd41_but_busy)) ||
    (state == S_CMD2         && reply_ready && ~(valid_cmd2)) ||
    (state == S_CMD3         && reply_ready && ~(valid_cmd3)) ||
    (state == S_CMD7         && reply_ready && ~(valid_cmd7) && ~(valid_cmd7_but_busy)) ||
    (state == S_CMD55_FOR_6  && reply_ready && ~(valid_cmd55)) ||
    (state == S_ACMD6        && reply_ready && ~(valid_acmd6));

assign operation_finished_ok = state == S_ACMD6 && reply_ready && valid_acmd6;

//------------------------------------------------------------------------------

wire prepare_cmd0           = state == S_IDLE && initial_delay[23] && operation_init;
wire valid_cmd0             = 1'b1; //always valid

wire prepare_cmd8           = state == S_CMD0 && reply_ready && valid_cmd0;
wire valid_cmd8             = reply_contents[45:40] == 6'd8 && reply_contents[19:16] == 4'b0001 && reply_contents[15:8] == 8'b11010010; //command index; accepted volage 2.7-3.6 V; check pattern echo

wire prepare_cmd55_for_41   = (state == S_CMD8 && reply_ready && valid_cmd8) || repeat_acmd41;
wire valid_cmd55            = reply_contents[45:40] == 6'd55 && reply_contents[39:27] == 13'd0 && reply_contents[24:21] == 4'b0; //command index; R1[31:19] no errors; R1[16:13] no errors

wire prepare_acmd41         = state == S_CMD55_FOR_41 && reply_ready && valid_cmd55;
wire valid_acmd41           = reply_contents[39:38] == 2'b11;                            //initialization complete and SDHC or SDXC;
wire valid_acmd41_but_busy  = reply_contents[39] == 1'b0 && acmd41_busy_cnt < 20'hFFFFF; //initialization not complete
wire repeat_acmd41          = state == S_ACMD41 && reply_ready && valid_acmd41_but_busy;

wire prepare_cmd2           = state == S_ACMD41 && reply_ready && valid_acmd41;
wire valid_cmd2             = 1'b1; //always valid

wire prepare_cmd3           = state == S_CMD2 && reply_ready && valid_cmd2;
wire valid_cmd3             = reply_contents[45:40] == 6'd3 && reply_contents[23:21] == 3'b0; //command index; R1[23,22,19] no errors
wire [15:0] cmd3_new_rca    = reply_contents[39:24];

wire prepare_cmd7           = state == S_CMD3 && reply_ready && valid_cmd3;
wire valid_cmd7_common      = reply_contents[45:40] == 6'd7 && reply_contents[39:27] == 13'd0 && reply_contents[24:21] == 4'b0; //command index; R1[31:19] no errors; R1[16:13] no errors
wire valid_cmd7             = valid_cmd7_common && current_dat0; 
wire valid_cmd7_but_busy    = valid_cmd7_common && ~(current_dat0);

wire prepare_cmd55_for_6    = (state == S_CMD7 && reply_ready && valid_cmd7) || (state == S_WAIT_DAT0 && current_dat0);

wire prepare_acmd6          = state == S_CMD55_FOR_6 && reply_ready && valid_cmd55;
wire valid_acmd6            = reply_contents[45:40] == 6'd6 && reply_contents[39:27] == 13'd0 && reply_contents[24:21] == 4'b0; //command index; R1[31:19] no errors; R1[16:13] no errors

//------------------------------------------------------------------------------

reg [19:0] acmd41_busy_cnt;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       acmd41_busy_cnt <= 20'd0;
    else if(prepare_cmd0)   acmd41_busy_cnt <= 20'd0;
    else if(repeat_acmd41)  acmd41_busy_cnt <= acmd41_busy_cnt + 20'd1;
end

reg [15:0] rca;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       rca <= 16'd0;
    else if(prepare_cmd7)   rca <= cmd3_new_rca;
end

//------------------------------------------------------------------------------

localparam [3:0] S_IDLE         = 4'd0;
localparam [3:0] S_CMD0         = 4'd1;
localparam [3:0] S_CMD8         = 4'd2;
localparam [3:0] S_CMD55_FOR_41 = 4'd3;
localparam [3:0] S_ACMD41       = 4'd4;
localparam [3:0] S_CMD2         = 4'd5;
localparam [3:0] S_CMD3         = 4'd6;
localparam [3:0] S_CMD7         = 4'd7;
localparam [3:0] S_WAIT_DAT0    = 4'd8;
localparam [3:0] S_CMD55_FOR_6  = 4'd9;
localparam [3:0] S_ACMD6        = 4'd10;

reg [3:0] state;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                               state <= S_IDLE;
    
    else if(operation_finished_with_error)                          state <= S_IDLE;
    
    else if(prepare_cmd0)                                           state <= S_CMD0;
    else if(prepare_cmd8)                                           state <= S_CMD8;
    else if(prepare_cmd55_for_41)                                   state <= S_CMD55_FOR_41;
    else if(prepare_acmd41)                                         state <= S_ACMD41;
    else if(repeat_acmd41)                                          state <= S_CMD55_FOR_41;
    else if(prepare_cmd2)                                           state <= S_CMD2;
    else if(prepare_cmd3)                                           state <= S_CMD3;
    else if(prepare_cmd7)                                           state <= S_CMD7;
    else if(state == S_CMD7 && reply_ready && valid_cmd7_but_busy)  state <= S_WAIT_DAT0;
    else if(prepare_cmd55_for_6)                                    state <= S_CMD55_FOR_6;
    else if(prepare_acmd6)                                          state <= S_ACMD6;
    
    else if(operation_finished_ok)                                  state <= S_IDLE;
end

//------------------------------------------------------------------------------

assign cmd_ready = prepare_cmd0 || prepare_cmd8 || prepare_cmd55_for_41 || prepare_acmd41 || prepare_cmd2 || prepare_cmd3 || prepare_cmd7 || prepare_cmd55_for_6 || prepare_acmd6;
    
assign cmd_index =
    (prepare_cmd0)?         6'd0 :
    (prepare_cmd8)?         6'd8 :
    (prepare_cmd55_for_41)? 6'd55 :
    (prepare_acmd41)?       6'd41 :
    (prepare_cmd2)?         6'd2 :
    (prepare_cmd3)?         6'd3 :
    (prepare_cmd7)?         6'd7 :
    (prepare_cmd55_for_6)?  6'd55 :
    (prepare_acmd6)?        6'd6 :
                            6'd0;

assign cmd_arg =
    (prepare_cmd0)?         32'd0 :             //stuff bits
    
    (prepare_cmd8)?         { 20'b0,            //reserved
                              4'b0001,          //VHS voltage supplied 2.7-3.6 V
                              8'b11010010 } :   //check pattern;
                            
    (prepare_cmd55_for_41)? { 16'd0,            //RCA
                              16'd0 } :         //stuff bits
                            
    (prepare_acmd41)?       { 1'b0,                   //busy
                              1'b1,                   //Host Capacity Support (1=SDHC or SDXC)
                              1'b0,                   //reserved FB(0)
                              1'b0,                   //SDXC Power Control (0=power saving)
                              3'b0,                   //reserved
                              1'b0,                   //switching to 1.8V request
                              16'b0011000000000000,   //voltage window field OCR[23:08]: 3.2-3.3 and 3.3-3.4
                              8'b0 } :                //reseved;
    
    (prepare_cmd2)?         32'd0 :             //stuff bits
    
    (prepare_cmd3)?         32'd0 :             //stuff bits
    
    (prepare_cmd7)?         { cmd3_new_rca,     //RCA
                              16'd0 } :         //stuff bits

    (prepare_cmd55_for_6)?  { rca,              //RCA
                              16'd0 } :         //stuff bits

    (prepare_acmd6)?        { 30'd0,            //stuff bits
                              2'b10 } :         //4 bit bus

                            32'd0;

assign cmd_resp_length =
    (prepare_cmd0)?         8'd0 :
    (prepare_cmd8)?         8'd48 :  //R7
    (prepare_cmd55_for_41)? 8'd48 :  //R1
    (prepare_acmd41)?       8'd48 :  //R3 OCR
    (prepare_cmd2)?         8'd136 : //R2
    (prepare_cmd3)?         8'd48 :  //R6
    (prepare_cmd7)?         8'd48 :  //R1b
    (prepare_cmd55_for_6)?  8'd48 :  //R1
    (prepare_acmd6)?        8'd48 :  //R1
                            8'd0;

assign cmd_resp_has_crc7 =
    (prepare_cmd0)?         1'b0 :
    (prepare_cmd8)?         1'b1 :
    (prepare_cmd55_for_41)? 1'b1 :
    (prepare_acmd41)?       1'b0 :
    (prepare_cmd2)?         1'b1 :
    (prepare_cmd3)?         1'b1 :
    (prepare_cmd7)?         1'b1 :
    (prepare_cmd55_for_6)?  1'b1 :
    (prepare_acmd6)?        1'b1 :
                            1'b1;

//------------------------------------------------------------------------------
// synthesis translate_off
wire _unused_ok = &{ 1'b0, reply_contents[135:46], reply_contents[20], reply_contents[7:0], 1'b0 };
// synthesis translate_on
//------------------------------------------------------------------------------

endmodule
