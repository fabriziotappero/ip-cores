#!/bin/bash
#
#	Example bash script for Quartus synthesis, place-and-route, and design 
#		assembly.
#	
#	Author(s): 
#	- Daniel C.K. Kho, daniel.kho@opencores.org | daniel.kho@tauhop.com
#	
#	Copyright (C) 2012-2013 Authors and OPENCORES.ORG
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# This notice and disclaimer must be retained as part of this text at all times.
#
#	@dependencies: 
#	@designer: Daniel C.K. Kho [daniel.kho@gmail.com] | [daniel.kho@tauhop.com]
#	@history: @see Mercurial log for full list of changes.
#	
#	@Description:
#

quartus_sh --flow compile axi4-tlm;

errorStr=`grep 'Error (' ./output_files/*.rpt`
if [ `echo ${#errorStr}` -gt 0 ]
then echo "Build error(s) exist. Refer to report files in the output_files directory for more details. Exiting."; exit;
else
	echo $(date "+[%Y-%m-%d %H:%M:%S]: Configuring device...");
	quartus_pgm -c 'USB-Blaster [1-1.1]' -m jtag -o 'p;./output_files/axi4-tlm.sof';
	
fi

errorStr=`grep 'Error (' ./output_files/*.rpt`
if [ `echo ${#errorStr}` -gt 0 ]
then echo "Configuration error(s) exist. Refer to report files in the output_files directory for more details. Exiting."; exit;
else
	echo $(date "+[%Y-%m-%d %H:%M:%S]: Loading waveform session...");
	quartus_stpw ./waves.stp &
fi
