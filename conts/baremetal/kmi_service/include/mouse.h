/*
 * Mouse details.
 */
#ifndef __MOUSE_H__
#define	__MOUSE_H__

/*
 * Keyboard structure
 */
struct mouse {
	unsigned long base;	/* Virtual base address */
	struct capability cap;  /* Capability describing keyboard */
};

#endif /* __MOUSE_H__ */
