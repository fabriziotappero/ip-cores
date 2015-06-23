#include "vgabios.h"

/* Declares */
static Bit8u          read_byte();
static Bit16u         read_word();
static void           write_byte();
static void           write_word();
static Bit8u          inb();
static Bit16u         inw();
static void           outb();
static void           outw();

static Bit16u         get_SS();

// Output
static void           printf();

static Bit8u find_vga_entry();

static void memsetb();
static void memsetw();
static void memcpyb();
static void memcpyw();

static void biosfn_set_video_mode();
static void biosfn_set_cursor_shape();
static void biosfn_set_cursor_pos();
static void biosfn_get_cursor_pos();
static void biosfn_scroll();
static void biosfn_read_char_attr();
static void biosfn_write_char_attr();
static void biosfn_write_char_only();
static void biosfn_write_teletype();
static void biosfn_load_text_8_16_pat();
static void biosfn_write_string();
extern Bit8u video_save_pointer_table[];

// This is for compiling with gcc2 and gcc3
#define ASM_START #asm
#define ASM_END   #endasm

ASM_START

MACRO SET_INT_VECTOR
  push ds
  xor ax, ax
  mov ds, ax
  mov ax, ?3
  mov ?1*4, ax
  mov ax, ?2
  mov ?1*4+2, ax
  pop ds
MEND

ASM_END

ASM_START
.text
.rom
.org 0

use16 8086

vgabios_start:
.byte	0x55, 0xaa	/* BIOS signature, required for BIOS extensions */

.byte	0x40		/* BIOS extension length in units of 512 bytes */


vgabios_entry_point:

  jmp vgabios_init_func

vgabios_name:
.ascii	"Zet/Bochs VGABios"
.ascii	" "
.byte	0x00

// Info from Bart Oldeman
.org 0x1e
.ascii  "IBM"
.byte   0x00

vgabios_version:
#ifndef VGABIOS_VERS
.ascii	"current-cvs"
#else
.ascii VGABIOS_VERS
#endif
.ascii	" "

vgabios_date:
.ascii  VGABIOS_DATE
.byte   0x0a,0x0d
.byte	0x00

vgabios_copyright:
.ascii	"(C) 2003 the LGPL VGABios developers Team"
.byte	0x0a,0x0d
.byte	0x00

vgabios_license:
.ascii	"This VGA/VBE Bios is released under the GNU LGPL"
.byte	0x0a,0x0d
.byte	0x0a,0x0d
.byte	0x00

vgabios_website:
.ascii	"Please visit :"
.byte	0x0a,0x0d
;;.ascii  " . http://www.plex86.org"
;;.byte	0x0a,0x0d
.ascii	" . http://zet.aluzina.org"
.byte	0x0a,0x0d
.ascii	" . http://bochs.sourceforge.net"
.byte	0x0a,0x0d
.ascii	" . http://www.nongnu.org/vgabios"
.byte	0x0a,0x0d
.byte	0x0a,0x0d
.byte	0x00


;; ========================================================
;;
;; Init Entry point
;;
;; ========================================================
vgabios_init_func:

;; init vga card
  call init_vga_card

;; init basic bios vars
  call init_bios_area

