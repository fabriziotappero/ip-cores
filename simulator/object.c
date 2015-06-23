#include <stdio.h>
#include <err.h>

#include "object.h"
#include "debug.h"
#include "bits.h"

void
object_dump(reg_t object)
{
	struct di_const *c;
	char *type;

	c = debug_get1_filter(OBJECT_TYPE(object), "type");
	if (c == NULL)
		type = "unknown";
	else
		type = c->name;

	printf("Object %s: 0x%x, gc bit: %d\n", type, OBJECT_DATUM(object), OBJECT_GC(object));
	puts("datum");
	debug_show(OBJECT_DATUM(object));
}

reg_t
object_set_field(reg_t object, uint32_t value, uint32_t offset, uint32_t mask)
{
	object &= ~(mask<<offset);
	object |= (value&mask)<<offset;
	return object;
}

reg_t
object_get_type(reg_t object)
{
	return OBJECT_TYPE(object);
}

reg_t
object_set_type(reg_t object, uint8_t type)
{
	return object_set_field(object, type,
				OBJECT_TYPE_OFFSET,
				OBJECT_TYPE_MASK);
}

reg_t
object_get_datum(reg_t object)
{
	return OBJECT_DATUM(object);
}

reg_t
object_get_datum_signed(reg_t object)
{
	return sign_extend(OBJECT_DATUM(object), 26);
}

reg_t
object_set_datum(reg_t object, uint32_t datum)
{
	return object_set_field(object, datum,
				OBJECT_DATUM_OFFSET,
				OBJECT_DATUM_MASK);
}

reg_t
object_get_gc(reg_t object)
{
	return OBJECT_GC(object);
}

reg_t
object_set_gc(reg_t object, uint32_t gc)
{
	return object_set_field(object, gc,
				OBJECT_GC_OFFSET,
				OBJECT_GC_MASK);
}


reg_t
object_make(uint8_t type, uint32_t datum)
{
	reg_t obj = 0;
	obj = object_set_type(obj, type);
	obj = object_set_datum(obj, datum);
	return obj;
}


void
object_serialize(reg_t obj, uint8_t *buf)
{
	buf[0] = (obj>>24) & 0xFF;
	buf[1] = (obj>>16) & 0xFF;
	buf[2] = (obj>>8)  & 0xFF;
	buf[3] =  obj      & 0xFF;
}

reg_t
object_deserialize(uint8_t *buf)
{
	return (buf[0]<<24) | (buf[1]<<16) | (buf[2]<<8) | buf[3];
}

int
object_read(reg_t *objects, int length, FILE *f)
{
	uint8_t buf[4];
	int i;
	for (i = 0; i < length; i++) {
		if (fread(buf, 4, 1, f) != 1) {
			warn("Read failed");
			return i;
		}
		objects[i] = object_deserialize(buf);
	}
	return length;
}

int
object_write(reg_t *objects, int length, FILE *f)
{
	uint8_t buf[4];
	int i;
	for (i = 0; i < length; i++) {
		object_serialize(objects[i], buf);
		if (fwrite(buf, 4, 1, f) != 1)
			return i;
	}
	return length;
}
