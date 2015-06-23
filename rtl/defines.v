/*
 * This file is subject to the terms and conditions of the BSD License. See
 * the file "LICENSE" in the main directory of this archive for more details.
 *
 * Copyright (C) 2014 Aleksander Osman
 */

//------------------------------------------------------------------------------

`define TRUE        1'b1
`define FALSE       1'b0

//------------------------------------------------------------------------------

`define CMD_null                    7'd0

`define CMD_3arg_add                7'd1
`define CMD_3arg_addu               7'd2
`define CMD_3arg_and                7'd3
`define CMD_3arg_nor                7'd4
`define CMD_3arg_or                 7'd5
`define CMD_3arg_slt                7'd6
`define CMD_3arg_sltu               7'd7
`define CMD_3arg_sub                7'd8
`define CMD_3arg_subu               7'd9
`define CMD_3arg_xor                7'd10
`define CMD_3arg_sllv               7'd11
`define CMD_3arg_srav               7'd12
`define CMD_3arg_srlv               7'd13
`define CMD_sll                     7'd14
`define CMD_sra                     7'd15
`define CMD_srl                     7'd16
`define CMD_addi                    7'd17
`define CMD_addiu                   7'd18
`define CMD_andi                    7'd19
`define CMD_ori                     7'd20
`define CMD_slti                    7'd21
`define CMD_sltiu                   7'd22
`define CMD_xori                    7'd23
`define CMD_muldiv_mfhi             7'd24
`define CMD_muldiv_mflo             7'd25
`define CMD_muldiv_mthi             7'd26
`define CMD_muldiv_mtlo             7'd27
`define CMD_muldiv_mult             7'd28
`define CMD_muldiv_multu            7'd29
`define CMD_muldiv_div              7'd30
`define CMD_muldiv_divu             7'd31
`define CMD_lui                     7'd32
`define CMD_break                   7'd33
`define CMD_syscall                 7'd34
`define CMD_mtc0                    7'd35
`define CMD_mfc0                    7'd36
`define CMD_cfc1_detect             7'd37
`define CMD_cp0_rfe                 7'd38
`define CMD_cp0_tlbp                7'd39
`define CMD_cp0_tlbr                7'd40
`define CMD_cp0_tlbwi               7'd41
`define CMD_cp0_tlbwr               7'd42
`define CMD_lb                      7'd43
`define CMD_lbu                     7'd44
`define CMD_lh                      7'd45
`define CMD_lhu                     7'd46
`define CMD_lw                      7'd47
`define CMD_lwl                     7'd48
`define CMD_lwr                     7'd49
`define CMD_sb                      7'd50
`define CMD_sh                      7'd51
`define CMD_sw                      7'd52
`define CMD_swl                     7'd53
`define CMD_swr                     7'd54
`define CMD_beq                     7'd55
`define CMD_bne                     7'd56
`define CMD_bgez                    7'd57
`define CMD_bgtz                    7'd58
`define CMD_blez                    7'd59
`define CMD_bltz                    7'd60
`define CMD_jr                      7'd61
`define CMD_bgezal                  7'd62
`define CMD_bltzal                  7'd63
`define CMD_jalr                    7'd64
`define CMD_jal                     7'd65
`define CMD_j                       7'd66
`define CMD_cp0_bc0f                7'd67
`define CMD_cp0_bc0t                7'd68
`define CMD_cp0_bc0_ign             7'd69

`define CMD_exc_coproc_unusable     7'd70
`define CMD_exc_reserved_instr      7'd71
`define CMD_exc_int_overflow        7'd72
`define CMD_exc_load_addr_err       7'd73
`define CMD_exc_store_addr_err      7'd74
`define CMD_exc_load_tlb            7'd75
`define CMD_exc_store_tlb           7'd76
`define CMD_exc_tlb_load_miss       7'd77
`define CMD_exc_tlb_store_miss      7'd78
`define CMD_exc_tlb_modif           7'd79

//------------------------------------------------------------------------------
