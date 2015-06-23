/*
 *  Test program for SpaceWire Light SPWAMBA core in LEON3 environment.
 */

#include <stdlib.h>
#include <stdio.h>
#include <asm-leon/irq.h>
#include <asm-leon/amba.h>

/*
 * The following defines are set in the Makefile:
 *   TXCLKFREQ        TX base clock frequency in MHz
 *   DESCTABLESIZE    Size of descriptor table as 2-log of nr of descriptors
 *   QUEUEFILL        Number of bytes needed to ALMOST fill up TX and RX queues
 *   LOOPBACKSWITCH   1 if the spacewire loopback can be switched through UART RX enable
 */

#define DEVICE_SPACEWIRELIGHT		0x131

/* APB registers */
#define SPWAMBA_REG_CONTROL		0x00
#define SPWAMBA_REG_STATUS		0x04
#define SPWAMBA_REG_TXSCALER		0x08
#define SPWAMBA_REG_TIMECODE		0x0c
#define SPWAMBA_REG_RXDMA		0x10
#define SPWAMBA_REG_TXDMA		0x14
#define SPWAMBA_CONTROL_RESET		0x0001
#define SPWAMBA_CONTROL_RESETDMA	0x0002
#define SPWAMBA_CONTROL_START		0x0004
#define SPWAMBA_CONTROL_DISABLE		0x0010
#define SPWAMBA_CONTROL_EXTTICK		0x0020
#define SPWAMBA_CONTROL_RXDMA		0x0040
#define SPWAMBA_CONTROL_TXDMA		0x0080
#define SPWAMBA_CONTROL_TXCANCEL	0x0100
#define SPWAMBA_CONTROL_IESTATUS	0x0200
#define SPWAMBA_CONTROL_IETICK		0x0400
#define SPWAMBA_CONTROL_IERXDESC	0x0800
#define SPWAMBA_CONTROL_IETXDESC	0x1000
#define SPWAMBA_CONTROL_IERXPACKET	0x2000
#define SPWAMBA_STATUS_RXDMA		0x0040
#define SPWAMBA_STATUS_TXDMA		0x0080
#define SPWAMBA_STATUS_RXDESC		0x0800
#define SPWAMBA_STATUS_TXDESC		0x1000
#define SPWAMBA_STATUS_RXPACKET		0x2000

/* Value test macros. */
#define CHECK_VALUE(label, v, expect)   ( ((v) == (expect)) || (printf("CHECK FAILED: line %d, %s, got 0x%08x, expected 0x%08x\n", __LINE__, (label), (v), (expect)), fail(), 1) )
#define CHECK_CONDITION(label, v, cond) ( (cond) || (printf("CHECK FAILED: line %d, %s, got 0x%08x\n", __LINE__, (label), (v)), fail(), 1) )


/* Points to data register of first UART */
extern int *console;

struct descriptor_struct {
	volatile unsigned int f;	/* descriptor flags */
	volatile unsigned char *d;	/* data pointer */
} __attribute__ ((packed));

static unsigned long spwamba_start;
static unsigned long spwamba_irq;
static volatile int  irq_expect;
static volatile unsigned int irq_count;
static struct descriptor_struct *rxdesctable;
static struct descriptor_struct *txdesctable;
static unsigned char *buf;


/* Put LEON3 in powerdown mode to indicate success. */
static void powerdown(void)
{
	asm volatile (
	  " rd    %%psr, %%g1         \n"
	  " andn  %%g1,  0x20,  %%g1  \n"
	  " wr    %%g1,  %%psr        \n"
	  " nop ; nop ; nop           \n"
	  " wr    %%g0,  %%asr19      \n"
	  " nop ; nop ; nop "
	  : : : "g1" );
}


/* Put LEON3 in error mode to indicate failure. */
static void fail(void) __attribute__ ((noreturn));
static void fail(void)
{
	asm volatile (
	  " rd    %%psr, %%g1         \n"
	  " andn  %%g1,  0x20,  %%g1  \n"
	  " wr    %%g1,  %%psr        \n"
	  " nop ; nop ; nop           \n"
	  " unimp 0                   \n"
	  " nop "
	  : : : "g1" );
	exit(1);
}


/* Write to SPWAMBA register. */
static inline void spwamba_write(unsigned int reg, unsigned int val)
{
	(*(volatile unsigned int *)(spwamba_start + reg)) = val;
}


/* Read from SPWAMBA register. */
static inline unsigned int spwamba_read(unsigned int reg)
{
	return (*(volatile unsigned int *)(spwamba_start + reg));
}


/* SPWAMBA interrupt handler. */
static int spwamba_interrupt(int irq, void *dev_id, struct leonbare_pt_regs *pt_regs)
{
	if (!irq_expect) {
		printf("ERROR: spurious SPWAMBA interrupt\n");
		fail();
	}
	irq_count++;
	return 0;
}


/* Verify default values of APB registers. */
static void check_default_regs(void)
{
	unsigned int v;

	/* reg_control: expect all zeroes except for desctablesize=5 */
	v = spwamba_read(SPWAMBA_REG_CONTROL);
	CHECK_VALUE("reg_control", v, (DESCTABLESIZE << 24));

	v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x4000);

	/* reg_txscaler: expect (TXCLKFREQ / 10 - 1) for 10 Mbit */
	v = spwamba_read(SPWAMBA_REG_TXSCALER);
	CHECK_VALUE("reg_txscaler", v, TXCLKFREQ / 10 - 1);

	v = spwamba_read(SPWAMBA_REG_TIMECODE);
	CHECK_VALUE("reg_timecode", v, 0);

	v = spwamba_read(SPWAMBA_REG_RXDMA);
	CHECK_VALUE("reg_rxdma", v, 0);

	v = spwamba_read(SPWAMBA_REG_TXDMA);
	CHECK_VALUE("reg_txdma", v, 0);
}


/* Test that the specified register bits are read/writeable. */
static void test_reg_readwrite(unsigned int reg, unsigned int mask)
{
	unsigned int i, v, t;
	v = 0;
	for (i = 0; i <= 32; i++) {
		if (v == 0 || (v & mask) != 0) {
			spwamba_write(reg, v);
			t = spwamba_read(reg);
			if ((t & mask) != v) {
				printf("ERROR: invalid value in register 0x%02x, wrote 0x%08x, got 0x%08x\n", reg, v, t);
				fail();
			}
		}
		v = (1 << i);
	}
}


