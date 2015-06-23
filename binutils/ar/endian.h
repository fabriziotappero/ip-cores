/*
 * endian.h -- endianness conversions
 */


#ifndef _ENDIAN_H_
#define _ENDIAN_H_


unsigned int read4FromEco(unsigned char *p);
void write4ToEco(unsigned char *p, unsigned int data);
void conv4FromEcoToNative(unsigned char *p);
void conv4FromNativeToEco(unsigned char *p);


#endif /* _ENDIAN_H_ */
