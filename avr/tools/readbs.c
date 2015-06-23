#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#include <stdio.h>
#include <stdint.h>


int
main(int argc, char *argv[])
{
	uint32_t data;
	int fd;

	if (argc < 2)
		errx(1, "usage: %s fil", argv[0]);
	
	fd = open(argv[1], O_RDONLY);
	if (fd < 0)
		err(1, "open");
	read(fd, &data, sizeof(data));
	printf("Boot segment size: %d\n", ntohl(data));
	read(fd, &data, sizeof(data));
	printf("Data segment size: %d\n", ntohl(data));
	return (0);
}
