# -*- coding: utf-8 -*-
"""
    LUTs.py
    =============

    Lookup tables for sinus and division calculation
    
    :copyright: Copyright (c) 2010 Jian Luo
    :author-email: jian.luo.cn(at_)gmail.com
    :license: LGPL, see LICENSE for details
    :revision: $Id: lut.py 5 2010-11-21 10:59:30Z rockee $
"""

from numpy import *
from myhdl import *
from fixed_point import fxintbv,fxint

__all__ = ['ROM', 'LZD', 'GS_R0_Gen',
           'get_lzd_width', 'get_gs_entry_shape']

def my_bin(x, w=16):
    l = len(bin(x))
    return ''.join(['0'*(w-l), bin(x)])


###########
# General #
###########

def ROM(dout, addr, CONTENT):
    """
    General ROM implementation
    """
    @always_comb
    def read():
        dout.next = CONTENT[int(addr)]
    return instances()


##########################
# Leading Zero Detection #
##########################

def count_l_zeros(x, width=8):
    """
    Helper for count leading zeros

    x:      input digit
    width:  bitwidth of x
    """
    count = 0
    for i in downrange(width):
        y = (x>>i) & 1
        if y:
            break
        else:
            count += 1
    return count

def get_lzd_width(width):
    """
    Get word length of counter for leading zero detector
    """
    return int(ceil(log2(width)))

def LZD(dout, index, width=16, depth=1, top=None, offset=0):
    """
    Higher-half LUT of leading zeros for 16bit digits
    """
    if not top:
        top=width
    if depth == 0:  # Leaf LUT
        # Prepare contents
        LZeros = tuple([(count_l_zeros(x, width=width)+offset)%top for x in range(2**width)])
        lut = ROM(dout, index, LZeros)
    else:           # Recursive create 2 half LUTs
        half_width = width / 2
        assert half_width * 2 == width, (
            "Word length of %s can't be evenly divided into 2 parts." % width
        )

        # Glue signals
        index_h = Signal(intbv(0)[half_width:])
        index_l = Signal(intbv(0)[half_width:])
        dout_h = Signal(intbv(0)[len(dout):])
        dout_l = Signal(intbv(0)[len(dout):])
        high = LZD(dout_h, index_h, width=half_width,
                    offset=offset, depth=depth-1, top=top)
        low = LZD(dout_l, index_l, width=half_width, top=top,
                    offset=offset+half_width, depth=depth-1)

        @always_comb
        def input():
            index_h.next = index[:half_width]
            index_l.next = index[half_width:]

        @always_comb
        def output():
            if index_h == 0:
                dout.next = dout_l
            else:
                dout.next = dout_h

    return instances()


##############################
# R0 of Goldschmidt Division #
##############################

def get_gs_entry_shape(width, index_width):
    w = index_width
    ww = width
    r_wl = around(w*1.5)                # Word length of table entry
    r_iwl = ceil(log2(1.0*ww/w))        # Integer word length
    return (int(r_iwl), int(r_wl-r_iwl))

def gen_GSDiv_R0(width=16, index_width=8, debug=0, roundMode='round_even'):
    """
    Generates table of R0 for Goldschmidt division

    width -- Bitwidth of divisor
    index_width -- Number of leading bits for indexing lut.
                   While the first bit of divisor is always 1, so actually only
                   index_width - 1 bits will be used for indexing.
    R_Q -- Representation of entry in the table
    """
    R0=[]
    w = index_width
    ww = width
    r_Q = get_gs_entry_shape(ww, w) # Shape of entries
    for ii in range(2**(w-1), 2**w):
        try:
            val = (ii<<(w)) + (1<<(w-1))
            d0 = fxint(val/(2.0**(ww)), Q=(0,ww), roundMode=roundMode)
            #R0.append(fxint(2.0**(ww)/d0, Q=r_Q, roundMode='round'))
            r = fxint(1./d0.fValue, Q=r_Q, roundMode=roundMode)
            R0.append(r[r_Q[0]+r_Q[1]:])# roundMode='round'))
        except:
            print ii
            raise

    # Check if the table fulfills our requirements:
    #   generate "index_width" bits of leading '1's or '0's
    if debug:
        # Do tests
        for i in range(2**(w-1)):
            ii = (1<<(w-1)) | i
            if debug > 1:
                print '\ndh=%3d' % ii
            dh = ii<<w
            r0 = fxint(int(R0[i]), Q=r_Q, roundMode=roundMode)
            for dl in range(2**(w-1)):
                d = fxint((dh + dl)/2.0**(ww), Q=(0,ww), roundMode=roundMode)
                q = d*r0
                q.Q = (1,ww)
                bs = bin(q)
                if bs.startswith('10'):
                    c = bs[1:].find('1')
                else:
                    c = bs.find('0')
                if c<0:
                    c = q.fwl
                if debug > 1:
                    print '%s(%-8f) x %s(%-8f) = %s(%-14s):%s c=%2d' % (
                                d.Bit(), d.fValue, r0.Bit(), r0.fValue,
                                q.Bit(), q.fValue, q.rep, c
                            )
                if c < w:
                    raise

    return map(int, R0)

