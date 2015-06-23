/*
 *  Override _hardreset hook in BCC startup code in order to
 *  initialize CPU, stack pointer, GPTIMER and IRQMP.
 *
 *  This is only used when the test program runs in a simulated LEON3.
 *  In real hardware, these things are handled either by the boot PROM
 *  or by GRMON.
 */

#define STACKPTR        0x4001fff0
#define FREQ_MHZ        40
#define GPTIMER_BASE    0x80000300
#define GPTIMER_SCALER_RELOAD   0x04
#define IRQMP_BASE      0x80000200
#define IRQMP_ILEVEL    0x00
#define IRQMP_ICLEAR    0x0c
#define IRQMP_MASK      0x40

.seg    "text"

.global _hardreset

_hardreset:

    /* Reset CPU */
    flush
    set   0xc0, %g1
    mov   %g1,  %psr
    mov   2,    %g1
    mov   %g1,  %wim

    /* Enable instruction cache */
    set   0x00200003, %g1
    sta   %g1,  [%g0] 2

    /* Set up stack pointer */
    set   STACKPTR, %g1
    mov   %g1,  %fp
    sub   %g1,  96,  %sp

    /* Set GPTIMER scale factor for 50 MHz */
    set   GPTIMER_BASE, %g2
    set   FREQ_MHZ-1, %g1
    st    %g1,  [%g2+GPTIMER_SCALER_RELOAD]

    /* Reset IRQMP (some of its registers are not cleared during hard reset) */
    set   IRQMP_BASE, %g2
    st    %g0,  [%g2+IRQMP_ILEVEL]
    st    %g0,  [%g2+IRQMP_MASK]
    orn   %g0,  %g0,  %g1
    st    %g1,  [%g2+IRQMP_ICLEAR]

    /* Set up trap table and enable traps */
    set   _trap_table, %g1
    mov   %g1,  %tbr
    set   0xe0, %g1
    mov   %g1,  %psr

    /* Jump back to BCC startup code */
    set   _hardreset_real,  %g1
    jmp   %g1
    nop

