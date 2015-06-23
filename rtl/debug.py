# -*- coding: utf-8 -*-
"""
    debug.py
    ========

    Debug functions
    
    :copyright: Copyright (c) 2010 Jian Luo.
    :author-email: jian.luo.cn(at_)gmail.com.
    :license: LGPL, see LICENSE for details.
    :revision: $Id: debug.py 6 2010-11-21 23:18:44Z rockee $
"""

import re

__re_dis=re.compile(r' *(?P<addr>[0-9a-f]+):\s+(?P<opcode>[0-9a-f]{8})\s+.*')
__dissembly = open('rom.dump').readlines()
__code = {}
for line in __dissembly:
    if line.find('debug')>0:
        break
    c = __re_dis.match(line)
    if c:
        __code[int(c.group('addr'), 16)] = line.strip()

def dissembly(address, opcode, rd=None, ra=None, rb=None,
                               dat_d=None, dat_a=None, dat_b=None,
                               alu_result=None, showreg=False):
    source = __code.get(int(address), '0'*8)
    if source.find('%08x' % opcode) >= 0:
        print '<match>: %s' % source
    else:
        print ''
        print '\tFATAL: NOT MATCH'
        print '\topcode:=%08x; expected:=%s' % (int(opcode), source)
    if not showreg:
        return
    print '\tRd: R%d=%d(%x) Ra: R%d=%d(%x) Rb: R%d=%d(%x) ALU: %d(%x)' % (
            rd, dat_d, dat_d, ra, dat_a, dat_a,
            rb, dat_b, dat_b, alu_result, alu_result)



### EOF ###
# vim:smarttab:sts=4:ts=4:sw=4:et:ai:tw=80:

