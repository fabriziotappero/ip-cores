# -*- coding: utf-8 -*-
"""
    memory.py
    =========

    Memory Stage
    
    :copyright: Copyright (c) 2010 Jian Luo
    :author-email: jian.luo.cn(at_)gmail.com
    :license: LGPL, see LICENSE for details
    :revision: $Id: memory.py 5 2010-11-21 10:59:30Z rockee $
"""

from myhdl import *
from defines import *
from functions import *

def MemUnit(
        # Inputs
        clock,
        reset,
        enable,
        ex_alu_result,
        ex_reg_d,
        ex_reg_write,
        ex_branch,
        ex_dat_d,
        ex_mem_read,
        ex_mem_write,
        ex_program_counter,
        ex_transfer_size,
        # Outputs
        mm_alu_result,
        mm_mem_read,
        mm_reg_d,
        mm_reg_write,
        mm_transfer_size,
        dmem_data_out,
        dmem_sel_out,
        dmem_we_out,
        dmem_addr_out,
        dmem_ena_out,
        ):
    """
    """
    mem_result = Signal(intbv(0)[CFG_DMEM_WIDTH:])

    mm_comb_alu_result = Signal(intbv(0)[CFG_DMEM_WIDTH:])
    mm_comb_mem_read = Signal(False)
    mm_comb_reg_d = Signal(intbv(0)[5:])
    mm_comb_reg_write = Signal(False)
    mm_comb_transfer_size = Signal(transfer_size_type.WORD)

    @always_comb
    def comb():
        # Local Variables
        alu_result = intbv(0)[CFG_DMEM_WIDTH:]
        
        if ex_branch:
            alu_result[:] = ex_program_counter
        else:
            alu_result[:] = ex_alu_result

        # TODO: forwarding
        mem_result.next = ex_dat_d

        # pipelining
        mm_comb_alu_result.next = alu_result
        mm_comb_mem_read.next = ex_mem_read
        mm_comb_reg_d.next = ex_reg_d
        mm_comb_reg_write.next = ex_reg_write
        mm_comb_transfer_size.next = ex_transfer_size

    @always_comb
    def control_dmem():
        dmem_data_out.next = mem_result
        dmem_sel_out.next = decode_mem_store(ex_alu_result[2:],ex_transfer_size)
        dmem_we_out.next = ex_mem_write
        dmem_addr_out.next = ex_alu_result[CFG_DMEM_SIZE:]
        dmem_ena_out.next = ex_mem_write or ex_mem_read

    @always(clock.posedge)
    def seq():
        if reset:
            mm_alu_result.next = 0
            mm_mem_read.next = False
            mm_reg_d.next = 0
            mm_reg_write.next = False
            mm_transfer_size.next = transfer_size_type.WORD
        elif enable:
            mm_alu_result.next = mm_comb_alu_result
            mm_mem_read.next = mm_comb_mem_read
            mm_reg_d.next = mm_comb_reg_d
            mm_reg_write.next = mm_comb_reg_write
            mm_transfer_size.next = mm_comb_transfer_size
        #if dmem_ena_out:
            #if dmem_we_out:
                #print 'write {0:b} {1:x} <- {2:x}'.format(
                #int(dmem_sel_out),
                #int(dmem_addr_out),
                #int(dmem_data_out))
            #else:
                #print 'read {0:b} {1:x}'.format(
                #int(dmem_sel_out),
                #int(dmem_addr_out),)


    return instances()
        
if __name__ == '__main__':
    clock = Signal(False)
    reset = Signal(False)
    enable = Signal(False)

    ex_alu_result = Signal(intbv(0)[32:])
    ex_reg_d = Signal(intbv(0)[5:])
    ex_reg_write = Signal(False)
    ex_branch = Signal(False)
    ex_dat_d = Signal(intbv(0)[32:])
    ex_mem_read = Signal(False)
    ex_mem_write = Signal(False)
    ex_program_counter = Signal(intbv(0)[CFG_IMEM_SIZE:])
    ex_transfer_size = Signal(transfer_size_type.WORD)
    mm_alu_result = Signal(intbv(0)[CFG_DMEM_WIDTH:])
    mm_mem_read = Signal(False)
    mm_reg_d = Signal(intbv(0)[5:])
    mm_reg_write = Signal(False)
    mm_transfer_size = Signal(transfer_size_type.WORD)
    dmem_data_out = Signal(intbv(0)[32:])
    dmem_sel_out = Signal(intbv(0)[4:])
    dmem_we_out = Signal(False)
    dmem_addr_out = Signal(intbv(0)[CFG_DMEM_SIZE:])
    dmem_ena_out = Signal(False)

    args = [
        MemUnit,
        # Inputs
        clock,
        reset,
        enable,
        ex_alu_result,
        ex_reg_d,
        ex_reg_write,
        ex_branch,
        ex_dat_d,
        ex_mem_read,
        ex_mem_write,
        ex_program_counter,
        ex_transfer_size,
        # Outputs
        mm_alu_result,
        mm_mem_read,
        mm_reg_d,
        mm_reg_write,
        mm_transfer_size,
        dmem_data_out,
        dmem_sel_out,
        dmem_we_out,
        dmem_addr_out,
        dmem_ena_out,
    ]
    toVHDL(*args)
    toVerilog(*args)

### EOF ###
# vim:smarttab:sts=4:ts=4:sw=4:et:ai:tw=80:

