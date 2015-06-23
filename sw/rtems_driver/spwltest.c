/*
 * Test program for SpaceWire Light RTEMS driver.
 * Joris van Rantwijk, 2010.
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <termios.h>
#include <rtems.h>
#include <rtems/error.h>
#include <bsp.h>
#include "spacewirelight.h"

void Init(rtems_task_argument);

#define CONFIGURE_INIT
#define CONFIGURE_APPLICATION_NEEDS_CONSOLE_DRIVER
#define CONFIGURE_APPLICATION_NEEDS_CLOCK_DRIVER
#define CONFIGURE_RTEMS_INIT_TASKS_TABLE
#define CONFIGURE_INIT_TASK_ENTRY_POINT             Init
#define CONFIGURE_MAXIMUM_TASKS                     10
#define CONFIGURE_MAXIMUM_SEMAPHORES                10
#include <rtems/confdefs.h>


struct data_test_context {
    int queued;
    unsigned int rxpackets;
    unsigned int rxblocksize;
    unsigned int txpackets;
    unsigned int txpacketsize;
    unsigned int txblocksize;
    int verify;
    rtems_id semaphore;
    volatile unsigned int txdone_packets;
    volatile unsigned int rxdone_packets;
    volatile unsigned int rxdone_bytes;
    volatile unsigned int rxminsize;
    volatile unsigned int rxmaxsize;
    volatile int mismatch;
};

static spwl_handle      spwh;
static unsigned int     spw_index;
static struct spwl_options spw_opt = SPWL_OPTIONS_DEFAULT;
static spwl_linkmode    spw_mode;

#define MAX_BLOCK_SIZE 16384            /* do not change */
static unsigned char rxbuf[MAX_BLOCK_SIZE];
static unsigned char txpool[2*MAX_BLOCK_SIZE];
static spwl_txbuf_t  txbuf_desc[16];

static const unsigned int autotest_blocksize[] = {
    1, 101, 500, 2048, 4000, 0 };
static const unsigned int autotest_packetsize[] = {
    1, 2, 3, 4, 100, 101, 1000, 4096, 10000, 100000, 1000000, 0 };

/* Report error and stop program. */
static void fatal_error(const char *s, rtems_status_code err)
{
    fprintf(stderr, "ERROR: %s", s);
    if (err)
        fprintf(stderr, " (%s)", rtems_status_text(err));
    fprintf(stderr, "\n");
    rtems_shutdown_executive(1);
}


/* Wait for user to enter a string. */
static void get_string(char *buf, size_t maxlen)
{
    unsigned int i;
    int k;
    char c;

    i = strlen(buf);
    printf("%s", buf);
    fflush(stdout);

    while (1) {
        k = read(STDIN_FILENO, &c, 1);
        if (k != 1)
            fatal_error("read from console", 0);
        if (c == '\b' && i > 0) {
            i--;
            printf("\b \b");
            fflush(stdout);
        } else if (c == '\n' || c == '\r') {
            buf[i] = '\0';
            printf("\n");
            fflush(stdout);
            return;
        } else if (i + 1 < maxlen && c >= 32 && c < 127) {
            buf[i++] = c;
            printf("%c", c);
            fflush(stdout);
        }
    }
}


/* Wait for user to enter a non-negative number. */
static int get_num(const char *prompt, int low, int high, int deflt)
{
    char buf[20];
    char *p;
    unsigned long v;

    while (1) {
        printf("%s ", prompt);
        fflush(stdout);

        if (deflt >= 0)
            sprintf(buf, "%d", deflt);
        else
            buf[0] = '\0';
        get_string(buf, sizeof(buf));

        v = strtoul(buf, &p, 10);
        while (p != buf && *p == ' ')
            p++;

        if (p != buf && *p == '\0' && v >= low && v <= high)
            return v;
    }
}


/* Wait for user to enter an option index.
   Return entered number, or -1 if an empty string was entered. */
static int get_opt(int high)
{
    char buf[20];
    char *p;
    unsigned long v;

    while (1) {
        printf("Option (0 .. %d) ? ", high);
        fflush(stdout);

        buf[0] = '\0';
        get_string(buf, sizeof(buf));

        if (buf[0] == '\0')
            return -1;

        v = strtoul(buf, &p, 10);
        while (p != buf && *p == ' ')
            p++;

        if (p != buf && *p == '\0' && v <= high)
            return v;
    }
}


/* Set console to non-blocking. */
void set_nonblocking(int fd, struct termios *tcattr_orig)
{
    cc_t vmin_orig;
    tcgetattr(STDIN_FILENO, tcattr_orig);
    vmin_orig = tcattr_orig->c_cc[VMIN];
    tcattr_orig->c_cc[VMIN] = 0;
    tcsetattr(STDIN_FILENO, TCSANOW, tcattr_orig);
    tcattr_orig->c_cc[VMIN] = vmin_orig;
}


/* Open driver. */
void open_driver(void)
{
    rtems_status_code ret;

    printf("Opening driver for device index %u\n"
           "  options: rxbufs=%u, txbufs=%u, rxbufsize=%u, txbufsize=%u\n",
           spw_index,
           spw_opt.rxbufs, spw_opt.txbufs,
           spw_opt.rxbufsize, spw_opt.txbufsize);

    ret = spwl_open(&spwh, spw_index, &spw_opt);
    if (ret != RTEMS_SUCCESSFUL) {
        if (ret == RTEMS_INVALID_NUMBER)
            fprintf(stderr, "ERROR: SpaceWire Light core not found\n");
        fatal_error("spwl_open", ret);
    }

    spw_mode = SPWL_LINKMODE_NOP;

    printf("  ok\n");
}


/* Show current link mode and status. */
void show_status(void)
{
    spwl_linkstatus status;
    unsigned int speed;

    spwl_get_linkstatus(spwh, &status, NULL);
    speed = 100 * (spwl_get_default_linkspeed(spwh) + 1) / (spwl_get_linkspeed(spwh) + 1);
    printf("[ mode=%s,  status=%s,  speed=%u.%uMbit ]\n",
           ((spw_mode == SPWL_LINKMODE_START) ?     "start" :
            (spw_mode == SPWL_LINKMODE_AUTOSTART) ? "autostart" :
            (spw_mode == SPWL_LINKMODE_DISABLE) ?   "disable" : "nop"),
           ((status == SPWL_LINK_STARTED) ?    "started" :
            (status == SPWL_LINK_CONNECTING) ? "connecting" :
            (status == SPWL_LINK_RUN) ?        "RUN" : "off"),
           speed/10, speed%10);
}


/* Re-initialize driver. */
void do_init_driver(void)
{
    amba_apb_device apbdev;
    unsigned int i;

    printf("\n---- Re-initialize driver ----\n");
    printf("Closing driver\n");
    spwl_close(spwh);

    printf("Detected SpaceWire Light devices:\n");
    for (i = 0; ; i++) {
        if (!amba_find_next_apbslv(&amba_conf, VENDOR_OPENCORES, DEVICE_SPACEWIRELIGHT, &apbdev, i))
            break;
        printf(" index=%u, addr=0x%08x, irq=%u\n", i, apbdev.start, apbdev.irq);
    }

    spw_index = get_num("Enter index of device to open:", 0, 100, -1);
    spw_opt.rxbufs    = get_num("Number of RX buffers (min 0, max 4096):",
                                0, 4096, spw_opt.rxbufs);
    spw_opt.txbufs    = get_num("Number of TX buffers (min 0, max 4096):",
                                0, 4096, spw_opt.txbufs);
    spw_opt.rxbufsize = get_num("RX buffer size (bytes, min 32, max 16384):",
                                0, MAX_BLOCK_SIZE, spw_opt.rxbufsize);
    spw_opt.txbufsize = get_num("TX buffer size (bytes, min 32, max 16384):",
                                0, MAX_BLOCK_SIZE, spw_opt.txbufsize);

    open_driver();
}


/* Change link mode. */
void do_set_link_mode(void)
{
    rtems_status_code ret;
    int opt;

    printf("\n---- Change link mode ----\n");
    show_status();
    printf(" 1.  Start     - start link; restart link after error\n");
    printf(" 2.  Autostart - wait for remote activity before starting the link\n");
    printf(" 3.  Disable   - disable link\n");
    printf(" 4.  Nop       - keep current link status; do not restart after error\n");

    opt = get_opt(4);
    if (opt > 0) {
        printf("\n");

        switch (opt) {
            case 1:
                printf("Setting link mode = start\n");
                spw_mode = SPWL_LINKMODE_START;
                break;
            case 2:
                printf("Setting link mode = autostart\n");
                spw_mode = SPWL_LINKMODE_AUTOSTART;
                break;
            case 3:
                printf("Setting link mode = disable\n");
                spw_mode = SPWL_LINKMODE_DISABLE;
                break;
            case 4:
                printf("Setting link mode = nop\n");
                spw_mode = SPWL_LINKMODE_NOP;
                break;
        }

        ret = spwl_set_linkmode(spwh, spw_mode);
        if (ret != RTEMS_SUCCESSFUL)
            fatal_error("spwl_set_linkmode", ret);
        printf("  ok\n");
    }
}


/* Change link speed. */
void do_set_link_speed(void)
{
    char prompt[80];
    rtems_status_code ret;
    int maxspeed, speed, scaler, scaler10;

    printf("\n---- Change link speed ----\n");

    scaler10 = spwl_get_default_linkspeed(spwh);
    scaler = spwl_get_linkspeed(spwh);
    speed = (10 * (scaler10 + 1) + scaler / 2) / (scaler + 1);
    maxspeed = 10 * (scaler10 + 1);

    sprintf(prompt, "New link speed in Mbit/s (2 .. %d) ?", maxspeed);
    speed = get_num(prompt, 2, maxspeed, speed);

    scaler = (10 * (scaler10 + 1) + speed / 2) / speed - 1;
    if (scaler > 255)
        scaler = 255;

    speed = 100 * (scaler10 + 1) / (scaler + 1);
    printf("Setting speed = %d.%d Mbit/s, scaler = %d\n", speed/10, speed%10, scaler);
    ret = spwl_set_linkspeed(spwh, scaler);
    if (ret != RTEMS_SUCCESSFUL)
        fatal_error("spwl_set_linkmode", ret);
    printf("  ok\n");
}


