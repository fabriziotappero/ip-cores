#!/usr/bin/env python
# -*- coding: utf-8 -*-

#
# Intercon models
#  * Dual P2P Wishbone model
#  * Single Bus Wishbone model
#
# Author:  Oscar Diaz
# Version: 0.1
# Date:    11-03-2011

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
# 11-03-2011 : (OD) initial release
#

"""
Basic Wishbone intercon models
"""

from nocmodel import *

class dualwb_intercon(intercon):
    """
    Wishbone dual P2P intercon model
    
    This intercon defines two bidirectional Wishbone P2P ports.
    """
    intercon_type = "dualwb"
    complement = None
    sideinfo = ""
    
    def __init__(self, **kwargs):
        intercon.__init__(self, **kwargs)
        
        # attributes: data_width (default 32 bits)
        if not hasattr(self, "data_width"):
            setattr(self, "data_width", 32)
        # addr_width (default 0, don't use address signal)
        if not hasattr(self, "addr_width"):
            setattr(self, "addr_width", 0)

        self.intercon_type = "dualwb"
#        self.complement = None
#        self.sideinfo = ""
        
        # build the intercon structure
        # Common signals
        #self.signals["rst_i"]
        #self.signals["clk_i"]
        # Master part
        # discard m_dat_i, m_we_o, m_sel_o, m_rty_i, m_lock_o
        # optional m_adr_o
        self.signals["m_dat_o"] = {"width": self.data_width, "direction": "out", "signal_obj": None, "description": "Master data output"}
        if self.addr_width > 0:
            self.signals["m_adr_o"] = {"width": self.addr_width, "direction": "out", "signal_obj": None, "description": "Master address output"}
        self.signals["m_stb_o"] = {"width": 1, "direction": "out", "signal_obj": None, "description": "Master strobe"}
        self.signals["m_cyc_o"] = {"width": 1, "direction": "out", "signal_obj": None, "description": "Master cycle"}
        self.signals["m_lflit_o"] = {"width": 1, "direction": "out", "signal_obj": None, "description": "Master last flit flag"}
        self.signals["m_ack_i"] = {"width": 1, "direction": "in", "signal_obj": None, "description": "Master acknowledge"}
        self.signals["m_stall_i"] = {"width": 1, "direction": "in", "signal_obj": None, "description": "Master stall"}
        self.signals["m_err_i"] = {"width": 1, "direction": "in", "signal_obj": None, "description": "Master error"}
        # Slave part
        # discard s_adr_i, s_dat_o, s_we_i, s_sel_i, s_rty_o, s_lock_i
        self.signals["s_dat_i"] = {"width": self.data_width, "direction": "in", "signal_obj": None, "description": "Slave data input"}
        if self.addr_width > 0:
            self.signals["s_adr_i"] = {"width": self.addr_width, "direction": "in", "signal_obj": None, "description": "Slave address input"}
        self.signals["s_stb_i"] = {"width": 1, "direction": "in", "signal_obj": None, "description": "Slave strobe"}
        self.signals["s_cyc_i"] = {"width": 1, "direction": "in", "signal_obj": None, "description": "Slave cycle"}
        self.signals["s_lflit_i"] = {"width": 1, "direction": "in", "signal_obj": None, "description": "Slave last flit flag"}
        self.signals["s_ack_o"] = {"width": 1, "direction": "out", "signal_obj": None, "description": "Slave acknowledge"}
        self.signals["s_stall_o"] = {"width": 1, "direction": "out", "signal_obj": None, "description": "Slave stall"}
        self.signals["s_err_o"] = {"width": 1, "direction": "out", "signal_obj": None, "description": "Slave error"}
        
    def get_complement_signal(self, signalname):
        """
        Get the signal name that should be connected to this signal when 
        connecting two intercon.
        
        Arguments:
        * signalname: signal name of this intercon
        
        Return: a string with the name of a signal from a complementary intercon.
        """
        if signalname not in self.signals:
            raise KeyError("Signal '%s' not found" % signalname)
        mchange = {"m": "s", "s": "m"}
        dchange = {"i": "o", "o": "i"}
        return mchange[signalname[0]] + signalname[1:-1] + dchange[signalname[-1]]
        
class slavewb_intercon():
    pass

class masterwb_intercon(intercon):
    """
    Wishbone single bus master intercon model
    
    This intercon defines a simple master Wishbone bus.
    """
    intercon_type = "masterwb"
    complement = slavewb_intercon
    sideinfo = "master"
    
    def __init__(self, **kwargs):
        intercon.__init__(self, **kwargs)
        
        # attributes: data_width (default 32 bits)
        if not hasattr(self, "data_width"):
            setattr(self, "data_width", 32)
        # addr_width (default 16 bits)
        if not hasattr(self, "addr_width"):
            setattr(self, "addr_width", 16)
            
        self.intercon_type = "masterwb"
