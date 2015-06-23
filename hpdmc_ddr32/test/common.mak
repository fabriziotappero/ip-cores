SOURCES_MODEL=tb_model.v ddr.v

all: hpdmc

model: $(SOURCES_MODEL)
	cver $(SOURCES_MODEL)

hpdmc: $(SOURCES)
	cver $(SOURCES_HPDMC)

clean:
	rm -f verilog.log hpdmc.vcd

.PHONY: clean model hpdmc
