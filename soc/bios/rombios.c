// ROM BIOS compatability entry points:
// ===================================
// $e05b ; POST Entry Point
// $e6f2 ; INT 19h Boot Load Service Entry Point
// $f045 ; INT 10 Functions 0-Fh Entry Point
// $f065 ; INT 10h Video Support Service Entry Point
// $f0a4 ; MDA/CGA Video Parameter Table (INT 1Dh)
// $fff0 ; Power-up Entry Point
// $fff5 ; ASCII Date ROM was built - 8 characters in MM/DD/YY
// $fffe ; System Model ID

#include "rombios.h"

#define BX_CPU           0

   /* model byte 0xFC = AT */
#define SYS_MODEL_ID     0xFC

#ifndef BIOS_BUILD_DATE
#  define BIOS_BUILD_DATE "06/23/99"
#endif

  // 1K of base memory used for Extended Bios Data Area (EBDA)
  // EBDA is used for PS/2 mouse support, and IDE BIOS, etc.
#define EBDA_SEG           0x9FC0
#define EBDA_SIZE          1              // In KiB
#define BASE_MEM_IN_K   (640 - EBDA_SIZE)

/* 256 bytes at 0x9ff00 -- 0x9ffff is used for the IPL boot table. */
#define IPL_SEG              0x9ff0
#define IPL_TABLE_OFFSET     0x0000
#define IPL_TABLE_ENTRIES    8
#define IPL_COUNT_OFFSET     0x0080  /* u16: number of valid table entries */
#define IPL_SEQUENCE_OFFSET  0x0082  /* u16: next boot device */
#define IPL_BOOTFIRST_OFFSET 0x0084  /* u16: user selected device */
#define IPL_SIZE             0xff
#define IPL_TYPE_FLOPPY      0x01
#define IPL_TYPE_HARDDISK    0x02
#define IPL_TYPE_CDROM       0x03
#define IPL_TYPE_BEV         0x80

// This is for compiling with gcc2 and gcc3
#define ASM_START #asm
#define ASM_END #endasm

ASM_START
.rom

.org 0x0000

use16 8086

MACRO SET_INT_VECTOR
  mov ax, ?3
  mov ?1*4, ax
  mov ax, ?2
  mov ?1*4+2, ax
MEND

ASM_END

typedef unsigned char  Bit8u;
typedef unsigned short Bit16u;
typedef unsigned short bx_bool;
typedef unsigned long  Bit32u;


  void memsetb(seg,offset,value,count);
  void memcpyb(dseg,doffset,sseg,soffset,count);
  void memcpyd(dseg,doffset,sseg,soffset,count);

  // memset of count bytes
    void
  memsetb(seg,offset,value,count)
    Bit16u seg;
    Bit16u offset;
    Bit16u value;
    Bit16u count;
  {
  ASM_START
    push bp
    mov  bp, sp

      push ax
      push cx
      push es
      push di

      mov  cx, 10[bp] ; count
      test cx, cx
      je   memsetb_end
      mov  ax, 4[bp] ; segment
      mov  es, ax
      mov  ax, 6[bp] ; offset
      mov  di, ax
      mov  al, 8[bp] ; value
      cld
      rep
       stosb

  memsetb_end:
      pop di
      pop es
      pop cx
      pop ax

    pop bp
  ASM_END
  }

  // memcpy of count bytes
    void
  memcpyb(dseg,doffset,sseg,soffset,count)
    Bit16u dseg;
    Bit16u doffset;
    Bit16u sseg;
    Bit16u soffset;
    Bit16u count;
  {
  ASM_START
    push bp
    mov  bp, sp

      push ax
      push cx
      push es
      push di
      push ds
      push si

      mov  cx, 12[bp] ; count
      test cx, cx
      je   memcpyb_end
      mov  ax, 4[bp] ; dsegment
      mov  es, ax
      mov  ax, 6[bp] ; doffset
      mov  di, ax
      mov  ax, 8[bp] ; ssegment
      mov  ds, ax
      mov  ax, 10[bp] ; soffset
      mov  si, ax
      cld
      rep
       movsb

  memcpyb_end:
      pop si
      pop ds
      pop di
      pop es
      pop cx
      pop ax

    pop bp
  ASM_END
  }

  // Bit32u (unsigned long) and long helper functions
  ASM_START

  idiv_u:
    xor dx,dx
    div bx
    ret

  ldivul:
    mov     cx,[di]
    mov     di,2[di]
    call    ludivmod
    xchg    ax,cx
    xchg    bx,di
    ret

.align 2
ldivmod:
    mov     dx,di           ; sign byte of b in dh
    mov     dl,bh           ; sign byte of a in dl
    test    di,di
    jns     set_asign
    neg     di
    neg     cx
    sbb     di,*0
set_asign:
    test    bx,bx
    jns     got_signs       ; leave r = a positive
    neg     bx
    neg     ax
    sbb     bx,*0
    j       got_signs

.align 2
ludivmod:
    xor     dx,dx           ; both sign bytes 0
got_signs:
    push    bp
    push    si
    mov     bp,sp
    push    di              ; remember b
    push    cx
b0  =       -4
b16 =       -2

    test    di,di
    jne     divlarge
    test    cx,cx
    je      divzero
    cmp     bx,cx
    jae     divlarge        ; would overflow
    xchg    dx,bx           ; a in dx:ax, signs in bx
    div     cx
    xchg    cx,ax           ; q in di:cx, junk in ax
    xchg    ax,bx           ; signs in ax, junk in bx
    xchg    ax,dx           ; r in ax, signs back in dx
    mov     bx,di           ; r in bx:ax
    j       zdivu1

divzero:                        ; return q = 0 and r = a
    test    dl,dl
    jns     return
    j       negr            ; a initially minus, restore it

divlarge:
    push    dx              ; remember sign bytes
    mov     si,di           ; w in si:dx, initially b from di:cx
    mov     dx,cx
    xor     cx,cx           ; q in di:cx, initially 0
    mov     di,cx
                            ; r in bx:ax, initially a
                            ; use di:cx rather than dx:cx in order
                            ; to have dx free for a byte pair later
    cmp     si,bx
    jb      loop1
    ja      zdivu           ; finished if b > r
    cmp     dx,ax
    ja      zdivu

; rotate w (= b) to greatest dyadic multiple of b <= r

loop1:
    shl     dx,*1           ; w = 2*w
    rcl     si,*1
    jc      loop1_exit      ; w was > r counting overflow (unsigned)
    cmp     si,bx           ; while w <= r (unsigned)
    jb      loop1
    ja      loop1_exit
    cmp     dx,ax
    jbe     loop1           ; else exit with carry clear for rcr
loop1_exit:
    rcr     si,*1
    rcr     dx,*1
loop2:
    shl     cx,*1           ; q = 2*q
    rcl     di,*1
    cmp     si,bx           ; if w <= r
    jb      loop2_over
    ja      loop2_test
    cmp     dx,ax
    ja      loop2_test
loop2_over:
    add     cx,*1           ; q++
    adc     di,*0
    sub     ax,dx           ; r = r-w
    sbb     bx,si
loop2_test:
    shr     si,*1           ; w = w/2
    rcr     dx,*1
    cmp     si,b16[bp]      ; while w >= b
    ja      loop2
    jb      zdivu
    cmp     dx,b0[bp]
    jae     loop2

zdivu:
    pop     dx              ; sign bytes
zdivu1:
    test    dh,dh
    js      zbminus
    test    dl,dl
    jns     return          ; else a initially minus, b plus
    mov     dx,ax           ; -a = b * q + r ==> a = b * (-q) + (-r)
    or      dx,bx
    je      negq            ; use if r = 0
    sub     ax,b0[bp]       ; use a = b * (-1 - q) + (b - r)
    sbb     bx,b16[bp]
    not     cx              ; q = -1 - q (same as complement)
    not     di
negr:
    neg     bx
    neg     ax
    sbb     bx,*0
return:
    mov     sp,bp
    pop     si
    pop     bp
    ret

.align 2
zbminus:
    test    dl,dl           ; (-a) = (-b) * q + r ==> a = b * q + (-r)
    js      negr            ; use if initial a was minus
    mov     dx,ax           ; a = (-b) * q + r ==> a = b * (-q) + r
    or      dx,bx
    je      negq            ; use if r = 0
    sub     ax,b0[bp]       ; use a = b * (-1 - q) + (b + r)
                                ; (b is now -b)
    sbb     bx,b16[bp]
    not     cx
    not     di
    mov     sp,bp
    pop     si
    pop     bp
    ret

.align 2
negq:
    neg     di
    neg     cx
    sbb     di,*0
    mov     sp,bp
    pop     si
    pop     bp
    ret

.align 2
ltstl:
ltstul:
    test    bx,bx
    je      ltst_not_sure
    ret

.align 2
ltst_not_sure:
    test    ax,ax
    js      ltst_fix_sign
    ret

.align 2
ltst_fix_sign:
    inc     bx
    ret

.align 2
lmull:
lmulul:
    mov     cx,ax
    mul     word ptr 2[di]
    xchg    ax,bx
    mul     word ptr [di]
    add     bx,ax
    mov     ax,ptr [di]
    mul     cx
    add     bx,dx
    ret

.align 2
lsubl:
lsubul:
    sub     ax,[di]
    sbb     bx,2[di]
    ret

.align 2
laddl:
laddul:
    add     ax,[di]
    adc     bx,2[di]
    ret

.align 2
lorl:
lorul:
    or      ax,[di]
    or      bx,2[di]
    ret

.align 2
lsrul:
    mov     cx,di
    jcxz    lsru_exit
    cmp     cx,*32
    jae     lsru_zero
lsru_loop:
    shr     bx,*1
    rcr     ax,*1
    loop    lsru_loop
lsru_exit:
    ret

.align 2
lsru_zero:
    xor     ax,ax
    mov     bx,ax
    ret

.align 2
landl:
landul:
    and     ax,[di]
    and     bx,2[di]
    ret

.align 2
lcmpl:
lcmpul:
    sub     bx,2[di]
    je      lcmp_not_sure
    ret

.align 2
lcmp_not_sure:
    cmp     ax,[di]
    jb      lcmp_b_and_lt
    jge     lcmp_exit

    inc     bx
lcmp_exit:
    ret

.align 2
lcmp_b_and_lt:
    dec     bx
    ret

lincl:
lincul:
    inc     word ptr [bx]
    je      LINC_HIGH_WORD
    ret
    .even
LINC_HIGH_WORD:
    inc     word ptr 2[bx]
    ret

  ASM_END

// for access to RAM area which is used by interrupt vectors
// and BIOS Data Area

typedef struct {
  unsigned char filler1[0x400];
  unsigned char filler2[0x6c];
  Bit16u ticks_low;
  Bit16u ticks_high;
  Bit8u  midnight_flag;
  } bios_data_t;

#define BiosData ((bios_data_t  *) 0)

typedef struct {
  union {
    struct {
      Bit16u di, si, bp, sp;
      Bit16u bx, dx, cx, ax;
      } r16;
    struct {
      Bit16u filler[4];
      Bit8u  bl, bh, dl, dh, cl, ch, al, ah;
      } r8;
    } u;
  } pusha_regs_t;

typedef struct {
  union {
    struct {
      Bit16u flags;
      } r16;
    struct {
      Bit8u  flagsl;
      Bit8u  flagsh;
      } r8;
    } u;
  } flags_t;

#define SetCF(x)   x.u.r8.flagsl |= 0x01
#define SetZF(x)   x.u.r8.flagsl |= 0x40
#define ClearCF(x) x.u.r8.flagsl &= 0xfe
#define ClearZF(x) x.u.r8.flagsl &= 0xbf
#define GetCF(x)   (x.u.r8.flagsl & 0x01)

typedef struct {
  Bit16u ip;
  Bit16u cs;
  flags_t flags;
  } iret_addr_t;

typedef struct {
  Bit16u type;
  Bit16u flags;
  Bit32u vector;
  Bit32u description;
  Bit32u reserved;
  } ipl_entry_t;

static Bit16u         inw();
static void           outw();

static Bit8u          read_byte();
static Bit16u         read_word();
static void           write_byte();
static void           write_word();
static void           bios_printf();

static void           int09_function();
static void           int13_harddisk();
static void           transf_sect();
static void           int13_diskette_function();
static void           int16_function();
static void           int19_function();
static void           int1a_function();
static Bit16u         get_CS();
static Bit16u         get_SS();
static unsigned int   enqueue_key();
static unsigned int   dequeue_key();
static void           set_diskette_ret_status();
static void           set_diskette_current_cyl();

static void           print_bios_banner();
static void           print_boot_device();
static void           print_boot_failure();

#if DEBUG_INT16
#  define BX_DEBUG_INT16(a...) BX_DEBUG(a)
#else
#  define BX_DEBUG_INT16(a...)
#endif

#define SET_AL(val8) AX = ((AX & 0xff00) | (val8))
#define SET_BL(val8) BX = ((BX & 0xff00) | (val8))
#define SET_CL(val8) CX = ((CX & 0xff00) | (val8))
#define SET_DL(val8) DX = ((DX & 0xff00) | (val8))
#define SET_AH(val8) AX = ((AX & 0x00ff) | ((val8) << 8))
#define SET_BH(val8) BX = ((BX & 0x00ff) | ((val8) << 8))
#define SET_CH(val8) CX = ((CX & 0x00ff) | ((val8) << 8))
#define SET_DH(val8) DX = ((DX & 0x00ff) | ((val8) << 8))

#define GET_AL() ( AX & 0x00ff )
#define GET_BL() ( BX & 0x00ff )
#define GET_CL() ( CX & 0x00ff )
#define GET_DL() ( DX & 0x00ff )
#define GET_AH() ( AX >> 8 )
#define GET_BH() ( BX >> 8 )
#define GET_CH() ( CX >> 8 )
#define GET_DH() ( DX >> 8 )

#define GET_ELDL() ( ELDX & 0x00ff )
#define GET_ELDH() ( ELDX >> 8 )

#define SET_CF()     FLAGS |= 0x0001
#define CLEAR_CF()   FLAGS &= 0xfffe
#define GET_CF()     (FLAGS & 0x0001)

#define SET_ZF()     FLAGS |= 0x0040
#define CLEAR_ZF()   FLAGS &= 0xffbf
#define GET_ZF()     (FLAGS & 0x0040)

#define UNSUPPORTED_FUNCTION 0x86

#define none 0
#define MAX_SCAN_CODE 0x58

static struct {
  Bit16u normal;
  Bit16u shift;
  Bit16u control;
  Bit16u alt;
  Bit8u lock_flags;
  } scan_to_scanascii[MAX_SCAN_CODE + 1] = {
      {   none,   none,   none,   none, none },
      { 0x011b, 0x011b, 0x011b, 0x0100, none }, /* escape */
      { 0x0231, 0x0221,   none, 0x7800, none }, /* 1! */
      { 0x0332, 0x0340, 0x0300, 0x7900, none }, /* 2@ */
      { 0x0433, 0x0423,   none, 0x7a00, none }, /* 3# */
      { 0x0534, 0x0524,   none, 0x7b00, none }, /* 4$ */
      { 0x0635, 0x0625,   none, 0x7c00, none }, /* 5% */
      { 0x0736, 0x075e, 0x071e, 0x7d00, none }, /* 6^ */
      { 0x0837, 0x0826,   none, 0x7e00, none }, /* 7& */
      { 0x0938, 0x092a,   none, 0x7f00, none }, /* 8* */
      { 0x0a39, 0x0a28,   none, 0x8000, none }, /* 9( */
      { 0x0b30, 0x0b29,   none, 0x8100, none }, /* 0) */
      { 0x0c2d, 0x0c5f, 0x0c1f, 0x8200, none }, /* -_ */
      { 0x0d3d, 0x0d2b,   none, 0x8300, none }, /* =+ */
      { 0x0e08, 0x0e08, 0x0e7f,   none, none }, /* backspace */
      { 0x0f09, 0x0f00,   none,   none, none }, /* tab */
      { 0x1071, 0x1051, 0x1011, 0x1000, 0x40 }, /* Q */
      { 0x1177, 0x1157, 0x1117, 0x1100, 0x40 }, /* W */
      { 0x1265, 0x1245, 0x1205, 0x1200, 0x40 }, /* E */
      { 0x1372, 0x1352, 0x1312, 0x1300, 0x40 }, /* R */
      { 0x1474, 0x1454, 0x1414, 0x1400, 0x40 }, /* T */
      { 0x1579, 0x1559, 0x1519, 0x1500, 0x40 }, /* Y */
      { 0x1675, 0x1655, 0x1615, 0x1600, 0x40 }, /* U */
      { 0x1769, 0x1749, 0x1709, 0x1700, 0x40 }, /* I */
      { 0x186f, 0x184f, 0x180f, 0x1800, 0x40 }, /* O */
      { 0x1970, 0x1950, 0x1910, 0x1900, 0x40 }, /* P */
      { 0x1a5b, 0x1a7b, 0x1a1b,   none, none }, /* [{ */
      { 0x1b5d, 0x1b7d, 0x1b1d,   none, none }, /* ]} */
      { 0x1c0d, 0x1c0d, 0x1c0a,   none, none }, /* Enter */
      {   none,   none,   none,   none, none }, /* L Ctrl */
      { 0x1e61, 0x1e41, 0x1e01, 0x1e00, 0x40 }, /* A */
      { 0x1f73, 0x1f53, 0x1f13, 0x1f00, 0x40 }, /* S */
      { 0x2064, 0x2044, 0x2004, 0x2000, 0x40 }, /* D */
      { 0x2166, 0x2146, 0x2106, 0x2100, 0x40 }, /* F */
      { 0x2267, 0x2247, 0x2207, 0x2200, 0x40 }, /* G */
      { 0x2368, 0x2348, 0x2308, 0x2300, 0x40 }, /* H */
      { 0x246a, 0x244a, 0x240a, 0x2400, 0x40 }, /* J */
      { 0x256b, 0x254b, 0x250b, 0x2500, 0x40 }, /* K */
      { 0x266c, 0x264c, 0x260c, 0x2600, 0x40 }, /* L */
      { 0x273b, 0x273a,   none,   none, none }, /* ;: */
      { 0x2827, 0x2822,   none,   none, none }, /* '" */
      { 0x2960, 0x297e,   none,   none, none }, /* `~ */
      {   none,   none,   none,   none, none }, /* L shift */
      { 0x2b5c, 0x2b7c, 0x2b1c,   none, none }, /* |\ */
      { 0x2c7a, 0x2c5a, 0x2c1a, 0x2c00, 0x40 }, /* Z */
      { 0x2d78, 0x2d58, 0x2d18, 0x2d00, 0x40 }, /* X */
      { 0x2e63, 0x2e43, 0x2e03, 0x2e00, 0x40 }, /* C */
      { 0x2f76, 0x2f56, 0x2f16, 0x2f00, 0x40 }, /* V */
      { 0x3062, 0x3042, 0x3002, 0x3000, 0x40 }, /* B */
      { 0x316e, 0x314e, 0x310e, 0x3100, 0x40 }, /* N */
      { 0x326d, 0x324d, 0x320d, 0x3200, 0x40 }, /* M */
      { 0x332c, 0x333c,   none,   none, none }, /* ,< */
      { 0x342e, 0x343e,   none,   none, none }, /* .> */
      { 0x352f, 0x353f,   none,   none, none }, /* /? */
      {   none,   none,   none,   none, none }, /* R Shift */
      { 0x372a, 0x372a,   none,   none, none }, /* * */
      {   none,   none,   none,   none, none }, /* L Alt */
      { 0x3920, 0x3920, 0x3920, 0x3920, none }, /* space */
      {   none,   none,   none,   none, none }, /* caps lock */
      { 0x3b00, 0x5400, 0x5e00, 0x6800, none }, /* F1 */
      { 0x3c00, 0x5500, 0x5f00, 0x6900, none }, /* F2 */
      { 0x3d00, 0x5600, 0x6000, 0x6a00, none }, /* F3 */
      { 0x3e00, 0x5700, 0x6100, 0x6b00, none }, /* F4 */
      { 0x3f00, 0x5800, 0x6200, 0x6c00, none }, /* F5 */
      { 0x4000, 0x5900, 0x6300, 0x6d00, none }, /* F6 */
      { 0x4100, 0x5a00, 0x6400, 0x6e00, none }, /* F7 */
      { 0x4200, 0x5b00, 0x6500, 0x6f00, none }, /* F8 */
      { 0x4300, 0x5c00, 0x6600, 0x7000, none }, /* F9 */
      { 0x4400, 0x5d00, 0x6700, 0x7100, none }, /* F10 */
      {   none,   none,   none,   none, none }, /* Num Lock */
      {   none,   none,   none,   none, none }, /* Scroll Lock */
      { 0x4700, 0x4737, 0x7700,   none, 0x20 }, /* 7 Home */
      { 0x4800, 0x4838,   none,   none, 0x20 }, /* 8 UP */
      { 0x4900, 0x4939, 0x8400,   none, 0x20 }, /* 9 PgUp */
      { 0x4a2d, 0x4a2d,   none,   none, none }, /* - */
      { 0x4b00, 0x4b34, 0x7300,   none, 0x20 }, /* 4 Left */
      { 0x4c00, 0x4c35,   none,   none, 0x20 }, /* 5 */
      { 0x4d00, 0x4d36, 0x7400,   none, 0x20 }, /* 6 Right */
      { 0x4e2b, 0x4e2b,   none,   none, none }, /* + */
      { 0x4f00, 0x4f31, 0x7500,   none, 0x20 }, /* 1 End */
      { 0x5000, 0x5032,   none,   none, 0x20 }, /* 2 Down */
      { 0x5100, 0x5133, 0x7600,   none, 0x20 }, /* 3 PgDn */
      { 0x5200, 0x5230,   none,   none, 0x20 }, /* 0 Ins */
      { 0x5300, 0x532e,   none,   none, 0x20 }, /* Del */
      {   none,   none,   none,   none, none },
      {   none,   none,   none,   none, none },
      { 0x565c, 0x567c,   none,   none, none }, /* \| */
      { 0x5700, 0x5700,   none,   none, none }, /* F11 */
      { 0x5800, 0x5800,   none,   none, none }  /* F12 */
      };

  Bit16u
inw(port)
  Bit16u port;
{
ASM_START
  push bp
  mov  bp, sp

    push dx
    mov  dx, 4[bp]
    in   ax, dx
    pop  dx

  pop  bp
ASM_END
}

  void
outw(port, val)
  Bit16u port;
  Bit16u  val;
{
ASM_START
  push bp
  mov  bp, sp

    push ax
    push dx
    mov  dx, 4[bp]
    mov  ax, 6[bp]
    out  dx, ax
    pop  dx
    pop  ax

  pop  bp
ASM_END
}

  Bit8u
read_byte(seg, offset)
  Bit16u seg;
  Bit16u offset;
{
ASM_START
  push bp
  mov  bp, sp

    push bx
    push ds
    mov  ax, 4[bp] ; segment
    mov  ds, ax
    mov  bx, 6[bp] ; offset
    mov  al, [bx]
    ;; al = return value (byte)
    pop  ds
    pop  bx

  pop  bp
ASM_END
}

  Bit16u
read_word(seg, offset)
  Bit16u seg;
  Bit16u offset;
{
ASM_START
  push bp
  mov  bp, sp

    push bx
    push ds
    mov  ax, 4[bp] ; segment
    mov  ds, ax
    mov  bx, 6[bp] ; offset
    mov  ax, [bx]
    ;; ax = return value (word)
    pop  ds
    pop  bx

  pop  bp
ASM_END
}

  void
write_byte(seg, offset, data)
  Bit16u seg;
  Bit16u offset;
  Bit8u data;
{
ASM_START
  push bp
  mov  bp, sp

    push ax
    push bx
    push ds
    mov  ax, 4[bp] ; segment
    mov  ds, ax
    mov  bx, 6[bp] ; offset
    mov  al, 8[bp] ; data byte
    mov  [bx], al  ; write data byte
    pop  ds
    pop  bx
    pop  ax

  pop  bp
ASM_END
}

  void
write_word(seg, offset, data)
  Bit16u seg;
  Bit16u offset;
  Bit16u data;
{
ASM_START
  push bp
  mov  bp, sp

    push ax
    push bx
    push ds
    mov  ax, 4[bp] ; segment
    mov  ds, ax
    mov  bx, 6[bp] ; offset
    mov  ax, 8[bp] ; data word
    mov  [bx], ax  ; write data word
    pop  ds
    pop  bx
    pop  ax

  pop  bp
ASM_END
}

  Bit16u
get_CS()
{
ASM_START
  mov  ax, cs
ASM_END
}

  Bit16u
get_SS()
{
ASM_START
  mov  ax, ss
ASM_END
}

  void
wrch(c)
  Bit8u  c;
{
  ASM_START
  push bp
  mov  bp, sp

  push bx
  mov  ah, #0x0e
  mov  al, 4[bp]
  xor  bx,bx
  int  #0x10
  pop  bx

  pop  bp
  ASM_END
}

  void
send(action, c)
  Bit16u action;
  Bit8u  c;
{
  if (action & BIOS_PRINTF_SCREEN) {
    if (c == '\n') wrch('\r');
    wrch(c);
  }
}

  void
put_int(action, val, width, neg)
  Bit16u action;
  short val, width;
  bx_bool neg;
{
  short nval = val / 10;
  if (nval)
    put_int(action, nval, width - 1, neg);
  else {
    while (--width > 0) send(action, ' ');
    if (neg) send(action, '-');
  }
  send(action, val - (nval * 10) + '0');
}

  void
put_uint(action, val, width, neg)
  Bit16u action;
  unsigned short val;
  short width;
  bx_bool neg;
{
  unsigned short nval = val / 10;
  if (nval)
    put_uint(action, nval, width - 1, neg);
  else {
    while (--width > 0) send(action, ' ');
    if (neg) send(action, '-');
  }
  send(action, val - (nval * 10) + '0');
}

  void
put_luint(action, val, width, neg)
  Bit16u action;
  unsigned long val;
  short width;
  bx_bool neg;
{
  unsigned long nval = val / 10;
  if (nval)
    put_luint(action, nval, width - 1, neg);
  else {
    while (--width > 0) send(action, ' ');
    if (neg) send(action, '-');
  }
  send(action, val - (nval * 10) + '0');
}

void put_str(action, segment, offset)
  Bit16u action;
  Bit16u segment;
  Bit16u offset;
{
  Bit8u c;

  while (c = read_byte(segment, offset)) {
    send(action, c);
    offset++;
  }
}

//--------------------------------------------------------------------------
// bios_printf()
//   A compact variable argument printf function.
//
//   Supports %[format_width][length]format
//   where format can be x,X,u,d,s,S,c
//   and the optional length modifier is l (ell)
//--------------------------------------------------------------------------
  void
bios_printf(action, s)
  Bit16u action;
  Bit8u *s;
{
  Bit8u c, format_char;
  bx_bool  in_format;
  short i;
  Bit16u  *arg_ptr;
  Bit16u   arg_seg, arg, nibble, hibyte, shift_count, format_width, hexadd;

  arg_ptr = &s;
  arg_seg = get_SS();

  in_format = 0;
  format_width = 0;

  if ((action & BIOS_PRINTF_DEBHALT) == BIOS_PRINTF_DEBHALT)
    bios_printf (BIOS_PRINTF_SCREEN, "FATAL: ");

  while (c = read_byte(get_CS(), s)) {
    if ( c == '%' ) {
      in_format = 1;
      format_width = 0;
      }
    else if (in_format) {
      if ( (c>='0') && (c<='9') ) {
        format_width = (format_width * 10) + (c - '0');
        }
      else {
        arg_ptr++; // increment to next arg
        arg = read_word(arg_seg, arg_ptr);
        if (c == 'x' || c == 'X') {
          if (format_width == 0)
            format_width = 4;
          if (c == 'x')
            hexadd = 'a';
          else
            hexadd = 'A';
          for (i=format_width-1; i>=0; i--) {
            nibble = (arg >> (4 * i)) & 0x000f;
            send (action, (nibble<=9)? (nibble+'0') : (nibble-10+hexadd));
            }
          }
        else if (c == 'u') {
          put_uint(action, arg, format_width, 0);
          }
        else if (c == 'l') {
          s++;
          c = read_byte(get_CS(), s); /* is it ld,lx,lu? */
          arg_ptr++; /* increment to next arg */
          hibyte = read_word(arg_seg, arg_ptr);
          if (c == 'd') {
            if (hibyte & 0x8000)
              put_luint(action, 0L-(((Bit32u) hibyte << 16) | arg), format_width-1, 1);
            else
              put_luint(action, ((Bit32u) hibyte << 16) | arg, format_width, 0);
           }
          else if (c == 'u') {
            put_luint(action, ((Bit32u) hibyte << 16) | arg, format_width, 0);
           }
          else if (c == 'x' || c == 'X')
           {
            if (format_width == 0)
              format_width = 8;
            if (c == 'x')
              hexadd = 'a';
            else
              hexadd = 'A';
            for (i=format_width-1; i>=0; i--) {
              nibble = ((((Bit32u) hibyte <<16) | arg) >> (4 * i)) & 0x000f;
              send (action, (nibble<=9)? (nibble+'0') : (nibble-10+hexadd));
              }
           }
          }
        else if (c == 'd') {
          if (arg & 0x8000)
            put_int(action, -arg, format_width - 1, 1);
          else
            put_int(action, arg, format_width, 0);
          }
        else if (c == 's') {
          put_str(action, get_CS(), arg);
          }
        else if (c == 'S') {
          hibyte = arg;
          arg_ptr++;
          arg = read_word(arg_seg, arg_ptr);
          put_str(action, hibyte, arg);
          }
        else if (c == 'c') {
          send(action, arg);
          }
        else
          BX_PANIC("bios_printf: unknown format\n");
          in_format = 0;
        }
      }
    else {
      send(action, c);
      }
    s ++;
    }

  if (action & BIOS_PRINTF_HALT) {
    // freeze in a busy loop.
ASM_START
    cli
 halt2_loop:
    hlt
    jmp halt2_loop
ASM_END
    }
}

static char bios_svn_version_string[] = "$Version: 0.4.3 $ $Date: Tue, 10 Mar 2009 21:02:08 +0100 $";

#define BIOS_COPYRIGHT_STRING "(c) 2009 Zeus Gomez Marmolejo and (c) 2002 MandrakeSoft S.A."

//--------------------------------------------------------------------------
// print_bios_banner
//   displays a the bios version
//--------------------------------------------------------------------------
void
print_bios_banner()
{
  printf("Zet ROMBIOS - build: %s\n%s\n\n",
    BIOS_BUILD_DATE, bios_svn_version_string);
}

//--------------------------------------------------------------------------
// BIOS Boot Specification 1.0.1 compatibility
//
// Very basic support for the BIOS Boot Specification, which allows expansion
// ROMs to register themselves as boot devices, instead of just stealing the
// INT 19h boot vector.
//
// This is a hack: to do it properly requires a proper PnP BIOS and we aren't
// one; we just lie to the option ROMs to make them behave correctly.
// We also don't support letting option ROMs register as bootable disk
// drives (BCVs), only as bootable devices (BEVs).
//
// http://www.phoenix.com/en/Customer+Services/White+Papers-Specs/pc+industry+specifications.htm
//--------------------------------------------------------------------------

static char drivetypes[][20]={"", "Floppy flash image", "Compact Flash" };

static void
init_boot_vectors()
{
  ipl_entry_t e;
  Bit16u count = 0;
  Bit16u ss = get_SS();

  /* Clear out the IPL table. */
  memsetb(IPL_SEG, IPL_TABLE_OFFSET, 0, IPL_SIZE);

  /* User selected device not set */
  write_word(IPL_SEG, IPL_BOOTFIRST_OFFSET, 0xFFFF);

  /* Floppy drive */
  e.type = IPL_TYPE_FLOPPY; e.flags = 0; e.vector = 0; e.description = 0; e.reserved = 0;
  memcpyb(IPL_SEG, IPL_TABLE_OFFSET + count * sizeof (e), ss, &e, sizeof (e));
  count++;

  /* First HDD */
  e.type = IPL_TYPE_HARDDISK; e.flags = 0; e.vector = 0; e.description = 0; e.reserved = 0;
  memcpyb(IPL_SEG, IPL_TABLE_OFFSET + count * sizeof (e), ss, &e, sizeof (e));
  count++;

  /* Remember how many devices we have */
  write_word(IPL_SEG, IPL_COUNT_OFFSET, count);
  /* Not tried booting anything yet */
  write_word(IPL_SEG, IPL_SEQUENCE_OFFSET, 0xffff);
}

static Bit8u
get_boot_vector(i, e)
Bit16u i; ipl_entry_t *e;
{
  Bit16u count;
  Bit16u ss = get_SS();
  /* Get the count of boot devices, and refuse to overrun the array */
  count = read_word(IPL_SEG, IPL_COUNT_OFFSET);
  if (i >= count) return 0;
  /* OK to read this device */
  memcpyb(ss, e, IPL_SEG, IPL_TABLE_OFFSET + i * sizeof (*e), sizeof (*e));
  return 1;
}

//--------------------------------------------------------------------------
// print_boot_device
//   displays the boot device
//--------------------------------------------------------------------------

void
print_boot_device(e)
  ipl_entry_t *e;
{
  Bit16u type;
  char description[33];
  Bit16u ss = get_SS();
  type = e->type;
  /* NIC appears as type 0x80 */
  if (type == IPL_TYPE_BEV) type = 0x4;
  if (type == 0 || type > 0x4) BX_PANIC("Bad drive type\n");
  printf("Booting from %s", drivetypes[type]);
  /* print product string if BEV */
  if (type == 4 && e->description != 0) {
    /* first 32 bytes are significant */
    memcpyb(ss, &description, (Bit16u)(e->description >> 16), (Bit16u)(e->description & 0xffff), 32);
    /* terminate string */
    description[32] = 0;
    printf(" [%S]", ss, description);
  }
  printf("...\n\n");
}

//--------------------------------------------------------------------------
// print_boot_failure
//   displays the reason why boot failed
//--------------------------------------------------------------------------
  void
print_boot_failure(type, reason)
  Bit16u type; Bit8u reason;
{
  if (type == 0 || type > 0x3) BX_PANIC("Bad drive type\n");

  printf("Boot failed");
  if (type < 4) {
    /* Report the reason too */
    if (reason==0)
      printf(": not a bootable disk");
    else
      printf(": could not read the boot disk");
  }
  printf("\n\n");
}


  void
int16_function(DI, SI, BP, SP, BX, DX, CX, AX, FLAGS)
  Bit16u DI, SI, BP, SP, BX, DX, CX, AX, FLAGS;
{
  Bit8u scan_code, ascii_code, shift_flags, led_flags, count;
  Bit16u kbd_code, max;

  shift_flags = read_byte(0x0040, 0x17);
  led_flags = read_byte(0x0040, 0x97);

  switch (GET_AH()) {
    case 0x00: /* read keyboard input */

      if ( !dequeue_key(&scan_code, &ascii_code, 1) ) {
        BX_PANIC("KBD: int16h: out of keyboard input\n");
        }
      if (scan_code !=0 && ascii_code == 0xF0) ascii_code = 0;
      else if (ascii_code == 0xE0) ascii_code = 0;
      AX = (scan_code << 8) | ascii_code;
      break;

    case 0x01: /* check keyboard status */
      if ( !dequeue_key(&scan_code, &ascii_code, 0) ) {
        SET_ZF();
        return;
        }
      if (scan_code !=0 && ascii_code == 0xF0) ascii_code = 0;
      else if (ascii_code == 0xE0) ascii_code = 0;
      AX = (scan_code << 8) | ascii_code;
      CLEAR_ZF();
      break;

    case 0x02: /* get shift flag status */
      shift_flags = read_byte(0x0040, 0x17);
      SET_AL(shift_flags);
      break;

    case 0x05: /* store key-stroke into buffer */
      if ( !enqueue_key(GET_CH(), GET_CL()) ) {
        SET_AL(1);
        }
      else {
        SET_AL(0);
        }
      break;

    case 0x09: /* GET KEYBOARD FUNCTIONALITY */
      // bit Bochs Description
      //  7    0   reserved
      //  6    0   INT 16/AH=20h-22h supported (122-key keyboard support)
      //  5    1   INT 16/AH=10h-12h supported (enhanced keyboard support)
      //  4    1   INT 16/AH=0Ah supported
      //  3    0   INT 16/AX=0306h supported
      //  2    0   INT 16/AX=0305h supported
      //  1    0   INT 16/AX=0304h supported
      //  0    0   INT 16/AX=0300h supported
      //
      SET_AL(0x30);
      break;

    case 0x10: /* read MF-II keyboard input */

      if ( !dequeue_key(&scan_code, &ascii_code, 1) ) {
        BX_PANIC("KBD: int16h: out of keyboard input\n");
        }
      if (scan_code !=0 && ascii_code == 0xF0) ascii_code = 0;
      AX = (scan_code << 8) | ascii_code;
      break;

    case 0x11: /* check MF-II keyboard status */
      if ( !dequeue_key(&scan_code, &ascii_code, 0) ) {
        SET_ZF();
        return;
        }
      if (scan_code !=0 && ascii_code == 0xF0) ascii_code = 0;
      AX = (scan_code << 8) | ascii_code;
      CLEAR_ZF();
      break;

    case 0x12: /* get extended keyboard status */
      shift_flags = read_byte(0x0040, 0x17);
      SET_AL(shift_flags);
      shift_flags = read_byte(0x0040, 0x18) & 0x73;
      shift_flags |= read_byte(0x0040, 0x96) & 0x0c;
      SET_AH(shift_flags);
      BX_DEBUG_INT16("int16: func 12 sending %04x\n",AX);
      break;

    case 0x92: /* keyboard capability check called by DOS 5.0+ keyb */
      SET_AH(0x80); // function int16 ah=0x10-0x12 supported
      break;

    case 0xA2: /* 122 keys capability check called by DOS 5.0+ keyb */
      // don't change AH : function int16 ah=0x20-0x22 NOT supported
      break;

    case 0x6F:
      if (GET_AL() == 0x08)
        SET_AH(0x02); // unsupported, aka normal keyboard

    default:
      BX_INFO("KBD: unsupported int 16h function %02x\n", GET_AH());
    }
}

  unsigned int
dequeue_key(scan_code, ascii_code, incr)
  Bit8u *scan_code;
  Bit8u *ascii_code;
  unsigned int incr;
{
  Bit16u buffer_start, buffer_end, buffer_head, buffer_tail;
  Bit16u ss;
  Bit8u  acode, scode;

#if BX_CPU < 2
  buffer_start = 0x001E;
  buffer_end   = 0x003E;
#else
  buffer_start = read_word(0x0040, 0x0080);
  buffer_end   = read_word(0x0040, 0x0082);
#endif

  buffer_head = read_word(0x0040, 0x001a);
  buffer_tail = read_word(0x0040, 0x001c);

  if (buffer_head != buffer_tail) {
    ss = get_SS();
    acode = read_byte(0x0040, buffer_head);
    scode = read_byte(0x0040, buffer_head+1);
    write_byte(ss, ascii_code, acode);
    write_byte(ss, scan_code, scode);

    if (incr) {
      buffer_head += 2;
      if (buffer_head >= buffer_end)
        buffer_head = buffer_start;
      write_word(0x0040, 0x001a, buffer_head);
      }
    return(1);
    }
  else {
    return(0);
    }
}

  void
int09_function(DI, SI, BP, SP, BX, DX, CX, AX)
  Bit16u DI, SI, BP, SP, BX, DX, CX, AX;
{
  Bit8u scancode, asciicode, shift_flags;
  Bit8u mf2_flags, mf2_state;

  //
  // DS has been set to F000 before call
  //


  scancode = GET_AL();

  if (scancode == 0) {
    BX_INFO("KBD: int09 handler: AL=0\n");
    return;
    }


  shift_flags = read_byte(0x0040, 0x17);
  mf2_flags = read_byte(0x0040, 0x18);
  mf2_state = read_byte(0x0040, 0x96);
  asciicode = 0;

  switch (scancode) {
    case 0x3a: /* Caps Lock press */
      shift_flags ^= 0x40;
      write_byte(0x0040, 0x17, shift_flags);
      mf2_flags |= 0x40;
      write_byte(0x0040, 0x18, mf2_flags);
      break;
    case 0xba: /* Caps Lock release */
      mf2_flags &= ~0x40;
      write_byte(0x0040, 0x18, mf2_flags);
      break;

    case 0x2a: /* L Shift press */
      shift_flags |= 0x02;
      write_byte(0x0040, 0x17, shift_flags);
      break;
    case 0xaa: /* L Shift release */
      shift_flags &= ~0x02;
      write_byte(0x0040, 0x17, shift_flags);
      break;

    case 0x36: /* R Shift press */
      shift_flags |= 0x01;
      write_byte(0x0040, 0x17, shift_flags);
      break;
    case 0xb6: /* R Shift release */
      shift_flags &= ~0x01;
      write_byte(0x0040, 0x17, shift_flags);
      break;

    case 0x1d: /* Ctrl press */
      if ((mf2_state & 0x01) == 0) {
        shift_flags |= 0x04;
        write_byte(0x0040, 0x17, shift_flags);
        if (mf2_state & 0x02) {
          mf2_state |= 0x04;
          write_byte(0x0040, 0x96, mf2_state);
        } else {
          mf2_flags |= 0x01;
          write_byte(0x0040, 0x18, mf2_flags);
        }
      }
      break;
    case 0x9d: /* Ctrl release */
      if ((mf2_state & 0x01) == 0) {
        shift_flags &= ~0x04;
        write_byte(0x0040, 0x17, shift_flags);
        if (mf2_state & 0x02) {
          mf2_state &= ~0x04;
          write_byte(0x0040, 0x96, mf2_state);
        } else {
          mf2_flags &= ~0x01;
          write_byte(0x0040, 0x18, mf2_flags);
        }
      }
      break;

    case 0x38: /* Alt press */
      shift_flags |= 0x08;
      write_byte(0x0040, 0x17, shift_flags);
      if (mf2_state & 0x02) {
        mf2_state |= 0x08;
        write_byte(0x0040, 0x96, mf2_state);
      } else {
        mf2_flags |= 0x02;
        write_byte(0x0040, 0x18, mf2_flags);
      }
      break;
    case 0xb8: /* Alt release */
      shift_flags &= ~0x08;
      write_byte(0x0040, 0x17, shift_flags);
      if (mf2_state & 0x02) {
        mf2_state &= ~0x08;
        write_byte(0x0040, 0x96, mf2_state);
      } else {
        mf2_flags &= ~0x02;
        write_byte(0x0040, 0x18, mf2_flags);
      }
      break;

    case 0x45: /* Num Lock press */
      if ((mf2_state & 0x03) == 0) {
        mf2_flags |= 0x20;
        write_byte(0x0040, 0x18, mf2_flags);
        shift_flags ^= 0x20;
        write_byte(0x0040, 0x17, shift_flags);
      }
      break;
    case 0xc5: /* Num Lock release */
      if ((mf2_state & 0x03) == 0) {
        mf2_flags &= ~0x20;
        write_byte(0x0040, 0x18, mf2_flags);
      }
      break;

    case 0x46: /* Scroll Lock press */
      mf2_flags |= 0x10;
      write_byte(0x0040, 0x18, mf2_flags);
      shift_flags ^= 0x10;
      write_byte(0x0040, 0x17, shift_flags);
      break;

    case 0xc6: /* Scroll Lock release */
      mf2_flags &= ~0x10;
      write_byte(0x0040, 0x18, mf2_flags);
      break;

    default:
      if (scancode & 0x80) {
        break; /* toss key releases ... */
      }
      if (scancode > MAX_SCAN_CODE) {
        BX_INFO("KBD: int09h_handler(): unknown scancode read: 0x%02x!\n", scancode);
        return;
      }
      if (shift_flags & 0x08) { /* ALT */
        asciicode = scan_to_scanascii[scancode].alt;
        scancode = scan_to_scanascii[scancode].alt >> 8;
      } else if (shift_flags & 0x04) { /* CONTROL */
        asciicode = scan_to_scanascii[scancode].control;
        scancode = scan_to_scanascii[scancode].control >> 8;
      } else if (((mf2_state & 0x02) > 0) && ((scancode >= 0x47) && (scancode <= 0x53))) {
        /* extended keys handling */
        asciicode = 0xe0;
        scancode = scan_to_scanascii[scancode].normal >> 8;
      } else if (shift_flags & 0x03) { /* LSHIFT + RSHIFT */
        /* check if lock state should be ignored
         * because a SHIFT key are pressed */

        if (shift_flags & scan_to_scanascii[scancode].lock_flags) {
          asciicode = scan_to_scanascii[scancode].normal;
          scancode = scan_to_scanascii[scancode].normal >> 8;
        } else {
          asciicode = scan_to_scanascii[scancode].shift;
          scancode = scan_to_scanascii[scancode].shift >> 8;
        }
      } else {
        /* check if lock is on */
        if (shift_flags & scan_to_scanascii[scancode].lock_flags) {
          asciicode = scan_to_scanascii[scancode].shift;
          scancode = scan_to_scanascii[scancode].shift >> 8;
        } else {
          asciicode = scan_to_scanascii[scancode].normal;
          scancode = scan_to_scanascii[scancode].normal >> 8;
        }
      }
      if (scancode==0 && asciicode==0) {
        BX_INFO("KBD: int09h_handler(): scancode & asciicode are zero?\n");
      }
      enqueue_key(scancode, asciicode);
      break;
  }
  if ((scancode & 0x7f) != 0x1d) {
    mf2_state &= ~0x01;
  }
  mf2_state &= ~0x02;
  write_byte(0x0040, 0x96, mf2_state);
}

  unsigned int
enqueue_key(scan_code, ascii_code)
  Bit8u scan_code, ascii_code;
{
  Bit16u buffer_start, buffer_end, buffer_head, buffer_tail, temp_tail;

#if BX_CPU < 2
  buffer_start = 0x001E;
  buffer_end   = 0x003E;
#else
  buffer_start = read_word(0x0040, 0x0080);
  buffer_end   = read_word(0x0040, 0x0082);
#endif

  buffer_head = read_word(0x0040, 0x001A);
  buffer_tail = read_word(0x0040, 0x001C);

  temp_tail = buffer_tail;
  buffer_tail += 2;
  if (buffer_tail >= buffer_end)
    buffer_tail = buffer_start;

  if (buffer_tail == buffer_head) {
    return(0);
    }

   write_byte(0x0040, temp_tail, ascii_code);
   write_byte(0x0040, temp_tail+1, scan_code);
   write_word(0x0040, 0x001C, buffer_tail);
   return(1);
}


#define SET_DISK_RET_STATUS(status) write_byte(0x0040, 0x0074, status)

  void
int13_harddisk(DS, ES, DI, SI, BP, ELDX, BX, DX, CX, AX, IP, CS, FLAGS)
  Bit16u DS, ES, DI, SI, BP, ELDX, BX, DX, CX, AX, IP, CS, FLAGS;
{
  Bit8u    drive, num_sectors, sector, head, status;
  Bit8u    drive_map;
  Bit8u    n_drives;
  Bit16u   max_cylinder, cylinder;
  Bit16u   hd_cylinders;
  Bit8u    hd_heads, hd_sectors;
  Bit8u    sector_count;
  Bit16u   tempbx;

  Bit32u   log_sector;

  write_byte(0x0040, 0x008e, 0);  // clear completion flag

  /* at this point, DL is >= 0x80 to be passed from the floppy int13h
     handler code */
  /* check how many disks first (cmos reg 0x12), return an error if
     drive not present */
  drive_map = 1;
  n_drives = 1;

  if (!(drive_map & (1<<(GET_ELDL()&0x7f)))) { /* allow 0, 1, or 2 disks */
    SET_AH(0x01);
    SET_DISK_RET_STATUS(0x01);
    SET_CF(); /* error occurred */
    return;
    }

  switch (GET_AH()) {

    case 0x00: /* disk controller reset */

      SET_AH(0);
      SET_DISK_RET_STATUS(0);
      set_diskette_ret_status(0);
      set_diskette_current_cyl(0, 0); /* current cylinder, diskette 1 */
      set_diskette_current_cyl(1, 0); /* current cylinder, diskette 2 */
      CLEAR_CF(); /* successful */
      return;
      break;

    case 0x01: /* read disk status */
      status = read_byte(0x0040, 0x0074);
      SET_AH(status);
      SET_DISK_RET_STATUS(0);
      /* set CF if error status read */
      if (status) SET_CF();
      else        CLEAR_CF();
      return;
      break;

    case 0x04: // verify disk sectors
    case 0x02: // read disk sectors
      drive = GET_ELDL();

      // get_hd_geometry(drive, &hd_cylinders, &hd_heads, &hd_sectors);
      // fixed geometry:
      hd_cylinders = 993;
      hd_heads     = 16;
      hd_sectors   = 63;

      num_sectors = GET_AL();
      cylinder    = (GET_CL() & 0x00c0) << 2 | GET_CH();
      sector      = (GET_CL() & 0x3f);
      head        = GET_DH();

      if ( (cylinder >= hd_cylinders) ||
           (sector > hd_sectors) ||
           (head >= hd_heads) ) {
        SET_AH(1);
        SET_DISK_RET_STATUS(1);
        SET_CF(); /* error occurred */
        return;
        }

      if ( GET_AH() == 0x04 ) {
        SET_AH(0);
        SET_DISK_RET_STATUS(0);
        CLEAR_CF();
        return;
        }

      log_sector = ((Bit32u)cylinder) * ((Bit32u)hd_heads) * ((Bit32u)hd_sectors)
                 + ((Bit32u)head) * ((Bit32u)hd_sectors)
                 + ((Bit32u)sector) - 1;

      sector_count = 0;
      tempbx = BX;

ASM_START
  sti  ;; enable higher priority interrupts
ASM_END

      while (1) {
ASM_START
        ;; store temp bx in real DI register
        push bp
        mov  bp, sp
        mov  di, _int13_harddisk.tempbx + 2 [bp]
        pop  bp

        ;; adjust if there will be an overrun
        cmp   di, #0xfe00
        jbe   i13_f02_no_adjust
i13_f02_adjust:
        sub   di, #0x0200 ; sub 512 bytes from offset
        mov   ax, es
        add   ax, #0x0020 ; add 512 to segment
        mov   es, ax

i13_f02_no_adjust:
        ; timeout = TIMEOUT;
        mov   cx, #0xffff

        ; while((timeout > 0) && (!(CSR_ACE_STATUSL & ACE_STATUSL_CFCMDRDY))) timeout--;
        mov   dx, #0xe204

i13_f02_ace_statusl2:
        in    ax, dx
        and   ax, #0x100
        loopz i13_f02_ace_statusl2

        ; if(timeout == 0) return 0;
        cmp   cx, #0
        jnz   i13_f02_success2
ASM_END
        printf("i13_f02(1): Timeout\n");
ASM_START
        jmp   _int13_fail

i13_f02_success2:
        ; CSR_ACE_MLBAL = blocknr & 0x0000ffff;
        push  bp
        mov   bp, sp
        mov   ax, _int13_harddisk.log_sector + 2 [bp]
        mov   dx, #0xe210
        out   dx, ax

        ; CSR_ACE_MLBAH = (blocknr & 0x0fff0000) >> 16;
        mov   ax, _int13_harddisk.log_sector + 4 [bp]
        mov   dx, #0xe212
        out   dx, ax
        pop   bp

        ; CSR_ACE_SECCMD = ACE_SECCMD_READ|0x01;
        mov   ax, #0x0301
        mov   dx, #0xe214
        out   dx, ax

        ; CSR_ACE_CTLL |= ACE_CTLL_CFGRESET;
        mov   dx, #0xe218
        in    ax, dx
        or    ax, #0x0080
        out   dx, ax

        ; buffer_count = 16;
        mov   si, #16

        ; while(buffer_count > 0) {
i13_f02_cond_loop:
        cmp   si, #0
        jbe   i13_f02_exit_loop

        ; timeout = TIMEOUT;
        mov   cx, #0xffff
        mov   bx, #0x000f

        ; while((timeout > 0) && (!(CSR_ACE_STATUSL & ACE_STATUSL_DATARDY))) timeout--;
        mov   dx, #0xe204
i13_f02_ace_statusl3:
        in    ax, dx
        and   ax, #0x20
        loopz i13_f02_ace_statusl3

        ; if(timeout == 0) return 0;
        cmp   cx, #0
        jnz  i13_f02_success3
        dec   bx
        mov   cx, #0xffff
        jne   i13_f02_ace_statusl3
ASM_END
        printf("i13_f02(2): Timeout\n");
ASM_START
        jmp   _int13_fail

i13_f02_success3:
        ; for(i=0;i<16;i++) {
        mov   cx, #16
        ; *bufw = CSR_ACE_DATA;
        mov   dx, #0xe240
i13_f02_ace_data:
        in    ax, dx
        eseg
              mov   [di], ax
        ; bufw++;
        add   di, #2
        ; }
        loop  i13_f02_ace_data

        ; buffer_count--;
        dec   si
        jmp   i13_f02_cond_loop

        ; }

i13_f02_exit_loop:
        ; CSR_ACE_CTLL &= ~ACE_CTLL_CFGRESET;
        mov   dx, #0xe218
        in    ax, dx
        and   ax, #0xff7f
        out   dx, ax

i13_f02_done:
        ;; store real DI register back to temp bx
        push bp
        mov  bp, sp
        mov  _int13_harddisk.tempbx + 2 [bp], di
        pop  bp
ASM_END

        sector_count++;
        log_sector++;
        num_sectors--;
        if (num_sectors) continue;
        else break;
      }

      SET_AH(0);
      SET_DISK_RET_STATUS(0);
      SET_AL(sector_count);
      CLEAR_CF(); /* successful */
      return;
      break;

    case 0x03: /* write disk sectors */
      drive = GET_ELDL ();

      // get_hd_geometry(drive, &hd_cylinders, &hd_heads, &hd_sectors);
      // fixed geometry:
      hd_cylinders = 993;
      hd_heads     = 16;
      hd_sectors   = 63;

      num_sectors = GET_AL();
      cylinder    = GET_CH();
      cylinder    |= ( ((Bit16u) GET_CL()) << 2) & 0x300;
      sector      = (GET_CL() & 0x3f);
      head        = GET_DH();

      if ( (cylinder >= hd_cylinders) ||
           (sector > hd_sectors) ||
           (head >= hd_heads) ) {
        SET_AH( 1);
        SET_DISK_RET_STATUS(1);
        SET_CF(); /* error occurred */
        return;
        }

      log_sector = ((Bit32u)cylinder) * ((Bit32u)hd_heads) * ((Bit32u)hd_sectors)
                 + ((Bit32u)head) * ((Bit32u)hd_sectors)
                 + ((Bit32u)sector) - 1;

      sector_count = 0;
      tempbx = BX;

ASM_START
  sti  ;; enable higher priority interrupts
ASM_END

      while (1) {
ASM_START
        ;; store temp bx in real SI register
        push bp
        mov  bp, sp
        mov  si, _int13_harddisk.tempbx + 2 [bp]
        pop  bp

        ;; adjust if there will be an overrun
        cmp   si, #0xfe00
        jbe   i13_f03_no_adjust
i13_f03_adjust:
        sub   si, #0x0200 ; sub 512 bytes from offset
        mov   ax, es
        add   ax, #0x0020 ; add 512 to segment
        mov   es, ax

i13_f03_no_adjust:
        ; timeout = TIMEOUT;
        mov   cx, #0xffff

        ; while((timeout > 0) && (!(CSR_ACE_STATUSL & ACE_STATUSL_CFCMDRDY))) timeout--;
        mov   dx, #0xe204

i13_f03_ace_statusl2:
        in    ax, dx
        and   ax, #0x100
        loopz i13_f03_ace_statusl2

        ; if(timeout == 0) return 0;
        cmp   cx, #0
        jnz   i13_f03_success2
ASM_END
        printf("i13_f03(1): Timeout\n");
ASM_START
        jmp   _int13_fail

i13_f03_success2:
        ; CSR_ACE_MLBAL = blocknr & 0x0000ffff;
        push  bp
        mov   bp, sp
        mov   ax, _int13_harddisk.log_sector + 2 [bp]
        mov   dx, #0xe210
        out   dx, ax

        ; CSR_ACE_MLBAH = (blocknr & 0x0fff0000) >> 16;
        mov   ax, _int13_harddisk.log_sector + 4 [bp]
        mov   dx, #0xe212
        out   dx, ax
        pop   bp

        ; CSR_ACE_SECCMD = ACE_SECCMD_WRITE|0x01;
        mov   ax, #0x0401
        mov   dx, #0xe214
        out   dx, ax

        ; CSR_ACE_CTLL |= ACE_CTLL_CFGRESET;
        mov   dx, #0xe218
        in    ax, dx
        or    ax, #0x0080
        out   dx, ax

        ; buffer_count = 16;
        mov   di, #16

        ; while(buffer_count > 0) {
i13_f03_cond_loop:
        cmp   di, #0
        jbe   i13_f03_exit_loop

        ; timeout = TIMEOUT;
        mov   cx, #0xffff
        mov   bx, #0x000f

        ; while((timeout > 0) && (!(CSR_ACE_STATUSL & ACE_STATUSL_DATARDY))) timeout--;
        mov   dx, #0xe204
i13_f03_ace_statusl3:
        in    ax, dx
        and   ax, #0x20
        loopz i13_f03_ace_statusl3

        ; if(timeout == 0) return 0;
        cmp   cx, #0
        jnz   i13_f03_success3
        dec   bx
        mov   cx, #0xffff
        jne   i13_f03_ace_statusl3
ASM_END
        printf("i13_f03(2): Timeout\n");
ASM_START
        jmp   _int13_fail

i13_f03_success3:
        ; for(i=0;i<16;i++) {
        mov   cx, #16
        ; *bufw = CSR_ACE_DATA;
        mov   dx, #0xe240
i13_f03_ace_data:
        eseg
              mov   ax, [si]
        out   dx, ax
        ; bufw++;
        add   si, #2
        ; }
        loop  i13_f03_ace_data

        ; buffer_count--;
        dec   di
        jmp   i13_f03_cond_loop

        ; }

i13_f03_exit_loop:
        ; CSR_ACE_CTLL &= ~ACE_CTLL_CFGRESET;
        mov   dx, #0xe218
        in    ax, dx
        and   ax, #0xff7f
        out   dx, ax

i13_f03_done:
        ;; store real SI register back to temp bx
        push bp
        mov  bp, sp
        mov  _int13_harddisk.tempbx + 2 [bp], si
        pop  bp
ASM_END

        sector_count++;
        log_sector++;
        num_sectors--;
        if (num_sectors) continue;
        else break;
      }

      SET_AH(0);
      SET_DISK_RET_STATUS(0);
      SET_AL(sector_count);
      CLEAR_CF(); /* successful */
      return;
      break;

    case 0x08:

      drive = GET_ELDL ();

      // get_hd_geometry(drive, &hd_cylinders, &hd_heads, &hd_sectors);
      // fixed geometry:
      hd_cylinders = 993;
      hd_heads     = 16;
      hd_sectors   = 63;

      max_cylinder = hd_cylinders - 2; /* 0 based */
      SET_AL(0);
      SET_CH(max_cylinder & 0xff);
      SET_CL(((max_cylinder >> 2) & 0xc0) | (hd_sectors & 0x3f));
      SET_DH(hd_heads - 1);
      SET_DL(n_drives); /* returns 0, 1, or 2 hard drives */
      SET_AH(0);
      SET_DISK_RET_STATUS(0);
      CLEAR_CF(); /* successful */

      return;
      break;

    case 0x09: /* initialize drive parameters */
    case 0x0c: /* seek to specified cylinder */
    case 0x0d: /* alternate disk reset */
    case 0x10: /* check drive ready */
    case 0x11: /* recalibrate */
      SET_AH(0);
      SET_DISK_RET_STATUS(0);
      CLEAR_CF(); /* successful */
      return;
      break;

    case 0x14: /* controller internal diagnostic */
      SET_AH(0);
      SET_DISK_RET_STATUS(0);
      CLEAR_CF(); /* successful */
      SET_AL(0);
      return;
      break;

    case 0x15: /* read disk drive size */
      drive = GET_ELDL();
      // get_hd_geometry(drive, &hd_cylinders, &hd_heads, &hd_sectors);
      // fixed geometry:
      hd_cylinders = 993;
      hd_heads     = 16;
      hd_sectors   = 63;

ASM_START
      push bp
      mov  bp, sp
      mov  al, _int13_harddisk.hd_heads + 2 [bp]
      mov  ah, _int13_harddisk.hd_sectors + 2 [bp]
      mul  al, ah ;; ax = heads * sectors
      mov  bx, _int13_harddisk.hd_cylinders + 2 [bp]
      dec  bx     ;; use (cylinders - 1) ???
      mul  ax, bx ;; dx:ax = (cylinders -1) * (heads * sectors)
      ;; now we need to move the 32bit result dx:ax to what the
      ;; BIOS wants which is cx:dx.
      ;; and then into CX:DX on the stack
      mov  _int13_harddisk.CX + 2 [bp], dx
      mov  _int13_harddisk.DX + 2 [bp], ax
      pop  bp
ASM_END
      SET_AH(3);  // hard disk accessible
      SET_DISK_RET_STATUS(0); // ??? should this be 0
      CLEAR_CF(); // successful
      return;
      break;

    default:
      BX_INFO("int13_harddisk: function %02xh unsupported, returns fail\n", GET_AH());
      goto int13_fail;
      break;
    }
ASM_START
_int13_fail:
ASM_END
int13_fail:
    SET_AH(0x01); // defaults to invalid function in AH or invalid parameter
int13_fail_noah:
    SET_DISK_RET_STATUS(GET_AH());
int13_fail_nostatus:
    SET_CF();     // error occurred
    return;

int13_success:
    SET_AH(0x00); // no error
int13_success_noah:
    SET_DISK_RET_STATUS(0x00);
    CLEAR_CF();   // no error
    return;
}

  void
