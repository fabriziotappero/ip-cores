        .global main                    // int main(void)

        .global _etext                  // -> .data initial values in ROM
        .global _data                   // -> .data area in RAM
        .global _edata                  // end of .data area
        .global __bss_start             // -> .bss area in RAM
        .global __bss_end__             // end of .bss area
        .global _stack                  // top of stack

// Stack Sizes
        .set  UND_STACK_SIZE, 0x00000004
        .set  ABT_STACK_SIZE, 0x00000004
        .set  FIQ_STACK_SIZE, 0x00000004
        .set  IRQ_STACK_SIZE, 0X00000080
        .set  SVC_STACK_SIZE, 0x00000004

// Standard definitions of Mode bits and Interrupt (I & F) flags in PSRs
        .set  MODE_USR, 0x10            // User Mode
        .set  MODE_FIQ, 0x11            // FIQ Mode
        .set  MODE_IRQ, 0x12            // IRQ Mode
        .set  MODE_SVC, 0x13            // Supervisor Mode
        .set  MODE_ABT, 0x17            // Abort Mode
        .set  MODE_UND, 0x1B            // Undefined Mode
        .set  MODE_SYS, 0x1F            // System Mode

        .equ  FIQ_BIT,  0x40            // when FIQ bit is set, FIQ is disabled
        .equ  IRQ_BIT,  0x80            // when IRQ bit is set, IRQ is disabled

        .text
        .code 32
        .align 2

        .global _boot
        .func   _boot
_boot:

// Runtime Interrupt Vectors
// -------------------------
Vectors:
        b     _start                    // reset - _start
        b     und_handler               // undefined - _undf
        b     swi_handler               // SWI - _swi
        b     iab_handler               // program abort - _pabt
        b     iab_handler               // data abort - _dabt
        nop                             // reserved
        ldr   pc,[pc,#-0xFF0]           // IRQ - read the VIC
        ldr   pc,[pc,#-0xFF0]           // FIQ - read the VIC

#if 0
// Use this group for production
_undf:  .word _reset                    // undefined - _reset
_swi:   .word _reset                    // SWI - _reset
_pabt:  .word _reset                    // program abort - _reset
_dabt:  .word _reset                    // data abort - _reset
_irq:   .word _reset                    // IRQ - _reset
_fiq:   .word _reset                    // FIQ - _reset

#else
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
#endif
        .size _boot, . - _boot
        .endfunc


// Setup the operating mode & stack.
// ---------------------------------
        .global _start, start, _mainCRTStartup
        .func   _start

_start:
start:
_mainCRTStartup:

// Initialize Interrupt System
// - Set stack location for each mode
// - Leave in System Mode with Interrupts Disabled
// -----------------------------------------------
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
// -> not necessary, bootloader can be directly ecxecuted from ROM
// -----------------------------------------------------
//#ifdef ROM_RUN
//        ldr   r1,=_etext                // -> ROM data start
//        ldr   r2,=_data                 // -> data start
//        ldr   r3,=_edata                // -> end of data
//1:      cmp   r2,r3                     // check if data to move
//        ldrlo r0,[r1],#4                // copy it
//        strlo r0,[r2],#4
//        blo   1b                        // loop until done
//#endif

// Clear .bss
// Hell no!
// ----------
//        mov   r0,#0                     // get a zero
//        ldr   r1,=__bss_start           // -> bss start
//        ldr   r2,=__bss_end__           // -> bss end
//2:      cmp   r1,r2                     // check if data to clear
//        strlo r0,[r1],#4                // clear 4 bytes
//        blo   2b                        // loop until done

// Call main program: main(0)
// --------------------------
        mov   r0,#0                     // no arguments (argc = 0)
        mov   r1,r0
        mov   r2,r0
        mov   fp,r0                     // null frame pointer
        mov   r7,r0                     // null frame pointer for thumb
        ldr   r10,=main
        mov   lr,pc
        bx    r10                       // enter main()

        .size   _start, . - _start
        .endfunc

        .global _reset, reset, exit, abort
        .func   _reset
_reset:
reset:
exit:
abort:

        b     .                         // loop until reset

// Data Fetch Abort Interrupt Handler
// -------------------------------------------------------------------
dab_handler:
		mov   r13, lr
		mov   r4, #16
		mcr   p15, 0, r4, c13, c13, 0
		mov   r4, #'<'
		bl    uart0_send_byte
		mov   r4, #'D'
		bl    uart0_send_byte
		mov   r4, #'A'
		bl    uart0_send_byte
		mov   r4, #'B'
		bl    uart0_send_byte
		b     isr_handler

// Instruction Fetch Abort Interrupt Handler
// -------------------------------------------------------------------
iab_handler:
		mov   r13, lr
		mov   r4, #32
		mcr   p15, 0, r4, c13, c13, 0
		mov   r4, #'<'
		bl    uart0_send_byte
		mov   r4, #'I'
		bl    uart0_send_byte
		mov   r4, #'A'
		bl    uart0_send_byte
		mov   r4, #'B'
		bl    uart0_send_byte
		b     isr_handler

// Software Interrupt Handler
// -------------------------------------------------------------------
swi_handler:
		mov   r13, lr
		mov   r4, #64
		mcr   p15, 0, r4, c13, c13, 0
		mov   r4, #'<'
		bl    uart0_send_byte
		mov   r4, #'S'
		bl    uart0_send_byte
		mov   r4, #'W'
		bl    uart0_send_byte
		mov   r4, #'I'
		bl    uart0_send_byte
		b     isr_handler

// Undefined Instruction Interrupt Handler
// -------------------------------------------------------------------
und_handler:
		mov   r13, lr
		mov   r4, #128
		mcr   p15, 0, r4, c13, c13, 0
		mov   r4, #'<'
		bl    uart0_send_byte
		mov   r4, #'U'
		bl    uart0_send_byte
		mov   r4, #'N'
		bl    uart0_send_byte
		mov   r4, #'D'
		bl    uart0_send_byte

// Interrupt Handler
// -------------------------------------------------------------------
isr_handler:
		mov   r4, #'-'
		bl    uart0_send_byte
		mov   r4, #'I'
		bl    uart0_send_byte
		mov   r4, #'N'
		bl    uart0_send_byte
		mov   r4, #'T'
		bl    uart0_send_byte
		mov   r4, #' '
		bl    uart0_send_byte
		mov   r4, #'@'
		bl    uart0_send_byte

		sub   r7, r13, #4
		bl    uart0_print_hex

		mov   r4, #' '
		bl    uart0_send_byte
		mov   r4, #'['		
		bl    uart0_send_byte

		mrc   p15,0,r7, c9, c9
		bl    uart0_print_hex

		mov   r4, #']'
		bl    uart0_send_byte
		mov   r4, #'>'
		bl    uart0_send_byte
		b .


// Send 32-bit HEX value via UART0
// -------------------------------------------------------------------
uart0_print_hex:
		mov   r9, lr // save link register
		mov   r8, #32

uart0_print_hex_loop:
		cmp   r8, #0
		moveq pc, r9

		sub   r8, r8, #4
		mov   r6, r7, lsr r8 // isolate 4-bit value
		and   r6, r6, #0x0F

		cmp   r6, #9
		bgt   adapt_char
		add   r4, r6, #'0'

		b     uart0_print_hex_char
adapt_char:
		sub   r6, r6, #10
		add   r4, r6, #'A'

uart0_print_hex_char:
		bl    uart0_send_byte
		b     uart0_print_hex_loop


// Send one char via UART0
// -------------------------------------------------------------------
uart0_send_byte:
		ldr   r0, =(0xFFFF001C)
		ldr   r0, [r0]
		and   r0, r0, #0x01
		cmp   r0, #0
		beq   uart0_send_byte
		ldr   r0, =(0xFFFF0018)
		str   r4, [r0]
		mov   pc, lr


        .size _reset, . - _reset
        .endfunc

        .end
