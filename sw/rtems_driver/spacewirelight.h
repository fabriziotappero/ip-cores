/*
 * Copyright 2010 Joris van Rantwijk
 *
 * This code is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 */

/**
 * @file    spacewirelight.h
 * @brief   SpaceWire Light driver for RTEMS 4.10 on LEON3.
 *
 * == Resources ==
 *
 * The driver allocates resources during the call to spwl_open_XXX() and
 * releases all resources in spwl_close().
 *
 * The driver allocates memory by calling malloc() and rtems_memalign().
 * The amount of memory required per device handle depends on the configuration
 * of the driver and the hardware:
 *   ~200 bytes for the device handle;
 *   (rxbufs * rxbufsize) bytes for receive buffers;
 *   (txbufs * txbufsize) bytes for transmit buffers;
 *   2 * 8 * (2**desctablesize) bytes for descriptor tables (where
 *   desctablesize depends on the configuration of the SpaceWire Light core).
 *
 * The driver creates a binary semaphores for internal synchronization.
 *
 * == Data flow ==
 *
 * Data delivery is packet-oriented. Although partial SpaceWire packets
 * may be sent/received, delivery of such data is not guaranteed until
 * the packet has been completed with an end-of-packet marker.
 *
 * For example, it is ok to call spwl_send() without an EOP flag to send
 * a partial SpaceWire packet, but in this case the data may linger in memory
 * for an unlimited period. Data delivery is not guaranteed until after
 * spwl_send() has been called again with the final part of the packet and
 * the EOP flag.
 *
 * Similarly, an incoming partial SpaceWire packet is not guaranteed to
 * be delivered to the application until after the packet's EOP marker
 * has been received.
 *
 * == Concurrency ==
 *
 * All API functions are reentrant, i.e. may be called concurrently
 * from multiple tasks for different device handles.
 *
 * Most API functions are thread-safe, i.e. may be called concurrently
 * for the same device handle. The exceptions are
 *  o spwl_close() must not be called concurrently with any other
 *    API function for the same device handle;
 *  o spwl_recv() and spwl_recv_rxbuf() must not be called concurrently
 *    with themselves or with eachother by multiple tasks for the same
 *    device handle;
 *  o spwl_send() and spwl_send_txbuf() must not be called concurrently
 *    with themselves or with eachother by multiple tasks for the same
 *    device handle.
 *
 * The API functions disable interrupts for limited periods of time
 * to ensure exclusive access to data structures and hardware registers.
 */

#ifndef _SPACEWIRELIGHT_H
#define _SPACEWIRELIGHT_H

#include <stdint.h>
#include <rtems.h>


/** Handle used to identify an open SpaceWire Light device. */
typedef struct spwl_context * spwl_handle;


/** Device ID used by SpaceWire Light in AMBA plug&play table. */
#define DEVICE_SPACEWIRELIGHT   0x131


/** Link mode. */
typedef enum {
    SPWL_LINKMODE_NOP       = 0,    /**< Leave the SpaceWire link as it is;
                                         don't try to (re)start or stop it. */
    SPWL_LINKMODE_START     = 1,    /**< Enable the SpaceWire link. */
    SPWL_LINKMODE_AUTOSTART = 2,    /**< Enable autostart mode. */
    SPWL_LINKMODE_DISABLE   = 3     /**< Disable the SpaceWire link. */
} spwl_linkmode;


/** Link status. */
typedef enum {
    SPWL_LINK_OFF           = 0,
    SPWL_LINK_STARTED       = 1,
    SPWL_LINK_CONNECTING    = 2,
    SPWL_LINK_RUN           = 3
} spwl_linkstatus;


/* Error bits returned by spwl_get_linkstatus(). */
#define SPWL_ERR_DISCONNECT 0x04
#define SPWL_ERR_PARITY     0x08
#define SPWL_ERR_ESCAPE     0x10
#define SPWL_ERR_CREDIT     0x20
#define SPWL_ERR_AHB        0x100

/* Flag bits used by recv/send functions. */
#define SPWL_WAIT           0x00    /**< Block task until call can proceed. */
#define SPWL_NO_WAIT        0x01    /**< Do not block task. */
#define SPWL_EOP            0x10    /**< Send/received EOP. */
#define SPWL_EEP            0x20    /**< Send/received EEP. */

