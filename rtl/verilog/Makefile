dual_port_ram:
	vppreproc +define+TYPE+"sc_sw" --simple versatile_fifo_dual_port_ram.v > versatile_fifo_dual_port_ram_sc_sw.v
	vppreproc +define+TYPE+"sc_dw" +define+DW --simple versatile_fifo_dual_port_ram.v > versatile_fifo_dual_port_ram_sc_dw.v
	vppreproc +define+TYPE+"dc_sw" +define+DC --simple versatile_fifo_dual_port_ram.v > versatile_fifo_dual_port_ram_dc_sw.v
	vppreproc +define+TYPE+"dc_dw" +define+DC +define+DW --simple versatile_fifo_dual_port_ram.v > versatile_fifo_dual_port_ram_dc_dw.v

export: svn_export_versatile_counter

gray_counter:
	excel2csv gray_counter.xls -S ,
	./versatile_counter_generator.php gray_counter.csv > gray_counter.v

sd:
	excel2csv sd_counter.xls -S ,
	./versatile_counter_generator.php sd_counter.csv > sd_counter.v

adr_gen:
	excel2csv adr_gen.xls -S ,

async_fifo_altera.v: adr_gen
	./versatile_counter_generator.php adr_gen.csv > adr_gen.v
	vppreproc +define+GENERATE_DIRECTION_AS_LATCH --simple ../../backend/altera/cycloneIV/dff_sr.v adr_gen.v versatile_fifo_dual_port_ram_dc_sw.v versatile_fifo_async_cmp.v async_fifo_top.v > async_fifo_altera.v

async_fifo_mq: gray_counter
	vppreproc --simple gray_counter.v 

async_fifo_dw_simplex_actel.v: adr_gen
	vppreproc +define+GENERATE_DIRECTION_AS_LATCH +define+ACTEL --noline adr_gen.v versatile_fifo_dual_port_ram_dc_dw.v dff_sr.v versatile_fifo_async_cmp.v async_fifo_dw_simplex_top.v > async_fifo_dw_simplex_actel.v

svn_export_versatile_counter:
	svn export http://opencores.org/ocsvn/versatile_counter/versatile_counter/trunk/rtl/verilog/CSV.class.php
	svn export http://opencores.org/ocsvn/versatile_counter/versatile_counter/trunk/rtl/verilog/versatile_counter_generator.php

all: export gray_counter gray_counter sd
