/*
 * Description: UART sample
 */

  .text
  .org    0x0000
	
  /* address for status register */
  ld 	r8, #0x0
  ldhb 	r8, #0x80 
  /* address for uart data register */
  ld 	r9, #0x01
  ldhb 	r9, #0x80
  /* addresses for branch targets */
  ld      r11, addrlo(check_rdrf)
  ldhb    r11, addrhi(check_rdrf)
  ld      r12, addrlo(check_tdre)
  ldhb    r12, addrhi(check_tdre)
	
  /* wait for uart receiver data */
check_rdrf: 
  ld r2, [r8]
  ld R3, #0x2
  and r2, r3
  jmpz r11

  /* data available, read data */
  ld r4, [R9]
  
  /* increment received data by one */
  add r4, #0x1

  /* wait for transmitter register empty */
check_tdre:
  ld r2, [r8]
  ld r3, #0x1
  and r2, r3
  jmpz r12

  /* transmitter register empty: send data */
  st r4, [r9]
  
/* back to start */
jmp r11
