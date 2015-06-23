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
        ldr   pc,_undf                  // undefined - _undf
        ldr   pc,_swi                   // SWI - _swi
        ldr   pc,_pabt                  // program abort - _pabt
        ldr   pc,_dabt                  // data abort - _dabt
        nop                             // reserved
        ldr   pc,[pc,#-0xFF0]           // IRQ - read the VIC
        ldr   pc,_fiq                   // FIQ - _fiq


// Use this group for development
_undf:  .word __undf                    // undefined
_swi:   .word __swi                     // SWI
_pabt:  .word __pabt                    // program abort
_dabt:  .word __dabt                    // data abort
_irq:   .word __irq                     // IRQ
_fiq:   .word __fiq                     // FIQ

__undf: b     .                         // undefined
__swi:  b     .                         // SWI
__pabt: b     .                         // program abort
__dabt: b     .                         // data abort
__irq:  b     .                         // IRQ
__fiq:  b     .                         // FIQ

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

// Initialize Interrupt System
// - Set stack location for each mode
// - Leave in System Mode with Interrupts Disabled
// ----------------------------------------------------
        ldr   r0,=_stack                    // Calc stack base
		mrs   r1,CPSR
		bic   r1,r1,#0x7F
		orr   r1,r1,#MODE_UND|IRQ_BIT|FIQ_BIT  // Change to Undefined Instruction mode
        msr   CPSR,r1
        mov   sp,r0                         // Store stack base

        sub   r0,r0,#UND_STACK_SIZE         // Calc stack base
		mrs   r1,CPSR
		bic   r1,r1,#0x7F
        orr   r1,r1,#MODE_ABT|IRQ_BIT|FIQ_BIT  // Change to Abort Mode
        msr   CPSR,r1
        mov   sp,r0                         // Store stack base

        sub   r0,r0,#ABT_STACK_SIZE         // Calc stack base
		mrs   r1,CPSR
		bic   r1,r1,#0x7F
        orr   r1,r1,#MODE_FIQ|IRQ_BIT|FIQ_BIT  // Change to FIQ Mode
        msr   CPSR,r1
        mov   sp,r0                         // Store stack base

        sub   r0,r0,#FIQ_STACK_SIZE         // Calc stack base
		mrs   r1,CPSR
		bic   r1,r1,#0x7F
        orr   r1,r1,#MODE_IRQ|IRQ_BIT|FIQ_BIT  // Change to IRQ Mode
        msr   CPSR,r1
        mov   sp,r0                         // Store stack base

        sub   r0,r0,#IRQ_STACK_SIZE         // Calc stack base
		mrs   r1,CPSR
		bic   r1,r1,#0x7F
        orr   r1,r1,#MODE_SVC|IRQ_BIT|FIQ_BIT  // Change to Supervisor Mode
        msr   CPSR,r1
        mov   sp,r0                         // Store stack base

        sub   r0,r0,#SVC_STACK_SIZE         // Calc stack base
		mrs   r1,CPSR
		bic   r1,r1,#0x7F
        orr   r1,r1,#MODE_SYS|IRQ_BIT|FIQ_BIT  // Change to System Mode
        msr   CPSR,r1
        mov   sp,r0                         // Store stack base

// Copy initialized data to its execution address in RAM
// -------------------------------------------------------------------
#ifdef ROM_RUN
        ldr   r1,=_etext                // -> ROM data start
        ldr   r2,=_data                 // -> data start
        ldr   r3,=_edata                // -> end of data
x01:    cmp   r2,r3                     // check if data to move
		beq   y01
        ldrlo r0,[r1],#4                // copy it
        strlo r0,[r2],#4
        blo   x01                       // loop until done
y01:
#endif
// Clear .bss
// ----------
        mov   r0,#0                     // get a zero
        ldr   r1,=__bss_start           // -> bss start
        ldr   r2,=__bss_end__           // -> bss end
x02:    cmp   r1,r2                     // check if data to clear
		beq   y02
        strlo r0,[r1],#4                // clear 4 bytes
        blo   x02                       // loop until done
y02:
// Call main program: main(0)
// --------------------------
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
