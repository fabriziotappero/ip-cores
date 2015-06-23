/*
 * Copyright 2010 Joris van Rantwijk.
 *
 * This code is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 */

/**
 * @file    spacewirelight.c
 * @brief   SpaceWire Light driver for RTEMS 4.10 on LEON3.
 *
 * See spacewirelight.h for a description of the API.
 */

#include <stdlib.h>
#include <stdint.h>
#include <bsp.h>
#include <rtems/malloc.h>

#include "spacewirelight.h"


/**
 * Define SPWL_CHECK_CONCURRENT_CALL to explicitly guard against
 * invalid concurrent calls from multiple tasks.
 */
/* #define SPWL_CHECK_CONCURRENT_CALL */

/* Tell GCC that type-incompatible pointers may be aliases. */
#define __may_alias             __attribute__((may_alias))

/* Register addresses, relative to APB base address. */
#define SPWL_REG_CONTROL        0x00
#define SPWL_REG_STATUS         0x04
#define SPWL_REG_TXSCALER       0x08
#define SPWL_REG_TIMECODE       0x0c
#define SPWL_REG_RXDMA          0x10
#define SPWL_REG_TXDMA          0x14

/* Bit masks in registers */
#define SPWL_CONTROL_RESET      0x0001
#define SPWL_CONTROL_START      0x0004
#define SPWL_CONTROL_AUTOSTART  0x0008
#define SPWL_CONTROL_DISABLE    0x0010
#define SPWL_CONTROL_RXDMA      0x0040
#define SPWL_CONTROL_TXDMA      0x0080
#define SPWL_CONTROL_IESTATUS   0x0200
#define SPWL_CONTROL_IETICK     0x0400
#define SPWL_CONTROL_IERXDESC   0x0800
#define SPWL_CONTROL_IETXDESC   0x1000
#define SPWL_STATUS_TICK        0x0400
#define SPWL_STATUS_RXDESC      0x0800
#define SPWL_STATUS_TXDESC      0x1000

#define SPWL_ERROR_MASK         ((SPWL_ERR_DISCONNECT) | (SPWL_ERR_PARITY) | \
                                 (SPWL_ERR_ESCAPE) | (SPWL_ERR_CREDIT))

/* Descriptor flag bits */
#define SPWL_DESC_LENMASK       0x0000ffff
#define SPWL_DESC_EN            0x00010000
#define SPWL_DESC_IE            0x00040000
#define SPWL_DESC_DONE          0x00080000
#define SPWL_DESC_EOP           0x00100000
#define SPWL_DESC_EEP           0x00200000

/* Convert EOP bits from descriptor flags to library API.
   This depends on the specific values of the EOP flags. */
#define SPWL_EOP_DESC_TO_FLAG(f)    (((f) & (SPWL_DESC_EOP | SPWL_DESC_EEP)) >> 16)
#define SPWL_EOP_FLAG_TO_DESC(f)    (((f) & (SPWL_EOP | SPWL_EEP)) << 16)


/* Frame descriptor. */
struct descriptor_struct {
    volatile uint32_t flags;
    volatile uint32_t ptr;
};


/* Structure describing an open SpaceWire Light device. */
struct spwl_context {
    struct spwl_context *next;          /* Link to next context */
    unsigned long   devaddr;            /* Base address of APB registers */
    unsigned int    devirq;             /* Device IRQ */
    unsigned int    ndesc;              /* Size of descriptor tables */
    unsigned int    rxbufs;             /* Number of RX buffers */
    unsigned int    txbufs;             /* Number of allocatex TX buffers */
    unsigned int    rxbufsize;          /* Size of each receive buffer */
    unsigned int    txbufsize;          /* Size of each transmit buffer */
    volatile struct descriptor_struct *rxdesc;  /* RX descriptor table */
    volatile struct descriptor_struct *txdesc;  /* TX descriptor table */
    unsigned char   *rxdata;            /* RX data buffers */
    unsigned char   *txdata;            /* Internal TX data buffers */
    unsigned int    rxdescqh, rxdescqlen;   /* RX descriptor ring */
    unsigned int    txdescqh, txdescqlen;   /* TX descriptor ring */
    unsigned int    txdataqh;           /* Next internal TX buffer to use */
    spwl_txbuf_t    *txappqh, *txappqt; /* List of application TX buffers */
    unsigned int    txappnact;          /* Nr of active app buffers */
    unsigned int    txappnrcl;          /* Nr of reclaimable app buffers */
    unsigned int    currxpos;           /* Position in partial RX frame */
    unsigned int    curtxpos;           /* Position in partial TX frame */
    unsigned int    deftxscaler;        /* Default (10 Mbit) TX scaler */
    unsigned int    pendingerrors;      /* Pending error bits */
    unsigned int    errorcnt;           /* Count link error detections */
    rtems_id        seminterrupt;       /* Semaphore to wait for interrupt */
    rtems_isr_entry saved_isr;          /* Old interrupt handler */
#ifdef SPWL_CHECK_CONCURRENT_CALL
    int             recvbusy;           /* Inside receive function */
    int             sendbusy;           /* Inside send function */
#endif
};


/* Global linked list of spwl_context structures. */
static struct spwl_context *spwl_context_list = NULL;

/* Default options used by spwl_open_xxx() functions. */
static const struct spwl_options spwl_default_options = SPWL_OPTIONS_DEFAULT;


/*
 * == Locking ==
 *
 * The "spwl_context" structure may be accessed concurrently by one or more
 * tasks through the API, as well as by the interrupt handler. The following
 * synchronization rules apply:
 *
 *  o Atomic access to hardware registers (i.e. read-modify-write control reg)
 *    is done with interrupts disabled. The only exception is inside the
 *    interrupt handler itself.
 *
 *  o Exclusive access to the context structure is ensured by disabling
 *    interrupts. Also the global linked list of context structures is
 *    accessed with interrupts disabled.
 *
 *  o During data copying in spwl_recv() and spwl_send(), interrupts are
 *    restored to the previous setting to avoid keeping interrupts disabled
 *    for unlimited periods of time.
 *
 *  o A binary semaphore is used to let tasks wait until an interrupt occurs.
 *    One issue here is to avoid races where the interrupt occurs before
 *    the task starts waiting. Another issue is that multiple tasks may be
 *    waiting for the same interrupt, in which case the interrupt should
 *    wake them all up.
 */


