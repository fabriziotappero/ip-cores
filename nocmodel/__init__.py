#!/usr/bin/env python
# -*- coding: utf-8 -*-

#
# NoCmodel package
#
# Author:  Oscar Diaz
# Version: 0.2
# Date:    05-07-2012

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
# 14-03-2011 : (OD) support for code generation 
#

"""
================
NoCmodel package
================
  
This package includes:
  
* Module noc_base: NoCmodel Base Objects
* Module noc_guilib: NoCmodel Graphic utilities
* Module noc_tbm_base: NoCmodel TBM simulation support
* Module noc_tbm_utils: helper functions for TBM simulation
* Module noc_codegen_base: NoCmodel base for code generation support
* Module noc_codegen_vhdl: VHDL support for code generation
* Module noc_helpers: Utility functions
* Package basicmodels: basic examples of NoC objects (not imported by default)
"""

# required modules
import networkx as nx

# provided modules
from noc_base import *
from noc_guilib import *
from noc_tbm_base import *
from noc_tbm_utils import *
from noc_rtl_myhdl import *
from noc_codegen_base import *
from noc_codegen_vhdl import *
from noc_helpers import *

__version__ = "0.2"
