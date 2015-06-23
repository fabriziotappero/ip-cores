
#ifndef __IMGDEV__
#define __IMGDEV__

int img_dev_open();
void img_dev_close();
int img_read_img(unsigned char* buff, int len);
int img_write_data(unsigned char* buf, int len,int addr);

#endif
