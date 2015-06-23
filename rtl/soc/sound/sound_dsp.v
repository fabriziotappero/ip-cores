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

module sound_dsp(
    input               clk,
    input               rst_n,
    
    output reg          irq,
    
    //io slave 220h-22Fh
    input       [3:0]   io_address,
    input               io_read,
    output      [7:0]   io_readdata_from_dsp,
    input               io_write,
    input       [7:0]   io_writedata,
    
    //dma
    output              dma_soundblaster_req,
    input               dma_soundblaster_ack,
    input               dma_soundblaster_terminal,
    input       [7:0]   dma_soundblaster_readdata,
    output      [7:0]   dma_soundblaster_writedata,
    
    //sample
    output              sample_from_dsp_disabled,
    output              sample_from_dsp_do,
    output      [7:0]   sample_from_dsp_value,
    
    //mgmt slave
    /*
    0-255.[15:0]: cycles in period
    */
    input       [8:0]   mgmt_address,
    input               mgmt_write,
    input       [31:0]  mgmt_writedata
);

//------------------------------------------------------------------------------

reg io_read_last;
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) io_read_last <= 1'b0; else if(io_read_last) io_read_last <= 1'b0; else io_read_last <= io_read; end 
wire io_read_valid = io_read && io_read_last == 1'b0;

//------------------------------------------------------------------------------

