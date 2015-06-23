create_clock -name fxclk_in -period 20 [get_ports fxclk_in]
set_property LOC Y19 [get_ports fxclk_in]
set_property IOSTANDARD LVCMOS33 [get_ports fxclk_in]


# output
set_property LOC P20 [get_ports pb[0]]  	;# PB0
set_property LOC N17 [get_ports pb[1]]  	;# PB1
set_property LOC P21 [get_ports pb[2]]  	;# PB2
set_property LOC R21 [get_ports pb[3]]  	;# PB3
set_property LOC T21 [get_ports pb[4]]  	;# PB4
set_property LOC U21 [get_ports pb[5]]  	;# PB5
set_property LOC P19 [get_ports pb[6]]  	;# PB6
set_property LOC R19 [get_ports pb[7]]		;# PB7

set_property IOSTANDARD LVCMOS33 [get_ports pb[*]]
set_property DRIVE 12 [get_ports pb[*]]



# input
set_property LOC T20 [get_ports pd[0]]		;# PD0
set_property LOC U20 [get_ports pd[1]]		;# PD1
set_property LOC U18 [get_ports pd[2]]		;# PD2
set_property LOC U17 [get_ports pd[3]]		;# PD3
set_property LOC W19 [get_ports pd[4]]		;# PD4
set_property LOC W20 [get_ports pd[5]]		;# PD5
set_property LOC W21 [get_ports pd[6]]		;# PD6
set_property LOC W22 [get_ports pd[7]]		;# PD7

set_property IOSTANDARD LVCMOS33 [get_ports pd[*]]
