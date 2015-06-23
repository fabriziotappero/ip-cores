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

module ps2(
    input                   clk,
    input                   rst_n,
    
    output reg              irq_keyb,
    output reg              irq_mouse,
    
    //io slave 0x60-0x67
    input       [2:0]       io_address,
    input                   io_read,
    output reg  [7:0]       io_readdata,
    input                   io_write,
    input       [7:0]       io_writedata,
    
    //io slave 0x90-0x9F
    input       [3:0]       sysctl_address,
    input                   sysctl_read,
    output reg  [7:0]       sysctl_readdata,
    input                   sysctl_write,
    input       [7:0]       sysctl_writedata,
    
    //speaker port 61h
    output                  speaker_61h_read,
    input       [7:0]       speaker_61h_readdata,
    output                  speaker_61h_write,
    output      [7:0]       speaker_61h_writedata,
    
    //output port
    output reg              output_a20_enable,
    output reg              output_reset_n,
    
    //ps2 keyboard
    inout                   ps2_kbclk,
    inout                   ps2_kbdat,
    
    //ps2 mouse
    inout                   ps2_mouseclk,
    inout                   ps2_mousedat
);

//------------------------------------------------------------------------------

reg io_read_last;
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) io_read_last <= 1'b0; else if(io_read_last) io_read_last <= 1'b0; else io_read_last <= io_read; end 
wire io_read_valid = io_read && io_read_last == 1'b0;

//------------------------------------------------------------------------------

assign speaker_61h_read         = io_read_valid && io_address == 3'd1;
assign speaker_61h_write        = io_write && io_address == 3'd1;
assign speaker_61h_writedata    = io_writedata;

//------------------------------------------------------------------------------ io read

