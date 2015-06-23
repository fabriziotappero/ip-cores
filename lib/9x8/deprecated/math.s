; Copyright 2012, Sinclair R.F., Inc.
;
; Multi-byte arithmetic

; Notation:  Multi-byte values on the stack are xx[n] where n=0 is the least
;            significant byte of the value

.function add_u16_u8__u16 ; ( u0[0] u0[1] u1[0] - us[0] us[1] )
  swap >r +uu r> +
.return

.function add_u16_u8__u24 ; ( u0[0] u0[1] u1[0] - us[0] us[1] us[2] )
  swap >r +uu r> +uu
.return

.function add_u16_u16__u16 ; ( u0[0] u0[1] u1[0] u1[1] - us[0] us[1] )
  >r .call(add_u16_u8__u16) r> +
.return

.function add_u16_u16__u24 ; ( u0[0] u0[1] u1[0] u1[1] - us[0] us[1] us[2] )
  >r .call(add_u16_u8__u24) r> .call(add_u16_u8__u16)
.return

.function add_u24_u8__u24 ; ( u0[0] u0[1] u0[2] u1[0] - us[0] us[1] us[2] )
  swap >r .call(add_u16_u8__u24) r> +
.return

.function add_u24_u8__u32 ; ( u0[0] u0[1] u0[2] u1[0] - us[0] us[1] us[2] u[3] )
  swap >r .call(add_u16_u8__u24) r> +uu
.return

.function add_u24_u16__u24 ; ( u0[0] u0[1] u0[2] u1[0] u1[1] - us[0] us[1] us[2] )
  >r .call(add_u24_u8__u24) r> .call(add_u16_u8__u16)
.return

.function add_u24_u16__u32 ; ( u0[0] u0[1] u0[2] u1[0] u1[1] - us[0] us[1] us[2] us[3] )
  >r .call(add_u24_u8__u32) r> .call(add_u24_u8__u24)
.return

.function add_u24_u24__u24 ; ( u0[0] u0[1] u0[2] u1[0] u1[1] u1[2] - us[0] us[1] us[2] )
  >r .call(add_u24_u16__u24) r> +
.return

.function add_u24_u24__u32 ; ( u0[0] u0[1] u0[2] u1[0] u1[1] u1[2] - us[0] us[1] us[2] us[3] )
  >r .call(add_u24_u16__u32) r> .call(add_u16_u8__u16)
.return

.function add_u32_u8__u32 ; ( u0[0] u0[1] u0[2] u0[3] u1[0] - us[0] us[1] us[2] us[3] )
  swap >r .call(add_u24_u8__u32) r> +
.return

.function add_u32_u16__u32 ; ( u0[0] u0[1] u0[2] u0[3] u1[0] u1[1] - us[0] us[1] us[2] us[3] )
  >r .call(add_u32_u8__u32) r> .call(add_u24_u8__u24)
.return

.function add_u32_u24__u32 ; ( u0[0] u0[1] u0[2] u0[3] u1[0] u1[1] u1[2] - us[0] us[1] us[2] us[3] )
  >r .call(add_u32_u16__u32) r> .call(add_u16_u8__u16)
.return

.function add_u32_u32__u32 ; ( u0[0] u0[1] u0[2] u0[3] u1[0] u1[1] u1[2] u1[3] - us[0] us[1] us[2] us[3] )
  >r .call(add_u32_u24__u32) r> +
.return
