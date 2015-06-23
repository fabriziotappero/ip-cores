onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /test_interrupts/clk
add wave -noupdate /test_interrupts/nreset
add wave -noupdate /test_interrupts/ctl_iff1_iff2_sig
add wave -noupdate /test_interrupts/nmi_sig
add wave -noupdate /test_interrupts/setM1_sig
add wave -noupdate /test_interrupts/intr_sig
add wave -noupdate /test_interrupts/ctl_iffx_we_sig
add wave -noupdate /test_interrupts/ctl_iffx_bit_sig
add wave -noupdate /test_interrupts/ctl_im_we_sig
add wave -noupdate /test_interrupts/db_sig
add wave -noupdate /test_interrupts/ctl_no_ints_sig
add wave -noupdate -divider STATE
add wave -noupdate -color Aquamarine /test_interrupts/iff1_sig
add wave -noupdate -color Aquamarine /test_interrupts/iff2_sig
add wave -noupdate -color Pink /test_interrupts/im1_sig
add wave -noupdate -color Pink /test_interrupts/im2_sig
add wave -noupdate /test_interrupts/in_nmi_sig
add wave -noupdate /test_interrupts/in_intr_sig
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1800 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 202
configure wave -valuecolwidth 66
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 1
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ns} {25800 ns}
