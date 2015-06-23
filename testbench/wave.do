onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /ge_1000baseX_tb/ge_1000baseX_testi/reset_pin
add wave -noupdate -radix hexadecimal /ge_1000baseX_tb/ge_1000baseX_testi/GE_125MHz_ref_ckpin
add wave -noupdate -radix hexadecimal /ge_1000baseX_tb/ge_1000baseX_testi/tbi_rx_ckpin
add wave -noupdate -radix hexadecimal /ge_1000baseX_tb/ge_1000baseX_testi/tbi_rxd
add wave -noupdate -radix hexadecimal /ge_1000baseX_tb/ge_1000baseX_testi/tbi_txd
add wave -noupdate -radix hexadecimal /ge_1000baseX_tb/ge_1000baseX_testi/gmii_rxd
add wave -noupdate -radix hexadecimal /ge_1000baseX_tb/ge_1000baseX_testi/gmii_rx_dv
add wave -noupdate -radix hexadecimal /ge_1000baseX_tb/ge_1000baseX_testi/gmii_rx_er
add wave -noupdate -radix hexadecimal /ge_1000baseX_tb/ge_1000baseX_testi/gmii_col
add wave -noupdate -radix hexadecimal /ge_1000baseX_tb/ge_1000baseX_testi/gmii_cs
add wave -noupdate -radix hexadecimal /ge_1000baseX_tb/ge_1000baseX_testi/gmii_txd
add wave -noupdate -radix hexadecimal /ge_1000baseX_tb/ge_1000baseX_testi/gmii_tx_en
add wave -noupdate -radix hexadecimal /ge_1000baseX_tb/ge_1000baseX_testi/gmii_tx_er
add wave -noupdate -radix hexadecimal /ge_1000baseX_tb/ge_1000baseX_testi/sync_en
add wave -noupdate -radix hexadecimal /ge_1000baseX_tb/ge_1000baseX_testi/loop_en
add wave -noupdate -radix hexadecimal /ge_1000baseX_tb/ge_1000baseX_testi/prbs_en
add wave -noupdate -radix hexadecimal /ge_1000baseX_tb/ge_1000baseX_testi/signal_detect
add wave -noupdate -radix hexadecimal /ge_1000baseX_tb/ge_1000baseX_testi/sync
add wave -noupdate -radix hexadecimal /ge_1000baseX_tb/ge_1000baseX_testi/mdio
add wave -noupdate -radix hexadecimal /ge_1000baseX_tb/ge_1000baseX_testi/mdio_ckpin
add wave -noupdate -radix hexadecimal /ge_1000baseX_tb/ge_1000baseX_testi/mdio_ckpin_buf
add wave -noupdate -radix hexadecimal /ge_1000baseX_tb/ge_1000baseX_testi/mdc
add wave -noupdate -radix hexadecimal /ge_1000baseX_tb/ge_1000baseX_testi/GE_125MHz_ref_ckpin_buf
add wave -noupdate -radix hexadecimal /ge_1000baseX_tb/ge_1000baseX_testi/GE_125MHz_ref_ck_locked
add wave -noupdate -radix hexadecimal /ge_1000baseX_tb/ge_1000baseX_testi/GE_125MHz_ref_ck_unbuf
add wave -noupdate -radix hexadecimal /ge_1000baseX_tb/ge_1000baseX_testi/GE_125MHz_ref_ck
add wave -noupdate -radix hexadecimal /ge_1000baseX_tb/ge_1000baseX_testi/tbi_rx_ckpin_buf
add wave -noupdate -radix hexadecimal /ge_1000baseX_tb/ge_1000baseX_testi/tbi_rx_ck_unbuf
add wave -noupdate -radix hexadecimal /ge_1000baseX_tb/ge_1000baseX_testi/tbi_rx_ck_locked
add wave -noupdate -radix hexadecimal /ge_1000baseX_tb/ge_1000baseX_testi/tbi_rx_ck
add wave -noupdate -radix hexadecimal /ge_1000baseX_tb/ge_1000baseX_testi/main_clocks_locked
add wave -noupdate -radix hexadecimal /ge_1000baseX_tb/ge_1000baseX_testi/tbi_rxck_reset_in
add wave -noupdate -radix hexadecimal /ge_1000baseX_tb/ge_1000baseX_testi/GE_125MHz_reset_in
add wave -noupdate -radix hexadecimal /ge_1000baseX_tb/ge_1000baseX_testi/mdc_reset_in
add wave -noupdate -radix hexadecimal /ge_1000baseX_tb/ge_1000baseX_testi/GE_125MHz_reset
add wave -noupdate -radix hexadecimal /ge_1000baseX_tb/ge_1000baseX_testi/tbi_rx_reset
add wave -noupdate -radix hexadecimal /ge_1000baseX_tb/ge_1000baseX_testi/mdc_reset
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 226
configure wave -valuecolwidth 74
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {173924520 ps} {611705 ns}
