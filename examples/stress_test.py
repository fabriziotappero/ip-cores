#!/usr/bin/env python
# -*- coding: utf-8 -*-

#
# NoCmodel stress test
#
# Author:  Oscar Diaz
# Version: 0.1
# Date:    20-05-2011

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
# 20-05-2011 : (OD) initial release
#

import myhdl
import logging
import random
import time
import os

from nocmodel import *
from nocmodel.basicmodels import *

# Stress test: generate a list of random sends and receives through all the NoC.

sim_starttime = 10
sim_maxtime = 1000
sim_sendtime = 900
sim_meanperiod = 30 # fifo full using 13
sim_stddevperiod = 3

# 1. Create the model

basicnoc = generate_squarenoc(3, with_ipcore=True)

basicnoc.protocol_ref = basic_protocol()

basicnoc.update_nocdata()

# 2. add tlm support, and configure logging
add_tbm_basic_support(basicnoc, log_file="simulation.log", log_level=logging.DEBUG)
# 2.1 setup byobject logging
if not os.access("/tmp/stress_test_log/", os.F_OK):
    os.mkdir("/tmp/stress_test_log/")
basicnoc.tbmsim.configure_byobject_logging(basefilename="/tmp/stress_test_log/stress", log_level=logging.DEBUG)

# 3. Prepare random packets
def do_checkvect(basicnoc, sim_starttime, sim_sendtime, sim_meanperiod, sim_stddevperiod):
    checkvect = {}
    testvect = {}
    for r in basicnoc.router_list():
        # generate the time instants for sending, its destination and packet value
        tvec = [abs(int(x + random.gauss(0, sim_stddevperiod))) + sim_starttime for x in range(0, sim_sendtime, sim_meanperiod)]
        # delete possible repeated values and sort time instants
        tvec = list(set(tvec))
        tvec.sort()
        #avail_dest = r.routingtable.keys().remove(r.get_address())
        avail_dest = r.routes_info.keys()
        dest = [random.choice(avail_dest) for x in tvec]
        value = [random.randrange(65536) for x in tvec]
        # generate a list of "test vectors": (<time>, <dest>, <value>)
        r.ipcore_ref.tbm.testvect = zip(tvec, dest, value)
        testvect[r.get_address()] = r.ipcore_ref.tbm.testvect
        # generate a list of expected values at every router destination
        # "check vectors" is: {dest : (<time from src>, <src>, <value>)}
        for i, d in enumerate(dest):
            if d in checkvect:
                checkvect[d].append(tuple([tvec[i], r.get_address(), value[i]]))
            else:
                checkvect[d] = [tuple([tvec[i], r.get_address(), value[i]])]
    # sort each checkvect by time
    for vect in checkvect.itervalues():
        vect.sort(key=lambda x: x[0])
    # put checkvects in each destination router
    for r in basicnoc.router_list():
        r.ipcore_ref.tbm.checkvect = checkvect[r.get_address()]
    with open("vectors.txt", "w") as f:
        f.write("testvect = %s\n" % repr(testvect))
        f.write("checkvect = %s\n" % repr(checkvect))
    #return (testvect, checkvect)
    
try:
    execfile("vectors.txt")
    for r in basicnoc.router_list():
        r.ipcore_ref.tbm.testvect = testvect[r.get_address()]
        r.ipcore_ref.tbm.checkvect = checkvect[r.get_address()]
    print "Using vectors.txt for test"
except:
    do_checkvect(basicnoc, sim_starttime, sim_sendtime, sim_meanperiod, sim_stddevperiod)
    print "Created new vectors for test"

# 3. Declare generators to put in the TBM simulation: 
# double generators that runs its own test vector and checks the expected results

