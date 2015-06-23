# !!! Constraint files are application specific !!!
# !!!          This is a template only          !!!

# on-board signals

# CLKOUT/FXCLK 
create_clock -name fxclk_in -period 20.833 [get_ports fxclk_in]
set_property PACKAGE_PIN J16 [get_ports fxclk_in]
set_property IOSTANDARD LVCMOS33 [get_ports fxclk_in]

# IFCLK 
create_clock -name ifclk_in -period 20.833 [get_ports ifclk_in]
set_property PACKAGE_PIN J14 [get_ports ifclk_in]
set_property IOSTANDARD LVCMOS33 [get_ports ifclk_in]


set_property PACKAGE_PIN D16 [get_ports {PB[0]}]  		;# PB0/FD0
set_property IOSTANDARD LVCMOS33 [get_ports {PB[0]}]

set_property PACKAGE_PIN F15 [get_ports {PB[1]}]  		;# PB1/FD1
set_property IOSTANDARD LVCMOS33 [get_ports {PB[1]}]

set_property PACKAGE_PIN E15 [get_ports {PB[2]}]  		;# PB2/FD2
set_property IOSTANDARD LVCMOS33 [get_ports {PB[2]}]

set_property PACKAGE_PIN D14 [get_ports {PB[3]}]  		;# PB3/FD3
set_property IOSTANDARD LVCMOS33 [get_ports {PB[3]}]

set_property PACKAGE_PIN F13 [get_ports {PB[4]}]  		;# PB4/FD4
set_property IOSTANDARD LVCMOS33 [get_ports {PB[4]}]

set_property PACKAGE_PIN E12 [get_ports {PB[5]}]  		;# PB5/FD5
set_property IOSTANDARD LVCMOS33 [get_ports {PB[5]}]

set_property PACKAGE_PIN F12 [get_ports {PB[6]}]  		;# PB6/FD6
set_property IOSTANDARD LVCMOS33 [get_ports {PB[6]}]

set_property PACKAGE_PIN G12 [get_ports {PB[7]}]  		;# PB7/FD7
set_property IOSTANDARD LVCMOS33 [get_ports {PB[7]}]


set_property PACKAGE_PIN H14 [get_ports {PD[0]}]  		;# PD0/FD8
set_property IOSTANDARD LVCMOS33 [get_ports {PD[0]}]

set_property PACKAGE_PIN J11 [get_ports {PD[1]}]  		;# PD1/FD9
set_property IOSTANDARD LVCMOS33 [get_ports {PD[1]}]

set_property PACKAGE_PIN J12 [get_ports {PD[2]}]  		;# PD2/FD10
set_property IOSTANDARD LVCMOS33 [get_ports {PD[2]}]

set_property PACKAGE_PIN J13 [get_ports {PD[3]}]  		;# PD3/FD11
set_property IOSTANDARD LVCMOS33 [get_ports {PD[3]}]

set_property PACKAGE_PIN K12 [get_ports {PD[4]}]  		;# PD4/FD12
set_property IOSTANDARD LVCMOS33 [get_ports {PD[4]}]

set_property PACKAGE_PIN K15 [get_ports {PD[5]}]  		;# PD5/FD13
set_property IOSTANDARD LVCMOS33 [get_ports {PD[5]}]

set_property PACKAGE_PIN K16 [get_ports {PD[6]}]  		;# PD6/FD14
set_property IOSTANDARD LVCMOS33 [get_ports {PD[6]}]

set_property PACKAGE_PIN M14 [get_ports {PD[7]}]  		;# PD7/FD15
set_property IOSTANDARD LVCMOS33 [get_ports {PD[7]}]


set_property PACKAGE_PIN R11 [get_ports {PA[0]}]  		;# PA0/INT0#
set_property IOSTANDARD LVCMOS33 [get_ports {PA[0]}]

set_property PACKAGE_PIN T10 [get_ports {PA[1]}]  		;# PA1/INT1#
set_property IOSTANDARD LVCMOS33 [get_ports {PA[1]}]

set_property PACKAGE_PIN H13 [get_ports {PA[2]}]  		;# PA2/SLOE
set_property IOSTANDARD LVCMOS33 [get_ports {PA[2]}]

set_property PACKAGE_PIN T3 [get_ports {PA[3]}]  		;# PA3/WU2
set_property IOSTANDARD LVCMOS33 [get_ports {PA[3]}]

