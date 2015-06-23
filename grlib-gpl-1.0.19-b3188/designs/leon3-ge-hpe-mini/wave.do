onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider LEON3MINI
add wave -noupdate -format Logic /testbench/d3/resetn
add wave -noupdate -format Logic /testbench/d3/resoutn
add wave -noupdate -format Logic /testbench/d3/clk
add wave -noupdate -format Logic /testbench/d3/errorn
add wave -noupdate -format Literal /testbench/d3/address
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/data
add wave -noupdate -format Literal /testbench/d3/ramsn
add wave -noupdate -format Literal /testbench/d3/ramoen
add wave -noupdate -format Literal /testbench/d3/rwen
add wave -noupdate -format Literal /testbench/d3/rben
add wave -noupdate -format Literal /testbench/d3/romsn
add wave -noupdate -format Logic /testbench/d3/iosn
add wave -noupdate -format Logic /testbench/d3/oen
add wave -noupdate -format Logic /testbench/d3/read
add wave -noupdate -format Logic /testbench/d3/writen
add wave -noupdate -format Literal /testbench/d3/sdcke
add wave -noupdate -format Literal /testbench/d3/sdcsn
add wave -noupdate -format Logic /testbench/d3/sdwen
add wave -noupdate -format Logic /testbench/d3/sdrasn
add wave -noupdate -format Logic /testbench/d3/sdcasn
add wave -noupdate -format Literal /testbench/d3/sddqm
add wave -noupdate -format Literal /testbench/d3/sdclk
add wave -noupdate -format Literal /testbench/d3/sdba
add wave -noupdate -format Logic /testbench/d3/dsuen
add wave -noupdate -format Logic /testbench/d3/dsutx
add wave -noupdate -format Logic /testbench/d3/dsurx
add wave -noupdate -format Logic /testbench/d3/dsuactn
add wave -noupdate -format Logic /testbench/d3/rxd1
add wave -noupdate -format Logic /testbench/d3/txd1
add wave -noupdate -format Logic /testbench/d3/emdio
add wave -noupdate -format Logic /testbench/d3/etx_clk
add wave -noupdate -format Logic /testbench/d3/erx_clk
add wave -noupdate -format Literal /testbench/d3/erxd
add wave -noupdate -format Logic /testbench/d3/erx_dv
add wave -noupdate -format Logic /testbench/d3/erx_er
add wave -noupdate -format Logic /testbench/d3/erx_col
add wave -noupdate -format Logic /testbench/d3/erx_crs
add wave -noupdate -format Literal /testbench/d3/etxd
add wave -noupdate -format Logic /testbench/d3/etx_en
add wave -noupdate -format Logic /testbench/d3/etx_er
add wave -noupdate -format Logic /testbench/d3/emdc
add wave -noupdate -format Logic /testbench/d3/emddis
add wave -noupdate -format Logic /testbench/d3/epwrdwn
add wave -noupdate -format Logic /testbench/d3/ereset
add wave -noupdate -format Logic /testbench/d3/esleep
add wave -noupdate -format Logic /testbench/d3/epause
add wave -noupdate -format Literal /testbench/d3/vcc
add wave -noupdate -format Literal /testbench/d3/gnd
add wave -noupdate -format Literal /testbench/d3/memi
add wave -noupdate -format Literal /testbench/d3/memo
add wave -noupdate -format Literal /testbench/d3/wpo
add wave -noupdate -format Literal /testbench/d3/sdi
add wave -noupdate -format Literal /testbench/d3/sdo
add wave -noupdate -format Literal /testbench/d3/sdo2
add wave -noupdate -format Literal /testbench/d3/sdo3
add wave -noupdate -format Literal /testbench/d3/apbi
add wave -noupdate -format Literal /testbench/d3/apbo
add wave -noupdate -format Literal /testbench/d3/ahbsi
add wave -noupdate -format Literal /testbench/d3/ahbso
add wave -noupdate -format Literal /testbench/d3/ahbmi
add wave -noupdate -format Literal /testbench/d3/ahbmo
add wave -noupdate -format Logic /testbench/d3/clkm
add wave -noupdate -format Logic /testbench/d3/rstn
add wave -noupdate -format Logic /testbench/d3/sdclkl
add wave -noupdate -format Literal /testbench/d3/cgi
add wave -noupdate -format Literal /testbench/d3/cgo
add wave -noupdate -format Literal /testbench/d3/u1i
add wave -noupdate -format Literal /testbench/d3/dui
add wave -noupdate -format Literal /testbench/d3/u1o
add wave -noupdate -format Literal /testbench/d3/duo
add wave -noupdate -format Literal /testbench/d3/irqi
add wave -noupdate -format Literal /testbench/d3/irqo
add wave -noupdate -format Literal /testbench/d3/dbgi
add wave -noupdate -format Literal /testbench/d3/dbgo
add wave -noupdate -format Literal /testbench/d3/dsui
add wave -noupdate -format Literal /testbench/d3/dsuo
add wave -noupdate -format Literal /testbench/d3/ethi
add wave -noupdate -format Literal /testbench/d3/ethi1
add wave -noupdate -format Literal /testbench/d3/ethi2
add wave -noupdate -format Literal /testbench/d3/etho
add wave -noupdate -format Literal /testbench/d3/etho1
add wave -noupdate -format Literal /testbench/d3/etho2
add wave -noupdate -format Literal /testbench/d3/gpti
add wave -noupdate -format Literal /testbench/d3/sa
add wave -noupdate -format Literal /testbench/d3/sd
add wave -noupdate -format Literal /testbench/d3/edcli
add wave -noupdate -format Logic /testbench/d3/dsubre
add wave -noupdate -format Logic /testbench/d3/dsuact
add wave -noupdate -format Logic /testbench/d3/oen_ctrl
add wave -noupdate -format Logic /testbench/d3/sdram_selected
add wave -noupdate -divider HPIRAM
add wave -noupdate -format Logic -radix hexadecimal /testbench/hpi_ram_1/clk
add wave -noupdate -format Literal -radix hexadecimal /testbench/hpi_ram_1/address
add wave -noupdate -format Literal -radix hexadecimal /testbench/hpi_ram_1/datain
add wave -noupdate -format Literal -radix hexadecimal /testbench/hpi_ram_1/dataout
add wave -noupdate -format Logic -radix hexadecimal /testbench/hpi_ram_1/writen
add wave -noupdate -format Logic -radix hexadecimal /testbench/hpi_ram_1/readn
add wave -noupdate -format Logic -radix hexadecimal /testbench/hpi_ram_1/csn
add wave -noupdate -format Literal -radix hexadecimal /testbench/hpi_ram_1/memarr
add wave -noupdate -format Literal -radix hexadecimal /testbench/hpi_ram_1/data_reg
add wave -noupdate -format Literal -radix hexadecimal /testbench/hpi_ram_1/mailbox_reg
add wave -noupdate -format Literal -radix hexadecimal /testbench/hpi_ram_1/address_reg
add wave -noupdate -format Literal -radix hexadecimal /testbench/hpi_ram_1/status_reg
add wave -noupdate -divider AHB2HPI
add wave -noupdate -format Logic -radix hexadecimal /testbench/d3/ahb2hpi2_1/hclk
add wave -noupdate -format Logic -radix hexadecimal /testbench/d3/ahb2hpi2_1/hresetn
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/ahb2hpi2_1/ahbso
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/ahb2hpi2_1/ahbsi
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/ahb2hpi2_1/addr
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/ahb2hpi2_1/wdata
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/ahb2hpi2_1/rdata
add wave -noupdate -format Logic -radix hexadecimal /testbench/d3/ahb2hpi2_1/ncs
add wave -noupdate -format Logic -radix hexadecimal /testbench/d3/ahb2hpi2_1/nwr
add wave -noupdate -format Logic -radix hexadecimal /testbench/d3/ahb2hpi2_1/nrd
add wave -noupdate -format Logic -radix hexadecimal /testbench/d3/ahb2hpi2_1/int
add wave -noupdate -format Logic -radix hexadecimal /testbench/d3/ahb2hpi2_1/dbg_equal
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/ahb2hpi2_1/c
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/ahb2hpi2_1/r
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/ahb2hpi2_1/rr
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/ahb2hpi2_1/in_data_probe
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/ahb2hpi2_1/out_data_probe
add wave -noupdate -format Logic -radix hexadecimal /testbench/d3/ahb2hpi2_1/equality_probe
add wave -noupdate -divider DAC_AHB
add wave -noupdate -format Logic -radix hexadecimal /testbench/d3/dac_ahb_1/rst
add wave -noupdate -format Logic -radix hexadecimal /testbench/d3/dac_ahb_1/clk
add wave -noupdate -format Literal -radix hexadecimal -expand /testbench/d3/dac_ahb_1/ahbsi
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/dac_ahb_1/ahbso
add wave -noupdate -format Logic -radix hexadecimal /testbench/d3/dac_ahb_1/dac_out
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/dac_ahb_1/r
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/dac_ahb_1/c
add wave -noupdate -format Logic -radix hexadecimal /testbench/d3/dac_ahb_1/ramsel
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/dac_ahb_1/write
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/dac_ahb_1/ramaddr
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/dac_ahb_1/ramdata
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/dac_ahb_1/memarr
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/dac_ahb_1/ra
add wave -noupdate -format Logic -radix hexadecimal /testbench/d3/dac_ahb_1/rstp
add wave -noupdate -divider {DAC SigDelt}
add wave -noupdate -format Logic /testbench/d3/dac_ahb_1/sigdelt_1/reset
add wave -noupdate -format Logic /testbench/d3/dac_ahb_1/sigdelt_1/clock
add wave -noupdate -format Literal /testbench/d3/dac_ahb_1/sigdelt_1/dac_in
add wave -noupdate -format Logic /testbench/d3/dac_ahb_1/sigdelt_1/dac_out
add wave -noupdate -format Literal /testbench/d3/dac_ahb_1/sigdelt_1/delta
add wave -noupdate -format Literal /testbench/d3/dac_ahb_1/sigdelt_1/state
add wave -noupdate -divider LEON3S
add wave -noupdate -format Literal -radix hexadecimal -expand /testbench/d3/cpu__0/u0/ahbi
add wave -noupdate -format Literal -radix hexadecimal -expand /testbench/d3/cpu__0/u0/ahbo
add wave -noupdate -divider {Memory Controller}
add wave -noupdate -format Literal -radix hexadecimal -expand /testbench/d3/mg2/sr1/ahbsi
add wave -noupdate -format Literal -radix hexadecimal -expand /testbench/d3/mg2/sr1/ahbso
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3465000 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
update
WaveRestoreZoom {50050 ns} {71050 ns}
