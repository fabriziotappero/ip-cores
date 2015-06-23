/*
 * Keyboard details.
 */
#ifndef __KEYBOARD_H__
#define	__KEYBOARD_H__

#include <libdev/kmi.h>

/*
 * Keyboard structure
 */
struct keyboard {
	unsigned long base;	/* Virtual base address */
	struct capability cap;  /* Capability describing keyboard */
	struct keyboard_state state;
};

#endif /* __KEYBOARD_H__ */