#        self.complement = slavewb_intercon
#        self.sideinfo = "master"
        
        # build the intercon structure
        self.signals["rst_i"] = {"width": 1, "direction": "in", "signal_obj": None, "description": "Reset input"}
        self.signals["clk_i"] = {"width": 1, "direction": "in", "signal_obj": None, "description": "Clock input"}
        
        # discard m_sel_o, m_rty_i, m_lock_o
        self.signals["m_adr_o"] = {"width": self.addr_width, "direction": "out", "signal_obj": None, "description": "Master address output"}
        self.signals["m_dat_i"] = {"width": self.data_width, "direction": "in", "signal_obj": None, "description": "Master data input"}
        self.signals["m_dat_o"] = {"width": self.data_width, "direction": "out", "signal_obj": None, "description": "Master data output"}
        self.signals["m_we_o"] = {"width": 1, "direction": "out", "signal_obj": None, "description": "Master write enable"}
        self.signals["m_stb_o"] = {"width": 1, "direction": "out", "signal_obj": None, "description": "Master strobe"}
        self.signals["m_cyc_o"] = {"width": 1, "direction": "out", "signal_obj": None, "description": "Master cycle"}
        self.signals["m_ack_i"] = {"width": 1, "direction": "in", "signal_obj": None, "description": "Master acknowledge"}
        self.signals["m_stall_i"] = {"width": 1, "direction": "in", "signal_obj": None, "description": "Master stall"}
        self.signals["m_err_i"] = {"width": 1, "direction": "in", "signal_obj": None, "description": "Master error"}
        self.signals["m_irq_i"] = {"width": 1, "direction": "in", "signal_obj": None, "description": "Master IRQ"}
        
    def get_complement_signal(self, signalname):
        """
        Get the signal name that should be connected to this signal when 
        connecting two intercon.
        
        Arguments:
        * signalname: signal name of this intercon
        
        Return: a string with the name of a signal from a complementary intercon.
        """
        if signalname not in self.signals:
            raise KeyError("Signal '%s' not found" % signalname)
        mchange = {"m": "s", "s": "m"}
        dchange = {"i": "o", "o": "i"}
        if signalname == "rst_i" or signalname == "clk_i":
            # special signals. Return None
            return None
        else:
            return mchange[signalname[0]] + signalname[1:-1] + dchange[signalname[-1]]
        
class slavewb_intercon(intercon):
    """
    Wishbone single bus slave intercon model
    
    This intercon defines a simple slave Wishbone bus.
    """
    intercon_type = "slavewb"
    complement = masterwb_intercon
    sideinfo = "slave"
    
    def __init__(self, **kwargs):
        intercon.__init__(self, **kwargs)
        
        # attributes: data_width (default 32 bits)
        if not hasattr(self, "data_width"):
            setattr(self, "data_width", 32)
        # addr_width (default 16 bits)
        if not hasattr(self, "addr_width"):
            setattr(self, "addr_width", 16)
            
        self.intercon_type = "slavewb"
#        self.complement = masterwb_intercon
#        self.sideinfo = "slave"
        
        # build the intercon structure
        self.signals["rst_i"] = {"width": 1, "direction": "in", "signal_obj": None, "description": "Reset input"}
        self.signals["clk_i"] = {"width": 1, "direction": "in", "signal_obj": None, "description": "Clock input"}
        
        # discard s_sel_o, s_rty_i, s_lock_o
        self.signals["s_adr_i"] = {"width": self.addr_width, "direction": "in", "signal_obj": None, "description": "Slave address output"}
        self.signals["s_dat_o"] = {"width": self.data_width, "direction": "out", "signal_obj": None, "description": "Slave data input"}
        self.signals["s_dat_i"] = {"width": self.data_width, "direction": "in", "signal_obj": None, "description": "Slave data output"}
        self.signals["s_we_i"] = {"width": 1, "direction": "in", "signal_obj": None, "description": "Slave write enable"}
        self.signals["s_stb_i"] = {"width": 1, "direction": "in", "signal_obj": None, "description": "Slave strobe"}
        self.signals["s_cyc_i"] = {"width": 1, "direction": "in", "signal_obj": None, "description": "Slave cycle"}
        self.signals["s_ack_o"] = {"width": 1, "direction": "out", "signal_obj": None, "description": "Slave acknowledge"}
        self.signals["s_stall_o"] = {"width": 1, "direction": "out", "signal_obj": None, "description": "Slave stall"}
        self.signals["s_err_o"] = {"width": 1, "direction": "out", "signal_obj": None, "description": "Slave error"}
        self.signals["s_irq_o"] = {"width": 1, "direction": "out", "signal_obj": None, "description": "Slave IRQ"}
        
    def get_complement_signal(self, signalname):
        """
        Get the signal name that should be connected to this signal when 
        connecting two intercon.
        
        Arguments:
        * signalname: signal name of this intercon
        
        Return: a string with the name of a signal from a complementary intercon.
        """
        if signalname not in self.signals:
            raise KeyError("Signal '%s' not found" % signalname)
        mchange = {"m": "s", "s": "m"}
        dchange = {"i": "o", "o": "i"}
        if signalname == "rst_i" or signalname == "clk_i":
            # special signals. Return None
            return None
        else:
            return mchange[signalname[0]] + signalname[1:-1] + dchange[signalname[-1]]
