


sd_actel:
	vppp --simple sd_defines.v sd_controller_fifo_wb.v sd_cmd_phy.v  sd_fifo.v sd_counter.v versatile_fifo_async_cmp.v sd_crc_7.v sd_crc_16.v sd_data_phy.v > sd_controller_fifo_actel.v

sd_generic: 
	vppp --simple sd_defines.v sd_controller_fifo_wb.v sd_cmd_phy.v  sd_fifo.v sd_counter.v versatile_fifo_async_cmp.v sd_crc_7.v sd_crc_16.v sd_data_phy.v versatile_fifo_dptam_dw.v > sd_controller_fifo.v

all: sd_actel sd_generic