wire [7:0] io_readdata_next =
    (io_read_valid && io_address == 3'd1)?        speaker_61h_readdata :
    (io_read_valid && io_address == 3'd4)? {
        status_keyboardparityerror,
        status_timeout,
        status_mousebufferfull,
        1'b1, //keyboard inhibit
        status_lastcommand,
        status_system,
        status_inputbufferfull,
        status_outputbufferfull
    } :
    (status_mousebufferfull)?               mouse_fifo_q :
                                            keyb_fifo_q_final;

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   io_readdata <= 8'd0;
    else                io_readdata <= io_readdata_next;
end

//------------------------------------------------------------------------------ sysctl read

wire [7:0] sysctl_readdata_next =
    (sysctl_address == 4'h2)?       { 6'd0, output_a20_enable, 1'b0 } :
                                    8'hFF;

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   sysctl_readdata <= 8'd0;
    else                sysctl_readdata <= sysctl_readdata_next;
end

//------------------------------------------------------------------------------ output

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   output_a20_enable <= 1'b1;
    else if(cmd_write_output_port)                      output_a20_enable <= io_writedata[1];
    else if(cmd_disable_a20)                            output_a20_enable <= 1'b0;
    else if(cmd_enable_a20)                             output_a20_enable <= 1'b1;
    else if(sysctl_write && sysctl_address == 4'h2)     output_a20_enable <= sysctl_writedata[1];
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                       output_reset_n <= 1'b1;
    else if(cmd_write_output_port)                                          output_reset_n <= io_writedata[0];
    else if(cmd_reset)                                                      output_reset_n <= 1'b0;
    else if(sysctl_write && sysctl_address == 4'h2 && sysctl_writedata[0])  output_reset_n <= 1'b0;
    else                                                                    output_reset_n <= 1'b1;
end

//------------------------------------------------------------------------------

reg status_keyboardparityerror;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                       status_keyboardparityerror <= 1'b0;
    else if(keyb_recv_parity_err || mouse_recv_parity_err)  status_keyboardparityerror <= 1'b1;
    else if(io_read_valid && io_address == 3'd4)            status_keyboardparityerror <= 1'b0;
end

reg status_timeout;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   status_timeout <= 1'b0;
    else if(keyb_timeout_reset || mouse_timeout_reset)  status_timeout <= 1'b1;
    else if(io_read_valid && io_address == 3'd4)        status_timeout <= 1'b0;
end

reg status_lastcommand;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                           status_lastcommand <= 1'b1;
    else if(io_write && io_address == 3'd0)     status_lastcommand <= 1'b0;
    else if(io_write && io_address == 3'd4)     status_lastcommand <= 1'b1;
end

reg translate;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   translate <= 1'b1;
    else if(cmd_write_command_byte)     translate <= io_writedata[6];
end

reg disable_mouse;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   disable_mouse <= 1'b0;
    else if(cmd_write_command_byte)     disable_mouse <= io_writedata[5];
    else if(cmd_disable_mouse)          disable_mouse <= 1'b1;
    else if(cmd_enable_mouse)           disable_mouse <= 1'b0;
    else if(write_to_mouse)             disable_mouse <= 1'b0;
end

reg disable_mouse_visible;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   disable_mouse_visible <= 1'b0;
    else if(cmd_write_command_byte)     disable_mouse_visible <= io_writedata[5];
    else if(cmd_disable_mouse)          disable_mouse_visible <= 1'b1;
    else if(cmd_enable_mouse)           disable_mouse_visible <= 1'b0;
end

reg disable_keyboard;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   disable_keyboard <= 1'b0;
    else if(cmd_write_command_byte)     disable_keyboard <= io_writedata[4];
    else if(cmd_disable_keyb)           disable_keyboard <= 1'b1;
    else if(cmd_enable_keyb)            disable_keyboard <= 1'b0;
    else if(write_to_keyb)              disable_keyboard <= 1'b0;
end

reg status_system;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   status_system <= 1'b0;
    else if(cmd_write_command_byte)     status_system <= io_writedata[2];
    else if(cmd_self_test)              status_system <= 1'b1;
end

reg allow_irq_mouse;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   allow_irq_mouse <= 1'b1;
    else if(cmd_write_command_byte)     allow_irq_mouse <= io_writedata[1];
end

reg allow_irq_keyb;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   allow_irq_keyb <= 1'b1;
    else if(cmd_write_command_byte)     allow_irq_keyb <= io_writedata[0];
end

//------------------------------------------------------------------------------ interrupts

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                                       irq_keyb <= 1'b0;
    else if(io_read_valid && io_address == 3'd0 && status_outputbufferfull && ~(status_mousebufferfull))    irq_keyb <= 1'b0;
    else if(allow_irq_keyb && status_outputbufferfull && ~(status_mousebufferfull))                         irq_keyb <= 1'b1;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                       irq_mouse <= 1'b0;
    else if(io_read_valid && io_address == 3'd0 && status_mousebufferfull)  irq_mouse <= 1'b0;
    else if(allow_irq_mouse && status_mousebufferfull)                      irq_mouse <= 1'b1;
end

wire outputbuffer_idle = ~(status_mousebufferfull) && ~(status_outputbufferfull);

reg status_mousebufferfull;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   status_mousebufferfull <= 1'b0;
    else if(io_read_valid && io_address == 3'd0)        status_mousebufferfull <= 1'b0;
    else if(outputbuffer_idle && ~(mouse_fifo_empty))   status_mousebufferfull <= 1'b1;
end

reg status_outputbufferfull;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                           status_outputbufferfull <= 1'b0;
    else if(io_read_valid && io_address == 3'd0)                                status_outputbufferfull <= 1'b0;
    else if(outputbuffer_idle && (~(mouse_fifo_empty) || ~(keyb_fifo_empty)))   status_outputbufferfull <= 1'b1;
end

//------------------------------------------------------------------------------ io write / controller commands

reg expecting_port_60h;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                           expecting_port_60h <= 1'b0;
    else if(io_write && io_address == 3'd0)     expecting_port_60h <= 1'b0;
    else if(cmd_with_param_first_byte)          expecting_port_60h <= 1'b1;
    else if(io_write && io_address == 3'd4)     expecting_port_60h <= 1'b0;
end

reg [7:0] last_command;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                           last_command <= 8'h00;
    else if(io_write && io_address == 3'd4)     last_command <= io_writedata;
end

wire cmd_with_param_first_byte  = io_write && io_address == 3'd4 && (
    io_writedata == 8'h60 || //write command byte
    io_writedata == 8'hCB || //write keyboard controller mode
    io_writedata == 8'hD1 || //write output port
    io_writedata == 8'hD3 || //write mouse output port
    io_writedata == 8'hD4 || //write to mouse
    io_writedata == 8'hD2    //write keyboard output buffer
);

wire cmd_with_param             = io_write && io_address == 3'd0 && expecting_port_60h && ~(status_inputbufferfull);
wire cmd_without_param          = io_write && io_address == 3'd4 && ~(cmd_with_param_first_byte);

wire cmd_write_command_byte     = cmd_with_param && last_command == 8'h60;
wire cmd_write_output_port      = cmd_with_param && last_command == 8'hD1;
wire cmd_write_to_keyb_output   = cmd_with_param && last_command == 8'hD2;
wire cmd_write_to_mouse_output  = cmd_with_param && last_command == 8'hD3;
wire cmd_write_to_mouse         = cmd_with_param && last_command == 8'hD4;

wire cmd_read_command_byte      = cmd_without_param && io_writedata == 8'h20;
wire cmd_disable_mouse          = cmd_without_param && io_writedata == 8'hA7;
wire cmd_enable_mouse           = cmd_without_param && io_writedata == 8'hA8;
wire cmd_test_mouse_port        = cmd_without_param && io_writedata == 8'hA9;
wire cmd_self_test              = cmd_without_param && io_writedata == 8'hAA;
wire cmd_interface_test         = cmd_without_param && io_writedata == 8'hAB;
wire cmd_disable_keyb           = cmd_without_param && io_writedata == 8'hAD;
wire cmd_enable_keyb            = cmd_without_param && io_writedata == 8'hAE;
wire cmd_read_input_port        = cmd_without_param && io_writedata == 8'hC0;
wire cmd_read_controller_mode   = cmd_without_param && io_writedata == 8'hCA;
wire cmd_read_output_port       = cmd_without_param && io_writedata == 8'hD0;
wire cmd_disable_a20            = cmd_without_param && io_writedata == 8'hDD;
wire cmd_enable_a20             = cmd_without_param && io_writedata == 8'hDF;
wire cmd_reset                  = cmd_without_param && io_writedata == 8'hFE;

//------------------------------------------------------------------------------ controller reply - not device

wire [7:0] command_byte = {
    1'b0,
    translate,
    disable_mouse_visible,
    disable_keyboard,
    1'b0,
    status_system,
    allow_irq_mouse,
    allow_irq_keyb
};

wire [7:0] output_port = {
    1'b0,
    1'b0,
    irq_mouse,
    irq_keyb,
    1'b0,
    1'b0,
    output_a20_enable,
    1'b1
};

reg [7:0] keyb_reply;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   keyb_reply <= 8'h00;
    else if(cmd_write_to_keyb_output)   keyb_reply <= io_writedata;
    else if(cmd_read_command_byte)      keyb_reply <= command_byte;
    else if(cmd_test_mouse_port)        keyb_reply <= 8'h00;
    else if(cmd_self_test)              keyb_reply <= 8'h55;
    else if(cmd_interface_test)         keyb_reply <= 8'h00;
    else if(cmd_read_input_port)        keyb_reply <= 8'h80;
    else if(cmd_read_controller_mode)   keyb_reply <= 8'h01;
    else if(cmd_read_output_port)       keyb_reply <= output_port;
end

reg keyb_reply_valid;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   keyb_reply_valid <= 1'b0;
    else if(cmd_write_to_keyb_output)   keyb_reply_valid <= 1'b1;
    else if(cmd_read_command_byte)      keyb_reply_valid <= 1'b1;
    else if(cmd_test_mouse_port)        keyb_reply_valid <= 1'b1;
    else if(cmd_self_test)              keyb_reply_valid <= 1'b1;
    else if(cmd_interface_test)         keyb_reply_valid <= 1'b1;
    else if(cmd_read_input_port)        keyb_reply_valid <= 1'b1;
    else if(cmd_read_controller_mode)   keyb_reply_valid <= 1'b1;
    else if(cmd_read_output_port)       keyb_reply_valid <= 1'b1;
    else if(ps2_kb_reply_done)          keyb_reply_valid <= 1'b0;
end

reg [7:0] mouse_reply;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   mouse_reply <= 8'd0;
    else if(cmd_write_to_mouse_output)  mouse_reply <= io_writedata;
end

reg mouse_reply_valid;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   mouse_reply_valid <= 1'b0;
    else if(cmd_write_to_mouse_output)  mouse_reply_valid <= 1'b1;
    else if(ps2_mouse_reply_done)       mouse_reply_valid <= 1'b0;
end

//------------------------------------------------------------------------------ write to device

wire write_to_keyb  = io_write && io_address == 3'd0 && ~(expecting_port_60h) && ~(status_inputbufferfull);
wire write_to_mouse = cmd_write_to_mouse;

reg status_inputbufferfull;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                       status_inputbufferfull <= 1'b0;
    else if(write_to_keyb || write_to_mouse)                status_inputbufferfull <= 1'b1;
    else if(input_write_done && status_outputbufferfull)    status_inputbufferfull <= 1'b0;
end

reg input_write_done;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   input_write_done <= 1'b0;
    else if(write_to_keyb || write_to_mouse)            input_write_done <= 1'b0;
    else if(ps2_kb_write_done || ps2_mouse_write_done)  input_write_done <= 1'b1;
end

reg input_for_mouse;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       input_for_mouse <= 1'b0;
    else if(write_to_keyb)  input_for_mouse <= 1'b0;
    else if(write_to_mouse) input_for_mouse <= 1'b1;
end

reg [7:0] inputbuffer;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                       inputbuffer <= 8'd0;
    else if(write_to_keyb || write_to_mouse)                inputbuffer <= io_writedata;
    else if(ps2_kb_write_shift || ps2_mouse_write_shift)    inputbuffer <= { 1'b0, inputbuffer[7:1] };
end

//------------------------------------------------------------------------------ ps/2 for keyboard

assign ps2_kbclk    = (ps2_kbclk_ena)?      ps2_kbclk_out       : 1'bZ;
assign ps2_kbdat    = (ps2_kbdat_ena)?      ps2_kbdat_out       : 1'bZ;

reg ps2_kbclk_ena;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                               ps2_kbclk_ena <= 1'b0;
    else if(keyb_timeout_reset)                                                     ps2_kbclk_ena <= 1'b0;
    else if(keyb_state == PS2_SEND_INHIBIT || keyb_state == PS2_WAIT_START)         ps2_kbclk_ena <= 1'b1;
    else if(keyb_state == PS2_SEND_CLOCK_RELEASE || keyb_state == PS2_WAIT_FINISH)  ps2_kbclk_ena <= 1'b0;
end

reg ps2_kbclk_out;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                           ps2_kbclk_out <= 1'b0;
    else if(keyb_state == PS2_SEND_INHIBIT || keyb_state == PS2_WAIT_START)     ps2_kbclk_out <= 1'b0;
end

reg ps2_kbdat_ena;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                           ps2_kbdat_ena <= 1'b0;
    else if(keyb_timeout_reset)                                 ps2_kbdat_ena <= 1'b0;
    else if(keyb_state == PS2_SEND_DATA_LOW)                    ps2_kbdat_ena <= 1'b1;
    else if(ps2_kb_write_shift && keyb_bit_counter == 4'd9)     ps2_kbdat_ena <= 1'b0;  //stop bit
end

reg ps2_kbdat_out;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                       ps2_kbdat_out <= 1'b0;
    else if(keyb_state == PS2_SEND_DATA_LOW)                ps2_kbdat_out <= 1'b0;              //start bit
    else if(ps2_kb_write_shift && keyb_bit_counter < 4'd8)  ps2_kbdat_out <= inputbuffer[0];    //data bits
    else if(ps2_kb_write_shift && keyb_bit_counter == 4'd8) ps2_kbdat_out <= ~(keyb_parity);    //parity bit
end

reg [15:0] keyb_clk_mv;
reg keyb_clk_mv_wait;
reg was_ps2_kbclk;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        keyb_clk_mv         <= 16'd0;
        keyb_clk_mv_wait    <= 1'b0;
        was_ps2_kbclk       <= 1'b0;
    end
    else begin
        keyb_clk_mv <= { keyb_clk_mv[14:0], keyb_kbclk };
    
        if(keyb_clk_mv_wait == 1'b0 && keyb_clk_mv[15:12] == 4'b1111 && keyb_clk_mv[3:0] == 4'b0000) begin
            was_ps2_kbclk <= 1'b1;
            keyb_clk_mv_wait <= 1'b1;
        end
        else if(keyb_clk_mv_wait == 1'b1 && keyb_clk_mv[15:0] == 16'h0000) begin
            keyb_clk_mv_wait <= 1'b0;
            was_ps2_kbclk <= 1'b0;
        end
        else begin
            was_ps2_kbclk <= 1'b0;
        end
    end
end

reg keyb_kbclk;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   keyb_kbclk <= 1'b1;
    else                keyb_kbclk <= ps2_kbclk;
end    

reg keyb_kbdat;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   keyb_kbdat <= 1'b1;
    else                keyb_kbdat <= ps2_kbdat;
end    

reg [25:0] keyb_timeout;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                       keyb_timeout <= 26'h0;
    else if(keyb_state == PS2_SEND_INHIBIT || keyb_state == PS2_RECV_START) keyb_timeout <= 26'h3FFFFFF;
    else if(keyb_state == PS2_IDLE)                                         keyb_timeout <= 26'h0;
    else if(keyb_timeout > 26'd0)                                           keyb_timeout <= keyb_timeout - 26'd1;
end

wire keyb_timeout_reset = keyb_timeout == 26'd1;

reg [12:0] keyb_timer;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                           keyb_timer <= 13'd0;
    else if(keyb_timeout_reset)                 keyb_timer <= 13'd0;                  
    
    else if(keyb_state == PS2_SEND_INHIBIT)     keyb_timer <= 13'd8191;
    else if(keyb_state == PS2_WAIT_START)       keyb_timer <= 13'd8191;
    
    else if(keyb_timer > 13'd0)                 keyb_timer <= keyb_timer - 13'd1;
end

reg [3:0] keyb_bit_counter;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               keyb_bit_counter <= 4'd0;
    else if(keyb_timeout_reset)                     keyb_bit_counter <= 4'd0;
    
    else if(keyb_state == PS2_SEND_CLOCK_RELEASE)   keyb_bit_counter <= 4'd0;
    else if(ps2_kb_write_shift)                     keyb_bit_counter <= keyb_bit_counter + 4'd1;
    
    else if(keyb_state == PS2_RECV_START)           keyb_bit_counter <= 4'd0;
    else if(keyb_recv)                              keyb_bit_counter <= keyb_bit_counter + 4'd1;
end

reg keyb_parity;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               keyb_parity <= 1'b0;
    
    else if(keyb_state == PS2_SEND_CLOCK_RELEASE)   keyb_parity <= 1'b0;
    else if(ps2_kb_write_shift)                     keyb_parity <= keyb_parity ^ inputbuffer[0];
    
    else if(keyb_state == PS2_RECV_START)           keyb_parity <= 1'b0;
    else if(keyb_recv)                              keyb_parity <= keyb_parity ^ keyb_kbdat;
end

reg [7:0] keyb_recv_buffer;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               keyb_recv_buffer <= 8'd0;
    else if(keyb_recv && keyb_bit_counter < 4'd8)   keyb_recv_buffer <= { keyb_kbdat, keyb_recv_buffer[7:1] };
end

wire keyb_recv              = keyb_state == PS2_RECV_BITS && was_ps2_kbclk;
wire keyb_recv_ok           = keyb_recv && keyb_bit_counter == 4'd8 && ~(keyb_parity) == keyb_kbdat;
wire keyb_recv_parity_err   = keyb_recv && keyb_bit_counter == 4'd8 && ~(keyb_parity) != keyb_kbdat;

reg keyb_recv_result;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                      keyb_recv_result <= 1'b0;
    else if(keyb_state == PS2_RECV_BITS)   keyb_recv_result <= keyb_recv_ok;
end
wire keyb_recv_final = keyb_state == PS2_RECV_WAIT_FOR_IDLE && keyb_kbclk == 1'b1 && keyb_kbdat == 1'b1 && keyb_recv_result;

reg keyb_translate_escape;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                       keyb_translate_escape <= 1'b0;
    else if(keyb_timeout_reset)                             keyb_translate_escape <= 1'b0;
    else if(keyb_recv_ok && keyb_translate_escape == 1'b0)  keyb_translate_escape <= translate && keyb_recv_buffer == 8'hF0;
    else if(keyb_recv_final && keyb_recv_buffer != 8'hF0)   keyb_translate_escape <= 1'b0;
end

reg [7:0] trans;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   trans <= 8'd0;
    else begin
        case(keyb_recv_buffer)
            8'h00: trans <= 8'hff; 8'h01: trans <= 8'h43; 8'h02: trans <= 8'h41; 8'h03: trans <= 8'h3f; 8'h04: trans <= 8'h3d; 8'h05: trans <= 8'h3b; 8'h06: trans <= 8'h3c; 8'h07: trans <= 8'h58;
            8'h08: trans <= 8'h64; 8'h09: trans <= 8'h44; 8'h0A: trans <= 8'h42; 8'h0B: trans <= 8'h40; 8'h0C: trans <= 8'h3e; 8'h0D: trans <= 8'h0f; 8'h0E: trans <= 8'h29; 8'h0F: trans <= 8'h59;
            8'h10: trans <= 8'h65; 8'h11: trans <= 8'h38; 8'h12: trans <= 8'h2a; 8'h13: trans <= 8'h70; 8'h14: trans <= 8'h1d; 8'h15: trans <= 8'h10; 8'h16: trans <= 8'h02; 8'h17: trans <= 8'h5a;
            8'h18: trans <= 8'h66; 8'h19: trans <= 8'h71; 8'h1A: trans <= 8'h2c; 8'h1B: trans <= 8'h1f; 8'h1C: trans <= 8'h1e; 8'h1D: trans <= 8'h11; 8'h1E: trans <= 8'h03; 8'h1F: trans <= 8'h5b;
            8'h20: trans <= 8'h67; 8'h21: trans <= 8'h2e; 8'h22: trans <= 8'h2d; 8'h23: trans <= 8'h20; 8'h24: trans <= 8'h12; 8'h25: trans <= 8'h05; 8'h26: trans <= 8'h04; 8'h27: trans <= 8'h5c;
            8'h28: trans <= 8'h68; 8'h29: trans <= 8'h39; 8'h2A: trans <= 8'h2f; 8'h2B: trans <= 8'h21; 8'h2C: trans <= 8'h14; 8'h2D: trans <= 8'h13; 8'h2E: trans <= 8'h06; 8'h2F: trans <= 8'h5d;
            8'h30: trans <= 8'h69; 8'h31: trans <= 8'h31; 8'h32: trans <= 8'h30; 8'h33: trans <= 8'h23; 8'h34: trans <= 8'h22; 8'h35: trans <= 8'h15; 8'h36: trans <= 8'h07; 8'h37: trans <= 8'h5e;
            8'h38: trans <= 8'h6a; 8'h39: trans <= 8'h72; 8'h3A: trans <= 8'h32; 8'h3B: trans <= 8'h24; 8'h3C: trans <= 8'h16; 8'h3D: trans <= 8'h08; 8'h3E: trans <= 8'h09; 8'h3F: trans <= 8'h5f;
            8'h40: trans <= 8'h6b; 8'h41: trans <= 8'h33; 8'h42: trans <= 8'h25; 8'h43: trans <= 8'h17; 8'h44: trans <= 8'h18; 8'h45: trans <= 8'h0b; 8'h46: trans <= 8'h0a; 8'h47: trans <= 8'h60;
            8'h48: trans <= 8'h6c; 8'h49: trans <= 8'h34; 8'h4A: trans <= 8'h35; 8'h4B: trans <= 8'h26; 8'h4C: trans <= 8'h27; 8'h4D: trans <= 8'h19; 8'h4E: trans <= 8'h0c; 8'h4F: trans <= 8'h61;
            8'h50: trans <= 8'h6d; 8'h51: trans <= 8'h73; 8'h52: trans <= 8'h28; 8'h53: trans <= 8'h74; 8'h54: trans <= 8'h1a; 8'h55: trans <= 8'h0d; 8'h56: trans <= 8'h62; 8'h57: trans <= 8'h6e;
            8'h58: trans <= 8'h3a; 8'h59: trans <= 8'h36; 8'h5A: trans <= 8'h1c; 8'h5B: trans <= 8'h1b; 8'h5C: trans <= 8'h75; 8'h5D: trans <= 8'h2b; 8'h5E: trans <= 8'h63; 8'h5F: trans <= 8'h76;
            8'h60: trans <= 8'h55; 8'h61: trans <= 8'h56; 8'h62: trans <= 8'h77; 8'h63: trans <= 8'h78; 8'h64: trans <= 8'h79; 8'h65: trans <= 8'h7a; 8'h66: trans <= 8'h0e; 8'h67: trans <= 8'h7b;
            8'h68: trans <= 8'h7c; 8'h69: trans <= 8'h4f; 8'h6A: trans <= 8'h7d; 8'h6B: trans <= 8'h4b; 8'h6C: trans <= 8'h47; 8'h6D: trans <= 8'h7e; 8'h6E: trans <= 8'h7f; 8'h6F: trans <= 8'h6f;
            8'h70: trans <= 8'h52; 8'h71: trans <= 8'h53; 8'h72: trans <= 8'h50; 8'h73: trans <= 8'h4c; 8'h74: trans <= 8'h4d; 8'h75: trans <= 8'h48; 8'h76: trans <= 8'h01; 8'h77: trans <= 8'h45;
            8'h78: trans <= 8'h57; 8'h79: trans <= 8'h4e; 8'h7A: trans <= 8'h51; 8'h7B: trans <= 8'h4a; 8'h7C: trans <= 8'h37; 8'h7D: trans <= 8'h49; 8'h7E: trans <= 8'h46; 8'h7F: trans <= 8'h54;
            8'h80: trans <= 8'h80; 8'h81: trans <= 8'h81; 8'h82: trans <= 8'h82; 8'h83: trans <= 8'h41; 8'h84: trans <= 8'h54; 8'h85: trans <= 8'h85; 8'h86: trans <= 8'h86; 8'h87: trans <= 8'h87;
            8'h88: trans <= 8'h88; 8'h89: trans <= 8'h89; 8'h8A: trans <= 8'h8a; 8'h8B: trans <= 8'h8b; 8'h8C: trans <= 8'h8c; 8'h8D: trans <= 8'h8d; 8'h8E: trans <= 8'h8e; 8'h8F: trans <= 8'h8f;
            default: trans <= keyb_recv_buffer;
        endcase
    end
end
  
localparam [3:0] PS2_IDLE                   = 4'd0;

localparam [3:0] PS2_SEND_INHIBIT           = 4'd1;
localparam [3:0] PS2_SEND_INHIBIT_WAIT      = 4'd2;
localparam [3:0] PS2_SEND_DATA_LOW          = 4'd3;
localparam [3:0] PS2_SEND_CLOCK_RELEASE     = 4'd4;
localparam [3:0] PS2_SEND_BITS              = 4'd5;
localparam [3:0] PS2_SEND_WAIT_FOR_ACK      = 4'd6;
localparam [3:0] PS2_SEND_WAIT_FOR_IDLE     = 4'd7;
localparam [3:0] PS2_SEND_FINISHED          = 4'd8;

localparam [3:0] PS2_RECV_START             = 4'd9;
localparam [3:0] PS2_RECV_BITS              = 4'd10;
localparam [3:0] PS2_RECV_WAIT_FOR_STOP     = 4'd11;
localparam [3:0] PS2_RECV_WAIT_FOR_IDLE     = 4'd12;

localparam [3:0] PS2_WAIT_START             = 4'd13;
localparam [3:0] PS2_WAIT                   = 4'd14;
localparam [3:0] PS2_WAIT_FINISH            = 4'd15;

reg [3:0] keyb_state;

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                                               keyb_state <= PS2_IDLE;
    else if(keyb_timeout_reset)                                                                                     keyb_state <= PS2_IDLE;
    
    //buffer full
    else if(keyb_state == PS2_IDLE && (keyb_fifo_counter >= 7'd60 || disable_keyboard))                                                                     keyb_state <= PS2_WAIT_START;
    else if(keyb_state == PS2_WAIT_START)                                                                                                                   keyb_state <= PS2_WAIT;
    else if(keyb_state == PS2_WAIT && keyb_timer == 13'd1 && status_inputbufferfull && ~(input_write_done) && ~(input_for_mouse) && ~(disable_keyboard))    keyb_state <= PS2_SEND_INHIBIT;
    else if(keyb_state == PS2_WAIT && keyb_timer == 13'd1 && (keyb_fifo_counter >= 7'd60 || disable_keyboard))                                              keyb_state <= PS2_WAIT_START;
    else if(keyb_state == PS2_WAIT && keyb_timer == 13'd1)                                                                                                  keyb_state <= PS2_WAIT_FINISH;
    else if(keyb_state == PS2_WAIT_FINISH)                                                                                                                  keyb_state <= PS2_IDLE;
    
    //send
    else if(keyb_state == PS2_IDLE && status_inputbufferfull && ~(input_write_done) && ~(input_for_mouse))  keyb_state <= PS2_SEND_INHIBIT;
    else if(keyb_state == PS2_SEND_INHIBIT)                                                                 keyb_state <= PS2_SEND_INHIBIT_WAIT;
    else if(keyb_state == PS2_SEND_INHIBIT_WAIT && keyb_timer == 13'd8)                                     keyb_state <= PS2_SEND_DATA_LOW;
    else if(keyb_state == PS2_SEND_DATA_LOW)                                                                keyb_state <= PS2_SEND_INHIBIT_WAIT;
    else if(keyb_state == PS2_SEND_INHIBIT_WAIT && keyb_timer == 13'd1)                                     keyb_state <= PS2_SEND_CLOCK_RELEASE;
    else if(keyb_state == PS2_SEND_CLOCK_RELEASE)                                                           keyb_state <= PS2_SEND_BITS;
    else if(keyb_state == PS2_SEND_BITS && ps2_kb_write_shift && keyb_bit_counter == 4'd9)                  keyb_state <= PS2_SEND_WAIT_FOR_ACK;
    else if(keyb_state == PS2_SEND_WAIT_FOR_ACK && was_ps2_kbclk && keyb_kbdat == 1'b0)                     keyb_state <= PS2_SEND_WAIT_FOR_IDLE;
    else if(keyb_state == PS2_SEND_WAIT_FOR_IDLE && keyb_kbclk == 1'b1 && keyb_kbdat == 1'b1)               keyb_state <= PS2_SEND_FINISHED;
    else if(keyb_state == PS2_SEND_FINISHED)                                                                keyb_state <= PS2_IDLE;
    
    //recv
    else if(keyb_state == PS2_IDLE && was_ps2_kbclk && keyb_kbdat == 1'b0)                          keyb_state <= PS2_RECV_START;
    else if(keyb_state == PS2_RECV_START)                                                           keyb_state <= PS2_RECV_BITS;
    else if(keyb_state == PS2_RECV_BITS && (keyb_recv_ok || keyb_recv_parity_err))                  keyb_state <= PS2_RECV_WAIT_FOR_STOP;
    else if(keyb_state == PS2_RECV_WAIT_FOR_STOP && was_ps2_kbclk && keyb_kbdat == 1'b1)            keyb_state <= PS2_RECV_WAIT_FOR_IDLE;
    else if(keyb_state == PS2_RECV_WAIT_FOR_IDLE && keyb_kbclk == 1'b1 && keyb_kbdat == 1'b1)       keyb_state <= PS2_IDLE;
end

wire [6:0]  keyb_fifo_counter = { keyb_fifo_full, keyb_fifo_usedw };
wire        keyb_fifo_full;
wire [5:0]  keyb_fifo_usedw;

wire [7:0]  keyb_fifo_q;
wire        keyb_fifo_empty;

wire [7:0] keyb_fifo_q_final = (keyb_fifo_empty)? keyb_fifo_q_last : keyb_fifo_q;

reg [7:0] keyb_fifo_q_last;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           keyb_fifo_q_last <= 8'd0;
    else if(~(keyb_fifo_empty)) keyb_fifo_q_last <= keyb_fifo_q;
end

wire ps2_kb_write_shift = keyb_state == PS2_SEND_BITS && was_ps2_kbclk;

wire ps2_kb_write_done = keyb_state == PS2_SEND_FINISHED;

wire ps2_kb_reply_done = keyb_reply_valid && keyb_fifo_counter < 7'd60 && ~(keyb_recv_final);

simple_fifo #(
    .width      (8),
    .widthu     (6)
)
keyb_fifo(
    .clk        (clk),
    .rst_n      (rst_n),
    
    .sclr       (cmd_self_test),                                                                                                //input
    
    .wrreq      (ps2_kb_reply_done || (keyb_recv_final && (~(translate) || keyb_recv_buffer != 8'hF0))),                        //input
    .data       ((ps2_kb_reply_done)? keyb_reply : (translate)? ({ keyb_translate_escape, 7'd0 } | trans) : keyb_recv_buffer),  //input [7:0]
    .full       (keyb_fifo_full),                                                                                               //output
    .usedw      (keyb_fifo_usedw),                                                                                              //output [5:0]
    
    .rdreq      (io_read_valid && io_address == 3'd0 && status_outputbufferfull && ~(status_mousebufferfull)),                  //input
    .q          (keyb_fifo_q),                                                                                                  //output [7:0]
    .empty      (keyb_fifo_empty)                                                                                               //output
);

//------------------------------------------------------------------------------ ps/2 for mouse

assign ps2_mouseclk    = (ps2_mouseclk_ena)?      ps2_mouseclk_out       : 1'bZ;
assign ps2_mousedat    = (ps2_mousedat_ena)?      ps2_mousedat_out       : 1'bZ;

reg ps2_mouseclk_ena;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                   ps2_mouseclk_ena <= 1'b0;
    else if(mouse_timeout_reset)                                                        ps2_mouseclk_ena <= 1'b0;
    else if(mouse_state == PS2_SEND_INHIBIT || mouse_state == PS2_WAIT_START)           ps2_mouseclk_ena <= 1'b1;
    else if(mouse_state == PS2_SEND_CLOCK_RELEASE || mouse_state == PS2_WAIT_FINISH)    ps2_mouseclk_ena <= 1'b0;
end

reg ps2_mouseclk_out;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                           ps2_mouseclk_out <= 1'b0;
    else if(mouse_state == PS2_SEND_INHIBIT || mouse_state == PS2_WAIT_START)   ps2_mouseclk_out <= 1'b0;
end

reg ps2_mousedat_ena;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                               ps2_mousedat_ena <= 1'b0;
    else if(mouse_timeout_reset)                                    ps2_mousedat_ena <= 1'b0;
    else if(mouse_state == PS2_SEND_DATA_LOW)                       ps2_mousedat_ena <= 1'b1;
    else if(ps2_mouse_write_shift && mouse_bit_counter == 4'd9)     ps2_mousedat_ena <= 1'b0;  //stop bit
end

reg ps2_mousedat_out;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                           ps2_mousedat_out <= 1'b0;
    else if(mouse_state == PS2_SEND_DATA_LOW)                   ps2_mousedat_out <= 1'b0;               //start bit
    else if(ps2_mouse_write_shift && mouse_bit_counter < 4'd8)  ps2_mousedat_out <= inputbuffer[0];     //data bits
    else if(ps2_mouse_write_shift && mouse_bit_counter == 4'd8) ps2_mousedat_out <= ~(mouse_parity);    //parity bit
end

reg [15:0] mouse_clk_mv;
reg mouse_clk_mv_wait;
reg was_ps2_mouseclk;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        mouse_clk_mv         <= 16'd0;
        mouse_clk_mv_wait    <= 1'b0;
        was_ps2_mouseclk       <= 1'b0;
    end
    else begin
        mouse_clk_mv <= { mouse_clk_mv[14:0], mouse_mouseclk };
    
        if(mouse_clk_mv_wait == 1'b0 && mouse_clk_mv[15:12] == 4'b1111 && mouse_clk_mv[3:0] == 4'b0000) begin
            was_ps2_mouseclk <= 1'b1;
            mouse_clk_mv_wait <= 1'b1;
        end
        else if(mouse_clk_mv_wait == 1'b1 && mouse_clk_mv[15:0] == 16'h0000) begin
            mouse_clk_mv_wait <= 1'b0;
            was_ps2_mouseclk <= 1'b0;
        end
        else begin
            was_ps2_mouseclk <= 1'b0;
        end
    end
end

reg mouse_mouseclk;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   mouse_mouseclk <= 1'b1;
    else                mouse_mouseclk <= ps2_mouseclk;
end    

reg mouse_mousedat;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   mouse_mousedat <= 1'b1;
    else                mouse_mousedat <= ps2_mousedat;
end

reg [25:0] mouse_timeout;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                           mouse_timeout <= 26'h0;
    else if(mouse_state == PS2_SEND_INHIBIT || mouse_state == PS2_RECV_START)   mouse_timeout <= 26'h3FFFFFF;
    else if(mouse_state == PS2_IDLE)                                            mouse_timeout <= 26'h0;
    else if(mouse_timeout > 26'd0)                                              mouse_timeout <= mouse_timeout - 26'd1;
end

wire mouse_timeout_reset = mouse_timeout == 26'd1;

reg [12:0] mouse_timer;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                           mouse_timer <= 13'd0;
    else if(mouse_timeout_reset)                mouse_timer <= 13'd0;
    else if(mouse_state == PS2_SEND_INHIBIT)    mouse_timer <= 13'd8191;
    else if(mouse_state == PS2_WAIT_START)      mouse_timer <= 13'd8191;
    
    else if(mouse_timer > 13'd0)                mouse_timer <= mouse_timer - 13'd1;
end

reg [3:0] mouse_bit_counter;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               mouse_bit_counter <= 4'd0;
    else if(mouse_timeout_reset)                    mouse_bit_counter <= 4'd0;
    
    else if(mouse_state == PS2_SEND_CLOCK_RELEASE)  mouse_bit_counter <= 4'd0;
    else if(ps2_mouse_write_shift)                  mouse_bit_counter <= mouse_bit_counter + 4'd1;
    
    else if(mouse_state == PS2_RECV_START)          mouse_bit_counter <= 4'd0;
    else if(mouse_recv)                             mouse_bit_counter <= mouse_bit_counter + 4'd1;
end

reg mouse_parity;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               mouse_parity <= 1'b0;
    
    else if(mouse_state == PS2_SEND_CLOCK_RELEASE)  mouse_parity <= 1'b0;
    else if(ps2_mouse_write_shift)                  mouse_parity <= mouse_parity ^ inputbuffer[0];
    
    else if(mouse_state == PS2_RECV_START)          mouse_parity <= 1'b0;
    else if(mouse_recv)                             mouse_parity <= mouse_parity ^ mouse_mousedat;
end

reg [7:0] mouse_recv_buffer;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               mouse_recv_buffer <= 8'd0;
    else if(mouse_recv && mouse_bit_counter < 4'd8) mouse_recv_buffer <= { mouse_mousedat, mouse_recv_buffer[7:1] };
end

wire mouse_recv              = mouse_state == PS2_RECV_BITS && was_ps2_mouseclk;
wire mouse_recv_ok           = mouse_recv && mouse_bit_counter == 4'd8 && ~(mouse_parity) == mouse_mousedat;
wire mouse_recv_parity_err   = mouse_recv && mouse_bit_counter == 4'd8 && ~(mouse_parity) != mouse_mousedat;

reg mouse_recv_result;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                       mouse_recv_result <= 1'b0;
    else if(mouse_state == PS2_RECV_BITS)   mouse_recv_result <= mouse_recv_ok;
end
wire mouse_recv_final = mouse_state == PS2_RECV_WAIT_FOR_IDLE && mouse_mouseclk == 1'b1 && mouse_mousedat == 1'b1 && mouse_recv_result;

reg [3:0] mouse_state;

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                                                       mouse_state <= PS2_IDLE;
    else if(mouse_timeout_reset)                                                                                            mouse_state <= PS2_IDLE;
    
    //buffer full
    else if(mouse_state == PS2_IDLE && (mouse_fifo_counter >= 7'd60 || disable_mouse))                                                                  mouse_state <= PS2_WAIT_START;
    else if(mouse_state == PS2_WAIT_START)                                                                                                              mouse_state <= PS2_WAIT;
    else if(mouse_state == PS2_WAIT && mouse_timer == 13'd1 && status_inputbufferfull && ~(input_write_done) && input_for_mouse && ~(disable_mouse))    mouse_state <= PS2_SEND_INHIBIT;
    else if(mouse_state == PS2_WAIT && mouse_timer == 13'd1 && (mouse_fifo_counter >= 7'd60 || disable_mouse))                                          mouse_state <= PS2_WAIT_START;
    else if(mouse_state == PS2_WAIT && mouse_timer == 13'd1)                                                                                            mouse_state <= PS2_WAIT_FINISH;
    else if(mouse_state == PS2_WAIT_FINISH)                                                                                                             mouse_state <= PS2_IDLE;
    
    //send
    else if(mouse_state == PS2_IDLE && status_inputbufferfull && ~(input_write_done) && input_for_mouse)    mouse_state <= PS2_SEND_INHIBIT;
    else if(mouse_state == PS2_SEND_INHIBIT)                                                                mouse_state <= PS2_SEND_INHIBIT_WAIT;
    else if(mouse_state == PS2_SEND_INHIBIT_WAIT && mouse_timer == 13'd8)                                   mouse_state <= PS2_SEND_DATA_LOW;
    else if(mouse_state == PS2_SEND_DATA_LOW)                                                               mouse_state <= PS2_SEND_INHIBIT_WAIT;
    else if(mouse_state == PS2_SEND_INHIBIT_WAIT && mouse_timer == 13'd1)                                   mouse_state <= PS2_SEND_CLOCK_RELEASE;
    else if(mouse_state == PS2_SEND_CLOCK_RELEASE)                                                          mouse_state <= PS2_SEND_BITS;
    else if(mouse_state == PS2_SEND_BITS && ps2_mouse_write_shift && mouse_bit_counter == 4'd9)             mouse_state <= PS2_SEND_WAIT_FOR_ACK;
    else if(mouse_state == PS2_SEND_WAIT_FOR_ACK && was_ps2_mouseclk && mouse_mousedat == 1'b0)             mouse_state <= PS2_SEND_WAIT_FOR_IDLE;
    else if(mouse_state == PS2_SEND_WAIT_FOR_IDLE && mouse_mouseclk == 1'b1 && mouse_mousedat == 1'b1)      mouse_state <= PS2_SEND_FINISHED;
    else if(mouse_state == PS2_SEND_FINISHED)                                                               mouse_state <= PS2_IDLE;
    
    //recv
    else if(mouse_state == PS2_IDLE && was_ps2_mouseclk && mouse_mousedat == 1'b0)                      mouse_state <= PS2_RECV_START;
    else if(mouse_state == PS2_RECV_START)                                                              mouse_state <= PS2_RECV_BITS;
    else if(mouse_state == PS2_RECV_BITS && (mouse_recv_ok || mouse_recv_parity_err))                   mouse_state <= PS2_RECV_WAIT_FOR_STOP;
    else if(mouse_state == PS2_RECV_WAIT_FOR_STOP && was_ps2_mouseclk && mouse_mousedat == 1'b1)        mouse_state <= PS2_RECV_WAIT_FOR_IDLE;
    else if(mouse_state == PS2_RECV_WAIT_FOR_IDLE && mouse_mouseclk == 1'b1 && mouse_mousedat == 1'b1)  mouse_state <= PS2_IDLE;
end

wire [6:0]  mouse_fifo_counter = { mouse_fifo_full, mouse_fifo_usedw };
wire        mouse_fifo_full;
wire [5:0]  mouse_fifo_usedw;

wire [7:0]  mouse_fifo_q;
wire        mouse_fifo_empty;

wire ps2_mouse_write_shift = mouse_state == PS2_SEND_BITS && was_ps2_mouseclk;

wire ps2_mouse_write_done = mouse_state == PS2_SEND_FINISHED;

wire ps2_mouse_reply_done = mouse_reply_valid && mouse_fifo_counter < 7'd60 && ~(mouse_recv_final);

simple_fifo #(
    .width      (8),
    .widthu     (6)
)
mouse_fifo(
    .clk        (clk),
    .rst_n      (rst_n),
    
    .sclr       (cmd_self_test),                                                //input
    
    .wrreq      (ps2_mouse_reply_done || mouse_recv_final),                     //input
    .data       ((ps2_mouse_reply_done)? mouse_reply : mouse_recv_buffer),      //input [7:0]
    .full       (mouse_fifo_full),                                              //output
    .usedw      (mouse_fifo_usedw),                                             //output [5:0]
    
    .rdreq      (io_read_valid && io_address == 3'd0 && status_mousebufferfull),//input
    .q          (mouse_fifo_q),                                                 //output [7:0]
    .empty      (mouse_fifo_empty)                                              //output
);

//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0, sysctl_read, sysctl_writedata[7:2], 1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------

endmodule
