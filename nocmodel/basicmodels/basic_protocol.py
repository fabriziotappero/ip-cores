#!/usr/bin/env python
# -*- coding: utf-8 -*-

#
# Basic Protocol model
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
Basic protocol helper
"""

from nocmodel.noc_base import *

class basic_protocol(protocol):
    """
    Basic protocol class
    
    This class simplify protocol object creation. It defines a simple packet
    with the following fields:
    
    |0   7|8  15|16  31|
    | src | dst | data |
    """
    def __init__(self):
        protocol.__init__(self, name="Basic protocol")
        self.update_packet_field("src", "int", 8, "Source address")
        self.update_packet_field("dst", "int", 8, "Destination address")
        self.update_packet_field("data", "int", 16, "Data payload")
