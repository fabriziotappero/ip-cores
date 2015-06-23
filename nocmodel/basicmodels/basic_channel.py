#!/usr/bin/env python
# -*- coding: utf-8 -*-

#
# Basic Channel model
#  * TBM model
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

"""
Basic channel TBM model
"""

from nocmodel.noc_tbm_base import *

# ---------------------------
# Channel TBM model

class basic_channel_tbm(noc_tbm_base):
    """
    TBM model of a NoC channel. It models a simple FIFO channel with
    adjustable delay. This channel will move any kind of data as a whole, but
    ideally will move packet objects.
        
    Attributes:
    * Channel delay: delay in clock ticks.
    
    Notes:
    *This model is completely behavioral
    """
    def __init__(self, channel_ref, channel_delay=2):
        noc_tbm_base.__init__(self)
        if isinstance(channel_ref, channel):
            self.channel_ref = channel_ref
            self.graph_ref = channel_ref.graph_ref
            self.logname = "Channel '%s'" % channel_ref.name
        else:
            raise TypeError("This class needs a channel object as constructor argument.")

        self.debug("constructor")

        # channel parameters
        self.channel_delay = channel_delay

        # list of router endpoints
        self.endpoints = self.channel_ref.endpoints

        # generators
        self.generators = []

        self.has_delay = False
        if self.channel_delay > 0:
            self.has_delay = True
            self.delay_fifo = []
            self.delay_fifo_max = 4 # error-catch parameter, avoid fifo excessive growing
            self.delay_event = myhdl.Signal(False)
            # implement delay generator
            @myhdl.instance
            def delay_generator():
                while True:
                    while len(self.delay_fifo) > 0:
                        # extract packet and recorded time
                        timed_packet = self.delay_fifo.pop(0)
                        # calculate the exact delay value
                        next_delay = self.channel_delay - (myhdl.now() - timed_packet[0])
                        # time could be 0, when the packets arrive from both endpoints
                        # at the same time. In that case don't yield
                        if next_delay < 0:
                            self.debug("delay_generator CATCH next_delay is '%d'" % next_delay)
                        elif next_delay > 0:
                            yield myhdl.delay(next_delay)
                        self.debug("delay_generator sending delayed packet (by %d), timed_packet format %s" % (next_delay, repr(timed_packet)) )
                        # use send()
                        retval = self.send(*timed_packet[1:])
                        # what to do in error case? report and continue
                        if retval != noc_tbm_errcodes.no_error:
                            self.error("delay_generator send returns code '%d'?" % retval )
                    self.delay_event.next = False
                    yield self.delay_event.posedge
            self.generators.append(delay_generator)

        self.debugstate()

    # channel only relays transactions
    # Transaction - related methods
    def send(self, src, dest, packet, addattrs=None):
        """
        This method will be called by recv (no delay) or by delay_generator
        src always is self
        """
        # dest MUST be one of the channel endpoints
        self.debug("-> send( %s , %s , %s , %s )" % (repr(src), repr(dest), repr(packet), repr(addattrs)))
        if isinstance(dest, int):
            # assume router direction
            thedest = self.graph_ref.get_router_by_address(dest)
            if thedest == False:
                self.error("-> send: dest %s not found" % repr(dest) )
                return noc_tbm_errcodes.tbm_badcall_send
        elif isinstance(dest, (router, ipcore)):
            thedest = dest
        else:
            self.error("-> send: what is dest '%s'?" % repr(dest) )
            return noc_tbm_errcodes.tbm_badcall_send

        # check dest as one of the channel endpoints
        if thedest not in self.endpoints:
            self.error("-> send: object %s is NOT one of the channel endpoints [%s,%s]" % (repr(thedest), repr(self.endpoints[0]), repr(self.endpoints[1])) )
            return noc_tbm_errcodes.tbm_badcall_send
            
        # call trace functions
        traceargs = {"self": self, "src": src, "dest": dest, "packet": packet, "addattrs": addattrs}
        for f in self.tracesend:
            if callable(f):
                f(traceargs)

        # call recv on the dest object
        retval = thedest.tbm.recv(self.channel_ref, dest, packet, addattrs)

        # Something to do with the retval? Only report it.
        self.debug("-> send returns code '%s'" % repr(retval))
        return retval

    def recv(self, src, dest, packet, addattrs=None):
        """
        receive a packet from an object. src is the object source and
        it MUST be one of the objects in channel endpoints
        """

        self.debug("-> recv( %s , %s , %s , %s )" % (repr(src), repr(dest), repr(packet), repr(addattrs)))
        # src can be an address or a noc object.
        if isinstance(src, int):
            # assume router direction
            thesrc = self.graph_ref.get_router_by_address(src)
            if thesrc == False:
                self.error("-> recv: src %s not found" % repr(src) )
                return noc_tbm_errcodes.tbm_badcall_recv
        elif isinstance(src, (router, ipcore)):
            thesrc = src
        else:
            self.error("-> recv: what is src '%s'?" % repr(src) )
            return noc_tbm_errcodes.tbm_badcall_recv

        # check src as one of the channel endpoints
        if thesrc not in self.endpoints:
            self.error("-> recv: object %s is NOT one of the channel endpoints [%s,%s]" % (repr(thesrc), repr(self.endpoints[0]), repr(self.endpoints[1])) )
            return noc_tbm_errcodes.tbm_badcall_recv
            
        # call trace functions        
        for f in self.tracerecv:
            if callable(f):
                traceargs = {"self": self, "src": src, "dest": dest, "packet": packet, "addattrs": addattrs}
                f(traceargs)

        # calculate the other endpoint
        end_index = self.endpoints.index(thesrc) - 1

        if self.has_delay:
            # put in delay fifo: store time and call attributes
            self.delay_fifo.append([myhdl.now(), self.channel_ref, self.endpoints[end_index], packet, addattrs])
            self.debug("-> recv put in delay_fifo (delay %d)" % self.channel_delay)
            # catch growing fifo
            if len(self.delay_fifo) > self.delay_fifo_max:
                self.warning("-> recv: delay_fifo is getting bigger! current size is %d" % len(self.delay_fifo) )
            # trigger event
            self.delay_event.next = True
            retval = noc_tbm_errcodes.no_error
        else:
            # use send() call directly
            router_dest = self.endpoints[end_index]
            retval = self.send(self.channel_ref, router_dest, packet, addattrs)

        self.debug("-> recv returns code '%d'", retval)
        return retval
