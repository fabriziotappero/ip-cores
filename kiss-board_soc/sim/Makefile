
#############################################################
### (ALLNoWAVE,NotSupportSDF(not-check))
#############################################################
INCCMD		= +incdir+
VLOG		= ./csh/vlog.csh
VSIM		= ./csh/vsim.csh

#############################################################
### NCVERILOG(ALLNoWAVE,NotSupportSDF(not-check))
#############################################################
#INCCMD		= -INCDIR 
#VLOG		= ./csh/ncvlog.csh
#VSIM		= ./csh/ncvsim.csh

#############################################################
### MODELSIM(VSIMRTLEXTisNowave)
#############################################################
MODEL_INC         = $(INCCMD)./mod
MODEL_SRC         =          ./mod
#XILINX_INC        = $(INCCMD)../../../orp/orp_soc/lib/xilinx
#XILINX_SRC        =          ../../../orp/orp_soc/lib/xilinx
#MEM_IF_INC        = $(INCCMD)../../../orp/orp_soc/rtl/verilog/mem_if
#MEM_IF_SRC        =          ../../../orp/orp_soc/rtl/verilog/mem_if
#SSVGA_INC         = $(INCCMD)../../../orp/orp_soc/rtl/verilog/ssvga
#SSVGA_SRC         =          ../../../orp/orp_soc/rtl/verilog/ssvga
#VGA_LCD_INC       = $(INCCMD)../../../../vga_lcd/rtl/verilog
#VGA_LCD_SRC       =          ../../../../vga_lcd/rtl/verilog
UART_INC          = $(INCCMD)../src/extend/uart16550
UART_SRC          =          ../src/extend/uart16550
DBG_INTERFACE_INC = $(INCCMD)../src/extend/dbg_interface
DBG_INTERFACE_SRC =          ../src/extend/dbg_interface
TC_INC            = $(INCCMD)../src/extend/tc
TC_SRC            =          ../src/extend/tc
WB_DMA_INC        = $(INCCMD)../src/extend/wb_dma
WB_DMA_SRC        =          ../src/extend/wb_dma
OR1200_INC        = $(INCCMD)../src/extend/or1200
OR1200_SRC        =          ../src/extend/or1200
TESSERA_INC       = $(INCCMD)../src
TESSERA_SRC       =          ../src


test_rtl: clean model altera uart16550 dbg_interface wb_dma tc or1200 tessera
	$(VLOG) $(INCCMD). ./pat/test.v
	$(VSIM) test test
test_gate: clean model altera gate
	$(VLOG) $(INCCMD). ./pat/test.v
	$(VSIM) test test

clean:
	rm -rf ./*.log
	#################################
	### modelsim
	#################################
	rm -rf ./work
	vlib work
	rm -rf ./wav
	mkdir wav
	#################################
	### ncverilog
	#################################
	#rm -rf ./*.txt
	#rm -rf ./lib
	#rm -rf ./work
	#mkdir ./lib
	#mkdir ./work
model:
	#$(VLOG) $(MODEL_INC) $(MODEL_SRC)/ram.v
	#$(VLOG) $(MODEL_INC) $(MODEL_SRC)/sdram4m8br12c8.v
	#$(VLOG) $(MODEL_INC) $(MODEL_SRC)/sdram8m8br12c9.v
	#$(VLOG) $(MODEL_INC) $(MODEL_SRC)/mt48lc4m16a2.v
	#$(VLOG) $(MODEL_INC) $(MODEL_SRC)/mt48lc16m16a2.v
	#$(VLOG) $(MODEL_INC) $(MODEL_SRC)/mt48lc32m16a2.v
	#$(VLOG) $(MODEL_INC) $(MODEL_SRC)/512Kx8.v
	#$(VLOG) $(MODEL_INC) $(MODEL_SRC)/dbg_if_model.v
	#$(VLOG) $(MODEL_INC) +define+DBG_IF_COMM $(MODEL_SRC)/dbg_comm2.v
	#$(VLOG) $(MODEL_INC) $(MODEL_SRC)/wb_master.v
	#$(VLOG) $(MODEL_INC)/28f016s3 $(MODEL_SRC)/28f016s3/bwsvff.v
	#$(VLOG) $(MODEL_INC) $(MODEL_SRC)/cycloneii_atoms.v
	#$(VLOG) $(MODEL_INC) $(MODEL_SRC)/verilog_k4s281632f_0401.v
	$(VLOG) $(MODEL_INC) $(MODEL_SRC)/rom.v
	$(VLOG) $(MODEL_INC) $(MODEL_SRC)/mt48lc8m16a2.v
	$(VLOG) $(MODEL_INC) $(MODEL_SRC)/altera_mf.v
	$(VLOG) $(MODEL_INC) $(MODEL_SRC)/220model.v
mem_if:
	#$(VLOG) $(MEM_IF_INC) $(MEM_IF_SRC)/flash_top.v
	#$(VLOG) $(MEM_IF_INC) $(MEM_IF_SRC)/sram_top.v
ssvga:
	#$(VLOG) $(SSVGA_INC) $(SSVGA_SRC)/ssvga_crtc.v
	#$(VLOG) $(SSVGA_INC) $(SSVGA_SRC)/ssvga_fifo.v
	#$(VLOG) $(SSVGA_INC) $(SSVGA_SRC)/ssvga_wbm_if.v
	#$(VLOG) $(SSVGA_INC) $(SSVGA_SRC)/ssvga_wbs_if.v
	#$(VLOG) $(SSVGA_INC) $(SSVGA_SRC)/ssvga_top.v
vga_lcd:
	#$(VLOG) $(VGA_LCD_INC) $(VGA_LCD_SRC)/vga_clkgen.v
	#$(VLOG) $(VGA_LCD_INC) $(VGA_LCD_SRC)/vga_colproc.v
	#$(VLOG) $(VGA_LCD_INC) $(VGA_LCD_SRC)/vga_csm_pb.v
	#$(VLOG) $(VGA_LCD_INC) $(VGA_LCD_SRC)/vga_cur_cregs.v
	#$(VLOG) $(VGA_LCD_INC) $(VGA_LCD_SRC)/vga_curproc.v
	#$(VLOG) $(VGA_LCD_INC) $(VGA_LCD_SRC)/vga_enh_top.v
	#$(VLOG) $(VGA_LCD_INC) $(VGA_LCD_SRC)/vga_fifo.v
	#$(VLOG) $(VGA_LCD_INC) $(VGA_LCD_SRC)/vga_fifo_dc.v
	#$(VLOG) $(VGA_LCD_INC) $(VGA_LCD_SRC)/vga_pgen.v
	#$(VLOG) $(VGA_LCD_INC) $(VGA_LCD_SRC)/vga_tgen.v
	#$(VLOG) $(VGA_LCD_INC) $(VGA_LCD_SRC)/vga_vtim.v
	#$(VLOG) $(VGA_LCD_INC) $(VGA_LCD_SRC)/vga_wb_master.v
	#$(VLOG) $(VGA_LCD_INC) $(VGA_LCD_SRC)/vga_wb_slave.v
	#$(VLOG) $(VGA_LCD_INC) $(VGA_LCD_SRC)/generic_dpram.v
	#$(VLOG) $(VGA_LCD_INC) $(VGA_LCD_SRC)/generic_spram.v
xilinx:
	#$(VLOG) $(XILINX_INC)/coregen $(XILINX_SRC)/coregen/XilinxCoreLib/async_fifo_v3_0.v
	#$(VLOG) $(XILINX_INC)/unisims $(XILINX_SRC)/unisims/RAMB4_S16.v
	#$(VLOG) $(XILINX_INC)/unisims $(XILINX_SRC)/unisims/RAMB4_S8.v
	#$(VLOG) $(XILINX_INC)/unisims $(XILINX_SRC)/unisims/RAMB4_S4.v
	#$(VLOG) $(XILINX_INC)/unisims $(XILINX_SRC)/unisims/RAMB4_S2.v
	#$(VLOG) $(XILINX_INC)/unisims $(XILINX_SRC)/unisims/RAMB4_S16_S16.v
	#$(VLOG) $(XILINX_INC)/unisims $(XILINX_SRC)/unisims/RAM32X1D.v
	#$(VLOG) $(XILINX_INC)/unisims $(XILINX_SRC)/unisims/RAMB4_S8_S16.v
	#$(VLOG) $(XILINX_INC)/unisims $(XILINX_SRC)/unisims/IBUFG.v
	#$(VLOG) $(XILINX_INC)/unisims $(XILINX_SRC)/unisims/BUFG.v
	#$(VLOG) $(XILINX_INC)/unisims $(XILINX_SRC)/unisims/CLKDLL.v
altera:
	#$(VLOG) $(TESSERA_INC) $(TESSERA_SRC)/altera/RAMB4_S8_S16.v
	#$(VLOG) $(TESSERA_INC) $(TESSERA_SRC)/altera/RAMB4_S8_S64.v
	#$(VLOG) $(TESSERA_INC) $(TESSERA_SRC)/altera/RAMB4_S8_S128.v
	#$(VLOG) $(TESSERA_INC) $(TESSERA_SRC)/altera/RAMB4_S16_S16.v
	$(VLOG) $(TESSERA_INC) $(TESSERA_SRC)/altera/RAM_256.v
	#$(VLOG) $(TESSERA_INC) $(TESSERA_SRC)/altera/RAM_512.v
	#$(VLOG) $(TESSERA_INC) $(TESSERA_SRC)/altera/RAM_1024.v
	#$(VLOG) $(TESSERA_INC) $(TESSERA_SRC)/altera/RAM_2048.v
	$(VLOG) $(TESSERA_INC) $(TESSERA_SRC)/altera/FIFO_LINE.v
	#$(VLOG) $(TESSERA_INC) $(TESSERA_SRC)/altera/FIFO_SB.v
	#$(VLOG) $(TESSERA_INC) $(TESSERA_SRC)/altera/pllx7per8_20to17_50.v
	#$(VLOG) $(TESSERA_INC) $(TESSERA_SRC)/altera/pllx1_20to20.v
	#$(VLOG) $(TESSERA_INC) $(TESSERA_SRC)/altera/pllx5per4_20to25.v
	#$(VLOG) $(TESSERA_INC) $(TESSERA_SRC)/altera/pllx3per2_20to30.v
	#$(VLOG) $(TESSERA_INC) $(TESSERA_SRC)/altera/pllx7per4_20to35.v
	#$(VLOG) $(TESSERA_INC) $(TESSERA_SRC)/altera/pllx2_20to40.v
	#$(VLOG) $(TESSERA_INC) $(TESSERA_SRC)/altera/pllx5per2_20to50.v
	#$(VLOG) $(TESSERA_INC) $(TESSERA_SRC)/altera/pllx3_20to60.v
	#$(VLOG) $(TESSERA_INC) $(TESSERA_SRC)/altera/pllx7per2_20to70.v
	#$(VLOG) $(TESSERA_INC) $(TESSERA_SRC)/altera/pllx4_20to80.v
	#$(VLOG) $(TESSERA_INC) $(TESSERA_SRC)/altera/pllx6_20to120.v
	#$(VLOG) $(TESSERA_INC) $(TESSERA_SRC)/altera/plletc.v
	$(VLOG) $(TESSERA_INC) $(TESSERA_SRC)/altera/pll_20to25AND50.v
	$(VLOG) $(TESSERA_INC) $(TESSERA_SRC)/altera/pll_20to30AND50.v
	$(VLOG) $(TESSERA_INC) $(TESSERA_SRC)/altera/pll_20to25AND60.v
	#$(VLOG) $(TESSERA_INC) $(TESSERA_SRC)/altera/pll_20to20AND40.v
	#$(VLOG) $(TESSERA_INC) $(TESSERA_SRC)/altera/pll_20to17P5AND35.v
	#$(VLOG) $(TESSERA_INC) $(TESSERA_SRC)/altera/pll_20to20.v
	#$(VLOG) $(TESSERA_INC) $(TESSERA_SRC)/altera/pll_20to40.v
	$(VLOG) $(TESSERA_INC) $(TESSERA_SRC)/altera/div.v
gate:
	$(VLOG) $(TESSERA_INC) ./tessera_top.vo
dbg_interface:
	$(VLOG) $(DBG_INTERFACE_INC) $(DBG_INTERFACE_SRC)/dbg_crc8_d1.v
	$(VLOG) $(DBG_INTERFACE_INC) $(DBG_INTERFACE_SRC)/dbg_defines.v
	$(VLOG) $(DBG_INTERFACE_INC) $(DBG_INTERFACE_SRC)/dbg_register.v
	$(VLOG) $(DBG_INTERFACE_INC) $(DBG_INTERFACE_SRC)/dbg_registers.v
	$(VLOG) $(DBG_INTERFACE_INC) $(DBG_INTERFACE_SRC)/dbg_sync_clk1_clk2.v
	$(VLOG) $(DBG_INTERFACE_INC) $(DBG_INTERFACE_SRC)/dbg_top.v
	$(VLOG) $(DBG_INTERFACE_INC) $(DBG_INTERFACE_SRC)/dbg_trace.v
uart16550:
	$(VLOG) $(UART_INC) $(UART_SRC)/raminfr.v
	$(VLOG) $(UART_INC) $(UART_SRC)/uart_sync_flops.v
	$(VLOG) $(UART_INC) $(UART_SRC)/uart_debug_if.v
	$(VLOG) $(UART_INC) $(UART_SRC)/uart_tfifo.v
	$(VLOG) $(UART_INC) $(UART_SRC)/uart_rfifo.v
	$(VLOG) $(UART_INC) $(UART_SRC)/uart_receiver.v
	$(VLOG) $(UART_INC) $(UART_SRC)/uart_regs.v
	$(VLOG) $(UART_INC) $(UART_SRC)/uart_transmitter.v
	$(VLOG) $(UART_INC) $(UART_SRC)/uart_wb.v
	$(VLOG) $(UART_INC) $(UART_SRC)/uart_top.v
tc:
	$(VLOG) $(TC_INC) $(TC_SRC)/tc_top.v
wb_dma:
	$(VLOG) $(WB_DMA_INC) $(WB_DMA_SRC)/wb_dma_top.v
	$(VLOG) $(WB_DMA_INC) $(WB_DMA_SRC)/wb_dma_rf.v
	$(VLOG) $(WB_DMA_INC) $(WB_DMA_SRC)/wb_dma_ch_rf.v
	$(VLOG) $(WB_DMA_INC) $(WB_DMA_SRC)/wb_dma_ch_sel.v
	$(VLOG) $(WB_DMA_INC) $(WB_DMA_SRC)/wb_dma_ch_pri_enc.v
	$(VLOG) $(WB_DMA_INC) $(WB_DMA_SRC)/wb_dma_ch_arb.v
	$(VLOG) $(WB_DMA_INC) $(WB_DMA_SRC)/wb_dma_de.v
	$(VLOG) $(WB_DMA_INC) $(WB_DMA_SRC)/wb_dma_inc30r.v
	$(VLOG) $(WB_DMA_INC) $(WB_DMA_SRC)/wb_dma_pri_enc_sub.v
	$(VLOG) $(WB_DMA_INC) $(WB_DMA_SRC)/wb_dma_wb_if.v
	$(VLOG) $(WB_DMA_INC) $(WB_DMA_SRC)/wb_dma_wb_mast.v
	$(VLOG) $(WB_DMA_INC) $(WB_DMA_SRC)/wb_dma_wb_slv.v
or1200:
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_iwb_biu.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_wb_biu.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_ctrl.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_cpu.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_rf.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_rfram_generic.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_alu.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_lsu.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_operandmuxes.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_wbmux.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_genpc.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_if.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_freeze.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_sprs.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_top.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_pic.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_pm.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_tt.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_except.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_dc_top.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_dc_fsm.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_reg2mem.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_mem2reg.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_dc_tag.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_dc_ram.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_ic_top.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_ic_fsm.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_ic_tag.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_ic_ram.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_immu_top.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_immu_tlb.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_dmmu_top.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_dmmu_tlb.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_amultp2_32x32.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_gmultp2_32x32.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_cfgr.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_du.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_sb.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_sb_fifo.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_mult_mac.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_qmem_top.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_dpram_32x32.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_spram_2048x32.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_spram_2048x32_bw.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_spram_2048x8.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_spram_512x20.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_spram_256x21.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_spram_1024x8.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_spram_1024x32.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_spram_1024x32_bw.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_spram_64x14.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_spram_64x22.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_spram_64x24.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_xcv_ram32x8d.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_spram_128x32.v
	$(VLOG) $(OR1200_INC) $(OR1200_SRC)/or1200_spram_32x24.v
tessera:
	$(VLOG) $(TESSERA_INC) $(TESSERA_SRC)/tessera_vga.v
	#$(VLOG) $(TESSERA_INC) $(TESSERA_SRC)/tessera_ram_data.v
	#$(VLOG) $(TESSERA_INC) $(TESSERA_SRC)/tessera_ram_vect.v
	$(VLOG) $(TESSERA_INC) $(TESSERA_SRC)/tessera_ram_tiny.v
	$(VLOG) $(TESSERA_INC) $(TESSERA_SRC)/tessera_sdram.v
	$(VLOG) $(TESSERA_INC) $(TESSERA_SRC)/tessera_mem.v
	$(VLOG) $(TESSERA_INC) $(TESSERA_SRC)/tessera_core.v
	#$(VLOG) $(TESSERA_INC) $(TESSERA_SRC)/tessera_tic.v
	$(VLOG) $(TESSERA_INC) +define+SIM $(TESSERA_SRC)/tessera_tic.v
	$(VLOG) $(TESSERA_INC) $(TESSERA_SRC)/tessera_top.v


