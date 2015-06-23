.186
.model tiny
.code
zero: 
        org 24h
srecv label near  
        org 100h
start:   
        xor ax,ax
        mov es,ax
        mov word ptr es:[10h*4], offset int10
        mov es:[10h*4+2], cs
        mov word ptr es:[11h*4], offset int11
        mov es:[11h*4+2], cs
        mov ax,1
        mov ax,cs
        mov es,ax

newline:
        mov di, offset buf 
        mov cx, 15              
newchar:
        int 10h
        mov al,ah
        stosb
        int 11h
        cmp al,8
        jne nobs
        sub di,2
        cmp di,offset buf
        jae nobs
        mov di,offset buf
nobs:
        cmp al,13
        jz nc1
        loop newchar
        mov al,13
        stosb
        int 11h
nc1:        
        mov byte ptr [di-1], 0
        mov si,offset buf
        cmp byte ptr [si],'d'
        jne nodump

        mov cx,8
        xor si,si
 dl1:       
        mov dx,16
        push cx
        call dumpline
        mov al,13
        int 11h
        pop cx
        loop dl1
   
        jmp cr    
nodump:        
        call prtstr
        mov al, '?'
        int 11h
cr:        
        mov al,13
        int 11h
        jmp newline

buf     db 16 dup(0)

;--------------------------------- receive char INT10 -----------------------------------
int10:  ; get RS232 char in ah
        push cx
        call srecv
        pop cx
        iret

;--------------------------------- send char INT11 -----------------------------------
int11:  ; write RS232 char from al
        push ax
        push cx
        out 0,al
        mov ah,1
        add ax,ax
int111:
        out 1,al
        mov cx,0adh;8bh;90h
even         
        loop $
        shr ax,1
        jnz int111
        pop cx
        pop ax
        iret

;--------------------------------- print string at SI -----------------------------------
prtstr:
        lodsb
        test al,al
        jz prtstr1
        int 11h
        jmp prtstr
prtstr1:
        ret     

;--------------------------------- print 4 digit hex number in ax -------------------------------
prthex4: 
        xchg ah,al
        call prthex2
        mov al,ah
;--------------------------------- print 2 digit hex number in al -------------------------------
prthex2: 
        mov bx, offset hexdigit
        push ax
        shr al,4
        xlat
        int 11h
        pop ax
        and al,15
        xlat
        int 11h
        ret
hexdigit db "0123456789ABCDEF"

;-------------------------------- dump DX bytes memory at DS:SI -------------------------------
dumpline:
        mov ax,ds
        call prthex4
        mov al, ':'
        int 11h
        mov ax,si
        call prthex4
        mov cx,dx
        mov al,' '
        int 11h
dump1:
        mov al, ' '
        int 11h
        lodsb
        call prthex2
        loop dump1
        mov cx,dx
        sub si,dx 
        mov al,' '
        int 11h
        int 11h       
dump2:
        lodsb
        sub al,32
        cmp al,128-32
        jb dump3
        mov al,'.'-32
dump3:  add al,32      
        int 11h
        loop dump2
        ret

end start
