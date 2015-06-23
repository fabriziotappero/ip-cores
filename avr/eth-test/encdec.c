#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include "encdec.h"
#include "device.h"

/* Decode an object, returning the data and setting the size. */
uint32_t
decode_object(uint32_t data, uint32_t devnum, uint8_t *osize)
{
	uint32_t retval;
	
	*osize = DATA_SIZE_TYPE(DATA_TYPE_DEV(devnum));
	retval = DATA_TYPE_DEV(devnum) == TYPE_NONE ? data :
	    OBJECT_DATUM(data);
	return (retval);
}

/* Encode an object, returning the data. */
uint32_t
encode_object(uint32_t data, uint32_t devnum)
{
	uint32_t retval;
	uint8_t otype;

	otype = DATA_TYPE_DEV(devnum);
	retval = (otype == TYPE_NONE) ? data : OBJECT_NEW(otype, data);
	return (retval);
}
