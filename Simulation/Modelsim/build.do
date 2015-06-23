# ---------------------------------------------------------------------------------
# BUILD SCRIPT
# ---------------------------------------------------------------------------------
#
# Build custom IP
#
vcom -work work -source -2002 $path_project_files/$path_design_files_logixa/package_txt_utilities.vhd
vcom -work work -source -2002 $path_project_files/$path_design_files_logixa/package_crc32_8b.vhd
vcom -work work -source -2002 $path_project_files/$path_design_files_logixa/package_hash10_24b.vhd
vcom -work work -source -2002 $path_project_files/$path_design_files_logixa/package_hash10_48b.vhd
vcom -work work -source -2002 $path_project_files/$path_design_files_logixa/package_esoc_configuration.vhd
vcom -work work -source -2002 $path_project_files/$path_design_files_logixa/esoc_clk_en_gen.vhd
vcom -work work -source -2002 $path_project_files/$path_design_files_logixa/esoc_control.vhd
vcom -work work -source -2002 $path_project_files/$path_design_files_logixa/esoc_bus_arbiter.vhd
vcom -work work -source -2002 $path_project_files/$path_design_files_logixa/esoc_port_mal_clock.vhd
vcom -work work -source -2002 $path_project_files/$path_design_files_logixa/esoc_port_mal_control.vhd
vcom -work work -source -2002 $path_project_files/$path_design_files_logixa/esoc_port_mal_inbound.vhd
vcom -work work -source -2002 $path_project_files/$path_design_files_logixa/esoc_port_mal_outbound.vhd
vcom -work work -source -2002 $path_project_files/$path_design_files_logixa/esoc_port_mal.vhd
vcom -work work -source -2002 $path_project_files/$path_design_files_logixa/esoc_port_interface.vhd
vcom -work work -source -2002 $path_project_files/$path_design_files_logixa/esoc_port_processor.vhd
vcom -work work -source -2002 $path_project_files/$path_design_files_logixa/esoc_port_processor_control.vhd
vcom -work work -source -2002 $path_project_files/$path_design_files_logixa/esoc_port_processor_inbound.vhd
vcom -work work -source -2002 $path_project_files/$path_design_files_logixa/esoc_port_processor_outbound.vhd
vcom -work work -source -2002 $path_project_files/$path_design_files_logixa/esoc_port_processor_search.vhd
vcom -work work -source -2002 $path_project_files/$path_design_files_logixa/esoc_port_storage.vhd
vcom -work work -source -2002 $path_project_files/$path_design_files_logixa/esoc_port.vhd
vcom -work work -source -2002 $path_project_files/$path_design_files_logixa/esoc_reset.vhd
vcom -work work -source -2002 $path_project_files/$path_design_files_logixa/esoc_search_engine.vhd
vcom -work work -source -2002 $path_project_files/$path_design_files_logixa/esoc_search_engine_control.vhd
vcom -work work -source -2002 $path_project_files/$path_design_files_logixa/esoc_search_engine_da.vhd
vcom -work work -source -2002 $path_project_files/$path_design_files_logixa/esoc_search_engine_sa.vhd
vcom -work work -source -2002 $path_project_files/$path_design_files_logixa/esoc_search_engine_sa_store.vhd
vcom -work work -source -2002 $path_project_files/$path_design_files_logixa/esoc.vhd
#
# Build vendor IP
#
 vcom -work work -source -2002 $path_project_files/$path_design_files_altera/esoc_pll1_c3/esoc_pll1_c3.vhd
 vcom -work work -source -2002 $path_project_files/$path_design_files_altera/esoc_pll2_c3/esoc_pll2_c3.vhd
 vcom -work work -source -2002 $path_project_files/$path_design_files_altera/esoc_fifo_nkx112/esoc_fifo_256x112.vhd
 vcom -work work -source -2002 $path_project_files/$path_design_files_altera/esoc_fifo_nkx80/esoc_fifo_128x80.vhd
 vcom -work work -source -2002 $path_project_files/$path_design_files_altera/esoc_fifo_nkx32/esoc_fifo_2kx32.vhd
 vcom -work work -source -2002 $path_project_files/$path_design_files_altera/esoc_fifo_nkx32/esoc_fifo_256x32.vhd
 vcom -work work -source -2002 $path_project_files/$path_design_files_altera/esoc_fifo_nkx16/esoc_fifo_256x16.vhd
 vcom -work work -source -2002 $path_project_files/$path_design_files_altera/esoc_fifo_nkx32x64/esoc_fifo_2kx32x64.vhd
 vcom -work work -source -2002 $path_project_files/$path_design_files_altera/esoc_fifo_nkx32x64/esoc_fifo_2kx64x32.vhd
 vcom -work work -source -2002 $path_project_files/$path_design_files_altera/esoc_ram_nkx1/esoc_ram_4kx1.vhd
 vcom -work work -source -2002 $path_project_files/$path_design_files_altera/esoc_ram_nkx80/esoc_ram_8kx80.vhd
 vcom -work work -source -2002 $path_project_files/$path_design_files_altera/esoc_rom_nkx32/esoc_rom_2kx32.vhd
 vcom -work work -source -2002 $path_project_files/$path_design_files_altera/esoc_port_mac/esoc_port_mac.vho
#
# Build testbench
#
 vcom -work work -source -2002 $path_project_files/$path_design_files_logixa/esoc_tb.vhd
#
# ---------------------------------------------------------------------------------
# START MODELSIM
# ---------------------------------------------------------------------------------
# vsim -t ps work.esoc_tb
