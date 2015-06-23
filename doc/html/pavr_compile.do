;# This is a Modelsim PE/Plus 5.3a_p1 macro file.
;# It can be seen here what's the compiling order for pAVR's VHDL sources.

;# Compile all pAVR sources
vcom -reportprogress 300 -work work {std_util.vhd}
vcom -reportprogress 300 -work work {pavr_util.vhd}
vcom -reportprogress 300 -work work {pavr_constants.vhd}
vcom -reportprogress 300 -work work {pavr_alu.vhd}
vcom -reportprogress 300 -work work {pavr_data_mem.vhd}
vcom -reportprogress 300 -work work {pavr_register_file.vhd}
vcom -reportprogress 300 -work work {pavr_io_file.vhd}
vcom -reportprogress 300 -work work {pavr_control.vhd}
