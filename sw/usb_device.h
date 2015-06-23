#ifndef __USB_DEVICE_H__
#define __USB_DEVICE_H__

//-----------------------------------------------------------------
// Types
//-----------------------------------------------------------------
typedef void (*FP_CLASS_REQUEST)(unsigned char req, unsigned short wValue, unsigned short WIndex, unsigned char *data, unsigned short wLength);
typedef void (*FP_BUS_RESET)(void);

//-----------------------------------------------------------------
// Prototypes
//-----------------------------------------------------------------
void usb_init(FP_BUS_RESET bus_reset, FP_CLASS_REQUEST class_request);
int  usb_control_send(unsigned char *buf, int size);

#endif