/* Basic test of APB registers. */
static void test_regs(void)
{
	/* test default values */
	check_default_regs();
	printf("default APB register values             [OK]\n");

	/* test read/write access */
	test_reg_readwrite(SPWAMBA_REG_CONTROL,  0x3e3c);
	test_reg_readwrite(SPWAMBA_REG_TXSCALER, 0xff);
	test_reg_readwrite(SPWAMBA_REG_TIMECODE, 0x3f00);
	test_reg_readwrite(SPWAMBA_REG_RXDMA,    0xfffffff8);
	test_reg_readwrite(SPWAMBA_REG_TXDMA,    0xfffffff8);
	printf("read/write access to APB registers      [OK]\n");

	/* test effect of reset command on registers */
	spwamba_write(SPWAMBA_REG_CONTROL,  0x3e00);
	spwamba_write(SPWAMBA_REG_TXSCALER, 0xff);
	spwamba_write(SPWAMBA_REG_TIMECODE, 0x3f);
	spwamba_write(SPWAMBA_REG_RXDMA,    0xfffffff8);
	spwamba_write(SPWAMBA_REG_TXDMA,    0xfffffff8);
	spwamba_write(SPWAMBA_REG_CONTROL,  0x3e21);
	check_default_regs();
	printf("reset of APB registers                  [OK]\n");
}


/* Test SpaceWire link */
void test_link(void)
{
	unsigned int i, v;

	/* start link */
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_START);

	/* wait until link up */
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 250 && (v & 3) == 0; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 250 && (v & 3) == 1; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 250 && (v & 3) == 2; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x4003);
	printf("SpaceWire link up                       [OK]\n");

	/* shut down link */
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_DISABLE);
	spwamba_write(SPWAMBA_REG_CONTROL, 0);

	/* check link down */
	v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x4000);
	printf("SpaceWire link down                     [OK]\n");

	irq_count  = 0;
	irq_expect = 1;
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_START | SPWAMBA_CONTROL_IESTATUS);

	/* wait until link up */
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 250 && (v & 3) != 3; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x4003);
	CHECK_VALUE("irq_count", irq_count, 1);

	/* shut link down */
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_DISABLE | SPWAMBA_CONTROL_IESTATUS);
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_IESTATUS);

	/* check link down */
	v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x4000);
	CHECK_VALUE("irq_count", irq_count, 2);
	printf("interrupt on status change              [OK]\n");

#if LOOPBACKSWITCH
	/* restart link */
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_START | SPWAMBA_CONTROL_IESTATUS);
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 250 && (v & 3) != 3; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x4003);
	CHECK_VALUE("irq_count", irq_count, 3);

	/* unplug link, link should go down */
	console[2] &= ~LEON_REG_UART_CTRL_RE;
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 40 && (v & 3) == 3; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_CONDITION("reg_status", v, (v & 0x03) != 3 &&
                                         (v & 0x1c) != 0 &&
                                         (v & 0xffffffe0) == 0x4000);
	CHECK_VALUE("irq_count", irq_count, 4);

	/* clear sticky bits */
	spwamba_write(SPWAMBA_REG_STATUS, 0xffffffe3);
	i = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_CONDITION("reg_status", i, (v & 0xfffffffc) == (i & 0xfffffffc));
	spwamba_write(SPWAMBA_REG_STATUS, v);
	v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_CONDITION("reg_status", v, (v & 0xfffffffc) == 0x4000);
	printf("sticky error bits                       [OK]\n");

	/* replug link and check that link is restored*/
	console[2] |= LEON_REG_UART_CTRL_RE;
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 250 && (v & 3) != 3; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x4003);
	CHECK_VALUE("irq_count", irq_count, 5);

	/* release link start line, link should stay up */
	irq_expect = 0;
	spwamba_write(SPWAMBA_REG_CONTROL, 0);
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 40 && (v & 3) == 3; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x4003);

	/* pull plug, link should go down */
	console[2] &= ~LEON_REG_UART_CTRL_RE;
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 40 && (v & 3) == 3; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_CONDITION("reg_status", v, (v & 0x1c) != 0 &&
                                         (v & 0xffffffe3) == 0x4000);
	spwamba_write(SPWAMBA_REG_STATUS, 0x3c);

	/* restore plug, link should stay down */
	console[2] |= LEON_REG_UART_CTRL_RE;
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 40 && (v & 3) == 0; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x4000);

	printf("handling physical disconnection         [OK]\n");
#endif
}


/* Test sending/receiving of time codes */
void test_timecode(void)
{
	unsigned int i, v;

	/* request time code transmission (link still down) */
	spwamba_write(SPWAMBA_REG_TIMECODE, 0x131ff);
	v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x4000);
	v = spwamba_read(SPWAMBA_REG_TIMECODE);
	CHECK_VALUE("reg_timecode", v, 0x3200);

	/* start link */
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_START);
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 250 && (v & 3) != 3; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 50 && (v & 0x400) == 0; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x4003);
	v = spwamba_read(SPWAMBA_REG_TIMECODE);
	CHECK_VALUE("reg_timecode", v, 0x3200);

	/* request time code transmission and wait for timecode received */
	spwamba_write(SPWAMBA_REG_TIMECODE, 0x13200);
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 50 && (v & 0x400) == 0; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x4403);
	v = spwamba_read(SPWAMBA_REG_TIMECODE);
	CHECK_VALUE("reg_timecode", v, 0x3332);
	printf("send/receive timecode                   [OK]\n");

	/* enable interrupt on time code */
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_IETICK);

	/* manually send time code and expect interrupt */
	irq_count  = 0;
	irq_expect = 1;
	spwamba_write(SPWAMBA_REG_TIMECODE, 0x10f00);
	for (i = 0; i < 50 && irq_count == 0; i++) ;
	v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x4403);
	v = spwamba_read(SPWAMBA_REG_TIMECODE);
	CHECK_VALUE("reg_timecode", v, 0x100f);
	CHECK_VALUE("irq_count", irq_count, 1);
	v = spwamba_read(SPWAMBA_REG_TIMECODE);
	printf("interrupt on time code                  [OK]\n");

	/* clear sticky status bit */
	v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x4403);
	spwamba_write(SPWAMBA_REG_STATUS, 0x400);
	v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x4003);

	/* set up GPTIMER to generate external time tick after 4 us;
	   external tick signal should be ignored */
	LEON3_GpTimer_Regs->e[1].rld = 4;
	LEON3_GpTimer_Regs->e[1].ctrl = 0x05;
	v = spwamba_read(SPWAMBA_REG_TIMECODE);
	for (i = 0; i < 100 && v == 0x100f; i++)
		v = spwamba_read(SPWAMBA_REG_TIMECODE);
	CHECK_VALUE("reg_timecode", v, 0x100f);

	/* enable external time tick and wait for timecode received */
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_IETICK | SPWAMBA_CONTROL_EXTTICK);
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 100 && (v & 0x400) == 0; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x4003);
	LEON3_GpTimer_Regs->e[1].ctrl = 0x05;
	for (i = 0; i < 100 && (v & 0x400) == 0; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x4403);
	spwamba_write(SPWAMBA_REG_STATUS, v);
	v = spwamba_read(SPWAMBA_REG_TIMECODE);
	CHECK_VALUE("reg_timecode", v, 0x1110);
	CHECK_VALUE("irq_count", irq_count, 2);
	printf("external tick_in signal                 [OK]\n");

	/* clear sticky status bits */
	v = spwamba_read(SPWAMBA_REG_STATUS);
	spwamba_write(SPWAMBA_REG_STATUS, v);
	
	/* disable external time codes, disable timecode interrupts */
	irq_expect = 0;
	LEON3_GpTimer_Regs->e[1].ctrl = 0;
	spwamba_write(SPWAMBA_REG_CONTROL, 0);

	/* note: link still up */
}


