#ifndef __L4LIB_ARCH_IRQ_H__
#define __L4LIB_ARCH_IRQ_H__

/*
 * Destructive atomic-read.
 *
 * Write 0 to byte at @location as its contents are read back.
 */
char l4_atomic_dest_readb(void *location);

#endif
