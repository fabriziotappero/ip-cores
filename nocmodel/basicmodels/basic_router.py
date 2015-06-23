#!/usr/bin/env python
# -*- coding: utf-8 -*-

#
# Basic Router model
#  * TBM model
#  * Code generation model
#
# Author:  Oscar Diaz
# Version: 0.2
# Date:    14-03-2011

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
# 14-03-2011 : (OD) adding code generation model
#

"""
* Basic router TBM model
* Router code generation model
"""

from nocmodel.noc_tbm_base import *
from nocmodel.noc_codegen_base import *
from intercon_model import *

# ---------------------------
# Router TBM model

class basic_router_tbm(noc_tbm_base):
    """
    TBM model of a NoC router. This router uses store-and-forward technique, 
    using the routing information from the router object. This model just
    forward the packet, and if the packet is in its router destination, send it
    to its ipcore. Each package that the ipcore generates is delivered 
    automátically.
    
    Attributes:
    * router_ref : base reference
    * fifo_len: max number of packets to hold in each port
    
    Notes:
    * This model is completely behavioral.
    * See code comments to better understanding.
    """
    def __init__(self, router_ref, fifo_len=5):
        noc_tbm_base.__init__(self)
        if isinstance(router_ref, router):
            self.router_ref = router_ref
            self.graph_ref = router_ref.graph_ref
            self.logname = "Router '%s'" % router_ref.name
            if router_ref.name == "":
                self.logname = "Router addr '%s'" % router_ref.address
        else:
            raise TypeError("This class needs a router object as constructor argument.")
        
        self.debug("constructor")
        
        # generic parameters
        self.fifo_len = fifo_len

        # delay parameters
        self.delay_route = 5        # delay for each routing decisition
        self.delay_outfromfifo = 2  # delay for extract packet from fifo to output port
        self.delay_ipcorebus = 1    # delay for ipcore local bus operations
        
        # router parameters (Assume rectangular coords)
        self.myaddress = router_ref.address
        self.mynodecoord = (router_ref.coord_x, router_ref.coord_y)

        # port additions: use a copy of the ports list, and add
        # fifo storage and signal events
        router_ref.update_ports_info()
        self.ports_info = router_ref.ports.copy()
        for p in self.ports_info.itervalues():
            p["fifo_in"] = []
            p["fifo_out"] = []
            p["fifo_in_event"] = myhdl.Signal(False)
            p["fifo_out_event"] = myhdl.Signal(False)
        self.idlesignal = myhdl.Signal(True)

        # extract a list of all fifo event signals
        self.list_fifo_in_events = [i["fifo_in_event"] for i in self.ports_info.itervalues()]
        self.list_fifo_out_events = [i["fifo_out_event"] for i in self.ports_info.itervalues()]

        # the routing table is generated from the routes_info dict
        # key: its destination address
        # values: a list of ports where the package should send it. First element
        #    is the default option, next elements are alternate routes
        router_ref.update_routes_info()
        self.detailed_routingtable = self.router_ref.routes_info.copy()
        self.routingtable = {}
        for dest, data in self.detailed_routingtable.iteritems():
            self.routingtable[dest] = [x["next"] for x in data]
        # add route to myself
        self.routingtable[self.myaddress] = [self.myaddress]
        
        # log interesting info
        self.info(" router params: fifo_len=%d" % self.fifo_len)
        self.info(" router info: addr=%d coord=%s" % (self.myaddress, repr(self.mynodecoord)))
        self.info(" router ports: %s" % repr(self.ports_info))
        self.info(" router routing table: %s" % repr(self.routingtable))

        # myhdl generators (concurrent processes)
        self.generators = []
        
        # fifo out process
        @myhdl.instance
        def flush_fifo_out():
            while True:
                for port, data in self.ports_info.iteritems():
                    if len(data["fifo_out"]) > 0:
                        self.idlesignal.next = False
                        if not data["fifo_out_event"].val:
                            self.debug("flush_fifo_out CATCH fifo not empty and NO trigger! fifo has %s" % repr(data["fifo_out"]))
                        self.info("flush_fifo_out event in port %d" % port)
                        packet = data["fifo_out"].pop(0)
                        self.debug("flush_fifo_out port %d packet is %s (delay %d)" % (port, repr(packet), self.delay_outfromfifo))
                        # DELAY model: time to move from fifo to external port in destination object
                        yield myhdl.delay(self.delay_outfromfifo)
                        self.idlesignal.next = False
                        # try to send it
                        retval = self.send(self.router_ref, data["channel"], packet)
                        if retval == noc_tbm_errcodes.no_error:
                            # clean trigger
                            data["fifo_out_event"].next = False
                            self.debug("flush_fifo_out clean trigger. list %s" % repr(self.list_fifo_out_events))
                            #continue
                        else:
                            self.error("flush_fifo_out FAILED in port %d (code %d)" % (port, retval))
                            # error management: 
                            #TODO: temporally put back to fifo
                            self.info("flush_fifo_out packet went back to fifo.")
                            data["fifo_out"].append(packet)
                    else:
                        if data["fifo_out_event"].val:
                            self.debug("flush_fifo_out CATCH fifo_out empty and trigger ON! Cleaning trigger")
                            data["fifo_out_event"].next = False
                self.idlesignal.next = True
                yield self.list_fifo_out_events
                self.debug("flush_fifo_out event hit. list %s" % repr(self.list_fifo_out_events))

        # routing loop
        @myhdl.instance
        def routing_loop():
            while True:
                # routing update: check all fifos
                for port, data in self.ports_info.iteritems():
                    while len(data["fifo_in"]) > 0:
                        self.idlesignal.next = False
                        if not data["fifo_in_event"].val:
                            self.debug("routing_loop CATCH fifo not empty and NO trigger! fifo has %s" % repr(data["fifo_in"]))
                        self.info("routing_loop fifo_in event in port %d" % port)
                        # data in fifo
                        packet = data["fifo_in"].pop(0)
                        data["fifo_in_event"].next = False
                        self.debug("routing_loop port %d packet %s to ipcore (delay %d)" % (port, repr(packet), self.delay_route))
                        # destination needed. extract from routing table
                        destaddr = packet["dst"]
                        self.debug("routing_loop port %d routingtable %s (dest %d)" % (port, repr(self.routingtable), destaddr))
                        nextaddr = self.routingtable[destaddr][0]
                        self.debug("routing_loop port %d to port %s (dest %d)" % (port, nextaddr, destaddr))
                        # DELAY model: time spent to make a route decisition
                        yield myhdl.delay(self.delay_route)
                        self.idlesignal.next = False
                        self.ports_info[nextaddr]["fifo_out"].append(packet)
                        # fifo trigger
                        if self.ports_info[nextaddr]["fifo_out_event"]:
                            self.debug("routing_loop CATCH possible miss event because port %d fifo_out_event=True", self.myaddress)
                        self.ports_info[nextaddr]["fifo_out_event"].next = True
                    # assuming empty fifo_in
                    if data["fifo_in_event"].val:
                        self.debug("routing_loop CATCH fifo_in empty and trigger ON! Cleaning trigger")
                        data["fifo_in_event"].next = False
                self.idlesignal.next = True
                self.debug("routing_loop idle. fifo_in_events list %s" % repr(self.list_fifo_in_events))
                if not any(self.list_fifo_in_events):
                    yield self.list_fifo_in_events
                else:
                    self.debug("routing_loop pending fifo_in_events list %s" % repr(self.list_fifo_in_events))
                self.debug("routing_loop fifo_in event hit. list %s" % repr(self.list_fifo_in_events))

        # list of all generators
        self.generators.extend([flush_fifo_out, routing_loop])
        self.debugstate()

    # Transaction - related methods
    def send(self, src, dest, packet, addattrs=None):
        """
        This method will be called on a fifo available data event
        
        Notes: 
        * Ignore src object.
        * dest should be a channel object, but also can be a router address or
          a router object.
        """
        self.debug("-> send( %s , %s , %s , %s )" % (repr(src), repr(dest), repr(packet), repr(addattrs)))
        if isinstance(dest, int):
            # it means dest is a router address
            therouter = self.graph_ref.get_router_by_address(dest)
            if therouter == False:
                self.error("-> send: dest %s not found" % repr(dest) )
                return noc_tbm_errcodes.tbm_badcall_send
            # extract channel ref from ports_info
            thedest = self.ports_info[therouter.address]["channel"]
        elif isinstance(dest, router):
            # extract channel ref from ports_info
            thedest = self.ports_info[dest.address]["channel"]
        elif isinstance(dest, channel):
            # use it directly
            thedest = dest
        else:
            self.error("-> send: what is dest '%s'?" % repr(dest) )
            return noc_tbm_errcodes.tbm_badcall_send

        # call recv on the dest channel object
        retval = thedest.tbm.recv(self.router_ref, thedest, packet, addattrs)

        # TODO: something to do with the retval?
        self.debug("-> send returns code '%s'" % repr(retval))
        return retval
    
    def recv(self, src, dest, packet, addattrs=None):
        """
        This method will be called by channel objects connected to this router.
        
        Notes:
        * The recv method only affect the receiver FIFO sets
        * Ignore dest object.
        """
        
        self.debug("-> recv( %s , %s , %s , %s )" % (repr(src), repr(dest), repr(packet), repr(addattrs)))
        # src can be an address or a noc object.
        # convert to addresses
        if isinstance(src, int):
            thesrc = src
        elif isinstance(src, router):
            thesrc = src.address
        elif isinstance(src, channel):
            # get address from the other end. Use the endpoints to calculate
            # source router
            src_index = src.endpoints.index(self.router_ref) - 1
            theend = src.endpoints[src_index]
            if isinstance(theend, router):
                thesrc = theend.address
            elif isinstance(theend, ipcore):
                thesrc = theend.router_ref.address
            else:
                self.error("-> recv: what is endpoint '%s' in channel '%s'?" % (repr(theend), repr(src)) )
                return noc_tbm_errcodes.tbm_badcall_recv
        else:
            self.error("-> recv: what is src '%s'?" % repr(src) )
            return noc_tbm_errcodes.tbm_badcall_recv

        # thesrc becomes the port number
        # check if there is enough space on the FIFO
        if len(self.ports_info[thesrc]["fifo_in"]) == self.fifo_len:
            # full FIFO
            self.error("-> recv: full fifo. Try later.")
            self.debug("-> recv: port %s fifo_in contents: %s" % (thesrc, repr(self.ports_info[thesrc]["fifo_in"])))
            return noc_tbm_errcodes.full_fifo
        # get into fifo
        self.ports_info[thesrc]["fifo_in"].append(packet)
        # trigger a new routing event
        if self.ports_info[thesrc]["fifo_in_event"].val:
            self.debug("-> recv: CATCH possible miss event because in port %d fifo_in_event=True", thesrc)
            self.debug("-> recv: CATCH fifo_in_event list %s" % repr(self.list_fifo_in_events))
        self.ports_info[thesrc]["fifo_in_event"].next = True

        self.debug("-> recv returns 'noc_tbm_errcodes.no_error'")
        return noc_tbm_errcodes.no_error

