BUILD = ../../../build

all:
	$(BUILD)/bin/as -o abs1.o abs1.s
	$(BUILD)/bin/as -o abs2.o abs2.s
	$(BUILD)/bin/ld -o abs12 abs1.o abs2.o
	$(BUILD)/bin/ld -o abs21 abs2.o abs1.o
	@echo -n "Comparing abs12 and abs21: "
	@if cmp abs12 abs21 ; \
	  then echo "Files are equal." ; \
	  else echo "Error found!" ; \
	fi

clean:
	rm -f *~ abs1.o abs2.o abs12 abs21
