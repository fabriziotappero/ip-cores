#ifndef  __USB_UART_H__
#define  __USB_UART_H__

//-----------------------------------------------------------------
// Prototypes
//-----------------------------------------------------------------
void usb_uart_init(void);
int  usb_uart_haschar(void);
int  usb_uart_getchar(void);
int  usb_uart_getblock(unsigned char *data, int max_length);
int  usb_uart_putchar(char txbyte);
void usb_uart_flush(void);

#endif
