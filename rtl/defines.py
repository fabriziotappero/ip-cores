# -*- coding: utf-8 -*-
"""
    defines.py
    ==========

    Constants and Enums
    
    :copyright: Copyright (c) 2010 Jian Luo
    :author-email: jian.luo.cn(at_)gmail.com
    :license: LGPL, see LICENSE for details
    :revision: $Id: defines.py 6 2010-11-21 23:18:44Z rockee $
"""

from myhdl import enum, instances

DEBUG = True
DEBUG_VERBOSE = 1

CFG_IMEM_SIZE = 16
CFG_IMEM_WIDTH = 32
CFG_DMEM_WIDTH = 32
CFG_DMEM_SIZE = 32
CFG_GPRF_SIZE = 5
CFG_REG_FWD_WRB = True

OPG_ADD = 0b00      # 0b00ixxx add, sub, cmp
OPG_CMP = 0b000101  # 0b000101 cmp
OPG_MUL = 0b01000   # 0b01i000 integer multiply
OPG_BSF = 0b01001   # 0b01i001 barrel shift
OPG_DIV = 0b01010   # 0b010010 integer divide
OPG_FSL = 0b01011   # 0b01d011 fsl command
OPG_FLT = 0b01110   # 0b010110 float
OPG_LOG = 0b100     # 0b10i0xx logic and pattern compare
OPG_IMM = 0b101100  # 0b101100 imm
OPG_EXT = 0b100100  # 0b100100 shift right, sext, cache
OPG_SPR = 0b100101  # 0b100101 move from/to special register
OPG_RET = 0b101101  # 0b101101 return
OPG_BRU = 0b10110   # 0b10i110 unconditional branch
OPG_BCC = 0b10111   # 0b10i111 conditional branch
OPG_MEM = 0b11      # 0b11ixxx load, store


alu_operation = enum('ALU_ADD', 'ALU_OR', 'ALU_AND', 'ALU_XOR',
                     'ALU_SHIFT', 'ALU_SEXT8', 'ALU_SEXT16', #)
                     'ALU_MUL', 'ALU_BS')
src_type_a = enum('REGA', 'NOT_REGA', 'PC', 'REGA_ZERO')
src_type_b = enum('REGB', 'NOT_REGB', 'IMM', 'NOT_IMM')
carry_type = enum('C_ZERO', 'C_ONE', 'ALU', 'ARITH')
branch_condition = enum('BEQ', 'BNE', 'BLT', 'BLE', 'BGT', 'BGE', 
                        'BRU', 'NOP')
transfer_size_type = enum('WORD', 'HALFWORD', 'BYTE')

### EOF ###
# vim:smarttab:sts=4:ts=4:sw=4:et:ai:tw=80:

