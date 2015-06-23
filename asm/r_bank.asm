	ajmp start		;
;
; testing bank register select
;
error:
	mov p1, psw		;
loop:
	nop		;
	nop		;
	ajmp loop		;

start:
	clr a
	mov r0, a		; bank 0
	mov r4, #040h		;
	mov psw, #008h		; bank 1
	mov r0, #001h		;
	mov r4, #041h		;
	mov psw, #010h		; bank 2
	mov r0, #002h		;
	mov r4, #042h		;
	mov psw, #018h		; bank 3
	mov r0, #003h		;
	mov r4, #043h		;

	mov p0, #00h		;

	mov psw, #010h		; bank 2
	mov a, r0		;
	subb a, #002h		;
	jnz error		;
	mov a, r4		;
	subb a, #042h		;
	jnz error		;

	mov p0, #01h		;

	mov psw, #008h		; bank 1
	mov a, r0		;
	subb a, #001h		;
	jnz error		;
	mov a, r4		;
	subb a, #041h		;
	jnz error		;

	mov p0, #02h		;

	mov psw, #018h		; bank 3
	mov a, r0		;
	subb a, #003h		;
	jnz error		;
	mov a, r4		;
	subb a, #043h		;
	jnz error		;

	mov p0, #03h		;

	mov psw, #000h		; bank 0
	mov a, r0		;
	jnz error		;
	mov a, r4		;
	subb a, #040h		;
	jnz error		;

	mov p0, #04h		;
