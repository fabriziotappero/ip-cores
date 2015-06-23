#include <stdio.h>

int
fputc(int c, FILE *stream)
{
	unsigned char ch = (unsigned char) c;
	/* This is where we should do output buffering */

	lock_stream(stream);
	if (stream->write_fn(&ch, stream->current_pos, 1, stream->handle) == 1) {
		/* Success */
		stream->current_pos++;
		unlock_stream(stream);
		return c;
	} else {
		unlock_stream(stream);
		return EOF;
	}
}
