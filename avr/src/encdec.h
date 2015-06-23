#ifndef _ENCDEC_H_
#define _ENCDEC_H_

#define swap32(x)			\
	((((x) & 0xff000000) >> 24) |	\
	(((x) & 0x00ff0000) >>  8) |	\
	(((x) & 0x0000ff00) <<  8) |	\
	(((x) & 0x000000ff) << 24))

uint32_t encode_object(uint32_t, uint32_t);
uint32_t decode_object(uint32_t, uint32_t, uint8_t *);

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
#define SIZE_INT	26
#define BSIZE_INT	(SIZE_INT + 2)
#define SIZE_CHAR	8
#define BSIZE_CHAR	(SIZE_CHAR + 2)

// size and position of the parts of an object
#define OBJECT_DATUM_OFFSET 0
#define OBJECT_DATUM_MASK 0x3FFFFFF
#define OBJECT_TYPE_OFFSET 27
#define OBJECT_TYPE_MASK 0x1F
#define OBJECT_GC_OFFSET 26 
#define OBJECT_GC_MASK 0x1


#define OBJECT_NEW(type, datum)						\
        ((((uint32_t)(type)&OBJECT_TYPE_MASK) << OBJECT_TYPE_OFFSET) |	\
	((datum)&OBJECT_DATUM_MASK))

#define OBJECT_TYPE(obj) \
	(((uint32_t)(obj)>>OBJECT_TYPE_OFFSET) & OBJECT_TYPE_MASK)
#define OBJECT_DATUM(obj) ((obj) & OBJECT_DATUM_MASK)
#define OBJECT_GC(obj) (((obj)>>OBJECT_GC_OFFSET)&OBJECT_GC_MASK)

#define DATA_SIZE_TYPE(type) ((type) == TYPE_CHAR) ? 1 : 4
// XXX: Change to DEVTYPE_BOOT || == DEVTYPE_STORAGE when we're ready
#define DATA_TYPE_DEV(dev) \
	(((dev) == DEVTYPE_BOOT) ? TYPE_NONE : TYPE_CHAR)
#endif /* _ENCDEC_H_ */