def GS_R0_Gen(dout, index, width=16, index_width=8, debug=0, roundMode='round_even'):
    """
    Generator of R0 for GoldSchmidt division, implemented as a lookup table
    
    width -- Word width
    index_width -- index width
    """
    addr_width = index_width - 1 # msb is always 1, while index >= 0.5
    msb = width - 1
    lsb = msb - addr_width
    R0 = tuple(gen_GSDiv_R0(width=width, index_width=index_width, debug=debug, roundMode=roundMode))
    # Only index_width - 1 bits are needed for indexing
    addr = Signal(intbv(0)[addr_width:])
    lut = ROM(dout, addr, R0)

    @always_comb
    def decode():
        #addr_i = intbv(0)[index_width-1:]
        #addr_i = index[:index_width]
        #addr.next = addr_i[addr_width:]
        addr.next = index[msb:lsb]

    return instances()
    

#############
# unit test #
#############

def tb_lzd():
    width = 16
    clk = Signal(False)
    d = Signal(intbv(0)[width:])
    lzeros = Signal(intbv(0)[get_lzd_width(width):])
    lzd = LZD(lzeros, d, width=width, depth=1)

    @always(delay(10))
    def clkgen():
        clk.next = not clk

    @instance
    def stim():
        yield delay(1)
        while 1:
            print 'd=%17s lzd=%d' % (my_bin(d,16), lzeros)
            if d >= 256:
                d.next = (d+(1 << 8)) % 65536
            else:
                d.next = d + 1
            yield clk.posedge

    #@always(clk.negedge)
    #def monitor():
        ## moniting on negedge 

    return instances()
    
def tb_gs_r0():
    width = 16
    iw = 8
    clk = Signal(False)
    d = Signal(fxintbv(0.5, Q=(0,width)))
    qt = get_gs_entry_shape(width, iw)
    r = Signal(fxintbv(0, Q=qt))
    q = Signal(fxintbv(0, Q=(qt[0],width)))
    gsr0 = GS_R0_Gen(r, d, index_width=iw)
    print qt

    @always(delay(10))
    def clkgen():
        clk.next = not clk

    @instance
    def stim():
        yield delay(1) # load r
        while d.fValue < 1:
            q.next = intbv(d.value*r.value)[:qt[0]+qt[1]-1].signed()
            yield delay(1)
            print 'd=%s(%f) * r=%s(%f) == q=%s(%f) %f' % (
                d.Bit(), d.fValue, r.Bit(), r.fValue,
                q.Bit(), q.fValue, 1.0/d.fValue)
            d.next = d.value + 1
            yield clk.posedge

    return instances()
    
def test_conv():
    rQ = get_gs_entry_shape(16, 8)
    addr = Signal(intbv(0)[16:])
    dout = Signal(intbv(0)[4:])
    rout = Signal(fxintbv(0, Q=rQ))
    toVHDL(LZD, dout, addr)
    toVHDL(GS_R0_Gen, rout, addr, debug=0)
    #gen_GSDiv_R0(debug=True)
    
if __name__ == '__main__':
    test_conv()
    tb = tb_gs_r0()
    #tb = tb_lzd()
    #gen_GSDiv_R0(debug=2)
    ##tb = traceSignals(tb_reciprocal)
    Simulation(tb).run()

### EOF ###
# vim:smarttab:sts=4:ts=4:sw=4:et:ai:

