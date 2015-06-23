export:
	make -C rtl/verilog/uart16550 export

config:
	make -C rtl/verilog config

ip:
	make -C rtl/verilog ip

all: export config ip

clean:
	make -C rtl/verilog clean