/* Read from a 32-bit register. */
static inline uint32_t readreg(unsigned long addr)
{
    uint32_t ret;
    asm volatile (
        "lda [%1] 1, %0"
        : "=r" (ret)
        : "r" (addr) );
    return ret;
}


/* Write to a 32-bit register. */
static inline void writereg(unsigned long addr, uint32_t v)
{
    *((volatile uint32_t *)addr) = v;
}


/* Read a 32-bit word from memory, bypassing the data cache. */
static inline uint32_t readmem_nocache(const volatile uint32_t *addr)
{
    uint32_t ret;
    asm volatile (
        "lda [%1] 1, %0"
        : "=r" (ret)
        : "r" (addr) );
    return ret;
}


/* Read a byte from memory, bypassing the data cache. */
static inline char readmem_byte_nocache(const volatile char *addr)
{
    char ret;
    asm volatile (
        "lduba [%1] 1, %0"
        : "=r" (ret)
        : "r" (addr) );
    return ret;
}


/* Write a 32-bit word to memory. */
static inline void writemem(volatile uint32_t *addr, uint32_t v)
{
    *addr = v;
}


/* Copy data, bypassing the CPU data cache. */
static void memcpy_nocache(void *dest, const volatile void *src, size_t n)
{
    char __may_alias                *cdst = dest;
    const volatile char __may_alias *csrc = src;

    /* Copy word-at-a-time if both pointers are word-aligned. */
    if (((((unsigned long)dest) | ((unsigned long)src)) & 3) == 0) {

        /* Copy words. */
        uint32_t __may_alias                *wdst = (uint32_t *)dest;
        const volatile uint32_t __may_alias *wsrc = (const volatile uint32_t *)src;
        while (n >= 4) {
            *wdst = readmem_nocache(wsrc);
            wdst++;
            wsrc++;
            n -= 4;
        }

        /* Copy any remaining bytes with the byte-loop below. */
        cdst = (char *)wdst;
        csrc = (const volatile char *)wsrc;
    }

    /* Copy bytes. */
    while (n > 0) {
        *cdst = readmem_byte_nocache(csrc);
        cdst++;
        csrc++;
        n--;
    }

}


/* Enable bits in the control register. Called with interrupts disabled. */
static inline void spwl_ctrl_setbits(spwl_handle h, uint32_t setbits)
{
    uint32_t value;
    value = readreg(h->devaddr + SPWL_REG_CONTROL);
    value |= setbits;
    writereg(h->devaddr + SPWL_REG_CONTROL, value);
}


/*
 * Wait until the interrupt handler releases the specified semaphore.
 * Called with interrupts disabled but returns with interrupts enabled.
 */
static rtems_status_code wait_for_interrupt(rtems_id sem,
                                            rtems_interrupt_level level,
                                            rtems_interval timeout)
{
    rtems_status_code ret;

    /*
     * The interrupt has been enabled in the SpaceWire core, but interrupts
     * are disabled at the CPU level. Therefore nothing can happen until
     * we are safely sleeping inside rtems_semaphore_obtain().
     *
     * Blocking the task with interrupts disabled is apparently handled
     * correctly by RTEMS, i.e. the kernel updates the CPU interrupt status
     * as part of the context switch.
     */
    ret = rtems_semaphore_obtain(sem, RTEMS_WAIT, timeout);

    /* Restore interrupts. */
    rtems_interrupt_enable(level);

    /* If we got the semaphore, flush it to wake the other waiting tasks.
       rtems_semaphore_flush() can be pretty slow, which is why we call it
       with interrupts enabled. */
    if (ret == RTEMS_SUCCESSFUL)
        rtems_semaphore_flush(sem);

    return ret;
}


/* Reap (some) completed TX descriptors. Called with interrupts disabled. */
static void reap_tx_descriptors(spwl_handle h)
{
    unsigned int    txdescqt, txdescqp, nreap;
    uint32_t        descf;

    /* Stop if the TX ring is empty. */
    if (h->txdescqlen == 0)
        return;

    /* Stop if the tail descriptor in the TX ring is not yet complete. */
    txdescqt = (h->txdescqh - h->txdescqlen) & (h->ndesc - 1);
    descf = readmem_nocache(&h->txdesc[txdescqt].flags);
    if ((descf & SPWL_DESC_DONE) == 0)
        return;

    /* Check if the entire TX ring is complete;
       in that case reap everything, otherwise reap just one buffer. */
    txdescqp = (h->txdescqh - 1) & (h->ndesc - 1);
    descf = readmem_nocache(&h->txdesc[txdescqp].flags);
    if ((descf & SPWL_DESC_DONE) != 0)
        nreap = h->txdescqlen;
    else
        nreap = 1;

    /* Remove reaped buffers from TX ring. */
    h->txdescqlen -= nreap;

    /* If the reaped buffers are application buffers, move them to the
       list of reclaimable buffers. */
    if (h->txappnact > 0) {
        h->txappnact -= nreap;
        h->txappnrcl += nreap;
    }
}


/*
 * Interrupt handler.
 *
 * The interrupt handler does not do any data handling itself.
 * It simple releases a semaphore to wake up tasks that do the actual work.
 */
static void spwl_interrupt_handler(rtems_vector_number vec)
{
    struct spwl_context *ctx;
    uint32_t ctrl;

    /* Scan list of device contexts for a matching IRQ vector. */
    for (ctx = spwl_context_list; ctx != NULL; ctx = ctx->next) {
        if (ctx->devirq + 0x10 == vec) {

            /* Disable device interrupts. */
            ctrl   = readreg(ctx->devaddr + SPWL_REG_CONTROL);
            ctrl &= ~ (SPWL_CONTROL_IERXDESC | SPWL_CONTROL_IETXDESC |
                       SPWL_CONTROL_IETICK | SPWL_CONTROL_IESTATUS);
            writereg(ctx->devaddr + SPWL_REG_CONTROL, ctrl);

            /* Notify waiting tasks. */
            rtems_semaphore_release(ctx->seminterrupt);
        }
    }
}


