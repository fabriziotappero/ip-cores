#!/usr/bin/env python
# -*- coding: utf-8 -*-

#
# NoC TBM simulation support - Utilities
#   This module declares additional helper functions 
#
# Author:  Oscar Diaz
# Version: 0.2
# Date:    17-03-2011

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
=============================
NoCmodel TBM simulation utils
=============================
  
This module declares additional helper functions.
  
* Function 'add_tbm_basic_support'
"""

from noc_tbm_base import *
from nocmodel.basicmodels import *

# helper functions
def add_tbm_basic_support(instance, **kwargs):
    """
    This function will add for every object in noc_instance a noc_tbm object
    """
    if isinstance(instance, noc):
        # add simulation object
        instance.tbmsim = noc_tbm_simulation(instance, **kwargs)
        # and add tbm objects recursively
        for obj in instance.all_list():
            altkwargs = kwargs
            altkwargs.pop("log_file", None)
            altkwargs.pop("log_level", None)
            add_tbm_basic_support(obj, **kwargs)
    elif isinstance(instance, ipcore):
        instance.tbm = basic_ipcore_tbm(instance, **kwargs)
        # don't forget internal channel
        instance.channel_ref.tbm = basic_channel_tbm(instance.channel_ref, **kwargs)
    elif isinstance(instance, router):
        instance.tbm = basic_router_tbm(instance, **kwargs)
    elif isinstance(instance, channel):
        instance.tbm = basic_channel_tbm(instance, **kwargs)
    else:
        raise TypeError("Unsupported object: type %s" % type(instance))
