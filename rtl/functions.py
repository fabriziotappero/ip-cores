# -*- coding: utf-8 -*-
"""
    functions.py
    ============

    Functions
    
    :copyright: Copyright (c) 2010 Jian Luo
    :author-email: jian.luo.cn(at_)gmail.com
    :license: LGPL, see LICENSE for details
    :revision: $Id: functions.py 5 2010-11-21 10:59:30Z rockee $
"""

from myhdl import *
from defines import *

def align_mem_load(data, size, address):
    """
    Aligns the memory load operation (Big endian decoding)
    """
    result = intbv(0)[32:]

    if size == transfer_size_type.BYTE:
        if address[1] == 0:
            if address[0] == 0:
                result[:] = data[32:24]
            else:
                result[:] = data[24:16]
        else:
            if address[0] == 0:
                result[:] = data[16:8]
            else:
                result[:] = data[8:]
    elif size == transfer_size_type.HALFWORD:
        if address[1] == 0:
            result[:] = data[32:16]
        else:
            result[:] = data[16:]
    else:
        result[:] = data

    return result

def decode_mem_store(address, size):
    result = intbv(0)[4:]

    if size == transfer_size_type.BYTE:
        if address[1] == 0:
            if address[0] == 0:
                result[:] = 0b1000
            else:
                result[:] = 0b0100
        else:
            if address[0] == 0:
                result[:] = 0b0010
            else:
                result[:] = 0b0001
    elif size == transfer_size_type.HALFWORD:
        if address[1] == 0:
            result[:] = 0b1100
        else:
            result[:] = 0b0011
    else:
        result[:] = 0b1111

    #if size == transfer_size_type.BYTE:
        #if address[1] == 0:
            #if address[0] == 0:
                #result[:] = 0b0001
            #else:
                #result[:] = 0b0010
        #else:
            #if address[0] == 0:
                #result[:] = 0b0100
            #else:
                #result[:] = 0b1000
    #elif size == transfer_size_type.HALFWORD:
        #if address[1] == 0:
            #result[:] = 0b0011
        #else:
            #result[:] = 0b1100
    #else:
        #result[:] = 0b1111

    return result

def align_mem_store(data, size):
    result = intbv(0)[32:]
    if size == transfer_size_type.BYTE:
        result[:] = concat(data[8:], data[8:], data[8:], data[8:])
    elif size == transfer_size_type.HALFWORD:
        result[:] = concat(data[16:], data[16:])
    else:
        result[:] = data
    return result
        

def forward_condition(reg_write, reg_a, reg_d):
    result = reg_write and (reg_a == reg_d)
    return result

def select_register_data(reg_dat, reg_x, wb_dat, write):
    tmp = intbv(0)[CFG_DMEM_WIDTH:]
    if reg_x == 0:
        tmp[:] = 0
    elif write:
        tmp[:] = wb_dat
    else:
        tmp[:] = reg_dat
    return tmp

def add(a, b, ci):
    aa = intbv(0)[CFG_DMEM_WIDTH+2:]
    bb = intbv(0)[CFG_DMEM_WIDTH+2:]
    cc = intbv(0)[CFG_DMEM_WIDTH+2:]
    result = intbv(0)[CFG_DMEM_WIDTH+1:]

    aa[:] = concat(False, a, True)
    bb[:] = concat(False, b, ci)
    cc[:] = aa.signed() + bb.signed()
    
    result[:] = cc[CFG_DMEM_WIDTH+2:1]
    return result

def repeat(input, times):
    result = intbv(0)[times:]
    for i in range(times):
        result[i] = input
    return result

def bit_reverse(input, width):
    result = intbv(0)[width:]
    for i in range(width):
        result[width-1-i] = input[i]
    return result

# XXX: Verilog don't allow veriable in slice,
#      the workaround is to write 2 function instead, but that's ugly :-(
def sign_extend(value, fill, from_size=16, to_size=32):
    tmp = intbv(0)[to_size:]
    size = to_size-from_size
    for i in range(size):
        tmp[to_size-1-i] = fill
    tmp[from_size:] = value[from_size:]
    return tmp

def sign_extend8(value, fill):
    tmp = intbv(0)[CFG_DMEM_WIDTH:]
    size = CFG_DMEM_WIDTH-8
    for i in range(size):
        tmp[CFG_DMEM_WIDTH-1-i] = fill
    tmp[8:] = value[8:]
    return tmp

def sign_extend16(value, fill):
    tmp = intbv(0)[CFG_DMEM_WIDTH:]
    size = CFG_DMEM_WIDTH-16
    for i in range(size):
        tmp[CFG_DMEM_WIDTH-1-i] = fill
    tmp[16:] = value[16:]
    return tmp

#def select_register_data(reg_dat, reg, wb_dat, write)
    
### EOF ###
# vim:smarttab:sts=4:ts=4:sw=4:et:ai:tw=80:

