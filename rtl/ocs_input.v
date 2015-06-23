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
 * \brief OCS user input implementation with WISHBONE slave interface.
 */

/*! \brief \copybrief ocs_input.v

List of user input registers:
\verbatim
Implemented:
     [DSKDATR & *008  ER  P       Disk data early read (dummy address)          not implemented]
    JOY0DAT     *00A  R   D       Joystick-mouse 0 data (vert,horiz)            read implemented here
    
    JOY1DAT     *00C  R   D       Joystick-mouse 1 data (vert,horiz)            read implemented here
     [CLXDAT    *00E  R   D       Collision data register (read and clear)      read implemented here]
    
    JOYTEST     *036  W   D       Write to all four joystick-mouse counters at once

Not implemented:
     [ADKCONR   *010  R   P       Audio, disk control register read             read not implemented here]
    POT0DAT     *012  R   P( E )  Pot counter pair 0 data (vert,horiz)          read not implemented here
    
    POT1DAT     *014  R   P( E )  Pot counter pair 1 data (vert,horiz)          
    POTGOR      *016  R   P       Pot port data read (formerly POTINP)
    POTGO       *034  W   P       Pot port data write and start
\endverbatim
*/
module ocs_input(
    //% \name Clock and reset
    //% @{
    input               CLK_I,
    input               reset_n,
    //% @}
    
    //% \name On-Screen-Display management interface
    //% @{
    input               on_screen_display,
    input               enable_joystick_1,
    //% @}
    
    //% \name WISHBONE slave
    //% @{
    input               CYC_I,
    input               STB_I,
    input               WE_I,
    input [8:2]         ADR_I,
    input [3:0]         SEL_I,
    input [31:0]        DAT_I,
    output reg [31:0]   DAT_O,
    output reg          ACK_O,
    //% @}
    
    //% \name Not aligned register access on a 32-bit WISHBONE bus
    //% @{
        // CLXDAT read implemented here
    output              na_clx_dat_read,
    input [15:0]        na_clx_dat,
        // POT0DAT read not implemented here
    input               na_pot0dat_read,
    output [15:0]       na_pot0dat,
    //% @}
    
    //% \name User input CIA interface
    //% @{
    // keyboard output
    input               sp_from_cia,
    output              sp_to_cia,
    output reg          cnt_to_cia,
    
    // CIA-A fire buttons
    output reg          ciaa_fire_0_n,
    output              ciaa_fire_1_n,
    //% @}
    
    //% \name drv_keyboard interface
    //% @{
    output              keyboard_ready,
    input               keyboard_event,
    input [7:0]         keyboard_scancode,
    
    // joystick on port 1
    input               joystick_1_up,
    input               joystick_1_down,
    input               joystick_1_left,
    input               joystick_1_right,
    input               joystick_1_fire,
    //% @}
    
    //% \name drv_mouse interface
    //% @{
    input               mouse_moved,
    input [8:0]         mouse_y_move,
    input [8:0]         mouse_x_move,
    input               mouse_left_button,
    input               mouse_right_button,
    input               mouse_middle_button
    //% @}
);

//-------------------- keyboard start
assign sp_to_cia = ~sp_shift[7];

