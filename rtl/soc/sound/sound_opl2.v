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

module sound_opl2(
    input               clk,
    input               rst_n,
    
    //sb slave 220h-22Fh
    input       [3:0]   sb_address,
    input               sb_read,
    output      [7:0]   sb_readdata_from_opl2,
    input               sb_write,
    input       [7:0]   sb_writedata,
    
    
    //fm music io slave 388h-389h
    input               fm_address,
    input               fm_read,
    output      [7:0]   fm_readdata,
    input               fm_write,
    input       [7:0]   fm_writedata,
    
    //sample
    output              sample_from_opl2,
    output      [15:0]  sample_from_opl2_value,
    
    //mgmt slave
    /*
    256.[12:0]:  cycles in 80us
    257.[9:0]:   cycles in 1 sample: 96000 Hz
    */
    input       [8:0]   mgmt_address,
    input               mgmt_write,
    input       [31:0]  mgmt_writedata
);

//------------------------------------------------------------------------------

reg [7:0] io_readdata;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   io_readdata <= 8'h06;
    else                io_readdata <= { timer1_overflow | timer2_overflow, timer1_overflow, timer2_overflow, 1'b0, 4'h6 };
end

assign sb_readdata_from_opl2 = io_readdata;
assign fm_readdata           = io_readdata;

//388h reads 06h for OPL2

//------------------------------------------------------------------------------

