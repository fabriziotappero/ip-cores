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
 * \brief On-Screen-Display and overall system management.
 */

/*! \brief \copybrief control_osd.v
*/
module control_osd(
    //% \name Clock and reset
    //% @{
    input               CLK_I,
	input               reset_n,
    output              reset_request,
    output reg          management_mode,
    //% @}
    
    //% \name WISHBONE master
    //% @{
    output reg          CYC_O,
    output reg          STB_O,
    output reg          WE_O,
    output reg [31:2]   ADR_O,
    output [3:0]        SEL_O,
    output reg [31:0]   master_DAT_O,
    input [31:0]        master_DAT_I,
    input               ACK_I,
    //% @}
    
    //% \name WISHBONE slave
    //% @{
    input [31:2]        ADR_I,
	input               CYC_I,
	input               WE_I,
	input               STB_I,
	input [3:0]         SEL_I,
	input [31:0]        slave_DAT_I,
	output [31:0]       slave_DAT_O,
	output reg          ACK_O,
	output              RTY_O,
	output              ERR_O,
    //% @}
    
    //% \name On-Screen-Display management interface
    //% @{
    input               request_osd,
    output reg          on_screen_display,
    
    input [4:0]         osd_line,
    input [4:0]         osd_column,
    output [7:0]        character,
	
	output reg          joystick_enable,
	input               keyboard_select,
	input               keyboard_up,
	input               keyboard_down,
	//% @}
	
	//% \name On-Screen-Display floppy management interface
    //% @{
	output              floppy_inserted,
    output reg [31:0]   floppy_sector,
    output reg          floppy_write_enabled,
    input               floppy_error
    //% @}
);

assign ERR_O = 1'b0;
assign RTY_O = 1'b0;
assign SEL_O = 4'b1111;

