#include <stdio.h>
#include <stdlib.h>
#include "buf.h"

int main()
{
	struct buf buf;
	int i, error;
	char data;

	buf_init(&buf);

	error = 0;
	i = 0;

	printf("Writing the buffer\n");
	for (i = 'A'; i < 'Z'; i++) {
		buf_write(&buf, (char *)&i, 1);
		if (BUF_FULL(&buf)) {
			printf("\nERROR WRITING\n");
			break;
		}
		printf("%c", i);
	}
	printf("\n");

	printf("Reads left: %d\n", buf_readsleft(&buf));
	printf("Writes left: %d\n", buf_writesleft(&buf));
	printf("Reading the buffer\n");
	while (1) {
		buf_read(&buf, &data, 1);
		if (BUF_EMPTY(&buf)) {
			printf("\nERROR READING\n");
			break;
		}
		printf("%c", data);
	}
	printf("\n");
	printf("Reads left: %d\n", buf_readsleft(&buf));
	printf("Writes left: %d\n", buf_writesleft(&buf));

	printf("Writing a little again\n");
	for (i = 'u'; i < ('u' + 4); i++) {
		buf_write(&buf, (char *)&i , 1);
		if (BUF_FULL(&buf)) {
			printf("\nERROR WRITING\n");
			break;
		}
		printf("%c", i);
	}
	printf("\n");
	printf("Reads left: %d\n", buf_readsleft(&buf));
	printf("Writes left: %d\n", buf_writesleft(&buf));
	printf("Reading the buffer\n");
	while (1) {
		buf_read(&buf, &data, 1);
		if (BUF_EMPTY(&buf)) {
			printf("\nERROR READING\n");
			break;
		}
		printf("%c", data);
	}
	printf("\n");
	printf("Reads left: %d\n", buf_readsleft(&buf));
	printf("Writes left: %d\n", buf_writesleft(&buf));
	printf("Done\n");
	return 0;
}
