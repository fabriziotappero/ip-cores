set test_default_scan_style multiplexed_flip_flop
set_dft_drc_configuration -internal_pins enable
set_dft_signal -type  InOutControl -hookup_pin  core0/leon3core0/testoen   -view existing_dft
set_dft_signal -type  Reset        -hookup_pin  core0/leon3core0/testrst   -view existing_dft
set_dft_signal -type  ScanEnable   -hookup_pin  core0/leon3core0/scanen    -view existing_dft
set_dft_signal -type  ScanDataIn   -hookup_pin  core0/leon3core0/gpioin(*) -view existing_dft
set_dft_signal -type  ScanDataOut  -hookup_pin  core0/leon3core0/address(*) -view existing_dft
set_dft_signal -type  ScanClock    -hookup_pin  core0/leon3core0/clk -view existing_dft -timing [list 1 10]
set_dft_signal -type  TestMode     -hookup_pin  core0/leon3core0/testen    -view existing_dft
set_clock_gating_style -sequential latch -control_point before -control_signal scan_enable
#insert_clock_gating
hookup_testports
