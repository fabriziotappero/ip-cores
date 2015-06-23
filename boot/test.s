.code16
/* start protected mode , no more CS/DS prefix */
start:
movl $0x01,%eax
movl %eax , %cr0
.code32
ljmp $0x0 , $0x0ffc20 
.org 0x020


/* select boot type */
movl $0x500, %edx
inb (%dx) , %al
and $3 , %al
cmp $1 , %al
jz boot_test
cmp $2 , %al
jz boot_ram
cmp $3 , %al
jz boot_spi

jmp boot_linux

boot_spi:
movl $0x1000, %esp
call init_uart

call banner

mov $6,%al
mov $0x500,%edx
out %al,(%dx)
mov $2,%al
mov $0x500,%edx
out %al,(%dx)
movb $0x03,%bl
call send8b_spi
movb $0x3F,%bl
call send8b_spi
movb $0xFF,%bl
call send8b_spi
movb $0xF0,%bl
call send8b_spi

mov $0x0FFFF0,%edi
mov $0x0c0000,%esi
call fill_spi

call banner

mov $6,%al
mov $0x500,%edx
out %al,(%dx)
mov $2,%al
mov $0x500,%edx
out %al,(%dx)
movb $0x03,%bl
call send8b_spi
movb $0x7F,%bl
call send8b_spi
movb $0xFF,%bl
call send8b_spi
movb $0xF0,%bl
call send8b_spi

mov $0x3FFFF0,%edi
mov $0x080000,%esi
call fill_spi

call banner

jmp boot_linux

fill_spi:
call recv32b_spi
mov %ebx ,%eax
rol $8,%eax
mov %al , (%edi)
inc %edi
rol $8,%eax
mov %al , (%edi)
inc %edi
rol $8,%eax
mov %al , (%edi)
inc %edi
rol $8,%eax
mov %al , (%edi)
mov (%edi), %bl
cmp %al , %bl
jz okpass
push edi
push esi
call banner
pop esi
pop edi
okpass:
inc %edi
dec %esi
jnz fill_spi
ret

// send %bl to spi , msb first
send8b_spi:
movw $0x500,%dx
movb $8,%cl
rol $1,%bl
nextbit:
mov %bl , %al
and $1, %al
outb %al, (%dx)
or $2, %al
outb %al, (%dx)
xor $2, %al
outb %al, (%dx)
rol $1,%bl
dec %cl
jnz nextbit
ret

//init spi
mov $6,%al
mov $0x500,%edx
out %al,(%dx)
mov $2,%al
mov $0x500,%edx
out %al,(%dx)
mov $0xF0,%bl
call sen8b_spi
mov $6,%al
mov $0x500,%edx
out %al,(%dx)
ret


// receive spi to %ebx
recv32b_spi:
movw $0x504,%dx
movb $32,%al
outb %al, (%dx)
mov $25,%ecx
waitloop:
dec %ecx
jnz waitloop
in (%dx), %eax
in (%dx), %eax
in (%dx), %eax
mov %eax,%ebx
ret

boot_linux:
call init_uart
/* setup ebda ptr at 0x40e*/
movl $0x0fff00 , %ebx
movl $0x040e , %ecx
mov %ebx , (%ecx)

/* eax = ram size */
/* ebx = ramd size */
/* ecx = ptr to cmdline */

mov $0x90000, %edi
mov $0x400 , %ecx
mov $0 , %eax
rep
stosl

/* command line */
mov $0x90800, %edi
mov %edi , 0x90228
mov $0xfff20, %esi
mov $0x100 , %ecx
rep
movsb

/* loader type */
mov $1, %al
mov  %eax , 0x90210

/* mem size */
movl $0x003c00 , %eax 
mov  %eax , 0x901e0

/* initrd start */
mov  $0x00400000 , %eax
/* mov  $0, %eax */
mov  %eax , 0x90218

/* initrd size */
movl $0x00200000 , %eax
/* movl $501047 , %eax */
/* movl $0 , %eax */
mov  %eax , 0x9021c

/* row cols */
mov $80,%al
mov %al,0x90007
mov $25,%al
mov %al,0x9000e

call banner

movl $0x00090000, %esi
ljmp $0x10, $0x00100000

boot_test:
mov $0x1000,%esp
call init_uart

mov $0 , %bl
loopboot:
call sendchar
incb %bl
jmp loopboot

sendchar:
push %eax
push %edx
/* wait if there is character to be sent */
wait_rdy:
movl $0x3fd, %edx
in (%dx),%al
andb $0x20,%al
jz wait_rdy
movl $0x3f8, %edx
mov %bl, %al
outb %al, (%dx)
pop %edx
pop %eax
ret

init_uart:
/* set 8N1 flow dlab =1*/
movl $0x3fb, %edx
movb $0x83 , %al
outb %al , (%dx)

/* set DLL divisor 1 = 115200 bauds , 2= 57600 bauds , ...*/
movl $0x3f8, %edx
movb $1 ,%al
outb %al , (%dx)
movl $0x3f9, %edx
movb $0 ,%al
outb %al , (%dx)

/* set 8N1 flow dlab=0*/
movl $0x3fb, %edx
movb $0x3 , %al
outb %al , (%dx)

/* disable fifo*/
movl $0x3fa, %edx
movb $0x7 , %al
outb %al , (%dx)

/*  */
movb $0 ,%al
movl $0x3f9, %edx
outb %al , (%dx)
movl $0x3fc, %edx
outb %al , (%dx)
/*  test char */
movl $0x3f8, %edx
ret

boot_ram:
mov $200,%ecx
mov $aabb1122,%ebx
mov %ebx , %eax
mov %ebx , (%ecx)
mov $0 , %ebx
mov (%ecx), %ebx
cmp %ebx , %eax
jz testok
movl $0x3f8, %edx
movb $0x41 , %al
addb %bl , %al
outb %al, (%dx)
jmp final

testok:
movl $0x3f8, %edx
movb $0x42 , %al
addb %bl , %al
outb %al, (%dx)

banner:
mov $0xfffb0, %esi
banner_loop:
movb (%esi),%bl
mov $0,%al
cmp %al,%bl
jz exit_banner
inc %esi
call sendchar
jmp banner_loop
exit_banner:
ret

final:
jmp final

/*  ebda */
.org 0x0300
.byte 0
.byte 0
.byte 0
.byte 0
.byte 0
.byte 0
.byte 0
.byte 0
.byte 0
.byte 0
.byte 0
.byte 0
.byte 0
.byte 0

/*  cmdline */
.org 0x0320
.asciz "console=ttyS0,115200n8 root=/dev/ram0 rw"

/* banner */
.org 0x03b0
.ascii "Boot copy flash"
.byte 10
.byte 13
.byte 0

/*  init jump bios */
.org 0x3d0
.code16
start2:
jmp start

.org 0x3f0
.code16
jmp start2
