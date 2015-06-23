; Copyright 2014, Sinclair R.F., Inc.
; Test bench for ../../math.s

.include math.s

.macro push16
.macro push24
.macro push32

.main

  ; Test u8 + u8 ==> u16
  0x7F 0x80
  0x7F 0x81
  0x80 0x7F
  0x80 0x80
  0x80 0x81
  0xFF 0x00
  0xFF 0x01
  0xFF 0x02
  0xFF 0xFE
  0xFF 0xFF
  ${10-1} :loop__u8_u8_u16 >r
    .call(out8,over)
    .call(out8,dup)
    .call(math__add_u8_u8_u16) .call(out16)
    .outstrobe(O_VALUE_DONE)
  r> .jumpc(loop__u8_u8_u16,1-) drop

  .push16(0x007F) 0x80
  .push16(0x007F) 0x81
  .push16(0x0080) 0x7F
  .push16(0x0080) 0x80
  .push16(0x0080) 0x81
  .push16(0x00FF) 0x00
  .push16(0x00FF) 0x01
  .push16(0x00FF) 0x02
  .push16(0x00FF) 0xFE
  .push16(0x00FF) 0xFF
  .push16(0x017F) 0x80
  .push16(0x017F) 0x81
  .push16(0x0180) 0x7F
  .push16(0x0180) 0x80
  .push16(0x0180) 0x81
  .push16(0x01FF) 0x00
  .push16(0x01FF) 0x01
  .push16(0x01FF) 0x02
  .push16(0x01FF) 0xFE
  .push16(0x01FF) 0xFF
  ${20-1} :loop__u16_u8_u16 >r
    >r over .call(out16,over)
    r> .call(out8,dup)
    .call(math__add_u16_u8_u16) .call(out16)
    .outstrobe(O_VALUE_DONE)
  r> .jumpc(loop__u16_u8_u16,1-) drop

  .push24(0x0001FF) 0xFF
  ${1-1} :loop__u24_u8_u24 >r
    >r .call(preserve_out24) r>
    .call(out8,dup)
    .call(math__add_u24_u8_u24)
    .call(out24)
    .outstrobe(O_VALUE_DONE)
  r> .jumpc(loop__u24_u8_u24,1-) drop

  .push24(0x0001FF) 0xFF
  ${1-1} :loop__u24_u8_u32 >r
    >r .call(preserve_out24) r>
    .call(out8,dup)
    .call(math__add_u24_u8_u32)
    .call(out32)
    .outstrobe(O_VALUE_DONE)
  r> .jumpc(loop__u24_u8_u32,1-) drop

  .push32(0x00800000) 0xFF
  ${1-1} :loop__u32_u8_u32 >r
    >r .call(preserve_out32) r>
    .call(out8,dup)
    .call(math__add_u32_u8_u32)
    .call(out32)
    .outstrobe(O_VALUE_DONE)
  r> .jumpc(loop__u32_u8_u32,1-) drop

  .push32(${0x00800000+0*1280*960*4}) .push24(${1280*960*4})
  .push32(${0x00800000+1*1280*960*4}) .push24(${1280*960*4})
  .push32(${0x00800000+2*1280*960*4}) .push24(${1280*960*4})
  .push32(${0x00800000+3*1280*960*4}) .push24(${1280*960*4})
  .push32(${0x00800000+4*1280*960*4}) .push24(${1280*960*4})
  ${5-1} :loop__u32_u24_u32 >r
    >r >r >r .call(preserve_out32) r> r> r>
    .call(preserve_out24)
    .call(math__add_u32_u24_u32)
    .call(out32)
    .outstrobe(O_VALUE_DONE)
  r> .jumpc(loop__u32_u24_u32,1-) drop

  .push32(${0x00800000+0*1280*960*4}) .push32(${1280*960*4})
  .push32(${0x00800000+1*1280*960*4}) .push32(${1280*960*4})
  .push32(${0x00800000+2*1280*960*4}) .push32(${1280*960*4})
  .push32(${0x00800000+3*1280*960*4}) .push32(${1280*960*4})
  .push32(${0x00800000+4*1280*960*4}) .push32(${1280*960*4})
  ${5-1} :loop__u32_u32_u32 >r
    >r >r >r >r .call(preserve_out32) r> r> r> r>
    .call(preserve_out32)
    .call(math__add_u32_u32_u32)
    .call(out32)
    .outstrobe(O_VALUE_DONE)
  r> .jumpc(loop__u32_u32_u32,1-) drop

  ; terminate and wait forever
  .outstrobe(O_TERMINATE) :infinite .jump(infinite)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Routines to output results.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.function preserve_out24
  0 .outport(O_VALUE)
  .outport(O_VALUE,>r)
  .outport(O_VALUE,>r)
  O_VALUE outport
  r> r>
  .return

.function preserve_out32
  .outport(O_VALUE,>r)
  .outport(O_VALUE,>r)
  .outport(O_VALUE,>r)
  O_VALUE outport
  r> r> r>
  .return

.function out8
  0 0 0 .call(out32) .return

.function out16
  0 0 .call(out32) .return

.function out24
  0 .call(out32) .return

.function out32
  ${4-1} :loop swap .outport(O_VALUE) .jumpc(loop,1-) drop
  .return
