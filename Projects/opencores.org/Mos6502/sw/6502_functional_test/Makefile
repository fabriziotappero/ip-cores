code=6502_functional_test

all:asm_6502



.PHONY asm_6502:
asm_6502: 
	(\
	echo "#################################################################"; \
	echo; \
	echo "assembling: $(code)    ####"; echo; \
	as65 -l -m -s2 -h0  $(code).asm ; \
	hex2abs16 $(code); \
	hex2abs   $(code); \
	hex2abs_split $(code); \
	)





