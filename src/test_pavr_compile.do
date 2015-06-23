;# This is a Modelsim PE/Plus 5.3a_p1 macro file.
;# It can be seen here what's the compiling order for pAVR's test VHDL sources.

;# Compile pAVR
do pavr_compile.do

;# Compile test architectures
;# Test-only constants (such as Program Memory length, etc)
vcom -reportprogress 300 -work work {test_pavr_constants.vhd}
;# Test-only functions (such as for quickly writing Program Memory)
vcom -reportprogress 300 -work work {test_pavr_util.vhd}
;# Program Memory
vcom -reportprogress 300 -work work {test_pavr_pm.vhd}
;# Main test architecture
vcom -reportprogress 300 -work work {test_pavr.vhd}
