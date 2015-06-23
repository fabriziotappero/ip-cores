;
; r0 - scon
; r1 - sbuf
; r2 - transnit test
; r3 - receive test
; r4 - pcon
;
	ajmp start;
	
	org 03h		;external interrupt 0
	reti;

	org 0bh		;t/c 0 interrupt
	setb p3.1	;
	clr p3.1	;
	reti;

	org 13h		;external interrupt 1
	reti;

	org 1bh		;t/c 1 interrupt
	reti;

	org 23h		;serial interface interrupt
	clr scon.4		;
	clr scon.0		;
	clr scon.1		;
  inc b		;
	reti;

	nop;
	nop;
wait:
	mov a,b		;
	jz wait		;
	ret		;

wait_txd:
	movx a, @r0		;
	jnb acc.1, wait_txd	;
	ret		;


	nop;
	nop;

test_txd:
	clr c		;
	movx a, @r1	;
	subb a, r2	;
	jnz error	;
	ret		;

	nop;
	nop;

test_rxd:
	clr c		;
	mov a, sbuf	;
	subb a, r3	;
	jnz error	;
	ret		;

	nop;
	nop;


start:
	clr a;
	mov 7fh, a	; error 0
	clr p3.7	;
	clr p3.0	;
	mov ie, #090h	; enable interrupts
	mov r0, #098h	; serial control address
	mov r1, #099h	; serial data buffer address
	mov dpl, #087h	; pcon
	mov dph, #000h	;

;
; testing mode 0
;
; transmit
;
	mov scon, #000h	; mode 0
	mov b,#000h	;
	mov a, #010h	;
	mov r2, #06ch	;
	mov sbuf, r2	; transmit 6c
	movx @r0, a	;
	acall wait	;
	acall test_txd	;
	mov c, p3.0	;
	jnc error	;
;
; receive
;
	setb ie.7	;
	mov a, #000h	;
	movx @r0,a	;
	mov 7fh, #001h	; error 1
	nop		;
	nop		;
	nop		;
	nop		;
	mov c, p3.0	;
	jc error	;
	mov 7fh, #002h	; error 2
	mov b,#000h	;
	mov a, #0d3h	;
	mov r3, a		;
	movx @r1, a		;
	mov scon, #010h		;
	acall wait		;
	acall test_rxd		;
	mov c, p3.0	;
	jnc error	;

	mov p0, #00h		;
	ajmp mode1		;

error:
	mov p2, 7fh		;
loop:
	nop			;
	ajmp loop		;

;
; mode 1
;
; transmit
;
mode1:
	mov b,#000h		;
	mov ie, #092h		;
	mov 7fh, #003h		; error 3
	clr p3.1		;
	mov a, #050h		; external mode 1 receive
	movx @r0, a		;
	mov scon, #040h		;
	mov th0, #0ech		;
	mov tl0, #0ech		;
	mov th1, #0ech		;
	mov tl1, #0ech		;
	mov tmod, #022h		;
	setb tcon.4		;
	setb tcon.6		;
	mov r2, #095h		;
	mov sbuf, r2		; start transmition
	acall wait		;
	clr tcon.4		;
	clr tcon.6		;
	acall test_txd		;
;
; receive
;
	mov 7fh, #004h		; error 4
	mov b, #000h		;
	mov a, #040h		;
	movx @r0, a		;
	mov scon, #050h		;
	mov a, #0a2h		;
	mov r3, a		;
	setb tcon.4		;
	setb tcon.6		;
	movx @r1, a		;
	acall wait		;
	acall wait_txd		;

	clr tcon.4		;
	clr tcon.6		;
	acall test_rxd		;
	mov 7fh, #005h		; error 5
	mov c, scon.2		;
	jnc error		;



;
; transmit / receive
;
	mov b,#000h		;
	mov ie, #082h		;
	mov 7fh, #006h		; error 6
	mov a, #050h		; external mode 1 receive
	movx @r0, a		;
	mov scon, #050h		;
	setb tcon.4		;
	setb tcon.6		;
	mov r2, #097h		;
	mov sbuf, r2		; start transmition
	mov a, #0d5h		;
	mov r3, a		;
	movx @r1, a		;
loop0:
	mov c, scon.1		;
	jnc loop0		;
	mov c, scon.0		;
	jnc loop0		;
	clr tcon.4		;
	clr tcon.6		;
	clr c		;
	acall test_txd		;
	mov 7fh, #007h		; error 7
	acall test_rxd		;
	clr scon.1		;
	clr scon.0		;

	mov p0, #01h		;


