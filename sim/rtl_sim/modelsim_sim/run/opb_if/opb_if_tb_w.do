onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Internal
add wave -noupdate -format Logic /opb_m_if_tb/opb_clk
add wave -noupdate -format Logic /opb_m_if_tb/opb_rst
add wave -noupdate -format Logic /opb_m_if_tb/m_request
add wave -noupdate -format Logic /opb_m_if_tb/mopb_mgrant
add wave -noupdate -format Logic /opb_m_if_tb/m_buslock
add wave -noupdate -format Logic /opb_m_if_tb/m_seqaddr
add wave -noupdate -format Logic /opb_m_if_tb/m_select
add wave -noupdate -format Logic /opb_m_if_tb/mopb_errack
add wave -noupdate -format Literal /opb_m_if_tb/m_be
add wave -noupdate -format Logic /opb_m_if_tb/m_rnw
add wave -noupdate -format Literal /opb_m_if_tb/m_abus
add wave -noupdate -format Literal /opb_m_if_tb/m_dbus
add wave -noupdate -format Literal /opb_m_if_tb/opb_dbus
add wave -noupdate -format Logic /opb_m_if_tb/mopb_retry
add wave -noupdate -format Logic /opb_m_if_tb/mopb_timeout
add wave -noupdate -format Logic /opb_m_if_tb/mopb_xferack
add wave -noupdate -divider T-FIFIO
add wave -noupdate -format Logic /opb_m_if_tb/opb_m_tx_req
add wave -noupdate -format Logic /opb_m_if_tb/opb_m_tx_en
add wave -noupdate -format Literal /opb_m_if_tb/opb_m_tx_data
add wave -noupdate -format Literal /opb_m_if_tb/opb_tx_dma_ctl
add wave -noupdate -format Literal /opb_m_if_tb/opb_tx_dma_addr
add wave -noupdate -divider R-FIFO
add wave -noupdate -format Logic /opb_m_if_tb/opb_m_rx_req
add wave -noupdate -format Logic /opb_m_if_tb/opb_m_rx_en
add wave -noupdate -format Literal /opb_m_if_tb/opb_m_rx_data
add wave -noupdate -format Literal /opb_m_if_tb/opb_rx_dma_ctl
add wave -noupdate -format Literal /opb_m_if_tb/opb_rx_dma_addr
add wave -noupdate -format Literal /opb_m_if_tb/opb_rx_data
add wave -noupdate -divider Internal
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1710000 ps} 0}
configure wave -namecolwidth 276
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
update
WaveRestoreZoom {0 ps} {3370500 ps}
