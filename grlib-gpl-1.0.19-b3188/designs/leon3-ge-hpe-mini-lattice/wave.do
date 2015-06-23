onerror {resume}
quietly WaveActivateNextPane {} 0
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
add wave -noupdate -format Literal -radix hexadecimal -expand /testbench/d3/dac_ahb_1/memarr
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/dac_ahb_1/ra
add wave -noupdate -format Logic -radix hexadecimal /testbench/d3/dac_ahb_1/rstp
add wave -noupdate -divider {DAC SigDelt}
add wave -noupdate -format Logic /testbench/d3/dac_ahb_1/sigdelt_1/reset
add wave -noupdate -format Logic /testbench/d3/dac_ahb_1/sigdelt_1/clock
add wave -noupdate -format Literal /testbench/d3/dac_ahb_1/sigdelt_1/dac_in
add wave -noupdate -format Logic /testbench/d3/dac_ahb_1/sigdelt_1/dac_out
add wave -noupdate -format Literal /testbench/d3/dac_ahb_1/sigdelt_1/delta
add wave -noupdate -format Literal /testbench/d3/dac_ahb_1/sigdelt_1/state
add wave -noupdate -divider {Clock Generator}
add wave -noupdate -format Logic /testbench/d3/clkgen0/str/v/clkin
add wave -noupdate -format Logic /testbench/d3/clkgen0/str/v/pciclkin
add wave -noupdate -format Logic /testbench/d3/clkgen0/str/v/clk
add wave -noupdate -format Logic /testbench/d3/clkgen0/str/v/clkn
add wave -noupdate -format Logic /testbench/d3/clkgen0/str/v/sdclk
add wave -noupdate -format Logic /testbench/d3/clkgen0/str/v/pciclk
add wave -noupdate -format Literal /testbench/d3/clkgen0/str/v/cgi
add wave -noupdate -format Literal /testbench/d3/clkgen0/str/v/cgo
add wave -noupdate -format Logic /testbench/d3/clkgen0/str/v/clk_i
add wave -noupdate -format Logic /testbench/d3/clkgen0/str/v/clkint
add wave -noupdate -format Logic /testbench/d3/clkgen0/str/v/pciclkint
add wave -noupdate -format Logic /testbench/d3/clkgen0/str/v/pllclk
add wave -noupdate -format Logic /testbench/d3/clkgen0/str/v/pllclkn
add wave -noupdate -format Logic /testbench/d3/clkgen0/str/v/s_clk
add wave -noupdate -divider LEON3S
add wave -noupdate -format Literal -radix hexadecimal -expand /testbench/d3/cpu__0/u0/ahbi
add wave -noupdate -format Literal -radix hexadecimal -expand /testbench/d3/cpu__0/u0/ahbo
add wave -noupdate -divider {Memory Controller}
add wave -noupdate -format Literal -radix hexadecimal -expand /testbench/d3/mg2/sr1/ahbsi
add wave -noupdate -format Literal -radix hexadecimal -expand /testbench/d3/mg2/sr1/ahbso
add wave -noupdate -divider {Internal Boot Prom}
add wave -noupdate -format Logic -radix hexadecimal /testbench/d3/mg2/sr1/promgen/bprom0/clk
add wave -noupdate -format Logic -radix hexadecimal /testbench/d3/mg2/sr1/promgen/bprom0/csn
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/mg2/sr1/promgen/bprom0/addr
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/mg2/sr1/promgen/bprom0/data
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/mg2/sr1/promgen/bprom0/raddr
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/mg2/sr1/promgen/bprom0/d
add wave -noupdate -divider {selected signals}
add wave -noupdate -format Logic /testbench/clk
add wave -noupdate -format Logic /testbench/rst
add wave -noupdate -format Literal -radix hexadecimal /testbench/address
add wave -noupdate -format Literal -radix hexadecimal /testbench/data
add wave -noupdate -format Literal /testbench/ramsn
add wave -noupdate -format Literal /testbench/ramoen
add wave -noupdate -format Literal /testbench/rben
add wave -noupdate -format Literal /testbench/rwen
add wave -noupdate -format Literal /testbench/rwenx
add wave -noupdate -format Literal /testbench/romsn
add wave -noupdate -format Logic /testbench/iosn
add wave -noupdate -format Logic /testbench/oen
add wave -noupdate -format Logic /testbench/read
add wave -noupdate -format Logic /testbench/writen
add wave -noupdate -format Literal -radix hexadecimal /testbench/sa
add wave -noupdate -format Literal -radix hexadecimal /testbench/sd
add wave -noupdate -format Literal /testbench/sdcke
add wave -noupdate -format Literal /testbench/sdcsn
add wave -noupdate -format Logic /testbench/sdwen
add wave -noupdate -format Logic /testbench/sdrasn
add wave -noupdate -format Logic /testbench/sdcasn
add wave -noupdate -format Literal /testbench/sddqm
add wave -noupdate -format Logic /testbench/sd_clk(0)
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
add wave -noupdate -format Logic /testbench/d3/dsubren
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
add wave -noupdate -format Literal /testbench/d3/s_ramsn
add wave -noupdate -format Literal /testbench/d3/s_sddqm
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
WaveRestoreZoom {2172976 ps} {4757024 ps}
