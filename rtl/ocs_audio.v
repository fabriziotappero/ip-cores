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
 * \brief OCS audio implementation with WISHBONE master and slave interface.
 */

/*! \brief \copybrief ocs_audio.v

List of audio registers:
\verbatim
Implemented:
    AUD0LCH   +  0A0  W   A( E )  Audio channel 0 location (high 3 bits, 5 if ECS)
    AUD0LCL   +  0A2  W   A       Audio channel 0 location (low 15 bits) (horiz. position)
    AUD0LEN      0A4  W   P       Audio channel 0 length
    AUD0PER      0A6  W   P( E )  Audio channel 0 period
    AUD0VOL      0A8  W   P       Audio channel 0 volume
    AUD0DAT   &  0AA  W   P       Audio channel 0 data
    
    AUD1LCH   +  0B0  W   A       Audio channel 1 location (high 3 bits)
    AUD1LCL   +  0B2  W   A       Audio channel 1 location (low 15 bits)
    AUD1LEN      0B4  W   P       Audio channel 1 length
    AUD1PER      0B6  W   P       Audio channel 1 period
    AUD1VOL      0B8  W   P       Audio channel 1 volume
    AUD1DAT   &  0BA  W   P       Audio channel 1 data
    
    AUD2LCH   +  0C0  W   A       Audio channel 2 location (high 3 bits)
    AUD2LCL   +  0C2  W   A       Audio channel 2 location (low 15 bits)
    AUD2LEN      0C4  W   P       Audio channel 2 length
    AUD2PER      0C6  W   P       Audio channel 2 period
    AUD2VOL      0C8  W   P       Audio channel 2 volume
    AUD2DAT   &  0CA  W   P       Audio channel 2 data
    
    AUD3LCH   +  0D0  W   A       Audio channel 3 location (high 3 bits)
    AUD3LCL   +  0D2  W   A       Audio channel 3 location (low 15 bits)
    AUD3LEN      0D4  W   P       Audio channel 3 length
    AUD3PER      0D6  W   P       Audio channel 3 period
    AUD3VOL      0D8  W   P       Audio channel 3 volume
    AUD3DAT   &  0DA  W   P       Audio channel 3 data
\endverbatim
*/
module ocs_audio(
    //% \name Clock and reset
    //% @{
    input           CLK_I,
    input           reset_n,
    //% @}
    
    //% \name WISHBONE master
    //% @{
    output reg      CYC_O,
    output reg      STB_O,
    output          WE_O,
    output [31:2]   ADR_O,
    output [3:0]    SEL_O,
    input [31:0]    master_DAT_I,
    input           ACK_I,
    //% @}
    
    //% \name WISHBONE slave
    //% @{
    input           CYC_I,
    input           STB_I,
    input           WE_I,
    input [8:2]     ADR_I,
    input [3:0]     SEL_I,
    input [31:0]    slave_DAT_I,
    output reg      ACK_O,
    //% @}
    
    //% \name Internal OCS ports
    //% @{
    input           pulse_color,
    input           line_start,
    
    input [10:0]    dma_con,
    input [14:0]    adk_con,
    
    output [3:0]    audio_irq,
    //% @}
    
    //% \name drv_audio interface
    //% @{
    output [5:0] volume0,
    output [5:0] volume1,
    output [5:0] volume2,
    output [5:0] volume3,
    output [7:0] sample0,
    output [7:0] sample1,
    output [7:0] sample2,
    output [7:0] sample3
    //% @}
);

assign WE_O = 1'b0;
assign SEL_O = 4'b1111;

assign volume0 = (adk_con[0] == 1'b1 || adk_con[4] == 1'b1) ? 6'd0 : (channel0_volume[6] == 1'b1) ? 6'b111111 : channel0_volume[5:0];
assign volume1 = (adk_con[1] == 1'b1 || adk_con[5] == 1'b1) ? 6'd0 : (channel1_volume[6] == 1'b1) ? 6'b111111 : channel1_volume[5:0];
assign volume2 = (adk_con[2] == 1'b1 || adk_con[6] == 1'b1) ? 6'd0 : (channel2_volume[6] == 1'b1) ? 6'b111111 : channel2_volume[5:0];
assign volume3 = (adk_con[3] == 1'b1 || adk_con[7] == 1'b1) ? 6'd0 : (channel3_volume[6] == 1'b1) ? 6'b111111 : channel3_volume[5:0];

