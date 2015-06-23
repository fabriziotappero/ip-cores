/*
 * This file is subject to the terms and conditions of the BSD License. See
 * the file "LICENSE" in the main directory of this archive for more details.
 *
 * Copyright (C) 2014 Aleksander Osman
 */

module driver_sd(
    input               clk,
    input               rst_n,
    
    //
    input       [1:0]   avs_address,
    input               avs_read,
    output      [31:0]  avs_readdata,
    input               avs_write,
    input       [31:0]  avs_writedata,
    
    //
    output      [31:0]  avm_address,
    input               avm_waitrequest,
    output              avm_read,
    input       [31:0]  avm_readdata,
    input               avm_readdatavalid,
    output              avm_write,
    output      [31:0]  avm_writedata,
    
    //
    output reg          sd_clk,
    inout               sd_cmd,
    inout       [3:0]   sd_dat
);

//------------------------------------------------------------------------------

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               sd_clk <= 1'b0;
    else if(write_stop_sd_clk || read_stop_sd_clk)  sd_clk <= 1'b0;
    else                                            sd_clk <= ~(sd_clk);
end

//------------------------------------------------------------------------------

wire current_dat0;

wire wr_data_done;
wire wr_data_last_in_sector;
wire wr_error;
wire wr_finished_sector;

wire        rd_data_done;
wire        rd_data_last_in_sector;
wire [31:0] rd_data;
wire        rd_error;

dat dat_inst(
    .clk                    (clk),
    .rst_n                  (rst_n),
    
    //
    .sd_clk_is_one          (sd_clk),                   //input
    
    //
    .wr_async_data_ready    (wr_async_data_ready),      //input
    .wr_async_data          (wr_async_data),            //input [31:0]
    .wr_data_done           (wr_data_done),             //output
    .wr_data_last_in_sector (wr_data_last_in_sector),   //output
    .wr_error               (wr_error),                 //output
    .wr_finished_sector     (wr_finished_sector),       //output
    
    //
    .rd_async_start         (rd_async_start),           //input
    .rd_async_abort         (rd_async_abort),           //input
    .rd_data_done           (rd_data_done),             //output
    .rd_data_last_in_sector (rd_data_last_in_sector),   //output
    .rd_data                (rd_data),                  //output [31:0]
    .rd_error               (rd_error),                 //output
    
    //
    .current_dat0           (current_dat0),             //output
    
    //
    .sd_dat                 (sd_dat)                    //inout [3:0]
);

//------------------------------------------------------------------------------

wire         reply_ready;
wire [135:0] reply_contents;
wire         reply_error;

wire        cmd_ready         = (operation_write)? write_cmd_ready         : (operation_read)? read_cmd_ready         : (operation_init)? init_cmd_ready         : 1'b0;
wire [5:0]  cmd_index         = (operation_write)? write_cmd_index         : (operation_read)? read_cmd_index         : (operation_init)? init_cmd_index         : 6'b0;
wire [31:0] cmd_arg           = (operation_write)? write_cmd_arg           : (operation_read)? read_cmd_arg           : (operation_init)? init_cmd_arg           : 32'b0;
wire [7:0]  cmd_resp_length   = (operation_write)? write_cmd_resp_length   : (operation_read)? read_cmd_resp_length   : (operation_init)? init_cmd_resp_length   : 8'b0;
wire        cmd_resp_has_crc7 = (operation_write)? write_cmd_resp_has_crc7 : (operation_read)? read_cmd_resp_has_crc7 : (operation_init)? init_cmd_resp_has_crc7 : 1'b0;

cmd cmd_inst(
    .clk                (clk),
    .rst_n              (rst_n),
    
    //
    .sd_clk_is_one      (sd_clk),               //input
    
    //
    .cmd_ready          (cmd_ready),            //input
    .cmd_index          (cmd_index),            //input [5:0]
    .cmd_arg            (cmd_arg),              //input [31:0]
    .cmd_resp_length    (cmd_resp_length),      //input [7:0]
    .cmd_resp_has_crc7  (cmd_resp_has_crc7),    //input
    
    //
    .reply_ready        (reply_ready),          //output
    .reply_contents     (reply_contents),       //output [135:0]
    .reply_error        (reply_error),          //output
    
    //
    .sd_cmd             (sd_cmd)                //inout
);

//------------------------------------------------------------------------------

wire [31:0] read_data;
wire        read_done;

wire        write_done;

avalon_master avalon_master_inst(
    .clk                    (clk),
    .rst_n                  (rst_n),
    
    //
    .avm_address            (avm_address),          //output [31:0]
    .avm_waitrequest        (avm_waitrequest),      //input
    .avm_read               (avm_read),             //output
    .avm_readdata           (avm_readdata),         //input [31:0]
    .avm_readdatavalid      (avm_readdatavalid),    //input
    .avm_write              (avm_write),            //output
    .avm_writedata          (avm_writedata),        //output [31:0]
    
    //
    .avalon_address_base    (avalon_address_base),  //input [31:0]
    
    //
    .read_start             (read_start),           //input
    .read_next              (read_next),            //input
    .read_data              (read_data),            //output [31:0]
    .read_done              (read_done),            //output
    
    //
    .write_start            (write_start),          //input
    .write_next             (write_next),           //input
    .write_data             (write_data),           //input [31:0]
    .write_done             (write_done)            //output
);

//------------------------------------------------------------------------------

wire operation_write;
wire operation_read;
wire operation_init;

wire operation_sector_last;

wire [31:0] sd_address;
wire [31:0] avalon_address_base;

wire operation_sector_update       = (operation_write && write_operation_sector_update)       || (operation_read && read_operation_sector_update);
wire operation_finished_ok         = (operation_write && write_operation_finished_ok)         || (operation_read && read_operation_finished_ok)         || (operation_init && init_operation_finished_ok);
wire operation_finished_with_error = (operation_write && write_operation_finished_with_error) || (operation_read && read_operation_finished_with_error) || (operation_init && init_operation_finished_with_error);

avalon_slave avalon_slave_inst(
    .clk                            (clk),
    .rst_n                          (rst_n),
    
    //
    .avs_address                    (avs_address),                      //input [1:0]
    .avs_read                       (avs_read),                         //input
    .avs_readdata                   (avs_readdata),                     //output [31:0]
    .avs_write                      (avs_write),                        //input
    .avs_writedata                  (avs_writedata),                    //input [31:0]
    
    //
    .operation_init                 (operation_init),                   //output
    .operation_read                 (operation_read),                   //output
    .operation_write                (operation_write),                  //output
    
    .operation_sector_update        (operation_sector_update),          //input
    .operation_sector_last          (operation_sector_last),            //output

    .operation_finished_ok          (operation_finished_ok),            //input
    .operation_finished_with_error  (operation_finished_with_error),    //input
    
    //
    .sd_address                     (sd_address),                       //output [31:0]
    .avalon_address_base            (avalon_address_base)               //output [31:0]
);

//------------------------------------------------------------------------------

wire init_operation_finished_ok;
wire init_operation_finished_with_error;

wire        init_cmd_ready;
wire [5:0]  init_cmd_index;
wire [31:0] init_cmd_arg;
wire [7:0]  init_cmd_resp_length;
wire        init_cmd_resp_has_crc7;

card_init card_init_inst(
    .clk                            (clk),
    .rst_n                          (rst_n),
    
    //
    .operation_init                 (operation_init),                       //input
    .operation_finished_ok          (init_operation_finished_ok),           //output
    .operation_finished_with_error  (init_operation_finished_with_error),   //output
    
    //
    .cmd_ready                      (init_cmd_ready),                       //output
    .cmd_index                      (init_cmd_index),                       //output [5:0]
    .cmd_arg                        (init_cmd_arg),                         //output [31:0]
    .cmd_resp_length                (init_cmd_resp_length),                 //output [7:0]
    .cmd_resp_has_crc7              (init_cmd_resp_has_crc7),               //output

    .reply_ready                    (reply_ready),                          //input
    .reply_contents                 (reply_contents),                       //input [135:0]
    .reply_error                    (reply_error),                          //input
    
    //
    .current_dat0                   (current_dat0)                          //input
);

//------------------------------------------------------------------------------

wire read_operation_sector_update;
wire read_operation_finished_ok;
wire read_operation_finished_with_error;

wire rd_async_start;
wire rd_async_abort;

wire read_stop_sd_clk;

wire        read_cmd_ready;
wire [5:0]  read_cmd_index;
wire [31:0] read_cmd_arg;
wire [7:0]  read_cmd_resp_length;
wire        read_cmd_resp_has_crc7;

wire        write_start;
wire        write_next;
wire [31:0] write_data;

card_read card_read_inst(
    .clk                            (clk),
    .rst_n                          (rst_n),
    
    //
    .operation_read                 (operation_read),                       //input
    
    .operation_sector_last          (operation_sector_last),                //input
    .operation_sector_update        (read_operation_sector_update),         //output
    
    .operation_finished_ok          (read_operation_finished_ok),           //output
    .operation_finished_with_error  (read_operation_finished_with_error),   //output
    
    //
    .cmd_ready                      (read_cmd_ready),                       //output
    .cmd_index                      (read_cmd_index),                       //output [5:0]
    .cmd_arg                        (read_cmd_arg),                         //output [31:0]
    .cmd_resp_length                (read_cmd_resp_length),                 //output [7:0]
    .cmd_resp_has_crc7              (read_cmd_resp_has_crc7),               //output
    
    .reply_ready                    (reply_ready),                          //input
    .reply_contents                 (reply_contents),                       //input [135:0]
    .reply_error                    (reply_error),                          //input
    
    //
    .write_start                    (write_start),                          //output
    .write_next                     (write_next),                           //output
    .write_data                     (write_data),                           //output [31:0]
    .write_done                     (write_done),                           //input
    
    //
    .rd_async_start                 (rd_async_start),                       //output
    .rd_async_abort                 (rd_async_abort),                       //output
    .rd_data_done                   (rd_data_done),                         //input
    .rd_data_last_in_sector         (rd_data_last_in_sector),               //input
    .rd_data                        (rd_data),                              //input [31:0]
    .rd_error                       (rd_error),                             //input
    
    //
    .sd_address                     (sd_address),                           //input [31:0]
    
    //
    .current_dat0                   (current_dat0),                         //input
    
    //
    .stop_sd_clk                    (read_stop_sd_clk)                      //output
);

//------------------------------------------------------------------------------

wire write_operation_sector_update;
wire write_operation_finished_ok;
wire write_operation_finished_with_error;

wire read_start;
wire read_next;

wire write_stop_sd_clk;

wire        write_cmd_ready;
wire [5:0]  write_cmd_index;
wire [31:0] write_cmd_arg;
wire [7:0]  write_cmd_resp_length;
wire        write_cmd_resp_has_crc7;

wire        wr_async_data_ready;
wire [31:0] wr_async_data;

card_write card_write_inst(
    .clk                            (clk),
    .rst_n                          (rst_n),
    
    //
    .operation_write                (operation_write),                      //input
    
    .operation_sector_last          (operation_sector_last),                //input
    .operation_sector_update        (write_operation_sector_update),        //output
    
    .operation_finished_ok          (write_operation_finished_ok),          //output
    .operation_finished_with_error  (write_operation_finished_with_error),  //output
    
    //
    .cmd_ready                      (write_cmd_ready),                      //output
    .cmd_index                      (write_cmd_index),                      //output [5:0]
    .cmd_arg                        (write_cmd_arg),                        //output [31:0]
    .cmd_resp_length                (write_cmd_resp_length),                //output [7:0]
    .cmd_resp_has_crc7              (write_cmd_resp_has_crc7),              //output
    
    .reply_ready                    (reply_ready),                          //input
    .reply_contents                 (reply_contents),                       //input [135:0]
    .reply_error                    (reply_error),                          //input
    
    //
    .read_start                     (read_start),                           //output
    .read_next                      (read_next),                            //output
    .read_data                      (read_data),                            //input [31:0]
    .read_done                      (read_done),                            //input
    
    //
    .wr_async_data_ready            (wr_async_data_ready),                  //output
    .wr_async_data                  (wr_async_data),                        //output [31:0]
    .wr_data_done                   (wr_data_done),                         //input
    .wr_data_last_in_sector         (wr_data_last_in_sector),               //input
    .wr_error                       (wr_error),                             //input
    .wr_finished_sector             (wr_finished_sector),                   //input
    
    //
    .sd_address                     (sd_address),                           //input [31:0]
    
    //
    .current_dat0                   (current_dat0),                         //input
    
    //
    .stop_sd_clk                    (write_stop_sd_clk)                     //output
);

//------------------------------------------------------------------------------

endmodule
