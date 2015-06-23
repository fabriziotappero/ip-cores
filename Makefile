UNITS=pdchain.vhdl  pdivtwo.vhdl
UNIT_TOP=pcount_tb.vhdl

TOP_EXE=$(patsubst %.vhdl,%,$(UNIT_TOP))
COPT=--ieee=synopsys -g
ROPT=--vcd=$(TOP_EXE).vcd --stop-time=10us


all: $(TOP_EXE) pcount

testvcd: $(TOP_EXE)
	ghdl -r $(TOP_EXE) $(ROPT)

testrun: $(TOP_EXE) pcount
	ghdl -r $(TOP_EXE) | ./pcount

$(TOP_EXE): $(UNITS) $(UNIT_TOP)
	ghdl -i $(UNITS) $(UNIT_TOP)
	ghdl -a $(COPT) $(UNIT_TOP)
	ghdl -m $(COPT) $(TOP_EXE)

pcount: pcount.c
	$(CC) -Wall -O -o $@ $<

clean:
	rm -rf $(TOP_EXE) pcount
	ghdl --remove
