/*
 * UART service for userspace
 */
#include <l4lib/macros.h>
#include L4LIB_INC_ARCH(syslib.h)
#include L4LIB_INC_ARCH(syscalls.h)
#include <l4lib/exregs.h>
#include <l4lib/lib/addr.h>
#include <l4lib/ipcdefs.h>
#include <l4/api/errno.h>
#include <l4/api/capability.h>
#include <l4/generic/cap-types.h>
#include <l4/api/space.h>
#include <container.h>
#include <linker.h>
#include <uart.h>
#include <libdev/uart.h>

/* Capabilities of this service */
static struct capability caparray[32];
static int total_caps = 0;

/* Number of UARTS to be managed by this service */
#define UARTS_TOTAL             1
static struct uart uart[UARTS_TOTAL];

int cap_read_all()
{
	int ncaps;
	int err;

	/* Read number of capabilities */
	if ((err = l4_capability_control(CAP_CONTROL_NCAPS,
					 0, &ncaps)) < 0) {
		printf("l4_capability_control() reading # of"
		       " capabilities failed.\n Could not "
		       "complete CAP_CONTROL_NCAPS request.\n");
		BUG();
	}
	total_caps = ncaps;

	/* Read all capabilities */
	if ((err = l4_capability_control(CAP_CONTROL_READ,
					 0, caparray)) < 0) {
		printf("l4_capability_control() reading of "
		       "capabilities failed.\n Could not "
		       "complete CAP_CONTROL_READ_CAPS request.\n");
		BUG();
	}

	return 0;
}

int cap_share_all_with_space()
{
	int err;
	/* Share all capabilities */
	if ((err = l4_capability_control(CAP_CONTROL_SHARE,
					 CAP_SHARE_ALL_SPACE, 0)) < 0) {
		printf("l4_capability_control() sharing of "
		       "capabilities failed.\n Could not "
		       "complete CAP_CONTROL_SHARE request. err=%d\n", err);
		BUG();
	}

	return 0;
}

/*
 * Scans for up to UARTS_TOTAL uart devices in capabilities.
 */
int uart_probe_devices(void)
{
	int uarts = 0;

	/* Scan for uart devices */
	for (int i = 0; i < total_caps; i++) {
		/* Match device type */
		if (cap_devtype(&caparray[i]) == CAP_DEVTYPE_UART) {
			/* Copy to correct device index */
			memcpy(&uart[cap_devnum(&caparray[i]) - 1].cap,
			       &caparray[i], sizeof(uart[0].cap));
			uarts++;
		}
	}

	if (uarts != UARTS_TOTAL) {
		printf("%s: Error, not all uarts could be found. "
		       "total uarts=%d\n", __CONTAINER_NAME__, uarts);
		return -ENODEV;
	}
	return 0;
}

static struct uart uart[UARTS_TOTAL];

int uart_setup_devices(void)
{
	for (int i = 0; i < UARTS_TOTAL; i++) {
		/* Get one page from address pool */
		uart[i].base = (unsigned long)l4_new_virtual(1);

		/* Map uart to a virtual address region */
		if (IS_ERR(l4_map((void *)__pfn_to_addr(uart[i].cap.start),
				  (void *)uart[i].base, uart[i].cap.size,
				  MAP_USR_IO, self_tid()))) {
			printf("%s: FATAL: Failed to map UART device "
			       "%d to a virtual address\n",
			       __CONTAINER_NAME__,
			       cap_devnum(&uart[i].cap));
			BUG();
		}

		/* Initialize uart */
		uart_init(uart[i].base);
	}
	return 0;
}

/*
 * Declare a statically allocated char buffer
 * with enough bitmap size to cover given size
 */
#define DECLARE_IDPOOL(name, size)      \
	         char name[(sizeof(struct id_pool) + ((size >> 12) >> 3))]

#define PAGE_POOL_SIZE                  SZ_1MB
static struct address_pool device_vaddr_pool;
DECLARE_IDPOOL(device_id_pool, PAGE_POOL_SIZE);

/*
 * Initialize a virtual address pool
 * for mapping physical devices.
 */
