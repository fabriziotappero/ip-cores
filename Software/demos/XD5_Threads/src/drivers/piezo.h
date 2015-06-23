#ifndef __PIEZO_H__
#define __PIEZO_H__

#include <stdint.h>

#define PIEZO_ADDRESS 0xA0000000

/* Following are defined for a 100 MHz Piezo driver */
#define C0	3058104
#define C1	1529052

#define C4	191110
#define C4s	180388
#define D4f	C4s
#define D4	170264
#define D4s	160705
#define E4f	D4s
#define E4	151685
#define F4	143172
#define F4s	135138
#define G4f	F4s
#define G4	127551
#define G4s	120395
#define A4f	G4s
#define A4	113636
#define A4s	107259
#define B4f	A4s
#define B4	101239
#define C5	95557
#define C5s	90192
#define D5f	C5s
#define D5	85131
#define D5s	80354
#define E5f	D5s
#define E5      75843

#define C8	11945


void Piezo_set(uint32_t count, int enable);
void Piezo_play(uint32_t note);

#endif
