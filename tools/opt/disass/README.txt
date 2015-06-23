This small program is used to disassemble
the boot code used by the SPARC Core.

Just run:

     ./disass | less

to see the code; note that the disassembled code
is of the kind:

   - Beginning of main function: IGNORE THIS
   - 4 x NOP: to signal beginning of ROM boot code
   - REAL boot code into the OpenBoot PROM at Physical Address 0xfff0000020
   - 4 x NOP: to signal beginning of RAM boot code
   - REAL boot code executed from RAM at Physical Address 0x00000400c0
   - 4 x NOP: to signal end of boot code
   - End of main() function: IGNORE THIS

That's all!
