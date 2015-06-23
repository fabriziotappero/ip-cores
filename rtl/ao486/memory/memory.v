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

`include "defines.v"

module memory(
    input               clk,
    input               rst_n,
    
    //REQ:
    input               read_do,
    output              read_done,
    output              read_page_fault,
    output              read_ac_fault,
    
    input       [1:0]   read_cpl,
    input       [31:0]  read_address,
    input       [3:0]   read_length,
    input               read_lock,
    input               read_rmw,
    output      [63:0]  read_data,
    //END
    
    //REQ:
    input               write_do,
    output              write_done,
    output              write_page_fault,
    output              write_ac_fault,
    
    input       [1:0]   write_cpl,
    input       [31:0]  write_address,
    input       [2:0]   write_length,
    input               write_lock,
    input               write_rmw,
    input       [31:0]  write_data,
    //END
    
    //REQ:
    input               tlbcheck_do,
    output              tlbcheck_done,
    output              tlbcheck_page_fault,
    
    input       [31:0]  tlbcheck_address,
    input               tlbcheck_rw,
    //END
    
    output              dcache_busy,
    
    //RESP:
    input               tlbflushsingle_do,
    output              tlbflushsingle_done,
    
    input       [31:0]  tlbflushsingle_address,
    //END
    
    //RESP:
    input               tlbflushall_do,
    //END
    
    //RESP:
    input               invdcode_do,
    output              invdcode_done,
    //END
    
    //RESP:
    input               invddata_do,
    output              invddata_done,
    //END
    
    //RESP:
    input               wbinvddata_do,
    output              wbinvddata_done,
    //END
    
    // prefetch exported
    input       [1:0]   prefetch_cpl,
    input       [31:0]  prefetch_eip,
    input       [63:0]  cs_cache,
    
    input               cr0_pg,
    input               cr0_wp,
    input               cr0_am,
    input               cr0_cd,
    input               cr0_nw,
    
    input               acflag,
    
    input       [31:0]  cr3,
    
    
    // prefetch_fifo exported
    input               prefetchfifo_accept_do,
    output      [67:0]  prefetchfifo_accept_data,
    output              prefetchfifo_accept_empty,
    
    input               pipeline_after_read_empty,
    input               pipeline_after_prefetch_empty,
    
    output      [31:0]  tlb_code_pf_cr2,
    output      [15:0]  tlb_code_pf_error_code,
    
    output      [31:0]  tlb_check_pf_cr2,
    output      [15:0]  tlb_check_pf_error_code,
    
    output      [31:0]  tlb_write_pf_cr2,
    output      [15:0]  tlb_write_pf_error_code,
        
    output      [31:0]  tlb_read_pf_cr2,
    output      [15:0]  tlb_read_pf_error_code,
    
    // reset exported
    input               pr_reset,
    input               rd_reset,
    input               exe_reset,
    input               wr_reset,
    
    // avalon master
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

wire        req_writeburst_do;
wire        req_writeburst_done;
wire [31:0] req_writeburst_address;
wire [1:0]  req_writeburst_dword_length;
wire [3:0]  req_writeburst_byteenable_0;
wire [3:0]  req_writeburst_byteenable_1;
wire [55:0] req_writeburst_data;

wire        resp_writeburst_do;
wire        resp_writeburst_done;
wire [31:0] resp_writeburst_address;
wire [1:0]  resp_writeburst_dword_length;
wire [3:0]  resp_writeburst_byteenable_0;
wire [3:0]  resp_writeburst_byteenable_1;
wire [55:0] resp_writeburst_data;

link_writeburst link_writeburst_inst(
    .clk                            (clk),
    .rst_n                          (rst_n),
    
    // writeburst REQ
    .req_writeburst_do              (req_writeburst_do),            //input
    .req_writeburst_done            (req_writeburst_done),          //output
    
    .req_writeburst_address         (req_writeburst_address),       //input [31:0]
    .req_writeburst_dword_length    (req_writeburst_dword_length),  //input [1:0]
    .req_writeburst_byteenable_0    (req_writeburst_byteenable_0),  //input [3:0]
    .req_writeburst_byteenable_1    (req_writeburst_byteenable_1),  //input [3:0]
    .req_writeburst_data            (req_writeburst_data),          //input [55:0]
    
    // writeburst RESP
    .resp_writeburst_do             (resp_writeburst_do),           //output
    .resp_writeburst_done           (resp_writeburst_done),         //input
    
    .resp_writeburst_address        (resp_writeburst_address),      //output [31:0]
    .resp_writeburst_dword_length   (resp_writeburst_dword_length), //output [1:0]
    .resp_writeburst_byteenable_0   (resp_writeburst_byteenable_0), //output [3:0]
    .resp_writeburst_byteenable_1   (resp_writeburst_byteenable_1), //output [3:0]
    .resp_writeburst_data           (resp_writeburst_data)          //output [55:0]
);

//------------------------------------------------------------------------------

wire         req_writeline_do;
wire         req_writeline_done;
wire [31:0]  req_writeline_address;
wire [127:0] req_writeline_line;
    
wire         resp_writeline_do;
wire         resp_writeline_done;
wire [31:0]  resp_writeline_address;
wire [127:0] resp_writeline_line;

link_writeline link_writeline_inst(
    .clk                (clk),
    .rst_n              (rst_n),
    
    // writeline REQ
    .req_writeline_do       (req_writeline_do),         //input
    .req_writeline_done     (req_writeline_done),       //output
    
    .req_writeline_address  (req_writeline_address),    //input [31:0]
    .req_writeline_line     (req_writeline_line),       //input [127:0]
    
    // writeline RESP
    .resp_writeline_do      (resp_writeline_do),        //output
    .resp_writeline_done    (resp_writeline_done),      //input
    
    .resp_writeline_address (resp_writeline_address),   //output [31:0]
    .resp_writeline_line    (resp_writeline_line)       //output [127:0]
);

//------------------------------------------------------------------------------

wire         req_readburst_do;
wire         req_readburst_done;
wire [31:0]  req_readburst_address;
wire [1:0]   req_readburst_dword_length;
wire [3:0]   req_readburst_byte_length;
wire [95:0]  req_readburst_data;

wire         resp_readburst_do;
wire         resp_readburst_done;
wire [31:0]  resp_readburst_address;
wire [1:0]   resp_readburst_dword_length;
wire [3:0]   resp_readburst_byte_length;
wire [95:0]  resp_readburst_data;

link_readburst link_readburst_inst(
    .clk                    (clk),
    .rst_n                  (rst_n),
    
    // readburst REQ
    .req_readburst_do               (req_readburst_do),             //input
    .req_readburst_done             (req_readburst_done),           //output
    
    .req_readburst_address          (req_readburst_address),        //input [31:0]
    .req_readburst_dword_length     (req_readburst_dword_length),   //input [1:0]
    .req_readburst_byte_length      (req_readburst_byte_length),    //input [11:0]
    .req_readburst_data             (req_readburst_data),           //output [95:0]
    
    // readburst RESP
    .resp_readburst_do              (resp_readburst_do),            //output
    .resp_readburst_done            (resp_readburst_done),          //input
    
    .resp_readburst_address         (resp_readburst_address),       //output [31:0]
    .resp_readburst_dword_length    (resp_readburst_dword_length),  //output [1:0]
    .resp_readburst_byte_length     (resp_readburst_byte_length),   //output [3:0]
    .resp_readburst_data            (resp_readburst_data)           //input [95:0]
);

//------------------------------------------------------------------------------


wire         req_readline_do;
wire         req_readline_done;
wire [31:0]  req_readline_address;
wire [127:0] req_readline_line;
    
wire         resp_readline_do;
wire         resp_readline_done;
wire [31:0]  resp_readline_address;
wire [127:0] resp_readline_line;

link_readline link_readline_inst(
    .clk                    (clk),
    .rst_n                  (rst_n),
    
    // readline REQ
    .req_readline_do        (req_readline_do),      //input
    .req_readline_done      (req_readline_done),    //output
    
    .req_readline_address   (req_readline_address), //input [31:0]
    .req_readline_line      (req_readline_line),    //output [127:0]
    
    // readline RESP
    .resp_readline_do       (resp_readline_do),     //output
    .resp_readline_done     (resp_readline_done),   //input
    
    .resp_readline_address  (resp_readline_address),//output [31:0]
    .resp_readline_line     (resp_readline_line)    //input [127:0]
);

//------------------------------------------------------------------------------

wire         req_readcode_do;
wire         req_readcode_done;
wire [31:0]  req_readcode_address;
wire [127:0] req_readcode_line;
wire [31:0]  req_readcode_partial;
wire         req_readcode_partial_done;
    
wire         resp_readcode_do;
wire         resp_readcode_done;
wire [31:0]  resp_readcode_address;
wire [127:0] resp_readcode_line;
wire [31:0]  resp_readcode_partial;
wire         resp_readcode_partial_done;

link_readcode link_readcode_inst(
    .clk                (clk),
    .rst_n              (rst_n),
    
    // readcode REQ
    .req_readcode_do                (req_readcode_do),            //input
    .req_readcode_done              (req_readcode_done),          //output
    
    .req_readcode_address           (req_readcode_address),       //input [31:0]
    .req_readcode_line              (req_readcode_line),          //output [127:0]
    .req_readcode_partial           (req_readcode_partial),       //output [31:0]
    .req_readcode_partial_done      (req_readcode_partial_done),  //output
    
    // readcode RESP
    .resp_readcode_do               (resp_readcode_do),           //output
    .resp_readcode_done             (resp_readcode_done),         //input
    
    .resp_readcode_address          (resp_readcode_address),      //output [31:0]
    .resp_readcode_line             (resp_readcode_line),         //input [127:0]
    .resp_readcode_partial          (resp_readcode_partial),      //input [31:0]
    .resp_readcode_partial_done     (resp_readcode_partial_done)  //input
);

//------------------------------------------------------------------------------

wire             req_dcacheread_do;
wire             req_dcacheread_done;
wire [3:0]       req_dcacheread_length;
wire             req_dcacheread_cache_disable;
wire [31:0]      req_dcacheread_address;
wire [63:0]      req_dcacheread_data;

wire             resp_dcacheread_do;
wire             resp_dcacheread_done;
wire [3:0]       resp_dcacheread_length;
wire             resp_dcacheread_cache_disable;
wire [31:0]      resp_dcacheread_address;
wire [63:0]      resp_dcacheread_data;

link_dcacheread link_dcacheread_inst(
    .clk                (clk),
    .rst_n              (rst_n),
    
    // dcacheread REQ
    .req_dcacheread_do                  (req_dcacheread_do),              //input
    .req_dcacheread_done                (req_dcacheread_done),            //output
    
    .req_dcacheread_length              (req_dcacheread_length),          //input [3:0]
    .req_dcacheread_cache_disable       (req_dcacheread_cache_disable),   //input
    .req_dcacheread_address             (req_dcacheread_address),         //input [31:0]
    .req_dcacheread_data                (req_dcacheread_data),            //output [63:0]
    
    // dcacheread RESP
    .resp_dcacheread_do                 (resp_dcacheread_do),             //output
    .resp_dcacheread_done               (resp_dcacheread_done),           //input
    
    .resp_dcacheread_length             (resp_dcacheread_length),         //output [3:0]
    .resp_dcacheread_cache_disable      (resp_dcacheread_cache_disable),  //output
    .resp_dcacheread_address            (resp_dcacheread_address),        //output [31:0]
    .resp_dcacheread_data               (resp_dcacheread_data)            //input [63:0]
);

//------------------------------------------------------------------------------

wire               req_dcachewrite_do;
wire               req_dcachewrite_done;
wire   [2:0]       req_dcachewrite_length;
wire               req_dcachewrite_cache_disable;
wire   [31:0]      req_dcachewrite_address;
wire               req_dcachewrite_write_through;
wire   [31:0]      req_dcachewrite_data;

wire              resp_dcachewrite_do;
wire              resp_dcachewrite_done;
wire  [2:0]       resp_dcachewrite_length;
wire              resp_dcachewrite_cache_disable;
wire  [31:0]      resp_dcachewrite_address;
wire              resp_dcachewrite_write_through;
wire  [31:0]      resp_dcachewrite_data;

link_dcachewrite link_dcachewrite_inst(
    .clk                (clk),
    .rst_n              (rst_n),
    
    // dcachewrite REQ
    .req_dcachewrite_do                 (req_dcachewrite_do),             //input
    .req_dcachewrite_done               (req_dcachewrite_done),           //output
    
    .req_dcachewrite_length             (req_dcachewrite_length),         //input [2:0]
    .req_dcachewrite_cache_disable      (req_dcachewrite_cache_disable),  //input
    .req_dcachewrite_address            (req_dcachewrite_address),        //input [31:0]
    .req_dcachewrite_write_through      (req_dcachewrite_write_through),  //input
    .req_dcachewrite_data               (req_dcachewrite_data),           //input [31:0]
    
    // dcachewrite RESP
    .resp_dcachewrite_do                (resp_dcachewrite_do),            //output
    .resp_dcachewrite_done              (resp_dcachewrite_done),          //input
    
    .resp_dcachewrite_length            (resp_dcachewrite_length),        //output [2:0]
    .resp_dcachewrite_cache_disable     (resp_dcachewrite_cache_disable), //output
    .resp_dcachewrite_address           (resp_dcachewrite_address),       //output [31:0]
    .resp_dcachewrite_write_through     (resp_dcachewrite_write_through), //output
    .resp_dcachewrite_data              (resp_dcachewrite_data)           //output [31:0]
);

//------------------------------------------------------------------------------

wire         tlbread_do;
wire         tlbread_done;
wire         tlbread_page_fault;
wire         tlbread_ac_fault;
wire         tlbread_retry;

wire [1:0]   tlbread_cpl;
wire [31:0]  tlbread_address;
wire [3:0]   tlbread_length;
wire [3:0]   tlbread_length_full;
wire         tlbread_lock;
wire         tlbread_rmw;
wire [63:0]  tlbread_data;


//------------------------------------------------------------------------------

wire         tlbwrite_do;
wire         tlbwrite_done;
wire         tlbwrite_page_fault;
wire         tlbwrite_ac_fault;

wire [1:0]   tlbwrite_cpl;
wire [31:0]  tlbwrite_address;
wire [2:0]   tlbwrite_length;
wire [2:0]   tlbwrite_length_full;
wire         tlbwrite_lock;
wire         tlbwrite_rmw;
wire [31:0]  tlbwrite_data;

//------------------------------------------------------------------------------

wire        dcachetoicache_write_do;
wire [31:0] dcachetoicache_write_address;

//------------------------------------------------------------------------------

wire        dcachetoicache_accept_do;
wire [31:0] dcachetoicache_accept_address;
wire        dcachetoicache_accept_empty;

//------------------------------------------------------------------------------

wire        icacheread_do;
wire [31:0] icacheread_address;
wire [4:0]  icacheread_length; // takes into account: page size and cs segment limit
wire        icacheread_cache_disable;

//------------------------------------------------------------------------------

wire            prefetchfifo_write_do;
wire [135:0]    prefetchfifo_write_data;

//------------------------------------------------------------------------------

wire            prefetched_do;
wire [4:0]      prefetched_length;

//------------------------------------------------------------------------------

wire [31:0]     prefetch_address;
wire [4:0]      prefetch_length;
wire            prefetch_su;

//------------------------------------------------------------------------------

wire            prefetchfifo_signal_limit_do;
wire            prefetchfifo_signal_pf_do;
wire [4:0]      prefetchfifo_used;

//------------------------------------------------------------------------------

wire            tlbcoderequest_do;
wire [31:0]     tlbcoderequest_address;
wire            tlbcoderequest_su;

//------------------------------------------------------------------------------

wire            tlbcode_do;
wire [31:0]     tlbcode_linear;
wire [31:0]     tlbcode_physical;
wire            tlbcode_cache_disable;

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

avalon_mem avalon_mem_inst(
    // global
    .clk                        (clk),
    .rst_n                      (rst_n),
    
    //RESP:
    .writeburst_do              (resp_writeburst_do),           //input
    .writeburst_done            (resp_writeburst_done),         //output
    
    .writeburst_address         (resp_writeburst_address),      //input [31:0]
    .writeburst_dword_length    (resp_writeburst_dword_length), //input [1:0]
    .writeburst_byteenable_0    (resp_writeburst_byteenable_0), //input [3:0]
    .writeburst_byteenable_1    (resp_writeburst_byteenable_1), //input [3:0]
    .writeburst_data            (resp_writeburst_data),         //input [55:0]
    //END
    
    //RESP:
    .writeline_do               (resp_writeline_do),            //input
    .writeline_done             (resp_writeline_done),          //output
    
    .writeline_address          (resp_writeline_address),       //input [31:0]
    .writeline_line             (resp_writeline_line),          //input [127:0]
    //END
    
    //RESP:
    .readburst_do               (resp_readburst_do),            //input
    .readburst_done             (resp_readburst_done),          //output
    
    .readburst_address          (resp_readburst_address),       //input  [31:0]
    .readburst_dword_length     (resp_readburst_dword_length),  //input  [1:0]
    .readburst_byte_length      (resp_readburst_byte_length),   //input [3:0]
    .readburst_data             (resp_readburst_data),          //output [95:0]
    //END
    
    //RESP:
    .readline_do                (resp_readline_do),             //input
    .readline_done              (resp_readline_done),           //output
    
    .readline_address           (resp_readline_address),        //input [31:0]
    .readline_line              (resp_readline_line),           //output [127:0]
    //END
    
    //RESP:
    .readcode_do                (resp_readcode_do),             //input
    .readcode_done              (resp_readcode_done),           //output

    .readcode_address           (resp_readcode_address),        //input [31:0]
    .readcode_line              (resp_readcode_line),           //output [127:0]
    .readcode_partial           (resp_readcode_partial),        //output [31:0]
    .readcode_partial_done      (resp_readcode_partial_done),   //output
    //END
    
    // avalon master
    .avm_address                (avm_address),                  //output [31:0]
    .avm_writedata              (avm_writedata),                //output [31:0]
    .avm_byteenable             (avm_byteenable),               //output [3:0]
    .avm_burstcount             (avm_burstcount),               //output [2:0]
    .avm_write                  (avm_write),                    //output
    .avm_read                   (avm_read),                     //output
    
    .avm_waitrequest            (avm_waitrequest),              //input
    .avm_readdatavalid          (avm_readdatavalid),            //input
    .avm_readdata               (avm_readdata)                  //input [31:0]
);

//------------------------------------------------------------------------------

dcache dcache_inst(
    // global
    .clk                (clk),
    .rst_n              (rst_n),
    
    //RESP:
    .dcacheread_do              (resp_dcacheread_do),              //input
    .dcacheread_done            (resp_dcacheread_done),            //output
    
    .dcacheread_length          (resp_dcacheread_length),          //input [3:0]
    .dcacheread_cache_disable   (resp_dcacheread_cache_disable),   //input
    .dcacheread_address         (resp_dcacheread_address),         //input [31:0]
    .dcacheread_data            (resp_dcacheread_data),            //output [63:0]
    //END
    
    //RESP:
    .dcachewrite_do                 (resp_dcachewrite_do),                 //input
    .dcachewrite_done               (resp_dcachewrite_done),               //output
    
    .dcachewrite_length             (resp_dcachewrite_length),             //input [2:0]
    .dcachewrite_cache_disable      (resp_dcachewrite_cache_disable),      //input
    .dcachewrite_address            (resp_dcachewrite_address),            //input [31:0]
    .dcachewrite_write_through      (resp_dcachewrite_write_through),      //input
    .dcachewrite_data               (resp_dcachewrite_data),               //input [31:0]
    //END
    
    //REQ:
    .readline_do            (req_readline_do),      //output
    .readline_done          (req_readline_done),    //input
    
    .readline_address       (req_readline_address),   //output [31:0]
    .readline_line          (req_readline_line),      //input [127:0]
    //END
    
    //REQ:
    .readburst_do               (req_readburst_do),             //output
    .readburst_done             (req_readburst_done),           //input
    
    .readburst_address          (req_readburst_address),        //output [31:0]
    .readburst_dword_length     (req_readburst_dword_length),   //output [1:0]
    .readburst_byte_length      (req_readburst_byte_length),    //output [3:0]
    .readburst_data             (req_readburst_data),           //input [95:0]
    //END
    
    //REQ:
    .writeline_do               (req_writeline_do),         //output
    .writeline_done             (req_writeline_done),       //input
    
    .writeline_address          (req_writeline_address),    //output [31:0]
    .writeline_line             (req_writeline_line),       //output [127:0]
    //END
    
    //REQ:
    .writeburst_do              (req_writeburst_do),            //output
    .writeburst_done            (req_writeburst_done),          //input
    
    .writeburst_address         (req_writeburst_address),       //output [31:0]
    .writeburst_dword_length    (req_writeburst_dword_length),  //output [1:0]
    .writeburst_byteenable_0    (req_writeburst_byteenable_0),  //output [3:0]
    .writeburst_byteenable_1    (req_writeburst_byteenable_1),  //output [3:0]
    .writeburst_data            (req_writeburst_data),          //output [55:0]
    //END
    
    .dcachetoicache_write_do        (dcachetoicache_write_do),         //output
    .dcachetoicache_write_address   (dcachetoicache_write_address),    //output [31:0]
                   
                   
    //RESP:
    .invddata_do        (invddata_do),        //input
    .invddata_done      (invddata_done),      //output
    //END
    
    //RESP:
    .wbinvddata_do      (wbinvddata_do),      //input
    .wbinvddata_done    (wbinvddata_done),    //output
    //END
    
    .dcache_busy        (dcache_busy)           //output
);

//------------------------------------------------------------------------------

dcache_to_icache_fifo dcache_to_icache_fifo_inst(
    .clk            (clk),
    .rst_n          (rst_n),
    
    //RESP:
    .dcachetoicache_write_do        (dcachetoicache_write_do),        //input
    .dcachetoicache_write_address   (dcachetoicache_write_address),   //input [31:0]
    //END
    
    
    //RESP:
    .dcachetoicache_accept_do       (dcachetoicache_accept_do),       //input
    .dcachetoicache_accept_address  (dcachetoicache_accept_address),  //output [31:0]
    .dcachetoicache_accept_empty    (dcachetoicache_accept_empty)     //output
    //END
);

//------------------------------------------------------------------------------

icache icache_inst(
    .clk            (clk),
    .rst_n          (rst_n),
    
    //RESP:
    .pr_reset       (pr_reset),   //input
    //END
    
    //RESP:
    .icacheread_do              (icacheread_do),              //input
    .icacheread_address         (icacheread_address),         //input [31:0]
    .icacheread_length          (icacheread_length),          //input [4:0] // takes into account: page size and cs segment limit
    .icacheread_cache_disable   (icacheread_cache_disable),   //input
    
    //REQ:
    .readcode_do                (req_readcode_do),              //output
    .readcode_done              (req_readcode_done),            //input
    
    .readcode_address           (req_readcode_address),         //output [31:0]
    .readcode_line              (req_readcode_line),            //input [127:0]
    .readcode_partial           (req_readcode_partial),         //input [31:0]
    .readcode_partial_done      (req_readcode_partial_done),    //input
    //END
    
    //REQ:
    .dcachetoicache_accept_do       (dcachetoicache_accept_do),       //output
    .dcachetoicache_accept_address  (dcachetoicache_accept_address),  //input [31:0]
    .dcachetoicache_accept_empty    (dcachetoicache_accept_empty),    //input
    //END
    
    //REQ:
    .prefetchfifo_write_do      (prefetchfifo_write_do),      //output
    .prefetchfifo_write_data    (prefetchfifo_write_data),    //output [135:0]
    //END
    
    //REQ:
    .prefetched_do      (prefetched_do),      //output
    .prefetched_length  (prefetched_length),  //output [4:0]
    //END
                   
    //RESP:
    .invdcode_do        (invdcode_do),    //input
    .invdcode_done      (invdcode_done)   //output
    //END
);

//------------------------------------------------------------------------------

memory_read memory_read_inst(
    // global
    .clk                (clk),
    .rst_n              (rst_n),
    
    // read step
    .rd_reset           (rd_reset),   //input
    
    //RESP:
    .read_do            (read_do),            //input
    .read_done          (read_done),          //output
    .read_page_fault    (read_page_fault),    //output
    .read_ac_fault      (read_ac_fault),      //output
    
    .read_cpl           (read_cpl),           //input [1:0]
    .read_address       (read_address),       //input [31:0]
    .read_length        (read_length),        //input [3:0]
    .read_lock          (read_lock),          //input
    .read_rmw           (read_rmw),           //input
    .read_data          (read_data),          //output [63:0]
    //END
    
    //REQ:
    .tlbread_do             (tlbread_do),             //output
    .tlbread_done           (tlbread_done),           //input
    .tlbread_page_fault     (tlbread_page_fault),     //input
    .tlbread_ac_fault       (tlbread_ac_fault),       //input
    .tlbread_retry          (tlbread_retry),          //input
    
    .tlbread_cpl            (tlbread_cpl),            //output [1:0]
    .tlbread_address        (tlbread_address),        //output [31:0]
    .tlbread_length         (tlbread_length),         //output [3:0]
    .tlbread_length_full    (tlbread_length_full),    //output [3:0]
    .tlbread_lock           (tlbread_lock),           //output
    .tlbread_rmw            (tlbread_rmw),            //output
    .tlbread_data           (tlbread_data)            //input [63:0]
    //END
    
);

//------------------------------------------------------------------------------

memory_write memory_write_inst(
    .clk                (clk),
    .rst_n              (rst_n),
    
    // write step
    .wr_reset           (wr_reset),   //input
    
    //RESP:
    .write_do           (write_do),           //input
    .write_done         (write_done),         //output
    .write_page_fault   (write_page_fault),   //output
    .write_ac_fault     (write_ac_fault),     //output
    
    .write_cpl          (write_cpl),          //input [1:0]
    .write_address      (write_address),      //input [31:0]
    .write_length       (write_length),       //input [2:0]
    .write_lock         (write_lock),         //input
    .write_rmw          (write_rmw),          //input
    .write_data         (write_data),         //input [31:0]
    //END
    
    //REQ:
    .tlbwrite_do            (tlbwrite_do),            //output
    .tlbwrite_done          (tlbwrite_done),          //input
    .tlbwrite_page_fault    (tlbwrite_page_fault),    //input
    .tlbwrite_ac_fault      (tlbwrite_ac_fault),      //input
    
    .tlbwrite_cpl           (tlbwrite_cpl),           //output [1:0]
    .tlbwrite_address       (tlbwrite_address),       //output [31:0]
    .tlbwrite_length        (tlbwrite_length),        //output [2:0]
    .tlbwrite_length_full   (tlbwrite_length_full),   //output [2:0]
    .tlbwrite_lock          (tlbwrite_lock),          //output
    .tlbwrite_rmw           (tlbwrite_rmw),           //output
    .tlbwrite_data          (tlbwrite_data)           //output [31:0]
    //END
    
);

//------------------------------------------------------------------------------

prefetch prefetch_inst(
    .clk                (clk),
    .rst_n              (rst_n),
    
    .pr_reset       (pr_reset),   //input
    
    // prefetch exported
    .prefetch_cpl   (prefetch_cpl),        //input [1:0]
    .prefetch_eip   (prefetch_eip),        //input [31:0]
    .cs_cache       (cs_cache),            //input [63:0]
    
    //to prefetch_control
    .prefetch_address   (prefetch_address),   //output [31:0]
    .prefetch_length    (prefetch_length),    //output [4:0]
    .prefetch_su        (prefetch_su),        //output
    
    //RESP:
    .prefetched_do      (prefetched_do),      //input
    .prefetched_length  (prefetched_length),  //input [4:0]
    //END

    //REQ:
    .prefetchfifo_signal_limit_do   (prefetchfifo_signal_limit_do)    //output
    //END
);

//------------------------------------------------------------------------------

prefetch_fifo prefetch_fifo_inst(
    .clk            (clk),
    .rst_n          (rst_n),
    
    .pr_reset       (pr_reset),   //input
    
    //RESP:
    .prefetchfifo_signal_limit_do    (prefetchfifo_signal_limit_do), //input
    //END
    
    //RESP:
    .prefetchfifo_signal_pf_do   (prefetchfifo_signal_pf_do),  //input
    //END
    
    //RESP:
    .prefetchfifo_write_do      (prefetchfifo_write_do),      //input
    .prefetchfifo_write_data    (prefetchfifo_write_data),    //input [135:0]
    //END
    
    .prefetchfifo_used   (prefetchfifo_used),    //output [4:0]
    
    //RESP:
    .prefetchfifo_accept_do     (prefetchfifo_accept_do),     //input
    .prefetchfifo_accept_data   (prefetchfifo_accept_data),   //output [67:0]
    .prefetchfifo_accept_empty  (prefetchfifo_accept_empty)   //output
    //END
);

//------------------------------------------------------------------------------


prefetch_control prefetch_control_inst(
    .clk                    (clk),
    .rst_n                  (rst_n),
    
    .pr_reset       (pr_reset), //input //same as reset to icache
    
    //REQ:
    .tlbcoderequest_do       (tlbcoderequest_do),      //output
    .tlbcoderequest_address  (tlbcoderequest_address), //output [31:0]
    .tlbcoderequest_su       (tlbcoderequest_su),      //output
    //END

    //RESP:
    .tlbcode_do             (tlbcode_do),             //input
    .tlbcode_linear         (tlbcode_linear),         //input [31:0]
    .tlbcode_physical       (tlbcode_physical),       //input [31:0]
    .tlbcode_cache_disable  (tlbcode_cache_disable),  //input
    //END
    
    //from prefetch
    .prefetch_address   (prefetch_address),   //input [31:0]
    .prefetch_length    (prefetch_length),    //input [4:0]
    .prefetch_su        (prefetch_su),        //input
    
    //from prefetchfifo
    .prefetchfifo_used  (prefetchfifo_used),  //input [4:0]
    
    //REQ
    .icacheread_do              (icacheread_do),              //output
    .icacheread_address         (icacheread_address),         //output [31:0]
    .icacheread_length          (icacheread_length),          //output [4:0] // takes into account: page size and cs segment limit
    .icacheread_cache_disable   (icacheread_cache_disable)    //output
    //END
);



//------------------------------------------------------------------------------

tlb tlb_inst(
    .clk                (clk),
    .rst_n              (rst_n),

    .pr_reset       (pr_reset),   //input
    .rd_reset       (rd_reset),   //input
    .exe_reset      (exe_reset),  //input
    .wr_reset       (wr_reset),   //input
    
    // tlb exported
    .cr0_pg                             (cr0_pg),                             //input
    .cr0_wp                             (cr0_wp),                             //input
    .cr0_am                             (cr0_am),                             //input
    .cr0_cd                             (cr0_cd),                             //input
    .cr0_nw                             (cr0_nw),                             //input
    
    .acflag                             (acflag),                             //input
    
    .cr3                                (cr3),                                //input [31:0]
    
    .pipeline_after_read_empty          (pipeline_after_read_empty),          //input
    .pipeline_after_prefetch_empty      (pipeline_after_prefetch_empty),      //input
    
    .tlb_code_pf_cr2         (tlb_code_pf_cr2),            //output [31:0]
    .tlb_code_pf_error_code  (tlb_code_pf_error_code),     //output [15:0]
    
    .tlb_check_pf_cr2        (tlb_check_pf_cr2),           //output [31:0]
    .tlb_check_pf_error_code (tlb_check_pf_error_code),    //output [15:0]
    
    .tlb_write_pf_cr2        (tlb_write_pf_cr2),           //output [31:0]
    .tlb_write_pf_error_code (tlb_write_pf_error_code),    //output [15:0]
        
    .tlb_read_pf_cr2         (tlb_read_pf_cr2),            //output [31:0]
    .tlb_read_pf_error_code  (tlb_read_pf_error_code),     //output [15:0]
             
    //RESP:
    .tlbflushsingle_do          (tlbflushsingle_do),          //input
    .tlbflushsingle_done        (tlbflushsingle_done),        //output
    
    .tlbflushsingle_address     (tlbflushsingle_address),     //input
    //END
    
    //RESP:
    .tlbflushall_do             (tlbflushall_do),             //input
    //END
    
    //RESP:
    .tlbread_do             (tlbread_do),             //input
    .tlbread_done           (tlbread_done),           //output
    .tlbread_page_fault     (tlbread_page_fault),     //output
    .tlbread_ac_fault       (tlbread_ac_fault),       //output
    .tlbread_retry          (tlbread_retry),          //output
    
    .tlbread_cpl            (tlbread_cpl),            //input [1:0]
    .tlbread_address        (tlbread_address),        //input [31:0]
    .tlbread_length         (tlbread_length),         //input [3:0]
    .tlbread_length_full    (tlbread_length_full),    //input [3:0]
    .tlbread_lock           (tlbread_lock),           //input
    .tlbread_rmw            (tlbread_rmw),            //input
    .tlbread_data           (tlbread_data),           //output [63:0]
    //END
    
    //RESP:
    .tlbwrite_do            (tlbwrite_do),            //input
    .tlbwrite_done          (tlbwrite_done),          //output
    .tlbwrite_page_fault    (tlbwrite_page_fault),    //output
    .tlbwrite_ac_fault      (tlbwrite_ac_fault),      //output
    
    .tlbwrite_cpl           (tlbwrite_cpl),           //input [1:0]
    .tlbwrite_address       (tlbwrite_address),       //input [31:0]
    .tlbwrite_length        (tlbwrite_length),        //input [2:0]
    .tlbwrite_length_full   (tlbwrite_length_full),   //input [2:0]
    .tlbwrite_lock          (tlbwrite_lock),          //input
    .tlbwrite_rmw           (tlbwrite_rmw),           //input
    .tlbwrite_data          (tlbwrite_data),          //input [31:0]
    //END
    
    //RESP:
    .tlbcheck_do            (tlbcheck_do),            //input
    .tlbcheck_done          (tlbcheck_done),          //output
    .tlbcheck_page_fault    (tlbcheck_page_fault),    //output

    .tlbcheck_address       (tlbcheck_address),       //input [31:0]
    .tlbcheck_rw            (tlbcheck_rw),            //input
    //END
    
    //REQ:
    .dcacheread_do              (req_dcacheread_do),
    .dcacheread_done            (req_dcacheread_done),
    
    .dcacheread_length          (req_dcacheread_length),
    .dcacheread_cache_disable   (req_dcacheread_cache_disable),
    .dcacheread_address         (req_dcacheread_address),
    .dcacheread_data            (req_dcacheread_data),
    //END
    
    //REQ:
    .dcachewrite_do                 (req_dcachewrite_do),                 //output
    .dcachewrite_done               (req_dcachewrite_done),               //input

    .dcachewrite_length             (req_dcachewrite_length),             //output [2:0]
    .dcachewrite_cache_disable      (req_dcachewrite_cache_disable),      //output
    .dcachewrite_address            (req_dcachewrite_address),            //output [31:0]
    .dcachewrite_write_through      (req_dcachewrite_write_through),      //output
    .dcachewrite_data               (req_dcachewrite_data),               //output [31:0]
    //END
    
    //RESP:
    .tlbcoderequest_do       (tlbcoderequest_do),          //input
    .tlbcoderequest_address  (tlbcoderequest_address),     //input [31:0]
    .tlbcoderequest_su       (tlbcoderequest_su),          //input
    //END

    //REQ:
    .tlbcode_do              (tlbcode_do),             //output
    .tlbcode_linear          (tlbcode_linear),         //output [31:0]
    .tlbcode_physical        (tlbcode_physical),       //output [31:0]
    .tlbcode_cache_disable   (tlbcode_cache_disable),  //output
    //END
    
    //REQ:
    .prefetchfifo_signal_pf_do   (prefetchfifo_signal_pf_do)     //output
    //END
);

    
    
endmodule
