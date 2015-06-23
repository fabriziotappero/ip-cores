TARGET=test_vdu

all: $(TARGET).bit

run: $(TARGET).bit
	(cd tmp/ && ../../../../bin/ml403 $(TARGET).bit)

tmp/clock.v: clock.xaw
	mkdir -p tmp
	(cd tmp/ && xaw2verilog ../clock.xaw clock.v)

$(TARGET).ace: tmp/$(TARGET).bit
	(cd tmp/ && ../../ace/ml40x_bit2ace $(TARGET).bit ../$(TARGET).ace ../../ace/)

tmp/$(TARGET).ngc: $(TARGET).prj $(TARGET).xst tmp/clock.v
	(cd tmp/ && xst -ifn ../$(TARGET).xst)

tmp/$(TARGET).ngd: tmp/$(TARGET).ngc ml403.ucf
	(cd tmp/ && ngdbuild -uc ../ml403.ucf $(TARGET).ngc)

tmp/$(TARGET).ncd: tmp/$(TARGET).ngd
	(cd tmp/ && map $(TARGET).ngd)

tmp/$(TARGET)-par.ncd: tmp/$(TARGET).ncd
	(cd tmp/ && par -w $(TARGET).ncd $(TARGET)-par.ncd)

tmp/$(TARGET).bit: tmp/$(TARGET)-par.ncd
	(cd tmp/ && bitgen -w $(TARGET)-par.ncd $(TARGET).bit)

$(TARGET).bit: tmp/$(TARGET).bit
	cp tmp/$(TARGET).bit ./$(TARGET).bit

clean:
	rm -fR tmp/

dist-clean:
	rm -fR $(TARGET).ace $(TARGET).bit tmp/
