# +-----------------------------------
# | 
# | tiny_spi "tiny_spi" v1.0
# | Thomas Chou 2010.01.19.18:07:51
# | SPI 8 bits
# | 
# | tiny_spi/hdl/tiny_spi.v
# | 
# |    ./hdl/tiny_spi.v syn, sim
# | 
# +-----------------------------------

# +-----------------------------------
# | module tiny_spi
# | 
set_module_property DESCRIPTION "tiny SPI 8 bits"
set_module_property NAME tiny_spi
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property GROUP "Interface Protocols/Serial"
set_module_property AUTHOR "Thomas Chou"
set_module_property DISPLAY_NAME "OpenCores tiny SPI"
set_module_property TOP_LEVEL_HDL_FILE hdl/tiny_spi.v
set_module_property TOP_LEVEL_HDL_MODULE tiny_spi
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file hdl/tiny_spi.v {SYNTHESIS SIMULATION}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
# | 
# +-----------------------------------
add_parameter BAUD_WIDTH INTEGER 8
set_parameter_property BAUD_WIDTH DEFAULT_VALUE 8
set_parameter_property BAUD_WIDTH DISPLAY_NAME BAUD_WIDTH
set_parameter_property BAUD_WIDTH UNITS None
set_parameter_property BAUD_WIDTH AFFECTS_GENERATION false
set_parameter_property BAUD_WIDTH HDL_PARAMETER true
add_parameter BAUD_DIV INTEGER 0
set_parameter_property BAUD_DIV DEFAULT_VALUE 0
set_parameter_property BAUD_DIV DISPLAY_NAME BAUD_DIV
set_parameter_property BAUD_DIV UNITS None
set_parameter_property BAUD_DIV AFFECTS_GENERATION false
set_parameter_property BAUD_DIV HDL_PARAMETER true
add_parameter SPI_MODE INTEGER 0
set_parameter_property SPI_MODE DEFAULT_VALUE 0
set_parameter_property SPI_MODE DISPLAY_NAME SPI_MODE
set_parameter_property SPI_MODE UNITS None
set_parameter_property SPI_MODE AFFECTS_GENERATION false
set_parameter_property SPI_MODE HDL_PARAMETER true

# +-----------------------------------
# | display items
# | 
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point d
# | 
add_interface d avalon end
set_interface_property d addressAlignment NATIVE
set_interface_property d addressUnits WORDS
set_interface_property d associatedClock clk
set_interface_property d associatedReset reset
set_interface_property d burstOnBurstBoundariesOnly false
set_interface_property d explicitAddressSpan 0
set_interface_property d holdTime 0
set_interface_property d isMemoryDevice false
set_interface_property d isNonVolatileStorage false
set_interface_property d linewrapBursts false
set_interface_property d maximumPendingReadTransactions 0
set_interface_property d printableDevice false
set_interface_property d readLatency 0
set_interface_property d readWaitStates 0
set_interface_property d readWaitTime 0
set_interface_property d setupTime 0
set_interface_property d timingUnits Cycles
set_interface_property d writeWaitTime 0

set_interface_property d ENABLED true

add_interface_port d stb_i chipselect Input 1
add_interface_port d we_i write Input 1
add_interface_port d dat_i writedata Input 32
add_interface_port d adr_i address Input 3
add_interface_port d dat_o readdata Output 32
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clk
# | 
add_interface clk clock end

set_interface_property clk ENABLED true

add_interface_port clk clk_i clk Input 1
# | 
# +-----------------------------------


# +-----------------------------------
# | connection point reset
# | 
add_interface reset reset end
set_interface_property reset associatedClock clk
set_interface_property reset synchronousEdges DEASSERT

set_interface_property reset ENABLED true

add_interface_port reset rst_i reset Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point irq
# | 
add_interface irq interrupt end
set_interface_property irq associatedAddressablePoint d
set_interface_property irq associatedClock clk
set_interface_property irq associatedReset reset
set_interface_property irq ENABLED true

add_interface_port irq int_o irq Output 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point spi
# | 
add_interface spi conduit end

set_interface_property spi ENABLED true

add_interface_port spi MOSI export Output 1
add_interface_port spi SCLK export Output 1
add_interface_port spi MISO export Input 1
# | 
# +-----------------------------------
