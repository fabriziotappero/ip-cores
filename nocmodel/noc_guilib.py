#!/usr/bin/env python
# -*- coding: utf-8 -*-

#
# Support for graphical representation of NoC objects
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
================
NoCmodel Graphic utilities
================
  
This module declares functions to draw graphical representations of 
NoCmodel objects.

"""
try:
    import matplotlib.pyplot as plt
    has_matplotlib = True
except:
    print("Matplotlib package not found. Drawing functions will not work.")
    has_matplotlib = False

import networkx as nx
import warnings

from noc_base import *

def draw_noc(noc, rectangular=True, nodepos=None):
    """
    Draw a representation of a NoC
    
    Arguments:
    * noc: Model to draw
    * rectangular: If True assumes rectangular layout, with routers 
      having coord_x and coord_y attributes. If false, expect router's 
      positions in nodepos argument
    * nodepos: Optional dictionary where keys are router's indexes and values 
      are tuples with x and y positions.
    """
    if not has_matplotlib:
        warnings.warn("Function not available")
        return None

    # node positions
    if rectangular:
        if nodepos == None:
            nodepos = {}
            for i in noc.router_list():
                nodepos[i.index] = (i.coord_x, i.coord_y)
    else:
        if nodepos == None:
            raise ValueError("For non-rectangular layouts this function needs argument 'nodepos'")

    # some parameters
    ip_relpos = (-0.3, 0.3) # relative to router
    # node labels
    nodelabels = {}
    for i in nodepos.iterkeys():
        nodelabels[i] = noc.node[i]["router_ref"].name

    # channel positions
    chpos = {}
    for i in noc.channel_list():
        ep = i.endpoints
        ep_1x = nodepos[ep[0].index][0]
        ep_1y = nodepos[ep[0].index][1]
        ep_2x = nodepos[ep[1].index][0]
        ep_2y = nodepos[ep[1].index][1]
        thepos = (ep_2x + ((ep_1x - ep_2x)/2.0), ep_2y + ((ep_1y - ep_2y)/2.0))
        chpos[i.index] = {"pos": thepos, "text": i.name}

    # start drawing
    nx.draw_networkx_nodes(noc, pos=nodepos, node_size=1000, node_color="blue", alpha=0.5)
    nx.draw_networkx_edges(noc, pos=nodepos, edge_color="black", alpha=1.0, width=3.0)
    nx.draw_networkx_labels(noc, pos=nodepos, labels=nodelabels, font_color="red")

    ax=plt.gca()
    # channel labels
    for i in chpos.itervalues():
        ax.text(i["pos"][0], i["pos"][1], i["text"], horizontalalignment="center", verticalalignment="top", bbox=dict(facecolor='red', alpha=0.2))

    # ipcore with channels and labels
    for i in noc.ipcore_list():
        thepos = nodepos[i.router_ref.index]
        # channel
        ax.arrow(thepos[0], thepos[1], ip_relpos[0], ip_relpos[1])
        # ip channel label
        ax.text(thepos[0]+(ip_relpos[0]/2), thepos[1]+(ip_relpos[1]/2), i.channel_ref.name, horizontalalignment="center", bbox=dict(facecolor='red', alpha=0.2))
        # box with ipcore labels
        ax.text(thepos[0]+ip_relpos[0], thepos[1]+ip_relpos[1], i.name, horizontalalignment="center", bbox=dict(facecolor='green', alpha=0.2))

    # adjust axis TODO!
    plt.show()
