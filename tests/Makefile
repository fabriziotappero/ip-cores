#s3roms :=  $(patsubst %.s,%.s3rom,$(wildcard *.s))
ml403roms := $(patsubst %.s,%.bin,$(wildcard *.s))
rtlroms := $(patsubst %.s,%.rtlrom,$(wildcard *s))

all: $(ml403roms)

# altera: ../../altera/zet/simulation/modelsim/bios0.dat ../../altera/zet/simulation/modelsim/bios1.dat

# ../../altera/zet/simulation/modelsim/bios0.dat: bios0.out
#	hexdump -v -e '1/1 "%02X"' -e '"\n"' bios0.out > ../../altera/zet/simulation/modelsim/bios0.dat

#../../altera/zet/simulation/modelsim/bios1.dat: bios1.out
#	hexdump -v -e '1/1 "%02X"' -e '"\n"' bios1.out > ../../altera/zet/simulation/modelsim/bios1.dat

#../../sim/bios.dat: bios.out
#	hexdump -v -e '1/1 "%02X"' -e '"\n"' bios.out > ../../sim/bios.dat
#	hexdump -v -e '1/2 "0x1%04_ax/%04x"' -e '"\n"' bios.out | awk -F/ '{printf "00%x/%s\n", rshift(strtonum($$1),1), $$2}' > ../../impl/spartan3an-sk/sim/flash-prom/memory_file

#$(BIOS): bios.out
#	splitlh bios.out $(BIOS)

%.s3rom: %.out
	hexdump -v -e '1/2 "0x1%04_ax/%04x"' -e '"\n"' $< | awk -F/ '{printf "00%x/%s\n", rshift(strtonum($$1),1), $$2}' > ../../impl/spartan3an-sk/sim/flash-prom/$@

%.mcs: %.out
	echo :020000040001F9 > $@
	hexdump -v -e '":20%04_ax00"' -e '32/1 "%02x"' -e '"00"' -e '"\n"' $< | tr a-z A-Z >> $@
	echo :00000001FF >> $@

#%.ml403: %.fout hd.img.rtl
#	paste -d\\ hd.img.rtl $< >../../impl/virtex4-ml403ep/sim/$@

%.ml403: %.rom
	hexdump -v -e '4/1 "%02X"' -e '"\n"' $< > ../impl/virtex4-ml403ep/sim/$@

%.fout: %.out hd.img.rtl
	for i in $$(seq 32768); do echo FFFF; done >$@
	hexdump -v -e '1/2 "%04X"' -e '"\n"' $< >>$@
	for i in $$(seq $$(( $$(wc -l hd.img.rtl | cut -f1 -d\ )-65536))); do echo FFFF; done >$@
%.rtlrom: %.out
	hexdump -v -e '1/2 "%04X"' -e '"\n"' $< > ../sim/$@

%.rtlold: %.out
	hexdump -v -e '1/1 "%02X"' -e '"\n"' $< > ../../sim/$@

%.rom: %.rom16
	out2rom-ml403 ff.out $< > $@

%.rom16: %.out ff.out
	cat ff.out $< > $@

%.bin: %.rom
	cat count.rom $< > $@

%.out: %.o
	objcopy -O binary -S $< $@

%.o: %.s
	as $< -o $@

hd.img.rtl: hd.img
	hexdump -v -e '1/2 "%04X"' -e '"\n"' $< >$@

clean:
	rm -f *.o *.out *.bin *.mcs ../../impl/spartan3an-sk/sim/flash-prom/*.s3rom ../../sim/*.rtlrom
