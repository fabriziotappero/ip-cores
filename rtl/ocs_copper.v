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
 * \brief OCS copper implementation with WISHBONE master and slave interface.
 */

/*! \brief \copybrief ocs_copper.v

List of copper registers:
\verbatim
Implemented:
    COPCON      *02E  W   A( E )  Coprocessor control register (CDANG)
    COP1LCH   +  080  W   A( E )  Coprocessor first location register (high 3 bits, high 5 bits if ECS)
    COP1LCL   +  082  W   A       Coprocessor first location register (low 15 bits)
    COP2LCH   +  084  W   A( E )  Coprocessor second location register (high 3 bits, high 5 bits if ECS)
    COP2LCL   +  086  W   A       Coprocessor second location register (low 15 bits)
    COPJMP1      088  S   A       Coprocessor restart at first location
    COPJMP2      08A  S   A       Coprocessor restart at second location
Not implemented:
    COPINS       08C  W   A       Coprocessor instruction fetch identify
\endverbatim

\note
    \li \c COPINS is not implemented.
*/
module ocs_copper(
    //% \name Clock and reset
    //% @{
    input               CLK_I,
    input               reset_n,
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
    
    //% \name WISHBONE slave
    //% @{
    input               CYC_I,
    input               STB_I,
    input               WE_I,
    input [8:2]         ADR_I,
    input [3:0]         SEL_I,
    input [31:0]        slave_DAT_I,
    output reg          ACK_O,
    //% @}
    
    //% \name Internal OCS ports
    //% @{
    input               line_start,
    input [8:0]         line_number,
    input [8:0]         column_number,
    
    input [10:0]        dma_con,
    input               blitter_busy
    //% @}
);

reg [15:0] cop_con;
reg [31:0] cop1_loc;
reg [31:0] cop2_loc;

reg [1:0] jump_strobe;
reg [1:0] state;
reg [31:0] pc;
reg [47:0] ir;
reg [1:0] avail;

parameter [1:0]
    S_IDLE          = 2'd0,
    S_LOAD          = 2'd1,
    S_SAVE          = 2'd2;
    
// MOVE: >= 0x20($80-$FF) always, >= 0x10 && < 0x20 CDANG, < 0x10($00-$3E) never
// WAIT: pos >= params;  PAL max(226,312)
//       horiz [7:1] bits, DDF,  0x0-0xE2, resolution 4 lowres, 8 hires, horiz blanking 0x0F-0x35, lowres 0x04-0x47 not used
//       vert [7:0] bits, 
// SKIP: pos >= params then skip next instruction
//
// enable bits: if 0 -> always true, vert[7] not masked, always checked

