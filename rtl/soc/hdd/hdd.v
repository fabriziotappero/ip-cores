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

module hdd(
    input               clk,
    input               rst_n,
    
    //irq
    output reg          irq,
    
    //avalon slave
    input               io_address,
    input       [3:0]   io_byteenable,
    input               io_read,
    output reg  [31:0]  io_readdata,
    input               io_write,
    input       [31:0]  io_writedata, 
    
    //ide shared port 0x3F6
    input               ide_3f6_read,
    output reg  [7:0]   ide_3f6_readdata,
    input               ide_3f6_write,
    input       [7:0]   ide_3f6_writedata,
    
    //master to control sd
    output      [31:0]  sd_master_address,
    input               sd_master_waitrequest,
    output              sd_master_read,
    input               sd_master_readdatavalid,
    input       [31:0]  sd_master_readdata,
    output              sd_master_write,
    output      [31:0]  sd_master_writedata,
    
    //slave with data from/to sd
    input       [8:0]   sd_slave_address,
    input               sd_slave_read,
    output reg  [31:0]  sd_slave_readdata,
    input               sd_slave_write,
    input       [31:0]  sd_slave_writedata,
    
    //management slave
    /*
    0x00.[31:0]:    identify write
    0x01.[16:0]:    media cylinders
    0x02.[4:0]:     media heads
    0x03.[8:0]:     media spt
    0x04.[13:0]:    media sectors per cylinder = spt * heads
    0x05.[31:0]:    media sectors total
    0x06.[31:0]:    media sd base
    */
    input       [2:0]   mgmt_address,
    input               mgmt_write,
    input       [31:0]  mgmt_writedata
);

//------------------------------------------------------------------------------

`define SD_AVALON_BASE_ADDRESS_FOR_HDD 32'h00000000

//------------------------------------------------------------------------------

reg io_read_last;
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) io_read_last <= 1'b0; else if(io_read_last) io_read_last <= 1'b0; else io_read_last <= io_read; end 
wire io_read_valid = io_read && io_read_last == 1'b0;

reg sd_slave_read_last;
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) sd_slave_read_last <= 1'b0; else if(sd_slave_read_last) sd_slave_read_last <= 1'b0; else sd_slave_read_last <= sd_slave_read; end 
wire sd_slave_read_valid = sd_slave_read && sd_slave_read_last == 1'b0;

//------------------------------------------------------------------------------

wire write_data_io =
    io_write && io_address == 1'b0 && io_byteenable[0] &&
    cmd_write_in_progress;

wire read_data_io =
    io_read_valid && io_address == 1'b0 && io_byteenable[0] && status_drq &&
    (cmd_read_in_progress || cmd_identify_in_progress);

wire [2:0] data_io_size =
    (io_byteenable[3:0] == 4'b1111)?    3'd4 :
    (io_byteenable[1:0] == 2'b11)?      3'd2 :
    (io_byteenable[0])?                 3'd1 :
                                        3'd0;

wire [7:0] status_value =
    (drive_select)?     8'h00 :
                        { status_busy,
                          status_drive_ready,
                          1'b0, //status write fault
                          1'b1, //status seek complete
                          status_drq,
                          1'b0, //status data corrected
                          status_index_pulse_counter == 4'd0 && status_index_pulse_first,
                          status_err
                        };

wire [15:0] cylinder_final = (drive_select)? 16'hFFFF : cylinder;

wire [31:0] io_readdata_next =
    (read_data_io)?                                                             from_hdd_result[31:0] :
    (io_read_valid && io_address == 1'b0 && io_byteenable[1:0] == 2'b10)?       { 16'd0, error_register, 8'd0 } :
    (io_read_valid && io_address == 1'b0 && io_byteenable[2:0] == 3'b100)?      { 8'd0,  sector_count,   16'd0 } :
    (io_read_valid && io_address == 1'b0 && io_byteenable[3:0] == 4'b1000)?     { sector, 24'd0 } :
    (io_read_valid && io_address == 1'b1 && io_byteenable[0] == 1'b1)?          { 24'd0, cylinder_final[7:0] } :
    (io_read_valid && io_address == 1'b1 && io_byteenable[1:0] == 2'b10)?       { 16'd0, cylinder_final[15:8], 8'd0 } :
    (io_read_valid && io_address == 1'b1 && io_byteenable[2:0] == 3'b100)?      { 8'd0, 8'h80 | ((lba_mode)? 8'h40 : 8'h00) | 8'h20 | ((drive_select)? 8'h10 : 8'h00) | ((drive_select)? 8'h00 : { 4'd0, head }), 16'd0 } :
    (io_read_valid && io_address == 1'b1 && io_byteenable[3:0] == 4'b1000)?     { status_value, 24'd0 } :
                                                                                32'd0; //used

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   io_readdata <= 32'b0;
    else                io_readdata <= io_readdata_next;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   ide_3f6_readdata <= 8'b0;
    else                ide_3f6_readdata <= status_value;
end

//------------------------------------------------------------------------------ media management

reg [16:0] media_cylinders;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                           media_cylinders <= 17'd0;
    else if(mgmt_address == 3'd1 && mgmt_write) media_cylinders <= mgmt_writedata[16:0];
end

reg [4:0] media_heads;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                           media_heads <= 5'd0;
    else if(mgmt_address == 3'd2 && mgmt_write) media_heads <= mgmt_writedata[4:0];
end

reg [8:0] media_spt;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                           media_spt <= 9'd0;
    else if(mgmt_address == 3'd3 && mgmt_write) media_spt <= mgmt_writedata[8:0];
end

reg [13:0] media_spc; //sectors per cylinder = spt * heads
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                           media_spc <= 14'd0; //14'd1008;
    else if(mgmt_address == 3'd4 && mgmt_write) media_spc <= mgmt_writedata[13:0];
end

reg [31:0] media_sectors;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                           media_sectors <= 32'd0; //32'd1032192;
    else if(mgmt_address == 3'd5 && mgmt_write) media_sectors <= mgmt_writedata;
end

reg [31:0] media_sd_base;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                           media_sd_base <= 32'd0;
    else if(mgmt_address == 3'd6 && mgmt_write) media_sd_base <= mgmt_writedata;
end

//------------------------------------------------------------------------------

reg status_drq;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                   status_drq <= 1'b0;
    else if(sw_reset_start)                                             status_drq <= 1'b0;
    else if(cmd_read_start || cmd_identify_start || cmd_seek_start)     status_drq <= 1'b0;
    else if(cmd_execute_drive_diag)                                     status_drq <= 1'b0;
    else if(cmd_initialize_start)                                       status_drq <= 1'b0;
    else if(cmd_verify_start)                                           status_drq <= 1'b0;
    else if(command_requires_drq)                                       status_drq <= 1'b1;
    else if(command_finished)                                           status_drq <= 1'b0;
    else if(drq_zero)                                                   status_drq <= 1'b0;
    else if(command_abort)                                              status_drq <= 1'b0;
end

reg status_busy;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                   status_busy <= 1'b0;
    else if(sw_reset_start)                                             status_busy <= 1'b1;
    else if(sw_reset_end)                                               status_busy <= 1'b0;
    else if(cmd_read_start || cmd_identify_start || cmd_seek_start)     status_busy <= 1'b1;
    else if(cmd_initialize_start)                                       status_busy <= 1'b0;
    else if(cmd_verify_start)                                           status_busy <= 1'b0;
    else if(command_requires_drq)                                       status_busy <= 1'b0;
    else if(command_finished)                                           status_busy <= 1'b0;
    else if(drq_zero)                                                   status_busy <= 1'b1;
    else if(command_abort)                                              status_busy <= 1'b0;
end

reg status_drive_ready;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               status_drive_ready <= 1'b1;
    else if(sw_reset_start)         status_drive_ready <= 1'b0;
    else if(sw_reset_end)           status_drive_ready <= 1'b1;
    else if(cmd_initialize_start)   status_drive_ready <= 1'b1;
    else if(cmd_features_start)     status_drive_ready <= 1'b1;
    else if(cmd_verify_start)       status_drive_ready <= 1'b1;
    else if(cmd_max_start)          status_drive_ready <= 1'b1;
    else if(command_requires_drq)   status_drive_ready <= 1'b1;
    else if(command_finished)       status_drive_ready <= 1'b1;
    else if(command_abort)          status_drive_ready <= 1'b1;
end

reg status_err;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               status_err <= 1'b0;
    else if(sw_reset_start)         status_err <= 1'b0;
    else if(command_requires_drq)   status_err <= 1'b0;
    else if(command_abort)          status_err <= 1'b1;
    else if(command_finished)       status_err <= 1'b0;
    else if(cmd_start)              status_err <= 1'b0;
end

reg [7:0] error_register;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                   error_register <= 8'h01;
    else if(sw_reset_start)                                             error_register <= 8'h01;
    else if(cmd_execute_drive_diag)                                     error_register <= 8'h01;
    else if(cmd_read_start || cmd_identify_start || cmd_seek_start)     error_register <= 8'h00;
    else if(command_requires_drq)                                       error_register <= 8'h00;
    else if(command_finished)                                           error_register <= 8'h00;
    else if(command_abort)                                              error_register <= 8'h04;
end

wire [3:0] status_index_pulse_counter_next = (status_index_pulse_counter == 4'd9)? 4'd0 : status_index_pulse_counter + 4'd1;

reg status_index_pulse_first;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                           status_index_pulse_first <= 1'b0;
    else if(status_index_pulse_counter != 4'd0) status_index_pulse_first <= 1'b1;
end

reg [3:0] status_index_pulse_counter;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                                                       status_index_pulse_counter <= 4'd0;
    else if(~(drive_select) && (ide_3f6_read || (io_read_valid && io_address == 1'b1 && io_byteenable[3:0] == 4'b1000)))    status_index_pulse_counter <= status_index_pulse_counter_next;
end

reg [7:0] features;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                       features <= 8'h00;
    else if(io_write && io_address == 1'b0 && io_byteenable[1:0] == 2'b10)  features <= io_writedata[15:8];
end

reg [16:0] num_sectors;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   num_sectors <= 17'd0;
    else if(lba48_transform_active)     num_sectors <= (sector_count == 8'd0 && hob_nsector == 8'd0)? 17'd65536 : { 1'b0, hob_nsector, sector_count };
    else if(lba48_transform_inactive)   num_sectors <= (sector_count == 8'd0)? 17'd256 : { 9'd0, sector_count };
    else if(update_location_by_one)     num_sectors <= num_sectors - 17'd1;
end

reg [7:0] sector_count;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                           sector_count <= 8'd1;
    else if(set_signature)                                                      sector_count <= 8'd1;
    else if(cmd_checkpower_start)                                               sector_count <= 8'hFF;
    else if(io_write && io_address == 1'b0 && io_byteenable[2:0] == 3'b100)     sector_count <= io_writedata[23:16];
    else if(update_location_by_one)                                             sector_count <= sector_count - 8'd1;
end

reg [7:0] hob_nsector;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                       hob_nsector <= 8'd0;
    else if(io_write && io_address == 1'b0 && io_byteenable[2:0] == 3'b100) hob_nsector <= sector_count;
end

reg drive_select;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                       drive_select <= 1'b0;
    else if(set_signature)                                                  drive_select <= 1'b0;
    else if(io_write && io_address == 1'b1 && io_byteenable[2:0] == 3'b100) drive_select <= io_writedata[20];
end

reg disable_irq;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       disable_irq <= 1'b0;
    else if(sw_reset_start) disable_irq <= 1'b0;
    else if(ide_3f6_write)  disable_irq <= ide_3f6_writedata[1];
end

wire sw_reset_start = ide_3f6_write && ide_3f6_writedata[2];
wire sw_reset_end   = ide_3f6_write && ~(ide_3f6_writedata[2]) && reset_in_progress;

reg reset_in_progress;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       reset_in_progress <= 1'b0;
    else if(ide_3f6_write)  reset_in_progress <= ide_3f6_writedata[2];
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                           irq <= 1'b0;
    else if(sw_reset_start)                     irq <= 1'b0;
    else if(raise_interrupt && ~(disable_irq))  irq <= 1'b1; //raise more important than lower
    else if(lower_interrupt)                    irq <= 1'b0;
end

reg [7:0] current_command;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                   current_command <= 8'b0;
    else if(sw_reset_start)                                                             current_command <= 8'b0;
    else if(cmd_read_start || cmd_write_start || cmd_identify_start || cmd_seek_start)  current_command <= io_writedata[31:24];
    else if(state == S_IDLE)                                                            current_command <= 8'd0;
end

reg lba_mode;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                       lba_mode <= 1'b0;
    else if(sw_reset_start)                                                 lba_mode <= 1'b0;
    else if(io_write && io_address == 1'b1 && io_byteenable[2:0] == 3'b100) lba_mode <= io_writedata[22];
end

reg [4:0] multiple_sectors;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           multiple_sectors <= 5'd0;
    else if(sw_reset_start)     multiple_sectors <= 5'd0;
    else if(cmd_multiple_start) multiple_sectors <= sector_count[4:0];
end

//------------------------------------------------------------------------------

wire [16:0] media_cylinders_minus_1 = media_cylinders - 17'd1;

reg [15:0] cylinder;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                           cylinder <= 16'd0;
    else if(set_signature)                                                                      cylinder <= 16'd0;
    else if(io_write && io_address == 1'b1 && io_byteenable[0] == 1'b1)                         cylinder <= { cylinder[15:8], io_writedata[7:0] };
    else if(io_write && io_address == 1'b1 && io_byteenable[1:0] == 2'b10)                      cylinder <= { io_writedata[15:8], cylinder[7:0] };
    else if(update_location_to_overflow)                                                        cylinder <= media_sectors[23:8];
    else if(update_location_by_one && lba_mode && current_command_lba48)                        cylinder <= location_lba48_plus_1[23:8];
    else if(update_location_by_one && lba_mode)                                                 cylinder <= location_lba28_plus_1[23:8];
    
    else if(update_location_to_max && lba_mode && current_command_lba48)                        cylinder <= location_lba48_max[23:8];
    else if(update_location_to_max && lba_mode)                                                 cylinder <= location_lba28_max[23:8];
    
    else if(update_location_chs_cylinder_only && { 1'b0, cylinder } < media_cylinders - 17'd1)  cylinder <= cylinder + 16'd1;
    else if(update_location_chs_cylinder_only)                                                  cylinder <= media_cylinders_minus_1[15:0];
    else if(cmd_calibrate_start)                                                                cylinder <= 16'd0;
end

reg [3:0] head;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   head <= 4'd0;
    else if(set_signature)                                                      head <= 4'd0;
    else if(io_write && io_address == 1'b1 && io_byteenable[2:0] == 3'b100)     head <= io_writedata[19:16];
    else if(update_location_to_overflow && ~(current_command_read_lba48))       head <= media_sectors[27:24];
    else if(update_location_by_one && lba_mode && ~(current_command_lba48))     head <= location_lba28_plus_1[27:24];
    else if(update_location_to_max && lba_mode && ~(current_command_lba48))     head <= location_lba28_max[27:24];
    else if(update_location_chs_head_only)                                      head <= head + 4'd1;
    else if(update_location_chs_cylinder_only)                                  head <= 4'd0;
end

reg [7:0] sector;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                           sector <= 8'd1;
    else if(set_signature)                                                      sector <= 8'd1;
    else if(io_write && io_address == 1'b0 && io_byteenable[3:0] == 4'b1000)    sector <= io_writedata[31:24];
    else if(update_location_to_overflow)                                        sector <= media_sectors[7:0];
    else if(update_location_by_one && lba_mode && current_command_lba48)        sector <= location_lba48_plus_1[7:0];
    else if(update_location_by_one && lba_mode)                                 sector <= location_lba28_plus_1[7:0];
    else if(update_location_to_max && lba_mode && current_command_lba48)        sector <= location_lba48_max[7:0];
    else if(update_location_to_max && lba_mode)                                 sector <= location_lba28_max[7:0];
    else if(update_location_chs_sector_only)                                    sector <= sector + 8'd1;
    else if(update_location_chs_head_only || update_location_chs_cylinder_only) sector <= 8'd1;
end

reg [7:0] hob_hcyl;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   hob_hcyl <= 8'd0;
    else if(io_write && io_address == 1'b1 && io_byteenable[1:0] == 2'b10)      hob_hcyl <= cylinder[15:8];
    else if(update_location_to_overflow && current_command_read_lba48)          hob_hcyl <= 8'd0;
    else if(update_location_by_one && lba_mode && current_command_lba48)        hob_hcyl <= location_lba48_plus_1[47:40];
    else if(update_location_to_max && lba_mode && current_command_lba48)        hob_hcyl <= location_lba48_max[47:40];
end

reg [7:0] hob_lcyl;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   hob_lcyl <= 8'd0;
    else if(io_write && io_address == 1'b1 && io_byteenable[0] == 1'b1)         hob_lcyl <= cylinder[7:0];
    else if(update_location_to_overflow && current_command_read_lba48)          hob_lcyl <= 8'd0;
    else if(update_location_by_one && lba_mode && current_command_lba48)        hob_lcyl <= location_lba48_plus_1[39:32];
    else if(update_location_to_max && lba_mode && current_command_lba48)        hob_lcyl <= location_lba48_max[39:32];
end

reg [7:0] hob_sector;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   hob_sector <= 8'd0;
    else if(io_write && io_address == 1'b0 && io_byteenable[3:0] == 4'b1000)    hob_sector <= sector;
    else if(update_location_to_overflow && current_command_read_lba48)          hob_sector <= media_sectors[31:24];
    else if(update_location_by_one && lba_mode && current_command_lba48)        hob_sector <= location_lba48_plus_1[31:24];
    else if(update_location_to_max && lba_mode && current_command_lba48)        hob_sector <= location_lba48_max[31:24];
end

wire [27:0] location_lba28_plus_1 = { head, cylinder, sector } + 28'd1;
wire [47:0] location_lba48_plus_1 = { hob_hcyl, hob_lcyl, hob_sector, cylinder, sector } + 48'd1;

wire [27:0] location_lba28_max = (media_sectors[31:28] != 4'd0)? 28'hFFFFFFF : media_sectors[27:0] - 28'd1; 
wire [47:0] location_lba48_max = { 16'd0, media_sectors - 32'd1 };

//------------------------------------------------------------------------------ update location

wire update_location_to_overflow =
    state == S_COUNT_DECISION && logical_sector[47:32] == 16'd0 && logical_sector[31:0] < media_sectors &&
    current_command_read_multiple && lba_mode && (current_command_read_lba48 || media_sectors[31:28] == 4'd0) &&
    (logical_sector[31:0] + { 27'd0, multiple_final_read }) > media_sectors;

wire update_location_to_max = cmd_max_start;

wire update_location_by_one =
    (state == S_SD_READ_WAIT_FOR_DATA && sd_slave_write && sd_counter == 7'd127) ||
    (state == S_SD_WRITE_WAIT_FOR_DATA && sd_slave_read_valid && sd_counter == 7'd127); 

wire update_location_chs_sector_only = update_location_by_one && ~(lba_mode) &&
    { 1'b0, sector } < media_spt;
    
wire update_location_chs_head_only = update_location_by_one && ~(lba_mode) &&
    { 1'b0, sector } == media_spt && { 1'b0, head } < media_heads - 5'd1;
    
wire update_location_chs_cylinder_only = update_location_by_one && ~(lba_mode) &&
    { 1'b0, sector } == media_spt && { 1'b0, head } == media_heads - 5'd1;

//------------------------------------------------------------------------------ current command

wire current_command_lba48 = current_command_read_lba48 || current_command_write_lba48 ||
    (cmd_max_start && io_writedata[31:24] == 8'h27);

wire cmd_read_in_progress          = current_command == 8'h24 || current_command == 8'h29 || current_command == 8'h20 || current_command == 8'h21 || current_command == 8'hC4;
wire current_command_read_multiple = current_command == 8'hC4 || current_command == 8'h29;
wire current_command_read_lba48    = current_command == 8'h24 || current_command == 8'h29;

wire cmd_identify_in_progress = current_command == 8'hEC || current_command == 8'hA1;

wire cmd_write_in_progress          = current_command == 8'h30 || current_command == 8'hC5 || current_command == 8'h34 || current_command == 8'h39;
wire current_command_write_multiple = current_command == 8'hC5 || current_command == 8'h39;
wire current_command_write_lba48    = current_command == 8'h34 || current_command == 8'h39;
    
//------------------------------------------------------------------------------ command

wire cmd_start =
    io_write && io_address == 1'b1 && io_byteenable[3:0] == 4'b1000 && ~(drive_select) && ~(status_busy);
    
//calibrate
wire cmd_calibrate_start = cmd_start && io_writedata[31:24] >= 8'h10 && io_writedata[31:24] <= 8'h1F;

//read
wire cmd_read_prepare = cmd_start && (io_writedata[31:24] == 8'h24 || io_writedata[31:24] == 8'h29 || io_writedata[31:24] == 8'h20 || io_writedata[31:24] == 8'h21 || io_writedata[31:24] == 8'hC4);

wire cmd_read_abort_at_start = cmd_read_prepare && (
    (~(lba_mode) && head == 4'd0 && cylinder == 16'd0 && sector == 8'd0) ||
    ((io_writedata[31:24] == 8'hC4 || io_writedata[31:24] == 8'h29) && multiple_sectors == 5'd0)
);

wire cmd_read_start = cmd_read_prepare && ~(cmd_read_abort_at_start);

//write
wire cmd_write_prepare = cmd_start && (io_writedata[31:24] == 8'h30 || io_writedata[31:24] == 8'hC5 || io_writedata[31:24] == 8'h34 || io_writedata[31:24] == 8'h39);

wire cmd_write_abort_at_start = cmd_write_prepare && (
    ((io_writedata[31:24] == 8'hC5 || io_writedata[31:24] == 8'h39) && multiple_sectors == 5'd0)
);

wire cmd_write_start = cmd_write_prepare && ~(cmd_write_abort_at_start);

wire write_data_ready =
    (current_command_write_multiple    && to_hdd_count >= { multiple_final_read, 7'd0 }) ||
    (~(current_command_write_multiple) && to_hdd_count >= 12'd128);

//diag
wire cmd_execute_drive_diag = cmd_start && io_writedata[31:24] == 8'h90;

//initialize
wire cmd_initialize_prepare = cmd_start && io_writedata[31:24] == 8'h91;

wire cmd_initialize_abort_at_start = cmd_initialize_prepare && (
    ({ 1'b0, sector_count } != media_spt) ||
    (head != 4'd0 && { 1'b0, head } != media_heads - 5'd1)
);

wire cmd_initialize_start = cmd_initialize_prepare && ~(cmd_initialize_abort_at_start);

//identify
wire cmd_identify_start = cmd_start && io_writedata[31:24] == 8'hEC;

//set features
wire cmd_features_prepare = cmd_start && io_writedata[31:24] == 8'hEF;

wire cmd_features_abort_at_start = cmd_features_prepare && (
    (features == 8'h03 && (sector_count[7:3] != 5'd0 && sector_count[7:3] != 5'd1 && sector_count[7:3] != 5'd4 && sector_count[7:3] != 5'd8)) ||
    (features != 8'h03 && features != 8'h02 && features != 8'h82 && features != 8'hAA && features != 8'h55 && features != 8'hCC && features != 8'h66)
);

wire cmd_features_start = cmd_features_prepare && ~(cmd_features_abort_at_start);

//read verify sectors
wire cmd_verify_start = cmd_start && (io_writedata[31:24] == 8'h40 || io_writedata[31:24] == 8'h41 || io_writedata[31:24] == 8'h42);

//set multiple

//if changed - fix cmd_multiple_abort_at_start
`define MAX_MULTIPLE_SECTORS 16

wire cmd_multiple_prepare = cmd_start && io_writedata[31:24] == 8'hC6;

wire cmd_multiple_abort_at_start = cmd_multiple_prepare && (
    (sector_count > `MAX_MULTIPLE_SECTORS) ||
    (sector_count != 8'd1 && sector_count != 8'd2 && sector_count != 8'd4 && sector_count != 8'd8 && sector_count != 8'd16) ||
    (sector_count == 8'd0)
);

wire cmd_multiple_start = cmd_multiple_prepare && ~(cmd_multiple_abort_at_start);

//power
wire cmd_power_start = cmd_start && (io_writedata[31:24] == 8'hE0 || io_writedata[31:24] == 8'hE1 || io_writedata[31:24] == 8'hE7 || io_writedata[31:24] == 8'hEA);

//check power
wire cmd_checkpower_start = cmd_start && io_writedata[31:24] == 8'hE5;

//seek
wire cmd_seek_start = cmd_start && io_writedata[31:24] == 8'h70;

wire cmd_seek_in_progress = current_command == 8'h70;

//max address
wire cmd_max_prepare = cmd_start && (io_writedata[31:24] == 8'h27 || io_writedata[31:24] == 8'hF8);

wire cmd_max_abort_at_start = cmd_max_prepare && (
    ~(lba_mode)
);

wire cmd_max_start = cmd_max_prepare && ~(cmd_max_abort_at_start);

//unknown
wire cmd_unknown_start = cmd_start &&
    ~(cmd_calibrate_start) &&
    ~(cmd_read_prepare) &&
    ~(cmd_write_prepare) &&
    ~(cmd_execute_drive_diag) &&
    ~(cmd_initialize_prepare) &&
    ~(cmd_identify_start) &&
    ~(cmd_features_prepare) &&
    ~(cmd_verify_start) &&
    ~(cmd_multiple_prepare) &&
    ~(cmd_power_start) &&
    ~(cmd_checkpower_start) &&
    ~(cmd_seek_start) &&
    ~(cmd_max_prepare);

//location
wire lba48_transform_active =
    (cmd_read_start   && (io_writedata[31:24] == 8'h24 || io_writedata[31:24] == 8'h29)) ||
    (cmd_write_start  && (io_writedata[31:24] == 8'h34 || io_writedata[31:24] == 8'h39)) ||
    (cmd_verify_start &&  io_writedata[31:24] == 8'h42) ||
    (cmd_max_start    &&  io_writedata[31:24] == 8'h27);
    
wire lba48_transform_inactive = ~(lba48_transform_active) && (cmd_read_start || cmd_write_start || cmd_verify_start || cmd_max_start);

wire set_signature =
    cmd_execute_drive_diag ||
    sw_reset_end;

//------------------------------------------------------------------------------

localparam [3:0] S_IDLE                     = 4'd0;

localparam [3:0] S_PREPARE_COUNT            = 4'd1;
localparam [3:0] S_COUNT_LOGICAL            = 4'd2;
localparam [3:0] S_COUNT_FINAL              = 4'd3;
localparam [3:0] S_COUNT_DECISION           = 4'd4;

localparam [3:0] S_SD_MUTEX                 = 4'd5;
localparam [3:0] S_SD_AVALON_BASE           = 4'd6;
localparam [3:0] S_SD_ADDRESS               = 4'd7;
localparam [3:0] S_SD_BLOCK_COUNT           = 4'd8;

localparam [3:0] S_SD_CONTROL               = 4'd9;
localparam [3:0] S_SD_READ_WAIT_FOR_DATA    = 4'd10;

localparam [3:0] S_WAIT_FOR_EMPTY_READ_FIFO = 4'd11;

localparam [3:0] S_IDENTIFY_COPY            = 4'd12;

localparam [3:0] S_WAIT_FOR_FULL_WRITE_FIFO = 4'd13;
localparam [3:0] S_SD_WRITE_WAIT_FOR_DATA   = 4'd14;

localparam [3:0] S_IDENTIFY_FILL            = 4'd15;

reg [3:0] state;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                                                       state <= S_IDLE;
    
    //read
    else if(state == S_IDLE && cmd_read_start)                                                                              state <= S_PREPARE_COUNT;
        //count
    else if(state == S_COUNT_DECISION && ~(count_decision_immediate_error) && cmd_read_in_progress)                         state <= S_SD_MUTEX;
        //sd
    else if(state == S_SD_CONTROL && sd_master_waitrequest == 1'b0 && cmd_read_in_progress)                                 state <= S_SD_READ_WAIT_FOR_DATA;
    else if(state == S_SD_READ_WAIT_FOR_DATA && logical_sector_count == 5'd0)                                               state <= S_WAIT_FOR_EMPTY_READ_FIFO;
    else if(state == S_WAIT_FOR_EMPTY_READ_FIFO && from_hdd_empty_valid && num_sectors == 17'd0 && cmd_read_in_progress)    state <= S_IDLE;
    else if(state == S_WAIT_FOR_EMPTY_READ_FIFO && from_hdd_empty_valid && cmd_read_in_progress)                            state <= S_PREPARE_COUNT;
    
    //seek
    else if(state == S_IDLE && cmd_seek_start)                                                                      state <= S_PREPARE_COUNT;
        //count
    else if(state == S_COUNT_DECISION && ~(count_decision_immediate_error) && cmd_seek_in_progress)                 state <= S_IDLE;
    
    //identify
    else if(state == S_IDLE && cmd_identify_start)                                                                  state <= S_IDENTIFY_FILL;
    else if(state == S_IDENTIFY_FILL && identify_counter == 7'd127)                                                 state <= S_WAIT_FOR_EMPTY_READ_FIFO;
    else if(state == S_WAIT_FOR_EMPTY_READ_FIFO && from_hdd_empty_valid && cmd_identify_in_progress)                state <= S_IDLE;
    
    //write
    else if(state == S_IDLE && cmd_write_start)                                                                     state <= S_WAIT_FOR_FULL_WRITE_FIFO;
    else if(state == S_WAIT_FOR_FULL_WRITE_FIFO && write_data_ready)                                                state <= S_PREPARE_COUNT;
        //count
    else if(state == S_COUNT_DECISION && ~(count_decision_immediate_error) && cmd_write_in_progress)                state <= S_SD_MUTEX;
        //sd
    else if(state == S_SD_CONTROL && sd_master_waitrequest == 1'b0 && cmd_write_in_progress)                        state <= S_SD_WRITE_WAIT_FOR_DATA;
    else if(state == S_SD_WRITE_WAIT_FOR_DATA && logical_sector_count == 5'd0 && num_sectors == 17'd0)              state <= S_IDLE;
    else if(state == S_SD_WRITE_WAIT_FOR_DATA && logical_sector_count == 5'd0)                                      state <= S_WAIT_FOR_FULL_WRITE_FIFO;
    
    //count
    else if(state == S_PREPARE_COUNT)                                                                               state <= S_COUNT_LOGICAL;
    else if(state == S_COUNT_LOGICAL && mult1_b == 14'd0 && mult2_b == 9'd0)                                        state <= S_COUNT_FINAL;
    else if(state == S_COUNT_FINAL)                                                                                 state <= S_COUNT_DECISION;
    else if(state == S_COUNT_DECISION && count_decision_immediate_error)                                            state <= S_IDLE;
     
    //sd read/write
    else if(state == S_SD_MUTEX && sd_master_readdatavalid && sd_master_readdata[2:0] == 3'd2)                      state <= S_SD_AVALON_BASE;
    else if(state == S_SD_AVALON_BASE && sd_master_waitrequest == 1'b0)                                             state <= S_SD_ADDRESS;
    else if(state == S_SD_ADDRESS     && sd_master_waitrequest == 1'b0)                                             state <= S_SD_BLOCK_COUNT;
    else if(state == S_SD_BLOCK_COUNT && sd_master_waitrequest == 1'b0)                                             state <= S_SD_CONTROL;
end

//------------------------------------------------------------------------------

wire drq_zero =
    (state == S_WAIT_FOR_EMPTY_READ_FIFO && from_hdd_empty_valid && cmd_read_in_progress) ||
    (state == S_WAIT_FOR_FULL_WRITE_FIFO && write_data_ready);

wire command_finished =
    (state == S_WAIT_FOR_EMPTY_READ_FIFO && from_hdd_empty_valid && cmd_read_in_progress && num_sectors == 17'd0) ||
    (state == S_WAIT_FOR_EMPTY_READ_FIFO && from_hdd_empty_valid && cmd_identify_in_progress) ||
    (state == S_SD_WRITE_WAIT_FOR_DATA && logical_sector_count == 5'd0 && num_sectors == 17'd0) ||
    cmd_calibrate_start ||
    cmd_multiple_start ||
    cmd_power_start ||
    cmd_checkpower_start ||
    (state == S_COUNT_DECISION && ~(count_decision_immediate_error) && cmd_seek_in_progress);

wire command_requires_drq =
    (state == S_SD_READ_WAIT_FOR_DATA && logical_sector_count == 5'd0) ||
    (state == S_IDENTIFY_FILL && identify_counter == 7'd127) ||
    (state == S_SD_WRITE_WAIT_FOR_DATA && logical_sector_count == 5'd0 && num_sectors > 17'd0) ||
    (state == S_IDLE && cmd_write_start);

wire raise_interrupt =
    command_requires_drq ||
    command_abort ||
    (state == S_SD_WRITE_WAIT_FOR_DATA && logical_sector_count == 5'd0 && num_sectors == 17'd0) ||
    cmd_calibrate_start ||
    cmd_execute_drive_diag ||
    cmd_initialize_start ||
    cmd_features_start ||
    cmd_verify_start ||
    cmd_multiple_start ||
    cmd_power_start ||
    cmd_checkpower_start ||
    (state == S_COUNT_DECISION && ~(count_decision_immediate_error) && cmd_seek_in_progress) ||
    cmd_max_start;

wire lower_interrupt =
    (io_read_valid  && io_address == 1'b1 && io_byteenable[3:0] == 4'b1000) ||
    (io_write && io_address == 1'b1 && io_byteenable[3:0] == 4'b1000 && ~(drive_select));

wire command_abort =
    (state == S_COUNT_DECISION && count_decision_immediate_error) ||
    cmd_read_abort_at_start ||
    cmd_write_abort_at_start ||
    cmd_initialize_abort_at_start ||
    cmd_features_abort_at_start ||
    cmd_multiple_abort_at_start ||
    cmd_max_abort_at_start ||
    cmd_unknown_start;

//------------------------------------------------------------------------------ count logical sector count

wire [31:0] sectors_left = media_sectors - logical_sector[31:0] - 32'd1;

wire [4:0] multiple_final_write = 
    (current_command_write_multiple && lba_mode && (current_command_write_lba48 || media_sectors[31:28] == 4'd0) && sectors_left < { 27'd0, multiple_final_read })? sectors_left[4:0] : multiple_final_read;

wire [4:0] multiple_final_read =
    (num_sectors >= { 12'd0, multiple_sectors })? multiple_sectors : num_sectors[4:0];

reg [4:0] logical_sector_count;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                                                           logical_sector_count <= 5'd0;
    else if(state == S_SD_AVALON_BASE && current_command_read_multiple)                                                         logical_sector_count <= multiple_final_read;
    else if(state == S_SD_AVALON_BASE && current_command_write_multiple)                                                        logical_sector_count <= multiple_final_write;
    else if(state == S_SD_AVALON_BASE)                                                                                          logical_sector_count <= 5'd1;
    
    else if(state == S_SD_READ_WAIT_FOR_DATA  && sd_slave_write       && sd_counter == 7'd127 && logical_sector_count > 5'd0)   logical_sector_count <= logical_sector_count - 5'd1;
    else if(state == S_SD_WRITE_WAIT_FOR_DATA && sd_slave_read_valid  && sd_counter == 7'd127 && logical_sector_count > 5'd0)   logical_sector_count <= logical_sector_count - 5'd1;
end

wire count_decision_immediate_error =
    logical_sector[47:32] != 16'd0 ||
    logical_sector[31:0] >= media_sectors ||
    (current_command_read_multiple && lba_mode && (current_command_read_lba48 || media_sectors[31:28] == 4'd0) && (logical_sector[31:0] + { 27'd0, multiple_final_read }) > media_sectors);
    
//------------------------------------------------------------------------------ count logical sector

reg [29:0] mult1_a; //cylinder
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)	                mult1_a <= 30'd0;
    else if(state == S_PREPARE_COUNT)   mult1_a <= { 14'd0, cylinder };
    else if(state == S_COUNT_LOGICAL)   mult1_a <= { mult1_a[28:0], 1'b0 };
end

reg [13:0] mult1_b; //media_spc
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   mult1_b <= 14'd0;
    else if(state == S_PREPARE_COUNT)   mult1_b <= media_spc;
    else if(state == S_COUNT_LOGICAL)   mult1_b <= { 1'b0, mult1_b[13:1] };
end

reg [29:0] logical_sector1; //cylinder * media_spc
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               logical_sector1 <= 30'd0;
    else if(state == S_PREPARE_COUNT)               logical_sector1 <= { 22'd0, sector } - 30'd1;
    else if(state == S_COUNT_LOGICAL && mult1_b[0]) logical_sector1 <= logical_sector1 + mult1_a;
end

reg [12:0] mult2_a; //head
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)	                mult2_a <= 13'd0;
    else if(state == S_PREPARE_COUNT)   mult2_a <= { 9'd0, head };
    else if(state == S_COUNT_LOGICAL)   mult2_a <= { mult2_a[11:0], 1'b0 };
end

reg [8:0] mult2_b; //media_spt
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   mult2_b <= 9'd0;
    else if(state == S_PREPARE_COUNT)   mult2_b <= media_spt;
    else if(state == S_COUNT_LOGICAL)   mult2_b <= { 1'b0, mult2_b[8:1] };
end

reg [12:0] logical_sector2; //head * media_spt
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               logical_sector2 <= 13'd0;
    else if(state == S_PREPARE_COUNT)               logical_sector2 <= 13'd0;
    else if(state == S_COUNT_LOGICAL && mult2_b[0]) logical_sector2 <= logical_sector2 + mult2_a;
end

reg [47:0] logical_sector;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                       logical_sector <= 48'd0;
    else if(state == S_COUNT_FINAL && lba_mode && current_command_lba48)    logical_sector <= { hob_hcyl, hob_lcyl, hob_sector, cylinder, sector };
    else if(state == S_COUNT_FINAL && lba_mode)                             logical_sector <= { 20'd0, head, cylinder, sector };
    else if(state == S_COUNT_FINAL)                                         logical_sector <= { 18'b0, logical_sector1 } + { 35'd0, logical_sector2 };
end
    
//------------------------------------------------------------------------------ sd

reg [6:0] sd_counter;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)	                                                            sd_counter <= 7'd0;
    else if(state != S_SD_READ_WAIT_FOR_DATA && state != S_SD_WRITE_WAIT_FOR_DATA)  sd_counter <= 7'd0;
    else if(sd_slave_write || sd_slave_read_valid)                                  sd_counter <= sd_counter + 7'd1;
end

reg [31:0] sd_sector;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   sd_sector <= 32'd0;
    else if(state == S_SD_AVALON_BASE)  sd_sector <= (logical_sector >= { 16'd0, media_sectors })? media_sd_base + media_sectors - 32'd1 : media_sd_base + logical_sector[31:0];
end

assign sd_master_address =
    (state == S_SD_MUTEX)?          32'd8 :
    (state == S_SD_AVALON_BASE)?    32'd0 :
    (state == S_SD_ADDRESS)?        32'd4 :
    (state == S_SD_BLOCK_COUNT)?    32'd8 :
    (state == S_SD_CONTROL)?        32'd12 :
                                    32'd0;

reg sd_read_done;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                           sd_read_done <= 1'b0;
    else if(sd_master_read && sd_master_waitrequest == 1'b0)    sd_read_done <= 1'b1;
    else if(sd_master_readdatavalid)                            sd_read_done <= 1'b0;
end

reg [3:0] sd_mutex_wait;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                       sd_mutex_wait <= 4'd0;
    else if(state == S_SD_MUTEX && sd_master_read == 1'b0)  sd_mutex_wait <= sd_mutex_wait + 4'd1;
end

assign sd_master_read = state == S_SD_MUTEX && sd_mutex_wait == 4'd9 && ~(sd_read_done);

assign sd_master_write = state == S_SD_AVALON_BASE || state == S_SD_ADDRESS || state == S_SD_BLOCK_COUNT || state == S_SD_CONTROL;

assign sd_master_writedata =
    (state == S_SD_AVALON_BASE)?                        `SD_AVALON_BASE_ADDRESS_FOR_HDD :
    (state == S_SD_ADDRESS)?                            sd_sector :
    (state == S_SD_BLOCK_COUNT)?                        { 27'd0, logical_sector_count } :
    (state == S_SD_CONTROL && cmd_read_in_progress)?    32'd2 : //CONTROL_READ
    (state == S_SD_CONTROL && cmd_write_in_progress)?   32'd3 : //CONTROL_WRITE
                                                        32'd0;

//------------------------------------------------------------------------------ fifo for identify

reg [6:0] identify_counter;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   identify_counter <= 7'd0;
    else if(state != S_IDENTIFY_FILL)   identify_counter <= 7'd0;
    else                                identify_counter <= identify_counter + 7'd1;
end

wire [31:0] identify_q;
wire [31:0] identify_q_final =
    (identify_counter == 7'd29)?    { (multiple_sectors > 5'd0)? (16'h0100 | { 11'd0, multiple_sectors }) : 16'h0000,  identify_q[15:0] } :
                                    identify_q;

simple_fifo #(
    .width      (32),
    .widthu     (7)
)
fifo_identify_inst(
    .clk        (clk),
    .rst_n      (rst_n),
    
    .sclr       (1'b0),                                                                 //input
    
    .data       ((mgmt_write)? mgmt_writedata : identify_q),                            //input [31:0]
    .wrreq      ((mgmt_address == 3'd0 && mgmt_write) || state == S_IDENTIFY_FILL),     //input
    
    .rdreq      (state == S_IDENTIFY_FILL),                                             //input
    .q          (identify_q),                                                           //output [31:0]
    
    /* verilator lint_off PINNOCONNECT */
    .full       (),                                                                     //output
    .empty      (),                                                                     //output
    .usedw      ()                                                                      //output [6:0]
    /* verilator lint_on PINNOCONNECT */
);

//------------------------------------------------------------------------------ fifo from hdd

wire [2:0] from_hdd_stored_index_next = 3'd4 + { 1'b0, from_hdd_stored_index } - data_io_size;

reg [1:0] from_hdd_stored_index;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                           from_hdd_stored_index <= 2'd0;
    else if(state == S_IDLE)                                                    from_hdd_stored_index <= 2'd0;
    else if(read_data_io && { 1'b0, from_hdd_stored_index } >= data_io_size)    from_hdd_stored_index <= from_hdd_stored_index - data_io_size[1:0];
    else if(read_data_io && from_hdd_empty)                                     from_hdd_stored_index <= 2'd0;
    else if(read_data_io)                                                       from_hdd_stored_index <= from_hdd_stored_index_next[1:0];
end

wire [55:0] from_hdd_result =
    (from_hdd_stored_index == 2'd0)?        { 24'd0, from_hdd_q } :
    (from_hdd_stored_index == 2'd1)?        { 16'd0, from_hdd_q, from_hdd_stored[7:0] } :
    (from_hdd_stored_index == 2'd2)?        { 8'd0,  from_hdd_q, from_hdd_stored[15:0] } :
                                            {        from_hdd_q, from_hdd_stored[23:0] };
    
reg [23:0] from_hdd_stored;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               from_hdd_stored <= 24'd0;
    else if(read_data_io && data_io_size == 3'd1)   from_hdd_stored <= from_hdd_result[31:8];
    else if(read_data_io && data_io_size == 3'd2)   from_hdd_stored <= from_hdd_result[39:16];
    else if(read_data_io && data_io_size == 3'd4)   from_hdd_stored <= from_hdd_result[55:32];
end

wire from_hdd_empty_valid = from_hdd_empty && from_hdd_stored_index == 2'd0;

wire        from_hdd_empty;
wire [31:0] from_hdd_q;

simple_fifo #(
    .width      (32),
    .widthu     (11)
)
fifo_from_hdd_inst(
    .clk        (clk),
    .rst_n      (rst_n),
    
    .sclr       (sw_reset_start),                                                                   //input
    
    .data       ((state == S_IDENTIFY_FILL)? identify_q_final : sd_slave_writedata),                //input [31:0]
    .wrreq      ((state == S_SD_READ_WAIT_FOR_DATA && sd_slave_write) || state == S_IDENTIFY_FILL), //input
    
    .rdreq      (read_data_io && { 1'b0, from_hdd_stored_index } < data_io_size),                   //input
    .empty      (from_hdd_empty),                                                                   //output
    .q          (from_hdd_q),                                                                       //output [31:0]

    /* verilator lint_off PINNOCONNECT */
    .full       (),                                                                                 //output
    .usedw      ()                                                                                  //output [10:0]
    /* verilator lint_on PINNOCONNECT */
);


//------------------------------------------------------------------------------ fifo to hdd

reg [1:0] to_hdd_stored_index;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       to_hdd_stored_index <= 2'd0;
    else if(write_data_io)  to_hdd_stored_index <= to_hdd_sum[1:0];
end

wire [55:0] to_hdd_result =
    (to_hdd_stored_index == 2'd0)?        { 24'd0, io_writedata } :
    (to_hdd_stored_index == 2'd1)?        { 16'd0, io_writedata, to_hdd_stored[7:0] } :
    (to_hdd_stored_index == 2'd2)?        { 8'd0,  io_writedata, to_hdd_stored[15:0] } :
                                          {        io_writedata, to_hdd_stored[23:0] };

wire [2:0] to_hdd_sum = data_io_size + { 1'b0, to_hdd_stored_index };

reg [23:0] to_hdd_stored;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               to_hdd_stored <= 24'd0;
    else if(write_data_io && to_hdd_sum == 3'd1)    to_hdd_stored <= { 16'd0, to_hdd_result[7:0] };
    else if(write_data_io && to_hdd_sum == 3'd2)    to_hdd_stored <= { 8'd0,  to_hdd_result[15:0] };
    else if(write_data_io && to_hdd_sum == 3'd3)    to_hdd_stored <= {        to_hdd_result[23:0] };
    else if(write_data_io && to_hdd_sum == 3'd5)    to_hdd_stored <= { 16'd0, to_hdd_result[39:32] };
    else if(write_data_io && to_hdd_sum == 3'd6)    to_hdd_stored <= { 8'd0,  to_hdd_result[47:32] };
    else if(write_data_io && to_hdd_sum == 3'd7)    to_hdd_stored <= {        to_hdd_result[55:32] };
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   sd_slave_readdata <= 32'b0;
    else                sd_slave_readdata <= to_hdd_q;
end

wire [11:0] to_hdd_count = { to_hdd_full, to_hdd_usedw };
wire [10:0] to_hdd_usedw;
wire        to_hdd_full;
wire [31:0] to_hdd_q;

simple_fifo #(
    .width      (32),
    .widthu     (11)
)
fifo_to_hdd_inst(
    .clk        (clk),
    .rst_n      (rst_n),
    
    .sclr       (sw_reset_start),                                               //input
    
    .data       (to_hdd_result[31:0]),                                          //input [31:0]
    .wrreq      (write_data_io && to_hdd_sum >= 3'd4 && ~(write_data_ready)),   //input
    .full       (to_hdd_full),                                                  //output
    
    .rdreq      (state == S_SD_WRITE_WAIT_FOR_DATA && sd_slave_read_valid),     //input
    .q          (to_hdd_q),                                                     //output [31:0]

    .usedw      (to_hdd_usedw),                                                 //output [10:0]
    
    /* verilator lint_off PINNOCONNECT */
    .empty      ()                                                             //output
    /* verilator lint_on PINNOCONNECT */
);

//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0, ide_3f6_writedata[7:3], ide_3f6_writedata[0],
                           sd_master_readdata[31:3], sd_slave_address[8:0],
                           media_cylinders_minus_1[16], from_hdd_stored_index_next[2], 1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------

endmodule
