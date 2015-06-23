#include <stdio.h>
#include <stdint.h>

extern int __fputc(int c, FILE *stream);

static int ser_out(int c)
{
	__fputc(c, 0);
	if (c == '\n')
		ser_out('\r');
	return 0;
}

static size_t
l4kdb_write(void *data, long int position, size_t count, void *handle /*unused*/)
{
	size_t i;
	char *real_data = data;
	for (i = 0; i < count; i++)
		ser_out(real_data[i]);
	return count;
}

struct __file __stdin = {
	.handle	    = NULL,
	.read_fn    = NULL,
	.write_fn   = NULL,
	.close_fn   = NULL,
	.eof_fn	    = NULL,
	.buffering_mode = _IONBF,
	.buffer	    = NULL,
	.unget_pos  = 0,
	.current_pos = 0,
	.eof	    = 0
};


struct __file __stdout = {
	.handle	    = NULL,
	.read_fn    = NULL,
	.write_fn   = l4kdb_write,
	.close_fn   = NULL,
	.eof_fn	    = NULL,
	.buffering_mode = _IONBF,
	.buffer	    = NULL,
	.unget_pos  = 0,
	.current_pos = 0,
	.eof	    = 0
};


struct __file __stderr = {
	.handle	    = NULL,
	.read_fn    = NULL,
	.write_fn   = l4kdb_write,
	.close_fn   = NULL,
	.eof_fn	    = NULL,
	.buffering_mode = _IONBF,
	.buffer	    = NULL,
	.unget_pos  = 0,
	.current_pos = 0,
	.eof	    = 0
};

FILE *stdin = &__stdin;
FILE *stdout = &__stdout;
FILE *stderr = &__stderr;
