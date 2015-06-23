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
 * \brief OCS system control implementation with WISHBONE slave interface.
 */

/*! \brief \copybrief ocs_control.v

List of system control registers:
\verbatim
Implemented:
     [DDFSTOP      094  W   A     Display bitplane data fetch stop              
                                  (horiz. position)                             write not implemented here]
    DMACON       096  W   ADP     DMA control write (clear or set)              write not implemented here
    
    DMACONR     *002  R   AP      DMA control (and blitter status) read
    VPOSR       *004  R   A( E )  Read vert most signif. bit (and frame flop)
    VHPOSR      *006  R   A       Read vert and horiz. position of beam
    
    ADKCON       09E  W   P       Audio, disk, UART control
    
    ADKCONR     *010  R   P       Audio, disk control register read
     [POT0DAT   *012  R   P( E )  Pot counter pair 0 data (vert,horiz)          read implemented here]
    
    INTENAR     *01C  R   P       Interrupt enable bits read
    INTREQR     *01E  R   P       Interrupt request bits read
    
     [CLXCON     098  W   D       Collision control                             write not implemented here]
    INTENA       09A  W   P       Interrupt enable bits (clear or set bits)     write not implemented here
    INTREQ       09C  W   P       Interrupt request bits (clear or set bits)
    
Not implemented:
    REFPTR    & *028  W   A       Refresh pointer                               
    VPOSW       *02A  W   A       Write vert most signif. bit (and frame flop)  
    VHPOSW      *02C  W   A       Write vert and horiz position of beam
    
    STREQU    & *038  S   D       Strobe for horiz sync with VB and EQU
    STRVBL    & *03A  S   D       Strobe for horiz sync with VB (vert. blank)
    STRHOR    & *03C  S   DP      Strobe for horiz sync
    STRLONG   & *03E  S   D( E )  Strobe for identification of long horiz. line.
    
    RESERVED     1110X
    RESERVED     1111X
    NO-OP(NULL)  1FE
\endverbatim
*/
module ocs_control(
    //% \name Clock and reset
    //% @{
    input               clk_30,
    input               reset_n,
    //% @}
    
    //% \name WISHBONE slave
    //% @{
    input               CYC_I,
    input               STB_I,
    input               WE_I,
    input [8:2]         ADR_I,
    input [3:0]         SEL_I,
    input [31:0]        slave_DAT_I,
    output reg [31:0]   slave_DAT_O,
    output reg          ACK_O,
    //% @}
    
    //% \name Not aligned register access on a 32-bit WISHBONE bus
    //% @{
        // INTENA write not implemented here
    input               na_int_ena_write,
    input [15:0]        na_int_ena,
    input [1:0]         na_int_ena_sel,
        // DMACON write not implemented here
    input               na_dma_con_write,
    input [15:0]        na_dma_con,
    input [1:0]         na_dma_con_sel,
        // POT0DAT read implemented here
    output              na_pot0dat_read,
    input [15:0]        na_pot0dat,
    //% @}
    
    //% \name Internal OCS ports: beam counters
    //% @{
    output reg          line_start,
    output reg          line_pre_start,
    output reg [8:0]    line_number,
    output reg [8:0]    column_number,
    //% @}
    
    //% \name Internal OCS ports: clock pulses for CIA and audio
    //% @{
    output reg          pulse_709379_hz,
    output              pulse_color,
    //% @}
    
    //% \name Internal OCS ports: global registers and blitter signals
    //% @{
    output reg [10:0]   dma_con,
    output reg [14:0]   adk_con,
    
    input               blitter_busy,
    input               blitter_zero,
    //% @}
    
    //% \name Internal OCS ports: interrupts
    //% @{
    input               blitter_irq,
    input               cia_a_irq,
    input               cia_b_irq,
    input               floppy_syn_irq,
    input               floppy_blk_irq,
    input               serial_rbf_irq,
    input               serial_tbe_irq,
    input [3:0]         audio_irq,
    
    output [2:0]        interrupt
    //% @}
);