#ifdef LEON3
/* Open a SpaceWire Light device. */
rtems_status_code spwl_open(spwl_handle *h,
                            unsigned int index,
                            const struct spwl_options *opt)
{
    amba_apb_device apbdev;

    /* Find device in APB plug&play configuration. */
    if (!amba_find_next_apbslv(&amba_conf,
                               VENDOR_OPENCORES, DEVICE_SPACEWIRELIGHT,
                               &apbdev, index)) {
        return RTEMS_INVALID_NUMBER;
    }

    return spwl_open_hwaddr(h, apbdev.start, apbdev.irq, opt);
}
#endif


/* Open a SpaceWire Light device. */
rtems_status_code spwl_open_hwaddr(spwl_handle *h,
                                   unsigned long addr, unsigned int irq,
                                   const struct spwl_options *opt)
{
    struct spwl_context *ctx;
    uint32_t t, desctablesize;
    rtems_status_code ret;
    rtems_interrupt_level level;
    unsigned int i;
    void *vp;

    /* Use default options if no options specified. */
    if (opt == NULL) {
        opt = &spwl_default_options;
    }

    /* Read configuration of SpaceWire Light core. */
    t = readreg(addr + SPWL_REG_CONTROL);
    desctablesize = (t >> 24);
    if (desctablesize < 4 || desctablesize > 14) {
        ret = RTEMS_IO_ERROR;
        goto errout;
    }

    if (opt->rxbufsize < 32 || opt->rxbufsize > 65532 ||
        opt->txbufsize < 32 || opt->txbufsize > 65532) {
        ret = RTEMS_INVALID_SIZE;
        goto errout;
    }

    /* Allocate context structure. */
    ctx = malloc(sizeof(struct spwl_context));
    if (ctx == NULL) {
        ret = RTEMS_NO_MEMORY;
        goto errout;
    }

    /* Initialize context structure. */
    ctx->devaddr    = addr;
    ctx->devirq     = irq;
    ctx->ndesc      = 1 << desctablesize;
    ctx->rxbufs     = opt->rxbufs;
    ctx->txbufs     = opt->txbufs;
    ctx->rxbufsize  = (opt->rxbufsize + 3) & (~3U);
    ctx->txbufsize  = (opt->txbufsize + 3) & (~3U);
    ctx->rxdescqh   = ctx->rxdescqlen = 0;
    ctx->txdescqh   = ctx->txdescqlen = 0;
    ctx->txdataqh   = 0;
    ctx->txappqt    = ctx->txappqh = NULL;
    ctx->txappnact  = 0;
    ctx->txappnrcl  = 0;
    ctx->currxpos   = 0;
    ctx->curtxpos   = 0;
#ifdef SPWL_CHECK_CONCURRENT_CALL
    ctx->recvbusy   = 0;
    ctx->sendbusy   = 0;
#endif
    ctx->pendingerrors = 0;
    ctx->errorcnt   = 0;

    /* Do not allocate more buffers than the size of the descriptor table. */
    if (ctx->rxbufs > ctx->ndesc)
        ctx->rxbufs = ctx->ndesc;
    if (ctx->txbufs > ctx->ndesc)
        ctx->txbufs = ctx->ndesc;

    /* Allocate RX/TX descriptor tables. */
    if (rtems_memalign(&vp, 8 * ctx->ndesc, 2 * 8 * ctx->ndesc)) {
        ret = RTEMS_NO_MEMORY;
        goto errout_desc;
    }
    ctx->rxdesc = ((struct descriptor_struct *)vp);
    ctx->txdesc = ((struct descriptor_struct *)vp) + ctx->ndesc;

    /* Allocate RX/TX data buffers. */
    if (rtems_memalign(&vp, 32, ctx->rxbufs * ctx->rxbufsize)) {
        ret = RTEMS_NO_MEMORY;
        goto errout_rxdata;
    }
    ctx->rxdata = vp;
    if (rtems_memalign(&vp, 32, ctx->txbufs * ctx->txbufsize)) {
        ret = RTEMS_NO_MEMORY;
        goto errout_txdata;
    }
    ctx->txdata = vp;

    /* Initialize semaphore. */
    ret = rtems_semaphore_create(
        rtems_build_name('S','P','W','L'),
        0,
        RTEMS_FIFO | RTEMS_SIMPLE_BINARY_SEMAPHORE,
        RTEMS_NO_PRIORITY,
        &ctx->seminterrupt);
    if (ret != RTEMS_SUCCESSFUL)
        goto errout_sem;

    /* Clear descriptor tables. */
    for (i = 0; i < ctx->ndesc; i++) {
        writemem(&ctx->rxdesc[i].flags, 0);
        writemem(&ctx->txdesc[i].flags, 0);
    }

    /* Fill RX descriptor table. */
    for (i = 0; i < ctx->rxbufs; i++) {
        unsigned char *pbuf = ctx->rxdata + i * ctx->rxbufsize;
        writemem(&ctx->rxdesc[i].ptr, (uint32_t)pbuf);
        writemem(&ctx->rxdesc[i].flags,
                 ctx->rxbufsize | SPWL_DESC_EN | SPWL_DESC_IE);
    }
    ctx->rxdescqh   = ctx->rxbufs & (ctx->ndesc - 1);
    ctx->rxdescqlen = ctx->rxbufs;

    /* Reset device. */
    writereg(ctx->devaddr + SPWL_REG_CONTROL, SPWL_CONTROL_RESET);

    /* Store initial TX scaler. */
    ctx->deftxscaler = readreg(ctx->devaddr + SPWL_REG_TXSCALER);

    /* Add context structure to linked list. */
    rtems_interrupt_disable(level);
    ctx->next = spwl_context_list;
    spwl_context_list = ctx;
    rtems_interrupt_enable(level);

    /* Register interrupt handler. */
    rtems_interrupt_catch(spwl_interrupt_handler, ctx->devirq + 0x10,
                          &ctx->saved_isr);
    LEON_Clear_interrupt(ctx->devirq);
    LEON_Unmask_interrupt(ctx->devirq);

    /* Initialize descriptor pointers. */
    writereg(ctx->devaddr + SPWL_REG_RXDMA, (uint32_t)(ctx->rxdesc));
    writereg(ctx->devaddr + SPWL_REG_TXDMA, (uint32_t)(ctx->txdesc));

    /* Start RX DMA. */
    writereg(ctx->devaddr + SPWL_REG_CONTROL, SPWL_CONTROL_RXDMA);

    *h = ctx;
    return RTEMS_SUCCESSFUL;

    /* Cleanup after error. */
errout_sem:
    free(ctx->txdata);
errout_txdata:
    free(ctx->rxdata);
errout_rxdata:
    free((void*)ctx->rxdesc);
errout_desc:
    free(ctx);
errout:
    return ret;
}