assign io_readdata_from_dsp =
    (io_address == 4'hE)?                       { read_ready, 7'h7F } :
    (io_address == 4'hA && copy_cnt > 6'd0)?    copyright_byte :
    (io_address == 4'hA)?                       read_buffer[15:8] :
    (io_address == 4'hC)?                       { write_ready, 7'h7F } :
                                                8'hFF;

//------------------------------------------------------------------------------

wire highspeed_start = cmd_high_auto_dma_out || cmd_high_single_dma_out || cmd_high_auto_dma_input || cmd_high_single_dma_input;

reg highspeed_mode;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           highspeed_mode <= 1'b0;
    else if(highspeed_reset)    highspeed_mode <= 1'b0;
    else if(highspeed_start)    highspeed_mode <= 1'b1;
    else if(dma_finished)       highspeed_mode <= 1'b0;
end

reg midi_uart_mode;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           midi_uart_mode <= 1'b0;
    else if(midi_uart_reset)    midi_uart_mode <= 1'b0;
    else if(cmd_midi_uart)      midi_uart_mode <= 1'b1;
end

reg reset_reg;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                               reset_reg <= 1'b0;
    else if(io_write && io_address == 4'h6 && ~(highspeed_mode))    reset_reg <= io_writedata[0];
end

wire highspeed_reset = io_write && io_address == 4'h6 && highspeed_mode;
wire midi_uart_reset = reset_reg && io_write && io_address == 4'h6 && ~(highspeed_mode) && midi_uart_mode    && io_writedata[0] == 1'b0;
wire sw_reset        = reset_reg && io_write && io_address == 4'h6 && ~(highspeed_mode) && ~(midi_uart_mode) && io_writedata[0] == 1'b0;

//------------------------------------------------------------------------------ dummy input

wire input_strobe = cmd_direct_input || dma_input;

reg input_direction;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                       input_direction <= 1'b0;
    else if(sw_reset)                                                       input_direction <= 1'b0;
    else if(input_strobe && ~(input_direction) && input_sample == 8'd254)   input_direction <= 1'b1;
    else if(input_strobe && input_direction    && input_sample == 8'd1)     input_direction <= 1'b0;
end

reg [7:0] input_sample;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                           input_sample <= 8'd128;
    else if(sw_reset)                           input_sample <= 8'd128;
    else if(input_strobe && ~(input_direction)) input_sample <= input_sample + 8'd1;
    else if(input_strobe && input_direction)    input_sample <= input_sample - 8'd1;
end

assign dma_soundblaster_writedata = (dma_id_active)? dma_id_value : input_sample;

//------------------------------------------------------------------------------

wire cmd_single_byte = write_left == 2'd0 && io_write && io_address == 4'hC && ~(midi_uart_mode) && ~(highspeed_mode);

wire cmd_wait_for_2byte = write_left == 2'd0 && io_write && io_address == 4'hC && ~(midi_uart_mode) && ~(highspeed_mode) && (
    io_writedata == 8'h10 || //direct output
    io_writedata == 8'h38 || //midi   output
    io_writedata == 8'h40 || //set time constant
    io_writedata == 8'hE0 || //dsp identification
    io_writedata == 8'hE4 || //write test register
    io_writedata == 8'hE2    //dma id
);
wire cmd_wait_for_3byte = write_left == 2'd0 && io_write && io_address == 4'hC && ~(midi_uart_mode) && ~(highspeed_mode) && (
    io_writedata == 8'h14 ||   //single cycle dma output
    io_writedata == 8'h16 ||   //single cycle dma 2 bit adpcm output
    io_writedata == 8'h17 ||   //single cycle dma 2 bit adpcm output with reference
    io_writedata == 8'h74 ||   //single cycle dma 4 bit adpcm output
    io_writedata == 8'h75 ||   //single cycle dma 4 bit adpcm output with reference
    io_writedata == 8'h76 ||   //single cycle dma 4 bit adpcm output
    io_writedata == 8'h77 ||   //single cycle dma 4 bit adpcm output with reference
    io_writedata == 8'h24 ||   //single cycle dma input
    io_writedata == 8'h48 ||   //set block size
    io_writedata == 8'h80      //pause dac
);

wire cmd_multiple_byte = write_length > 2'd0 && write_left == 2'd0 && ~(midi_uart_mode) && ~(highspeed_mode);

wire cmd_dsp_version            = cmd_single_byte && io_writedata == 8'hE1;
wire cmd_direct_output          = cmd_multiple_byte && write_length == 2'd2 && write_buffer[15:8] == 8'h10;
wire cmd_single_dma_output      = cmd_multiple_byte && write_length == 2'd3 && write_buffer[23:16] == 8'h14;
wire cmd_single_2_adpcm_out     = cmd_multiple_byte && write_length == 2'd3 && write_buffer[23:16] == 8'h16;
wire cmd_single_2_adpcm_out_ref = cmd_multiple_byte && write_length == 2'd3 && write_buffer[23:16] == 8'h17;
wire cmd_single_4_adpcm_out     = cmd_multiple_byte && write_length == 2'd3 && write_buffer[23:16] == 8'h74;
wire cmd_single_4_adpcm_out_ref = cmd_multiple_byte && write_length == 2'd3 && write_buffer[23:16] == 8'h75;
wire cmd_single_3_adpcm_out     = cmd_multiple_byte && write_length == 2'd3 && write_buffer[23:16] == 8'h76;
wire cmd_single_3_adpcm_out_ref = cmd_multiple_byte && write_length == 2'd3 && write_buffer[23:16] == 8'h77;

wire cmd_single_dma_input       = cmd_multiple_byte && write_length == 2'd3 && write_buffer[23:16] == 8'h24;

wire cmd_auto_dma_out           = cmd_single_byte && io_writedata == 8'h1C;
wire cmd_auto_dma_exit          = cmd_single_byte && io_writedata == 8'hDA;

wire cmd_auto_2_adpcm_out_ref   = cmd_single_byte && io_writedata == 8'h1F;
wire cmd_auto_3_adpcm_out_ref   = cmd_single_byte && io_writedata == 8'h7F;
wire cmd_auto_4_adpcm_out_ref   = cmd_single_byte && io_writedata == 8'h7D;

wire cmd_direct_input           = cmd_single_byte && io_writedata == 8'h20;
wire cmd_auto_dma_input         = cmd_single_byte && io_writedata == 8'h2C;

//wire cmd_midi_polling_input     = cmd_single_byte && io_writedata == 8'h30;
//wire cmd_midi_interrupt_input   = cmd_single_byte && io_writedata == 8'h31;

wire cmd_midi_uart              = cmd_single_byte && { io_writedata[7:2], 2'b00 } == 8'h34;
//wire cmd_midi_output            = cmd_multiple_byte && write_length == 2'd2 && write_buffer[15:8] == 8'h38;

wire cmd_set_time_constant      = cmd_multiple_byte && write_length == 2'd2 && write_buffer[15:8] == 8'h40;
wire cmd_set_block_size         = cmd_multiple_byte && write_length == 2'd3 && write_buffer[23:16] == 8'h48;

wire cmd_pause_dac              = cmd_multiple_byte && write_length == 2'd3 && write_buffer[23:16] == 8'h80;

wire cmd_high_auto_dma_out      = cmd_single_byte && io_writedata == 8'h90;
wire cmd_high_single_dma_out    = cmd_single_byte && io_writedata == 8'h91;

wire cmd_high_auto_dma_input    = cmd_single_byte && io_writedata == 8'h98;
wire cmd_high_single_dma_input  = cmd_single_byte && io_writedata == 8'h99;

wire cmd_dma_pause_start        = cmd_single_byte && io_writedata == 8'hD0;
wire cmd_dma_pause_end          = cmd_single_byte && io_writedata == 8'hD4;

wire cmd_speaker_on             = cmd_single_byte && io_writedata == 8'hD1;
wire cmd_speaker_off            = cmd_single_byte && io_writedata == 8'hD3;
wire cmd_speaker_status         = cmd_single_byte && io_writedata == 8'hD8;

wire cmd_dsp_identification     = cmd_multiple_byte && write_length == 2'd2 && write_buffer[15:8] == 8'hE0;
wire cmd_f8_zero                = cmd_single_byte && io_writedata == 8'hF8;
wire cmd_trigger_irq            = cmd_single_byte && io_writedata == 8'hF2;

wire cmd_test_register_write    = cmd_multiple_byte && write_length == 2'd2 && write_buffer[15:8] == 8'hE4;
wire cmd_test_register_read     = cmd_single_byte && io_writedata == 8'hE8;

wire cmd_copyright              = cmd_single_byte && io_writedata == 8'hE3;
wire cmd_dma_id                 = cmd_multiple_byte && write_length == 2'd2 && write_buffer[15:8] == 8'hE2;

//------------------------------------------------------------------------------ 'weird dma identification' from DosBox

reg [1:0] dma_id_count;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   dma_id_count <= 2'd0;
    else if(sw_reset)   dma_id_count <= 2'd0;
    else if(cmd_dma_id) dma_id_count <= dma_id_count + 2'd1;
end

reg [7:0] dma_id_value;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   dma_id_value <= 8'hAA;
    else if(sw_reset)   dma_id_value <= 8'hAA;
    else if(cmd_dma_id) dma_id_value <= dma_id_value + dma_id_q;
end

reg dma_id_active;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               dma_id_active <= 1'b0;
    else if(sw_reset)               dma_id_active <= 1'b0;
    else if(cmd_dma_id)             dma_id_active <= 1'b1;
    else if(dma_soundblaster_ack)   dma_id_active <= 1'b0;
end

wire [7:0] dma_id_q;

simple_single_rom #(
    .widthad    (10),
    .width      (8),
    .datafile   ("./../soc/sound/dsp_dma_identification_rom.hex")
)
dma_id_rom_inst (
    .clk        (clk),
    
    .addr       ({dma_id_count, io_writedata}),
    .q          (dma_id_q)
);

//------------------------------------------------------------------------------ copyright

reg [5:0] copy_cnt;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                               copy_cnt <= 6'd0;
    else if(cmd_copyright)                                          copy_cnt <= 6'd45;
    else if(io_read_valid && io_address == 4'hA && copy_cnt > 6'd0) copy_cnt <= copy_cnt - 6'd1;
end

wire [7:0] copyright_byte =
    (copy_cnt == 6'd45 || copy_cnt == 6'd34 || copy_cnt == 6'd31 || copy_cnt == 6'd20)?                     8'h43 : //C
    (copy_cnt == 6'd44 || copy_cnt == 6'd17 || copy_cnt == 6'd15)?                                          8'h4F : //O
    (copy_cnt == 6'd43)?                                                                                    8'h50 : //P
    (copy_cnt == 6'd42 || copy_cnt == 6'd13)?                                                               8'h59 : //Y
    (copy_cnt == 6'd41 || copy_cnt == 6'd30)?                                                               8'h52 : //R
    (copy_cnt == 6'd40 || copy_cnt == 6'd26)?                                                               8'h49 : //I
    (copy_cnt == 6'd39 || copy_cnt == 6'd14)?                                                               8'h47 : //G
    (copy_cnt == 6'd38 || copy_cnt == 6'd19)?                                                               8'h48 : //H
    (copy_cnt == 6'd37 || copy_cnt == 6'd27 || copy_cnt == 6'd22 || copy_cnt == 6'd10)?                     8'h54 : //T
    (copy_cnt == 6'd36 || copy_cnt == 6'd32 || copy_cnt == 6'd23 || copy_cnt == 6'd12 || copy_cnt == 6'd7)? 8'h20 : //' '
    (copy_cnt == 6'd35)?                                                                                    8'h28 : //(
    (copy_cnt == 6'd33)?                                                                                    8'h29 : //)
    (copy_cnt == 6'd29 || copy_cnt == 6'd24 || copy_cnt == 6'd21)?                                          8'h45 : //E
    (copy_cnt == 6'd28)?                                                                                    8'h41 : //A
    (copy_cnt == 6'd25)?                                                                                    8'h56 : //V
    (copy_cnt == 6'd18)?                                                                                    8'h4E : //N
    (copy_cnt == 6'd16 || copy_cnt == 6'd11)?                                                               8'h4C : //L
    (copy_cnt == 6'd13)?                                                                                    8'h59 : //Y
    (copy_cnt == 6'd9)?                                                                                     8'h44 : //D
    (copy_cnt == 6'd8)?                                                                                     8'h2C : //,
    (copy_cnt == 6'd6)?                                                                                     8'h31 : //1
    (copy_cnt == 6'd5 || copy_cnt == 6'd4)?                                                                 8'h39 : //9
    (copy_cnt == 6'd3)?                                                                                     8'h32 : //2
    (copy_cnt == 6'd2)?                                                                                     8'h2E : //.
                                                                                                            8'h00;  //for copy_cnt == 6'd1
//------------------------------------------------------------------------------

reg [7:0] test_register;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   test_register <= 8'd0;
    else if(cmd_test_register_write)    test_register <= write_buffer[7:0];
end

reg speaker_on;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           speaker_on <= 1'b0;
    else if(sw_reset)           speaker_on <= 1'b0;
    else if(cmd_speaker_on)     speaker_on <= 1'b1;
    else if(cmd_speaker_off)    speaker_on <= 1'b0;
end

reg [15:0] block_size;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           block_size <= 16'd0;
    else if(sw_reset)           block_size <= 16'd0;
    else if(cmd_set_block_size) block_size <= { write_buffer[7:0], write_buffer[15:8] };
end

reg pause_dma;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                   pause_dma <= 1'b0;
    else if(sw_reset)                                                   pause_dma <= 1'b0;
    else if(cmd_dma_pause_start)                                        pause_dma <= 1'b1;
    else if(cmd_dma_pause_end || dma_single_start || dma_auto_start)    pause_dma <= 1'b0;
end

//------------------------------------------------------------------------------ pause dac

wire pause_interrupt = pause_counter == 16'd0 && pause_period == 16'd1;

reg pause_active;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                           pause_active <= 1'b0;
    else if(sw_reset)                                           pause_active <= 1'b0;
    else if(cmd_pause_dac)                                      pause_active <= 1'b1;
    else if(pause_counter == 16'd0 && pause_period == 16'd0)    pause_active <= 1'b0;
end

reg [15:0] pause_counter;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                       pause_counter <= 16'd0;
    else if(sw_reset)                                       pause_counter <= 16'd0;
    else if(cmd_pause_dac)                                  pause_counter <= { write_buffer[7:0], write_buffer[15:8] };
    else if(pause_period == 16'd0 && pause_counter > 16'd0) pause_counter <= pause_counter - 16'd1;
end

reg [15:0] pause_period;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                       pause_period <= 16'd0;
    else if(sw_reset)                                       pause_period <= 16'd0;
    else if(cmd_pause_dac)                                  pause_period <= period_q;
    else if(pause_period == 16'd0 && pause_counter > 16'd0) pause_period <= period_q;
    else if(pause_period > 16'd0)                           pause_period <= pause_period - 16'd1;
end

//------------------------------------------------------------------------------

wire write_ready = midi_uart_mode || highspeed_mode;

reg [1:0] write_length;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                           write_length <= 2'd0;
    else if(sw_reset)                           write_length <= 2'd0;
    else if(cmd_midi_uart || highspeed_start)   write_length <= 2'd0;
    else if(cmd_wait_for_2byte)                 write_length <= 2'd2;
    else if(cmd_wait_for_3byte)                 write_length <= 2'd3;
    else if(write_left == 2'd0)                 write_length <= 2'd0;
end

reg [1:0] write_left;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                               write_left <= 2'd0;
    else if(sw_reset)                                               write_left <= 2'd0;
    else if(cmd_midi_uart || highspeed_start)                       write_left <= 2'd0;
    else if(cmd_wait_for_2byte)                                     write_left <= 2'd1;
    else if(cmd_wait_for_3byte)                                     write_left <= 2'd2;
    else if(io_write && io_address == 4'hC && write_left > 2'd0)    write_left <= write_left - 2'd1;
end

reg [23:0] write_buffer;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                               write_buffer <= 24'd0;
    else if(sw_reset)                                               write_buffer <= 24'd0;
    else if(cmd_wait_for_2byte || cmd_wait_for_3byte)               write_buffer <= { write_buffer[15:0], io_writedata };
    else if(io_write && io_address == 4'hC && write_left > 2'd0)    write_buffer <= { write_buffer[15:0], io_writedata };
end

//------------------------------------------------------------------------------

wire read_ready = ~(midi_uart_mode) && read_buffer_size > 2'd0;

reg [1:0] read_buffer_size;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                   read_buffer_size <= 2'd0;
    else if(sw_reset)                                                   read_buffer_size <= 2'd1;
    else if(cmd_dsp_version)                                            read_buffer_size <= 2'd2;
    else if(cmd_direct_input)                                           read_buffer_size <= 2'd1;
    else if(cmd_midi_uart)                                              read_buffer_size <= 2'd0;
    else if(cmd_speaker_status)                                         read_buffer_size <= 2'd1;
    else if(cmd_dsp_identification)                                     read_buffer_size <= 2'd1;
    else if(cmd_f8_zero)                                                read_buffer_size <= 2'd1;
    else if(cmd_test_register_read)                                     read_buffer_size <= 2'd1;
    else if(cmd_copyright)                                              read_buffer_size <= 2'd0;
    
    else if(io_read_valid && io_address == 4'hA && read_buffer_size > 2'd0) read_buffer_size <= read_buffer_size - 2'd1;
end

reg [15:0] read_buffer;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                   read_buffer <= 16'd0;
    else if(sw_reset)                                                   read_buffer <= { 8'hAA, 8'h00 };
    else if(cmd_dsp_version)                                            read_buffer <= { 8'h02, 8'h01 };
    else if(cmd_direct_input)                                           read_buffer <= { input_sample, 8'h00 };
    else if(cmd_speaker_status)                                         read_buffer <= { (speaker_on)? 8'hFF : 8'h00, 8'h00 };
    else if(cmd_dsp_identification)                                     read_buffer <= { ~(write_buffer[7:0]), 8'h00 };
    else if(cmd_f8_zero)                                                read_buffer <= { 8'h00, 8'h00 };
    else if(cmd_test_register_read)                                     read_buffer <= { test_register, 8'h00 };
    
    else if(io_read_valid && io_address == 4'hA && read_buffer_size > 2'd0) read_buffer <= { read_buffer[7:0], 8'd0 };
end

//------------------------------------------------------------------------------ irq

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                               irq <= 1'b0;
    else if(sw_reset)                                               irq <= 1'b0;
    
    else if(dma_finished || dma_auto_restart || pause_interrupt)    irq <= 1'b1;
    else if(cmd_trigger_irq)                                        irq <= 1'b1;
    
    else if(io_read_valid && io_address == 4'hE)                    irq <= 1'b0;
end

//------------------------------------------------------------------------------ dma commands

localparam [4:0] S_IDLE                 = 5'd0;
localparam [4:0] S_OUT_SINGLE_8_BIT     = 5'd1;
localparam [4:0] S_OUT_SINGLE_4_BIT     = 5'd2;
localparam [4:0] S_OUT_SINGLE_3_BIT     = 5'd3;
localparam [4:0] S_OUT_SINGLE_2_BIT     = 5'd4;
localparam [4:0] S_OUT_SINGLE_4_BIT_REF = 5'd5;
localparam [4:0] S_OUT_SINGLE_3_BIT_REF = 5'd6;
localparam [4:0] S_OUT_SINGLE_2_BIT_REF = 5'd7;
localparam [4:0] S_OUT_AUTO_8_BIT       = 5'd8;
localparam [4:0] S_OUT_AUTO_4_BIT_REF   = 5'd9;
localparam [4:0] S_OUT_AUTO_3_BIT_REF   = 5'd10;
localparam [4:0] S_OUT_AUTO_2_BIT_REF   = 5'd11;
localparam [4:0] S_IN_SINGLE            = 5'd12;
localparam [4:0] S_IN_AUTO              = 5'd13;
localparam [4:0] S_OUT_SINGLE_HIGH      = 5'd14;
localparam [4:0] S_OUT_AUTO_HIGH        = 5'd15;
localparam [4:0] S_IN_SINGLE_HIGH       = 5'd16;
localparam [4:0] S_IN_AUTO_HIGH         = 5'd17;

reg [4:0] dma_command;

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                           dma_command <= S_IDLE;
    else if(sw_reset)                           dma_command <= S_IDLE;
    
    else if(cmd_single_dma_output)              dma_command <= S_OUT_SINGLE_8_BIT;
    else if(cmd_single_4_adpcm_out)             dma_command <= S_OUT_SINGLE_4_BIT;
    else if(cmd_single_3_adpcm_out)             dma_command <= S_OUT_SINGLE_3_BIT;
    else if(cmd_single_2_adpcm_out)             dma_command <= S_OUT_SINGLE_2_BIT;
    
    else if(cmd_single_4_adpcm_out_ref)         dma_command <= S_OUT_SINGLE_4_BIT_REF;
    else if(cmd_single_3_adpcm_out_ref)         dma_command <= S_OUT_SINGLE_3_BIT_REF;
    else if(cmd_single_2_adpcm_out_ref)         dma_command <= S_OUT_SINGLE_2_BIT_REF;
    
    else if(cmd_auto_dma_out)                   dma_command <= S_OUT_AUTO_8_BIT;
    else if(cmd_auto_4_adpcm_out_ref)           dma_command <= S_OUT_AUTO_4_BIT_REF;
    else if(cmd_auto_3_adpcm_out_ref)           dma_command <= S_OUT_AUTO_3_BIT_REF;
    else if(cmd_auto_2_adpcm_out_ref)           dma_command <= S_OUT_AUTO_2_BIT_REF;
    
    else if(cmd_single_dma_input)               dma_command <= S_IN_SINGLE;
    else if(cmd_auto_dma_input)                 dma_command <= S_IN_AUTO;
    
    else if(cmd_high_single_dma_out)            dma_command <= S_OUT_SINGLE_HIGH;
    else if(cmd_high_auto_dma_out)              dma_command <= S_OUT_AUTO_HIGH;
    
    else if(cmd_high_single_dma_input)          dma_command <= S_IN_SINGLE_HIGH;
    else if(cmd_high_auto_dma_input)            dma_command <= S_IN_AUTO_HIGH;
    
    else if(dma_single_start || dma_auto_start) dma_command <= S_IDLE;
end

//------------------------------------------------------------------------------ dma

wire dma_single_start = dma_restart_possible && (
    dma_command == S_OUT_SINGLE_8_BIT || dma_command == S_OUT_SINGLE_4_BIT     || dma_command == S_OUT_SINGLE_3_BIT     || dma_command == S_OUT_SINGLE_2_BIT     ||
                                         dma_command == S_OUT_SINGLE_4_BIT_REF || dma_command == S_OUT_SINGLE_3_BIT_REF || dma_command == S_OUT_SINGLE_2_BIT_REF ||
    dma_command == S_IN_SINGLE ||
    dma_command == S_OUT_SINGLE_HIGH || dma_command == S_IN_SINGLE_HIGH
);

wire dma_auto_start = dma_restart_possible && (
    dma_command == S_OUT_AUTO_8_BIT || dma_command == S_OUT_AUTO_4_BIT_REF || dma_command == S_OUT_AUTO_3_BIT_REF || dma_command == S_OUT_AUTO_2_BIT_REF ||
    dma_command == S_IN_AUTO ||
    dma_command == S_OUT_AUTO_HIGH || dma_command == S_IN_AUTO_HIGH
);

wire dma_normal_req = dma_in_progress && dma_wait == 16'd0 && adpcm_wait == 2'd0 && ~(pause_dma);

assign dma_soundblaster_req = dma_id_active || dma_normal_req;

wire dma_valid  = dma_normal_req && dma_soundblaster_ack && ~(dma_id_active);
wire dma_output = ~(dma_is_input) && dma_valid;
wire dma_input  = dma_is_input    && dma_valid;

wire dma_finished = dma_in_progress && ~(dma_autoinit) && (
    (dma_valid && dma_left == 17'd1 && adpcm_type == ADPCM_NONE) ||
    (adpcm_output && dma_left == 17'd0 && adpcm_type != ADPCM_NONE && adpcm_wait == 2'd1)
);
    
wire dma_auto_restart = dma_in_progress && dma_autoinit && (
    (dma_valid && dma_left == 17'd1 && adpcm_type == ADPCM_NONE) ||
    (adpcm_output && dma_left == 17'd0 && adpcm_type != ADPCM_NONE && adpcm_wait == 2'd1)
);

wire dma_restart_possible = dma_wait == 16'd0 && (adpcm_wait == 2'd0 || (adpcm_type != ADPCM_NONE && adpcm_wait == 2'd1)) && (~(dma_in_progress) || dma_auto_restart || pause_dma);

reg [16:0] dma_left;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                           dma_left <= 17'd0;
    else if(sw_reset)                           dma_left <= 17'd0;
    else if(dma_single_start)                   dma_left <= { write_buffer[7:0], write_buffer[15:8] } + 16'd1;
    else if(dma_auto_start || dma_auto_restart) dma_left <= block_size + 16'd1;
    else if(dma_valid && dma_left > 17'd0)      dma_left <= dma_left - 17'd1;
    else if(dma_finished)                       dma_left <= 17'd0;
end

reg dma_in_progress;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                           dma_in_progress <= 1'b0;
    else if(sw_reset)                           dma_in_progress <= 1'b0;
    else if(dma_single_start || dma_auto_start) dma_in_progress <= 1'b1;
    else if(dma_finished)                       dma_in_progress <= 1'b0;
end

reg dma_is_input;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                                                                                                               dma_is_input <= 1'b0;
    else if(sw_reset)                                                                                                                                                               dma_is_input <= 1'b0;
    else if((dma_single_start || dma_auto_start) && (dma_command == S_IN_SINGLE || dma_command == S_IN_AUTO || dma_command == S_IN_SINGLE_HIGH || dma_command == S_IN_AUTO_HIGH))   dma_is_input <= 1'b1;
    else if(dma_single_start || dma_auto_start)                                                                                                                                     dma_is_input <= 1'b0;
end

reg dma_autoinit;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           dma_autoinit <= 1'b0;
    else if(sw_reset)           dma_autoinit <= 1'b0;
    else if(dma_single_start)   dma_autoinit <= 1'b0;
    else if(dma_auto_start)     dma_autoinit <= 1'b1;
    else if(cmd_auto_dma_exit)  dma_autoinit <= 1'b0;
end

reg [15:0] dma_wait;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                                                   dma_wait <= 16'd0;
    else if(sw_reset)                                                                                                   dma_wait <= 16'd0;
    else if(dma_finished || dma_valid || adpcm_output || (~(dma_in_progress) && (dma_single_start || dma_auto_start)))  dma_wait <= period_q;
    else if(dma_wait > 16'd0)                                                                                           dma_wait <= dma_wait - 16'd1;
end

//------------------------------------------------------------------------------ adpcm

localparam [1:0] ADPCM_NONE = 2'd0;
localparam [1:0] ADPCM_4BIT = 2'd1;
localparam [1:0] ADPCM_3BIT = 2'd2;
localparam [1:0] ADPCM_2BIT = 2'd3;

wire adpcm_reference_start = 
    (dma_single_start || dma_auto_start) && (
    dma_command == S_OUT_SINGLE_2_BIT_REF || dma_command == S_OUT_SINGLE_3_BIT_REF || dma_command == S_OUT_SINGLE_4_BIT_REF ||
    dma_command == S_OUT_AUTO_2_BIT_REF   || dma_command == S_OUT_AUTO_3_BIT_REF   || dma_command == S_OUT_AUTO_4_BIT_REF
);

wire adpcm_output = dma_wait == 16'd0 && adpcm_wait > 2'd0;

reg adpcm_reference_awaiting;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               adpcm_reference_awaiting <= 1'b0;
    else if(sw_reset)                               adpcm_reference_awaiting <= 1'b0;
    else if(adpcm_reference_start)                  adpcm_reference_awaiting <= 1'b1;
    else if(dma_single_start || dma_auto_start)     adpcm_reference_awaiting <= 1'b0;
    else if(adpcm_reference_awaiting && dma_output) adpcm_reference_awaiting <= 1'b0;
    else if(dma_finished)                           adpcm_reference_awaiting <= 1'b0;
end

reg adpcm_reference_output;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   adpcm_reference_output <= 1'b0;
    else                adpcm_reference_output <= adpcm_reference_awaiting;
end

reg [1:0] adpcm_wait;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               adpcm_wait <= 2'd0;
    else if(sw_reset)                               adpcm_wait <= 2'd0;
    else if(dma_single_start || dma_auto_start)     adpcm_wait <= 2'd0;
    else if(adpcm_reference_awaiting && dma_output) adpcm_wait <= 2'd0;
    else if(dma_output && adpcm_type == ADPCM_2BIT) adpcm_wait <= 2'd3;
    else if(dma_output && adpcm_type == ADPCM_3BIT) adpcm_wait <= 2'd2;
    else if(dma_output && adpcm_type == ADPCM_4BIT) adpcm_wait <= 2'd1;
    else if(adpcm_output && adpcm_wait > 2'd0)      adpcm_wait <= adpcm_wait - 2'd1;
end

reg [7:0] adpcm_sample;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   adpcm_sample <= 8'd0;
    else if(sw_reset)                                   adpcm_sample <= 8'd0;
    else if(dma_output)                                 adpcm_sample <= dma_soundblaster_readdata;
    else if(adpcm_output && adpcm_type == ADPCM_2BIT)   adpcm_sample <= { adpcm_sample[5:0], 2'b0 };
    else if(adpcm_output && adpcm_type == ADPCM_3BIT)   adpcm_sample <= { adpcm_sample[4:0], 3'b0 };
    else if(adpcm_output && adpcm_type == ADPCM_4BIT)   adpcm_sample <= { adpcm_sample[3:0], 4'b0 };
end

reg adpcm_active;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   adpcm_active <= 1'b0;
    else if(sw_reset)                                   adpcm_active <= 1'b0;
    else if(adpcm_reference_awaiting && dma_output)     adpcm_active <= 1'b0;
    else if(adpcm_type != ADPCM_NONE && dma_output)     adpcm_active <= 1'b1;
    else if(adpcm_output)                               adpcm_active <= 1'b1;
    else                                                adpcm_active <= 1'b0;
end

wire [7:0] adpcm_active_value =
    (adpcm_type == ADPCM_2BIT)?     adpcm_2bit_reference_next :
    (adpcm_type == ADPCM_3BIT)?     adpcm_3bit_reference_next :
                                    adpcm_4bit_reference_next;

reg [1:0] adpcm_type;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                                                                                                       adpcm_type <= ADPCM_NONE;
    else if(sw_reset)                                                                                                                                                       adpcm_type <= ADPCM_NONE;
    else if((dma_single_start || dma_auto_start) && (dma_command == S_OUT_SINGLE_2_BIT_REF || dma_command == S_OUT_SINGLE_2_BIT || dma_command == S_OUT_AUTO_2_BIT_REF))    adpcm_type <= ADPCM_2BIT;
    else if((dma_single_start || dma_auto_start) && (dma_command == S_OUT_SINGLE_3_BIT_REF || dma_command == S_OUT_SINGLE_3_BIT || dma_command == S_OUT_AUTO_3_BIT_REF))    adpcm_type <= ADPCM_3BIT;
    else if((dma_single_start || dma_auto_start) && (dma_command == S_OUT_SINGLE_4_BIT_REF || dma_command == S_OUT_SINGLE_4_BIT || dma_command == S_OUT_AUTO_4_BIT_REF))    adpcm_type <= ADPCM_4BIT;
    else if((dma_single_start || dma_auto_start))                                                                                                                           adpcm_type <= ADPCM_NONE;
    else if(dma_finished)                                                                                                                                                   adpcm_type <= ADPCM_NONE;
end

reg [2:0] adpcm_step;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   adpcm_step <= 3'd0;
    else if(sw_reset)                                   adpcm_step <= 3'd0;
    else if(adpcm_active && adpcm_type == ADPCM_2BIT)   adpcm_step <= adpcm_2bit_step_next;
    else if(adpcm_active && adpcm_type == ADPCM_3BIT)   adpcm_step <= adpcm_3bit_step_next;
    else if(adpcm_active && adpcm_type == ADPCM_4BIT)   adpcm_step <= adpcm_4bit_step_next;
    else if(adpcm_reference_awaiting && dma_output)     adpcm_step <= 3'd0;
end

reg [7:0] adpcm_reference;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   adpcm_reference <= 8'd0;
    else if(sw_reset)                                   adpcm_reference <= 8'd0;
    else if(adpcm_active && adpcm_type == ADPCM_2BIT)   adpcm_reference <= adpcm_2bit_reference_next;
    else if(adpcm_active && adpcm_type == ADPCM_3BIT)   adpcm_reference <= adpcm_3bit_reference_next;
    else if(adpcm_active && adpcm_type == ADPCM_4BIT)   adpcm_reference <= adpcm_4bit_reference_next;
    else if(adpcm_reference_awaiting && dma_output)     adpcm_reference <= dma_soundblaster_readdata;
end

//------------------------------------------------------------------------------ adpcm 2 bit

wire [1:0] adpcm_2bit_sample = adpcm_sample[7:6];

wire [7:0] adpcm_2bit_reference_adjust =
    (adpcm_step[2:0] == 3'd0)?      { 7'd0, adpcm_2bit_sample[0] } :
    (adpcm_step[2:0] == 3'd1)?      { 6'd0, adpcm_2bit_sample[0], 1'b1 } :
    (adpcm_step[2:0] == 3'd2)?      { 5'd0, adpcm_2bit_sample[0], 2'b10 } :
    (adpcm_step[2:0] == 3'd3)?      { 4'd0, adpcm_2bit_sample[0], 3'b100 } :
    (adpcm_step[2:0] == 3'd4)?      { 3'd0, adpcm_2bit_sample[0], 4'b1000 } :
                                    { 2'd0, adpcm_2bit_sample[0], 5'b10000 }; //adpcm_step[2:0] == 3'd5

wire [8:0] adpcm_2bit_reference_sum = adpcm_reference + adpcm_2bit_reference_adjust;
wire [8:0] adpcm_2bit_reference_sub = adpcm_reference - adpcm_2bit_reference_adjust;

wire [7:0] adpcm_2bit_reference_next =
    (adpcm_2bit_sample[1] && adpcm_2bit_reference_sub[8])?  8'd0 :
    (adpcm_2bit_sample[1])?                                 adpcm_2bit_reference_sub[7:0] :
    (adpcm_2bit_reference_sum[8])?                          8'd255 :
                                                            adpcm_2bit_reference_sum[7:0];
wire [2:0] adpcm_2bit_step_next =
    (adpcm_step < 3'd5 && adpcm_2bit_sample[0] == 1'b1)?    adpcm_step + 3'd1 :
    (adpcm_step > 3'd0 && adpcm_2bit_sample[0] == 1'b0)?    adpcm_step - 3'd1 :
                                                            adpcm_step;

//------------------------------------------------------------------------------ adpcm 3 bit

wire [2:0] adpcm_3bit_sample = adpcm_sample[7:5];

wire [7:0] adpcm_3bit_reference_adjust =
    (adpcm_step[2:0] == 3'd0)?                                  { 6'd0, adpcm_3bit_sample[1:0] } :
    (adpcm_step[2:0] == 3'd1)?                                  { 5'd0, adpcm_3bit_sample[1:0], 1'b1 } :
    (adpcm_step[2:0] == 3'd2)?                                  { 4'd0, adpcm_3bit_sample[1:0], 2'b10 } :
    (adpcm_step[2:0] == 3'd3)?                                  { 3'd0, adpcm_3bit_sample[1:0], 3'b100 } :
    (adpcm_step[2:0] == 3'd4 && adpcm_3bit_sample == 3'd0)?     8'd5 :
    (adpcm_step[2:0] == 3'd4 && adpcm_3bit_sample == 3'd1)?     8'd15 :
    (adpcm_step[2:0] == 3'd4 && adpcm_3bit_sample == 3'd2)?     8'd25 :
                                                                8'd35;
    
wire [8:0] adpcm_3bit_reference_sum = adpcm_reference + adpcm_3bit_reference_adjust;
wire [8:0] adpcm_3bit_reference_sub = adpcm_reference - adpcm_3bit_reference_adjust;

wire [7:0] adpcm_3bit_reference_next =
    (adpcm_3bit_sample[2] && adpcm_3bit_reference_sub[8])?  8'd0 :
    (adpcm_3bit_sample[2])?                                 adpcm_3bit_reference_sub[7:0] :
    (adpcm_3bit_reference_sum[8])?                          8'd255 :
                                                            adpcm_3bit_reference_sum[7:0];
wire [2:0] adpcm_3bit_step_next =
    (adpcm_step < 3'd4 && adpcm_3bit_sample[1:0] == 2'b11)? adpcm_step + 3'd1 :
    (adpcm_step > 3'd0 && adpcm_3bit_sample[1:0] == 2'b00)? adpcm_step - 3'd1 :
                                                            adpcm_step;

//------------------------------------------------------------------------------ adpcm 4 bit

wire [3:0] adpcm_4bit_sample = adpcm_sample[7:4];

wire [7:0] adpcm_4bit_reference_adjust =
    (adpcm_step[2:0] == 3'd0)?      { 5'd0, adpcm_4bit_sample[2:0] } :
    (adpcm_step[2:0] == 3'd1)?      { 4'd0, adpcm_4bit_sample[2:0], 1'b1 } :
    (adpcm_step[2:0] == 3'd2)?      { 3'd0, adpcm_4bit_sample[2:0], 2'b10 } :
                                    { 2'd0, adpcm_4bit_sample[2:0], 3'b100 }; //adpcm_step[2:0] == 3'd3
    
wire [8:0] adpcm_4bit_reference_sum = adpcm_reference + adpcm_4bit_reference_adjust;
wire [8:0] adpcm_4bit_reference_sub = adpcm_reference - adpcm_4bit_reference_adjust;

wire [7:0] adpcm_4bit_reference_next =
    (adpcm_4bit_sample[3] && adpcm_4bit_reference_sub[8])?  8'd0 :
    (adpcm_4bit_sample[3])?                                 adpcm_4bit_reference_sub[7:0] :
    (adpcm_4bit_reference_sum[8])?                          8'd255 :
                                                            adpcm_4bit_reference_sum[7:0];
wire [2:0] adpcm_4bit_step_next =
    (adpcm_step < 3'd3 && adpcm_4bit_sample[2:0] >= 3'd5)?  adpcm_step + 3'd1 :
    (adpcm_step > 3'd0 && adpcm_4bit_sample[2:0] == 3'd0)?  adpcm_step - 3'd1 :
                                                            adpcm_step;

//------------------------------------------------------------------------------

reg [7:0] period_address;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               period_address <= 8'd128;
    else if(sw_reset)               period_address <= 8'd128;
    else if(cmd_set_time_constant)  period_address <= write_buffer[7:0];
end

wire [15:0] period_q;

simple_ram #(
    .widthad    (8),
    .width      (16)
)
period_ram_inst(
    .clk                (clk),
    
    .wraddress          (mgmt_address[7:0]),
    .wren               (mgmt_write && mgmt_address[8] == 1'b0),
    .data               (mgmt_writedata[15:0]),
    
    .rdaddress          (period_address),
    .q                  (period_q)
);

//------------------------------------------------------------------------------

assign sample_from_dsp_disabled = ~(speaker_on) || pause_active;
assign sample_from_dsp_do = ~(sample_from_dsp_disabled) && ((dma_output && adpcm_type == ADPCM_NONE) || cmd_direct_output || adpcm_active || (~(adpcm_reference_awaiting) && adpcm_reference_output));

assign sample_from_dsp_value =
    (adpcm_reference_output)?   adpcm_sample :
    (adpcm_active)?             adpcm_active_value :
    (dma_output)?               dma_soundblaster_readdata :
                                write_buffer[7:0];

//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0, mgmt_writedata[31:16], dma_soundblaster_terminal, 1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------

endmodule
