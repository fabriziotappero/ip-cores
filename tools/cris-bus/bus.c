/* $Id: bus.c,v 1.1.1.1 2006-02-04 03:35:01 freza Exp $ */

#include <sys/mman.h>

#include <errno.h>
#include <fcntl.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <asm/page.h>


typedef int 			bus_space_tag_t;
typedef u_char 			*bus_space_handle_t;

#define bus_space_read_4(t, h, addr) \
	*((volatile u_int32_t *) ((h) + (addr)))

#define bus_space_write_4(t, h, addr, val) \
	(*((volatile u_int32_t *) ((h) + (addr))) = (u_int32_t)(val))

#define bus_space_read_2(t, h, addr) \
	*((volatile u_int16_t *) ((h) + (u_int16_t)(addr)))

#define bus_space_write_2(t, h, addr, val) \
	(*((volatile u_int16_t *) ((h) + (addr))) = (u_int16_t)(val))

#define bus_space_read_1(t, h, addr) \
	*((volatile u_int8_t *) ((h) + (addr)))

#define bus_space_write_1(t, h, addr, val) \
	(*((volatile u_int8_t *) ((h) + (addr))) = (u_int8_t)(val))

#define VERBOSE(arg) 	if (verbose) warnx arg

static int 		verbose = 0;


void
warnx(char *fmt, ...)
{
	va_list 		ap;

	fprintf(stderr, "bus: ");
	va_start(ap, fmt);
	vfprintf(stderr, fmt, ap);
	va_end(ap);
	fprintf(stderr, "\n");
}

void
errx(int ret, char *fmt, ...)
{
	va_list 		ap;

	fprintf(stderr, "bus: ");
	va_start(ap, fmt);
	vfprintf(stderr, fmt, ap);
	va_end(ap);
	fprintf(stderr, "\n");

	exit(ret);
}

void
err(int ret, char *fmt, ...)
{
	va_list 		ap;

	fprintf(stderr, "bus: ");
	va_start(ap, fmt);
	vfprintf(stderr, fmt, ap);
	va_end(ap);
	fprintf(stderr, ": %s\n", strerror(errno));

	exit(ret);
}


#include <stdlib.h>
#include <errno.h>

int
xstrtou(char *str, u_long *val)
{
	char                    *end;
	int 			base = 10;

	if (str[0] == '0')
		switch (str[1]) {
		case 'x':
			base = 16;
			str += 2;
			break;
		case 'd':
			base = 10;
			str += 2;
			break;
		case 'o':
			base = 8;
			str += 2;
			break;
		case 'b':
			base = 2;
			str += 2;
			break;
		default:
			return EINVAL;
		}

	*val = (u_long) strtoul(str, &end, base);
	if (*end != '\0' || str[0] == '\0')
		return EINVAL;

	return 0;
}

int
bus_space_tag(bus_space_tag_t *t)
{
	*t = open("/dev/mem", O_RDWR | O_SYNC, 0);
	if (*t == -1)
		return (errno);
	return 0;
}

#ifndef PAGE_ALIGN
#define PAGE_ALIGN(val) 	(((val) + PAGE_SIZE - 1) & PAGE_MASK)
#endif

int
bus_space_map(bus_space_tag_t t, u_int32_t base, u_int32_t size, int flags,
    bus_space_handle_t *h)
{
	off_t 			real;

	real = base & PAGE_MASK;
	size = PAGE_ALIGN(size);

	VERBOSE(("fd %d, mapping %dB at 0x%08x with offs 0x%08x",
	    t, size, real, base % PAGE_SIZE));

	*h = mmap(0, size, PROT_READ|PROT_WRITE, MAP_FILE|MAP_SHARED, t, real);
	if (*h == MAP_FAILED)
		return (errno);
	*h += base % PAGE_SIZE;

	return (0);
}

/*
 * Main and stuff.
 */
#define ARGUMENTS 	"a:b:c:f:hvw:"

