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

module sound(
    input               clk,
    input               rst_n,
    
    output              irq,
    
    //speaker input
    input               speaker_enable,
    input               speaker_out,
    
    //io slave 220h-22Fh
    input       [3:0]   io_address,
    input               io_read,
    output reg  [7:0]   io_readdata,
    input               io_write,
    input       [7:0]   io_writedata,
    
    //fm music io slave 388h-389h
    input               fm_address,
    input               fm_read,
    output      [7:0]   fm_readdata,
    input               fm_write,
    input       [7:0]   fm_writedata,

    //dma
    output              dma_soundblaster_req,
    input               dma_soundblaster_ack,
    input               dma_soundblaster_terminal,
    input       [7:0]   dma_soundblaster_readdata,
    output      [7:0]   dma_soundblaster_writedata,
    
    //sound interface master
    output      [2:0]   avm_address,
    input               avm_waitrequest,
    output              avm_write,
    output      [31:0]  avm_writedata,
    
    //mgmt slave
    /*
    0-255.[15:0]: cycles in period
    256.[12:0]:  cycles in 80us
    257.[9:0]:   cycles in 1 sample: 96000 Hz
    */
    input       [8:0]   mgmt_address,
    input               mgmt_write,
    input       [31:0]  mgmt_writedata
);

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------ dsp

wire [7:0] io_readdata_from_dsp;

wire       sample_from_dsp_disabled;
wire       sample_from_dsp_do;
wire [7:0] sample_from_dsp_value;

sound_dsp sound_dsp_inst(
    .clk                        (clk),
    .rst_n                      (rst_n),
    
    .irq                        (irq),                          //output
    
    //io slave 220h-22Fh
    .io_address                 (io_address),                   //input [3:0]
    .io_read                    (io_read),                      //input
    .io_readdata_from_dsp       (io_readdata_from_dsp),         //output [7:0]
    .io_write                   (io_write),                     //input
    .io_writedata               (io_writedata),                 //input [7:0]
    
    //dma
    .dma_soundblaster_req       (dma_soundblaster_req),         //output
    .dma_soundblaster_ack       (dma_soundblaster_ack),         //input
    .dma_soundblaster_terminal  (dma_soundblaster_terminal),    //input
    .dma_soundblaster_readdata  (dma_soundblaster_readdata),    //input [7:0]
    .dma_soundblaster_writedata (dma_soundblaster_writedata),   //output [7:0]
    
    //sample
    .sample_from_dsp_disabled   (sample_from_dsp_disabled),     //output
    .sample_from_dsp_do         (sample_from_dsp_do),           //output
    .sample_from_dsp_value      (sample_from_dsp_value),        //output [7:0] unsigned
    
    //mgmt slave
    /*
    0-255.[15:0]: cycles in period
    */
    .mgmt_address               (mgmt_address),                 //input [8:0]
    .mgmt_write                 (mgmt_write),                   //input
    .mgmt_writedata             (mgmt_writedata)                //input [31:0]
);

//------------------------------------------------------------------------------ opl2

wire [7:0] sb_readdata_from_opl2;

wire        sample_from_opl2;
wire [15:0] sample_from_opl2_value;

sound_opl2 sound_opl2_inst(
    .clk                        (clk),
    .rst_n                      (rst_n),
    
    //sb slave 220h-22Fh
    .sb_address                 (io_address),               //input [3:0]
    .sb_read                    (io_read),                  //input
    .sb_readdata_from_opl2      (sb_readdata_from_opl2),    //output [7:0]
    .sb_write                   (io_write),                 //input
    .sb_writedata               (io_writedata),             //input [7:0]
    
    
    //fm music io slave 388h-389h
    .fm_address                 (fm_address),               //input
    .fm_read                    (fm_read),                  //input
    .fm_readdata                (fm_readdata),              //output [7:0]
    .fm_write                   (fm_write),                 //input
    .fm_writedata               (fm_writedata),             //input [7:0]
    
    //sample
    .sample_from_opl2           (sample_from_opl2),         //output
    .sample_from_opl2_value     (sample_from_opl2_value),   //output [15:0]
    
    //mgmt slave
    /*
    256.[12:0]:  cycles in 80us
    257.[9:0]:   cycles in 1 sample: 96000 Hz
    */
    .mgmt_address               (mgmt_address),   //input [8:0]
    .mgmt_write                 (mgmt_write),     //input
    .mgmt_writedata             (mgmt_writedata)  //input [31:0]
);

