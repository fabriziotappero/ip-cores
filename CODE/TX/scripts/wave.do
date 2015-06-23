onerror {resume}
quietly WaveActivateNextPane {} 0
virtual signal -install /tx_tb_ent/uut/flagmachine { (context /tx_tb_ent/uut/flagmachine )(line__62/transmit_reg & txd )} TransmitLine
virtual signal -install /tx_tb_ent/uut/backendmachine { (context /tx_tb_ent/uut/backendmachine )(p2s_proc/tmp_reg & txd )} toTrans
add wave -noupdate -format Logic /tx_tb_ent/txen
add wave -noupdate -format Logic /tx_tb_ent/txclk
add wave -noupdate -format Logic /tx_tb_ent/rst_n
add wave -noupdate -format Logic /tx_tb_ent/abortframe
add wave -noupdate -format Logic /tx_tb_ent/abortedtrans
add wave -noupdate -format Logic /tx_tb_ent/uut/flagmachine/abortframe
add wave -noupdate -format Logic /tx_tb_ent/uut/txcontroller/abortedtrans
add wave -noupdate -format Logic /tx_tb_ent/writebyte
add wave -noupdate -format Logic /tx_tb_ent/rdy
add wave -noupdate -format Logic /tx_tb_ent/validframe
add wave -noupdate -format Logic /tx_tb_ent/uut/txcontroller/frame
add wave -noupdate -format Logic /tx_tb_ent/uut/backendmachine/backendenable
add wave -noupdate -format Logic /tx_tb_ent/uut/backendmachine/inprogress
add wave -noupdate -format Logic /tx_tb_ent/uut/backendmachine/enable
add wave -noupdate -format Literal /tx_tb_ent/txdata
add wave -noupdate -format Literal /tx_tb_ent/backend_proc/counter
add wave -noupdate -format Literal /tx_tb_ent/serial_interface/output
add wave -noupdate -format Literal -label TransmitLine /tx_tb_ent/uut/flagmachine/TransmitLine
add wave -noupdate -format Literal -label toTrans /tx_tb_ent/uut/backendmachine/toTrans
add wave -noupdate -format Literal /tx_tb_ent/uut/txcontroller/flag_proc/state
add wave -noupdate -format Literal /tx_tb_ent/uut/flagmachine/line__62/transmit_reg
add wave -noupdate -format Literal /tx_tb_ent/uut/backendmachine/p2s_proc/tmp_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {1700 ns}
WaveRestoreZoom {0 ps} {7051122 ps}