;; set int10 vect
  SET_INT_VECTOR(0x10, #0xC000, #vgabios_int10_handler)

;; display splash screen
  call _display_splash_screen

;; init video mode and clear the screen
  mov ax,#0x0003
  int #0x10

;; show info
  call _display_info

  retf
ASM_END

/*
 *  int10 handled here
 */
ASM_START
vgabios_int10_handler:
  pushf
  cmp   ah, #0x0f
  jne   int10_test_1A
  call  biosfn_get_video_mode
  jmp   int10_end
int10_test_1A:
int10_test_1103:
  cmp   ax, #0x1103
  jne   int10_normal
  call  biosfn_set_text_block_specifier
  jmp   int10_end

int10_normal:
  push es
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

;; We have to set ds to access the right data segment
  mov   bx, #0xc000
  mov   ds, bx

  call _int10_func

  ; popa ; we do this instead:
  pop di
  pop si
  pop bp
  add sp, #2
  pop bx
  pop dx
  pop cx
  pop ax

  pop ds
  pop es
int10_end:
  popf
  iret
ASM_END

#include "vgatables.h"
#include "vgafonts.h"

/*
 * Boot time harware inits
 */
ASM_START
init_vga_card:
;; switch to color mode and enable CPU access 480 lines
  mov dx, #0x3C2
  mov al, #0xC3
  outb dx,al

;; more than 64k 3C4/04
  mov dx, #0x3C4
  mov al, #0x04
  outb dx,al
  mov dx, #0x3C5
  mov al, #0x02
  outb dx,al

#if defined(USE_BX_INFO) || defined(DEBUG)
  mov  bx, #msg_vga_init
  push bx
  call _printf
#endif
;  inc  sp
;  inc  sp
  ret

#if defined(USE_BX_INFO) || defined(DEBUG)
msg_vga_init:
.ascii "VGABios $Id: vgabios.c,v 1.66 2006/07/10 07:47:51 vruppert Exp $"
.byte 0x0d,0x0a,0x00
#endif
ASM_END

// --------------------------------------------------------------------------------------------
/*
 *  Boot time bios area inits
 */
ASM_START
init_bios_area:
  push  ds
  mov   ax, # BIOSMEM_SEG
  mov   ds, ax

;; init detected hardware BIOS Area
  mov   bx, # BIOSMEM_INITIAL_MODE
  mov   ax, [bx]
  and   ax, #0xffcf
;; set 80x25 color (not clear from RBIL but usual)
  or    ax, #0x0020
  mov   [bx], ax

;; Just for the first int10 find its children

;; the default char height
  mov   bx, # BIOSMEM_CHAR_HEIGHT
  mov   al, #0x10
  mov   [bx], al

;; Clear the screen
  mov   bx, # BIOSMEM_VIDEO_CTL
  mov   al, #0x60
  mov   [bx], al

;; Set the basic screen we have
  mov   bx, # BIOSMEM_SWITCHES
  mov   al, #0xf9
  mov   [bx], al

;; Set the basic modeset options
  mov   bx, # BIOSMEM_MODESET_CTL
  mov   al, #0x51
  mov   [bx], al

;; Set the  default MSR
  mov   bx, # BIOSMEM_CURRENT_MSR
  mov   al, #0x09
  mov   [bx], al

  pop ds
  ret

_video_save_pointer_table:
  .word _video_param_table
  .word 0xc000

  .word 0 /* XXX: fill it */
  .word 0

  .word 0 /* XXX: fill it */
  .word 0

  .word 0 /* XXX: fill it */
  .word 0

  .word 0 /* XXX: fill it */
  .word 0

  .word 0 /* XXX: fill it */
  .word 0

  .word 0 /* XXX: fill it */
  .word 0

ASM_END

// --------------------------------------------------------------------------------------------
/*
 *  Boot time Splash screen
 */
static void display_splash_screen()
{
}

// --------------------------------------------------------------------------------------------
/*
 *  Tell who we are
 */

static void display_info()
{
ASM_START
 mov ax,#0xc000
 mov ds,ax
 mov si,#vgabios_name
 call _display_string
 mov si,#vgabios_version
 call _display_string

 ;;mov si,#vgabios_copyright
 ;;call _display_string
 ;;mov si,#crlf
 ;;call _display_string

 mov si,#vgabios_license
 call _display_string
 mov si,#vgabios_website
 call _display_string
ASM_END
}

static void display_string()
{
 // Get length of string
ASM_START
 mov ax,ds
 mov es,ax
 mov di,si
 xor cx,cx
 not cx
 xor al,al
 cld
 repne
  scasb
 not cx
 dec cx
 push cx

 mov ax,#0x0300
 mov bx,#0x0000
 int #0x10

 pop cx
 mov ax,#0x1301
 mov bx,#0x000b
 mov bp,si
 int #0x10
ASM_END
}

// --------------------------------------------------------
/*
 * int10 main dispatcher
 */
static void int10_func(DI, SI, BP, SP, BX, DX, CX, AX, DS, ES, FLAGS)
  Bit16u DI, SI, BP, SP, BX, DX, CX, AX, ES, DS, FLAGS;
{
 // BIOS functions
 switch(GET_AH())
  {
   case 0x00:
     biosfn_set_video_mode(GET_AL());
     switch(GET_AL()&0x7F)
      {case 6:
        SET_AL(0x3F);
        break;
       case 0:
       case 1:
       case 2:
       case 3:
       case 4:
       case 5:
       case 7:
        SET_AL(0x30);
        break;
      default:
        SET_AL(0x20);
      }
     break;
   case 0x01:
     biosfn_set_cursor_shape(GET_CH(),GET_CL());
     break;
   case 0x02:
     biosfn_set_cursor_pos(GET_BH(),DX);
     break;
   case 0x03:
     biosfn_get_cursor_pos(GET_BH(),&CX,&DX);
     break;
   case 0x06:
     biosfn_scroll(GET_AL(),GET_BH(),GET_CH(),GET_CL(),GET_DH(),GET_DL(),0xFF,SCROLL_UP);
     break;
   case 0x07:
     biosfn_scroll(GET_AL(),GET_BH(),GET_CH(),GET_CL(),GET_DH(),GET_DL(),0xFF,SCROLL_DOWN);
     break;
   case 0x08:
     biosfn_read_char_attr(GET_BH(),&AX);
     break;
   case 0x09:
     biosfn_write_char_attr(GET_AL(),GET_BH(),GET_BL(),CX);
     break;
   case 0x0A:
     biosfn_write_char_only(GET_AL(),GET_BH(),GET_BL(),CX);
     break;
   case 0x0E:
     // Ralf Brown Interrupt list is WRONG on bh(page)
     // We do output only on the current page !
     biosfn_write_teletype(GET_AL(),0xff,GET_BL(),NO_ATTR);
     break;
   case 0x11:
     switch(GET_AL())
      {
       case 0x04:
       case 0x14:
        biosfn_load_text_8_16_pat(GET_AL(),GET_BL());
        break;
      }
     break;
   case 0x13:
     biosfn_write_string(GET_AL(),GET_BH(),GET_BL(),CX,GET_DH(),GET_DL(),ES,BP);
     break;
  }
}

// ============================================================================================
//
// BIOS functions
//
// ============================================================================================

static void biosfn_set_video_mode(mode) Bit8u mode;
{// mode: Bit 7 is 1 if no clear screen

 // Should we clear the screen ?
 Bit8u noclearmem=mode&0x80;
 Bit8u line,mmask,*palette,vpti;
 Bit16u i,twidth,theightm1,cheight;
 Bit8u modeset_ctl,video_ctl,vga_switches;
 Bit16u crtc_addr;

 // The real mode
 mode=mode&0x7f;

 // find the entry in the video modes
 line=find_vga_entry(mode);

 if(line==0xFF)
  return;

 vpti=line_to_vpti[line];
 twidth=video_param_table[vpti].twidth;
 theightm1=video_param_table[vpti].theightm1;
 cheight=video_param_table[vpti].cheight;

 // Read the bios vga control
 video_ctl=read_byte(BIOSMEM_SEG,BIOSMEM_VIDEO_CTL);

 // Read the bios vga switches
 vga_switches=read_byte(BIOSMEM_SEG,BIOSMEM_SWITCHES);

 // Read the bios mode set control
 modeset_ctl=read_byte(BIOSMEM_SEG,BIOSMEM_MODESET_CTL);

 // Then we know the number of lines
// FIXME

 // if palette loading (bit 3 of modeset ctl = 0)
 if((modeset_ctl&0x08)==0)
  {// Set the PEL mask
   outb(VGAREG_PEL_MASK,vga_modes[line].pelmask);

   // Set the whole dac always, from 0
   outb(VGAREG_DAC_WRITE_ADDRESS,0x00);

   // From which palette
   switch(vga_modes[line].dacmodel)
    {case 0:
      palette=&palette0;
      break;
     case 1:
      palette=&palette1;
      break;
     case 2:
      palette=&palette2;
      break;
     case 3:
      palette=&palette3;
      break;
    }
   // Always 256*3 values
   for(i=0;i<0x0100;i++)
    {if(i<=dac_regs[vga_modes[line].dacmodel])
      {outb(VGAREG_DAC_DATA,palette[(i*3)+0]);
       outb(VGAREG_DAC_DATA,palette[(i*3)+1]);
       outb(VGAREG_DAC_DATA,palette[(i*3)+2]);
      }
     else
      {outb(VGAREG_DAC_DATA,0);
       outb(VGAREG_DAC_DATA,0);
       outb(VGAREG_DAC_DATA,0);
      }
    }
  }

 // Reset Attribute Ctl flip-flop
 inb(VGAREG_ACTL_RESET);

 // Set Attribute Ctl
 for(i=0;i<=0x13;i++)
  {outb(VGAREG_ACTL_ADDRESS,i);
   outb(VGAREG_ACTL_WRITE_DATA,video_param_table[vpti].actl_regs[i]);
  }
 outb(VGAREG_ACTL_ADDRESS,0x14);
 outb(VGAREG_ACTL_WRITE_DATA,0x00);

 // Set Sequencer Ctl
 outb(VGAREG_SEQU_ADDRESS,0);
 outb(VGAREG_SEQU_DATA,0x03);
 for(i=1;i<=4;i++)
  {outb(VGAREG_SEQU_ADDRESS,i);
   outb(VGAREG_SEQU_DATA,video_param_table[vpti].sequ_regs[i - 1]);
  }

 // Set Grafx Ctl
 for(i=0;i<=8;i++)
  {outb(VGAREG_GRDC_ADDRESS,i);
   outb(VGAREG_GRDC_DATA,video_param_table[vpti].grdc_regs[i]);
  }

 // Set CRTC address VGA or MDA
 crtc_addr=vga_modes[line].memmodel==MTEXT?VGAREG_MDA_CRTC_ADDRESS:VGAREG_VGA_CRTC_ADDRESS;

 // Disable CRTC write protection
 outw(crtc_addr,0x0011);
 // Set CRTC regs
 for(i=0;i<=0x18;i++)
  {outb(crtc_addr,i);
   outb(crtc_addr+1,video_param_table[vpti].crtc_regs[i]);
  }

 // Set the misc register
 outb(VGAREG_WRITE_MISC_OUTPUT,video_param_table[vpti].miscreg);

 // Enable video
 outb(VGAREG_ACTL_ADDRESS,0x20);
 inb(VGAREG_ACTL_RESET);

 if(noclearmem==0x00)
  {
   if(vga_modes[line].class==TEXT)
    {
     memsetw(vga_modes[line].sstart,0,0x0720,0x4000); // 32k
    }
   else
    {
     if(mode<0x0d)
      {
       memsetw(vga_modes[line].sstart,0,0x0000,0x4000); // 32k
      }
     else
      {
       outb( VGAREG_SEQU_ADDRESS, 0x02 );
       mmask = inb( VGAREG_SEQU_DATA );
       outb( VGAREG_SEQU_DATA, 0x0f ); // all planes
       memsetw(vga_modes[line].sstart,0,0x0000,0x8000); // 64k
       outb( VGAREG_SEQU_DATA, mmask );
      }
    }
  }

 // Set the BIOS mem
 write_byte(BIOSMEM_SEG,BIOSMEM_CURRENT_MODE,mode);
 write_word(BIOSMEM_SEG,BIOSMEM_NB_COLS,twidth);
 write_word(BIOSMEM_SEG,BIOSMEM_PAGE_SIZE,*(Bit16u *)&video_param_table[vpti].slength_l);
 write_word(BIOSMEM_SEG,BIOSMEM_CRTC_ADDRESS,crtc_addr);
 write_byte(BIOSMEM_SEG,BIOSMEM_NB_ROWS,theightm1);
 write_word(BIOSMEM_SEG,BIOSMEM_CHAR_HEIGHT,cheight);
 write_byte(BIOSMEM_SEG,BIOSMEM_VIDEO_CTL,(0x60|noclearmem));
 write_byte(BIOSMEM_SEG,BIOSMEM_SWITCHES,0xF9);
 write_byte(BIOSMEM_SEG,BIOSMEM_MODESET_CTL,read_byte(BIOSMEM_SEG,BIOSMEM_MODESET_CTL)&0x7f);

 // FIXME We nearly have the good tables. to be reworked
 write_byte(BIOSMEM_SEG,BIOSMEM_DCC_INDEX,0x08);    // 8 is VGA should be ok for now
 write_word(BIOSMEM_SEG,BIOSMEM_VS_POINTER, video_save_pointer_table);
 write_word(BIOSMEM_SEG,BIOSMEM_VS_POINTER+2, 0xc000);

 // FIXME
 write_byte(BIOSMEM_SEG,BIOSMEM_CURRENT_MSR,0x00); // Unavailable on vanilla vga, but...
 write_byte(BIOSMEM_SEG,BIOSMEM_CURRENT_PAL,0x00); // Unavailable on vanilla vga, but...

 if(vga_modes[line].class==TEXT)
  {
   biosfn_set_cursor_shape(0x06,0x07);
  }

 // Set cursor pos for page 0..7
 for(i=0;i<8;i++)
  biosfn_set_cursor_pos(i,0x0000);

 // Write the fonts in memory
 if(vga_modes[line].class==TEXT)
  {
ASM_START
  ;; copy and activate 8x16 font
  mov ax, #0x1104
  mov bl, #0x00
  int #0x10
  mov ax, #0x1103
  mov bl, #0x00
  int #0x10
ASM_END
  }
}

// --------------------------------------------------------------------------------------------
static void biosfn_set_cursor_shape (CH,CL)
Bit8u CH;Bit8u CL;
{Bit16u cheight,curs,crtc_addr;
 Bit8u modeset_ctl;

 CH&=0x3f;
 CL&=0x1f;

 curs=(CH<<8)+CL;
 write_word(BIOSMEM_SEG,BIOSMEM_CURSOR_TYPE,curs);

 modeset_ctl=read_byte(BIOSMEM_SEG,BIOSMEM_MODESET_CTL);
 cheight = read_word(BIOSMEM_SEG,BIOSMEM_CHAR_HEIGHT);
 if((modeset_ctl&0x01) && (cheight>8) && (CL<8) && (CH<0x20))
  {
   if(CL!=(CH+1))
    {
     CH = ((CH+1) * cheight / 8) -1;
    }
   else
    {
     CH = ((CL+1) * cheight / 8) - 2;
    }
   CL = ((CL+1) * cheight / 8) - 1;
  }

 // CTRC regs 0x0a and 0x0b
 crtc_addr=read_word(BIOSMEM_SEG,BIOSMEM_CRTC_ADDRESS);
 outb(crtc_addr,0x0a);
 outb(crtc_addr+1,CH);
 outb(crtc_addr,0x0b);
 outb(crtc_addr+1,CL);
}

// --------------------------------------------------------------------------------------------
static void biosfn_set_cursor_pos (page, cursor)
Bit8u page;Bit16u cursor;
{
 Bit8u current;
 Bit16u crtc_addr;

 // Should not happen...
 if(page>7)return;

 // Bios cursor pos
 write_word(BIOSMEM_SEG, BIOSMEM_CURSOR_POS+2*page, cursor);

 // Set the hardware cursor
 current=read_byte(BIOSMEM_SEG,BIOSMEM_CURRENT_PAGE);
 if(page==current)
  {
   // CRTC regs 0x0e and 0x0f
   crtc_addr=read_word(BIOSMEM_SEG,BIOSMEM_CRTC_ADDRESS);
   outb(crtc_addr,0x0e);
   outb(crtc_addr+1,(cursor&0xff00)>>8);
   outb(crtc_addr,0x0f);
   outb(crtc_addr+1,cursor&0x00ff);
  }
}

// --------------------------------------------------------------------------------------------
static void biosfn_get_cursor_pos (page,shape, pos)
Bit8u page;Bit16u *shape;Bit16u *pos;
{
 Bit16u ss=get_SS();

 // Default
 write_word(ss, shape, 0);
 write_word(ss, pos, 0);

 if(page>7)return;
 // FIXME should handle VGA 14/16 lines
 write_word(ss,shape,read_word(BIOSMEM_SEG,BIOSMEM_CURSOR_TYPE));
 write_word(ss,pos,read_word(BIOSMEM_SEG,BIOSMEM_CURSOR_POS+page*2));
}

// --------------------------------------------------------------------------------------------
static void biosfn_scroll (nblines,attr,rul,cul,rlr,clr,page,dir)
Bit8u nblines;Bit8u attr;Bit8u rul;Bit8u cul;Bit8u rlr;Bit8u clr;Bit8u page;Bit8u dir;
{
 // page == 0xFF if current

 Bit8u mode,line,cheight,bpp,cols;
 Bit16u nbcols,nbrows,i;
 Bit16u address;

 if(rul>rlr)return;
 if(cul>clr)return;

 // Get the mode
 mode=read_byte(BIOSMEM_SEG,BIOSMEM_CURRENT_MODE);
 line=find_vga_entry(mode);
 if(line==0xFF)return;

 // Get the dimensions
 nbrows=read_byte(BIOSMEM_SEG,BIOSMEM_NB_ROWS)+1;
 nbcols=read_word(BIOSMEM_SEG,BIOSMEM_NB_COLS);

 // Get the current page
 if(page==0xFF)
  page=read_byte(BIOSMEM_SEG,BIOSMEM_CURRENT_PAGE);

 if(rlr>=nbrows)rlr=nbrows-1;
 if(clr>=nbcols)clr=nbcols-1;
 if(nblines>nbrows)nblines=0;
 cols=clr-cul+1;

 if(vga_modes[line].class==TEXT)
  {
   // Compute the address
   address=SCREEN_MEM_START(nbcols,nbrows,page);
#ifdef DEBUG
   printf("Scroll, address %04x (%04x %04x %02x)\n",address,nbrows,nbcols,page);
#endif

   if(nblines==0&&rul==0&&cul==0&&rlr==nbrows-1&&clr==nbcols-1)
    {
     memsetw(vga_modes[line].sstart,address,(Bit16u)attr*0x100+' ',nbrows*nbcols);
    }
   else
    {// if Scroll up
     if(dir==SCROLL_UP)
      {for(i=rul;i<=rlr;i++)
        {
         if((i+nblines>rlr)||(nblines==0))
          memsetw(vga_modes[line].sstart,address+(i*nbcols+cul)*2,(Bit16u)attr*0x100+' ',cols);
         else
          memcpyw(vga_modes[line].sstart,address+(i*nbcols+cul)*2,vga_modes[line].sstart,((i+nblines)*nbcols+cul)*2,cols);
        }
      }
     else
      {for(i=rlr;i>=rul;i--)
        {
         if((i<rul+nblines)||(nblines==0))
          memsetw(vga_modes[line].sstart,address+(i*nbcols+cul)*2,(Bit16u)attr*0x100+' ',cols);
         else
          memcpyw(vga_modes[line].sstart,address+(i*nbcols+cul)*2,vga_modes[line].sstart,((i-nblines)*nbcols+cul)*2,cols);
         if (i>rlr) break;
        }
      }
    }
  }
}

// --------------------------------------------------------------------------------------------
static void biosfn_read_char_attr (page,car)
Bit8u page;Bit16u *car;
{Bit16u ss=get_SS();
 Bit8u xcurs,ycurs,mode,line;
 Bit16u nbcols,nbrows,address;
 Bit16u cursor,dummy;

 // Get the mode
 mode=read_byte(BIOSMEM_SEG,BIOSMEM_CURRENT_MODE);
 line=find_vga_entry(mode);
 if(line==0xFF)return;

 // Get the cursor pos for the page
 biosfn_get_cursor_pos(page,&dummy,&cursor);
 xcurs=cursor&0x00ff;ycurs=(cursor&0xff00)>>8;

 // Get the dimensions
 nbrows=read_byte(BIOSMEM_SEG,BIOSMEM_NB_ROWS)+1;
 nbcols=read_word(BIOSMEM_SEG,BIOSMEM_NB_COLS);

 // Compute the address
 address=SCREEN_MEM_START(nbcols,nbrows,page)+(xcurs+ycurs*nbcols)*2;

 write_word(ss,car,read_word(vga_modes[line].sstart,address));
}

// --------------------------------------------------------------------------------------------
static void biosfn_write_char_attr (car,page,attr,count)
Bit8u car;Bit8u page;Bit8u attr;Bit16u count;
{
 Bit8u cheight,xcurs,ycurs,mode,line,bpp;
 Bit16u nbcols,nbrows,address;
 Bit16u cursor,dummy;

 // Get the mode
 mode=read_byte(BIOSMEM_SEG,BIOSMEM_CURRENT_MODE);
 line=find_vga_entry(mode);
 if(line==0xFF)return;

 // Get the cursor pos for the page
 biosfn_get_cursor_pos(page,&dummy,&cursor);
 xcurs=cursor&0x00ff;ycurs=(cursor&0xff00)>>8;

 // Get the dimensions
 nbrows=read_byte(BIOSMEM_SEG,BIOSMEM_NB_ROWS)+1;
 nbcols=read_word(BIOSMEM_SEG,BIOSMEM_NB_COLS);

 // Compute the address
 address=SCREEN_MEM_START(nbcols,nbrows,page)+(xcurs+ycurs*nbcols)*2;

 dummy=((Bit16u)attr<<8)+car;
 memsetw(vga_modes[line].sstart,address,dummy,count);
}

// --------------------------------------------------------------------------------------------
static void biosfn_write_char_only (car,page,attr,count)
Bit8u car;Bit8u page;Bit8u attr;Bit16u count;
{
 Bit8u cheight,xcurs,ycurs,mode,line,bpp;
 Bit16u nbcols,nbrows,address;
 Bit16u cursor,dummy;

 // Get the mode
 mode=read_byte(BIOSMEM_SEG,BIOSMEM_CURRENT_MODE);
 line=find_vga_entry(mode);
 if(line==0xFF)return;

 // Get the cursor pos for the page
 biosfn_get_cursor_pos(page,&dummy,&cursor);
 xcurs=cursor&0x00ff;ycurs=(cursor&0xff00)>>8;

 // Get the dimensions
 nbrows=read_byte(BIOSMEM_SEG,BIOSMEM_NB_ROWS)+1;
 nbcols=read_word(BIOSMEM_SEG,BIOSMEM_NB_COLS);

 // Compute the address
 address=SCREEN_MEM_START(nbcols,nbrows,page)+(xcurs+ycurs*nbcols)*2;

 while(count-->0)
  {write_byte(vga_modes[line].sstart,address,car);
   address+=2;
  }
}

// --------------------------------------------------------------------------------------------
static void biosfn_write_teletype (car, page, attr, flag)
Bit8u car;Bit8u page;Bit8u attr;Bit8u flag;
{// flag = WITH_ATTR / NO_ATTR

 Bit8u cheight,xcurs,ycurs,mode,line,bpp;
 Bit16u nbcols,nbrows,address;
 Bit16u cursor,dummy;

 // special case if page is 0xff, use current page
 if(page==0xff)
  page=read_byte(BIOSMEM_SEG,BIOSMEM_CURRENT_PAGE);

 // Get the mode
 mode=read_byte(BIOSMEM_SEG,BIOSMEM_CURRENT_MODE);
 line=find_vga_entry(mode);
 if(line==0xFF)return;

 // Get the cursor pos for the page
 biosfn_get_cursor_pos(page,&dummy,&cursor);
 xcurs=cursor&0x00ff;ycurs=(cursor&0xff00)>>8;

 // Get the dimensions
 nbrows=read_byte(BIOSMEM_SEG,BIOSMEM_NB_ROWS)+1;
 nbcols=read_word(BIOSMEM_SEG,BIOSMEM_NB_COLS);

 switch(car)
  {
   case 7:
    //FIXME should beep
    break;

   case 8:
    if(xcurs>0)xcurs--;
    break;

   case '\r':
    xcurs=0;
    break;

   case '\n':
    ycurs++;
    break;

   case '\t':
    do
     {
      biosfn_write_teletype(' ',page,attr,flag);
      biosfn_get_cursor_pos(page,&dummy,&cursor);
      xcurs=cursor&0x00ff;ycurs=(cursor&0xff00)>>8;
     }while(xcurs%8==0);
    break;

   default:

    if(vga_modes[line].class==TEXT)
     {
      // Compute the address
      address=SCREEN_MEM_START(nbcols,nbrows,page)+(xcurs+ycurs*nbcols)*2;

      // Write the char
      write_byte(vga_modes[line].sstart,address,car);

      if(flag==WITH_ATTR)
       write_byte(vga_modes[line].sstart,address+1,attr);
     }
    xcurs++;
  }

 // Do we need to wrap ?
 if(xcurs==nbcols)
  {xcurs=0;
   ycurs++;
  }

 // Do we need to scroll ?
 if(ycurs==nbrows)
  {
   if(vga_modes[line].class==TEXT)
    {
     biosfn_scroll(0x01,0x07,0,0,nbrows-1,nbcols-1,page,SCROLL_UP);
    }
   ycurs-=1;
  }

 // Set the cursor for the page
 cursor=ycurs; cursor<<=8; cursor+=xcurs;
 biosfn_set_cursor_pos(page,cursor);
}

// --------------------------------------------------------------------------------------------
ASM_START
biosfn_get_video_mode:
  push  ds
  mov   ax, # BIOSMEM_SEG
  mov   ds, ax
  push  bx
  mov   bx, # BIOSMEM_CURRENT_PAGE
  mov   al, [bx]
  pop   bx
  mov   bh, al
  push  bx
  mov   bx, # BIOSMEM_VIDEO_CTL
  mov   ah, [bx]
  and   ah, #0x80
  mov   bx, # BIOSMEM_CURRENT_MODE
  mov   al, [bx]
  or    al, ah
  mov   bx, # BIOSMEM_NB_COLS
  mov   ah, [bx]
  pop   bx
  pop   ds
  ret
ASM_END

// --------------------------------------------------------------------------------------------
static void get_font_access()
{
ASM_START
 mov dx, # VGAREG_SEQU_ADDRESS
 mov ax, #0x0100
 out dx, ax
 mov ax, #0x0402
 out dx, ax
 mov ax, #0x0704
 out dx, ax
 mov ax, #0x0300
 out dx, ax
 mov dx, # VGAREG_GRDC_ADDRESS
 mov ax, #0x0204
 out dx, ax
 mov ax, #0x0005
 out dx, ax
 mov ax, #0x0406
 out dx, ax
ASM_END
}

static void release_font_access()
{
ASM_START
 mov dx, # VGAREG_SEQU_ADDRESS
 mov ax, #0x0100
 out dx, ax
 mov ax, #0x0302
 out dx, ax
 mov ax, #0x0304
 out dx, ax
 mov ax, #0x0300
 out dx, ax
 mov dx, # VGAREG_READ_MISC_OUTPUT
 in  al, dx
 and al, #0x01
 push cx
 mov cl,*2
 shl al,cl
 pop cx
 or  al, #0x0a
 mov ah, al
 mov al, #0x06
 mov dx, # VGAREG_GRDC_ADDRESS
 out dx, ax
 mov ax, #0x0004
 out dx, ax
 mov ax, #0x1005
 out dx, ax
ASM_END
}

ASM_START
idiv_u:
  xor dx,dx
  div bx
  ret
ASM_END

static void set_scan_lines(lines) Bit8u lines;
{
 Bit16u crtc_addr,cols,page,vde;
 Bit8u crtc_r9,ovl,rows;

 crtc_addr = read_word(BIOSMEM_SEG,BIOSMEM_CRTC_ADDRESS);
 outb(crtc_addr, 0x09);
 crtc_r9 = inb(crtc_addr+1);
 crtc_r9 = (crtc_r9 & 0xe0) | (lines - 1);
 outb(crtc_addr+1, crtc_r9);
/*
 if(lines==8)
  {
   biosfn_set_cursor_shape(0x06,0x07);
  }
 else
  {
   biosfn_set_cursor_shape(lines-4,lines-3);
  }
*/
 write_word(BIOSMEM_SEG,BIOSMEM_CHAR_HEIGHT, lines);
 outb(crtc_addr, 0x12);
 vde = inb(crtc_addr+1);
 outb(crtc_addr, 0x07);
 ovl = inb(crtc_addr+1);
 vde += (((ovl & 0x02) << 7) + ((ovl & 0x40) << 3) + 1);
 rows = vde / lines;
 write_byte(BIOSMEM_SEG,BIOSMEM_NB_ROWS, rows-1);
 cols = read_word(BIOSMEM_SEG,BIOSMEM_NB_COLS);
 write_word(BIOSMEM_SEG,BIOSMEM_PAGE_SIZE, rows * cols * 2);
}

// --------------------------------------------------------------------------------------------
ASM_START
biosfn_set_text_block_specifier:
  push  ax
  push  dx
  mov   dx, # VGAREG_SEQU_ADDRESS
  mov   ah, bl
  mov   al, #0x03
  out   dx, ax
  pop   dx
  pop   ax
  ret
ASM_END

// --------------------------------------------------------------------------------------------
static void biosfn_load_text_8_16_pat (AL,BL) Bit8u AL;Bit8u BL;
{
 Bit16u blockaddr,dest,i,src;

 get_font_access();
 blockaddr = ((BL & 0x03) << 14) + ((BL & 0x04) << 11);
 for(i=0;i<0x100;i++)
  {
   src = i * 16;
   dest = blockaddr + i * 32;
   memcpyb(0xA000, dest, 0xC000, vgafont16+src, 16);
  }
 release_font_access();
 if(AL>=0x10)
  {
   set_scan_lines(16);
  }
}

// --------------------------------------------------------------------------------------------
static void biosfn_write_string (flag,page,attr,count,row,col,seg,offset)
Bit8u flag;Bit8u page;Bit8u attr;Bit16u count;Bit8u row;Bit8u col;Bit16u seg;Bit16u offset;
{
 Bit16u newcurs,oldcurs,dummy;
 Bit8u car,carattr;

 // Read curs info for the page
 biosfn_get_cursor_pos(page,&dummy,&oldcurs);

 // if row=0xff special case : use current cursor position
 if(row==0xff)
  {col=oldcurs&0x00ff;
   row=(oldcurs&0xff00)>>8;
  }

 newcurs=row; newcurs<<=8; newcurs+=col;
 biosfn_set_cursor_pos(page,newcurs);

 while(count--!=0)
  {
   car=read_byte(seg,offset++);
   if((flag&0x02)!=0)
    attr=read_byte(seg,offset++);

   biosfn_write_teletype(car,page,attr,WITH_ATTR);
  }

 // Set back curs pos
 if((flag&0x01)==0)
  biosfn_set_cursor_pos(page,oldcurs);
}

// ============================================================================================
//
// Video Utils
//
// ============================================================================================

// --------------------------------------------------------------------------------------------
static Bit8u find_vga_entry(mode)
Bit8u mode;
{
 Bit8u i,line=0xFF;
 for(i=0;i<=MODE_MAX;i++)
  if(vga_modes[i].svgamode==mode)
   {line=i;
    break;
   }
 return line;
}

// --------------------------------------------------------------------------------------------
static void memsetw(seg,offset,value,count)
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
    cmp  cx, #0x00
    je   memsetw_end
    mov  ax, 4[bp] ; segment
    mov  es, ax
    mov  ax, 6[bp] ; offset
    mov  di, ax
    mov  ax, 8[bp] ; value
    cld
    rep
     stosw

memsetw_end:
    pop di
    pop es
    pop cx
    pop ax

  pop bp
ASM_END
}

// --------------------------------------------------------------------------------------------
static void memcpyb(dseg,doffset,sseg,soffset,count)
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
    cmp  cx, #0x0000
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

// --------------------------------------------------------------------------------------------
static void memcpyw(dseg,doffset,sseg,soffset,count)
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
    cmp  cx, #0x0000
    je   memcpyw_end
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
     movsw

memcpyw_end:
    pop si
    pop ds
    pop di
    pop es
    pop cx
    pop ax

  pop bp
ASM_END
}

// --------------------------------------------------------------------------------------------
static Bit8u
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

// --------------------------------------------------------------------------------------------
static Bit16u
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

// --------------------------------------------------------------------------------------------
static void
write_byte(seg, offset, data)
  Bit16u seg;
  Bit16u offset;
  Bit8u  data;
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

// --------------------------------------------------------------------------------------------
static void
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

// --------------------------------------------------------------------------------------------
 Bit8u
inb(port)
  Bit16u port;
{
ASM_START
  push bp
  mov  bp, sp

    push dx
    mov  dx, 4[bp]
    in   al, dx
    pop  dx

  pop  bp
ASM_END
}

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

// --------------------------------------------------------------------------------------------
  void
outb(port, val)
  Bit16u port;
  Bit8u  val;
{
ASM_START
  push bp
  mov  bp, sp

    push ax
    push dx
    mov  dx, 4[bp]
    mov  al, 6[bp]
    out  dx, al
    pop  dx
    pop  ax

  pop  bp
ASM_END
}