/* Condition bits used by spwl_wait function. */
#define SPWL_COND_RDYRECV   0x01    /**< Received data is ready. */
#define SPWL_COND_RDYSEND   0x02    /**< Ready for spwl_send(). */
#define SPWL_COND_RDYSENDBUF 0x04   /**< Ready for spwl_send_txbuf(). */
#define SPWL_COND_RECLAIM   0x08    /**< Ready for spwl_reclaim_txbuf(). */
#define SPWL_COND_TIMECODE  0x10    /**< Timecode received after the last call to spwl_get_timecode(). */
#define SPWL_COND_LINKUP    0x20    /**< Link is up. */
#define SPWL_COND_LINKDOWN  0x40    /**< Link is down. */


/** Optional parameters to be passed when opening the driver. */
struct spwl_options {

    /** Number of receive buffers to allocate.
        (Can not be larger than the hardware descriptor table). */
    unsigned int    rxbufs;

    /** Number of transmit buffers to allocate.
        (Can not be larger than the hardware descriptor table). */
    unsigned int    txbufs;

    /** Size of each receive buffer in bytes (at most 65532). */
    unsigned int    rxbufsize;

    /** Size of each allocated transmit buffer in bytes (at most 65532).
        Does not affect the size of queued application buffers. */
    unsigned int    txbufsize;
};


/** Initializer for spwl_options (default values). */
#define SPWL_OPTIONS_DEFAULT    { 32, 16, 2048, 2048 }


/** Description of a buffer holding data to be transmitted. */
typedef struct spwl_txbuf {
    const void *data;               /**< Pointer to buffer, 4-byte aligned. */
    uint16_t    nbytes;             /**< Number of bytes to be transmitted. */
    uint16_t    eop;                /**< SPWL_EOP or SPWL_EEP or 0. */
    uint32_t    tag;                /**< Optional application-defined field. */
    struct spwl_txbuf *next;        /**< Used internally by library. */
} spwl_txbuf_t;


/**
 * Open a SpaceWire Light device.
 *
 * Open the index'th SpaceWire Light device found in the AMBA plug&play map.
 * Allocate receive/transmit buffers and reset the device core.
 *
 * A SpaceWire Light device which is already open, may not be opened again
 * until the existing handle has been closed.
 *
 * @retval RTEMS_SUCCESSFUL     Open successful.
 * @retval RTEMS_INVALID_NUMBER Core not found in AMBA plug&play map.
 * @retval RTEMS_INVALID_SIZE   Invalid option value.
 *
 * @param[out] h    Device handle supplied by the driver.
 * @param[in] index Index of the SpaceWire Light core to use.
 * @param[in] opt   Pointer to a structure of optional device parameters,
 *                  or NULL to use default parameters.
 */
rtems_status_code spwl_open(spwl_handle *h,
                            unsigned int index,
                            const struct spwl_options *opt);


/**
 * Open a SpaceWire Light device.
 *
 * Open a SpaceWire Light device identified by its hardware base address
 * and IRQ number. Allocate receive/transmit buffers and reset the device core.
 *
 * A SpaceWire Light device which is already open, may not be opened again
 * until the existing handle has been closed.
 *
 * @retval RTEMS_SUCCESSFUL     Open successful.
 * @retval RTEMS_INVALID_SIZE   Invalid option value.
 *
 * @param[out] h    Device handle supplied by the driver.
 * @param[in] addr  Base address of the SpaceWire Light core.
 * @param[in] irq   Interrupt number of the SpaceWire Light core (hardware
 *                  IRQ number, zero-based).
 * @param[in] opt   Pointer to a structure of optional device parameters,
 *                  or NULL to use default parameters.
 */
rtems_status_code spwl_open_hwaddr(spwl_handle *h,
                                   unsigned long addr, unsigned int irq,
                                   const struct spwl_options *opt);


/**
 * Close an open SpaceWire Light device.
 * Reset the SpaceWire Light core and release all associated memory.
 *
 * This function must not be called concurrently with any other
 * API function for the same device handle.
 *
 * @param[in] h     Device handle to close; this handle will be invalid
 *                  after this call.
 */
