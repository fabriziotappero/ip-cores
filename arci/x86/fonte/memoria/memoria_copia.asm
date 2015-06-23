%include "../../macro/macro.inc"

bits 32
;==============================================================================
codigi_global memoria_copia
;==============================================================================
push edi
push esi
mov edi,[esp+0x0c]
mov esi,[esp+0x10]
mov edx,[esp+0x14]

.itera
cmp edx,0x20
jae .prefasa
mov ecx,edx
rep movsb
pop esi
pop edi
ret

.prefasa
mov eax,esi
mov ecx,0x10
and eax,0x0f
jz .fonte_aliniada
sub ecx,eax
sub edx,ecx
rep movsb

.fonte_aliniada
cmp edx,0x80
hwnt jae .copia_0x80_prefasa

.copia_0x10_prefasa
mov ecx,edx
and ecx,0x0f
sub edx,ecx
mov eax,edi
and eax,0x0f
jz .copia_0x10_aliniada

.copia_0x10
movaps xmm0,[esi]
movups [edi],xmm0
add esi,0x10
add edi,0x10
sub edx,0x10
hst jnz .copia_0x10
rep movsb
pop esi
pop edi
ret

.copia_0x10_aliniada
movaps xmm0,[esi]
movaps [edi],xmm0
add esi,0x10
add edi,0x10
sub edx,0x10
hst jnz .copia_0x10_aliniada
rep movsb
pop esi
pop edi
ret

.copia_0x80_prefasa
mov ecx,edx
and ecx,0x7f
mov eax,edi
sub edx,ecx
and eax,0x0f
jz .copia_0x80_aliniada

.copia_0x80
movaps xmm0,[esi+0x00]
movaps xmm1,[esi+0x10]
movaps xmm2,[esi+0x20]
movaps xmm3,[esi+0x30]
movaps xmm4,[esi+0x40]
movaps xmm5,[esi+0x50]
movaps xmm6,[esi+0x60]
movaps xmm7,[esi+0x70]
movups [edi+0x00],xmm0
movups [edi+0x10],xmm1
movups [edi+0x20],xmm2
movups [edi+0x30],xmm3
movups [edi+0x40],xmm4
movups [edi+0x50],xmm5
movups [edi+0x60],xmm6
movups [edi+0x70],xmm7
add esi,0x80
add edi,0x80
sub edx,0x80
hst jnz .copia_0x80
mov edx,ecx
jmp .itera

.copia_0x80_aliniada
movaps xmm0,[esi+0x00]
movaps xmm1,[esi+0x10]
movaps xmm2,[esi+0x20]
movaps xmm3,[esi+0x30]
movaps xmm4,[esi+0x40]
movaps xmm5,[esi+0x50]
movaps xmm6,[esi+0x60]
movaps xmm7,[esi+0x70]
movaps [edi+0x00],xmm0
movaps [edi+0x10],xmm1
movaps [edi+0x20],xmm2
movaps [edi+0x30],xmm3
movaps [edi+0x40],xmm4
movaps [edi+0x50],xmm5
movaps [edi+0x60],xmm6
movaps [edi+0x70],xmm7
add esi,0x80
add edi,0x80
sub edx,0x80
hst jnz .copia_0x80_aliniada
mov edx,ecx
jmp .itera
