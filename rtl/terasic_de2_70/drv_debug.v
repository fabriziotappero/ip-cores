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
 * \brief Switches and hex leds driver for debug purposes.
 */

/*! \brief \copybrief drv_debug.v
*/
module drv_debug(
    //% \name Clock and reset
    //% @{
    input           CLK_I,
    input           reset_n,
    //% @}
    
    //% \name Internal debug signals
    //% @{
    input [31:2]    master_adr_o,
    input [31:0]    debug_pc,
    input [7:0]     debug_syscon,
    input [7:0]     debug_track,
    //% @}
    
    //% \name Switches and hex leds hardware interface
    //% @{
    // hex output
    output [7:0]    hex0,
    output [7:0]    hex1,
    output [7:0]    hex2,
    output [7:0]    hex3,
    output [7:0]    hex4,
    output [7:0]    hex5,
    output [7:0]    hex6,
    output [7:0]    hex7,
    // switches input
    input           debug_sw_pc,
    input           debug_sw_adr
    //% @}
);

assign hex0 =
    (display[3:0] == 4'd0) ?    ~8'b00111111 :
    (display[3:0] == 4'd1) ?    ~8'b00000110 :
    (display[3:0] == 4'd2) ?    ~8'b01011011 :
    (display[3:0] == 4'd3) ?    ~8'b01001111 :
    (display[3:0] == 4'd4) ?    ~8'b01100110 :
    (display[3:0] == 4'd5) ?    ~8'b01101101 :
    (display[3:0] == 4'd6) ?    ~8'b01111101 :
    (display[3:0] == 4'd7) ?    ~8'b00000111 :
    (display[3:0] == 4'd8) ?    ~8'b01111111 :
    (display[3:0] == 4'd9) ?    ~8'b01101111 :
    (display[3:0] == 4'd10) ?   ~8'b01110111 :
    (display[3:0] == 4'd11) ?   ~8'b01111100 :
    (display[3:0] == 4'd12) ?   ~8'b00111001 :
    (display[3:0] == 4'd13) ?   ~8'b01011110 :
    (display[3:0] == 4'd14) ?   ~8'b01111001 :
                                ~8'b01110001;
assign hex1 =
    (display[7:4] == 4'd0) ?    ~8'b00111111 :
    (display[7:4] == 4'd1) ?    ~8'b00000110 :
    (display[7:4] == 4'd2) ?    ~8'b01011011 :
    (display[7:4] == 4'd3) ?    ~8'b01001111 :
    (display[7:4] == 4'd4) ?    ~8'b01100110 :
    (display[7:4] == 4'd5) ?    ~8'b01101101 :
    (display[7:4] == 4'd6) ?    ~8'b01111101 :
    (display[7:4] == 4'd7) ?    ~8'b00000111 :
    (display[7:4] == 4'd8) ?    ~8'b01111111 :
    (display[7:4] == 4'd9) ?    ~8'b01101111 :
    (display[7:4] == 4'd10) ?   ~8'b01110111 :
    (display[7:4] == 4'd11) ?   ~8'b01111100 :
    (display[7:4] == 4'd12) ?   ~8'b00111001 :
    (display[7:4] == 4'd13) ?   ~8'b01011110 :
    (display[7:4] == 4'd14) ?   ~8'b01111001 :
                                ~8'b01110001;
assign hex2 =
    (display[11:8] == 4'd0) ?   ~8'b00111111 :
    (display[11:8] == 4'd1) ?   ~8'b00000110 :
    (display[11:8] == 4'd2) ?   ~8'b01011011 :
    (display[11:8] == 4'd3) ?   ~8'b01001111 :
    (display[11:8] == 4'd4) ?   ~8'b01100110 :
    (display[11:8] == 4'd5) ?   ~8'b01101101 :
    (display[11:8] == 4'd6) ?   ~8'b01111101 :
    (display[11:8] == 4'd7) ?   ~8'b00000111 :
    (display[11:8] == 4'd8) ?   ~8'b01111111 :
    (display[11:8] == 4'd9) ?   ~8'b01101111 :
    (display[11:8] == 4'd10) ?  ~8'b01110111 :
    (display[11:8] == 4'd11) ?  ~8'b01111100 :
    (display[11:8] == 4'd12) ?  ~8'b00111001 :
    (display[11:8] == 4'd13) ?  ~8'b01011110 :
    (display[11:8] == 4'd14) ?  ~8'b01111001 :
                                ~8'b01110001;
assign hex3 =
    (display[15:12] == 4'd0) ?  ~8'b00111111 :
    (display[15:12] == 4'd1) ?  ~8'b00000110 :
    (display[15:12] == 4'd2) ?  ~8'b01011011 :
    (display[15:12] == 4'd3) ?  ~8'b01001111 :
    (display[15:12] == 4'd4) ?  ~8'b01100110 :
    (display[15:12] == 4'd5) ?  ~8'b01101101 :
    (display[15:12] == 4'd6) ?  ~8'b01111101 :
    (display[15:12] == 4'd7) ?  ~8'b00000111 :
    (display[15:12] == 4'd8) ?  ~8'b01111111 :
    (display[15:12] == 4'd9) ?  ~8'b01101111 :
    (display[15:12] == 4'd10) ? ~8'b01110111 :
    (display[15:12] == 4'd11) ? ~8'b01111100 :
    (display[15:12] == 4'd12) ? ~8'b00111001 :
    (display[15:12] == 4'd13) ? ~8'b01011110 :
    (display[15:12] == 4'd14) ? ~8'b01111001 :
                                ~8'b01110001;
assign hex4 =
    (display[19:16] == 4'd0) ?  ~8'b00111111 :
    (display[19:16] == 4'd1) ?  ~8'b00000110 :
    (display[19:16] == 4'd2) ?  ~8'b01011011 :
    (display[19:16] == 4'd3) ?  ~8'b01001111 :
    (display[19:16] == 4'd4) ?  ~8'b01100110 :
    (display[19:16] == 4'd5) ?  ~8'b01101101 :
    (display[19:16] == 4'd6) ?  ~8'b01111101 :
    (display[19:16] == 4'd7) ?  ~8'b00000111 :
    (display[19:16] == 4'd8) ?  ~8'b01111111 :
    (display[19:16] == 4'd9) ?  ~8'b01101111 :
    (display[19:16] == 4'd10) ? ~8'b01110111 :
    (display[19:16] == 4'd11) ? ~8'b01111100 :
    (display[19:16] == 4'd12) ? ~8'b00111001 :
    (display[19:16] == 4'd13) ? ~8'b01011110 :
    (display[19:16] == 4'd14) ? ~8'b01111001 :
                                ~8'b01110001;
assign hex5 =
    (display[23:20] == 4'd0) ?  ~8'b00111111 :
    (display[23:20] == 4'd1) ?  ~8'b00000110 :
    (display[23:20] == 4'd2) ?  ~8'b01011011 :
    (display[23:20] == 4'd3) ?  ~8'b01001111 :
    (display[23:20] == 4'd4) ?  ~8'b01100110 :
    (display[23:20] == 4'd5) ?  ~8'b01101101 :
    (display[23:20] == 4'd6) ?  ~8'b01111101 :
    (display[23:20] == 4'd7) ?  ~8'b00000111 :
    (display[23:20] == 4'd8) ?  ~8'b01111111 :
    (display[23:20] == 4'd9) ?  ~8'b01101111 :
    (display[23:20] == 4'd10) ? ~8'b01110111 :
    (display[23:20] == 4'd11) ? ~8'b01111100 :
    (display[23:20] == 4'd12) ? ~8'b00111001 :
    (display[23:20] == 4'd13) ? ~8'b01011110 :
    (display[23:20] == 4'd14) ? ~8'b01111001 :
                                ~8'b01110001;
assign hex6 =
    (display[27:24] == 4'd0) ?  ~8'b00111111 :
    (display[27:24] == 4'd1) ?  ~8'b00000110 :
    (display[27:24] == 4'd2) ?  ~8'b01011011 :
    (display[27:24] == 4'd3) ?  ~8'b01001111 :
    (display[27:24] == 4'd4) ?  ~8'b01100110 :
    (display[27:24] == 4'd5) ?  ~8'b01101101 :
    (display[27:24] == 4'd6) ?  ~8'b01111101 :
    (display[27:24] == 4'd7) ?  ~8'b00000111 :
    (display[27:24] == 4'd8) ?  ~8'b01111111 :
    (display[27:24] == 4'd9) ?  ~8'b01101111 :
    (display[27:24] == 4'd10) ? ~8'b01110111 :
    (display[27:24] == 4'd11) ? ~8'b01111100 :
    (display[27:24] == 4'd12) ? ~8'b00111001 :
    (display[27:24] == 4'd13) ? ~8'b01011110 :
    (display[27:24] == 4'd14) ? ~8'b01111001 :
                                ~8'b01110001;
assign hex7 =
    (display[31:28] == 4'd0) ?  ~8'b00111111 :
    (display[31:28] == 4'd1) ?  ~8'b00000110 :
    (display[31:28] == 4'd2) ?  ~8'b01011011 :
    (display[31:28] == 4'd3) ?  ~8'b01001111 :
    (display[31:28] == 4'd4) ?  ~8'b01100110 :
    (display[31:28] == 4'd5) ?  ~8'b01101101 :
    (display[31:28] == 4'd6) ?  ~8'b01111101 :
    (display[31:28] == 4'd7) ?  ~8'b00000111 :
    (display[31:28] == 4'd8) ?  ~8'b01111111 :
    (display[31:28] == 4'd9) ?  ~8'b01101111 :
    (display[31:28] == 4'd10) ? ~8'b01110111 :
    (display[31:28] == 4'd11) ? ~8'b01111100 :
    (display[31:28] == 4'd12) ? ~8'b00111001 :
    (display[31:28] == 4'd13) ? ~8'b01011110 :
    (display[31:28] == 4'd14) ? ~8'b01111001 :
                                ~8'b01110001;
reg [31:0] display;

always @(posedge CLK_I or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        display <= 32'd0;
    end
    else begin
        if(debug_sw_pc == 1'b1)         display <= debug_pc;
        else if(debug_sw_adr == 1'b1)   display <= {master_adr_o[31:2], 2'b00 };
        else                            display <= { debug_track, 16'd0, debug_syscon };
    end
end
endmodule

// ---------------- general DEBUG
/*
wire debug_write;
assign debug_write =    master1_cyc_o == 1'b1 && master1_stb_o == 1'b1 && master1_we_o == 1'b0 && master1_adr_o != last_addr &&
                        ({master1_adr_o[31:2], 2'b00} >= 32'h00DFF000) && ({master1_adr_o[31:2], 2'b00} <= 32'h00DFF01C);

reg [11:0] debug_addr;
reg [31:2] last_addr;
always @(posedge clk_30 or negedge reset_n) begin
    if(reset_n == 1'b0)                                         last_addr <= 30'd0;
    else                                                        last_addr <= master1_adr_o;                           
end

always @(posedge clk_30 or negedge reset_n) begin
    if(reset_n == 1'b0)                                       debug_addr <= 12'd0;
    else if(debug_write == 1'b1 //&& debug_addr < 12'd4095//) debug_addr <= debug_addr + 12'd1;
end

altsyncram debug_ram_inst(
    .clock0(clk_30),

    .address_a(debug_addr),
    .wren_a(debug_write == 1'b1),
    .data_a( { 3'b0, master1_adr_o[8:2], 2'b00} ),
    .q_a()
);
defparam 
    debug_ram_inst.operation_mode = "SINGLE_PORT",
    debug_ram_inst.width_a = 12,
    debug_ram_inst.lpm_hint = "ENABLE_RUNTIME_MOD=YES,INSTANCE_NAME=mem",
    debug_ram_inst.widthad_a = 12;
*/

/*
// ----------------------------- copper DEBUG
wire debug_write;
assign debug_write = (state == S_SAVE && ACK_I == 1'b1);

reg [7:0] debug_addr;
always @(posedge CLK_I) begin
    if(line_start == 1'b1 && line_number == 9'd0)   debug_addr <= 8'd0;
    else if(debug_write == 1'b1 && debug_addr < 8'd255) debug_addr <= debug_addr + 8'd1;
end

altsyncram debug_ram_inst(
    .clock0(CLK_I),

    .address_a(debug_addr),
    .wren_a(debug_write == 1'b1),
    .data_a({3'b0, line_number, ir}),
    .q_a()
);
defparam 
    debug_ram_inst.operation_mode = "SINGLE_PORT",
    debug_ram_inst.width_a = 60,
    debug_ram_inst.lpm_hint = "ENABLE_RUNTIME_MOD=YES,INSTANCE_NAME=cop",
    debug_ram_inst.widthad_a = 8;
*/

//------------------------- video DEBUG
/*
altsyncram debug_ram_inst(
    .clock0(CLK_I),

    .address_a(bitplain_ram_addr),
    .wren_a(burst_read_ready == 1'b1 && burst_read_request == 1'b1 && line_number == 9'hF4),
    .data_a({dma_address_full, (dma_address_full[1] == 1'b0) ? burst_read_data : {even_data, burst_read_data[31:16]}, 3'b0, burst_read_enabled }),
    .q_a()
);
defparam 
    debug_ram_inst.operation_mode = "SINGLE_PORT",
    debug_ram_inst.width_a = 68,
    debug_ram_inst.lpm_hint = "ENABLE_RUNTIME_MOD=YES,INSTANCE_NAME=bpl",
    debug_ram_inst.widthad_a = 5;
*/
/*
wire debug_write;
assign debug_write = (line_number >= 9'd64 && write_ena == 1'b1 && write_address == 1'b0);

reg [7:0] debug_addr;
always @(posedge CLK_I or negedge reset_n) begin
    if(reset_n == 1'b0)             debug_addr <= 8'd0;
    else if(debug_write == 1'b1)    debug_addr <= debug_addr + 8'd1;
end

altsyncram debug_ram_inst(
    .clock0(CLK_I),

    .address_a(debug_addr),
    .wren_a(debug_write == 1'b1),
    .data_a( { 3'b0, line_number, 3'b0, column_number, 2'b0, dma_state, write_sel, write_data, dma_address_full } ),
    .q_a()
);
defparam 
    debug_ram_inst.operation_mode = "SINGLE_PORT",
    debug_ram_inst.width_a = 96,
    debug_ram_inst.lpm_hint = "ENABLE_RUNTIME_MOD=YES,INSTANCE_NAME=mem",
    debug_ram_inst.widthad_a = 8;
*/

// ---------------- floppy DEBUG
/*
wire debug_write;
assign debug_write = (buffer_read_cycle == 1'b1 && state != S_WRITE_TO_SD);

reg [7:0] debug_addr;
always @(posedge clk_30 or negedge reset_n) begin
    if(reset_n == 1'b0)                                         debug_addr <= 8'd0;
    else if(debug_write == 1'b1 && debug_addr < 8'd255)         debug_addr <= debug_addr + 8'd1;
end

altsyncram debug_ram_inst(
    .clock0(clk_30),

    .address_a(debug_addr),
    .wren_a(debug_write == 1'b1),
    .data_a( { mfm_decoder[11:8], dsklen, dskptr, 4'b1111 } ),
    .q_a()
);
defparam 
    debug_ram_inst.operation_mode = "SINGLE_PORT",
    debug_ram_inst.width_a = 56,
    debug_ram_inst.lpm_hint = "ENABLE_RUNTIME_MOD=YES,INSTANCE_NAME=flop",
    debug_ram_inst.widthad_a = 8;
*/

//------------------------------------------------- video_priority DEBUG
/*
altsyncram debug_ram_inst(
    .clock0(CLK_I),

    .address_a(line_ram_addr),
    .wren_a(line_ena == 1'b1 && line_number == 9'd150 && column_number >= 9'h81 &&
        ((column_number == 9'h1C1 && line_ram_counter == 3'd1) || (column_number < 9'h1C1 && line_ram_counter == 3'd3))),
    .data_a((column_number == 9'h1C1 && line_ram_counter == 3'd1)? { final_color_value, 24'd0 } : { line_ram_data[23:0], final_color_value }),
    .q_a()
);
defparam 
    debug_ram_inst.operation_mode = "SINGLE_PORT",
    debug_ram_inst.width_a = 36,
    debug_ram_inst.lpm_hint = "ENABLE_RUNTIME_MOD=YES,INSTANCE_NAME=mem",
    debug_ram_inst.widthad_a = 8;
*/

// ----------------------------- cia8520 DEBUG
/*
wire debug_write;
assign debug_write =    (last_irq_n == 1'b1 && irq_n == 1'b0);

reg last_irq_n;
always @(posedge CLK_I or negedge reset_n) begin
    if(reset_n == 1'b0) last_irq_n <= 1'b1;
    else                last_irq_n <= irq_n;
end

reg [7:0] debug_addr;
always @(posedge CLK_I) begin
    if(debug_write == 1'b1 && debug_addr < 8'd255) debug_addr <= debug_addr + 8'd1;
end

altsyncram debug_ram_inst(
    .clock0(CLK_I),

    .address_a(debug_addr),
    .wren_a(debug_write == 1'b1),
    .data_a( {2'b0, icr_mask, 2'b0, icr_data, last_cnt_i, cnt_i, cra, serial_latch } ),
    .q_a()
);
defparam 
    debug_ram_inst.operation_mode = "SINGLE_PORT",
    debug_ram_inst.width_a = 32,
    debug_ram_inst.lpm_hint = "ENABLE_RUNTIME_MOD=YES,INSTANCE_NAME=cia",
    debug_ram_inst.widthad_a = 8;
*/