/* RX/TX event loop. */
static int do_data_test_eventloop(struct data_test_context *ctx)
{
    rtems_status_code ret;
    unsigned int rxdone_packets = 0, rxdone_bytes = 0;
    unsigned int rxminsize = 0, rxmaxsize = 0;
    unsigned int txdone_packets = 0;
    unsigned int rxpos = 0, txpos = 0, txbufp = 0, txbufn = 0;
    unsigned int cond;
    unsigned int f, offset;
    void *buf;
    size_t p;
    int k;
    char c;

    /* Flush pending reclaimable buffers from previous test. */
    {
        spwl_txbuf_t *tmp;
        while (spwl_reclaim_txbuf(spwh, &tmp, SPWL_NO_WAIT) == RTEMS_SUCCESSFUL)
            ;
    }

    /* Run until test completes or user aborts. */
    while (txdone_packets < ctx->txpackets ||
           rxdone_packets < ctx->rxpackets ||
           txbufn > 0) {

        /* Abort test when user hits Enter. */
        do {
            k = read(STDIN_FILENO, &c, 1);
        } while (k == 1 && c != '\n' && c != '\r');
        if (k == 1 && (c == '\n' || c == '\r'))
            return -1;

        /* Wait until progress can be made. */
        cond = 0;
        if (txbufn > 0)
            cond |= SPWL_COND_RECLAIM;
        if (ctx->queued && txdone_packets < ctx->txpackets && txbufn < 16)
            cond |= SPWL_COND_RDYSENDBUF;
        if (!ctx->queued && txdone_packets < ctx->txpackets)
            cond |= SPWL_COND_RDYSEND;
        if (rxdone_packets < ctx->rxpackets)
            cond |= SPWL_COND_RDYRECV;
        ret = spwl_wait(spwh, &cond, rtems_clock_get_ticks_per_second());
        if (ret != RTEMS_SUCCESSFUL && ret != RTEMS_TIMEOUT)
            fatal_error("spwl_wait", ret);

        /* Send data. */
        if ((cond & (SPWL_COND_RDYSEND | SPWL_COND_RDYSENDBUF)) != 0) {
            if (((cond & SPWL_COND_RDYSEND) != 0 && ctx->queued) ||
                ((cond & SPWL_COND_RDYSENDBUF) != 0 && !ctx->queued) ||
                txbufn == 16 ||
                txdone_packets >= ctx->txpackets)
                fatal_error("spwl_wait, unexpected condition", 0);
            f = SPWL_EOP;
            p = ctx->txpacketsize - txpos;
            if (p > ctx->txblocksize) {
                p = ctx->txblocksize;
                f = 0;
            }
            offset = (txdone_packets * 4 + txpos) & (MAX_BLOCK_SIZE-1);
            if (ctx->queued) {
                txbuf_desc[txbufp].data = txpool + offset;
                txbuf_desc[txbufp].nbytes = p;
                txbuf_desc[txbufp].eop = f;
                ret = spwl_send_txbuf(spwh, txbuf_desc + txbufp, SPWL_NO_WAIT);
                if (ret != RTEMS_SUCCESSFUL)
                    fatal_error("spwl_send_txbuf", ret);
                txbufp = (txbufp + 1) & 15;
                txbufn++;
            } else {
                ret = spwl_send(spwh, txpool + offset, p, &p, f | SPWL_NO_WAIT);
                if (ret != RTEMS_SUCCESSFUL)
                    fatal_error("spwl_send", ret);
            }
            txpos += p;
            if (txpos >= ctx->txpacketsize) {
                txdone_packets++;
                txpos = 0;
            }
        }

        /* Receive data. */
        if ((cond & SPWL_COND_RDYRECV) != 0) {
            if (rxdone_packets >= ctx->rxpackets)
                fatal_error("spwl_wait, unexpected condition", 0);
            if (ctx->queued) {
                uint16_t nbytes;
                ret = spwl_recv_rxbuf(spwh, &buf, &nbytes, &f, SPWL_NO_WAIT);
                if (ret != RTEMS_SUCCESSFUL)
                    fatal_error("spwl_recv_rxbuf", ret);
                p = nbytes;
            } else {
                ret = spwl_recv(spwh, rxbuf, ctx->rxblocksize, &p, &f, SPWL_NO_WAIT);
                if (ret != RTEMS_SUCCESSFUL)
                    fatal_error("spwl_recv", ret);
                buf = rxbuf;
            }
            if (ctx->verify) {
                offset = (rxdone_packets * 4 + rxpos) & (MAX_BLOCK_SIZE-1);
                if (memcmp(buf, txpool + offset, p) != 0)
                    ctx->mismatch = 1;
            }
            rxpos += p;
            rxdone_bytes += p;
            if (f == SPWL_EEP || f == SPWL_EOP) {
                if (f == SPWL_EEP)
                    ctx->mismatch = 1;
                if (ctx->verify && rxpos > 0 && rxpos != ctx->txpacketsize)
                    ctx->mismatch = 1;
                if (rxpos > 0)
                    rxdone_packets++;
                if (rxpos > 0 && (rxpos < rxminsize || rxminsize == 0))
                    rxminsize = rxpos;
                if (rxpos > rxmaxsize)
                    rxmaxsize = rxpos;
                rxpos = 0;
            }
            if (ctx->queued) {
                ret = spwl_release_rxbuf(spwh, buf);
                if (ret != RTEMS_SUCCESSFUL)
                    fatal_error("spwl_release_rxbuf", ret);
            }
        }

        /* Reclaim TX buffers (queued mode). */
        if ((cond & SPWL_COND_RECLAIM) != 0) {
            spwl_txbuf_t *tmp;
            if (txbufn == 0)
                fatal_error("spwl_wait, unexpeced condition", 0);
            ret = spwl_reclaim_txbuf(spwh, &tmp, SPWL_NO_WAIT);
            if (ret != RTEMS_SUCCESSFUL)
                fatal_error("spwl_reclaim_txbuf", ret);
            txbufn--;
        }

        /* Update results. */
        ctx->txdone_packets = txdone_packets;
        ctx->rxdone_packets = rxdone_packets;
        ctx->rxdone_bytes   = rxdone_bytes;
        ctx->rxminsize      = rxminsize;
        ctx->rxmaxsize      = rxmaxsize;
    }

    return 0;
}