# set ip_cores functionality as myhdl generators
def sourcechkgen(din, dout, tbm_ref):
    """
    This generator drives dout based on gen_data vectors
    and reacts to din to check with chk_data vectors.
    """
    # prepare data indexes for check vectors
    check_dict = {}
    for idx, val in enumerate(tbm_ref.checkvect):
        check_dict[val[2]] = idx
    received_idx = [False]*len(tbm_ref.checkvect)
    
    @myhdl.instance
    def datagen():
        datacount = 0
        protocol_ref = tbm_ref.ipcore_ref.get_protocol_ref()
        mysrc = tbm_ref.ipcore_ref.get_address()
        tbm_ref.debug("sourcechkgen.datagen: init dout is %s" % repr(dout.val))
        gen_data = tbm_ref.testvect
        
        for test_vector in gen_data:
            # test_vector : (<time>, <dest>, <value>)
            next_delay = test_vector[0] - myhdl.now()
            yield myhdl.delay(next_delay)
            dout.next = protocol_ref.newpacket(False, mysrc, test_vector[1], test_vector[2])
            tbm_ref.debug("sourcechkgen.datagen: sent test vector <%s>, dout is %s" % (repr(test_vector), repr(dout.val)))
        # wait for end of simulation
        tbm_ref.debug("sourcechkgen.datagen: test vectors exhausted. Going idle.")
        # TODO: check an easy way to go idle in MyHDL
        #next_delay = sim_maxtime - myhdl.now()
        #yield myhdl.delay(next_delay)
        #raise myhdl.StopSimulation("sourcechkgen.datagen: End of simulation")
        return

    @myhdl.instance
    def datacheck():
        protocol_ref = tbm_ref.ipcore_ref.get_protocol_ref()
        mydest = tbm_ref.ipcore_ref.get_address()
        check_data = tbm_ref.checkvect
        while True:
            # just check for data reception
            yield din
            # check packet
            inpacket = din.val
            # search checkvect by data payload
            chkidx = check_dict.get(inpacket["data"])
            if chkidx is None:
                tbm_ref.error("sourcechkgen.datacheck: unexpected packet : %s" % repr(inpacket))
            else:
                # check vectors : (<time from src>, <src>, <value>)
                expected_vector = check_data[chkidx]
                # received packet: report it
                received_idx[chkidx] = True
                # data was checked before. Inform about packet delay
                tbm_ref.debug("sourcechkgen.datacheck: (delay %d) packet received : <%s>, expected src=<%s>, value=<%s> " % (myhdl.now() - expected_vector[0], repr(inpacket), repr(expected_vector[1]), repr(expected_vector[2])))
                if inpacket["src"] != expected_vector[1]:
                    tbm_ref.error("sourcechkgen.datacheck: source address != %d (%d)" % (expected_vector[1], inpacket["src"]))
                if inpacket["dst"] != mydest:
                    tbm_ref.error("sourcechkgen.datacheck: destination address != %d (%d)" % (mydest, inpacket["dst"]))
            
    @myhdl.instance
    def finalcheck():
        while True:
            yield myhdl.delay(sim_maxtime - 1)
            # final check: missing packets
            tbm_ref.debug("sourcechkgen.finalcheck: check for missing packets.")
            if not all(received_idx):
                # missing packets:
                miss_count = len(received_idx) - sum(received_idx)
                tbm_ref.error("sourcechkgen.finalcheck: there are %d missing packets!" % miss_count)
                for idx, val in enumerate(tbm_ref.checkvect):
                    if not received_idx[idx]:
                        tbm_ref.debug("sourcechkgen.finalcheck: missing packet: <%s>" % repr(val))
                        
       
    return (datagen, datacheck, finalcheck)

# 5. assign generators to ip cores (in TLM model !)
for r in basicnoc.router_list():
    r.ipcore_ref.tbm.register_generator(sourcechkgen)
       
# 6. configure simulation and run!
basicnoc.tbmsim.configure_simulation(max_time=sim_maxtime)
print "Starting simulation..."
runsecs = time.clock()
basicnoc.tbmsim.run()
runsecs = time.clock() - runsecs
print "Simulation finished in %f secs. Pick the results in log files." % runsecs

# 7. View graphical representation

draw_noc(basicnoc)
