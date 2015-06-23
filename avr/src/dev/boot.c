#include <device.h>

static igordev_init_fn_t boot_init;
static igordev_read_fn_t boot_read;
static igordev_write_fn_t boot_write;
static igordev_flush_fn_t boot_flush;
extern struct igordev igordev_mmc;

struct igordev igordev_boot = {
	.init = boot_init,
	.read = boot_read,
	.write = boot_write,
	.flush = boot_flush
};

/* We want to be loaded later on. */
void
boot_init(void)
{
	igordev_boot.id = (CAN_READ | ADDR_READ | ADDR_WRITE | (DEVTYPE_BOOT <<
	    DEVTYPE_OFFSET));
	igordev_boot.read_status = igordev_boot.write_status = IDEV_STATUS_OK;
}

/* Read data from boot program. */
uint8_t
boot_read(uint64_t addr, uint8_t *data, uint8_t numbytes)
{

	return (igordev_mmc.read(addr, data, numbytes));
}

/* We don't allow writing to this part. */
uint8_t
boot_write(uint64_t addr, uint8_t *data, uint8_t numbytes)
{
	return (numbytes);
}

void
boot_flush(void) {}
