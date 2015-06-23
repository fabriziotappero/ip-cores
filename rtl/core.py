# -*- coding: utf-8 -*-
"""
    core.py
    =======

    MyBlaze Core, top level entity
    
    :copyright: Copyright (c) 2010 Jian Luo
    :author-email: jian.luo.cn(at_)gmail.com
    :license: LGPL, see LICENSE for details
    :revision: $Id: core.py 6 2010-11-21 23:18:44Z rockee $
"""

from myhdl import *
from defines import *
from functions import *

from fetch import *
from decoder import *
from execute import *
from memory import *

def MyBlazeCore(
        clock,
        reset,
        dmem_ena_in,

        dmem_data_in,
        dmem_data_out,
        dmem_sel_out,
        dmem_we_out,
        dmem_addr_out,
        dmem_ena_out,
        imem_data_in,
        imem_addr_out,
        imem_ena_out,

        # Ports only for debug
        debug_if_program_counter=0,

        debug_of_alu_op=0,
        debug_of_alu_src_a=0,
        debug_of_alu_src_b=0,
        debug_of_branch_cond=0,
        debug_of_carry=0,
        debug_of_carry_keep=0,
        debug_of_delay=0,
        debug_of_hazard=0,
        debug_of_immediate=0,
        debug_of_instruction=0,
        debug_of_mem_read=0,
        debug_of_mem_write=0,
        debug_of_operation=0,
        debug_of_program_counter=0,
        debug_of_reg_a=0,
        debug_of_reg_b=0,
        debug_of_reg_d=0,
        debug_of_reg_write=0,
        debug_of_transfer_size=0,

        debug_of_fwd_mem_result=0,
        debug_of_fwd_reg_d=0,
        debug_of_fwd_reg_write=0,

        debug_gprf_dat_a=0,
        debug_gprf_dat_b=0,
        debug_gprf_dat_d=0,

        debug_ex_alu_result=0,
        debug_ex_reg_d=0,
        debug_ex_reg_write=0,

        debug_ex_branch=0,
        debug_ex_dat_d=0,
        debug_ex_flush_id=0,
        debug_ex_mem_read=0,
        debug_ex_mem_write=0,
        debug_ex_program_counter=0,
        debug_ex_transfer_size=0,

        debug_ex_dat_a=0,
        debug_ex_dat_b=0,
        debug_ex_instruction=0,
        debug_ex_reg_a=0,
        debug_ex_reg_b=0,

        debug_mm_alu_result=0,
        debug_mm_mem_read=0,
        debug_mm_reg_d=0,
        debug_mm_reg_write=0,
        debug_mm_transfer_size=0,

        DEBUG=True,
        ):
    """
    """
    # Ports only for debug
    of_instruction = 0
    if __debug__:
        of_instruction = Signal(intbv(0)[CFG_IMEM_WIDTH:])
    # End Ports only for debug

    if_program_counter = Signal(intbv(0)[CFG_IMEM_SIZE:])

    gprf_dat_a = Signal(intbv(0)[CFG_DMEM_WIDTH:])
    gprf_dat_b = Signal(intbv(0)[CFG_DMEM_WIDTH:])
    gprf_dat_d = Signal(intbv(0)[CFG_DMEM_WIDTH:])

    of_alu_op = Signal(alu_operation.ALU_ADD)
    of_alu_src_a = Signal(src_type_a.REGA)
    of_alu_src_b = Signal(src_type_b.REGB)
    of_branch_cond = Signal(branch_condition.NOP)
    of_carry = Signal(carry_type.C_ZERO)
    of_carry_keep = Signal(False)
    of_delay = Signal(False)
    of_hazard = Signal(False)
    of_immediate = Signal(intbv(0)[CFG_DMEM_WIDTH:])
    of_mem_read = Signal(False)
    of_mem_write = Signal(False)
    of_operation = Signal(False)
    of_program_counter = Signal(intbv(0)[CFG_IMEM_SIZE:])
    of_reg_a = Signal(intbv(0)[CFG_GPRF_SIZE:])
    of_reg_b = Signal(intbv(0)[CFG_GPRF_SIZE:])
    of_reg_d = Signal(intbv(0)[CFG_GPRF_SIZE:])
    of_reg_write = Signal(False)
    of_transfer_size = Signal(transfer_size_type.WORD)

    # Write back stage forwards
    of_fwd_mem_result = Signal(intbv(0)[CFG_DMEM_WIDTH:])
    of_fwd_reg_d = Signal(intbv(0)[CFG_GPRF_SIZE:])
    of_fwd_reg_write = Signal(False)

    ex_alu_result = Signal(intbv(0)[CFG_DMEM_WIDTH:])
    ex_reg_d = Signal(intbv(0)[CFG_GPRF_SIZE:])
    ex_reg_write = Signal(False)

    ex_branch = Signal(False)
    ex_dat_d = Signal(intbv(0)[CFG_DMEM_WIDTH:])
    ex_flush_id = Signal(False)
    ex_mem_read = Signal(False)
    ex_mem_write = Signal(False)
    ex_program_counter = Signal(intbv(0)[CFG_IMEM_SIZE:])
    ex_transfer_size = Signal(transfer_size_type.WORD)

    # Ports only for debug
    ex_dat_a = 0
    ex_dat_b = 0
    ex_instruction = 0
    ex_reg_a = 0
    ex_reg_b = 0
    if __debug__:
        ex_dat_a = Signal(intbv(0)[CFG_DMEM_WIDTH:])
        ex_dat_b = Signal(intbv(0)[CFG_DMEM_WIDTH:])
        ex_instruction = Signal(intbv(0)[CFG_DMEM_WIDTH:])
        ex_reg_a = Signal(intbv(0)[CFG_GPRF_SIZE:])
        ex_reg_b = Signal(intbv(0)[CFG_GPRF_SIZE:])
    # End Ports only for debug

    mm_alu_result = Signal(intbv(0)[CFG_DMEM_WIDTH:])
    mm_mem_read = Signal(False)
    mm_reg_d = Signal(intbv(0)[CFG_GPRF_SIZE:])
    mm_reg_write = Signal(False)
    mm_transfer_size = Signal(transfer_size_type.WORD)
    
    ftch = FetchUnit(
        clock=clock,
        reset=reset,
        enable=dmem_ena_in,
        of_hazard=of_hazard,
        ex_alu_result=ex_alu_result,
        ex_branch=ex_branch,
        if_program_counter=if_program_counter,
        imem_addr_out=imem_addr_out,
        imem_ena_out=imem_ena_out,
    )

    deco = Decoder(
        clock=clock,
        reset=reset,
        enable=dmem_ena_in,
        dmem_data_in=dmem_data_in,
        imem_data_in=imem_data_in,
        if_program_counter=if_program_counter,
        ex_flush_id=ex_flush_id,
        mm_alu_result=mm_alu_result,
        mm_mem_read=mm_mem_read,
        mm_reg_d=mm_reg_d,
        mm_reg_write=mm_reg_write,
        mm_transfer_size=mm_transfer_size,
        gprf_dat_a=gprf_dat_a,
        gprf_dat_b=gprf_dat_b,
        gprf_dat_d=gprf_dat_d,
        of_alu_op=of_alu_op,
        of_alu_src_a=of_alu_src_a,
        of_alu_src_b=of_alu_src_b,
        of_branch_cond=of_branch_cond,
        of_carry=of_carry,
        of_carry_keep=of_carry_keep,
        of_delay=of_delay,
        of_hazard=of_hazard,
        of_immediate=of_immediate,
        of_mem_read=of_mem_read,
        of_mem_write=of_mem_write,
        of_operation=of_operation,
        of_program_counter=of_program_counter,
        of_reg_a=of_reg_a,
        of_reg_b=of_reg_b,
        of_reg_d=of_reg_d,
        of_reg_write=of_reg_write,
        of_transfer_size=of_transfer_size,

        # Write back stage output
        of_fwd_mem_result=of_fwd_mem_result,
        of_fwd_reg_d=of_fwd_reg_d,
        of_fwd_reg_write=of_fwd_reg_write,

        # Ports only for debug
        of_instruction=of_instruction,
        
    )

    exeu = ExecuteUnit(
        # Inputs
        clock=clock,
        reset=reset,
        enable=dmem_ena_in,
        dmem_data_in=dmem_data_in,
        gprf_dat_a=gprf_dat_a,
        gprf_dat_b=gprf_dat_b,
        gprf_dat_d=gprf_dat_d,
        mm_alu_result=mm_alu_result,
        mm_mem_read=mm_mem_read,
        mm_reg_d=mm_reg_d,
        mm_reg_write=mm_reg_write,
        mm_transfer_size=mm_transfer_size,
        of_alu_op=of_alu_op,
        of_alu_src_a=of_alu_src_a,
        of_alu_src_b=of_alu_src_b,
        of_branch_cond=of_branch_cond,
        of_carry=of_carry,
        of_carry_keep=of_carry_keep,
        of_delay=of_delay,
        of_immediate=of_immediate,
        of_mem_read=of_mem_read,
        of_mem_write=of_mem_write,
        of_operation=of_operation,
        of_program_counter=of_program_counter,
        of_reg_a=of_reg_a,
        of_reg_b=of_reg_b,
        of_reg_d=of_reg_d,
        of_reg_write=of_reg_write,
        of_transfer_size=of_transfer_size,

        # Write back stage forwards,
        of_fwd_mem_result=of_fwd_mem_result,
        of_fwd_reg_d=of_fwd_reg_d,
        of_fwd_reg_write=of_fwd_reg_write,

        # Outputs
        ex_alu_result=ex_alu_result,
        ex_reg_d=ex_reg_d,
        ex_reg_write=ex_reg_write,

        ex_branch=ex_branch,
        ex_dat_d=ex_dat_d,
        ex_flush_id=ex_flush_id,
        ex_mem_read=ex_mem_read,
        ex_mem_write=ex_mem_write,
        ex_program_counter=ex_program_counter,
        ex_transfer_size=ex_transfer_size,

        # Ports only for debug
        of_instruction=of_instruction,
        ex_dat_a=ex_dat_a,
        ex_dat_b=ex_dat_b,
        ex_instruction=ex_instruction,
        ex_reg_a=ex_reg_a,
        ex_reg_b=ex_reg_b,
    )

    memu = MemUnit(
        # Inputs
        clock=clock,
        reset=reset,
        enable=dmem_ena_in,
        ex_alu_result=ex_alu_result,
        ex_reg_d=ex_reg_d,
        ex_reg_write=ex_reg_write,
        ex_branch=ex_branch,
        ex_dat_d=ex_dat_d,
        ex_mem_read=ex_mem_read,
        ex_mem_write=ex_mem_write,
        ex_program_counter=ex_program_counter,
        ex_transfer_size=ex_transfer_size,
        # Outputs
        mm_alu_result=mm_alu_result,
        mm_mem_read=mm_mem_read,
        mm_reg_d=mm_reg_d,
        mm_reg_write=mm_reg_write,
        mm_transfer_size=mm_transfer_size,
        dmem_data_out=dmem_data_out,
        dmem_sel_out=dmem_sel_out,
        dmem_we_out=dmem_we_out,
        dmem_addr_out=dmem_addr_out,
        dmem_ena_out=dmem_ena_out,
    )

    @always_comb
    def debug_output():
        debug_if_program_counter.next = if_program_counter

        debug_of_alu_op.next = of_alu_op
        debug_of_alu_src_a.next = of_alu_src_a
        debug_of_alu_src_b.next = of_alu_src_b
        debug_of_branch_cond.next = of_branch_cond
        debug_of_carry.next = of_carry
        debug_of_carry_keep.next = of_carry_keep
        debug_of_delay.next = of_delay
        debug_of_hazard.next = of_hazard
        debug_of_immediate.next = of_immediate
        debug_of_instruction.next = of_instruction
        debug_of_mem_read.next = of_mem_read
        debug_of_mem_write.next = of_mem_write
        debug_of_operation.next = of_operation
        debug_of_program_counter.next = of_program_counter
        debug_of_reg_a.next = of_reg_a
        debug_of_reg_b.next = of_reg_b
        debug_of_reg_d.next = of_reg_d
        debug_of_reg_write.next = of_reg_write
        debug_of_transfer_size.next = of_transfer_size

        debug_of_fwd_mem_result.next = of_fwd_mem_result
        debug_of_fwd_reg_d.next = of_fwd_reg_d
        debug_of_fwd_reg_write.next = of_fwd_reg_write

        debug_gprf_dat_a.next = gprf_dat_a
        debug_gprf_dat_b.next = gprf_dat_b
        debug_gprf_dat_d.next = gprf_dat_d

        debug_ex_alu_result.next = ex_alu_result
        debug_ex_reg_d.next = ex_reg_d
        debug_ex_reg_write.next = ex_reg_write

        debug_ex_branch.next = ex_branch
        debug_ex_dat_d.next = ex_dat_d
        debug_ex_flush_id.next = ex_flush_id
        debug_ex_mem_read.next = ex_mem_read
        debug_ex_mem_write.next = ex_mem_write
        debug_ex_program_counter.next = ex_program_counter
        debug_ex_transfer_size.next = ex_transfer_size

        debug_ex_dat_a.next = ex_dat_a
        debug_ex_dat_b.next = ex_dat_b
        debug_ex_instruction.next = ex_instruction
        debug_ex_reg_a.next = ex_reg_a
        debug_ex_reg_b.next = ex_reg_b

        debug_mm_alu_result.next = mm_alu_result
        debug_mm_mem_read.next = mm_mem_read
        debug_mm_reg_d.next = mm_reg_d
        debug_mm_reg_write.next = mm_reg_write
        debug_mm_transfer_size.next = mm_transfer_size

    if DEBUG:
        return ftch, deco, exeu, memu, debug_output
    return ftch, deco, exeu, memu

def bench():
    clock = Signal(False)
    reset = Signal(False)

    dmem_ena_in = Signal(False)
    dmem_data_in = Signal(intbv(0)[CFG_DMEM_WIDTH:])
    dmem_data_out = Signal(intbv(0)[CFG_DMEM_WIDTH:])
    dmem_sel_out = Signal(intbv(0)[4:])
    dmem_we_out = Signal(False)
    dmem_addr_out = Signal(intbv(0)[CFG_DMEM_SIZE:])
    dmem_ena_out = Signal(False)
    imem_data_in = Signal(intbv(0)[CFG_IMEM_WIDTH:])
    imem_addr_out = Signal(intbv(0)[CFG_IMEM_SIZE:])
    imem_ena_out = Signal(False)

    core = MyBlazeCore(
        clock=clock,
        reset=reset,
        dmem_ena_in=dmem_ena_in,

        dmem_data_in=dmem_data_in,
        dmem_data_out=dmem_data_out,
        dmem_sel_out=dmem_sel_out,
        dmem_we_out=dmem_we_out,
        dmem_addr_out=dmem_addr_out,
        dmem_ena_out=dmem_ena_out,
        imem_data_in=imem_data_in,
        imem_addr_out=imem_addr_out,
        imem_ena_out=imem_ena_out,
    )
    #code = ['001000''00','001''00000','0000''0000','0000''0001', # addi r1,r0,1
            #'001000''00','010''00000','0000''0000','0000''0010', # addi r1,r0,2
            #'001000''00','011''00000','0000''0000','0000''0011', # addi r1,r0,3
            #'001000''00','100''00000','0000''0000','0000''0100', # addi r1,r0,4
            #'001000''00','101''00000','0000''0000','0000''0101', # addi r1,r0,5
            #'001000''00','110''00000','0000''0000','0000''0110', # addi r1,r0,6
            #'001000''00','111''00000','0000''0000','0000''0111', # addi r1,r0,7
            #'001000''01','000''00000','0000''0000','0000''1000', # addi r1,r0,8
            #]
    #imem = [int(x, 16) for x in code]
    imem = []
    for x in open('rom.vmem').readlines():
        x = int(x, 16)
        imem.append((x>>24)%256)
        imem.append((x>>16)%256)
        imem.append((x>>8)%256)
        imem.append((x>>0)%256)

    dmem = imem
    print 'memory size: 0x%04x' % len(imem)
    #imem = [int(x, 16) for x in open('rom.vmem').readlines()]
    #dmem = [Signal(intbv(0)[32:]) for i in range(2**14)]
    import re

    @always(delay(10))
    def clockgen():
        clock.next = not clock

    @instance
    def ram():
        while 1:
            yield clock.posedge
            if dmem_ena_out:
                dmem_ena_in.next = False
                addr = int(dmem_addr_out)
                aligned_addr = (dmem_addr_out/4*4)
                if (dmem_sel_out == 0b1000 or
                    dmem_sel_out == 0b0100 or
                    dmem_sel_out == 0b0010 or
                    dmem_sel_out == 0b0001):
                    size = 1
                elif (dmem_sel_out == 0b1100 or
                      dmem_sel_out == 0b0011) and addr%2==0:
                    size = 2
                elif dmem_sel_out == 0b1111 and addr%4==0:
                    size = 4
                else:
                    assert False
                    
                if dmem_we_out:
                    if size==1:
                        if addr == 0xffffffc0:
                            print chr(dmem_data_out%256),
                        else:
                            dmem[addr] = dmem_data_out%256
                    elif size==2:
                        dmem[addr] = (dmem_data_out>>8)%256
                        dmem[addr+1] = dmem_data_out%256
                    else:
                        dmem[addr] = (dmem_data_out>>24)%256
                        dmem[addr+1] = (dmem_data_out>>16)%256
                        dmem[addr+2] = (dmem_data_out>>8)%256
                        dmem[addr+3] = (dmem_data_out>>0)%256
                    #dmem[dmem_addr_out/4].next = dmem_data_out
                    #print 'write addr=0x%08x data=0x%08x' % (dmem_addr_out, dmem_data_out)
                else:
                    dmem_data_in.next = (
                                             ((dmem[aligned_addr]%256)<<24)
                                            +((dmem[aligned_addr+1]%256)<<16)
                                            +((dmem[aligned_addr+2]%256)<<8)
                                            +(dmem[aligned_addr+3]%256)
                                        )
                #yield clock.posedge
                yield clock.posedge
            dmem_ena_in.next = True

    @instance
    def stimulus():
        reset.next = True
        yield delay(33)
        reset.next = False
        dmem_ena_in.next = True
        yield reset.negedge
        #for i in range(len(imem)):
        while 1:
            iaddr = int(imem_addr_out)
            if iaddr >= len(imem):
                break
            word = (((imem[iaddr]%256)<<24)
                   +((imem[iaddr+1]%256)<<16)
                   +((imem[iaddr+2]%256)<<8)
                   +(imem[iaddr+3]%256))
            #print 'imem addr:=0x%x code:=0x%08x' % (iaddr, word)
            #print '<dissemble> %s' % code.get(iaddr)
            imem_data_in.next = word
            yield clock.negedge

        for i in range(8):
            #print 'cycle %d: imem addr:=0x%x code:=NOP' % (i+len(imem),
                                                         #imem_addr_out)
            imem_data_in.next = 0
            yield clock.negedge
        StopSimulation()
        assert False # map(int, dmem[:4]
    return instances()

