# -*- coding: utf-8 -*-
"""
    execute.py
    ==========

    Execute Unit
    
    :copyright: Copyright (c) 2010 Jian Luo
    :author-email: jian.luo.cn(at_)gmail.com
    :license: LGPL, see LICENSE for details
    :revision: $Id: execute.py 6 2010-11-21 23:18:44Z rockee $
"""

from myhdl import *
from defines import *
from functions import *

def ExecuteUnit(
        # Inputs
        clock,
        reset,
        enable,
        dmem_data_in,
        gprf_dat_a,
        gprf_dat_b,
        gprf_dat_d,
        mm_alu_result,
        mm_mem_read,
        mm_reg_d,
        mm_reg_write,
        mm_transfer_size,
        of_alu_op,
        of_alu_src_a,
        of_alu_src_b,
        of_branch_cond,
        of_carry,
        of_carry_keep,
        of_delay,
        of_immediate,
        of_mem_read,
        of_mem_write,
        of_operation,
        of_program_counter,
        of_reg_a,
        of_reg_b,
        of_reg_d,
        of_reg_write,
        of_transfer_size,

        # Write back stage forwards
        of_fwd_mem_result,
        of_fwd_reg_d,
        of_fwd_reg_write,

        # Outputs
        ex_alu_result,
        ex_reg_d,
        ex_reg_write,

        ex_branch,
        ex_dat_d,
        ex_flush_id,
        ex_mem_read,
        ex_mem_write,
        ex_program_counter,
        ex_transfer_size,

        # Ports only for debug
        of_instruction=0,
        ex_dat_a=0,
        ex_dat_b=0,
        ex_instruction=0,
        ex_reg_a=0,
        ex_reg_b=0,

    ):
    """
    """
    ex_r_carry = Signal(False)
    ex_r_flush_ex= Signal(False)

    ex_r_alu_result = Signal(intbv(0)[CFG_DMEM_WIDTH:])
    ex_r_reg_d = Signal(intbv(0)[CFG_GPRF_SIZE:])
    ex_r_reg_write = Signal(False)

    ex_comb_r_carry = Signal(False)
    ex_comb_r_flush_ex = Signal(False)

    ex_comb_r_alu_result = Signal(intbv(0)[CFG_DMEM_WIDTH:])
    ex_comb_r_reg_d = Signal(intbv(0)[CFG_GPRF_SIZE:])
    ex_comb_r_reg_write = Signal(False)

    ex_comb_branch = Signal(False)
    ex_comb_dat_d = Signal(intbv(0)[CFG_DMEM_WIDTH:])
    ex_comb_flush_id = Signal(False)
    ex_comb_mem_read = Signal(False)
    ex_comb_mem_write = Signal(False)
    ex_comb_program_counter = Signal(intbv(0)[CFG_IMEM_SIZE:])
    ex_comb_transfer_size = Signal(transfer_size_type.WORD)

    if __debug__:
        ex_comb_dat_a = Signal(intbv(0)[CFG_DMEM_WIDTH:])
        ex_comb_dat_b = Signal(intbv(0)[CFG_DMEM_WIDTH:])
        ex_comb_instruction = Signal(intbv(0)[CFG_DMEM_WIDTH:])
        ex_comb_reg_a = Signal(intbv(0)[CFG_GPRF_SIZE:])
        ex_comb_reg_b = Signal(intbv(0)[CFG_GPRF_SIZE:])

    @always_comb
    def regout():
        ex_alu_result.next = ex_r_alu_result
        ex_reg_d.next = ex_r_reg_d
        ex_reg_write.next = ex_r_reg_write
        
    cpu_clock = 0
    @always(clock.posedge)
    def seq():
        """
        ExecUnit sequential logic
        """
        if reset:
            ex_r_carry.next = False
            ex_r_flush_ex.next = False

            ex_r_alu_result.next = intbv(0)[CFG_DMEM_WIDTH:]
            ex_r_reg_d.next = intbv(0)[CFG_GPRF_SIZE:]
            ex_r_reg_write.next = False

            ex_branch.next = False
            ex_dat_d.next = intbv(0)[CFG_DMEM_WIDTH:]
            ex_flush_id.next = False
            ex_mem_read.next = False
            ex_mem_write.next = False
            ex_program_counter.next = intbv(0)[CFG_IMEM_SIZE:]
            ex_transfer_size.next = transfer_size_type.WORD

        elif enable:
            ex_r_carry.next = ex_comb_r_carry
            ex_r_flush_ex.next = ex_comb_r_flush_ex

            ex_r_alu_result.next = ex_comb_r_alu_result
            ex_r_reg_d.next = ex_comb_r_reg_d
            ex_r_reg_write.next = ex_comb_r_reg_write

            ex_branch.next = ex_comb_branch
            ex_dat_d.next = ex_comb_dat_d
            ex_flush_id.next = ex_comb_flush_id
            ex_mem_read.next = ex_comb_mem_read
            ex_mem_write.next = ex_comb_mem_write
            ex_program_counter.next = ex_comb_program_counter
            ex_transfer_size.next = ex_comb_transfer_size

        if __debug__:
          if enable:
            ex_dat_a.next = ex_comb_dat_a
            ex_dat_b.next = ex_comb_dat_b
            ex_instruction.next = ex_comb_instruction
            ex_reg_a.next = ex_comb_reg_a
            ex_reg_b.next = ex_comb_reg_b

    @always_comb
    def comb():
        """
        ExecUnit combinatorial logic
        """
        # Signals mapping
        r_carry = False
        r_flush_ex = False

        r_alu_result = intbv(0)[CFG_DMEM_WIDTH:]
        r_reg_d = intbv(0)[CFG_GPRF_SIZE:]
        r_reg_write = False

        branch = False
        dat_d = intbv(0)[CFG_DMEM_WIDTH:]
        flush_id = False
        mem_read = False
        mem_write = False
        program_counter = intbv(0)[CFG_IMEM_SIZE:]
        transfer_size = transfer_size_type.WORD

        # Local Variables 
        alu_src_a = intbv(0)[CFG_DMEM_WIDTH:]
        alu_src_b = intbv(0)[CFG_DMEM_WIDTH:]
        carry = False

        result = intbv(0)[CFG_DMEM_WIDTH+1:]
        result_add = intbv(0)[CFG_DMEM_WIDTH+1:]
        zero = False

        dat_a = intbv(0)[CFG_DMEM_WIDTH:]
        dat_b = intbv(0)[CFG_DMEM_WIDTH:]
        sel_dat_a = intbv(0)[CFG_DMEM_WIDTH:]
        sel_dat_b = intbv(0)[CFG_DMEM_WIDTH:]
        sel_dat_d = intbv(0)[CFG_DMEM_WIDTH:]
        mem_result = intbv(0)[CFG_DMEM_WIDTH:]

        # XXX: write back result must be forwarded,
        # if gprf has read old data behaviour
        #cfg_reg_fwd_wrb = CFG_REG_FWD_WRB   # Hacked to pass VHDL syntax check
        #if cfg_reg_fwd_wrb:
        sel_dat_a[:] = select_register_data(
                            gprf_dat_a, of_reg_a, of_fwd_mem_result,
                            forward_condition(of_fwd_reg_write,
                                              of_fwd_reg_d, of_reg_a)
                       )
        sel_dat_b[:] = select_register_data(
                            gprf_dat_b, of_reg_b, of_fwd_mem_result,
                            forward_condition(of_fwd_reg_write,
                                              of_fwd_reg_d, of_reg_b)
                       )
        sel_dat_d[:] = select_register_data(
                            gprf_dat_d, of_reg_d, of_fwd_mem_result,
                            forward_condition(of_fwd_reg_write,
                                              of_fwd_reg_d, of_reg_d)
                       )
        #else:
            #sel_dat_a[:] = gprf_dat_a
            #sel_dat_b[:] = gprf_dat_b
            #sel_dat_d[:] = gprf_dat_d


        if not ex_r_flush_ex:
            mem_write = bool(of_mem_write)
            mem_read = bool(of_mem_read)
            transfer_size = of_transfer_size.val # Needed?
            r_reg_write = bool(of_reg_write)
            r_reg_d[:] = of_reg_d

        if mm_mem_read:
            mem_result[:] = align_mem_load(dmem_data_in, mm_transfer_size,
                                        mm_alu_result[2:])
        else:
            mem_result[:] = mm_alu_result

        # Reg A
        if forward_condition(ex_r_reg_write, ex_r_reg_d, of_reg_a) == True:
            # Forward from exec
            dat_a[:] = ex_r_alu_result
        elif forward_condition(mm_reg_write, mm_reg_d, of_reg_a) == True:
            # Forward from mem
            dat_a[:] = mem_result
        else:
            # Default from gprf
            dat_a[:] = sel_dat_a

        # Reg B
        if forward_condition(ex_r_reg_write, ex_r_reg_d, of_reg_b) == True:
            # Forward from exec
            dat_b[:] = ex_r_alu_result
        elif forward_condition(mm_reg_write, mm_reg_d, of_reg_b) == True:
            # Forward from mem
            dat_b[:] = mem_result
        else:
            # Default from gprf
            dat_b[:] = sel_dat_b

        # XXX Why bother?
        if forward_condition(ex_r_reg_write, ex_r_reg_d, of_reg_d) == True:
            dat_d[:] = align_mem_store(ex_r_alu_result, of_transfer_size)
            #print 'fwd_ex r%d=%x' % (of_reg_d, dat_d)
        elif forward_condition(mm_reg_write, mm_reg_d, of_reg_d) == True:
            dat_d[:] = align_mem_store(mem_result, of_transfer_size)
            
            #print 'fwd_mm r%d=%x' % (of_reg_d, dat_d)
        else:
            dat_d[:] = align_mem_store(sel_dat_d, of_transfer_size)
            #print 'gprf r%d=%x'  % (of_reg_d, dat_d)

        # Operand A
        if of_alu_src_a == src_type_a.PC:
            alu_src_a[:] = of_program_counter
        elif of_alu_src_a == src_type_a.NOT_REGA:
            alu_src_a[:] = ~dat_a
        elif of_alu_src_a == src_type_a.REGA_ZERO:
            alu_src_a[:] = 0
        else:
            alu_src_a[:] = dat_a

        # Operand B
        if of_alu_src_b == src_type_b.IMM:
            alu_src_b[:] = of_immediate
        elif of_alu_src_b == src_type_b.NOT_IMM:
            alu_src_b[:] = ~of_immediate
        elif of_alu_src_b == src_type_b.NOT_REGB:
            alu_src_b[:] = ~dat_b
        else:
            alu_src_b[:] = dat_b

        # Determine value of carry in
        if of_carry == carry_type.ALU:
            carry = bool(ex_r_carry)
        elif of_carry == carry_type.C_ONE:
            carry = True
        elif of_carry == carry_type.ARITH:
            carry = alu_src_a[CFG_DMEM_WIDTH-1]
        else:
            carry = False

        #result_add[:] = alu_src_a.signed() + alu_src_b.signed() + carry
        result_add[:] = add(alu_src_a, alu_src_b, carry)

        if of_alu_op == alu_operation.ALU_ADD:
            result[:] = result_add
        elif of_alu_op == alu_operation.ALU_OR:
            or_rslt = intbv(0)[CFG_DMEM_WIDTH:]
            or_rslt[:] = alu_src_a | alu_src_b
            result[:] = or_rslt
        elif of_alu_op == alu_operation.ALU_AND:
            and_rslt = intbv(0)[CFG_DMEM_WIDTH:]
            and_rslt[:] = alu_src_a & alu_src_b
            result[:] = and_rslt
        elif of_alu_op == alu_operation.ALU_XOR:
            xor_rslt = intbv(0)[CFG_DMEM_WIDTH:]
            xor_rslt[:] = alu_src_a ^ alu_src_b
            result[:] = xor_rslt
        elif of_alu_op == alu_operation.ALU_SHIFT:
            result[:] = concat(alu_src_a[0], carry, alu_src_a[CFG_DMEM_WIDTH:1])
        elif of_alu_op == alu_operation.ALU_SEXT8:
            
            result[:] = concat(False, sign_extend8(alu_src_a, alu_src_a[7]))
            #result[:] = concat(False, sign_extend(alu_src_a, alu_src_a[7],
                                                  #8, CFG_DMEM_WIDTH))
        elif of_alu_op == alu_operation.ALU_SEXT16:
            result[:] = concat(False, sign_extend16(alu_src_a, alu_src_a[15]))
            #result[:] = concat(False, sign_extend(alu_src_a, alu_src_a[15],
                                                  #16, CFG_DMEM_WIDTH))
        else:
            result[:] = 0
            if __debug__:
                assert False, 'FATAL Error: Unsupported ALU operation'

        # Set carry register
        if of_carry_keep:
            r_carry = bool(ex_r_carry) # bool() needs for signal type mismatch
        else:
            r_carry = result[CFG_DMEM_WIDTH]

        if not ex_r_flush_ex:
            zero = dat_a == 0

            if of_branch_cond == branch_condition.BRU:
                branch = True
            elif of_branch_cond == branch_condition.BEQ:
                branch = zero
            elif of_branch_cond == branch_condition.BNE:
                branch = not zero
            elif of_branch_cond == branch_condition.BLT:
                branch = dat_a[CFG_DMEM_WIDTH-1]
            elif of_branch_cond == branch_condition.BLE:
                branch = dat_a[CFG_DMEM_WIDTH-1] or zero
            elif of_branch_cond == branch_condition.BGT:
                branch = not bool(dat_a[CFG_DMEM_WIDTH-1] or zero)
            elif of_branch_cond == branch_condition.BGE:
                branch = not dat_a[CFG_DMEM_WIDTH-1]
            else:
                branch = False

        # Handle CMPU
        cmp_cond = alu_src_a[CFG_DMEM_WIDTH-1] ^ alu_src_b[CFG_DMEM_WIDTH-1] 
        if of_operation and bool(cmp_cond):
            ## Set MSB
            msb = alu_src_a[CFG_DMEM_WIDTH-1]
            r_alu_result[:] = concat(msb, result[CFG_DMEM_WIDTH-1:])
        else:
            r_alu_result[:] = result[CFG_DMEM_WIDTH:]

        program_counter[:] = of_program_counter

        # Determine flush signals
        flush_id = branch
        r_flush_ex = branch and not of_delay

        # Write to local register
        ex_comb_r_carry.next = r_carry
        ex_comb_r_flush_ex.next = r_flush_ex

        ex_comb_r_alu_result.next = r_alu_result
        ex_comb_r_reg_d.next = r_reg_d
        ex_comb_r_reg_write.next = r_reg_write

        ex_comb_branch.next = branch
        ex_comb_dat_d.next = dat_d
        ex_comb_flush_id.next = flush_id
        ex_comb_mem_read.next = mem_read
        ex_comb_mem_write.next = mem_write
        ex_comb_program_counter.next = program_counter
        ex_comb_transfer_size.next = transfer_size
            
        if __debug__:
            ex_comb_dat_a.next = dat_a
            ex_comb_dat_b.next = dat_b
            ex_comb_instruction.next = of_instruction
            ex_comb_reg_a.next = of_reg_a
            ex_comb_reg_b.next = of_reg_b

    return instances()

if __name__ == '__main__':
    clock = Signal(False)
    reset = Signal(False)
    enable = Signal(False)

    dmem_data_in = Signal(intbv(0)[CFG_DMEM_WIDTH:])

    mm_alu_result = Signal(intbv(0)[CFG_DMEM_WIDTH:])
    mm_mem_read =  Signal(False)
    mm_reg_d = Signal(intbv(0)[CFG_GPRF_SIZE:])
    mm_reg_write = Signal(False)
    mm_transfer_size = Signal(transfer_size_type.WORD)

    gprf_dat_a = Signal(intbv(0)[CFG_DMEM_WIDTH:])
    gprf_dat_b = Signal(intbv(0)[CFG_DMEM_WIDTH:])
    gprf_dat_d = Signal(intbv(0)[CFG_DMEM_WIDTH:])

    ex_flush_id = Signal(False)
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
    
    kw = dict(
        clock=clock,
        reset=reset,
        enable=enable,
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
        # Write back stage forwards
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
    )
    toVerilog(ExecuteUnit, **kw)
    toVHDL(ExecuteUnit, **kw)

### EOF ###
# vim:smarttab:sts=4:ts=4:sw=4:et:ai:tw=80:

