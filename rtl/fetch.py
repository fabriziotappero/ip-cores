# -*- coding: utf-8 -*-
"""
    fetch.py
    ========

    Fetch Unit
    
    :copyright: Copyright (c) 2010 Jian Luo
    :author-email: jian.luo.cn(at_)gmail.com
    :license: LGPL, see LICENSE for details
    :revision: $Id: fetch.py 6 2010-11-21 23:18:44Z rockee $
"""

from myhdl import *
from defines import *
from functions import *

def FetchUnit(
        clock,
        reset,
        enable,
        of_hazard,
        ex_alu_result,
        ex_branch,
        if_program_counter,
        imem_addr_out,
        imem_ena_out,
        ):
    """
    """
    MAX_IMEM_ADDR = 2**CFG_IMEM_SIZE
    if_comb_r_program_counter = Signal(intbv(0)[CFG_IMEM_SIZE:])
    if_r_program_counter = Signal(intbv(0)[CFG_IMEM_SIZE:])

    @always_comb
    def comb():
        program_counter = intbv(0)[CFG_IMEM_SIZE:]
        if reset:
            program_counter[:] = 0
        elif of_hazard:
            program_counter[:] = if_r_program_counter
        elif ex_branch:
            program_counter[:] = ex_alu_result[CFG_IMEM_SIZE:]
        else:
            #program_counter[:] = ((if_r_program_counter[CFG_IMEM_SIZE:2]+1)
                                    #<< 2) % MAX_IMEM_ADDR
            program_counter[:] = (if_r_program_counter+4) % MAX_IMEM_ADDR
        if_comb_r_program_counter.next = program_counter
        #if ex_branch:
            #program_counter[:] = ex_alu_result[CFG_IMEM_SIZE:]
        #else:
            #program_counter[:] = if_r_program_counter
            ###program_counter[:] = ((if_r_program_counter[CFG_IMEM_SIZE:2]+1)
                                    ###<< 2) % MAX_IMEM_ADDR
            ##program_counter[:] = (if_r_program_counter+4) % MAX_IMEM_ADDR
        #if_program_counter.next = program_counter
        #imem_addr_out.next = program_counter
        #if of_hazard:
            #if_comb_r_program_counter.next = program_counter
        #else:
            #if_comb_r_program_counter.next = (program_counter+4) % MAX_IMEM_ADDR

    @always(clock.posedge)
    def seq():
        if reset:
            if_r_program_counter.next = 0
        elif enable:
            if_r_program_counter.next = if_comb_r_program_counter

    @always_comb
    def regout():
        imem_ena_out.next = enable
        imem_addr_out.next = if_comb_r_program_counter
        #if __debug__:
            #imem_addr_out.next = if_r_program_counter
            
        if_program_counter.next = if_r_program_counter

    return instances()

if __name__ == '__main__':
    clock = Signal(False)
    reset = Signal(False)
    enable = Signal(False)
    imem_addr_out = Signal(intbv(0)[CFG_IMEM_SIZE:])
    imem_ena_out = Signal(False)
    if_program_counter = Signal(intbv(0)[CFG_IMEM_SIZE:])
    of_hazard = Signal(False)
    ex_alu_result = Signal(intbv(0)[32:])
    ex_branch = Signal(False)
    
    args = [
        FetchUnit,
        clock,
        reset,
        enable,
        of_hazard,
        ex_alu_result,
        ex_branch,
        if_program_counter,
        imem_addr_out,
        imem_ena_out,
    ]
    toVHDL(*args)
    toVerilog(*args)

### EOF ###
# vim:smarttab:sts=4:ts=4:sw=4:et:ai:tw=80:

