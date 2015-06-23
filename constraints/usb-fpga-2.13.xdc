# !!! Constraint files are application specific !!!
# !!!          This is a template only          !!!

# on-board signals

# CLKOUT/FXCLK 
create_clock -name fxclk_in -period 20.833 [get_ports fxclk_in]
set_property PACKAGE_PIN P15 [get_ports fxclk_in]
set_property IOSTANDARD LVCMOS33 [get_ports fxclk_in]

# IFCLK 
create_clock -name ifclk_in -period 20.833 [get_ports ifclk_in]
set_property PACKAGE_PIN P17 [get_ports ifclk_in]
set_property IOSTANDARD LVCMOS33 [get_ports ifclk_in]


set_property PACKAGE_PIN M16 [get_ports {PB[0]}]  		;# PB0/FD0
set_property IOSTANDARD LVCMOS33 [get_ports {PB[0]}]

set_property PACKAGE_PIN L16 [get_ports {PB[1]}]  		;# PB1/FD1
set_property IOSTANDARD LVCMOS33 [get_ports {PB[1]}]

set_property PACKAGE_PIN L14 [get_ports {PB[2]}]  		;# PB2/FD2
set_property IOSTANDARD LVCMOS33 [get_ports {PB[2]}]

set_property PACKAGE_PIN M14 [get_ports {PB[3]}]  		;# PB3/FD3
set_property IOSTANDARD LVCMOS33 [get_ports {PB[3]}]

set_property PACKAGE_PIN L18 [get_ports {PB[4]}]  		;# PB4/FD4
set_property IOSTANDARD LVCMOS33 [get_ports {PB[4]}]

set_property PACKAGE_PIN M18 [get_ports {PB[5]}]  		;# PB5/FD5
set_property IOSTANDARD LVCMOS33 [get_ports {PB[5]}]

set_property PACKAGE_PIN R12 [get_ports {PB[6]}]  		;# PB6/FD6
set_property IOSTANDARD LVCMOS33 [get_ports {PB[6]}]

set_property PACKAGE_PIN R13 [get_ports {PB[7]}]  		;# PB7/FD7
set_property IOSTANDARD LVCMOS33 [get_ports {PB[7]}]


set_property PACKAGE_PIN T9 [get_ports {PD[0]}]  		;# PD0/FD8
set_property IOSTANDARD LVCMOS33 [get_ports {PD[0]}]

set_property PACKAGE_PIN V10 [get_ports {PD[1]}]  		;# PD1/FD9
set_property IOSTANDARD LVCMOS33 [get_ports {PD[1]}]

set_property PACKAGE_PIN U11 [get_ports {PD[2]}]  		;# PD2/FD10
set_property IOSTANDARD LVCMOS33 [get_ports {PD[2]}]

set_property PACKAGE_PIN V11 [get_ports {PD[3]}]  		;# PD3/FD11
set_property IOSTANDARD LVCMOS33 [get_ports {PD[3]}]

set_property PACKAGE_PIN V12 [get_ports {PD[4]}]  		;# PD4/FD12
set_property IOSTANDARD LVCMOS33 [get_ports {PD[4]}]

set_property PACKAGE_PIN U13 [get_ports {PD[5]}]  		;# PD5/FD13
set_property IOSTANDARD LVCMOS33 [get_ports {PD[5]}]

set_property PACKAGE_PIN U14 [get_ports {PD[6]}]  		;# PD6/FD14
set_property IOSTANDARD LVCMOS33 [get_ports {PD[6]}]

set_property PACKAGE_PIN V14 [get_ports {PD[7]}]  		;# PD7/FD15
set_property IOSTANDARD LVCMOS33 [get_ports {PD[7]}]


set_property PACKAGE_PIN R15 [get_ports {PA[0]}]  		;# PA0/INT0#
set_property IOSTANDARD LVCMOS33 [get_ports {PA[0]}]

set_property PACKAGE_PIN T15 [get_ports {PA[1]}]  		;# PA1/INT1#
set_property IOSTANDARD LVCMOS33 [get_ports {PA[1]}]

set_property PACKAGE_PIN T14 [get_ports {PA[2]}]  		;# PA2/SLOE
set_property IOSTANDARD LVCMOS33 [get_ports {PA[2]}]

set_property PACKAGE_PIN T13 [get_ports {PA[3]}]  		;# PA3/WU2
set_property IOSTANDARD LVCMOS33 [get_ports {PA[3]}]

