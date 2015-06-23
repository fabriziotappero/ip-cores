; Copyright 2013, 2015, Sinclair R.F., Inc.
;
; Character manipulation functions

.IFNDEF D__INCLUDED__CHAR_S__
.define D__INCLUDED__CHAR_S__

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Convert to and from binary.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Convert a single binary digit to its byte value.  Return 0x00 on success and
; 0xFF on failure.
; ( u_binary_n - u f )
.function char__binary_to_byte
  '0' -
  dup 0xFE & .jumpc(error)
  .return(0)
  :error .return(0xFF)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Convert to and from hex.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Convert a byte to its 2-digit hex representation with the digit for the most
; significant nibble at the top of the data stack.
; ( u - u_hex_lsn u_hex_msn )
.function char__byte_to_2hex
  ; ( u - u u_hex_lsn )
  dup 0x0F .call(char__nibble_to_hex,&)
  ; ( u u_hex_lsn - u_hex_lsn u_hex_msn )
  swap 0>> 0>> 0>> .call(char__nibble_to_hex,0>>)
  .return

; Convert a byte to the minimal 1 or 2 digit hex representation with the digit
; for the most significant nibble at the top of the data stack.
; ( u - u_hex_lsn u_hex_msn ) or ( u - u_hex_lsn )
.function char__byte_to_hex
  dup 0xF0 & .jumpc(include_msn)
    .call(char__nibble_to_hex) .return
  :include_msn
    .call(char__byte_to_2hex) .return

; Convert a 4 byte value to its 8-digit hexadecimal representation.
; ( u_LSB u u u_MSB - )
.function char__4byte_to_8hex
  >r >r >r >r
  ${4-1} :loop r> swap >r .call(char__byte_to_2hex) r> .jumpc(loop,1-)
  .return(drop)

; Convert a nibble between 0x00 and 0x0F inclusive to it hex digit.
; ( u - u_hex_n )
.function char__nibble_to_hex
  0x09 over - 0x80 & 0<> ${ord('A')-ord('9')-1} & + '0' .return(+)

; Convert two hex digits to their byte value.  Return 0x00 on success and 0xFF
; on failure.
; ( u_hex_lsn u_hex_msn - u f )
.function char__2hex_to_byte
  ; convert the msn to its position and save the error indication
  ; ( u_hex_lsn u_hex_lsn - u_hex_msn u_msn ) r:( - f_msn )
  .call(char__hex_to_nibble) >r <<0 <<0 <<0 <<0
  ; ( u_hex_lsn u_msn - u ) r:( f_msn - f_lsn f_msn )
  ; convert the lsn to its position, save the error indication, and combine the two nibble conversions
  .call(char__hex_to_nibble,swap) >r or
  ; compute the return status and return
  ; ( u - u f ) r:( f_lsn f_msn - )
  r> r> .return(or)

; Convert a single hex digit to its nibble value.  Return 0x00 on success and
; 0xFF on failure.
; ( u_hex_n - u f )
.function char__hex_to_nibble
  dup        0x80 & .jumpc(error)
  dup '0'  - 0x80 & .jumpc(error)
  '9' over - 0x80 & .jumpc(not_value_0_to_9) '0' - .return(0)
  :not_value_0_to_9
  dup 'A'  - 0x80 & .jumpc(error)
  'F' over - 0x80 & .jumpc(not_value_A_to_F) ${ord('A')-10} - .return(0)
  :not_value_A_to_F
  dup 'a'  - 0x80 & .jumpc(error)
  'f' over - 0x80 & .jumpc(error) ${ord('a')-10} - .return(0)
  :error .return(0xFF)

.ENDIF ; D__INCLUDED__CHAR_S__
