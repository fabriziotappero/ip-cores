#ifndef USB_SYNC_H_
#define USB_SYNC_H_

#include <system.h>
#include <io.h>

#include "types.h"

#define USB_DATA_RD			IORD_8DIRECT(USB_SYNC_0_BASE, 0)
#define USB_DATA_WR(data)		IOWR_8DIRECT(USB_SYNC_0_BASE, 0, data)
#define USB_RX_STATUS			IORD_32DIRECT(USB_SYNC_0_BASE, 4)
#define USB_TX_STATUS			IORD_32DIRECT(USB_SYNC_0_BASE, 8)
#define USB_TX_FULL			(USB_TX_STATUS & (1 << 12))
#define USB_RX_EMPTY			(USB_RX_STATUS & (1 << 12))
#define USB_TX_USED			(USB_TX_STATUS & 0x0FFF)
#define USB_TX_FREE			(4095 - USB_TX_USED)


void usb_putch(uint8_t c);
bool usb_kbhit(void);
uint8_t usb_getch(void);
void usb_print(const char *string);

#endif /*USB_SYNC_H_*/