set_property PACKAGE_PIN R11 [get_ports {PA[4]}]  		;# PA4/FIFOADR0
set_property IOSTANDARD LVCMOS33 [get_ports {PA[4]}]

set_property PACKAGE_PIN T11 [get_ports {PA[5]}]  		;# PA5/FIFOADR1
set_property IOSTANDARD LVCMOS33 [get_ports {PA[5]}]

set_property PACKAGE_PIN R10 [get_ports {PA[6]}]  		;# PA6/PKTEND
set_property IOSTANDARD LVCMOS33 [get_ports {PA[6]}]

set_property PACKAGE_PIN T10 [get_ports {PA[7]}]  		;# PA7/FLAGD/SLCS#
set_property IOSTANDARD LVCMOS33 [get_ports {PA[7]}]


set_property PACKAGE_PIN R17 [get_ports {PC[0]}]  		;# PC0/GPIFADR0
set_property IOSTANDARD LVCMOS33 [get_ports {PC[0]}]

set_property PACKAGE_PIN R18 [get_ports {PC[1]}]  		;# PC1/GPIFADR1
set_property IOSTANDARD LVCMOS33 [get_ports {PC[1]}]

set_property PACKAGE_PIN P18 [get_ports {PC[2]}]  		;# PC2/GPIFADR2
set_property IOSTANDARD LVCMOS33 [get_ports {PC[2]}]

set_property PACKAGE_PIN P14 [get_ports {PC[3]}]  		;# PC3/GPIFADR3
set_property IOSTANDARD LVCMOS33 [get_ports {PC[3]}]

set_property PACKAGE_PIN K18 [get_ports {FLASH_DO}]  		;# PC4/GPIFADR4
set_property IOSTANDARD LVCMOS33 [get_ports {FLASH_DO}]

set_property PACKAGE_PIN L13 [get_ports {FLASH_CS}]  		;# PC5/GPIFADR5
set_property IOSTANDARD LVCMOS33 [get_ports {FLASH_CS}]

set_property PACKAGE_PIN E9 [get_ports {FLASH_CLK}]  		;# PC6/GPIFADR6
set_property IOSTANDARD LVCMOS33 [get_ports {FLASH_CLK}]

set_property PACKAGE_PIN K17 [get_ports {FLASH_DI}]  		;# PC7/GPIFADR7
set_property IOSTANDARD LVCMOS33 [get_ports {FLASH_DI}]


set_property PACKAGE_PIN P10 [get_ports {PE[0]}]  		;# PE0/T0OUT
set_property IOSTANDARD LVCMOS33 [get_ports {PE[0]}]

set_property PACKAGE_PIN P7 [get_ports {PE[1]}]  		;# PE1/T1OUT
set_property IOSTANDARD LVCMOS33 [get_ports {PE[1]}]

set_property PACKAGE_PIN V15 [get_ports {PE[2]}]  		;# PE2/T2OUT
set_property IOSTANDARD LVCMOS33 [get_ports {PE[2]}]

set_property PACKAGE_PIN R16 [get_ports {PE[5]}]  		;# PE5/INT6
set_property IOSTANDARD LVCMOS33 [get_ports {PE[5]}]

set_property PACKAGE_PIN T16 [get_ports {PE[6]}]  		;# PE6/T2EX
set_property IOSTANDARD LVCMOS33 [get_ports {PE[6]}]


set_property PACKAGE_PIN V16 [get_ports {SLRD}]  		;# RDY0/SLRD
set_property IOSTANDARD LVCMOS33 [get_ports {SLRD}]

set_property PACKAGE_PIN U16 [get_ports {SLWR}]  		;# RDY1/SLWR
set_property IOSTANDARD LVCMOS33 [get_ports {SLWR}]

set_property PACKAGE_PIN V17 [get_ports {RDY2}]  		;# RDY2
set_property IOSTANDARD LVCMOS33 [get_ports {RDY2}]

set_property PACKAGE_PIN U17 [get_ports {RDY3}]  		;# RDY3
set_property IOSTANDARD LVCMOS33 [get_ports {RDY3}]

set_property PACKAGE_PIN U18 [get_ports {RDY4}]  		;# RDY4
set_property IOSTANDARD LVCMOS33 [get_ports {RDY4}]