/* Close an open SpaceWire Light device. */
void spwl_close(spwl_handle h)
{
    struct spwl_context **ctxp;
    rtems_interrupt_level level;

    /* Reset device. */
    writereg(h->devaddr + SPWL_REG_CONTROL, SPWL_CONTROL_RESET);

    /* Unregister interrupt handler.
       NOTE: This is incorrect in case of shared interrupts. */
    LEON_Mask_interrupt(h->devirq);
    LEON_Clear_interrupt(h->devirq);
    rtems_interrupt_catch(h->saved_isr, h->devirq + 0x10, &h->saved_isr);

    /* Unlink context structure. */
    rtems_interrupt_disable(level);
    ctxp = &spwl_context_list;
    for (ctxp = &spwl_context_list; *ctxp != NULL; ctxp = &(*ctxp)->next) {
        if (*ctxp == h) {
            *ctxp = h->next;
            break;
        }
    }
    rtems_interrupt_enable(level);

    /* Delete semaphore. */
    rtems_semaphore_delete(h->seminterrupt);

    /* Release memory. */
    free(h->txdata);
    free(h->rxdata);
    free((void*)h->rxdesc);
    free(h);
}


/* Set the TX clock scaler for the link. */
rtems_status_code spwl_set_linkspeed(spwl_handle h, unsigned int scaler)
{
    writereg(h->devaddr + SPWL_REG_TXSCALER, scaler);
    return RTEMS_SUCCESSFUL;
}


/* Return the currently configured TX clock scaler. */
unsigned int spwl_get_linkspeed(spwl_handle h)
{
    return readreg(h->devaddr + SPWL_REG_TXSCALER);
}


/* Return the default TX scaler value. */
unsigned int spwl_get_default_linkspeed(spwl_handle h)
{
    return h->deftxscaler;
}


/* Change the mode of the SpaceWire link. */
rtems_status_code spwl_set_linkmode(spwl_handle h, spwl_linkmode mode)
{
    rtems_interrupt_level level;
    uint32_t ctrl, m;

    /* Convert link mode to bits in control register. */
    switch (mode) {
        case SPWL_LINKMODE_START:
            m = SPWL_CONTROL_START;
            break;   
        case SPWL_LINKMODE_AUTOSTART:
            m = SPWL_CONTROL_AUTOSTART;
            break;
        case SPWL_LINKMODE_DISABLE:
            m = SPWL_CONTROL_DISABLE;
            break;
        default:
            m = 0;
            break;
    }

    /* Update control register. */
    rtems_interrupt_disable(level);
    ctrl = readreg(h->devaddr + SPWL_REG_CONTROL);
    ctrl &=  ~ (SPWL_CONTROL_START |
                SPWL_CONTROL_AUTOSTART |
                SPWL_CONTROL_DISABLE);
    ctrl |= m;
    writereg(h->devaddr + SPWL_REG_CONTROL, ctrl);
    rtems_interrupt_enable(level);

    return RTEMS_SUCCESSFUL; 
}


/* Get status and pending errors of SpaceWire link. */
rtems_status_code spwl_get_linkstatus(spwl_handle h,
                                      spwl_linkstatus *linkstatus,
                                      unsigned int *errors)
{
    rtems_interrupt_level level;
    uint32_t status;

    rtems_interrupt_disable(level);

    /* Read status word and clear error flags. */
    status = readreg(h->devaddr + SPWL_REG_STATUS);
    writereg(h->devaddr + SPWL_REG_STATUS, status & SPWL_ERROR_MASK);

    /* Update error counter (needed in case spwl_wait() is in progress). */
    if ((status & SPWL_ERROR_MASK) != 0)
        h->errorcnt++;

    /* Accumulate error flags. */
    h->pendingerrors |= status;

    /* Clear pending errors if error status is requested. */
    if (errors) {
        status |= h->pendingerrors & SPWL_ERROR_MASK;
        h->pendingerrors = 0;
    }

    rtems_interrupt_enable(level);

    if (linkstatus)
        *linkstatus = status & 3;
    if (errors)
        *errors = status & (SPWL_ERROR_MASK | SPWL_ERR_AHB);

    return RTEMS_SUCCESSFUL;
}


