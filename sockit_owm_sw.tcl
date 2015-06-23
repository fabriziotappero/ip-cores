###############################################################################
#                                                                             #
#  Minimalistic 1-wire (onewire) master with Avalon MM bus interface          #
#                                                                             #
#  Copyright (C) 2010  Iztok Jeras                                            #
#                                                                             #
###############################################################################
#                                                                             #
#  This script is free software: you can redistribute it and/or modify        #
#  it under the terms of the GNU Lesser General Public License                #
#  as published by the Free Software Foundation, either                       #
#  version 3 of the License, or (at your option) any later version.           #
#                                                                             #
#  This RTL is distributed in the hope that it will be useful,                #
#  but WITHOUT ANY WARRANTY; without even the implied warranty of             #
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              #
#  GNU General Public License for more details.                               #
#                                                                             #
#  You should have received a copy of the GNU General Public License          #
#  along with this program.  If not, see <http:#www.gnu.org/licenses/>.       #
#                                                                             #
###############################################################################

# Create a new driver
create_driver sockit_owm_driver

# Association with hardware
set_sw_property hw_class_name sockit_owm

# Driver version
set_sw_property version 1.3

# This driver is compatible with version 1.3 and above
set_sw_property min_compatible_hw_version 1.3

# Interrupt properties
set_sw_property isr_preemption_supported true
set_sw_property supported_interrupt_apis "legacy_interrupt_api enhanced_interrupt_api"

# Initialize the driver in alt_sys_init()
set_sw_property auto_initialize true

# Location in generated BSP that above sources will be copied into
set_sw_property bsp_subdirectory drivers

# C source files
add_sw_property       c_source HAL/src/sockit_owm.c
add_sw_property       c_source HAL/src/ownet.c
add_sw_property       c_source HAL/src/owtran.c
add_sw_property       c_source HAL/src/owlnk.c
add_sw_property       c_source HAL/src/owses.c

# Include files
add_sw_property include_source inc/sockit_owm_regs.h
add_sw_property include_source HAL/inc/sockit_owm.h
add_sw_property include_source HAL/inc/ownet.h

# Common files
add_sw_property       c_source HAL/src/owerr.c
add_sw_property       c_source HAL/src/crcutil.c
add_sw_property include_source HAL/inc/findtype.h
add_sw_property       c_source HAL/src/findtype.c

# device files (thermometer)
add_sw_property include_source HAL/inc/temp10.h
add_sw_property       c_source HAL/src/temp10.c
add_sw_property include_source HAL/inc/temp28.h
add_sw_property       c_source HAL/src/temp28.c
add_sw_property include_source HAL/inc/temp42.h
add_sw_property       c_source HAL/src/temp42.c

# This driver supports HAL & UCOSII BSP (OS) types
add_sw_property supported_bsp_type HAL
add_sw_property supported_bsp_type UCOSII

# Driver configuration options
add_sw_setting boolean_define_only public_mk_define polling_driver_enable  SOCKIT_OWM_POLLING    true "Small-footprint (polled mode) driver"
add_sw_setting boolean_define_only public_mk_define hardware_delay_enable  SOCKIT_OWM_HW_DLY     true "Mili second delay implemented in hardware"
add_sw_setting boolean_define_only public_mk_define error_detection_enable SOCKIT_OWM_ERR_ENABLE true "Implement error detection support"
add_sw_setting boolean_define_only public_mk_define error_detection_small  SOCKIT_OWM_ERR_SMALL  true "Reduced memory consumption for error detection"

# Enable application layer code
#add_sw_setting boolean_define_only public_mk_define enable_A SOCKIT_OWM_A false "Enable driver A"