/* Create 2048 bytes dummy data for transfer tests. */
static void create_test_data(void)
{
	unsigned int i, j, k, t;
	buf[0] = j = k = 1;
	for (i = 1; i < 2048; i++) {
		buf[i] = j;
		t = j;
		j += k;
		k = t;
	}
}


/* Check that dummy data has not accidentally been overwritten. */
static void check_test_data(void)
{
	unsigned int i, j, k, t;
	CHECK_VALUE("dummydata", buf[0], 1);
	j = k = 1;
	for (i = 1; i < 1024; i++) {
		CHECK_VALUE("dummydata", buf[i], (unsigned char)j);
		buf[i] = j;
		t = j;
		j += k;
		k = t;
	}
}


/* Test rxdesc/txdesc/rxpacket interrupts. */
static void test_data_interrupt(unsigned int iemask)
{
	unsigned int i, v;

	/* Reset DMA; reset sticky status bits */
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_RESETDMA);
	v = spwamba_read(SPWAMBA_REG_STATUS);
	spwamba_write(SPWAMBA_REG_STATUS, v);

	irq_count = 0;
	irq_expect = 1;

	/* Start TX dma */
	txdesctable[0].f = 0x170003;	/* EOP, EN, IE, WR, 3 bytes */
	txdesctable[0].d = buf;
	spwamba_write(SPWAMBA_REG_TXDMA, (unsigned int)txdesctable);
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_TXDMA | iemask);

	/* Wait until packet transmitted */
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 200 && (v & 0x80) != 0; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_CONDITION("reg_status", v, (v & 0x3fff) == 0x1003);
	CHECK_VALUE("irq_count", irq_count, (iemask & SPWAMBA_CONTROL_IETXDESC) ? 1 : 0);
	irq_count = 0;

	/* Start RX dma */
	rxdesctable[0].f = 0x10400;	/* EN, 1024 bytes */
	rxdesctable[0].d = buf + 8192;
	rxdesctable[1].f = 0x70400;	/* EN, IE, WR, 1024 bytes */
	rxdesctable[1].d = buf + 8196;
	spwamba_write(SPWAMBA_REG_RXDMA, (unsigned int)rxdesctable);
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_RXDMA | iemask);

	/* Wait until packet received */
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 200 && (v & 0x2000) == 0; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x7043);
	spwamba_write(SPWAMBA_REG_STATUS, v);
	CHECK_VALUE("irq_count", irq_count, (iemask & SPWAMBA_CONTROL_IERXPACKET) ? 1 : 0);
	irq_count = 0;

	/* Start TX dma */
	txdesctable[0].f = 0x130003;	/* EOP, EN, WR, 3 bytes */
	txdesctable[0].d = buf + 4;
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_TXDMA | iemask);

	/* Wait until packet received */
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 200 && (v & 0x2000) == 0; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x6843);
	spwamba_write(SPWAMBA_REG_STATUS, v);
	CHECK_VALUE("irq_count", irq_count, (iemask & (SPWAMBA_CONTROL_IERXPACKET | SPWAMBA_CONTROL_IERXDESC)) ? 1 : 0);
	irq_count = 0;

	/* Disable interrupts; reset DMA */
	irq_expect = 0;
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_RESETDMA);
	v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x4003);
}