// --------------------------------------------------------------------------------------------
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

Bit16u get_SS()
{
ASM_START
  mov  ax, ss
ASM_END
}

void printf(s)
  Bit8u *s;
{
  Bit8u c, format_char;
  Boolean  in_format;
  unsigned format_width, i;
  Bit16u  *arg_ptr;
  Bit16u   arg_seg, arg, digit, nibble, shift_count;

  arg_ptr = &s;
  arg_seg = get_SS();

  in_format = 0;
  format_width = 0;

  while (c = read_byte(0xc000, s)) {
    if ( c == '%' ) {
      in_format = 1;
      format_width = 0;
      }
    else if (in_format) {
      if ( (c>='0') && (c<='9') ) {
        format_width = (format_width * 10) + (c - '0');
        }
      else if (c == 'x') {
        arg_ptr++; // increment to next arg
        arg = read_word(arg_seg, arg_ptr);
        if (format_width == 0)
          format_width = 4;
        i = 0;
        digit = format_width - 1;
        for (i=0; i<format_width; i++) {
          nibble = (arg >> (4 * digit)) & 0x000f;
          if (nibble <= 9)
            outb(0x0500, nibble + '0');
          else
            outb(0x0500, (nibble - 10) + 'A');
          digit--;
          }
        in_format = 0;
        }
      //else if (c == 'd') {
      //  in_format = 0;
      //  }
      }
    else {
      outb(0x0500, c);
      }
    s ++;
    }
}

// --------------------------------------------------------------------------------------------

ASM_START
;; DATA_SEG_DEFS_HERE
ASM_END

ASM_START
.ascii "vgabios ends here"
.byte  0x00
vgabios_end:
.byte 0xCB
;; BLOCK_STRINGS_BEGIN
ASM_END
