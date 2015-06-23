#!/usr/bin/env python
# -*- coding: utf-8 -*-

#
# NoCmodel - setup file
#
# Author:  Oscar Diaz
# Version: 0.2
# Date:    05-07-2011

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
# 05-07-2011 : (OD) second release
#

from distutils.core import setup

classifiers = """\
Development Status :: 3 - Alpha
Intended Audience :: Developers
License :: OSI Approved :: GNU Library or Lesser General Public License (LGPL)
Operating System :: OS Independent
Programming Language :: Python
Topic :: Scientific/Engineering :: Electronic Design Automation (EDA)
"""

setup(name='nocmodel',
        version='0.1',
        description='Network-on-Chip modeling library',
        author='Oscar Diaz',
        author_email='dargor@opencores.org',
        url='http://opencores.org/project,nocmodel',
        license='LGPL',
        requires=['networkx', 'myhdl'],
        platforms=["Any"],
        keywords="HDL ASIC FPGA SoC NoC hardware design",
        classifiers=filter(None, classifiers.split("\n")),
        packages=[
            'nocmodel',
            'nocmodel.basicmodels',
          ],
      )
