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

module sound_opl2_operator(
    input                   clk,
    input                   rst_n,
    
    input                   write_20h_35h,
    input                   write_40h_55h,
    input                   write_60h_75h,
    input                   write_80h_95h,
    input                   write_E0h_F5h,
    
    input           [7:0]   writedata,
    
    input           [16:0]  freq_and_octave,
    input           [3:0]   freq_high,
    input           [2:0]   octave,
    input           [2:0]   feedback,
    
    input                   vibrato_depth,
    input                   tremolo_depth,
    
    output                  wform_decrel_request,
    output          [7:0]   wform_decrel_address,
    input           [15:0]  wform_decrel_q,
    
    input                   waveform_select_enable,
    
    output reg      [15:0]  cval,
    input                   keyboard_split,
    
    output          [7:0]   attack_address,
    input           [19:0]  attack_value,
    
    input           [6:0]   prepare_cnt,
    
    input                   enable_normal,
    input                   enable_rythm,
    input                   disable_normal,
    input                   disable_percussion,
    
    output                  rythm_c1,
    output                  rythm_c2,
    output                  rythm_c3,
    
    input                   rythm_phasebit,
    input                   rythm_noisebit,
    input                   rythm_snarebit,
    
    //rythm_bassdrum, rythm_hihat, rythm_snare, rythm_tomtom, rythm_cymbal
    input                   rythm_hihat,
    input                   rythm_snare,
    input                   rythm_cymbal,
    
    input                   operator_a,
    input                   operator_b,

    input           [15:0]  modulator
);

//------------------------------------------------------------------------------ write awaiting

reg await_tremolo;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       await_tremolo <= 1'b0;
    else if(write_20h_35h)  await_tremolo <= writedata[7];
end

reg await_vibrato;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       await_vibrato <= 1'b0;
    else if(write_20h_35h)  await_vibrato <= writedata[6];
end

reg await_eg_type;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       await_eg_type <= 1'b1;
    else if(write_20h_35h)  await_eg_type <= writedata[5];
end

reg await_keyboard_scaling_rate;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       await_keyboard_scaling_rate <= 1'b0;
    else if(write_20h_35h)  await_keyboard_scaling_rate <= writedata[4];
end

reg [3:0] await_freq_multi;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       await_freq_multi <= 4'd0;
    else if(write_20h_35h)  await_freq_multi <= writedata[3:0];
end

reg [1:0] await_keyboard_scaling_level;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       await_keyboard_scaling_level <= 2'd0;
    else if(write_40h_55h)  await_keyboard_scaling_level <= writedata[7:6];
end

reg [5:0] await_total_level;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       await_total_level <= 6'd0;
    else if(write_40h_55h)  await_total_level <= writedata[5:0];
end

reg [3:0] await_attack_rate;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       await_attack_rate <= 4'd0;
    else if(write_60h_75h)  await_attack_rate <= writedata[7:4];
end

reg [3:0] await_decay_rate;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       await_decay_rate <= 4'd0;
    else if(write_60h_75h)  await_decay_rate <= writedata[3:0];
end

reg [3:0] await_sustain_level;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       await_sustain_level <= 4'd0;
    else if(write_80h_95h)  await_sustain_level <= writedata[7:4];
end

reg [3:0] await_release_rate;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       await_release_rate <= 4'd0;
    else if(write_80h_95h)  await_release_rate <= writedata[3:0];
end

reg [1:0] await_wave_select;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       await_wave_select <= 2'd0;
    else if(write_E0h_F5h)  await_wave_select <= writedata[1:0];
end

//------------------------------------------------------------------------------

wire prepare_cnt_load_regs      = prepare_cnt == 7'd2;

wire prepare_cnt_freq_1         = prepare_cnt == 7'd3;
wire prepare_cnt_freq_2         = prepare_cnt == 7'd4;
wire prepare_cnt_freq_3         = prepare_cnt == 7'd5;
wire prepare_cnt_freq_4         = prepare_cnt == 7'd6;
wire prepare_cnt_freq_5         = prepare_cnt == 7'd7;
wire prepare_cnt_freq_6         = prepare_cnt == 7'd8;

wire prepare_cnt_chg_release_1  = prepare_cnt == 7'd9;
wire prepare_cnt_chg_release_2  = prepare_cnt == 7'd10;

wire prepare_cnt_chg_decay_1    = prepare_cnt == 7'd11;
wire prepare_cnt_chg_decay_2    = prepare_cnt == 7'd12;

wire prepare_cnt_chg_attack_1   = prepare_cnt == 7'd13;

wire prepare_cnt_chg_enable_1   = prepare_cnt == 7'd14;
wire prepare_cnt_chg_enable_2   = prepare_cnt == 7'd15;

//

wire prepare_cnt_vibrato_1  = prepare_cnt == 7'd24;
wire prepare_cnt_vibrato_2  = prepare_cnt == 7'd25;
wire prepare_cnt_vibrato_3  = prepare_cnt == 7'd26;
wire prepare_cnt_vibrato_4  = prepare_cnt == 7'd27;
wire prepare_cnt_vibrato_5  = prepare_cnt == 7'd28;
wire prepare_cnt_vibrato_6  = prepare_cnt == 7'd29;
wire prepare_cnt_vibrato_7  = prepare_cnt == 7'd30;
wire prepare_cnt_vibrato_8  = prepare_cnt == 7'd31;
wire prepare_cnt_vibrato_9  = prepare_cnt == 7'd32;
wire prepare_cnt_vibrato_10 = prepare_cnt == 7'd33;
wire prepare_cnt_vibrato_11 = prepare_cnt == 7'd34;

wire prepare_cnt_tcount_1   = prepare_cnt == 7'd35;
wire prepare_cnt_tcount_2   = prepare_cnt == 7'd36;
wire prepare_cnt_tcount_3   = prepare_cnt == 7'd37;
//update wfpos, tcount, generator_pos, env_step

