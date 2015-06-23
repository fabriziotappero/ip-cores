#include <avr/io.h>

#include <stdint.h>
#include <stdlib.h>
#include <device.h>

/* Example device for adding device-specific hooks. */

#define LED_INIT 0xFE
#define LED_UNINIT 0x0F
#define LED_ERROR 0xF0

static igordev_read_fn_t led_read;
static igordev_init_fn_t led_init;
static igordev_write_fn_t led_write;
static igordev_deinit_fn_t led_deinit;

struct igordev igordev_ledstk500 = {
	.init = led_init,
	.deinit = led_deinit,
	.read = led_read,
	.write = led_write,
	.write_status = 0,
	.read_status = 0,
	.priv = NULL
};

/* Example initialization routine. */
void
led_init()
{
	/* Initialize buffers. Could probably be device-independent */
	igordev_ledstk500.read_status = igordev_ledstk500.write_status = IDEV_STATUS_OK;

	DDRC = 0xFF;
	/* Initialize skelton device-specific stuff. */
	PORTC = LED_INIT;
}

/* Example read routine. */
uint8_t
led_read(uint8_t *data, uint8_t num)
{

	if (num == 0)
		return (0);
	/* Read only the status of the device if num > 0 */
	/* Read data into device buffers and set pointer. */
	*data = PORTC;
	return (1);
}

/* Example write routine. */
uint8_t
led_write(uint8_t *data, uint8_t num)
{
	if (num == 0)
		return (0);
	PORTC = *data;
	return (0);
}

/* Deinit. */
void
led_deinit(void)
{
	PORTC = LED_UNINIT;
}
