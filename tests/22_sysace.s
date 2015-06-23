.code16
start:

# CSR_ACE_BUSMODE = ACE_BUSMODE_16BIT;
movw $0xe200, %dx
movw $0x0001, %ax
outw %ax, %dx

# if(!(CSR_ACE_STATUSL & ACE_STATUSL_CFDETECT)) return 0;
movw $0xe204, %dx
inw  %dx, %ax
andw $0x0010, %ax
jne  cf_detect
movw $0x2, (0)
hlt
cf_detect:

# if((CSR_ACE_ERRORL != 0) || (CSR_ACE_ERRORH != 0)) return 0;
movw $0xe208, %dx
inw  %dx, %ax
cmpw $0x0, %ax
jne  error_l

movw $0xe20a, %dx
inw  %dx, %ax
cmpw $0x0, %ax
je   lock_req
error_l:
movw $0x3, (0)
hlt
lock_req:

# CSR_ACE_CTLL |= ACE_CTLL_LOCKREQ;
movw $0xe218, %dx
inw  %dx, %ax
orw  $0x2, %ax
outw %ax, %dx

# timeout = TIMEOUT;
movw $0xffff, %cx

# while((timeout > 0) && (!(CSR_ACE_STATUSL & ACE_STATUSL_MPULOCK))) timeout--;
movw $0xe204, %dx
ace_statusl:
inw  %dx, %ax
andw $0x2, %ax
loopz ace_statusl

# if(timeout == 0) return 0;
cmpw $0x0, %cx
jnz  success
movw $0x4, (0)
hlt

success:
# We are going to read the first block
xor %bx, %bx

# timeout = TIMEOUT;
movw $0xffff, %cx

# while((timeout > 0) && (!(CSR_ACE_STATUSL & ACE_STATUSL_CFCMDRDY))) timeout--;
movw $0xe204, %dx
ace_statusl2:
inw  %dx, %ax
andw $0x100, %ax
loopz ace_statusl2

# if(timeout == 0) return 0;
cmpw $0x0, %cx
jnz  success2
movw $0x5, (0)
hlt

success2:
movw $0x4, (2)
# CSR_ACE_MLBAL = blocknr & 0x0000ffff;
# CSR_ACE_MLBAH = (blocknr & 0x0fff0000) >> 16;
xorw %ax, %ax
movw $0xe210, %dx
outw %ax, %dx
movw $0xe212, %dx
outw %ax, %dx

movw $0x5, (2)
# CSR_ACE_SECCMD = ACE_SECCMD_READ|0x01;
movw $0x0301, %ax
movw $0xe214, %dx
outw %ax, %dx

movw $0x6, (2)
# CSR_ACE_CTLL |= ACE_CTLL_CFGRESET;
movw $0xe218, %dx
inw  %dx, %ax
orw  $0x0080, %ax
outw %ax, %dx

movw $0x7, (2)
# buffer_count = 16;
movw $16, %si

movw $0x8, (2)
# while(buffer_count > 0) {
cond_loop:
cmpw $0, %si
jbe  exit_loop

# timeout = TIMEOUT;
movw $0xffff, %cx

# while((timeout > 0) && (!(CSR_ACE_STATUSL & ACE_STATUSL_DATARDY))) timeout--;
movw $0xe204, %dx
ace_statusl3:
inw  %dx, %ax
andw $0x20, %ax
loopz ace_statusl3

# if(timeout == 0) return 0;
cmpw $0x0, %cx
jnz  success3
movw $0x6, (0)
hlt

success3:
# for(i=0;i<16;i++) {
movw $16, %cx
# *bufw = CSR_ACE_DATA;
movw $0xe240, %dx
ace_data:
inw  %dx, %ax
movw %ax, (%bx)
# bufw++;
addw $2, %bx
# }
loop ace_data

# buffer_count--;
decw %si
jmp cond_loop

# }
exit_loop:

# CSR_ACE_CTLL &= ~ACE_CTLL_CFGRESET;
movw $0xe218, %dx
inw  %dx, %ax
andw $0xff7f, %ax
outw %ax, %dx

hlt

.org 65520
jmp start
.org 65535
.byte 0xff

