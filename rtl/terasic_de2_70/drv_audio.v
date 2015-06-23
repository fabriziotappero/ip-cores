/* 
 * Copyright 2010, Aleksander Osman, alfik@poczta.fm. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are
 * permitted provided that the following conditions are met:
 *
 *  1. Redistributions of source code must retain the above copyright notice, this list of
 *     conditions and the following disclaimer.
 *
 *  2. Redistributions in binary form must reproduce the above copyright notice, this list
 *     of conditions and the following disclaimer in the documentation and/or other materials
 *     provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*! \file
 * \brief WM8731 audio codec driver for stereo audio output.
 */

/*! \brief \copybrief drv_audio.v
*/
module drv_audio(
	//% \name Clock and reset
    //% @{
	input       clk_12,
	input       reset_n,
	//% @}
	
	//% \name drv_audio interface
    //% @{
    input [5:0] volume0,
    input [5:0] volume1,
    input [5:0] volume2,
    input [5:0] volume3,
    input [7:0] sample0,
    input [7:0] sample1,
    input [7:0] sample2,
    input [7:0] sample3,
	//% @}
	
	//% \name WM8731 audio codec hardware interface
	//% @{
	output      ac_sclk,
	inout       ac_sdat,
	output      ac_xclk,
	output reg  ac_bclk,
	output      ac_dat,
	output reg  ac_lr
	//% @}
);

//clock domain switch
reg [5:0] volume0a;
reg [5:0] volume1a;
reg [5:0] volume2a;
reg [5:0] volume3a;
reg [7:0] sample0a;
reg [7:0] sample1a;
reg [7:0] sample2a;
reg [7:0] sample3a;

always @(posedge clk_12) begin
    volume0a <= volume0;
    volume1a <= volume1;
    volume2a <= volume2;
    volume3a <= volume3;
    sample0a <= sample0;
    sample1a <= sample1;
    sample2a <= sample2;
    sample3a <= sample3;
end

reg [5:0] volume0f;
reg [5:0] volume1f;
reg [5:0] volume2f;
reg [5:0] volume3f;
reg [7:0] sample0f;
reg [7:0] sample1f;
reg [7:0] sample2f;
reg [7:0] sample3f;

always @(posedge clk_12) begin
    volume0f <= volume0a;
    volume1f <= volume1a;
    volume2f <= volume2a;
    volume3f <= volume3a;
    sample0f <= sample0a;
    sample1f <= sample1a;
    sample2f <= sample2a;
    sample3f <= sample3a;
end


assign ac_dat = left_right_sample[31];
assign ac_xclk = clk_12;

// left MSB-LSB, right MSB-LSB
reg [31:0] left_right_sample;
reg [7:0] data_counter;

