	mov r5, #0a1h;
	mov r4, #054h;
	mov r1, #001h;
	mov r0, #070h;
	lcall DIV16U;
	mov p0, r5;
	mov p0, r4;
	mov p0, r7;
	mov p0, r6;

;
;  testing div
;

  mov a, #0e5h;
  mov b, #072h;
  div ab;
  mov p0, a;
  mov p0, b;
  jnc ok1;
  mov p1, #00h;
  
ok1:
  mov c, psw.2;
  jnc ok2;
  mov p1, #01h;

ok2:
  mov a, #0d3h;
  mov b, #00h;
  div ab;
  jnc ok3;
  mov p1, #02h;

ok3:
  mov c, psw.2;
  jc ok4;
  mov p1, #03h;


;
;testing mul
;

ok4:
  mov a, #03h
  mov b, #04h
  mul ab;
  mov p0, a;
  mov p0, b;
  jnc ok5;
  mov p1, #04h;

ok5:
  mov c, psw.2;
  jnc ok6;
  mov p1, #05h;

ok6:
  mov a, #057h;
  mov b, #0eeh;
  mul ab;
  mov p0, a;
  mov p0, b;
  jnc ok7;
  mov p1, #06h;

ok7:
  mov c, psw.2;
  jc ok8;
  mov p1, #07h;

ok8:
  mov p0, #00h;
  nop
  sjmp ok8;
  




;26 Oct 00 added code to zero remainder when dividend is zero
;26 Oct 00 Change labels from duxxx to duaxxx
;19 Dec 99 corrected comments
;16 Dec 99 made from DIV32U
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;DIV16U is called to divide (unsigned) a 16-bit dividend using a
; 16-bit divisor.
;
;DIV16U solves for quotient and remainder the equation:
;
; dividend = divisor*quotient + remainder
;
;Call:
;  r5,r4 = dividend
;  r1,r0 = divisor
;  lcall DIV16U
;  jc	divide_by_zero
;
;Return:
; r5,r4 = quotient
; r7,r6 = remainder
; c flag set to 1 if divide by zero attempted
; All registers, acc, b and have been changed.
; Data pointer has not been disturbed
;
;Note:
; (1)Most significant (ms) register always listed first when comma
;  separates two in a comment. Example: r5,r4 (r5 contains the ms bits)
; (2) The algorithm used in this code borrows heavily from work posted
;   by John C. Wren who said he got it from a C complier.  
;
;Original author: John Veazey, Ridgecrest, CA, 16 Dec 99
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;cseg
DIV16U:
;
;Clear the working quotient
;
      clr   a
      mov   r2,a
      mov   r3,a
;
;b counts the number of places+1 the divisor was initially
; shifted left to align its ms bit set with the ms bit set
; in the dividend
;
      mov   b,#1
;
;Make an error return if trying to divide by zero
;
      mov   a,r1
      orl   a,r0
      jz    dua920
;
;Just return with quotient and remainder zero if dividend is zero
;
      mov   a,r5;
      orl   a,r4;
      jnz   dua200;
      mov   r7,a;
      mov   r6,a;
      ajmp  dua910      ;Make a normal return
;
;Align the msb set in the demoninator with the msb set in the
; numerator. Increment the shift count in b each time a shift left
; is performed.
;
dua200:
      mov   a,r1	;Stop if MSB set
      rlc   a
      jc    dua600
      clr   c
      mov   a,r5        ;Compare r1 & r5
      subb  a,r1
      jc    dua600      ; jump if r1>r5
      jnz   dua240      ; jump if r1<r5
      mov   a,r4        ;r1=r5, so compare r0 & r4
      subb  a,r0
      jc    dua600      ; jump if r0>r4
dua240:
      clr   c           ;Now shift the denominator
      mov   a,r0        ; left 1 bit position
      rlc   a
      mov   r0,a
      mov   a,r1
      rlc   a
      mov   r1,a
      inc   b           ;Increment b counter and
      sjmp  dua200      ; continue
;
;Compare the shifted divisor with the remainder (what's
; left of the dividend)
;
dua600:
      clr   c
      mov   a,r5
      subb  a,r1
      jc    dua720      ;jump if r1>r5
      jnz   dua700      ;jump if r1<r5
      mov   a,r4
      subb  a,r0
      jc    dua720      ;jump if r0>r4
;
;Divisor is equal or smaller, so subtract it off and
; get a 1 for the quotient
;
dua700:
      mov   a,r4
      clr   c
      subb  a,r0
      mov   r4,a
      mov   a,r5
      subb  a,r1
      mov   r5,a
      clr   c
      cpl   c           ;Get a 1 for the quotient
      sjmp  dua730
;
;Divisor is greater, get a 0 for the quotient
;
dua720:
      clr   c
;
;Shift 0 or 1 into quotient
;
dua730:
      mov   a,r2
      rlc   a
      mov   r2,a
      mov   a,r3
      rlc   a		;Test for overlow removed here because
      mov   r3,a	; it can't happen when dividing 16 by 16
;
;Now shift the denominator right 1, decrement the counter
; in b until b = 0
;
dua740:
      clr   c
      mov   a,r1
      rrc   a
      mov   r1,a
      mov   a,r0
      rrc   a
      mov   r0,a
      djnz  b,dua600
;
;Move quotient and remainder so that quotient is returned in the same
; registers as the dividend. This makes it easier to divide repeatedly
; by the same number as you would do when converting to a new radix.
;
      mov   a,r5
      mov   r7,a
      mov   a,r4
      mov   r6,a
      mov   a,r3
      mov   r5,a
      mov   a,r2
      mov   r4,a
;
;Make the normal return
;
dua910:
      clr   c
      ret
;
;Make the error return
;
dua920:
      clr   c
      cpl   c
      ret
;End of DIV16U
