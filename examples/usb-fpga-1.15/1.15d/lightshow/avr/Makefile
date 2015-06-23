AVRGCC=avr-gcc -std=gnu99 -save-temps -mmcu=atxmega128a1 -O2
OBJ2HEX=avr-objcopy

all: lightshow.ihx

%.obj : %.c
	$(AVRGCC) $< -o $@

%.ihx : %.obj
	$(OBJ2HEX) -R .eeprom -O ihex $< $@

clean:
	rm -f *.o *.i *.s *.obj *.old *.bak *~

distclean:
	rm -f *.ihx
