; Copyright 2013, Sinclair R.F., Inc.
; Test bench for AXI4-Lite master peripheral.

.main

  ; Write 4 bytes.
  0x0F 0x01 0x02 0x03 0x04 .call(alm_write_u32,0x7C)

  ; Read 4 bytes.
  .call(alm_read_u32,0x7C)

  ; Write the gray code of the address to all of memory
  0x80 :loop_write_all
    4 - >r
    0x0F r@ ${4-1} :loop_4 >r
      dup dup 0>> ^ swap 1+
    r> .jumpc(loop_4,1-) drop drop
    r@ .call(alm_write_u32)
  r> .jumpc(loop_write_all,nop) drop

  ; Issue several reads.
  0x40 :loop_read >r
    r@ .call(alm_read_u32)
    ${4-1} :loop_diag >r .outport(O_DIAG_DATA) r> .jumpc(loop_diag,1-) drop
  r> .jumpc(loop_read,0>>) drop

  ; Send termination strobe to the test bench and then wait forever.
  .outstrobe(O_DONE)
  :infinite .jump(infinite)

; Read a 32-bit value at a 32-bit aligned address.
; ( u_addr - u_LSB u u u_MSB )
.function alm_read_u32
  ; Output the 7-bit address.
  .outport(O_ALM_ADDRESS)
  ; Issue the strobe that starts the read process.
  .outstrobe(O_ALM_CMD_READ)
  ; Wait for the read process to finish.
  :wait .inport(I_ALM_BUSY) .jumpc(wait)
  ; Read the 4 bytes
  ${4-1} :loop_read .inport(I_ALM_READ_BYTE) swap .jumpc(loop_read,1-) drop
  .return

; Issue a write
; ( u_we u_LSB u u u_MSB u_addr - )
.function alm_write_u32
  ; Output the 7-bit address.
  .outport(O_ALM_ADDRESS)
  ; Output the 4 data bytes, MSB first.
  ${4-1} :loop_data swap .outport(O_ALM_DATA) .jumpc(loop_data,1-) drop
  ; Ensure all 4 bytes are written.
  .outport(O_ALM_WE)
  ; Issue the strobe that starts the write.
  .outstrobe(O_ALM_CMD_WRITE)
  ; Wait for the write process to finish.
  :wait .inport(I_ALM_BUSY) .jumpc(wait)
  .return