set_property PACKAGE_PIN T11 [get_ports {PA[4]}]  		;# PA4/FIFOADR0
set_property IOSTANDARD LVCMOS33 [get_ports {PA[4]}]

set_property PACKAGE_PIN N11 [get_ports {PA[5]}]  		;# PA5/FIFOADR1
set_property IOSTANDARD LVCMOS33 [get_ports {PA[5]}]

set_property PACKAGE_PIN T5 [get_ports {PA[6]}]  		;# PA6/PKTEND
set_property IOSTANDARD LVCMOS33 [get_ports {PA[6]}]

set_property PACKAGE_PIN R3 [get_ports {PA[7]}]  		;# PA7/FLAGD/SLCS#
set_property IOSTANDARD LVCMOS33 [get_ports {PA[7]}]


set_property PACKAGE_PIN P10 [get_ports {PC[0]}]  		;# PC0/GPIFADR0
set_property IOSTANDARD LVCMOS33 [get_ports {PC[0]}]

set_property PACKAGE_PIN N12 [get_ports {PC[1]}]  		;# PC1/GPIFADR1
set_property IOSTANDARD LVCMOS33 [get_ports {PC[1]}]

set_property PACKAGE_PIN P12 [get_ports {PC[2]}]  		;# PC2/GPIFADR2
set_property IOSTANDARD LVCMOS33 [get_ports {PC[2]}]

set_property PACKAGE_PIN N5 [get_ports {PC[3]}]  		;# PC3/GPIFADR3
set_property IOSTANDARD LVCMOS33 [get_ports {PC[3]}]

set_property PACKAGE_PIN P5 [get_ports {PC[4]}]  		;# PC4/GPIFADR4
set_property IOSTANDARD LVCMOS33 [get_ports {PC[4]}]

set_property PACKAGE_PIN L8 [get_ports {PC[5]}]  		;# PC5/GPIFADR5
set_property IOSTANDARD LVCMOS33 [get_ports {PC[5]}]

set_property PACKAGE_PIN L7 [get_ports {PC[6]}]  		;# PC6/GPIFADR6
set_property IOSTANDARD LVCMOS33 [get_ports {PC[6]}]

set_property PACKAGE_PIN R5 [get_ports {PC[7]}]  		;# PC7/GPIFADR7
set_property IOSTANDARD LVCMOS33 [get_ports {PC[7]}]


set_property PACKAGE_PIN H16 [get_ports {SLRD}]  		;# RDY0/SLRD
set_property IOSTANDARD LVCMOS33 [get_ports {SLRD}]

set_property PACKAGE_PIN H15 [get_ports {SLWR}]  		;# RDY1/SLWR
set_property IOSTANDARD LVCMOS33 [get_ports {SLWR}]


set_property PACKAGE_PIN G14 [get_ports {FLAGA}]  		;# CTL0/FLAGA
set_property IOSTANDARD LVCMOS33 [get_ports {FLAGA}]

set_property PACKAGE_PIN G16 [get_ports {FLAGB}]  		;# CTL1/FLAGB
set_property IOSTANDARD LVCMOS33 [get_ports {FLAGB}]

set_property PACKAGE_PIN H11 [get_ports {FLAGC}]  		;# CTL2/FLAGC
set_property IOSTANDARD LVCMOS33 [get_ports {FLAGC}]

set_property PACKAGE_PIN G11 [get_ports {CTL3}]  		;# CTL3
set_property IOSTANDARD LVCMOS33 [get_ports {CTL3}]


set_property PACKAGE_PIN F15 [get_ports {SCL}]  		;# SCL
set_property IOSTANDARD LVCMOS33 [get_ports {SCL}]

set_property PACKAGE_PIN E16 [get_ports {SDA}]  		;# SDA
set_property IOSTANDARD LVCMOS33 [get_ports {SDA}]


set_property PACKAGE_PIN E13 [get_ports {RxD1}]  		;# RxD1
set_property IOSTANDARD LVCMOS33 [get_ports {RxD1}]

set_property PACKAGE_PIN F14 [get_ports {TxD1}]  		;# TxD1
set_property IOSTANDARD LVCMOS33 [get_ports {TxD1}]


# external I/O

set_property PACKAGE_PIN B16 [get_ports {IO_A[0]}]		;# A6 / B16~IO_L29N_A22_M1A14_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[0]}]

