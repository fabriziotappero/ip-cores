all: spigpio.vcd

spigpio.txt: ~/proj/opencores/spislave/spislave/trunk/spislave/rtl/verilog/spigpio.v tb_spigpio.v 
	cat /dev/null > spigpio.txt 
	for file in $^; do echo $$file >> spigpio.txt; done

spigpio: spigpio.txt
	iverilog -o spigpio -c spigpio.txt

spigpio.vcd: spigpio
	./spigpio

gtk: spigpio.vcd
	gtkwave spigpio.vcd

clean: spigpio
	rm -f spigpio
	rm -f spigpio.vcd
	rm -f spigpio.txt