assign interrupt =
    (int_ena[14] == 1'b0)? 3'd0 :
    (int_ena[13] == 1'b1 && int_req[13] == 1'b1) ? 3'd6 :
    (int_ena[12] == 1'b1 && int_req[12] == 1'b1) ? 3'd5 :
    (int_ena[11] == 1'b1 && int_req[11] == 1'b1) ? 3'd5 :
    (int_ena[10] == 1'b1 && int_req[10] == 1'b1) ? 3'd4 :
    (int_ena[9] == 1'b1 && int_req[9] == 1'b1) ? 3'd4 :
    (int_ena[8] == 1'b1 && int_req[8] == 1'b1) ? 3'd4 :
    (int_ena[7] == 1'b1 && int_req[7] == 1'b1) ? 3'd4 :
    (int_ena[6] == 1'b1 && int_req[6] == 1'b1) ? 3'd3 :
    (int_ena[5] == 1'b1 && int_req[5] == 1'b1) ? 3'd3 :
    (int_ena[4] == 1'b1 && int_req[4] == 1'b1) ? 3'd3 :
    (int_ena[3] == 1'b1 && int_req[3] == 1'b1) ? 3'd2 :
    (int_ena[2] == 1'b1 && int_req[2] == 1'b1) ? 3'd1 :
    (int_ena[1] == 1'b1 && int_req[1] == 1'b1) ? 3'd1 :
    (int_ena[0] == 1'b1 && int_req[0] == 1'b1) ? 3'd1 :
    3'd0;

wire [14:0] new_int_req;
assign new_int_req = {
    1'b0,
    cia_b_irq,
    floppy_syn_irq,
    serial_rbf_irq,
    audio_irq[3:0],
    blitter_irq,
    (line_start == 1'b1 && line_number == 9'd0),
    1'b0,
    cia_a_irq,
    1'b0,
    floppy_blk_irq,
    serial_tbe_irq
};

reg [14:0] int_ena;
reg [14:0] int_req;
reg [10:0] column_counter;
reg long_frame;

assign na_pot0dat_read = (CYC_I == 1'b1 && STB_I == 1'b1 && ACK_O == 1'b0 && WE_I == 1'b0 && { ADR_I, 2'b0 } == 9'h010 && SEL_I[1:0] != 2'b00);

always @(posedge clk_30 or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        slave_DAT_O <= 32'd0;
        ACK_O <= 1'b0;
        
        line_start <= 1'b0;
        line_pre_start <= 1'b0;
        line_number <= 9'd0;
        column_number <= 9'd0;
        
        dma_con <= 11'd0;
        int_req <= 15'd0;
        int_ena <= 15'd0;
        adk_con <= 15'd0;
        column_counter <= 11'd0;
        long_frame <= 1'b0;
    end
    else begin
        if(na_dma_con_write == 1'b1 && na_dma_con_sel[1:0] == 2'b11) begin
            if(na_dma_con[15] == 1'b1)  dma_con <= dma_con | na_dma_con[10:0];
            else                        dma_con <= dma_con & (~na_dma_con[10:0]);
        end
        
        if(na_int_ena_write == 1'b1 && na_int_ena_sel[1:0] == 2'b11) begin
            if(na_int_ena[15] == 1'b1)  int_ena <= int_ena | na_int_ena[14:0];
            else                        int_ena <= int_ena & (~na_int_ena[14:0]);
        end
        
        if(column_counter == 11'd1919)  column_counter <= 11'd0;
        else                            column_counter <= column_counter + 11'd1;
        
        if(column_counter == 11'd1918)  line_pre_start <= 1'b1;
        else                            line_pre_start <= 1'b0;
        
        if(column_counter == 11'd1919)  line_start <= 1'b1;
        else                            line_start <= 1'b0;
        
        if(column_counter == 11'd1919) begin
            column_number <= 9'd0;
            
            if(line_number == 9'd311 && long_frame == 1'b0) begin
                line_number <= 9'd0;
                long_frame <= 1'b1;
            end
            else if(line_number == 9'd312 && long_frame == 1'b1) begin
                line_number <= 9'd0;
                long_frame <= 1'b0;
            end
            else line_number <= line_number + 9'd1;
        end
        else if(column_counter > 11'd600 /*time for 6 bitplain*/) begin
            if(column_counter[0] == 1'b1 && column_number < 9'd452 /*226*2*/)  column_number <= column_number + 9'd1;
        end
        
        if(ACK_O == 1'b1) ACK_O <= 1'b0;
        
        if(CYC_I == 1'b1 && STB_I == 1'b1 && ACK_O == 1'b0) begin
            ACK_O <= 1'b1;
            
            // BLTDDAT not used, DMACONR
            if(WE_I == 1'b0 && { ADR_I, 2'b0 } == 9'h000)       slave_DAT_O <= { 16'd0, 1'b0, blitter_busy, blitter_zero, 2'b00, dma_con[10:0] };
            // VPOSR, VHPOSR
            else if(WE_I == 1'b0 && { ADR_I, 2'b0 } == 9'h004)  slave_DAT_O <= { long_frame, 14'd0, line_number[8:0], column_number[8:1] };
            // INTENAR, INTREQR
            else if(WE_I == 1'b0 && { ADR_I, 2'b0 } == 9'h01C)  slave_DAT_O <= { 1'b0, int_ena[14:0], 1'b0, int_req[14:0] };
            // ADKCONR, POT0DAT read implemented here
            else if(WE_I == 1'b0 && { ADR_I, 2'b0 } == 9'h010)  slave_DAT_O <= { 1'b0, adk_con[14:0], na_pot0dat };
            // INTREQ, ADKCON
            else if(WE_I == 1'b1 && { ADR_I, 2'b0 } == 9'h09C) begin
                if(SEL_I[1:0] == 2'b11) begin
                    if(slave_DAT_I[15] == 1'b1) adk_con <= adk_con | slave_DAT_I[14:0];
                    else                        adk_con <= adk_con & (~slave_DAT_I[14:0]);
                end
            end
        end
        
        if(CYC_I == 1'b1 && STB_I == 1'b1 && ACK_O == 1'b0 && WE_I == 1'b1 && { ADR_I, 2'b0 } == 9'h09C && SEL_I[3:2] == 2'b11) begin
            if(slave_DAT_I[31] == 1'b1) int_req <= (int_req | (new_int_req /*& int_ena*/)) | slave_DAT_I[30:16];
            else                        int_req <= (int_req | (new_int_req /*& int_ena*/)) & (~slave_DAT_I[30:16]);
        end
        else                            int_req <= (int_req | (new_int_req /*& int_ena*/));
        
    end
end




// 1/10 fCPU == 1/20 color clock
reg [2:0] counter_709379_hz;
always @(posedge clk_30 or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        counter_709379_hz <= 3'd0;
        pulse_709379_hz <= 1'b0;
    end
    else if(pulse_color == 1'b1) begin
        if(counter_709379_hz == 3'd4) begin
            pulse_709379_hz <= 1'b1;
            counter_709379_hz <= 3'd0;
        end
        else begin
            pulse_709379_hz <= 1'b0;
            counter_709379_hz <= counter_709379_hz + 3'd1;
        end
    end
    else begin
        pulse_709379_hz <= 1'b0;
    end
end

// 1/2 fCPU = 1 color clock
// 3.546875MHz
assign pulse_color = (pulse_cpu == 1'b1) && (pulse_counter == 1'b1);

reg pulse_counter;
always @(posedge clk_30 or negedge reset_n) begin
    if(reset_n == 1'b0)         pulse_counter <= 1'b0;
    else if(pulse_cpu == 1'b1)  pulse_counter <= ~pulse_counter;
end

// fCPU
// in: 30MHz, out: 7.09375MHz -> 960 - 227
reg [10:0] counter_cpu;
reg pulse_cpu;
always @(posedge clk_30 or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        counter_cpu <= 11'd960;
        pulse_cpu <= 1'b0;
    end
    else if(counter_cpu <= 11'd114) begin
        counter_cpu <= counter_cpu - 11'd227 + 11'd960;
        pulse_cpu <= 1'b1;
    end
    else if(counter_cpu < 11'd227) begin
        counter_cpu <= counter_cpu + 11'd960;
        pulse_cpu <= 1'b0;
    end
    else if(counter_cpu > 11'd960) begin
        counter_cpu <= counter_cpu - 11'd227 - 11'd227;
        pulse_cpu <= 1'b1;
    end
    else begin
        counter_cpu <= counter_cpu - 11'd227;
        pulse_cpu <= 1'b0;
    end
end

endmodule