set_property PACKAGE_PIN T18 [get_ports {RDY5}]  		;# RDY5
set_property IOSTANDARD LVCMOS33 [get_ports {RDY5}]


set_property PACKAGE_PIN N16 [get_ports {FLAGA}]  		;# CTL0/FLAGA
set_property IOSTANDARD LVCMOS33 [get_ports {FLAGA}]

set_property PACKAGE_PIN N15 [get_ports {FLAGB}]  		;# CTL1/FLAGB
set_property IOSTANDARD LVCMOS33 [get_ports {FLAGB}]

set_property PACKAGE_PIN N14 [get_ports {FLAGC}]  		;# CTL2/FLAGC
set_property IOSTANDARD LVCMOS33 [get_ports {FLAGC}]

set_property PACKAGE_PIN N17 [get_ports {CTL3}]  		;# CTL3
set_property IOSTANDARD LVCMOS33 [get_ports {CTL3}]

set_property PACKAGE_PIN M13 [get_ports {CTL4}]  		;# CTL4
set_property IOSTANDARD LVCMOS33 [get_ports {CTL4}]


set_property PACKAGE_PIN D10 [get_ports {INT4}]  		;# INT4
set_property IOSTANDARD LVCMOS33 [get_ports {INT4}]

set_property PACKAGE_PIN U12 [get_ports {INT5_N}]  		;# INT5#
set_property IOSTANDARD LVCMOS33 [get_ports {INT5_N}]

set_property PACKAGE_PIN M17 [get_ports {T0}]  		;# T0
set_property IOSTANDARD LVCMOS33 [get_ports {T0}]


set_property PACKAGE_PIN B8 [get_ports {SCL}]  		;# SCL
set_property IOSTANDARD LVCMOS33 [get_ports {SCL}]

set_property PACKAGE_PIN A10 [get_ports {SDA}]  		;# SDA
set_property IOSTANDARD LVCMOS33 [get_ports {SDA}]


set_property PACKAGE_PIN A8 [get_ports {RxD0}]  		;# RxD0
set_property IOSTANDARD LVCMOS33 [get_ports {RxD0}]

set_property PACKAGE_PIN A9 [get_ports {TxD0}]  		;# TxD0
set_property IOSTANDARD LVCMOS33 [get_ports {TxD0}]


# external I/O

set_property PACKAGE_PIN K16 [get_ports {IO_A[0]}]		;# A3 / E22~IO_L22P_T3_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[0]}]

set_property PACKAGE_PIN K15 [get_ports {IO_A[1]}]		;# A4 / C22~IO_L20P_T3_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[1]}]

set_property PACKAGE_PIN J15 [get_ports {IO_A[2]}]		;# A5 / E21~IO_L23P_T3_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[2]}]

set_property PACKAGE_PIN H15 [get_ports {IO_A[3]}]		;# A6 / B21~IO_L21P_T3_DQS_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[3]}]

set_property PACKAGE_PIN J14 [get_ports {IO_A[4]}]		;# A7 / D20~IO_L19P_T3_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[4]}]

set_property PACKAGE_PIN H17 [get_ports {IO_A[5]}]		;# A8 / B20~IO_L16P_T2_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[5]}]

set_property PACKAGE_PIN G17 [get_ports {IO_A[6]}]		;# A9 / C19~IO_L13N_T2_MRCC_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[6]}]

set_property PACKAGE_PIN G18 [get_ports {IO_A[7]}]		;# A10 / C18~IO_L13P_T2_MRCC_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[7]}]

set_property PACKAGE_PIN F18 [get_ports {IO_A[8]}]		;# A11 / B18~IO_L11N_T1_SRCC_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[8]}]

set_property PACKAGE_PIN E18 [get_ports {IO_A[9]}]		;# A12 / B17~IO_L11P_T1_SRCC_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[9]}]

set_property PACKAGE_PIN D18 [get_ports {IO_A[10]}]		;# A13 / B16~IO_L7N_T1_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[10]}]

set_property PACKAGE_PIN G13 [get_ports {IO_A[11]}]		;# A14 / A16~IO_L9N_T1_DQS_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[11]}]

set_property PACKAGE_PIN F13 [get_ports {IO_A[12]}]		;# A18 / A14~IO_L10N_T1_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[12]}]

set_property PACKAGE_PIN E16 [get_ports {IO_A[13]}]		;# A19 / D15~IO_L6N_T0_VREF_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[13]}]

