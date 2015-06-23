#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#include <stdio.h>
#include <stdint.h>

#define MAXBUFLEN 4096

int
main(int argc, char *argv[])
{
	struct stat st;
	uint32_t bootsize, datasize, data;
	uint8_t buffer[MAXBUFLEN];
	ssize_t numbytes;
	int fd, fd_boot, fd_data;

	if (argc < 4)
		errx(1, "usage: %s bootprogram datacontents outfile", argv[0]);
	
	fd = open(argv[3], O_WRONLY | O_CREAT, 0644);
	if (fd < 0)
		err(1, "open %s", argv[3]);
	fd_boot = open(argv[1], O_RDONLY);
	if (fd_boot < 0)
		err(1, "open %s", argv[1]);
	fd_data = open(argv[2], O_RDONLY);
	if (fd_data < 0)
		err(1, "open %s", argv[2]);
	/* Get sizes. */
	if (fstat(fd_boot, &st) < 0)
		err(1, "fstat");
	bootsize = htonl(st.st_size);
	if (fstat(fd_data, &st) < 0)
		err(1, "fstat");
	datasize = htonl(st.st_size);
	/* Write bootsize and datasize. */
	if (write(fd, &bootsize, sizeof(bootsize)) < 0)
		err(1, "write");
	if (write(fd, &datasize, sizeof(datasize)) < 0)
		err(1, "write");

	/* Read data and write to sd. */
	while ((numbytes = read(fd_boot, buffer, MAXBUFLEN)) > 0) {
		if (write(fd, buffer, numbytes) < 0)
			err(1, "write");
	}
	while ((numbytes = read(fd_data, buffer, MAXBUFLEN)) > 0) {
		if (write(fd, buffer, numbytes) < 0)
			err(1, "write");
	}
	return (0);
}
