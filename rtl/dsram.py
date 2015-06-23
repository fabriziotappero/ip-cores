# -*- coding: utf-8 -*-
"""
    dsram.py
    ========

    Dual port synchronous ram
    
    :copyright: Copyright (c) 2010 Jian Luo
    :author-email: jian.luo.cn(at_)gmail.com
    :license: LGPL, see LICENSE for details
    :revision: $Id: dsram.py 6 2010-11-21 23:18:44Z rockee $
"""

from myhdl import *
from defines import *
from functions import *

def DSRAM(dat_o, adr_i, ena_i, dat_w_i, adr_w_i, wre_i, clock,
           width=32, size=8):
    """
    Dual port synchronous RAM with New Data Read-During-Write Behavior
    """
    ram = [Signal(intbv(0)[width:]) for i in range(2**size)]
    @always(clock.posedge)
    def logic():
        if ena_i:
            if wre_i:
                ram[int(adr_w_i)].next = dat_w_i
            dat_o.next = ram[int(adr_i)]

    return instances()
                
### EOF ###
# vim:smarttab:sts=4:ts=4:sw=4:et:ai:tw=80:

