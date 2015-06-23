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
 * \brief OCS floppy implementation with WISHBONE master and slave interface.
 */

/*! \brief \copybrief ocs_floppy.v

List of floppy registers:
\verbatim
Implemented:
     [SERDATR   *018  R   P       Serial port data and status read              read not implemented here]
    DSKBYTR     *01A  R   P       Disk data byte and status read                read not implemented here

    DSKPTH    + *020  W   A( E )  Disk pointer (high 3 bits, 5 bits if ECS)
    DSKPTL    + *022  W   A       Disk pointer (low 15 bits)
    DSKLEN      *024  W   P       Disk length
    DSKDAT    & *026  W   P       Disk DMA data write
    
        [not used 07C]
    DSKSYNC     ~07E  W   P       Disk sync pattern register for disk read

Not implemented:
    DSKDATR   & *008  ER  P       Disk data early read (dummy address)          not implemented
     [JOY0DAT   *00A  R   D       Joystick-mouse 0 data (vert,horiz)            read not implemented here]
\endverbatim
*/
module ocs_floppy(
    //% \name Clock and reset
    //% @{
    input               CLK_I,
    input               reset_n,
    //% @}
    
    //% \name On-Screen-Display floppy management interface
    //% @{
    input               floppy_inserted,
    input [31:0]        floppy_sector,
    input               floppy_write_enabled,
    output reg          floppy_error,
    //% @}
    
    //% \name WISHBONE master
    //% @{
    output reg          CYC_O,
    output reg          STB_O,
    output reg          WE_O,
    output reg [31:2]   ADR_O,
    output reg [3:0]    SEL_O,
    output reg [31:0]   master_DAT_O,
    input [31:0]        master_DAT_I,
    input               ACK_I,
    //% @}
    
    //% \name WISHBONE slave for OCS registers
    //% @{
    input               CYC_I,
    input               STB_I,
    input               WE_I,
    input [8:2]         ADR_I,
    input [3:0]         SEL_I,
    input [31:0]        slave_DAT_I,
    output reg          ACK_O,
    //% @}
    
    //% \name WISHBONE slave for floppy buffer
    //% @{
    input               buffer_CYC_I,
    input               buffer_STB_I,
    input               buffer_WE_I,
    input [13:2]        buffer_ADR_I,
    input [3:0]         buffer_SEL_I,
    input [31:0]        buffer_DAT_I,
    output [31:0]       buffer_DAT_O,
    output reg          buffer_ACK_O,
    //% @}
    
    //% \name Not aligned register access on a 32-bit WISHBONE bus
    //% @{
        // DSKBYTR read not implemented here
    input               na_dskbytr_read,
    output [15:0]       na_dskbytr,
    //% @}
    
    //% \name Internal OCS ports
    //% @{
    input               line_start,
    
    input [10:0]        dma_con,
    input [14:0]        adk_con,

    output reg          floppy_syn_irq,
    output reg          floppy_blk_irq,
    //% @}
    
    //% \name Floppy CIA interface
    //% @{
    output              fl_rdy_n,
    output              fl_tk0_n,
    output              fl_wpro_n,
    output              fl_chng_n,
    output              fl_index_n,

    input               fl_mtr_n,
    input [3:0]         fl_sel_n,
    input               fl_side_n,
    input               fl_dir,
    input               fl_step_n,
    //% @}
    
    //% \name Debug signals
    //% @{
    output [7:0]        debug_floppy,
    output [7:0]        debug_track
    //% @}
);

reg [33:0]  mfm_encoder;
reg [31:0]  checksum;
reg [3:0]   sector;

reg         last_checksum_bit;
reg [31:0]  first_long_word;

wire [63:0] mfm_output = {
    ~mfm_encoder[33] & ~mfm_encoder[31], mfm_encoder[31], ~mfm_encoder[31] & ~mfm_encoder[29], mfm_encoder[29],
    ~mfm_encoder[29] & ~mfm_encoder[27], mfm_encoder[27], ~mfm_encoder[27] & ~mfm_encoder[25], mfm_encoder[25],
    ~mfm_encoder[25] & ~mfm_encoder[23], mfm_encoder[23], ~mfm_encoder[23] & ~mfm_encoder[21], mfm_encoder[21],
    ~mfm_encoder[21] & ~mfm_encoder[19], mfm_encoder[19], ~mfm_encoder[19] & ~mfm_encoder[17], mfm_encoder[17],
    ~mfm_encoder[17] & ~mfm_encoder[15], mfm_encoder[15], ~mfm_encoder[15] & ~mfm_encoder[13], mfm_encoder[13],
    ~mfm_encoder[13] & ~mfm_encoder[11], mfm_encoder[11], ~mfm_encoder[11] & ~mfm_encoder[9],  mfm_encoder[9],
    ~mfm_encoder[9]  & ~mfm_encoder[7],  mfm_encoder[7],  ~mfm_encoder[7]  & ~mfm_encoder[5],  mfm_encoder[5],
    ~mfm_encoder[5]  & ~mfm_encoder[3],  mfm_encoder[3],  ~mfm_encoder[3]  & ~mfm_encoder[1],  mfm_encoder[1],
    ~mfm_encoder[32] & ~mfm_encoder[30], mfm_encoder[30], ~mfm_encoder[30] & ~mfm_encoder[28], mfm_encoder[28],
    ~mfm_encoder[28] & ~mfm_encoder[26], mfm_encoder[26], ~mfm_encoder[26] & ~mfm_encoder[24], mfm_encoder[24],
    ~mfm_encoder[24] & ~mfm_encoder[22], mfm_encoder[22], ~mfm_encoder[22] & ~mfm_encoder[20], mfm_encoder[20],
    ~mfm_encoder[20] & ~mfm_encoder[18], mfm_encoder[18], ~mfm_encoder[18] & ~mfm_encoder[16], mfm_encoder[16],
    ~mfm_encoder[16] & ~mfm_encoder[14], mfm_encoder[14], ~mfm_encoder[14] & ~mfm_encoder[12], mfm_encoder[12],
    ~mfm_encoder[12] & ~mfm_encoder[10], mfm_encoder[10], ~mfm_encoder[10] & ~mfm_encoder[8],  mfm_encoder[8],
    ~mfm_encoder[8]  & ~mfm_encoder[6],  mfm_encoder[6],  ~mfm_encoder[6]  & ~mfm_encoder[4],  mfm_encoder[4],
    ~mfm_encoder[4]  & ~mfm_encoder[2],  mfm_encoder[2],  ~mfm_encoder[2]  & ~mfm_encoder[0],  mfm_encoder[0]
};

wire [31:0] header = 
    { 8'hFF, {track, 1'b0} + {7'b0, ~last_fl_side_n}, {4'b0, sector}, 8'd11 - {4'b0, sector} };

wire [31:0] masked_checksum = checksum & 32'h55555555;

reg [47:0] output_shift;
reg [15:0] output_first_word;
reg [5:0] output_line_cnt;
reg [5:0] last_output_line_cnt;
reg [4:0] output_shift_cnt;

wire output_shifting = (last_output_line_cnt != 6'd0);
wire output_shifted = (last_dsksync_halt == 1'b0 && last_output_line_cnt != 6'd0 && output_line_cnt == 6'd0);
wire output_index = (last_buffer_addr == 12'd3124 && buffer_addr == 12'd0);
wire write_sector_ready = (buffer_addr == 12'd127);
wire [31:0] output_long_word = { output_first_word, output_shift[47:32] };

//*********************************** FLOPPY BUFFER start
reg [11:0] buffer_addr;
reg [11:0] last_buffer_addr;
reg [8:0] buffer_counter;
reg last_buffer_ACK_O;

wire buffer_write_cycle = 
    (buffer_CYC_I == 1'b1 && buffer_STB_I == 1'b1 && buffer_WE_I == 1'b1 && buffer_SEL_I == 4'b1111 && buffer_ACK_O == 1'b0);
wire buffer_read_cycle = 
    (buffer_CYC_I == 1'b1 && buffer_STB_I == 1'b1 && buffer_WE_I == 1'b0 && buffer_SEL_I == 4'b1111 && buffer_ACK_O == 1'b0);

wire buffer_wren =
    (enable_write == 1'b1)?                                                         1'b1 :
    (buffer_counter >= 9'd1 && buffer_counter <= 9'd14)?                            1'b1 :
    (buffer_counter >= 9'd16 && buffer_counter <= 9'd271 && (buffer_ACK_O == 1'b1 || last_buffer_ACK_O == 1'b1))?  1'b1 :
    (buffer_counter >= 9'd272 && buffer_counter <= 9'd275)?                         1'b1 :
    1'b0;

wire [31:0] buffer_data =
    (enable_write == 1'b1)?                                 master_DAT_O :
    (buffer_counter == 9'd1)?                               32'hAAAAAAAA :
    (buffer_counter == 9'd2)?                               32'h44894489 :
    // insert header, insert header checksum
    (buffer_counter == 9'd3 || buffer_counter == 9'd13)?    mfm_output[63:32] :
    (buffer_counter == 9'd4 || buffer_counter == 9'd14)?    mfm_output[31:0] :
    (buffer_counter == 9'd5)?                               { ~mfm_encoder[0], 1'b0, 2'b10, 28'hAAAAAAA } :
    (buffer_counter <= 9'd14)?                              32'hAAAAAAAA :
    // insert data, count data checksum
    (buffer_counter >= 9'd16 && buffer_counter <= 9'd270 && buffer_counter[0] == 1'b0)? 
                                                            mfm_output[63:32] :
    (buffer_counter >= 9'd17 && buffer_counter <= 9'd271 && buffer_counter[0] == 1'b1)? 
                                                            mfm_output[31:0] :
    // fix first and middle bit
    (buffer_counter == 9'd272 || buffer_counter == 9'd274)? mfm_output[63:32] :
    // write checksum
    (buffer_counter == 9'd273 || buffer_counter == 9'd275)? mfm_output[31:0] :
                                                            32'd0;
wire [31:0] buffer_q;

altsyncram buffer_ram_inst(
    .clock0     (CLK_I),
    .address_a  (buffer_addr),
    .wren_a     (buffer_wren),
    .data_a     (buffer_data),
    .q_a        (buffer_q),
    
    .clock1     (CLK_I),
    .address_b  (buffer_ADR_I),
    .q_b        (buffer_DAT_O)
);
defparam 
    buffer_ram_inst.operation_mode  = "BIDIR_DUAL_PORT",
    buffer_ram_inst.width_a         = 32,
    buffer_ram_inst.widthad_a       = 12,
    buffer_ram_inst.width_b         = 32,
    buffer_ram_inst.widthad_b       = 12,
    buffer_ram_inst.init_file       = "ocs_floppy.mif";
/*  
    buffer_counter
    15->16:     load mfm A, load addr A
    16->17:     store A, load addr A+128
    17->18:     load mfm A+1, store A+128, load addr A+1
    18->19:     store A+1, load addr A+129
    ......
    269->270:   load mfm A+127, store A+254, load addr A+127
    270->271:   store A+127, load addr A+255
    271->272:   store A+255
*/

always @(posedge CLK_I or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        buffer_addr             <= 12'd0;
        last_buffer_addr        <= 12'd0;
        buffer_counter          <= 9'd0;
        mfm_encoder             <= 34'd0;
        checksum                <= 32'd0;
        sector                  <= 4'd0;
        
        last_checksum_bit       <= 1'b0;
        first_long_word         <= 32'd0;
        
        buffer_ACK_O            <= 1'b0;
        last_buffer_ACK_O       <= 1'b0;
        
        output_shift            <= 48'd0;
        output_first_word       <= 16'd0;
        output_line_cnt         <= 6'd0;
        last_output_line_cnt    <= 6'd0;
        output_shift_cnt        <= 5'd0;
    end
    else begin
        last_buffer_ACK_O <= buffer_ACK_O;
        if(buffer_write_cycle == 1'b1 || buffer_read_cycle == 1'b1) buffer_ACK_O <= 1'b1;
        else                                                        buffer_ACK_O <= 1'b0;
        
        if(buffer_counter >= 9'd3 && buffer_counter <= 9'd12)
            checksum <= checksum ^ buffer_data;
        else if(buffer_counter == 9'd14)
            checksum <= 32'd0;
        else if(buffer_counter >= 9'd16 && buffer_counter <= 9'd271 && buffer_wren == 1'b1)
            checksum <= checksum ^ buffer_data;
        else if(buffer_counter == 9'd275)
            checksum <= 32'd0;
        
        if(buffer_counter == 9'd14)     last_checksum_bit <= buffer_data[0];
        if(buffer_counter == 9'd15)     first_long_word <= buffer_DAT_I;
        
        if(buffer_counter == 9'd275 && sector < 4'd10)  sector <= sector + 4'd1;
        else if(buffer_counter == 9'd275)               sector <= 4'd0;
        
        if(start_read == 1'b1) begin
            buffer_counter <= 9'd1;
            buffer_addr <= 12'd0;
            checksum <= 32'd0;
            sector <= 4'd0;
        end
        
        if(buffer_counter >= 9'd1 && buffer_counter <= 9'd14)
            buffer_counter <= buffer_counter + 9'd1;
        else if(buffer_counter >= 9'd15 && buffer_counter <= 9'd269 && buffer_counter[0] == 1'b1 && buffer_write_cycle == 1'b1)
            buffer_counter <= buffer_counter + 9'd1;
        else if(buffer_counter >= 9'd16 && buffer_counter <= 9'd270 && buffer_counter[0] == 1'b0)
            buffer_counter <= buffer_counter + 9'd1;
        else if(buffer_counter >= 9'd271 && buffer_counter <= 9'd274)
            buffer_counter <= buffer_counter + 9'd1;
        else if(buffer_counter == 9'd275 && sector < 4'd10)
            buffer_counter <= 9'd1;
        else if(buffer_counter == 9'd275)
            buffer_counter <= 9'd0;
        
        if(buffer_counter >= 9'd1 && buffer_counter <= 9'd13)
            buffer_addr <= buffer_addr + 12'd1;
        // skip data checksum
        else if(buffer_counter == 9'd14)
            buffer_addr <= buffer_addr + 12'd3;
        else if(buffer_counter >= 9'd17 && buffer_counter <= 9'd269 && buffer_counter[0] == 1'b1 && buffer_write_cycle == 1'b1)
            buffer_addr <= buffer_addr - 12'd128 + 12'd1;
        else if(buffer_counter >= 9'd16 && buffer_counter <= 9'd270 && buffer_counter[0] == 1'b0)
            buffer_addr <= buffer_addr + 12'd128;
        else if(buffer_counter == 9'd271)
            buffer_addr <= buffer_addr - 12'd256 + 12'd1;
        else if(buffer_counter == 9'd272)
            buffer_addr <= buffer_addr + 12'd128;
        else if(buffer_counter == 9'd273)
            buffer_addr <= buffer_addr - 12'd128 - 12'd2;
        else if(buffer_counter == 9'd274)
            buffer_addr <= buffer_addr + 12'd1;
        else if(buffer_counter == 9'd275 && sector < 4'd10)
            buffer_addr <= buffer_addr + 12'd1 + 12'd256;
        else if(buffer_counter == 9'd275)
            buffer_addr <= 12'd0;
        
        if(buffer_counter == 9'd2)
            mfm_encoder <= { 1'b1, header[1], header[31:0] };
        // checksum
        else if(buffer_counter == 9'd12)
            mfm_encoder <= { 1'b0, masked_checksum[1], masked_checksum[31:0] };
        else if(buffer_counter == 9'd15 && buffer_write_cycle == 1'b1)
            mfm_encoder <= { 1'b1, 1'b1, buffer_DAT_I };
        else if(buffer_counter >= 9'd17 && buffer_counter <= 9'd269 && buffer_counter[0] == 1'b1 && buffer_write_cycle == 1'b1)
            mfm_encoder <= { mfm_encoder[1], mfm_encoder[0], buffer_DAT_I};
        else if(buffer_counter == 9'd271)
            mfm_encoder <= { checksum[0]^buffer_data[0], mfm_encoder[1], first_long_word };
        else if(buffer_counter == 9'd273)
            mfm_encoder <= { last_checksum_bit, masked_checksum[1], masked_checksum[31:0] };
        
        last_output_line_cnt <= output_line_cnt;
        last_buffer_addr <= buffer_addr;
        
        if(output_line_cnt == 6'd16) output_first_word[15:0] <= output_shift[47:32];
        
        //if(output_shifted) $display("%08x ", output_long_word);
        
        // read mfm data
        if(buffer_counter == 9'd0 && start_read == 1'b0 && active_write == 1'b0) begin
        
            if(output_line_cnt != 6'd0 && dsksync_halt == 1'b0) begin
                if(output_shift_cnt == 5'd0)    output_shift <= { output_shift[46:32], buffer_q, 1'b0 };
                else                            output_shift <= { output_shift[46:0], 1'b0 };
                
                if(output_shift_cnt == 5'd0) begin
                    if(buffer_addr == 12'd3124) buffer_addr <= 12'd0;
                    else                        buffer_addr <= buffer_addr + 12'd1;
                end
                output_shift_cnt <= output_shift_cnt - 5'd1;
            end
            
            if(output_line_cnt != 6'd0 && dsksync_halt == 1'b1) begin
                output_line_cnt <= 6'd0;
            end
            else if(output_line_cnt != 6'd0) begin
                output_line_cnt <= output_line_cnt - 6'd1;
            end
            else if(line_start == 1'b1) begin
                output_line_cnt <= 6'd32;
            end
        end
        // write data
        else if(buffer_counter == 9'd0 && start_read == 1'b0 && active_write == 1'b1) begin
            if(start_write == 1'b1)         buffer_addr <= 12'd0;
            else if(enable_write == 1'b1)   buffer_addr <= buffer_addr + 12'd1;
        end
        else begin
            output_shift_cnt <= 5'd0;
            output_line_cnt <= 6'd0;
        end
        
    end
end

//*********************************** FLOPPY BUFFER end

assign debug_track = { 1'b0, track };

assign debug_floppy = { last_fl_side_n, adk_con[10], dma_active, state > 4'd7, state };

assign fl_tk0_n     = (fl_sel_n == 4'b1110 && track == 7'd0)? 1'b0 : 1'b1;
assign fl_wpro_n    = (floppy_inserted == 1'b1 && fl_sel_n == 4'b1110)? floppy_write_enabled : 1'b1;
//id bit = 1 for internal drive
assign fl_rdy_n     = (floppy_inserted == 1'b1 && fl_sel_n == 4'b1110 && motor_spinup_delay == 15'd32767)? 1'b0 : 1'b1;
assign fl_chng_n    = (fl_sel_n == 4'b1110)? reg_fl_chng_n : 1'b1;
assign fl_index_n   = (fl_sel_n == 4'b1110)? reg_fl_index_n : 1'b1;

reg [6:0] track;
reg last_fl_step_n;
reg floppy_pos_changed;
reg [3:0] last_fl_sel_n;
reg last_fl_side_n;

reg reg_fl_chng_n;
reg reg_fl_index_n;
reg reg_fl_mtr_n;

reg [14:0] motor_spinup_delay;

reg [31:0] dskptr;
reg [15:0] dsklen;
reg [15:0] dsksync;
reg last_dma_secondary;
reg dma_started;

reg [31:0] mfm_decoder;

wire dma_active;
assign dma_active =
    last_dma_secondary == 1'b1 && dsklen[15] == 1'b1 && dma_con[9] == 1'b1 && dma_con[4] == 1'b1 && dsklen[13:0] != 14'd0;

reg [5:0] byte_dsksync;
reg [2:0] byte_counter;

assign na_dskbytr = { byte_counter != 3'd0, dma_active, dsklen[14], byte_dsksync != 6'd0, 
    (byte_counter == 3'd1)? output_long_word[31:24] :
    (byte_counter == 3'd2)? output_long_word[23:16] :
    (byte_counter == 3'd3)? output_long_word[15:8] :
    output_long_word[7:0]
};

reg [3:0] substate;
reg [3:0] last_substate;
reg [3:0] state;
reg [3:0] last_state;
parameter [3:0]
    S_IDLE              = 4'd0,
    S_READ_FROM_SD      = 4'd1,
    S_READ_READY_0      = 4'd2,
    S_READ_READY_1      = 4'd3,
    S_WRITE_CONVERT_0   = 4'd4,
    S_WRITE_CONVERT_1   = 4'd5,
    S_WRITE_CONVERT_2   = 4'd6,
    S_WRITE_TO_SD       = 4'd7;

// byte position:   track*2*11*512  + side*11*512
// sector position: track*2*11      + side*11       = track*2*(8+2+1) + side*(8+2+1) = track*(16+4+2) + side*(8+2+1)
wire [31:0] sd_track_address;
assign sd_track_address =
    floppy_sector +
    { 21'b0, track, 4'b0 } +
    { 23'b0, track, 2'b0 } +
    { 24'b0, track, 1'b0 } +
    { 28'b0, ~last_fl_side_n, 3'b0 } +
    { 30'b0, ~last_fl_side_n, 1'b0 } +
    { 31'b0, ~last_fl_side_n };

wire [15:0] mfm_decoder_odd_30_16 = {
    master_DAT_I[30], 1'b0, master_DAT_I[28], 1'b0,
    master_DAT_I[26], 1'b0, master_DAT_I[24], 1'b0,
    master_DAT_I[22], 1'b0, master_DAT_I[20], 1'b0,
    master_DAT_I[18], 1'b0, master_DAT_I[16], 1'b0
};
wire [15:0] mfm_decoder_odd_14_0 = {    
    master_DAT_I[14], 1'b0, master_DAT_I[12], 1'b0,
    master_DAT_I[10], 1'b0, master_DAT_I[8], 1'b0,
    master_DAT_I[6], 1'b0, master_DAT_I[4], 1'b0,
    master_DAT_I[2], 1'b0, master_DAT_I[0], 1'b0
};
wire [15:0] mfm_decoder_even_30_16 = {
    1'b0, master_DAT_I[30], 1'b0, master_DAT_I[28],
    1'b0, master_DAT_I[26], 1'b0, master_DAT_I[24],
    1'b0, master_DAT_I[22], 1'b0, master_DAT_I[20],
    1'b0, master_DAT_I[18], 1'b0, master_DAT_I[16]
};
wire [15:0] mfm_decoder_even_14_0 = {
    1'b0, master_DAT_I[14], 1'b0, master_DAT_I[12],
    1'b0, master_DAT_I[10], 1'b0, master_DAT_I[8],
    1'b0, master_DAT_I[6], 1'b0, master_DAT_I[4],
    1'b0, master_DAT_I[2], 1'b0, master_DAT_I[0]
};
wire [31:0] dskptr_sum =
    (substate == 4'd0)? dskptr + 32'd0 :
    (substate == 4'd1)? dskptr + 32'd2 :
    (substate == 4'd2)? dskptr + 32'd512 :
    dskptr + 32'd514;

wire start_read     = (last_state == S_IDLE && state == S_READ_FROM_SD);
wire start_write    = (last_state == S_WRITE_CONVERT_1 && state == S_WRITE_CONVERT_2);
wire active_write   = (state == S_WRITE_CONVERT_2 || state == S_WRITE_TO_SD);
wire enable_write   = (last_state == S_WRITE_CONVERT_2 && last_substate == 4'd3 && substate == 4'd0);
wire dsksync_halt   = (output_shift[47:32] == dsksync && dma_started == 1'b0 && output_shifting == 1'b1 && dma_active == 1'b1 && dsklen[14] == 1'b0);
reg last_dsksync_halt;

always @(posedge CLK_I or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        floppy_error <= 1'b0;
        
        CYC_O <= 1'b0;
        STB_O <= 1'b0;
        WE_O <= 1'b0;
        ADR_O <= 30'd0;
        SEL_O <= 4'b0000;
        master_DAT_O <= 32'd0;
        ACK_O <= 1'b0;

        floppy_syn_irq <= 1'b0;
        floppy_blk_irq <= 1'b0;
        
        reg_fl_chng_n <= 1'b1;
        reg_fl_index_n <= 1'b1;
        reg_fl_mtr_n <= 1'b1;
        
        motor_spinup_delay <= 15'd0;
        
        last_fl_step_n <= 1'b1;
        last_fl_sel_n <= 4'b1111;
        last_fl_side_n <= 1'b1;
        track <= 7'd0;
        floppy_pos_changed <= 1'b0;
        
        dskptr <= 32'd0;
        dsklen <= 16'd0;
        dsksync <= 16'd0;
        last_dma_secondary <= 1'b0;
        
        dma_started <= 1'b0;
        last_dsksync_halt <= 1'b0;
        
        byte_dsksync <= 6'd0;
        byte_counter <= 3'd0;
        
        mfm_decoder <= 32'd0;
        
        substate <= 4'd0;
        last_substate <= 4'd0;
        state <= S_IDLE;
        last_state <= S_IDLE;
    end
    else begin
        if(floppy_inserted == 1'b1 && fl_sel_n == 4'b1110 && fl_step_n == 1'b0)     reg_fl_chng_n <= 1'b1;
        else if(floppy_inserted == 1'b0)                                            reg_fl_chng_n <= 1'b0;
        
        if(fl_sel_n[3:0] == 4'b1110) begin
            last_fl_step_n <= fl_step_n;
            last_fl_side_n <= fl_side_n;
        end
        last_fl_sel_n <= fl_sel_n;
        if(fl_sel_n[3:0] == 4'b1110 && last_fl_step_n == 1'b0 && fl_step_n == 1'b1) begin
            if(fl_dir == 1'b0 && track < 7'd79)     track <= track + 7'd1;
            else if(fl_dir == 1'b1 && track > 7'd0) track <= track - 7'd1;
        end
        
        if(last_fl_sel_n[0] == 1'b1 && fl_sel_n[0] == 1'b0) reg_fl_mtr_n <= fl_mtr_n;
        
        if(reg_fl_mtr_n == 1'b1)                                        motor_spinup_delay <= 15'd0;
        else if(reg_fl_mtr_n == 1'b0 && motor_spinup_delay < 15'd32767) motor_spinup_delay <= motor_spinup_delay + 15'd1;
        
        if(fl_sel_n[3:0] == 4'b1110 && ((last_fl_step_n == 1'b0 && fl_step_n == 1'b1) || (last_fl_side_n != fl_side_n)))
                                                                                        floppy_pos_changed <= 1'b1;
        else if(state == S_READ_READY_0)                                                floppy_pos_changed <= 1'b0;
        
        if(dma_started == 1'b1 && dma_active == 1'b0)   dma_started <= 1'b0;
        if(floppy_error == 1'b1)                        floppy_error <= 1'b0;
        if(floppy_blk_irq == 1'b1)                      floppy_blk_irq <= 1'b0;
        if(floppy_syn_irq == 1'b1)                      floppy_syn_irq <= 1'b0;
        if(reg_fl_index_n == 1'b0)                      reg_fl_index_n <= 1'b1;
        
        
        if(floppy_syn_irq == 1'b1)
            byte_dsksync <= 6'd1;
        else if(byte_dsksync == 6'd61 || floppy_inserted == 1'b0 || reg_fl_mtr_n == 1'b1 || fl_sel_n[0] == 1'b1)
            byte_dsksync <= 6'd0;
        else if(byte_dsksync != 6'd0)
            byte_dsksync <= byte_dsksync + 6'd1;
        
        if(na_dskbytr_read == 1'b1 && byte_counter > 3'd0 && byte_counter < 3'd4)   byte_counter <= byte_counter + 3'd1;
        else if(na_dskbytr_read == 1'b1)                                            byte_counter <= 3'd0;
        
        last_state <= state;
        last_substate <= substate;
        last_dsksync_halt <= dsksync_halt;
        
        if(CYC_I == 1'b1 && STB_I == 1'b1 && ACK_O == 1'b0) ACK_O <= 1'b1;
        else ACK_O <= 1'b0;

        if(CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b1 && ACK_O == 1'b0) begin
            if({ ADR_I, 2'b0 } == 9'h020 && SEL_I[0] == 1'b1)   dskptr[7:0]     <= slave_DAT_I[7:0];
            if({ ADR_I, 2'b0 } == 9'h020 && SEL_I[1] == 1'b1)   dskptr[15:8]    <= slave_DAT_I[15:8];
            if({ ADR_I, 2'b0 } == 9'h020 && SEL_I[2] == 1'b1)   dskptr[23:16]   <= slave_DAT_I[23:16];
            if({ ADR_I, 2'b0 } == 9'h020 && SEL_I[3] == 1'b1)   dskptr[31:24]   <= slave_DAT_I[31:24];
            if({ ADR_I, 2'b0 } == 9'h024 && SEL_I[0] == 1'b1)   ;
            if({ ADR_I, 2'b0 } == 9'h024 && SEL_I[1] == 1'b1)   ;
            if({ ADR_I, 2'b0 } == 9'h024 && SEL_I[2] == 1'b1)   dsklen[7:0]      <= slave_DAT_I[23:16];
            if({ ADR_I, 2'b0 } == 9'h024 && SEL_I[3] == 1'b1)   dsklen[15:8]     <= slave_DAT_I[31:24];
            if({ ADR_I, 2'b0 } == 9'h07C && SEL_I[0] == 1'b1)   dsksync[7:0]     <= slave_DAT_I[7:0];
            if({ ADR_I, 2'b0 } == 9'h07C && SEL_I[1] == 1'b1)   dsksync[15:8]    <= slave_DAT_I[15:8];
            if({ ADR_I, 2'b0 } == 9'h07C && SEL_I[2] == 1'b1)   ;
            if({ ADR_I, 2'b0 } == 9'h07C && SEL_I[3] == 1'b1)   ;
            
            if({ ADR_I, 2'b0 } == 9'h024 && SEL_I[3] == 1'b1)   last_dma_secondary <= dsklen[15];
        end
        
        if(state == S_IDLE) begin
            if(dma_active == 1'b1 || (floppy_inserted == 1'b1 && motor_spinup_delay != 15'd0)) begin
                ADR_O <= 30'h4000400; // 0x10001000, sd
                substate <= 4'd0;
                state <= S_READ_FROM_SD;
            end
        end
        else if(state == S_READ_FROM_SD) begin
            if(ACK_I == 1'b1 && CYC_O == 1'b1 && STB_O == 1'b1) begin
                CYC_O <= 1'b0;
                STB_O <= 1'b0;
                
                if(substate < 4'd3) begin
                    substate <= substate + 4'd1;
                    ADR_O <= ADR_O + 30'd1;
                end
                else if(substate == 4'd3) begin
                    substate <= substate + 4'd1;
                    ADR_O <= 30'h04000400; // 0x10001000, sd read state
                end
                else if(substate >= 4'd4 && master_DAT_I == 32'd5) begin
                    floppy_error <= 1'b1;
                    substate <= 4'd0;
                    state <= S_IDLE;
                end
                else if(substate == 4'd4 && master_DAT_I == 32'd3) begin
                    substate <= substate + 4'd1;
                end
                else if(substate == 4'd5 && master_DAT_I == 32'd2) begin
                    substate <= 4'd0;
                    state <= S_READ_READY_0;
                end
            end
            else if(ACK_I == 1'b0) begin
                CYC_O <= 1'b1;
                STB_O <= 1'b1;
                WE_O <= (substate <= 4'd3)? 1'b1 : 1'b0;
                SEL_O <= 4'b1111;
                // ADR_O <= ADR_O
                master_DAT_O <=
                    (substate == 4'd0)? 32'h10004000 :      // base address
                    (substate == 4'd1)? sd_track_address :  // sd sector number
                    (substate == 4'd2)? 32'd11 :            // read sector size
                    32'd2;                                  // start sd read
            end
        end
        
        else if(state == S_READ_READY_0) begin
            
            if(floppy_pos_changed == 1'b1 || (dma_active == 1'b0 && (floppy_inserted == 1'b0 || motor_spinup_delay == 15'd0))) begin
                state <= S_IDLE;
            end
            else if(dma_active == 1'b1 && dsklen[14] == 1'b1) begin
                substate <= 4'd0;
                mfm_decoder <= 32'd0;
                state <= S_WRITE_CONVERT_0;
            end
            else begin
                
                
                if(output_index == 1'b1) reg_fl_index_n <= 1'b0;
                
                if(output_shifted == 1'b1) byte_counter <= 3'd1;
                
                if(output_shift[47:32] == dsksync && output_shifting == 1'b1 && floppy_syn_irq == 1'b0) floppy_syn_irq <= 1'b1;
                
                if(output_shifted == 1'b1 && dma_active == 1'b1 && dsklen[14] == 1'b0 && (adk_con[10] == 1'b0 || dma_started == 1'b1)) begin
                    master_DAT_O <= (dskptr[1] == 1'b0)? output_long_word : { output_long_word[15:0], output_long_word[31:16] };
                    dma_started <= 1'b1;
                    substate <= 4'd0;
                    state <= S_READ_READY_1;
                end
                else if(dsksync_halt == 1'b1) begin
                    dma_started <= 1'b1;
                end
            
            end
            
        end
         
        else if(state == S_READ_READY_1) begin
            if(ACK_I == 1'b1 && CYC_O == 1'b1 && STB_O == 1'b1) begin
                CYC_O <= 1'b0;
                STB_O <= 1'b0;
                
                if(substate == 4'd0) begin
                    dskptr <= dskptr + 32'd2;
                    dsklen[13:0] <= dsklen[13:0] - 14'd1;
                    if(dsklen[13:0] == 14'd1) begin
                        floppy_blk_irq <= 1'b1;
                        state <= S_READ_READY_0;
                    end
                    else substate <= substate + 4'd1;
                end
                else if(substate == 4'd1) begin
                    dskptr <= dskptr + 32'd2;
                    dsklen[13:0] <= dsklen[13:0] - 14'd1;
                    if(dsklen[13:0] == 14'd1) floppy_blk_irq <= 1'b1;
                    state <= S_READ_READY_0;
                end
            end
            else if(ACK_I == 1'b0) begin
                CYC_O <= 1'b1;
                STB_O <= 1'b1;
                WE_O <= 1'b1;
                SEL_O <= (dskptr[1] == 1'b0)? 4'b1100 : 4'b0011;
                ADR_O <= dskptr[31:2];
            end
        end
        
        
        
        
        //  start reading till 0x4489
        //  skip 1*2 bytes
        else if(state == S_WRITE_CONVERT_0) begin
            if(ACK_I == 1'b1 && CYC_O == 1'b1 && STB_O == 1'b1) begin
                CYC_O <= 1'b0;
                STB_O <= 1'b0;
                
                if(dsklen[13:0] <= 14'd1) begin
                    floppy_blk_irq <= 1'b1;
                    dskptr <= dskptr + { 17'd0, dsklen[13:0], 1'b0 };
                    dsklen[13:0] <= 14'd0;
                    substate <= 4'd0;
                    state <= S_IDLE;
                end
                else if( (dskptr[1] == 1'b0 && master_DAT_I[31:16] == 16'h4489) ||
                        (dskptr[1] == 1'b1 && master_DAT_I[15:0] == 16'h4489) )
                begin
                    dskptr <= dskptr + 32'd4;
                    dsklen[13:0] <= dsklen[13:0] - 14'd2;
                    substate <= 4'd0;
                    state <= S_WRITE_CONVERT_1;
                end
                else begin
                    dskptr <= dskptr + 32'd2;
                    dsklen[13:0] <= dsklen[13:0] - 14'd1;
                end
            end
            else if(ACK_I == 1'b0) begin
                CYC_O <= 1'b1;
                STB_O <= 1'b1;
                WE_O <= 1'b0;
                SEL_O <= 4'b1111;
                ADR_O <= dskptr[31:2];
            end
        end
        //  read next 4 words, decode sector number
        //  skip 24*2 bytes
        else if(state == S_WRITE_CONVERT_1) begin
            if(ACK_I == 1'b1 && CYC_O == 1'b1 && STB_O == 1'b1) begin
                CYC_O <= 1'b0;
                STB_O <= 1'b0;
                
                if(dsklen[13:0] <= 14'd24) begin
                    floppy_blk_irq <= 1'b1;
                    dskptr <= dskptr + { 17'd0, dsklen[13:0], 1'b0 };
                    dsklen[13:0] <= 14'd0;
                    substate <= 4'd0;
                    state <= S_IDLE;
                end
                else if(substate < 4'd3) begin
                    substate <= substate + 4'd1;
                    dskptr <= dskptr + 32'd2;
                    dsklen[13:0] <= dsklen[13:0] - 14'd1;
                
                    if(substate == 4'd0)
                        mfm_decoder[31:16] <= (dskptr[1] == 1'b0)? mfm_decoder_odd_30_16  : mfm_decoder_odd_14_0;
                    else if(substate == 4'd1)
                        mfm_decoder[15:0]  <= (dskptr[1] == 1'b0)? mfm_decoder_odd_30_16  : mfm_decoder_odd_14_0;
                    else if(substate == 4'd2)
                        mfm_decoder[31:16] <= mfm_decoder[31:16] | ((dskptr[1] == 1'b0)? mfm_decoder_even_30_16 : mfm_decoder_even_14_0);
                end
                else if(substate == 4'd3) begin
                    mfm_decoder[15:0]  <= mfm_decoder[15:0]  | ((dskptr[1] == 1'b0)? mfm_decoder_even_30_16 : mfm_decoder_even_14_0);
                    
                    dskptr <= dskptr + 32'd50;
                    dsklen[13:0] <= dsklen[13:0] - 14'd25;
                    substate <= 4'd0;
                    state <= S_WRITE_CONVERT_2;
                end
            end
            else if(ACK_I == 1'b0) begin
                CYC_O <= 1'b1;
                STB_O <= 1'b1;
                WE_O <= 1'b0;
                SEL_O <= 4'b1111;
                ADR_O <= dskptr[31:2];
            end
        end
        //  read sector, decode to floppy buffer
        else if(state == S_WRITE_CONVERT_2) begin
            if(ACK_I == 1'b1 && CYC_O == 1'b1 && STB_O == 1'b1) begin
                CYC_O <= 1'b0;
                STB_O <= 1'b0;
                
                if(dsklen[13:0] <= 14'd257) begin
                    floppy_blk_irq <= 1'b1;
                    dskptr <= dskptr + { 17'd0, dsklen[13:0], 1'b0 };
                    dsklen[13:0] <= 14'd0;
                    substate <= 4'd0;
                    state <= S_IDLE;
                end
                else if(substate < 4'd3) begin
                    substate <= substate + 4'd1;
                    
                    if(substate == 4'd0)
                        master_DAT_O[31:16] <= (dskptr_sum[1] == 1'b0)? mfm_decoder_odd_30_16  : mfm_decoder_odd_14_0;
                    else if(substate == 4'd1)
                        master_DAT_O[15:0]  <= (dskptr_sum[1] == 1'b0)? mfm_decoder_odd_30_16  : mfm_decoder_odd_14_0;
                    else if(substate == 4'd2)
                        master_DAT_O[31:16] <= master_DAT_O[31:16] | ((dskptr_sum[1] == 1'b0)? mfm_decoder_even_30_16 : mfm_decoder_even_14_0);
                end
                else if(substate == 4'd3) begin
                    master_DAT_O[15:0]  <= master_DAT_O[15:0]  | ((dskptr_sum[1] == 1'b0)? mfm_decoder_even_30_16 : mfm_decoder_even_14_0);
                    
                    substate <= 4'd0;
                    if(write_sector_ready == 1'b1) begin
						dskptr <= dskptr + 32'd516;
						dsklen[13:0] <= dsklen[13:0] - 14'd258;
                        ADR_O <= 30'h04000400; // 0x10001000, sd
                        state <= S_WRITE_TO_SD;
                    end
					else begin
						dskptr <= dskptr + 32'd4;
						dsklen[13:0] <= dsklen[13:0] - 14'd2;
					end
                end
            end
            else if(ACK_I == 1'b0) begin
                CYC_O <= 1'b1;
                STB_O <= 1'b1;
                WE_O <= 1'b0;
                SEL_O <= 4'b1111;
                ADR_O <= dskptr_sum[31:2];
            end
        end
        //  sd write
        // continue
        else if(state == S_WRITE_TO_SD) begin
            if(ACK_I == 1'b1 && CYC_O == 1'b1 && STB_O == 1'b1) begin
                CYC_O <= 1'b0;
                STB_O <= 1'b0;
                
                if(substate < 4'd3) begin
                    substate <= substate + 4'd1;
                    ADR_O <= ADR_O + 30'd1;
                end
                else if(substate == 4'd3) begin
                    substate <= substate + 4'd1;
                    ADR_O <= 30'h04000400; // 0x10001000, sd read state
                end
                else if(substate >= 4'd4 && master_DAT_I == 32'd5) begin
                    floppy_error <= 1'b1;
                    substate <= 4'd0;
                    state <= S_IDLE;
                end
                else if(substate == 4'd4 && master_DAT_I == 32'd4) begin
                    substate <= substate + 4'd1;
                end
                else if(substate == 4'd5 && master_DAT_I == 32'd2) begin
                    substate <= 4'd0;
                    if(dsklen[13:0] == 14'd0) begin
                        floppy_blk_irq <= 1'b1;
                        state <= S_IDLE;
                    end
                    else begin
                        state <= S_WRITE_CONVERT_0;
                    end
                end
            end
            else if(ACK_I == 1'b0) begin
                CYC_O <= 1'b1;
                STB_O <= 1'b1;
                WE_O <= (substate <= 4'd3)? 1'b1 : 1'b0;
                SEL_O <= 4'b1111;
                // ADR_O <= ADR_O
                master_DAT_O <=
                    (substate == 4'd0)? 32'h10004000 :  // base address
                    (substate == 4'd1)? sd_track_address + { 28'd0, mfm_decoder[11:8] }: // sd sector number
                    (substate == 4'd2)? 32'd1 : // write sector count
                    32'd3; // start sd write
            end
        end
    end
end

endmodule
