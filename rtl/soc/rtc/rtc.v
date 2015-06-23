/*
 * Copyright (c) 2014, Aleksander Osman
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 * 
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

module rtc(
    input               clk,
    input               rst_n,
    
    output reg          irq,
    
    //io slave
    input               io_address,
    input               io_read,
    output reg  [7:0]   io_readdata,
    input               io_write,
    input       [7:0]   io_writedata,
    
    //mgmt slave
    /*
    128.[26:0]: cycles in second
    129.[12:0]: cycles in 122.07031 us
    */
    input       [7:0]   mgmt_address,
    input               mgmt_write,
    input       [31:0]  mgmt_writedata
);

//------------------------------------------------------------------------------

reg io_read_last;
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) io_read_last <= 1'b0; else if(io_read_last) io_read_last <= 1'b0; else io_read_last <= io_read; end 
wire io_read_valid = io_read && io_read_last == 1'b0;

//------------------------------------------------------------------------------ cycle count from mgmt

reg [26:0] cycles_in_second;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               cycles_in_second <= 27'd30303030;
    else if(mgmt_write && mgmt_address == 8'd128)   cycles_in_second <= mgmt_writedata[26:0];
end

reg [12:0] cycles_in_122us;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               cycles_in_122us <= 13'd4069;
    else if(mgmt_write && mgmt_address == 8'd129)   cycles_in_122us <= mgmt_writedata[12:0];
end

//------------------------------------------------------------------------------ io read

wire [7:0] io_readdata_next =
    (io_address == 1'b0)?       8'hFF :
    (ram_address == 7'h00)?     rtc_second :
    (ram_address == 7'h01)?     alarm_second :
    (ram_address == 7'h02)?     rtc_minute :
    (ram_address == 7'h03)?     alarm_second :
    (ram_address == 7'h04)?     rtc_hour :
    (ram_address == 7'h05)?     alarm_hour :
    (ram_address == 7'h06)?     rtc_dayofweek :
    (ram_address == 7'h07)?     rtc_dayofmonth :
    (ram_address == 7'h08)?     rtc_month :
    (ram_address == 7'h09)?     rtc_year :
    (ram_address == 7'h0A)?     { sec_state == SEC_UPDATE_IN_PROGRESS || sec_state == SEC_SECOND_START, divider, periodic_rate } :
    (ram_address == 7'h0B)?     { crb_freeze, crb_int_periodic_ena, crb_int_alarm_ena, crb_int_update_ena,
                                  1'b0, crb_binarymode, crb_24hour, crb_daylightsaving } :
    (ram_address == 7'h0C)?     { irq, periodic_interrupt, alarm_interrupt, update_interrupt, 4'd0 } :
    (ram_address == 7'h0D)?     8'h80 :
    (ram_address == 7'h32)?     rtc_century :
    (ram_address == 7'h37)?     rtc_century :
                                ram_q;

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   io_readdata <= 8'd0;
    else                io_readdata <= io_readdata_next;
end

//------------------------------------------------------------------------------ irq

wire interrupt_start = irq == 1'b0 && (
    (crb_int_periodic_ena && periodic_interrupt) ||
    (crb_int_alarm_ena    && alarm_interrupt) ||
    (crb_int_update_ena   && update_interrupt) );

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                       irq <= 1'b0;
    else if(io_read_valid && io_address == 1'b1 && ram_address == 7'h0C)    irq <= 1'b0;
    else if(interrupt_start)                                                irq <= 1'b1;
end

//------------------------------------------------------------------------------ once per second state machine

localparam [2:0] SEC_UPDATE_START       = 3'd0;
localparam [2:0] SEC_UPDATE_IN_PROGRESS = 3'd1;
localparam [2:0] SEC_SECOND_START       = 3'd2;
localparam [2:0] SEC_SECOND_IN_PROGRESS = 3'd3;
localparam [2:0] SEC_STOPPED            = 3'd4;

reg [2:0] sec_state;

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                                   sec_state <= SEC_UPDATE_START;
    
    else if(crb_freeze || divider[2:1] == 2'b11)                                                        sec_state <= SEC_STOPPED;
    else if(sec_state == SEC_STOPPED)                                                                   sec_state <= SEC_UPDATE_START;
    
    else if(sec_state == SEC_UPDATE_START)                                                              sec_state <= SEC_UPDATE_IN_PROGRESS;
    else if(sec_state == SEC_UPDATE_IN_PROGRESS && sec_timeout == 27'd0)                                sec_state <= SEC_SECOND_START;
    else if(sec_state == SEC_SECOND_START)                                                              sec_state <= SEC_SECOND_IN_PROGRESS;
    else if(sec_state == SEC_SECOND_IN_PROGRESS && sec_timeout == { 13'd0, cycles_in_122us, 1'b0 })     sec_state <= SEC_UPDATE_START;
end

reg [26:0] sec_timeout;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               sec_timeout <= 27'd8137; //4069*2 -1
    else if(crb_freeze || divider[2:1] == 2'b11)    sec_timeout <= 27'd8137; //4069*2 -1
    else if(sec_timeout == 27'd0)                   sec_timeout <= cycles_in_second;
    else                                            sec_timeout <= sec_timeout - 27'd1;
end

reg update_interrupt;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                       update_interrupt <= 1'b0;
    else if(io_read_valid && io_address == 1'b1 && ram_address == 7'h0C)    update_interrupt <= 1'b0;
    else if(sec_state == SEC_SECOND_START)                                  update_interrupt <= 1'b1;
end

//------------------------------------------------------------------------------

wire max_second = 
    (crb_binarymode && rtc_second >= 8'd59) ||
    (~(crb_binarymode) && (rtc_second[7:4] >= 4'd6 || (rtc_second[7:4] == 4'd5 && rtc_second[3:0] >= 4'd9)));

wire [7:0] next_second =
    (max_second)?                                       8'd0 :
    (~(crb_binarymode) && rtc_second[3:0] >= 4'd9)?     { rtc_second[7:4] + 4'd1, 4'd0 } :
                                                        rtc_second + 8'd1;

wire max_minute = 
    (crb_binarymode && rtc_minute >= 8'd59) ||
    (~(crb_binarymode) && (rtc_minute[7:4] >= 4'd6 || (rtc_minute[7:4] == 4'd5 && rtc_minute[3:0] >= 4'd9)));

wire [7:0] next_minute =
    (max_minute)?                                       8'd0 :
    (~(crb_binarymode) && rtc_minute[3:0] >= 4'd9)?     { rtc_minute[7:4] + 4'd1, 4'd0 } :
                                                        rtc_minute + 8'd1;

wire dst_april   = crb_daylightsaving && rtc_dayofweek == 8'd1 && rtc_month == 8'd4 &&
    ((crb_binarymode && rtc_dayofmonth >= 8'd24) || (~(crb_binarymode) && rtc_dayofmonth[7:4] >= 4'd2 && rtc_dayofmonth[3:0] >= 4'd4)) &&
    rtc_hour == 8'd1;

wire dst_october = crb_daylightsaving && rtc_dayofweek == 8'd1 &&
    ((crb_binarymode && rtc_month == 8'd10) || (~(crb_binarymode) && rtc_month[7:4] == 4'd1 && rtc_month[3:0] == 4'd0)) &&
    ((crb_binarymode && rtc_dayofmonth >= 8'd25) || (~(crb_binarymode) && rtc_dayofmonth[7:4] >= 4'd2 && rtc_dayofmonth[3:0] >= 4'd5)) &&
    rtc_hour == 8'd1;
    
wire max_hour =
    (~(crb_24hour) && crb_binarymode    && rtc_hour[7] && rtc_hour[6:0] >= 7'd12) ||
    (crb_24hour    && crb_binarymode    && rtc_hour >= 8'd23) ||
    (~(crb_24hour) && ~(crb_binarymode) && rtc_hour[7] && (rtc_hour[6:4] >= 3'd2 || (rtc_hour[6:4] == 3'd1 && rtc_hour[3:0] >= 4'd2))) ||
    (crb_24hour    && ~(crb_binarymode) && (rtc_hour[7:4] >= 4'd3 || (rtc_hour[7:4] == 4'd2 && rtc_hour[3:0] >= 4'd3)));

wire [7:0] next_hour =
    (dst_april)?                                                                                8'd3 :
    (dst_october)?                                                                              8'd1 :
    (~(crb_24hour) && max_hour)?                                                                8'd1 :
    (crb_24hour    && max_hour)?                                                                8'd0 :
    (~(crb_24hour) && crb_binarymode    && rtc_hour[6:0] >= 7'd12)?                             8'h81 :
    (~(crb_24hour) && ~(crb_binarymode) && rtc_hour[6:4] == 3'd1 && rtc_hour[3:0] >= 4'd2)?     8'h81 :
    (~(crb_24hour) && ~(crb_binarymode) && rtc_hour[6:4] == 3'd0 && rtc_hour[3:0] >= 4'd9)?     { rtc_hour[7], 3'b1, 4'd0 }  :
    (crb_24hour    && ~(crb_binarymode) && rtc_hour[3:0] >= 4'd9)?                              { rtc_hour[7:4] + 4'd1, 4'd0 } :
                                                                                                rtc_hour + 8'd1;

wire max_dayofweek = rtc_dayofweek >= 8'd7;

wire [7:0] next_dayofweek =
    (max_dayofweek)?    8'd1 :
                        rtc_dayofweek + 8'd1;

//simplified leap year condition
wire leap_year =
    (crb_binarymode    && rtc_year[1:0] == 2'b00) ||
    (~(crb_binarymode) && ((rtc_year[1:0] == 2'b00 && rtc_year[4] == 1'b0) || (rtc_year[1:0] == 2'b10 && rtc_year[4] == 1'b1)));

wire max_dayofmonth = 
    (crb_binarymode && (
        (rtc_month <= 8'd1  && rtc_dayofmonth >= 8'd31) ||
        (rtc_month == 8'd2  && ((~(leap_year) && rtc_dayofmonth >= 8'd28) || (leap_year && rtc_dayofmonth >= 8'd29))) ||
        (rtc_month == 8'd3  && rtc_dayofmonth >= 8'd31) ||
        (rtc_month == 8'd4  && rtc_dayofmonth >= 8'd30) ||
        (rtc_month == 8'd5  && rtc_dayofmonth >= 8'd31) ||
        (rtc_month == 8'd6  && rtc_dayofmonth >= 8'd30) ||
        (rtc_month == 8'd7  && rtc_dayofmonth >= 8'd31) ||
        (rtc_month == 8'd8  && rtc_dayofmonth >= 8'd31) ||
        (rtc_month == 8'd9  && rtc_dayofmonth >= 8'd30) ||
        (rtc_month == 8'd10 && rtc_dayofmonth >= 8'd31) ||
        (rtc_month == 8'd11 && rtc_dayofmonth >= 8'd30) ||
        (rtc_month >= 8'd12 && rtc_dayofmonth >= 8'd31))
    ) ||
    (~(crb_binarymode) && (
        (rtc_month <= 8'h01 && (rtc_dayofmonth[7:4] >= 4'd4 || (rtc_dayofmonth[7:4] == 4'd3 && rtc_dayofmonth[3:0] >= 4'd1))) ||
        (rtc_month == 8'h02 && ((~(leap_year) && (rtc_dayofmonth[7:4] >= 4'd3 || (rtc_dayofmonth[7:4] == 4'd2 && rtc_dayofmonth[3:0] >= 4'd8))) ||
                               (leap_year    && (rtc_dayofmonth[7:4] >= 4'd3 || (rtc_dayofmonth[7:4] == 4'd2 && rtc_dayofmonth[3:0] >= 4'd9))))) ||
        (rtc_month == 8'h03 && (rtc_dayofmonth[7:4] >= 4'd4 || (rtc_dayofmonth[7:4] == 4'd3 && rtc_dayofmonth[3:0] >= 4'd1))) ||
        (rtc_month == 8'h04 && (rtc_dayofmonth[7:4] >= 4'd4 || (rtc_dayofmonth[7:4] == 4'd3))) ||
        (rtc_month == 8'h05 && (rtc_dayofmonth[7:4] >= 4'd4 || (rtc_dayofmonth[7:4] == 4'd3 && rtc_dayofmonth[3:0] >= 4'd1))) ||
        (rtc_month == 8'h06 && (rtc_dayofmonth[7:4] >= 4'd4 || (rtc_dayofmonth[7:4] == 4'd3))) ||
        (rtc_month == 8'h07 && (rtc_dayofmonth[7:4] >= 4'd4 || (rtc_dayofmonth[7:4] == 4'd3 && rtc_dayofmonth[3:0] >= 4'd1))) ||
        (rtc_month == 8'h08 && (rtc_dayofmonth[7:4] >= 4'd4 || (rtc_dayofmonth[7:4] == 4'd3 && rtc_dayofmonth[3:0] >= 4'd1))) ||
        (rtc_month == 8'h09 && (rtc_dayofmonth[7:4] >= 4'd4 || (rtc_dayofmonth[7:4] == 4'd3))) ||
        (rtc_month == 8'h10 && (rtc_dayofmonth[7:4] >= 4'd4 || (rtc_dayofmonth[7:4] == 4'd3 && rtc_dayofmonth[3:0] >= 4'd1))) ||
        (rtc_month == 8'h11 && (rtc_dayofmonth[7:4] >= 4'd4 || (rtc_dayofmonth[7:4] == 4'd3))) ||
        (rtc_month >= 8'h12 && (rtc_dayofmonth[7:4] >= 4'd4 || (rtc_dayofmonth[7:4] == 4'd3 && rtc_dayofmonth[3:0] >= 4'd1))))
    );

wire [7:0] next_dayofmonth =
    (max_dayofmonth)?                                       8'd1 :
    (~(crb_binarymode) && rtc_dayofmonth[3:0] >= 4'd9)?     { rtc_dayofmonth[7:4] + 4'd1, 4'd0 } :
                                                            rtc_dayofmonth + 8'd1;

wire max_month =
    (crb_binarymode && rtc_month >= 8'd12) || (~(crb_binarymode) && (rtc_month[7:4] >= 4'd2 || (rtc_month[7:4] == 4'd1 && rtc_month[3:0] >= 4'd2)));

wire [7:0] next_month =
    (max_month)?                                    8'd1 :
    (~(crb_binarymode) && rtc_month[3:0] >= 4'd9)?  { rtc_month[7:4] + 4'd1, 4'd0 } :
                                                    rtc_month + 8'd1;
    
wire max_year =
    (crb_binarymode && rtc_year >= 8'd99) || (~(crb_binarymode) && (rtc_year[7:4] >= 4'd10 || (rtc_year[7:4] == 4'd9 && rtc_year[3:0] >= 4'd9)));

wire [7:0] next_year =
    (max_year)?                                     8'd0 :
    (~(crb_binarymode) && rtc_year[3:0] >= 4'd9)?   { rtc_year[7:4] + 4'd1, 4'd0 } :
                                                    rtc_year + 8'd1;

wire max_century =
    (crb_binarymode && rtc_century >= 8'd99) || (~(crb_binarymode) && (rtc_century[7:4] >= 4'd10 || (rtc_century[7:4] == 4'd9 && rtc_century[3:0] >= 4'd9)));

wire [7:0] next_century =
    (max_century)?                                      8'd0 :
    (~(crb_binarymode) && rtc_century[3:0] >= 4'd9)?    { rtc_century[7:4] + 4'd1, 4'd0 } :
                                                        rtc_century + 8'd1;
    
//------------------------------------------------------------------------------

wire rtc_second_update = sec_state == SEC_SECOND_START;
wire rtc_minute_update = rtc_second_update && max_second;
wire rtc_hour_update   = rtc_minute_update && max_minute;
wire rtc_day_update    = rtc_hour_update   && max_hour;
wire rtc_month_update  = rtc_day_update    && max_dayofmonth;
wire rtc_year_update   = rtc_month_update  && max_month;
wire rtc_century_update= rtc_year_update   && max_year;

//------------------------------------------------------------------------------

reg [7:0] rtc_second;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                   rtc_second <= 8'd0;
    else if(mgmt_write && mgmt_address == 8'h00)                        rtc_second <= mgmt_writedata[7:0];
    else if(io_write && io_address == 1'b1 && ram_address == 7'h00)     rtc_second <= io_writedata;
    else if(rtc_second_update)                                          rtc_second <= next_second; 
end

reg [7:0] rtc_minute;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                   rtc_minute <= 8'd0;
    else if(mgmt_write && mgmt_address == 8'h02)                        rtc_minute <= mgmt_writedata[7:0];
    else if(io_write && io_address == 1'b1 && ram_address == 7'h02)     rtc_minute <= io_writedata;
    else if(rtc_minute_update)                                          rtc_minute <= next_minute;
end

reg [7:0] rtc_hour;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                   rtc_hour <= 8'd0;
    else if(mgmt_write && mgmt_address == 8'h04)                        rtc_hour <= mgmt_writedata[7:0];
    else if(io_write && io_address == 1'b1 && ram_address == 7'h04)     rtc_hour <= io_writedata;
    else if(rtc_hour_update)                                            rtc_hour <= next_hour;
end

reg [7:0] rtc_dayofweek;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                   rtc_dayofweek <= 8'd0;
    else if(mgmt_write && mgmt_address == 8'h06)                        rtc_dayofweek <= mgmt_writedata[7:0];
    else if(io_write && io_address == 1'b1 && ram_address == 7'h06)     rtc_dayofweek <= io_writedata;
    else if(rtc_day_update)                                             rtc_dayofweek <= next_dayofweek;
end

reg [7:0] rtc_dayofmonth;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                   rtc_dayofmonth <= 8'd0;
    else if(mgmt_write && mgmt_address == 8'h07)                        rtc_dayofmonth <= mgmt_writedata[7:0];
    else if(io_write && io_address == 1'b1 && ram_address == 7'h07)     rtc_dayofmonth <= io_writedata;
    else if(rtc_day_update)                                             rtc_dayofmonth <= next_dayofmonth;
end

reg [7:0] rtc_month;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                   rtc_month <= 8'd0;
    else if(mgmt_write && mgmt_address == 8'h08)                        rtc_month <= mgmt_writedata[7:0];
    else if(io_write && io_address == 1'b1 && ram_address == 7'h08)     rtc_month <= io_writedata;
    else if(rtc_month_update)                                           rtc_month <= next_month;
end

reg [7:0] rtc_year;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                   rtc_year <= 8'd0;
    else if(mgmt_write && mgmt_address == 8'h09)                        rtc_year <= mgmt_writedata[7:0];
    else if(io_write && io_address == 1'b1 && ram_address == 7'h09)     rtc_year <= io_writedata;
    else if(rtc_year_update)                                            rtc_year <= next_year;
end

reg [7:0] rtc_century;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                   rtc_century <= 8'd0;
    else if(mgmt_write && mgmt_address == 8'h32)                        rtc_century <= mgmt_writedata[7:0];
    else if(io_write && io_address == 1'b1 && ram_address == 7'h32)     rtc_century <= io_writedata;
    else if(io_write && io_address == 1'b1 && ram_address == 7'h37)     rtc_century <= io_writedata;
    else if(rtc_century_update)                                         rtc_century <= next_century;
end

//------------------------------------------------------------------------------

reg [7:0] alarm_second;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                   alarm_second <= 8'd0;
    else if(mgmt_write && mgmt_address == 8'h01)                        alarm_second <= mgmt_writedata[7:0];
    else if(io_write && io_address == 1'b1 && ram_address == 7'h01)     alarm_second <= io_writedata;
end

reg [7:0] alarm_minute;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                   alarm_minute <= 8'd0;
    else if(mgmt_write && mgmt_address == 8'h03)                        alarm_minute <= mgmt_writedata[7:0];
    else if(io_write && io_address == 1'b1 && ram_address == 7'h03)     alarm_minute <= io_writedata;
end

reg [7:0] alarm_hour;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                   alarm_hour <= 8'd0;
    else if(mgmt_write && mgmt_address == 8'h05)                        alarm_hour <= mgmt_writedata[7:0];
    else if(io_write && io_address == 1'b1 && ram_address == 7'h05)     alarm_hour <= io_writedata;
end

wire alarm_interrupt_activate =
    (alarm_second[7:6] == 2'b11 || (rtc_second_update && next_second == alarm_second)) &&
    (alarm_minute[7:6] == 2'b11 || (rtc_minute_update && next_minute == alarm_minute) || (~(rtc_minute_update) && rtc_minute == alarm_minute)) &&
    (alarm_hour[7:6] == 2'b11   || (rtc_hour_update && next_hour == alarm_hour)       || (~(rtc_hour_update)   && rtc_hour == alarm_hour));

reg alarm_interrupt;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                       alarm_interrupt <= 1'b0;
    else if(io_read_valid && io_address == 1'b1 && ram_address == 7'h0C)    alarm_interrupt <= 1'b0;
    else if(sec_state == SEC_SECOND_START && alarm_interrupt_activate)      alarm_interrupt <= 1'b1;
end

//------------------------------------------------------------------------------

/*
crb_freeze 1: no update, no alarm
*/

reg crb_freeze;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                   crb_freeze <= 1'b0;
    else if(mgmt_write && mgmt_address == 8'h0B)                        crb_freeze <= mgmt_writedata[7];
    else if(io_write && io_address == 1'b1 && ram_address == 7'h0B)     crb_freeze <= io_writedata[7];
end

reg crb_int_periodic_ena;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                   crb_int_periodic_ena <= 1'b0;
    else if(mgmt_write && mgmt_address == 8'h0B)                        crb_int_periodic_ena <= mgmt_writedata[6];
    else if(io_write && io_address == 1'b1 && ram_address == 7'h0B)     crb_int_periodic_ena <= io_writedata[6];
end

reg crb_int_alarm_ena;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                   crb_int_alarm_ena <= 1'b0;
    else if(mgmt_write && mgmt_address == 8'h0B)                        crb_int_alarm_ena <= mgmt_writedata[5];
    else if(io_write && io_address == 1'b1 && ram_address == 7'h0B)     crb_int_alarm_ena <= io_writedata[5];
end

reg crb_int_update_ena;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                   crb_int_update_ena <= 1'b0;
    else if(mgmt_write && mgmt_address == 8'h0B)                        crb_int_update_ena <= ~(mgmt_writedata[7]) & mgmt_writedata[4];
    else if(io_write && io_address == 1'b1 && ram_address == 7'h0B)     crb_int_update_ena <= ~(io_writedata[7]) & io_writedata[4];
end

reg crb_binarymode;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                   crb_binarymode <= 1'b0;
    else if(mgmt_write && mgmt_address == 8'h0B)                        crb_binarymode <= mgmt_writedata[2];
    else if(io_write && io_address == 1'b1 && ram_address == 7'h0B)     crb_binarymode <= io_writedata[2];
end

reg crb_24hour;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                   crb_24hour <= 1'b1;
    else if(mgmt_write && mgmt_address == 8'h0B)                        crb_24hour <= mgmt_writedata[1];
    else if(io_write && io_address == 1'b1 && ram_address == 7'h0B)     crb_24hour <= io_writedata[1];
end

reg crb_daylightsaving;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                   crb_daylightsaving <= 1'b0;
    else if(mgmt_write && mgmt_address == 8'h0B)                        crb_daylightsaving <= mgmt_writedata[0];
    else if(io_write && io_address == 1'b1 && ram_address == 7'h0B)     crb_daylightsaving <= io_writedata[0]; 
end

//------------------------------------------------------------------------------

/*
divider 00x : no periodic
divider 11x : no update, no alarm
*/

reg [2:0] divider;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                   divider <= 3'd2;
    else if(mgmt_write && mgmt_address == 8'h0A)                        divider <= mgmt_writedata[6:4];
    else if(io_write && io_address == 1'b1 && ram_address == 7'h0A)     divider <= io_writedata[6:4];
end

reg [3:0] periodic_rate;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                   periodic_rate <= 4'd6;
    else if(mgmt_write && mgmt_address == 8'h0A)                        periodic_rate <= mgmt_writedata[3:0];
    else if(io_write && io_address == 1'b1 && ram_address == 7'h0A)     periodic_rate <= io_writedata[3:0];
end

wire periodic_enabled = divider[2:1] != 2'b00 && periodic_rate != 4'd0;
wire periodic_start   = periodic_enabled && (
                            (periodic_minor == 13'd0 && periodic_major == 13'd0) ||
                            (periodic_minor == 13'd0 && periodic_major == 13'd1));
wire periodic_count   = periodic_enabled && periodic_major >= 13'd1;

wire [12:0] periodic_major_initial = {
    periodic_rate == 4'd15, periodic_rate == 4'd14, periodic_rate == 4'd13, periodic_rate == 4'd12,
    periodic_rate == 4'd11, periodic_rate == 4'd10, periodic_rate == 4'd9 || periodic_rate == 4'd2,  periodic_rate == 4'd8 || periodic_rate == 4'd1,  
    periodic_rate == 4'd7,  periodic_rate == 4'd6,  periodic_rate == 4'd5,  periodic_rate == 4'd4,
    periodic_rate == 4'd3 };

reg [12:0] periodic_minor;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   periodic_minor <= 13'd0;
    else if(~(periodic_enabled))                        periodic_minor <= 13'd0;
    else if(periodic_start)                             periodic_minor <= cycles_in_122us;
    else if(periodic_count && periodic_minor == 13'd0)  periodic_minor <= cycles_in_122us;
    else if(periodic_count)                             periodic_minor <= periodic_minor - 13'd1;
end

reg [12:0] periodic_major;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   periodic_major <= 13'd0;
    else if(~(periodic_enabled))                        periodic_major <= 13'd0;
    else if(periodic_start)                             periodic_major <= periodic_major_initial;
    else if(periodic_count && periodic_minor == 13'd0)  periodic_major <= periodic_major - 13'd1;
end

reg periodic_interrupt;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                               periodic_interrupt <= 1'b0;
    else if(io_read_valid && io_address == 1'b1 && ram_address == 7'h0C)            periodic_interrupt <= 1'b0;
    else if(periodic_enabled && periodic_minor == 13'd0 && periodic_major == 13'd1) periodic_interrupt <= 1'b1;
end

//------------------------------------------------------------------------------

reg [6:0] ram_address;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                       ram_address <= 7'd0;
    else if(io_write && io_address == 1'b0) ram_address <= io_writedata[6:0];
end

//------------------------------------------------------------------------------

wire [7:0] ram_q;

simple_ram #(
    .width      (8),
    .widthad    (7)
)
rtc_ram_inst(
    .clk                (clk),
    
    .wraddress          ((mgmt_write && mgmt_address[7] == 1'b0)?   mgmt_address[6:0] : ram_address),
    .wren               ((mgmt_write && mgmt_address[7] == 1'b0) || (io_write && io_address == 1'b1)),
    .data               ((mgmt_write && mgmt_address[7] == 1'b0)?   mgmt_writedata[7:0] : io_writedata),
    
    .rdaddress          ((io_write && io_address == 1'b0)?  io_writedata[6:0] : ram_address),
    .q                  (ram_q)
);

//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0, mgmt_writedata[31:27], 1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------

endmodule
