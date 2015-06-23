# -*- coding: utf-8 -*-
"""
    top.py
    ======

    Top Level of the System Design
    
    :copyright: Copyright (c) 2010 Jian Luo
    :author-email: jian.luo.cn(at_)gmail.com
    :license: LGPL, see LICENSE for details
    :revision: $Id: top.py 6 2010-11-21 23:18:44Z rockee $
"""

from myhdl import *
from defines import *
from functions import *
from core import *
from uart import *
from bram import *

program = []

def prepare():
    one = open('rom.vmem')
    banks = [open('rom%s.vmem'%i, 'w') for i in range(4)]
    try:
        for line in one.readlines():
            program.append(int(line, 16))
            for i in range(4):
                print >>banks[3-i], line[i*2:(i+1)*2]
    finally:
        [f.close() for f in banks]
        one.close()
        
def Program(data_out, data_in, address, write, enable, clock, *args, **kw):
    imem = tuple(program)
    @always(clock.posedge)
    def output():
        #if enable:
            data_out.next = imem[address[:2]]
    return instances()
    
def SysTop(txd_line, rxd_line, txd_line2, rxd_line2, leds, reset, clock,

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

        debug_dmem_ena_in=0,
        debug_dmem_data_in=0,
        debug_dmem_data_out=0,
        debug_dmem_sel_out=0,
        debug_dmem_we_out=0,
        debug_dmem_addr_out=0,
        debug_dmem_ena_out=0,
        debug_dmem_ena=0,

        debug_imem_data_in=0,
        debug_imem_data_out=0,
        debug_imem_sel_out=0,
        debug_imem_we_out=0,
        debug_imem_addr_out=0,
        debug_imem_ena=0,
        debug_imem_ena_out=0,

        size=4, DEBUG=True):
    rx_data = Signal(intbv(0)[32:])
    rx_avail = Signal(False)
    rx_error = Signal(False)
    read_en = Signal(False)
    tx_data = Signal(intbv(0)[32:])
    tx_busy = Signal(False)
    write_en = Signal(False)
    uart_rxd = Signal(False)
    uart_txd = Signal(False)

    rx_data2 = Signal(intbv(0)[32:])
    rx_avail2 = Signal(False)
    rx_error2 = Signal(False)
    read_en2 = Signal(False)
    tx_data2 = Signal(intbv(0)[32:])
    tx_busy2 = Signal(False)
    write_en2 = Signal(False)
    uart_rxd2 = Signal(False)
    uart_txd2 = Signal(False)

    led_reg = Signal(intbv(0)[32:])
    led_low = Signal(intbv(0)[32:])

    dmem_ena_in = Signal(False)
    dmem_data_in = Signal(intbv(0)[CFG_DMEM_WIDTH:])
    dmem_data_out = Signal(intbv(0)[CFG_DMEM_WIDTH:])
    dmem_sel_out = Signal(intbv(0)[4:])
    dmem_sel = Signal(intbv(0)[4:])
    dmem_we_out = Signal(False)
    dmem_addr_out = Signal(intbv(0)[CFG_DMEM_SIZE:])
    dmem_ena_out = Signal(False)
    dmem_ena = Signal(False)

    imem_data_in = Signal(intbv(0)[CFG_DMEM_WIDTH:])
    imem_data_out = Signal(intbv(0)[CFG_IMEM_WIDTH:])
    imem_sel_out = Signal(intbv(0)[4:])
    imem_we_out = Signal(False)
    imem_addr_out = Signal(intbv(0)[CFG_IMEM_SIZE:])
    imem_ena = Signal(True)
    imem_ena_out = Signal(False)

    imem = BankedBRAM(imem_data_in, imem_data_out, imem_addr_out,
                      imem_sel_out, imem_ena_out, clock,
                     size=size, to_verilog=True,
                     filename_pattern='rom%s.vmem')
    #imem = Program(imem_data_in, imem_data_out, imem_addr_out,
                      #imem_sel_out, imem_ena_out, clock,
                     #size=size, to_verilog=True,
                     #filename_pattern='rom%s.vmem')
    dmem = BankedBRAM(dmem_data_in, dmem_data_out, dmem_addr_out,
                      dmem_sel, dmem_ena, clock,
                     size=size, to_verilog=True,
                     filename_pattern='rom%s.vmem')

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

        # Ports only for debug
        debug_if_program_counter=debug_if_program_counter,

        debug_of_alu_op=debug_of_alu_op,
        debug_of_alu_src_a=debug_of_alu_src_a,
        debug_of_alu_src_b=debug_of_alu_src_b,
        debug_of_branch_cond=debug_of_branch_cond,
        debug_of_carry=debug_of_carry,
        debug_of_carry_keep=debug_of_carry_keep,
        debug_of_delay=debug_of_delay,
        debug_of_hazard=debug_of_hazard,
        debug_of_immediate=debug_of_immediate,
        debug_of_instruction=debug_of_instruction,
        debug_of_mem_read=debug_of_mem_read,
        debug_of_mem_write=debug_of_mem_write,
        debug_of_operation=debug_of_operation,
        debug_of_program_counter=debug_of_program_counter,
        debug_of_reg_a=debug_of_reg_a,
        debug_of_reg_b=debug_of_reg_b,
        debug_of_reg_d=debug_of_reg_d,
        debug_of_reg_write=debug_of_reg_write,
        debug_of_transfer_size=debug_of_transfer_size,

        debug_of_fwd_mem_result=debug_of_fwd_mem_result,
        debug_of_fwd_reg_d=debug_of_fwd_reg_d,
        debug_of_fwd_reg_write=debug_of_fwd_reg_write,

        debug_gprf_dat_a=debug_gprf_dat_a,
        debug_gprf_dat_b=debug_gprf_dat_b,
        debug_gprf_dat_d=debug_gprf_dat_d,

        debug_ex_alu_result=debug_ex_alu_result,
        debug_ex_reg_d=debug_ex_reg_d,
        debug_ex_reg_write=debug_ex_reg_write,

        debug_ex_branch=debug_ex_branch,
        debug_ex_dat_d=debug_ex_dat_d,
        debug_ex_flush_id=debug_ex_flush_id,
        debug_ex_mem_read=debug_ex_mem_read,
        debug_ex_mem_write=debug_ex_mem_write,
        debug_ex_program_counter=debug_ex_program_counter,
        debug_ex_transfer_size=debug_ex_transfer_size,

        debug_ex_dat_a=debug_ex_dat_a,
        debug_ex_dat_b=debug_ex_dat_b,
        debug_ex_instruction=debug_ex_instruction,
        debug_ex_reg_a=debug_ex_reg_a,
        debug_ex_reg_b=debug_ex_reg_b,

        debug_mm_alu_result=debug_mm_alu_result,
        debug_mm_mem_read=debug_mm_mem_read,
        debug_mm_reg_d=debug_mm_reg_d,
        debug_mm_reg_write=debug_mm_reg_write,
        debug_mm_transfer_size=debug_mm_transfer_size,

        DEBUG=DEBUG,
    )

    uart = UART(rx_data, rx_avail, rx_error, read_en,
           tx_data, tx_busy, write_en,
           uart_rxd, uart_txd, reset, clock,
           freq_hz=50000000, baud=115200)

    uart2 = UART(rx_data2, rx_avail2, rx_error2, read_en2,
           tx_data2, tx_busy2, write_en2,
           uart_rxd2, uart_txd2, reset, clock,
           freq_hz=50000000, baud=115200)

    @always_comb
    def glue():
        dmem_ena_in.next = True
        if dmem_we_out:
            dmem_sel.next = dmem_sel_out
        else:
            dmem_sel.next = 0
        tx_data.next = dmem_data_out
        if dmem_addr_out < 2**size:
            dmem_ena.next = dmem_ena_out
            write_en.next = False
        elif dmem_we_out and dmem_addr_out[28:] >= 0xfffffc0:
            dmem_ena.next = False
            dmem_ena_in.next = not tx_busy
            write_en.next = True
        else:
            write_en.next = False
            dmem_ena.next = False

        #leds.next = concat(led_reg[4:], led_low[4:])
        leds.next = led_reg[8:]
        
    count = Signal(intbv(0)[20:])
    @always(clock.posedge)
    def run():
        
        if reset:
            txd_line.next = False
            txd_line2.next = False
            led_reg.next = 1
            led_low.next = 1
            imem_data_out.next = 0
            imem_sel_out.next = 0
            read_en.next = False
            uart_rxd.next = 1
            read_en2.next = False
            uart_rxd2.next = 1
            count.next = 0
        else:
            txd_line.next = uart_txd
            uart_rxd.next = rxd_line
            txd_line2.next = uart_txd2
            uart_rxd2.next = rxd_line2
            read_en.next = False
            count.next = (count+1)%(2**20)
            #if count == 0:
                #led_low.next = concat(led_low[31:], led_low[31])

            #if write_en and not tx_busy:
                #led_reg.next = concat(led_reg[31:], led_reg[31])
            if dmem_we_out and dmem_addr_out[28:] == 0xFFFFFB0:
                led_reg.next = dmem_data_out
            else:
                led_reg.next = led_reg
            #led_reg.next = concat(dmem_ena_in, dmem_we_out, dmem_ena_out,
                #write_en,)
            #if imem_addr_out == 0x244:
                #led_reg.next = 0xff


    @always_comb
    def debug_output():
        debug_dmem_ena_in.next = dmem_ena_in
        debug_dmem_data_in.next = dmem_data_in
        debug_dmem_data_out.next = dmem_data_out
        debug_dmem_sel_out.next = dmem_sel_out
        debug_dmem_we_out.next = dmem_we_out
        debug_dmem_addr_out.next = dmem_addr_out
        debug_dmem_ena_out.next = dmem_ena_out
        debug_dmem_ena.next = dmem_ena

        debug_imem_data_in.next = imem_data_in
        debug_imem_data_out.next = imem_data_out
        debug_imem_sel_out.next = imem_sel_out
        debug_imem_we_out.next = imem_we_out
        debug_imem_addr_out.next = imem_addr_out
        debug_imem_ena.next = imem_ena
        debug_imem_ena_out.next = imem_ena_out

    if DEBUG:
        return imem, dmem, core, uart, uart2, glue, run, debug_output
    
    return imem, dmem, core, uart, uart2, glue, run