wire prepare_cnt_attack_1  = prepare_cnt == 7'd42 && state == S_ATTACK;
//wire prepare_cnt_attack_2  = prepare_cnt == 7'd43 && state == S_ATTACK;
//wire prepare_cnt_attack_3  = prepare_cnt == 7'd44 && state == S_ATTACK;
wire prepare_cnt_attack_4  = prepare_cnt == 7'd45 && state == S_ATTACK;
//wire prepare_cnt_attack_5  = prepare_cnt == 7'd46 && state == S_ATTACK;
//wire prepare_cnt_attack_6  = prepare_cnt == 7'd47 && state == S_ATTACK;
wire prepare_cnt_attack_7  = prepare_cnt == 7'd48 && state == S_ATTACK;
//wire prepare_cnt_attack_8  = prepare_cnt == 7'd49 && state == S_ATTACK;
//wire prepare_cnt_attack_9  = prepare_cnt == 7'd50 && state == S_ATTACK;
wire prepare_cnt_attack_10 = prepare_cnt == 7'd51 && state == S_ATTACK;
//wire prepare_cnt_attack_11 = prepare_cnt == 7'd52 && state == S_ATTACK;
//wire prepare_cnt_attack_12 = prepare_cnt == 7'd53 && state == S_ATTACK;
wire prepare_cnt_attack_13 = prepare_cnt == 7'd54 && state == S_ATTACK;
wire prepare_cnt_attack_14 = prepare_cnt == 7'd55 && state == S_ATTACK;
//wire prepare_cnt_attack_15 = prepare_cnt == 7'd56 && state == S_ATTACK;
//wire prepare_cnt_attack_16 = prepare_cnt == 7'd57 && state == S_ATTACK;
wire prepare_cnt_attack_17 = prepare_cnt == 7'd58 && state == S_ATTACK;
wire prepare_cnt_attack_18 = prepare_cnt == 7'd59 && state == S_ATTACK;
wire prepare_cnt_attack_19 = prepare_cnt == 7'd60 && state == S_ATTACK;
//wire prepare_cnt_attack_20 = prepare_cnt == 7'd61 && state == S_ATTACK;
//wire prepare_cnt_attack_21 = prepare_cnt == 7'd62 && state == S_ATTACK;
wire prepare_cnt_attack_22 = prepare_cnt == 7'd63 && state == S_ATTACK;
wire prepare_cnt_attack_23 = prepare_cnt == 7'd64 && state == S_ATTACK;
wire prepare_cnt_attack_24 = prepare_cnt == 7'd65 && state == S_ATTACK;
wire prepare_cnt_attack_25 = prepare_cnt == 7'd66 && state == S_ATTACK;
wire prepare_cnt_attack_26 = prepare_cnt == 7'd67 && state == S_ATTACK;
wire prepare_cnt_attack_27 = prepare_cnt == 7'd68 && state == S_ATTACK;
wire prepare_cnt_attack_28 = prepare_cnt == 7'd69 && state == S_ATTACK;
wire prepare_cnt_attack_29 = prepare_cnt == 7'd70 && state == S_ATTACK;
wire prepare_cnt_attack_30 = prepare_cnt == 7'd71 && state == S_ATTACK;

wire prepare_cnt_decay_1   = prepare_cnt == 7'd42 && state == S_DECAY;
//wire prepare_cnt_decay_2   = prepare_cnt == 7'd43 && state == S_DECAY;
//wire prepare_cnt_decay_3   = prepare_cnt == 7'd44 && state == S_DECAY;
wire prepare_cnt_decay_4   = prepare_cnt == 7'd45 && state == S_DECAY;
wire prepare_cnt_decay_5   = prepare_cnt == 7'd46 && state == S_DECAY;

wire prepare_cnt_release_1 = prepare_cnt == 7'd42 && (state == S_RELEASE || state == S_SUSTAIN_NOKEEP);
//wire prepare_cnt_release_2 = prepare_cnt == 7'd43 && (state == S_RELEASE || state == S_SUSTAIN_NOKEEP);
//wire prepare_cnt_release_3 = prepare_cnt == 7'd44 && (state == S_RELEASE || state == S_SUSTAIN_NOKEEP);
wire prepare_cnt_release_4 = prepare_cnt == 7'd45 && (state == S_RELEASE || state == S_SUSTAIN_NOKEEP);
wire prepare_cnt_release_5 = prepare_cnt == 7'd46 && (state == S_RELEASE || state == S_SUSTAIN_NOKEEP);

wire prepare_cnt_output_1  = (prepare_cnt == 7'd74 && operator_a) || (prepare_cnt == 7'd94 && operator_b);
wire prepare_cnt_output_2  = (prepare_cnt == 7'd75 && operator_a) || (prepare_cnt == 7'd95 && operator_b);
wire prepare_cnt_output_3  = (prepare_cnt == 7'd76 && operator_a) || (prepare_cnt == 7'd96 && operator_b);
wire prepare_cnt_output_4  = (prepare_cnt == 7'd77 && operator_a) || (prepare_cnt == 7'd97 && operator_b);
wire prepare_cnt_output_5  = (prepare_cnt == 7'd78 && operator_a) || (prepare_cnt == 7'd98 && operator_b);
//wire prepare_cnt_output_6  = (prepare_cnt == 7'd79 && operator_a) || (prepare_cnt == 7'd99 && operator_b);
//wire prepare_cnt_output_7  = (prepare_cnt == 7'd80 && operator_a) || (prepare_cnt == 7'd100 && operator_b);
wire prepare_cnt_output_8  = (prepare_cnt == 7'd81 && operator_a) || (prepare_cnt == 7'd101 && operator_b);
//wire prepare_cnt_output_9  = (prepare_cnt == 7'd82 && operator_a) || (prepare_cnt == 7'd102 && operator_b);
//wire prepare_cnt_output_10 = (prepare_cnt == 7'd83 && operator_a) || (prepare_cnt == 7'd103 && operator_b);
wire prepare_cnt_output_11 = (prepare_cnt == 7'd84 && operator_a) || (prepare_cnt == 7'd104 && operator_b);
//wire prepare_cnt_output_12 = (prepare_cnt == 7'd85 && operator_a) || (prepare_cnt == 7'd105 && operator_b);
wire prepare_cnt_output_13 = (prepare_cnt == 7'd86 && operator_a) || (prepare_cnt == 7'd106 && operator_b);
wire prepare_cnt_output_14 = (prepare_cnt == 7'd87 && operator_a) || (prepare_cnt == 7'd107 && operator_b);
wire prepare_cnt_output_15 = (prepare_cnt == 7'd88 && operator_a) || (prepare_cnt == 7'd108 && operator_b);


/*

ARC_TVS_KSR_MUL:
    change_keepsustain:     op_state, sus_keep (op_state, sus_keep)
    change_vibrato:         vibrato*, tremolo*
    change_frequency:       toff, tinc, vol, freq_high & 
    
ARC_KSL_OUTLEV:
    change_frequency
    
ARC_ATTR_DECR:
    change_attackrate:      a0,a1,a2,a3, env_step_a, env_step_skip_a (attackrate, toff)
    change_decayrate:       decaymul, env_step_d (decayrate, toff)
    
ARC_SUSL_RELR:
    change_releaserate:     releasemul, env_step_r (releaserate, toff)
    change_sustainlevel:    sustain_level
    
ARC_FREQ_NUM:
    change_frequency op1
    change_frequency op2
    
ARC_KON_BNUM:
    enable_operator op1   / disable_operator op1 / enable_operator op1  / disable_operator op1
    change_frequency op1  / disable_operator op2 / enable_operator op2  / disable_operator op2
    enable_operator op2   /                      / change_frequency op1 / change_frequency op1
    change_frequency op2  /                      / change_frequency op2 / change_frequency op2
    
enable_operator:            tcount, op_state, act_state (act_state, wave_sel)
disable_operator:           op_state, act_state
    
ARC_FEEDBACK:
    change_feedback:        mfbi
    
ARC_WAVE_SEL:
    change_waveform:        cur_wmask, cur_wform (wave_sel)

*/


reg tremolo;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               tremolo <= 1'b0;
    else if(prepare_cnt_load_regs)  tremolo <= await_tremolo;
end

reg vibrato;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               vibrato <= 1'b0;
    else if(prepare_cnt_load_regs)  vibrato <= await_vibrato;
end

reg eg_type;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               eg_type <= 1'b1;
    else if(prepare_cnt_load_regs)  eg_type <= await_eg_type;
end

reg keyboard_scaling_rate;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               keyboard_scaling_rate <= 1'b0;
    else if(prepare_cnt_load_regs)  keyboard_scaling_rate <= await_keyboard_scaling_rate;
end

reg [3:0] freq_multi;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               freq_multi <= 4'd0;
    else if(prepare_cnt_load_regs)  freq_multi <= await_freq_multi;
