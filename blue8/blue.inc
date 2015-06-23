#ifndef CODEOFFSET
#define CODEOFFSET 0
#endif

uart:	equ 0xFFE
swreg:	equ 0xFF0

#define DEFSTACK lds 0xEA0
#define PRSTRING(string) ldx string | call print_msgx
#define LDIM(b,v) ldi b | sta v
#define JMPIF(mem,add) cmp mem | snz | jmp add
#define SKIP jmp _location_+2+CODEOFFSET

#ifdef BLUEMON
/* Need to include equates for all the monitor symbols here
   after relocation (EDO)
*/
BLUEMONBASE: equ 0xED0
bluemon: equ BLUEMONBASE+1
printchar:	equ BLUEMONBASE+0x00e5
hexsep:	equ BLUEMONBASE+0x008f
cr:	equ BLUEMONBASE+0x010c
_con_13: equ BLUEMONBASE+0x010c
hexin4:	equ BLUEMONBASE+0x0095
print_msgx:	equ BLUEMONBASE+0x00f3
waitcharecho:	equ BLUEMONBASE+0x010e
prompt:	equ BLUEMONBASE+0x000c
colon:	equ BLUEMONBASE+0x0082
hexinct:	equ BLUEMONBASE+0x0097
numin:	equ BLUEMONBASE+0x008c
hexnib:	equ BLUEMONBASE+0x008a
_con_15:	equ BLUEMONBASE+0x008a
bs:	equ BLUEMONBASE+0x0090
_con_8: equ BLUEMONBASE+0x0090
lf:	equ BLUEMONBASE+0x010d
ten:	equ BLUEMONBASE+0x010d
_con_10: equ BLUEMONBASE+0x010d
zero:	equ BLUEMONBASE+0x0085
_con_48: equ BLUEMONBASE+0x0085
bits3:	equ BLUEMONBASE+0x008b
hexct:	equ BLUEMONBASE+0x0091
hexzero:	equ BLUEMONBASE+0x0086
_con_0: equ BLUEMONBASE+0x0086
hextmp:	equ BLUEMONBASE+0x008d
cmdi:	equ BLUEMONBASE+0x0081
hextmp2:	equ BLUEMONBASE+0x008e
escape:	equ BLUEMONBASE+0x0083
print_msg:	equ BLUEMONBASE+0x00ee
ff:	equ BLUEMONBASE+0x010b
_con_255: equ BLUEMONBASE+0x010b
cmdg:	equ BLUEMONBASE+0x0080
hexout1:	equ BLUEMONBASE+0x00d9
xmitwait:	equ BLUEMONBASE+0x0100
crlf:	equ BLUEMONBASE+0x00e2
icount:	equ BLUEMONBASE+0x0093
waitchar:	equ BLUEMONBASE+0x0106
hexout4:	equ BLUEMONBASE+0x00a0
limit:	equ BLUEMONBASE+0x011d
nine:	equ BLUEMONBASE+0x0087
_con_57: equ BLUEMONBASE+0x0087
mask3:	equ BLUEMONBASE+0x0092
hexout2:	equ BLUEMONBASE+0x00d2
makelower:	equ BLUEMONBASE+0x0084
space:	equ BLUEMONBASE+0x0094
_con_32: equ BLUEMONBASE+0x0094
hexmask:	equ BLUEMONBASE+0x0089
print_msgcr:	equ BLUEMONBASE+0x00e8
hexa:	equ BLUEMONBASE+0x0088
cmdd:	equ BLUEMONBASE+0x007f
#endif