wire [31:0] move_address;
assign move_address = { 8'd0, 12'hDFF, 3'b0, ir[40:32] };

wire beam_compare;
assign beam_compare = 
    (line_number[7:0] & { 1'b1, ir[30:24] }) > (ir[47:40] & { 1'b1, ir[30:24] }) ||
    (   (line_number[7:0] & { 1'b1, ir[30:24] }) == (ir[47:40] & { 1'b1, ir[30:24] }) &&
        (column_number[8:0] & { ir[23:17], 2'b0 }) >= ({ ir[39:33], 2'b0 } & { ir[23:17], 2'b0 })
    );
                

always @(posedge CLK_I or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        CYC_O <= 1'b0;
        STB_O <= 1'b0;
        WE_O <= 1'b0;
        ADR_O <= 30'd0;
        SEL_O <= 4'b0000;
        master_DAT_O <= 32'd0;
        ACK_O <= 1'b0;
        
        cop_con <= 16'd0;
        cop1_loc <= 32'd0;
        cop2_loc <= 32'd0;
        
        jump_strobe <= 2'b11;
        state <= S_IDLE;
        pc <= 32'd0;
        ir <= 48'd0;
        avail <= 2'd0;
    end
    else begin
        if(CYC_I == 1'b1 && STB_I == 1'b1 /*&& WE_I == 1'b1*/ && ACK_O == 1'b0) ACK_O <= 1'b1;
        else ACK_O <= 1'b0;
        
        // JMP1
        if( (CYC_I == 1'b1 && STB_I == 1'b1 /*&& WE_I == 1'b1*/ && { ADR_I, 2'b0 } == 9'h088 && SEL_O[3:2] != 2'b00 && ACK_O == 1'b0) ||
            (line_start == 1'b1 && line_number == 9'd0) ) //PAL:25, NTSC: 20
        begin
            jump_strobe <= 2'b01;
        end
        // JMP2
        else if(CYC_I == 1'b1 && STB_I == 1'b1 /*&& WE_I == 1'b1*/ && { ADR_I, 2'b0 } == 9'h088 && SEL_O[1:0] != 2'b00 && ACK_O == 1'b0) begin
            jump_strobe <= 2'b10;
        end
        else if(state == S_SAVE &&
            ((cop_con[1] == 1'b1 && move_address[8:0] <= 9'h03E) || (cop_con[1] == 1'b0 && move_address[8:0] <= 9'h07E)))
        begin
            jump_strobe <= 2'b11;
        end
        
        // 02C:     VHPOSW(not used),   COPCON,
        // 080:     COP1LCH,            COP1LCL,
        // 084:     COP2LCH,            COP2LCL,
        // 088:     COPJMP1,            COPJMP2,
        if(CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b1 && ACK_O == 1'b0) begin
            if({ ADR_I, 2'b0 } == 9'h02C && SEL_I[0] == 1'b1)  cop_con[7:0]   <= slave_DAT_I[7:0];
            if({ ADR_I, 2'b0 } == 9'h02C && SEL_I[1] == 1'b1)  cop_con[15:8]  <= slave_DAT_I[15:8];
            if({ ADR_I, 2'b0 } == 9'h02C && SEL_I[2] == 1'b1)  ;
            if({ ADR_I, 2'b0 } == 9'h02C && SEL_I[3] == 1'b1)  ;
            if({ ADR_I, 2'b0 } == 9'h080 && SEL_I[0] == 1'b1)  cop1_loc[7:0]   <= slave_DAT_I[7:0];
            if({ ADR_I, 2'b0 } == 9'h080 && SEL_I[1] == 1'b1)  cop1_loc[15:8]  <= slave_DAT_I[15:8];
            if({ ADR_I, 2'b0 } == 9'h080 && SEL_I[2] == 1'b1)  cop1_loc[23:16] <= slave_DAT_I[23:16];
            if({ ADR_I, 2'b0 } == 9'h080 && SEL_I[3] == 1'b1)  cop1_loc[31:24] <= slave_DAT_I[31:24];
            if({ ADR_I, 2'b0 } == 9'h084 && SEL_I[0] == 1'b1)  cop2_loc[7:0]   <= slave_DAT_I[7:0];
            if({ ADR_I, 2'b0 } == 9'h084 && SEL_I[1] == 1'b1)  cop2_loc[15:8]  <= slave_DAT_I[15:8];
            if({ ADR_I, 2'b0 } == 9'h084 && SEL_I[2] == 1'b1)  cop2_loc[23:16] <= slave_DAT_I[23:16];
            if({ ADR_I, 2'b0 } == 9'h084 && SEL_I[3] == 1'b1)  cop2_loc[31:24] <= slave_DAT_I[31:24];
        end
        else if(state == S_IDLE) begin
            // DMAEN, COPEN
            if(dma_con[9] == 1'b0 || dma_con[7] == 1'b0 ) begin
                jump_strobe <= 2'b11;
            end
            else if(jump_strobe == 2'b11) begin
                // no operation
            end
            else if(jump_strobe == 2'b01) begin
                jump_strobe <= 2'b00;
                pc <= cop1_loc;
                avail <= 2'd0;
                state <= S_LOAD;
            end
            else if(jump_strobe == 2'b10) begin
                jump_strobe <= 2'b00;
                pc <= cop2_loc;
                avail <= 2'd0;
                state <= S_LOAD;
            end
            else if(avail < 2'd2) begin
                state <= S_LOAD;
            end
            // MOVE
            else if(ir[32] == 1'b0) begin
                state <= S_SAVE;
            end
            // WAIT
            else if(ir[32] == 1'b1 && ir[16] == 1'b0 && (ir[31] == 1'b1 || blitter_busy == 1'b0) && beam_compare == 1'b1) begin
                avail <= avail - 2'd2;
                ir <= { ir[15:0], 32'd0 };
                state <= S_LOAD;
            end
            // SKIP
            else if(ir[32] == 1'b1 && ir[16] == 1'b1 && (ir[31] == 1'b1 || blitter_busy == 1'b0) && beam_compare == 1'b1) begin
                if(avail == 2'd2)   pc <= pc + 32'd4;
                else                pc <= pc + 32'd2;
                
                avail <= 2'd0;
                ir <= { ir[15:0], 32'd0 };
                state <= S_LOAD;
            end
            
        end
        else if(state == S_LOAD) begin
            if(ACK_I == 1'b1) begin
                CYC_O <= 1'b0;
                STB_O <= 1'b0;
                
                if(pc[1] == 1'b0 && avail == 2'd0) begin
                    pc <= pc + 32'd4;
                    avail <= avail + 2'd2;
                    ir[47:16] <= master_DAT_I[31:0];
                end
                else if(pc[1] == 1'b0 && avail == 2'd1) begin
                    pc <= pc + 32'd4;
                    avail <= avail + 2'd2;
                    ir[31:0] <= master_DAT_I[31:0];
                end
                else if(pc[1] == 1'b1 && avail == 2'd0) begin
                    pc <= pc + 32'd2;
                    avail <= avail + 2'd1;
                    ir[47:32] <= master_DAT_I[15:0];
                end
                else if(pc[1] == 1'b1 && avail == 2'd1) begin
                    pc <= pc + 32'd2;
                    avail <= avail + 2'd1;
                    ir[31:16] <= master_DAT_I[15:0];
                end
                
                state <= S_IDLE;
            end
            else begin
                CYC_O <= 1'b1;
                STB_O <= 1'b1;
                WE_O <= 1'b0;
                ADR_O <= pc[31:2];
                SEL_O <= 4'b1111;
            end
        end
        else if(state == S_SAVE) begin
            if(ACK_I == 1'b1 || (cop_con[1] == 1'b1 && move_address[8:0] <= 9'h03E) || (cop_con[1] == 1'b0 && move_address[8:0] <= 9'h07E))
            begin
                CYC_O <= 1'b0;
                STB_O <= 1'b0;
                
                avail <= avail - 2'd2;
                ir <= { ir[15:0], 32'd0 };
                
                state <= S_IDLE;
            end
            else begin
                CYC_O <= 1'b1;
                STB_O <= 1'b1;
                WE_O <= 1'b1;
                ADR_O <= move_address[31:2];
                if(move_address[1] == 1'b0) begin
                    SEL_O <= 4'b1100;
                    master_DAT_O <= { ir[31:16], 16'd0 };
                end
                else begin
                    SEL_O <= 4'b0011;
                    master_DAT_O <= { 16'd0, ir[31:16] };
                end
            end
        end
    end
end

endmodule

