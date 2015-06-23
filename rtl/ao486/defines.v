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


`define TRUE    1'b1
`define FALSE   1'b0

//------------------------------------------------------------------------------

//divide by zero
`define EXCEPTION_DE        8'd0
//debug
`define EXCEPTION_DB        8'd1
//breakpoint
`define EXCEPTION_BP        8'd3
//overflow
`define EXCEPTION_OF        8'd4
//bounds
`define EXCEPTION_BR        8'd5
`define EXCEPTION_UD        8'd6
`define EXCEPTION_NM        8'd7
`define EXCEPTION_DF        8'd8
`define EXCEPTION_TS        8'd10
`define EXCEPTION_NP        8'd11
`define EXCEPTION_SS        8'd12
`define EXCEPTION_GP        8'd13
`define EXCEPTION_PF        8'd14
`define EXCEPTION_AC        8'd17
`define EXCEPTION_MC        8'd18

//------------------------------------------------------------------------------

`define PREFETCH_GP_FAULT   4'd15
`define PREFETCH_PF_FAULT   4'd14
`define PREFETCH_MIN_FAULT  4'd9

//------------------------------------------------------------------------------

`define CMD_NULL            7'd0

`define CMDEX_NULL          4'd0

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

`define CPUID_MODEL_FAMILY_STEPPING     32'h0000045B

`define MC_PARAM_1_FLAG_NO_WRITE                13'd1
`define MC_PARAM_1_FLAG_NO_WRITE_BIT            19
// no write and cpl from param 3
`define MC_PARAM_1_FLAG_CPL_FROM_PARAM_3        13'd3
`define MC_PARAM_1_FLAG_CPL_FROM_PARAM_3_BIT    20
`define MC_PARAM_1_FLAG_NP_NOT_SS               13'd7
`define MC_PARAM_1_FLAG_NP_NOT_SS_BIT           21

`define EFLAGS_BIT_VM       17

`define DESC_BIT_G          55
`define DESC_BIT_D_B        54
`define DESC_BIT_P          47
`define DESC_BIT_SEG        44
`define DESC_BITS_TYPE      43:40
`define DESC_BITS_DPL       46:45
`define DESC_BIT_TYPE_BIT_0 40

`define DESC_IS_CODE(val)                   val[43]
`define DESC_IS_DATA(val)                   ~(val[43])
`define DESC_IS_DATA_RO(val)                (~val[43] && ~val[41])
`define DESC_IS_DATA_RW(val)                (~val[43] && val[41])
`define DESC_IS_CODE_EO(val)                (val[43] && ~val[41])
`define DESC_IS_CODE_NON_CONFORMING(val)    (val[43] && ~val[42])
`define DESC_IS_NOT_ACCESSED(val)           ~(val[40])
`define DESC_IS_ACCESSED(val)               val[40]
`define DESC_IS_CODE_CONFORMING(val)        (val[43] && val[42])

`define SELECTOR_BITS_RPL   1:0
`define SELECTOR_BIT_TI     2
`define SELECTOR_FOR_CODE(val)              { val[15:2], 2'b00 }

`define DR7_BIT_GD      13

`define SEGMENT_ES          3'd0
`define SEGMENT_CS          3'd1
`define SEGMENT_SS          3'd2
`define SEGMENT_DS          3'd3
`define SEGMENT_FS          3'd4
`define SEGMENT_GS          3'd5
`define SEGMENT_LDT         3'd6
`define SEGMENT_TR          3'd7

`define DESC_TSS_AVAIL_386          4'h9
`define DESC_TSS_BUSY_386           4'hB
`define DESC_TSS_AVAIL_286          4'h1
`define DESC_TSS_BUSY_286           4'h3
`define DESC_INTERRUPT_GATE_386     4'hE
`define DESC_INTERRUPT_GATE_286     4'h6
`define DESC_TRAP_GATE_386          4'hF
`define DESC_TRAP_GATE_286          4'h7
`define DESC_CALL_GATE_386          4'hC
`define DESC_CALL_GATE_286          4'h4
`define DESC_LDT                    4'h2
`define DESC_TASK_GATE              4'h5

`define DESC_MASK_G         64'h0080000000000000
`define DESC_MASK_D_B       64'h0040000000000000
`define DESC_MASK_L         64'h0020000000000000
`define DESC_MASK_AVL       64'h0010000000000000
`define DESC_MASK_LIMIT     64'h000F00000000FFFF
`define DESC_MASK_P         64'h0000800000000000
`define DESC_MASK_DPL       64'h0000600000000000
`define DESC_MASK_SEG       64'h0000100000000000
`define DESC_MASK_TYPE      64'h00000F0000000000
`define DESC_MASK_DATA_RWA  64'h0000030000000000

`define MUTEX_EAX_BIT       0
`define MUTEX_ECX_BIT       1
`define MUTEX_EDX_BIT       2
`define MUTEX_EBX_BIT       3
`define MUTEX_ESP_BIT       4
`define MUTEX_EBP_BIT       5
`define MUTEX_ESI_BIT       6
`define MUTEX_EDI_BIT       7
`define MUTEX_EFLAGS_BIT    8
`define MUTEX_MEMORY_BIT    9
`define MUTEX_ACTIVE_BIT    10
`define MUTEX_IO_BIT        11

`define ARITH_VALID 4'd8

`define ARITH_ADD   4'd0
`define ARITH_OR    4'd1
`define ARITH_ADC   4'd2
`define ARITH_SBB   4'd3
`define ARITH_AND   4'd4
`define ARITH_SUB   4'd5
`define ARITH_XOR   4'd6
`define ARITH_CMP   4'd7

//------------------------------------------------------------------------------

`include "startup_default.v"

//------------------------------------------------------------------------------

`include "autogen/defines.v"

//------------------------------------------------------------------------------
