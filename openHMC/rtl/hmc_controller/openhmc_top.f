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

### Make sure to source the path variable first.
#use: export OPENHMC_PATH=path_to_openhmc_main_folder

####HEADER
-incdir ${OPENHMC_PATH}/rtl/include/

####Top
${OPENHMC_PATH}/rtl/hmc_controller/openhmc_top.v

####Controller TX
${OPENHMC_PATH}/rtl/hmc_controller/tx/tx_link.v
${OPENHMC_PATH}/rtl/hmc_controller/tx/tx_run_length_limiter.v
${OPENHMC_PATH}/rtl/hmc_controller/tx/tx_scrambler.v
${OPENHMC_PATH}/rtl/hmc_controller/tx/tx_crc_combine.v

####Controller RX
${OPENHMC_PATH}/rtl/hmc_controller/rx/rx_link.v
${OPENHMC_PATH}/rtl/hmc_controller/rx/rx_lane_logic.v
${OPENHMC_PATH}/rtl/hmc_controller/rx/rx_descrambler.v
${OPENHMC_PATH}/rtl/hmc_controller/rx/rx_crc_compare.v

####CRC
${OPENHMC_PATH}/rtl/hmc_controller/crc/crc_128_init.v
${OPENHMC_PATH}/rtl/hmc_controller/crc/crc_accu.v

####Register File
${OPENHMC_PATH}/rtl/hmc_controller/register_file/openhmc_8x_rf.v
${OPENHMC_PATH}/rtl/hmc_controller/register_file/openhmc_16x_rf.v

####Building blocks
-f ${OPENHMC_PATH}/rtl/building_blocks/fifos/sync/openhmc_sync_fifos.f
${OPENHMC_PATH}/rtl/building_blocks/fifos/async/openhmc_async_fifo.v
${OPENHMC_PATH}/rtl/building_blocks/counter/counter48.v
${OPENHMC_PATH}/rtl/building_blocks/rams/openhmc_ram.v
