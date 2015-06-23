# -*- coding: utf-8 -*-
"""
    gprf.py
    =======

    General purpose Register File
    
    :copyright: Copyright (c) 2010 Jian Luo
    :author-email: jian.luo.cn(at_)gmail.com
    :license: LGPL, see LICENSE for details
    :revision: $Id: gprf.py 6 2010-11-21 23:18:44Z rockee $
"""

from myhdl import *
from defines import *
from functions import *
from dsram import *
#from debug import *

def GPRF(
        clock,
        enable,
        gprf_adr_a_i,
        gprf_adr_b_i,
        gprf_adr_d_i,
        gprf_dat_w_i,
        gprf_adr_w_i,
        gprf_wre_i,
        gprf_dat_a_o,
        gprf_dat_b_o,
        gprf_dat_d_o,
        ):
    a = DSRAM(gprf_dat_a_o, gprf_adr_a_i, enable,
              gprf_dat_w_i, gprf_adr_w_i, gprf_wre_i, clock,
              width=CFG_DMEM_WIDTH, size=CFG_GPRF_SIZE)
    b = DSRAM(gprf_dat_b_o, gprf_adr_b_i, enable,
              gprf_dat_w_i, gprf_adr_w_i, gprf_wre_i, clock,
              width=CFG_DMEM_WIDTH, size=CFG_GPRF_SIZE)
    d = DSRAM(gprf_dat_d_o, gprf_adr_d_i, enable,
              gprf_dat_w_i, gprf_adr_w_i, gprf_wre_i, clock,
              width=CFG_DMEM_WIDTH, size=CFG_GPRF_SIZE)

    #if __debug__:
        #@instance
        #def show():
            #while DEBUG_VERBOSE:
                #yield clock.posedge
                ##print 'tick'
                #addr_a = gprf_adr_a_i
                #addr_b = gprf_adr_b_i
                #addr_d = gprf_adr_d_i
                #if enable and gprf_wre_i:
                    #print 'gprf:\twrite:\t',
                    #print 'Rd := R%d<-0x%x' % (gprf_adr_w_i, gprf_dat_w_i)
                #yield delay(1)
                #if enable:
                    #print 'gprf:\tread:\t',
                    #print ('Ra := R%d->0x%x, Rb := R%d->0x%x, Rd := R%d->0x%x'
                           #% (addr_a, gprf_dat_a_o,
                              #addr_b, gprf_dat_b_o,
                              #addr_d, gprf_dat_d_o))

            
    return instances()

### EOF ###
# vim:smarttab:sts=4:ts=4:sw=4:et:ai:tw=80:

