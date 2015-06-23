/*
 * dspkbd.h -- display & keyboard controller simulation
 */


#ifndef _DSPKBD_H_
#define _DSPKBD_H_


Word displayRead(Word addr);
void displayWrite(Word addr, Word data);

void displayReset(void);
void displayInit(void);
void displayExit(void);


#define KEYBOARD_CTRL		0	/* keyboard control register */
#define KEYBOARD_DATA		4	/* keyboard data register */

#define KEYBOARD_RDY		0x01	/* keyboard has a character */
#define KEYBOARD_IEN		0x02	/* enable keyboard interrupt */
#define KEYBOARD_USEC		2000	/* input checking interval */


Word keyboardRead(Word addr);
void keyboardWrite(Word addr, Word data);

void keyboardReset(void);
void keyboardInit(void);
void keyboardExit(void);


#endif /* _DSPKBD_H_ */
