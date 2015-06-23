# CLKOUT/FXCLK 
create_clock -name fxclk -period 10 [get_ports fxclk]
set_property PACKAGE_PIN P15 [get_ports fxclk]
set_property IOSTANDARD LVCMOS33 [get_ports fxclk]

# led1
set_property PACKAGE_PIN H15 [get_ports {led1[0]}]		;# A6 / B21~IO_L21P_T3_DQS_16
set_property PACKAGE_PIN J13 [get_ports {led1[1]}]		;# B6 / A21~IO_L21N_T3_DQS_16
set_property PACKAGE_PIN J14 [get_ports {led1[2]}]		;# A7 / D20~IO_L19P_T3_16
set_property PACKAGE_PIN H14 [get_ports {led1[3]}]		;# B7 / C20~IO_L19N_T3_VREF_16
set_property PACKAGE_PIN H17 [get_ports {led1[4]}]		;# A8 / B20~IO_L16P_T2_16
set_property PACKAGE_PIN G14 [get_ports {led1[5]}]		;# B8 / A20~IO_L16N_T2_16
set_property PACKAGE_PIN G17 [get_ports {led1[6]}]		;# A9 / C19~IO_L13N_T2_MRCC_16
set_property PACKAGE_PIN G16 [get_ports {led1[7]}]		;# B9 / A19~IO_L17N_T2_16
set_property PACKAGE_PIN G18 [get_ports {led1[8]}]		;# A10 / C18~IO_L13P_T2_MRCC_16
set_property PACKAGE_PIN H16 [get_ports {led1[9]}]		;# B10 / A18~IO_L17P_T2_16
set_property IOSTANDARD LVCMOS33 [get_ports {led1[*]}]
set_property DRIVE 12 [get_ports {led1[*]}]

# sw
set_property PACKAGE_PIN F18 [get_ports {sw[0]}]		;# A11 / B18~IO_L11N_T1_SRCC_16
set_property PACKAGE_PIN F16 [get_ports {sw[1]}]		;# B11 / D17~IO_L12P_T1_MRCC_16
set_property PACKAGE_PIN E18 [get_ports {sw[2]}]		;# A12 / B17~IO_L11P_T1_SRCC_16
set_property PACKAGE_PIN F15 [get_ports {sw[3]}]		;# B12 / C17~IO_L12N_T1_MRCC_16
set_property IOSTANDARD LVCMOS33 [get_ports {sw[*]}]
set_property PULLUP true [get_ports {sw[*]}]

# led2
set_property PACKAGE_PIN U9 [get_ports {led2[0]}]		;# C3 / AB17~IO_L2N_T0_13
set_property PACKAGE_PIN V9 [get_ports {led2[1]}]		;# D3 / AB16~IO_L2P_T0_13
set_property PACKAGE_PIN U8 [get_ports {led2[2]}]		;# C4 / Y16~IO_L1P_T0_13
set_property PACKAGE_PIN V7 [get_ports {led2[3]}]		;# D4 / AA16~IO_L1N_T0_13
set_property PACKAGE_PIN U7 [get_ports {led2[4]}]		;# C5 / AA15~IO_L4P_T0_13
set_property PACKAGE_PIN V6 [get_ports {led2[5]}]		;# D5 / AB15~IO_L4N_T0_13
set_property PACKAGE_PIN U6 [get_ports {led2[6]}]		;# C6 / Y13~IO_L5P_T0_13
set_property PACKAGE_PIN V5 [get_ports {led2[7]}]		;# D6 / AA14~IO_L5N_T0_13
set_property PACKAGE_PIN T8 [get_ports {led2[8]}]		;# C7 / W14~IO_L6P_T0_13
set_property PACKAGE_PIN V4 [get_ports {led2[9]}]		;# D7 / Y14~IO_L6N_T0_VREF_13
set_property PACKAGE_PIN R8 [get_ports {led2[10]}]		;# C8 / AA13~IO_L3P_T0_DQS_13
set_property PACKAGE_PIN T5 [get_ports {led2[11]}]		;# D8 / AB13~IO_L3N_T0_DQS_13
set_property PACKAGE_PIN R7 [get_ports {led2[12]}]		;# C9 / AB12~IO_L7N_T1_13
set_property PACKAGE_PIN T4 [get_ports {led2[13]}]		;# D9 / AB11~IO_L7P_T1_13
set_property PACKAGE_PIN T6 [get_ports {led2[14]}]		;# C10 / W12~IO_L12N_T1_MRCC_13
set_property PACKAGE_PIN U4 [get_ports {led2[15]}]		;# D10 / W11~IO_L12P_T1_MRCC_13
set_property PACKAGE_PIN R6 [get_ports {led2[16]}]		;# C11 / AA11~IO_L9N_T1_DQS_13
set_property PACKAGE_PIN U3 [get_ports {led2[17]}]		;# D11 / AA10~IO_L9P_T1_DQS_13
set_property PACKAGE_PIN R5 [get_ports {led2[18]}]		;# C12 / AA9~IO_L8P_T1_13
set_property PACKAGE_PIN V1 [get_ports {led2[19]}]		;# D12 / AB10~IO_L8N_T1_13
set_property IOSTANDARD LVCMOS33 [get_ports {led2[*]}]
set_property DRIVE 12 [get_ports {led2[*]}]

# bitstream settings
set_property BITSTREAM.CONFIG.CONFIGRATE 66 [current_design]  
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR No [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 2 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true [current_design] 
