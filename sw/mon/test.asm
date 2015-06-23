
test.o:     file format elf32-m68k

Disassembly of section .text:

00000000 <_start>:
   0:	6000 00d8      	braw da <init>
   4:	4e71           	nop
   6:	4e71           	nop

00000008 <write_a>:
   8:	207c ff01 0000 	moveal #-16711680,%a0
   e:	6000 0014      	braw 24 <w_loop>
  12:	4e71           	nop
  14:	4e71           	nop

00000016 <write_b>:
  16:	207c ff02 0000 	moveal #-16646144,%a0
  1c:	6000 0006      	braw 24 <w_loop>
  20:	4e71           	nop
  22:	4e71           	nop

00000024 <w_loop>:
  24:	3e10           	movew %a0@,%d7
  26:	0247 0200      	andiw #512,%d7
  2a:	6600 fff8      	bnew 24 <w_loop>
  2e:	4e71           	nop
  30:	4e71           	nop
  32:	1080           	moveb %d0,%a0@
  34:	4e71           	nop
  36:	4e71           	nop
  38:	4e75           	rts
  3a:	4e71           	nop
  3c:	4e71           	nop

0000003e <read_a>:
  3e:	207c ff01 0000 	moveal #-16711680,%a0
  44:	6000 0014      	braw 5a <r_loop>
  48:	4e71           	nop
  4a:	4e71           	nop

0000004c <read_b>:
  4c:	207c ff02 0000 	moveal #-16646144,%a0
  52:	6000 0006      	braw 5a <r_loop>
  56:	4e71           	nop
  58:	4e71           	nop

0000005a <r_loop>:
  5a:	3e10           	movew %a0@,%d7
  5c:	1007           	moveb %d7,%d0
  5e:	0247 0100      	andiw #256,%d7
  62:	6600 fff6      	bnew 5a <r_loop>
  66:	4e71           	nop
  68:	4e71           	nop
  6a:	4e75           	rts
  6c:	4e71           	nop
  6e:	4e71           	nop

00000070 <sign_on>:
  70:	103c 004b      	moveb #75,%d0
  74:	6100 ff92      	bsrw 8 <write_a>
  78:	4e71           	nop
  7a:	4e71           	nop
  7c:	103c 0036      	moveb #54,%d0
  80:	6100 ff86      	bsrw 8 <write_a>
  84:	4e71           	nop
  86:	4e71           	nop
  88:	103c 0038      	moveb #56,%d0
  8c:	6100 ff7a      	bsrw 8 <write_a>
  90:	4e71           	nop
  92:	4e71           	nop
  94:	6100 0032      	bsrw c8 <crlf>
  98:	4e71           	nop
  9a:	4e71           	nop
  9c:	4e75           	rts
  9e:	4e71           	nop
  a0:	4e71           	nop

000000a2 <sign_ok>:
  a2:	103c 004f      	moveb #79,%d0
  a6:	6100 ff60      	bsrw 8 <write_a>
  aa:	4e71           	nop
  ac:	4e71           	nop
  ae:	103c 004b      	moveb #75,%d0
  b2:	6100 ff54      	bsrw 8 <write_a>
  b6:	4e71           	nop
  b8:	4e71           	nop
  ba:	6100 000c      	bsrw c8 <crlf>
  be:	4e71           	nop
  c0:	4e71           	nop
  c2:	4e75           	rts
  c4:	4e71           	nop
  c6:	4e71           	nop

000000c8 <crlf>:
  c8:	103c 000d      	moveb #13,%d0
  cc:	6100 ff56      	bsrw 24 <w_loop>
  d0:	4e71           	nop
  d2:	4e71           	nop
  d4:	4e75           	rts
  d6:	4e71           	nop
  d8:	4e71           	nop

000000da <init>:
  da:	2e7c 8000 0400 	moveal #-2147482624,%sp
  e0:	6100 ff8e      	bsrw 70 <sign_on>
  e4:	4e71           	nop
  e6:	4e71           	nop
  e8:	6100 ffb8      	bsrw a2 <sign_ok>
  ec:	4e71           	nop
  ee:	4e71           	nop
  f0:	6000 0016      	braw 108 <main>
  f4:	4e71           	nop
  f6:	4e71           	nop

000000f8 <code>:
  f8:	323c 7f7f      	movew #32639,%d1
  fc:	b340           	eorw %d1,%d0
  fe:	4e71           	nop
 100:	4e71           	nop
 102:	4e75           	rts
 104:	4e71           	nop
 106:	4e71           	nop

00000108 <main>:
 108:	6100 ff34      	bsrw 3e <read_a>
 10c:	4e71           	nop
 10e:	4e71           	nop
 110:	6100 ffe6      	bsrw f8 <code>
 114:	4e71           	nop
 116:	4e71           	nop
 118:	6100 feee      	bsrw 8 <write_a>
 11c:	4e71           	nop
 11e:	4e71           	nop
 120:	6100 ffa6      	bsrw c8 <crlf>
 124:	4e71           	nop
 126:	4e71           	nop
 128:	6000 ffde      	braw 108 <main>
 12c:	4e71           	nop
 12e:	4e71           	nop
Disassembly of section .data:
