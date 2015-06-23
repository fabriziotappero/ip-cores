; Copyright 2013, Sinclair R.F., Inc.
; Test bench for ../../char.s

.include char.s

.main

  ; Test the single hex digit to nibble conversion.
  0x00 ${ord('0')-1} '0' '9' ${ord('9')+1} ${ord('A')-1} 'A' 'F' ${ord('F')+1} ${ord('a')-1} 'a' 'f' ${ord('f')+1}
  ${13-1} :loop__hex_to_nibble .call(test__hex_to_nibble,swap) .jumpc(loop__hex_to_nibble,1-) drop

  ; Test dual hex digit to nibble conversion.
  "0A" "0F" "0G" "A0" "F0" "G0"
  ${6-1} :loop__2hex_to_byte >r .call(test__2hex_to_byte) r> .jumpc(loop__2hex_to_byte,1-) drop

  ; Test the nibble to hex digit conversion.
  0x00 0x09 0x0A 0x0F
  ${4-1} :loop__nibble_to_hex .call(test__nibble_to_hex,swap) .jumpc(loop__nibble_to_hex,1-) drop

  ; Test the byte to 2-digit hex conversion.
  0x00 0x09 0x0A 0x0F 0x90 0x99 0x9A 0x9F 0xA0 0xA9 0xAA 0xAF 0xF0 0xF9 0xFA 0xFF
  ${16-1} :loop__byte_to_2hex .call(test__byte_to_2hex,swap) .jumpc(loop__byte_to_2hex,1-) drop

  ; terminate and wait forever
  .outstrobe(O_TERMINATE) :infinite .jump(infinite)

; Evaluate the nibble to hex conversion and the output the error status, the
; converted value, and the original value.
.function test__byte_to_2hex
  .call(char__byte_to_2hex,dup) .outport(O_VALUE) .outport(O_VALUE) .outport(O_VALUE) .return

; Evaluate the nibble to hex conversion and the output the error status, the
; converted value, and the original value.
.function test__nibble_to_hex
  .call(char__nibble_to_hex,dup) .outport(O_VALUE) .outport(O_VALUE) .return

; Evaluate the 2-digit hex to byte conversion and the output the error status,
; the converted value, and the original values.
.function test__2hex_to_byte
  over .call(char__2hex_to_byte,over) .outport(O_VALUE) .outport(O_VALUE) .outport(O_VALUE) .outport(O_VALUE) .return

; Evaluate the hex to nibble conversion and the output the error status, the
; converted value, and the original value.
.function test__hex_to_nibble
  .call(char__hex_to_nibble,dup) .outport(O_VALUE) .outport(O_VALUE) .outport(O_VALUE) .return