transf_sect(seg, offset)
  Bit16u seg;
  Bit16u offset;
{
ASM_START
  push bp
  mov  bp, sp

    push ax
    push bx
    push cx
    push dx
    push di
    push ds

    mov  ax, 4[bp] ; segment
    mov  ds, ax
    mov  bx, 6[bp] ; offset
    mov  dx, #0xe000
    mov  cx, #256
    xor  di, di

one_sect:
    in   ax, dx    ; read word from flash
    mov  [bx+di], ax ; write word
    inc  dx
    inc  dx
    inc  di
    inc  di
    loop one_sect

    pop  ds
    pop  di
    pop  dx
    pop  cx
    pop  bx
    pop  ax

  pop  bp
ASM_END
}

  void
int13_diskette_function(DS, ES, DI, SI, BP, ELDX, BX, DX, CX, AX, IP, CS, FLAGS)
  Bit16u DS, ES, DI, SI, BP, ELDX, BX, DX, CX, AX, IP, CS, FLAGS;
{
  Bit8u  drive, num_sectors, track, sector, head, status;
  Bit16u base_address, base_count, base_es;
  Bit8u  page, mode_register, val8, dor;
  Bit8u  return_status[7];
  Bit8u  drive_type, num_floppies, ah;
  Bit16u es, last_addr;
  Bit16u log_sector, tmp, i, j;

  ah = GET_AH();

  switch ( ah ) {
    case 0x00: // diskette controller reset
      SET_AH(0);
      set_diskette_ret_status(0);
      CLEAR_CF(); // successful
      set_diskette_current_cyl(drive, 0); // current cylinder
      return;

    case 0x02: // Read Diskette Sectors
      num_sectors = GET_AL();
      track       = GET_CH();
      sector      = GET_CL();
      head        = GET_DH();
      drive       = GET_ELDL();

      if ((drive > 1) || (head > 1) || (sector == 0) ||
          (num_sectors == 0) || (num_sectors > 72)) {
        BX_INFO("int13_diskette: read/write/verify: parameter out of range\n");
        SET_AH(1);
        set_diskette_ret_status(1);
        SET_AL(0); // no sectors read
        SET_CF(); // error occurred
        return;
      }

        page = (ES >> 12);   // upper 4 bits
        base_es = (ES << 4); // lower 16bits contributed by ES
        base_address = base_es + BX; // lower 16 bits of address
                                     // contributed by ES:BX
        if ( base_address < base_es ) {
          // in case of carry, adjust page by 1
          page++;
        }
        base_count = (num_sectors * 512) - 1;

        // check for 64K boundary overrun
        last_addr = base_address + base_count;
        if (last_addr < base_address) {
          SET_AH(0x09);
          set_diskette_ret_status(0x09);
          SET_AL(0); // no sectors read
          SET_CF(); // error occurred
          return;
        }

        log_sector = track * 36 + head * 18 + sector - 1;
        last_addr = page << 12;

        // Configure the sector address
        for (j=0; j<num_sectors; j++)
          {
            outw(0xe000, log_sector+j);
            base_count = base_address + (j << 9);
            transf_sect (last_addr, base_count);
          }

        // ??? should track be new val from return_status[3] ?
        set_diskette_current_cyl(drive, track);
        // AL = number of sectors read (same value as passed)
        SET_AH(0x00); // success
        CLEAR_CF();   // success
        return;
    default:
        BX_INFO("int13_diskette: unsupported AH=%02x\n", GET_AH());

      // if ( (ah==0x20) || ((ah>=0x41) && (ah<=0x49)) || (ah==0x4e) ) {
        SET_AH(0x01); // ???
        set_diskette_ret_status(1);
        SET_CF();
        return;
      //   }
    }
}

 void
set_diskette_ret_status(value)
  Bit8u value;
{
  write_byte(0x0040, 0x0041, value);
}

  void
set_diskette_current_cyl(drive, cyl)
  Bit8u drive;
  Bit8u cyl;
{
/* TEMP HACK: FOR MSDOS
  if (drive > 1)
    drive = 1; */
  /*  BX_PANIC("set_diskette_current_cyl(): drive > 1\n"); */
  write_byte(0x0040, 0x0094+drive, cyl);
}

void
int19_function(seq_nr)
Bit16u seq_nr;
{
  Bit16u ebda_seg=read_word(0x0040,0x000E);
  Bit16u bootdev;
  Bit8u  bootdrv;
  Bit8u  bootchk;
  Bit16u bootseg;
  Bit16u bootip;
  Bit16u status;
  Bit16u bootfirst;

  ipl_entry_t e;

  // Here we assume that BX_ELTORITO_BOOT is defined, so
  //   CMOS regs 0x3D and 0x38 contain the boot sequence:
  //     CMOS reg 0x3D & 0x0f : 1st boot device
  //     CMOS reg 0x3D & 0xf0 : 2nd boot device
  //     CMOS reg 0x38 & 0xf0 : 3rd boot device
  //   boot device codes:
  //     0x00 : not defined
  //     0x01 : first floppy
  //     0x02 : first harddrive
  //     0x03 : first cdrom
  //     0x04 - 0x0f : PnP expansion ROMs (e.g. Etherboot)
  //     else : boot failure

  // Get the boot sequence
/*
 * Zet: we don't have a CMOS device
 *
  bootdev = inb_cmos(0x3d);
  bootdev |= ((inb_cmos(0x38) & 0xf0) << 4);
  bootdev >>= 4 * seq_nr;
  bootdev &= 0xf;
*/
  bootdev = 0x2;  // 1: flopy disk, 2: hard disk

  /* Read user selected device */
  bootfirst = read_word(IPL_SEG, IPL_BOOTFIRST_OFFSET);
  if (bootfirst != 0xFFFF) {
    bootdev = bootfirst;
    /* User selected device not set */
    write_word(IPL_SEG, IPL_BOOTFIRST_OFFSET, 0xFFFF);
    /* Reset boot sequence */
    write_word(IPL_SEG, IPL_SEQUENCE_OFFSET, 0xFFFF);
  } else if (bootdev == 0) BX_PANIC("No bootable device.\n");

  /* Translate from CMOS runes to an IPL table offset by subtracting 1 */
  bootdev -= 1;

  /* Read the boot device from the IPL table */
  if (get_boot_vector(bootdev, &e) == 0) {
    BX_INFO("Invalid boot device (0x%x)\n", bootdev);
    return;
  }

  /* Do the loading, and set up vector as a far pointer to the boot
   * address, and bootdrv as the boot drive */
  print_boot_device(&e);

  switch(e.type) {
  case IPL_TYPE_FLOPPY: /* FDD */
  case IPL_TYPE_HARDDISK: /* HDD */

    bootdrv = (e.type == IPL_TYPE_HARDDISK) ? 0x80 : 0x00;
    bootseg = 0x07c0;
    status = 0;

ASM_START
    push bp
    mov  bp, sp
    push ax
    push bx
    push cx
    push dx

    mov  dl, _int19_function.bootdrv + 2[bp]
    mov  ax, _int19_function.bootseg + 2[bp]
    mov  es, ax         ;; segment
    xor  bx, bx         ;; offset
    mov  ah, #0x02      ;; function 2, read diskette sector
    mov  al, #0x01      ;; read 1 sector
    mov  ch, #0x00      ;; track 0
    mov  cl, #0x01      ;; sector 1
    mov  dh, #0x00      ;; head 0
    int  #0x13          ;; read sector
    jnc  int19_load_done
    mov  ax, #0x0001
    mov  _int19_function.status + 2[bp], ax

int19_load_done:
    pop  dx
    pop  cx
    pop  bx
    pop  ax
    pop  bp
ASM_END

    if (status != 0) {
      print_boot_failure(e.type, 1);
      return;
    }

    /* Canonicalize bootseg:bootip */
    bootip = (bootseg & 0x0fff) << 4;
    bootseg &= 0xf000;
  break;

  default: return;
  }

  /* Debugging info */
  BX_INFO("Booting from %x:%x\n", bootseg, bootip);

  /* Jump to the boot vector */
ASM_START
    mov  bp, sp
    ;; Build an iret stack frame that will take us to the boot vector.
    ;; iret pops ip, then cs, then flags, so push them in the opposite order.
    pushf
    mov  ax, _int19_function.bootseg + 0[bp]
    push ax
    mov  ax, _int19_function.bootip + 0[bp]
    push ax
    ;; Set the magic number in ax and the boot drive in dl.
    mov  ax, #0xaa55
    mov  dl, _int19_function.bootdrv + 0[bp]
    ;; Zero some of the other registers.
    xor  bx, bx
    mov  ds, bx
    mov  es, bx
    mov  bp, bx
    ;; Go!
    iret
ASM_END
}

  void
int1a_function(regs, ds, iret_addr)
  pusha_regs_t regs; // regs pushed from PUSHA instruction
  Bit16u ds; // previous DS:, DS set to 0x0000 by asm wrapper
  iret_addr_t  iret_addr; // CS,IP,Flags pushed from original INT call
{
  Bit8u val8;

  ASM_START
  sti
  ASM_END

  switch (regs.u.r8.ah) {
    case 0: // get current clock count
      ASM_START
      cli
      ASM_END
      regs.u.r16.cx = BiosData->ticks_high;
      regs.u.r16.dx = BiosData->ticks_low;
      regs.u.r8.al  = BiosData->midnight_flag;
      BiosData->midnight_flag = 0; // reset flag
      ASM_START
      sti
      ASM_END
      // AH already 0
      ClearCF(iret_addr.flags); // OK
      break;

    default:
      SetCF(iret_addr.flags); // Unsupported
    }
}

ASM_START
;----------------------
;- INT13h (relocated) -
;----------------------
;
; int13_relocated is a little bit messed up since I played with it
; I have to rewrite it:
;   - call a function that detect which function to call
;   - make all called C function get the same parameters list
;
int13_relocated:
  push  ax
  push  cx
  push  dx
  push  bx

int13_legacy:

  push  dx                   ;; push eltorito value of dx instead of sp

  push  bp
  push  si
  push  di

  push  es
  push  ds
  push  ss
  pop   ds

  ;; now the 16-bit registers can be restored with:
  ;; pop ds; pop es; popa; iret
  ;; arguments passed to functions should be
  ;; DS, ES, DI, SI, BP, ELDX, BX, DX, CX, AX, IP, CS, FLAGS

  test  dl, #0x80
  jnz   int13_notfloppy

  mov  ax, #int13_out
  push ax
  jmp _int13_diskette_function

int13_notfloppy:

int13_disk:
  ;; int13_harddisk modifies high word of EAX
;  shr   eax, #16
;  push  ax
  call  _int13_harddisk
;  pop   ax
;  shl   eax, #16

int13_out:
;
; ZEUS HACK: put IF flag on.
;  Seems that MS-DOS does a 'cli' before calling this
;  but after int13 it doesn't set the interrupts back
;
  mov bp, sp
  mov ax, 24[bp]  ; FLAGS location
  or  ax, #0x0200 ; IF on
  mov 24[bp], ax

  pop ds
  pop es
  ; popa ; we do this instead:
  pop di
  pop si
  pop bp
  add sp, #2
  pop bx
  pop dx
  pop cx
  pop ax

  iret

;----------
;- INT18h -
;----------
int18_handler: ;; Boot Failure recovery: try the next device.

  ;; Reset SP and SS
  mov  ax, #0xfffe
  mov  sp, ax
  xor  ax, ax
  mov  ss, ax

  ;; Get the boot sequence number out of the IPL memory
  mov  bx, #IPL_SEG
  mov  ds, bx                     ;; Set segment
  mov  bx, IPL_SEQUENCE_OFFSET    ;; BX is now the sequence number
  inc  bx                         ;; ++
  mov  IPL_SEQUENCE_OFFSET, bx    ;; Write it back
  mov  ds, ax                     ;; and reset the segment to zero.

  ;; Carry on in the INT 19h handler, using the new sequence number
  push bx

  jmp  int19_next_boot

;----------
;- INT19h -
;----------
int19_relocated: ;; Boot function, relocated

  ;; int19 was beginning to be really complex, so now it
  ;; just calls a C function that does the work

  push bp
  mov  bp, sp

  ;; Reset SS and SP
  mov  ax, #0xfffe
  mov  sp, ax
  xor  ax, ax
  mov  ss, ax

  ;; Start from the first boot device (0, in AX)
  mov  bx, #IPL_SEG
  mov  ds, bx                     ;; Set segment to write to the IPL memory
  mov  IPL_SEQUENCE_OFFSET, ax    ;; Save the sequence number
  mov  ds, ax                     ;; and reset the segment.

  push ax

int19_next_boot:

  ;; Call the C code for the next boot device
  call _int19_function

  ;; Boot failed: invoke the boot recovery function
  int  #0x18

;----------
;- INT1Ch -
;----------
int1c_handler: ;; User Timer Tick
  iret

