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
 * \brief Terminator for not handled WISHBONE bus cycles.
 */

/*! \brief \copybrief bus_terminator.v
*/
module bus_terminator(
    //% \name Clock and reset
    //% @{
    input CLK_I,
    input reset_n,
    //% @}
    
    //% \name WISHBONE slave
    //% @{
    input [31:2]    ADR_I,
    input           CYC_I,
    input           WE_I,
    input           STB_I,
    input [3:0]     SEL_I,
    input [31:0]    slave_DAT_I,
    output [31:0]   slave_DAT_O,
    output reg      ACK_O,
    output reg      RTY_O,
    output          ERR_O,
    //% @}
    
    //% \name ao68000 interrupt cycle indicator
    //% @{
    input           cpu_space_cycle
    //% @}
);

assign ERR_O        = 1'b0;
assign slave_DAT_O  = 32'd0;

wire accepted_addresses =
    ({ADR_I, 2'b00} >= 32'h00F00000 && {ADR_I, 2'b00} <= 32'h00F7FFFC) ||
    ({ADR_I, 2'b00} >= 32'h00E80000 && {ADR_I, 2'b00} <= 32'h00EFFFFC) ||
    // Lotus2
    ({ADR_I, 2'b00} >= 32'h00200000 && {ADR_I, 2'b00} <= 32'h009FFFFF) ||
    // Pinball Dreams
    {ADR_I, 2'b00} == 32'h00DFF11C ||
    
    {ADR_I, 2'b00} == 32'h00DFF1FC ||
    {ADR_I, 2'b00} == 32'h00DFF0FC ||
    {ADR_I, 2'b00} == 32'h00DC003C ||
    {ADR_I, 2'b00} == 32'h00D8003C ||
    {ADR_I, 2'b00} == 32'hFFFFFFFC;

always @(posedge CLK_I or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        ACK_O <= 1'b0;
        RTY_O <= 1'b0;
    end
    else begin
        if( cpu_space_cycle == 1'b0 &&
            accepted_addresses == 1'b1 &&
            CYC_I == 1'b1 && STB_I == 1'b1 && ACK_O == 1'b0)    ACK_O <= 1'b1;
        else                                                    ACK_O <= 1'b0;
        
        if( cpu_space_cycle == 1'b1 && 
            ADR_I[31:5] == 27'b111_1111_1111_1111_1111_1111_1111 &&
            CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b0)
        begin
            RTY_O <= 1'b1;
        end
        else begin
            RTY_O <= 1'b0;
        end
    end
end

endmodule
