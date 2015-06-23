(July 31th 2013)
It weas a heav task to create/find an appropriate test bench on assembler level
useable by the end-user.
In 2012 Klaus Dormann creates and publish his amazing 6502 test suite written
in assembler. Thanks again to Klaus!
It uses the a65 assembler created by Frank A. Kingswood
   (http://www.kingswood-consulting.co.uk/assemblers/)
   
If you generate the HEX/BIN files for your project, please aware of the offset
of #10/$a bytes.
   
I made a little change in both attached source files to allow running the
programs on systems without any os or monitor direcly from RAM.

Klaus implemented an UNEXPECTED RESET TRAP which prevent the start of program
after RESET in default configuration. Default is now "RESET -> start".

In both programs the lines
  dw  res_trap
  dw  start
should activated/deactivated by your requirements.

"6502_functional_test.a65" (5581):
vec_init
        dw  nmi_trap
;        dw  res_trap
        dw  start
        dw  irq_trap
vec_bss equ $fffa
    endif                   ;end of RAM init data
    
    if (load_data_direct = 1) & (ROM_vectors = 1)  
        org $fffa       ;vectors
        dw  nmi_trap
;        dw  res_trap
        dw  start
        dw  irq_trap
    endif


"65C02_extended_opcodes_test.a65c" (2614):
vec_init
        dw  nmi_trap
;        dw  res_trap
        dw  start
        dw  irq_trap

(2657):
    if (load_data_direct = 1) & (ROM_vectors = 1)  
        org $fffa       ;vectors
        dw  nmi_trap
;        dw  res_trap
        dw  start
        dw  irq_trap
    endif
