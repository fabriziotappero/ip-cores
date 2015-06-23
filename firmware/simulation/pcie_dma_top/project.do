set projectEnv [project env]
if { [string length $projectEnv]==0} {
	puts "no project open"
	puts $projectEnv
} else {
	puts "closing project"
	project close
}

vdel -all -lib work
vlib work
vmap work work
project new . pcie_dma_top

# ----------------------------------------------------------
# packages
# ----------------------------------------------------------
project addfile ../../sources/packages/pcie_package.vhd

# ----------------------------------------------------------
# PCIe DMA top module
# ----------------------------------------------------------
project addfile ../../sources/shared/virtex7_dma_top.vhd
# ----------------------------------------------------------
# dma sources
# ----------------------------------------------------------

project addfile ../../sources/pcie/DMA_Core.vhd
project addfile ../../sources/pcie/pcie_slow_clock.vhd
project addfile ../../sources/pcie/pcie_init.vhd
project addfile ../../sources/pcie/pcie_ep_wrap.vhd
project addfile ../../sources/pcie/pcie_dma_wrap.vhd
project addfile ../../sources/pcie/intr_ctrl.vhd
project addfile ../../sources/pcie/dma_read_write.vhd

project addfile ../../sources/pcie/dma_control.vhd
project addfile ../../sources/pcie/pcie_clocking.vhd

project addfile ../../Projects/pcie_dma_top/pcie_dma_top.srcs/sources_1/ip/clk_wiz_40/clk_wiz_40_funcsim.vhdl
project addfile ../../Projects/pcie_dma_top/pcie_dma_top.srcs/sources_1/ip/pcie_x8_gen3_3_0/pcie_x8_gen3_3_0_funcsim.vhdl

# ----------------------------------------------------------
# example application
# ----------------------------------------------------------

project addfile ../../sources/application/application.vhd
project addfile ../../Projects/pcie_dma_top/pcie_dma_top.srcs/sources_1/ip/fifo_256x256/fifo_256x256_funcsim.vhdl

project compileall
