#!/usr/bin/env python
# -*- coding: utf-8 -*-

#
# Helper functions for NoC Objects
#   Functions that easily construct predefined NoC structures and objects
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
# 14-03-2011 : (OD) initial release
#

import networkx as nx
from noc_base import *

def generate_squarenoc(orderx=3, ordery=None, with_ipcore=False):
    """
    NoC generator helper: generates a 2D grid NoC object
    
    Arguments
    * orderx: optional X-axis length of the grid. By default build a 3x3 square 
      grid.
    * ordery: optional Y-axis length of the grid. By default build a square grid
      of order "orderx". This argument is used to build rectangular grids.
    * with_ipcore: If True, add ipcores to routers automatically.
    """
    if ordery == None:
        ordery = orderx
        
    # 1. generate a 2d grid
    basegrid = nx.grid_2d_graph(orderx, ordery)
    
    # 2. convert to a graph with ints as nodes
    convgrid = nx.Graph()
    for n in basegrid.nodes_iter():
        n2 = n[0] + n[1]*orderx
        convgrid.add_node(n2, coord_x=n[0], coord_y=n[1])
    for e in basegrid.edges_iter():
        e1 = e[0][0] + e[0][1]*orderx
        e2 = e[1][0] + e[1][1]*orderx
        convgrid.add_edge(e1, e2)
        
    nocbase = noc(name="NoC grid %dx%d" % (orderx, ordery), data=convgrid)

    # 2. for each node add router object
    for n in nocbase.nodes_iter():
        cx = nocbase.node[n]["coord_x"]
        cy = nocbase.node[n]["coord_y"]
        r = nocbase._add_router_from_node(n, coord_x=cx, coord_y=cy)
        if with_ipcore:
            nocbase.add_ipcore(r)
    
    # 3. for each edge add channel object
    for e in nocbase.edges_iter():
        nocbase._add_channel_from_edge(e)
    
    return nocbase
