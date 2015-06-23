; Copyright 2012, Sinclair R.F., Inc.
;
; Test the core instructions.

.memory RAM ram
.variable fred 3 -3
.variable joe  0*6

.main

  ; Test the left rotation instructions.
  -1 <<0 <<1 <<msb <<msb <<msb <<msb <<msb <<msb <<msb <<msb drop

  ; Test the right rotation instructions.
  -1 0>> 1>> msb>> msb>> msb>> msb>> msb>> msb>> lsb>> lsb>> drop

  ; Test the "dup" instruction.
  3 4 dup 0<> dup nip nip nip drop

  ; Test the "over" instruction.
  3 4 over 0<> nip nip drop

  ; Test the >r, r@, and r> instructions.
  3 >r -1 >r r@ r> r@ r> nip nip nip drop

  ; Test the "swap" instruction.
  3 4 swap nip drop

  ; Test the addition and subtraction instructions.
  8 5 - 7 + drop

  ; Test the comparison operations
  0  0=  drop 8  0=  drop 0xFF  0=  drop
  0  0<> drop 8  0<> drop 0xFF  0<> drop
  0 -1=  drop 8 -1=  drop 0xFF -1=  drop
  0 -1<> drop 8 -1<> drop 0xFF -1<> drop

  ; Test the bitwise logical operators
  0x11 0x12 &  drop
  0x11 0x12 or drop
  0x11 0x12 ^  drop

  ; Test the increment and decrement operators
  0xFE 1+ 1+ 1+ 1- 1- 1- drop

  ;
  ; Test the memory access operators.
  ;

  ; get the two pre-loaded values for "fred"
  .fetchvector(fred,2) drop drop

  ; Set the entire RAM "ram" to 0xFF.
  ${size['ram']-1} :set_mem 0xFF swap .jumpc(set_mem,.store-(ram)) drop

  ; Ensure "fred" was changed.
  .fetchvector(fred,2) drop drop

  ; Fetch, alter, and store the first value in "joe" using raw ".fetch(ram)" and ".store(ram)" macros.
  joe .fetch(ram) 1- joe .store(ram) drop

  ; Do the same using ".fetchvalue" and ".storevalue" macros.
  .fetchvalue(joe) 1- .storevalue(joe) .fetchvalue(joe) drop

  ; Do the same to the third element of "joe".
  2 .fetchindexed(joe) 1- 2 .storeindexed(joe) ${joe+2} .fetch(ram) drop

  ; Check the ".storevector" and ".fetch+" macros.
  6 7 .storevector(fred,2) fred .fetch+(ram) .fetch(ram) drop drop

  ; Test "call" and "callc" opcodes.
  .call(test_callc,3) drop

  ; Test the carry bit operations
  0xBF 0x41 +c - +c - +c drop drop drop
  0x00 0x02 -c - -c - -c drop drop drop

  ; Hang in an infinite loop.
  :infinite .jump(infinite)

; Function to test "callc" opcode
; ( u - \sum_n=1^u{n} )
.function test_callc
  dup 1- .callc(test_callc,nop) .return(+)
