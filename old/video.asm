@ l0 : temp
@ l1 : constant 1
@ l2 : current address for memwrites
@ l3 : temp, holds the value received from uart
@ h1 : toggle bit = 0 zero, when a full 16 Bit word was received
@ h2 : holds the bitmask of the invalid instruction 0xffff = special with
@ l4 : temp, used for branch condition

80:
  ldi   l2, 0x80
  lsi   l2, 0x40     @ start of user program
  
  ldi   h2, 0xff     
  lsi   h2, 0xff     @ h2 = 0xffff  

  ldi   l1, 1        @ constant 1
  ldi   h1, 0        @ toggle bit (hi low)
  stio  h2, [h1]     @ leds echo


1: @ wait for byte
  ldi   l0, 0x80     @ uart status address
  ldio  l3, [l0]
  ldi   h0, 2        @ uart data ready bit
  and   l4, l3, h0
  brz   l4, :1
  ldi   h0, 0x81     @ uart data address
  

  ldio  l3, [h0]     @ uart rcv
  xor	h1, h1, l1   @ toggle state (16 bit Ready)
  stio  l3, [h0]     @ uart echo (uart should be ready at this point)
  ldi   h0, 0x00	 @ leds address
  stio  l3, [h0]     @ leds echo
  brz   h1, :2  
  nop		     @ hier könnte leds echo sein (nop wegen evtl.  Simulator bug)


  @ olny first half (LSB) of instruction was received  
  brnz  h1, :1
  mov   h3, l3	     @ h3: holds 16-bit instr (here LSB are set)  
 

2: @ full 16-Bit instruction is ready
  shi   l3, 8        @ move received 8 bits
  or    h3, h3, l3   @ merge the two instructionbytes 
  stio  h3, [l2]     @ write instruction to programm-mem
  xor   l4, h3, h2   @ check if the instruction writen to pmem is 0xffff  
  brnz  l4, :1
  adi   l2, 1	     @ increase program-write address	

@@ programm loaded

@ jump to begin of loaded program
  ldi   l0, 0x40
  jump  <l0>
  nop



