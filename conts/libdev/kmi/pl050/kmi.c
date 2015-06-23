
/*
 * PL050 Primecell Keyboard, Mouse driver
 *
 * Copyright (C) 2010 Amit Mahajan
 */

#include <libdev/kmi.h>
#include "kmi.h"
#include "keymap.h"

/* Enable Rx irq */
void kmi_rx_irq_enable(unsigned long base)
{
	*(volatile unsigned long *)(base + PL050_KMICR) = KMI_RXINTR;
}

int kmi_data_read(unsigned long base)
{
	/* Check and return if data present */
	if (*(volatile unsigned long *)(base + PL050_KMISTAT) & KMI_RXFULL)
		return *(volatile unsigned long *)(base + PL050_KMIDATA);
	else
		return 0;
}

#if 0
char kmi_keyboard_read(int c, struct keyboard_state *state)
{
	int keycode, shkeycode;
	int keynum;
	int extflag;
	int modmask;

	/* Special codes */
	switch (c) {
	case 0xF0:
		/* release */
		state->modifiers |= MODIFIER_RELEASE;
 		return 0;
	case 0xE0:
		/* extended */
		state->modifiers |= MODIFIER_EXTENDED;
		return 0;
	case 0xE1:
		/* extended for 2 characters - only used for Break in mode 2 */
		state->modifiers |= MODIFIER_EXTENDED;
		state->modifiers |= MODIFIER_EXTENDED2;
 		return 0;
 	}

		extflag = 1;
		modmask = 0xFFFFFFFF;

		/* Is this a scan code? */
		if (c > 0 && c <= 0x9F)
		{
			keynum = scancode_mode2_extended[c];

			/* ignore unrecognised codes */
			if (!keynum)
			{
				state->modifiers &= ~MODIFIER_RELEASE;
				return 0;
			}

			/* is this an extended code? */
			if (state->modifiers & MODIFIER_EXTENDED)
			{
				keycode = keymap_uk2[keynum].ext_nomods;
				extflag = 0;
				state->modifiers &= ~MODIFIER_EXTENDED;
				if (!keycode)
				{
					state->modifiers &= ~MODIFIER_RELEASE;
					return 0;
				}
			}
			else if (state->modifiers & MODIFIER_EXTENDED2)
			{
				keycode = keymap_uk2[keynum].ext_nomods;
				extflag = 0;
				state->modifiers &= ~MODIFIER_EXTENDED2;
				if (!keycode)
				{
					state->modifiers &= ~MODIFIER_RELEASE;
					return 0;
				}
			}
			else
			{
				keycode = keymap_uk2[keynum].nomods;
				if (!keycode)
				{
					state->modifiers &= ~MODIFIER_RELEASE;
					return 0;
				}
			}

			/* handle shift */
			if (state->modifiers & MODIFIER_CAPSLK)
			{
				if (keycode >= 'a' && keycode <= 'z')
				{
					if (!(state->modifiers & MODIFIER_SHIFT))
					{
						shkeycode = !extflag ? keymap_uk2[keynum].ext_shift : keymap_uk2[keynum].shift;
						if (shkeycode)
							keycode = shkeycode;
					}
				}
				else
				{
					if (state->modifiers & MODIFIER_SHIFT)
					{
						shkeycode = !extflag ? keymap_uk2[keynum].ext_shift : keymap_uk2[keynum].shift;
						if (shkeycode)
							keycode = shkeycode;
					}
				}
			}
			else
			{
				if (state->modifiers & MODIFIER_SHIFT)
				{
					shkeycode = extflag ? keymap_uk2[keynum].ext_shift : keymap_uk2[keynum].shift;
					if (shkeycode)
						keycode = shkeycode;
				}
			}

			/* handle the numeric keypad */
			if (keycode & MODIFIER_NUMLK)
			{
				keycode &= ~MODIFIER_NUMLK;

				if (state->modifiers & MODIFIER_NUMLK)
				{
					if (!(state->modifiers & MODIFIER_SHIFT))
					{
						switch (keycode)
						{
							case KEYCODE_HOME:
								keycode = '7';
								break;
							case KEYCODE_UP:
								keycode = '8';
								break;
							case KEYCODE_PAGEUP:
								keycode = '9';
								break;
							case KEYCODE_LEFT:
								keycode = '4';
								break;
							case KEYCODE_CENTER:
								keycode = '5';
								break;
							case KEYCODE_RIGHT:
								keycode = '6';
								break;
							case KEYCODE_END:
								keycode = '1';
								break;
							case KEYCODE_DOWN:
								keycode = '2';
								break;
							case KEYCODE_PAGEDN:
								keycode = '3';
								break;
							case KEYCODE_INSERT:
								keycode = '0';
								break;
							case KEYCODE_DELETE:
								keycode = '.';
								break;
						}
					}
					else
						modmask = ~MODIFIER_SHIFT;
				}
			}

			/* modifier keys */
			switch (keycode)
			{
				case KEYCODE_LSHIFT:
					if (state->modifiers & MODIFIER_RELEASE)
						state->modifiers &= ~(MODIFIER_LSHIFT | MODIFIER_RELEASE);
					else
						state->modifiers |= MODIFIER_LSHIFT;
					return 0;

				case KEYCODE_RSHIFT:
					if (state->modifiers & MODIFIER_RELEASE)
						state->modifiers &= ~(MODIFIER_RSHIFT | MODIFIER_RELEASE);
					else
						state->modifiers |= MODIFIER_RSHIFT;
					return 0;

				case KEYCODE_LCTRL:
					if (state->modifiers & MODIFIER_RELEASE)
						state->modifiers &= ~(MODIFIER_LCTRL | MODIFIER_RELEASE);
					else
						state->modifiers |= MODIFIER_LCTRL;
					return 0;

				case KEYCODE_RCTRL:
					if (state->modifiers & MODIFIER_RELEASE)
						state->modifiers &= ~(MODIFIER_RCTRL | MODIFIER_RELEASE);
					else
						state->modifiers |= MODIFIER_RCTRL;
					return 0;

				case KEYCODE_ALT:
					if (state->modifiers & MODIFIER_RELEASE)
						state->modifiers &= ~(MODIFIER_ALT | MODIFIER_RELEASE);
					else
						state->modifiers |= MODIFIER_ALT;
					return 0;

				case KEYCODE_ALTGR:
					if (state->modifiers & MODIFIER_RELEASE)
						state->modifiers &= ~(MODIFIER_ALTGR | MODIFIER_RELEASE);
					else
						state->modifiers |= MODIFIER_ALTGR;
					return 0;

				case KEYCODE_CAPSLK:
					if (state->modifiers & MODIFIER_RELEASE)
						state->modifiers &= ~MODIFIER_RELEASE;
					else
					{
						state->modifiers ^= MODIFIER_CAPSLK;
						//__keyb_update_locks (state);
					}
					return 0;

				case KEYCODE_SCRLK:
					if (state->modifiers & MODIFIER_RELEASE)
						state->modifiers &= ~MODIFIER_RELEASE;
					else
					{
						state->modifiers ^= MODIFIER_SCRLK;
						//__keyb_update_locks (state);
					}
					return 0;

				case KEYCODE_NUMLK:
					if (state->modifiers & MODIFIER_RELEASE)
						state->modifiers &= ~MODIFIER_RELEASE;
					else
					{
						state->modifiers ^= MODIFIER_NUMLK;
						//__keyb_update_locks (state);
					}
					return 0;
			}

			if (state->modifiers & MODIFIER_RELEASE)
			{
				/* clear release condition */
				state->modifiers &= ~MODIFIER_RELEASE;
			}
			else
			{
				/* write code into the buffer */
				return keycode;
			}
			return 0;
		}

	return 0;
}
#endif

