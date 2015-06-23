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
 * \brief DM9000A 10/100 Mbit Ethernet driver for a VGA frame grabber 
 */

/*! \brief \copybrief drv_eth_vga_capture.v
*/
module drv_eth_vga_capture(
    //% \name Clock and reset
    //% @{
    input           clk_30,
    input           clk_25,
    input           reset_n,
    //% @}
    
    //% \name Captured VGA output signals
    //% @{
    input           display_valid,
    input [9:0]     vga_r,
    input [9:0]     vga_g,
    input [9:0]     vga_b,
    //% @}
    
    //% \name DM9000A Ethernet hardware interface
    //% @{
    output          enet_clk_25,
    output          enet_reset_n,
    output          enet_cs_n,
    input           enet_irq,
    
    output reg      enet_ior_n,
    output reg      enet_iow_n,
    output reg      enet_cmd,
    inout [15:0]    enet_data
    //% @}
);
assign enet_clk_25  = clk_25;
assign enet_reset_n = reset_n;
assign enet_cs_n    = 1'b0;

reg tx_active;

reg enet_data_oe;
reg [15:0] enet_data_out;
assign enet_data = (enet_data_oe == 1'b1)? enet_data_out : 16'bZ;

//************ packet Ethernet and IP/UDP header contents ROM
reg [5:0] ram_addr;
wire [15:0] ram_q;

altsyncram ethernet_ram_inst(
    .clock0(clk_30),
    .address_a(ram_addr),
    .q_a(ram_q)
);
defparam
    ethernet_ram_inst.operation_mode = "ROM",
    ethernet_ram_inst.width_a = 16,
    ethernet_ram_inst.widthad_a = 6,
    ethernet_ram_inst.init_file = "drv_eth_vga_capture.mif";

//************ vga burst fifo
reg [8:0] vga_line_number;
reg last_display_valid;
reg [1:0] select_line;
reg block_wrreq;
always @(posedge clk_30 or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        vga_line_number <= 9'd0;
        last_display_valid <= 1'b0;
        select_line <= 2'd0;
        block_wrreq <= 1'b0;
    end
    else begin
        last_display_valid <= display_valid;
        
        if(fifo_empty == 1'b0 && last_display_valid == 1'b0 && display_valid == 1'b1)   block_wrreq <= 1'b1;
        else if(display_valid == 1'b0)                                                  block_wrreq <= 1'b0;
        
        if(display_valid == 1'b0 && last_display_valid == 1'b1) begin
            if(vga_line_number == 9'd479)   vga_line_number <= 9'd0;
            else                            vga_line_number <= vga_line_number + 9'd1;
        end
        
        if(display_valid == 1'b0 && last_display_valid == 1'b1 && vga_line_number == 9'd479) select_line <= select_line + 2'd1;
    end
end

wire fifo_wrreq = (fifo_empty == 1'b1 || last_display_valid == 1'b1) && block_wrreq == 1'b0 && display_valid == 1'b1 && select_line == vga_line_number[1:0];
wire start_load = fifo_empty == 1'b0;

wire fifo_empty;
wire [11:0] fifo_q;

scfifo vga_fifo_inst(
    .clock(clk_30),
    .data( { vga_r[9:6], vga_g[9:6], vga_b[9:6] } ),
    .wrreq(fifo_wrreq),
    .rdreq(fifo_rdreq),
    
    .empty(fifo_empty),
    .q(fifo_q)
);
defparam
    vga_fifo_inst.lpm_width = 12,
    vga_fifo_inst.lpm_numwords = 1024;

reg fifo_rdreq;
reg [1:0] fifo_rd_cnt;
reg [11:0] last_fifo_q;

//************

reg [15:0] state_counter;
always @(posedge clk_30 or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        state_counter   <= 16'd0;
        tx_active       <= 1'b0;
        
        enet_iow_n      <= 1'b1;
        enet_ior_n      <= 1'b1;
        enet_cmd        <= 1'b0;        // low: INDEX, high: DATA
        enet_data_oe    <= 1'b0;
        enet_data_out   <= 16'd0;
        
        ram_addr        <= 6'd0;
        
        fifo_rdreq      <= 1'b0;
        fifo_rd_cnt     <= 2'd0;
        last_fifo_q     <= 12'd0;
    end
    else if(state_counter == 16'd50000) begin
        enet_iow_n <= 1'b0;
        enet_cmd <= 1'b0;
        enet_data_oe <= 1'b1;
        enet_data_out <= { 8'd0, 8'hFF }; // set IMR(FFh = 0x80)
        
        state_counter <= state_counter + 16'd1;
    end
    else if(state_counter == 16'd50002) begin
        enet_iow_n <= 1'b0;
        enet_cmd <= 1'b1;
        enet_data_out <= { 8'd0, 8'h80 }; 
        
        state_counter <= state_counter + 16'd1;
    end
    else if(state_counter == 16'd50005) begin
        enet_iow_n <= 1'b0;
        enet_cmd <= 1'b0;
        enet_data_out <= { 8'd0, 8'h1F }; // power-up PHY (1Fh = 0x00)
        
        state_counter <= state_counter + 16'd1;
    end
    else if(state_counter == 16'd50007) begin
        enet_iow_n <= 1'b0;
        enet_cmd <= 1'b1;
        enet_data_out <= { 8'd0, 8'h00 }; 
        
        state_counter <= state_counter + 16'd1;
    end
    
    else if(state_counter == 16'd50010) begin
        enet_iow_n <= 1'b0;
        enet_cmd <= 1'b0;
        enet_data_out <= { 8'd0, 8'h31 }; // set checksum reg (31h = 0x05)
        
        state_counter <= state_counter + 16'd1;
    end
    else if(state_counter == 16'd50012) begin
        enet_iow_n <= 1'b0;
        enet_cmd <= 1'b1;
        enet_data_out <= { 8'd0, 8'h05 }; 
        
        state_counter <= state_counter + 16'd1;
    end
    
    
    else if(state_counter == 16'd50018) begin
        enet_iow_n <= 1'b0;
        enet_cmd <= 1'b0;
        enet_data_out <= { 8'd0, 8'hF8 }; // set MWCMD(F8h = 16-bit data) 
        
        ram_addr <= 6'd0;
        state_counter <= state_counter + 16'd1;
    end
    else if(state_counter >= 16'd50020 && state_counter <= 16'd50060 && state_counter[0] == 1'b0) begin
        enet_iow_n <= 1'b0;
        enet_cmd <= 1'b1;
        enet_data_out <= ram_q;
        
        ram_addr <= ram_addr + 6'd1;
        state_counter <= state_counter + 16'd1;
    end
    else if(state_counter == 16'd50062) begin
        if(start_load == 1'b1) begin
            enet_iow_n <= 1'b0;
            enet_cmd <= 1'b1;
            enet_data_out <= { 7'd0, vga_line_number };
            
            fifo_rdreq <= 1'b1;
            fifo_rd_cnt <= 2'd0;
            state_counter <= state_counter + 16'd1;
        end
    end
    else if(state_counter == 16'd50063) begin
        enet_iow_n <= 1'b1;
        fifo_rdreq <= 1'b1;
        last_fifo_q <= fifo_q;
        state_counter <= state_counter + 16'd1;
    end
    
    
    else if(state_counter >= 16'd50064 && state_counter <= 16'd51022 && state_counter[0] == 1'b0) begin
        enet_iow_n <= 1'b0;
        enet_cmd <= 1'b1;
        
        if(fifo_rd_cnt == 2'd0)     enet_data_out <= { fifo_q[3:0], last_fifo_q }; 
        else if(fifo_rd_cnt == 2'd1)enet_data_out <= { fifo_q[7:0], last_fifo_q[11:4] };
        else                        enet_data_out <= { fifo_q, last_fifo_q[11:8] };
        
        if(fifo_rd_cnt == 2'd2) fifo_rdreq <= 1'b1;
        else                    fifo_rdreq <= 1'b0;
        
        fifo_rd_cnt <= fifo_rd_cnt + 2'd1;
        last_fifo_q <= fifo_q;
        
        if(state_counter == 16'd51022)  state_counter <= 16'd60016 - 16'd1;
        else                            state_counter <= state_counter + 16'd1;
    end
    else if(state_counter >= 16'd50064 && state_counter <= 16'd51022 && state_counter[0] == 1'b1 && fifo_rd_cnt == 2'd3) begin
        enet_iow_n <= 1'b1;
        fifo_rdreq <= 1'b1;
        last_fifo_q <= fifo_q;
        fifo_rd_cnt <= 2'd0;
        state_counter <= state_counter + 16'd1;
    end
    else if(state_counter >= 16'd50064 && state_counter <= 16'd51022 && state_counter[0] == 1'b1) begin
        enet_iow_n <= 1'b1;
        fifo_rdreq <= 1'b1;
        state_counter <= state_counter + 16'd1;
    end
    
    
    else if(state_counter == 16'd60016) begin
        enet_iow_n <= 1'b0;
        enet_cmd <= 1'b0;
        enet_data_oe <= 1'b1;
        enet_data_out <= { 8'd0, 8'h02 }; // read TX(02h bit 0 == 0)
        
        state_counter <= state_counter + 16'd1;
    end
    else if(state_counter == 16'd60018) begin
        enet_ior_n <= 1'b0;
        enet_cmd <= 1'b1;
        enet_data_oe <= 1'b0;
        
        state_counter <= state_counter + 16'd1;
    end
    else if(state_counter == 16'd60020) begin
        enet_ior_n <= 1'b1;
        tx_active <= enet_data[0];
        
        state_counter <= state_counter + 16'd1;
    end
    else if(state_counter == 16'd60022) begin
        if(tx_active == 1'b0)   state_counter <= 16'd60118;
        else                    state_counter <= 16'd60016;
    end
    
    else if(state_counter == 16'd60118) begin
        enet_iow_n <= 1'b0;
        enet_cmd <= 1'b0;
        enet_data_oe <= 1'b1;
        enet_data_out <= { 8'd0, 8'hFC }; // set TXPLL(FCh = low byte)
        
        state_counter <= state_counter + 16'd1;
    end
    else if(state_counter == 16'd60120) begin
        enet_iow_n <= 1'b0;
        enet_cmd <= 1'b1;
        enet_data_out <= { 8'h00, 8'hEC }; 
        
        state_counter <= state_counter + 16'd1;
    end
    
    else if(state_counter == 16'd60123) begin
        enet_iow_n <= 1'b0;
        enet_cmd <= 1'b0;
        enet_data_out <= { 8'd0, 8'hFD }; // set TXPLH(FDh = high byte)
        
        state_counter <= state_counter + 16'd1;
    end
    else if(state_counter == 16'd60125) begin
        enet_iow_n <= 1'b0;
        enet_cmd <= 1'b1;
        enet_data_out <= { 8'h00, 8'h03 }; 
        
        state_counter <= state_counter + 16'd1;
    end
    
    else if(state_counter == 16'd60128) begin
        enet_iow_n <= 1'b0;
        enet_cmd <= 1'b0;
        enet_data_out <= { 8'd0, 8'h02 }; // write TX(02h = 0x01)
        
        state_counter <= state_counter + 16'd1;
    end
    else if(state_counter == 16'd60130) begin
        enet_iow_n <= 1'b0;
        enet_cmd <= 1'b1;
        enet_data_out <= { 8'h00, 8'h01 }; 
        
        state_counter <= state_counter + 16'd1;
    end
    
    else if(state_counter == 16'd60132) begin
         state_counter <= 16'd50018;
    end
    
    else if(state_counter <= 16'd60132) begin
        enet_iow_n <= 1'b1;
        enet_ior_n <= 1'b1;
        fifo_rdreq <= 1'b0;
        state_counter <= state_counter + 16'd1;
    end
    
end

endmodule
