#!/bin/csh -f
#*****************************************************************************
# (c) Copyright 2009 Xilinx, Inc. All rights reserved.
#
# This file contains confidential and proprietary information
# of Xilinx, Inc. and is protected under U.S. and
# international copyright and other intellectual property
# laws.
#
# DISCLAIMER
# This disclaimer is not a license and does not grant any
# rights to the materials distributed herewith. Except as
# otherwise provided in a valid license issued to you by
# Xilinx, and to the maximum extent permitted by applicable
# law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
# WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
# AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
# BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
# INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
# (2) Xilinx shall not be liable (whether in contract or tort,
# including negligence, or under any other theory of
# liability) for any loss or damage of any kind or nature
# related to, arising under or in connection with these
# materials, including for any direct, or any indirect,
# special, incidental, or consequential loss or damage
# (including loss of data, profits, goodwill, or any type of
# loss or damage suffered as a result of any action brought
# by a third party) even if such damage or loss was
# reasonably foreseeable or Xilinx had been advised of the
# possibility of the same.
#
# CRITICAL APPLICATIONS
# Xilinx products are not designed or intended to be fail-
# safe, or for use in any application requiring fail-safe
# performance, such as life-support or safety devices or
# systems, Class III medical devices, nuclear facilities,
# applications related to the deployment of airbags, or any
# other applications that could lead to death, personal
# injury, or severe property or environmental damage
# (individually and collectively, "Critical
# Applications"). Customer assumes the sole risk and
# liability of any use of Xilinx products in Critical
# Applications, subject only to applicable laws and
# regulations governing limitations on product liability.
#
# THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
# PART OF THIS FILE AT ALL TIMES.
#
# ****************************************************************************
#   ____  ____
#  /   /\/   /
# /___/  \  /    Vendor                : Xilinx
# \   \   \/     Version               : 3.5
#  \   \         Application           : MIG
#  /   /         Filename              : ise_flow.bat
# /___/   /\     Date Last Modified    : $Date: 2010/06/06 09:42:27 $
# \   \  /  \    Date Created          : Fri Feb 06 2009
#  \___\/\___\
#
# Device            : Spartan-6
# Design Name       : DDR/DDR2/DDR3/LPDDR
# Purpose           : Batch file to run PAR through ISE batch mode
# Reference         :
# Revision History  :
# ****************************************************************************

./rem_files.sh




echo Synthesis Tool: XST

mkdir "../synth/__projnav" > ise_flow_results.txt
mkdir "../synth/xst" >> ise_flow_results.txt
mkdir "../synth/xst/work" >> ise_flow_results.txt

xst -ifn ise_run.txt -ofn mem_interface_top.syr -intstyle ise >> ise_flow_results.txt
ngdbuild -intstyle ise -dd ../synth/_ngo -uc mem0.ucf -p xc6slx75csg484-3 mem0.ngc mem0.ngd >> ise_flow_results.txt

map -intstyle ise -detail -w -pr off -c 100 -o mem0_map.ncd mem0.ngd mem0.pcf >> ise_flow_results.txt
par -w -intstyle ise -ol std mem0_map.ncd mem0.ncd mem0.pcf >> ise_flow_results.txt
trce -e 100 mem0.ncd mem0.pcf >> ise_flow_results.txt
bitgen -intstyle ise -f mem_interface_top.ut mem0.ncd >> ise_flow_results.txt

echo done!