/* Wait for specified condition with timeout. */
rtems_status_code spwl_wait(spwl_handle h,
                            unsigned int *cond, rtems_interval timeout)
{
    rtems_status_code   ret;
    rtems_interrupt_level level;
    unsigned int        i_cond = *cond;
    unsigned int        r_cond = 0;
    unsigned int        rxdescqt;
    unsigned int        prev_errorcnt = 0;
    rtems_interval      endtime = RTEMS_NO_TIMEOUT;
    rtems_interval      timeleft = timeout;
    uint32_t            status, ctrl, descf;
    int                 first = 1;

    /* Determine maximum wait time. */
    if (timeout != RTEMS_NO_TIMEOUT)
        endtime = rtems_clock_get_ticks_since_boot() + timeout;

    /* Wait until condition satisfied or timeout. */
    do {

        /* Disable global interrupts. */
        rtems_interrupt_disable(level);

        /* Store initial link error count to detect upcoming link events. */
        if (first)
            prev_errorcnt = h->errorcnt;
        first = 0;

        /* Enable relevant device interrupts. */
        ctrl = readreg(h->devaddr + SPWL_REG_CONTROL);
        if ((i_cond & SPWL_COND_RDYRECV) != 0)
            ctrl |= SPWL_CONTROL_IERXDESC;
        if ((i_cond & (SPWL_COND_RDYSEND |
                     SPWL_COND_RDYSENDBUF |
                     SPWL_COND_RECLAIM)) != 0)
            ctrl |= SPWL_CONTROL_IETXDESC;
        if ((i_cond & SPWL_COND_TIMECODE) != 0)
            ctrl |= SPWL_CONTROL_IETICK;
        if ((i_cond & (SPWL_COND_LINKUP | SPWL_COND_LINKDOWN)) != 0)
            ctrl |= SPWL_CONTROL_IESTATUS;
        writereg(h->devaddr + SPWL_REG_CONTROL, ctrl);

        /* Read status register and clear error flags. */
        status = readreg(h->devaddr + SPWL_REG_STATUS);
        writereg(h->devaddr + SPWL_REG_STATUS, status & SPWL_ERROR_MASK);

        /* Update error counter. */
        if ((status & SPWL_ERROR_MASK) != 0)
            h->errorcnt++;

        /* Accumulate error flags for spwl_get_linkstatus(). */
        h->pendingerrors |= status;

        /* Check for link up condition. */
        if ((i_cond & SPWL_COND_LINKUP) != 0 &&
            ((status & 3) == 3 || h->errorcnt > prev_errorcnt)) {
            /* Either the link is currently up, or a link error occurred
               since entering spwl_wait(), indicating that the link has
               been up even if it is already down again. */
            r_cond |= SPWL_COND_LINKUP;
        }

        /* Check for link down condition. */
        if ((i_cond & SPWL_COND_LINKDOWN) != 0 &&
            ((status & 3) != 3 || h->errorcnt > prev_errorcnt)) {
            /* Either the link is currently down, or a link error occured
               since entering spwl_wait(), indicating that the link has
               been down even if it is already up again. */
            r_cond |= SPWL_COND_LINKDOWN;
        }

        /* Check receive condition. */
        if ((i_cond & SPWL_COND_RDYRECV) != 0) {
            /* Check for received data in RX ring. */
            rxdescqt = (h->rxdescqh - h->rxdescqlen) & (h->ndesc - 1);
            descf = readmem_nocache(&h->rxdesc[rxdescqt].flags);
            if ((descf & SPWL_DESC_DONE) != 0)
                r_cond |= SPWL_COND_RDYRECV;
        }

        /* Check send/reclaim conditions. */
        if ((i_cond & (SPWL_COND_RDYSEND |
                       SPWL_COND_RDYSENDBUF |
                       SPWL_COND_RECLAIM)) != 0) {

            /* Reap completed TX descriptors. */
            reap_tx_descriptors(h);

            /* Check for room in TX ring and room in TX internal buffers
               and no application buffers in TX ring. */
            if ((i_cond & SPWL_COND_RDYSEND) != 0 &&
                h->txdescqlen < h->ndesc &&
                h->txdescqlen < h->txbufs &&
                h->txappnact == 0)
                r_cond |= SPWL_COND_RDYSEND;

            /* Check for room in TX ring and no internal buffers in TX ring. */
            if ((i_cond & SPWL_COND_RDYSENDBUF) != 0 &&
                h->txdescqlen < h->ndesc &&
                (h->txdescqlen == 0 || h->txappnact > 0))
                r_cond |= SPWL_COND_RDYSENDBUF;

            /* Check for non-empty reclaim list. */
            if ((i_cond & SPWL_COND_RECLAIM) != 0 &&
                h->txappnrcl > 0)
                r_cond |= SPWL_COND_RECLAIM;
        }

        /* Check for received time code. */
        if ((i_cond & SPWL_COND_TIMECODE) != 0 &&
            (status & SPWL_STATUS_TICK) != 0) {
            /* There is a pending timecode. */
            r_cond |= SPWL_COND_TIMECODE;
        }

        /* Stop waiting if any of the conditions has been satisfied. */
        if (r_cond != 0) {
            rtems_interrupt_enable(level);
            ret = RTEMS_SUCCESSFUL;
            break;
        }

        /* Wait for interrupt (returns with interrupts enabled). */
        ret = wait_for_interrupt(h->seminterrupt, level, timeleft);

        /* Recalculate the time left to wait. */
        if (timeout != RTEMS_NO_TIMEOUT) {
            rtems_interval tnow = rtems_clock_get_ticks_since_boot();
            if (tnow >= endtime) {
                ret = RTEMS_TIMEOUT;
                break;
            }
            timeleft = endtime - tnow;
        }

        /* Stop if the interrupt timed out. */
    } while (ret != RTEMS_TIMEOUT);

    /* Return */
    *cond = r_cond;
    return ret;
}


