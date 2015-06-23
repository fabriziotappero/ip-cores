/* $Id: boot.c,v 1.1.1.1 2006-02-04 03:35:00 freza Exp $ */

#include <sys/mman.h>

#include <errno.h>
#include <fcntl.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>


extern int mcsdecode(FILE *, u_int8_t **, size_t *);

static int 		verbose = 0;
static int 		is_ftp = 0;

#define VERBOSE(arg) 	if (verbose) warnx arg
#define TRACE(arg) 	if (verbose > 1) warnx arg


void
warnx(char *fmt, ...)
{
	va_list 		ap;

	if (is_ftp)
		fprintf(stdout, "150-");
	fprintf(stdout, "boot: ");
	va_start(ap, fmt);
	vfprintf(stdout, fmt, ap);
	va_end(ap);
	fprintf(stdout, "\r\n");
}

void
errx(int ret, char *fmt, ...)
{
	va_list 		ap;

	if (is_ftp)
		fprintf(stdout, "510-");
	fprintf(stderr, "boot: ");
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

	if (is_ftp)
		fprintf(stdout, "510-");
	fprintf(stderr, "boot: ");
	va_start(ap, fmt);
	vfprintf(stderr, fmt, ap);
	va_end(ap);
	fprintf(stderr, ": %s\n", strerror(errno));

	exit(ret);
}

/*
 * Main and stuff.
 */
#define ARGUMENTS 	"d:hp:v"

void
usage()
{
	printf("Usage: boot [options] [file.mcs]\n");
	printf("-d s   Use device 's' [/dev/virtex0]\n");
	printf("-h     Print this help\n");
	printf("-p b   Don't boot, set PROG to 'b' (1 or 0)\n");
	printf("-v     Verbose operation\n");
}

int
main(int argc, char *argv[])
{
	FILE 			*file;
	u_int8_t 		*data;
	char 			*path, *device, *str;
	size_t 			count;
	int 			fd, progval;
	int 			c, do_setprog, do_raw_boot;

	do_raw_boot = 0; 	/* via kernel by default */
	do_setprog = 0; 	/* boot by default */
	is_ftp = 0;
	progval = 0; 		/* gcc */
	device = "/dev/virtex0";
	path = NULL;

	if ((str = getenv("FTP_METHOD")) != NULL) {
		if (strcasecmp(str, "PUT") == 0) {
			is_ftp = 1;
		} else {
			errx(1, "FTP method %s, only PUT supported", str);
		}
	}

	while((c = getopt(argc, argv, ARGUMENTS)) != -1) {
		switch (c) {
		case 'd': 		/* Select device 	*/
			device = optarg;
			break;

		case 'h': 		/* Show help 		*/
			usage();
			return 0;

		case 'p':
			do_setprog = 1;
			switch (optarg[0]) {
			case '0':
				progval = 0;
				break;
			case '1':
				progval = 1;
				break;
			default:
				errx(1, "Argument to -p should be 0 or 1");
				/*UNREACHED*/
			}
			break;

		case 'v': 		/* Verbose operation 	*/
			verbose++;
			break;

		default:
			errx(1, "unknown argument -%c", optopt);
		}
	}

	argc -= optind;
	argv += optind;

	if (argc > (do_setprog ? 0 : 1))
		errx(1, "stray arguments");

	/* We're going to boot, so read the design. */
	if (do_setprog == 0) {
		if (argc == 1)
			path = argv[0];

		if (path != NULL) {
			VERBOSE(("open design file %s", path));
			file = fopen(path, "r");
			if (file == NULL)
				err(1, "could not open %s", path);
		} else {
			/* NOTE: vftpd is broken in that it will blocking
			 *     copy statfd (fd 3) to the user until the end,
			 *     then it will transfer the file, and in the
			 *     end copy messages again. So we have to close
			 *     statfd so that we can proceed reading stdin.
			 */
			if (is_ftp) {
				write(3, "150-boot: design file is stdin\r\n",
				    32);
				(void) close(3);
			} else {
				VERBOSE(("design file is stdin"));
			}

			file = stdin;
		}

		if (mcsdecode(file, &data, &count) != 0)
			errx(1, "could not decode %s", path);
		VERBOSE(("decoded %d bytes", count));
	} else {
		/* XXX: Control PROG from kernel */
		return (1);
	}

	/* Let's do the well behaved boot then. */
	VERBOSE(("open device"));
	fd = open(device, O_RDWR, 0);
	if (fd == -1)
		err(1, "could not open %s", device);

	VERBOSE(("write configuration stream"));
	if (write(fd, (const void *) data, count) != count)
		err(1, "failed to boot%s", \
		    errno == EIO ? ": CRC error" : "");

	VERBOSE(("acknowledge startup"));
	if (close(fd) == -1)
		err(1, "failed to boot%s", \
		    errno == EIO ? ": DONE timeout" : "");

	VERBOSE(("success"));
	return (0);
}