if __name__ == '__main__':
  if 0:
    clock = Signal(False)
    reset = Signal(False)

    dmem_ena_in = Signal(False)
    dmem_data_in = Signal(intbv(0)[CFG_DMEM_WIDTH:])
    dmem_data_out = Signal(intbv(0)[CFG_DMEM_WIDTH:])
    dmem_sel_out = Signal(intbv(0)[4:])
    dmem_we_out = Signal(False)
    dmem_addr_out = Signal(intbv(0)[CFG_DMEM_SIZE:])
    dmem_ena_out = Signal(False)
    imem_data_in = Signal(intbv(0)[CFG_IMEM_WIDTH:])
    imem_addr_out = Signal(intbv(0)[CFG_IMEM_SIZE:])
    imem_ena_out = Signal(False)

    kw = dict(
        clock=clock,
        reset=reset,
        dmem_ena_in=dmem_ena_in,

        dmem_data_in=dmem_data_in,
        dmem_data_out=dmem_data_out,
        dmem_sel_out=dmem_sel_out,
        dmem_we_out=dmem_we_out,
        dmem_addr_out=dmem_addr_out,
        dmem_ena_out=dmem_ena_out,
        imem_data_in=imem_data_in,
        imem_addr_out=imem_addr_out,
        imem_ena_out=imem_ena_out,
    )
    toVHDL(MyBlazeCore, **kw)
    toVerilog(MyBlazeCore, **kw)
  else:
    tb = bench()
    #tb = traceSignals(bench)
    Simulation(tb).run(2000000)

### EOF ###
# vim:smarttab:sts=4:ts=4:sw=4:et:ai:tw=80:

