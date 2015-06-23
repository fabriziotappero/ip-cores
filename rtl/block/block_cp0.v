/*
 * This file is subject to the terms and conditions of the BSD License. See
 * the file "LICENSE" in the main directory of this archive for more details.
 *
 * Copyright (C) 2014 Aleksander Osman
 */

`include "defines.v"

module block_cp0(
    input               clk,
    input               rst_n,
    
    //
    output reg          config_switch_caches,
    output reg          config_isolate_cache,
    output              config_coproc0_usable,
    output              config_coproc1_usable,
    output              config_kernel_mode,
    
    //
    input               exe_cmd_mtc0,
    input       [31:0]  exe_instr,
    input       [31:0]  exe_b,
    
    input               exe_cmd_rfe,
    input               exe_cmd_tlbr,
    input               exe_cmd_tlbwi,
    input               exe_cmd_tlbwr,
    
    //
    output      [31:0]  coproc0_output,
    
    //
    output      [5:0]   tlbw_index,
    output      [49:0]  tlbw_value,
    
    //
    output reg  [5:0]   tlbr_index,
    
    input               tlb_ram_read_result_ready,
    input       [49:0]  tlb_ram_read_result,
    
    //
    input               tlbp_update,
    input               tlbp_hit,
    input       [5:0]   tlbp_index,
    
    //
    output              micro_flush_do,
    output reg  [5:0]   entryhi_asid,
    
    //
    input               sr_cm_set,
    input               sr_cm_clear,
    
    //
    input       [5:0]   interrupt_vector,
    
    //
    output              exception_start,
    output      [31:0]  exception_start_pc,
    
    //
    input               mem_stalled,
    input       [6:0]   mem_cmd,
    input       [31:0]  mem_instr,
    input       [31:0]  mem_pc_plus4,
    input       [1:0]   mem_branched,
    input       [31:0]  mem_branch_address,
    input       [31:0]  mem_badvpn
); /* verilator public_module */

//------------------------------------------------------------------------------

reg [5:0]  sr_ku_ie;            //kernel/user and interrupt enable
reg        sr_bev;              //boot exception vector
reg        sr_cm;               //last d-cache load hit; used in d-cache isolated
reg [7:0]  sr_im;               //interrupt mask
reg [3:0]  sr_coproc_usable;    //coprocessor usable
reg        sr_reverse_endian;
reg        sr_tlb_shutdown;
reg        sr_parity_error;
reg        sr_parity_zero;

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   sr_ku_ie <= 6'b0;
    else if(exe_cmd_mtc0 && exe_instr[15:11] == 5'd12)  sr_ku_ie <= exe_b[5:0];
    else if(exe_cmd_rfe)                                sr_ku_ie <= { sr_ku_ie[5:4], sr_ku_ie[5:2] };
    else if(exception_start)                            sr_ku_ie <= { sr_ku_ie[3:0], 2'b00 };
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   sr_cm <= `FALSE;
    else if(exe_cmd_mtc0 && exe_instr[15:11] == 5'd12)  sr_cm <= exe_b[19];
    else if(sr_cm_clear)                                sr_cm <= `FALSE; //first sr_cm_clear important
    else if(sr_cm_set)                                  sr_cm <= `TRUE;
end

always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) sr_coproc_usable      <= 4'b0;   else if(exe_cmd_mtc0 && exe_instr[15:11] == 5'd12) sr_coproc_usable     <= exe_b[31:28]; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) sr_reverse_endian     <= `FALSE; else if(exe_cmd_mtc0 && exe_instr[15:11] == 5'd12) sr_reverse_endian    <= exe_b[25];    end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) sr_bev                <= `TRUE;  else if(exe_cmd_mtc0 && exe_instr[15:11] == 5'd12) sr_bev               <= exe_b[22];    end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) sr_tlb_shutdown       <= `FALSE; else if(exe_cmd_mtc0 && exe_instr[15:11] == 5'd12) sr_tlb_shutdown      <= exe_b[21];    end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) sr_parity_error       <= `FALSE; else if(exe_cmd_mtc0 && exe_instr[15:11] == 5'd12) sr_parity_error      <= exe_b[20];    end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) sr_parity_zero        <= `FALSE; else if(exe_cmd_mtc0 && exe_instr[15:11] == 5'd12) sr_parity_zero       <= exe_b[18];    end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) config_switch_caches  <= `FALSE; else if(exe_cmd_mtc0 && exe_instr[15:11] == 5'd12) config_switch_caches <= exe_b[17];    end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) config_isolate_cache  <= `FALSE; else if(exe_cmd_mtc0 && exe_instr[15:11] == 5'd12) config_isolate_cache <= exe_b[16];    end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) sr_im                 <= 8'h00;  else if(exe_cmd_mtc0 && exe_instr[15:11] == 5'd12) sr_im                <= exe_b[15:8];  end

assign config_kernel_mode    = ~(sr_ku_ie[1]);
assign config_coproc0_usable = sr_coproc_usable[0];
assign config_coproc1_usable = sr_coproc_usable[1];

//------------------------------------------------------------------------------

reg        cause_bd;            //branch delay
reg [1:0]  cause_ce;            //coproc error
reg [1:0]  cause_ip_writable;   //interrupt pending ([1:0] writable)
reg [4:0]  cause_exccode;       //exccode
reg [31:0] epc;
reg [31:0] badvaddr;

reg [5:0] interrupt_vector_reg;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   interrupt_vector_reg <= 6'd0;
    else                interrupt_vector_reg <= interrupt_vector;
end

wire [7:0] cause_ip = { interrupt_vector_reg, cause_ip_writable };

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   cause_bd <= `FALSE;
    else if(exe_cmd_mtc0 && exe_instr[15:11] == 5'd13)  cause_bd <= exe_b[31];
    else if(exception_start)                            cause_bd <= (exception_not_interrupt && mem_branched == 2'd2) || (exception_interrupt && mem_branched == 2'd1);
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   cause_ce <= 2'd0;
    else if(exe_cmd_mtc0 && exe_instr[15:11] == 5'd13)  cause_ce <= exe_b[29:28];
    else if(exception_coprocessor_error)                cause_ce <= mem_instr[27:26];
    else if(exception_start)                            cause_ce <= 2'd0;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   cause_ip_writable <= 2'd0;
    else if(exe_cmd_mtc0 && exe_instr[15:11] == 5'd13)  cause_ip_writable <= exe_b[9:8];
    else if(exception_start)                            cause_ip_writable <= 2'd0;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   cause_exccode <= 5'd31;
    else if(exe_cmd_mtc0 && exe_instr[15:11] == 5'd13)  cause_exccode <= exe_b[6:2];
    else if(exception_start)                            cause_exccode <= exception_cause;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   epc <= 32'd0;
    else if(exception_start)                            epc <= exception_epc;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   badvaddr <= 32'd0;
    else if(exception_badvaddr_update)                  badvaddr <= mem_badvpn;
end

//------------------------------------------------------------------------------

reg        tlb_probe;
reg [5:0]  tlb_random;
reg [10:0] tlb_ptebase;
reg [18:0] tlb_badvpn;

reg [19:0]  entryhi_vpn;
reg [19:0]  entrylo_pfn;
reg         entrylo_n;
reg         entrylo_d;
reg         entrylo_v;
reg         entrylo_g;

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   entryhi_vpn <= 20'd0;
    else if(exception_badvaddr_update)                  entryhi_vpn <= mem_badvpn[31:12];
    else if(exe_cmd_mtc0 && exe_instr[15:11] == 5'd10)  entryhi_vpn <= exe_b[31:12];
    else if(tlb_ram_read_result_ready)                  entryhi_vpn <= tlb_ram_read_result[19:0];
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   entryhi_asid <= 6'd0;
    else if(exe_cmd_mtc0 && exe_instr[15:11] == 5'd10)  entryhi_asid <= exe_b[11:6];
    else if(tlb_ram_read_result_ready)                  entryhi_asid <= tlb_ram_read_result[45:40];
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   entrylo_pfn <= 20'd0;
    else if(exe_cmd_mtc0 && exe_instr[15:11] == 5'd2)   entrylo_pfn <= exe_b[31:12];
    else if(tlb_ram_read_result_ready)                  entrylo_pfn <= tlb_ram_read_result[39:20];
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   entrylo_n <= `FALSE;
    else if(exe_cmd_mtc0 && exe_instr[15:11] == 5'd2)   entrylo_n <= exe_b[11];
    else if(tlb_ram_read_result_ready)                  entrylo_n <= tlb_ram_read_result[46];
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   entrylo_d <= `FALSE;
    else if(exe_cmd_mtc0 && exe_instr[15:11] == 5'd2)   entrylo_d <= exe_b[10];
    else if(tlb_ram_read_result_ready)                  entrylo_d <= tlb_ram_read_result[47];
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   entrylo_v <= `FALSE;
    else if(exe_cmd_mtc0 && exe_instr[15:11] == 5'd2)   entrylo_v <= exe_b[9];
    else if(tlb_ram_read_result_ready)                  entrylo_v <= tlb_ram_read_result[48];
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   entrylo_g <= `FALSE;
    else if(exe_cmd_mtc0 && exe_instr[15:11] == 5'd2)   entrylo_g <= exe_b[8];
    else if(tlb_ram_read_result_ready)                  entrylo_g <= tlb_ram_read_result[49];
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   tlb_ptebase <= 11'd0;
    else if(exe_cmd_mtc0 && exe_instr[15:11] == 5'd4)   tlb_ptebase <= exe_b[31:21];
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   tlb_badvpn <= 19'd0;
    else if(exception_badvaddr_update)                  tlb_badvpn <= mem_badvpn[30:12];
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   tlbr_index <= 6'd0;
    else if(exe_cmd_mtc0 && exe_instr[15:11] == 5'd0)   tlbr_index <= exe_b[13:8];
    else if(tlbp_update)                                tlbr_index <= (tlbp_hit)? tlbp_index : 6'd0;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   tlb_probe <= `FALSE;
    else if(exe_cmd_mtc0 && exe_instr[15:11] == 5'd0)   tlb_probe <= exe_b[31];
    else if(tlbp_update)                                tlb_probe <= ~(tlbp_hit);
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   tlb_random <= 6'd63;
    else if(exe_cmd_tlbwr)                              tlb_random <= (tlb_random <= 6'd08)? 6'd63 : tlb_random - 6'd1;
end

reg [5:0] entryhi_asid_last;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   entryhi_asid_last <= 6'd0;
    else                entryhi_asid_last <= entryhi_asid;
end

assign micro_flush_do = (entryhi_asid_last != entryhi_asid) || exe_cmd_tlbwi || exe_cmd_tlbwr;

assign tlbw_index = (exe_cmd_tlbwi)? tlbr_index : tlb_random;
assign tlbw_value = (tlb_ram_read_result_ready)?
    { tlb_ram_read_result[49], tlb_ram_read_result[48], tlb_ram_read_result[47], tlb_ram_read_result[46], tlb_ram_read_result[45:40], tlb_ram_read_result[39:20], tlb_ram_read_result[19:0] } :
    { entrylo_g, entrylo_v, entrylo_d, entrylo_n, entryhi_asid, entrylo_pfn, entryhi_vpn };

//------------------------------------------------------------------------------

assign coproc0_output =
    (tlb_ram_read_result_ready && exe_instr[15:11] == 5'd2)?
                                    { tlb_ram_read_result[39:20], tlb_ram_read_result[46], tlb_ram_read_result[47], tlb_ram_read_result[48], tlb_ram_read_result[49], 8'd0 } :  //entry low just after tlbr
    (tlb_ram_read_result_ready && exe_instr[15:11] == 5'd10)?
                                    { tlb_ram_read_result[19:0], tlb_ram_read_result[45:40], 6'd0 } :                                                                           //entry high just after tlbr

    (exe_instr[15:11] == 5'd0)?     { tlb_probe, 17'd0, tlbr_index, 8'd0 } :                                    //tlb index
    (exe_instr[15:11] == 5'd1)?     { 18'd0, tlb_random, 8'd0 } :                                               //tlb random
    (exe_instr[15:11] == 5'd2)?     { entrylo_pfn, entrylo_n, entrylo_d, entrylo_v, entrylo_g, 8'd0 } :         //entry low
    (exe_instr[15:11] == 5'd4)?     { tlb_ptebase, tlb_badvpn, 2'b0 } :                                         //tlb context
    (exe_instr[15:11] == 5'd8)?     badvaddr :                                                                  //bad vaddr
    (exe_instr[15:11] == 5'd10)?    { entryhi_vpn, entryhi_asid, 6'd0 } :                                       //entry high
    (exe_instr[15:11] == 5'd12)?    { sr_coproc_usable, 2'b0, sr_reverse_endian, 2'b0, sr_bev, sr_tlb_shutdown, sr_parity_error, sr_cm, sr_parity_zero,
                                      config_switch_caches, config_isolate_cache, sr_im, 2'b0, sr_ku_ie } :     //SR
    (exe_instr[15:11] == 5'd13)?    { cause_bd, 1'b0, cause_ce, 12'd0, cause_ip, 1'b0, cause_exccode, 2'b0 } :  //cause
    (exe_instr[15:11] == 5'd14)?    epc :                                                                       //epc
    (exe_instr[15:11] == 5'd15)?    { 16'd0, 8'h02, 8'h30 } :                                                   //PRId
                                    32'd0;

//------------------------------------------------------------------------------

//input       [6:0]   mem_cmd,
//input               mem_branched,
//input       [31:0]  mem_badvpn

reg mem_stalled_last;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   mem_stalled_last <= `FALSE;
    else                mem_stalled_last <= mem_stalled;
end

wire exception_interrupt         = sr_ku_ie[0] && (cause_ip & sr_im) != 8'd0 && (mem_cmd != `CMD_null || (mem_stalled_last && ~(mem_stalled))) && ~(exception_not_interrupt) && ~(mem_stalled);
wire exception_badvaddr_update   = mem_cmd == `CMD_exc_load_tlb || mem_cmd == `CMD_exc_store_tlb || mem_cmd == `CMD_exc_tlb_load_miss || mem_cmd == `CMD_exc_tlb_store_miss || mem_cmd == `CMD_exc_tlb_modif;
wire exception_coprocessor_error = mem_cmd == `CMD_exc_coproc_unusable;

wire exception_not_interrupt = exception_coprocessor_error || exception_badvaddr_update || mem_cmd == `CMD_exc_int_overflow || mem_cmd == `CMD_break || mem_cmd == `CMD_syscall ||
                               mem_cmd == `CMD_exc_load_addr_err || mem_cmd == `CMD_exc_store_addr_err || mem_cmd == `CMD_exc_reserved_instr;

assign exception_start = exception_not_interrupt || exception_interrupt;

wire [31:0] exception_epc =
    (exception_interrupt && mem_branched == 2'd2)?  mem_branch_address :
    (exception_interrupt && mem_branched == 2'd0)?  mem_pc_plus4 :
    (mem_branched == 2'd2)?                         mem_pc_plus4 - 32'd8 :
                                                    mem_pc_plus4 - 32'd4;

wire [4:0] exception_cause =
    (mem_cmd == `CMD_exc_tlb_modif)?                                        5'd1 :
    (mem_cmd == `CMD_exc_load_tlb  || mem_cmd == `CMD_exc_tlb_load_miss)?   5'd2 :
    (mem_cmd == `CMD_exc_store_tlb || mem_cmd == `CMD_exc_tlb_store_miss)?  5'd3 :
    (mem_cmd == `CMD_exc_load_addr_err)?                                    5'd4 :
    (mem_cmd == `CMD_exc_store_addr_err)?                                   5'd5 :
    (mem_cmd == `CMD_syscall)?                                              5'd8 :
    (mem_cmd == `CMD_break)?                                                5'd9 :
    (mem_cmd == `CMD_exc_reserved_instr)?                                   5'd10 :
    (mem_cmd == `CMD_exc_coproc_unusable)?                                  5'd11 :
    (mem_cmd == `CMD_exc_int_overflow)?                                     5'd12 :
                                                                            5'd0;  //interrupt

assign exception_start_pc =
    (sr_bev && (mem_cmd == `CMD_exc_tlb_load_miss || mem_cmd == `CMD_exc_tlb_store_miss))?  32'hBFC00100 :
    (mem_cmd == `CMD_exc_tlb_load_miss || mem_cmd == `CMD_exc_tlb_store_miss)?              32'h80000000 :
    (sr_bev)?                                                                               32'hBFC00180 :
                                                                                            32'h80000080;

//------------------------------------------------------------------------------
// synthesis translate_off
wire _unused_ok = &{ 1'b0, exe_instr[31:16], exe_instr[10:0], exe_cmd_tlbr, exe_cmd_tlbwr, mem_instr[31:28], mem_instr[25:0], 1'b0 };
// synthesis translate_on
//------------------------------------------------------------------------------

endmodule
