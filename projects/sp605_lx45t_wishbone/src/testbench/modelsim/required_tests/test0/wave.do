onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group PCIE_CORE64_WB /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/o_wb_clk
add wave -noupdate -expand -group PCIE_CORE64_WB /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/o_wb_rst
add wave -noupdate -expand -group PCIE_CORE64_WB /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/i_wbm_ack
add wave -noupdate -expand -group PCIE_CORE64_WB /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/i_wbm_err
add wave -noupdate -expand -group PCIE_CORE64_WB /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/i_wbm_rty
add wave -noupdate -expand -group PCIE_CORE64_WB /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/i_wdm_irq_0
add wave -noupdate -expand -group PCIE_CORE64_WB -radix hexadecimal -childformat {{/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(63) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(62) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(61) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(60) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(59) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(58) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(57) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(56) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(55) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(54) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(53) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(52) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(51) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(50) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(49) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(48) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(47) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(46) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(45) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(44) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(43) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(42) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(41) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(40) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(39) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(38) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(37) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(36) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(35) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(34) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(33) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(32) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(31) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(30) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(29) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(28) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(27) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(26) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(25) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(24) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(23) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(22) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(21) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(20) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(19) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(18) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(17) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(16) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(15) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(14) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(13) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(12) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(11) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(10) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(9) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(8) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(7) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(6) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(5) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(4) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(3) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(2) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(1) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(0) -radix hexadecimal}} -subitemconfig {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(63) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(62) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(61) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(60) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(59) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(58) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(57) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(56) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(55) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(54) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(53) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(52) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(51) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(50) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(49) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(48) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(47) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(46) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(45) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(44) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(43) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(42) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(41) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(40) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(39) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(38) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(37) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(36) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(35) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(34) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(33) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(32) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(31) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(30) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(29) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(28) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(27) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(26) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(25) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(24) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(23) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(22) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(21) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(20) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(19) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(18) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(17) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(16) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(15) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(14) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(13) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(12) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(11) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(10) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(9) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(8) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(7) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(6) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(5) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(4) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(3) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(2) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(1) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data(0) {-height 15 -radix hexadecimal}} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_data
add wave -noupdate -expand -group PCIE_CORE64_WB /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/iv_wbm_irq_dmar
add wave -noupdate -expand -group PCIE_CORE64_WB /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/o_wbm_cyc
add wave -noupdate -expand -group PCIE_CORE64_WB /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/o_wbm_stb
add wave -noupdate -expand -group PCIE_CORE64_WB /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/o_wbm_we
add wave -noupdate -expand -group PCIE_CORE64_WB -radix hexadecimal /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/ov_wbm_addr
add wave -noupdate -expand -group PCIE_CORE64_WB /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/ov_wbm_bte
add wave -noupdate -expand -group PCIE_CORE64_WB /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/ov_wbm_cti
add wave -noupdate -expand -group PCIE_CORE64_WB -radix hexadecimal /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/ov_wbm_data
add wave -noupdate -expand -group PCIE_CORE64_WB /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/ov_wbm_sel
add wave -noupdate -group TEST_GEN_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/i_clk
add wave -noupdate -group TEST_GEN_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/i_rst
add wave -noupdate -group TEST_GEN_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/i_wbs_burst_cyc
add wave -noupdate -group TEST_GEN_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/i_wbs_burst_stb
add wave -noupdate -group TEST_GEN_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/i_wbs_burst_we
add wave -noupdate -group TEST_GEN_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/i_wbs_cfg_cyc
add wave -noupdate -group TEST_GEN_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/i_wbs_cfg_stb
add wave -noupdate -group TEST_GEN_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/i_wbs_cfg_we
add wave -noupdate -group TEST_GEN_WB -radix hexadecimal /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/iv_wbs_burst_addr
add wave -noupdate -group TEST_GEN_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/iv_wbs_burst_bte
add wave -noupdate -group TEST_GEN_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/iv_wbs_burst_cti
add wave -noupdate -group TEST_GEN_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/iv_wbs_burst_sel
add wave -noupdate -group TEST_GEN_WB -radix hexadecimal /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/iv_wbs_cfg_addr
add wave -noupdate -group TEST_GEN_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/iv_wbs_cfg_bte
add wave -noupdate -group TEST_GEN_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/iv_wbs_cfg_cti
add wave -noupdate -group TEST_GEN_WB -radix hexadecimal /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/iv_wbs_cfg_data
add wave -noupdate -group TEST_GEN_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/iv_wbs_cfg_sel
add wave -noupdate -group TEST_GEN_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/o_wbs_irq_dmar
add wave -noupdate -group TEST_GEN_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/o_wbs_burst_ack
add wave -noupdate -group TEST_GEN_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/o_wbs_burst_err
add wave -noupdate -group TEST_GEN_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/o_wbs_burst_rty
add wave -noupdate -group TEST_GEN_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/o_wbs_cfg_ack
add wave -noupdate -group TEST_GEN_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/o_wbs_cfg_err
add wave -noupdate -group TEST_GEN_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/o_wbs_cfg_rty
add wave -noupdate -group TEST_GEN_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/o_wbs_irq_0
add wave -noupdate -group TEST_GEN_WB -radix hexadecimal /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/ov_wbs_burst_data
add wave -noupdate -group TEST_GEN_WB -radix hexadecimal /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/ov_wbs_cfg_data
add wave -noupdate -expand -group TEST_CHECK_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/i_clk
add wave -noupdate -expand -group TEST_CHECK_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/i_rst
add wave -noupdate -expand -group TEST_CHECK_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/i_wbs_burst_cyc
add wave -noupdate -expand -group TEST_CHECK_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/i_wbs_burst_stb
add wave -noupdate -expand -group TEST_CHECK_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/i_wbs_burst_we
add wave -noupdate -expand -group TEST_CHECK_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/i_wbs_cfg_cyc
add wave -noupdate -expand -group TEST_CHECK_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/i_wbs_cfg_stb
add wave -noupdate -expand -group TEST_CHECK_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/i_wbs_cfg_we
add wave -noupdate -expand -group TEST_CHECK_WB -radix hexadecimal /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/iv_wbs_burst_addr
add wave -noupdate -expand -group TEST_CHECK_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/iv_wbs_burst_bte
add wave -noupdate -expand -group TEST_CHECK_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/iv_wbs_burst_cti
add wave -noupdate -expand -group TEST_CHECK_WB -radix hexadecimal /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/iv_wbs_burst_data
add wave -noupdate -expand -group TEST_CHECK_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/iv_wbs_burst_sel
add wave -noupdate -expand -group TEST_CHECK_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/iv_wbs_cfg_addr
add wave -noupdate -expand -group TEST_CHECK_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/iv_wbs_cfg_bte
add wave -noupdate -expand -group TEST_CHECK_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/iv_wbs_cfg_cti
add wave -noupdate -expand -group TEST_CHECK_WB -radix hexadecimal /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/iv_wbs_cfg_data
add wave -noupdate -expand -group TEST_CHECK_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/iv_wbs_cfg_sel
add wave -noupdate -expand -group TEST_CHECK_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/o_wbs_irq_dmar
add wave -noupdate -expand -group TEST_CHECK_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/o_wbs_burst_ack
add wave -noupdate -expand -group TEST_CHECK_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/o_wbs_burst_err
add wave -noupdate -expand -group TEST_CHECK_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/o_wbs_burst_rty
add wave -noupdate -expand -group TEST_CHECK_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/o_wbs_cfg_ack
add wave -noupdate -expand -group TEST_CHECK_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/o_wbs_cfg_err
add wave -noupdate -expand -group TEST_CHECK_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/o_wbs_cfg_rty
add wave -noupdate -expand -group TEST_CHECK_WB /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/o_wbs_irq_0
add wave -noupdate -expand -group TEST_CHECK_WB -radix hexadecimal /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/ov_wbs_cfg_data
add wave -noupdate -group TEST_CHECK.WBS_CFG /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/WB_CFG_SLAVE/i_wbs_cfg_cyc
add wave -noupdate -group TEST_CHECK.WBS_CFG /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/WB_CFG_SLAVE/i_wbs_cfg_stb
add wave -noupdate -group TEST_CHECK.WBS_CFG /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/WB_CFG_SLAVE/i_wbs_cfg_we
add wave -noupdate -group TEST_CHECK.WBS_CFG /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/WB_CFG_SLAVE/iv_wbs_cfg_addr
add wave -noupdate -group TEST_CHECK.WBS_CFG /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/WB_CFG_SLAVE/iv_wbs_cfg_bte
add wave -noupdate -group TEST_CHECK.WBS_CFG /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/WB_CFG_SLAVE/iv_wbs_cfg_cti
add wave -noupdate -group TEST_CHECK.WBS_CFG /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/WB_CFG_SLAVE/iv_wbs_cfg_data
add wave -noupdate -group TEST_CHECK.WBS_CFG /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/WB_CFG_SLAVE/iv_wbs_cfg_sel
add wave -noupdate -group TEST_CHECK.WBS_CFG /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/WB_CFG_SLAVE/o_wbs_cfg_ack
add wave -noupdate -group TEST_CHECK.WBS_CFG /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/WB_CFG_SLAVE/o_wbs_cfg_err
add wave -noupdate -group TEST_CHECK.WBS_CFG /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/WB_CFG_SLAVE/o_wbs_cfg_rty
add wave -noupdate -group TEST_CHECK.WBS_CFG /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/WB_CFG_SLAVE/ov_test_check_ctrl
add wave -noupdate -group TEST_CHECK.WBS_CFG /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/WB_CFG_SLAVE/ov_test_check_err_adr
add wave -noupdate -group TEST_CHECK.WBS_CFG /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/WB_CFG_SLAVE/ov_test_check_size
add wave -noupdate -group TEST_CHECK.WBS_CFG /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/WB_CFG_SLAVE/ov_wbs_cfg_data
add wave -noupdate -group TEST_CHECK.WBS_CFG.LOGIC -radix hexadecimal /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/WB_CFG_SLAVE/iv_wbs_cfg_addr
add wave -noupdate -group TEST_CHECK.WBS_CFG.LOGIC /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/WB_CFG_SLAVE/o_wbs_cfg_ack
add wave -noupdate -group TEST_CHECK.WBS_CFG.LOGIC -radix hexadecimal /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/WB_CFG_SLAVE/ov_wbs_cfg_data
add wave -noupdate -group TEST_CHECK.WBS_CFG.LOGIC /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/WB_CFG_SLAVE/s_wbs_active
add wave -noupdate -group TEST_CHECK.WBS_CFG.LOGIC /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/WB_CFG_SLAVE/s_wbs_active_rd
add wave -noupdate -group TEST_CHECK.WBS_CFG.LOGIC /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/WB_CFG_SLAVE/s_wbs_active_wr
add wave -noupdate -group TEST_CHECK.WBS_CFG.LOGIC -radix hexadecimal /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/WB_CFG_SLAVE/sv_bl_ram_adr
add wave -noupdate -group TEST_CHECK.WBS_CFG.LOGIC /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/WB_CFG_SLAVE/s_bl_ram_data_we
add wave -noupdate -group TEST_CHECK.WBS_CFG.LOGIC -radix hexadecimal /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/WB_CFG_SLAVE/sv_bl_ram_data_out
add wave -noupdate -group TEST_CHECK.WBS_CFG.BL_RAM /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/WB_CFG_SLAVE/BL_RAM/wr
add wave -noupdate -group TEST_CHECK.WBS_CFG.BL_RAM -radix hexadecimal /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/WB_CFG_SLAVE/BL_RAM/data_in
add wave -noupdate -group TEST_CHECK.WBS_CFG.BL_RAM -radix hexadecimal /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/WB_CFG_SLAVE/BL_RAM/data_out
add wave -noupdate -group TEST_CHECK.WBS_CFG.BL_RAM -radix hexadecimal /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/WB_CFG_SLAVE/BL_RAM/adr
add wave -noupdate -group WB_CROSS.M#0 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/m0_ack_o
add wave -noupdate -group WB_CROSS.M#0 -radix hexadecimal /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/m0_addr_i
add wave -noupdate -group WB_CROSS.M#0 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/m0_bte_i
add wave -noupdate -group WB_CROSS.M#0 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/m0_cti_i
add wave -noupdate -group WB_CROSS.M#0 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/m0_cyc_i
add wave -noupdate -group WB_CROSS.M#0 -radix hexadecimal /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/m0_data_i
add wave -noupdate -group WB_CROSS.M#0 -radix hexadecimal /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/m0_data_o
add wave -noupdate -group WB_CROSS.M#0 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/m0_err_o
add wave -noupdate -group WB_CROSS.M#0 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/m0_rty_o
add wave -noupdate -group WB_CROSS.M#0 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/m0_sel_i
add wave -noupdate -group WB_CROSS.M#0 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/m0_stb_i
add wave -noupdate -group WB_CROSS.M#0 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/m0_we_i
add wave -noupdate -group WB_CROSS.S#0 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s0_ack_i
add wave -noupdate -group WB_CROSS.S#0 -radix hexadecimal /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s0_addr_o
add wave -noupdate -group WB_CROSS.S#0 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s0_bte_o
add wave -noupdate -group WB_CROSS.S#0 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s0_cti_o
add wave -noupdate -group WB_CROSS.S#0 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s0_cyc_o
add wave -noupdate -group WB_CROSS.S#0 -radix hexadecimal /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s0_data_i
add wave -noupdate -group WB_CROSS.S#0 -radix hexadecimal /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s0_data_o
add wave -noupdate -group WB_CROSS.S#0 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s0_err_i
add wave -noupdate -group WB_CROSS.S#0 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s0_rty_i
add wave -noupdate -group WB_CROSS.S#0 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s0_sel_o
add wave -noupdate -group WB_CROSS.S#0 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s0_stb_o
add wave -noupdate -group WB_CROSS.S#0 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s0_we_o
add wave -noupdate -group WB_CROSS.S#1 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s1_ack_i
add wave -noupdate -group WB_CROSS.S#1 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s1_addr_o
add wave -noupdate -group WB_CROSS.S#1 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s1_bte_o
add wave -noupdate -group WB_CROSS.S#1 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s1_cti_o
add wave -noupdate -group WB_CROSS.S#1 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s1_cyc_o
add wave -noupdate -group WB_CROSS.S#1 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s1_data_i
add wave -noupdate -group WB_CROSS.S#1 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s1_data_o
add wave -noupdate -group WB_CROSS.S#1 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s1_err_i
add wave -noupdate -group WB_CROSS.S#1 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s1_rty_i
add wave -noupdate -group WB_CROSS.S#1 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s1_sel_o
add wave -noupdate -group WB_CROSS.S#1 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s1_stb_o
add wave -noupdate -group WB_CROSS.S#1 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s1_we_o
add wave -noupdate -group WB_CROSS.S#2 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s2_ack_i
add wave -noupdate -group WB_CROSS.S#2 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s2_addr_o
add wave -noupdate -group WB_CROSS.S#2 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s2_bte_o
add wave -noupdate -group WB_CROSS.S#2 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s2_cti_o
add wave -noupdate -group WB_CROSS.S#2 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s2_cyc_o
add wave -noupdate -group WB_CROSS.S#2 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s2_data_i
add wave -noupdate -group WB_CROSS.S#2 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s2_data_o
add wave -noupdate -group WB_CROSS.S#2 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s2_err_i
add wave -noupdate -group WB_CROSS.S#2 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s2_rty_i
add wave -noupdate -group WB_CROSS.S#2 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s2_sel_o
add wave -noupdate -group WB_CROSS.S#2 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s2_stb_o
add wave -noupdate -group WB_CROSS.S#2 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s2_we_o
add wave -noupdate -group WB_CROSS.S#3 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s3_ack_i
add wave -noupdate -group WB_CROSS.S#3 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s3_addr_o
add wave -noupdate -group WB_CROSS.S#3 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s3_bte_o
add wave -noupdate -group WB_CROSS.S#3 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s3_cti_o
add wave -noupdate -group WB_CROSS.S#3 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s3_cyc_o
add wave -noupdate -group WB_CROSS.S#3 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s3_data_i
add wave -noupdate -group WB_CROSS.S#3 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s3_data_o
add wave -noupdate -group WB_CROSS.S#3 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s3_err_i
add wave -noupdate -group WB_CROSS.S#3 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s3_rty_i
add wave -noupdate -group WB_CROSS.S#3 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s3_sel_o
add wave -noupdate -group WB_CROSS.S#3 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s3_stb_o
add wave -noupdate -group WB_CROSS.S#3 /stend_sp605_wishbone/dut/WB_SOPC/WB_CROSS/s3_we_o
add wave -noupdate -group CORE.reg -childformat {{/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/CORE/rx/reg_access.adr -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/CORE/rx/reg_access.data -radix hexadecimal}} -subitemconfig {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/CORE/rx/reg_access.adr {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/CORE/rx/reg_access.data {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/CORE/rx/reg_access.req_wr -expand /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/CORE/rx/reg_access.req_rd -expand} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/CORE/rx/reg_access
add wave -noupdate -group CORE.reg -childformat {{/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/CORE/reg/reg_access_back.data -radix hexadecimal}} -subitemconfig {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/CORE/reg/reg_access_back.data {-height 15 -radix hexadecimal}} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/CORE/reg/reg_access_back
add wave -noupdate -group CORE.reg -childformat {{/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/CORE/reg/reg_disp.adr -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/CORE/reg/reg_disp.data -radix hexadecimal}} -subitemconfig {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/CORE/reg/reg_disp.adr {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/CORE/reg/reg_disp.data {-height 15 -radix hexadecimal}} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/CORE/reg/reg_disp
add wave -noupdate -group CORE.reg -childformat {{/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/CORE/reg/reg_disp_back.data -radix hexadecimal}} -subitemconfig {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/CORE/reg/reg_disp_back.data {-height 15 -radix hexadecimal}} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/CORE/reg/reg_disp_back
add wave -noupdate -group CORE.reg -childformat {{/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/CORE/reg/reg_ext_fifo.adr -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/CORE/reg/reg_ext_fifo.data -radix hexadecimal}} -subitemconfig {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/CORE/reg/reg_ext_fifo.adr {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/CORE/reg/reg_ext_fifo.data {-height 15 -radix hexadecimal}} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/CORE/reg/reg_ext_fifo
add wave -noupdate -group CORE.reg -childformat {{/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/CORE/reg/reg_ext_fifo_back.data -radix hexadecimal}} -subitemconfig {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/CORE/reg/reg_ext_fifo_back.data {-height 15 -radix hexadecimal}} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/CORE/reg/reg_ext_fifo_back
add wave -noupdate -group CORE.reg /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/CORE/reg/st1p
add wave -noupdate -group CORE.reg /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/CORE/reg/stp
add wave -noupdate -group PB_BUS -childformat {{/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/pb_master.adr -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/pb_master.data -radix hexadecimal}} -subitemconfig {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/pb_master.adr {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/pb_master.data {-height 15 -radix hexadecimal}} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/pb_master
add wave -noupdate -group PB_BUS -childformat {{/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/pb_slave.data -radix hexadecimal}} -subitemconfig {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/pb_slave.data {-height 15 -radix hexadecimal}} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/pb_slave
add wave -noupdate -group DBG_0 -radix hexadecimal /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/CORE/disp/ext_fifo_disp.adr
add wave -noupdate -group DBG_0 /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/CORE/fifo/ram_data/loc_adr_we
add wave -noupdate -group DBG_0 -radix hexadecimal /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/CORE/fifo/ram_data/data_in
add wave -noupdate -group DBG_0 /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/CORE/fifo/ram_data/dma_chn
add wave -noupdate -group DBG_0 -radix hexadecimal /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/CORE/fifo/ram_data/pf_adr
add wave -noupdate -group DBG_0 /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/CORE/fifo/ram_data/pf_chn
add wave -noupdate -group DBG_0 /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/CORE/fifo/ram_data/clk
add wave -noupdate -group DBG_0 /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/CORE/fifo/main/stp
add wave -noupdate -group DBG_0 /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/CORE/fifo/main/stw
add wave -noupdate -divider {New Divider}
add wave -noupdate /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/PW_WB/PB_WB_BRIDGE/sv_pb_fsm
add wave -noupdate /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/PW_WB/PB_WB_BRIDGE/sv_wbm_fsm
add wave -noupdate -childformat {{/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/PW_WB/pb_master.adr -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/PW_WB/pb_master.data -radix hexadecimal}} -subitemconfig {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/PW_WB/pb_master.adr {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/PW_WB/pb_master.data {-height 15 -radix hexadecimal}} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/PW_WB/pb_master
add wave -noupdate -childformat {{/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/PW_WB/pb_slave.data -radix hexadecimal}} -subitemconfig {/stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/PW_WB/pb_slave.data {-height 15 -radix hexadecimal}} /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/PW_WB/pb_slave
add wave -noupdate /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/PW_WB/PB_WB_BRIDGE/sv_wb_comp_incoming_data_count
add wave -noupdate /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/PW_WB/PB_WB_BRIDGE/sv_wb_comp_outgoing_fifo_data_count
add wave -noupdate /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/PW_WB/PB_WB_BRIDGE/sv_wb_comp_outgoing_in_data_count
add wave -noupdate /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/PW_WB/PB_WB_BRIDGE/sv_wb_comp_outgoing_out_data_count
add wave -noupdate -divider {New Divider}
add wave -noupdate -group TEST_GEN.WBS_CFG /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/WB_CFG_SLAVE/i_wbs_cfg_cyc
add wave -noupdate -group TEST_GEN.WBS_CFG /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/WB_CFG_SLAVE/i_wbs_cfg_stb
add wave -noupdate -group TEST_GEN.WBS_CFG /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/WB_CFG_SLAVE/i_wbs_cfg_we
add wave -noupdate -group TEST_GEN.WBS_CFG -radix hexadecimal /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/WB_CFG_SLAVE/iv_wbs_cfg_addr
add wave -noupdate -group TEST_GEN.WBS_CFG /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/WB_CFG_SLAVE/iv_wbs_cfg_bte
add wave -noupdate -group TEST_GEN.WBS_CFG /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/WB_CFG_SLAVE/iv_wbs_cfg_cti
add wave -noupdate -group TEST_GEN.WBS_CFG -radix hexadecimal /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/WB_CFG_SLAVE/iv_wbs_cfg_data
add wave -noupdate -group TEST_GEN.WBS_CFG /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/WB_CFG_SLAVE/iv_wbs_cfg_sel
add wave -noupdate -group TEST_GEN.WBS_CFG /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/WB_CFG_SLAVE/o_wbs_cfg_ack
add wave -noupdate -group TEST_GEN.WBS_CFG /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/WB_CFG_SLAVE/o_wbs_cfg_err
add wave -noupdate -group TEST_GEN.WBS_CFG /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/WB_CFG_SLAVE/o_wbs_cfg_rty
add wave -noupdate -group TEST_GEN.WBS_CFG -radix hexadecimal /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/WB_CFG_SLAVE/ov_wbs_cfg_data
add wave -noupdate -group TEST_GEN.GEN_LOGIC /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN/di_clk
add wave -noupdate -group TEST_GEN.GEN_LOGIC -radix hexadecimal /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN/di_data
add wave -noupdate -group TEST_GEN.GEN_LOGIC /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN/di_data_we
add wave -noupdate -group TEST_GEN.GEN_LOGIC /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN/di_fifo_rst
add wave -noupdate -group TEST_GEN.GEN_LOGIC /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN/di_flag_paf
add wave -noupdate -group TEST_GEN.GEN_LOGIC /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN/di_rdy
add wave -noupdate -group TEST_GEN.GEN_LOGIC /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN/di_start
add wave -noupdate -group TEST_GEN.GEN_LOGIC -radix hexadecimal /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN/test_gen_bl_wr
add wave -noupdate -group TEST_GEN.GEN_LOGIC -radix hexadecimal /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN/test_gen_cnt1
add wave -noupdate -group TEST_GEN.GEN_LOGIC -radix hexadecimal /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN/test_gen_cnt2
add wave -noupdate -group TEST_GEN.GEN_LOGIC -radix hexadecimal -childformat {{/stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN/test_gen_ctrl(15) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN/test_gen_ctrl(14) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN/test_gen_ctrl(13) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN/test_gen_ctrl(12) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN/test_gen_ctrl(11) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN/test_gen_ctrl(10) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN/test_gen_ctrl(9) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN/test_gen_ctrl(8) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN/test_gen_ctrl(7) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN/test_gen_ctrl(6) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN/test_gen_ctrl(5) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN/test_gen_ctrl(4) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN/test_gen_ctrl(3) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN/test_gen_ctrl(2) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN/test_gen_ctrl(1) -radix hexadecimal} {/stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN/test_gen_ctrl(0) -radix hexadecimal}} -subitemconfig {/stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN/test_gen_ctrl(15) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN/test_gen_ctrl(14) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN/test_gen_ctrl(13) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN/test_gen_ctrl(12) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN/test_gen_ctrl(11) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN/test_gen_ctrl(10) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN/test_gen_ctrl(9) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN/test_gen_ctrl(8) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN/test_gen_ctrl(7) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN/test_gen_ctrl(6) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN/test_gen_ctrl(5) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN/test_gen_ctrl(4) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN/test_gen_ctrl(3) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN/test_gen_ctrl(2) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN/test_gen_ctrl(1) {-height 15 -radix hexadecimal} /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN/test_gen_ctrl(0) {-height 15 -radix hexadecimal}} /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN/test_gen_ctrl
add wave -noupdate -group TEST_GEN.GEN_LOGIC -radix hexadecimal /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN/test_gen_size
add wave -noupdate -group TEST_GEN.FIFO /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN_FIFO/clk
add wave -noupdate -group TEST_GEN.FIFO -radix hexadecimal /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN_FIFO/din
add wave -noupdate -group TEST_GEN.FIFO -radix hexadecimal /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN_FIFO/dout
add wave -noupdate -group TEST_GEN.FIFO /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN_FIFO/empty
add wave -noupdate -group TEST_GEN.FIFO /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN_FIFO/full
add wave -noupdate -group TEST_GEN.FIFO /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN_FIFO/prog_full
add wave -noupdate -group TEST_GEN.FIFO /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN_FIFO/rd_en
add wave -noupdate -group TEST_GEN.FIFO /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN_FIFO/rst
add wave -noupdate -group TEST_GEN.FIFO /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/TEST_GEN_FIFO/wr_en
add wave -noupdate -group TEST_GEN.WBS_BURST /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/WB_BURST_SLAVE/i_wbs_burst_cyc
add wave -noupdate -group TEST_GEN.WBS_BURST /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/WB_BURST_SLAVE/i_wbs_burst_stb
add wave -noupdate -group TEST_GEN.WBS_BURST /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/WB_BURST_SLAVE/i_wbs_burst_we
add wave -noupdate -group TEST_GEN.WBS_BURST -radix hexadecimal /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/WB_BURST_SLAVE/iv_wbs_burst_addr
add wave -noupdate -group TEST_GEN.WBS_BURST /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/WB_BURST_SLAVE/iv_wbs_burst_bte
add wave -noupdate -group TEST_GEN.WBS_BURST /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/WB_BURST_SLAVE/iv_wbs_burst_cti
add wave -noupdate -group TEST_GEN.WBS_BURST /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/WB_BURST_SLAVE/iv_wbs_burst_sel
add wave -noupdate -group TEST_GEN.WBS_BURST /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/WB_BURST_SLAVE/o_wbs_burst_ack
add wave -noupdate -group TEST_GEN.WBS_BURST /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/WB_BURST_SLAVE/o_wbs_burst_rty
add wave -noupdate -group TEST_GEN.WBS_BURST -radix hexadecimal /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/WB_BURST_SLAVE/ov_wbs_burst_data
add wave -noupdate -group TEST_GEN.WBS_BURST /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/WB_BURST_SLAVE/o_wbs_burst_err
add wave -noupdate -radix unsigned /stend_sp605_wishbone/dut/WB_SOPC/TEST_GEN/WB_BURST_SLAVE/sv_wbs_burst_counter
add wave -noupdate -radix unsigned /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/WB_BURST_SLAVE/sv_wbs_burst_counter
add wave -noupdate -radix unsigned /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/PW_WB/PB_WB_BRIDGE/WB_COMP_OUTGOING_FIFO/data_count
add wave -noupdate -radix unsigned /stend_sp605_wishbone/dut/WB_SOPC/PCIE_CORE64_WB/PW_WB/PB_WB_BRIDGE/si_wb_outgoing_fifo_wr_counter
add wave -noupdate /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/WB_BURST_SLAVE/s_wbs_dly_ena
add wave -noupdate -radix unsigned /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/WB_BURST_SLAVE/sv_wbs_ack_dly_value
add wave -noupdate -radix unsigned /stend_sp605_wishbone/dut/WB_SOPC/TEST_CHECK/WB_BURST_SLAVE/sv_wbs_dly_position
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {417260202 ps} 0}
configure wave -namecolwidth 679
configure wave -valuecolwidth 119
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
configure wave -timelineunits ps
update
WaveRestoreZoom {414714356 ps} {421053848 ps}
