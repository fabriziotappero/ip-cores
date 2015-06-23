;
; test lcall and bit addressable memory space
;
	mov 20h, #00h	;
	setb  02h	;
	lcall t		;
	mov P0, 20h	;
	ljmp e		;

t:
	mov P0, #10	;
	ret	;
e:
	nop	;
	nop	;

;
; test p bit in psw
;
	mov r0, #0f0h	;
	mov a, #031h	;    p=1
	mov c, psw.0	;
	jnc error	;
	mov p0, #001h	;
	mov r0, #0f1h	;
	mov a, #063h	;    p=0
	mov c, psw.0	;
	jc error	;
	mov P0, #02h	;
	jnz test1	;
	nop
	nop
	nop
test1:
	ljmp test	;

error:
	mov p1, r0;

;
; test relative jumps
;


	org 01f0h	;
test_r1:
	nop		;
	mov p0, #33h	;
	ajmp test_r2	;

	org 0210h
test:
	mov b, #04h	;
	clr a		;
	jz test_r1	;

	org 02f0h	;
	mov r0, #00	;
	ljmp error	;

test_r2:
	mov b, #05h	;
	mov r4, #10h	;
	mov r5, #20h	;
	mov a, r4	;
	subb a, #10h	;
	jnz error1	;
	mov a, r5	;
	subb a, #20h	;
	jnz error1	;
	
	mov b, #06h	;
	mov r4, b	;
	mov a, r5	;
	subb a, #20h	;
	jnz error1	;
	mov a, r4	;
	subb a, #06h	;
	jnz error1	;
	mov b, #06h	;

	mov r0, #02h	;
	mov a, #044h	;
	mov b, #044h	;
	subb a, b	;
	jnz error1	;

	mov r0, #03h	;
	mov a, #04h	;
	mov b, #084h	;
	clr b.7		;
	subb a, b	;
	jnz error1	;

	mov r0, #03h	;
	mov a, #04h	;
	mov b, #084h	;
	clr b.7		;
	subb a, b	;
	jnz error1	;

	mov r0, #04h	;
	mov psw, #00h	;
	setb c		;
	mov a, #0e4h	;
	subb a, #04h	;
	mov a, psw	;
	subb a, #041h	;
	jnz error1	;
	ajmp test_lcall ;

error1:
	ljmp error	;
;;;;;;;;;;;;;;;;;;

test_lcall:
	mov r0, #05h	;
	clr a		;
	lcall tst1	;
	inc a		;
	subb a, #3h	;
	jnz error1	;
	ljmp done	;
	inc a		;
	inc a		;
tst1:
	lcall tst2	;
	inc a		;
	ret		;
	inc a		;
	inc a		;

tst2:
	inc a		;
	ret		;
	inc a		;
	inc a		;

;;;;;;;;;;;;;;;;;;

done:
	nop		;
	mov p0, #34h	;
	ajmp done	;


end


