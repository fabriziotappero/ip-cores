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
 * \brief OCS serial port implementation with WISHBONE slave interface. [functionality not implemented]
 */

/*! \brief \copybrief ocs_serial.v

List of serial registers:
\verbatim
Not implemented:
    SERDATR     *018  R   P       Serial port data and status read              read implemented here
     [DSKBYTR   *01A  R   P       Disk data byte and status read                read implemented here]

    SERDAT      *030  W   P       Serial port data and stop bits write
    SERPER      *032  W   P       Serial port period and control
\endverbatim
*/

module ocs_serial(
    //% \name Clock and reset
    //% @{
    input CLK_I,
    input reset_n,
    //% @}
    
    //% \name WISHBONE slave
    //% @{
    input CYC_I,
    input STB_I,
    input WE_I,
    input [8:2] ADR_I,
    input [3:0] SEL_I,
    input [31:0] DAT_I,
    output reg [31:0] DAT_O,
    output reg ACK_O,
    //% @}
    
    //% \name Not aligned register access on a 32-bit WISHBONE bus
    //% @{
        // DSKBYTR read implemented here
    output na_dskbytr_read,
    input [15:0] na_dskbytr
    //% @}
);

assign na_dskbytr_read =
    (CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b0 && { ADR_I, 2'b0 } == 9'h018 && SEL_I[1:0] != 2'b00 && ACK_O == 1'b0);

always @(posedge CLK_I or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        DAT_O <= 32'd0;
        ACK_O <= 1'b0;
    end
    else begin
        if(CYC_I == 1'b1 && STB_I == 1'b1 && ACK_O == 1'b0) ACK_O <= 1'b1;
        else ACK_O <= 1'b0;
        
        if(CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b0) begin
            if({ ADR_I, 2'b0 } == 9'h018 && SEL_I[0] == 1'b1)  DAT_O[7:0]     <= na_dskbytr[7:0];
            if({ ADR_I, 2'b0 } == 9'h018 && SEL_I[1] == 1'b1)  DAT_O[15:8]    <= na_dskbytr[15:8];
            if({ ADR_I, 2'b0 } == 9'h018 && SEL_I[2] == 1'b1)  DAT_O[23:16]   <= 8'd0;
            if({ ADR_I, 2'b0 } == 9'h018 && SEL_I[3] == 1'b1)  DAT_O[31:24]   <= 8'd0;
        end
    end
end

endmodule
