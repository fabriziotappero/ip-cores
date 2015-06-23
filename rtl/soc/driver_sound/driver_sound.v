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

module driver_sound(
    input           clk_12,
    input           rst_n,
    
    //sound interface slave
    input           avs_write,
    input   [31:0]  avs_writedata,
    
    //WM8731 audio codec
    output reg      ac_sclk,
    inout           ac_sdat,
    
    output          ac_xclk,
    output reg      ac_bclk,
    output          ac_dat,
    output reg      ac_lr
);

//------------------------------------------------------------------------------ audio codec output DSP/PCM mode B

assign ac_dat = sample[15];
assign ac_xclk = clk_12;

reg [15:0] sample_next;
always @(posedge clk_12 or negedge rst_n) begin
    if(rst_n == 1'b0)   sample_next <= 16'd0;
    else if(avs_write)  sample_next <= avs_writedata[15:0];
end

reg [6:0] sample_cnt;
always @(posedge clk_12 or negedge rst_n) begin
    if(rst_n == 1'b0)               sample_cnt <= 7'd0;
    else if(~(sound_ready))         sample_cnt <= 7'd0;
    else if(sample_cnt == 7'd124)   sample_cnt <= 7'd0;
    else                            sample_cnt <= sample_cnt + 7'd1;
end

always @(posedge clk_12 or negedge rst_n) begin
    if(rst_n == 1'b0)                                   ac_lr <= 1'b0;
    else if(sample_cnt == 7'd1 || sample_cnt == 7'd2)   ac_lr <= 1'b1;
    else                                                ac_lr <= 1'b0;
end

always @(posedge clk_12 or negedge rst_n) begin
    if(rst_n == 1'b0)                                   ac_bclk <= 1'b0;
    else if(sample_cnt >= 7'd2 && sample_cnt <= 7'd64)  ac_bclk <= ~(ac_bclk);
    else                                                ac_bclk <= 1'b0;
end

reg [15:0] sample;
always @(posedge clk_12 or negedge rst_n) begin
    if(rst_n == 1'b0)                                                           sample <= 16'd0;
    else if(sample_cnt == 7'd1)                                                 sample <= sample_next;
    else if(sample_cnt >= 7'd2 && sample_cnt <= 7'd64 && sample_cnt[0] == 1'b1) sample <= { sample[14:0], sample[15] };
end

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

localparam [3:0] CTRL_IDLE     = 4'd0;
localparam [3:0] CTRL_RESET    = 4'd1;
localparam [3:0] CTRL_POWER    = 4'd2;
localparam [3:0] CTRL_OUTPUT   = 4'd3;
localparam [3:0] CTRL_SIDE     = 4'd4;
localparam [3:0] CTRL_EMPH     = 4'd5;
localparam [3:0] CTRL_FORMAT   = 4'd6;
localparam [3:0] CTRL_SAMPLING = 4'd7;
localparam [3:0] CTRL_ACTIVATE = 4'd8;
localparam [3:0] CTRL_READY    = 4'd9;

reg [3:0]  control_state;

reg        control_start;
reg [15:0] control_data;

wire sound_ready = control_state == CTRL_READY;

always @(posedge clk_12 or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        control_start   <= 1'b0;
        control_data    <= 16'd0;
        control_state   <= CTRL_IDLE;
    end
    else begin
        if(control_state == CTRL_IDLE) begin
            control_start   <= 1'b1;
            control_data    <= 16'b0001111_000000000; //reset
            control_state   <= CTRL_RESET;
        end
        else if(control_state == CTRL_RESET && i2c_ready == 1'b1) begin
            control_start   <= 1'b1;
            control_data    <= 16'b0000110_001100111; // power down unused parts
            control_state   <= CTRL_POWER;
        end
        else if(control_state == CTRL_POWER && i2c_ready == 1'b1) begin
            control_start   <= 1'b1;
            control_data    <= 16'b0000010_101111001; // 0dB headphone output
            control_state   <= CTRL_OUTPUT;
        end
        else if(control_state == CTRL_OUTPUT && i2c_ready == 1'b1) begin
            control_start   <= 1'b1;
            control_data    <= 16'b0000100_011010010; // DAC select
            control_state   <= CTRL_SIDE;
        end
        else if(control_state == CTRL_SIDE && i2c_ready == 1'b1) begin
            control_start   <= 1'b1;
            control_data    <= 16'b0000101_000000101; // disable mute, 41.1kHz de-emphasis
            control_state   <= CTRL_EMPH;
        end
        else if(control_state == CTRL_EMPH && i2c_ready == 1'b1) begin
            control_start   <= 1'b1;
            control_data    <= 16'b0000111_000000011; // DSP mode
            control_state   <= CTRL_FORMAT;
        end
        else if(control_state == CTRL_FORMAT && i2c_ready == 1'b1) begin
            control_start   <= 1'b1;
            control_data    <= 16'b0001000_000011101; // USB mode, 12MHz, 96 kHz
            control_state   <= CTRL_SAMPLING;
        end
        else if(control_state == CTRL_SAMPLING && i2c_ready == 1'b1) begin
            control_start   <= 1'b1;
            control_data    <= 16'b0001001_000000001; //activate
            control_state   <= CTRL_ACTIVATE;
        end
        else if(control_state == CTRL_ACTIVATE && i2c_ready == 1'b1) begin
            control_state   <= CTRL_READY;
        end
        else begin
            control_start <= 1'b0;
        end
    end
end

//------------------------------------------------------------------------------

wire i2c_ready = (i2c_state == S_IDLE && control_start == 1'b0);
assign ac_sdat = (sdat_oe == 1'b0)? 1'bZ : sdat_o;

reg         sdat_oe;
reg         sdat_o;
reg [7:0]   dat_byte;
reg [1:0]   part;
reg [2:0]   counter;
reg [3:0]   i2c_state;

localparam [3:0] S_IDLE     = 4'd0;
localparam [3:0] S_SEND_0   = 4'd1;
localparam [3:0] S_SEND_1   = 4'd2;
localparam [3:0] S_SEND_2   = 4'd3;
localparam [3:0] S_SEND_3   = 4'd4;
localparam [3:0] S_SEND_4   = 4'd5;
localparam [3:0] S_END_0    = 4'd6;
localparam [3:0] S_END_1    = 4'd7;
localparam [3:0] S_END_2    = 4'd8;
    
always @(posedge clk_12 or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        ac_sclk   <= 1'b1;
        sdat_oe   <= 1'b0;
        sdat_o    <= 1'b1;
        dat_byte  <= 8'd0;
        part      <= 2'b0;
        counter   <= 3'd0;
        i2c_state <= S_IDLE;
    end
    else if(i2c_state == S_IDLE && control_start == 1'b1) begin
        // start
        sdat_oe   <= 1'b1;
        sdat_o    <= 1'b0;
        ac_sclk   <= 1'b1;
        
        part      <= 2'b0;
        dat_byte  <= 8'b0011010_0;
        counter   <= 3'd7;
        i2c_state <= S_SEND_0;
    end
    else if(i2c_state == S_SEND_0) begin
        sdat_oe   <= 1'b1;
        sdat_o    <= dat_byte[7];
        ac_sclk   <= 1'b0;
        i2c_state <= S_SEND_1;
    end
    else if(i2c_state == S_SEND_1) begin
        ac_sclk <= 1'b1;
        
        if(counter == 3'd0) i2c_state <= S_SEND_2;
        else begin
            dat_byte  <= { dat_byte[6:0], 1'b0 };
            counter   <= counter - 3'd1; 
            i2c_state <= S_SEND_0;
        end
    end
    else if(i2c_state == S_SEND_2) begin
        sdat_oe   <= 1'b0;
        ac_sclk   <= 1'b0;
        i2c_state <= S_SEND_3;
    end
    else if(i2c_state == S_SEND_3) begin
        ac_sclk   <= 1'b1;
        i2c_state <= S_SEND_4;
    end
    else if(i2c_state == S_SEND_4 && ac_sdat == 1'b0) begin
        ac_sclk   <= 1'b0;
        part      <= part + 2'b1;
        counter   <= 3'd7;
        
        if(part == 2'd0)      dat_byte <= control_data[15:8];
        else if(part == 2'd1) dat_byte <= control_data[7:0];
        
        if(part == 2'd0 || part == 2'd1) i2c_state <= S_SEND_0;
        else                             i2c_state <= S_END_0;
    end
    else if(i2c_state == S_END_0) begin
        sdat_oe   <= 1'b1;
        sdat_o    <= 1'b0;
        ac_sclk   <= 1'b0;
        i2c_state <= S_END_1;
    end
    else if(i2c_state == S_END_1) begin
        ac_sclk   <= 1'b1;
        i2c_state <= S_END_2;
    end
    else if(i2c_state == S_END_2) begin
        // end
        sdat_oe   <= 1'b0;
        i2c_state <= S_IDLE;
    end
end

//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0, avs_writedata[31:16], 1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------

endmodule