reg [7:0] index;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                               index <= 8'd0;
    else if((sb_address == 4'd0 || sb_address == 4'd8) && sb_write) index <= sb_writedata;
    else if(fm_address == 1'd0 && fm_write)                         index <= fm_writedata;
end

wire io_write = (((sb_address == 4'd1 || sb_address == 4'd9) && sb_write) || (fm_address == 1'd1 && fm_write));

wire [7:0] io_writedata = (sb_write)? sb_writedata : fm_writedata;

//------------------------------------------------------------------------------ timer 1

reg [7:0] timer1_preset;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   timer1_preset <= 8'd0;
    else if(io_write && index == 8'h02) timer1_preset <= io_writedata;
end

reg timer1_mask;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                           timer1_mask <= 1'd0;
    else if(io_write && index == 8'h04 && ~(io_writedata[7]))   timer1_mask <= io_writedata[6];
end

reg timer1_overflow;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                   timer1_overflow <= 1'b0;
    else if(io_write && index == 8'h04 && io_writedata[7])                              timer1_overflow <= 1'b0;
    else if(io_write && index == 8'h04 && ~(io_writedata[7]) && io_writedata[6])        timer1_overflow <= 1'b0;
    else if(timer1_active && timer1_sub == 13'd0 && timer1 == 8'hFF && ~(timer1_mask))  timer1_overflow <= 1'b1;
end

wire timer1_activate = io_write && index == 8'h04 && ~(io_writedata[7]) && ~(timer1_active) && io_writedata[0];

reg timer1_active;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                   timer1_active <= 1'd0;
    else if(timer1_activate)                                                            timer1_active <= 1'b1;
    else if(io_write && index == 8'h04 && ~(io_writedata[7]) && ~(io_writedata[0]))     timer1_active <= 1'b0;
end

reg [7:0] timer1;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                   timer1 <= 8'd0;
    else if(timer1_activate)                                            timer1 <= timer1_preset;
    else if(timer1_active && timer1_sub == 13'd0 && timer1 == 8'hFF)    timer1 <= timer1_preset;
    else if(timer1_active && timer1_sub == 13'd0)                       timer1 <= timer1 + 8'd1;
end

reg [12:0] timer1_sub;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               timer1_sub <= 13'd0;
    else if(timer1_activate)                        timer1_sub <= period_80us;
    else if(timer1_active && timer1_sub > 13'd0)    timer1_sub <= timer1_sub - 13'd1;
    else if(timer1_active && timer1_sub == 13'd0)   timer1_sub <= period_80us;
end

//------------------------------------------------------------------------------ timer 2

reg [7:0] timer2_preset;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   timer2_preset <= 8'd0;
    else if(io_write && index == 8'h03) timer2_preset <= io_writedata;
end

reg timer2_mask;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                           timer2_mask <= 1'd0;
    else if(io_write && index == 8'h04 && ~(io_writedata[7]))   timer2_mask <= io_writedata[5];
end

reg timer2_overflow;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                   timer2_overflow <= 1'b0;
    else if(io_write && index == 8'h04 && io_writedata[7])                              timer2_overflow <= 1'b0;
    else if(io_write && index == 8'h04 && ~(io_writedata[7]) && io_writedata[5])        timer2_overflow <= 1'b0;
    else if(timer2_active && timer2_sub == 15'd0 && timer2 == 8'hFF && ~(timer2_mask))  timer2_overflow <= 1'b1;
end

wire timer2_activate = io_write && index == 8'h04 && ~(io_writedata[7]) && ~(timer2_active) && io_writedata[1];

reg timer2_active;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                   timer2_active <= 1'd0;
    else if(timer2_activate)                                                            timer2_active <= 1'b1;
    else if(io_write && index == 8'h04 && ~(io_writedata[7]) && ~(io_writedata[1]))     timer2_active <= 1'b0;
end

reg [7:0] timer2;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                   timer2 <= 8'd0;
    else if(timer2_activate)                                            timer2 <= timer2_preset;
    else if(timer2_active && timer2_sub == 15'd0 && timer2 == 8'hFF)    timer2 <= timer2_preset;
    else if(timer2_active && timer2_sub == 15'd0)                       timer2 <= timer2 + 8'd1;
end

reg [14:0] timer2_sub;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               timer2_sub <= 15'd0;
    else if(timer2_activate)                        timer2_sub <= { period_80us, 2'b00 };
    else if(timer2_active && timer2_sub > 15'd0)    timer2_sub <= timer2_sub - 15'd1;
    else if(timer2_active && timer2_sub == 15'd0)   timer2_sub <= { period_80us, 2'b00 };
end

//------------------------------------------------------------------------------ mgmt

reg [12:0] period_80us;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               period_80us <= 13'd2400;
    else if(mgmt_write && mgmt_address == 9'd256)   period_80us <= mgmt_writedata[12:0];
end

reg [9:0] period_sample;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               period_sample <= 10'd347;
    else if(mgmt_write && mgmt_address == 9'd257)   period_sample <= mgmt_writedata[9:0];
end

//------------------------------------------------------------------------------ register write with immediate reaction

reg await_waveform_select_enable;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                       await_waveform_select_enable <= 1'b0;
    else if(io_write && index == 8'h01)     await_waveform_select_enable <= io_writedata[5];
end

//------------------------------------------------------------------------------ register write with delayed reaction

reg await_keyboard_split;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                       await_keyboard_split <= 1'b0;
    else if(io_write && index == 8'h08)     await_keyboard_split <= io_writedata[6];
end

reg await_tremolo_depth;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                       await_tremolo_depth <= 1'b0;
    else if(io_write && index == 8'hBD)     await_tremolo_depth <= io_writedata[7];
end

reg await_vibrato_depth;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                       await_vibrato_depth <= 1'b0;
    else if(io_write && index == 8'hBD)     await_vibrato_depth <= io_writedata[6];
end

reg await_rythm;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                       await_rythm <= 1'b0;
    else if(io_write && index == 8'hBD)     await_rythm <= io_writedata[5];
end

//------------------------------------------------------------------------------

//waveform_select_enable

//composite_sine_wave

//enable_bass_drum
//enable_snare_drum
//enable_tom_tom
//enable_cymbal
//enable_hi_hat

reg keyboard_split;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               keyboard_split <= 1'b0;
    else if(prepare_cnt_load_regs)  keyboard_split <= await_keyboard_split;
end

reg tremolo_depth;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               tremolo_depth <= 1'b0;
    else if(prepare_cnt_load_regs)  tremolo_depth <= await_tremolo_depth;
end

reg vibrato_depth;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               vibrato_depth <= 1'b0;
    else if(prepare_cnt_load_regs)  vibrato_depth <= await_vibrato_depth;
end

reg rythm;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               rythm <= 1'b0;
    else if(prepare_cnt_load_regs)  rythm <= await_rythm;
end

//------------------------------------------------------------------------------

wire prepare_cnt_load_regs = prepare_cnt == 7'd2;

wire prepare_cnt_sample_1 = prepare_cnt == 7'd114;
wire prepare_cnt_sample_2 = prepare_cnt == 7'd115;
wire prepare_cnt_sample_3 = prepare_cnt == 7'd116;
wire prepare_cnt_sample_4 = prepare_cnt == 7'd117;
wire prepare_cnt_sample_5 = prepare_cnt == 7'd118;
wire prepare_cnt_sample_6 = prepare_cnt == 7'd119;
wire prepare_cnt_sample_7 = prepare_cnt == 7'd120;
wire prepare_cnt_sample_8 = prepare_cnt == 7'd121;
wire prepare_cnt_sample_9 = prepare_cnt == 7'd122;

wire prepare_cnt_sample_10= prepare_cnt == 7'd123;
wire prepare_cnt_sample_11= prepare_cnt == 7'd124;

//------------------------------------------------------------------------------

reg [9:0] sample_cnt;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               sample_cnt <= 10'd0;
    else if(sample_cnt == 10'd0)    sample_cnt <= period_sample - 10'd1;
    else                            sample_cnt <= sample_cnt - 10'd1;
end

//------------------------------------------------------------------------------

reg [6:0] prepare_cnt;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               prepare_cnt <= 7'd0;
    else if(sample_cnt == 10'd1)    prepare_cnt <= 7'd1;
    else if(prepare_cnt != 7'd0)    prepare_cnt <= prepare_cnt + 7'd1;
end

reg [22:0] lfsr;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               lfsr <= 23'd1;
    else if(prepare_cnt_load_regs)  lfsr <= { lfsr[22] ^ lfsr[15] ^ lfsr[14] ^ lfsr[0], lfsr[22:1] };
end

//cliping
//wire [15:0] sample_next = (sample[25] == 1'b0 && sample > 26'h0007FFF)? 26'h0007FFF : (sample[25] == 1'b1 && sample < 26'h3FF8000)? 26'h3FF8000 : sample;

wire [15:0] sample_next =
    (sample[25] == 1'b0 && sample[24] == 1'b1)? sample[25:10] :
    (sample[25] == 1'b0 && sample[23] == 1'b1)? sample[24:9] :
    (sample[25] == 1'b0 && sample[22] == 1'b1)? sample[23:8] :
    (sample[25] == 1'b0 && sample[21] == 1'b1)? sample[22:7] :
    (sample[25] == 1'b0 && sample[20] == 1'b1)? sample[21:6] :
    (sample[25] == 1'b0 && sample[19] == 1'b1)? sample[20:5] :
    (sample[25] == 1'b0 && sample[18] == 1'b1)? sample[19:4] :
    (sample[25] == 1'b0 && sample[17] == 1'b1)? sample[18:3] :
    (sample[25] == 1'b0 && sample[16] == 1'b1)? sample[17:2] :
    (sample[25] == 1'b0 && sample[15] == 1'b1)? sample[16:1] :
    (sample[25] == 1'b1 && sample[24] == 1'b0)? sample[25:10] :
    (sample[25] == 1'b1 && sample[23] == 1'b0)? sample[24:9] :
    (sample[25] == 1'b1 && sample[22] == 1'b0)? sample[23:8] :
    (sample[25] == 1'b1 && sample[21] == 1'b0)? sample[22:7] :
    (sample[25] == 1'b1 && sample[20] == 1'b0)? sample[21:6] :
    (sample[25] == 1'b1 && sample[19] == 1'b0)? sample[20:5] :
    (sample[25] == 1'b1 && sample[18] == 1'b0)? sample[19:4] :
    (sample[25] == 1'b1 && sample[17] == 1'b0)? sample[18:3] :
    (sample[25] == 1'b1 && sample[16] == 1'b0)? sample[17:2] :
    (sample[25] == 1'b1 && sample[15] == 1'b0)? sample[16:1] :
                                                sample[15:0];

reg [25:0] sample;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               sample <= 26'd0;
    else if(prepare_cnt_sample_1)   sample <=          { {10{chanval_0[15]}}, chanval_0 };
    else if(prepare_cnt_sample_2)   sample <= sample + { {10{chanval_1[15]}}, chanval_1 };
    else if(prepare_cnt_sample_3)   sample <= sample + { {10{chanval_2[15]}}, chanval_2 };
    else if(prepare_cnt_sample_4)   sample <= sample + { {10{chanval_3[15]}}, chanval_3 };
    else if(prepare_cnt_sample_5)   sample <= sample + { {10{chanval_4[15]}}, chanval_4 };
    else if(prepare_cnt_sample_6)   sample <= sample + { {10{chanval_5[15]}}, chanval_5 };
    else if(prepare_cnt_sample_7)   sample <= sample + { {10{chanval_6[15]}}, chanval_6 };
    else if(prepare_cnt_sample_8)   sample <= sample + { {10{chanval_7[15]}}, chanval_7 };
    else if(prepare_cnt_sample_9)   sample <= sample + { {10{chanval_8[15]}}, chanval_8 };
    
    else if(prepare_cnt_sample_10)  sample <= sample_next;
end

assign sample_from_opl2_value = sample[15:0];
assign sample_from_opl2       = prepare_cnt_sample_11;

//------------------------------------------------------------------------------

wire rythm_c1;
wire rythm_c3;

wire [15:0] chanval_0;
wire [15:0] chanval_1;
wire [15:0] chanval_2;
wire [15:0] chanval_3;
wire [15:0] chanval_4;
wire [15:0] chanval_5;
wire [15:0] chanval_6;
wire [15:0] chanval_7;
wire [15:0] chanval_8;

sound_opl2_channel channel_0_inst(
    .clk                    (clk),
    .rst_n                  (rst_n),
    
    .write_20h_35h_op1      (io_write && index == 8'h20),  //input
    .write_40h_55h_op1      (io_write && index == 8'h40),  //input
    .write_60h_75h_op1      (io_write && index == 8'h60),  //input
    .write_80h_95h_op1      (io_write && index == 8'h80),  //input
    .write_E0h_F5h_op1      (io_write && index == 8'hE0),  //input
    
    .write_20h_35h_op2      (io_write && index == 8'h23),  //input
    .write_40h_55h_op2      (io_write && index == 8'h43),  //input
    .write_60h_75h_op2      (io_write && index == 8'h63),  //input
    .write_80h_95h_op2      (io_write && index == 8'h83),  //input
    .write_E0h_F5h_op2      (io_write && index == 8'hE3),  //input
    
    .write_A0h_A8h          (io_write && index == 8'hA0),  //input
    .write_B0h_B8h          (io_write && index == 8'hB0),  //input
    .write_C0h_C8h          (io_write && index == 8'hC0),  //input
    
    .writedata              (io_writedata),  //input [7:0]
    
    .vibrato_depth          (vibrato_depth),    //input
    .tremolo_depth          (tremolo_depth),    //input
    .waveform_select_enable (await_waveform_select_enable),   //input
    .keyboard_split         (keyboard_split),           //input
    
    .prepare_cnt            (prepare_cnt),  //input [6:0]
    
    .rythm_enable           (1'b0), //input
    .rythm_write            (1'b0), //input
    .rythm_bass_drum        (1'b0), //input
    .rythm_snare_drum       (1'b0), //input
    .rythm_tom_tom          (1'b0), //input
    .rythm_cymbal           (1'b0), //input
    .rythm_hi_hat           (1'b0), //input
    
    .channel_6              (1'b0), //input
    .channel_7              (1'b0), //input
    .channel_8              (1'b0), //input
    
    /* verilator lint_off PINNOCONNECT */
    .rythm_c1               (),     //output / not used
    .rythm_c3               (),     //output / not used
    /* verilator lint_on PINNOCONNECT */
    
    .rythm_phasebit         (1'b0), //input
    .rythm_noisebit         (1'b0), //input
    
    .chanval                (chanval_0)    //output [15:0]
);

sound_opl2_channel channel_1_inst(
    .clk                    (clk),
    .rst_n                  (rst_n),
    
    .write_20h_35h_op1      (io_write && index == 8'h21),  //input
    .write_40h_55h_op1      (io_write && index == 8'h41),  //input
    .write_60h_75h_op1      (io_write && index == 8'h61),  //input
    .write_80h_95h_op1      (io_write && index == 8'h81),  //input
    .write_E0h_F5h_op1      (io_write && index == 8'hE1),  //input
    
    .write_20h_35h_op2      (io_write && index == 8'h24),  //input
    .write_40h_55h_op2      (io_write && index == 8'h44),  //input
    .write_60h_75h_op2      (io_write && index == 8'h64),  //input
    .write_80h_95h_op2      (io_write && index == 8'h84),  //input
    .write_E0h_F5h_op2      (io_write && index == 8'hE4),  //input
    
    .write_A0h_A8h          (io_write && index == 8'hA1),  //input
    .write_B0h_B8h          (io_write && index == 8'hB1),  //input
    .write_C0h_C8h          (io_write && index == 8'hC1),  //input
    
    .writedata              (io_writedata),  //input [7:0]

    .vibrato_depth          (vibrato_depth),    //input
    .tremolo_depth          (tremolo_depth),    //input
    .waveform_select_enable (await_waveform_select_enable),   //input
    .keyboard_split         (keyboard_split),           //input
    
    .prepare_cnt            (prepare_cnt),  //input [6:0]
    
    .rythm_enable           (1'b0), //input
    .rythm_write            (1'b0), //input
    .rythm_bass_drum        (1'b0), //input
    .rythm_snare_drum       (1'b0), //input
    .rythm_tom_tom          (1'b0), //input
    .rythm_cymbal           (1'b0), //input
    .rythm_hi_hat           (1'b0), //input
    
    .channel_6              (1'b0), //input
    .channel_7              (1'b0), //input
    .channel_8              (1'b0), //input
    
    /* verilator lint_off PINNOCONNECT */
    .rythm_c1               (),     //output / not used
    .rythm_c3               (),     //output / not used
    /* verilator lint_on PINNOCONNECT */
    
    .rythm_phasebit         (1'b0), //input
    .rythm_noisebit         (1'b0), //input
    
    .chanval                (chanval_1)   //output [15:0]
);

sound_opl2_channel channel_2_inst(
    .clk                    (clk),
    .rst_n                  (rst_n),
    
    .write_20h_35h_op1      (io_write && index == 8'h22),  //input
    .write_40h_55h_op1      (io_write && index == 8'h42),  //input
    .write_60h_75h_op1      (io_write && index == 8'h62),  //input
    .write_80h_95h_op1      (io_write && index == 8'h82),  //input
    .write_E0h_F5h_op1      (io_write && index == 8'hE2),  //input
    
    .write_20h_35h_op2      (io_write && index == 8'h25),  //input
    .write_40h_55h_op2      (io_write && index == 8'h45),  //input
    .write_60h_75h_op2      (io_write && index == 8'h65),  //input
    .write_80h_95h_op2      (io_write && index == 8'h85),  //input
    .write_E0h_F5h_op2      (io_write && index == 8'hE5),  //input
    
    .write_A0h_A8h          (io_write && index == 8'hA2),  //input
    .write_B0h_B8h          (io_write && index == 8'hB2),  //input
    .write_C0h_C8h          (io_write && index == 8'hC2),  //input
    
    .writedata              (io_writedata),  //input [7:0]
    
    .vibrato_depth          (vibrato_depth),    //input
    .tremolo_depth          (tremolo_depth),    //input
    .waveform_select_enable (await_waveform_select_enable),   //input
    .keyboard_split         (keyboard_split),           //input
    
    .prepare_cnt            (prepare_cnt),  //input [6:0]
    
    .rythm_enable           (1'b0), //input
    .rythm_write            (1'b0), //input
    .rythm_bass_drum        (1'b0), //input
    .rythm_snare_drum       (1'b0), //input
    .rythm_tom_tom          (1'b0), //input
    .rythm_cymbal           (1'b0), //input
    .rythm_hi_hat           (1'b0), //input
    
    .channel_6              (1'b0), //input
    .channel_7              (1'b0), //input
    .channel_8              (1'b0), //input
    
    /* verilator lint_off PINNOCONNECT */
    .rythm_c1               (),     //output / not used
    .rythm_c3               (),     //output / not used
    /* verilator lint_on PINNOCONNECT */
    
    .rythm_phasebit         (1'b0), //input
    .rythm_noisebit         (1'b0), //input
    
    .chanval                (chanval_2)    //output [15:0]
);

sound_opl2_channel channel_3_inst(
    .clk                    (clk),
    .rst_n                  (rst_n),
    
    .write_20h_35h_op1      (io_write && index == 8'h28),  //input
    .write_40h_55h_op1      (io_write && index == 8'h48),  //input
    .write_60h_75h_op1      (io_write && index == 8'h68),  //input
    .write_80h_95h_op1      (io_write && index == 8'h88),  //input
    .write_E0h_F5h_op1      (io_write && index == 8'hE8),  //input
    
    .write_20h_35h_op2      (io_write && index == 8'h2B),  //input
    .write_40h_55h_op2      (io_write && index == 8'h4B),  //input
    .write_60h_75h_op2      (io_write && index == 8'h6B),  //input
    .write_80h_95h_op2      (io_write && index == 8'h8B),  //input
    .write_E0h_F5h_op2      (io_write && index == 8'hEB),  //input
    
    .write_A0h_A8h          (io_write && index == 8'hA3),  //input
    .write_B0h_B8h          (io_write && index == 8'hB3),  //input
    .write_C0h_C8h          (io_write && index == 8'hC3),  //input
    
    .writedata              (io_writedata),  //input [7:0]
    
    .vibrato_depth          (vibrato_depth),    //input
    .tremolo_depth          (tremolo_depth),    //input
    .waveform_select_enable (await_waveform_select_enable),   //input
    .keyboard_split         (keyboard_split),           //input
    
    .prepare_cnt            (prepare_cnt),  //input [6:0]
    
    .rythm_enable           (1'b0), //input
    .rythm_write            (1'b0), //input
    .rythm_bass_drum        (1'b0), //input
    .rythm_snare_drum       (1'b0), //input
    .rythm_tom_tom          (1'b0), //input
    .rythm_cymbal           (1'b0), //input
    .rythm_hi_hat           (1'b0), //input
    
    .channel_6              (1'b0), //input
    .channel_7              (1'b0), //input
    .channel_8              (1'b0), //input
    
    /* verilator lint_off PINNOCONNECT */
    .rythm_c1               (),     //output / not used
    .rythm_c3               (),     //output / not used
    /* verilator lint_on PINNOCONNECT */
    
    .rythm_phasebit         (1'b0), //input
    .rythm_noisebit         (1'b0), //input
    
    .chanval                (chanval_3)    //output [15:0]
);

sound_opl2_channel channel_4_inst(
    .clk                    (clk),
    .rst_n                  (rst_n),
    
    .write_20h_35h_op1      (io_write && index == 8'h29),  //input
    .write_40h_55h_op1      (io_write && index == 8'h49),  //input
    .write_60h_75h_op1      (io_write && index == 8'h69),  //input
    .write_80h_95h_op1      (io_write && index == 8'h89),  //input
    .write_E0h_F5h_op1      (io_write && index == 8'hE9),  //input
    
    .write_20h_35h_op2      (io_write && index == 8'h2C),  //input
    .write_40h_55h_op2      (io_write && index == 8'h4C),  //input
    .write_60h_75h_op2      (io_write && index == 8'h6C),  //input
    .write_80h_95h_op2      (io_write && index == 8'h8C),  //input
    .write_E0h_F5h_op2      (io_write && index == 8'hEC),  //input
    
    .write_A0h_A8h          (io_write && index == 8'hA4),  //input
    .write_B0h_B8h          (io_write && index == 8'hB4),  //input
    .write_C0h_C8h          (io_write && index == 8'hC4),  //input
    
    .writedata              (io_writedata),  //input [7:0]
    
    .vibrato_depth          (vibrato_depth),    //input
    .tremolo_depth          (tremolo_depth),    //input
    .waveform_select_enable (await_waveform_select_enable),   //input
    .keyboard_split         (keyboard_split),           //input
    
    .prepare_cnt            (prepare_cnt),  //input [6:0]
    
    .rythm_enable           (1'b0), //input
    .rythm_write            (1'b0), //input
    .rythm_bass_drum        (1'b0), //input
    .rythm_snare_drum       (1'b0), //input
    .rythm_tom_tom          (1'b0), //input
    .rythm_cymbal           (1'b0), //input
    .rythm_hi_hat           (1'b0), //input
    
    .channel_6              (1'b0), //input
    .channel_7              (1'b0), //input
    .channel_8              (1'b0), //input
    
    /* verilator lint_off PINNOCONNECT */
    .rythm_c1               (),     //output / not used
    .rythm_c3               (),     //output / not used
    /* verilator lint_on PINNOCONNECT */
    
    .rythm_phasebit         (1'b0), //input
    .rythm_noisebit         (1'b0), //input
    
    .chanval                (chanval_4)    //output [15:0]
);

sound_opl2_channel channel_5_inst(
    .clk                    (clk),
    .rst_n                  (rst_n),
    
    .write_20h_35h_op1      (io_write && index == 8'h2A),  //input
    .write_40h_55h_op1      (io_write && index == 8'h4A),  //input
    .write_60h_75h_op1      (io_write && index == 8'h6A),  //input
    .write_80h_95h_op1      (io_write && index == 8'h8A),  //input
    .write_E0h_F5h_op1      (io_write && index == 8'hEA),  //input
    
    .write_20h_35h_op2      (io_write && index == 8'h2D),  //input
    .write_40h_55h_op2      (io_write && index == 8'h4D),  //input
    .write_60h_75h_op2      (io_write && index == 8'h6D),  //input
    .write_80h_95h_op2      (io_write && index == 8'h8D),  //input
    .write_E0h_F5h_op2      (io_write && index == 8'hED),  //input
    
    .write_A0h_A8h          (io_write && index == 8'hA5),  //input
    .write_B0h_B8h          (io_write && index == 8'hB5),  //input
    .write_C0h_C8h          (io_write && index == 8'hC5),  //input
    
    .writedata              (io_writedata),  //input [7:0]
    
    .vibrato_depth          (vibrato_depth),    //input
    .tremolo_depth          (tremolo_depth),    //input
    .waveform_select_enable (await_waveform_select_enable),   //input
    .keyboard_split         (keyboard_split),           //input
    
    .prepare_cnt            (prepare_cnt),  //input [6:0]
    
    .rythm_enable           (1'b0), //input
    .rythm_write            (1'b0), //input
    .rythm_bass_drum        (1'b0), //input
    .rythm_snare_drum       (1'b0), //input
    .rythm_tom_tom          (1'b0), //input
    .rythm_cymbal           (1'b0), //input
    .rythm_hi_hat           (1'b0), //input
    
    .channel_6              (1'b0), //input
    .channel_7              (1'b0), //input
    .channel_8              (1'b0), //input
    
    /* verilator lint_off PINNOCONNECT */
    .rythm_c1               (),     //output / not used
    .rythm_c3               (),     //output / not used
    /* verilator lint_on PINNOCONNECT */
    
    .rythm_phasebit         (1'b0), //input
    .rythm_noisebit         (1'b0), //input
    
    .chanval                (chanval_5)    //output [15:0]
);

sound_opl2_channel channel_6_inst(
    .clk                    (clk),
    .rst_n                  (rst_n),
    
    .write_20h_35h_op1      (io_write && index == 8'h30),  //input
    .write_40h_55h_op1      (io_write && index == 8'h50),  //input
    .write_60h_75h_op1      (io_write && index == 8'h70),  //input
    .write_80h_95h_op1      (io_write && index == 8'h90),  //input
    .write_E0h_F5h_op1      (io_write && index == 8'hF0),  //input
    
    .write_20h_35h_op2      (io_write && index == 8'h33),  //input
    .write_40h_55h_op2      (io_write && index == 8'h53),  //input
    .write_60h_75h_op2      (io_write && index == 8'h73),  //input
    .write_80h_95h_op2      (io_write && index == 8'h93),  //input
    .write_E0h_F5h_op2      (io_write && index == 8'hF3),  //input
    
    .write_A0h_A8h          (io_write && index == 8'hA6),  //input
    .write_B0h_B8h          (io_write && index == 8'hB6),  //input
    .write_C0h_C8h          (io_write && index == 8'hC6),  //input
    
    .writedata              (io_writedata),  //input [7:0]
    
    .vibrato_depth          (vibrato_depth),    //input
    .tremolo_depth          (tremolo_depth),    //input
    .waveform_select_enable (await_waveform_select_enable),   //input
    .keyboard_split         (keyboard_split),           //input
    
    .prepare_cnt            (prepare_cnt),  //input [6:0]
    
    .rythm_enable           (rythm),                                //input
    .rythm_write            (io_write && index == 8'hBD),           //input
    .rythm_bass_drum        (io_writedata[5] && io_writedata[4]),   //input
    .rythm_snare_drum       (1'b0),                                 //input
    .rythm_tom_tom          (1'b0),                                 //input
    .rythm_cymbal           (1'b0),                                 //input
    .rythm_hi_hat           (1'b0),                                 //input
    
    .channel_6              (1'b1), //input
    .channel_7              (1'b0), //input
    .channel_8              (1'b0), //input
    
    /* verilator lint_off PINNOCONNECT */
    .rythm_c1               (),     //output / not used
    .rythm_c3               (),     //output / not used
    /* verilator lint_on PINNOCONNECT */
    
    .rythm_phasebit         (1'b0), //input
    .rythm_noisebit         (1'b0), //input
    
    .chanval                (chanval_6)    //output [15:0]
);

sound_opl2_channel channel_7_inst(
    .clk                    (clk),
    .rst_n                  (rst_n),
    
    .write_20h_35h_op1      (io_write && index == 8'h31),  //input
    .write_40h_55h_op1      (io_write && index == 8'h51),  //input
    .write_60h_75h_op1      (io_write && index == 8'h71),  //input
    .write_80h_95h_op1      (io_write && index == 8'h91),  //input
    .write_E0h_F5h_op1      (io_write && index == 8'hF1),  //input
    
    .write_20h_35h_op2      (io_write && index == 8'h34),  //input
    .write_40h_55h_op2      (io_write && index == 8'h54),  //input
    .write_60h_75h_op2      (io_write && index == 8'h74),  //input
    .write_80h_95h_op2      (io_write && index == 8'h94),  //input
    .write_E0h_F5h_op2      (io_write && index == 8'hF4),  //input
    
    .write_A0h_A8h          (io_write && index == 8'hA7),  //input
    .write_B0h_B8h          (io_write && index == 8'hB7),  //input
    .write_C0h_C8h          (io_write && index == 8'hC7),  //input
    
    .writedata              (io_writedata),  //input [7:0]
    
    .vibrato_depth          (vibrato_depth),    //input
    .tremolo_depth          (tremolo_depth),    //input
    .waveform_select_enable (await_waveform_select_enable),   //input
    .keyboard_split         (keyboard_split),           //input
    
    .prepare_cnt            (prepare_cnt),  //input [6:0]
    
    .rythm_enable           (rythm),                                //input
    .rythm_write            (io_write && index == 8'hBD),           //input
    .rythm_bass_drum        (1'b0),                                 //input
    .rythm_snare_drum       (io_writedata[5] && io_writedata[3]),   //input
    .rythm_tom_tom          (1'b0),                                 //input
    .rythm_cymbal           (1'b0),                                 //input
    .rythm_hi_hat           (io_writedata[5] && io_writedata[0]),   //input
    
    .channel_6              (1'b0), //input
    .channel_7              (1'b1), //input
    .channel_8              (1'b0), //input
    
    .rythm_c1               (rythm_c1),             //output
    /* verilator lint_off PINNOCONNECT */
    .rythm_c3               (),                     //output / not used
    /* verilator lint_on PINNOCONNECT */
    .rythm_phasebit         (rythm_c1 | rythm_c3),  //input
    .rythm_noisebit         (lfsr[22]),             //input
    
    .chanval                (chanval_7)    //output [15:0]
);

sound_opl2_channel channel_8_inst(
    .clk                    (clk),
    .rst_n                  (rst_n),
    
    .write_20h_35h_op1      (io_write && index == 8'h32),  //input
    .write_40h_55h_op1      (io_write && index == 8'h52),  //input
    .write_60h_75h_op1      (io_write && index == 8'h72),  //input
    .write_80h_95h_op1      (io_write && index == 8'h92),  //input
    .write_E0h_F5h_op1      (io_write && index == 8'hF2),  //input
    
    .write_20h_35h_op2      (io_write && index == 8'h35),  //input
    .write_40h_55h_op2      (io_write && index == 8'h55),  //input
    .write_60h_75h_op2      (io_write && index == 8'h75),  //input
    .write_80h_95h_op2      (io_write && index == 8'h95),  //input
    .write_E0h_F5h_op2      (io_write && index == 8'hF5),  //input
    
    .write_A0h_A8h          (io_write && index == 8'hA8),  //input
    .write_B0h_B8h          (io_write && index == 8'hB8),  //input
    .write_C0h_C8h          (io_write && index == 8'hC8),  //input
    
    .writedata              (io_writedata),  //input [7:0]
    
    .vibrato_depth          (vibrato_depth),    //input
    .tremolo_depth          (tremolo_depth),    //input
    .waveform_select_enable (await_waveform_select_enable),   //input
    .keyboard_split         (keyboard_split),           //input
    
    .prepare_cnt            (prepare_cnt),  //input [6:0]
    
    .rythm_enable           (rythm),                                //input
    .rythm_write            (io_write && index == 8'hBD),           //input
    .rythm_bass_drum        (1'b0),                                 //input
    .rythm_snare_drum       (1'b0),                                 //input
    .rythm_tom_tom          (io_writedata[5] && io_writedata[2]),   //input
    .rythm_cymbal           (io_writedata[5] && io_writedata[1]),   //input
    .rythm_hi_hat           (1'b0),                                 //input
    
    .channel_6              (1'b0), //input
    .channel_7              (1'b0), //input
    .channel_8              (1'b1), //input
    
    /* verilator lint_off PINNOCONNECT */
    .rythm_c1               (),                     //output / not used
    /* verilator lint_on PINNOCONNECT */
    .rythm_c3               (rythm_c3),             //output
    .rythm_phasebit         (rythm_c1 | rythm_c3),  //input
    .rythm_noisebit         (1'b0),                 //input
    
    .chanval                (chanval_8)    //output [15:0]
);

//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0, sb_read, fm_read, mgmt_writedata[31:13], 1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------

endmodule
