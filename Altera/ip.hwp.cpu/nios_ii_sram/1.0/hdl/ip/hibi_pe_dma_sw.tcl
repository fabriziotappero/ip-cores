#
# hibi_pe_dma_driver.tcl
#

# Create a new driver
create_driver hibi_pe_dma_driver

# Associate it with some hardware known as "hibi_pe_dma"
set_sw_property hw_class_name hibi_pe_dma

# The version of this driver
set_sw_property version 11.0

# This driver may be incompatible with versions of hardware less
# than specified below.
set_sw_property min_compatible_hw_version 1.0

# Initialize the driver in alt_sys_init()
set_sw_property auto_initialize true

# Location in generated BSP that above sources will be copied into
set_sw_property bsp_subdirectory drivers

# Interrupt properties: This driver supports enhanced interrupt API
#set_sw_property isr_preemption_supported true
set_sw_property supported_interrupt_apis "enhanced_interrupt_api"

#,
# Source file listings...
#

# C/C++ source files
add_sw_property c_source HAL/src/hibi_pe_dma_read.c
add_sw_property c_source HAL/src/hibi_pe_dma_write.c
add_sw_property c_source HAL/src/hibi_pe_dma_open.c
add_sw_property c_source HAL/src/hibi_pe_dma_close.c
add_sw_property c_source HAL/src/hibi_pe_dma_lseek.c
add_sw_property c_source HAL/src/hibi_pe_dma_ioctl.c
add_sw_property c_source HAL/src/hibi_pe_dma_init.c
add_sw_property c_source HAL/src/hibi_pe_dma_cbuffer.c

# Include files
add_sw_property include_source HAL/inc/hibi_pe_dma.h
add_sw_property include_source HAL/inc/hibi_pe_dma_defines.h
add_sw_property include_source HAL/inc/hibi_pe_dma_cbuffer.h
add_sw_property include_source HAL/inc/hibi_endpoints.h
add_sw_property include_source inc/hibi_pe_dma_regs.h

# This driver supports UCOSII BSP (OS) types
# add_sw_property supported_bsp_type HAL
add_sw_property supported_bsp_type UCOSII

# Add the following settings
add_sw_setting boolean_define_only public_mk_define enable_debug_prints HIBI_PE_DMA_DRIVER_TEST false "Enable Debug Prints in HIBI PE DMA Driver"
add_sw_setting decimal_number system_h_define number_of_channels HIBI_PE_DMA_CHANNELS 8 "Number of HIBI PE DMA Channels"
add_sw_setting decimal_number system_h_define channel_buffer_size HIBI_PE_DMA_BUFFER_SIZE 100 "HIBI PE DMA Channel RX/TX Buffer Size (bytes)"
add_sw_setting unquoted_string system_h_define hibi_shared_memory_name HIBI_PE_DMA_SHARED_MEMORY_NAME HIBI_PE_DMA_SHARED_MEMORY "HIBI PE DMA Shared Memory Name"

# End of file
