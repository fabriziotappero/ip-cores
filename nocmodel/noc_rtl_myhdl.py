#!/usr/bin/env python
# -*- coding: utf-8 -*-

#
# NoC RTL support in MyHDL
#   This module adds support for mixed model and RTL descriptions in MyHDL
#
# Author:  Oscar Diaz
# Version: 0.2
# Date:    01-06-2012

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
# 01-06-2012 : (OD) big refactorization
#

"""
===============================
NoCmodel RTL MyHDL support
===============================
  
This module extends 'noc_tbm_base' class for RTL descriptions in MyHDL
  
* Class 'noc_rtl_myhdl_base'
"""

import myhdl

from nocmodel import *
from noc_tbm_base import *

class noc_rtl_myhdl_base(noc_tbm_base):
    """
    Extended class for a MyHDL description of a NoC router.
    
    This class adds support for behavioral - RTL mixed modeling and
    full RTL modeling. It is meant to add in NoC objects through
    multiple inheritance mechanism
    
    Features:
    * Keep a list of (Intercon type) interface objects, each object is 
        indexed by a port index and each object stores a list of signals
        dict: "interface_objects"
    * Keep a list of external interface objects. Each object is a set of 
        signals (use "signalset" class), and are accessed by any python
        object (a string is recommended).
        dict: "external_objects"
    * Keep a list of internal MyHDL signals, and provides correct references
        dict: "internal_signals"
    """
    # Interface objects methods
    def add_interface(self, port_idx, object_ref=None):
        """
        Add a new interface
        Arguments:
        """
        if not hasattr(self, "interface_objects"):
            self._new_interface_objects()
            
        self.interface_objects[port_idx] = object_ref
        return object_ref

    def get_interface_signal(self, port_idx, signalname):
        """
        Try to get a signal reference from the interface object indexed by
        "port_idx". Raise an Exception if not found.
        Arguments:
        * port_idx: 
        * signalname:
        Returns:
          the MyHDL signal reference
        """
        if not hasattr(self, "interface_objects"):
            self._new_interface_objects()
            
        if port_idx not in self.interface_objects:
            raise ValueError("%s : Interface '%s' not found." % (repr(self), repr(port_idx)))
            
        # check if object is list-dict type or a class with signal attributes
        if isinstance(self.interface_objects[port_idx], (tuple, list, dict)):
            # indexing lookup
            if signalname not in self.interface_objects[port_idx]:
                raise AttributeError("%s : Signal '%s' from Interface %s not found." % (repr(self), signalname, repr(port_idx)))
                
            return self.interface_objects[port_idx][signalname]
        else:
            # attribute lookup
            try:
                return getattr(self.interface_objects[port_idx], signalname)
            except:
                 raise AttributeError("%s : Signal '%s' from Interface %s not found." % (repr(self), signalname, repr(port_idx)))
                 
    def get_interface_all_signals(self, port_idx):
        """
        Return a dict with all signals references from interface
        Arguments:
        * port_idx: 
        Returns:
          dict with references to all signals in interface
        """
        if not hasattr(self, "interface_objects"):
            self._new_interface_objects()
            return {}
            
        if port_idx not in self.interface_objects:
            raise ValueError("%s : Interface '%s' not found." % (repr(self), repr(port_idx)))
            
        if isinstance(self.interface_objects[port_idx], dict):
            return self.interface_objects[port_idx]
        elif isinstance(self.interface_objects[port_idx], (tuple, list)):
            return dict([(k, v) for k, v in enumerate(self.interface_objects[port_idx])])
        else:
            # search through all attributes
            retval = {}
            for attrname in dir(self.interface_objects[port_idx]):
                attr = getattr(self.interface_objects[port_idx], attrname)
                if isinstance(attr, myhdl.SignalType):
                    retval[attrname] = attr
            return retval
            
    # External interface objects methods
    def add_external_interface(self, index, object_ref=None):
        if not hasattr(self, "external_objects"):
            self._new_external_objects()
            
        if index is None:
            raise ValueError("Index cannot be None.")
        
        # Use an intercon object to model the external 
        # interface objects.
        if object_ref is not None:
            if not isinstance(object_ref, signalset):
                raise ValueError("Object_ref must be of signalset type (not %s, type %s)" % (repr(object_ref), type(object_ref)))
        else:
            object_ref = signalset(index)
        
        self.external_objects[index] = object_ref
        return object_ref
        
    def get_external_signal(self, index, signalname):
        """
        Try to get a signal reference from the external interface object 
        indexed by "index". Raise an Exception if not found.
        Arguments:
        * index: 
        * signalname:
        Returns:
          the MyHDL signal reference
        """
        if not hasattr(self, "external_objects"):
            self._new_external_objects()
            
        if index is None:
            # special case: search through all external interfaces
            siglist = []
            for sigset in self.external_objects.itervalues():
                try:
                    siglist.append(sigset.get_signal_ref(signalname))
                except:
                    pass
            if len(siglist) == 0:
                raise ValueError("%s : signal '%s' not found in any of the external objects." % (repr(self), repr(signalname)))
            elif len(siglist) > 1:
                raise ValueError("%s : signal '%s' found on multiple external objects." % (repr(self), repr(signalname)))
            else:
                return siglist[0]
            
        if index not in self.external_objects:
            raise ValueError("%s : External interface '%s' not found." % (repr(self), repr(index)))
            
        return self.external_objects[index].get_signal_ref(signalname)
                 
    def get_external_all_signals(self, index):
        """
        Return a dict with all signals references from interface
        Arguments:
        * index: 
        Returns:
          dict with references to all signals in interface
        """
        if not hasattr(self, "external_objects"):
            self._new_external_objects()
            
        if index not in self.external_objects:
            raise ValueError("%s : External interface '%s' not found." % (repr(self), repr(index)))
            
        retval = {}
        for signalname in self.external_objects[index].get_signal_allnames():
            retval[signalname] = self.external_objects[index].get_signal_ref(signalname)
        return retval

    # Internal signals methods
    def getset_internal_signal(self, signalname, newsignal_ref=None):
        """
        Try to get a reference to a internal signal with name "signalname".
        If not found, optionally add a new signal with its reference
        in "newsignal_ref".
        Arguments:
        * signalname: 
        * newsignal_ref:
        Returns:
          the MyHDL signal reference, or the contents of "newsignal_ref"
        """
        if not hasattr(self, "internal_signals"):
            self._new_internal_signals()
        
        if signalname not in self.internal_signals:
            if newsignal_ref is not None:
                if isinstance(newsignal_ref, myhdl.SignalType):
                    self.internal_signals[signalname] = newsignal_ref
                else:
                    # build a new signal based on newsignal_ref
                    self.internal_signals[signalname] = myhdl.Signal(newsignal_ref)
            else:
                raise ValueError("%s : Signal '%s' not found." % (repr(self), signalname))
        return self.internal_signals[signalname]
            
    def internal_signal_iter(self):
        """
        Return an iterator object over all the internal signals.
        This iterator works with tuples (signame, sigref).
        """
        return self.internal_signals.iteritems()
        
    # Methods to override
    def build_generators_codegen(self, withbaseclass=True):
        """
        Separate generator builder, for hw generators only
        NOTES:
        * Generators in this method must be convertible
        * Use overridden functions
        """
        raise NotImplementedError
        
    def _new_internal_signals(self):
        self.internal_signals = {}
    def _new_external_objects(self):
        self.external_objects = {}
    def _new_interface_objects(self):
        self.interface_objects = {}
