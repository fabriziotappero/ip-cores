.186
.model tiny
.code
        org 100h
start: 
      cli
      mov ax,30h
      mov ss,ax
      mov sp,100h
      push 0f000h
	pop ds
      mov al,34h
      out 43h,al
      xor al,al
      out 40h,al
      out 40h,al 
      
	
	mov si,0e000h
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
	db 0eah
      dw 0,-1    


; ----------------  serial receive byte 115200 bps --------------
srecb:  mov ah,80h
        mov dx,3dah
        mov cx,-5aeh ; (half start bit)
srstb:  in al,dx
	  shr al,2
	  jc srstb

        in al,40h ; lo counter
        add ch,al
        in al,40h ; hi counter, ignore

l1:
        call dlybit
	  in al,dx
        shr al,2
	  rcr ah,1
	  jnc l1

dlybit:
        sub cx,0a5bh  ;  (full bit)
dly1:
        in al,40h
        cmp al,ch
        in al,40h
        jnz dly1
        ret


end start
