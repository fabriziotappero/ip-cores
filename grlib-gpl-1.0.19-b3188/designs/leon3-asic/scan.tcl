set test_default_scan_style multiplexed_flip_flop
set_dft_drc_configuration -internal_pins enable
set_dft_signal -type  InOutControl -port  dsurx   -view existing_dft
set_dft_signal -type  Reset        -port  dsuen -active_state 0  -view existing_dft
set_dft_signal -type  ScanEnable   -port  dsubre    -view existing_dft
set_dft_signal -type  ScanDataIn   -port  [get_ports gpio\[*\]] -view existing_dft
set_dft_signal -type  ScanDataOut  -port  [get_ports address\[*\]] -view existing_dft
set_dft_signal -type  ScanClock    -port  clka -view existing_dft -timing [list 1 10]
set_dft_signal -type  TestMode     -port  testen    -view existing_dft
set_clock_gating_style -sequential latch -control_point before -control_signal scan_enable
#insert_clock_gating
hookup_testports
