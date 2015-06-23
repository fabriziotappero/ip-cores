#!/usr/bin/env python
# -*- coding: utf-8 -*-

#
# Basic IPcore model
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
* Basic ipcore TBM model
* Ipcore code generation model
"""

from nocmodel.noc_tbm_base import *
from nocmodel.noc_codegen_base import *
from intercon_model import *

# ---------------------------
# Basic IPCore TBM model

class basic_ipcore_tbm(noc_tbm_base):
    """
    TBM model of a NoC ipcore. Its based on sending and receiving packets
    to a custom-based MyHDL generators. This class does not define any
    functionality.
    
    Attributes:
    * ipcore_ref: reference to ipcore base object
    
    Notes:
    * This model is completely behavioral.
    * See code comments to better understanding.
    """
    def __init__(self, ipcore_ref):
        noc_tbm_base.__init__(self)
        if isinstance(ipcore_ref, ipcore):
            self.ipcore_ref = ipcore_ref
            self.graph_ref = ipcore_ref.graph_ref
            self.logname = "IPCore '%s'" % ipcore_ref.name
            if ipcore_ref.name == "":
                self.logname = "IPCore '%s'" % ipcore_ref.router_ref.name
        else:
            raise TypeError("This class needs a ipcore object as constructor argument.")
        
        self.debug("constructor")
        # generic parameters
        self.retrytimes = 3
        self.retrydelay = 2

        # one-port support: get a reference to the related channel
        self.localch = self.ipcore_ref.channel_ref

        # get protocol reference
        self.protocol_ref = self.ipcore_ref.get_protocol_ref()
        
        # bidirectional port: the sender part will write data to the signal 
        # outgoing_packet. This class provides a generator thar call send() 
        # method when there is new data. 
        # for receiving data, recv() method will write
        # to the signal incoming_packet, and the ipcore must provide a generator 
        # sensible to that signal. Use the method register_generator()
        self.incoming_packet = myhdl.Signal(packet())
        self.outgoing_packet = myhdl.Signal(packet())
        
        @myhdl.instance
        def outgoing_process():
            while True:
                yield self.outgoing_packet
                # multiple tries
                for i in range(self.retrytimes):
                    retval = self.send(self.ipcore_ref, self.localch, self.outgoing_packet.val)
                    if retval == noc_tbm_errcodes.no_error:
                        break;
                    yield myhdl.delay(self.retrydelay)
        
        self.generators = [outgoing_process]
        self.debugstate()

    def register_generator(self, genfunction, **kwargs):
        """
        Register a new generator for this ipcore. 
        
        Arguments:
        * genfunction: function that returns a MyHDL generator
        * kwargs: optional keyed arguments to pass to genfunction call
        
        Notes:
        * This method requires that genfunction has the following prototype:
            * my_function(din, dout, tbm_ref, <other_arguments>)
                * din is a MyHDL Signal of type packet, and is the input signal 
                  to the ipcore. Use this signal to react to input events and 
                  receive input packets.
                * dout is a MyHDL Signal of type packet, and is the output 
                  signal to the ipcore. Use this signal to send out packets to
                  local channel (and then insert into the NoC).
                * tbm_ref is a reference to an object with logging methods. 
                  (e.g. tbm_ref.info("message") ).
                * <other_arguments> may be defined, this method use kwargs 
                  argument to pass them.
        """
        makegen = genfunction(din=self.incoming_packet, dout=self.outgoing_packet, tbm_ref=self, **kwargs)
        self.debug("register_generator( %s ) generator is %s args %s" % (repr(genfunction), repr(makegen), repr(kwargs)))
        self.generators.append(makegen)

    # Transaction - related methods
    def send(self, src, dest, packet, addattrs=None):
        """
        Assumptions: 
        * Safely ignore src and dest arguments, because this method 
          is called only by this object generators, therefore it always send 
          packets to the ipcore related channel.
        * In theory src should be self.ipcore_ref, and dest should be 
          self.localch . This may be checked for errors.
        """
        self.debug("-> send( %s , %s , %s , %s )" % (repr(src), repr(dest), repr(packet), repr(addattrs)))

        # call recv on the local channel object
        retval = self.localch.tbm.recv(self.ipcore_ref, self.localch, packet, addattrs)
        
        # something to do with the retval? Only report it.
        self.debug("-> send returns code '%s'" % repr(retval))
        return retval
    
    def recv(self, src, dest, packet, addattrs=None):
        """
        Assumptions: 
        * Safely ignore src and dest arguments, because this method 
          is called only by local channel object.
        * In theory src should be self.localch, and dest should be 
          self.ipcore_ref . This may be checked for errors.
        """
        self.debug("-> recv( %s , %s , %s , %s )" % (repr(src), repr(dest), repr(packet), repr(addattrs)))

        # update signal
        self.incoming_packet.next = packet

        self.debug("-> recv returns 'noc_tbm_errcodes.no_error'")
        return noc_tbm_errcodes.no_error

# ---------------------------
# Ipcore code generation model

class basic_ipcore_codegen(noc_codegen_ext):
    """
    Code generation extension for Ipcore objects.
    """
    
    def __init__(self, codegen_ref):
        noc_codegen_ext.__init__(self, codegen_ref)
        #self.codegen_ref = codegen_ref
        self.ipcore_ref = codegen_ref.nocobject_ref
        if not isinstance(self.ipcore_ref, ipcore):
            raise TypeError("Argument must be a 'noc_codegen_base' instance defined for a ipcore object.")

        # ipcore model: This basic ipcore has some parameters put in the 
        # generics list, and only one port of type masterwb.
        
        codegen_ref.modulename = "basic_ipcore"
        
        # 1. convert some attributes to generics
        codegen_ref.add_generic("name", self.ipcore_ref.name, "Ipcore Name")
        codegen_ref.add_generic("address", self.ipcore_ref.router_ref.address, "Ipcore router Address")
        
        # 2. check intercon on ipcore port
        
        ch = self.ipcore_ref.channel_ref
        icon = ch.ports[None]["intercon"]
        if not isinstance(icon, masterwb_intercon):
            raise UserWarning("Port Local on ipcore '%s' does not use intercon 'masterwb_intercon'." % self.ipcore_ref.name)
        
        # 2. convert ipcore port to codegen port
        codegen_ref.add_port("PortLocal", None, "Port Local", type=icon.intercon_type)
        
        for signame, sigval in icon.signals.iteritems():
            stmp = get_new_signal(
                name=signame, 
                direction=sigval["direction"], 
                default_value=intbv(0)[sigval["width"]:], 
                description=sigval["description"])
            codegen_ref.add_port("PortLocal", stmp)
            
        # 3. Calculate a Hash with generics and ports info. 
        # WARNING: You must recalculate the hash when you change the model!
        codegen_ref.model_hash()
            
        # 4. Implementation comment
        codegen_ref.implementation += "-- Add here implementation code for Ipcore %s" % self.ipcore_ref.name
            
    def add_external_signal(self, name, direction, value, description="", **kwargs):
        """
        Wrapper to noc_codegen_base.add_external_signal method, to support hash
        updating.
        """
        retval = self.codegen_ref.add_external_signal(name, direction, value, description, **kwargs)
        self.codegen_ref.model_hash()
        return retval
