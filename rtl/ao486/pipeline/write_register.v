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

module write_register(
    input               clk,
    input               rst_n,
    
    
    
    //general input
    input       [63:0]  glob_descriptor,
    input       [31:0]  glob_param_1,
    
    //wr input
    input               wr_is_8bit,
    input               wr_operand_32bit,
    input       [15:0]  wr_decoder, 
    input       [2:0]   wr_modregrm_reg,
    input       [2:0]   wr_modregrm_rm,
    
    input               wr_clear_rflag,
    
    //segment control
    input       [15:0]  wr_seg_sel,
    input       [1:0]   wr_seg_rpl,
    input               wr_seg_cache_valid,
                                   
    input               write_seg_sel,
    input               write_seg_rpl,
    input               write_seg_cache,
    input               write_seg_cache_valid,
    input       [63:0]  wr_seg_cache_mask,
    
    input               wr_validate_seg_regs,
    
    input               write_system_touch,
    input               write_system_busy_tss,

    //exe exception write
    input               dr6_bd_set,
    
    //exception input
    input               exc_set_rflag,
    input               exc_debug_start,
    input               exc_pf_read,
    input               exc_pf_write,
    input               exc_pf_code,
    input               exc_pf_check,
    input               exc_restore_esp,
    
    input       [31:0]  wr_esp_prev,
                                   
    //cr2 input
    input       [31:0]  tlb_code_pf_cr2,
    input       [31:0]  tlb_write_pf_cr2,
    input       [31:0]  tlb_read_pf_cr2,
    input       [31:0]  tlb_check_pf_cr2,
    
    //debug input
    input       [3:0]   wr_debug_code_reg,
    input       [3:0]   wr_debug_write_reg,
    input       [3:0]   wr_debug_read_reg,
    input               wr_debug_step_reg,
    input               wr_debug_task_reg,
                                   
    //write reg
    input               write_eax,
    input               write_regrm,
                                   
    //write reg options
    input               wr_dst_is_rm,
    input               wr_dst_is_reg,
    input               wr_dst_is_implicit_reg,
    input               wr_regrm_word,
    input               wr_regrm_dword,
    
    //write reg data
    input       [31:0]  result,
   
    //output
    output      [1:0]   cpl,
    
    output              protected_mode,
    output              v8086_mode,
    output              real_mode,
    
    output              io_allow_check_needed,
    
    output      [2:0]   debug_len0,
    output      [2:0]   debug_len1,
    output      [2:0]   debug_len2,
    output      [2:0]   debug_len3,
    
    //registers input
    
    input       [31:0]  eax_to_reg,
    input       [31:0]  ebx_to_reg,
    input       [31:0]  ecx_to_reg,
    input       [31:0]  edx_to_reg,
    input       [31:0]  esi_to_reg,
    input       [31:0]  edi_to_reg,
    input       [31:0]  ebp_to_reg,
    input       [31:0]  esp_to_reg,
    
    input               cr0_pe_to_reg,
    input               cr0_mp_to_reg,
    input               cr0_em_to_reg,
    input               cr0_ts_to_reg,
    input               cr0_ne_to_reg,
    input               cr0_wp_to_reg,
    input               cr0_am_to_reg,
    input               cr0_nw_to_reg,
    input               cr0_cd_to_reg,
    input               cr0_pg_to_reg,
    
    input       [31:0]  cr2_to_reg,
    input       [31:0]  cr3_to_reg,
    
    input               cflag_to_reg,
    input               pflag_to_reg,
    input               aflag_to_reg,
    input               zflag_to_reg,
    input               sflag_to_reg,
    input               oflag_to_reg,
    input               tflag_to_reg,
    input               iflag_to_reg,
    input               dflag_to_reg,
    input       [1:0]   iopl_to_reg,
    input               ntflag_to_reg,
    input               rflag_to_reg,
    input               vmflag_to_reg,
    input               acflag_to_reg,
    input               idflag_to_reg,
    
    input       [31:0]  gdtr_base_to_reg,
    input       [15:0]  gdtr_limit_to_reg,
    
    input       [31:0]  idtr_base_to_reg,
    input       [15:0]  idtr_limit_to_reg,
    
    input       [31:0]  dr0_to_reg,
    input       [31:0]  dr1_to_reg,
    input       [31:0]  dr2_to_reg,
    input       [31:0]  dr3_to_reg,
    input       [3:0]   dr6_breakpoints_to_reg,
    input               dr6_b12_to_reg,
    input               dr6_bd_to_reg,
    input               dr6_bs_to_reg,
    input               dr6_bt_to_reg,
    input       [31:0]  dr7_to_reg,
    
    input       [15:0]  es_to_reg,
    input       [15:0]  ds_to_reg,
    input       [15:0]  ss_to_reg,
    input       [15:0]  fs_to_reg,
    input       [15:0]  gs_to_reg,
    input       [15:0]  cs_to_reg,
    input       [15:0]  ldtr_to_reg,
    input       [15:0]  tr_to_reg,

    input       [63:0]  es_cache_to_reg,
    input       [63:0]  ds_cache_to_reg,
    input       [63:0]  ss_cache_to_reg,
    input       [63:0]  fs_cache_to_reg,
    input       [63:0]  gs_cache_to_reg,
    input       [63:0]  cs_cache_to_reg,
    input       [63:0]  ldtr_cache_to_reg,
    input       [63:0]  tr_cache_to_reg,

    input               es_cache_valid_to_reg,
    input               ds_cache_valid_to_reg,
    input               ss_cache_valid_to_reg,
    input               fs_cache_valid_to_reg,
    input               gs_cache_valid_to_reg,
    input               cs_cache_valid_to_reg,
    input               ldtr_cache_valid_to_reg,

    input       [1:0]   es_rpl_to_reg,
    input       [1:0]   ds_rpl_to_reg,
    input       [1:0]   ss_rpl_to_reg,
    input       [1:0]   fs_rpl_to_reg,
    input       [1:0]   gs_rpl_to_reg,
    input       [1:0]   cs_rpl_to_reg,
    input       [1:0]   ldtr_rpl_to_reg,
    input       [1:0]   tr_rpl_to_reg,
    
    //registers output
    output reg  [31:0]  eax,
    output reg  [31:0]  ebx,
    output reg  [31:0]  ecx,
    output reg  [31:0]  edx,
    output reg  [31:0]  esi,
    output reg  [31:0]  edi,
    output reg  [31:0]  ebp,
    output reg  [31:0]  esp,

    output reg          cr0_pe,
    output reg          cr0_mp,
    output reg          cr0_em,
    output reg          cr0_ts,
    output reg          cr0_ne,
    output reg          cr0_wp,
    output reg          cr0_am,
    output reg          cr0_nw,
    output reg          cr0_cd,
    output reg          cr0_pg,
    
    output reg  [31:0]  cr2,
    output reg  [31:0]  cr3,
    
    output reg          cflag,
    output reg          pflag,
    output reg          aflag,
    output reg          zflag,
    output reg          sflag,
    output reg          oflag,
    output reg          tflag,
    output reg          iflag,
    output reg          dflag,
    output reg  [1:0]   iopl,
    output reg          ntflag,
    output reg          rflag,
    output reg          vmflag,
    output reg          acflag,
    output reg          idflag,

    output reg  [31:0]  gdtr_base,
    output reg  [15:0]  gdtr_limit,
    
    output reg  [31:0]  idtr_base,
    output reg  [15:0]  idtr_limit,
    
    output reg  [31:0]  dr0,
    output reg  [31:0]  dr1,
    output reg  [31:0]  dr2,
    output reg  [31:0]  dr3,
    output reg  [3:0]   dr6_breakpoints,
    output reg          dr6_b12,
    output reg          dr6_bd,
    output reg          dr6_bs,
    output reg          dr6_bt,
    output reg  [31:0]  dr7,
    
    output reg  [15:0]  es,
    output reg  [15:0]  ds,
    output reg  [15:0]  ss,
    output reg  [15:0]  fs,
    output reg  [15:0]  gs,
    output reg  [15:0]  cs,
    output reg  [15:0]  ldtr,
    output reg  [15:0]  tr,

    output reg  [63:0]  es_cache,
    output reg  [63:0]  ds_cache,
    output reg  [63:0]  ss_cache,
    output reg  [63:0]  fs_cache,
    output reg  [63:0]  gs_cache,
    output reg  [63:0]  cs_cache,
    output reg  [63:0]  ldtr_cache,
    output reg  [63:0]  tr_cache,

    output reg          es_cache_valid,
    output reg          ds_cache_valid,
    output reg          ss_cache_valid,
    output reg          fs_cache_valid,
    output reg          gs_cache_valid,
    output reg          cs_cache_valid,
    output reg          ldtr_cache_valid,
    output reg          tr_cache_valid,

    output reg  [1:0]   es_rpl,
    output reg  [1:0]   ds_rpl,
    output reg  [1:0]   ss_rpl,
    output reg  [1:0]   fs_rpl,
    output reg  [1:0]   gs_rpl,
    output reg  [1:0]   cs_rpl,
    output reg  [1:0]   ldtr_rpl,
    output reg  [1:0]   tr_rpl
);

//------------------------------------------------------------------------------ misc output

assign cpl = cs_rpl;

assign protected_mode = cr0_pe && ~(vmflag);
assign v8086_mode     = cr0_pe && vmflag;
assign real_mode      = ~(cr0_pe);

assign debug_len0 =
    (dr7[19:18] == 2'b00)?  3'b111 :
    (dr7[19:18] == 2'b01)?  3'b110 :
    (dr7[19:18] == 2'b10)?  3'b000 :
                            3'b100;
assign debug_len1 =
    (dr7[23:22] == 2'b00)?  3'b111 :
    (dr7[23:22] == 2'b01)?  3'b110 :
    (dr7[23:22] == 2'b10)?  3'b000 :
                            3'b100;
assign debug_len2 =
    (dr7[27:26] == 2'b00)?  3'b111 :
    (dr7[27:26] == 2'b01)?  3'b110 :
    (dr7[27:26] == 2'b10)?  3'b000 :
                            3'b100;
assign debug_len3 =
    (dr7[31:30] == 2'b00)?  3'b111 :
    (dr7[31:30] == 2'b01)?  3'b110 :
    (dr7[31:30] == 2'b10)?  3'b000 :
                            3'b100;

assign io_allow_check_needed = cr0_pe && (vmflag || cpl > iopl);

//------------------------------------------------------------------------------ general registers value

wire [2:0]  w_index;
wire        w_write_regrm;
wire        w_operand_32bit;
wire        w_operand_16bit;

wire [31:0] eax_value;
wire [31:0] ebx_value;
wire [31:0] ecx_value;
wire [31:0] edx_value;
wire [31:0] ebp_value;
wire [31:0] esp_value;
wire [31:0] esi_value;
wire [31:0] edi_value;

assign w_index = (wr_dst_is_rm)?             wr_modregrm_rm :
                 (wr_dst_is_reg)?            wr_modregrm_reg :
                 (wr_dst_is_implicit_reg)?   wr_decoder[2:0] :
                                             3'd0; //write_eax
                                                
assign w_write_regrm = write_eax || (write_regrm && (wr_dst_is_rm || wr_dst_is_reg || wr_dst_is_implicit_reg));

assign w_operand_32bit = (wr_regrm_word)?   `FALSE :
                         (wr_regrm_dword)?  `TRUE :
                                            wr_operand_32bit;

assign w_operand_16bit = ~(w_operand_32bit);


assign eax_value =
    (wr_is_8bit && w_index == 3'd0)?        { eax[31:8],  result[7:0] } :
    (wr_is_8bit && w_index == 3'd4)?        { eax[31:16], result[7:0], eax[7:0] } :
    (w_operand_16bit && w_index == 3'd0)?   { eax[31:16], result[15:0] } :
    (w_operand_32bit && w_index == 3'd0)?   result :
                                            eax_to_reg;

assign ebx_value =
    (wr_is_8bit && w_index == 3'd3)?        { ebx[31:8],  result[7:0] } :
    (wr_is_8bit && w_index == 3'd7)?        { ebx[31:16], result[7:0], ebx[7:0] } :
    (w_operand_16bit && w_index == 3'd3)?   { ebx[31:16], result[15:0] } :
    (w_operand_32bit && w_index == 3'd3)?   result :
                                            ebx_to_reg;
assign ecx_value =
    (wr_is_8bit && w_index == 3'd1)?        { ecx[31:8],  result[7:0] } :
    (wr_is_8bit && w_index == 3'd5)?        { ecx[31:16], result[7:0], ecx[7:0] } :
    (w_operand_16bit && w_index == 3'd1)?   { ecx[31:16], result[15:0] } :
    (w_operand_32bit && w_index == 3'd1)?   result :
                                            ecx_to_reg;
assign edx_value =
    (wr_is_8bit && w_index == 3'd2)?        { edx[31:8],  result[7:0] } :
    (wr_is_8bit && w_index == 3'd6)?        { edx[31:16], result[7:0], edx[7:0] } :
    (w_operand_16bit && w_index == 3'd2)?   { edx[31:16], result[15:0] } :
    (w_operand_32bit && w_index == 3'd2)?   result :
                                            edx_to_reg;
assign esi_value =
    (~(wr_is_8bit) && w_operand_16bit && w_index == 3'd6)?  { esi[31:16], result[15:0] } :
    (~(wr_is_8bit) && w_operand_32bit && w_index == 3'd6)?  result :
                                                            esi_to_reg;
assign edi_value =
    (~(wr_is_8bit) && w_operand_16bit && w_index == 3'd7)?  { edi[31:16], result[15:0] } :
    (~(wr_is_8bit) && w_operand_32bit && w_index == 3'd7)?  result :
                                                            edi_to_reg;
assign ebp_value =
    (~(wr_is_8bit) && w_operand_16bit && w_index == 3'd5)?  { ebp[31:16], result[15:0] } :
    (~(wr_is_8bit) && w_operand_32bit && w_index == 3'd5)?  result :
                                                            ebp_to_reg; 
assign esp_value =
    (~(wr_is_8bit) && w_operand_16bit && w_index == 3'd4)?  { esp_to_reg[31:16], result[15:0] } : // possible mix: from result and esp_to_reg
    (~(wr_is_8bit) && w_operand_32bit && w_index == 3'd4)?  result :
                                                            esp_to_reg; 

//------------------------------------------------------------------------------ general registers


always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) eax <= `STARTUP_EAX; else if(w_write_regrm) eax <= eax_value;                                              else eax <= eax_to_reg; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) ebx <= `STARTUP_EBX; else if(w_write_regrm) ebx <= ebx_value;                                              else ebx <= ebx_to_reg; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) ecx <= `STARTUP_ECX; else if(w_write_regrm) ecx <= ecx_value;                                              else ecx <= ecx_to_reg; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) edx <= `STARTUP_EDX; else if(w_write_regrm) edx <= edx_value;                                              else edx <= edx_to_reg; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) esi <= `STARTUP_ESI; else if(w_write_regrm) esi <= esi_value;                                              else esi <= esi_to_reg; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) edi <= `STARTUP_EDI; else if(w_write_regrm) edi <= edi_value;                                              else edi <= edi_to_reg; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) ebp <= `STARTUP_EBP; else if(w_write_regrm) ebp <= ebp_value;                                              else ebp <= ebp_to_reg; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) esp <= `STARTUP_ESP; else if(w_write_regrm) esp <= esp_value; else if(exc_restore_esp) esp <= wr_esp_prev; else esp <= esp_to_reg; end

//------------------------------------------------------------------------------ control registers

always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) cr0_pe <= `STARTUP_CR0_PE; else cr0_pe <= cr0_pe_to_reg; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) cr0_mp <= `STARTUP_CR0_MP; else cr0_mp <= cr0_mp_to_reg; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) cr0_em <= `STARTUP_CR0_EM; else cr0_em <= cr0_em_to_reg; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) cr0_ts <= `STARTUP_CR0_TS; else cr0_ts <= cr0_ts_to_reg; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) cr0_ne <= `STARTUP_CR0_NE; else cr0_ne <= cr0_ne_to_reg; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) cr0_wp <= `STARTUP_CR0_WP; else cr0_wp <= cr0_wp_to_reg; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) cr0_am <= `STARTUP_CR0_AM; else cr0_am <= cr0_am_to_reg; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) cr0_nw <= `STARTUP_CR0_NW; else cr0_nw <= cr0_nw_to_reg; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) cr0_cd <= `STARTUP_CR0_CD; else cr0_cd <= cr0_cd_to_reg; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) cr0_pg <= `STARTUP_CR0_PG; else cr0_pg <= cr0_pg_to_reg; end

always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) cr3    <= `STARTUP_CR3;  else cr3    <= cr3_to_reg;    end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       cr2 <= `STARTUP_CR2;
    else if(exc_pf_write)   cr2 <= tlb_write_pf_cr2;
    else if(exc_pf_check)   cr2 <= tlb_check_pf_cr2;
    else if(exc_pf_read)    cr2 <= tlb_read_pf_cr2;
    else if(exc_pf_code)    cr2 <= tlb_code_pf_cr2;
    else                    cr2 <= cr2_to_reg;
end

//------------------------------------------------------------------------------ eflags

always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) cflag  <= `STARTUP_CFLAG;  else cflag  <= cflag_to_reg;  end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) pflag  <= `STARTUP_PFLAG;  else pflag  <= pflag_to_reg;  end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) aflag  <= `STARTUP_AFLAG;  else aflag  <= aflag_to_reg;  end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) zflag  <= `STARTUP_ZFLAG;  else zflag  <= zflag_to_reg;  end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) sflag  <= `STARTUP_SFLAG;  else sflag  <= sflag_to_reg;  end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) oflag  <= `STARTUP_OFLAG;  else oflag  <= oflag_to_reg;  end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) tflag  <= `STARTUP_TFLAG;  else tflag  <= tflag_to_reg;  end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) iflag  <= `STARTUP_IFLAG;  else iflag  <= iflag_to_reg;  end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) dflag  <= `STARTUP_DFLAG;  else dflag  <= dflag_to_reg;  end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) iopl   <= `STARTUP_IOPL;   else iopl   <= iopl_to_reg;   end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) ntflag <= `STARTUP_NTFLAG; else ntflag <= ntflag_to_reg; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) vmflag <= `STARTUP_VMFLAG; else vmflag <= vmflag_to_reg; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) acflag <= `STARTUP_ACFLAG; else acflag <= acflag_to_reg; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) idflag <= `STARTUP_IDFLAG; else idflag <= idflag_to_reg; end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       rflag <= `STARTUP_RFLAG;
    else if(wr_clear_rflag) rflag <= `FALSE;
    else if(exc_set_rflag)  rflag <= `TRUE;
    else                    rflag <= rflag_to_reg;
end

//------------------------------------------------------------------------------ gdtr, idtr

always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) gdtr_base  <= `STARTUP_GDTR_BASE;  else gdtr_base  <= gdtr_base_to_reg;  end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) gdtr_limit <= `STARTUP_GDTR_LIMIT; else gdtr_limit <= gdtr_limit_to_reg; end

always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) idtr_base  <= `STARTUP_IDTR_BASE;  else idtr_base  <= idtr_base_to_reg;  end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) idtr_limit <= `STARTUP_IDTR_LIMIT; else idtr_limit <= idtr_limit_to_reg; end


//------------------------------------------------------------------------------ debug registers



always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) dr0 <= `STARTUP_DR0; else dr0 <= dr0_to_reg; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) dr1 <= `STARTUP_DR1; else dr1 <= dr1_to_reg; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) dr2 <= `STARTUP_DR2; else dr2 <= dr2_to_reg; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) dr3 <= `STARTUP_DR3; else dr3 <= dr3_to_reg; end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           dr6_breakpoints <= `STARTUP_DR6_BREAKPOINTS;
    else if(exc_debug_start)    dr6_breakpoints <= wr_debug_read_reg | wr_debug_write_reg | wr_debug_code_reg;
    else                        dr6_breakpoints <= dr6_breakpoints_to_reg;
end

always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) dr6_b12 <= `STARTUP_DR6_B12; else if(exc_debug_start) dr6_b12 <= `FALSE;                         else dr6_b12 <= dr6_b12_to_reg; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) dr6_bd  <= `STARTUP_DR6_BD;  else if(dr6_bd_set)      dr6_bd  <= `TRUE;                          else dr6_bd  <= dr6_bd_to_reg;  end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) dr6_bs  <= `STARTUP_DR6_BS;  else if(exc_debug_start) dr6_bs <= wr_debug_step_reg;               else dr6_bs  <= dr6_bs_to_reg;  end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) dr6_bt  <= `STARTUP_DR6_BT;  else if(exc_debug_start) dr6_bt <= wr_debug_task_reg;               else dr6_bt  <= dr6_bt_to_reg;  end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) dr7     <= `STARTUP_DR7;     else if(exc_debug_start) dr7    <= { dr7[31:14], 1'b0, dr7[12:0] }; else dr7     <= dr7_to_reg;     end


//------------------------------------------------------------------------------ segment registers

wire [63:0] w_seg_cache;
wire [2:0]  wr_seg_index;

wire ds_invalidate;
wire es_invalidate;
wire fs_invalidate;
wire gs_invalidate;

assign wr_seg_index = glob_param_1[18:16];

assign w_seg_cache = (write_system_touch)?     glob_descriptor | 64'h0000010000000000 :
                     (write_system_busy_tss)?  glob_descriptor | 64'h0000020000000000 :
                                               glob_descriptor;

assign ds_invalidate = wr_validate_seg_regs && ds_cache[`DESC_BITS_DPL] < cpl && (ds_cache_valid == `FALSE || ds_cache[`DESC_BIT_SEG] == `FALSE || `DESC_IS_DATA(ds_cache) || `DESC_IS_CODE_NON_CONFORMING(ds_cache));
assign es_invalidate = wr_validate_seg_regs && es_cache[`DESC_BITS_DPL] < cpl && (es_cache_valid == `FALSE || es_cache[`DESC_BIT_SEG] == `FALSE || `DESC_IS_DATA(es_cache) || `DESC_IS_CODE_NON_CONFORMING(es_cache));
assign fs_invalidate = wr_validate_seg_regs && fs_cache[`DESC_BITS_DPL] < cpl && (fs_cache_valid == `FALSE || fs_cache[`DESC_BIT_SEG] == `FALSE || `DESC_IS_DATA(fs_cache) || `DESC_IS_CODE_NON_CONFORMING(fs_cache));
assign gs_invalidate = wr_validate_seg_regs && gs_cache[`DESC_BITS_DPL] < cpl && (gs_cache_valid == `FALSE || gs_cache[`DESC_BIT_SEG] == `FALSE || `DESC_IS_DATA(gs_cache) || `DESC_IS_CODE_NON_CONFORMING(gs_cache));

always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) es   <= `STARTUP_ES;   else if(es_invalidate) es <= 16'd0; else if(write_seg_sel && wr_seg_index == 3'd0) es   <= wr_seg_sel; else es   <= es_to_reg;   end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) ds   <= `STARTUP_DS;   else if(ds_invalidate) ds <= 16'd0; else if(write_seg_sel && wr_seg_index == 3'd3) ds   <= wr_seg_sel; else ds   <= ds_to_reg;   end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) ss   <= `STARTUP_SS;                                       else if(write_seg_sel && wr_seg_index == 3'd2) ss   <= wr_seg_sel; else ss   <= ss_to_reg;   end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) fs   <= `STARTUP_FS;   else if(fs_invalidate) fs <= 16'd0; else if(write_seg_sel && wr_seg_index == 3'd4) fs   <= wr_seg_sel; else fs   <= fs_to_reg;   end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) gs   <= `STARTUP_GS;   else if(gs_invalidate) gs <= 16'd0; else if(write_seg_sel && wr_seg_index == 3'd5) gs   <= wr_seg_sel; else gs   <= gs_to_reg;   end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) cs   <= `STARTUP_CS;                                       else if(write_seg_sel && wr_seg_index == 3'd1) cs   <= wr_seg_sel; else cs   <= cs_to_reg;   end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) ldtr <= `STARTUP_LDTR;                                     else if(write_seg_sel && wr_seg_index == 3'd6) ldtr <= wr_seg_sel; else ldtr <= ldtr_to_reg; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) tr   <= `STARTUP_TR;                                       else if(write_seg_sel && wr_seg_index == 3'd7) tr   <= wr_seg_sel; else tr   <= tr_to_reg;   end

always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) es_rpl   <= `STARTUP_ES_RPL;   else if(write_seg_rpl && wr_seg_index == 3'd0)                             es_rpl   <= wr_seg_rpl; else es_rpl   <= es_rpl_to_reg;   end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) ds_rpl   <= `STARTUP_DS_RPL;   else if(write_seg_rpl && wr_seg_index == 3'd3)                             ds_rpl   <= wr_seg_rpl; else ds_rpl   <= ds_rpl_to_reg;   end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) ss_rpl   <= `STARTUP_SS_RPL;   else if(write_seg_rpl && wr_seg_index == 3'd2)                             ss_rpl   <= wr_seg_rpl; else ss_rpl   <= ss_rpl_to_reg;   end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) fs_rpl   <= `STARTUP_FS_RPL;   else if(write_seg_rpl && wr_seg_index == 3'd4)                             fs_rpl   <= wr_seg_rpl; else fs_rpl   <= fs_rpl_to_reg;   end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) gs_rpl   <= `STARTUP_GS_RPL;   else if(write_seg_rpl && wr_seg_index == 3'd5)                             gs_rpl   <= wr_seg_rpl; else gs_rpl   <= gs_rpl_to_reg;   end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) cs_rpl   <= `STARTUP_CS_RPL;   else if(write_seg_rpl && wr_seg_index == 3'd1)                             cs_rpl   <= wr_seg_rpl; else cs_rpl   <= cs_rpl_to_reg;   end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) ldtr_rpl <= `STARTUP_LDTR_RPL; else if(write_seg_rpl && wr_seg_index == 3'd6 && w_seg_cache[`DESC_BIT_P]) ldtr_rpl <= wr_seg_rpl; else ldtr_rpl <= ldtr_rpl_to_reg; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) tr_rpl   <= `STARTUP_TR_RPL;   else if(write_seg_rpl && wr_seg_index == 3'd7)                             tr_rpl   <= wr_seg_rpl; else tr_rpl   <= tr_rpl_to_reg;   end

`define ALWAYS   always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0)

// G=0, D/B=0, P=1, Data, Accessed, R/W
`define DEFAULT_SEG_CACHE       { 8'd0,  8'd0, 1'b1, 2'b0, 1'b1, 1'b0, 1'b0, 2'b11, 8'd0,  16'd0, 16'hFFFF }
//valid, G=0, D/B=0, P=1, Code, Accessed, R/X
`define DEFAULT_CS_CACHE        { 8'hFF, 8'd0, 1'b1, 2'b0, 1'b1, 1'b0, 1'b0, 2'b11, 8'hFF, 16'd0, 16'hFFFF }
// G=0, D/B=0, P=1, System, LDT segment
`define DEFAULT_LDTR_CACHE      { 8'd0,  8'd0, 1'b1, 2'b0, 1'b0,              4'd2, 8'd0,  16'd0, 16'hFFFF }
// G=0, D/B=0, P=1, System, TSS Busy 386
`define DEFAULT_TR_CACHE        { 8'd0,  8'd0, 1'b1, 2'b0, 1'b0,             4'd11, 8'd0,  16'd0, 16'hFFFF }

`ALWAYS es_cache   <= `STARTUP_ES_CACHE;   else if(write_seg_cache && wr_seg_index == 3'd0)                             es_cache   <= (es_cache   & wr_seg_cache_mask) | w_seg_cache; else es_cache   <= es_cache_to_reg;   end
`ALWAYS ds_cache   <= `STARTUP_DS_CACHE;   else if(write_seg_cache && wr_seg_index == 3'd3)                             ds_cache   <= (ds_cache   & wr_seg_cache_mask) | w_seg_cache; else ds_cache   <= ds_cache_to_reg;   end
`ALWAYS ss_cache   <= `STARTUP_SS_CACHE;   else if(write_seg_cache && wr_seg_index == 3'd2)                             ss_cache   <= (ss_cache   & wr_seg_cache_mask) | w_seg_cache; else ss_cache   <= ss_cache_to_reg;   end
`ALWAYS fs_cache   <= `STARTUP_FS_CACHE;   else if(write_seg_cache && wr_seg_index == 3'd4)                             fs_cache   <= (fs_cache   & wr_seg_cache_mask) | w_seg_cache; else fs_cache   <= fs_cache_to_reg;   end
`ALWAYS gs_cache   <= `STARTUP_GS_CACHE;   else if(write_seg_cache && wr_seg_index == 3'd5)                             gs_cache   <= (gs_cache   & wr_seg_cache_mask) | w_seg_cache; else gs_cache   <= gs_cache_to_reg;   end
`ALWAYS cs_cache   <= `STARTUP_CS_CACHE;   else if(write_seg_cache && wr_seg_index == 3'd1)                             cs_cache   <= (cs_cache   & wr_seg_cache_mask) | w_seg_cache; else cs_cache   <= cs_cache_to_reg;   end
`ALWAYS ldtr_cache <= `STARTUP_LDTR_CACHE; else if(write_seg_cache && wr_seg_index == 3'd6 && w_seg_cache[`DESC_BIT_P]) ldtr_cache <= (ldtr_cache & wr_seg_cache_mask) | w_seg_cache; else ldtr_cache <= ldtr_cache_to_reg; end
`ALWAYS tr_cache   <= `STARTUP_TR_CACHE;   else if(write_seg_cache && wr_seg_index == 3'd7)                             tr_cache   <= (tr_cache   & wr_seg_cache_mask) | w_seg_cache; else tr_cache   <= tr_cache_to_reg;   end

`ALWAYS es_cache_valid   <= `STARTUP_ES_VALID; else if(es_invalidate) es_cache_valid <= 1'b0; else if(write_seg_cache_valid && wr_seg_index == 3'd0) es_cache_valid   <= wr_seg_cache_valid; else es_cache_valid   <= es_cache_valid_to_reg;   end
`ALWAYS ds_cache_valid   <= `STARTUP_DS_VALID; else if(ds_invalidate) ds_cache_valid <= 1'b0; else if(write_seg_cache_valid && wr_seg_index == 3'd3) ds_cache_valid   <= wr_seg_cache_valid; else ds_cache_valid   <= ds_cache_valid_to_reg;   end
`ALWAYS ss_cache_valid   <= `STARTUP_SS_VALID;                                                else if(write_seg_cache_valid && wr_seg_index == 3'd2) ss_cache_valid   <= wr_seg_cache_valid; else ss_cache_valid   <= ss_cache_valid_to_reg;   end
`ALWAYS fs_cache_valid   <= `STARTUP_FS_VALID; else if(fs_invalidate) fs_cache_valid <= 1'b0; else if(write_seg_cache_valid && wr_seg_index == 3'd4) fs_cache_valid   <= wr_seg_cache_valid; else fs_cache_valid   <= fs_cache_valid_to_reg;   end
`ALWAYS gs_cache_valid   <= `STARTUP_GS_VALID; else if(gs_invalidate) gs_cache_valid <= 1'b0; else if(write_seg_cache_valid && wr_seg_index == 3'd5) gs_cache_valid   <= wr_seg_cache_valid; else gs_cache_valid   <= gs_cache_valid_to_reg;   end
`ALWAYS cs_cache_valid   <= `STARTUP_CS_VALID;                                                else if(write_seg_cache_valid && wr_seg_index == 3'd1) cs_cache_valid   <= wr_seg_cache_valid; else cs_cache_valid   <= cs_cache_valid_to_reg;   end
`ALWAYS ldtr_cache_valid <= `STARTUP_LDTR_VALID;                                              else if(write_seg_cache_valid && wr_seg_index == 3'd6) ldtr_cache_valid <= wr_seg_cache_valid; else ldtr_cache_valid <= ldtr_cache_valid_to_reg; end
`ALWAYS tr_cache_valid   <= `STARTUP_TR_VALID;                                                else if(write_seg_cache_valid && wr_seg_index == 3'd7) tr_cache_valid   <= wr_seg_cache_valid; end

//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0, glob_param_1[31:19], glob_param_1[15:0], wr_decoder[15:3], 1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------

endmodule
