FILES="aclocal.m4 bfd/aclocal.m4 bfd/archures.c bfd/reloc.c bfd/bfd.h bfd/bfd-in2.h bfd/bfd-in3.h bfd/bfdver.h bfd/config.bfd bfd/config.h bfd/configure bfd/configure.in bfd/cpu-rise.c bfd/doc/Makefile.in bfd/elf32-rise.c bfd/elf32-target.h bfd/Makefile.am bfd/Makefile.in bfd/po/Makefile.in bfd/targets.c bfd/targmatch.h binutils/readelf.c bootstrap.sh config.sub configure cpu/rise.cpu cpu/rise.opc gas/aclocal.m4 gas/config/tc-rise.c gas/config/tc-rise.h gas/configure gas/configure.in gas/configure.tgt gas/Makefile.am include/dis-asm.h include/elf/common.h include/elf/rise.h ld/aclocal.m4 ld/configure.tgt ld/emulparams/riseelf.sh ld/Makefile.am ld/Makefile.in opcodes/aclocal.m4 opcodes/configure opcodes/configure.in opcodes/disassemble.c opcodes/Makefile.am opcodes/Makefile.in opcodes/po/Makefile.in opcodes/rise-asm.c opcodes/rise-desc.c opcodes/rise-desc.h opcodes/rise-dis.c opcodes/rise-ibld.c opcodes/rise-opc.c opcodes/rise-opc.h opcodes/rise-opinst.c"

for f in $FILES; do
    echo "copying $f"
    cp binutils-2.17/$f binutils-2.17-rise/$f
done


