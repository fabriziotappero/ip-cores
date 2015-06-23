#include "piezo.h"

void Piezo_set(uint32_t count, int enable)
{
	volatile uint32_t *Piezo = (volatile uint32_t *)PIEZO_ADDRESS;

	if (enable) {
		*Piezo = count | 0x1000000;
	}
	else {
		*Piezo = count & ~0x1000000;
	}
}

void Piezo_play(uint32_t note)
{
	Piezo_set(note, 1);
}