;
; mode 2 
;
; transmit
;
	mov b,#000h	;
	mov ie, #090h		;
	mov 7fh, #008h		; error 8
	mov a, #090h		; external mode 2 receive
	movx @r0, a		;
	mov scon, #080h		;
	mov r2, #095h		;
	mov sbuf, r2		; start transmition
	acall wait		;
	acall test_txd		;
;
; receive 1
;
	mov 7fh, #009h		; error 9
	mov b, #000h		;
	mov a, #088h		;
	movx @r0, a		;
	mov scon, #090h		;	
	mov a, #0a2h		;
	mov r3, a		;
	movx @r1, a		;
	acall wait		;
	acall test_rxd		;
	mov 7fh, #00ah		; error a
	mov c, scon.2		;
	jnc error1		;
;
; receive 2
;
	setb ie.7	;
	mov 7fh, #00bh		; error b
	mov b, #000h		;
	mov a, #080h		;
	movx @r0, a		;
	mov scon, #0b0h		;	
	mov a, #0b2h		;
	mov r3, a		;
	movx @r1, a		;
loop1:
	nop			;
	nop			;
	dec a   		;
	jnz   loop1		;
	acall test_rxd		;
	mov 7fh, #00ch		; error c
	mov a, b		;
	jnz error1		;
;
; transmit / receive
;
	mov b,#000h		;
	mov ie, #000h		;
	mov 7fh, #00dh		; error d
	mov a, #090h		; external mode 2 receive
	movx @r0, a		;
	mov a, #080h		;
	movx @dptr, a		;
	mov pcon, a		;
	mov scon, #090h		;
	mov r2, #097h		;
	mov sbuf, r2		; start transmition
	mov a, #0d5h		;
	mov r3, a		;
	movx @r1, a		;
loop2:
	mov c, scon.1		;
	jnc loop2		;
	mov c, scon.0		;
	jnc loop2		;
	acall test_txd		;
	mov 7fh, #00eh		; error e
	acall test_rxd		;
	clr scon.1		;
	clr scon.0		;

	mov p0, #02h		;
	ajmp mode3		;

error1:
	ljmp error		;

;
; mode 3
;
; transmit
;
mode3:
	mov b,#000h	;
	mov ie, #092h		;
	mov 7fh, #00fh		; error f
	mov a, #0d0h		; external mode 3 receive
	movx @r0, a		;
	mov scon, #0c0h		;
	mov r2, #095h		;
	setb tcon.4		;
	setb tcon.6		;
	mov sbuf, r2		; start transmition
	acall wait		;
	clr tcon.4		;
	clr tcon.6		;
	acall test_txd		;
;
; receive
;
	setb ie.7	;
	mov 7fh, #010h		; error 10
	mov b, #000h		;
	mov a, #0c0h		;
	movx @r0, a		;
	mov scon, #0d4h		;	
	mov a, #0a2h		;
	mov r3, a		;
	movx @r1, a		;
	setb tcon.4		;
	setb tcon.6		;
	acall wait		;
	acall wait_txd		;

	clr tcon.4		;
	clr tcon.6		;
	acall test_rxd		;
	mov 7fh, #011h		; error 11
	mov c, scon.2		;
	jc error1		;
;
; transmit / receive
;
	mov scon, #0d8h		;
	mov b,#000h		;
	mov ie, #082h		;
	mov 7fh, #012h		; error 12
	mov a, #0d0h		; external mode 3 receive
	movx @r0, a		;
	mov r2, #097h		;
	setb tcon.4		;
	setb tcon.6		;
	mov sbuf, r2		; start transmition
	mov a, #0d5h		;
	mov r3, a		;
	movx @r1, a		;
loop3:
	mov c, scon.1		;
	jnc loop3		;
	mov c, scon.0		;
	jnc loop3		;
	clr tcon.4		;
	clr tcon.6		;
	acall test_txd		;
	mov 7fh, #013h		; error 13
	acall test_rxd		;
	clr scon.1		;
	clr scon.0		;
	mov 7fh, #014h		; error 14
	mov c, scon.2		;
	jc error2		;
	movx a, @r0		;
	subb a, #0d7h		;

done:
	mov p0, #03h		;
	ajmp done		;

error2:
	ljmp error		;


	end
