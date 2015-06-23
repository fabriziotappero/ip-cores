
#include "hardware/usb_sync/usb_sync.h"


void usb_putch(uint8_t c)
{
	while (USB_TX_FULL);
	USB_DATA_WR(c);
}

bool usb_kbhit(void)
{
	return !USB_RX_EMPTY;
}

uint8_t usb_getch(void)
{
	while (USB_RX_EMPTY);
	return USB_DATA_RD;
}

void usb_print(const char *string)
{
	while (*string != 0)
	{
		usb_putch(*string);
		string++;
	}
}
