        .global main                    // int main(void)

        .global _etext                  // -> .data initial values in ROM
        .global _data                   // -> .data area in RAM
        .global _edata                  // end of .data area
        .global __bss_start             // -> .bss area in RAM
        .global __bss_end__             // end of .bss area
        .global _stack                  // top of stack

// Stack Sizes
        .set  UND_STACK_SIZE, 0x00000080
        .set  ABT_STACK_SIZE, 0x00000080
        .set  FIQ_STACK_SIZE, 0x00000080
        .set  IRQ_STACK_SIZE, 0X00000080
        .set  SVC_STACK_SIZE, 0x00000080

// Standard definitions of Mode bits and Interrupt flags in MSRs
        .set  MODE_USR, 0x10            // User Mode
        .set  MODE_FIQ, 0x11            // FIQ Mode
        .set  MODE_IRQ, 0x12            // IRQ Mode
        .set  MODE_SVC, 0x13            // Supervisor Mode
        .set  MODE_ABT, 0x17            // Abort Mode
        .set  MODE_UND, 0x1B            // Undefined Mode
        .set  MODE_SYS, 0x1F            // System Mode

        .equ  FIQ_BIT, 0x40             // when FIQ bit is set, FIQ is disabled
        .equ  IRQ_BIT, 0x80             // when IRQ bit is set, IRQ is disabled

        .text
        .code 32
        .align 2

        .global _boot
        .func   _boot
_boot:

// Runtime Interrupt Vectors
// -------------------------------------------------------------------
Vectors:
        b     _start                    // reset - _start
        b     .                         // undefined
        b     .                         // SWI
        b     .                         // program abort
        b     .                         // data abort
        nop                             // reserved
        b     .                     	// IRQ
        b     .                         // FIQ

        .size _boot, . - _boot
        .endfunc


// Setup the operating mode & stack.
// -------------------------------------------------------------------
        .global _start, start, _mainCRTStartup
        .func   _start

_start:
start:
_mainCRTStartup:

// Who am I? Where am I going?

// - Set stack location for system mode with interrupts disabled
// -------------------------------------------------------------------
        ldr   r0,=_stack                    // Calc stack base
		mrs   r1,CPSR
		bic   r1,r1,#0x7F
        orr   r1,r1,#MODE_SYS|IRQ_BIT|FIQ_BIT  // Change to System Mode
        msr   CPSR,r1
        mov   sp,r0                         // Store stack base


// Call main program: main(0)
// -------------------------------------------------------------------
        mov   r0,#0                     // no arguments (argc = 0)
        mov   r1,r0
        mov   r2,r0
        mov   fp,r0                     // null frame pointer
        mov   r7,r0                     // null frame pointer for thumb
        ldr   r10,=main
        mov   lr,pc
        mov   pc, r10                   // enter main()

        .size   _start, . - _start
        .endfunc

        .global _reset, reset, exit, abort
        .func   _reset
_reset:
reset:
exit:
abort:

        b     .                         // loop until reset

        .size _reset, . - _reset
        .endfunc

        .end
