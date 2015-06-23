#
#                              .--------------. .----------------. .------------.
#                             | .------------. | .--------------. | .----------. |
#                             | | ____  ____ | | | ____    ____ | | |   ______ | |
#                             | ||_   ||   _|| | ||_   \  /   _|| | | .' ___  || |
#       ___  _ __   ___ _ __  | |  | |__| |  | | |  |   \/   |  | | |/ .'   \_|| |
#      / _ \| '_ \ / _ \ '_ \ | |  |  __  |  | | |  | |\  /| |  | | || |       | |
#       (_) | |_) |  __/ | | || | _| |  | |_ | | | _| |_\/_| |_ | | |\ `.___.'\| |
#      \___/| .__/ \___|_| |_|| ||____||____|| | ||_____||_____|| | | `._____.'| |
#           | |               | |            | | |              | | |          | |
#           |_|               | '------------' | '--------------' | '----------' |
#                              '--------------' '----------------' '------------'
#
#  openHMC - An Open Source Hybrid Memory Cube Controller
#  (C) Copyright 2014 Computer Architecture Group - University of Heidelberg
#  www.ziti.uni-heidelberg.de
#  B6, 26
#  68159 Mannheim
#  Germany
#
#  Contact: openhmc@ziti.uni-heidelberg.de
#  http://ra.ziti.uni-heidelberg.de/openhmc
#
#   This source file is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Lesser General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This source file is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Lesser General Public License for more details.
#
#   You should have received a copy of the GNU Lesser General Public License
#   along with this source file.  If not, see <http://www.gnu.org/licenses/>.
#
#

#Leave untouched
+define+HMC_REQUESTER_IS_ACTIVE=0
+define+HMC_RESPONDER_IS_ACTIVE=0
+define+CAG_ASSERTIONS

+define+RFS_DATA_WIDTH=64
+define+RFS_HMC_CONTROLLER_RF_AWIDTH=4
+define+RFS_HMC_CONTROLLER_RF_RWIDTH=64
+define+RFS_HMC_CONTROLLER_RF_WWIDTH=64

+incdir+${OPENHMC_SIM}/tb/bfm/src
+incdir+${OPENHMC_SIM}/tb/bfm/testlib
+incdir+${OPENHMC_SIM}/UVC/axi4_stream/sv
+incdir+${OPENHMC_SIM}/UVC/cag_rgm/sv
+incdir+${OPENHMC_SIM}/UVC/hmc_module/sv
+incdir+${OPENHMC_SIM}/UVC/hmc_base_types/sv

#Micron BFM model
-f ${OPENHMC_SIM}/bfm/hmc_bfm.f

-64bit
-access +rwc

-uvm

-sv
-q

-ncerror CUVWSI
-ncerror CUVWSP
-ncerror CUVMPW
-ncerror CUVUKP
-ncerror RTSDAD
-ncerror OBINRG
-ncerror BNDMEM
-ncerror FUNTSK
-ncerror CSINFI
-ncerror RECOME
-nowarn CUVIHR
+UVM_NO_RELNOTES

### DUT-specific files

-top tb_top