/* Transfer received data to the specified application buffer. */
rtems_status_code spwl_recv(spwl_handle h,
                            void *buf, size_t maxlen, size_t *ntrans,
                            unsigned int *eop, unsigned int flags)
{
    rtems_status_code   ret;
    rtems_interrupt_level level;
    size_t              r_ntrans = 0;
    unsigned int        r_eop = 0;
    unsigned int        rxdescqt;
    uint32_t            descf, descp, framelen, ncopy;

    /* Disable interrupts. */
    rtems_interrupt_disable(level);

#ifdef SPWL_CHECK_CONCURRENT_CALL
    /* Limit damage in case of concurrent calls. */
    if (h->recvbusy) {
        rtems_interrupt_enable(level);
        return RTEMS_RESOURCE_IN_USE;
    }
    h->recvbusy = 1;
#endif

    /* Transfer data until request satisfied. */
    while (1) {

        /* Transfer data until request satisfied or no more data available. */
        while (r_ntrans < maxlen && r_eop == 0) {

            /* Check that the RX ring is nonempty. */
            if (h->rxdescqlen == 0)
                break;

            /* Check that the frame at the tail of the RX ring is ready. */
            rxdescqt = (h->rxdescqh - h->rxdescqlen) & (h->ndesc - 1);
            descf = readmem_nocache(&h->rxdesc[rxdescqt].flags);
            descp = h->rxdesc[rxdescqt].ptr;
            if ((descf & SPWL_DESC_DONE) == 0) {
                /* No more received frames available. */
                break;
            }

            /* Re-enable interrupts during copying. */
            rtems_interrupt_enable(level);

            /* Copy data from current frame to application buffer. */
            framelen = descf & SPWL_DESC_LENMASK;
            ncopy    = framelen - h->currxpos;
            if (ncopy > maxlen - r_ntrans)
                ncopy = maxlen - r_ntrans;
            memcpy_nocache((unsigned char *)buf + r_ntrans,
                           (unsigned char *)descp + h->currxpos,
                           ncopy);
            r_ntrans    += ncopy;
            h->currxpos += ncopy;

            /* Re-disable interrupts. */
            rtems_interrupt_disable(level);

            /* Handle end of frame. */
            if (h->currxpos >= framelen) {

                /* Pass EOP flags to application. */
                r_eop = SPWL_EOP_DESC_TO_FLAG(descf);

                /* Reset partial frame position. */
                h->currxpos = 0;

                /* Resubmit buffer to head of RX ring. */
                writemem(&h->rxdesc[h->rxdescqh].ptr, descp);
                writemem(&h->rxdesc[h->rxdescqh].flags,
                         h->rxbufsize | SPWL_DESC_EN | SPWL_DESC_IE);
                h->rxdescqh = (h->rxdescqh + 1) & (h->ndesc - 1);

                /* Restart RX DMA. */
                spwl_ctrl_setbits(h, SPWL_CONTROL_RXDMA);
            }
        }

        /* Stop if request satisfied. */
        if (r_ntrans == maxlen || r_eop != 0) {
            ret = RTEMS_SUCCESSFUL;
            break;
        }

        /* No more received frames available.
           Stop if application does not want to wait. */
        if ((flags & SPWL_NO_WAIT) != 0) {
            ret = (r_ntrans > 0) ? RTEMS_SUCCESSFUL : RTEMS_UNSATISFIED;
            break;
        }

        /* Enable interrupt on data received. */
        spwl_ctrl_setbits(h, SPWL_CONTROL_IERXDESC);

        /* Final check for received data (avoid race condition). */
        rxdescqt = (h->rxdescqh - h->rxdescqlen) & (h->ndesc - 1);
        if (h->rxdescqlen == 0 ||
            (readmem_nocache(&h->rxdesc[rxdescqt].flags) & SPWL_DESC_DONE) == 0) {
            /* Wait until RX interrupt. */
            wait_for_interrupt(h->seminterrupt, level, RTEMS_NO_TIMEOUT);
            rtems_interrupt_disable(level);
        }
    }

    /* Restore interrupts. */
#ifdef SPWL_CHECK_CONCURRENT_CALL
    h->recvbusy = 0;
#endif
    rtems_interrupt_enable(level);

    /* Return */
    *ntrans = r_ntrans;
    *eop    = r_eop;
    return ret;
}


/* Send data to the SpaceWire link. */
rtems_status_code spwl_send(spwl_handle h,
                            const void *buf, size_t maxlen, size_t *ntrans,
                            unsigned int flags)
{
    rtems_status_code   ret;
    rtems_interrupt_level level;
    size_t              r_ntrans = 0;
    unsigned char *     bufp;
    unsigned int        txdescqp;
    uint32_t            descf, ncopy;

    /* Disable interrupts. */
    rtems_interrupt_disable(level);

#ifdef SPWL_CHECK_CONCURRENT_CALL
    /* Limit damage in case of concurrent calls. */
    if (h->sendbusy) {
        rtems_interrupt_enable(level);
        return RTEMS_RESOURCE_IN_USE;
    }
    h->sendbusy = 1;
#endif

    /* Transfer data until request satisfied. */
    while (1) {

        /* Reap completed TX descriptors if possible. */
        reap_tx_descriptors(h);

        /* Transfer data until request satisfied or no more room in TX bufs. */
        do {

            /* Check that there is a buffer available and that
               there are no application buffers in the TX ring. */
            if (h->txdescqlen >= h->ndesc ||
                h->txdescqlen >= h->txbufs ||
                h->txappnact > 0)
                break;

            /* Re-enable interrupts during copying. */
            rtems_interrupt_enable(level);

            /* Copy data from application buffer to internal TX buffer. */
            bufp  = h->txdata + h->txdataqh * h->txbufsize;
            ncopy = h->txbufsize - h->curtxpos;
            if (ncopy > maxlen - r_ntrans)
                ncopy = maxlen - r_ntrans;
            memcpy(bufp + h->curtxpos, (unsigned char *)buf + r_ntrans, ncopy);
            r_ntrans    += ncopy;
            h->curtxpos += ncopy;

            /* Re-disable interrupts. */
            rtems_interrupt_disable(level);

            /* Handle end of frame. */
            if (h->curtxpos >= h->txbufsize ||
                (flags & (SPWL_EOP | SPWL_EEP)) != 0) {

                /* Insert buffer in TX descriptor ring. */
                descf = h->curtxpos | SPWL_DESC_EN | SPWL_DESC_IE;
                if (r_ntrans == maxlen) {
                    /* Handle EOP. */
                    descf |= SPWL_EOP_FLAG_TO_DESC(flags);
                    flags &= ~(SPWL_EOP | SPWL_EEP);
                }
                writemem(&h->txdesc[h->txdescqh].ptr, (uint32_t)bufp);
                writemem(&h->txdesc[h->txdescqh].flags, descf);
                h->txdescqh = (h->txdescqh + 1) & (h->ndesc - 1);
                h->txdescqlen++;

                /* Advance internal TX buffer pointer. */
                h->curtxpos = 0;
                h->txdataqh++;
                if (h->txdataqh == h->txbufs)
                    h->txdataqh = 0;

                /* Restart TX DMA. */
                spwl_ctrl_setbits(h, SPWL_CONTROL_TXDMA);
            }

        } while (r_ntrans < maxlen);

        /* Stop when request satisfied. */
        if (r_ntrans == maxlen && (flags & (SPWL_EOP | SPWL_EEP)) == 0) {
            ret = RTEMS_SUCCESSFUL;
            break;
        }

        /* No more room in TX queue, but application wants to send more.
           Stop if application does not want to wait. */
        if ((flags & SPWL_NO_WAIT) != 0) {
            ret = (r_ntrans > 0) ? RTEMS_SUCCESSFUL : RTEMS_UNSATISFIED;
            break;
        }

        /* Enable interrupt on frame transmitted */
        spwl_ctrl_setbits(h, SPWL_CONTROL_IETXDESC);

        /* Final check for TX room (avoid race condition). */
        if (h->txappnact > 0) {
            /* Wait until all app buffers can be removed from the TX ring. */
            txdescqp = (h->txdescqh - 1) & (h->ndesc - 1);
        } else {
            /* Wait until one buffer can be removed from the TX ring. */
            txdescqp = (h->txdescqh - h->txdescqlen) & (h->ndesc - 1);
        }
        descf = readmem_nocache(&h->txdesc[txdescqp].flags);
        if ((descf & SPWL_DESC_DONE) == 0) {
            /* Wait until TX interrupt. */
            wait_for_interrupt(h->seminterrupt, level, RTEMS_NO_TIMEOUT);
            rtems_interrupt_disable(level);
        }
    }

    /* Restore interrupts. */
#ifdef SPWL_CHECK_CONCURRENT_CALL
    h->sendbusy = 0;
#endif
    rtems_interrupt_enable(level);

    /* Return */
    *ntrans = r_ntrans;
    return ret;
}


/* Receive data from the SpaceWire link without copying. */
rtems_status_code spwl_recv_rxbuf(spwl_handle h,
                                  void **buf,
                                  uint16_t *nbytes, unsigned int *eop,
                                  unsigned int flags)
{
    rtems_status_code   ret;
    rtems_interrupt_level level;
    unsigned int        rxdescqt;
    uint32_t            descf;
    void                *r_buf = NULL;
    uint16_t            r_nbytes = 0;
    unsigned int        r_eop = 0;

    /* Disable interrupts. */
    rtems_interrupt_disable(level);

#ifdef SPWL_CHECK_CONCURRENT_CALL
    /* Limit damage in case of concurrent calls. */
    if (h->recvbusy) {
        rtems_interrupt_enable(level);
        return RTEMS_RESOURCE_IN_USE;
    }
    h->recvbusy = 1;
#endif

    /* Make sure there is received data available. */
    while (1) {

        /* Determine tail of RX ring. */
        rxdescqt = (h->rxdescqh - h->rxdescqlen) & (h->ndesc - 1);

        /* Check if there is at least one received frame available. */
        if (h->rxdescqlen > 0) {
            descf = readmem_nocache(&h->rxdesc[rxdescqt].flags);
            if ((descf & SPWL_DESC_DONE) != 0)
                break;
        }

        /* There is no data available.
           Stop if the application does not want to wait. */
        if ((flags & SPWL_NO_WAIT) != 0) {
            ret = RTEMS_UNSATISFIED;
            goto out_unlock;
        }

        /* Enable interrupt on data received. */
        spwl_ctrl_setbits(h, SPWL_CONTROL_IERXDESC);

        /* Final check for received data (avoid race condition). */
        if (h->rxdescqlen > 0) {
            descf = readmem_nocache(&h->rxdesc[rxdescqt].flags);
            if ((descf & SPWL_DESC_DONE) != 0)
                break;
        }

        /* Wait until RX interrupt. */
        wait_for_interrupt(h->seminterrupt, level, RTEMS_NO_TIMEOUT);
        rtems_interrupt_disable(level);
    }

    /* At least one received frame is available.
       Remove buffer from RX ring and give it to the application. */
    r_buf    = (void *)(h->rxdesc[rxdescqt].ptr);
    r_nbytes = descf & SPWL_DESC_LENMASK;
    r_eop    = SPWL_EOP_DESC_TO_FLAG(descf);
    h->rxdescqlen--;

    /* Reset partial frame position.
       Mixing calls to spwl_recv() and spwl_recv_rxbuf() is not supported. */
    h->currxpos = 0;

    ret = RTEMS_SUCCESSFUL;

out_unlock:
    /* Restore interrupts. */
#ifdef SPWL_CHECK_CONCURRENT_CALL
    h->recvbusy = 0;
#endif
    rtems_interrupt_enable(level);

    *buf    = r_buf;
    *nbytes = r_nbytes;
    *eop    = r_eop;
    return ret;
}


/* Release receive buffers back to the driver. */
rtems_status_code spwl_release_rxbuf(spwl_handle h, void *buf)
{
    rtems_interrupt_level level;

    /* Disable interrupts. */
    rtems_interrupt_disable(level);

    /* Insert buffer at head of RX ring. */
    writemem(&h->rxdesc[h->rxdescqh].ptr, (uint32_t)buf);
    writemem(&h->rxdesc[h->rxdescqh].flags,
             h->rxbufsize | SPWL_DESC_EN | SPWL_DESC_IE);
    h->rxdescqh = (h->rxdescqh + 1) & (h->ndesc - 1);
    h->rxdescqlen++;

    /* Restart RX DMA. */
    spwl_ctrl_setbits(h, SPWL_CONTROL_RXDMA);

    /* Restore interrupts. */
    rtems_interrupt_enable(level);

    return RTEMS_SUCCESSFUL;
}


/* Submit data for transmission to the SpaceWire link without copying. */
rtems_status_code spwl_send_txbuf(spwl_handle h,
                                  struct spwl_txbuf *buf, unsigned int flags)
{
    rtems_status_code   ret;
    rtems_interrupt_level level;
    unsigned int        txdescqp;
    uint32_t            descf;

    /* Disable interrupts. */
    rtems_interrupt_disable(level);

#ifdef SPWL_CHECK_CONCURRENT_CALL
    /* Limit damage in case of concurrent calls. */
    if (h->sendbusy) {
        rtems_interrupt_enable(level);
        return RTEMS_RESOURCE_IN_USE;
    }
    h->sendbusy = 1;
#endif

    /* Make sure there is room in the TX ring. */
    while (1) {

        /* Reap completed TX descriptors if possible. */
        reap_tx_descriptors(h);

        if (h->txdescqlen > 0 && h->txappnact == 0) {
            /* Internal buffers in the TX ring; wait until they are gone. */
            txdescqp = (h->txdescqh - 1) & (h->ndesc - 1);
        } else if (h->txdescqlen >= h->ndesc) {
            /* TX ring is full; wait until at least one buffer is gone. */
            txdescqp = (h->txdescqh - h->txdescqlen) & (h->ndesc - 1);
        } else {
            /* Good to go. */
            break;
        }

        /* There is currently no room.
           Stop if the application does not want to wait. */
        if ((flags & SPWL_NO_WAIT) != 0) {
            ret = RTEMS_UNSATISFIED;
            goto out_unlock;
        }

        /* Enable interrupt on data transmitted. */
        spwl_ctrl_setbits(h, SPWL_CONTROL_IETXDESC);

        /* Final check for completed TX descriptor (avoid race condition). */
        descf = readmem_nocache(&h->txdesc[txdescqp].flags);
        if ((descf & SPWL_DESC_DONE) == 0) {
            /* Wait until TX interrupt. */
            wait_for_interrupt(h->seminterrupt, level, RTEMS_NO_TIMEOUT);
            rtems_interrupt_disable(level);
        }
    }

    /* There is room for at least one frame.
       Insert buffer at head of application-buffer list. */
    buf->next = NULL;
    if (h->txappqh != NULL)
        h->txappqh->next = buf;
    else
        h->txappqt = buf;
    h->txappqh = buf;
    h->txappnact++;

    /* Insert buffer at head of TX descriptor ring. */
    descf = buf->nbytes |
            SPWL_EOP_FLAG_TO_DESC(buf->eop) | SPWL_DESC_EN | SPWL_DESC_IE;
    writemem(&h->txdesc[h->txdescqh].ptr, (uint32_t)(buf->data));
    writemem(&h->txdesc[h->txdescqh].flags, descf);
    h->txdescqh = (h->txdescqh + 1) & (h->ndesc - 1);
    h->txdescqlen++;

    /* Restart TX DMA. */
    spwl_ctrl_setbits(h, SPWL_CONTROL_TXDMA);

    ret = RTEMS_SUCCESSFUL;

out_unlock:
    /* Restore interrupts. */
#ifdef SPWL_CHECK_CONCURRENT_CALL
    h->sendbusy = 0;
#endif
    rtems_interrupt_enable(level);

    return ret;
}


/* Reclaim transmit buffers after completion of transmission. */
rtems_status_code spwl_reclaim_txbuf(spwl_handle h,
                                     struct spwl_txbuf **buf, unsigned flags)
{
    rtems_status_code   ret;
    rtems_interrupt_level level;
    struct spwl_txbuf  *r_buf = NULL;
    unsigned int        txdescqt;
    uint32_t            descf;

    /* Disable interrupts. */
    rtems_interrupt_disable(level);

    /* Make sure the reclaim list is not empty. */
    while (1) {

        /* Reap completed TX descriptors if possible. */
        reap_tx_descriptors(h);

        /* Check that the reclaim list is non-empty. */
        if (h->txappnrcl > 0)
            break;

        /* No buffers ready to reclaim.
           Stop if the application does not want to wait. */
        if ((flags & SPWL_NO_WAIT) != 0) {
            ret = RTEMS_UNSATISFIED;
            goto out_unlock;
        }

        /* Enable interrupt on data transmitted. */
        spwl_ctrl_setbits(h, SPWL_CONTROL_IETXDESC);

        /* Final check for completed TX descriptors (avoid race condition). */
        if (h->txappnact > 0) {
            /* There are application buffers in the TX ring.
               Maybe one has completed in the mean time. */
            txdescqt = (h->txdescqh - h->txdescqlen) & (h->ndesc - 1);
            descf = readmem_nocache(&h->txdesc[txdescqt].flags);
            if ((descf & SPWL_DESC_DONE) != 0)
                continue;
        }

        /* Wait until TX interrupt. */
        wait_for_interrupt(h->seminterrupt, level, RTEMS_NO_TIMEOUT);
        rtems_interrupt_disable(level);
    }

    /* The reclaim list is non-empty. 
       Pass one reclaimable buffer to the application. */
    r_buf = h->txappqt;
    h->txappqt = h->txappqt->next;
    if (h->txappqt == NULL)
        h->txappqh = NULL;
    h->txappnrcl--;
    r_buf->next = NULL;

    ret = RTEMS_SUCCESSFUL;

out_unlock:
    /* Restore interrupts. */
    rtems_interrupt_enable(level);

    /* Return */
    *buf = r_buf;
    return ret;
}


/* Return last received timecode. */
uint8_t spwl_get_timecode(spwl_handle h)
{
    uint32_t v;

    /* Clear "tick" bit in status register. */
    writereg(h->devaddr + SPWL_REG_STATUS, SPWL_STATUS_TICK);

    /* Read last received timecode. */
    v = readreg(h->devaddr + SPWL_REG_TIMECODE);
    return v & 0xff;
}


/* Send a timecode to the SpaceWire link. */
rtems_status_code spwl_send_timecode(spwl_handle h, uint8_t timecode)
{
    writereg(h->devaddr + SPWL_REG_TIMECODE, 0x10000 | (timecode << 8));
    return RTEMS_SUCCESSFUL;
}
                                    
/* vim: expandtab softtabstop=4
*/
/* end */
