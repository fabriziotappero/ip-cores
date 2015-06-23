VHDLS = \
  dac_dsm3.vhd \
  dac_dsm3v.vhd \
  dac_dsm3_top.vhd \
  dac_tb.vhd \


STD=standard
#STD=synopsys
show_spectra: dac_tb.dat
	python show_dac.py
show_ghw:   dac_tb dac_tb.ghw
	gtkwave dac_tb.ghw wzrmb.sav
dac_tb: ${VHDLS}
	ghdl -a -g --std=93c --ieee=${STD} ${VHDLS} 
	ghdl -e --std=93c -fexplicit --ieee=${STD} dac_tb
dac_tb.dat: dac_tb
	./dac_tb --wave=dac_tb.ghw --stop-time=2000000ns
dac_tb.ghw: dac_tb
	./dac_tb --wave=dac_tb.ghw --stop-time=2000000ns
clean:
	rm *.o *.vcd *.ghw *.dat *.cf dac_tb
