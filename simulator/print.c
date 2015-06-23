#include <stdio.h>
#include <inttypes.h>

#include "print.h"
#include "object.h"
#include "regs.h"
#include "memory.h"

uint8_t currently_printing[MEMORY_ADDRESS_SPACE_SIZE];

void
print_init(void)
{
	int i;
	for (i = 0; i < DEFAULT_MEMORY_SIZE; i++)
		currently_printing[i] = 0;
}

void
print_list(uint32_t addr, int first)
{
	reg_t val = memory_get(addr);
	int32_t datum = object_get_datum(val);
	uint32_t type = object_get_type(val);

	if (type == TYPE_CONS) {
		reg_t cdr = memory_get(addr+1);
		if (object_get_type(cdr) != TYPE_SNOC) {
			printf("#(0x%X:malformed cons cell: second part has type 0x%X)",
			       addr, object_get_type(cdr));
			return;
		}
		printf(first ? "(" : " ");
		print(datum);
		print_list(object_get_datum(cdr), 0);
	} else if (type == TYPE_NIL) {
		printf(")");
	} else {
		printf(" . ");
		print(addr);
		printf(")");
	}
}

void
print_array(uint32_t addr)
{
	reg_t val = memory_get(addr);
	int i;
	int sz = object_get_datum(val);
	int str = 1;

	for (i = 0; i < sz; i++) {
		val = memory_get(addr+i+1);
		if (object_get_type(val) != TYPE_PTR) {
			printf("#(0x%X:malformed array)", addr);
			return;
		}
		val = memory_get(object_get_datum(val));
		if (object_get_type(val) != TYPE_CHAR) {
			str = 0;
			break;
		}
	}

	if (str) {
		printf("\"");
		for (i = 0; i < sz; i++) {
			val = memory_get(addr+i+1);
			val = memory_get(object_get_datum(val));
			printf("%c", object_get_datum(val));
		}
		printf("\"");
	} else {
		printf("#(0x%X:array(%d)", addr, sz);
		for (i = 0; i < sz; i++) {
			printf(" ");
			print(object_get_datum(memory_get(addr+i+1)));
		}
		printf(")");
	}
}

void
print_symbol(uint32_t addr)
{
	reg_t val = memory_get(addr);
	uint32_t arr_addr = object_get_datum(val);
	reg_t arr = memory_get(arr_addr);
	int sz = 0, i = 0;
	if (object_get_type(arr) != TYPE_ARRAY)
		goto print_symbol_err;
	sz = object_get_datum(arr);
	for (i = 1; i <= sz; i++) {
		val = memory_get(arr_addr+i);
		if (object_get_type(val) != TYPE_PTR)
			goto print_symbol_err;
		val = memory_get(object_get_datum(val));
		if (object_get_type(val) != TYPE_CHAR)
			goto print_symbol_err;
		printf("%c", object_get_datum(val));
	}

	return;
print_symbol_err:
	printf("#(0x%X:malformed symbol [%X,%X])", addr, sz, i);
}

void
print_function(uint32_t addr)
{
	reg_t val = memory_get(addr);
	int32_t datum = object_get_datum(val);

	printf("#(0x%X:func ", addr);
	print(object_get_datum(memory_get(datum)));
	printf(")");
	/*
	printf("#(0x%X:function ", addr);
	print(datum);
	printf(")");
	*/
}

void
print_builtin(uint32_t addr)
{
	reg_t val = memory_get(addr);
	int32_t datum = object_get_datum(val);

	printf("#(builtin ");
	print(datum);
	printf(")");
}

void
print(uint32_t addr)
{
	reg_t val = memory_get(addr);
	int32_t datum = object_get_datum(val);
	uint32_t type = object_get_type(val);

	if (currently_printing[addr]) {
		printf("#(R 0x%X:%X:%X)", addr, type, datum);
		return;
	}

	currently_printing[addr] = 1;

	switch (object_get_type(val)) {
	case TYPE_NONE:
		printf("#(0x%X:none)", addr);
		break;
	case TYPE_INT:
		printf("%d", datum);
		break;
	case TYPE_FLOAT:
		printf("%f", (float)datum);
		break;
	case TYPE_CONS:
		print_list(addr, 1);
		break;
	case TYPE_SNOC:
		printf("#(0x%X:snoc ", addr);
		print(datum);
		printf(")");
		break;
	case TYPE_PTR:
		printf("#(0x%X:ptr ", addr);
		print(datum);
		printf(")");
		break;
	case TYPE_ARRAY:
		print_array(addr);
		break;
	case TYPE_NIL:
		printf("nil");
		break;
	case TYPE_T:
		printf("t");
		break;
	case TYPE_CHAR:
		printf("#\\%c", datum);
		break;
	case TYPE_SYMBOL:
		print_symbol(addr);
		break;
	case TYPE_FUNCTION:
		print_function(addr);
		break;
	case TYPE_BUILTIN:
		print_builtin(addr);
		break;
	default:
		printf("#(0x%X:invalid object %X:%X)", addr, type, datum);
		break;
	}

	currently_printing[addr] = 0;
}

