#ifndef __ARM_V5_UTCB_H__
#define __ARM_V5_UTCB_H__

/*
 * Pointer to Kernel Interface Page's UTCB pointer offset.
 */
extern struct utcb **kip_utcb_ref;

static inline struct utcb *l4_get_utcb()
{
 	/*
	 * By double dereferencing, we get the private TLS
	 * (aka UTCB). First reference is to the KIP's utcb
	 * offset, second is to the utcb itself, to which
	 * the KIP's utcb reference had been updated during
	 * context switch.
	 */
	return *kip_utcb_ref;
}

#endif /* __ARM_V5_UTCB_H__ */
