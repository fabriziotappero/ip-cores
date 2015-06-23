#ifndef _OBJECT_H_
#define _OBJECT_H_

#include "types.h"

#define TYPE_NONE	0x0
#define TYPE_INT	0x1
#define TYPE_FLOAT	0x3
#define TYPE_CONS	0x4
#define TYPE_SNOC	0x5
#define TYPE_PTR	0x6
#define TYPE_ARRAY	0x7
#define TYPE_NIL	0x8
#define TYPE_T		0x9
#define TYPE_CHAR	0xA
#define TYPE_SYMBOL	0xB
#define TYPE_FUNCTION	0xC
#define TYPE_BUILTIN    0xD

// size and position of the parts of an object
#define OBJECT_DATUM_OFFSET 0
#define OBJECT_DATUM_MASK 0x3FFFFFF
#define OBJECT_TYPE_OFFSET 27
#define OBJECT_TYPE_MASK 0x1F
#define OBJECT_GC_OFFSET 26
#define OBJECT_GC_MASK 0x1


#define OBJECT_NEW(type, datum) \
	((((type)&OBJECT_TYPE_MASK) << OBJECT_TYPE_OFFSET) | ((datum)&OBJECT_DATUM_MASK))
#define OBJECT_DATUM(obj) ((obj) & OBJECT_DATUM_MASK)
#define OBJECT_TYPE(obj) (((obj)>>OBJECT_TYPE_OFFSET) & OBJECT_TYPE_MASK)
#define OBJECT_GC(obj) (((obj)>>OBJECT_GC_OFFSET)&OBJECT_GC_MASK)

void object_dump(reg_t object);

reg_t object_get_type(reg_t object);
reg_t object_set_type(reg_t object, uint8_t type);
reg_t object_get_datum(reg_t object);
reg_t object_get_datum_signed(reg_t object);
reg_t object_set_datum(reg_t object, uint32_t datum);
reg_t object_get_gc(reg_t object);
reg_t object_set_gc(reg_t object, uint32_t gc);

reg_t object_make(uint8_t type, uint32_t datum);

int object_read(reg_t *objects, int length, FILE *f);
int object_write(reg_t *objects, int length, FILE *f);

#endif /* _OBJECT_H_ */