void
usage()
{
	printf("Version: $Freza: bus.c,v 1.6 2005/11/22 12:57:25 jh Exp $\n");
	printf("Usage: bus [opts]\n");
	printf("-a x   Set bus address\n");
	printf("-b n   Set bus access width, one of 1, 2, 4 [4]\n");
	printf("-c n   How many values to process\n");
	printf("-f s   Copy data FROM hexa text file TO memory\n");
	printf("-h     Print this help\n");
	printf("-v     Verbose operation\n");
	printf("-w x   Write value x\n");
}

int
main(int argc, char *argv[])
{
	FILE 			*data;
	bus_space_handle_t 	ioh;
	bus_space_tag_t 	tag;
	u_int32_t 		addr;
	u_int32_t 		value;
	int 			do_write, has_addr;
	int 			count;
	int 			width;
	int 			i, c, ret;

	do_write 	= 0;
	has_addr 	= 0;
	count 		= -1;
	width 		= 4;
	data 		= NULL;

	while((c = getopt(argc, argv, ARGUMENTS)) != -1) {
		switch (c) {
		case 'a': 		/* Set address 		*/
			if (xstrtou(optarg, (u_long *) &addr) != 0)
				errx(1, "not a number: %s", optarg);
			has_addr = 1;
			break;

		case 'b': 		/* Set access width 	*/
			if (xstrtou(optarg, (u_long *) &width) != 0)
				errx(1, "not a number: %s", optarg);
			switch (width) {
				case 1:
				case 2:
				case 4:
					break;
				default:
					errx(1, "bad width: %d", width);
			}
			break;

		case 'c': 		/* Set value count 	*/
			if (xstrtou(optarg, (u_long *) &count) != 0)
				errx(1, "not a number: %s", optarg);
			break;

		case 'f': 		/* File to read from/write to */
			do_write = 1;
			if ((data = fopen(optarg, "r")) == NULL)
				err(1, "could not open %s", optarg);

			break;

		case 'h': 		/* Show help 		*/
			usage();
			return 0;

		case 'v': 		/* Verbose operation 	*/
			verbose = 1;
			break;

		case 'w': 		/* Value to write 	*/
			if (xstrtou(optarg, (u_long *) &value) != 0)
				errx(1, "not a number: %s", optarg);
			do_write = 1;
			break;

		default:
			errx(1, "unknown argument -%c", optopt);
		}
	}

	argc -= optind;
	argv += optind;

	/* Validate user isn't insane. */
	if (argc > 0)
		errx(1, "stray arguments");

	if (! has_addr)
		errx(1, "address is mandatory");

	/* Grab bus space. */
	if ((ret = bus_space_tag(&tag)) != 0)
		err(1, "could not access physical memory, error %d", ret);

	if (count == -1) {
		if (data != NULL)
			count = PAGE_SIZE / width;
		else
			count = 1;
	}

	if ((ret = bus_space_map(tag, addr, count * width, 0, &ioh)) != 0)
		err(1, "could not map bus space, error %d", ret);

	if (do_write) {
		for (i = 0; i < count; i++) {
			if (data != NULL) {
				if (fscanf(data, "%x", &value) != 1) {
					if (feof(data))
						break;
					else
					if (ferror(data))
						err(1, "file read error");
					else
						err(1, "invalid input");
				}
			}
			VERBOSE(("[%03d] 0x%08x <- 0x%08x", i,
			    addr + i * width, value));

			switch (width) {
			case 1:
				bus_space_write_1(tag, ioh, i * width, value);
				break;
			case 2:
				bus_space_write_2(tag, ioh, i * width, value);
				break;
			case 4:
				bus_space_write_4(tag, ioh, i * width, value);
				break;
			}
		}
	} else {
		for (i = 0; i < count; i++) {
			switch (width) {
			case 1:
				value = bus_space_read_1(tag, ioh, i * width);
				printf("%02x\n", value);
				break;
			case 2:
				value = bus_space_read_2(tag, ioh, i * width);
				printf("%04x\n", value);
				break;
			case 4:
				value = bus_space_read_4(tag, ioh, i * width);
				printf("%08x\n", value);
				break;
			}
		}
	}

	return (0);
}
