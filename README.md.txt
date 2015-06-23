==TinyCPU==

TinyCPU is an 8-bit processor designed to be small, yet fairly fast. 

Goals:

The goals of TinyCPU are basically to have a small 8-bit processor that can be embedded with minimal logic required, but also fast enough to do what's needed.
With these goals, I try to lay out instructions in a way so that they are trivial to decode, for instance, nearly all ALU opcodes fit within 2 opcode groups,
and the ALU is arranged so that no translation needs to be done to decode these groups. It is also designed to be fast. Because XST failed at synthesizing
every attempt I threw at multi-port registerfiles, I instead decided to make it braindead simple and just provide a port for every register. This means that
every register can be accessed at the same time, preventing me from having to worry about how many registers are accessed in an opcode, and therefore enabling
very rich opcodes. Also, with the standard opcode format, decoding should hopefully be a breeze involving basically only 2 or 3 states. 

Features:
1. Single clock cycle for all instructions without memory access
2. Two clock cycles for memory access instructions
3. 7 general purpose registers arranged as 2 banks of 4 registers, as well as 2 fixed registers
4. IP and SP are treated as normal registers, enabling very intuitive opcodes such as "push and move" without polluting the opcode space
5. Able to use up to 255 input and output ports
6. Fixed opcode size of 2 bytes
7. Capable of addressing up to 65536 bytes of memory with 4 segment registers for "extended" memory accesses
8. Conditional execution is built into every opcode
9. Von Neuman machine, ie data is code and vice-versa


Plans:

Although a lot of the processor is well underway and coded, there is still some minor planning taking place. The instruction list is still not formalized
and as of this writing, there is still room for 3 "full" opcodes, and 4 opcodes in a group not completely allocated.

Software:

I can already tell getting software running on this will be difficult, though I have a plan for loading software through the UART built into the papilio-one. 
Also, I will create a fairly awesome assembler for this architecture using the DSL capabilities of Ruby. I created a prototype x86 assembler in Ruby before, so
it shouldn't be any big deal.. and it should be a lot easier than writing an assembler in say C... Also, I have no immediate plans of porting a C compiler.
This is mainly because of the small segment size(just 256 bytes).. though I'm considering adding a way to "extend" segments in some way without changing the opcode
format. 

Oddities:

I used this opportunity to try out my "JIT/JIF" comparison mechanism. Basically, instead of doing something like

cmp r0,r1
jgt .greater
mov r0,0xFF
.greater:
mov r1,0x00

You can instead do
cmp_greater_than r0,r1
jit .greater --jit=jump if true
mov r0,0xFF
.greater:
mov r1,0x00

or because of the awesome conditional execution that's built in:

cmp greater_than r0,r1
mov_if_true r0,0xFF
mov r1,0x00


Short comings:

This truth-register mechanism is unlike anything I've ever seen, and I'm really curious as to how it will act in actual logic. Because of how it works, conditional jumps are needed
a lot less often, which in the future could mean less cache missing (if I ever implement a cache, that is) It's only bad part is that multiple comparisons are needed
when doing something like `if r0>0 and r0<10 then r3=0`:

mov r4,0
mov r5,10
cmp_greater r0,r4
jif .skip
cmp_lessthan r0,r5
mov_if_true r3,0
.skip:
;continue on

Another apparent thing is that code size is going to be difficult to keep down, especially since each segment can only contain 128 instructions.
One possible solution is adding a "overflow into segment" option where when IP rolls over from 255 to 0, it will also increment CS by 1