onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {system interface}
add wave -noupdate -format Logic /test/i_tessera_top/sys_pll_a_clk
add wave -noupdate -format Logic /test/i_tessera_top/sys_pll_b_clk
add wave -noupdate -format Logic -height 14 /test/t_sys_reset_n
add wave -noupdate -format Logic -height 14 /test/t_sys_init_n
add wave -noupdate -format Logic /test/t_sys_clk0
add wave -noupdate -format Logic -height 14 /test/t_sys_clk1
add wave -noupdate -format Logic -height 14 /test/t_sys_clk2
add wave -noupdate -format Logic -height 14 /test/t_sys_clk3
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/sys_or1200_res
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/sys_sdram_res
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/sys_wb_res
add wave -noupdate -format Literal -height 14 /test/i_tessera_top/i_tessera_core/sys_clmode
add wave -noupdate -format Logic /test/r_uart_data
add wave -noupdate -divider {flash interface}
add wave -noupdate -format Logic -height 14 /test/t_mem_cs2_rstdrv
add wave -noupdate -format Logic -height 14 /test/t_mem_cs2_int
add wave -noupdate -format Logic -height 14 /test/t_mem_cs2_dir
add wave -noupdate -format Logic -height 14 /test/t_mem_cs2_g_n
add wave -noupdate -format Logic -height 14 /test/t_mem_cs2_n
add wave -noupdate -format Logic -height 14 /test/t_mem_cs2_iochrdy
add wave -noupdate -format Logic -height 14 /test/t_mem_cs1_rst_n
add wave -noupdate -format Logic -height 14 /test/t_mem_cs1_n
add wave -noupdate -format Logic -height 14 /test/t_mem_cs1_rdy
add wave -noupdate -format Logic -height 14 /test/t_mem_cs0_n
add wave -noupdate -format Logic -height 14 /test/t_mem_we_n
add wave -noupdate -format Logic -height 14 /test/t_mem_oe_n
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/t_mem_a
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/t_mem_d
add wave -noupdate -format Literal /test/i_tessera_top/i_tessera_core/i_tessera_mem/i_tessera_mem_core/cs0_read_load
add wave -noupdate -format Logic /test/i_tessera_top/sys_pll_locked
add wave -noupdate -divider {sdram0 interface}
add wave -noupdate -format Logic /test/t_sdram0_clk
add wave -noupdate -format Logic -height 14 /test/t_sdram0_cke
add wave -noupdate -format Literal -height 14 /test/t_sdram0_cs_n
add wave -noupdate -format Logic -height 14 /test/t_sdram0_ras_n
add wave -noupdate -format Logic -height 14 /test/t_sdram0_cas_n
add wave -noupdate -format Logic -height 14 /test/t_sdram0_we_n
add wave -noupdate -format Literal -height 14 /test/t_sdram0_dqm
add wave -noupdate -format Literal -height 14 /test/t_sdram0_ba
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/t_sdram0_a
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/t_sdram0_d
add wave -noupdate -divider {sdram1 interface}
add wave -noupdate -format Logic /test/t_sdram1_clk
add wave -noupdate -format Logic -height 14 /test/t_sdram1_cke
add wave -noupdate -format Literal -height 14 /test/t_sdram1_cs_n
add wave -noupdate -format Logic -height 14 /test/t_sdram1_ras_n
add wave -noupdate -format Logic -height 14 /test/t_sdram1_cas_n
add wave -noupdate -format Logic -height 14 /test/t_sdram1_we_n
add wave -noupdate -format Literal -height 14 /test/t_sdram1_dqm
add wave -noupdate -format Literal -height 14 /test/t_sdram1_ba
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/t_sdram1_a
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/t_sdram1_d
add wave -noupdate -divider debug
add wave -noupdate -format Literal -height 14 /test/t_misc_gpio
add wave -noupdate -format Logic -height 14 /test/t_misc_tp
add wave -noupdate -divider jtag
add wave -noupdate -divider uart
add wave -noupdate -format Logic -height 14 /test/t_uart_txd
add wave -noupdate -format Logic -height 14 /test/t_uart_rxd
add wave -noupdate -format Logic -height 14 /test/t_uart_rts_n
add wave -noupdate -format Logic -height 14 /test/t_uart_cts_n
add wave -noupdate -format Logic -height 14 /test/t_uart_dtr_n
add wave -noupdate -format Logic -height 14 /test/t_uart_dsr_n
add wave -noupdate -format Logic -height 14 /test/t_uart_dcd_n
add wave -noupdate -format Logic -height 14 /test/t_uart_ri_n
add wave -noupdate -divider vga
add wave -noupdate -format Logic /test/t_vga_clkp
add wave -noupdate -format Logic /test/t_vga_clkn
add wave -noupdate -format Logic -height 14 /test/t_vga_hsync
add wave -noupdate -format Logic -height 14 /test/t_vga_vsync
add wave -noupdate -format Logic -height 14 /test/t_vga_blank
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/t_vga_d
add wave -noupdate -format Logic /test/i_tessera_top/i_tessera_core/i_tessera_vga/i_tessera_vga_core/i_tessera_vga_ctrl/init
add wave -noupdate -format Logic /test/i_tessera_top/i_tessera_core/i_tessera_vga/i_tessera_vga_core/i_tessera_vga_ctrl/vga_vload
add wave -noupdate -format Logic /test/i_tessera_top/i_tessera_core/i_tessera_vga/i_tessera_vga_fifo/write_exist
add wave -noupdate -format Literal /test/i_tessera_top/i_tessera_core/i_tessera_vga/i_tessera_vga_fifo/write_data
add wave -noupdate -format Logic /test/i_tessera_top/i_tessera_core/i_tessera_vga/vga_init
add wave -noupdate -format Logic /test/i_tessera_top/i_tessera_core/i_tessera_vga/vga_clear
add wave -noupdate -format Logic /test/i_tessera_top/i_tessera_core/i_tessera_vga/vga_ack
add wave -noupdate -format Logic /test/i_tessera_top/i_tessera_core/i_tessera_vga/vga_exist
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/i_tessera_vga/dma_req
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/i_tessera_top/i_tessera_core/i_tessera_vga/dma_address
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/i_tessera_vga/dma_ack
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/i_tessera_vga/dma_exist
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/i_tessera_top/i_tessera_core/i_tessera_vga/dma_data
add wave -noupdate -divider Master
add wave -noupdate -format Literal /test/i_tessera_top/i_tessera_core/i_or1200_top/iwb_biu/biu_dat_i
add wave -noupdate -format Literal /test/i_tessera_top/i_tessera_core/i_or1200_top/iwb_biu/biu_adr_i
add wave -noupdate -format Logic /test/i_tessera_top/i_tessera_core/i_or1200_top/iwb_biu/biu_cyc_i
add wave -noupdate -format Logic /test/i_tessera_top/i_tessera_core/i_or1200_top/iwb_biu/biu_stb_i
add wave -noupdate -format Logic /test/i_tessera_top/i_tessera_core/i_or1200_top/iwb_biu/biu_we_i
add wave -noupdate -format Logic /test/i_tessera_top/i_tessera_core/i_or1200_top/iwb_biu/biu_cab_i
add wave -noupdate -format Literal /test/i_tessera_top/i_tessera_core/i_or1200_top/iwb_biu/biu_sel_i
add wave -noupdate -format Literal /test/i_tessera_top/i_tessera_core/i_or1200_top/iwb_biu/biu_dat_o
add wave -noupdate -format Logic /test/i_tessera_top/i_tessera_core/i_or1200_top/iwb_biu/biu_ack_o
add wave -noupdate -format Logic /test/i_tessera_top/i_tessera_core/i_or1200_top/iwb_biu/biu_err_o
add wave -noupdate -format Literal /test/i_tessera_top/i_tessera_core/i_or1200_top/iwb_biu/valid_div
add wave -noupdate -format Logic /test/i_tessera_top/i_tessera_core/i_or1200_top/iwb_biu/long_ack_o
add wave -noupdate -format Logic /test/i_tessera_top/i_tessera_core/i_or1200_top/iwb_biu/long_err_o
add wave -noupdate -format Logic /test/i_tessera_top/i_tessera_core/i_or1200_top/iwb_biu/aborted
add wave -noupdate -format Logic /test/i_tessera_top/i_tessera_core/i_or1200_top/iwb_biu/aborted_r
add wave -noupdate -format Logic /test/i_tessera_top/i_tessera_core/i_or1200_top/iwb_biu/retry
add wave -noupdate -format Logic /test/i_tessera_top/i_tessera_core/i_or1200_top/iwb_biu/previous_complete
add wave -noupdate -format Logic /test/i_tessera_top/i_tessera_core/i_or1200_top/iwb_biu/same_addr
add wave -noupdate -format Logic /test/i_tessera_top/i_tessera_core/i_or1200_top/iwb_biu/repeated_access
add wave -noupdate -format Logic /test/i_tessera_top/i_tessera_core/i_or1200_top/iwb_biu/repeated_access_ack
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_rim_cyc_o
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/i_tessera_top/i_tessera_core/wb_rim_adr_o
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/i_tessera_top/i_tessera_core/wb_rim_dat_i
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/i_tessera_top/i_tessera_core/wb_rim_dat_o
add wave -noupdate -format Literal -height 14 /test/i_tessera_top/i_tessera_core/wb_rim_sel_o
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_rim_ack_i
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_rim_err_i
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_rim_rty_i
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_rim_we_o
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_rim_stb_o
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_rim_cab_o
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_rdm_cyc_o
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/i_tessera_top/i_tessera_core/wb_rdm_adr_o
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/i_tessera_top/i_tessera_core/wb_rdm_dat_i
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/i_tessera_top/i_tessera_core/wb_rdm_dat_o
add wave -noupdate -format Literal -height 14 /test/i_tessera_top/i_tessera_core/wb_rdm_sel_o
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_rdm_ack_i
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_rdm_err_i
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_rdm_rty_i
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_rdm_we_o
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_rdm_stb_o
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_rdm_cab_o
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/i_tessera_top/i_tessera_core/wb_dm_adr_o
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/i_tessera_top/i_tessera_core/wb_dm_dat_i
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/i_tessera_top/i_tessera_core/wb_dm_dat_o
add wave -noupdate -format Literal -height 14 /test/i_tessera_top/i_tessera_core/wb_dm_sel_o
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_dm_we_o
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_dm_stb_o
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_dm_cyc_o
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_dm_cab_o
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_dm_ack_i
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_dm_err_i
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_ticm_cyc_o
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/i_tessera_top/i_tessera_core/wb_ticm_adr_o
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/i_tessera_top/i_tessera_core/wb_ticm_dat_i
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/i_tessera_top/i_tessera_core/wb_ticm_dat_o
add wave -noupdate -format Literal -height 14 /test/i_tessera_top/i_tessera_core/wb_ticm_sel_o
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_ticm_ack_i
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_ticm_err_i
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_ticm_rty_i
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_ticm_we_o
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_ticm_stb_o
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_ticm_cab_o
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_dma0m_cyc_o
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/i_tessera_top/i_tessera_core/wb_dma0m_adr_o
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/i_tessera_top/i_tessera_core/wb_dma0m_dat_i
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/i_tessera_top/i_tessera_core/wb_dma0m_dat_o
add wave -noupdate -format Literal -height 14 /test/i_tessera_top/i_tessera_core/wb_dma0m_sel_o
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_dma0m_ack_i
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_dma0m_err_i
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_dma0m_rty_i
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_dma0m_we_o
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_dma0m_stb_o
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_dma0m_cab_o
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/prefix_flash
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/i_tessera_top/i_tessera_core/wb_rif_adr
add wave -noupdate -divider Slave
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_flashs_cyc_i
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_flashs_stb_i
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_flashs_cab_i
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/i_tessera_top/i_tessera_core/wb_flashs_adr_i
add wave -noupdate -format Literal -height 14 /test/i_tessera_top/i_tessera_core/wb_flashs_sel_i
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_flashs_we_i
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/i_tessera_top/i_tessera_core/wb_flashs_dat_i
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/i_tessera_top/i_tessera_core/wb_flashs_dat_o
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_flashs_ack_o
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_flashs_err_o
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_sdram0s_cyc_i
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_sdram0s_stb_i
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_sdram0s_cab_i
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/i_tessera_top/i_tessera_core/wb_sdram0s_adr_i
add wave -noupdate -format Literal -height 14 /test/i_tessera_top/i_tessera_core/wb_sdram0s_sel_i
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_sdram0s_we_i
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/i_tessera_top/i_tessera_core/wb_sdram0s_dat_i
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/i_tessera_top/i_tessera_core/wb_sdram0s_dat_o
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_sdram0s_ack_o
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_sdram0s_err_o
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_sdram1s_cyc_i
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_sdram1s_stb_i
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_sdram1s_cab_i
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/i_tessera_top/i_tessera_core/wb_sdram1s_adr_i
add wave -noupdate -format Literal -height 14 /test/i_tessera_top/i_tessera_core/wb_sdram1s_sel_i
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_sdram1s_we_i
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/i_tessera_top/i_tessera_core/wb_sdram1s_dat_i
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/i_tessera_top/i_tessera_core/wb_sdram1s_dat_o
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_sdram1s_ack_o
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_sdram1s_err_o
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_ram0s_cyc_i
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_ram0s_stb_i
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_ram0s_cab_i
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/i_tessera_top/i_tessera_core/wb_ram0s_adr_i
add wave -noupdate -format Literal -height 14 /test/i_tessera_top/i_tessera_core/wb_ram0s_sel_i
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_ram0s_we_i
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/i_tessera_top/i_tessera_core/wb_ram0s_dat_i
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/i_tessera_top/i_tessera_core/wb_ram0s_dat_o
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_ram0s_ack_o
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_ram0s_err_o
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_ram1s_cyc_i
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_ram1s_stb_i
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_ram1s_cab_i
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/i_tessera_top/i_tessera_core/wb_ram1s_adr_i
add wave -noupdate -format Literal -height 14 /test/i_tessera_top/i_tessera_core/wb_ram1s_sel_i
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_ram1s_we_i
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/i_tessera_top/i_tessera_core/wb_ram1s_dat_i
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/i_tessera_top/i_tessera_core/wb_ram1s_dat_o
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_ram1s_ack_o
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_ram1s_err_o
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_uarts_cyc_i
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_uarts_stb_i
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_uarts_cab_i
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/i_tessera_top/i_tessera_core/wb_uarts_adr_i
add wave -noupdate -format Literal -height 14 /test/i_tessera_top/i_tessera_core/wb_uarts_sel_i
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_uarts_we_i
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/i_tessera_top/i_tessera_core/wb_uarts_dat_i
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/i_tessera_top/i_tessera_core/wb_uarts_dat_o
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_uarts_ack_o
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_uarts_err_o
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_vgas_cyc_i
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_vgas_stb_i
add wave -noupdate -format Literal -height 14 /test/i_tessera_top/i_tessera_core/wb_vgas_sel_i
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_vgas_we_i
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/i_tessera_top/i_tessera_core/wb_vgas_adr_i
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/i_tessera_top/i_tessera_core/wb_vgas_dat_i
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_vgas_cab_i
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/i_tessera_top/i_tessera_core/wb_vgas_dat_o
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_vgas_ack_o
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_vgas_err_o
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_dma0s_cyc_i
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_dma0s_stb_i
add wave -noupdate -format Literal -height 14 /test/i_tessera_top/i_tessera_core/wb_dma0s_sel_i
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_dma0s_we_i
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/i_tessera_top/i_tessera_core/wb_dma0s_adr_i
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/i_tessera_top/i_tessera_core/wb_dma0s_dat_i
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_dma0s_cab_i
add wave -noupdate -format Literal -height 14 -radix hexadecimal /test/i_tessera_top/i_tessera_core/wb_dma0s_dat_o
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_dma0s_ack_o
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/wb_dma0s_err_o
add wave -noupdate -divider debug
add wave -noupdate -format Literal /test/i_tessera_top/i_tessera_core/i_tessera_vga/i_tessera_vga_fifo/i_FIFO_LINE/data
add wave -noupdate -format Logic /test/i_tessera_top/i_tessera_core/i_tessera_vga/i_tessera_vga_fifo/i_FIFO_LINE/wrreq
add wave -noupdate -format Logic /test/i_tessera_top/i_tessera_core/i_tessera_vga/i_tessera_vga_fifo/i_FIFO_LINE/rdreq
add wave -noupdate -format Logic /test/i_tessera_top/i_tessera_core/i_tessera_vga/i_tessera_vga_fifo/i_FIFO_LINE/rdclk
add wave -noupdate -format Logic /test/i_tessera_top/i_tessera_core/i_tessera_vga/i_tessera_vga_fifo/i_FIFO_LINE/wrclk
add wave -noupdate -format Logic /test/i_tessera_top/i_tessera_core/i_tessera_vga/i_tessera_vga_fifo/i_FIFO_LINE/aclr
add wave -noupdate -format Literal /test/i_tessera_top/i_tessera_core/i_tessera_vga/i_tessera_vga_fifo/i_FIFO_LINE/q
add wave -noupdate -format Logic /test/i_tessera_top/i_tessera_core/i_tessera_vga/i_tessera_vga_fifo/i_FIFO_LINE/rdempty
add wave -noupdate -format Logic /test/i_tessera_top/i_tessera_core/i_tessera_vga/i_tessera_vga_fifo/i_FIFO_LINE/sub_wire0
add wave -noupdate -format Literal /test/i_tessera_top/i_tessera_core/i_tessera_vga/i_tessera_vga_fifo/i_FIFO_LINE/sub_wire1
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /test/stack_push
add wave -noupdate -format Logic /test/stack_pop
add wave -noupdate -format Logic /test/stack_check
add wave -noupdate -format Literal -height 14 /test/i_tessera_top/i_tessera_core/i_or1200_top/or1200_cpu/or1200_except/except_trig
add wave -noupdate -format Literal -height 14 /test/i_tessera_top/i_tessera_core/i_or1200_top/or1200_cpu/or1200_except/sr
add wave -noupdate -format Literal -height 14 /test/i_tessera_top/i_tessera_core/i_or1200_top/or1200_cpu/or1200_except/delayed_iee
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/i_or1200_top/or1200_cpu/or1200_except/ex_freeze
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/i_or1200_top/or1200_cpu/or1200_except/branch_taken
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/i_or1200_top/or1200_cpu/or1200_except/ex_dslot
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/i_or1200_top/or1200_cpu/or1200_except/sr_we
add wave -noupdate -format Literal -height 14 /test/i_tessera_top/i_tessera_core/pic_ints
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/i_or1200_top/sig_int
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/i_or1200_top/or1200_cpu/or1200_except/sig_ibuserr
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/i_or1200_top/or1200_cpu/or1200_except/sig_dbuserr
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/i_or1200_top/or1200_cpu/or1200_except/sig_illegal
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/i_or1200_top/or1200_cpu/or1200_except/sig_align
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/i_or1200_top/or1200_cpu/or1200_except/sig_range
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/i_or1200_top/or1200_cpu/or1200_except/sig_dtlbmiss
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/i_or1200_top/or1200_cpu/or1200_except/sig_dmmufault
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/i_or1200_top/or1200_cpu/or1200_except/sig_int
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/i_or1200_top/or1200_cpu/or1200_except/sig_syscall
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/i_or1200_top/or1200_cpu/or1200_except/sig_trap
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/i_or1200_top/or1200_cpu/or1200_except/sig_itlbmiss
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/i_or1200_top/or1200_cpu/or1200_except/sig_immufault
add wave -noupdate -format Logic -height 14 /test/i_tessera_top/i_tessera_core/i_or1200_top/or1200_cpu/or1200_except/sig_tick
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {6373475001 ps} {2213702379 ps}
WaveRestoreZoom {2213657755 ps} {2213814458 ps}
configure wave -namecolwidth 417
configure wave -valuecolwidth 76
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