/* Test DMA and data transfer. */
static void test_data(void)
{
	unsigned int i, j, k, v;

	/* note: link still up */

	/* sentinels in RX buffer */
	buf[8200] = 0xa0;
	buf[9216] = 0xa1;
	buf[9220] = 0xa2;
	buf[10244] = 0xa3;
	buf[11268] = 0xa4;
	buf[11272] = 0xa5;

	/* set up one TX descriptor */
	txdesctable[0].f = 0x00110004;		/* EOP, EN, 4 bytes */
	txdesctable[0].d = buf;
	txdesctable[1].f = 0xfffeffff;		/* disabled */
	txdesctable[1].d = NULL;

	/* set up two RX descriptors */
	rxdesctable[0].f = 0x10400;		/* EN, 1024 bytes */
	rxdesctable[0].d = buf + 8192;
	rxdesctable[1].f = 0x50400;		/* IE, EN, 1024 bytes */
	rxdesctable[1].d = buf + 9216;
	rxdesctable[2].f = 0;			/* disabled */
	rxdesctable[2].d = NULL;

	/* start TX dma and wait until complete */
	spwamba_write(SPWAMBA_REG_TXDMA, (unsigned int)txdesctable);
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_TXDMA);
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 200 && (v & 0x80) != 0; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_CONDITION("reg_status", v, (v & 0x3fff) == 0x0003);

	/* check TX descriptor status */
	v = spwamba_read(SPWAMBA_REG_TXDMA);
	CHECK_VALUE("reg_txdma", v, ((unsigned int)txdesctable) + 8);
	CHECK_VALUE("txdesctable[0].f", txdesctable[0].f, 0x00180000);
	CHECK_VALUE("txdesctable[0].d", (unsigned int)txdesctable[0].d, (unsigned int)buf);
	CHECK_VALUE("txdesctable[1].f", txdesctable[1].f, 0xfffeffff);

	/* start RX dma and wait until packet received */
	spwamba_write(SPWAMBA_REG_RXDMA, (unsigned int)rxdesctable);
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_RXDMA);
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 200 && (v & 0x2000) == 0; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x6043);

	/* check RX descriptor status */
	v = spwamba_read(SPWAMBA_REG_RXDMA);
	CHECK_VALUE("reg_rxdma", v, ((unsigned int)rxdesctable) + 8);
	CHECK_VALUE("rxdesctable[0].f", rxdesctable[0].f, 0x00180004);
	CHECK_VALUE("rxdesctable[0].d", (unsigned int)rxdesctable[0].d, ((unsigned int)buf) + 8192);
	CHECK_VALUE("rxdesctable[1].f", rxdesctable[1].f, 0x00050400);

	/* check received data */
	for (i = 0; i < 4; i++)
		CHECK_VALUE("rxdata", buf[8192+i], buf[i]);
	for (i = 0; i < 4; i++)
		CHECK_VALUE("rxeop", buf[8196+i], 0x00);
	CHECK_VALUE("rx sentinel", buf[8200], 0xa0);
	CHECK_VALUE("rx sentinel", buf[9216], 0xa1);

	/* sticky rxpacket bit */
	v = spwamba_read(SPWAMBA_REG_STATUS);	
	CHECK_VALUE("reg_status", v, 0x6043);
	spwamba_write(SPWAMBA_REG_STATUS, v);
	v = spwamba_read(SPWAMBA_REG_STATUS);	
	CHECK_VALUE("reg_status", v, 0x4043);

	printf("transfer packet                         [OK]\n");

	/* send another packet */
	txdesctable[1].f = 0x00110003;		/* EOP, EN, 3 bytes */
	txdesctable[1].d = buf + 4;
	txdesctable[2].f = 0;

	/* start TX dma and wait until complete */
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_TXDMA);
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 200 && (v & 0x80) != 0; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("txdesctable[1].f", txdesctable[1].f, 0x00180000);

	/* wait until packet received and check status */
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 200 && (v & 0x2000) == 0; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x6843);
	v = spwamba_read(SPWAMBA_REG_RXDMA);
	CHECK_VALUE("reg_rxdma", v, ((unsigned int)rxdesctable) + 0x10);
	CHECK_VALUE("rxdesctable[1].f", rxdesctable[1].f, 0x001c0003);

	/* check received data */
	for (i = 0; i < 3; i++)
		CHECK_VALUE("rxdata", buf[9216+i], buf[4+i]);
	CHECK_VALUE("rxeop", buf[9219], 0x00);
	CHECK_VALUE("rx sentinel", buf[9220], 0xa2);

	/* sticky rxpacket, rxframe bits */
	v = spwamba_read(SPWAMBA_REG_STATUS);	
	CHECK_VALUE("reg_status", v, 0x6843);
	spwamba_write(SPWAMBA_REG_STATUS, 0x2000);
	v = spwamba_read(SPWAMBA_REG_STATUS);	
	CHECK_VALUE("reg_status", v, 0x4843);
	spwamba_write(SPWAMBA_REG_STATUS, 0x0800);
	v = spwamba_read(SPWAMBA_REG_STATUS);	
	CHECK_VALUE("reg_status", v, 0x4043);

	printf("transfer packet (2)                     [OK]\n");

	/* send another packet */
	txdesctable[2].f = 0x00150002;		/* EOP, IE, EN, 2 bytes */
	txdesctable[2].d = buf + 8;
	txdesctable[3].f = 0;

	/* start TX dma and wait until complete */
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_TXDMA);
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 200 && (v & 0x80) == 0x80; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("txdesctable[2].f", txdesctable[2].f, 0x001c0000);

	/* wait until RX dma disabled */
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 200 && (v & 0x40) != 0; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x1003);
	v = spwamba_read(SPWAMBA_REG_RXDMA);
	CHECK_VALUE("reg_rxdma", v, ((unsigned int)rxdesctable) + 0x10);
	CHECK_VALUE("rxdesctable[2].f", rxdesctable[2].f, 0);

	/* sticky txframe bit */
	v = spwamba_read(SPWAMBA_REG_STATUS);	
	CHECK_VALUE("reg_status", v, 0x1003);
	spwamba_write(SPWAMBA_REG_STATUS, 0x1000);
	v = spwamba_read(SPWAMBA_REG_STATUS);	
	CHECK_VALUE("reg_status", v, 0x0003);

	printf("stop RX dma at inactive descriptor      [OK]\n");

	/* resume RX DMA */
	rxdesctable[2].f = 0x30400;		/* EN, WR, 1024 bytes */
	rxdesctable[2].d = buf + 10240;
	rxdesctable[0].f = 0x10400;		/* EN, 1024 bytes */
	rxdesctable[0].d = buf + 11264;
	rxdesctable[3].f = 0x10234;		/* enabled but unused */
	rxdesctable[3].d = NULL;
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_RXDMA);

	/* wait until pending packet received;
           check RX descriptor wrapped */
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 200 && (v & 0x2000) == 0; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x6043);
	spwamba_write(SPWAMBA_REG_STATUS, v);
	v = spwamba_read(SPWAMBA_REG_RXDMA);
	CHECK_VALUE("reg_rxdma", v, (unsigned int)rxdesctable);
	CHECK_VALUE("rxdesctable[2].f", rxdesctable[2].f, 0x001a0002);
	CHECK_VALUE("rxdesctable[3].f", rxdesctable[3].f, 0x00010234);

	/* check received data */
	CHECK_VALUE("rxdata", buf[10240], buf[8]);
	CHECK_VALUE("rxdata", buf[10241], buf[9]);
	CHECK_VALUE("rxeop", buf[10242], 0x00);
	CHECK_VALUE("rxeop", buf[10243], 0x00);
	CHECK_VALUE("rx sentinel", buf[10244], 0xa3);

	printf("resume RX dma                           [OK]\n");

	/* send another packet;
	   check TX descriptor wrapped */
	txdesctable[3].f = 0x00130001;		/* EOP, EN, WR, 1 byte */
	txdesctable[3].d = buf + 12;
	txdesctable[4].f = 0x00010123;		/* enabled but unused */
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_TXDMA);
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 200 && (v & 0x80) != 0; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x4043);
	v = spwamba_read(SPWAMBA_REG_TXDMA);
	CHECK_VALUE("reg_txdma", v, (unsigned int)txdesctable);
	CHECK_VALUE("txdesctable[3].f", txdesctable[3].f, 0x001a0000);
	CHECK_VALUE("txdesctable[4].f", txdesctable[4].f, 0x00010123);

	/* wait until packet received */
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 200 && (v & 0x2000) == 0; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x6043);
	spwamba_write(SPWAMBA_REG_STATUS, v);
	v = spwamba_read(SPWAMBA_REG_RXDMA);
	CHECK_VALUE("reg_rxdma", v, ((unsigned int)rxdesctable) + 8);
	CHECK_VALUE("rxdesctable[0].f", rxdesctable[0].f, 0x00180001);
	CHECK_VALUE("rxdesctable[3].f", rxdesctable[3].f, 0x00010234);

	/* check received data */
	CHECK_VALUE("rxdata", buf[11264], buf[12]);
	CHECK_VALUE("rxeop", buf[11265], 0x00);
	CHECK_VALUE("rxeop", buf[11266], 0x00);
	CHECK_VALUE("rxeop", buf[11267], 0x00);
	CHECK_VALUE("rx sentinel", buf[11268], 0xa4);

	/* send packet and check descriptor auto-wrap */
	k = (1 << DESCTABLESIZE) - 1;
	txdesctable[k].f = 0x00110003;	    /* EOP, EN, 3 bytes */
	txdesctable[k].d = buf + 16;
	spwamba_write(SPWAMBA_REG_TXDMA, (unsigned int)(&txdesctable[k]));
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_TXDMA);
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 200 && (v & 0x80) != 0; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	v = spwamba_read(SPWAMBA_REG_TXDMA);
	CHECK_VALUE("reg_txdma", v, (unsigned int)txdesctable);
	CHECK_VALUE("txdesctable[k].f", txdesctable[k].f, 0x00180000);

	/* wait until RX dma disabled */
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 200 && (v & 0x40) != 0; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x0003);

	/* restart RX dma; receive packet; check descriptor auto-wrap */
	rxdesctable[k].f = 0x10400;		/* EN, 1024 bytes */
	rxdesctable[k].d = buf + 11268;
	spwamba_write(SPWAMBA_REG_RXDMA, (unsigned int)(&rxdesctable[k]));
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_RXDMA);
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 200 && (v & 0x2000) == 0; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x6043);
	spwamba_write(SPWAMBA_REG_STATUS, v);
	v = spwamba_read(SPWAMBA_REG_RXDMA);
	CHECK_VALUE("reg_rxdma", v, (unsigned int)rxdesctable);
	CHECK_VALUE("rxdesctable[k].f", rxdesctable[k].f, 0x00180003);

	/* check received data */
	for (i = 0; i < 3; i++)
		CHECK_VALUE("rxdata", buf[11268+i], buf[16+i]);
	CHECK_VALUE("rxeop", buf[11271], 0x00);
	CHECK_VALUE("rx sentinel", buf[11272], 0xa5);

	printf("descriptor wrap                         [OK]\n");

	/* test interrupts */
	test_data_interrupt(SPWAMBA_CONTROL_IERXDESC);
	test_data_interrupt(SPWAMBA_CONTROL_IETXDESC);
	test_data_interrupt(SPWAMBA_CONTROL_IERXPACKET);
	test_data_interrupt(SPWAMBA_CONTROL_IERXDESC | SPWAMBA_CONTROL_IETXDESC | SPWAMBA_CONTROL_IERXPACKET);

	printf("data interrupts                         [OK]\n");

	/* start RX dma */
	rxdesctable[0].f = 0x10400;		/* EN, 1024 bytes */
	rxdesctable[0].d = buf + 8192;
	rxdesctable[1].f = 0;
	spwamba_write(SPWAMBA_REG_RXDMA, (unsigned int)rxdesctable);
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_RXDMA);

	/* transmit partial packets and check txdesc flag */
	spwamba_write(SPWAMBA_REG_TXDMA, (unsigned int)txdesctable);
	for (i = 0; i < 8; i++) {
		txdesctable[i].f = (0x10000 | (i < 4 ? 0x40000 : 0)) + i + 1;
		txdesctable[i].d = buf + 4 * i;
		txdesctable[i+1].f = 0;
		spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_TXDMA);
		v = spwamba_read(SPWAMBA_REG_STATUS);
		for (j = 0; j < 200 && (v & 0x80) != 0; j++)
			v = spwamba_read(SPWAMBA_REG_STATUS);
		CHECK_CONDITION("reg_status", v, (v & 0x3fff) == (0x43 | (i < 4 ? 0x1000 : 0)));
		spwamba_write(SPWAMBA_REG_STATUS, v);
		CHECK_VALUE("txdesctable", txdesctable[i].f, 0x80000 | (i < 4 ? 0x40000 : 0));
	}

	/* transmit a series of partial packets at once */
	for (i = 8; i < 16; i++) {
		txdesctable[i].f = 0x10000 + i + 1;
		txdesctable[i].d = buf + 4 * i;
	}
	txdesctable[16].f = 0;
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_TXDMA);
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 1200 && (v & 0x80) != 0; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x0043);
	for (i = 8; i < 16; i++)
		CHECK_VALUE("txdesctable", txdesctable[i].f, 0x80000);

	/* transmit just an EOP character */
	txdesctable[16].f = 0x110000;	/* EOP, EN, 0 bytes */
	txdesctable[16].d = (unsigned char *)0xc0000000;	/* invalid pointer */
	txdesctable[17].f = 0;
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_TXDMA);

	/* wait until packet received */
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 1200 && (v & 0x2000) == 0; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x6043);
	spwamba_write(SPWAMBA_REG_STATUS, v);
	CHECK_VALUE("txdesctable[16].f", txdesctable[16].f, 0x180000);
	CHECK_VALUE("rxdesctable[0].f", rxdesctable[0].f, 0x180088);

	/* check received data */
	k = 0;
	for (i = 0; i < 16; i++) {
		for (j = 0; j < i + 1; j++) {
			CHECK_VALUE("rxdata", buf[8192+k], buf[4*i+j]);
			k++;
		}
	}

	printf("send partial packets                    [OK]\n");

	/* set up descriptors for packets with different sizes */
	for (i = 0; i < 8; i++) {
		txdesctable[i].f = 0x110000 + i + 1;
		txdesctable[i].d = buf + 4 * i;
	}
	/* tx packets of size 28 .. 35 */
	for (i = 8; i < 16; i++) {
		txdesctable[i].f = 0x110000 + i + 20;
		txdesctable[i].d = buf + 4 * i;
	}
	txdesctable[16].f = 0;
	/* initially set up just 12 rx frames */
	for (i = 0; i < 12; i++) {
		rxdesctable[i].f = 0x10020;	/* max 32 bytes */
		rxdesctable[i].d = buf + 8192 + 36 * i;
	}
	rxdesctable[12].f = 0;

	/* start transfer and wait until rx complete */
	spwamba_write(SPWAMBA_REG_RXDMA, (unsigned int)rxdesctable);
	spwamba_write(SPWAMBA_REG_TXDMA, (unsigned int)txdesctable);
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_RXDMA | SPWAMBA_CONTROL_TXDMA);
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 2400 && (v & 0x40) != 0; i++ )
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_CONDITION("reg_status", v, (v & 0x3f7f) == 0x2003);
	spwamba_write(SPWAMBA_REG_STATUS, v);

	/* the next rx frame will have no EOP,
           so it should trigger rxdesc but not rxpacket */
	rxdesctable[12].f = 0x50020;
	rxdesctable[12].d = buf + 8192 + 36 * 12;
	rxdesctable[13].f = 0;
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_RXDMA);
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 2400 && (v & 0x40) != 0; i++ )
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_CONDITION("reg_status", v, (v & 0xff7f) == 0x0803);
	spwamba_write(SPWAMBA_REG_STATUS, v);

	/* do remaining RX frames; all packets are split over 2 rx frames */
	for (i = 13; i < 20; i++) {
		rxdesctable[i].f = 0x10020;	/* max 32 bytes */
		rxdesctable[i].d = buf + 8192 + 36 * i;
	}
	rxdesctable[19].f = 0x50020;		/* IE on last descriptor */
	rxdesctable[20].f = 0;
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_RXDMA);
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 2400 && (v & 0x0800) == 0; i++ )
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x6843);
	spwamba_write(SPWAMBA_REG_STATUS, v);

	/* check completed descriptors */
	for (i = 0; i < 16; i++)
		CHECK_VALUE("txdesctable", txdesctable[i].f, 0x180000);
	for (i = 0; i < 8; i++)
		CHECK_VALUE("rxdesctable", rxdesctable[i].f, 0x180000 + i + 1);
	for (i = 8; i < 12; i++)
		CHECK_VALUE("rxdesctable", rxdesctable[i].f, 0x180000 + i + 20);
	CHECK_VALUE("rxdesctable", rxdesctable[12].f, 0x0c0020);
	CHECK_VALUE("rxdesctable", rxdesctable[13].f, 0x180000);
	CHECK_VALUE("rxdesctable", rxdesctable[14].f, 0x080020);
	CHECK_VALUE("rxdesctable", rxdesctable[15].f, 0x180001);
	CHECK_VALUE("rxdesctable", rxdesctable[16].f, 0x080020);
	CHECK_VALUE("rxdesctable", rxdesctable[17].f, 0x180002);
	CHECK_VALUE("rxdesctable", rxdesctable[18].f, 0x080020);
	CHECK_VALUE("rxdesctable", rxdesctable[19].f, 0x1c0003);

	/* check received data */
	for (i = 0; i < 8; i++)
		for (j = 0; j < i + 1; j++)
			CHECK_VALUE("rxdata", buf[8192+36*i+j], buf[4*i+j]);
	k = 8;
	for (i = 8; i < 16; i++) {
		for (j = 0; j < i + 20; j++) {
			CHECK_VALUE("rxdata", buf[8192+36*k+j%32], buf[4*i+j]);
			if (j == 31) k++;
		}
		k++;
	}

	printf("several packet lengths                  [OK]\n");

	/* set up 8 rx and tx descriptors for EEP packets */
	for (i = 0; i < 8; i++) {
		txdesctable[i].f = 0x210000 + i + 1;
		txdesctable[i].d = buf + 12 * i;
		rxdesctable[i].f = 0x010400 | (i == 7 ? 0x40000 : 0);
		rxdesctable[i].d = buf + 8192 + 12 * i;
	}
	txdesctable[8].f = 0;
	rxdesctable[8].f = 0;

	/* start DMA, wait until last frame received */
	spwamba_write(SPWAMBA_REG_RXDMA, (unsigned int)rxdesctable);
	spwamba_write(SPWAMBA_REG_TXDMA, (unsigned int)txdesctable);
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_RXDMA | SPWAMBA_CONTROL_TXDMA);
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 1200 && (v & 0x0800) == 0; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x6843);
	spwamba_write(SPWAMBA_REG_STATUS, v);

	/* check completed descriptors and received data*/
	for (i = 0; i < 8; i++) {
		CHECK_VALUE("txdesctable", txdesctable[i].f, 0x280000);
		CHECK_VALUE("rxdesctable", rxdesctable[i].f, (0x280000 | (i == 7 ? 0x40000 : 0)) + i + 1);
		for (j = 0; j < i + 1; j++)
			CHECK_VALUE("rxdata", buf[8192+12*i+j], buf[12*i+j]);
		for (j = i + 1; ; j++) {
			CHECK_VALUE("rxeep", buf[8192+12*i+j], 0x01);
			if ((j & 3) == 3)
				break;
		}
	}

	printf("transfer EEP packets                    [OK]\n");

	/* send so much data that the RX and TX queues fill up */
	txdesctable[0].f = 0x150000 + QUEUEFILL; /* EOP, EN, IE, QUEUEFILL bytes */
	txdesctable[0].d = buf;
	txdesctable[1].f = 0x150000 + QUEUEFILL; /* EOP, EN, IE, QUEUEFILL bytes */
	txdesctable[1].d = buf + 40;
	txdesctable[2].f = 0;
	spwamba_write(SPWAMBA_REG_TXDMA, (unsigned int)txdesctable);
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_TXDMA);

	/* wait until first packet transmitted */
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 12000 && (v & 0x1000) == 0; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	/* wait a little longer to make sure the flow is blocked */
	for (i = 0; i < 1200; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x1083);

	/* start RX dma */
	rxdesctable[0].f = 0x010800;	/* EN, 2048 bytes */
	rxdesctable[0].d = buf + 8192;
	rxdesctable[1].f = 0x050800;	/* EN, IE, 2048 bytes */
	rxdesctable[1].d = buf + 8192 + 2048;
	rxdesctable[2].f = 0;
	spwamba_write(SPWAMBA_REG_RXDMA, (unsigned int)rxdesctable);
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_RXDMA);

	/* wait until second packet received */
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 32000 && (v & 0x800) == 0; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x7843);
	spwamba_write(SPWAMBA_REG_STATUS, v);

	/* check completed descriptors */
	CHECK_VALUE("txdesctable[0].f", txdesctable[0].f, 0x1c0000);
	CHECK_VALUE("txdesctable[1].f", txdesctable[1].f, 0x1c0000);
	CHECK_VALUE("rxdesctable[0].f", rxdesctable[0].f, 0x180000 + QUEUEFILL);
	CHECK_VALUE("rxdesctable[1].f", rxdesctable[1].f, 0x1c0000 + QUEUEFILL);

	/* check received data */
	for (i = 0; i < QUEUEFILL / 4; i++)
		CHECK_VALUE("rxdata", ((unsigned int *)buf)[2048+i], ((unsigned int *)buf)[i]);
	for (i = 0; i < QUEUEFILL / 4; i++)
		CHECK_VALUE("rxdata", ((unsigned int *)buf)[2048+512+i], ((unsigned int *)buf)[10+i]);
	CHECK_VALUE("rxeop", ((unsigned int *)buf)[2048+512+QUEUEFILL/4], 0);

	printf("handle full TX queue                    [OK]\n");

	/* start tx dma */
	txdesctable[0].f = 0x050200;	/* EN, IE, 512 bytes */
	txdesctable[0].d = buf;
	txdesctable[1].f = 0x150100;	/* EOP, EN, IE, 256 bytes */
	txdesctable[1].d = buf + 512;
	txdesctable[2].f = 0;
	spwamba_write(SPWAMBA_REG_TXDMA, (unsigned int)txdesctable);
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_TXDMA);

	/* wait until first packet sent, then cancel tx dma */
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 4000 && (v & 0x1000) == 0; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_TXCANCEL);
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 4000 && (v & 0x0040) != 0; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x1003);
	CHECK_VALUE("txdesctable[0].f", txdesctable[0].f, 0x0c0000);
	CHECK_VALUE("txdesctable[1].f", txdesctable[1].f, 0x150100);

	/* send EEP to flush the partial packet */
	txdesctable[1].f = 0x250000;
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_TXDMA);

	/* start rx dma */
	rxdesctable[0].f = 0x010400;	/* EN, max 1024 bytes */
	rxdesctable[0].d = buf + 8192;
	rxdesctable[1].f = 0;
	spwamba_write(SPWAMBA_REG_RXDMA, (unsigned int)rxdesctable);
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_RXDMA);
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 1600 && (v & 0x2000) == 0; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x7043);
	spwamba_write(SPWAMBA_REG_STATUS, v);
	CHECK_VALUE("txdesctable[1].f", txdesctable[1].f, 0x2c0000);
	CHECK_CONDITION("rxdesctable[0].f", rxdesctable[0].f, (rxdesctable[0].f & 0xfffff000) == 0x280000);

	printf("cancel TX dma                           [OK]\n");

	/* start tx dma from invalid address */
	txdesctable[2].f = 0x110010;	/* EOP, EN, 16 bytes */
	txdesctable[2].d = (unsigned char *)0xc0000000;	/* invalid pointer */
	txdesctable[3].f = 0;
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_TXDMA);
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 200 && (v & 0x80) != 0; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);

	/* check ahberror flag */
	CHECK_VALUE("reg_status", v, 0x4103);
	spwamba_write(SPWAMBA_REG_STATUS, v);
	v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x4103);

	/* reset DMA */
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_RESETDMA);
	v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x4003);

	printf("AHB error and dma reset                 [OK]\n");

	/* note: link still up */
}


