#!/bin/bash
#
#	Example bash script for Mentor Graphics QuestaSim/ModelSim simulation.
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

errorStr=`grep "\*\* Error: " $1/simulate.log`
echo $errorStr;

if [ `echo ${#errorStr}` -gt 0 ]
then echo "Errors exist. Refer $1/simulate.log for more details. Exiting."; exit;
else
	vsim -t ps -do $1/waves.do -voptargs="+acc" "work.tb_fir(rtl)";
	echo $(date "+[%Y-%m-%d %H:%M:%S]: simulation loaded.");
fi
