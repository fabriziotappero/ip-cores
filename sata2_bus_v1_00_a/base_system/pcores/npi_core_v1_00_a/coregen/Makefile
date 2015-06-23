# This Makefile will generate the NGC files based on only the XCO files
# DO NOT Delete the XCO files!

FILES=rx_fifo.xco tx_fifo.xco npi_ila.xco npi_if_ila.xco npi_if_tx_ila.xco \

.SUFFIXES: .xco .ngc

.xco.ngc:
	coregen -p coregen.cgp -b $<

ALL: $(FILES:.xco=.ngc)


clean:
	rm -rf *~ *.txt *.ncf *.ise *.vho *.tcl *.log *.pdf *.xrpt
	rm -rf tmp xlnx_auto_0_xdb
	rm -rf *.gise *.xise *.asy *.cgc _xmsgs 

clean_ngc:
	rm -rf *.ngc

clean_cdc:
	rm -rf *.cdc

clean_vhd:
	rm -rf *.vhd

real_clean: clean clean_ngc clean_cdc clean_vhd
