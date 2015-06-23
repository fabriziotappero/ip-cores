;void memoria_copia(n1 *dst,n1 *fnt,nN cuantia)
;{
; nN conta;
; for(conta = 0;conta<cuantia;conta++)
; {
;  dst[conta]=fnt[conta];
; }
;}
%include "../../macro/macro.inc"

bits 64
;==============================================================================
codigi_global memoria_copia
;==============================================================================
cmp rdx,0x20
jae .prefasa
mov ecx,edx
rep movsb
ret

.prefasa
mov eax,esi
mov ecx,0x10
and eax,0x0f
jz .fonte_aliniada
sub ecx,eax
sub rdx,rcx
rep movsb

.fonte_aliniada
cmp rdx,0x100
hwnt jae .copia_0x100_prefasa

.copia_0x10_prefasa
mov ecx,edx
and ecx,0x0f
sub rdx,rcx
mov eax,edi
and eax,0x0f
jz .copia_0x10_aliniada

.copia_0x10
movaps xmm0,[rsi]
movups [rdi],xmm0
add rsi,0x10
add rdi,0x10
sub rdx,0x10
hst jnz .copia_0x10
rep movsb
ret

.copia_0x10_aliniada
movaps xmm0,[rsi]
movaps [rdi],xmm0
add rsi,0x10
add rdi,0x10
sub rdx,0x10
hst jnz .copia_0x10_aliniada
rep movsb
ret

.copia_0x100_prefasa
mov ecx,edx
and ecx,0xff
mov eax,edi
sub rdx,rcx
and eax,0x0f
jz .copia_0x100_aliniada

.copia_0x100
movaps xmm0,[rsi+0x00]
movaps xmm1,[rsi+0x10]
movaps xmm2,[rsi+0x20]
movaps xmm3,[rsi+0x30]
movaps xmm4,[rsi+0x40]
movaps xmm5,[rsi+0x50]
movaps xmm6,[rsi+0x60]
movaps xmm7,[rsi+0x70]
movaps xmm8,[rsi+0x80]
movaps xmm9,[rsi+0x90]
movaps xmm10,[rsi+0xa0]
movaps xmm11,[rsi+0xb0]
movaps xmm12,[rsi+0xc0]
movaps xmm13,[rsi+0xd0]
movaps xmm14,[rsi+0xe0]
movaps xmm15,[rsi+0xf0]
movups [rdi+0x00],xmm0
movups [rdi+0x10],xmm1
movups [rdi+0x20],xmm2
movups [rdi+0x30],xmm3
movups [rdi+0x40],xmm4
movups [rdi+0x50],xmm5
movups [rdi+0x60],xmm6
movups [rdi+0x70],xmm7
movups [rdi+0x80],xmm8
movups [rdi+0x90],xmm9
movups [rdi+0xa0],xmm10
movups [rdi+0xb0],xmm11
movups [rdi+0xc0],xmm12
movups [rdi+0xd0],xmm13
movups [rdi+0xe0],xmm14
movups [rdi+0xf0],xmm15
add rsi,0x100
add rdi,0x100
sub rdx,0x100
hst jnz .copia_0x100
mov edx,ecx
jmp memoria_copia

.copia_0x100_aliniada
movaps xmm0,[rsi+0x00]
movaps xmm1,[rsi+0x10]
movaps xmm2,[rsi+0x20]
movaps xmm3,[rsi+0x30]
movaps xmm4,[rsi+0x40]
movaps xmm5,[rsi+0x50]
movaps xmm6,[rsi+0x60]
movaps xmm7,[rsi+0x70]
movaps xmm8,[rsi+0x80]
movaps xmm9,[rsi+0x90]
movaps xmm10,[rsi+0xa0]
movaps xmm11,[rsi+0xb0]
movaps xmm12,[rsi+0xc0]
movaps xmm13,[rsi+0xd0]
movaps xmm14,[rsi+0xe0]
movaps xmm15,[rsi+0xf0]
movaps [rdi+0x00],xmm0
movaps [rdi+0x10],xmm1
movaps [rdi+0x20],xmm2
movaps [rdi+0x30],xmm3
movaps [rdi+0x40],xmm4
movaps [rdi+0x50],xmm5
movaps [rdi+0x60],xmm6
movaps [rdi+0x70],xmm7
movaps [rdi+0x80],xmm8
movaps [rdi+0x90],xmm9
movaps [rdi+0xa0],xmm10
movaps [rdi+0xb0],xmm11
movaps [rdi+0xc0],xmm12
movaps [rdi+0xd0],xmm13
movaps [rdi+0xe0],xmm14
movaps [rdi+0xf0],xmm15
add rsi,0x100
add rdi,0x100
sub rdx,0x100
hst jnz .copia_0x100_aliniada
mov edx,ecx
jmp memoria_copia
