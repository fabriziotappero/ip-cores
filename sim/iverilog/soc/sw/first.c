
static void outb();
static void main();

#asm

use16 386

.text

.org 0xfff0

jmp 0xf000:start_code

#endasm

#asm
.text

.org 0x0000

start_code:

mov ax, #0xf000
mov ds, ax
mov es, ax
mov fs, ax
mov gs, ax
mov ss, ax

mov esp, #0xffec

call _main

end_label:
jmp end_label

.data
.org 0xF000


#endasm


typedef unsigned char  Bit8u;
typedef unsigned short Bit16u;
typedef unsigned short bx_bool;
typedef unsigned long  Bit32u;

  void
  main()
{
    char *txt = "Hello world !";
    int i = 0;
    
    while(txt[i] != 0) {
        outb(0x8888, txt[i]);
        i++;
    }
}

  void
outb(port, val)
  Bit16u port;
  Bit8u  val;
{
#asm
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
#endasm
}