set_property PACKAGE_PIN C17 [get_ports {IO_A[14]}]		;# A20 / B13~IO_L8N_T1_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[14]}]

set_property PACKAGE_PIN A18 [get_ports {IO_A[15]}]		;# A21 / N3~IO_L19N_T3_VREF_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[15]}]

set_property PACKAGE_PIN C15 [get_ports {IO_A[16]}]		;# A22 / H4~IO_L12P_T1_MRCC_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[16]}]

set_property PACKAGE_PIN B17 [get_ports {IO_A[17]}]		;# A23 / G4~IO_L12N_T1_MRCC_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[17]}]

set_property PACKAGE_PIN C14 [get_ports {IO_A[18]}]		;# A24 / E3~IO_L6N_T0_VREF_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[18]}]

set_property PACKAGE_PIN D13 [get_ports {IO_A[19]}]		;# A25 / B2~IO_L2N_T0_AD12N_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[19]}]

set_property PACKAGE_PIN A16 [get_ports {IO_A[20]}]		;# A26 / D2~IO_L4N_T0_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[20]}]

set_property PACKAGE_PIN B14 [get_ports {IO_A[21]}]		;# A27 / G2~IO_L8N_T1_AD14N_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[21]}]

set_property PACKAGE_PIN B12 [get_ports {IO_A[22]}]		;# A28 / A1~IO_L1N_T0_AD4N_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[22]}]

set_property PACKAGE_PIN A14 [get_ports {IO_A[23]}]		;# A29 / D1~IO_L3N_T0_DQS_AD5N_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[23]}]

set_property PACKAGE_PIN B11 [get_ports {IO_A[24]}]		;# A30 / G1~IO_L5P_T0_AD13P_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[24]}]


set_property PACKAGE_PIN J18 [get_ports {IO_B[0]}]		;# B3 / D22~IO_L22N_T3_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[0]}]

set_property PACKAGE_PIN J17 [get_ports {IO_B[1]}]		;# B4 / B22~IO_L20N_T3_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[1]}]

set_property PACKAGE_PIN K13 [get_ports {IO_B[2]}]		;# B5 / D21~IO_L23N_T3_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[2]}]

set_property PACKAGE_PIN J13 [get_ports {IO_B[3]}]		;# B6 / A21~IO_L21N_T3_DQS_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[3]}]

set_property PACKAGE_PIN H14 [get_ports {IO_B[4]}]		;# B7 / C20~IO_L19N_T3_VREF_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[4]}]

set_property PACKAGE_PIN G14 [get_ports {IO_B[5]}]		;# B8 / A20~IO_L16N_T2_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[5]}]

set_property PACKAGE_PIN G16 [get_ports {IO_B[6]}]		;# B9 / A19~IO_L17N_T2_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[6]}]

set_property PACKAGE_PIN H16 [get_ports {IO_B[7]}]		;# B10 / A18~IO_L17P_T2_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[7]}]

set_property PACKAGE_PIN F16 [get_ports {IO_B[8]}]		;# B11 / D17~IO_L12P_T1_MRCC_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[8]}]

set_property PACKAGE_PIN F15 [get_ports {IO_B[9]}]		;# B12 / C17~IO_L12N_T1_MRCC_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[9]}]

set_property PACKAGE_PIN E17 [get_ports {IO_B[10]}]		;# B13 / B15~IO_L7P_T1_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[10]}]

set_property PACKAGE_PIN D17 [get_ports {IO_B[11]}]		;# B14 / A15~IO_L9P_T1_DQS_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[11]}]

set_property PACKAGE_PIN F14 [get_ports {IO_B[12]}]		;# B18 / A13~IO_L10P_T1_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[12]}]

set_property PACKAGE_PIN E15 [get_ports {IO_B[13]}]		;# B19 / D14~IO_L6P_T0_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[13]}]

set_property PACKAGE_PIN C16 [get_ports {IO_B[14]}]		;# B20 / C13~IO_L8P_T1_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[14]}]

set_property PACKAGE_PIN B18 [get_ports {IO_B[15]}]		;# B21 / H3~IO_L11P_T1_SRCC_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[15]}]

set_property PACKAGE_PIN D15 [get_ports {IO_B[16]}]		;# B22 / G3~IO_L11N_T1_SRCC_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[16]}]

set_property PACKAGE_PIN B16 [get_ports {IO_B[17]}]		;# B23 / F4~IO_0_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[17]}]

set_property PACKAGE_PIN D14 [get_ports {IO_B[18]}]		;# B24 / F3~IO_L6P_T0_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[18]}]

set_property PACKAGE_PIN D12 [get_ports {IO_B[19]}]		;# B25 / C2~IO_L2P_T0_AD12P_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[19]}]

set_property PACKAGE_PIN A15 [get_ports {IO_B[20]}]		;# B26 / E2~IO_L4P_T0_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[20]}]

set_property PACKAGE_PIN B13 [get_ports {IO_B[21]}]		;# B27 / H2~IO_L8P_T1_AD14P_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[21]}]

set_property PACKAGE_PIN C12 [get_ports {IO_B[22]}]		;# B28 / B1~IO_L1P_T0_AD4P_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[22]}]

set_property PACKAGE_PIN A13 [get_ports {IO_B[23]}]		;# B29 / E1~IO_L3P_T0_DQS_AD5P_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[23]}]

set_property PACKAGE_PIN A11 [get_ports {IO_B[24]}]		;# B30 / F1~IO_L5N_T0_AD13N_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[24]}]


set_property PACKAGE_PIN U9 [get_ports {IO_C[0]}]		;# C3 / AB17~IO_L2N_T0_13
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[0]}]

set_property PACKAGE_PIN U8 [get_ports {IO_C[1]}]		;# C4 / Y16~IO_L1P_T0_13
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[1]}]

set_property PACKAGE_PIN U7 [get_ports {IO_C[2]}]		;# C5 / AA15~IO_L4P_T0_13
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[2]}]

set_property PACKAGE_PIN U6 [get_ports {IO_C[3]}]		;# C6 / Y13~IO_L5P_T0_13
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[3]}]

set_property PACKAGE_PIN T8 [get_ports {IO_C[4]}]		;# C7 / W14~IO_L6P_T0_13
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[4]}]

set_property PACKAGE_PIN R8 [get_ports {IO_C[5]}]		;# C8 / AA13~IO_L3P_T0_DQS_13
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[5]}]

set_property PACKAGE_PIN R7 [get_ports {IO_C[6]}]		;# C9 / AB12~IO_L7N_T1_13
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[6]}]

set_property PACKAGE_PIN T6 [get_ports {IO_C[7]}]		;# C10 / W12~IO_L12N_T1_MRCC_13
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[7]}]

set_property PACKAGE_PIN R6 [get_ports {IO_C[8]}]		;# C11 / AA11~IO_L9N_T1_DQS_13
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[8]}]

set_property PACKAGE_PIN R5 [get_ports {IO_C[9]}]		;# C12 / AA9~IO_L8P_T1_13
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[9]}]

set_property PACKAGE_PIN V2 [get_ports {IO_C[10]}]		;# C13 / W9~IO_L24P_T3_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[10]}]

set_property PACKAGE_PIN U2 [get_ports {IO_C[11]}]		;# C14 / AA8~IO_L22P_T3_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[11]}]

set_property PACKAGE_PIN K6 [get_ports {IO_C[12]}]		;# C15 / V7~IO_L19P_T3_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[12]}]

set_property PACKAGE_PIN N6 [get_ports {IO_C[13]}]		;# C19 / AB6~IO_L20N_T3_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[13]}]

set_property PACKAGE_PIN M6 [get_ports {IO_C[14]}]		;# C20 / AA5~IO_L10P_T1_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[14]}]

set_property PACKAGE_PIN L6 [get_ports {IO_C[15]}]		;# C21 / Y4~IO_L11P_T1_SRCC_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[15]}]

set_property PACKAGE_PIN L5 [get_ports {IO_C[16]}]		;# C22 / V4~IO_L12P_T1_MRCC_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[16]}]

set_property PACKAGE_PIN N4 [get_ports {IO_C[17]}]		;# C23 / Y3~IO_L9P_T1_DQS_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[17]}]

set_property PACKAGE_PIN M4 [get_ports {IO_C[18]}]		;# C24 / U3~IO_L6P_T0_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[18]}]

set_property PACKAGE_PIN M3 [get_ports {IO_C[19]}]		;# C25 / AB3~IO_L8P_T1_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[19]}]

set_property PACKAGE_PIN M2 [get_ports {IO_C[20]}]		;# C26 / W2~IO_L4P_T0_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[20]}]

