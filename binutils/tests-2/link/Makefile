BUILD = ../../../build

all:
	$(BUILD)/bin/as -o link1.o link1.s
	$(BUILD)/bin/as -o link2.o link2.s
	$(BUILD)/bin/ld -o link12 link1.o link2.o
	$(BUILD)/bin/ld -o link21 link2.o link1.o
	@echo -n "Comparing link12 and link21: "
	@if cmp link12 link21 ; \
	  then echo "Files are equal." ; \
	  else echo "Error found!" ; \
	fi

clean:
	rm -f *~ link1.o link2.o link12 link21
