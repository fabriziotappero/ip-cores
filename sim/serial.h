/*
 * serial.h -- serial line simulation
 */


#ifndef _SERIAL_H_
#define _SERIAL_H_


#define SERIAL_RCVR_CTRL	0	/* receiver control register */
#define SERIAL_RCVR_DATA	4	/* receiver data register */
#define SERIAL_XMTR_CTRL	8	/* transmitter control register */
#define SERIAL_XMTR_DATA	12	/* transmitter data register */

#define SERIAL_RCVR_RDY		0x01	/* receiver has a character */
#define SERIAL_RCVR_IEN		0x02	/* enable receiver interrupt */
#define SERIAL_RCVR_USEC	2000	/* input checking interval */

#define SERIAL_XMTR_RDY		0x01	/* transmitter accepts a character */
#define SERIAL_XMTR_IEN		0x02	/* enable transmitter interrupt */
#define SERIAL_XMTR_USEC	1042	/* output speed */


Word serialRead(Word addr);
void serialWrite(Word addr, Word data);

void serialReset(void);
void serialInit(int numSerials, Bool connectTerminals[]);
void serialExit(void);


#endif /* _SERIAL_H_ */