set_property PACKAGE_PIN B15 [get_ports {IO_A[1]}]		;# A7 / B15~IO_L29P_A23_M1A13_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[1]}]

set_property PACKAGE_PIN A14 [get_ports {IO_A[2]}]		;# A8 / A14~IO_L65N_SCP2_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[2]}]

set_property PACKAGE_PIN A13 [get_ports {IO_A[3]}]		;# A9 / A13~IO_L63N_SCP6_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[3]}]

set_property PACKAGE_PIN A12 [get_ports {IO_A[4]}]		;# A10 / A12~IO_L62N_VREF_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[4]}]

set_property PACKAGE_PIN D12 [get_ports {IO_A[5]}]		;# A11 / D12~IO_L66N_SCP0_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[5]}]

set_property PACKAGE_PIN D11 [get_ports {IO_A[6]}]		;# A12 / D11~IO_L66P_SCP1_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[6]}]

set_property PACKAGE_PIN A11 [get_ports {IO_A[7]}]		;# A13 / A11~IO_L39N_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[7]}]

set_property PACKAGE_PIN A10 [get_ports {IO_A[8]}]		;# A14 / A10~IO_L35N_GCLK16_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[8]}]

set_property PACKAGE_PIN C10 [get_ports {IO_A[9]}]		;# A18 / C10~IO_L37N_GCLK12_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[9]}]

set_property PACKAGE_PIN D9 [get_ports {IO_A[10]}]		;# A19 / D9~IO_L40N_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[10]}]

set_property PACKAGE_PIN A9 [get_ports {IO_A[11]}]		;# A20 / A9~IO_L34N_GCLK18_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[11]}]

set_property PACKAGE_PIN C8 [get_ports {IO_A[12]}]		;# A21 / C8~IO_L38N_VREF_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[12]}]

set_property PACKAGE_PIN A8 [get_ports {IO_A[13]}]		;# A22 / A8~IO_L33N_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[13]}]

set_property PACKAGE_PIN E8 [get_ports {IO_A[14]}]		;# A23 / E8~IO_L36N_GCLK14_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[14]}]

set_property PACKAGE_PIN E7 [get_ports {IO_A[15]}]		;# A24 / E7~IO_L36P_GCLK15_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[15]}]

set_property PACKAGE_PIN A7 [get_ports {IO_A[16]}]		;# A25 / A7~IO_L6N_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[16]}]

set_property PACKAGE_PIN C6 [get_ports {IO_A[17]}]		;# A26 / C6~IO_L7N_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[17]}]

set_property PACKAGE_PIN A6 [get_ports {IO_A[18]}]		;# A27 / A6~IO_L4N_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[18]}]

set_property PACKAGE_PIN A5 [get_ports {IO_A[19]}]		;# A28 / A5~IO_L2N_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[19]}]

set_property PACKAGE_PIN C5 [get_ports {IO_A[20]}]		;# A29 / C5~IO_L3N_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[20]}]

set_property PACKAGE_PIN A4 [get_ports {IO_A[21]}]		;# A30 / A4~IO_L1N_VREF_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[21]}]


set_property PACKAGE_PIN C16 [get_ports {IO_B[0]}]		;# B6 / C16~IO_L33N_A14_M1A4_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[0]}]

set_property PACKAGE_PIN C15 [get_ports {IO_B[1]}]		;# B7 / C15~IO_L33P_A15_M1A10_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[1]}]

set_property PACKAGE_PIN B14 [get_ports {IO_B[2]}]		;# B8 / B14~IO_L65P_SCP3_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[2]}]

set_property PACKAGE_PIN C13 [get_ports {IO_B[3]}]		;# B9 / C13~IO_L63P_SCP7_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[3]}]

set_property PACKAGE_PIN B12 [get_ports {IO_B[4]}]		;# B10 / B12~IO_L62P_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[4]}]

set_property PACKAGE_PIN E11 [get_ports {IO_B[5]}]		;# B11 / E11~IO_L64N_SCP4_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[5]}]

set_property PACKAGE_PIN F10 [get_ports {IO_B[6]}]		;# B12 / F10~IO_L64P_SCP5_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[6]}]

set_property PACKAGE_PIN C11 [get_ports {IO_B[7]}]		;# B13 / C11~IO_L39P_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[7]}]

set_property PACKAGE_PIN B10 [get_ports {IO_B[8]}]		;# B14 / B10~IO_L35P_GCLK17_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[8]}]