void spwl_close(spwl_handle h);


/**
 * Set the TX clock scaler for the link.
 *
 * The link bit rate defaults to 10 Mbit/s.
 * Link handshake is always done at 10 Mbit/s, regardless of this setting.
 *
 * This function sets the TX bit rate to
 *   (txclkfreq / (scaler + 1)) bits per second;
 *   where txclkfreq is determined by the hardware configuration of the core.
 *
 * If a link is up, this function immediately affects the current bit rate.
 * Future links will perform the handshake at 10 Mbit/s and then switch
 * to the rate programmed through this function.
 *
 * @param[in]  h        Device handle.
 * @param[in]  scaler   Scale factor for TX clock minus 1 (0 <= scaler <= 255).
 */
rtems_status_code spwl_set_linkspeed(spwl_handle h, unsigned int scaler);


/**
 * Return the currently configured TX clock scaler (minus 1).
 */
unsigned int spwl_get_linkspeed(spwl_handle h);


/**
 * Return the default TX scaler value (i.e. approximately 10 Mbit).
 */
unsigned int spwl_get_default_linkspeed(spwl_handle h);


/**
 * Change the mode of the SpaceWire link.
 *
 * @param[in] h         Device handle.
 * @param[in] mode      New mode for SpaceWire link.
 */
rtems_status_code spwl_set_linkmode(spwl_handle h, spwl_linkmode mode);


/**
 * Return the current status of the SpaceWire link.
 * Also return any link errors that occurred since the previous call to
 * this function.
 *
 * @param[in] h         Device handle.
 * @param[out] status   Current status of SpaceWire link.
 * @param[out] errors   Pending errors as OR mask of SPWL_ERR_xxx values.
 */
rtems_status_code spwl_get_linkstatus(spwl_handle h,
                                      spwl_linkstatus *linkstatus,
                                      unsigned int *errors);


/**
 * Wait for specified condition with timeout.
 *
 * Block the task until at least one of the specified conditions occurs
 * or the specified timeout elapses.
 *
 * Wait conditions are specified as a bitwise OR of SPWL_COND_xxx constants:
 *   SPWL_COND_RDYRECV :    return when data is ready to be received;
 *   SPWL_COND_RDYSEND :    return when spwl_send() can proceed;
 *   SPWL_COND_RDYSENDBUF : return when spwl_send_txbuf() can proceed;
 *   SPWL_COND_RECLAIM :    return when a tx buffer is ready to be reclaimed.
 *   SPWL_COND_TIMECODE :   return when a timecode has been received after
 *                          the last call to spwl_get_timecode;
 *   SPWL_COND_LINKUP :     return when the link is up;
 *   SPWL_COND_LINKDOWN :   return when the link is down.
 *
 * @retval RTEMS_SUCCESSFUL At least one of the specified conditions satisfied.
 * @retval RTEMS_TIMEOUT    Timeout elapsed before any condition is satisfied.
 *
 * @param[in]  h        Device handle.
 * @param[in]  cond     Conditions to wait for (OR mask of SPWL_COND_xxx bits).
 * @param[out] cond     Conditions satisfied (OR mask of SPWL_COND_xxx bits).
 * @param[in]  timeout  Maximum time to wait as a number of RTEMS clock ticks,
 *                      or 0 to wait forever.
 */
rtems_status_code spwl_wait(spwl_handle h,
                            unsigned int *cond, rtems_interval timeout);


/**
 * Transfer received data to the specified application buffer.
 *
 * If the end of a SpaceWire packet is reached, stop the transfer and
 * report the end-of-packet marker in *eop.
 *
 * Stop the transfer when maxlen bytes have been transfered without
 * reaching the end of a SpaceWire packet. The remainder of the packet
 * will be transfered during the next call to spwl_recv().
 *
 * If SPWL_NO_WAIT is specified and there is not enough data available
 * to satisfy the request, transfer as much data as is currently available.
 * If SPWL_WAIT is specified, block the task until either maxlen bytes
 * have been received or the end of a SpaceWire packet is reached.
 *
 * @retval RTEMS_SUCCESSFUL     Request was at least partially successful.
 * @retval RTEMS_UNSATISFIED    No data available and SPWL_NO_WAIT specified.
 *
 * This function is more efficient if the application buffer is 4-byte aligned.
 *
 * This function must not be called concurrently with itself or with
 * spwl_recv_rxbuf() from multiple tasks for the same device handle.
 *
 * @param[in]  h        Device handle.
 * @param[out] buf      Pointer to application buffer.
 * @param[in]  maxlen   Maximum number of bytes to transfer.
 * @param[out] ntrans   Actual number of bytes transfered.
 * @param[out] eop      End-of-packet marker; either SPWL_EOP or SPWL_EEP or 0.
 * @param[in]  flags    Blocking mode, either SPWL_WAIT or SPWL_NO_WAIT.
 */
