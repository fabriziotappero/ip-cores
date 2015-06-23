# -*- coding: utf-8 -*-
"""
    decoder.py
    ==========

    Instruction Decoder
    
    :copyright: Copyright (c) 2010 Jian Luo
    :author-email: jian.luo.cn(at_)gmail.com
    :license: LGPL, see LICENSE for details
    :revision: $Id: decoder.py 6 2010-11-21 23:18:44Z rockee $
"""

from random import randrange
from myhdl import *
from defines import *
from functions import *
from gprf import *
#from debug import *

def Decoder(
        # Inputs
        clock,
        reset,
        enable,
        dmem_data_in,
        imem_data_in,
        if_program_counter,
        ex_flush_id,
        mm_alu_result,
        mm_mem_read,
        mm_reg_d,
        mm_reg_write,
        mm_transfer_size,

        # Outputs
        gprf_dat_a,
        gprf_dat_b,
        gprf_dat_d,
        of_alu_op,
        of_alu_src_a,
        of_alu_src_b,
        of_branch_cond,
        of_carry,
        of_carry_keep,
        of_delay,
        of_hazard,
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

        # Write back stage outputs
        of_fwd_mem_result,
        of_fwd_reg_d,
        of_fwd_reg_write,

        # Ports only for debug
        of_instruction=0,
    ):
    """
    Python System Model of the OF Stage
    """
    of_comb_r_has_imm_high = Signal(False)
    of_comb_r_hazard = Signal(False)
    of_comb_r_immediate_high = Signal(intbv(0)[16:])
    of_comb_r_instruction = Signal(intbv(0)[CFG_DMEM_WIDTH:])
    of_comb_r_mem_read = Signal(False)
    of_comb_r_program_counter = Signal(intbv(0)[CFG_IMEM_SIZE:])
    of_comb_r_reg_d = Signal(intbv(0)[5:])
    of_r_has_imm_high = Signal(False)
    of_r_hazard = Signal(False)
    of_r_immediate_high = Signal(intbv(0)[16:])
    of_r_instruction = Signal(intbv(0)[CFG_DMEM_WIDTH:])
    of_r_mem_read = Signal(False)
    of_r_program_counter = Signal(intbv(0)[CFG_IMEM_SIZE:])
    of_r_reg_d = Signal(intbv(0)[5:])

    of_comb_alu_op = Signal(alu_operation.ALU_ADD)
    of_comb_alu_src_a = Signal(src_type_a.REGA)
    of_comb_alu_src_b = Signal(src_type_b.REGB)
    of_comb_branch_cond = Signal(branch_condition.NOP)
    of_comb_carry = Signal(carry_type.C_ZERO)
    of_comb_carry_keep = Signal(False)
    of_comb_delay = Signal(False)
    of_comb_immediate = Signal(intbv(0)[CFG_DMEM_WIDTH:])
    of_comb_instruction = Signal(intbv(0)[CFG_DMEM_WIDTH:])
    of_comb_mem_write = Signal(False)
    of_comb_operation = Signal(False)
    of_comb_program_counter = Signal(intbv(0)[CFG_IMEM_SIZE:])
    of_comb_reg_a = Signal(intbv(0)[5:])
    of_comb_reg_b = Signal(intbv(0)[5:])
    of_comb_reg_write = Signal(False)
    of_comb_transfer_size = Signal(transfer_size_type.WORD)

    wb_dat_d = Signal(intbv(0)[CFG_DMEM_WIDTH:])

    gprf = GPRF(
                clock=clock,
                enable=enable,
                gprf_adr_a_i=of_comb_reg_a,
                gprf_adr_b_i=of_comb_reg_b,
                gprf_adr_d_i=of_comb_r_reg_d,
                gprf_dat_w_i=wb_dat_d,
                gprf_adr_w_i=mm_reg_d,
                gprf_wre_i=mm_reg_write,
                gprf_dat_a_o=gprf_dat_a,
                gprf_dat_b_o=gprf_dat_b,
                gprf_dat_d_o=gprf_dat_d,
           )

    @always(clock.posedge)
    def decode():
        #cfg_reg_fwd_wrb = CFG_REG_FWD_WRB   # Hacked to pass VHDL syntax check

        if reset:
            of_alu_op.next = alu_operation.ALU_ADD
            of_alu_src_a.next = src_type_a.REGA
            of_alu_src_b.next = src_type_b.REGB
            of_branch_cond.next = branch_condition.NOP
            of_carry.next = carry_type.C_ZERO
            of_carry_keep.next = False
            of_delay.next = False
            of_immediate.next = 0
            of_mem_write.next = False
            of_operation.next = False
            of_program_counter.next = 0
            of_reg_a.next = 0 
            of_reg_b.next = 0 
            of_reg_write.next = False
            of_transfer_size.next = transfer_size_type.WORD

            of_r_mem_read.next = False
            of_r_reg_d.next = 0
            of_r_hazard.next = False
            of_r_has_imm_high.next = False
            of_r_immediate_high.next = 0
            of_r_instruction.next = 0
            of_r_program_counter.next = 0

            of_fwd_mem_result.next = 0
            of_fwd_reg_d.next = 0
            of_fwd_reg_write.next = False

        elif enable:
            of_alu_op.next = of_comb_alu_op
            of_alu_src_a.next = of_comb_alu_src_a
            of_alu_src_b.next = of_comb_alu_src_b
            of_branch_cond.next = of_comb_branch_cond
            of_carry.next = of_comb_carry
            of_carry_keep.next = of_comb_carry_keep
            of_delay.next = of_comb_delay
            of_immediate.next = of_comb_immediate
            of_mem_write.next = of_comb_mem_write
            of_operation.next = of_comb_operation
            of_program_counter.next = of_comb_program_counter
            of_reg_a.next = of_comb_reg_a
            of_reg_b.next = of_comb_reg_b
            of_reg_write.next = of_comb_reg_write
            of_transfer_size.next = of_comb_transfer_size

            of_r_mem_read.next = of_comb_r_mem_read
            of_r_reg_d.next = of_comb_r_reg_d
            of_r_hazard.next = of_comb_r_hazard
            of_r_has_imm_high.next = of_comb_r_has_imm_high
            of_r_immediate_high.next = of_comb_r_immediate_high
            of_r_instruction.next = of_comb_r_instruction
            of_r_program_counter.next = of_comb_r_program_counter

            #if cfg_reg_fwd_wrb == True:
            of_fwd_mem_result.next = wb_dat_d
            of_fwd_reg_d.next = mm_reg_d
            of_fwd_reg_write.next = mm_reg_write

    @always_comb
    def regout():
        of_hazard.next = of_r_hazard
        of_mem_read.next = of_r_mem_read
        of_reg_d.next = of_r_reg_d
        if __debug__:
            of_instruction.next = of_r_instruction

    @always_comb
    def comb():
        # XXX intbvs should be explicitly declared
        # Register
        r_instruction = intbv(0)[32:]
        r_instruction[:] = imem_data_in
        r_program_counter = intbv(0)[CFG_IMEM_SIZE:]
        r_program_counter[:] = if_program_counter
        r_immediate_high = intbv(0)[16:]
        r_has_imm_high = False
        r_reg_d = intbv(0)[5:]
        # Local Variables
        r_hazard = False
        immediate = intbv(0)[32:]
        immediate_low = intbv(0)[16:]
        instruction = intbv(0)[32:]
        mem_result = intbv(0)[32:]
        opcode = intbv(0)[6:]
        opgroup = intbv(0)[5:]
        program_counter = intbv(0)[CFG_IMEM_SIZE:]
        reg_a = intbv(0)[5:]
        reg_b = intbv(0)[5:]

        if mm_mem_read:
            mem_result[:] = align_mem_load(dmem_data_in, mm_transfer_size,
                                           mm_alu_result[2:])
        else:
            mem_result[:] = mm_alu_result

        wb_dat_d.next = mem_result

        if not ex_flush_id and of_r_mem_read and (
                imem_data_in[21:16] == of_r_reg_d or
                imem_data_in[16:11] == of_r_reg_d):
            # A hazard occurred on register a or b
            instruction[:] = 0
            program_counter[:] = 0
            r_hazard = True
        elif not ex_flush_id and of_r_mem_read and (
                imem_data_in[26:21] == of_r_reg_d):
            # A hazard occurred on register d
            # This actually only applies to store after load, but it's also
            # nonsense to discard the result just after read it from memory.
            # So, trigger a hazard alarm whenever Rd is the same,
            # in order to simplify the logic.
            instruction[:] = 0
            program_counter[:] = 0
            r_hazard = True
        elif of_r_hazard:
            instruction[:] = of_r_instruction
            program_counter[:] = of_r_program_counter
            r_hazard = False
        else:
            instruction[:] = imem_data_in
            program_counter[:] = if_program_counter
            r_hazard = False

        # Dissemble instruction
        opgroup[:] = concat(instruction[32:30], instruction[29:26])
        opcode[:] = instruction[32:26]
        has_imm = opcode[3]
        immediate_low[:] = instruction[16:]
        reg_a[:] = instruction[21:16]
        reg_b[:] = instruction[16:11]
        r_reg_d[:] = instruction[26:21]

        # Process immediate
        # IMM15 will only be used as msr bitmap
        # so there is no need to treat it separately
        if of_r_has_imm_high: # last inst is imm
            immediate[:] = concat(of_r_immediate_high, immediate_low)
        else:
            immediate[:] = sign_extend16(immediate_low, immediate_low[15])
            

        # Default Mux States
        alu_op = alu_operation.ALU_ADD
        alu_src_a = src_type_a.REGA
        alu_src_b = src_type_b.REGB
        branch_cond = branch_condition.NOP
        carry = carry_type.C_ZERO
        carry_keep = False
        delay = False
        r_mem_read = False
        mem_write = False
        operation = False
        reg_write = False
        transfer_size = transfer_size_type.WORD

        if bool(ex_flush_id or r_hazard):
            pass
        elif opgroup[5:3] == OPG_ADD:
            # ADD / SUBTRACT / COMPARE
            alu_op = alu_operation.ALU_ADD

            if opcode[0]:
                alu_src_a = src_type_a.NOT_REGA

            if opcode == OPG_CMP and instruction[1]:
                operation = True # cmpu

            if has_imm:
                alu_src_b = src_type_b.IMM
            else:
                alu_src_b = src_type_b.REGB

            #carry_code = intbv(0)[2:]
            #carry_code[:] = opcode[2:]
            #if carry_code == 0:
            if opcode[2:] == 0:
                carry = carry_type.C_ZERO
            #elif carry_code == 1:
            elif opcode[2:] == 1:
                carry = carry_type.C_ONE
            else:
                carry = carry_type.ALU

            carry_keep = opcode[2]

            reg_write = not (r_reg_d == 0)

        elif opgroup[5:2] == OPG_LOG:
            # OR/AND/XOR
            #logic_code = intbv(0)[2:]
            #logic_code[:] = opcode[2:]
            #if logic_code == 0:
            if opcode[2:] == 0:
                alu_op = alu_operation.ALU_OR
            #elif logic_code == 2:
            elif opcode[2:] == 2:
                alu_op = alu_operation.ALU_XOR
            else:
                alu_op = alu_operation.ALU_AND

            #if has_imm and logic_code == 3:
            if has_imm and opcode[2:] == 3:
                alu_src_b = src_type_b.NOT_IMM
            elif has_imm:
                alu_src_b = src_type_b.IMM
            #elif not has_imm and logic_code == 3:
            elif not has_imm and opcode[2:] == 3:
                alu_src_b = src_type_b.NOT_REGB
            else:
                alu_src_b = src_type_b.REGB

            reg_write = not (r_reg_d == 0)

        elif opcode == OPG_IMM:
            # Immediate
            r_immediate_high[:] = instruction[16:]
            r_has_imm_high = True

        elif opcode == OPG_EXT:
            # Sign extend / Shift right
            #func_code = intbv(0)[2:]
            #func_code[:] = instruction[7:5]
            #if func_code == 3:
            if instruction[7:5] == 3:
                if instruction[0]:
                    alu_op = alu_operation.ALU_SEXT16
                else:
                    alu_op = alu_operation.ALU_SEXT8
            else:
                alu_op = alu_operation.ALU_SHIFT
                carry_keep = False
                #if func_code == 2:
                if instruction[7:5] == 2:
                    carry = carry_type.C_ZERO
                #elif func_code == 1:
                elif instruction[7:5] == 1:
                    carry = carry_type.ALU
                else:
                    carry = carry_type.ARITH

            reg_write = not (r_reg_d == 0)

        elif opgroup == OPG_BRU:
            branch_cond = branch_condition.BRU

            if has_imm:
                alu_src_b = src_type_b.IMM
            else:
                alu_src_b = src_type_b.REGB

            if reg_a[2]:
                reg_write = not (r_reg_d == 0)

            if reg_a[3]:
                alu_src_a = src_type_a.REGA_ZERO
            else:
                alu_src_a = src_type_a.PC

            delay = reg_a[4]

        elif opgroup == OPG_BCC:
            alu_op  = alu_operation.ALU_ADD
            alu_src_a = src_type_a.PC

            if has_imm:
                alu_src_b = src_type_b.IMM
            else:
                alu_src_b = src_type_b.REGB

            #br_code = intbv(0)[3:]
            #br_code[:] = r_reg_d[3:]
            #if br_code == 0:
            if r_reg_d[3:] == 0:
                branch_cond = branch_condition.BEQ
            #elif br_code == 1:
            elif r_reg_d[3:] == 1:
                branch_cond = branch_condition.BNE
            #elif br_code == 2:
            elif r_reg_d[3:] == 2:
                branch_cond = branch_condition.BLT
            #elif br_code == 3:
            elif r_reg_d[3:] == 3:
                branch_cond = branch_condition.BLE
            #elif br_code == 4:
            elif r_reg_d[3:] == 4:
                branch_cond = branch_condition.BGT
            else:
                branch_cond = branch_condition.BGE

            delay = r_reg_d[4]

        elif opcode == OPG_RET:
            branch_cond = branch_condition.BRU
            alu_src_b = src_type_b.IMM
            delay = True

        elif opgroup[5:3] == OPG_MEM:
            alu_op = alu_operation.ALU_ADD
            alu_src_a = src_type_a.REGA

            if has_imm:
                alu_src_b = src_type_b.IMM
            else:
                alu_src_b = src_type_b.REGB

            carry = carry_type.C_ZERO

            if opcode[2]:
                mem_write = True
                r_mem_read = False
                reg_write = False
            else:
                mem_write = False
                r_mem_read = True
                reg_write = not (r_reg_d == 0)

            #transfer_size_code = intbv(0)[2:]
            #transfer_size_code[:] = opcode[2:]
            #if transfer_size_code == 0:
            if opcode[2:] == 0:
                transfer_size = transfer_size_type.BYTE
            #elif transfer_size_code == 1:
            elif opcode[2:] == 1:
                transfer_size = transfer_size_type.HALFWORD
            else:
                transfer_size = transfer_size_type.WORD

            delay = False
        else:
            pass

        # Outputs
        of_comb_r_has_imm_high.next = r_has_imm_high 
        of_comb_r_immediate_high.next = r_immediate_high 
        of_comb_r_instruction.next = r_instruction
        of_comb_r_program_counter.next = r_program_counter
        of_comb_r_hazard.next = r_hazard
        of_comb_r_mem_read.next = r_mem_read 
        of_comb_r_reg_d.next = r_reg_d 

        of_comb_alu_op.next = alu_op 
        of_comb_alu_src_a.next = alu_src_a 
        of_comb_alu_src_b.next = alu_src_b 
        of_comb_branch_cond.next = branch_cond 
        of_comb_carry.next = carry 
        of_comb_carry_keep.next = carry_keep 
        of_comb_delay.next = delay 
        of_comb_immediate.next = immediate 
        of_comb_mem_write.next = mem_write 
        of_comb_operation.next = operation 
        of_comb_program_counter.next = program_counter
        of_comb_reg_a.next = reg_a 
        of_comb_reg_b.next = reg_b 
        of_comb_reg_write.next = reg_write 
        of_comb_transfer_size.next = transfer_size 

    return instances()