set_property PACKAGE_PIN E10 [get_ports {IO_B[9]}]		;# B18 / E10~IO_L37P_GCLK13_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[9]}]

set_property PACKAGE_PIN F9 [get_ports {IO_B[10]}]		;# B19 / F9~IO_L40P_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[10]}]

set_property PACKAGE_PIN C9 [get_ports {IO_B[11]}]		;# B20 / C9~IO_L34P_GCLK19_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[11]}]

set_property PACKAGE_PIN D8 [get_ports {IO_B[12]}]		;# B21 / D8~IO_L38P_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[12]}]

set_property PACKAGE_PIN B8 [get_ports {IO_B[13]}]		;# B22 / B8~IO_L33P_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[13]}]

set_property PACKAGE_PIN F7 [get_ports {IO_B[14]}]		;# B23 / F7~IO_L5P_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[14]}]

set_property PACKAGE_PIN E6 [get_ports {IO_B[15]}]		;# B24 / E6~IO_L5N_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[15]}]

set_property PACKAGE_PIN C7 [get_ports {IO_B[16]}]		;# B25 / C7~IO_L6P_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[16]}]

set_property PACKAGE_PIN D6 [get_ports {IO_B[17]}]		;# B26 / D6~IO_L7P_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[17]}]

set_property PACKAGE_PIN B6 [get_ports {IO_B[18]}]		;# B27 / B6~IO_L4P_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[18]}]

set_property PACKAGE_PIN B5 [get_ports {IO_B[19]}]		;# B28 / B5~IO_L2P_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[19]}]

set_property PACKAGE_PIN D5 [get_ports {IO_B[20]}]		;# B29 / D5~IO_L3P_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[20]}]

set_property PACKAGE_PIN C4 [get_ports {IO_B[21]}]		;# B30 / C4~IO_L1P_HSWAPEN_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[21]}]


set_property PACKAGE_PIN R15 [get_ports {IO_C[0]}]		;# C6 / R15~IO_L49P_M1DQ10_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[0]}]

set_property PACKAGE_PIN N16 [get_ports {IO_C[1]}]		;# C7 / N16~IO_L45N_A0_M1LDQSN_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[1]}]

set_property PACKAGE_PIN N14 [get_ports {IO_C[2]}]		;# C8 / N14~IO_L45P_A1_M1LDQS_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[2]}]

set_property PACKAGE_PIN T15 [get_ports {IO_C[3]}]		;# C9 / T15~IO_L50N_M1UDQSN_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[3]}]

set_property PACKAGE_PIN R14 [get_ports {IO_C[4]}]		;# C10 / R14~IO_L50P_M1UDQS_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[4]}]

set_property PACKAGE_PIN R12 [get_ports {IO_C[5]}]		;# C11 / R12~IO_L52P_M1DQ14_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[5]}]

set_property PACKAGE_PIN L16 [get_ports {IO_C[6]}]		;# C12 / L16~IO_L47N_LDC_M1DQ1_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[6]}]

set_property PACKAGE_PIN L14 [get_ports {IO_C[7]}]		;# C13 / L14~IO_L47P_FWE_B_M1DQ0_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[7]}]

set_property PACKAGE_PIN L13 [get_ports {IO_C[8]}]		;# C14 / L13~IO_L53N_VREF_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[8]}]

set_property PACKAGE_PIN L12 [get_ports {IO_C[9]}]		;# C15 / L12~IO_L53P_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[9]}]

set_property PACKAGE_PIN M11 [get_ports {IO_C[10]}]		;# C19 / M11~IO_L2N_CMPMOSI_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[10]}]

set_property PACKAGE_PIN K11 [get_ports {IO_C[11]}]		;# C20 / K11~IO_L42N_GCLK6_TRDY1_M1LDM_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[11]}]

set_property PACKAGE_PIN L10 [get_ports {IO_C[12]}]		;# C21 / L10~IO_L16P_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[12]}]

set_property PACKAGE_PIN P9 [get_ports {IO_C[13]}]		;# C22 / P9~IO_L14N_D12_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[13]}]

set_property PACKAGE_PIN N9 [get_ports {IO_C[14]}]		;# C23 / N9~IO_L14P_D11_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[14]}]

set_property PACKAGE_PIN M9 [get_ports {IO_C[15]}]		;# C24 / M9~IO_L29P_GCLK3_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[15]}]

