; Copyright 2013, 2015, Sinclair R.F., Inc.
;
; 8-bit unsigned vs. unsigned comparison operators

.IFNDEF D__INCLUDED__CMP_8BIT_UU_S__
.define D__INCLUDED__CMP_8BIT_UU_S__

; Compare two unsigned 8-bit values for equality.
; ( u1 u2 - f"u1 = u2" )
.function cmp_8bit_uu_eq
  - .return(0=)

; Compare two unsigned 8-bit values for inequality.
; ( u1 u2 - f"u1 != u2" )
.function cmp_8bit_uu_ne
  - .return(0<>)

; Return true if the unsigned value u1 is less than the unsigned value u2.
; Method:  If the msb of u1 and u2 are the same, then then msb of the difference
;          indicates which one is larger.  Otherwise the msb of u1 indicates
;          which one is larger.
; ( u1 u2 - f"u1 < u2" )
.function cmp_8bit_uu_lt
  over over ^ 0x80 & .jumpc(different)
    - 0x80 & .return(0<>)
  :different
    drop 0x80 & .return(0=)

; Return true if the unsigned value u1 is greater than or equal to the unsigned
; value u2.
; ( u1 u2 - f"u1 >= u2" )
.function cmp_8bit_uu_ge
  .call(cmp_8bit_uu_lt) .return(0=)

; Return true if the unsigned value u1 is less than or equal to the unsigned
; value u2.
; ( u1 u2 - f"u1 <= u2" )
.function cmp_8bit_uu_le
  .call(cmp_8bit_uu_lt,swap) .return(0=)

; Return true if the unsigned value u1 is greater than the unsigned value u2.
; ( u1 u2 - f"u1 > u2" )
.function cmp_8bit_uu_gt
  .call(cmp_8bit_uu_lt,swap) .return

; Return the smaller of two unsigned values.
; ( u1 u2 - min(u1,u2) )
.function min_u8
  ; ( u1 u2 - u1 u2 f"u1 >= u2" )
  over .call(cmp_8bit_uu_lt,over) 0=
  ; ( u1 u2 f"u1 >= u2" - u1 u2 ) r:( - f"u1 >= u2" )
  >r
  ; (u1 u2 - u1 u2-u1 )
  over -
  ; ( u1 u2-u1 - u1 u2-u1 f"u1 >= u2" ) r:( f"u1 >= u2" - )
  r>
  ; if u1<u2:  ( u1 u2-u1 f"u1 >= u2" - u1 0 )
  ; otherwise: ( u1 u2-u1 f"u1 >= u2" - u1 u2-u1 )
  &
  ; ( u1 uX - min(u1,u2) )
  .return(+)

.ENDIF ; D__INCLUDED__CMP_8BIT_UU_S__
