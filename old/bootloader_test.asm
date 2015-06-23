@ l0 : temp
@ l1 : constant 1
@ l2 : current address for memwrites
@ l3 : temp, holds the value received from uart
@ h1 : toggle bit = 0 zero, when a full 16 Bit word was received
@ h2 : holds the bitmask of the invalid instruction 0xffff = special with
@ l4 : temp, used for branch condition

  ldi   l2, 0x80
  lsi   l2, 0x40     @ start of user program
  
  ldi   h2, 0xff     
  lsi   h2, 0xff     @ h2 = 0xffff  

  ldi   l1, 1        @ constant 1
  ldi   h1, 0        @ toggle bit (hi low)

1: @ wait for byte
  ldi   l0, 0xc0     @ uart status address
  ldio  l3, [l0]
  nop
  ldi   h0, 2        @ uart data ready bit
  and   l4, l3, h0
  ldi   h0, 0xc1     @ uart data address
  brz   l4, :1
  nop    
  

  ldio  l3, [h0]     @ uart rcv
  nop
  xor	h1, h1, l1   @ toggle state (16 bit Ready)
  stio  l3, [h0]     @ uart echo (uart should be ready at this point)
  nop
  ldi   h0, 0x00
  stio  l3, [h0]     @ leds echo
  nop
  brz   h1, :2  
  nop		     @ hier könnte leds echo sein (nop wegen evtl.  Simulator bug)


  @ olny first half (LSB) of instruction was received  
  mov   h3, l3	     @ h3: holds 16-bit instr (here LSB are set)  
  brnz  h1, :1
  nop

2: @ full 16-Bit instruction is ready
  lsi   l3, 0x00     @ move received 8 bits
  or    h3, h3, l3   @ merge the two instructionbytes 
  stio  l2, [h0]     @ write instruction to programm-mem
  nop
  xor   l4, h3, h2   @ check if the instruction writen to pmem is 0xffff  
  adi   l2, 1	     @ increase program-write address	
  brnz  l4, :1
  nop

@@ programm loaded

@ jump to begin of loaded program
  ldi   l0, 0x40
  nop
  jump  <l0>
  nop