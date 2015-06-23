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

module sound_opl2_channel(
    input                   clk,
    input                   rst_n,
    
    input                   write_20h_35h_op1,
    input                   write_40h_55h_op1,
    input                   write_60h_75h_op1,
    input                   write_80h_95h_op1,
    input                   write_E0h_F5h_op1,
    
    input                   write_20h_35h_op2,
    input                   write_40h_55h_op2,
    input                   write_60h_75h_op2,
    input                   write_80h_95h_op2,
    input                   write_E0h_F5h_op2,
    
    input                   write_A0h_A8h,
    input                   write_B0h_B8h,
    input                   write_C0h_C8h,
    
    input           [7:0]   writedata,
    
    input                   vibrato_depth,
    input                   tremolo_depth,
    input                   waveform_select_enable,
    input                   keyboard_split,
    
    input           [6:0]   prepare_cnt,
    
    input                   rythm_enable,
    input                   rythm_write,
    input                   rythm_bass_drum,
    input                   rythm_snare_drum,
    input                   rythm_tom_tom,
    input                   rythm_cymbal,
    input                   rythm_hi_hat,
    
    input                   channel_6,
    input                   channel_7,
    input                   channel_8,
    
    output                  rythm_c1,
    output                  rythm_c3,  
    input                   rythm_phasebit,
    input                   rythm_noisebit,
    
    output reg      [15:0]  chanval
);

//------------------------------------------------------------------------------

reg [9:0] await_f_number;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       await_f_number <= 10'd0;
    else if(write_A0h_A8h)  await_f_number <= { f_number[9:8], writedata };
    else if(write_B0h_B8h)  await_f_number <= { writedata[1:0], f_number[7:0] };
end

//reg await_key_on; write_B0h_B8h; writedata[5]

reg [2:0] await_octave;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       await_octave <= 3'd0;
    else if(write_B0h_B8h)  await_octave <= writedata[4:2];
end

reg [2:0] await_feedback;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       await_feedback <= 3'd0;
    else if(write_C0h_C8h)  await_feedback <= writedata[3:1];
end

reg await_no_modulation;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       await_no_modulation <= 1'b0;
    else if(write_C0h_C8h)  await_no_modulation <= writedata[0];
end

//------------------------------------------------------------------------------

wire prepare_cnt_load_regs = prepare_cnt == 7'd2;

reg [9:0] f_number;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               f_number <= 10'd0;
    else if(prepare_cnt_load_regs)  f_number <= await_f_number;
end

//reg key_on;

reg [2:0] octave;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               octave <= 3'd0;
    else if(prepare_cnt_load_regs)  octave <= await_octave;
end

reg [2:0] feedback;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               feedback <= 3'd0;
    else if(prepare_cnt_load_regs)  feedback <= await_feedback;
end

reg no_modulation;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               no_modulation <= 1'b0;
    else if(prepare_cnt_load_regs)  no_modulation <= await_no_modulation;
end

//------------------------------------------------------------------------------

wire enable_normal_a     = write_B0h_B8h && writedata[5];
wire disable_normal_a    = write_B0h_B8h && ~(writedata[5]);

wire enable_rythm_a      = rythm_write && ((channel_6 &&   rythm_bass_drum)  || (channel_7 &&   rythm_hi_hat)  || (channel_8 &&   rythm_tom_tom));
wire disable_percussion_a= rythm_write && ((channel_6 && ~(rythm_bass_drum)) || (channel_7 && ~(rythm_hi_hat)) || (channel_8 && ~(rythm_tom_tom)));

wire enable_normal_b     = write_B0h_B8h && writedata[5];
wire disable_normal_b    = write_B0h_B8h && ~(writedata[5]);

wire enable_rythm_b      = rythm_write && ((channel_6 &&   rythm_bass_drum)  || (channel_7 &&   rythm_snare_drum)  || (channel_8 &&   rythm_cymbal));
wire disable_percussion_b= rythm_write && ((channel_6 && ~(rythm_bass_drum)) || (channel_7 && ~(rythm_snare_drum)) || (channel_8 && ~(rythm_cymbal)));

//------------------------------------------------------------------------------

wire prepare_cnt_chanval_1 = prepare_cnt == 7'd110;
wire prepare_cnt_chanval_2 = prepare_cnt == 7'd111;

//------------------------------------------------------------------------------

wire [14:0] cval_op_b_times_2 = (cval_op_b[15] == 1'b0 && cval_op_b > 16'h3FFF)? 15'h3FFF : (cval_op_b[15] == 1'b1 && cval_op_b < 16'hC000)? 15'h4000 : cval_op_b[14:0];
wire [14:0] cval_op_a_times_2 = (cval_op_a[15] == 1'b0 && cval_op_a > 16'h3FFF)? 15'h3FFF : (cval_op_a[15] == 1'b1 && cval_op_a < 16'hC000)? 15'h4000 : cval_op_a[14:0];