void init_vaddr_pool(void)
{
	for (int i = 0; i < total_caps; i++) {
		/* Find the virtual memory region for this process */
		if (cap_type(&caparray[i]) == CAP_TYPE_MAP_VIRTMEM &&
		    __pfn_to_addr(caparray[i].start) ==
		    (unsigned long)vma_start) {

			/*
			 * Do we have any unused virtual space
			 * where we run, and do we have enough
			 * pages of it to map all uarts?
			 */
			if (__pfn(page_align_up(__end))
			    + UARTS_TOTAL <= caparray[i].end) {
				/*
				 * Yes. We initialize the device
				 * virtual memory pool here.
				 *
				 * We may allocate virtual memory
				 * addresses from this pool.
				 */
				address_pool_init(&device_vaddr_pool,
						  (struct id_pool *)&device_id_pool,
						  page_align_up(__end),
						  __pfn_to_addr(caparray[i].end));
				return;
			} else
				goto out_err;
		}
	}

out_err:
	printf("%s: FATAL: No virtual memory "
	       "region available to map "
	       "devices.\n", __CONTAINER_NAME__);
	BUG();
}

void *l4_new_virtual(int npages)
{
	return address_new(&device_vaddr_pool, npages, PAGE_SIZE);
}

void uart_generic_tx(char c, int devno)
{
	uart_tx_char(uart[devno].base, c);
}

char uart_generic_rx(int devno)
{
	return uart_rx_char(uart[devno].base);
}

void handle_requests(void)
{
	u32 mr[MR_UNUSED_TOTAL];
	l4id_t senderid;
	u32 tag;
	int ret;

	printf("%s: Initiating ipc.\n", __CONTAINER__);
	if ((ret = l4_receive(L4_ANYTHREAD)) < 0) {
		printf("%s: %s: IPC Error: %d. Quitting...\n",
		       __CONTAINER__, __FUNCTION__, ret);
		BUG();
	}

	/* Syslib conventional ipc data which uses first few mrs. */
	tag = l4_get_tag();
	senderid = l4_get_sender();

	/* Read mrs not used by syslib */
	for (int i = 0; i < MR_UNUSED_TOTAL; i++)
		mr[i] = read_mr(MR_UNUSED_START + i);

	/*
	 * TODO:
	 *
	 * Maybe add tags here that handle requests for sharing
	 * of the requested uart device with the client?
	 *
	 * In order to be able to do that, we should have a
	 * shareable/grantable capability to the device. Also
	 * the request should (currently) come from a task
	 * inside the current container
	 */

	/*
	  * FIXME: Right now we are talking to UART1 by default, we need to define protocol
	  * for sommunication with UART service
	  */
	switch (tag) {
	case L4_IPC_TAG_UART_SENDCHAR:
		printf("got L4_IPC_TAG_UART_SENDCHAR with char %d\n ", mr[0]);
		uart_generic_tx((char)mr[0], 0);
		break;
	case L4_IPC_TAG_UART_RECVCHAR:
		mr[0] = (int)uart_generic_rx(0);
		break;
	default:
		printf("%s: Error received ipc from 0x%x residing "
		       "in container %x with an unrecognized tag: "
		       "0x%x\n", __CONTAINER__, senderid,
		       __cid(senderid), tag);
	}

	/* Reply */
	if ((ret = l4_ipc_return(ret)) < 0) {
		printf("%s: IPC return error: %d.\n", __FUNCTION__, ret);
		BUG();
	}
}

/*
 * UTCB-size aligned utcb.
 *
 * BIG WARNING NOTE:
 * This in-place declaration is legal if we are running
 * in a disjoint virtual address space, where the utcb
 * declaration lies in a unique virtual address in
 * the system.
 */
#define DECLARE_UTCB(name) \
	struct utcb name ALIGN(sizeof(struct utcb))

DECLARE_UTCB(utcb);

/* Set up own utcb for ipc */
int l4_utcb_setup(void *utcb_address)
{
	struct task_ids ids;
	struct exregs_data exregs;
	int err;

	l4_getid(&ids);

	/* Clear utcb */
	memset(utcb_address, 0, sizeof(struct utcb));

	/* Setup exregs for utcb request */
	memset(&exregs, 0, sizeof(exregs));
	exregs_set_utcb(&exregs, (unsigned long)utcb_address);

	if ((err = l4_exchange_registers(&exregs, ids.tid)) < 0)
		return err;

	return 0;
}

void main(void)
{
	int err;

	/* Read all capabilities */
	cap_read_all();

	/* Share all with space */
	cap_share_all_with_space();

	/* Scan for uart devices in capabilities */
	uart_probe_devices();

	/* Initialize virtual address pool for uarts */
	init_vaddr_pool();

	/* Map and initialize uart devices */
	uart_setup_devices();

	/* Setup own utcb */
	if ((err = l4_utcb_setup(&utcb)) < 0) {
		printf("FATAL: Could not set up own utcb. "
		       "err=%d\n", err);
		BUG();
	}

	/* Listen for uart requests */
	while (1)
		handle_requests();
}