//------------------------------------------------------------------------------ io_readdata

wire [7:0] io_readdata_next =
    (io_address == 4'h8 || io_address == 4'h9)?     sb_readdata_from_opl2 :
                                                    io_readdata_from_dsp;
    
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   io_readdata <= 8'd0;
    else                io_readdata <= io_readdata_next;
end

//------------------------------------------------------------------------------ speaker

reg [15:0] speaker_value;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               speaker_value <= 16'd0;
    else if(speaker_enable && speaker_out == 1'b0)  speaker_value <= 16'd16384;
    else if(speaker_enable && speaker_out == 1'b1)  speaker_value <= 16'd49152;
    else                                            speaker_value <= 16'd0;
end

//------------------------------------------------------------------------------

reg [15:0] sample_dsp;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   sample_dsp <= 16'd0;
    else if(sample_from_dsp_disabled)   sample_dsp <= 16'd0;
    else if(sample_from_dsp_do)         sample_dsp <= { sample_from_dsp_value, 8'd0 } - 16'd32768; //unsigned to signed
end

reg [15:0] sample_opl2;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           sample_opl2 <= 16'd0;
    else if(sample_from_opl2)   sample_opl2 <= sample_from_opl2_value; //already signed
end

wire [15:0] sample_sum_1 = sample_dsp + sample_opl2;

wire [15:0] sample_next_1 = (sample_dsp[15] == 1'b0 && sample_opl2[15] == 1'b0 && sample_sum_1[15] == 1'b1)?   16'd32767 :
                            (sample_dsp[15] == 1'b1 && sample_opl2[15] == 1'b1 && sample_sum_1[15] == 1'b0)?   16'd32768 :
                                                                                                               sample_sum_1[15:0];
reg [15:0] sample_sum_1_reg;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               sample_sum_1_reg <= 16'd0;
    else if(state == STATE_LOAD_1)  sample_sum_1_reg <= sample_next_1;
end

wire [15:0] sample_sum_2 = sample_sum_1_reg + speaker_value;

wire [15:0] sample_next_2 = (sample_sum_1_reg[15] == 1'b0 && speaker_value[15] == 1'b0 && sample_sum_2[15] == 1'b1)?    16'd32767 :
                            (sample_sum_1_reg[15] == 1'b1 && speaker_value[15] == 1'b1 && sample_sum_2[15] == 1'b0)?    16'd32768 :
                                                                                                                        sample_sum_2[15:0];

//------------------------------------------------------------------------------

localparam [1:0] STATE_IDLE   = 2'd0;
localparam [1:0] STATE_LOAD_1 = 2'd1;
localparam [1:0] STATE_LOAD_2 = 2'd2;
localparam [1:0] STATE_WRITE  = 2'd3;

reg [1:0] state;

reg [15:0] sample_sum_2_reg;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               sample_sum_2_reg <= 16'd0;
    else if(state == STATE_LOAD_2)  sample_sum_2_reg <= sample_next_2;
end

assign avm_address   = 3'd0;
assign avm_writedata = { 16'd0, sample_sum_2_reg }; //signed
assign avm_write     = state == STATE_WRITE;

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   state <= STATE_IDLE;
    else if(state == STATE_IDLE && sample_from_opl2)    state <= STATE_LOAD_1;
    else if(state == STATE_LOAD_1)                      state <= STATE_LOAD_2;
    else if(state == STATE_LOAD_2)                      state <= STATE_WRITE;
    else if(state == STATE_WRITE && ~(avm_waitrequest)) state <= STATE_IDLE;
end

//------------------------------------------------------------------------------

endmodule
