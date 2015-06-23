;
; bank 0  - counters
; bank 1  - expected values
;
; @7f error code
;

	ajmp start;
	
	.org 03h	;external interrupt 0
	ajmp ei0	;

	.org 0bh	;t/c 0 interrupt
	ajmp tc0	;

	.org 13h	;external interrupt 1
	ajmp ei1	;

	.org 1bh	;t/c 1 interrupt
	ajmp tc1	;

	.org 23h	;serial interface interrupt
	setb b.4	;
	clr scon.0		;
	clr scon.1		;
	reti;

ei0:
	setb b.0;
	mov c, 0		;
	jc stop0		;
	clr 2		;
	reti;

tc0:
	setb b.1;
	mov c, 1		;
	jc stop1	;
	clr 3		;
	reti;

ei1:
	setb b.2;
	mov c, 2		;
	jc stop2	;
	clr 0		;
	reti;

tc1:
	setb b.3;
	mov c, 3		;
	jc stop3	;
	clr 1		;
	reti;


stop0:
	nop;
	mov c, 0	;
	jc stop0	;
	reti		;
stop1:
	nop;
	mov c, 1	;
	jc stop1	;
	reti		;
stop2:
	nop;
	mov c, 2	;
	jc stop2	;
	reti		;
stop3:
	nop;
	mov c, 3	;
	jc stop3	;
	reti		;

wait:
	nop		;
	nop		;
	dec a		;
	jnz wait	;
	ret;

error:
	mov psw, #00h		;
	mov p1, 7fh		;
loop0:
	nop		;
	ajmp loop0		;

test:
	subb a, b		;
	jnz error		;
	ret		;
	
test_tcon:
	subb a, tcon		;
	jnz error		;
	ret		;

start:
	clr a
	mov r0, a		;
	mov r1, a		;
	mov r2, a		;
	mov r3, a		;
	mov r4, a		;
	mov 7fh, a		; error 0
	mov 20h, a		; 
	mov sp, #02fh		;
;
; testing interrupt enable interrupt enable register
;
; ea (ie.7)
;
	mov ie, #00fh		;
	mov sbuf, #00h		;
	mov tmod, #033h	; t/c 0 and 1 in mode 3
	mov th0, #0fdh		;load timer 0
	mov tl0, #0fch		;
	mov tcon, #050h		;
	clr p3.4		;
	clr p3.3		;
	mov 7fh, #001h		; error 1
	mov a, #010h		;
	acall wait		;
	clr tcon.6		;
	clr tcon.4		;
	clr a		;
	acall test		;
	mov a, #0aah		;
	mov 7fh, #002h		; error 2
	acall test_tcon		;
	mov tcon, #00h		;
	mov a, #00ah		;
	acall test_tcon		;
	setb p3.4		;
	setb p3.3		;
	mov a, #00h		;
	acall test_tcon		;
	clr scon.0		;
	clr scon.1		;

;
; ie
;
	mov tcon, #005h		; external interrupts are edge sensitive
	mov ie, #099h		;
	mov th0, #0fdh		;load timer 0
	mov tl0, #0fch		;
	mov tcon, #055h		;
	mov sbuf, #098h		;
	clr p3.4		;
	clr p3.3		;
	setb p3.4		;
	setb p3.3		;
	mov 7fh, #003h		; error 3
	mov a, #010h		;
	acall wait		;
	clr tcon.6		;
	clr tcon.4		;
	mov a, #019h		;
	acall test		;
	mov 7fh, #004h		; error 4
	mov a, #02dh		;
	acall test_tcon		;

	mov b,#000h		;
	mov ie, #09fh		;
	mov 7fh, #005h		; error 5
	mov a, #010h		;
	acall wait		;
	clr tcon.6		;
	clr tcon.4		;
	mov a, #006h		;
	acall test		;
	mov 7fh, #006h		; error 6
	mov a, #005h		;
	acall test_tcon		;
;
; software interrupts
;
	mov b,#000h		;
	mov tcon, #0afh		;
	setb scon.0		;
	mov 7fh, #007h		; error 7
	mov a, #005h		;
	acall wait		;
	mov a, #01fh		;
	acall test		;
	mov 7fh, #008h		; error 8
	mov a, #005h		;
	acall test_tcon		;

	mov p0, #001h		;
;
; interrupt prioriti test
;
	mov b,#000h		;
	mov ie, #08fh		;
	mov ip, #003h		;
	mov 20, #00ch		;
	mov tcon, #0afh		;
	mov 7fh, #009h		; error 9
	mov a, #005h		;
	acall wait		;
	mov a, #00fh		;
	acall test		;
	mov 7fh, #00ah		; error a
	mov a, #005h		;
	acall test_tcon		;

	mov b,#000h		;
	mov ip, #00ch		;
	mov 20, #003h		;
	mov tcon, #0afh		;
	mov 7fh, #00bh		; error b
	mov a, #005h		;
	acall wait		;
	mov a, #00fh		;
	acall test		;
	mov 7fh, #00ch		; error c
	mov a, #005h		;
	acall test_tcon		;

	mov p0, #002h		;
