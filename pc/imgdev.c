

// this file implements some function to access image device


#include <usb.h>
#include <stdio.h>

#include "misc.h"


#define IMG_DEV_VID 0x0547
#define IMG_DEV_PID 0x1002
//#define IMG_DEV_VID 0x0a82 
//#define IMG_DEV_PID 0x0603

static usb_dev_handle* img_dev_handle=NULL;

int img_dev_open()
{
        struct usb_bus *bus;
        if(img_dev_handle)
                return -1;
        usb_set_debug(14);
        usb_init();
        usb_find_busses();
        usb_find_devices();

        for (bus = usb_get_busses(); bus; bus = bus->next) 
        {
                struct usb_device *dev;
                for (dev = bus->devices; dev; dev = dev->next)
                {
                        if(      dev->descriptor.idVendor  == IMG_DEV_VID
                             &&  dev->descriptor.idProduct == IMG_DEV_PID )
                        {
                                        img_dev_handle = usb_open(dev);
                                        usb_set_configuration ( img_dev_handle, 1);
                                        usb_claim_interface   ( img_dev_handle, 0);
                                        usb_set_altinterface  ( img_dev_handle, 0);
                                        return 0;
                        }
                }
        }
        return -1;
}

void img_dev_close()
{
        if(img_dev_handle)
        {
                usb_close(img_dev_handle);
                img_dev_handle=NULL;
        }

}

int img_read_img(unsigned char* buf, int len)
{
        int i;
        if(!img_dev_handle)
                return -2;
        i=usb_bulk_read(img_dev_handle, 0x82, (char*)buf,  len, 200);
        if(i!=len)
                DEBUG_LINE("read data error");
        return i;
}

int img_write_data(unsigned char* buf, int len,int addr)
{
        int i;
        if(!img_dev_handle)
                return -2;
        if(addr != 0x08 && addr != 0x6 )
                return -3;
        i=usb_bulk_write(img_dev_handle, addr, (char*)buf,  len, 500);
        if(i!=len)
        {
                DEBUG_LINE("write data have some error i= %d",i);
                return -1;
        }
        return i;
}