;--------------------
;- POST: HARD DRIVE -
;--------------------
; relocated here because the primary POST area isnt big enough.
hard_drive_post:
  // IRQ 14 = INT 76h
  // INT 76h calls INT 15h function ax=9100

  xor  ax, ax
  mov  ds, ax
  mov  0x0474, al /* hard disk status of last operation */
  mov  0x0477, al /* hard disk port offset (XT only ???) */
  mov  0x048c, al /* hard disk status register */
  mov  0x048d, al /* hard disk error register */
  mov  0x048e, al /* hard disk task complete flag */
  mov  al, #0x01
  mov  0x0475, al /* hard disk number attached */
  mov  al, #0xc0
  mov  0x0476, al /* hard disk control byte */
  SET_INT_VECTOR(0x13, #0xF000, #int13_handler)
  SET_INT_VECTOR(0x76, #0xF000, #int76_handler)

  ;; Initialize the sysace controller
  ; CSR_ACE_BUSMODE = ACE_BUSMODE_16BIT;
  mov  dx, #0xe200
  mov  ax, #0x0001
  out  dx, ax

  ; if(!(CSR_ACE_STATUSL & ACE_STATUSL_CFDETECT)) return 0;
  mov  dx, #0xe204
  in   ax,  dx
  and  ax, #0x0010
  jne  cf_detect
  hlt  ;; error

cf_detect:
  ; if((CSR_ACE_ERRORL != 0) || (CSR_ACE_ERRORH != 0)) return 0;
  mov  dx, #0xe208
  in   ax, dx
  cmp  ax, #0x0
jne  error_l
  mov  dx, #0xe20a
  in   ax, dx
  cmp  ax, #0x0
  je   lock_req
error_l:
  hlt

lock_req:
  ; CSR_ACE_CTLL |= ACE_CTLL_LOCKREQ;
  mov  dx, #0xe218
  in   ax, dx
  or   ax, #0x2
  out  dx, ax

  ; timeout = TIMEOUT;
  mov  cx, #0xffff

  ; while((timeout > 0) && (!(CSR_ACE_STATUSL & ACE_STATUSL_MPULOCK))) timeout--;
  mov  dx, #0xe204
ace_statusl:
  in   ax, dx
  and  ax, #0x2
  loopz ace_statusl

  ; if(timeout == 0) return 0;
  cmp  cx, #0x0
  jnz  success
  hlt  ;; error obtaining lock

success:
  ret


;--------------------
;- POST: EBDA segment
;--------------------
; relocated here because the primary POST area isnt big enough.
ebda_post:
  xor ax, ax            ; mov EBDA seg into 40E
  mov ds, ax
  mov word ptr [0x40E], #EBDA_SEG
  ret;;

;--------------------
int76_handler:
  ;; record completion in BIOS task complete flag
  push  ax
  push  ds
  mov   ax, #0x0040
  mov   ds, ax
  mov   0x008E, #0xff
;  call  eoi_both_pics
  pop   ds
  pop   ax
  iret


rom_checksum:
  push ax
  push bx
  push cx
  xor  ax, ax
  xor  bx, bx
  xor  cx, cx
  mov  ch, [2]
  shl  cx, #1
checksum_loop:
  add  al, [bx]
  inc  bx
  loop checksum_loop
  and  al, #0xff
  pop  cx
  pop  bx
  pop  ax
  ret


;; We need a copy of this string, but we are not actually a PnP BIOS,
;; so make sure it is *not* aligned, so OSes will not see it if they scan.
.align 16
  db 0
pnp_string:
  .ascii "$PnP"


rom_scan:
  ;; Scan for existence of valid expansion ROMS.
  ;;   Video ROM:   from 0xC0000..0xC7FFF in 2k increments
  ;;   General ROM: from 0xC8000..0xDFFFF in 2k increments
  ;;   System  ROM: only 0xE0000
  ;;
  ;; Header:
  ;;   Offset    Value
  ;;   0         0x55
  ;;   1         0xAA
  ;;   2         ROM length in 512-byte blocks
  ;;   3         ROM initialization entry point (FAR CALL)

rom_scan_loop:
  push ax       ;; Save AX
  mov  ds, cx
  mov  ax, #0x0004 ;; start with increment of 4 (512-byte) blocks = 2k
  cmp [0], #0xAA55 ;; look for signature
  jne  rom_scan_increment
  call rom_checksum
  jnz  rom_scan_increment
  mov  al, [2]  ;; change increment to ROM length in 512-byte blocks

  ;; We want our increment in 512-byte quantities, rounded to
  ;; the nearest 2k quantity, since we only scan at 2k intervals.
  test al, #0x03
  jz   block_count_rounded
  and  al, #0xfc ;; needs rounding up
  add  al, #0x04
block_count_rounded:

  xor  bx, bx   ;; Restore DS back to 0000:
  mov  ds, bx
  push ax       ;; Save AX
  push di       ;; Save DI
  ;; Push addr of ROM entry point
  push cx       ;; Push seg
  ;; push #0x0003  ;; Push offset - not an 8086 valid operand
  mov ax, #0x0003
  push ax

  ;; Point ES:DI at "$PnP", which tells the ROM that we are a PnP BIOS.
  ;; That should stop it grabbing INT 19h; we will use its BEV instead.
  mov  ax, #0xf000
  mov  es, ax
  lea  di, pnp_string

  mov  bp, sp   ;; Call ROM init routine using seg:off on stack
  db   0xff     ;; call_far ss:[bp+0]
  db   0x5e
  db   0
  cli           ;; In case expansion ROM BIOS turns IF on
  add  sp, #2   ;; Pop offset value
  pop  cx       ;; Pop seg value (restore CX)

  ;; Look at the ROM's PnP Expansion header.  Properly, we're supposed
  ;; to init all the ROMs and then go back and build an IPL table of
  ;; all the bootable devices, but we can get away with one pass.
  mov  ds, cx       ;; ROM base
  mov  bx, 0x001a   ;; 0x1A is the offset into ROM header that contains...
  mov  ax, [bx]     ;; the offset of PnP expansion header, where...
  cmp  ax, #0x5024  ;; we look for signature "$PnP"
  jne  no_bev
  mov  ax, 2[bx]
  cmp  ax, #0x506e
  jne  no_bev
  mov  ax, 0x1a[bx] ;; 0x1A is also the offset into the expansion header of...
  cmp  ax, #0x0000  ;; the Bootstrap Entry Vector, or zero if there is none.
  je   no_bev

  ;; Found a device that thinks it can boot the system.  Record its BEV and product name string.
  mov  di, 0x10[bx]            ;; Pointer to the product name string or zero if none
  mov  bx, #IPL_SEG            ;; Go to the segment where the IPL table lives
  mov  ds, bx
  mov  bx, IPL_COUNT_OFFSET    ;; Read the number of entries so far
  cmp  bx, #IPL_TABLE_ENTRIES
  je   no_bev                  ;; Get out if the table is full
  push cx
  mov  cx, #0x4                ;; Zet: Needed to be compatible with 8086
  shl  bx, cl                  ;; Turn count into offset (entries are 16 bytes)
  pop  cx
  mov  0[bx], #IPL_TYPE_BEV    ;; This entry is a BEV device
  mov  6[bx], cx               ;; Build a far pointer from the segment...
  mov  4[bx], ax               ;; and the offset
  cmp  di, #0x0000
  je   no_prod_str
  mov  0xA[bx], cx             ;; Build a far pointer from the segment...
  mov  8[bx], di               ;; and the offset
no_prod_str:
  push cx
  mov  cx, #0x4
  shr  bx, cl                  ;; Turn the offset back into a count
  pop  cx
  inc  bx                      ;; We have one more entry now
  mov  IPL_COUNT_OFFSET, bx    ;; Remember that.

no_bev:
  pop  di       ;; Restore DI
  pop  ax       ;; Restore AX
rom_scan_increment:
  push cx
  mov  cx, #5
  shl  ax, cl   ;; convert 512-bytes blocks to 16-byte increments
                ;; because the segment selector is shifted left 4 bits.
  pop  cx
  add  cx, ax
  pop  ax       ;; Restore AX
  cmp  cx, ax
  jbe  rom_scan_loop

  xor  ax, ax   ;; Restore DS back to 0000:
  mov  ds, ax
  ret

;; for 'C' strings and other data, insert them here with
;; a the following hack:
;; DATA_SEG_DEFS_HERE


;; the following area can be used to write dynamically generated tables
  .align 16
bios_table_area_start:
  dd 0xaafb4442
  dd bios_table_area_end - bios_table_area_start - 8;

;--------
;- POST -
;--------
.org 0xe05b ; POST Entry Point
post:
  xor ax, ax

normal_post:
  ; case 0: normal startup

  cli
  mov  ax, #0xfffe
  mov  sp, ax
  xor  ax, ax
  mov  ds, ax
  mov  ss, ax

  ;; zero out BIOS data area (40:00..40:ff)
  mov  es, ax
  mov  cx, #0x0080 ;; 128 words
  mov  di, #0x0400
  cld
  rep
    stosw

  ;; set all interrupts to default handler
  xor  bx, bx         ;; offset index
  mov  cx, #0x0100    ;; counter (256 interrupts)
  mov  ax, #dummy_iret_handler
  mov  dx, #0xF000

post_default_ints:
  mov  [bx], ax
  add  bx, #2
  mov  [bx], dx
  add  bx, #2
  loop post_default_ints

  ;; set vector 0x79 to zero
  ;; this is used by 'gardian angel' protection system
  SET_INT_VECTOR(0x79, #0, #0)

  ;; base memory in K 40:13 (word)
  mov  ax, #BASE_MEM_IN_K
  mov  0x0413, ax


  ;; Manufacturing Test 40:12
  ;;   zerod out above

  ;; Warm Boot Flag 0040:0072
  ;;   value of 1234h = skip memory checks
  ;;   zerod out above

  ;; Bootstrap failure vector
  SET_INT_VECTOR(0x18, #0xF000, #int18_handler)

  ;; Bootstrap Loader vector
  SET_INT_VECTOR(0x19, #0xF000, #int19_handler)

  ;; User Timer Tick vector
  SET_INT_VECTOR(0x1c, #0xF000, #int1c_handler)

  ;; Memory Size Check vector
  SET_INT_VECTOR(0x12, #0xF000, #int12_handler)

  ;; Equipment Configuration Check vector
  SET_INT_VECTOR(0x11, #0xF000, #int11_handler)

  ;; EBDA setup
  call ebda_post

  ;; PIT setup
  SET_INT_VECTOR(0x08, #0xF000, #int08_handler)
  ;; int 1C already points at dummy_iret_handler (above)

  ;; Keyboard
  SET_INT_VECTOR(0x09, #0xF000, #int09_handler)
  SET_INT_VECTOR(0x16, #0xF000, #int16_handler)

  xor  ax, ax
  mov  ds, ax
  mov  0x0417, al /* keyboard shift flags, set 1 */
  mov  0x0418, al /* keyboard shift flags, set 2 */
  mov  0x0419, al /* keyboard alt-numpad work area */
  mov  0x0471, al /* keyboard ctrl-break flag */
  mov  0x0497, al /* keyboard status flags 4 */
  mov  al, #0x10
  mov  0x0496, al /* keyboard status flags 3 */

  /* keyboard head of buffer pointer */
  mov  bx, #0x001E
  mov  0x041A, bx

  /* keyboard end of buffer pointer */
  mov  0x041C, bx

  /* keyboard pointer to start of buffer */
  mov  bx, #0x001E
  mov  0x0480, bx

  /* keyboard pointer to end of buffer */
  mov  bx, #0x003E
  mov  0x0482, bx

  ;; CMOS RTC
  SET_INT_VECTOR(0x1A, #0xF000, #int1a_handler)

  ;; Video setup
  SET_INT_VECTOR(0x10, #0xF000, #int10_handler)

  mov  cx, #0xc000  ;; init vga bios
  mov  ax, #0xc780

  call rom_scan

  call _print_bios_banner

  ;;
  ;; Hard Drive setup
  ;;
  call hard_drive_post

  call _init_boot_vectors

  mov  cx, #0xc800  ;; init option roms
  mov  ax, #0xe000
  call rom_scan

  sti        ;; enable interrupts
  int  #0x19

;-------------------------------------------
;- INT 13h Fixed Disk Services Entry Point -
;-------------------------------------------
.org 0xe3fe ; INT 13h Fixed Disk Services Entry Point
int13_handler:
  //JMPL(int13_relocated)
  jmp int13_relocated

.org 0xe401 ; Fixed Disk Parameter Table

;----------
;- INT19h -
;----------
.org 0xe6f2 ; INT 19h Boot Load Service Entry Point
int19_handler:

  jmp int19_relocated


;----------------------------------------
;- INT 16h Keyboard Service Entry Point -
;----------------------------------------
.org 0xe82e
int16_handler:

  sti
  push  ds
  pushf
  ;pusha ; we do this instead:
  push ax
  push cx
  push dx
  push bx
  push sp
  mov  bx, sp
  sseg
    add  [bx], #10
  sseg
    mov  bx, [bx+2]
  push bp
  push si
  push di

  cmp   ah, #0x00
  je    int16_F00
  cmp   ah, #0x10
  je    int16_F00

  mov  bx, #0xf000
  mov  ds, bx
  call _int16_function
  ; popa ; we do this instead:
  pop di
  pop si
  pop bp
  add sp, #2
  pop bx
  pop dx
  pop cx
  pop ax
  popf
  pop  ds
  jz   int16_zero_set

int16_zero_clear:
  push bp
  mov  bp, sp
  //SEG SS
  and  BYTE [bp + 0x06], #0xbf
  pop  bp
  iret

int16_zero_set:
  push bp
  mov  bp, sp
  //SEG SS
  or   BYTE [bp + 0x06], #0x40
  pop  bp
  iret

int16_F00:
  mov  bx, #0x0040
  mov  ds, bx

int16_wait_for_key:
  cli
  mov  bx, 0x001a
  cmp  bx, 0x001c
  jne  int16_key_found
  sti
  nop
#if 0
                           /* no key yet, call int 15h, function AX=9002 */
  0x50,                    /* push AX */
  0xb8, 0x02, 0x90,        /* mov AX, #0x9002 */
  0xcd, 0x15,              /* int 15h */
  0x58,                    /* pop  AX */
  0xeb, 0xea,              /* jmp   WAIT_FOR_KEY */
#endif
  jmp  int16_wait_for_key

int16_key_found:
  mov  bx, #0xf000
  mov  ds, bx
  call _int16_function
  ; popa ; we do this instead:
  pop di
  pop si
  pop bp
  add sp, #2
  pop bx
  pop dx
  pop cx
  pop ax
  popf
  pop  ds
#if 0
                           /* notify int16 complete w/ int 15h, function AX=9102 */
  0x50,                    /* push AX */
  0xb8, 0x02, 0x91,        /* mov AX, #0x9102 */
  0xcd, 0x15,              /* int 15h */
  0x58,                    /* pop  AX */
#endif
  iret



;-------------------------------------------------
;- INT09h : Keyboard Hardware Service Entry Point -
;-------------------------------------------------
.org 0xe987
int09_handler:
  cli
  push ax
  in  al, #0x60             ;;read key from keyboard controller
  sti

  push  ds
  ;pusha ; we do this instead:

  push ax
  push cx
  push dx
  push bx
  push sp
  mov  bx, sp
  sseg
    add  [bx], #10
  sseg
    mov  bx, [bx+2]
  push bp
  push si
  push di

  ;; check for extended key
  cmp  al, #0xe0
  jne int09_check_pause
  xor  ax, ax
  mov  ds, ax
  mov  al, BYTE [0x496]     ;; mf2_state |= 0x02
  or   al, #0x02
  mov  BYTE [0x496], al
  jmp int09_done

int09_check_pause: ;; check for pause key
  cmp  al, #0xe1
  jne int09_process_key
  xor  ax, ax
  mov  ds, ax
  mov  al, BYTE [0x496]     ;; mf2_state |= 0x01
  or   al, #0x01
  mov  BYTE [0x496], al
  jmp int09_done

int09_process_key:
  mov   bx, #0xf000
  mov   ds, bx
  call  _int09_function
int09_done:
  ; popa ; we do this instead:
  pop di
  pop si
  pop bp
  add sp, #2
  pop bx
  pop dx
  pop cx
  pop ax

  pop   ds

  cli
  pop ax
  iret


;----------
;- INT10h -
;----------
.org 0xf065 ; INT 10h Video Support Service Entry Point
int10_handler:
  ;; dont do anything, since the VGA BIOS handles int10h requests
  iret

.org 0xf0a4 ; MDA/CGA Video Parameter Table (INT 1Dh)

;----------
;- INT12h -
;----------
.org 0xf841 ; INT 12h Memory Size Service Entry Point
; ??? different for Pentium (machine check)?
int12_handler:
  push ds
  mov  ax, #0x0040
  mov  ds, ax
  mov  ax, 0x0013
  pop  ds
  iret

;----------
;- INT11h -
;----------
.org 0xf84d ; INT 11h Equipment List Service Entry Point
int11_handler:
  push ds
  mov  ax, #0x0040
  mov  ds, ax
  mov  ax, 0x0010
  pop  ds
  iret

;----------
;- INT1Ah -
;----------
.org 0xfe6e ; INT 1Ah Time-of-day Service Entry Point
int1a_handler:
  push ds
  ;pusha ; we do this instead:
  push ax
  push cx
  push dx
  push bx
  push sp
  mov  bx, sp
  sseg
    add  [bx], #10
  sseg
    mov  bx, [bx+2]
  push bp
  push si
  push di

  xor  ax, ax
  mov  ds, ax
int1a_callfunction:
  call _int1a_function
  ; popa ; we do this instead:
  pop di
  pop si
  pop bp
  add sp, #2
  pop bx
  pop dx
  pop cx
  pop ax

  pop  ds
  iret

;---------
;- INT08 -
;---------
.org 0xfea5 ; INT 08h System Timer ISR Entry Point
int08_handler:
  sti
  push ax
  push bx
  push ds
  xor ax, ax
  mov ds, ax

  mov ax, 0x046c ;; get ticks dword
  mov bx, 0x046e
  inc ax
  jne i08_linc_done
  inc bx         ;; inc high word

i08_linc_done:
  push bx
  ;; compare eax to one days worth of timer ticks at 18.2 hz
  sub bx, #0x0018
  jne i08_lcmp_done
  cmp ax, #0x00B0
  jb  i08_lcmp_b_and_lt
  jge i08_lcmp_done
  inc bx
  jmp i08_lcmp_done

i08_lcmp_b_and_lt:
  dec bx

i08_lcmp_done:
  pop bx
  jb  int08_store_ticks
  ;; there has been a midnight rollover at this point
  xor ax, ax      ;; zero out counter
  xor bx, bx
  inc BYTE 0x0470 ;; increment rollover flag

int08_store_ticks:
  mov 0x046c, ax ;; store new ticks dword
  mov 0x046e, bx
  ;; chain to user timer tick INT #0x1c
  //pushf
  //;; call_ep [ds:loc]
  //CALL_EP( 0x1c << 2 )
  int #0x1c
  cli
  ;; call eoi_master_pic
  pop ds
  pop bx
  pop ax
  iret

.org 0xfef3 ; Initial Interrupt Vector Offsets Loaded by POST


.org 0xff00
.ascii BIOS_COPYRIGHT_STRING

;------------------------------------------------
;- IRET Instruction for Dummy Interrupt Handler -
;------------------------------------------------
.org 0xff53 ; IRET Instruction for Dummy Interrupt Handler
dummy_iret_handler:
  iret

.org 0xfff0 ; Power-up Entry Point
;  hlt
  jmp 0xf000:post

.org 0xfff5 ; ASCII Date ROM was built - 8 characters in MM/DD/YY
.ascii BIOS_BUILD_DATE

.org 0xfffe ; System Model ID
db SYS_MODEL_ID
db 0x00   ; filler
ASM_END

ASM_START
.org 0xcc00
bios_table_area_end:
// bcc-generated data will be placed here
ASM_END