/* Test handling of link loss during data transfer */
static void test_linkloss(void)
{
	unsigned int i, v;

	/* note: link still up */

	/* transfer one packet; wait until received */
	txdesctable[0].f = 0x00110014;		/* EOP, EN, 20 bytes */
	txdesctable[0].d = buf + 4;
	txdesctable[1].f = 0;
	rxdesctable[0].f = 0x00010400;		/* EN, 1024 bytes */
	rxdesctable[0].d = buf + 8192;
	rxdesctable[1].f = 0;
	spwamba_write(SPWAMBA_REG_RXDMA, (unsigned int)rxdesctable);
	spwamba_write(SPWAMBA_REG_TXDMA, (unsigned int)txdesctable);
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_TXDMA | SPWAMBA_CONTROL_RXDMA);
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 400 && (v & 0x2000) == 0; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x6043);
	spwamba_write(SPWAMBA_REG_STATUS, v);
	CHECK_VALUE("txdesctable[0].f", txdesctable[0].f, 0x00180000);
	CHECK_VALUE("rxdesctable[0].f", rxdesctable[0].f, 0x00180014);

	/* verify received data */
	for (i = 0; i < 20; i++)
		CHECK_VALUE("rxdata", buf[8192+i], buf[4+i]);

#if LOOPBACKSWITCH
	/* unplug link */
	console[2] &= ~LEON_REG_UART_CTRL_RE;
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 40 && (v & 3) == 3; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	spwamba_write(SPWAMBA_REG_STATUS, v);

	/* check receive buffer still empty */
	v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x4040);

	/* replug link */
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_START);
	console[2] |= LEON_REG_UART_CTRL_RE;
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 250 && (v & 3) != 3; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);

	/* check receive buffer still empty */
	v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x4043);

	/* transfer one packet; wait until received */
	txdesctable[1].f = 0x00110014;		/* EOP, EN, 20 bytes */
	txdesctable[1].d = buf + 24;
	txdesctable[2].f = 0;
	rxdesctable[1].f = 0x00010400;		/* EN, 1024 bytes */
	rxdesctable[1].d = buf + 8192 + 20;
	rxdesctable[2].f = 0;
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_TXDMA);
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 200 && (v & 0x2000) == 0; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x6043);
	spwamba_write(SPWAMBA_REG_STATUS, v);
	CHECK_VALUE("txdesctable[1].f", txdesctable[1].f, 0x00180000);
	CHECK_VALUE("rxdesctable[1].f", rxdesctable[1].f, 0x00180014);

	/* verify received data */
	for (i = 0; i < 20; i++)
		CHECK_VALUE("rxdata", buf[8192+20+i], buf[24+i]);

	/* transfer partial packet */
	txdesctable[2].f = 0x00050014;		/* EN, IE, 20 bytes */
	txdesctable[2].d = buf;
	txdesctable[3].f = 0;
	rxdesctable[2].f = 0x00010400;		/* EN, 1024 bytes */
	rxdesctable[2].d = buf + 8192;
	rxdesctable[3].f = 0;
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_TXDMA);

	/* wait until partial packet transferred */
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 200; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x1043);
	spwamba_write(SPWAMBA_REG_STATUS, v);
	CHECK_VALUE("txdesctable[2].f", txdesctable[2].f, 0x000c0000);

	/* unplug link */
	console[2] &= ~LEON_REG_UART_CTRL_RE;
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 40 && (v & 3) == 3; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_CONDITION("reg_status", v, (v & 0x1fe3) == 0x0040);

	/* wait until EEP received */
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 100 && (v & 0x2000) == 0; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_CONDITION("reg_status", v, (v & 0xffffffe0) == 0x6040);
	spwamba_write(SPWAMBA_REG_STATUS, v);
	CHECK_VALUE("rxdesctable[2].f", rxdesctable[2].f, 0x00280014);

	/* verify received data */
	for (i = 0; i < 20; i++)
		CHECK_VALUE("rxdata", buf[8192+i], buf[i]);
	CHECK_VALUE("rxeep", buf[8192+20], 0x01);

	/* send one packet; should be discarded */
	txdesctable[3].f = 0x0015000a;		/* EOP, IE, EN, 10 bytes */
	txdesctable[3].d = buf;
	txdesctable[4].f = 0;
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_TXDMA | SPWAMBA_CONTROL_START);
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 200 && (v & 0x0800) == 0; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_CONDITION("reg_status", v, (v & 0xfffffffc) == 0x5040);
	spwamba_write(SPWAMBA_REG_STATUS, v);
	CHECK_VALUE("txdesctable[3].f", txdesctable[3].f, 0x001c0000);

	/* replug link */
	console[2] |= LEON_REG_UART_CTRL_RE;
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 250 && (v & 3) != 3; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);

	/* check receive buffer still empty */
	for (i = 0; i < 200; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x4043);

	/* transfer one packet; wait until received */
	txdesctable[4].f = 0x0011000a;		/* EOP, EN, 10 bytes */
	txdesctable[4].d = buf + 28;
	txdesctable[5].f = 0;
	rxdesctable[3].f = 0x00010400;		/* EN, 1024 bytes */
	rxdesctable[3].d = buf + 8192;
	rxdesctable[4].f = 0;
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_TXDMA);
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 400 && (v & 0x2000) == 0; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x6043);
	spwamba_write(SPWAMBA_REG_STATUS, v);
	CHECK_VALUE("txdesctable[4].f", txdesctable[4].f, 0x00180000);
	CHECK_VALUE("rxdesctable[3].f", rxdesctable[3].f, 0x0018000a);

	/* verify received data */
	for (i = 0; i < 10; i++)
		CHECK_VALUE("rxdata", buf[8192+i], buf[28+i]);
	CHECK_VALUE("rxeop", buf[8192+10], 0x00);

	printf("got EEP and txdiscard after link lost   [OK]\n");

#else
	spwamba_write(SPWAMBA_REG_RXDMA, ((unsigned int)rxdesctable) + 4 * 8);
	spwamba_write(SPWAMBA_REG_TXDMA, ((unsigned int)txdesctable) + 5 * 8);
#endif

	/* transfer partial packet */
	txdesctable[5].f = 0x0001000a;		/* EN, 10 bytes */
	txdesctable[5].d = buf + 32;
	txdesctable[6].f = 0;
	rxdesctable[4].f = 0x00010400;		/* EN, 1024 bytes */
	rxdesctable[4].d = buf + 8192;
	rxdesctable[5].f = 0;
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_TXDMA);

	/* wait until partial packet transferred */
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 200; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x0043);
	CHECK_VALUE("txdesctable[5].f", txdesctable[5].f, 0x00080000);

	/* disable link */
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_DISABLE);
	v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_CONDITION("reg_status", v, (v & 0xffff9fff) == 0x0040);

	/* wait until EEP received */
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 100 && (v & 0x2000) == 0; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x6040);
	spwamba_write(SPWAMBA_REG_STATUS, v);
	CHECK_VALUE("rxdesctable[4].f", rxdesctable[4].f, 0x0028000a);

	/* verify received data */
	for (i = 0; i < 10; i++)
		CHECK_VALUE("rxdata", buf[8192+i], buf[i+32]);
	CHECK_VALUE("rxeep", buf[8192+10], 0x01);

	/* send one packet; wait until packet in TX buf */
	txdesctable[6].f = 0x0011000a;		/* EOP, EN, 10 bytes */
	txdesctable[6].d = buf + 36;
	txdesctable[7].f = 0;
	rxdesctable[5].f = 0x00010400;		/* EN, 1024 bytes */
	rxdesctable[5].d = buf + 8192;
	rxdesctable[6].f = 0;
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_TXDMA);
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 400 && (v & 0x80) != 0; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x4040);
	CHECK_VALUE("txdesctable[6].f", txdesctable[6].f, 0x00180000);

	/* reenable link */
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_START);

	/* wait until packet received */
	v = spwamba_read(SPWAMBA_REG_STATUS);
	for (i = 0; i < 400 && (v & 0x2000) == 0; i++)
		v = spwamba_read(SPWAMBA_REG_STATUS);
	CHECK_VALUE("reg_status", v, 0x6043);
	spwamba_write(SPWAMBA_REG_STATUS, v);
	CHECK_VALUE("rxdesctable[5].f", rxdesctable[5].f, 0x0018000a);

	/* verify received data */
	for (i = 0; i < 10; i++)
		CHECK_VALUE("rxdata", buf[8192+i], buf[36+i]);
	CHECK_VALUE("rxeop", buf[8192+10], 0x00);

	printf("got EEP after link disabled             [OK]\n");

	/* reset DMA */
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_RESETDMA);

	/* note: link still up */
}


