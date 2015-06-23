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

module pc_bus(
    input               clk,
    input               rst_n,
    
    //control slave
    input        [1:0]  ctrl_address,
    input               ctrl_write,
    input       [31:0]  ctrl_writedata,
    
    //memory slave
    input       [29:0]  mem_address,
    input       [3:0]   mem_byteenable,
    input               mem_read,
    output      [31:0]  mem_readdata,
    input               mem_write,
    input       [31:0]  mem_writedata,
    output              mem_waitrequest,
    output              mem_readdatavalid,
    input       [2:0]   mem_burstcount,
    
    //memory master
    output      [31:0]  sdram_address,
    output      [3:0]   sdram_byteenable,
    output              sdram_read,
    input       [31:0]  sdram_readdata,
    output              sdram_write,
    output      [31:0]  sdram_writedata,
    input               sdram_waitrequest,
    input               sdram_readdatavalid,
    output      [2:0]   sdram_burstcount,
    
    //vga master
    output      [31:0]  vga_address,
    output      [3:0]   vga_byteenable,
    output              vga_read,
    input       [31:0]  vga_readdata,
    output              vga_write,
    output      [31:0]  vga_writedata,
    input               vga_waitrequest,
    input               vga_readdatavalid,
    output      [2:0]   vga_burstcount
);

//------------------------------------------------------------------------------ ctrl

