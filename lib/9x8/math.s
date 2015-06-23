; Copyright 2014-2015, Sinclair R.F., Inc.
;
; Unsigned arithmetic operations.

.IFNDEF D__INCLUDED__MATH_S__
.define D__INCLUDED__MATH_S__

; Notation:
;   ux_n is the n'th byte of ux where n=0 is the LSB
;         example:  ( u0_0 u0_1 ) are the LSB and MSB of a 2-byte 16-bit value.
;   u0 and u1 are two input vectors, us is their sum

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Add two unsigned 8-bit values to produce an unsigned 16-bit value.
; Method:  calculate and push the carry bit onto the return stack, calculate the
;          8-bit sum of the two 8-bit values, use the previously stored and
;          computed carry bit as the MSB of the 16-bit return value.
; 6 instructions
;
; ( u0 u1 - us_0 us_1 )
.function math__add_u8_u8_u16
  ; ( u_0 u_1 - u_0 u_1 ) r:( - c )
  ; ( u0 u1 - us_0 us_1 )
  +c >r + r>
  .return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; miscellaneous unsigned addition operations

; ( u0_0 u0_1  u0 - us_0 us_1 )
; 9 instructions
.function math__add_u16_u8_u16
  ; ( u0_0 u0_1 u1 - u0_0 u1 ) r:( - u0_1  )
  swap >r
  ; ( u0_0 u1 - us_0 c_0 )
  +c >r + r>
  ; ( c_0 - us_1 ) r:( u0_1 )
  r> .return(+)

; ( u0_0 u0_1 u1 - us_0 us_1 us_2 )
; 13 instructions
.function math__add_u16_u8_u24
  ; ( u0_0 u0_1 u1 - u0_0 u1 ) r:( - u0_1 )
  swap >r
  ; ( u0_0 u1 - us_0 c_0 )
  +c >r + r>
  ; ( c_0 - us_1 us_2 ) r:( u0_1  - )
  r> +c >r + r>
  .return

; ( u0_0 u0_1 u0_2 u1 - us_0 us_1 us_2 )
.function math__add_u24_u8_u24
  swap >r .call(math__add_u16_u8_u24)
  r> .return(+)

; ( u0_0 u0_1 u0_2 u1 - us_0 us_1 us_2 us_3 )
.function math__add_u24_u8_u32
  swap >r .call(math__add_u16_u8_u24)
  r> .call(math__add_u8_u8_u16)
  .return

.function math__add_u32_u8_u32
  swap >r .call(math__add_u24_u8_u32)
  r> .return(+)

.function math__add_u32_u16_u32
  >r .call(math__add_u32_u8_u32)
  r> .call(math__add_u24_u8_u24)
  .return

.function math__add_u32_u24_u32
  >r .call(math__add_u32_u16_u32)
  r> .call(math__add_u16_u8_u16)
  .return

.function math__add_u32_u32_u32
  >r .call(math__add_u32_u24_u32)
  r> .return(+)

.ENDIF ; D__INCLUDED__MATH_S__