assign keyboard_ready = (cnt_counter == 16'd0);


reg [15:0] cnt_counter;
reg [7:0] sp_shift;
always @(posedge CLK_I or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        cnt_to_cia  <= 1'b1;
        cnt_counter <= 16'd0;
        sp_shift    <= 8'hFF;
    end
    else if(keyboard_event == 1'b1 && on_screen_display == 1'b0) begin
        sp_shift <= keyboard_scancode;
        cnt_counter <= cnt_counter + 16'd1;
        cnt_to_cia <= 1'b0;
    end
    else if(cnt_counter >= 16'd1 && cnt_counter <= 16'd15) begin
        cnt_counter <= cnt_counter + 16'd1;
        cnt_to_cia <= ~cnt_to_cia;
        if(cnt_to_cia == 1'b1) sp_shift <= { sp_shift[6:0], 1'b0 };
    end
    else if(cnt_counter == 16'd16 && sp_from_cia == 1'b0) begin
        cnt_counter <= cnt_counter + 16'd1;
    end
    else if(cnt_counter == 16'd17 && sp_from_cia == 1'b1) begin
        cnt_counter <= 16'd0;
    end
/*  synchronization
    else if(cnt_counter == 16'd65535 && sp_from_cia == 1'b1) begin
        cnt_to_cia <= ~cnt_to_cia;
        cnt_counter <= 16'd16;
    end
    else if(cnt_counter >= 16'd16 && sp_from_cia == 1'b1) begin
        cnt_counter <= cnt_counter + 16'd1;
    end
    else sp_from_cia == 1'b0 -> sp_from_cia == 1'b0 begin
        cnt_counter <= 16'd0;
    end
*/
end
//-------------------- keyboard end


assign na_pot0dat = 16'd0;

assign na_clx_dat_read =
    (CYC_I == 1'b1 && STB_I == 1'b1 && ACK_O == 1'b0 && WE_I == 1'b0 && { ADR_I, 2'b0 } == 9'h018 && SEL_I[1:0] != 2'b00);

reg [15:0] potgo;
reg [15:0] joy0dat;
reg [15:0] joy1dat;
reg right_button_n;
reg middle_button_n;

wire [15:0] joy1dat_final;
assign joy1dat_final =
    (enable_joystick_1 == 1'b1)?
    {   6'b0,                               //15-10
        joystick_1_left,                    //9
        joystick_1_up ^ joystick_1_left,    //8
        6'b0,                               //7-2
        joystick_1_right,                   //1
        joystick_1_down ^ joystick_1_right  //0
    } :
    joy1dat;

assign ciaa_fire_1_n = (enable_joystick_1 == 1'b1 && joystick_1_fire == 1'b1)? 1'b0 : 1'b1;

wire [15:0] potgo_final;
assign potgo_final = { 1'b0, potgo[14], 1'b0, potgo[12], 1'b0, right_button_n, 1'b0, middle_button_n, 7'b0, 1'b0 };

wire [8:0] joy0dat_y;
assign joy0dat_y = { joy0dat[15], joy0dat[15:8] } - mouse_y_move;

wire [8:0] joy0dat_x;
assign joy0dat_x = { joy0dat[7], joy0dat[7:0] } + mouse_x_move;

always @(posedge CLK_I or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        DAT_O           <= 32'd0;
        ACK_O           <= 1'b0;
        
        ciaa_fire_0_n   <= 1'b1;
        
        potgo           <= 16'd0;
        joy0dat         <= 16'd0;
        joy1dat         <= 16'd0;
        
        right_button_n  <= 1'b1;
        middle_button_n <= 1'b1;
    end
    else begin
        if(CYC_I == 1'b1 && STB_I == 1'b1 && ACK_O == 1'b0) ACK_O <= 1'b1;
        else                                                ACK_O <= 1'b0;
        
        if(mouse_moved == 1'b1) begin
            joy0dat[15:8] <= joy0dat_y[7:0];
            joy0dat[7:0] <= joy0dat_x[7:0];
            
            ciaa_fire_0_n   <= ~mouse_left_button;
            right_button_n  <= ~mouse_right_button;
            middle_button_n <= ~mouse_middle_button;
        end
        
        if(CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b0) begin
            if({ ADR_I, 2'b0 } == 9'h008)                       DAT_O[31:0]     <= { 16'd0 /*DSKDATR*/, joy0dat };
            if({ ADR_I, 2'b0 } == 9'h00C)                       DAT_O[31:0]     <= { joy1dat_final, na_clx_dat };
            if({ ADR_I, 2'b0 } == 9'h014)                       DAT_O[31:0]     <= { 16'd0 /*POT1DAT*/, potgo_final };
        end
        else if(CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b1) begin
            if({ ADR_I, 2'b0 } == 9'h034 && SEL_I[3] == 1'b1)   potgo[15:8] <= DAT_I[31:24];
            if({ ADR_I, 2'b0 } == 9'h034 && SEL_I[2] == 1'b1)   potgo[7:0]  <= DAT_I[23:16];
            if({ ADR_I, 2'b0 } == 9'h034 && SEL_I[1] == 1'b1)   { joy0dat[15:8], joy1dat[15:8] } <= { DAT_I[15:8], DAT_I[15:8] };
            if({ ADR_I, 2'b0 } == 9'h034 && SEL_I[0] == 1'b1)   { joy0dat[7:0], joy1dat[7:0] } <= { DAT_I[7:0], DAT_I[7:0] };
        end
    end
end

endmodule
