set_scan_configuration -clock_mixing mix_clocks -chain_count 16
create_test_protocol
preview_dft
dft_drc > synopsys/dft_drc.log
