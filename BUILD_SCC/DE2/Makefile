all:
	quartus_map DE2_USB_API.qpf
	quartus_fit DE2_USB_API.qpf
	quartus_asm DE2_USB_API.qpf
	quartus_pgm -c USB-Blaster -m jtag  -o "p;DE2_USB_API.sof"
test:
	./setup.sh
	../../FPT2011_AI_TERMINAL/connect6 -port /dev/ttyS0 -player D
	
pgm:
	quartus_pgm -c USB-Blaster -m jtag  -o "p;DE2_USB_API.sof"

sim:
	vcom S_TO_AS.vhd 
	vcom S_TO_AS_CONFIG.vhd
	vcom testbench.vhd
clean:
	rm -rf db *.msg *.smsg *.summary *.done *.rpt *.pof *.sof transcript incremental_db simulation