wire [13:0] mult_left_1;
assign mult_left_1 =
    ((volume1f[0] == 1'b1)? { {6{sample1f[7]}}, sample1f[7:0] } : 14'd0) +
    ((volume1f[1] == 1'b1)? { {5{sample1f[7]}}, sample1f[7:0], 1'b0 } : 14'd0) +
    ((volume1f[2] == 1'b1)? { {4{sample1f[7]}}, sample1f[7:0], 2'b0 } : 14'd0) +
    ((volume1f[3] == 1'b1)? { {3{sample1f[7]}}, sample1f[7:0], 3'b0 } : 14'd0) +
    ((volume1f[4] == 1'b1)? { {2{sample1f[7]}}, sample1f[7:0], 4'b0 } : 14'd0) +
    ((volume1f[5] == 1'b1)? { {1{sample1f[7]}}, sample1f[7:0], 5'b0 } : 14'd0);

wire [13:0] mult_left_2;
assign mult_left_2 =
    ((volume2f[0] == 1'b1)? { {6{sample2f[7]}}, sample2f[7:0] } : 14'd0) +
    ((volume2f[1] == 1'b1)? { {5{sample2f[7]}}, sample2f[7:0], 1'b0 } : 14'd0) +
    ((volume2f[2] == 1'b1)? { {4{sample2f[7]}}, sample2f[7:0], 2'b0 } : 14'd0) +
    ((volume2f[3] == 1'b1)? { {3{sample2f[7]}}, sample2f[7:0], 3'b0 } : 14'd0) +
    ((volume2f[4] == 1'b1)? { {2{sample2f[7]}}, sample2f[7:0], 4'b0 } : 14'd0) +
    ((volume2f[5] == 1'b1)? { {1{sample2f[7]}}, sample2f[7:0], 5'b0 } : 14'd0);

wire [13:0] mult_right_0;
assign mult_right_0 =
    ((volume0f[0] == 1'b1)? { {6{sample0f[7]}}, sample0f[7:0] } : 14'd0) +
    ((volume0f[1] == 1'b1)? { {5{sample0f[7]}}, sample0f[7:0], 1'b0 } : 14'd0) +
    ((volume0f[2] == 1'b1)? { {4{sample0f[7]}}, sample0f[7:0], 2'b0 } : 14'd0) +
    ((volume0f[3] == 1'b1)? { {3{sample0f[7]}}, sample0f[7:0], 3'b0 } : 14'd0) +
    ((volume0f[4] == 1'b1)? { {2{sample0f[7]}}, sample0f[7:0], 4'b0 } : 14'd0) +
    ((volume0f[5] == 1'b1)? { {1{sample0f[7]}}, sample0f[7:0], 5'b0 } : 14'd0);
    
wire [13:0] mult_right_3;
assign mult_right_3 =
    ((volume3f[0] == 1'b1)? { {6{sample3f[7]}}, sample3f[7:0] } : 14'd0) +
    ((volume3f[1] == 1'b1)? { {5{sample3f[7]}}, sample3f[7:0], 1'b0 } : 14'd0) +
    ((volume3f[2] == 1'b1)? { {4{sample3f[7]}}, sample3f[7:0], 2'b0 } : 14'd0) +
    ((volume3f[3] == 1'b1)? { {3{sample3f[7]}}, sample3f[7:0], 3'b0 } : 14'd0) +
    ((volume3f[4] == 1'b1)? { {2{sample3f[7]}}, sample3f[7:0], 4'b0 } : 14'd0) +
    ((volume3f[5] == 1'b1)? { {1{sample3f[7]}}, sample3f[7:0], 5'b0 } : 14'd0);

wire [14:0] left_channel;
assign left_channel = { mult_left_1[13], mult_left_1 } + { mult_left_2[13], mult_left_2 };

wire [14:0] right_channel;
assign right_channel = { mult_right_0[13], mult_right_0 } + { mult_right_3[13], mult_right_3 };

/* Butterworth second order low-pass filter, cut-off = 3.3 kHz, sampling rate = 48 kHz
    y_n =
            1.4014      y_n1
            -0.5432     y_n2
            0.0354      x_n
            0.0709      x_n1
            0.0354      x_n2
    Coefficients * 2^14:
            1.4014  ->  22961           =   1.01100110110001
            -0.5432 ->  -8900           =  -0.10001011000100
            0.0354  ->  580             =   0.10010001000000
            0.0709  ->  1162            =   0.10010001010000
            0.0354  ->  580             =   0.10010001000000
*/

wire [31:0] lx_n;
assign lx_n = { {3{left_channel[14]}}, left_channel, 14'd0 };

wire [31:0] rx_n;
assign rx_n = { {3{right_channel[14]}}, right_channel, 14'd0 };

reg [31:0] ly_n1;
reg [31:0] ly_n2;
reg [31:0] lx_n1;
reg [31:0] lx_n2;

reg [31:0] ry_n1;
reg [31:0] ry_n2;
reg [31:0] rx_n1;
reg [31:0] rx_n2;

wire [31:0] minus_ly_n2;
assign minus_ly_n2 = -ly_n2;

wire [31:0] ly_n;
assign ly_n = 
    ly_n1 +
    { {2{ly_n1[31]}}, ly_n1[31:2] } +
    { {3{ly_n1[31]}}, ly_n1[31:3] } +
    { {6{ly_n1[31]}}, ly_n1[31:6] } +
    { {7{ly_n1[31]}}, ly_n1[31:7] } +
    { {9{ly_n1[31]}}, ly_n1[31:9] } +
    { {10{ly_n1[31]}}, ly_n1[31:10] } +
    { {14{ly_n1[31]}}, ly_n1[31:14] } +
    
    { {1{minus_ly_n2[31]}}, minus_ly_n2[31:1] } +
    { {5{minus_ly_n2[31]}}, minus_ly_n2[31:5] } +
    { {7{minus_ly_n2[31]}}, minus_ly_n2[31:7] } +
    { {8{minus_ly_n2[31]}}, minus_ly_n2[31:8] } +
    { {13{minus_ly_n2[31]}}, minus_ly_n2[31:13] } +
    { {14{minus_ly_n2[31]}}, minus_ly_n2[31:14] } +
    
    { {5{lx_n[31]}}, lx_n[31:5] } +
    { {8{lx_n[31]}}, lx_n[31:8] } +
    { {12{lx_n[31]}}, lx_n[31:12] } +
    { {14{lx_n[31]}}, lx_n[31:14] } +
    
    { {4{lx_n1[31]}}, lx_n1[31:4] } +
    { {7{lx_n1[31]}}, lx_n1[31:7] } +
    { {11{lx_n1[31]}}, lx_n1[31:11] } +
    { {14{lx_n1[31]}}, lx_n1[31:14] } +
    
    { {5{lx_n2[31]}}, lx_n2[31:5] } +
    { {8{lx_n2[31]}}, lx_n2[31:8] } +
    { {12{lx_n2[31]}}, lx_n2[31:12] } +
    { {14{lx_n2[31]}}, lx_n2[31:14] };

wire [31:0] minus_ry_n2;
assign minus_ry_n2 = -ry_n2;

wire [31:0] ry_n;
assign ry_n = 
    ry_n1 +
    { {2{ry_n1[31]}}, ry_n1[31:2] } +
    { {3{ry_n1[31]}}, ry_n1[31:3] } +
    { {6{ry_n1[31]}}, ry_n1[31:6] } +
    { {7{ry_n1[31]}}, ry_n1[31:7] } +
    { {9{ry_n1[31]}}, ry_n1[31:9] } +
    { {10{ry_n1[31]}}, ry_n1[31:10] } +
    { {14{ry_n1[31]}}, ry_n1[31:14] } +
    
    { {1{minus_ry_n2[31]}}, minus_ry_n2[31:1] } +
    { {5{minus_ry_n2[31]}}, minus_ry_n2[31:5] } +
    { {7{minus_ry_n2[31]}}, minus_ry_n2[31:7] } +
    { {8{minus_ry_n2[31]}}, minus_ry_n2[31:8] } +
    { {13{minus_ry_n2[31]}}, minus_ry_n2[31:13] } +
    { {14{minus_ry_n2[31]}}, minus_ry_n2[31:14] } +
    
    { {5{rx_n[31]}}, rx_n[31:5] } +
    { {8{rx_n[31]}}, rx_n[31:8] } +
    { {12{rx_n[31]}}, rx_n[31:12] } +
    { {14{rx_n[31]}}, rx_n[31:14] } +
    
    { {4{rx_n1[31]}}, rx_n1[31:4] } +
    { {7{rx_n1[31]}}, rx_n1[31:7] } +
    { {11{rx_n1[31]}}, rx_n1[31:11] } +
    { {14{rx_n1[31]}}, rx_n1[31:14] } +
    
    { {5{rx_n2[31]}}, rx_n2[31:5] } +
    { {8{rx_n2[31]}}, rx_n2[31:8] } +
    { {12{rx_n2[31]}}, rx_n2[31:12] } +
    { {14{rx_n2[31]}}, rx_n2[31:14] };

always @(posedge clk_12 or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        data_counter        <= 8'd0;
        left_right_sample   <= 32'd0;
        ac_bclk             <= 1'b0;
        ac_lr               <= 1'b0;

        ly_n1 <= 30'd0;
        ly_n2 <= 30'd0;
        lx_n1 <= 30'd0;
        lx_n2 <= 30'd0;
        ry_n1 <= 30'd0;
        ry_n2 <= 30'd0;
        rx_n1 <= 30'd0;
        rx_n2 <= 30'd0;
    end
    else if(data_counter == 8'd0 && state == S_READY) begin
        data_counter <= data_counter + 8'd1;
        left_right_sample <= { ly_n[29:14],  ry_n[29:14] };
        ac_bclk <= 1'b0;
        ac_lr <= 1'b1;
        
        ly_n1 <= ly_n;
        ly_n2 <= ly_n1;
        lx_n1 <= lx_n;
        lx_n2 <= lx_n1;
        ry_n1 <= ry_n;
        ry_n2 <= ry_n1;
        rx_n1 <= rx_n;
        rx_n2 <= rx_n1;

    end
    else if(data_counter == 8'd1) begin
        data_counter <= data_counter + 8'd1;
        ac_bclk <= 1'b1;
        ac_lr <= 1'b1;
    end
    else if(data_counter >= 8'd127 && data_counter <= 8'd248) begin
        data_counter <= data_counter + 8'd1;
        left_right_sample <= { left_right_sample[30:0], 1'b0 };
        ac_bclk <= 1'b0;
        ac_lr <= 1'b0;
    end
    else if(data_counter == 8'd249) begin
        data_counter <= 8'd0;
        ac_bclk <= 1'b0;
        ac_lr <= 1'b0;
    end
    else if(data_counter[1:0] == 2'b11) begin
        data_counter <= data_counter + 8'd1;
        left_right_sample <= { left_right_sample[30:0], 1'b0 };
        ac_bclk <= 1'b0;
        ac_lr <= 1'b0;
    end
    else if(data_counter[1:0] == 2'b01) begin
        data_counter <= data_counter + 8'd1;
        ac_bclk <= 1'b1;
        ac_lr <= 1'b0;
    end
    else if(data_counter != 8'd0 && state == S_READY) begin
        data_counter <= data_counter + 8'd1;
    end
end

reg i2c_start;
reg [15:0] i2c_data;
reg [3:0] state;

parameter [3:0]
    S_IDLE      = 4'd0,
    S_RESET     = 4'd1,
    S_POWER     = 4'd2,
    S_OUTPUT    = 4'd3,
    S_SIDE      = 4'd4,
    S_EMPH      = 4'd5,
    S_FORMAT    = 4'd6,
    S_SAMPLING  = 4'd7,
    S_ACTIVATE  = 4'd8,
    S_READY     = 4'd9; 

wire i2c_ready;

i2c_send i2c_send_inst(
    .clk_12(clk_12),
    .reset_n(reset_n),
    
    .start(i2c_start),
    .data(i2c_data),
    .ready(i2c_ready),
    
    .sclk(ac_sclk),
    .sdat(ac_sdat)
);

always @(posedge clk_12 or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        i2c_start <= 1'b0;
        i2c_data <= 16'd0;
        state <= S_IDLE;
    end
    else begin
        if(state == S_IDLE) begin
            i2c_start <= 1'b1;
            i2c_data <= 16'b0001111_000000000;
            state <= S_RESET;
        end
        else if(state == S_RESET && i2c_ready == 1'b1) begin
            i2c_start <= 1'b1;
            i2c_data <= 16'b0000110_001100111; // power down unused parts
            state <= S_POWER;
        end
        else if(state == S_POWER && i2c_ready == 1'b1) begin
            i2c_start <= 1'b1;
            i2c_data <= 16'b0000010_101111001; // 0dB headphone output
            state <= S_OUTPUT;
        end
        else if(state == S_OUTPUT && i2c_ready == 1'b1) begin
            i2c_start <= 1'b1;
            i2c_data <= 16'b0000100_011010010; // DAC select
            state <= S_SIDE;
        end
        else if(state == S_SIDE && i2c_ready == 1'b1) begin
            i2c_start <= 1'b1;
            i2c_data <= 16'b0000101_000000011; // disable mute, 32kHz de-emphasis
            state <= S_EMPH;
        end
        else if(state == S_EMPH && i2c_ready == 1'b1) begin
            i2c_start <= 1'b1;
            i2c_data <= 16'b0000111_000000011; // DSP mode
            state <= S_FORMAT;
        end
        else if(state == S_FORMAT && i2c_ready == 1'b1) begin
            i2c_start <= 1'b1;
            i2c_data <= 16'b0001000_000000001; // USB mode, 12MHz, 48 kHz
            state <= S_SAMPLING;
        end
        else if(state == S_SAMPLING && i2c_ready == 1'b1) begin
            i2c_start <= 1'b1;
            i2c_data <= 16'b0001001_000000001;
            state <= S_ACTIVATE;
        end
        else if(state == S_ACTIVATE && i2c_ready == 1'b1) begin
            state <= S_READY;
        end
        else begin
            i2c_start <= 1'b0;
        end
    end
end

endmodule

/*! \brief I2C write helper module.
 */
module i2c_send(
    input clk_12,
    input reset_n,
    
    input start,
    input [15:0] data,
    output ready,
    
    output reg sclk,
    inout sdat
);

assign ready = (state == S_IDLE && start == 1'b0);
assign sdat = (sdat_oe == 1'b0)? 1'bZ : sdat_o;

reg sdat_oe;
reg sdat_o;
reg [7:0] dat_byte;
reg [1:0] part;
reg [2:0] counter;
reg [3:0] state;
parameter [3:0]
    S_IDLE      = 4'd0,
    S_SEND_0    = 4'd1,
    S_SEND_1    = 4'd2,
    S_SEND_2    = 4'd3,
    S_SEND_3    = 4'd4,
    S_SEND_4    = 4'd5,
    S_END_0     = 4'd6,
    S_END_1     = 4'd7,
    S_END_2     = 4'd8;
    
always @(posedge clk_12 or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        sclk <= 1'b1;
        sdat_oe <= 1'b0;
        sdat_o <= 1'b1;
        dat_byte <= 8'd0;
        part <= 2'b0;
        counter <= 3'd0;
        state <= S_IDLE;
    end
    else if(state == S_IDLE && start == 1'b1) begin
        // start
        sdat_oe <= 1'b1;
        sdat_o <= 1'b0;
        sclk <= 1'b1;
        
        part <= 2'b0;
        dat_byte <= 8'b0011010_0;
        counter <= 3'd7;
        state <= S_SEND_0;
    end
    else if(state == S_SEND_0) begin
        sdat_oe <= 1'b1;
        sdat_o <= dat_byte[7];
        sclk <= 1'b0;
        state <= S_SEND_1;
    end
    else if(state == S_SEND_1) begin
        sclk <= 1'b1;
        
        if(counter == 3'd0) state <= S_SEND_2;
        else begin
            dat_byte <= { dat_byte[6:0], 1'b0 };
            counter <= counter - 3'd1; 
            state <= S_SEND_0;
        end
    end
    else if(state == S_SEND_2) begin
        sdat_oe <= 1'b0;
        sclk <= 1'b0;
        state <= S_SEND_3;
    end
    else if(state == S_SEND_3) begin
        sclk <= 1'b1;
        state <= S_SEND_4;
    end
    else if(state == S_SEND_4 && sdat == 1'b0) begin
        sclk <= 1'b0;
        part <= part + 2'b1;
        counter <= 3'd7;
        
        if(part == 2'd0)        dat_byte <= data[15:8];
        else if(part == 2'd1)   dat_byte <= data[7:0];
        
        if(part == 2'd0 || part == 2'd1)    state <= S_SEND_0;
        else                                state <= S_END_0;
    end
    else if(state == S_END_0) begin
        sdat_oe <= 1'b1;
        sdat_o <= 1'b0;
        sclk <= 1'b0;
        state <= S_END_1;
    end
    else if(state == S_END_1) begin
        sclk <= 1'b1;
        state <= S_END_2;
    end
    else if(state == S_END_2) begin
        // end
        sdat_oe <= 1'b0;
        state <= S_IDLE;
    end
end

endmodule