set_property PACKAGE_PIN K5 [get_ports {IO_C[21]}]		;# C27 / U2~IO_L2P_T0_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[21]}]

set_property PACKAGE_PIN L4 [get_ports {IO_C[22]}]		;# C28 / AA1~IO_L7P_T1_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[22]}]

set_property PACKAGE_PIN L3 [get_ports {IO_C[23]}]		;# C29 / W1~IO_L5P_T0_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[23]}]

set_property PACKAGE_PIN K3 [get_ports {IO_C[24]}]		;# C30 / T1~IO_L1P_T0_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[24]}]


set_property PACKAGE_PIN V9 [get_ports {IO_D[0]}]		;# D3 / AB16~IO_L2P_T0_13
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[0]}]

set_property PACKAGE_PIN V7 [get_ports {IO_D[1]}]		;# D4 / AA16~IO_L1N_T0_13
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[1]}]

set_property PACKAGE_PIN V6 [get_ports {IO_D[2]}]		;# D5 / AB15~IO_L4N_T0_13
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[2]}]

set_property PACKAGE_PIN V5 [get_ports {IO_D[3]}]		;# D6 / AA14~IO_L5N_T0_13
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[3]}]

set_property PACKAGE_PIN V4 [get_ports {IO_D[4]}]		;# D7 / Y14~IO_L6N_T0_VREF_13
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[4]}]

set_property PACKAGE_PIN T5 [get_ports {IO_D[5]}]		;# D8 / AB13~IO_L3N_T0_DQS_13
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[5]}]

set_property PACKAGE_PIN T4 [get_ports {IO_D[6]}]		;# D9 / AB11~IO_L7P_T1_13
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[6]}]

set_property PACKAGE_PIN U4 [get_ports {IO_D[7]}]		;# D10 / W11~IO_L12P_T1_MRCC_13
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[7]}]

set_property PACKAGE_PIN U3 [get_ports {IO_D[8]}]		;# D11 / AA10~IO_L9P_T1_DQS_13
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[8]}]

set_property PACKAGE_PIN V1 [get_ports {IO_D[9]}]		;# D12 / AB10~IO_L8N_T1_13
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[9]}]

set_property PACKAGE_PIN U1 [get_ports {IO_D[10]}]		;# D13 / Y9~IO_L24N_T3_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[10]}]

set_property PACKAGE_PIN T3 [get_ports {IO_D[11]}]		;# D14 / AB8~IO_L22N_T3_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[11]}]

set_property PACKAGE_PIN R3 [get_ports {IO_D[12]}]		;# D15 / W7~IO_L19N_T3_VREF_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[12]}]

set_property PACKAGE_PIN P5 [get_ports {IO_D[13]}]		;# D19 / AB7~IO_L20P_T3_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[13]}]

set_property PACKAGE_PIN N5 [get_ports {IO_D[14]}]		;# D20 / AB5~IO_L10N_T1_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[14]}]

set_property PACKAGE_PIN P4 [get_ports {IO_D[15]}]		;# D21 / AA4~IO_L11N_T1_SRCC_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[15]}]

set_property PACKAGE_PIN P3 [get_ports {IO_D[16]}]		;# D22 / W4~IO_L12N_T1_MRCC_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[16]}]

set_property PACKAGE_PIN T1 [get_ports {IO_D[17]}]		;# D23 / AA3~IO_L9N_T1_DQS_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[17]}]

set_property PACKAGE_PIN R1 [get_ports {IO_D[18]}]		;# D24 / V3~IO_L6N_T0_VREF_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[18]}]

set_property PACKAGE_PIN R2 [get_ports {IO_D[19]}]		;# D25 / AB2~IO_L8N_T1_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[19]}]

set_property PACKAGE_PIN P2 [get_ports {IO_D[20]}]		;# D26 / Y2~IO_L4N_T0_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[20]}]

set_property PACKAGE_PIN N2 [get_ports {IO_D[21]}]		;# D27 / V2~IO_L2N_T0_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[21]}]

set_property PACKAGE_PIN N1 [get_ports {IO_D[22]}]		;# D28 / AB1~IO_L7N_T1_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[22]}]

set_property PACKAGE_PIN M1 [get_ports {IO_D[23]}]		;# D29 / Y1~IO_L5N_T0_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[23]}]

set_property PACKAGE_PIN L1 [get_ports {IO_D[24]}]		;# D30 / U1~IO_L1N_T0_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[24]}]