/* RX worker thread. */
static void rxtask_main(uintptr_t arg)
{
    struct data_test_context *ctx = (struct data_test_context *)arg;
    rtems_status_code ret;
    unsigned int rxdone_packets = 0, rxdone_bytes = 0;
    unsigned int rxminsize = 0, rxmaxsize = 0;
    unsigned int rxpos = 0;
    unsigned int f, offset;
    size_t p;
    void *buf;

    /* Receive data until test complete. */
    while (rxdone_packets < ctx->rxpackets) {

        if (ctx->queued) {
            uint16_t nbytes;
            ret = spwl_recv_rxbuf(spwh, &buf, &nbytes, &f, SPWL_WAIT);
            if (ret != RTEMS_SUCCESSFUL)
                fatal_error("spwl_recv_rxbuf", ret);
            p = nbytes;
        } else {
            ret = spwl_recv(spwh, rxbuf, ctx->rxblocksize, &p, &f, SPWL_WAIT);
            if (ret != RTEMS_SUCCESSFUL)
                fatal_error("spwl_recv", ret);
            buf = rxbuf;
        }

        if (ctx->verify) {
            offset = (rxdone_packets * 4 + rxpos) & (MAX_BLOCK_SIZE-1);
            if (memcmp(buf, txpool + offset, p) != 0)
                ctx->mismatch = 1;
        }

        rxpos += p;
        rxdone_bytes += p;

        if (f == SPWL_EEP || f == SPWL_EOP) {
            if (f == SPWL_EEP)
                ctx->mismatch = 1;
            if (ctx->verify && rxpos > 0 && rxpos != ctx->txpacketsize)
                ctx->mismatch = 1;
            if (rxpos > 0)
                rxdone_packets++;
            if (rxpos > 0 && (rxpos < rxminsize || rxminsize == 0))
                rxminsize = rxpos;
            if (rxpos > rxmaxsize)
                rxmaxsize = rxpos;
            rxpos = 0;
        }

        if (ctx->queued) {
            ret = spwl_release_rxbuf(spwh, buf);
            if (ret != RTEMS_SUCCESSFUL)
                fatal_error("spwl_release_rxbuf", ret);
        }

        /* Update results. */
        ctx->rxdone_packets = rxdone_packets;
        ctx->rxdone_bytes   = rxdone_bytes;
        ctx->rxminsize      = rxminsize;
        ctx->rxmaxsize      = rxmaxsize;
    }

    /* Release semaphore, then sleep forever. */
    rtems_semaphore_release(ctx->semaphore);
    rtems_task_suspend(RTEMS_SELF);
}


/* TX worker thread. */
static void txtask_main(uintptr_t arg)
{
    struct data_test_context *ctx = (struct data_test_context *)arg;
    rtems_status_code ret;
    unsigned int txdone_packets = 0;
    unsigned int txpos = 0, txbufp = 0, txbufn = 0;
    unsigned int f, offset;
    size_t p;

    /* Flush pending reclaimable buffers from previous test. */
    {
        spwl_txbuf_t *tmp;
        while (spwl_reclaim_txbuf(spwh, &tmp, SPWL_NO_WAIT) == RTEMS_SUCCESSFUL)
            ;
    }

    /* Send data until test completes. */
    while (txdone_packets < ctx->txpackets || txbufn > 0) {

        /* Send data. */
        if (txdone_packets < ctx->txpackets && txbufn < 16) {
            f = SPWL_EOP;
            p = ctx->txpacketsize - txpos;
            if (p > ctx->txblocksize) {
                p = ctx->txblocksize;
                f = 0;
            }
            offset = (txdone_packets * 4 + txpos) & (MAX_BLOCK_SIZE-1);
            if (ctx->queued) {
                txbuf_desc[txbufp].data = txpool + offset;
                txbuf_desc[txbufp].nbytes = p;
                txbuf_desc[txbufp].eop = f;
                ret = spwl_send_txbuf(spwh, txbuf_desc + txbufp, SPWL_WAIT);
                if (ret != RTEMS_SUCCESSFUL)
                    fatal_error("spwl_send_txbuf", ret);
                txbufp = (txbufp + 1) & 15;
                txbufn++;
            } else {
                ret = spwl_send(spwh, txpool + offset, p, &p, f | SPWL_WAIT);
                if (ret != RTEMS_SUCCESSFUL)
                    fatal_error("spwl_send", ret);
            }
            txpos += p;
            if (txpos >= ctx->txpacketsize) {
                txdone_packets++;
                txpos = 0;
            }
        }

        /* Reclaim TX buffers (queued mode). */
        if (ctx->queued && (txbufn == 16 || txdone_packets == ctx->txpackets)) {
            spwl_txbuf_t *tmp;
            ret = spwl_reclaim_txbuf(spwh, &tmp, SPWL_WAIT);
            if (ret != RTEMS_SUCCESSFUL)
                fatal_error("spwl_reclaim_txbuf", ret);
            if (tmp != txbuf_desc + ((16+txbufp-txbufn)&15))
                fatal_error("spwl_reclaim_txbuf returned unexpected pointer", 0);
            txbufn--;
        }

        /* Update results. */
        ctx->txdone_packets = txdone_packets;
    }

    /* Release semaphore, then sleep forever. */
    rtems_semaphore_release(ctx->semaphore);
    rtems_task_suspend(RTEMS_SELF);
}


/* Run a data send/receive test. Return 0 if ok, -1 if an error occurred. */
int do_data_test(int queued, int eventloop,
                 unsigned int rxpackets, unsigned int rxblocksize,
                 unsigned int txpackets, unsigned int txpacketsize,
                 unsigned int txblocksize, int verify)
{
    rtems_status_code ret;
    struct termios tcattr;
    struct data_test_context ctx;
    struct timespec tstart, tend;
    rtems_id rxtask = 0, txtask = 0;
    int aborted = 0;
    int activethreads;
    unsigned int elapsedms;

    if (queued && txpackets > 0 && (txblocksize & 3) != 0)
        fatal_error("invalid txblocksize in queued mode", 0);

    printf("\nStarting data test:\n");
    printf("  api:     %s, %s\n", queued ? "queue" : "copy",
                                  eventloop ? "eventloop" : "blocking");
    if (txpackets > 0) {
        printf("  send:    %u packets of %u bytes, blocksize=%u\n",
               txpackets, txpacketsize, txblocksize);
    }
    if (rxpackets > 0) {
        printf("  receive: %u packets", rxpackets);
        if (!queued)
            printf(", blocksize=%u", rxblocksize);
        printf(", verify=%s", verify ? "yes" : "no");
        printf("\n");
    }

    set_nonblocking(STDIN_FILENO, &tcattr);
    printf("  test started ... press Enter to abort\n");

    /* Set up context structure. */
    ctx.queued      = queued;
    ctx.rxpackets   = rxpackets;
    ctx.rxblocksize = rxblocksize;
    ctx.txpackets   = txpackets;
    ctx.txpacketsize = txpacketsize;
    ctx.txblocksize = txblocksize;
    ctx.verify      = verify;
    ctx.semaphore   = 0;
    ctx.txdone_packets = 0;
    ctx.rxdone_packets = 0;
    ctx.rxdone_bytes   = 0;
    ctx.rxminsize      = 0;
    ctx.rxmaxsize      = 0;
    ctx.mismatch       = 0;

    /* Create worker threads and completion semaphore for multi-thread test. */
    if (!eventloop) {
        ret = rtems_semaphore_create(rtems_build_name('d','o','n','e'),
                                     0,
                                     RTEMS_COUNTING_SEMAPHORE,
                                     RTEMS_NO_PRIORITY,
                                     &ctx.semaphore);
        if (ret != RTEMS_SUCCESSFUL)
            fatal_error("rtems_semaphore_create", ret);
        if (rxpackets > 0) {
            ret = rtems_task_create(rtems_build_name('r','x','t','s'),
                                    200,
                                    RTEMS_CONFIGURED_MINIMUM_STACK_SIZE,
                                    RTEMS_PREEMPT,
                                    RTEMS_NO_FLOATING_POINT,
                                    &rxtask);
            if (ret != RTEMS_SUCCESSFUL)
                fatal_error("rtems_task_create", ret);
        }
        if (txpackets > 0) {
            ret = rtems_task_create(rtems_build_name('t','x','t','s'),
                                    200,
                                    RTEMS_CONFIGURED_MINIMUM_STACK_SIZE,
                                    RTEMS_PREEMPT | RTEMS_NO_TIMESLICE,
                                    RTEMS_LOCAL,
                                    &txtask);
            if (ret != RTEMS_SUCCESSFUL)
                fatal_error("rtems_task_create", ret);
        }
    }

    /* Start timer. */
    rtems_clock_get_uptime(&tstart);

    /* Run test. */
    if (eventloop) {

        if (do_data_test_eventloop(&ctx) != 0)
            aborted = 1;

    } else {

        /* Start worker threads. */
        if (rxpackets > 0)
            rtems_task_start(rxtask, rxtask_main, (uintptr_t)&ctx);
        if (txpackets > 0)
            rtems_task_start(txtask, txtask_main, (uintptr_t)&ctx);

        /* Wait until test complete or test aborted. */
        activethreads = (rxpackets > 0) + (txpackets > 0);
        while (activethreads) {
            int k;
            char c;

            /* Abort test when user hits Enter. */
            do {
                k = read(STDIN_FILENO, &c, 1);
            } while (k == 1 && c != '\n' && c != '\r');
            if (k == 1 && (c == '\n' || c == '\r')) {
                aborted = 1;
                break;
            }

            ret = rtems_semaphore_obtain(ctx.semaphore, RTEMS_WAIT,
                                         rtems_clock_get_ticks_per_second());
            if (ret == RTEMS_SUCCESSFUL)
                activethreads--;
        }

    }

    /* Stop timer. */
    rtems_clock_get_uptime(&tend);

    /* Clean up resources. */
    if (!eventloop) {
        if (rxpackets > 0)
            rtems_task_delete(rxtask);
        if (txpackets > 0)
            rtems_task_delete(txtask);
        rtems_semaphore_delete(ctx.semaphore);
    }

    /* Report result. */
    if (aborted)
        printf("  aborted, ");
    else
        printf("  done, ");

    elapsedms = 1 + (tend.tv_sec - tstart.tv_sec) * 1000 +
                tend.tv_nsec / 1000000 - tstart.tv_nsec / 1000000;
    printf("%3d.%03d seconds elapsed\n", elapsedms / 1000, elapsedms % 1000);
    if (txpackets > 0) {
        uint64_t rate = (uint64_t)ctx.txdone_packets * (uint64_t)txpacketsize * 1000U / elapsedms;
        printf("  sent %u packets (%u bytes/s)\n",
               ctx.txdone_packets, (unsigned int)rate);
    }
    if (rxpackets > 0) {
        uint64_t rate = (uint64_t)ctx.rxdone_bytes * 1000U / elapsedms;
        printf("  received %u packets, %u bytes (%u bytes/s)\n",
               ctx.rxdone_packets, ctx.rxdone_bytes, (unsigned int)rate);
        if (ctx.rxdone_packets > 0)
            printf("  received min packet size = %u, max packet size = %u\n",
                   ctx.rxminsize, ctx.rxmaxsize);
    }
    if (ctx.mismatch)
        printf("  MISMATCH OR EEP DETECTED IN RECEIVED DATA\n");

    /* Restore stdin mode. */
    tcsetattr(STDIN_FILENO, TCSANOW, &tcattr);

    return (aborted || ctx.mismatch) ? -1 : 0;
}


/* Run a series of loopback tests. */
int do_autotest(int verify)
{
    int queued, eventloop;
    unsigned int npackets, packetsize, rxblocksize, txblocksize;
    int i, j, ret;

    printf("\nStarting automatic test\n");

    for (queued = 0; queued <= 1; queued++) {
        for(eventloop = 0; eventloop <= 1; eventloop++) {
            for (i = 0; autotest_packetsize[i] > 0; i++) {
                for (j = 0; autotest_blocksize[j] > 0; j++) {

                    packetsize = autotest_packetsize[i];
                    txblocksize = autotest_blocksize[j];

                    if (queued && (txblocksize & 3) != 0)
                        continue;

                    npackets = 10000000 / packetsize;
                    if (npackets > 100000)
                        npackets = 100000;
                    if (npackets * packetsize / txblocksize > 100000)
                        npackets = 100000 * txblocksize / packetsize;
                    if (npackets < 1)
                        continue;

                    rxblocksize = 4000;
                    ret = do_data_test(queued, eventloop,
                                       npackets, rxblocksize,
                                       npackets, packetsize, txblocksize,
                                       verify);
                    if (ret < 0)
                        return ret;

                    if (!queued && autotest_blocksize[j] != 4000) {
                        txblocksize = 4000;
                        rxblocksize = autotest_blocksize[j];
                        ret = do_data_test(queued, eventloop,
                                           npackets, rxblocksize,
                                           npackets, packetsize, txblocksize,
                                           verify);
                        if (ret < 0)
                            return ret;
                    }

                    if (txblocksize > packetsize && rxblocksize > packetsize)
                        break;
                }
            }
        }
    }

    printf("\nAutomatic test completed\n");
    return 0;
}


/* Put system in passive loopback mode. */
void do_passive_loopback(int queued, int blocksize)
{
    rtems_status_code ret;
    struct termios tcattr;
    struct timespec tstart, tend;
    unsigned int done_packets = 0, done_bytes = 0;
    unsigned int txpos = 0, txbufp = 0, txbufn = 0;
    size_t rxlen = 0;
    unsigned int rxeop = 0;
    void *rxbufp;
    unsigned int cond;
    int k;
    char c;
    unsigned int elapsedms;
    uint64_t rate;

    printf("\nStarting passive loopback mode:\n");
    printf("  api:       %s\n", queued ? "queue" : "copy");
    if (!queued)
        printf("  blocksize: %u\n", blocksize);

    set_nonblocking(STDIN_FILENO, &tcattr);
    printf("  started ... press Enter to stop\n");

    /* Flush pending reclaimable buffers from previous test. */
    {
        spwl_txbuf_t *tmp;
        while (spwl_reclaim_txbuf(spwh, &tmp, SPWL_NO_WAIT) == RTEMS_SUCCESSFUL)
            ;
    }

    /* Start timer. */
    rtems_clock_get_uptime(&tstart);

    /* Run in passive loopback. */
    while (1) {

        /* Check if user pressed Enter. */
        do {
            k = read(STDIN_FILENO, &c, 1);
        } while (k == 1 && c != '\n' && c != '\r');
        if (k == 1 && (c == '\n' || c == '\r'))
            break;

        /* Receive data. */
        if (rxlen == 0 && rxeop == 0) {
            if (queued) {
                uint16_t rxlen16;
                ret = spwl_recv_rxbuf(spwh, &rxbufp, &rxlen16, &rxeop, SPWL_NO_WAIT);
                rxlen = rxlen16;
                if (ret != RTEMS_SUCCESSFUL && ret != RTEMS_UNSATISFIED)
                    fatal_error("spwl_recv_rxbuf", ret);
            } else {
                ret = spwl_recv(spwh, rxbuf, blocksize, &rxlen, &rxeop, SPWL_NO_WAIT);
                if (ret != RTEMS_SUCCESSFUL && ret != RTEMS_UNSATISFIED)
                    fatal_error("spwl_recv", ret);
            }
            done_bytes += rxlen;
            if (rxeop)
                done_packets++;
        }

        /* Send data. */
        if ((rxlen > 0 || rxeop != 0) && txbufn < 16) {
            if (queued) {
                txbuf_desc[txbufp].data = rxbufp;
                txbuf_desc[txbufp].nbytes = rxlen;
                txbuf_desc[txbufp].eop = rxeop;
                ret = spwl_send_txbuf(spwh, txbuf_desc + txbufp, SPWL_NO_WAIT);
                if (ret == RTEMS_SUCCESSFUL) {
                    ret = spwl_release_rxbuf(spwh, rxbufp);
                    if (ret != RTEMS_SUCCESSFUL)
                        fatal_error("spwl_release_rxbuf", ret);
                    rxlen = rxeop = 0;
                    txbufp = (txbufp + 1) & 15;
                    txbufn++;
                }
                if (ret != RTEMS_SUCCESSFUL && ret != RTEMS_UNSATISFIED)
                    fatal_error("spwl_send_txbuf", ret);
            } else {
                size_t ntrans;
                ret = spwl_send(spwh, rxbuf + txpos, rxlen - txpos, &ntrans, rxeop | SPWL_NO_WAIT);
                if (ret == RTEMS_SUCCESSFUL) {
                    txpos += ntrans;
                    if (txpos == rxlen)
                        rxlen = rxeop = txpos = 0;
                }
                if (ret != RTEMS_SUCCESSFUL && ret != RTEMS_UNSATISFIED)
                    fatal_error("spwl_send", ret);
            }
        }

        /* Reclaim buffers. */
        if (txbufn > 0) {
            struct spwl_txbuf *p;
            ret = spwl_reclaim_txbuf(spwh, &p, SPWL_NO_WAIT);
            if (ret == RTEMS_SUCCESSFUL) {
                if (p != txbuf_desc + ((txbufp + 16 - txbufn) & 15))
                    fatal_error("spwl_reclaim_txbuf returned unexpected buffer", 0);
                txbufn--;
            }
            if (ret != RTEMS_SUCCESSFUL && ret != RTEMS_UNSATISFIED)
                fatal_error("spwl_reclaim_txbuf", ret);
        }

        /* Wait until ready. */
        cond = 0;
        if (rxlen == 0 && rxeop == 0)
            cond |= SPWL_COND_RDYRECV;
        if (!queued && (rxlen > 0 || rxeop != 0))
            cond |= SPWL_COND_RDYSEND;
        if (queued && (rxlen > 0 || rxeop != 0) && txbufn < 16)
            cond |= SPWL_COND_RDYSENDBUF;
        if (txbufn > 0)
            cond |= SPWL_COND_RECLAIM;
        ret = spwl_wait(spwh, &cond, rtems_clock_get_ticks_per_second());
        if (ret != RTEMS_SUCCESSFUL && ret != RTEMS_TIMEOUT)
            fatal_error("spwl_wait", ret);
    }

    /* Stop timer. */
    rtems_clock_get_uptime(&tend);

    /* Report result. */
    elapsedms = 1 + (tend.tv_sec - tstart.tv_sec) * 1000 +
                tend.tv_nsec / 1000000 - tstart.tv_nsec / 1000000;
    printf("  done, %3d.%03d seconds elapsed\n",
           elapsedms / 1000, elapsedms % 1000);
    rate = (uint64_t)done_bytes * 1000U / elapsedms;
    printf("  sent %u packets, %u bytes (%u bytes/s)\n",
           done_packets, done_bytes, (unsigned int)rate);

    /* Restore stdin mode. */
    tcsetattr(STDIN_FILENO, TCSANOW, &tcattr);
}


/* Send time codes. */
void do_send_timecode(void)
{
    rtems_status_code ret;
    uint8_t timecode;
    int value;

    printf("\n");
    value = get_num("Enter timecode value to send (0 .. 63):", 0, 63, -1);
    if (value >= 0) {
        timecode = spwl_get_timecode(spwh);
        printf("Last received timecode value: %u\n", timecode);
        printf("Sending timecode value %d\n", value);
        ret = spwl_send_timecode(spwh, value);
        if (ret != RTEMS_SUCCESSFUL)
            fatal_error("spwl_send_timecode", ret);
        timecode = spwl_get_timecode(spwh);
        printf("Last received timecode value: %u\n", timecode);
        rtems_task_wake_after(rtems_clock_get_ticks_per_second() / 10);
        timecode = spwl_get_timecode(spwh);
        printf("Last received timecode value (after 0.1s): %u\n", timecode);
    }
}


/* Show time codes and link events. */
void do_recv_timecode(void)
{
    rtems_status_code ret;
    struct termios tcattr;
    struct timespec tstart, ts;
    spwl_linkstatus status;
    int link_is_up;
    unsigned int errors;
    unsigned int cond;
    unsigned int millis;
    uint8_t timecode;
    int k;
    char c;

    printf("\n---- Show time codes and link events ----\n");

    rtems_clock_get_uptime(&tstart);

    spwl_get_linkstatus(spwh, &status, &errors);
    link_is_up = (status == SPWL_LINK_RUN);
    printf("  link %s, errors = %s%s%s%s%s%s\n",
           link_is_up ? "up" : "down",
           (errors == 0) ? "none" : "",
           (errors & SPWL_ERR_DISCONNECT) ? "disconnect " : "",
           (errors & SPWL_ERR_PARITY)     ? "parity " : "",
           (errors & SPWL_ERR_ESCAPE)     ? "escape " : "",
           (errors & SPWL_ERR_CREDIT)     ? "credit " : "",
           (errors & SPWL_ERR_AHB)        ? "AHB " : "");

    timecode = spwl_get_timecode(spwh);
    printf("  last timecode = %u\n", timecode);

    set_nonblocking(STDIN_FILENO, &tcattr);
    printf("  waiting for events ... press Enter to stop\n");

    while (1) {

        /* Abort test when user hits Enter. */
        do {
            k = read(STDIN_FILENO, &c, 1);
        } while (k == 1 && c != '\n' && c != '\r');
        if (k == 1 && (c == '\n' || c == '\r'))
            break;

        /* Wait for event. */
        cond = SPWL_COND_TIMECODE;
        if (link_is_up)
            cond |= SPWL_COND_LINKDOWN;
        else
            cond |= SPWL_COND_LINKUP;
        ret = spwl_wait(spwh, &cond, rtems_clock_get_ticks_per_second());
        if (ret != RTEMS_SUCCESSFUL && ret != RTEMS_TIMEOUT)
            fatal_error("spwl_wait", ret);

        /* Report event. */
        rtems_clock_get_uptime(&ts);
        millis = (ts.tv_sec - tstart.tv_sec) * 1000 +
                 ts.tv_nsec / 1000000 - tstart.tv_nsec / 1000000;

        if ((cond & SPWL_COND_LINKUP) != 0) {
            printf("  %4u.%03u: link up\n", millis / 1000, millis % 1000);
            link_is_up = 1;
        }

        if ((cond & SPWL_COND_LINKDOWN) != 0) {
            spwl_get_linkstatus(spwh, &status, &errors);
            printf("  %4u.%03u: link down, errors = %s%s%s%s%s%s\n",
                   millis / 1000, millis % 1000,
                   (errors == 0) ? "none" : "",
                   (errors & SPWL_ERR_DISCONNECT) ? "disconnect " : "",
                   (errors & SPWL_ERR_PARITY)     ? "parity " : "",
                   (errors & SPWL_ERR_ESCAPE)     ? "escape " : "",
                   (errors & SPWL_ERR_CREDIT)     ? "credit " : "",
                   (errors & SPWL_ERR_AHB)        ? "AHB " : "");
            link_is_up = 0;
        }

        if ((cond & SPWL_COND_TIMECODE) != 0) {
            timecode = spwl_get_timecode(spwh);
            printf("  %4u.%03u: got tick, timecode = %d\n",
                   millis / 1000, millis % 1000, timecode);
        }
    }

    /* Restore console mode. */
    tcsetattr(STDIN_FILENO, TCSANOW, &tcattr);

    printf("  done\n");
}


/* Receive/send menu. */
void menu_recvsend(int send)
{
    int opt;
    int queued, eventloop;
    int npacket, packetsize, blocksize;

    do {

        printf("\n---- %s packets ----\n", send ? "Send" : "Receive");
        show_status();
        printf(" 1.  Copy API; blocking calls\n");
        printf(" 2.  Copy API; event loop\n");
        printf(" 3.  Queue API; blocking calls\n");
        printf(" 4.  Queue API; event loop\n");
        printf(" 0.  Back to main menu\n");

        opt = get_opt(4);
        if (opt > 0 && opt <= 4) {

            queued    = (opt == 3 || opt == 4);
            eventloop = (opt == 2 || opt == 4);

            npacket = get_num("Number of packets ?", 0, 1000000, -1);

            if (send)
                packetsize = get_num("Packet size in bytes (1 .. 1000000) ?", 1, 1000000, -1);
            else
                packetsize = 0;

            blocksize = 0;
            while (send || !queued) {
                blocksize = get_num("Block size in bytes (1 .. 16384) ?", 1, MAX_BLOCK_SIZE, 4096);
                if ((blocksize & 3) == 0 || !queued)
                    break;
                printf("INVALID: block size must be a multiple of 4 in queued mode\n");
            }

            if (npacket > 0) {
                if (send) {
                    do_data_test(queued, eventloop,
                                 0, 0,
                                 npacket, packetsize, blocksize,
                                 0);
                } else {
                    do_data_test(queued, eventloop,
                                 npacket, blocksize,
                                 0, 0, 0,
                                 0);
                }
            }
        }
    } while (opt != 0);
}


/* Loopback test menu. */
void menu_loopback(int verify)
{
    int opt;
    int queued, eventloop;
    int npacket, packetsize, blocksize;

    do {

        printf("\n---- Loopback test %s ----\n",
               verify ? "with data compare" : "(no compare)");
        show_status();
        printf(" 1.  Copy API; blocking calls; multi-threaded\n");
        printf(" 2.  Copy API; event loop\n");
        printf(" 3.  Queue API; blocking calls; multi-threaded\n");
        printf(" 4.  Queue API; event loop\n");
        printf(" 5.  Automatic test\n");
        printf(" 0.  Back to main menu\n");

        opt = get_opt(5);
        if (opt > 0 && opt <= 4) {

            queued    = (opt == 3 || opt == 4);
            eventloop = (opt == 2 || opt == 4);

            npacket = get_num("Number of packets ?", 0, 1000000, -1);
            packetsize = get_num("Packet size in bytes (1 .. 1000000) ?", 1, 1000000, -1);
            while (1) {
                blocksize = get_num("Block size in bytes (1 .. 16384) ?", 1, MAX_BLOCK_SIZE, 4096);
                if ((blocksize & 3) == 0 || !queued)
                    break;
                printf("INVALID: block size must be a multiple of 4 in queued mode\n");
            }

            if (npacket > 0) {
                do_data_test(queued, eventloop,
                             npacket, blocksize,
                             npacket, packetsize, blocksize,
                             verify);
            }

        } else if (opt == 5) {

            do_autotest(verify);

        }

    } while (opt != 0);
}


/* Passive loopback menu. */
void menu_passiveloop(void)
{
    int opt;
    int queued, blocksize = 0;

    printf("\n---- Passive loopback mode----\n");
    show_status();
    printf(" 1.  Copy API\n");
    printf(" 2.  Queue API\n");
    printf(" 0.  Back to main menu\n");

    opt = get_opt(2);
    if (opt > 0 && opt <= 2) {

        queued = (opt == 2);

        while (!queued) {
            blocksize = get_num("Block size in bytes (32 .. 16384) ?", 32, MAX_BLOCK_SIZE, 4096);
            if ((blocksize & 3) == 0 || !queued)
                break;
            printf("INVALID: block size must be a multiple of 4 in queued mode\n");
        }

        do_passive_loopback(queued, blocksize);
    }
}


/* Main menu. */
void menu_main(void)
{
    int opt;

    do {
        printf("\n==== SpaceWire Light Test ====\n");
        show_status();
        printf(" 1.  Re-initialize driver\n");
        printf(" 2.  Set link mode\n");
        printf(" 3.  Set link speed\n");
        printf(" 4.  Receive packets\n");
        printf(" 5.  Send packets\n");
        printf(" 6.  Loopback test (no compare)\n");
        printf(" 7.  Loopback test with data compare\n");
        printf(" 8.  Passive loopback\n");
        printf(" 9.  Send time code\n");
        printf("10.  Show time codes and link events\n");
        printf(" 0.  Exit\n");

        opt = get_opt(10);
        switch (opt) {
            case 1: do_init_driver(); break;
            case 2: do_set_link_mode(); break;
            case 3: do_set_link_speed(); break;
            case 4: menu_recvsend(0); break;
            case 5: menu_recvsend(1); break;
            case 6: menu_loopback(0); break;
            case 7: menu_loopback(1); break;
            case 8: menu_passiveloop(); break;
            case 9: do_send_timecode(); break;
            case 10: do_recv_timecode(); break;
        }

    } while (opt != 0);
}


/* Main program. */
void Init(rtems_task_argument arg)
{
    int i;

    printf("\nSpaceWire Light test program for RTEMS\n\n");

    /* Put stdin in raw mode. */
    {
        struct termios tcattr;
        tcgetattr(STDIN_FILENO, &tcattr);
        tcattr.c_iflag &= ~IGNCR;
        tcattr.c_lflag &= ~(ICANON | ECHO);
        tcattr.c_cc[VMIN] = 1;
        tcattr.c_cc[VTIME] = 0;
        tcsetattr(STDIN_FILENO, TCSANOW, &tcattr);
    }

    /* Create TX data pool. */
    for (i = 0; i < MAX_BLOCK_SIZE; i++) {
        int v = ((i & 1) << 7) | ((i & 2) << 5) |
                ((i & 4) << 3) | ((i & 8) << 1) |
                ((i & 16) >> 1) | ((i & 32) >> 3) |
                ((i & 64) >> 5) | ((i & 128) >> 7);
        v += (i >> 8);
        txpool[i] = v;
    }
    memcpy(txpool + MAX_BLOCK_SIZE, txpool, MAX_BLOCK_SIZE);

    /* Open SpaceWire core */
    spw_index = 0;
    open_driver();

    /* Main menu. */
    menu_main();

    /* Clean up. */
    spwl_close(spwh);

    printf("\nExit.\n");
    rtems_shutdown_executive(0);
}

/* vim: expandtab softtabstop=4
*/
/* end */
