onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /testbench/clk
add wave -noupdate -format Logic /testbench/rst
add wave -noupdate -format Logic /testbench/wdogn
add wave -noupdate -format Literal -radix hexadecimal /testbench/address
add wave -noupdate -format Literal -radix hexadecimal /testbench/data
add wave -noupdate -format Literal -radix hexadecimal /testbench/cb
add wave -noupdate -format Literal /testbench/sdcke
add wave -noupdate -format Literal /testbench/sdcsn
add wave -noupdate -format Logic /testbench/sdwen
add wave -noupdate -format Logic /testbench/sdrasn
add wave -noupdate -format Logic /testbench/sdcasn
add wave -noupdate -format Literal /testbench/sddqm
add wave -noupdate -format Logic /testbench/sdclk
add wave -noupdate -format Literal -radix hexadecimal /testbench/sa
add wave -noupdate -format Literal -radix hexadecimal /testbench/sd
add wave -noupdate -format Literal -radix hexadecimal /testbench/scb
add wave -noupdate -format Literal /testbench/ramsn
add wave -noupdate -format Literal /testbench/ramoen
add wave -noupdate -format Literal /testbench/rwen
add wave -noupdate -format Literal /testbench/romsn
add wave -noupdate -format Logic /testbench/iosn
add wave -noupdate -format Logic /testbench/oen
add wave -noupdate -format Logic /testbench/read
add wave -noupdate -format Logic /testbench/writen
add wave -noupdate -format Logic /testbench/brdyn
add wave -noupdate -format Logic /testbench/bexcn
add wave -noupdate -format Logic /testbench/dsuen
add wave -noupdate -format Logic /testbench/dsutx
add wave -noupdate -format Logic /testbench/dsurx
add wave -noupdate -format Logic /testbench/dsubre
add wave -noupdate -format Logic /testbench/dsuact
add wave -noupdate -format Logic /testbench/dsurst
add wave -noupdate -format Logic /testbench/test
add wave -noupdate -format Logic /testbench/error
add wave -noupdate -format Literal /testbench/gpio
add wave -noupdate -format Logic /testbench/txd1
add wave -noupdate -format Logic /testbench/rxd1
add wave -noupdate -format Literal /testbench/can_txd
add wave -noupdate -format Literal /testbench/can_rxd
add wave -noupdate -format Literal /testbench/spw_rxdp
add wave -noupdate -format Literal /testbench/spw_rxdn
add wave -noupdate -format Literal /testbench/spw_rxsp
add wave -noupdate -format Literal /testbench/spw_rxsn
add wave -noupdate -format Literal /testbench/spw_txdp
add wave -noupdate -format Literal /testbench/spw_txdn
add wave -noupdate -format Literal /testbench/spw_txsp
add wave -noupdate -format Literal /testbench/spw_txsn
add wave -noupdate -format Logic /testbench/d3/pci_rst
add wave -noupdate -format Logic /testbench/d3/pci_clk
add wave -noupdate -format Logic /testbench/d3/pci_gnt
add wave -noupdate -format Logic /testbench/d3/pci_idsel
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/pci_ad
add wave -noupdate -format Literal /testbench/d3/pci_cbe
add wave -noupdate -format Logic /testbench/d3/pci_frame
add wave -noupdate -format Logic /testbench/d3/pci_irdy
add wave -noupdate -format Logic /testbench/d3/pci_trdy
add wave -noupdate -format Logic /testbench/d3/pci_devsel
add wave -noupdate -format Logic /testbench/d3/pci_stop
add wave -noupdate -format Logic /testbench/d3/pci_perr
add wave -noupdate -format Logic /testbench/d3/pci_par
add wave -noupdate -format Logic /testbench/d3/pci_req
add wave -noupdate -format Logic /testbench/d3/pci_host
add wave -noupdate -format Literal /testbench/d3/pci_arb_req
add wave -noupdate -format Literal /testbench/d3/pci_arb_gnt
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 150
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
WaveRestoreZoom {0 ps} {577500 ns}