wire [16:0] cval_op_a_times_2_sum   = chanval + { cval_op_a_times_2, 1'b0 };
wire [15:0] cval_op_a_times_2_final =
    (cval_op_a_times_2_sum[16] == 1'b1 && chanval[15] == 1'b0 && cval_op_a_times_2[14] == 1'b0)?    16'h7FFF :
    (cval_op_a_times_2_sum[16] == 1'b0 && chanval[15] == 1'b1 && cval_op_a_times_2[14] == 1'b1)?    16'h8000 :
                                                                                                    cval_op_a_times_2_sum[15:0];
wire [16:0] cval_op_a_sum   = chanval + cval_op_a;
wire [15:0] cval_op_a_final =
    (cval_op_a_sum[16] == 1'b1 && chanval[15] == 1'b0 && cval_op_a[14] == 1'b0)?    16'h7FFF :
    (cval_op_a_sum[16] == 1'b0 && chanval[15] == 1'b1 && cval_op_a[14] == 1'b1)?    16'h8000 :
                                                                                    cval_op_a_sum[15:0];

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                                                       chanval <= 16'd0;
    
    else if(prepare_cnt_chanval_1 && rythm_enable && channel_6)                                                             chanval <= { cval_op_b_times_2, 1'b0 };
    else if(prepare_cnt_chanval_1 && rythm_enable && (channel_7 || channel_8))                                              chanval <= { cval_op_b_times_2, 1'b0 };
    else if(prepare_cnt_chanval_2 && rythm_enable && (channel_7 || channel_8))                                              chanval <= cval_op_a_times_2_final;
    
    else if(prepare_cnt_chanval_1 && (~(rythm_enable) || (~(channel_6) && ~(channel_7) && ~(channel_8))))                   chanval <= cval_op_b;
    else if(prepare_cnt_chanval_2 && (~(rythm_enable) || (~(channel_6) && ~(channel_7) && ~(channel_8))) && no_modulation)  chanval <= cval_op_a_final;
    
    else if(prepare_cnt_chanval_1)                                                                                          chanval <= 16'd0;
end

wire modulate_with_feedback =
    (rythm_enable && channel_6 && ~(no_modulation)) ||
    (~(rythm_enable) || (~(channel_6) && ~(channel_7) && ~(channel_8)));

wire modulate_op_b =
    (rythm_enable && channel_6 && ~(no_modulation)) ||
    ((~(rythm_enable) || (~(channel_6) && ~(channel_7) && ~(channel_8))) && ~(no_modulation));

wire [15:0] modulator_b = (modulate_op_b)? cval_op_a : 16'd0;

wire [2:0] feedback_a   = (modulate_with_feedback)? feedback : 3'd0;


//------------------------------------------------------------------------------

//6.0 drum bass
//6.1 drum bass
//7.0 hi hat
//7.1 snare
//8.0 tom tom
//8.1 cymbal

//------------------------------------------------------------------------------

wire [16:0] freq_and_octave =
    (octave == 3'd0)?   { 7'd0, f_number } :
    (octave == 3'd1)?   { 6'd0, f_number, 1'd0 } :
    (octave == 3'd2)?   { 5'd0, f_number, 2'd0 } :
    (octave == 3'd3)?   { 4'd0, f_number, 3'd0 } :
    (octave == 3'd4)?   { 3'd0, f_number, 4'd0 } :
    (octave == 3'd5)?   { 2'd0, f_number, 5'd0 } :
    (octave == 3'd6)?   { 1'd0, f_number, 6'd0 } :
                        {       f_number, 7'd0 };

//------------------------------------------------------------------------------

wire wform_decrel_request_a;
wire wform_decrel_request_b;

wire [7:0]  wform_decrel_address_a;
wire [7:0]  wform_decrel_address_b;

wire [15:0] wform_decrel_q_a;
wire [15:0] wform_decrel_q_b;

simple_rom #(
    .widthad    (9),
    .width      (16),
    .datafile   ("./../soc/sound/opl2_waveform_rom.hex")
)
waveform_rom_inst (
    .clk        (clk),
    
    .addr_a     ({ wform_decrel_request_a, wform_decrel_address_a }),
    .addr_b     ({ wform_decrel_request_b, wform_decrel_address_b }),
    .q_a        (wform_decrel_q_a),
    .q_b        (wform_decrel_q_b)
);

//------------------------------------------------------------------------------

wire [7:0] attack_address_a;
wire [7:0] attack_address_b;

wire [19:0] attack_value_a;
wire [19:0] attack_value_b;

simple_rom #(
    .widthad    (8),
    .width      (20),
    .datafile   ("./../soc/sound/opl2_attack_rom.hex")
)
attack_rom_inst (
    .clk        (clk),
    
    .addr_a     (attack_address_a),
    .addr_b     (attack_address_b),
    
    .q_a        (attack_value_a),
    .q_b        (attack_value_b)
);

//------------------------------------------------------------------------------
    
wire [15:0] cval_op_a;
wire [15:0] cval_op_b;

wire rythm_c2;

sound_opl2_operator op1_inst(
    .clk                    (clk),
    .rst_n                  (rst_n),
    
    .write_20h_35h          (write_20h_35h_op1),        //input
    .write_40h_55h          (write_40h_55h_op1),        //input
    .write_60h_75h          (write_60h_75h_op1),        //input
    .write_80h_95h          (write_80h_95h_op1),        //input
    .write_E0h_F5h          (write_E0h_F5h_op1),        //input
    
    .writedata              (writedata),                //input [7:0]
    
    .freq_and_octave        (freq_and_octave),          //input [16:0]
    .freq_high              (f_number[9:6]),            //input [3:0]
    .octave                 (octave),                   //input [2:0]
    .feedback               (feedback_a),               //input [2:0]
   
    .vibrato_depth          (vibrato_depth),            //input
    .tremolo_depth          (tremolo_depth),            //input

    .wform_decrel_request   (wform_decrel_request_a),   //output
    .wform_decrel_address   (wform_decrel_address_a),   //output [7:0]
    .wform_decrel_q         (wform_decrel_q_a),         //input [15:0]
    
    .waveform_select_enable (waveform_select_enable),   //input
    
    .cval                   (cval_op_a),                //output [15:0]
    .keyboard_split         (keyboard_split),           //input

    .attack_address         (attack_address_a),         //output [7:0]
    .attack_value           (attack_value_a),           //input [19:0]
    
    .prepare_cnt            (prepare_cnt),              //input [6:0]
    
    .enable_normal          (enable_normal_a),          //input
    .enable_rythm           (enable_rythm_a),           //input
    .disable_normal         (disable_normal_a),         //input
    .disable_percussion     (disable_percussion_a),     //input
    
    .rythm_c1               (rythm_c1),                 //output
    .rythm_c2               (rythm_c2),                 //output
    /* verilator lint_off PINNOCONNECT */
    .rythm_c3               (),                         //output / not used
    /* verilator lint_on PINNOCONNECT */
    
    .rythm_phasebit         (rythm_phasebit),           //input
    .rythm_noisebit         (rythm_noisebit),           //input
    .rythm_snarebit         (1'b0),                     //input
    
    .rythm_hihat            (channel_7),                //input
    .rythm_snare            (1'b0),                     //input
    .rythm_cymbal           (1'b0),                     //input
    
    .operator_a             (1'b1),                     //input
    .operator_b             (1'b0),                     //input
    
    .modulator              (16'd0)                     //input [15:0]
);

sound_opl2_operator op2_inst(
    .clk                    (clk),
    .rst_n                  (rst_n),
    
    .write_20h_35h          (write_20h_35h_op2),        //input
    .write_40h_55h          (write_40h_55h_op2),        //input
    .write_60h_75h          (write_60h_75h_op2),        //input
    .write_80h_95h          (write_80h_95h_op2),        //input
    .write_E0h_F5h          (write_E0h_F5h_op2),        //input
    
    .writedata              (writedata),                //input [7:0]
   
    .freq_and_octave        (freq_and_octave),          //input [16:0]
    .freq_high              (f_number[9:6]),            //input [3:0]
    .octave                 (octave),                   //input [2:0]
    .feedback               (3'd0),                     //input [2:0]
    
    .vibrato_depth          (vibrato_depth),            //input
    .tremolo_depth          (tremolo_depth),            //input
    
    .wform_decrel_request   (wform_decrel_request_b),   //output
    .wform_decrel_address   (wform_decrel_address_b),   //output [7:0]
    .wform_decrel_q         (wform_decrel_q_b),         //input [15:0]
    
    .waveform_select_enable (waveform_select_enable),   //input
    
    .cval                   (cval_op_b),                //output [15:0]
    .keyboard_split         (keyboard_split),           //input
    
    .attack_address         (attack_address_b),         //output [7:0]
    .attack_value           (attack_value_b),           //input [19:0]
    
    .prepare_cnt            (prepare_cnt),              //input [6:0]
    
    .enable_normal          (enable_normal_b),          //input
    .enable_rythm           (enable_rythm_b),           //input
    .disable_normal         (disable_normal_b),         //input
    .disable_percussion     (disable_percussion_b),     //input
    
    /* verilator lint_off PINNOCONNECT */
    .rythm_c1               (),                         //output / not used
    .rythm_c2               (),                         //output / not used
    /* verilator lint_on PINNOCONNECT */
    .rythm_c3               (rythm_c3),                 //output
    
    .rythm_phasebit         (rythm_phasebit),           //input
    .rythm_noisebit         (rythm_noisebit),           //input
    .rythm_snarebit         (rythm_c2),                 //input
    
    .rythm_hihat            (1'b0),                     //input
    .rythm_snare            (channel_7),                //input
    .rythm_cymbal           (channel_8),                //input
    
    .operator_a             (1'b0),                     //input
    .operator_b             (1'b1),                     //input
    
    .modulator              (modulator_b)               //input [15:0]
);

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

endmodule
