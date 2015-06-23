create_clock -name fxclk_in -period 20.833 [get_ports fxclk]
set_property PACKAGE_PIN P15 [get_ports fxclk]
set_property IOSTANDARD LVCMOS33 [get_ports fxclk]

# output
set_property PACKAGE_PIN M16 [get_ports {pb[0]}]  		;# PB0/FD0
set_property PACKAGE_PIN L16 [get_ports {pb[1]}]  		;# PB1/FD1
set_property PACKAGE_PIN L14 [get_ports {pb[2]}]  		;# PB2/FD2
set_property PACKAGE_PIN M14 [get_ports {pb[3]}]  		;# PB3/FD3
set_property PACKAGE_PIN L18 [get_ports {pb[4]}]  		;# PB4/FD4
set_property PACKAGE_PIN M18 [get_ports {pb[5]}]  		;# PB5/FD5
set_property PACKAGE_PIN R12 [get_ports {pb[6]}]  		;# PB6/FD6
set_property PACKAGE_PIN R13 [get_ports {pb[7]}]  		;# PB7/FD7
set_property IOSTANDARD LVCMOS33 [get_ports pb[*]]
set_property DRIVE 12 [get_ports pb[*]]

# input
set_property PACKAGE_PIN T9 [get_ports {pd[0]}]  		;# PD0/FD8
set_property PACKAGE_PIN V10 [get_ports {pd[1]}]  		;# PD1/FD9
set_property PACKAGE_PIN U11 [get_ports {pd[2]}]  		;# PD2/FD10
set_property PACKAGE_PIN V11 [get_ports {pd[3]}]  		;# PD3/FD11
set_property PACKAGE_PIN V12 [get_ports {pd[4]}]  		;# PD4/FD12
set_property PACKAGE_PIN U13 [get_ports {pd[5]}]  		;# PD5/FD13
set_property PACKAGE_PIN U14 [get_ports {pd[6]}]  		;# PD6/FD14
set_property PACKAGE_PIN V14 [get_ports {pd[7]}]  		;# PD7/FD15

set_property IOSTANDARD LVCMOS33 [get_ports pd[*]]

# bitstream settings for all ZTEX Series 2 FPGA Boards
set_property BITSTREAM.CONFIG.CONFIGRATE 66 [current_design]  
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR No [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 2 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true [current_design] 

