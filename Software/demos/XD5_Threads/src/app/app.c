#include <stdlib.h>
#include "drivers/lcd.h"
#include "drivers/led.h"
#include "os/lock.h"

static int lock;

void LED_showTID(int tid);
void LED_hideTID(int tid);
void delay(void);


/* Each thread will enter at main */
int main(void)
{
	int tid = 0;
	char val = 0;


	/* Load unique thread ID which is stored in register k1 */
	asm (
		"addu %[tid], $27, $0\n\t"
		: [tid] "=r"(tid)
		:
		:
	);

	/* Allow a single thread to set up the LCD screen and LEDs*/
	if (tid == 1) {
		LED_write(0);
		LCD_clear();
		LCD_setPos(0);
		LCD_printString("Thread: 12345678");
		LCD_setPos(16);
		LCD_printString("Work:");
	}

	/* Loop a critical section in which work is performed */
	while (1) {
		Lock(&lock, NULL, NULL);
		LED_showTID(tid);
		LCD_setPos(23 + (uint8_t)tid);
		LCD_printByte(val);
		val++;
		LED_hideTID(tid);
		Unlock(&lock);
		delay();
	}
	
	return 0;
}


/* delay:
 *   Create a software delay. Use this to increase or decrease
 *   the probability that the thread holds the lock when the
 *   scheduler swaps it out.
 */
void delay(void)
{
	/* A higher value of 'c' makes it less likely that
	 * a lock will be held, but also lowers throughput. */
	volatile unsigned int c = 16;  // 0, 2, 8, 14, 16, 18, 500, 507

	while (c != 0) {
		c--;
	}
}

/* check_violation:
 *   Checks to see if more than one LED is lit, meaning that more
 *   than one is in the critical section. If this is true, the
 *   Error LED is lit.
 */
void check_violation(uint8_t led)
{
	int i;
	int found_high = 0;

	for (i=0; i<8; i++) {
		found_high += (led & 0x1);
		if (found_high > 1) {
			LED_write(LED_read() | LED_ERROR);
			break;
		}
		led >>= 1;
	}
}

/* LED_showTID:
 *   Shows the thread ID (1->8) as a single lit LED (0->7).
 */
void LED_showTID(int tid)
{
	uint32_t led;

	led = LED_read();
	led |= (0x80 >> (tid - 1));
	LED_write(led);
	check_violation(led);
}


/* LED_hideTID:
 *   Turns off the LED (0->7) corresponding to the thread ID (1->8).
 */
void LED_hideTID(int tid)
{
	uint32_t led;

	led = LED_read();
	led &= ~(0x80 >> (tid - 1));
	LED_write(led);
}

