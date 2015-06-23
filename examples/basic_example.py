#!/usr/bin/env python
# -*- coding: utf-8 -*-

#
# NoCmodel basic example
#
# Author:  Oscar Diaz
# Version: 0.1
# Date:    03-03-2011

#
# This code is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This code is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the
# Free Software  Foundation, Inc., 59 Temple Place, Suite 330,
# Boston, MA  02111-1307  USA
#

#
# Changelog:
#
# 03-03-2011 : (OD) initial release
#

import myhdl
import logging

from nocmodel import *
from nocmodel.basicmodels import *

# Basic example model with TBM simulation

# 1. Create the model

basicnoc = noc(name="Basic 2x2 NoC example")

# 1.1 create a rectangular 2x2 NoC, make its connections and add default protocol

R11 = basicnoc.add_router("R11", with_ipcore=True, coord_x = 1, coord_y = 1)
R12 = basicnoc.add_router("R12", with_ipcore=True, coord_x = 1, coord_y = 2)
R21 = basicnoc.add_router("R21", with_ipcore=True, coord_x = 2, coord_y = 1)
R22 = basicnoc.add_router("R22", with_ipcore=True, coord_x = 2, coord_y = 2)

basicnoc.add_channel(R11,R12)
basicnoc.add_channel(R11,R21)
basicnoc.add_channel(R12,R22)
basicnoc.add_channel(R21,R22)

basicnoc.protocol_ref = basic_protocol()

for r in basicnoc.router_list():
    r.update_ports_info()
    r.update_routes_info()

# 2. add tbm support, and configure logging
add_tbm_basic_support(basicnoc, log_file="simulation.log", log_level=logging.DEBUG)

# 3. Declare generators to put in the TBM simulation

# set ip_cores functionality as myhdl generators
def sourcegen(din, dout, tbm_ref, mydest, data=None, startdelay=100, period=100):
    # this generator only drives dout
    @myhdl.instance
    def putnewdata():
        datacount = 0
        protocol_ref = tbm_ref.ipcore_ref.get_protocol_ref()
        mysrc = tbm_ref.ipcore_ref.router_ref.address
        tbm_ref.debug("sourcegen: init dout is %s" % repr(dout.val))
        yield myhdl.delay(startdelay)
        while True:
            if len(data) == datacount:
                tbm_ref.debug("sourcegen: end of data. waiting for %d steps" % (period*10))
                yield myhdl.delay(period*10)
                raise myhdl.StopSimulation("data ended at time %d" % myhdl.now())
            dout.next = protocol_ref.newpacket(False, mysrc, mydest, data[datacount])
            tbm_ref.debug("sourcegen: data next element %d dout is %s datacount is %d" % (data[datacount], repr(dout.val), datacount))
            yield myhdl.delay(period)
            datacount += 1
    return putnewdata
    
def checkgen(din, dout, tbm_ref, mysrc, data=None):
    # this generator only respond to din
    @myhdl.instance
    def checkdata():
        datacount = 0
        protocol_ref = tbm_ref.ipcore_ref.get_protocol_ref()
        mydest = tbm_ref.ipcore_ref.router_ref.address
        while True:
            yield din
            if len(data) > datacount:
                checkdata = din.val["data"]
                tbm_ref.debug("checkgen: assert checkdata != data[datacount] => %d != %d [%d]" % (checkdata, data[datacount], datacount))
                if checkdata != data[datacount]:
                    tbm_ref.error("checkgen: value != %d (%d)" % (data[datacount], checkdata))
                tbm_ref.debug("checkgen: assert source address != mysrc => %d != %d " % (din.val["src"], mysrc))
                if din.val["src"] != mysrc:
                    tbm_ref.error("checkgen: source address != %d (%d)" % (mysrc, din.val["src"]))
                tbm_ref.debug("checkgen: assert destination address != mydest => %d != %d " % (din.val["dst"], mydest))
                if din.val["dst"] != mydest:
                    tbm_ref.error("checkgen: destination address != %d (%d)" % (mydest, din.val["dst"]))
                datacount += 1
    return checkdata

# 4. Set test vectors
R11_testdata = [5, 12, 50, -11, 6, 9, 0, 3, 25]
R12_testdata = [x*5 for x in R11_testdata]

# 5. assign generators to ip cores (in TBM model !)
# R11 will send to R22, R12 will send to R21
R11.ipcore_ref.tbm.register_generator(sourcegen, mydest=R22.address, data=R11_testdata, startdelay=10, period=20)
R12.ipcore_ref.tbm.register_generator(sourcegen, mydest=R21.address, data=R12_testdata, startdelay=15, period=25)
R21.ipcore_ref.tbm.register_generator(checkgen, mysrc=R12.address, data=R12_testdata)
R22.ipcore_ref.tbm.register_generator(checkgen, mysrc=R11.address, data=R11_testdata)
       
# 6. configure simulation and run!
basicnoc.tbmsim.configure_simulation(max_time=1000)
print "Starting simulation..."
basicnoc.tbmsim.run()
print "Simulation finished. Pick the results in log files."

# 7. View graphical representation

draw_noc(basicnoc)