/* Change TX bit rate and measure throughput */
static void test_txrate(void)
{
	unsigned int i, k, v;

	/* note: link still up */

	/* set up 2nd GPTIMER channel to count down microseconds */
	LEON3_GpTimer_Regs->e[1].rld = 0xffffffff;
	LEON3_GpTimer_Regs->e[1].ctrl = 0x05;

	for (k = 0; k < 3; k++) {
		unsigned int nbyte, txfreq, usec;

		switch (k) {
		  case 1:
			nbyte = 500;
			txfreq = 5;
			break;
		  case 2:
			nbyte = 2048;
			txfreq = TXCLKFREQ / 2;
			break;
		  default:
			nbyte = 1000;
			txfreq = 10;
			break;
		}

		/* switch TX bit rate to txfreq Mbit/s */
		spwamba_write(SPWAMBA_REG_TXSCALER, (TXCLKFREQ / txfreq) - 1);

		/* setup packet of nbyte bytes */
		txdesctable[0].f = 0x00110000 + nbyte;
		txdesctable[0].d = buf;
		txdesctable[1].f = 0;
		rxdesctable[0].f = 0x00011000;		/* EN, 4096 bytes */
		rxdesctable[0].d = buf + 8192;
		rxdesctable[1].f = 0;

		/* transfer packet and wait until received */
		usec = LEON3_GpTimer_Regs->e[1].val;
		spwamba_write(SPWAMBA_REG_RXDMA, (unsigned int)rxdesctable);
		spwamba_write(SPWAMBA_REG_TXDMA, (unsigned int)txdesctable);
		spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_TXDMA | SPWAMBA_CONTROL_RXDMA);
		v = spwamba_read(SPWAMBA_REG_STATUS);
		for (i = 0; i < 16000 && (v & 0x2080) != 0x2000; i++)
			v = spwamba_read(SPWAMBA_REG_STATUS);

		usec = usec - LEON3_GpTimer_Regs->e[1].val + 1;

		CHECK_VALUE("reg_status", v, 0x6043);
		spwamba_write(SPWAMBA_REG_STATUS, v);
		CHECK_VALUE("txdesctable[0].f", txdesctable[0].f, 0x00180000);
		CHECK_VALUE("rxdesctable[0].f", rxdesctable[0].f, 0x00180000 + nbyte);

		/* verify last 32 bytes */
		for (i = nbyte - 32; i < nbyte; i++)
			CHECK_VALUE("rxdata", buf[8192+i], buf[i]);
		CHECK_VALUE("rxeop", buf[8192+nbyte], 0x00);

		printf("transfered %d bytes at %d Mbit/s in %d usec = %d.%03d MByte/s [OK]\n",
		       nbyte, txfreq, usec, nbyte/usec, ((nbyte%usec)*1000)/usec);
	}

	/* reset SPWAMBA */
	spwamba_write(SPWAMBA_REG_CONTROL, SPWAMBA_CONTROL_RESET);

	/* disable GPTIMER channel */
	LEON3_GpTimer_Regs->e[1].ctrl = 0;
}