set_property PACKAGE_PIN N8 [get_ports {IO_C[16]}]		;# C25 / N8~IO_L29N_GCLK2_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[16]}]

set_property PACKAGE_PIN R7 [get_ports {IO_C[17]}]		;# C26 / R7~IO_L32P_GCLK29_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[17]}]

set_property PACKAGE_PIN M7 [get_ports {IO_C[18]}]		;# C27 / M7~IO_L31N_GCLK30_D15_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[18]}]

set_property PACKAGE_PIN P6 [get_ports {IO_C[19]}]		;# C28 / P6~IO_L47P_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[19]}]

set_property PACKAGE_PIN M6 [get_ports {IO_C[20]}]		;# C29 / M6~IO_L64P_D8_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[20]}]

set_property PACKAGE_PIN P4 [get_ports {IO_C[21]}]		;# C30 / P4~IO_L63P_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[21]}]


set_property PACKAGE_PIN R16 [get_ports {IO_D[0]}]		;# D6 / R16~IO_L49N_M1DQ11_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[0]}]

set_property PACKAGE_PIN P16 [get_ports {IO_D[1]}]		;# D7 / P16~IO_L48N_M1DQ9_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[1]}]

set_property PACKAGE_PIN P15 [get_ports {IO_D[2]}]		;# D8 / P15~IO_L48P_HDC_M1DQ8_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[2]}]

set_property PACKAGE_PIN T14 [get_ports {IO_D[3]}]		;# D9 / T14~IO_L51P_M1DQ12_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[3]}]

set_property PACKAGE_PIN T13 [get_ports {IO_D[4]}]		;# D10 / T13~IO_L51N_M1DQ13_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[4]}]

set_property PACKAGE_PIN T12 [get_ports {IO_D[5]}]		;# D11 / T12~IO_L52N_M1DQ15_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[5]}]

set_property PACKAGE_PIN M16 [get_ports {IO_D[6]}]		;# D12 / M16~IO_L46N_FOE_B_M1DQ3_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[6]}]

set_property PACKAGE_PIN M15 [get_ports {IO_D[7]}]		;# D13 / M15~IO_L46P_FCS_B_M1DQ2_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[7]}]

set_property PACKAGE_PIN K14 [get_ports {IO_D[8]}]		;# D14 / K14~IO_L41N_GCLK8_M1CASN_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[8]}]

set_property PACKAGE_PIN M13 [get_ports {IO_D[9]}]		;# D15 / M13~IO_L74P_AWAKE_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[9]}]

set_property PACKAGE_PIN M12 [get_ports {IO_D[10]}]		;# D19 / M12~IO_L2P_CMPCLK_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[10]}]

set_property PACKAGE_PIN P11 [get_ports {IO_D[11]}]		;# D20 / P11~IO_L13N_D10_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[11]}]

set_property PACKAGE_PIN M10 [get_ports {IO_D[12]}]		;# D21 / M10~IO_L16N_VREF_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[12]}]

set_property PACKAGE_PIN T9 [get_ports {IO_D[13]}]		;# D22 / T9~IO_L23N_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[13]}]

set_property PACKAGE_PIN R9 [get_ports {IO_D[14]}]		;# D23 / R9~IO_L23P_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[14]}]

set_property PACKAGE_PIN T8 [get_ports {IO_D[15]}]		;# D24 / T8~IO_L30N_GCLK0_USERCCLK_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[15]}]

set_property PACKAGE_PIN P8 [get_ports {IO_D[16]}]		;# D25 / P8~IO_L30P_GCLK1_D13_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[16]}]

set_property PACKAGE_PIN T7 [get_ports {IO_D[17]}]		;# D26 / T7~IO_L32N_GCLK28_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[17]}]

set_property PACKAGE_PIN P7 [get_ports {IO_D[18]}]		;# D27 / P7~IO_L31P_GCLK31_D14_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[18]}]

set_property PACKAGE_PIN T6 [get_ports {IO_D[19]}]		;# D28 / T6~IO_L47N_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[19]}]

set_property PACKAGE_PIN N6 [get_ports {IO_D[20]}]		;# D29 / N6~IO_L64N_D9_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[20]}]

set_property PACKAGE_PIN T4 [get_ports {IO_D[21]}]		;# D30 / T4~IO_L63N_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[21]}]