rtems_status_code spwl_recv(spwl_handle h,
                            void *buf, size_t maxlen, size_t *ntrans,
                            unsigned int *eop, unsigned int flags);


/**
 * Send data to the SpaceWire link.
 *
 * Send maxlen bytes from the application buffer to the SpaceWire link,
 * optionally followed by an end-of-packet marker. If an end-of-packet
 * marker is not specified, the following call to spwl_send() will
 * add more data to the same packet.
 *
 * If SPWL_NO_WAIT is specified and there is not enough room in the
 * transmit queue to satisfy the request, transfer as much data as can
 * be immediately stored.
 * If SPWL_WAIT is specified, block the task until exactly maxlen bytes
 * have been transfered.
 *
 * @retval RTEMS_SUCCESSFUL     Request at least partially succesful.
 * @retval RTEMS_UNSATISFIED    No data could be transfered (SPWL_NO_WAIT).
 *
 * This function is more efficient if the application buffer is 4-byte aligned.
 *
 * This function must not be called concurrently with itself or with
 * spwl_send_txbuf() from multiple tasks for the same device handle.
 *
 * @param[in]  h        Device handle.
 * @param[in]  buf      Pointer to application buffer.
 * @param[in]  maxlen   Maximum number of bytes to transfer.
 * @param[out] ntrans   Actual number of bytes transferred.
 * @param[in]  flags    Bitwise OR of blocking flags (SPWL_WAIT or SPWL_NO_WAIT)
 *                      and end-of-packet marker (SPWL_EOP or SPWL_EEP or 0).
 */
rtems_status_code spwl_send(spwl_handle h,
                            const void *buf, size_t maxlen, size_t *ntrans,
                            unsigned int flags);


/**
 * Receive data from the SpaceWire link without copying.
 *
 * Take one frame from the tail of the receive queue and pass
 * its data pointer to the application.
 *
 * If SPWL_NO_WAIT is specified and the receive queue is empty, return
 * RTEMS_UNSATISFIED. If SPWL_WAIT is specified an the receive queue
 * is empty, block the task until a received frame becomes available.
 *
 * Data buffers returned by this function are still owned by the driver.
 * When the application has finished processing the data, it must release
 * the buffers back to the driver by calling spwl_release_rxbuf().
 *
 * @retval RTEMS_SUCCESS        Request successful.
 * @retval RTEMS_UNSATISFIED    No received buffer available (SPWL_NO_WAIT).
 *
 * The driver owns a limited number of receive buffers (configurable through
 * spwl_options.rxbufs). If the application holds on to too many received
 * buffers, the driver may run out of buffers to work with.
 *
 * This function is more efficient than spwl_recv() because it does not
 * copy received data. Depending on the hardware configuration, the contents
 * of DMA buffers returned by this function may not be coherent with the
 * data cache of the CPU. The LEON3 provides transparent cache coherency
 * only when cache snooping is enabled in the CPU configuration. Otherwise
 * the application must explicitly deal with cache coherency issues, either
 * by using cache bypass instructions when accessing the data or by flushing
 * the data cache before accessing the buffer.
 *
 * Mixing calls to spwl_recv() and spwl_recv_rxbuf() is not recommended.
 * This function must not be called concurrently with itself or with
 * spwl_recv() from multiple tasks for the same device handle.
 *
 * @param[in]  h        Device handle.
 * @param[out] buf      Pointer to data buffer.
 * @param[out] nbytes   Number of data bytes in returned data buffer.
 * @param[out] eop      End-of-packet flags associated with returned buffer.
 * @param[in]  flags    Blocking mode, either SPWL_WAIT or SPWL_NO_WAIT.
 */
rtems_status_code spwl_recv_rxbuf(spwl_handle h,
                                  void **buf,
                                  uint16_t *nbytes, unsigned int *eop,
                                  unsigned int flags);


/**
 * Release a receive buffer back to the driver.
 *
 * Buffers obtained through spwl_recv_rxbuf() must be released to the
 * driver through this function. The order in which buffers are released
 * is not important.
 *
 * Each time a pointer is obtained through spwl_recv_rxbuf(), there must be
 * exactly one release of that pointer through this function. Total chaos
 * will ensue if other pointers than those obtained through spwl_recv_rxbuf()
 * are passed to this function, or if a pointer acquired once is released
 * multiple times.
 *
 * @param[in]  h        Device handle.
 * @param[in]  buf      Data buffer to be returned to the driver.
 */
rtems_status_code spwl_release_rxbuf(spwl_handle h, void *buf);


/**
 * Submit data for transmission to the SpaceWire link without copying.
 *
 * Add the buffer to the tail of the transmit queue. This function is more
 * efficient than spwl_send() because it does not copy data.
 *
 * The data buffer pointer (buf->data) must be 4-byte aligned.
 *
 * If SPWL_NO_WAIT is specified and the transmit queue is full, return
 * RTEMS_UNSATISFIED. If SPWL_WAIT is specified and the transmit queue
 * is full, block the task until the buffer can be queued.
 *
 * The driver internally keeps a pointers to the submitted spwl_txbuf
 * structure. The application must guarantee that this structure, and
 * the buffer it points to, remain valid and unchanged after this call.
 * After the driver finishes processing of the data, the buffer structure
 * is returned to the application through spwl_reclaim_txbuf().
 *
 * @retval RTEMS_SUCCESSFUL     Buffer queued for transmission.
 * @retval RTEMS_UNSATISFIED    No room in TX queue (SPWL_NO_WAIT).
 *
 * Mixing calls to spwl_send() and spwl_send_txbuf() is not recommended.
 * This function must not be called concurrently with itself or with
 * spwl_send() from multiple tasks for the same device handle.
 *
 * @param[in]  h        Device handle.
 * @param[in]  buf      Structure describing frame to be queued.
 * @param[in]  flags    Blocking mode, either SPWL_WAIT or SPWL_NO_WAIT.
 */
rtems_status_code spwl_send_txbuf(spwl_handle h,
                                  struct spwl_txbuf *buf, unsigned int flags);


/**
 * Reclaim transmit buffer after completion of transmission.
 *
 * Buffers queued through spwl_send_txbuf() are eventually passed back
 * to the application through this function. The driver returns the same
 * spwl_txbuf pointers that were originally submitted by the application.
 * Buffers are passed back in the same order in which they were submitted
 * by the application.
 *
 * Except for the "next" field, the contents of the spwl_txbuf structures
 * is not changed by the driver. The "next" field is used internally by the
 * driver and is set to NULL when the buffer is returned.
 *
 * If SPWL_NO_WAIT is specified and there are no buffers ready to be reclaimed,
 * return RTEMS_UNSATISFIED. If SPWL_WAIT is specified, block the task until
 * a buffer can be reclaimed.
 *
 * @retval RTEMS_SUCCESSFUL     Successfully reclaimed a buffer.
 * @retval RTEMS_UNSATISFIED    No reclaimable buffer (SPWL_NO_WAIT).
 *
 * @param[in]  h        Device handle.
 * @param[out] buf      Completed spwl_txbuf structure.
 * @param[in]  flags    Blocking mode, either SPWL_WAIT or SPWL_NO_WAIT.
 */
rtems_status_code spwl_reclaim_txbuf(spwl_handle h,
                                     struct spwl_txbuf **buf,
                                     unsigned int flags);


/**
 * Return last received timecode.
 */
uint8_t spwl_get_timecode(spwl_handle h);


/**
 * Send a timecode to the SpaceWire link.
 *
 * @param[in]  h        Device handle.
 * @param[in]  timecode Time code to transmit.
 */
rtems_status_code spwl_send_timecode(spwl_handle h, uint8_t timecode);
                                     
#endif
/* end */