int main(void)
{
	printf("-------- spwamba_test --------\n");

	/* Workaround to force amba_init(). */
	{
		unsigned int *tcount, *treload, *tctrl;
		Timer_getTimer1(&tcount, &treload, &tctrl);
	}

	/* Find SPWAMBA core on APB bus. */
	spwamba_start = amba_find_apbslv_addr(0x8, 0x131, &spwamba_irq);
	if ((spwamba_start & 0xf0000000) != 0x80000000) {
		printf("ERROR: SPWAMBA core not found on APB bus.\n");
		fail();
		return 1;
	}
	printf("Found SPWAMBA core at 0x%08lx, irq=%lu.\n", spwamba_start, spwamba_irq);

	/* Install interrupt handler. */
	irq_expect = 0;
	catch_interrupt((int)spwamba_interrupt, spwamba_irq);
	leonbare_enable_irq(spwamba_irq);

	/* Allocate RX and TX descriptor tables, suitably aligned */
	rxdesctable = malloc(3 * (1 << DESCTABLESIZE) * 8);
	rxdesctable = (struct descriptor_struct *)(((((unsigned int)rxdesctable) >> (DESCTABLESIZE + 3)) + 1) << (DESCTABLESIZE + 3));
	txdesctable = rxdesctable + (1 << DESCTABLESIZE);

	/* Allocate 16 kByte buffer */
	buf = malloc(16384);

	/* Enable spacewire link, disable external time tick */
#if LOOPBACKSWITCH
	console[2] |= LEON_REG_UART_CTRL_RE;	/* uart RXEN bit enables spacewire loopback */
#endif
	LEON3_GpTimer_Regs->e[1].ctrl = 0;	/* Timer2 generates tick_in pulses */

	test_regs();
	test_link();
	test_timecode();
	create_test_data();
	test_data();
	test_linkloss();
	test_txrate();

	check_test_data();

	printf("-------- done --------\n");
	powerdown();

	return 0;
}