end

reg [1:0] keyboard_scaling_level;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               keyboard_scaling_level <= 2'd0;
    else if(prepare_cnt_load_regs)  keyboard_scaling_level <= await_keyboard_scaling_level;
end

reg [5:0] total_level;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               total_level <= 6'd0;
    else if(prepare_cnt_load_regs)  total_level <= await_total_level;
end

reg [3:0] attack_rate;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               attack_rate <= 4'd0;
    else if(prepare_cnt_load_regs)  attack_rate <= await_attack_rate;
end

reg [3:0] decay_rate;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               decay_rate <= 4'd0;
    else if(prepare_cnt_load_regs)  decay_rate <= await_decay_rate;
end

reg [3:0] sustain_level;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               sustain_level <= 4'd0;
    else if(prepare_cnt_load_regs)  sustain_level <= await_sustain_level;
end

reg [3:0] release_rate;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               release_rate <= 4'd0;
    else if(prepare_cnt_load_regs)  release_rate <= await_release_rate;
end

reg [1:0] wave_select;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                           wave_select <= 2'd0;
    else if(prepare_cnt_load_regs && waveform_select_enable)    wave_select <= await_wave_select;
end

//------------------------------------------------------------------------------ change_frequency

wire [3:0] freq_multi_final =
    (freq_multi == 4'd11)?  4'd10 :
    (freq_multi == 4'd13)?  4'd12 :
    (freq_multi == 4'd14)?  4'd15 :
                            freq_multi;

// f_INT * fixedpoint / (N * f_s)
// f_INT = 49715,903 Hz
// fixedpoint = 32'h00010000
// N = 1024
// f_s = 96000 Hz

// freq_multi * (32+1) * freq_and_octave

reg [22:0] tinc_prepare;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)          tinc_prepare <= 23'd0;
    else if(prepare_cnt_freq_1) tinc_prepare <= { 5'd0, freq_and_octave } + { freq_and_octave, 5'd0 }; //(32+1) * freq_and_octave
end

reg [25:0] tinc;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                       tinc <= 26'd0;
    else if(prepare_cnt_freq_1)                                              tinc <= 26'd0;
    else if(prepare_cnt_freq_2 && freq_multi == 4'd0)                        tinc <= {  4'd0, tinc_prepare[22:1] }; // div2
    else if(prepare_cnt_freq_2 && freq_multi != 4'd0 && freq_multi_final[0]) tinc <= tinc + { 3'd0, tinc_prepare };
    else if(prepare_cnt_freq_3 && freq_multi != 4'd0 && freq_multi_final[1]) tinc <= tinc + { 2'd0, tinc_prepare, 1'd0 };
    else if(prepare_cnt_freq_4 && freq_multi != 4'd0 && freq_multi_final[2]) tinc <= tinc + { 1'd0, tinc_prepare, 2'd0 };
    else if(prepare_cnt_freq_5 && freq_multi != 4'd0 && freq_multi_final[3]) tinc <= tinc + {       tinc_prepare, 3'd0 };
end

wire [3:0] toff_next =
    (~(keyboard_scaling_rate))? { 2'b0, octave[2:1] } : { octave, (freq_high[3] & ~(keyboard_split)) | (freq_high[2] & keyboard_split) };

reg [3:0] toff;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)          toff <= 4'd0;
    else if(prepare_cnt_freq_6) toff <= toff_next;
end

wire [5:0] kslev_prepare =
    (freq_high == 4'd15)?     6'd56 :
    (freq_high == 4'd14)?     6'd55 :
    (freq_high == 4'd13)?     6'd54 :
    (freq_high == 4'd12)?     6'd53 :
    (freq_high == 4'd11)?     6'd52 :
    (freq_high == 4'd10)?     6'd51 :
    (freq_high == 4'd9)?      6'd50 :
    (freq_high == 4'd8)?      6'd48 :
    (freq_high == 4'd7)?      6'd47 :
    (freq_high == 4'd6)?      6'd45 :
    (freq_high == 4'd5)?      6'd43 :
    (freq_high == 4'd4)?      6'd40 :
    (freq_high == 4'd3)?      6'd37 :
    (freq_high == 4'd2)?      6'd32 :
    (freq_high == 4'd1)?      6'd24 :
                              6'd0;

wire [2:0] kslev_oct = 3'd7 - octave;
wire [5:0] kslev_sub = { kslev_oct, 3'b0 };

wire [5:0] kslev = (kslev_sub > kslev_prepare)? 6'd0 : kslev_prepare - kslev_sub;

//total_level[5:0]
//keyboard_scaling_level[1:0]

wire [7:0] kslev_mult =
    (keyboard_scaling_level == 2'd0)?   8'd0 :
    (keyboard_scaling_level == 2'd1)?   { 1'd0, kslev, 1'd0 } :
    (keyboard_scaling_level == 2'd2)?   { 2'd0, kslev } :
                                        {       kslev, 2'd0 };

reg [8:0] volume_in;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           volume_in <= 9'd0;
    else if(prepare_cnt_freq_1)  volume_in <= { 1'b0, kslev_mult };
    else if(prepare_cnt_freq_2)  volume_in <= volume_in + { 1'b0, total_level, 2'd0 };
end

wire [16:0] volume_prepare =
    (volume_in[4:0] == 5'd0)?   { 1'b1, 16'h0000 } :
    (volume_in[4:0] == 5'd1)?   { 1'b0, 16'hFA83 } : //2^{-1/32}
    (volume_in[4:0] == 5'd2)?   { 1'b0, 16'hF525 } : //2^{-2/32}
    (volume_in[4:0] == 5'd3)?   { 1'b0, 16'hEFE4 } : //2^{-3/32}
    (volume_in[4:0] == 5'd4)?   { 1'b0, 16'hEAC0 } : //2^{-4/32}
    (volume_in[4:0] == 5'd5)?   { 1'b0, 16'hE5B9 } : //2^{-5/32}
    (volume_in[4:0] == 5'd6)?   { 1'b0, 16'hE0CC } : //2^{-6/32}
    (volume_in[4:0] == 5'd7)?   { 1'b0, 16'hDBFB } : //2^{-7/32}
    (volume_in[4:0] == 5'd8)?   { 1'b0, 16'hD744 } : //2^{-8/32}
    (volume_in[4:0] == 5'd9)?   { 1'b0, 16'hD2A8 } : //2^{-9/32}
    (volume_in[4:0] == 5'd10)?  { 1'b0, 16'hCE24 } : //2^{-10/32}
    (volume_in[4:0] == 5'd11)?  { 1'b0, 16'hC9B9 } : //2^{-11/32}
    (volume_in[4:0] == 5'd12)?  { 1'b0, 16'hC567 } : //2^{-12/32}
    (volume_in[4:0] == 5'd13)?  { 1'b0, 16'hC12C } : //2^{-13/32}
    (volume_in[4:0] == 5'd14)?  { 1'b0, 16'hBD08 } : //2^{-14/32}
    (volume_in[4:0] == 5'd15)?  { 1'b0, 16'hB8FB } : //2^{-15/32}
    (volume_in[4:0] == 5'd16)?  { 1'b0, 16'hB504 } : //2^{-16/32}
    (volume_in[4:0] == 5'd17)?  { 1'b0, 16'hB123 } : //2^{-17/32}
    (volume_in[4:0] == 5'd18)?  { 1'b0, 16'hAD58 } : //2^{-18/32}
    (volume_in[4:0] == 5'd19)?  { 1'b0, 16'hA9A1 } : //2^{-19/32}
    (volume_in[4:0] == 5'd20)?  { 1'b0, 16'hA5FE } : //2^{-20/32}
    (volume_in[4:0] == 5'd21)?  { 1'b0, 16'hA270 } : //2^{-21/32}
    (volume_in[4:0] == 5'd22)?  { 1'b0, 16'h9EF5 } : //2^{-22/32}
    (volume_in[4:0] == 5'd23)?  { 1'b0, 16'h9B8D } : //2^{-23/32}
    (volume_in[4:0] == 5'd24)?  { 1'b0, 16'h9837 } : //2^{-24/32}
    (volume_in[4:0] == 5'd25)?  { 1'b0, 16'h94F4 } : //2^{-25/32}
    (volume_in[4:0] == 5'd26)?  { 1'b0, 16'h91C3 } : //2^{-26/32}
    (volume_in[4:0] == 5'd27)?  { 1'b0, 16'h8EA4 } : //2^{-27/32}
    (volume_in[4:0] == 5'd28)?  { 1'b0, 16'h8B95 } : //2^{-28/32}
    (volume_in[4:0] == 5'd29)?  { 1'b0, 16'h8898 } : //2^{-29/32}
    (volume_in[4:0] == 5'd30)?  { 1'b0, 16'h85AA } : //2^{-30/32}
                                { 1'b0, 16'h82CD };  //2^{-31/32}
                                
reg [16:0] volume_frac;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           volume_frac <= 17'd0;
    else if(prepare_cnt_freq_3)  volume_frac <= volume_prepare;
end

reg [3:0] volume_int;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           volume_int <= 4'd0;
    else if(prepare_cnt_freq_3)  volume_int <= volume_in[8:5];
end

//------------------------------------------------------------------------------ change_release, change_decay, waveform

assign wform_decrel_request = prepare_cnt_chg_release_1 || prepare_cnt_chg_decay_1;

assign wform_decrel_address = (prepare_cnt_chg_release_1)? { toff, release_rate } : (prepare_cnt_chg_decay_1)? { toff, decay_rate } : waveform_address;

//------------------------------------------------------------------------------ change_release

reg [16:0] release_mul;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               release_mul <= 17'h10000;
    else if(prepare_cnt_chg_release_2)   release_mul <= (release_rate == 4'd0)? 17'h10000 : { 1'b0, wform_decrel_q };
end

wire [6:0] release_steps = { 1'b0, release_rate, 2'b0 } + { 3'd0, toff };

wire [11:0] release_mask_next =
    (release_rate == 4'd0)?         12'h0 : 
    (release_steps[6:2] >= 5'd12)?  12'h0 :
    (release_steps[6:2] == 5'd11)?  12'h001 :
    (release_steps[6:2] == 5'd10)?  12'h003 :
    (release_steps[6:2] == 5'd9)?   12'h007 :
    (release_steps[6:2] == 5'd8)?   12'h00F :
    (release_steps[6:2] == 5'd7)?   12'h01F :
    (release_steps[6:2] == 5'd6)?   12'h03F :
    (release_steps[6:2] == 5'd5)?   12'h07F :
    (release_steps[6:2] == 5'd4)?   12'h0FF :
    (release_steps[6:2] == 5'd3)?   12'h1FF :
    (release_steps[6:2] == 5'd2)?   12'h3FF :
    (release_steps[6:2] == 5'd1)?   12'h7FF :
                                    12'hFFF;

reg [11:0] release_mask;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               release_mask <= 12'd0;
    else if(prepare_cnt_chg_release_2)   release_mask <= release_mask_next;
end

//------------------------------------------------------------------------------ change_decay

reg [16:0] decay_mul;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           decay_mul <= 17'h10000;
    else if(prepare_cnt_chg_decay_2) decay_mul <= (decay_rate == 4'd0)? 17'h10000 : { 1'b0, wform_decrel_q };
end

wire [6:0] decay_steps = { 1'b0, decay_rate, 2'b0 } + { 3'd0, toff };

wire [11:0] decay_mask_next =
    (decay_rate == 4'd0)?           12'h0 : 
    (decay_steps[6:2] >= 5'd12)?    12'h0 :
    (decay_steps[6:2] == 5'd11)?    12'h001 :
    (decay_steps[6:2] == 5'd10)?    12'h003 :
    (decay_steps[6:2] == 5'd9)?     12'h007 :
    (decay_steps[6:2] == 5'd8)?     12'h00F :
    (decay_steps[6:2] == 5'd7)?     12'h01F :
    (decay_steps[6:2] == 5'd6)?     12'h03F :
    (decay_steps[6:2] == 5'd5)?     12'h07F :
    (decay_steps[6:2] == 5'd4)?     12'h0FF :
    (decay_steps[6:2] == 5'd3)?     12'h1FF :
    (decay_steps[6:2] == 5'd2)?     12'h3FF :
    (decay_steps[6:2] == 5'd1)?     12'h7FF :
                                    12'hFFF;

reg [11:0] decay_mask;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   decay_mask <= 12'd0;
    else if(prepare_cnt_chg_decay_2)    decay_mask <= decay_mask_next;
end

//------------------------------------------------------------------------------ change_attack

assign attack_address = { toff, attack_rate };

wire [6:0] attack_steps = { 1'b0, attack_rate, 2'b0 } + { 3'd0, toff };

wire [11:0] attack_mask_next =
    (attack_rate == 4'd0)?          12'h0 : 
    (attack_steps[6:2] >= 5'd12)?   12'h0 :
    (attack_steps[6:2] == 5'd11)?   12'h001 :
    (attack_steps[6:2] == 5'd10)?   12'h003 :
    (attack_steps[6:2] == 5'd9)?    12'h007 :
    (attack_steps[6:2] == 5'd8)?    12'h00F :
    (attack_steps[6:2] == 5'd7)?    12'h01F :
    (attack_steps[6:2] == 5'd6)?    12'h03F :
    (attack_steps[6:2] == 5'd5)?    12'h07F :
    (attack_steps[6:2] == 5'd4)?    12'h0FF :
    (attack_steps[6:2] == 5'd3)?    12'h1FF :
    (attack_steps[6:2] == 5'd2)?    12'h3FF :
    (attack_steps[6:2] == 5'd1)?    12'h7FF :
                                    12'hFFF;

reg [11:0] attack_mask;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               attack_mask <= 12'd0;
    else if(prepare_cnt_chg_attack_1)    attack_mask <= attack_mask_next;
end

wire [7:0] attack_skip_mask_next =
    (attack_mask_next > 12'd48)?        8'hFF :
    (attack_mask_next[1:0] == 2'd0)?    8'hAA :
    (attack_mask_next[1:0] == 2'd1)?    8'hBA :
    (attack_mask_next[1:0] == 2'd2)?    8'hEE :
                                        8'hFE;

reg [7:0] attack_skip_mask;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   attack_skip_mask <= 8'd0;
    else if(prepare_cnt_chg_attack_1)   attack_skip_mask <= attack_skip_mask_next;
end

//------------------------------------------------------------------------------ change_enable / change_disable : react everytime

reg active_normal;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                               active_normal <= 1'b0;
    else if(~(active_normal) && ~(active_rythm) && enable_normal)   active_normal <= 1'b1;
    else if(active_normal && disable_normal)                        active_normal <= 1'b0;
end

reg active_rythm;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                               active_rythm <= 1'b0;
    else if(~(active_normal) && ~(active_rythm) && enable_rythm)    active_rythm <= 1'b1;
    else if(active_rythm && disable_percussion)                     active_rythm <= 1'b0;
end

localparam [1:0] ACTIVE_IDLE        = 2'd0;
localparam [1:0] ACTIVE_TO_RELEASE  = 2'd1;
localparam [1:0] ACTIVE_TO_ATTACK   = 2'd2;

reg [1:0] active_on_next_sample;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                   active_on_next_sample <= ACTIVE_IDLE;
    else if(~(active_normal) && ~(active_rythm) && (enable_normal || enable_rythm))     active_on_next_sample <= ACTIVE_TO_ATTACK;
    else if((active_normal && disable_normal) || (active_rythm && disable_percussion))  active_on_next_sample <= ACTIVE_TO_RELEASE;
    else if(prepare_cnt_chg_enable_2)                                                   active_on_next_sample <= ACTIVE_IDLE;
end

//------------------------------------------------------------------------------ state

localparam [2:0] S_OFF              = 3'd0;
localparam [2:0] S_ATTACK           = 3'd1;
localparam [2:0] S_DECAY            = 3'd2;
localparam [2:0] S_SUSTAIN          = 3'd3;
localparam [2:0] S_SUSTAIN_NOKEEP   = 3'd4;
localparam [2:0] S_RELEASE          = 3'd5;

reg [2:0] state;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                                   state <= S_OFF;
    
    else if(prepare_cnt_chg_enable_1 && active_on_next_sample == ACTIVE_TO_ATTACK)                      state <= S_ATTACK;
    else if(prepare_cnt_chg_enable_1 && active_on_next_sample == ACTIVE_TO_RELEASE && state != S_OFF)   state <= S_RELEASE;
    
    else if(prepare_cnt_chg_enable_1 && state == S_SUSTAIN        && eg_type == 1'b0)                   state <= S_SUSTAIN_NOKEEP;
    else if(prepare_cnt_chg_enable_1 && state == S_SUSTAIN_NOKEEP && eg_type == 1'b1)                   state <= S_SUSTAIN;

    //attack
    else if(attack_step_finished)                                                                       state <= S_DECAY;
    
    //decay
    else if(decay_step_finish_to_sustain)                                                               state <= S_SUSTAIN;
    else if(decay_step_finish_to_sustain_no_keep)                                                       state <= S_SUSTAIN_NOKEEP;
    
    //release
    else if(state == S_RELEASE && release_step_finish)                                                  state <= S_OFF;
end

//------------------------------------------------------------------------------ rythm data between operators

assign rythm_c1 = (tcount[18] ^ tcount[23]) | tcount[19];  //(c1 & 0x88) ^ ((c1<<5) & 0x80)
assign rythm_c2 = tcount[24];
assign rythm_c3 = tcount[21] ^ tcount[19]; //((c3 ^ (c3<<2)) & 0x20)

//------------------------------------------------------------------------------ vibrato

// (f_INT/8192) * (8/f_s) * LFO_fixedpoint = 8484
// ~6,1 Hz

reg [26:0] vibrato_pos;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               vibrato_pos <= 27'd0;
    else if(prepare_cnt_vibrato_1)  vibrato_pos <= vibrato_pos + 27'd8484;
end

wire vibrato_table_8 = vibrato_depth && (vibrato_pos[26:24] == 3'd0 || vibrato_pos[26:24] == 3'd4);
wire vibrato_table_4 =
    (vibrato_depth == 1'b0 && (vibrato_pos[26:24] == 3'd0 || vibrato_pos[26:24] == 3'd4)) ||
    (vibrato_depth == 1'b1 && (vibrato_pos[26:24] == 3'd1 || vibrato_pos[26:24] == 3'd3 || vibrato_pos[26:24] == 3'd5 || vibrato_pos[26:24] == 3'd7));
wire vibrato_table_2 =
    (vibrato_depth == 1'b0 && (vibrato_pos[26:24] == 3'd1 || vibrato_pos[26:24] == 3'd3 || vibrato_pos[26:24] == 3'd5 || vibrato_pos[26:24] == 3'd7));
    
wire [9:0] vibrato_mult =
    (vibrato_table_8 && freq_high[3:1] == 3'd1)?                                10'd91 :  //1
    (vibrato_table_8 && freq_high[3:1] == 3'd2)?                                10'd183 : //2
    (vibrato_table_8 && freq_high[3:1] == 3'd3)?                                10'd275 : //3
    (vibrato_table_8 && freq_high[3:1] == 3'd4)?                                10'd367 : //4
    (vibrato_table_8 && freq_high[3:1] == 3'd5)?                                10'd458 : //5
    (vibrato_table_8 && freq_high[3:1] == 3'd6)?                                10'd550 : //6
    (vibrato_table_8 && freq_high[3:1] == 3'd7)?                                10'd642 : //7
    (vibrato_table_4 && (freq_high[3:1] == 3'd2 || freq_high[3:1] == 3'd3))?    10'd91 :  //1
    (vibrato_table_4 && (freq_high[3:1] == 3'd4 || freq_high[3:1] == 3'd5))?    10'd183 : //2
    (vibrato_table_4 && (freq_high[3:1] == 3'd6 || freq_high[3:1] == 3'd7))?    10'd275 : //3
    (vibrato_table_2 && freq_high[3:1] >= 3'd4)?                                10'd91 :  //1
                                                                                10'd0;

//vibrato_pos[26:24]
//freq_high[3:1]
//vibrato_depth[0]

//tinc*(lut*high/8)*fixed*70/50000)/fixed

wire vibrato_sign = vibrato_pos[26:24] == 3'd3 || vibrato_pos[26:24] == 3'd4 || vibrato_pos[26:24] == 3'd5;

reg [35:0] tinc_vibrato;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   tinc_vibrato <= 36'd0;
    else if(prepare_cnt_vibrato_1)                      tinc_vibrato <= 36'd0;
    else if(prepare_cnt_vibrato_2  && vibrato_mult[0])  tinc_vibrato <= tinc_vibrato + { 10'd0, tinc };
    else if(prepare_cnt_vibrato_3  && vibrato_mult[1])  tinc_vibrato <= tinc_vibrato + { 9'd0,  tinc, 1'b0 };
    else if(prepare_cnt_vibrato_4  && vibrato_mult[2])  tinc_vibrato <= tinc_vibrato + { 8'd0,  tinc, 2'b0 };
    else if(prepare_cnt_vibrato_5  && vibrato_mult[3])  tinc_vibrato <= tinc_vibrato + { 7'd0,  tinc, 3'b0 };
    else if(prepare_cnt_vibrato_6  && vibrato_mult[4])  tinc_vibrato <= tinc_vibrato + { 6'd0,  tinc, 4'b0 };
    else if(prepare_cnt_vibrato_7  && vibrato_mult[5])  tinc_vibrato <= tinc_vibrato + { 5'd0,  tinc, 5'b0 };
    else if(prepare_cnt_vibrato_8  && vibrato_mult[6])  tinc_vibrato <= tinc_vibrato + { 4'd0,  tinc, 6'b0 };
    else if(prepare_cnt_vibrato_9  && vibrato_mult[7])  tinc_vibrato <= tinc_vibrato + { 3'd0,  tinc, 7'b0 };
    else if(prepare_cnt_vibrato_10 && vibrato_mult[8])  tinc_vibrato <= tinc_vibrato + { 2'd0,  tinc, 8'b0 };
    else if(prepare_cnt_vibrato_11 && vibrato_mult[9])  tinc_vibrato <= tinc_vibrato + { 1'd0,  tinc, 9'b0 };
end

//------------------------------------------------------------------------------

reg [25:0] tcount;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                               tcount <= 26'd0;
    else if(prepare_cnt_chg_enable_1 && active_on_next_sample == ACTIVE_TO_ATTACK)  tcount <= 26'd0;
    
    else if(prepare_cnt_tcount_2 && vibrato && ~(vibrato_sign))                     tcount <= tcount + { 6'd0, tinc_vibrato[35:16] };
    else if(prepare_cnt_tcount_2 && vibrato && vibrato_sign)                        tcount <= tcount - { 6'd0, tinc_vibrato[35:16] };
    else if(prepare_cnt_tcount_3)                                                   tcount <= tcount + tinc;
end

wire [25:0] wfpos_next =
                                                                                //(phasebit<<8) | (0x34<<(phasebit ^ (noisebit<<1)))
    (rythm_hihat  && active_rythm && ~(rythm_phasebit) && ~(rythm_noisebit))?   { 2'b0, 8'h34, 16'd0 }:
    (rythm_hihat  && active_rythm && ~(rythm_phasebit) && rythm_noisebit)?      { 8'h34, 2'b0, 16'd0 } :
    (rythm_hihat  && active_rythm && rythm_phasebit    && ~(rythm_noisebit))?   { 8'h80 | 8'h34, 2'b0, 16'd0 } :
    (rythm_hihat  && active_rythm && rythm_phasebit    && rythm_noisebit)?      { 8'h80 | 8'h0D, 2'b0, 16'd0 } :
                                                                                //((1+snare_phase_bit) ^ noisebit)<<8
    (rythm_snare  && active_rythm && ~(rythm_snarebit) && ~(rythm_noisebit))?   { 2'b01, 8'd0, 16'd0 } :
    (rythm_snare  && active_rythm && ~(rythm_snarebit) && rythm_noisebit)?      { 2'b00, 8'd0, 16'd0 } :
    (rythm_snare  && active_rythm && rythm_snarebit    && ~(rythm_noisebit))?   { 2'b10, 8'd0, 16'd0 } :
    (rythm_snare  && active_rythm && rythm_snarebit    && rythm_noisebit)?      { 2'b11, 8'd0, 16'd0 } :
                                                                                //(1+phasebit)<<8
    (rythm_cymbal && active_rythm && ~(rythm_phasebit))?                        { 2'b01, 8'd0, 16'd0 } :
    (rythm_cymbal && active_rythm && rythm_phasebit)?                           { 2'b11, 8'd0, 16'd0 } :
                                                                                tcount;

reg [25:0] wfpos;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               wfpos <= 26'd0;
    else if(prepare_cnt_tcount_1)   wfpos <= wfpos_next;
end

//------------------------------------------------------------------------------ generator_pos

reg [16:0] generator_pos;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   generator_pos <= 17'd0;
    else if(prepare_cnt_tcount_1 && generator_pos[16])  generator_pos <= { 1'b0, generator_pos[15:0] };
    else if(prepare_cnt_tcount_2)                       generator_pos <= generator_pos + 17'd33939; //f_INT / f_s * fixedpoint
end

wire generator_active = generator_pos[16];

reg [11:0] env_step;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                   env_step <= 12'd0;
    else if(prepare_cnt_tcount_3 && state != S_OFF && generator_active) env_step <= env_step + 12'd1; //for attack,decay,release,sustain
end

//------------------------------------------------------------------------------ operate on attack

reg [19:0] attack_sum;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               attack_sum <= 20'd0;
    else if(prepare_cnt_attack_4)   attack_sum <= mult_result[35:16];                   //amp^2
    else if(prepare_cnt_attack_10)  attack_sum <= mult_result[35:16];                   //(3)
    else if(prepare_cnt_attack_14)  attack_sum <= attack_sum + mult_result_reg[35:16];  //(2)
    else if(prepare_cnt_attack_17)  attack_sum <= attack_sum + mult_result_reg[35:16];  //(1)
    else if(prepare_cnt_attack_18)  attack_sum <= attack_sum + 20'd154;                 //0.0377/16 *fixedpoint
end

reg [19:0] attack_amp;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   attack_amp <= 20'd0;
    else if(prepare_cnt_attack_22)                      attack_amp <= mult_result[35:16];
    else if(prepare_cnt_attack_23 && attack_value[16])  attack_amp <= attack_amp + { attack_sum[18:0], 1'b0 };
    else if(prepare_cnt_attack_24 && attack_value[17])  attack_amp <= attack_amp + { attack_sum[17:0], 2'b0 };
    else if(prepare_cnt_attack_25 && attack_value[18])  attack_amp <= attack_amp + { attack_sum[16:0], 3'b0 };
    else if(prepare_cnt_attack_26 && attack_value[19])  attack_amp <= attack_amp + { attack_sum[15:0], 4'b0 };
end

//

wire attack_step_active_1 = prepare_cnt_attack_29 && generator_active && (env_step & attack_mask) == 12'd0;
wire attack_step_active_2 = prepare_cnt_attack_30 && generator_active && (env_step & attack_mask) == 12'd0;

wire attack_step_finished = attack_step_active_2 && (amp >= 20'd65536 || attack_steps >= 7'd62);
wire attack_step_update   = attack_step_active_2 && (attack_skip_pos & attack_skip_mask) != 8'd0;

reg [7:0] attack_skip_pos;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                           attack_skip_pos <= 8'd0;
    else if(attack_step_active_1 && attack_skip_pos == 8'd0)    attack_skip_pos <= 8'd1;   
    else if(attack_step_active_1)                               attack_skip_pos <= { attack_skip_pos[6:0], attack_skip_pos[7] };
end

//------------------------------------------------------------------------------ operate on decay

wire [16:0] sustain_amp =
    (sustain_level == 4'd0)?    17'h10000 :
    (sustain_level == 4'd1)?    17'h0B504 :
    (sustain_level == 4'd2)?    17'h08000 :
    (sustain_level == 4'd3)?    17'h05A82 :
    (sustain_level == 4'd4)?    17'h04000 :
    (sustain_level == 4'd5)?    17'h02D41 :
    (sustain_level == 4'd6)?    17'h02000 :
    (sustain_level == 4'd7)?    17'h016A0 :
    (sustain_level == 4'd8)?    17'h01000 :
    (sustain_level == 4'd9)?    17'h00B50 :
    (sustain_level == 4'd10)?   17'h00800 :
    (sustain_level == 4'd11)?   17'h005A8 :
    (sustain_level == 4'd12)?   17'h00400 :
    (sustain_level == 4'd13)?   17'h002D4 :
    (sustain_level == 4'd14)?   17'h00200 :
                                17'h00000;

wire decay_step_active = prepare_cnt_decay_5 && generator_active && (env_step & decay_mask) == 12'd0;

wire decay_step_finish_to_sustain           = decay_step_active && amp <= { 3'b0, sustain_amp } && eg_type;
wire decay_step_finish_to_sustain_no_keep   = decay_step_active && amp <= { 3'b0, sustain_amp } && ~(eg_type);

//------------------------------------------------------------------------------ operate on release

wire release_step_active = prepare_cnt_release_5 && generator_active && (env_step & release_mask) == 12'd0;
wire release_step_finish = release_step_active && amp <= 20'd1;

//------------------------------------------------------------------------------ multiply unit

reg [17:0] mult_a;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               mult_a <= 18'd0;
    
    //attack
    else if(prepare_cnt_attack_1)   mult_a <= { 1'b0, amp[16:0] };
    else if(prepare_cnt_attack_4)   mult_a <= mult_result[33:16]; //amp^2
    else if(prepare_cnt_attack_7)   mult_a <= mult_result[33:16]; //amp^3
    else if(prepare_cnt_attack_10)  mult_a <= { 1'b0, attack_sum[16:0] };
    else if(prepare_cnt_attack_13)  mult_a <= { 1'b0, amp[16:0] };
    else if(prepare_cnt_attack_19)  mult_a <= { 2'b0, attack_value[15:0] };

    //decay
    else if(prepare_cnt_decay_1)    mult_a <= { 1'b0, amp[16:0] };
    
    //release
    else if(prepare_cnt_release_1)  mult_a <= { 1'b0, amp[16:0] };
    
    //output
    else if(prepare_cnt_output_5)   mult_a <= { waveform_value[16], waveform_value };
    else if(prepare_cnt_output_8)   mult_a <= mult_result[33:16];
    else if(prepare_cnt_output_11)  mult_a <= mult_result[33:16];
end

reg [17:0] mult_b;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               mult_b <= 18'd0;
    
    //attack
    else if(prepare_cnt_attack_1)   mult_b <= { 1'b0, amp[16:0] };
    else if(prepare_cnt_attack_7)   mult_b <= 18'd30392; //7.42/16 *fixedpoint
    else if(prepare_cnt_attack_10)  mult_b <= 18'h2E6E2; //-17.57/16 *fixedpoint
    else if(prepare_cnt_attack_13)  mult_b <= 18'd43950; //10.73/16 *fixedpoint
    else if(prepare_cnt_attack_19)  mult_b <= { 1'b0, attack_sum[16:0] };
    
    //decay
    else if(prepare_cnt_decay_1)    mult_b <= { 1'b0, decay_mul };
    
    //release
    else if(prepare_cnt_release_1)  mult_b <= { 1'b0, release_mul };
    
    //output
    else if(prepare_cnt_output_5)   mult_b <= { 1'b0, volume_frac };
    else if(prepare_cnt_output_8)   mult_b <= { 1'b0, step_amp };
    else if(prepare_cnt_output_11)  mult_b <= { 1'b0, tremolo_coeff };
end

wire [35:0] mult_result;

simple_mult #(
    .widtha (18),
    .widthb (18),
    .widthp (36)
)
operator_mult_inst (
    .clk    (clk),

    .a      (mult_a),      //input [17:0]
    .b      (mult_b),      //input [17:0]
    
    .out    (mult_result)  //output [35:0]
);

reg [35:0] mult_result_reg;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   mult_result_reg <= 36'd0;
    else                mult_result_reg <= mult_result;
end

reg [16:0] step_amp;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                       step_amp <= 17'd0;

    else if(attack_step_finished)           step_amp <= 17'd65536;
    else if(attack_step_update)             step_amp <= amp[16:0];
    
    else if(decay_step_finish_to_sustain)   step_amp <= sustain_amp;
    else if(decay_step_active)              step_amp <= amp[16:0];
    
    else if(release_step_finish)            step_amp <= 17'd0;
    else if(release_step_active)            step_amp <= amp[16:0];
end

reg [19:0] amp;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                           amp <= 20'd0;
    
    //attack
    else if(prepare_cnt_attack_27)                              amp <= amp + attack_amp;
    else if(prepare_cnt_attack_28 && amp > 20'd65536)           amp <= 20'd65537;
    else if(attack_step_finished)                               amp <= 20'd65536;
    
    //decay
    else if(prepare_cnt_decay_4 && amp > { 3'b0, sustain_amp }) amp <= mult_result[35:16];
    else if(decay_step_finish_to_sustain)                       amp <= { 3'b0, sustain_amp };
    
    //release
    else if(prepare_cnt_release_4 && amp > 20'd1)               amp <= mult_result[35:16];
    else if(release_step_finish)                                amp <= 20'd0;
end

//------------------------------------------------------------------------------ waveform

//mfbi: *2^(feedback+8)
//(lastcval + cval)*2^(feedback+7)

//input [2:0]   feedback,
//input [15:0]  modulator,
//      [25:0]  wfpos

wire [16:0] waveform_wfpos_plus_modulator = { 6'd0, wfpos[25:16] } + modulator;
wire [16:0] waveform_feedback_sum         = cval_last + cval;
wire [25:0] waveform_feedback_modulator =
    (feedback == 3'd1)?     { 2'b0, waveform_feedback_sum[15:0], 8'd0 } :
    (feedback == 3'd2)?     { 1'b0, waveform_feedback_sum[15:0], 9'd0 } :
    (feedback == 3'd3)?     {       waveform_feedback_sum[15:0], 10'd0 } :
    (feedback == 3'd4)?     {       waveform_feedback_sum[14:0], 11'd0 } :
    (feedback == 3'd5)?     {       waveform_feedback_sum[13:0], 12'd0 } :
    (feedback == 3'd6)?     {       waveform_feedback_sum[12:0], 13'd0 } :
                            {       waveform_feedback_sum[11:0], 14'd0 };
                            
reg [25:0] waveform_feedback_modulator_reg;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   waveform_feedback_modulator_reg <= 26'd0;
    else                waveform_feedback_modulator_reg <= waveform_feedback_modulator;
end                            

wire [26:0] waveform_wfpos_plus_feedback = wfpos + waveform_feedback_modulator_reg;
    
reg [9:0] waveform_counter;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   waveform_counter <= 10'd0; 
    else if(prepare_cnt_output_1 && feedback == 3'd0)   waveform_counter <= waveform_wfpos_plus_modulator[9:0];
    else if(prepare_cnt_output_1)                       waveform_counter <= waveform_wfpos_plus_feedback[25:16];
end

wire waveform_counter_reverse = (waveform_counter >= 10'd256 && waveform_counter <= 10'd511) || waveform_counter >= 10'd768;

reg [7:0] waveform_address;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                   waveform_address <= 8'd0;
    else if(prepare_cnt_output_2 && wave_select == 2'd1 && waveform_counter >= 10'd512) waveform_address <= 8'd0;
    else if(prepare_cnt_output_2 && wave_select == 2'd3 && waveform_counter_reverse)    waveform_address <= 8'd0;
    else if(prepare_cnt_output_2 && waveform_counter_reverse)                           waveform_address <= 8'd255 - waveform_counter[7:0];
    else if(prepare_cnt_output_2)                                                       waveform_address <= waveform_counter[7:0];
end

wire [15:0] waveform_q_negative = -wform_decrel_q;

reg [16:0] waveform_value;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                   waveform_value <= 17'd0;
    else if(prepare_cnt_output_4 && wave_select == 2'd0 && waveform_counter >= 10'd512) waveform_value <= { 1'b1, waveform_q_negative };
    else if(prepare_cnt_output_4)                                                       waveform_value <= { 1'b0, wform_decrel_q };
end

//------------------------------------------------------------------------------ tremolo

//TREMTAB_SIZE * TREM_FREQ * FIXED_LFO / f_s = 34270
reg [29:0] tremolo_pos;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                               tremolo_pos <= 30'd0;
    else if(prepare_cnt_output_1)                                   tremolo_pos <= tremolo_pos + 30'd34270;
    else if(prepare_cnt_output_2 && tremolo_pos[29:24] == 6'd53)    tremolo_pos <= { 6'd0, tremolo_pos[23:0] };
end

wire [6:0] tremolo_idx =
    (tremolo_depth    && tremolo_pos[29:24] <= 6'd13)?      7'd13 - { 1'b0, tremolo_pos[29:24] } :
    (tremolo_depth    && tremolo_pos[29:24] <= 6'd40)?      { 1'b0, tremolo_pos[29:24] } - 7'd14 :
    (tremolo_depth    && tremolo_pos[29:24] <= 6'd52)?      7'd66 - { 1'b0, tremolo_pos[29:24] } :
    (~(tremolo_depth) && tremolo_pos[29:24] <= 6'd1)?       7'd3 :
    (~(tremolo_depth) && tremolo_pos[29:24] <= 6'd5)?       7'd2 :
    (~(tremolo_depth) && tremolo_pos[29:24] <= 6'd9)?       7'd1 :
    (~(tremolo_depth) && tremolo_pos[29:24] <= 6'd17)?      7'd0 :
    (~(tremolo_depth) && tremolo_pos[29:24] <= 6'd21)?      7'd1 :
    (~(tremolo_depth) && tremolo_pos[29:24] <= 6'd25)?      7'd2 :
    (~(tremolo_depth) && tremolo_pos[29:24] <= 6'd29)?      7'd3 :
    (~(tremolo_depth) && tremolo_pos[29:24] <= 6'd33)?      7'd4 :
    (~(tremolo_depth) && tremolo_pos[29:24] <= 6'd37)?      7'd5 :
    (~(tremolo_depth) && tremolo_pos[29:24] <= 6'd42)?      7'd6 :
    (~(tremolo_depth) && tremolo_pos[29:24] <= 6'd46)?      7'd5 :
    (~(tremolo_depth) && tremolo_pos[29:24] <= 6'd50)?      7'd4 :
                                                            7'd3;

wire [16:0] tremolo_48db =
    (tremolo_idx[4:0] == 5'd26)?    17'h9308 :
    (tremolo_idx[4:0] == 5'd25)?    17'h9633 :
    (tremolo_idx[4:0] == 5'd24)?    17'h9970 :
    (tremolo_idx[4:0] == 5'd23)?    17'h9CBF :
    (tremolo_idx[4:0] == 5'd22)?    17'hA020 :
    (tremolo_idx[4:0] == 5'd21)?    17'hA394 :
    (tremolo_idx[4:0] == 5'd20)?    17'hA71B :
    (tremolo_idx[4:0] == 5'd19)?    17'hAAB5 :
    (tremolo_idx[4:0] == 5'd18)?    17'hAE63 :
    (tremolo_idx[4:0] == 5'd17)?    17'hB225 :
    (tremolo_idx[4:0] == 5'd16)?    17'hB5FC :
    (tremolo_idx[4:0] == 5'd15)?    17'hB9E8 :
    (tremolo_idx[4:0] == 5'd14)?    17'hBDEA :
    (tremolo_idx[4:0] == 5'd13)?    17'hC203 :
    (tremolo_idx[4:0] == 5'd12)?    17'hC631 :
    (tremolo_idx[4:0] == 5'd11)?    17'hCA77 :
    (tremolo_idx[4:0] == 5'd10)?    17'hCED4 :
    (tremolo_idx[4:0] == 5'd9)?     17'hD34A :
    (tremolo_idx[4:0] == 5'd8)?     17'hD7D8 :
    (tremolo_idx[4:0] == 5'd7)?     17'hDC7F :
    (tremolo_idx[4:0] == 5'd6)?     17'hE140 :
    (tremolo_idx[4:0] == 5'd5)?     17'hE61B :
    (tremolo_idx[4:0] == 5'd4)?     17'hEB10 :
    (tremolo_idx[4:0] == 5'd3)?     17'hF022 :
    (tremolo_idx[4:0] == 5'd2)?     17'hF54F :
    (tremolo_idx[4:0] == 5'd1)?     17'hFA99 :
                                    17'h10000;

wire [16:0] tremolo_12db =
    (tremolo_idx[4:0] == 5'd6)?     17'hDEDC :
    (tremolo_idx[4:0] == 5'd5)?     17'hE411 :
    (tremolo_idx[4:0] == 5'd4)?     17'hE966 :
    (tremolo_idx[4:0] == 5'd3)?     17'hEEDB :
    (tremolo_idx[4:0] == 5'd2)?     17'hF470 :
    (tremolo_idx[4:0] == 5'd1)?     17'hFA27 :
                                    17'h10000;

reg [16:0] tremolo_coeff;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               tremolo_coeff <= 17'd0;
    else if(prepare_cnt_output_3 && ~(tremolo))     tremolo_coeff <= 17'h10000;
    else if(prepare_cnt_output_3 && tremolo_depth)  tremolo_coeff <= tremolo_48db;
    else if(prepare_cnt_output_3)                   tremolo_coeff <= tremolo_12db;
end

//------------------------------------------------------------------------------

wire [15:0] cval_shifted =
    (volume_int == 4'd1)?   { 1'b0,  cval[15:1] } :
    (volume_int == 4'd2)?   { 2'b0,  cval[15:2] } :
    (volume_int == 4'd3)?   { 3'b0,  cval[15:3] } :
    (volume_int == 4'd4)?   { 4'b0,  cval[15:4] } :
    (volume_int == 4'd5)?   { 5'b0,  cval[15:5] } :
    (volume_int == 4'd6)?   { 6'b0,  cval[15:6] } :
    (volume_int == 4'd7)?   { 7'b0,  cval[15:7] } :
    (volume_int == 4'd8)?   { 8'b0,  cval[15:8] } :
    (volume_int == 4'd9)?   { 9'b0,  cval[15:9] } :
    (volume_int == 4'd10)?  { 10'b0, cval[15:10] } :
    (volume_int == 4'd11)?  { 11'b0, cval[15:11] } :
    (volume_int == 4'd12)?  { 12'b0, cval[15:12] } :
    (volume_int == 4'd13)?  { 13'b0, cval[15:13] } :
                                     cval;

reg [15:0] cval_last;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               cval_last <= 16'd0;
    else if(prepare_cnt_output_13)  cval_last <= cval;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               cval <= 16'd0;
    else if(prepare_cnt_output_14)  cval <= mult_result[33:18];
    else if(prepare_cnt_output_15)  cval <= (state == S_OFF)? 16'd0 : cval_shifted;
end

//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0,
    release_steps[1:0], decay_steps[1:0], mult_result_reg[15:0],
    waveform_wfpos_plus_modulator[16:10], waveform_feedback_sum[16],
    waveform_wfpos_plus_feedback[26], waveform_wfpos_plus_feedback[15:0],
    tremolo_idx[6:5],
    1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------

endmodule