//****************** Display memory
wire [31:0] char;
wire [31:0] display_q;
assign slave_DAT_O = ({ADR_I, 2'b00} >= 32'h10000000 && {ADR_I, 2'b00} <= 32'h10000FFF)? display_q : 32'd0;

altsyncram display_ram_inst(
    .clock0(CLK_I),
    .clock1(CLK_I),
    .address_a(ADR_I[11:2]),
    .wren_a(CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b1 && {ADR_I, 2'b00} >= 32'h10000000 && {ADR_I, 2'b00} <= 32'h10000FFF),
    .data_a(slave_DAT_I),
    .byteena_a(SEL_I),
    .q_a(display_q),
    .address_b(char_addr[11:2]),
    .q_b(char)
);
defparam display_ram_inst.operation_mode = "BIDIR_DUAL_PORT";
defparam display_ram_inst.width_a = 32;
defparam display_ram_inst.widthad_a = 10;
defparam display_ram_inst.width_byteena_a = 4;
defparam display_ram_inst.width_b = 32;
defparam display_ram_inst.widthad_b = 10;
defparam display_ram_inst.init_file = "control_osd.mif";

wire [7:0] final_char;
assign final_char =
    (char_addr[1:0] == 2'd0)? char[31:24] :
    (char_addr[1:0] == 2'd1)? char[23:16] :
    (char_addr[1:0] == 2'd2)? char[15:8] :
    char[7:0];

assign character = (osd_line == 5'd9 && final_char != 8'd0)? {1'b1, final_char[6:0]} : final_char;

//***************** Control
reg [7:0] pointer;
reg [7:0] selected_floppy_pointer;

reg [31:0] value_a;
reg [31:0] value_b;

reg [1:0] value_counter;
reg [4:0] last_osd_column;

reg last_keyboard_up;
reg last_keyboard_down;
reg last_keyboard_select;
reg last_request_osd;

reg [22:0] keyboard_counter;
reg keyboard_repeating;
wire keyboard_repeat;
assign keyboard_repeat = (keyboard_repeating == 1'b0 && keyboard_counter == 23'd6000000) || (keyboard_repeating == 1'b1 && keyboard_counter == 23'd1000000);

wire [12:0] current_addr;
assign current_addr = {3'b0, osd_line, 5'b0} - 13'd64 + { pointer, 5'b0 };
wire [12:0] selected_floppy_addr;
assign selected_floppy_addr = { 3'b0, 5'd9, 5'b0 } - 13'd64 + { selected_floppy_pointer, 5'b0 };

wire [11:0] char_addr;
assign char_addr =
    ((value_counter == 2'd1)?   5'd24 :
     (value_counter > 2'd1)?    5'd28 :
     (osd_column == 5'd31)?     12'd0 : osd_column + 5'd1
    ) +
    ((osd_line == 5'd0 && state != S_ON_SCREEN_DISPLAY)?    12'd0 :
     (osd_line == 5'd0 && state == S_ON_SCREEN_DISPLAY)?    12'd160 :
     
     (osd_line == 5'd1 && state == S_SD_CHECK_INIT)?        12'd32 :
     (osd_line == 5'd1 && state == S_SD_ERROR)?             12'd64 :
     (osd_line == 5'd1 && state == S_SELECT_ROM)?           12'd96 :
     (osd_line == 5'd1 && state == S_ON_SCREEN_DISPLAY && floppy_inserted == 1'd0)?
                                                            12'd192 :
     (osd_line == 5'd1 && state == S_ON_SCREEN_DISPLAY)?    selected_floppy_addr[11:0] - 12'd96 + 12'd1024 :
     
     (osd_line == 5'd9 && state == S_SD_ERROR)?             12'd352 :
     (state == S_SD_ERROR)?                                 12'd128 :
     
     (current_addr[12] == 1'b1)?                            12'd128 :
     (state == S_SELECT_ROM)?                               current_addr[11:0] + 12'd512 :
     
     (state != S_ON_SCREEN_DISPLAY)?                        12'd128 :
     
     (current_addr[11:0] == 12'd0 && joystick_enable == 1'b0)?
                                                            12'd224 :
     (current_addr[11:0] == 12'd0 && joystick_enable == 1'b1)?
                                                            12'd256 :
     
     (current_addr[11:0] == 12'd32 && floppy_write_enabled == 1'b0)?
                                                            12'd288 :
     (current_addr[11:0] == 12'd32 && floppy_write_enabled == 1'b1)?
                                                            12'd320 :
                                                            
     (current_addr[11:0] == 12'd64)?                        12'd352 :
     
     (current_addr[11:0] == 12'd96 && floppy_inserted == 1'd1)?
                                                            12'd384 :
     
     (floppy_inserted == 13'd0)?                            current_addr[11:0] - 12'd96 + 12'd1024 :
     
                                                            12'd128
                                                            
    );
    
assign floppy_inserted = (floppy_sector != 32'd0);
assign reset_request = {last_keyboard_select == 1'b0 && keyboard_select == 1'b1 && value_a[3] == 1'b1};

reg [3:0] state;
parameter [3:0]
    S_SD_CHECK_INIT     = 4'd0,
    S_SD_ERROR          = 4'd1,
    S_READ_INTRO        = 4'd2,
    S_READ_INTRO_WAIT   = 4'd3,
    S_READ_HEADER       = 4'd4,
    S_READ_HEADER_WAIT  = 4'd5,
    S_SELECT_ROM        = 4'd6,
    S_COPY_ROM          = 4'd7,
    S_RUNNING           = 4'd8,
    S_ON_SCREEN_DISPLAY = 4'd9;
    
reg [1:0] substate;

always @(posedge CLK_I or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        CYC_O <= 1'b0;
        STB_O <= 1'b0;
        ADR_O <= 30'd0;
        WE_O <= 1'b0;
        master_DAT_O <= 32'd0;
        
        ACK_O <= 1'b0;
        
        management_mode <= 1'b1;
        pointer <= -8'd7;
        selected_floppy_pointer <= -8'd5;
        
        value_a <= 32'd0;
        value_b <= 32'd0;
        value_counter <= 2'd0;
        last_osd_column <= 5'd0;
        
        last_keyboard_up <= 1'b0;
        last_keyboard_down <= 1'b0;
        last_keyboard_select <= 1'b0;
        last_request_osd <= 1'b0;
        
        on_screen_display       <= 1'b1;
        joystick_enable         <= 1'b0;
        floppy_sector           <= 32'd0;
        floppy_write_enabled    <= 1'b0;
        
        keyboard_counter <= 23'd0;
        keyboard_repeating <= 1'b0;
        
        substate <= 2'd0;
        state <= S_SD_CHECK_INIT;
    end
    else begin
        if(CYC_I == 1'b1 && STB_I == 1'b1 && ACK_O == 1'b0) ACK_O <= 1'b1;
        else                                                ACK_O <= 1'b0;
        
        
        last_osd_column         <= osd_column;
        last_keyboard_up        <= keyboard_up;
        last_keyboard_down      <= keyboard_down;
        last_keyboard_select    <= keyboard_select;
        last_request_osd        <= request_osd;
        
        if(osd_column == 5'd31 && last_osd_column != 5'd31) value_counter <= 2'd1;
        else if(value_counter != 2'd0)                      value_counter <= value_counter + 2'd1;
        
        if(osd_line == 5'd9 && value_counter == 2'd2) value_a <= char;
        if(osd_line == 5'd9 && value_counter == 2'd3) value_b <= char;
        
        if(keyboard_up == 1'b0 && keyboard_down == 1'b0)    keyboard_repeating <= 1'b0;
        else if(keyboard_repeat == 1'b1)                    keyboard_repeating <= 1'b1;
        
        if((keyboard_up == 1'b1 || keyboard_down == 1'b1) && keyboard_repeat == 1'b0)   keyboard_counter <= keyboard_counter + 21'd1;
        else                                                                            keyboard_counter <= 21'd0;
        
        if(keyboard_up == 1'b1 && (last_keyboard_up == 1'b0 || keyboard_repeat == 1'b1) && value_a[0] == 1'b1 && value_a[1] == 1'b0)
            pointer <= pointer - 8'd1;
        else if(keyboard_down == 1'b1 && (last_keyboard_down == 1'b0 || keyboard_repeat == 1'b1) && value_a[0] == 1'b1 && value_a[2] == 1'b0)
            pointer <= pointer + 8'd1;
        else if(state == S_ON_SCREEN_DISPLAY && last_keyboard_select == 1'b0 && keyboard_select == 1'b1 && value_a[5] == 1'b1 && floppy_inserted == 13'd1)
            pointer <= selected_floppy_pointer;
        else if(state == S_ON_SCREEN_DISPLAY && last_keyboard_select == 1'b0 && keyboard_select == 1'b1 && value_a[5] == 1'b1 && floppy_inserted == 13'd0)
            pointer <= -8'd4;
        
        if(floppy_error == 1'b1) begin
            CYC_O <= 1'b0;
            STB_O <= 1'b0;
            
            on_screen_display <= 1'b1;
            state <= S_SD_ERROR;
        end
        else if(state == S_SD_CHECK_INIT) begin
            if(ACK_I == 1'b1 && CYC_O == 1'b1 && STB_O == 1'b1) begin
                CYC_O <= 1'b0;
                STB_O <= 1'b0;
                
                if(master_DAT_I == 32'd2) begin
                    ADR_O <= 30'h4000400; // 0x10001000, base write address
                    substate <= 2'd0;
                    state <= S_READ_INTRO;
                end
                else if(master_DAT_I == 32'd1) begin
                    state <= S_SD_ERROR;
                end
            end
            else if(ACK_I == 1'b0) begin
                CYC_O <= 1'b1;
                STB_O <= 1'b1;
                WE_O <= 1'b0;
                ADR_O <= 30'h4000400; // 0x10001000, read state
            end
        end
        
        else if(state == S_READ_INTRO) begin
            if(ACK_I == 1'b1 && CYC_O == 1'b1 && STB_O == 1'b1) begin
                CYC_O <= 1'b0;
                STB_O <= 1'b0;
                
                if(substate < 2'd3) begin
                    substate <= substate + 2'd1;
                    ADR_O <= ADR_O + 30'd1;
                end
                else begin
                    substate <= 2'd0;
                    state <= S_READ_INTRO_WAIT;
                end
            end
            else if(ACK_I == 1'b0) begin
                CYC_O <= 1'b1;
                STB_O <= 1'b1;
                WE_O <= 1'b1;
                //ADR_O <= ADR_O;
                
                master_DAT_O <=
                    (substate == 2'd0)? 32'h10180000 :  // base address, 0x10000000
                    (substate == 2'd1)? 32'd0 :         // sd sector number
                    (substate == 2'd2)? 32'd432 :       // read sector size
                    32'd2;                              // start sd read
            end
        end
        else if(state == S_READ_INTRO_WAIT) begin
            if(ACK_I == 1'b1 && CYC_O == 1'b1 && STB_O == 1'b1) begin
                CYC_O <= 1'b0;
                STB_O <= 1'b0;
                
                if(master_DAT_I == 32'd2) begin
                    ADR_O <= 30'h4000400; // 0x10001000, base write address
                    substate <= 2'd0;
                    state <= S_READ_HEADER;
                end
                else if(master_DAT_I == 32'd5) begin
                    state <= S_SD_ERROR;
                end
            end
            else if(ACK_I == 1'b0) begin
                CYC_O <= 1'b1;
                STB_O <= 1'b1;
                WE_O <= 1'b0;
                ADR_O <= 30'h4000400; // 0x10001000, read state
            end
        end
        
        else if(state == S_READ_HEADER) begin
            if(ACK_I == 1'b1 && CYC_O == 1'b1 && STB_O == 1'b1) begin
                CYC_O <= 1'b0;
                STB_O <= 1'b0;
                
                if(substate < 2'd3) begin
                    substate <= substate + 2'd1;
                    ADR_O <= ADR_O + 30'd1;
                end
                else begin
                    substate <= 2'd0;
                    state <= S_READ_HEADER_WAIT;
                end
            end
            else if(ACK_I == 1'b0) begin
                CYC_O <= 1'b1;
                STB_O <= 1'b1;
                WE_O <= 1'b1;
                //ADR_O <= ADR_O;
                
                master_DAT_O <=
                    (substate == 2'd0)? 32'h10000200 :  // base address, 0x10000000
                    (substate == 2'd1)? 32'd432 :       // sd sector number
                    (substate == 2'd2)? 32'd8 :         // read sector size
                    32'd2;                              // start sd read
            end
        end
        else if(state == S_READ_HEADER_WAIT) begin
            if(ACK_I == 1'b1 && CYC_O == 1'b1 && STB_O == 1'b1) begin
                CYC_O <= 1'b0;
                STB_O <= 1'b0;
                
                if(master_DAT_I == 32'd2) begin
                    ADR_O <= 30'h4000400; // 0x10001000, base write address
                    substate <= 2'd0;
                    state <= S_SELECT_ROM;
                end
                else if(master_DAT_I == 32'd5) begin
                    state <= S_SD_ERROR;
                end
            end
            else if(ACK_I == 1'b0) begin
                CYC_O <= 1'b1;
                STB_O <= 1'b1;
                WE_O <= 1'b0;
                ADR_O <= 30'h4000400; // 0x10001000, read state
            end
        end
        else if(state == S_SELECT_ROM && keyboard_select == 1'b1 && value_a != 32'd0) begin
            if(ACK_I == 1'b1 && CYC_O == 1'b1 && STB_O == 1'b1) begin
                CYC_O <= 1'b0;
                STB_O <= 1'b0;
                
                if(substate < 2'd3) begin
                    substate <= substate + 2'd1;
                    ADR_O <= ADR_O + 30'd1;
                end
                else begin
                    substate <= 2'd0;
                    state <= S_COPY_ROM;
                end
            end
            else if(ACK_I == 1'b0) begin
                CYC_O <= 1'b1;
                STB_O <= 1'b1;
                WE_O <= 1'b1;
                //ADR_O <= ADR_O;
                
                master_DAT_O <=
                    (substate == 2'd0)? 32'h001C0000 :  // base address, 0x00FC0000
                    (substate == 2'd1)? value_b :       // sd sector number
                    (substate == 2'd2)? 32'd512 :       // read sector size
                    32'd2;                              // start sd read
            end
        end
        else if(state == S_COPY_ROM) begin
            if(ACK_I == 1'b1 && CYC_O == 1'b1 && STB_O == 1'b1) begin
                CYC_O <= 1'b0;
                STB_O <= 1'b0;
                
                if(master_DAT_I == 32'd2) begin
                    substate <= 2'd0;
                    management_mode <= 1'b0;
                    on_screen_display <= 1'b0;
                    state <= S_RUNNING;
                end
                else if(master_DAT_I == 32'd5) begin
                    state <= S_SD_ERROR;
                end
            end
            else if(ACK_I == 1'b0) begin
                CYC_O <= 1'b1;
                STB_O <= 1'b1;
                WE_O <= 1'b0;
                ADR_O <= 30'h4000400; // 0x10001000, read state
            end
        end
        else if(state == S_RUNNING && last_request_osd == 1'b0 && request_osd == 1'b1) begin
            on_screen_display <= 1'b1;
            state <= S_ON_SCREEN_DISPLAY;
        end
        else if(state == S_ON_SCREEN_DISPLAY && last_request_osd == 1'b0 && request_osd == 1'b1) begin
            on_screen_display <= 1'b0;
            state <= S_RUNNING;
        end
        else if(state == S_ON_SCREEN_DISPLAY && last_keyboard_select == 1'b0 && keyboard_select == 1'b1 && value_a[4] == 1'b1) begin
            joystick_enable <= ~joystick_enable;
        end
        else if(state == S_ON_SCREEN_DISPLAY && last_keyboard_select == 1'b0 && keyboard_select == 1'b1 && value_a[6] == 1'b1) begin
            floppy_write_enabled <= ~floppy_write_enabled;
        end
        else if(state == S_ON_SCREEN_DISPLAY && last_keyboard_select == 1'b0 && keyboard_select == 1'b1 && value_a[5] == 1'b1) begin
            if(floppy_inserted == 13'd1) begin
                floppy_sector <= 32'd0;
            end
            else begin
                floppy_sector <= value_b;
                selected_floppy_pointer <= pointer;
            end
        end
    end
end

endmodule

