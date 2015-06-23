; this is the bootstrap code contained in SRAM.coe initialization file

.186
.model tiny
.code
      org 0
start:	
      mov ax,0ff80h
	mov ss,ax
	mov ds,ax
	mov es,ax
	mov sp,100h
	
	mov si,com
	call srecb
	mov bh,ah
	call srecb
	mov bl,ah

sloop:	
	call srecb
	mov [si],ah
	inc si
	dec bx
	jnz sloop
	jmp exec

; ----------------  serial receive byte 115200 bps --------------
srecb:	
      mov ah,80h
	mov cx,56h
srstb:
	in al,0
	and al,1
	jnz srstb
      nop
l1:
	loop l1

rnxtb:
	mov cl,adh
l2:
	loop l2
	test al,80h
	jnz return		
	in al,0
	ror ax,1
	jmp rnxtb
return:
	ret
exec: jmp com

      org 100h
com:
      

end start