SVN_PATH = http://opencores.org/ocsvn/uart16550/uart16550/trunk/rtl/verilog/

#DEFINE_FILES = uart_defines.v
DEFINE_FILES = timescale.v

RTL_FILES = raminfr.v
RTL_FILES += uart_debug_if.v
RTL_FILES += uart_receiver.v
RTL_FILES += uart_regs.v
RTL_FILES += uart_rfifo.v
RTL_FILES += uart_tfifo.v
RTL_FILES += uart_sync_flops.v
RTL_FILES += uart_wb.v
RTL_FILES += uart_transmitter.v
RTL_FILES += uart_top.v

export:
	echo "Exporting UART 16550\n"
	for rtl_file in $(RTL_FILES) ; do \
	svn export $(SVN_PATH)$$rtl_file; \
        done
	for define_file in $(DEFINE_FILES) ; do \
		svn export $(SVN_PATH)$$define_file ;\
        done

ip:
	vppreproc --simple $(RTL_FILES) > uart16550_ip.v

clean:
	rm $(RTL_FILES)
	rm $(DEFINE_FILES)
	rm uart16550_ip.v