if __name__ == '__main__':
    clock = Signal(False)
    reset = Signal(False)
    enable = Signal(False)

    dmem_data_in = Signal(intbv(0)[CFG_DMEM_WIDTH:])
    imem_data_in = Signal(intbv(0)[CFG_IMEM_WIDTH:])
    if_program_counter = Signal(intbv(0)[CFG_IMEM_SIZE:])
    ex_flush_id = Signal(False)
    mm_alu_result = Signal(intbv(0)[CFG_DMEM_WIDTH:])
    mm_mem_read = Signal(False)
    mm_reg_d = Signal(intbv(0)[CFG_GPRF_SIZE:])
    mm_reg_write = Signal(False)
    mm_transfer_size = Signal(transfer_size_type.WORD)
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
    of_fwd_mem_result = Signal(intbv(0)[CFG_DMEM_WIDTH:])
    of_fwd_reg_d = Signal(intbv(0)[CFG_GPRF_SIZE:])
    of_fwd_reg_write = Signal(False)
    if __debug__:
        of_instruction = Signal(intbv(0)[CFG_IMEM_WIDTH:])
    # End Ports only for debug


    kw = dict(
        clock=clock,
        reset=reset,
        enable=enable,
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
        of_fwd_mem_result=of_fwd_mem_result,
        of_fwd_reg_d=of_fwd_reg_d,
        of_fwd_reg_write=of_fwd_reg_write,

    )
    toVerilog(Decoder, **kw)
    toVHDL(Decoder, **kw)
    

### EOF ###
# vim:smarttab:sts=4:ts=4:sw=4:et:ai:tw=80:

