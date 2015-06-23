/*
 * This file is subject to the terms and conditions of the BSD License. See
 * the file "LICENSE" in the main directory of this archive for more details.
 *
 * Copyright (C) 2014 Aleksander Osman
 */

`include "defines.v"

module aoR3000(
    input               clk,
    input               rst_n,
    
    //
    input       [5:0]   interrupt_vector,
    
    //
    output      [31:0]  avm_address,
    output      [31:0]  avm_writedata,
    output      [3:0]   avm_byteenable,
    output      [2:0]   avm_burstcount,
    output              avm_write,
    output              avm_read,
    
    input               avm_waitrequest,
    input               avm_readdatavalid,
    input       [31:0]  avm_readdata
);

//------------------------------------------------------------------------------

wire        if_exc_address_error;
wire        if_exc_tlb_inv;
wire        if_exc_tlb_miss;

wire        if_ready;
wire [31:0] if_instr;
wire [31:0] if_pc;

wire [8:0]  fetch_cache_read_address;
wire [8:0]  fetch_cache_write_address;
wire        fetch_cache_write_enable;
wire [53:0] fetch_cache_data;

wire        tlb_ram_fetch_start;
wire [19:0] tlb_ram_fetch_vpn;

wire [31:0] ram_instr_address;
wire        ram_instr_req;


pipeline_if pipeline_if_inst(
    .clk                        (clk),
    .rst_n                      (rst_n),
    
    //
    .config_kernel_mode         (config_kernel_mode),       //input
    .entryhi_asid               (entryhi_asid),             //input [5:0]

    //
    .micro_flush_do             (micro_flush_do),           //input

    //
    .exception_start            (exception_start),          //input
    .exception_start_pc         (exception_start_pc),       //input [31:0]
    
    //
    .mem_stall                  (mem_stall),                //input

    //
    .if_exc_address_error       (if_exc_address_error),     //output
    .if_exc_tlb_inv             (if_exc_tlb_inv),           //output
    .if_exc_tlb_miss            (if_exc_tlb_miss),          //output
    .if_ready                   (if_ready),                 //output
    .if_instr                   (if_instr),                 //output [31:0]
    .if_pc                      (if_pc),                    //output [31:0]
    
    //
    .branch_start               (branch_start),             //input
    .branch_address             (branch_address),           //input [31:0]
    
    //
    .fetch_cache_read_address   (fetch_cache_read_address), //output [8:0]
    .fetch_cache_q              (fetch_cache_q),            //input [53:0]

    .fetch_cache_write_address  (fetch_cache_write_address),//output [8:0]
    .fetch_cache_write_enable   (fetch_cache_write_enable), //output
    .fetch_cache_data           (fetch_cache_data),         //output [53:0]
    
    
    //
    .tlb_ram_fetch_start        (tlb_ram_fetch_start),      //output
    .tlb_ram_fetch_vpn          (tlb_ram_fetch_vpn),        //output [19:0]
    .tlb_ram_fetch_hit          (tlb_ram_fetch_hit),        //input
    .tlb_ram_fetch_result       (tlb_ram_fetch_result),     //input [49:0]
    .tlb_ram_fetch_missed       (tlb_ram_fetch_missed),     //input

    //
    .ram_instr_address          (ram_instr_address),        //output [31:0]
    .ram_instr_req              (ram_instr_req),            //output
    .ram_instr_ack              (ram_instr_ack),            //input
    
    //
    .ram_result_address         (ram_result_address),       //input [31:0]
    .ram_result_valid           (ram_result_valid),         //input
    .ram_result_is_read_instr   (ram_result_is_read_instr), //input
    .ram_result_burstcount      (ram_result_burstcount),    //input [2:0]
    .ram_result                 (ram_result)                //input [31:0]
);


//------------------------------------------------------------------------------

wire [6:0]  rf_cmd;
wire [31:0] rf_instr;
wire [31:0] rf_pc_plus4;
wire [31:0] rf_badvpn;
wire [31:0] rf_a;
wire [31:0] rf_b;

pipeline_rf pipeline_rf_inst(
    .clk                        (clk),
    .rst_n                      (rst_n),
    
    //
    .exception_start            (exception_start),      //input

    //
    .if_exc_address_error       (if_exc_address_error), //input
    .if_exc_tlb_inv             (if_exc_tlb_inv),       //input
    .if_exc_tlb_miss            (if_exc_tlb_miss),      //input
    .if_ready                   (if_ready),             //input
    .if_instr                   (if_instr),             //input [31:0]
    .if_pc                      (if_pc),                //input [31:0]
    
    //
    .rf_cmd                     (rf_cmd),               //output [6:0]
    .rf_instr                   (rf_instr),             //output [31:0]
    .rf_pc_plus4                (rf_pc_plus4),          //output [31:0]
    .rf_badvpn                  (rf_badvpn),            //output [31:0]
    .rf_a                       (rf_a),                 //output [31:0]
    .rf_b                       (rf_b),                 //output [31:0]
    
    //
    .mem_stall                  (mem_stall),            //input

    //
    .exe_result_index           (exe_result_index),     //input [4:0]
    .exe_result                 (exe_result),           //input [31:0]
    
    .mem_result_index           (mem_result_index),     //input [4:0]
    .mem_result                 (mem_result),           //input [31:0]

    .muldiv_result_index        (muldiv_result_index),  //input [4:0]
    .muldiv_result              (muldiv_result)         //input [31:0]
);

//------------------------------------------------------------------------------

wire [6:0]  exe_cmd;
wire [31:0] exe_instr;
wire [31:0] exe_pc_plus4;
wire        exe_pc_user_seg;
wire [31:0] exe_badvpn;
wire [31:0] exe_a;
wire [31:0] exe_b;
wire [1:0]  exe_branched;
wire [31:0] exe_branch_address;
wire        exe_cmd_cp0;
wire        exe_cmd_load;
wire        exe_cmd_store;

wire [4:0]  exe_result_index;
wire [31:0] exe_result;

wire [31:0] data_address_next;
wire [31:0] data_address;

wire        branch_start;
wire [31:0] branch_address;

pipeline_exe pipeline_exe_inst(
    .clk                        (clk),
    .rst_n                      (rst_n),
    
    //
    .config_kernel_mode         (config_kernel_mode),       //input
    
    //
    .exception_start            (exception_start),          //input

    //
    .mem_stall                  (mem_stall),                //input

    //
    .rf_cmd                     (rf_cmd),                   //input [6:0]
    .rf_instr                   (rf_instr),                 //input [31:0]
    .rf_pc_plus4                (rf_pc_plus4),              //input [31:0]
    .rf_badvpn                  (rf_badvpn),                //input [31:0]
    .rf_a                       (rf_a),                     //input [31:0]
    .rf_b                       (rf_b),                     //input [31:0]
    
    //
    .exe_cmd                    (exe_cmd),                  //output [6:0]
    .exe_instr                  (exe_instr),                //output [31:0]
    .exe_pc_plus4               (exe_pc_plus4),             //output [31:0]
    .exe_pc_user_seg            (exe_pc_user_seg),          //output
    .exe_badvpn                 (exe_badvpn),               //output [31:0]
    .exe_a                      (exe_a),                    //output [31:0]
    .exe_b                      (exe_b),                    //output [31:0]
    .exe_branched               (exe_branched),             //output [1:0]
    .exe_branch_address         (exe_branch_address),       //output [31:0]
    .exe_cmd_cp0                (exe_cmd_cp0),              //output
    .exe_cmd_load               (exe_cmd_load),             //output
    .exe_cmd_store              (exe_cmd_store),            //output

    //
    .exe_result_index           (exe_result_index),         //output [4:0]
    .exe_result                 (exe_result),               //output [31:0]
    
    //
    .data_address_next          (data_address_next),        //output [31:0]
    .data_address               (data_address),             //output [31:0]
    
    //
    .branch_start               (branch_start),             //output
    .branch_address             (branch_address),           //output [31:0]

    //
    .write_buffer_counter       (write_buffer_counter)      //input [4:0]
);

//------------------------------------------------------------------------------

wire        mem_stall;

wire        config_kernel_mode;
wire        config_switch_caches;

wire [4:0]  mem_result_index;
wire [31:0] mem_result;

wire        tlb_ram_read_do;
wire [5:0]  tlb_ram_read_index;

wire        tlb_ram_write_do;
wire [5:0]  tlb_ram_write_index;
wire [49:0] tlb_ram_write_value;

wire        tlb_ram_data_start;
wire [19:0] tlb_ram_data_vpn;

wire        micro_flush_do;
wire [5:0]  entryhi_asid;

wire        exception_start;
wire [31:0] exception_start_pc;

wire [8:0]  data_cache_read_address;
wire [8:0]  data_cache_write_address;
wire        data_cache_write_enable;
wire [53:0] data_cache_data;

wire        ram_fifo_wrreq;
wire [66:0] ram_fifo_data;

wire [4:0]  muldiv_result_index;
wire [31:0] muldiv_result;

pipeline_mem pipeline_mem_inst(
    .clk                        (clk),
    .rst_n                      (rst_n),
    
    //
    .interrupt_vector           (interrupt_vector),         //input [5:0]
    
    //
    .mem_stall                  (mem_stall),                //output
    
    //
    .config_kernel_mode         (config_kernel_mode),       //output
    .config_switch_caches       (config_switch_caches),     //output
    
    //
    .exe_cmd                    (exe_cmd),                  //input [6:0]
    .exe_instr                  (exe_instr),                //input [31:0]
    .exe_pc_plus4               (exe_pc_plus4),             //input [31:0]
    .exe_pc_user_seg            (exe_pc_user_seg),          //input
    .exe_badvpn                 (exe_badvpn),               //input [31:0]
    .exe_a                      (exe_a),                    //input [31:0]
    .exe_b                      (exe_b),                    //input [31:0]
    .exe_branched               (exe_branched),             //input [1:0]
    .exe_branch_address         (exe_branch_address),       //input [31:0]
    .exe_cmd_cp0                (exe_cmd_cp0),              //input
    .exe_cmd_load               (exe_cmd_load),             //input
    .exe_cmd_store              (exe_cmd_store),            //input

    //
    .exe_result_index           (exe_result_index),         //input [4:0]
    .exe_result                 (exe_result),               //input [31:0]
    
    //
    .mem_result_index           (mem_result_index),         //output [4:0]
    .mem_result                 (mem_result),               //output [31:0]
    
    //
    .muldiv_result_index        (muldiv_result_index),      //output [4:0]
    .muldiv_result              (muldiv_result),            //output [31:0]
    
    //
    .tlb_ram_read_do            (tlb_ram_read_do),          //output
    .tlb_ram_read_index         (tlb_ram_read_index),       //output [5:0]
    .tlb_ram_read_result_ready  (tlb_ram_read_result_ready),//input
    .tlb_ram_read_result        (tlb_ram_read_result),      //input [49:0]
    
    //
    .tlb_ram_write_do           (tlb_ram_write_do),         //output
    .tlb_ram_write_index        (tlb_ram_write_index),      //output [5:0]
    .tlb_ram_write_value        (tlb_ram_write_value),      //output [49:0]
    
    //
    .tlb_ram_data_start         (tlb_ram_data_start),       //output
    .tlb_ram_data_vpn           (tlb_ram_data_vpn),         //output [19:0]
    .tlb_ram_data_hit           (tlb_ram_data_hit),         //input
    .tlb_ram_data_index         (tlb_ram_data_index),       //input [5:0]
    .tlb_ram_data_result        (tlb_ram_data_result),      //input [49:0]
    .tlb_ram_data_missed        (tlb_ram_data_missed),      //input

    //
    .exception_start            (exception_start),          //output
    .exception_start_pc         (exception_start_pc),       //output [31:0]
    
    //
    .micro_flush_do             (micro_flush_do),           //output
    .entryhi_asid               (entryhi_asid),             //output [5:0]
    
    //
    .data_address_next          (data_address_next),        //input [31:0]
    .data_address               (data_address),             //input [31:0]
    
    //
    .data_cache_read_address    (data_cache_read_address),  //output [8:0]
    .data_cache_q               (data_cache_q),             //input [53:0]

    .data_cache_write_address   (data_cache_write_address), //output [8:0]
    .data_cache_write_enable    (data_cache_write_enable),  //output
    .data_cache_data            (data_cache_data),          //output [53:0]
    
    //
    .ram_fifo_wrreq             (ram_fifo_wrreq),           //output
    .ram_fifo_data              (ram_fifo_data),            //output [66:0]
    .ram_fifo_full              (ram_fifo_full),            //input
    
    //
    .ram_result_address         (ram_result_address),       //input [31:0]
    .ram_result_valid           (ram_result_valid),         //input
    .ram_result_is_read_instr   (ram_result_is_read_instr), //input
    .ram_result_burstcount      (ram_result_burstcount),    //input [2:0]
    .ram_result                 (ram_result)                //input [31:0]
);

//------------------------------------------------------------------------------

wire [53:0] fetch_cache_q;

wire [53:0] data_cache_q;

wire        ram_fifo_empty;
wire        ram_fifo_full;
wire [66:0] ram_fifo_q;

wire [4:0]  write_buffer_counter;

memory_ram memory_ram_inst(
    .clk                        (clk),
    .rst_n                      (rst_n),
    
    //
    .config_switch_caches       (config_switch_caches),     //input

    //
    .fetch_cache_read_address   (fetch_cache_read_address), //input [8:0]
    .fetch_cache_q              (fetch_cache_q),            //input [53:0]

    .fetch_cache_write_address  (fetch_cache_write_address),//input [8:0]
    .fetch_cache_write_enable   (fetch_cache_write_enable), //input
    .fetch_cache_data           (fetch_cache_data),         //input [53:0]
    
    //
    .data_cache_read_address    (data_cache_read_address),  //input [8:0]
    .data_cache_q               (data_cache_q),             //output [53:0]
    
    .data_cache_write_address   (data_cache_write_address), //input [8:0]
    .data_cache_write_enable    (data_cache_write_enable),  //input
    .data_cache_data            (data_cache_data),          //input [53:0]
    
    //ram_fifo
    .ram_fifo_rdreq             (ram_fifo_rdreq),           //input
    .ram_fifo_wrreq             (ram_fifo_wrreq),           //input
    .ram_fifo_data              (ram_fifo_data),            //input [66:0]
    
    .ram_fifo_empty             (ram_fifo_empty),           //output
    .ram_fifo_full              (ram_fifo_full),            //output
    .ram_fifo_q                 (ram_fifo_q),               //output [66:0]

    .write_buffer_counter       (write_buffer_counter)      //output [4:0]
);

//------------------------------------------------------------------------------

wire        tlb_ram_read_result_ready;
wire [49:0] tlb_ram_read_result;

wire        tlb_ram_data_hit;
wire [5:0]  tlb_ram_data_index;
wire [49:0] tlb_ram_data_result;
wire        tlb_ram_data_missed;

wire        tlb_ram_fetch_hit;
wire [49:0] tlb_ram_fetch_result;
wire        tlb_ram_fetch_missed;

memory_tlb_ram memory_tlb_ram_inst(
    .clk                        (clk),
    .rst_n                      (rst_n),

    //
    .tlb_ram_read_do            (tlb_ram_read_do),          //input
    .tlb_ram_read_index         (tlb_ram_read_index),       //input [5:0]
    .tlb_ram_read_result_ready  (tlb_ram_read_result_ready),//output
    .tlb_ram_read_result        (tlb_ram_read_result),      //output [49:0]
    
    //
    .tlb_ram_write_do           (tlb_ram_write_do),         //input
    .tlb_ram_write_index        (tlb_ram_write_index),      //input [5:0]
    .tlb_ram_write_value        (tlb_ram_write_value),      //input [49:0]
    
    //
    .entryhi_asid               (entryhi_asid),             //input [5:0]
    
    //
    .tlb_ram_data_start         (tlb_ram_data_start),       //input
    .tlb_ram_data_vpn           (tlb_ram_data_vpn),         //input [19:0]
    .tlb_ram_data_hit           (tlb_ram_data_hit),         //output
    .tlb_ram_data_index         (tlb_ram_data_index),       //output [5:0]
    .tlb_ram_data_result        (tlb_ram_data_result),      //output [49:0]
    .tlb_ram_data_missed        (tlb_ram_data_missed),      //output

    //
    .tlb_ram_fetch_start        (tlb_ram_fetch_start),      //input
    .tlb_ram_fetch_vpn          (tlb_ram_fetch_vpn),        //input [19:0]
    .tlb_ram_fetch_hit          (tlb_ram_fetch_hit),        //output
    .tlb_ram_fetch_result       (tlb_ram_fetch_result),     //output [49:0]
    .tlb_ram_fetch_missed       (tlb_ram_fetch_missed)      //output
);

//------------------------------------------------------------------------------

wire        ram_fifo_rdreq;

wire [31:0] ram_result_address;
wire        ram_result_valid;
wire        ram_result_is_read_instr;
wire [2:0]  ram_result_burstcount;
wire [31:0] ram_result;

wire        ram_instr_ack;

memory_avalon memory_avalon_inst(
    .clk                        (clk),
    .rst_n                      (rst_n),
    
    .ram_fifo_q                 (ram_fifo_q),               //input [66:0]
    .ram_fifo_empty             (ram_fifo_empty),           //input
    .ram_fifo_rdreq             (ram_fifo_rdreq),           //output
    
    //
    .ram_instr_address          (ram_instr_address),        //input [31:0]
    .ram_instr_req              (ram_instr_req),            //input
    .ram_instr_ack              (ram_instr_ack),            //output
    
    .ram_result_address         (ram_result_address),       //output [31:0]
    .ram_result_valid           (ram_result_valid),         //output
    .ram_result_is_read_instr   (ram_result_is_read_instr), //output
    .ram_result_burstcount      (ram_result_burstcount),    //output [2:0]
    .ram_result                 (ram_result),               //output [31:0]
    
    //
    .avm_address                (avm_address),              //output [31:0]
    .avm_writedata              (avm_writedata),            //output [31:0]
    .avm_byteenable             (avm_byteenable),           //output [3:0]
    .avm_burstcount             (avm_burstcount),           //output [2:0]
    .avm_write                  (avm_write),                //output
    .avm_read                   (avm_read),                 //output
    
    .avm_waitrequest            (avm_waitrequest),          //input
    .avm_readdatavalid          (avm_readdatavalid),        //input
    .avm_readdata               (avm_readdata)              //input [31:0]
);

//------------------------------------------------------------------------------

endmodule
