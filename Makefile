VERILOG=iverilog


all: rc4.vvp
rc4.vvp: rc4_tb.v rc4.v

clean:
	$(RM) *.vvp *.vcd 

# Create an Icarus processed file from a verilog source
%.vvp: %.v
	$(VERILOG) -o $@ $^