# ---------------------------
# Router code generation model

class basic_router_codegen(noc_codegen_ext):
    """
    Code generation extension for Router objects.
    """
    
    def __init__(self, codegen_ref):
        noc_codegen_ext.__init__(self, codegen_ref)
        self.router_ref = codegen_ref.nocobject_ref
        if not isinstance(self.router_ref, router):
            raise TypeError("Argument must be a 'noc_codegen_base' instance defined for a router object.")

        # router model: This basic router has some parameters put in the 
        # generics list, and a fixed number of NoC ports: 4. 
        
        # assumptions: use 4 ports 'dualwb_intercon' plus 1 port 'slavewb_intercon'
        
        codegen_ref.modulename = "basic_4P_router"
        
        # 1. convert basic attributes to generics
        codegen_ref.add_generic("name", self.router_ref.name, "Router Name")
        codegen_ref.add_generic("address", self.router_ref.address, "Router Address")
        # assuming rectangular layout
        codegen_ref.add_generic("coord_x", self.router_ref.coord_x, "Router X-axis Coord")
        codegen_ref.add_generic("coord_y", self.router_ref.coord_y, "Router Y-axis Coord")
        
        # 2. Calculate which of 4 ports is used by who
        portinfo = {"N": None, "E": None, "S": None, "W": None}
        for pname, pvalues in self.router_ref.ports.iteritems():
            if pname != self.router_ref.address:
                # check correct intercon
                if not isinstance(pvalues["channel"].ports[self.router_ref.address]["intercon"], dualwb_intercon):
                    raise UserWarning("Port '%d' on router '%s' does not use intercon 'dualwb_intercon'." % (pname, self.router_ref.name))
                # calculate which port
                dx = self.router_ref.coord_x - pvalues["peer"].coord_x
                dy = self.router_ref.coord_y - pvalues["peer"].coord_y
                if dx == 0:
                    if dy > 0:
                        portinfo["S"] = pname
                    else:
                        portinfo["N"] = pname
                if dy == 0:
                    if dx > 0:
                        portinfo["W"] = pname
                    else:
                        portinfo["E"] = pname
            else:
                # check correct intercon
                if not isinstance(pvalues["channel"].ports[self.router_ref.address]["intercon"], slavewb_intercon):
                    raise UserWarning("Port 'Local' on router '%s' does not use intercon 'slavewb_intercon'." % self.router_ref.name)
        
        icon_ref = dualwb_intercon()
        # 3. Add ports and info through generics
        for pname, pvalue in portinfo.iteritems():
            # add new port
            pstr = "Port%s" % pname
            codegen_ref.add_port(pstr, None, "Port %s" % pname, type=icon_ref.intercon_type, nocport=pvalue)
            for signame, sigval in icon_ref.signals.iteritems():
                stmp = get_new_signal(
                    name=signame, 
                    direction=sigval["direction"], 
                    default_value=intbv(0)[sigval["width"]:], 
                    description=sigval["description"])
                codegen_ref.add_port(pstr, stmp)
            # determine if the port is used
            if pvalue is None:
                penable = 0
                paddr = 0
            else:
                penable = 1
                paddr = pvalue
            codegen_ref.add_generic("Use_Port%s" % pname, penable, "Is Port%s being used?" % pname)
            codegen_ref.add_generic("Dest_Port%s" % pname, paddr, "Dest address in Port%s" % pname)
        # 4. Local port
        icon_ref = slavewb_intercon()
        codegen_ref.add_port("PortLocal", None, "Port Local", type=icon_ref.intercon_type)
        for signame, sigval in icon_ref.signals.iteritems():
            stmp = get_new_signal(
                name=signame, 
                direction=sigval["direction"], 
                default_value=intbv(0)[sigval["width"]:], 
                description=sigval["description"])
            codegen_ref.add_port("PortLocal", stmp)
        
        # 5. Calculate a hash with generics and ports info. This hash will help 
        # codegen to establish equivalent router implementations.
        codegen_ref.model_hash()

        # 6. Implementation comment
        codegen_ref.implementation += "-- Add here implementation code for Router %s" % self.router_ref.name
