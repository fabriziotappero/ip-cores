# -*- coding: utf-8 -*-
"""
    bram.py
    =======

    Block RAM
    
    :copyright: Copyright (c) 2010 Jian Luo
    :author-email: jian.luo.cn(at_)gmail.com
    :license: LGPL, see LICENSE for details
    :revision: $Id: bram.py 6 2010-11-21 23:18:44Z rockee $
"""

from myhdl import *
from defines import *
from functions import *
from debug import *

def BRAMInitial(ram, filename, clock):
    __verilog__ = """
    initial $readmemh("%(filename)s", %(ram)s);
    """
    __vhdl__ = """
    """
    @instance
    def initial():
        vals = open(filename).readlines()
        for i,v in enumerate(vals):
            ram[i].next = int(v, 16)
        yield clock.negedge
    return instances()

# XXX: Hacked to make $readmemh work
class RAM(list):
    # representation 
    def __str__(self):
        from myhdl._extractHierarchy import _memInfoMap
        if id(self) in _memInfoMap:
            return _memInfoMap[id(self)].name
        else:
            return list.__str__(self)

def BRAM(
        data_out,
        data_in,
        address,
        write,
        enable,
        clock,
        width=8,
        size=16,
        filename='',
        ):
    """
    Single Port Synchronous RAM with Old Data Read-During-Write Behavior
    """
    max = 2**size
    ram = RAM(Signal(intbv(0)[width:]) for i in range(max))
    if filename:
        init = BRAMInitial(ram, filename, clock)

    @always(clock.posedge)
    def logic():
        if enable:
            if write:
                ram[int(address)].next = data_in
            data_out.next = ram[int(address)%max]

    return instances()

def BankedBRAM(
        data_out,
        data_in,
        address,
        write,
        enable,
        clock,
        width=32,
        bank_size=2,
        size=16,
        to_verilog=1,
        filename_pattern='',
        ):
    # XXX: Verilog just don't allow dynamic register slicing
    # have to fix ram shape to 4x8bit
    if to_verilog:
        width=32
        bank_size=2
    bank_count = 2 ** bank_size
    bank_width = width/bank_count
    bank_in = [Signal(intbv(0)[bank_width:]) for i in range(bank_count)]
    bank_out = [Signal(intbv(0)[bank_width:]) for i in range(bank_count)]
    bank_wre = [Signal(False) for i in range(bank_count)]
    bank_addr = Signal(intbv(0)[len(address)-bank_size:])
    if filename_pattern:
        bank = [BRAM(data_out=bank_out[i], data_in=bank_in[i],
                     address=bank_addr, write=bank_wre[i],
                     enable=enable, clock=clock,
                     width=bank_width, size=size-bank_size,
                     filename=filename_pattern%i)

                    for i in range(bank_count)]
    else:
        bank = [BRAM(data_out=bank_out[i], data_in=bank_in[i],
                     address=bank_addr, write=bank_wre[i],
                     enable=enable, clock=clock,
                     width=bank_width, size=size-bank_size,)

                    for i in range(bank_count)]
        
    if to_verilog:
        @always_comb
        def reassemble():
            bank_addr.next = address[:bank_size]
            for i in range(bank_count):
                bank_wre[i].next = write[i]
            bank_in[0].next = data_in[8:]
            bank_in[1].next = data_in[16:8]
            bank_in[2].next = data_in[24:16]
            bank_in[3].next = data_in[32:24]
            data_out.next = concat(bank_out[3], bank_out[2],
                                   bank_out[1], bank_out[0])
            
    else:
        @always_comb
        def reassemble():
            bank_addr.next = address[:bank_size]
            tmp = intbv(0)[width:]
            tmp_low = intbv(0)[width-bank_width:]
            for i in range(bank_count):
                bank_wre[i].next = write[i]
                bank_in[i].next = data_in[(i+1)*bank_width:i*bank_width]
                tmp_low[:] = tmp[:bank_width]
                tmp[:] = concat(bank_out[i], tmp_low)
            data_out.next = tmp

    return bank, reassemble

if __name__ == '__main__':
    data_out = Signal(intbv(0)[32:])
    data_in = Signal(intbv(0)[32:])
    address = Signal(intbv(0)[16:])
    write = Signal(intbv(0)[4:])
    bram_write = Signal(False)
    clock = Signal(False)
    enable = Signal(False)
    bram_kw = dict(
        func=BRAM,
        data_out=data_out,
        data_in=data_in,
        address=address,
        write=bram_write,
        enable=enable,
        clock=clock,
        width=32,
        size=8,
        filename='rom.vmem',
    )
    kw = dict(
        data_out=data_out,
        data_in=data_in,
        address=address,
        write=write,
        enable=enable,
        clock=clock,
        width=32,
        bank_size=2,
        size=8,
        filename_pattern='rom%d.vmem',
    )
    toVerilog(BankedBRAM, to_verilog=True, **kw)
    #toVerilog(**bram_kw)
    toVHDL(BankedBRAM, **kw)

### EOF ###
# vim:smarttab:sts=4:ts=4:sw=4:et:ai:tw=80:

