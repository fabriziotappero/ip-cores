# Copyright (C) 1991-2004 Altera Corporation
# Any  megafunction  design,  and related netlist (encrypted  or  decrypted),
# support information,  device programming or simulation file,  and any other
# associated  documentation or information  provided by  Altera  or a partner
# under  Altera's   Megafunction   Partnership   Program  may  be  used  only
# to program  PLD  devices (but not masked  PLD  devices) from  Altera.   Any
# other  use  of such  megafunction  design,  netlist,  support  information,
# device programming or simulation file,  or any other  related documentation
# or information  is prohibited  for  any  other purpose,  including, but not
# limited to  modification,  reverse engineering,  de-compiling, or use  with
# any other  silicon devices,  unless such use is  explicitly  licensed under
# a separate agreement with  Altera  or a megafunction partner.  Title to the
# intellectual property,  including patents,  copyrights,  trademarks,  trade
# secrets,  or maskworks,  embodied in any such megafunction design, netlist,
# support  information,  device programming or simulation file,  or any other
# related documentation or information provided by  Altera  or a megafunction
# partner, remains with Altera, the megafunction partner, or their respective
# licensors. No other licenses, including any licenses needed under any third
# party's intellectual property, are provided herein.

# Quartus II: Generate Tcl File for Project
# File: tessera_top.tcl
# Generated on: Thu May 18 12:46:39 2006

# Load Quartus II Tcl Project package
package require ::quartus::project

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "tessera_top"]} {
		puts "Project tessera_top is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists tessera_top]} {
		project_open -revision tessera_top tessera_top
	} else {
		project_new -revision tessera_top tessera_top
	}
	set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION 4.2
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "13:21:00  JUNE 23, 2005"
	set_global_assignment -name LAST_QUARTUS_VERSION 4.2
	set_global_assignment -name VERILOG_FILE ../src/altera/pll_20to35and70.v
	set_global_assignment -name VERILOG_FILE ../src/altera/pll_20to17p5and35.v
	set_global_assignment -name VERILOG_FILE ../src/altera/pll_20to40.v
	set_global_assignment -name VERILOG_FILE ../src/altera/pll_20to20.v
	set_global_assignment -name VERILOG_FILE ../src/altera/pll_20to20and40.v
	set_global_assignment -name VERILOG_FILE ../src/altera/pll_20to25and60.v
	set_global_assignment -name VERILOG_FILE ../src/altera/pll_20to30and50.v
	set_global_assignment -name VERILOG_FILE ../src/altera/pll_20to25and50.v
	set_global_assignment -name VERILOG_FILE ../src/altera/div.v
	set_global_assignment -name VERILOG_FILE ../src/altera/pllx7per8_20to17_50.v
	set_global_assignment -name VERILOG_FILE ../src/altera/pllx1_20to20.v
	set_global_assignment -name VERILOG_FILE ../src/altera/pllx5per4_20to25.v
	set_global_assignment -name VERILOG_FILE ../src/altera/pllx3per2_20to30.v
	set_global_assignment -name VERILOG_FILE ../src/altera/pllx7per4_20to35.v
	set_global_assignment -name VERILOG_FILE ../src/altera/pllx2_20to40.v
	set_global_assignment -name VERILOG_FILE ../src/altera/pllx5per2_20to50.v
	set_global_assignment -name VERILOG_FILE ../src/altera/pllx3_20to60.v
	set_global_assignment -name VERILOG_FILE ../src/altera/pllx7per2_20to70.v
	set_global_assignment -name VERILOG_FILE ../src/altera/pllx4_20to80.v
	set_global_assignment -name VERILOG_FILE ../src/altera/pllx6_20to120.v
	set_global_assignment -name VERILOG_FILE ../src/altera/plletc.v
	set_global_assignment -name VERILOG_FILE ../src/altera/ram_1024.v
	set_global_assignment -name VERILOG_FILE ../src/altera/ram_2048.v
	set_global_assignment -name VERILOG_FILE ../src/altera/ram_256.v
	set_global_assignment -name VERILOG_FILE ../src/altera/fifo_line.v
	set_global_assignment -name VERILOG_FILE ../src/altera/ramb4_s8_s64.v
	set_global_assignment -name VERILOG_FILE ../src/altera/ramb4_s16_s16.v
	set_global_assignment -name VERILOG_FILE ../src/extend/wb_dma/wb_dma_ch_arb.v
	set_global_assignment -name VERILOG_FILE ../src/extend/wb_dma/wb_dma_ch_pri_enc.v
	set_global_assignment -name VERILOG_FILE ../src/extend/wb_dma/wb_dma_ch_rf.v
	set_global_assignment -name VERILOG_FILE ../src/extend/wb_dma/wb_dma_ch_sel.v
	set_global_assignment -name VERILOG_FILE ../src/extend/wb_dma/wb_dma_de.v
	set_global_assignment -name VERILOG_FILE ../src/extend/wb_dma/wb_dma_inc30r.v
	set_global_assignment -name VERILOG_FILE ../src/extend/wb_dma/wb_dma_pri_enc_sub.v
	set_global_assignment -name VERILOG_FILE ../src/extend/wb_dma/wb_dma_rf.v
	set_global_assignment -name VERILOG_FILE ../src/extend/wb_dma/wb_dma_top.v
	set_global_assignment -name VERILOG_FILE ../src/extend/wb_dma/wb_dma_wb_if.v
	set_global_assignment -name VERILOG_FILE ../src/extend/wb_dma/wb_dma_wb_mast.v
	set_global_assignment -name VERILOG_FILE ../src/extend/wb_dma/wb_dma_wb_slv.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_xcv_ram32x8d.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_alu.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_amultp2_32x32.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_cfgr.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_cpu.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_ctrl.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_dc_fsm.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_dc_ram.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_dc_tag.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_dc_top.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_defines.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_dmmu_tlb.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_dmmu_top.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_dpram_32x32.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_du.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_except.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_freeze.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_genpc.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_gmultp2_32x32.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_ic_fsm.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_ic_ram.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_ic_tag.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_ic_top.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_if.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_immu_tlb.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_immu_top.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_iwb_biu.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_lsu.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_mem2reg.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_mult_mac.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_operandmuxes.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_pic.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_pm.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_qmem_top.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_reg2mem.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_rf.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_rfram_generic.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_sb.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_sb_fifo.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_spram_32x24.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_spram_64x14.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_spram_64x22.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_spram_64x24.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_spram_128x32.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_spram_256x21.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_spram_512x20.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_spram_1024x8.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_spram_1024x32.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_spram_1024x32_bw.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_spram_2048x8.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_spram_2048x32.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_spram_2048x32_bw.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_sprs.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_top.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_tpram_32x32.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_tt.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_wb_biu.v
	set_global_assignment -name VERILOG_FILE ../src/extend/or1200/or1200_wbmux.v
	set_global_assignment -name VERILOG_FILE ../src/extend/uart16550/raminfr.v
	set_global_assignment -name VERILOG_FILE ../src/extend/uart16550/uart_debug_if.v
	set_global_assignment -name VERILOG_FILE ../src/extend/uart16550/uart_receiver.v
	set_global_assignment -name VERILOG_FILE ../src/extend/uart16550/uart_regs.v
	set_global_assignment -name VERILOG_FILE ../src/extend/uart16550/uart_rfifo.v
	set_global_assignment -name VERILOG_FILE ../src/extend/uart16550/uart_sync_flops.v
	set_global_assignment -name VERILOG_FILE ../src/extend/uart16550/uart_tfifo.v
	set_global_assignment -name VERILOG_FILE ../src/extend/uart16550/uart_top.v
	set_global_assignment -name VERILOG_FILE ../src/extend/uart16550/uart_transmitter.v
	set_global_assignment -name VERILOG_FILE ../src/extend/uart16550/uart_wb.v
	set_global_assignment -name VERILOG_FILE ../src/extend/dbg_interface/dbg_crc8_d1.v
	set_global_assignment -name VERILOG_FILE ../src/extend/dbg_interface/dbg_defines.v
	set_global_assignment -name VERILOG_FILE ../src/extend/dbg_interface/dbg_register.v
	set_global_assignment -name VERILOG_FILE ../src/extend/dbg_interface/dbg_registers.v
	set_global_assignment -name VERILOG_FILE ../src/extend/dbg_interface/dbg_sync_clk1_clk2.v
	set_global_assignment -name VERILOG_FILE ../src/extend/dbg_interface/dbg_trace.v
	set_global_assignment -name VERILOG_FILE ../src/extend/dbg_interface/dbg_top.v
	set_global_assignment -name VERILOG_FILE ../src/extend/tc/tc_top.v
	set_global_assignment -name VERILOG_FILE ../src/tessera_ram_vect.v
	set_global_assignment -name VERILOG_FILE ../src/tessera_ram_tiny.v
	set_global_assignment -name VERILOG_FILE ../src/tessera_sdram.v
	set_global_assignment -name VERILOG_FILE ../src/tessera_mem.v
	set_global_assignment -name VERILOG_FILE ../src/tessera_vga.v
	set_global_assignment -name VERILOG_FILE ../src/tessera_tic.v
	set_global_assignment -name VERILOG_FILE ../src/tessera_core.v
	set_global_assignment -name VERILOG_FILE ../src/tessera_top.v
	set_global_assignment -name CUT_OFF_PATHS_BETWEEN_CLOCK_DOMAINS OFF
	set_global_assignment -name CUT_OFF_READ_DURING_WRITE_PATHS OFF
	set_global_assignment -name CUT_OFF_IO_PIN_FEEDBACK OFF
	set_global_assignment -name TSU_REQUIREMENT 6ns
	set_global_assignment -name TCO_REQUIREMENT 6ns
	set_global_assignment -name DUTY_CYCLE 50 -section_id sys_clk0_OBJECT
	set_global_assignment -name FMAX_REQUIREMENT "20.0 MHz" -section_id sys_clk0_OBJECT
	set_global_assignment -name INVERT_BASE_CLOCK OFF -section_id sys_clk0_OBJECT
	set_global_assignment -name MULTIPLY_BASE_CLOCK_PERIOD_BY 1 -section_id sys_clk0_OBJECT
	set_global_assignment -name DIVIDE_BASE_CLOCK_PERIOD_BY 1 -section_id sys_clk0_OBJECT
	set_global_assignment -name FAMILY Cyclone
	set_global_assignment -name DEVICE EP1C12Q240C6
	set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"
	set_global_assignment -name RESERVE_ASDO_AFTER_CONFIGURATION "AS OUTPUT DRIVING AN UNSPECIFIED SIGNAL"
	set_global_assignment -name SLOW_SLEW_RATE ON
	set_global_assignment -name ENABLE_RECOVERY_REMOVAL_ANALYSIS ON
	set_global_assignment -name EDA_SIMULATION_TOOL "ModelSim (Verilog)"
	set_global_assignment -name EDA_OUTPUT_DATA_FORMAT VERILOG -section_id eda_simulation
	set_global_assignment -name EDA_TIME_SCALE "1 ps" -section_id eda_simulation
	set_global_assignment -name CYCLONE_CONFIGURATION_DEVICE EPCS4
	set_global_assignment -name RESERVE_ALL_UNUSED_PINS_NO_OUTPUT_GND "AS INPUT TRI-STATED"
	set_global_assignment -name GLITCH_INTERVAL 1
	set_global_assignment -name LOGICLOCK_INCREMENTAL_COMPILE_ASSIGNMENT off
	set_location_assignment PIN_179 -to sys_reset_n
	set_location_assignment PIN_180 -to sys_init_n
	set_location_assignment PIN_28 -to sys_clk0
	set_location_assignment PIN_29 -to sys_clk1
	set_location_assignment PIN_153 -to sys_clk2
	set_location_assignment PIN_152 -to sys_clk3
	set_location_assignment PIN_125 -to uart_txd
	set_location_assignment PIN_126 -to uart_rxd
	set_location_assignment PIN_127 -to uart_rts_n
	set_location_assignment PIN_128 -to uart_cts_n
	set_location_assignment PIN_131 -to uart_dtr_n
	set_location_assignment PIN_132 -to uart_dsr_n
	set_location_assignment PIN_133 -to uart_dcd_n
	set_location_assignment PIN_134 -to uart_ri_n
	set_location_assignment PIN_239 -to mem_cs2_rstdrv
	set_location_assignment PIN_240 -to mem_cs2_int
	set_location_assignment PIN_1 -to mem_cs2_dir
	set_location_assignment PIN_2 -to mem_cs2_g_n
	set_location_assignment PIN_3 -to mem_cs2_n
	set_location_assignment PIN_4 -to mem_cs2_iochrdy
	set_location_assignment PIN_119 -to mem_cs1_rst_n
	set_location_assignment PIN_5 -to mem_cs1_n
	set_location_assignment PIN_6 -to mem_cs1_rdy
	set_location_assignment PIN_7 -to mem_cs0_n
	set_location_assignment PIN_8 -to mem_we_n
	set_location_assignment PIN_11 -to mem_oe_n
	set_location_assignment PIN_12 -to mem_a[22]
	set_location_assignment PIN_13 -to mem_a[21]
	set_location_assignment PIN_14 -to mem_a[20]
	set_location_assignment PIN_15 -to mem_a[19]
	set_location_assignment PIN_16 -to mem_a[18]
	set_location_assignment PIN_17 -to mem_a[17]
	set_location_assignment PIN_18 -to mem_a[16]
	set_location_assignment PIN_19 -to mem_a[15]
	set_location_assignment PIN_20 -to mem_a[14]
	set_location_assignment PIN_21 -to mem_a[13]
	set_location_assignment PIN_23 -to mem_a[12]
	set_location_assignment PIN_38 -to mem_a[11]
	set_location_assignment PIN_39 -to mem_a[10]
	set_location_assignment PIN_41 -to mem_a[9]
	set_location_assignment PIN_42 -to mem_a[8]
	set_location_assignment PIN_43 -to mem_a[7]
	set_location_assignment PIN_44 -to mem_a[6]
	set_location_assignment PIN_45 -to mem_a[5]
	set_location_assignment PIN_46 -to mem_a[4]
	set_location_assignment PIN_47 -to mem_a[3]
	set_location_assignment PIN_48 -to mem_a[2]
	set_location_assignment PIN_49 -to mem_a[1]
	set_location_assignment PIN_50 -to mem_a[0]
	set_location_assignment PIN_53 -to mem_d[7]
	set_location_assignment PIN_54 -to mem_d[6]
	set_location_assignment PIN_55 -to mem_d[5]
	set_location_assignment PIN_56 -to mem_d[4]
	set_location_assignment PIN_57 -to mem_d[3]
	set_location_assignment PIN_58 -to mem_d[2]
	set_location_assignment PIN_59 -to mem_d[1]
	set_location_assignment PIN_60 -to mem_d[0]
	set_location_assignment PIN_181 -to sdram0_clk
	set_location_assignment PIN_182 -to sdram0_cke
	set_location_assignment PIN_183 -to sdram0_cs_n[1]
	set_location_assignment PIN_184 -to sdram0_cs_n[0]
	set_location_assignment PIN_185 -to sdram0_ras_n
	set_location_assignment PIN_186 -to sdram0_cas_n
	set_location_assignment PIN_187 -to sdram0_we_n
	set_location_assignment PIN_188 -to sdram0_dqm[1]
	set_location_assignment PIN_193 -to sdram0_dqm[0]
	set_location_assignment PIN_194 -to sdram0_ba[1]
	set_location_assignment PIN_195 -to sdram0_ba[0]
	set_location_assignment PIN_196 -to sdram0_a[12]
	set_location_assignment PIN_197 -to sdram0_a[11]
	set_location_assignment PIN_200 -to sdram0_a[10]
	set_location_assignment PIN_201 -to sdram0_a[9]
	set_location_assignment PIN_202 -to sdram0_a[8]
	set_location_assignment PIN_203 -to sdram0_a[7]
	set_location_assignment PIN_206 -to sdram0_a[6]
	set_location_assignment PIN_207 -to sdram0_a[5]
	set_location_assignment PIN_208 -to sdram0_a[4]
	set_location_assignment PIN_213 -to sdram0_a[3]
	set_location_assignment PIN_214 -to sdram0_a[2]
	set_location_assignment PIN_215 -to sdram0_a[1]
	set_location_assignment PIN_216 -to sdram0_a[0]
	set_location_assignment PIN_217 -to sdram0_d[15]
	set_location_assignment PIN_218 -to sdram0_d[14]
	set_location_assignment PIN_219 -to sdram0_d[13]
	set_location_assignment PIN_222 -to sdram0_d[12]
	set_location_assignment PIN_223 -to sdram0_d[11]
	set_location_assignment PIN_224 -to sdram0_d[10]
	set_location_assignment PIN_225 -to sdram0_d[9]
	set_location_assignment PIN_226 -to sdram0_d[8]
	set_location_assignment PIN_227 -to sdram0_d[7]
	set_location_assignment PIN_228 -to sdram0_d[6]
	set_location_assignment PIN_233 -to sdram0_d[5]
	set_location_assignment PIN_234 -to sdram0_d[4]
	set_location_assignment PIN_235 -to sdram0_d[3]
	set_location_assignment PIN_236 -to sdram0_d[2]
	set_location_assignment PIN_237 -to sdram0_d[1]
	set_location_assignment PIN_238 -to sdram0_d[0]
	set_location_assignment PIN_61 -to sdram1_clk
	set_location_assignment PIN_62 -to sdram1_cke
	set_location_assignment PIN_63 -to sdram1_cs_n[1]
	set_location_assignment PIN_64 -to sdram1_cs_n[0]
	set_location_assignment PIN_65 -to sdram1_ras_n
	set_location_assignment PIN_66 -to sdram1_cas_n
	set_location_assignment PIN_67 -to sdram1_we_n
	set_location_assignment PIN_68 -to sdram1_dqm[1]
	set_location_assignment PIN_73 -to sdram1_dqm[0]
	set_location_assignment PIN_74 -to sdram1_ba[1]
	set_location_assignment PIN_75 -to sdram1_ba[0]
	set_location_assignment PIN_76 -to sdram1_a[12]
	set_location_assignment PIN_77 -to sdram1_a[11]
	set_location_assignment PIN_78 -to sdram1_a[10]
	set_location_assignment PIN_79 -to sdram1_a[9]
	set_location_assignment PIN_82 -to sdram1_a[8]
	set_location_assignment PIN_83 -to sdram1_a[7]
	set_location_assignment PIN_84 -to sdram1_a[6]
	set_location_assignment PIN_85 -to sdram1_a[5]
	set_location_assignment PIN_86 -to sdram1_a[4]
	set_location_assignment PIN_87 -to sdram1_a[3]
	set_location_assignment PIN_88 -to sdram1_a[2]
	set_location_assignment PIN_93 -to sdram1_a[1]
	set_location_assignment PIN_94 -to sdram1_a[0]
	set_location_assignment PIN_95 -to sdram1_d[15]
	set_location_assignment PIN_98 -to sdram1_d[14]
	set_location_assignment PIN_99 -to sdram1_d[13]
	set_location_assignment PIN_100 -to sdram1_d[12]
	set_location_assignment PIN_101 -to sdram1_d[11]
	set_location_assignment PIN_104 -to sdram1_d[10]
	set_location_assignment PIN_105 -to sdram1_d[9]
	set_location_assignment PIN_106 -to sdram1_d[8]
	set_location_assignment PIN_107 -to sdram1_d[7]
	set_location_assignment PIN_108 -to sdram1_d[6]
	set_location_assignment PIN_113 -to sdram1_d[5]
	set_location_assignment PIN_114 -to sdram1_d[4]
	set_location_assignment PIN_115 -to sdram1_d[3]
	set_location_assignment PIN_116 -to sdram1_d[2]
	set_location_assignment PIN_117 -to sdram1_d[1]
	set_location_assignment PIN_118 -to sdram1_d[0]
	set_location_assignment PIN_135 -to vga_clkp
	set_location_assignment PIN_136 -to vga_clkn
	set_location_assignment PIN_137 -to vga_vsync
	set_location_assignment PIN_138 -to vga_hsync
	set_location_assignment PIN_139 -to vga_blank
	set_location_assignment PIN_140 -to vga_d[23]
	set_location_assignment PIN_141 -to vga_d[22]
	set_location_assignment PIN_143 -to vga_d[21]
	set_location_assignment PIN_144 -to vga_d[20]
	set_location_assignment PIN_156 -to vga_d[19]
	set_location_assignment PIN_158 -to vga_d[18]
	set_location_assignment PIN_159 -to vga_d[17]
	set_location_assignment PIN_160 -to vga_d[16]
	set_location_assignment PIN_161 -to vga_d[15]
	set_location_assignment PIN_162 -to vga_d[14]
	set_location_assignment PIN_163 -to vga_d[13]
	set_location_assignment PIN_164 -to vga_d[12]
	set_location_assignment PIN_165 -to vga_d[11]
	set_location_assignment PIN_166 -to vga_d[10]
	set_location_assignment PIN_167 -to vga_d[9]
	set_location_assignment PIN_168 -to vga_d[8]
	set_location_assignment PIN_169 -to vga_d[7]
	set_location_assignment PIN_170 -to vga_d[6]
	set_location_assignment PIN_173 -to vga_d[5]
	set_location_assignment PIN_174 -to vga_d[4]
	set_location_assignment PIN_175 -to vga_d[3]
	set_location_assignment PIN_176 -to vga_d[2]
	set_location_assignment PIN_177 -to vga_d[1]
	set_location_assignment PIN_178 -to vga_d[0]
	set_location_assignment PIN_121 -to misc_gpio[3]
	set_location_assignment PIN_122 -to misc_gpio[2]
	set_location_assignment PIN_123 -to misc_gpio[1]
	set_location_assignment PIN_124 -to misc_gpio[0]
	set_location_assignment PIN_120 -to misc_tp
	set_instance_assignment -name CLOCK_SETTINGS sys_clk0_OBJECT -to sys_clk0
	set_instance_assignment -name IO_STANDARD LVCMOS -to vga_clkp
	set_instance_assignment -name IO_STANDARD LVCMOS -to vga_clkn
	set_instance_assignment -name IO_STANDARD LVCMOS -to vga_vsync
	set_instance_assignment -name IO_STANDARD LVCMOS -to vga_hsync
	set_instance_assignment -name IO_STANDARD LVCMOS -to vga_blank
	set_instance_assignment -name IO_STANDARD LVCMOS -to vga_d[23]
	set_instance_assignment -name IO_STANDARD LVCMOS -to vga_d[22]
	set_instance_assignment -name IO_STANDARD LVCMOS -to vga_d[21]
	set_instance_assignment -name IO_STANDARD LVCMOS -to vga_d[20]
	set_instance_assignment -name IO_STANDARD LVCMOS -to vga_d[19]
	set_instance_assignment -name IO_STANDARD LVCMOS -to vga_d[18]
	set_instance_assignment -name IO_STANDARD LVCMOS -to vga_d[17]
	set_instance_assignment -name IO_STANDARD LVCMOS -to vga_d[16]
	set_instance_assignment -name IO_STANDARD LVCMOS -to vga_d[15]
	set_instance_assignment -name IO_STANDARD LVCMOS -to vga_d[14]
	set_instance_assignment -name IO_STANDARD LVCMOS -to vga_d[13]
	set_instance_assignment -name IO_STANDARD LVCMOS -to vga_d[12]
	set_instance_assignment -name IO_STANDARD LVCMOS -to vga_d[11]
	set_instance_assignment -name IO_STANDARD LVCMOS -to vga_d[10]
	set_instance_assignment -name IO_STANDARD LVCMOS -to vga_d[9]
	set_instance_assignment -name IO_STANDARD LVCMOS -to vga_d[8]
	set_instance_assignment -name IO_STANDARD LVCMOS -to vga_d[7]
	set_instance_assignment -name IO_STANDARD LVCMOS -to vga_d[6]
	set_instance_assignment -name IO_STANDARD LVCMOS -to vga_d[5]
	set_instance_assignment -name IO_STANDARD LVCMOS -to vga_d[4]
	set_instance_assignment -name IO_STANDARD LVCMOS -to vga_d[3]
	set_instance_assignment -name IO_STANDARD LVCMOS -to vga_d[2]
	set_instance_assignment -name IO_STANDARD LVCMOS -to vga_d[1]
	set_instance_assignment -name IO_STANDARD LVCMOS -to vga_d[0]
	set_instance_assignment -name GLOBAL_SIGNAL "GLOBAL CLOCK" -to sys_clk0

	# Commit assignments
	export_assignments

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