reg [127:0] data_at_0xffffffff;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                           data_at_0xffffffff <= 128'h0000000000000000000000F000FFF0EA;
    else if(ctrl_write && ctrl_address == 2'd0) data_at_0xffffffff <= { data_at_0xffffffff[127:32], ctrl_writedata };
    else if(ctrl_write && ctrl_address == 2'd1) data_at_0xffffffff <= { data_at_0xffffffff[127:64], ctrl_writedata, data_at_0xffffffff[31:0] };
    else if(ctrl_write && ctrl_address == 2'd2) data_at_0xffffffff <= { data_at_0xffffffff[127:96], ctrl_writedata, data_at_0xffffffff[63:0] };
    else if(ctrl_write && ctrl_address == 2'd3) data_at_0xffffffff <= {                             ctrl_writedata, data_at_0xffffffff[95:0] };
end

//------------------------------------------------------------------------------ transaction

wire select_vga        = ~(slow_start) && ~(slow_in_progress) && ~(transaction_in_progress) && (mem_read || mem_write) && ({ mem_address, 2'b00 } >= 32'h000A0000 && { mem_address, 2'b00 } < 32'h000C0000);
wire select_sdram      = ~(slow_start) && ~(slow_in_progress) && ~(transaction_in_progress) && (mem_read || mem_write) && ~(select_vga);

wire transaction_start = ~(slow_start) && ~(slow_in_progress) && ~(transaction_in_progress) && (mem_read || (mem_write && mem_burstcount > 3'd1));

reg transaction_is_read;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           transaction_is_read <= 1'b0;
    else if(transaction_start)  transaction_is_read <= mem_read;
end

reg transaction_select_vga;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           transaction_select_vga <= 1'b0;
    else if(transaction_start)  transaction_select_vga <= select_vga;
end

reg transaction_was_read_accepted;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                               transaction_was_read_accepted <= 1'b1;
    else if(transaction_start && mem_read && mem_waitrequest)                       transaction_was_read_accepted <= 1'b0;
    else if(transaction_start && mem_read)                                          transaction_was_read_accepted <= 1'b1;
    else if(transaction_in_progress && transaction_is_read && ~(mem_waitrequest))   transaction_was_read_accepted <= 1'b1;
end

reg [2:0] transaction_burstcount;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                                               transaction_burstcount <= 3'd0;
    else if(transaction_start && mem_write && ~(mem_waitrequest))                                                   transaction_burstcount <= mem_burstcount - 3'd1;
    else if(transaction_start && (mem_read || mem_write))                                                           transaction_burstcount <= mem_burstcount;
    else if(transaction_in_progress && mem_write         && transaction_burstcount > 3'd0 && ~(mem_waitrequest))    transaction_burstcount <= transaction_burstcount - 3'd1;
    else if(transaction_in_progress && mem_readdatavalid && transaction_burstcount > 3'd0)                          transaction_burstcount <= transaction_burstcount - 3'd1;
end

reg [3:0] transaction_byteenable;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                       transaction_byteenable <= 4'd0;
    else if(transaction_start && mem_read)  transaction_byteenable <= mem_byteenable;
end

reg transaction_in_progress;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                                               transaction_in_progress <= 1'b0;
    else if(transaction_start)                                                                                      transaction_in_progress <= 1'b1;
    else if(transaction_in_progress && mem_write         && transaction_burstcount <= 3'd1 && ~(mem_waitrequest))   transaction_in_progress <= 1'b0;
    else if(transaction_in_progress && mem_readdatavalid && transaction_burstcount <= 3'd1)                         transaction_in_progress <= 1'b0;
end

//------------------------------------------------------------------------------ slow

wire slow_start = ~(slow_in_progress) && ~(transaction_in_progress) && (mem_read || mem_write) && (
    { mem_address, 2'b00 } == 32'h0009FFF4 ||
    { mem_address, 2'b00 } == 32'h0009FFF8 ||
    { mem_address, 2'b00 } == 32'h0009FFFC ||
    
    { mem_address, 2'b00 } == 32'h000BFFF4 ||
    { mem_address, 2'b00 } == 32'h000BFFF8 ||
    { mem_address, 2'b00 } == 32'h000BFFFC ||
    
    { mem_address, 2'b00 } == 32'hFFFFFFE4 ||
    { mem_address, 2'b00 } == 32'hFFFFFFE8 ||
    { mem_address, 2'b00 } == 32'hFFFFFFEC ||
    { mem_address, 2'b00 } == 32'hFFFFFFF0 ||
    { mem_address, 2'b00 } == 32'hFFFFFFF4 ||
    { mem_address, 2'b00 } == 32'hFFFFFFF8 ||
    { mem_address, 2'b00 } == 32'hFFFFFFFC
);

reg slow_in_progress;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                                       slow_in_progress <= 1'b0;
    else if(slow_start)                                                                                     slow_in_progress <= 1'b1;
    
    else if(slow_write_active && slow_is_vga   && vga_waitrequest == 1'b0   && slow_burstcount <= 3'd1)     slow_in_progress <= 1'b0;
    else if(slow_write_active && slow_is_sdram && sdram_waitrequest == 1'b0 && slow_burstcount <= 3'd1)     slow_in_progress <= 1'b0;
    else if(slow_write_active && slow_is_0xff  &&                              slow_burstcount <= 3'd1)     slow_in_progress <= 1'b0;
    
    else if(slow_read_active && slow_is_vga   && vga_readdatavalid   && slow_burstcount <= 3'd1)            slow_in_progress <= 1'b0;
    else if(slow_read_active && slow_is_sdram && sdram_readdatavalid && slow_burstcount <= 3'd1)            slow_in_progress <= 1'b0;
    else if(slow_read_active && slow_is_0xff  &&                        slow_burstcount <= 3'd1)            slow_in_progress <= 1'b0;
end

reg [31:0] slow_address;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                           slow_address <= 32'b0;
    else if(slow_start)                                                         slow_address <= { mem_address, 2'b0 };
    
    else if(slow_write_active && slow_is_vga   && vga_waitrequest   == 1'b0)    slow_address <= slow_address + 32'd4;
    else if(slow_write_active && slow_is_sdram && sdram_waitrequest == 1'b0)    slow_address <= slow_address + 32'd4;
    else if(slow_write_active && slow_is_0xff)                                  slow_address <= slow_address + 32'd4;
    
    else if(slow_read_active && slow_is_vga   && vga_readdatavalid)             slow_address <= slow_address + 32'd4;
    else if(slow_read_active && slow_is_sdram && sdram_readdatavalid)           slow_address <= slow_address + 32'd4;
    else if(slow_read_active && slow_is_0xff)                                   slow_address <= slow_address + 32'd4;
end

wire slow_is_vga   = { slow_address[31:2], 2'b0 } >= 32'h000A0000 && { slow_address[31:2], 2'b00 } < 32'h000C0000;
wire slow_is_0xff  = { slow_address[31:2], 2'b0 } >= 32'hFFFFFFF0;
wire slow_is_sdram = ~(slow_is_vga) && ~(slow_is_0xff);

reg slow_write_active;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                                       slow_write_active <= 1'b0;
    else if(slow_start && mem_write)                                                                        slow_write_active <= 1'b1;
    
    else if(slow_write_active && slow_is_vga   && vga_waitrequest == 1'b0   && slow_burstcount <= 3'd1)     slow_write_active <= 1'b0;
    else if(slow_write_active && slow_is_sdram && sdram_waitrequest == 1'b0 && slow_burstcount <= 3'd1)     slow_write_active <= 1'b0;
    else if(slow_write_active && slow_is_0xff  &&                              slow_burstcount <= 3'd1)     slow_write_active <= 1'b0;
end

reg slow_was_read_accepted;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   slow_was_read_accepted <= 1'b0;
    else if(slow_start && mem_read)                     slow_was_read_accepted <= 1'b0; //mem_waitrequest always 1'b1
    else if(slow_read_active && ~(mem_waitrequest))     slow_was_read_accepted <= 1'b1;
end

reg slow_read_active;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                               slow_read_active <= 1'b0;
    else if(slow_start && mem_read)                                                                 slow_read_active <= 1'b1;
    
    else if(slow_read_active && slow_is_vga   && vga_readdatavalid   && slow_burstcount <= 3'd1)    slow_read_active <= 1'b0;
    else if(slow_read_active && slow_is_sdram && sdram_readdatavalid && slow_burstcount <= 3'd1)    slow_read_active <= 1'b0;
    else if(slow_read_active && slow_is_0xff  &&                        slow_burstcount <= 3'd1)    slow_read_active <= 1'b0;
end

reg [2:0] slow_read_cnt;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                                   slow_read_cnt <= 3'd0;
    else if(slow_start && mem_read)                                                                     slow_read_cnt <= (mem_burstcount == 3'd0)? 3'd1 : mem_burstcount;
    
    else if(slow_read_active && slow_is_vga   && vga_waitrequest == 1'b0   && slow_read_cnt > 3'd0)     slow_read_cnt <= slow_read_cnt - 3'd1;
    else if(slow_read_active && slow_is_sdram && sdram_waitrequest == 1'b0 && slow_read_cnt > 3'd0)     slow_read_cnt <= slow_read_cnt - 3'd1;
    else if(slow_read_active && slow_is_0xff  &&                              slow_read_cnt > 3'd0)     slow_read_cnt <= slow_read_cnt - 3'd1;
end

reg [3:0] slow_byteenable;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   slow_byteenable <= 4'd0;
    else if(slow_start && mem_read)     slow_byteenable <= mem_byteenable;
end

reg [2:0] slow_burstcount;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                                       slow_burstcount <= 3'd0;
    else if(slow_start)                                                                                     slow_burstcount <= mem_burstcount;
    
    else if(slow_write_active && slow_is_vga   && vga_waitrequest == 1'b0   && slow_burstcount > 3'd0)      slow_burstcount <= slow_burstcount - 3'd1;
    else if(slow_write_active && slow_is_sdram && sdram_waitrequest == 1'b0 && slow_burstcount > 3'd0)      slow_burstcount <= slow_burstcount - 3'd1;
    else if(slow_write_active && slow_is_0xff  &&                              slow_burstcount > 3'd0)      slow_burstcount <= slow_burstcount - 3'd1;
    
    else if(slow_read_active && slow_is_vga   && vga_readdatavalid   && slow_burstcount > 3'd0)             slow_burstcount <= slow_burstcount - 3'd1;
    else if(slow_read_active && slow_is_sdram && sdram_readdatavalid && slow_burstcount > 3'd0)             slow_burstcount <= slow_burstcount - 3'd1;
    else if(slow_read_active && slow_is_0xff  &&                        slow_burstcount > 3'd0)             slow_burstcount <= slow_burstcount - 3'd1;
end

//------------------------------------------------------------------------------ sdram

assign sdram_address =
    (slow_in_progress && slow_address[31:27] == 5'd0)?  { 4'd0, 1'b1, slow_address[26:0] } :
    (slow_in_progress)?                                 32'hFFFFFFFC :
    (mem_address[29:25] == 5'd0)?                       { 4'd0, 1'b1, mem_address[24:0], 2'b0 } :
                                                        32'hFFFFFFFC;

assign sdram_byteenable =
    (slow_in_progress && slow_read_active)?             slow_byteenable :
    (transaction_in_progress && transaction_is_read)?   transaction_byteenable :
                                                        mem_byteenable;

assign sdram_read =
    (slow_in_progress)?                                                         slow_read_cnt > 3'd0 && slow_is_sdram :
    (select_sdram || (transaction_in_progress && ~(transaction_select_vga)))?   mem_read && ~(transaction_in_progress && ~(transaction_is_read)) :
                                                                                1'b0;

assign sdram_write =
    (slow_in_progress)?                                                         slow_write_active && slow_is_sdram :
    (select_sdram || (transaction_in_progress && ~(transaction_select_vga)))?   mem_write && ~(transaction_in_progress && transaction_is_read) :
                                                                                1'b0;

assign sdram_writedata = mem_writedata;

assign sdram_burstcount =
    (slow_in_progress)?     3'd1 :
                            mem_burstcount;

//------------------------------------------------------------------------------ vga

assign vga_address =
    (slow_in_progress)?     slow_address :
                            { mem_address, 2'b0 };

assign vga_byteenable =
    (slow_in_progress && slow_read_active)?             slow_byteenable :
    (transaction_in_progress && transaction_is_read)?   transaction_byteenable :
                                                        mem_byteenable;

assign vga_read =
    (slow_in_progress)?                                                     slow_read_cnt > 3'd0 && slow_is_vga :
    (select_vga || (transaction_in_progress && transaction_select_vga))?    mem_read && ~(transaction_in_progress && ~(transaction_is_read)) :
                                                                            1'b0;

assign vga_write =
    (slow_in_progress)?                                                     slow_write_active && slow_is_vga :
    (select_vga || (transaction_in_progress && transaction_select_vga))?    mem_write && ~(transaction_in_progress && transaction_is_read) :
                                                                            1'b0;

assign vga_writedata = mem_writedata;

assign vga_burstcount =
    (slow_in_progress)?     3'd1 :
                            mem_burstcount;

//------------------------------------------------------------------------------ mem

assign mem_readdata =
    (slow_in_progress && slow_is_vga)?                                          vga_readdata :
    (slow_in_progress && slow_is_0xff && slow_address[3:2] == 2'h0)?            data_at_0xffffffff[31:0] :
    (slow_in_progress && slow_is_0xff && slow_address[3:2] == 2'h1)?            data_at_0xffffffff[63:32] :
    (slow_in_progress && slow_is_0xff && slow_address[3:2] == 2'h2)?            data_at_0xffffffff[95:64] :
    (slow_in_progress && slow_is_0xff && slow_address[3:2] == 2'h3)?            data_at_0xffffffff[127:96] :
    (slow_in_progress)?                                                         sdram_readdata :
    (select_vga || (transaction_in_progress && transaction_select_vga))?        vga_readdata :
                                                                                sdram_readdata;

assign mem_readdatavalid= 
    (slow_in_progress && slow_is_vga)?                                          vga_readdatavalid :
    (slow_in_progress && slow_is_0xff)?                                         1'b1 :
    (slow_in_progress)?                                                         sdram_readdatavalid :
    (select_vga || (transaction_in_progress && transaction_select_vga))?        vga_readdatavalid :
                                                                                sdram_readdatavalid;

assign mem_waitrequest =
    (slow_in_progress && (slow_write_active || (slow_read_active && ~(slow_was_read_accepted))) && slow_is_vga)?            vga_waitrequest :
    (slow_in_progress && (slow_write_active || (slow_read_active && ~(slow_was_read_accepted))) && slow_is_sdram)?          sdram_waitrequest :
    (slow_in_progress && slow_read_active && slow_was_read_accepted)?                                                       1'b1 :
    (transaction_in_progress && (~(transaction_is_read) || ~(transaction_was_read_accepted)) && transaction_select_vga)?    vga_waitrequest :
    (transaction_in_progress && (~(transaction_is_read) || ~(transaction_was_read_accepted)))?                              sdram_waitrequest :
    (transaction_in_progress && transaction_is_read && transaction_was_read_accepted)?                                      1'b1 :
        (select_vga && vga_waitrequest) || (select_sdram && sdram_waitrequest) || slow_start;

endmodule
