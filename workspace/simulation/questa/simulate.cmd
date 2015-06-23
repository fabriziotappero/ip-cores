rem 	Example bash script for Mentor Graphics QuestaSim\ModelSim simulation.
rem 	
rem 	Author(s): 
rem 	- Daniel C.K. Kho, daniel.kho@opencores.org | daniel.kho@tauhop.com
rem 	
rem 	Copyright (C) 2012-2013 Authors and OPENCORES.ORG
rem  
rem  This program is free software: you can redistribute it and\or modify
rem  it under the terms of the GNU General Public License as published by
rem  the Free Software Foundation, either version 3 of the License, or
rem  (at your option) any later version.
rem 
rem  This program is distributed in the hope that it will be useful,
rem  but WITHOUT ANY WARRANTY; without even the implied warranty of
rem  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
rem  GNU General Public License for more details.
rem  
rem  You should have received a copy of the GNU General Public License
rem  along with this program.  If not, see <http:\\www.gnu.org\licenses\>.
rem 
rem  This notice and disclaimer must be retained as part of this text at all times.
rem 
rem 	@dependencies: 
rem 	@designer: Daniel C.K. Kho [daniel.kho@gmail.com] | [daniel.kho@tauhop.com]
rem 	@history: @see Mercurial log for full list of changes.
rem 	
rem 	@Description:
rem 

rem Remove logs, and previous compilation netlist files.
del modelsim.ini simulate.log
rmdir work altera osvvm tauhop

vlib work
vmap work work

vlib osvvm
vmap osvvm osvvm

vlib tauhop
vmap tauhop tauhop

vcom -2008 -work osvvm "..\..\..\rtl\packages\os-vvm\SortListPkg_int.vhd" "..\..\..\rtl\packages\os-vvm\RandomBasePkg.vhd" "..\..\..\rtl\packages\os-vvm\RandomPkg.vhd" "..\..\..\rtl\packages\os-vvm\CoveragePkg.vhd"

vcom -2008 -work tauhop "..\..\..\rtl\packages\pkg-tlm.vhdl" "..\..\..\rtl\packages\pkg-axi-tlm.vhdl" "..\..\..\rtl\packages\pkg-types.vhdl" "..\..\..\rtl\axi4-stream-bfm-master.vhdl" "..\..\..\tester\stimuli\galois-lfsr.vhdl" "..\..\..\tester\stimuli\prbs-31.vhdl"

vcom -2008 -work work "..\..\..\tester\tester.vhdl" "..\..\..\rtl\user.vhdl"

rem Make sure you have no compilation errors before you run vsim. Uncomment the following after there are no compilation errors.
rem vsim -t ps -do .\waves.do -voptargs="+acc" "work.user(rtl)"
