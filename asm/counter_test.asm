; r0: counter 0 owerflov counter
; r1: counter 1 owerflov counter
; r2: error code
; r3: counter high expected value
; r4: counter low expected value
; r5: owerflov counter expected value

	ajmp start;

	org 03h		;external interrupt 0
	reti;

	org 0bh		;t/c 0 interrupt
	inc r0;
	reti;

	org 13h		;external interrupt 1
	reti;

	org 1bh		;t/c 1 interrupt
	inc r1;
	reti;

	org 23h		;serial interface interrupt
	reti;


test0:
	mov a, th0	;
	subb a, r3	;
	jnz error	;
	inc r2		;
	mov a,tl0	;
	subb a, r4	;
	jnz error	;
	inc r2		;
	mov a, r0	;
	subb a, r5	;
	jnz error	;
	ret;

test1:
	mov a, th1	;
	subb a, r3	;
	jnz error	;
	inc r2		;
	mov a,tl1	;
	subb a, r4	;
	jnz error	;
	inc r2		;
	mov a, r1	;
	subb a, r5	;
	jnz error	;
	ret;

wait:
	dec a		; 1
	nop		; 1
	nop		; 1
	nop		; 1
	nop		; 1
	nop		; 1
	nop		; 1
	nop		; 1
	jnz wait	; 4
	ret		; 4


error:
	mov p0, r2;
	nop;
	ajmp error;


start:
	clr a;
	mov r0, a;
	mov r1, a;
	mov ie, #08ah	;enable interrupts
	clr c;

;
; timer 0 test
;
; mode 0
;
	mov tmod, #004h	;t/c 0 and t/c 1 in counter mode 0
	mov th0, #000h	;load counter 0
	mov tl0, #000h	;
	mov tcon, #010h	;start counter 0;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	clr tcon.4	;stop counter 0
	mov r2, #010h	;
	mov r3, #000h	;
	mov r4, #003h	;
	mov r5, #000h	;
	acall test0	;

	mov tl0, #01ch	; load counter 0
	setb tcon.4	;start counter0
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	clr tcon.4	;stop counter 0
	mov r2, #020h	;
	mov r3, #001h	;
	mov r4, #000h	;
	mov r5, #000h	;
	acall test0	;

	mov tl0, #01ch	;
	mov th0, #0ffh	;
	setb tcon.4	;start counter 0
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	clr tcon.4	;stop counter 0
	mov r2, #030h	;
	mov r3, #000h	;
	mov r4, #001h	;
	mov r5, #001h	;
	acall test0	;
;
; mode 1
;
	mov tmod, #005h	; t/c 0 in mode 1
	mov th0, #000h	;load counter 0
	mov tl0, #000h	;
	setb tcon.4	;start counter 0;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	clr tcon.4	;stop counter 0
	mov r2, #040h	;
	mov r3, #000h	;
	mov r4, #004h	;
	mov r5, #001h	;
	acall test0	;

	mov tl0, #0fch	; load counter 0
	setb tcon.4	;start counter 0;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	clr tcon.4	;stop counter 0;
	mov r2, #050h	;
	mov r3, #001h	;
	mov r4, #001h	;
	mov r5, #001h	;
	acall test0	;

	mov tl0, #0fch	;
	mov th0, #0ffh	;
	setb tcon.4	;start counter 0
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	clr tcon.4	;stop counter 0
	mov r2, #060h	;
	mov r3, #000h	;
	mov r4, #002h	;
	mov r5, #002h	;
	acall test0	;
;
; mode 2
;
	mov tmod, #006h	; t/c 0 in mode 2
	mov th0, #000h	;load counter 0
	mov tl0, #005h	;
	setb tcon.4	;start counter 0;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	clr tcon.4	;stop counter 0
	mov r2, #070h	;
	mov r3, #000h	;
	mov r4, #009h	;
	mov r5, #002h	;
	acall test0	;

	mov tl0, #0fch	; load counter 0
	mov th0, #050h	;
	setb tcon.4	;start counter 0;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	clr tcon.4	;stop counter 0;
	mov r2, #080h	;
	mov r3, #050h	;
	mov r4, #051h	;
	mov r5, #003h	;
	acall test0	;
