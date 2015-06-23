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
 * \brief IS61LPS51236A pipelined SSRAM driver with WISHBONE slave interface.
 */

/*! \brief \copybrief bus_ssram.v
*/
module bus_ssram(
	//% \name Clock and reset
    //% @{
	input               clk_30,
	input               reset_n,
	//% @}
	
	//% \name WISHBONE slave
    //% @{
	input [20:2]        ADR_I,
	input               CYC_I,
	input               WE_I,
	input [3:0]         SEL_I,
	input               STB_I,
	input [31:0]        DAT_I,
	output reg [31:0]   DAT_O,
	output reg          ACK_O,
	//% @}

	//% \name Direct drv_ssram read/write burst DMA for ocs_video and drv_vga 
    //% @{
    // drv_vga read burst
    input               burst_read_vga_request,
    input [31:2]        burst_read_vga_address,
    output              burst_read_vga_ready,
    // ocs_video bitplain read burst
	input               burst_read_video_request,
	input [31:2]        burst_read_video_address,
	output              burst_read_video_ready,
	// common read burst data signal
	output reg [35:0]   burst_read_data,
	//% @}
	
	// ocs_video video output write burst
	input               burst_write_request,
	input [31:2]        burst_write_address,
	output reg          burst_write_ready,
	input [35:0]        burst_write_data,
	//% @}
	
	//% \name IS61LPS51236A pipelined SSRAM hardware interface
    //% @{
	output reg [18:0]   ssram_address,
	output reg          ssram_oe_n,
	output reg          ssram_writeen_n,
	output reg [3:0]    ssram_byteen_n,
	output              ssram_adsp_n,
	output              ssram_clk,
	output              ssram_globalw_n,
	output reg          ssram_advance_n,
	output reg          ssram_adsc_n,
	output              ssram_ce1_n,
	output              ssram_ce2,
	output              ssram_ce3_n,
	inout [35:0]        ssram_data
	//% @}
);

assign ssram_clk = clk_30;
assign ssram_globalw_n = 1'b1;
assign ssram_adsp_n = 1'b1;
assign ssram_ce1_n = 1'b0;
assign ssram_ce2 = 1'b1;
assign ssram_ce3_n = 1'b0;

reg ssram_data_oe;
reg [35:0] ssram_data_reg;
assign ssram_data = (ssram_data_oe == 1'b1) ? ssram_data_reg : 36'bZ;

reg [18:0] burst_address;

reg burst_read_select;
reg burst_read_ready;

assign burst_read_vga_ready = (burst_read_select == 1'b0)? burst_read_ready : 1'b0;
assign burst_read_video_ready = (burst_read_select == 1'b0)? 1'b0 : burst_read_ready;

reg [3:2] burst_read_low_address;
reg burst_read_one_loop;
wire burst_read_request;
assign burst_read_request = (burst_read_select == 1'b0)? burst_read_vga_request : burst_read_video_request;

reg [3:0] state;
parameter [3:0]
	S_IDLE      = 4'd0,
	S_VW0       = 4'd1,
	S_VW1       = 4'd2,
	S_VW2       = 4'd3,
	S_VW3       = 4'd4,
	S_VW4       = 4'd5,
	S_VR1       = 4'd6,
	S_VR2       = 4'd7,
	S_VR3       = 4'd8,
	S_VR4       = 4'd9,
	S_R1        = 4'd10,
	S_R2        = 4'd11,
	S_R3        = 4'd12,
	S_PRE_IDLE  = 4'd13;

always @(posedge clk_30 or negedge reset_n) begin
	if(reset_n == 1'b0) begin
		ssram_address <= 19'd0;
		ssram_adsc_n <= 1'b1;
		ssram_advance_n <= 1'b1;
		ssram_data_reg <= 36'd0;
		ssram_data_oe <= 1'b0;
		ssram_oe_n <= 1'b1;
		ssram_writeen_n <= 1'b1;
		ssram_byteen_n <= 4'b1111;
		
		burst_address <= 19'd0;
		
		burst_read_data <= 36'd0;
        burst_read_ready <= 1'b0;
        burst_read_select <= 1'b0;
		burst_read_low_address <= 2'd0;
		burst_read_one_loop <= 1'b0;
		
		burst_write_ready <= 1'b0;
		
		ACK_O <= 1'b0;
		DAT_O <= 32'd0;
		
		state <= S_IDLE;
	end
	else if(state == S_IDLE) begin
        ACK_O <= 1'b0;
        
        if(burst_read_vga_request == 1'b1 || burst_read_video_request == 1'b1) begin
            // address and byte enables output
            if(burst_read_vga_request == 1'b1)          ssram_address <= { burst_read_vga_address[20:4], 2'b0 };
            else if(burst_read_video_request == 1'b1)   ssram_address <= { burst_read_video_address[20:4], 2'b0 };
            ssram_adsc_n <= 1'b0;
            ssram_advance_n <= 1'b1;
            ssram_data_reg <= 32'd0;
            ssram_data_oe <= 1'b0;
            ssram_oe_n <= 1'b1;
            ssram_writeen_n <= 1'b1;
            ssram_byteen_n <= 4'b0000;
            
            if(burst_read_vga_request == 1'b1) begin
                burst_address <= { burst_read_vga_address[20:4], 2'b0 } + 19'd4;
                burst_read_low_address <= burst_read_vga_address[3:2];
                burst_read_select <= 1'b0;
            end
            else if(burst_read_video_request == 1'b1) begin
                burst_address <= { burst_read_video_address[20:4], 2'b0 } + 19'd4;
                burst_read_low_address <= burst_read_video_address[3:2];
                burst_read_select <= 1'b1;
            end
            burst_read_one_loop <= 1'b0;
            state <= S_VR1;
        end
        else if(burst_write_request == 1'b1) begin
            burst_write_ready <= 1'b1;
            burst_address <= burst_write_address[20:2];
            state <= S_VW0;
        end
        else if(ACK_O == 1'b0 && CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b0) begin
            // address and byte enables output
            ssram_address <= ADR_I[20:2];
            ssram_adsc_n <= 1'b0;
            ssram_advance_n <= 1'b1;
            ssram_data_reg <= 32'd0;
            ssram_data_oe <= 1'b0;
            ssram_oe_n <= 1'b1;
            ssram_writeen_n <= 1'b1;
            ssram_byteen_n <= 4'b0000;
        
            state <= S_R1;
        end
        else if(ACK_O == 1'b0 && CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b1) begin
            // address, byte enables and write enables output
            ssram_address <= ADR_I[20:2];
            ssram_adsc_n <= 1'b0;
            ssram_advance_n <= 1'b1;
            ssram_data_reg <= { 4'b0, DAT_I };
            ssram_data_oe <= 1'b1;
            ssram_oe_n <= 1'b1;
            ssram_writeen_n <= 1'b0;
            ssram_byteen_n <= ~SEL_I;
            
            ACK_O <= 1'b1;
            state <= S_PRE_IDLE;
        end
    end
    else if(state == S_VW0) begin
		state <= S_VW1;
	end
	else if(state == S_VW1) begin
        if(burst_write_request == 1'b0) begin
            burst_write_ready <= 1'b0;
            ssram_adsc_n <= 1'b1;
            ssram_advance_n <= 1'b1;
            ssram_data_oe <= 1'b0;
            ssram_writeen_n <= 1'b1;
            state <= S_PRE_IDLE;
        end
        else begin
            // address, byte enables and write enables output
            ssram_address <= burst_address;
            ssram_adsc_n <= 1'b0;
            ssram_advance_n <= 1'b1;
            ssram_data_reg <= burst_write_data;
            ssram_data_oe <= 1'b1;
            ssram_oe_n <= 1'b1;
            ssram_writeen_n <= 1'b0;
            ssram_byteen_n <= 4'b0000;
        
            burst_address <= burst_address + 19'd4;
            state <= S_VW2;
        end
    end
    else if(state == S_VW2) begin
        if(burst_write_request == 1'b0) begin
            burst_write_ready <= 1'b0;
            ssram_adsc_n <= 1'b1;
            ssram_advance_n <= 1'b1;
            ssram_data_oe <= 1'b0;
            ssram_writeen_n <= 1'b1;
            state <= S_PRE_IDLE;
        end
        else begin
            ssram_adsc_n <= 1'b1;
            ssram_advance_n <= 1'b0;
            ssram_data_reg <= burst_write_data;
        
            state <= S_VW3;
        end
    end
    else if(state == S_VW3) begin
        if(burst_write_request == 1'b0) begin
            burst_write_ready <= 1'b0;
            ssram_adsc_n <= 1'b1;
            ssram_advance_n <= 1'b1;
            ssram_data_oe <= 1'b0;
            ssram_writeen_n <= 1'b1;
            state <= S_PRE_IDLE;
        end
        else begin
            ssram_data_reg <= burst_write_data;
            
            state <= S_VW4;
        end
    end
    else if(state == S_VW4) begin
        if(burst_write_request == 1'b0) begin
            burst_write_ready <= 1'b0;
            ssram_adsc_n <= 1'b1;
            ssram_advance_n <= 1'b1;
            ssram_data_oe <= 1'b0;
            ssram_writeen_n <= 1'b1;
            state <= S_PRE_IDLE;
        end
        else begin
            ssram_data_reg <= burst_write_data;
        
            state <= S_VW1;
        end
    end
    else if(state == S_VR1) begin
        if(burst_read_request == 1'b0) begin
            burst_read_ready <= 1'b0;
            ssram_adsc_n <= 1'b1;
            ssram_advance_n <= 1'b1;
            state <= S_PRE_IDLE;
        end
        else begin
            if(burst_read_low_address[3:2] == 2'b10 && burst_read_one_loop == 1'b1) burst_read_ready <= 1'b1;
            
            // address and byte enables latched
            ssram_adsc_n <= 1'b1;
            ssram_advance_n <= 1'b0;
        
            burst_read_data <= ssram_data;
            state <= S_VR2;
        end
    end
    else if(state == S_VR2) begin
        if(burst_read_request == 1'b0) begin
            burst_read_ready <= 1'b0;
            ssram_adsc_n <= 1'b1;
            ssram_advance_n <= 1'b1;
            state <= S_PRE_IDLE;
        end
        else begin
            if(burst_read_low_address[3:2] == 2'b11 && burst_read_one_loop == 1'b1) burst_read_ready <= 1'b1;
            
            // output enable output
            ssram_oe_n <= 1'b0;
        
            burst_read_data <= ssram_data;
            state <= S_VR3;
        end
    end
    else if(state == S_VR3) begin
        if(burst_read_request == 1'b0) begin
            burst_read_ready <= 1'b0;
            ssram_adsc_n <= 1'b1;
            ssram_advance_n <= 1'b1;
            state <= S_PRE_IDLE;
        end
        else begin
            if(burst_read_low_address[3:2] == 2'b00) burst_read_ready <= 1'b1;
            
            burst_read_data <= ssram_data;
            state <= S_VR4;
        end
    end
    else if(state == S_VR4) begin
        if(burst_read_request == 1'b0) begin
            burst_read_ready <= 1'b0;
            ssram_adsc_n <= 1'b1;
            ssram_advance_n <= 1'b1;
            state <= S_PRE_IDLE;
        end
        else begin
            if(burst_read_low_address[3:2] == 2'b01) burst_read_ready <= 1'b1;
            burst_read_one_loop <= 1'b1;
            
            ssram_address <= burst_address;
            ssram_adsc_n <= 1'b0;
            ssram_advance_n <= 1'b1;
        
            burst_read_data <= ssram_data;
            burst_address <= burst_address + 19'd4;
            state <= S_VR1;
        end
    end
    else if(state == S_R1) begin
        // address and byte enables latched
        ssram_adsc_n <= 1'b1;
        ssram_advance_n <= 1'b1;
        
        state <= S_R2;
    end
    else if(state == S_R2) begin
        // output enable output
        ssram_oe_n <= 1'b0;
        
        state <= S_R3;
    end
    else if(state == S_R3) begin
        DAT_O <= ssram_data[31:0];
        ACK_O <= 1'b1;
        
        ssram_address <= 19'd0;
        ssram_adsc_n <= 1'b1;
        ssram_advance_n <= 1'b1;
        ssram_data_reg <= 36'd0;
        ssram_data_oe <= 1'b0;
        ssram_oe_n <= 1'b1;
        ssram_writeen_n <= 1'b1;
        ssram_byteen_n <= 4'b1111;
        
        state <= S_IDLE;
    end
    else if(state == S_PRE_IDLE) begin
        ACK_O <= 1'b0;
        
        ssram_address <= 19'd0;
        ssram_adsc_n <= 1'b1;
        ssram_advance_n <= 1'b1;
        ssram_data_reg <= 36'd0;
        ssram_data_oe <= 1'b0;
        ssram_oe_n <= 1'b1;
        ssram_writeen_n <= 1'b1;
        ssram_byteen_n <= 4'b1111;
        
        state <= S_IDLE;
    end
end

endmodule
