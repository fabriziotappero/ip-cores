#ifndef __USB_DESC_H__
#define __USB_DESC_H__

//-----------------------------------------------------------------
// Prototypes
//-----------------------------------------------------------------
unsigned char *usb_get_descriptor( unsigned char bDescriptorType, unsigned char bDescriptorIndex, unsigned short wLength, unsigned char *pSize );
int usb_is_bus_powered(void);

#endif