;
; mode 3
;
	mov tmod, #007h	; t/c 0 in mode 3
	mov th0, #000h	;load counter 0
	mov tl0, #000h	;
	setb tcon.4	;start counter 0;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	clr tcon.4	;stop counter 0
	mov r2, #090h	;
	mov r3, #000h	;
	mov r4, #004h	;
	mov r5, #003h	;
	acall test0	;

	mov tl0, #0fch	; load counter 0
	mov th0, #000h	;
	setb tcon.4	;start counter 0
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	clr tcon.4	;stop counter 0
	mov r2, #0a0h	;
	mov r3, #000h	;
	mov r4, #002h	;
	mov r5, #004h	;
	acall test0	;

	mov tl0, #000h	; load counter 0
	mov th0, #000h	;
	setb tcon.6	; start counter 1
	mov a, #03h	;
	acall wait	;
	nop;
	nop;
	nop;
	clr tcon.6	; stop counter 1
	mov r2, #0b0h	;
	mov r3, #004h	;
	mov r4, #000h	;
	mov r5, #004h	;
	acall test0	;

	mov tl0, #000h	; load counter 0
	mov th0, #0fch	;
	setb tcon.6	;start counter 1
	mov a, #05h	;
	acall wait	;
	nop;
	nop;
	nop;
	clr tcon.6	;stop counter 1
	mov r2, #0c0h	;
	mov r3, #003h	;
	mov r4, #000h	;
	mov r5, #001h	;
	mov r0, 01h	;
	acall test0	;

	mov p0, #001h	; test counter 0 done!
	mov r1, #000h	;

;
; timer 1 test
;
; mode 0
;
	mov tmod, #040h	;t/c 0 and t/c 1 in counter mode 0
	mov th1, #000h	;load counter 1
	mov tl1, #000h	;
	mov tcon, #040h	;start counter 1;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	clr tcon.6	;stop counter 1
	mov r2, #018h	;
	mov r3, #000h	;
	mov r4, #004h	;
	mov r5, #000h	;
	acall test1	;

	mov tl1, #01ch	; load counter 1
	setb tcon.6	;start counter 1
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	clr tcon.6	;stop counter 1
	mov r2, #028h	;
	mov r3, #001h	;
	mov r4, #001h	;
	mov r5, #000h	;
	acall test1	;

	mov tl1, #01ch	;
	mov th1, #0ffh	;
	setb tcon.6	;start counter 1
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	clr tcon.6	;stop counter 1
	mov r2, #038h	;
	mov r3, #000h	;
	mov r4, #002h	;
	mov r5, #001h	;
	acall test1	;
;
; mode 1
;
	mov tmod, #050h	; t/c 1 in counter 1
	mov th1, #000h	;load counter 1
	mov tl1, #000h	;
	setb tcon.6	;start counter 1
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	clr tcon.6	;stop counter 1
	mov r2, #048h	;
	mov r3, #000h	;
	mov r4, #004h	;
	mov r5, #001h	;
	acall test1	;

	mov tl1, #0fch	; load counter 1
	setb tcon.6	; start counter 1
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	clr tcon.6	;stop counter 1
	mov r2, #058h	;
	mov r3, #001h	;
	mov r4, #001h	;
	mov r5, #001h	;
	acall test1	;

	mov tl1, #0fch	;
	mov th1, #0ffh	;
	setb tcon.6	;start counter 1
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	clr tcon.6	;stop counter 1
	mov r2, #068h	;
	mov r3, #000h	;
	mov r4, #002h	;
	mov r5, #002h	;
	acall test1	;
;
; mode 2
;
	mov tmod, #060h	; t/c 1 in mode 2
	mov th1, #000h	;load counter 1
	mov tl1, #005h	;
	setb tcon.6	;start counter 1
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	clr tcon.6	;stop counter 1
	mov r2, #078h	;
	mov r3, #000h	;
	mov r4, #009h	;
	mov r5, #002h	;
	acall test1	;

	mov tl1, #0fch	; load counter 1
	mov th1, #050h	;
	setb tcon.6	;start counter 1
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	clr tcon.6	;stop counter 1
	mov r2, #088h	;
	mov r3, #050h	;
	mov r4, #051h	;
	mov r5, #003h	;
	acall test1	;
;
; mode 3
;
	mov tmod, #070h	; t/c 1 in mode 3
	mov th1, #000h	;load counter 1
	mov tl1, #000h	;
	setb tcon.6	;start counter 1
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	clr tcon.6	;stop counter 1
	mov r2, #098h	;
	mov r3, #000h	;
	mov r4, #000h	;
	mov r5, #003h	;
	acall test1	;

	mov tl1, #0fch	; load counter 1
	mov th1, #0ffh	;
	setb tcon.6	;start counter 1
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	cpl p3.6;


	cpl p3.6;
	cpl p3.6;
	cpl p3.6;
	clr tcon.6	;stop counter 1
	mov r2, #0a8h	;
	mov r3, #0ffh	;
	mov r4, #0fch	;
	mov r5, #003h	;
	acall test1	;

	mov p0, #002h	; test counter 1 done!


end