wire [3:0] dma_reqs;
wire [1:0] selected_channel;
assign selected_channel = 
    (dma_reqs[0] == 1'b1) ? 2'd0 :
    (dma_reqs[1] == 1'b1) ? 2'd1 :
    (dma_reqs[2] == 1'b1) ? 2'd2 :
    2'd3;

assign ADR_O =
    (selected_channel == 3'd0) ? dma_address0[31:2] :
    (selected_channel == 3'd1) ? dma_address1[31:2] :
    (selected_channel == 3'd2) ? dma_address2[31:2] :
    dma_address3[31:2];

wire dma_req;
assign dma_req = dma_reqs[0] | dma_reqs[1] | dma_reqs[2] | dma_reqs[3];

//*************** Channel 0
wire [6:0] channel0_volume;
wire [15:0] channel0_data;
wire [1:0] channel0_update;
wire [31:0] dma_address0;

wire write_ena_extern0;
assign write_ena_extern0 = (CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b1 &&
    (  { ADR_I, 2'b0 } == 9'h0A0 || { ADR_I, 2'b0 } == 9'h0A4 || { ADR_I, 2'b0 } == 9'h0A8 ) );
wire write_ena0;
assign write_ena0 = write_ena_extern0;

wire [1:0] write_address0;
assign write_address0 =
    ({ ADR_I, 2'b0 } == 9'h0A0) ? 2'd0 :
    ({ ADR_I, 2'b0 } == 9'h0A4) ? 2'd1 :
    2'd2;

wire [31:0] write_data0;
assign write_data0 = slave_DAT_I;

wire [3:0] write_sel0;
assign write_sel0 = SEL_I;

sound_channel sound_channel_0(
    .CLK_I(CLK_I),
    .reset_n(reset_n),
    
    .pulse_color(pulse_color),
    .line_start(line_start),
    
    .dma_ena(dma_con[9] == 1'b1 && dma_con[0] == 1'b1),
    .dma_req(dma_reqs[0]),
    .dma_address(dma_address0),
    .dma_done(selected_channel == 2'd0 && ACK_I == 1'b1),
    .dma_data(master_DAT_I),
    
    .write_ena(write_ena0),
    .write_address(write_address0),
    .write_data(write_data0),
    .write_sel(write_sel0),
    
    .irq(audio_irq[0]),
    
    .volume(channel0_volume),
    .sample(sample0),
    .is_modulator_channel(adk_con[0] == 1'b1 || adk_con[4] == 1'b1),
    .data(channel0_data),
    .data_update(channel0_update)
);


//*************** Channel 1
wire [6:0] channel1_volume;
wire [15:0] channel1_data;
wire [1:0] channel1_update;
wire [31:0] dma_address1;

wire write_ena_extern1;
assign write_ena_extern1 = (CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b1 &&
    (  { ADR_I, 2'b0 } == 9'h0B0 || { ADR_I, 2'b0 } == 9'h0B4 || { ADR_I, 2'b0 } == 9'h0B8) );
wire write_ena1;
assign write_ena1 = ((adk_con[0] == 1'b1 || adk_con[4] == 1'b1) && (channel0_update == 2'b10 || channel0_update == 2'b11)) || write_ena_extern1;

wire [1:0] write_address1;
assign write_address1 = 
    write_ena_extern1 ? (
        ({ ADR_I, 2'b0 } == 9'h0B0) ? 2'd0 :
        ({ ADR_I, 2'b0 } == 9'h0B4) ? 2'd1 :
        2'd2
    ) :
    (adk_con[0] == 1'b1 && adk_con[4] == 1'b0) ? 2'd2 :
    (adk_con[0] == 1'b0 && adk_con[4] == 1'b1) ? 2'd1 :
    (channel0_update == 2'b10) ? 2'd2 :
    2'd1;
    
wire [3:0] write_sel1;
assign write_sel1 =
    write_ena_extern1 ? SEL_I :
    (adk_con[0] == 1'b1 && adk_con[4] == 1'b0) ? 4'b1100 :
    (adk_con[0] == 1'b0 && adk_con[4] == 1'b1) ? 4'b0011 :
    (channel0_update == 2'b10) ? 4'b1100 :
    4'b0011;

wire [31:0] write_data1;
assign write_data1 = 
    write_ena_extern1 ? slave_DAT_I :
    channel0_data;

sound_channel sound_channel_1(
    .CLK_I(CLK_I),
    .reset_n(reset_n),
    
    .pulse_color(pulse_color),
    .line_start(line_start),
    
    .dma_ena(dma_con[9] == 1'b1 && dma_con[1] == 1'b1),
    .dma_req(dma_reqs[1]),
    .dma_address(dma_address1),
    .dma_done(selected_channel == 2'd1 && ACK_I == 1'b1),
    .dma_data(master_DAT_I),
    
    .write_ena(write_ena1),
    .write_address(write_address1),
    .write_data(write_data1),
    .write_sel(write_sel1),
    
    .irq(audio_irq[1]),
    
    .volume(channel1_volume),
    .sample(sample1),
    .is_modulator_channel(adk_con[1] == 1'b1 || adk_con[5] == 1'b1),
    .data(channel1_data),
    .data_update(channel1_update)
);

//*************** Channel 2
wire [6:0] channel2_volume;
wire [15:0] channel2_data;
wire [1:0] channel2_update;
wire [31:0] dma_address2;
wire [7:0] channel2_sample;

wire write_ena_extern2;
assign write_ena_extern2 = (CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b1 &&
    (  { ADR_I, 2'b0 } == 9'h0C0 || { ADR_I, 2'b0 } == 9'h0C4 || { ADR_I, 2'b0 } == 9'h0C8) );
wire write_ena2;
assign write_ena2 = ((adk_con[1] == 1'b1 || adk_con[5] == 1'b1) && (channel1_update == 2'b10 || channel1_update == 2'b11)) || write_ena_extern2;

wire [1:0] write_address2;
assign write_address2 = 
    write_ena_extern2 ? (
        ({ ADR_I, 2'b0 } == 9'h0C0) ? 2'd0 :
        ({ ADR_I, 2'b0 } == 9'h0C4) ? 2'd1 :
        2'd2
    ) :
    (adk_con[1] == 1'b1 && adk_con[5] == 1'b0) ? 2'd2 :
    (adk_con[1] == 1'b0 && adk_con[5] == 1'b1) ? 2'd1 :
    (channel1_update == 2'b10) ? 2'd2 :
    2'd1;
    
wire [3:0] write_sel2;
assign write_sel2 =
    write_ena_extern2 ? SEL_I :
    (adk_con[1] == 1'b1 && adk_con[5] == 1'b0) ? 4'b1100 :
    (adk_con[1] == 1'b0 && adk_con[5] == 1'b1) ? 4'b0011 :
    (channel1_update == 2'b10) ? 4'b1100 :
    4'b0011;

wire [31:0] write_data2;
assign write_data2 = 
    write_ena_extern2 ? slave_DAT_I :
    channel1_data;

sound_channel sound_channel_2(
    .CLK_I(CLK_I),
    .reset_n(reset_n),
    
    .pulse_color(pulse_color),
    .line_start(line_start),
    
    .dma_ena(dma_con[9] == 1'b1 && dma_con[2] == 1'b1),
    .dma_req(dma_reqs[2]),
    .dma_address(dma_address2),
    .dma_done(selected_channel == 2'd2 && ACK_I == 1'b1),
    .dma_data(master_DAT_I),
    
    .write_ena(write_ena2),
    .write_address(write_address2),
    .write_data(write_data2),
    .write_sel(write_sel2),
    
    .irq(audio_irq[2]),
    
    .volume(channel2_volume),
    .sample(sample2),
    .is_modulator_channel(adk_con[2] == 1'b1 || adk_con[6] == 1'b1),
    .data(channel2_data),
    .data_update(channel2_update)
);

//****************** Channel 3
wire [6:0] channel3_volume;
wire [15:0] channel3_data;
wire [1:0] channel3_update;
wire [31:0] dma_address3;

wire write_ena_extern3;
assign write_ena_extern3 = (CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b1 &&
    ( { ADR_I, 2'b0 } == 9'h0D0 || { ADR_I, 2'b0 } == 9'h0D4 || { ADR_I, 2'b0 } == 9'h0D8) );
wire write_ena3;
assign write_ena3 = ((adk_con[2] == 1'b1 || adk_con[6] == 1'b1) && (channel2_update == 2'b10 || channel2_update == 2'b11)) || write_ena_extern3;

wire [1:0] write_address3;
assign write_address3 = 
    write_ena_extern3 ? (
        ({ ADR_I, 2'b0 } == 9'h0D0) ? 2'd0 :
        ({ ADR_I, 2'b0 } == 9'h0D4) ? 2'd1 :
        2'd2
    ) :
    (adk_con[2] == 1'b1 && adk_con[6] == 1'b0) ? 2'd2 :
    (adk_con[2] == 1'b0 && adk_con[6] == 1'b1) ? 2'd1 :
    (channel2_update == 2'b10) ? 2'd2 :
    2'd1;
    
wire [3:0] write_sel3;
assign write_sel3 =
    write_ena_extern3 ? SEL_I :
    (adk_con[2] == 1'b1 && adk_con[6] == 1'b0) ? 4'b1100 :
    (adk_con[2] == 1'b0 && adk_con[6] == 1'b1) ? 4'b0011 :
    (channel2_update == 2'b10) ? 4'b1100 :
    4'b0011;

wire [31:0] write_data3;
assign write_data3 = 
    write_ena_extern3 ? slave_DAT_I :
    channel2_data;

sound_channel sound_channel_3(
    .CLK_I(CLK_I),
    .reset_n(reset_n),
    
    .pulse_color(pulse_color),
    .line_start(line_start),
    
    .dma_ena(dma_con[9] == 1'b1 && dma_con[3] == 1'b1),
    .dma_req(dma_reqs[3]),
    .dma_address(dma_address3),
    .dma_done(selected_channel == 2'd3 && ACK_I == 1'b1),
    .dma_data(master_DAT_I),
    
    .write_ena(write_ena3),
    .write_address(write_address3),
    .write_data(write_data3),
    .write_sel(write_sel3),
    
    .irq(audio_irq[3]),
    
    .volume(channel3_volume),
    .sample(sample3),
    .is_modulator_channel(adk_con[3] == 1'b1 || adk_con[7] == 1'b1),
    .data(channel3_data),
    .data_update(channel3_update)
);

always @(posedge CLK_I or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        CYC_O <= 1'b0;
        STB_O <= 1'b0;
        ACK_O <= 1'b0;
    end
    else begin
        if(ACK_O == 1'b1) begin
            ACK_O <= 1'b0;
        end
        else if(write_ena_extern0 == 1'b1 || write_ena_extern1 == 1'b1 || write_ena_extern2 == 1'b1 || write_ena_extern3 == 1'b1 ||
            (CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b0))
        begin
            ACK_O <= 1'b1;
        end
        
        if(CYC_O == 1'b0 && STB_O == 1'b0 && dma_req == 1'b1) begin
            CYC_O <= 1'b1;
            STB_O <= 1'b1;
        end
        else if(CYC_O == 1'b1 && STB_O == 1'b1 && ACK_I == 1'b1) begin
            CYC_O <= 1'b0;
            STB_O <= 1'b0;
        end
         
    end
end

endmodule

/*! \brief Single audio channel.
 */
module sound_channel(
    input               CLK_I,
    input               reset_n,
    
    // color pulse
    input               pulse_color,
    input               line_start,
    
    input               dma_ena,
    output reg          dma_req,
    output reg [31:0]   dma_address,
    input               dma_done,
    input [31:0]        dma_data,
    
    input               write_ena,
    // 0:   AUDxLCH,    AUDxLCL,
    // 1:   AUDxLEN,    AUDxPER,
    // 2:   AUDxVOL,    AUDxDAT,
    input [1:0]         write_address,
    input [31:0]        write_data,
    input [3:0]         write_sel,
    
    output reg          irq,
    
    // sound interface
    // 0-63,64 only
    output reg [6:0]    volume,
    output reg [7:0]    sample,
    input               is_modulator_channel,
    // volume[6:0]:  modulation
    // period[15:0]: modulation
    output reg [15:0]   data,
    // 2'b01: 8 bit sample update only
    // 2'b10: 8 bit sample and even word update
    // 2'b11: 8 bit sample and odd word update
    output reg [1:0]    data_update
);

reg [31:0] location;
reg [15:0] length;
reg [16:0] length_left;
reg [15:0] period;
reg [15:0] period_left;
reg even_word;
reg [15:0] data2;
reg [1:0] avail;
reg [1:0] state;

parameter [1:0]
    S_IDLE      = 2'd0,
    S_DIRECT    = 2'd1,
    S_DMA       = 2'd2;

always @(posedge CLK_I or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        dma_req <= 1'b0;
        dma_address <= 32'd0;
        irq <= 1'b0;
        volume <= 7'd0;
        sample <= 8'd0;
        data <= 16'd0;
        data_update <= 2'b00;
        
        location <= 32'd0;
        length <= 16'd0;
        length_left <= 17'd0;
        period <= 16'd0;
        period_left <= 16'd0;
        even_word <= 1'b0;
        data2 <= 16'd0;
        avail <= 2'd0;
        state <= S_IDLE;
    end
    else begin
        
        if(irq == 1'b1)             irq <= 1'b0;
        if(data_update != 2'b00)    data_update <= 2'b00;
        
        if(state == S_IDLE && dma_ena == 1'b0 && write_ena == 1'b1 && write_address == 2'd2 && write_sel[1:0] != 2'b00) begin
            state <= S_DIRECT;
            length_left <= 17'd2;
            period_left <= period;
            even_word <= 1'b0;
            avail <= 2'd0;
        end
        else if((state == S_DIRECT && dma_ena == 1'b1) || (state == S_DMA && dma_ena == 1'b0)) begin
            state <= S_IDLE;
        end
        else if(state == S_IDLE && dma_ena == 1'b1 && line_start == 1'b1 && length > 17'd0) begin
            state <= S_DMA;
            dma_address <= location;
            length_left <= { length, 1'b0 };
            period_left <= period;
            irq <= 1'b1;
            even_word <= 1'b0;
            avail <= 2'd0;
            
            dma_req <= 1'b1;
        end
        else if(state == S_DMA && line_start == 1'b1 && avail < 2'd2) begin
            dma_req <= 1'b1;
        end
        else if(state == S_DMA && dma_done == 1'b1) begin
            dma_req <= 1'b0;
            avail <= avail + 2'd1;
            dma_address <= dma_address + 32'd2;
        end
        
        if((state == S_DIRECT || state == S_DMA) && pulse_color == 1'b1) begin
            if(period_left > 16'd1) begin
                period_left <= period_left - 16'd1;
            end
            else begin
                period_left <= period;
                
                if(is_modulator_channel == 1'b0)    data_update <= 2'b01;
                else if(even_word == 1'b0)          data_update <= 2'b10;
                else                                data_update <= 2'b11;
                
                if(is_modulator_channel == 1'b1)    even_word <= ~even_word;
                
                if(length_left[0] == 1'b0)          sample <= data[15:8];
                else                                sample <= data[7:0];
                
                if(avail > 2'd0 && (is_modulator_channel == 1'b1 || length_left[0] == 1'b1)) begin
                    if(avail == 2'd2) data <= data2;
                    avail <= avail - 2'd1;
                end
                
                if((is_modulator_channel == 1'b1 && length_left <= 17'd2) || length_left <= 17'd1) begin
                    length_left <= 17'd0;
                    state <= S_IDLE;
                    if(state == S_DIRECT) irq <= 1'b1;
                end
                else if(is_modulator_channel == 1'b1)   length_left <= length_left - 17'd2;
                else                                    length_left <= length_left - 17'd1;
            end
        end
        
        if(write_ena == 1'b1) begin
            if(write_address == 2'd0 && write_sel[0] == 1'b1) location[7:0] <= write_data[7:0];
            if(write_address == 2'd0 && write_sel[1] == 1'b1) location[15:8] <= write_data[15:8];
            if(write_address == 2'd0 && write_sel[2] == 1'b1) location[23:16] <= write_data[23:16];
            if(write_address == 2'd0 && write_sel[3] == 1'b1) location[31:24] <= write_data[31:24];
            if(write_address == 2'd1 && write_sel[0] == 1'b1) period[7:0] <= write_data[7:0];
            if(write_address == 2'd1 && write_sel[1] == 1'b1) period[15:8] <= write_data[15:8];
            if(write_address == 2'd1 && write_sel[2] == 1'b1) length[7:0] <= write_data[23:16];
            if(write_address == 2'd1 && write_sel[3] == 1'b1) length[15:8] <= write_data[31:24];
            if(write_address == 2'd2 && write_sel[0] == 1'b1) data[7:0] <= write_data[7:0];
            if(write_address == 2'd2 && write_sel[1] == 1'b1) data[15:8] <= write_data[15:8];
            if(write_address == 2'd2 && write_sel[2] == 1'b1) volume[6:0] <= write_data[22:16];
            if(write_address == 2'd2 && write_sel[3] == 1'b1) ;
        end
        else if(dma_done == 1'b1) begin
            if(avail == 2'd0) begin
                if(dma_address[1] == 1'b0)  data <= dma_data[31:16];
                else                        data <= dma_data[15:0];
            end
            else begin
                if(dma_address[1] == 1'b0)  data2 <= dma_data[31:16];
                else                        data2 <= dma_data[15:0];
            end
        end
        
    end
end


endmodule