/*
 * Simple logic to interpret keyboard keys and shift keys
 * TODO: Add support for all the modifier keys
 *
 * Keyevents work in 3 phase manner, if you press 'A':
 * 1. scan code for 'A' is generated
 * 2. Key release event i.e KYBD_DATA_KEYUP
 * 3. scan code for 'A' again is generated
 */
char kmi_keyboard_read(unsigned long base, struct keyboard_state *state)
{
	int keynum, keycode = 0;

	/* Read Keyboard RX buffer */
	unsigned char data = kmi_data_read(base);

	/* if a key up occurred (key released) occured */
	if (data == KYBD_DATA_KEYUP) {
		state->keyup = 1;
		return 0;
	}
	else if (state->keyup){
		state->keyup = 0;

		/* Check if shift was lifted */
		if ((data == KYBD_DATA_SHIFTL) || (data == KYBD_DATA_SHIFTR)) {
			state->shift = 0;
		}
		else {
			/*	Find key number */
			keynum = scancode_mode2_extended[data];
			if(state->shift)
				keycode = keymap_uk2[keynum].shift;
			else
				keycode = keymap_uk2[keynum].nomods;

		}

	}
	else if ((data == KYBD_DATA_SHIFTL) || (data == KYBD_DATA_SHIFTR)) {
		state->shift = 1;
	}

	return (unsigned char)keycode;
}

void kmi_keyboard_init(unsigned long base, unsigned int div)
{
	/* STOP KMI */
	*(volatile unsigned long *)(base + PL050_KMICR) = 0x0;

	/*
	 * For versatile, KMI refernce clock = 24MHz
	 * KMI manual says we need 8MHz clock,
	 * so divide by 3
	 */
	*(volatile unsigned long *)(base + PL050_KMICLKDIV) = div;

	/* Enable KMI and TX/RX interrupts */
	*(volatile unsigned long *)(base + PL050_KMICR) =
						KMI_RXINTR | KMI_EN;

	/* Reset and wait for reset to complete */
	*(volatile unsigned long *)(base + PL050_KMIDATA) =
						KYBD_DATA_RESET;
	while(kmi_data_read(base) != KYBD_DATA_RTR);
}

void kmi_mouse_enable(unsigned long base)
{
	unsigned long *datareg = (unsigned long *)(base + PL050_KMIDATA);

	*datareg = MOUSE_DATA_ENABLE;

	/*sleep for sometime here */

	while (*datareg != MOUSE_DATA_ACK);
}

void kmi_mouse_init(unsigned long base, unsigned int div)
{
	int data[2];

	/* STOP KMI */
	*(volatile unsigned long *)(base + PL050_KMICR) = 0x0;

	/*
	 * For versatile, KMI refernce clock = 24MHz
	 * KMI manual says we need 8MHz clock,
	 * so divide by 3
	 */
	*(volatile unsigned long *)(base + PL050_KMICLKDIV) = div;

	/* Enable KMI and TX/RX interrupts */
	*(volatile unsigned long *)(base + PL050_KMICR) =
						KMI_RXINTR | KMI_EN;

	/* Reset and wait for reset to complete */
	*(volatile unsigned long *)(base + PL050_KMIDATA) =
						MOUSE_DATA_RESET;

	do {
		data[0] = kmi_data_read(base);
		/* Some sleep here */
		data[1] = kmi_data_read(base);
	}while((data[0] != MOUSE_DATA_ACK) && (data[1] != MOUSE_DATA_RTR));

	/* Set enable data code to mouse */
	kmi_mouse_enable(base);
}