import sys
from numpy import log2

def TopBench():
    prepare()
    size = int(log2(int(sys.argv[1]))) if len(sys.argv) > 1 else 4
    print 'size=%s' % size

    txd_line = Signal(False)
    rxd_line = Signal(False)
    txd_line2 = Signal(False)
    rxd_line2 = Signal(False)
    leds = Signal(intbv(0)[8:])
    reset = Signal(False)
    clock = Signal(False)


    debug_if_program_counter = Signal(intbv(0)[CFG_IMEM_SIZE:])

    debug_gprf_dat_a = Signal(intbv(0)[CFG_DMEM_WIDTH:])
    debug_gprf_dat_b = Signal(intbv(0)[CFG_DMEM_WIDTH:])
    debug_gprf_dat_d = Signal(intbv(0)[CFG_DMEM_WIDTH:])

    debug_of_alu_op = Signal(alu_operation.ALU_ADD)
    debug_of_alu_src_a = Signal(src_type_a.REGA)
    debug_of_alu_src_b = Signal(src_type_b.REGB)
    debug_of_branch_cond = Signal(branch_condition.NOP)
    debug_of_carry = Signal(carry_type.C_ZERO)
    debug_of_carry_keep = Signal(False)
    debug_of_delay = Signal(False)
    debug_of_hazard = Signal(False)
    debug_of_immediate = Signal(intbv(0)[CFG_DMEM_WIDTH:])
    debug_of_instruction = Signal(intbv(0)[CFG_IMEM_WIDTH:])
    debug_of_mem_read = Signal(False)
    debug_of_mem_write = Signal(False)
    debug_of_operation = Signal(False)
    debug_of_program_counter = Signal(intbv(0)[CFG_IMEM_SIZE:])
    debug_of_reg_a = Signal(intbv(0)[5:])
    debug_of_reg_b = Signal(intbv(0)[5:])
    debug_of_reg_d = Signal(intbv(0)[5:])
    debug_of_reg_write = Signal(False)
    debug_of_transfer_size = Signal(transfer_size_type.WORD)

    # Write back stage forwards
    debug_of_fwd_mem_result = Signal(intbv(0)[CFG_DMEM_WIDTH:])
    debug_of_fwd_reg_d = Signal(intbv(0)[5:])
    debug_of_fwd_reg_write = Signal(False)

    debug_ex_alu_result = Signal(intbv(0)[CFG_DMEM_WIDTH:])
    debug_ex_reg_d = Signal(intbv(0)[5:])
    debug_ex_reg_write = Signal(False)

    debug_ex_branch = Signal(False)
    debug_ex_dat_d = Signal(intbv(0)[CFG_DMEM_WIDTH:])
    debug_ex_flush_id = Signal(False)
    debug_ex_mem_read = Signal(False)
    debug_ex_mem_write = Signal(False)
    debug_ex_program_counter = Signal(intbv(0)[CFG_IMEM_SIZE:])
    debug_ex_transfer_size = Signal(transfer_size_type.WORD)

    debug_ex_dat_a = Signal(intbv(0)[CFG_DMEM_WIDTH:])
    debug_ex_dat_b = Signal(intbv(0)[CFG_DMEM_WIDTH:])
    debug_ex_instruction = Signal(intbv(0)[CFG_DMEM_WIDTH:])
    debug_ex_reg_a = Signal(intbv(0)[5:])
    debug_ex_reg_b = Signal(intbv(0)[5:])

    debug_mm_alu_result = Signal(intbv(0)[CFG_DMEM_WIDTH:])
    debug_mm_mem_read = Signal(False)
    debug_mm_reg_d = Signal(intbv(0)[5:])
    debug_mm_reg_write = Signal(False)
    debug_mm_transfer_size = Signal(transfer_size_type.WORD)

    debug_dmem_ena_in = Signal(False)
    debug_dmem_data_in = Signal(intbv(0)[CFG_DMEM_WIDTH:])
    debug_dmem_data_out = Signal(intbv(0)[CFG_DMEM_WIDTH:])
    debug_dmem_sel_out = Signal(intbv(0)[4:])
    debug_dmem_we_out = Signal(False)
    debug_dmem_addr_out = Signal(intbv(0)[CFG_DMEM_SIZE:])
    debug_dmem_ena_out = Signal(False)
    debug_dmem_ena = Signal(False)

    debug_imem_data_in = Signal(intbv(0)[CFG_DMEM_WIDTH:])
    debug_imem_data_out = Signal(intbv(0)[CFG_IMEM_WIDTH:])
    debug_imem_sel_out = Signal(intbv(0)[4:])
    debug_imem_we_out = Signal(False)
    debug_imem_addr_out = Signal(intbv(0)[CFG_IMEM_SIZE:])
    debug_imem_ena = Signal(True)
    debug_imem_ena_out = Signal(False)

    top = SysTop(txd_line, rxd_line, txd_line2, rxd_line2, leds, reset, clock,
    
        # Ports only for debug
        debug_if_program_counter,

        debug_of_alu_op,
        debug_of_alu_src_a,
        debug_of_alu_src_b,
        debug_of_branch_cond,
        debug_of_carry,
        debug_of_carry_keep,
        debug_of_delay,
        debug_of_hazard,
        debug_of_immediate,
        debug_of_instruction,
        debug_of_mem_read,
        debug_of_mem_write,
        debug_of_operation,
        debug_of_program_counter,
        debug_of_reg_a,
        debug_of_reg_b,
        debug_of_reg_d,
        debug_of_reg_write,
        debug_of_transfer_size,

        debug_of_fwd_mem_result,
        debug_of_fwd_reg_d,
        debug_of_fwd_reg_write,

        debug_gprf_dat_a,
        debug_gprf_dat_b,
        debug_gprf_dat_d,

        debug_ex_alu_result,
        debug_ex_reg_d,
        debug_ex_reg_write,

        debug_ex_branch,
        debug_ex_dat_d,
        debug_ex_flush_id,
        debug_ex_mem_read,
        debug_ex_mem_write,
        debug_ex_program_counter,
        debug_ex_transfer_size,

        debug_ex_dat_a,
        debug_ex_dat_b,
        debug_ex_instruction,
        debug_ex_reg_a,
        debug_ex_reg_b,

        debug_mm_alu_result,
        debug_mm_mem_read,
        debug_mm_reg_d,
        debug_mm_reg_write,
        debug_mm_transfer_size,

        debug_dmem_ena_in,
        debug_dmem_data_in,
        debug_dmem_data_out,
        debug_dmem_sel_out,
        debug_dmem_we_out,
        debug_dmem_addr_out,
        debug_dmem_ena_out,
        debug_dmem_ena,

        debug_imem_data_in,
        debug_imem_data_out,
        debug_imem_sel_out,
        debug_imem_we_out,
        debug_imem_addr_out,
        debug_imem_ena,
        debug_imem_ena_out,

        size=size)
        
    @instance
    def clockgen():
        yield delay(10)
        clock.next = False
        while 1:
            yield delay(10)
            clock.next = not clock

    @instance
    def stimulus():
        reset.next = False
        yield delay(37)
        reset.next = True
        yield delay(53)
        reset.next = False
        for i in range(3000):
            yield clock.negedge
        reset.next = False
        yield delay(37)
        reset.next = True
        yield delay(53)
        reset.next = False
        for i in range(3000):
            yield clock.negedge

        raise StopSimulation

    @instance
    def monitor():
        while 1:
            yield clock.posedge
            #if debug_dmem_ena_in:
                #print '%x' % debug_ex_program_counter

            #if debug_ex_program_counter == 0x0:
                #print 'reach the start 00000000'
            #if debug_ex_program_counter == 0x244:
                #print 'reach the second xil_print call'
            if debug_dmem_addr_out == 0xffffffc0:
                #if debug_dmem_sel_out == 0b1000:
                if debug_dmem_we_out:
                    sys.stdout.write(chr(int(debug_dmem_data_out[8:])))
                    sys.stdout.flush()
                    #print int(debug_dmem_data_out[8:])
                    #print 'output: %d' % debug_dmem_data_out[8:]




            #print 'if_pc: %x\timem_addr: %x\treset: %x' % (
                #debug_if_program_counter, debug_imem_addr_out, reset
            #)
            #print ('of_pc: %x\tof_instruction:%x'
                   ##'\tbranch_cond:%s\talu_op:%s'
                   #'\thazard:%x') % (
                #debug_of_program_counter, debug_of_instruction,
                ##debug_of_branch_cond, debug_of_alu_op,
                #debug_of_hazard,
            #)
            #print 'ex_pc: %x\tex_instruction:%x' % (
                #debug_ex_program_counter,
                #debug_ex_instruction,
            #)
            #print 'Ra: r%d=%x\tRb: r%d=%x\t-> Rd:%d\tdat_d:%x\talu_result: %x\tbranch: %x' % (
                #debug_ex_reg_a, debug_ex_dat_a,
                #debug_ex_reg_b, debug_ex_dat_b,
                #debug_ex_reg_d, debug_ex_dat_d,
                #debug_ex_alu_result,
                #debug_ex_branch,
            #)
            #print 'ex_mem_read %s ex_mem_write %s' % (
                #debug_ex_mem_read, debug_ex_mem_write)
            #print ''




            #if enable and not ex_r_flush_ex: # and (ex_comb_r_reg_write
                    ##or ex_comb_mem_read or ex_comb_mem_write): # and DEBUG_VERBOSE:
            ##if DEBUG_VERBOSE:
                #print 'EX:',
                #dissembly(of_program_counter,
                          #of_instruction,
                          #ex_comb_r_reg_d,
                          #of_reg_a, 
                          #of_reg_b,
                          #ex_comb_dat_d,
                          #ex_comb_dat_a,
                          #ex_comb_dat_b, 
                          #ex_comb_r_alu_result,
                          #True)
                #print "\t",of_alu_op, of_alu_src_a, of_alu_src_b, of_immediate.signed()
                #print "\treg_write:=%s mem_read:=%s mem_write:=%s branch:=%s flush_ex:=%s" % (
                    #ex_comb_r_reg_write,ex_comb_mem_read,ex_comb_mem_write,
                    #ex_comb_branch, ex_comb_r_flush_ex)
                #print ''
                #if of_program_counter == 0x244:
                    #raw_input()
            

    return instances()
    
if __name__ == '__main__':
  if 0:
    tb = traceSignals(TopBench)
    Simulation(tb).run()
    #conversion.verify.simulator = 'icarus'
    #conversion.verify(TopBench)
  else:
    prepare()
    txd_line = Signal(False)
    rxd_line = Signal(False)
    txd_line2 = Signal(False)
    rxd_line2 = Signal(False)
    leds = Signal(intbv(0)[8:])
    reset = Signal(False)
    clock = Signal(False)
    size = int(log2(int(sys.argv[1]))) if len(sys.argv) > 1 else 4
    print 'size=%s' % size
    #toVHDL(uart_test_top, txd_line, rxd_line, leds, reset, clock)
    toVerilog(SysTop, txd_line, rxd_line, txd_line2, rxd_line2, leds, reset,
            clock, size=size, DEBUG=False)
        
        

### EOF ###
# vim:smarttab:sts=4:ts=4:sw=4:et:ai:tw=80:

