
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <sys/syscall.h>
#include <dirent.h>
#include <l4lib/os/posix/readdir.h>
#include <tests.h>

#define DENTS_TOTAL	50

void print_fsize(struct stat *s)
{
	printf("%lu", s->st_size);
}

void print_flink(struct stat *s)
{
	printf("%d", s->st_nlink);
}

void print_fuser(struct stat *s)
{
	printf("%d", s->st_uid);
	printf("%c", ' ');
	printf("%c", ' ');
	printf("%d", s->st_gid);
}

void print_ftype(struct stat *s)
{
	unsigned int type = s->st_mode & S_IFMT;

	if (type == S_IFDIR)
		printf("%c", 'd');
	else if (type == S_IFSOCK)
		printf("%c", 's');
	else if (type == S_IFCHR)
		printf("%c", 'c');
	else if (type == S_IFLNK)
		printf("%c", 'l');
	else if (type == S_IFREG)
		printf("%c", '-');
}

void print_fperm(struct stat *s)
{
	if (s->st_mode & S_IRUSR)
		printf("%c", 'r');
	else
		printf("%c", '-');
	if (s->st_mode & S_IWUSR)
		printf("%c", 'w');
	else
		printf("%c", '-');
	if (s->st_mode & S_IXUSR)
		printf("%c", 'x');
	else
		printf("%c", '-');
}

void print_fstat(struct stat *s)
{
	print_ftype(s);
	print_fperm(s);
	printf("%c", ' ');
	printf("%c", ' ');
	print_fsize(s);
	printf("%c", ' ');
}

void print_dirents(char *path, void *buf, int cnt)
{
	int i = 0;
	struct dirent *dp = buf;
	// struct stat statbuf;
	char pathbuf[256];

	strncpy(pathbuf, path, 256);
	while (cnt > 0) {
		strcpy(pathbuf, path);
		strcpy(&pathbuf[strlen(pathbuf)],"/");
		strcpy(&pathbuf[strlen(pathbuf)],dp->d_name);
		//printf("Dirent %d:\n", i);
		//printf("Inode: %d\n", dp->d_ino);
		//printf("Offset: %d\n", dp->d_off);
		//printf("Reclen: %d\n", dp->d_reclen);
		//if (stat(pathbuf, &statbuf) < 0)
		//	perror("STAT");
		// print_fstat(&statbuf);
		test_printf("%s\n", dp->d_name);
		cnt -= dp->d_reclen;
		dp = (struct dirent *)((void *)dp + dp->d_reclen);
		i++;
	}
}

int lsdir(char *path)
{
	struct dirent dents[DENTS_TOTAL];
	int bytes;
	int fd;

	memset(dents, 0, sizeof(struct dirent) * DENTS_TOTAL);

	if ((fd = open(path, O_RDONLY)) < 0) {
		test_printf("OPEN failed.\n");
		return -1;
	} else
		test_printf("Got fd: %d for opening %s\n", fd, path);

	if ((bytes = os_readdir(fd, dents, sizeof(struct dirent) * DENTS_TOTAL)) < 0) {
		test_printf("GETDENTS error: %d\n", bytes);
		return -1;
	} else {
		print_dirents(path, dents, bytes);
	}

	return 0;
}

int dirtest(void)
{
	if (lsdir(".") < 0) {
		test_printf("lsdir failed.\n");
		goto out_err;
	}
	if (lsdir("/") < 0) {
		test_printf("lsdir failed.\n");
		goto out_err;
	}

	test_printf("\nCreating directories: usr, etc, tmp, var, home, opt, bin, boot, lib, dev\n");
	if (mkdir("/usr", 0) < 0) {
		test_printf("MKDIR: %d\n", errno);
		goto out_err;
	}
	if (mkdir("/etc", 0) < 0) {
		test_printf("MKDIR: %d\n", errno);
		goto out_err;
	}
	if (mkdir("/tmp", 0) < 0) {
		test_printf("MKDIR: %d\n", errno);
		goto out_err;
	}
	if (mkdir("/var", 0) < 0) {
		test_printf("MKDIR: %d\n", errno);
		goto out_err;
	}
	if (mkdir("/bin", 0) < 0) {
		test_printf("MKDIR: %d\n", errno);
		goto out_err;
	}
	if (mkdir("/boot", 0) < 0) {
		test_printf("MKDIR: %d\n", errno);
		goto out_err;
	}
	if (mkdir("/lib", 0) < 0) {
		test_printf("MKDIR: %d\n", errno);
		goto out_err;
	}
	if (mkdir("/dev", 0) < 0) {
		test_printf("MKDIR: %d\n", errno);
		goto out_err;
	}
	if (mkdir("/usr/bin", 0) < 0) {
		test_printf("MKDIR: %d\n", errno);
		goto out_err;
	}
	if (mkdir("/home/", 0) < 0) {
		test_printf("MKDIR: %d\n", errno);
		goto out_err;
	}
	if (mkdir("/home/bahadir", 0) < 0) {
		test_printf("MKDIR: %d\n", errno);
		goto out_err;
	}
	if (chdir("/home/bahadir") < 0) {
		test_printf("MKDIR: %d\n", errno);
		goto out_err;
	}
	test_printf("Changed curdir to /home/bahadir\n");

	test_printf("\nlsdir root directory:\n");
	if (lsdir("/") < 0)
		goto out_err;

	test_printf("\nlsdir /usr:\n");
	if (lsdir("/usr") < 0)
		goto out_err;

	test_printf("\nlsdir current directory:\n");
	if (lsdir(".") < 0)
		goto out_err;
	test_printf("\nlsdir /usr/./././bin//\n");
	if (lsdir("/usr/./././bin//") < 0)
		goto out_err;

	printf("DIR TEST            -- PASSED --\n");
	return 0;

out_err:
	printf("DIR TEST            -- FAILED --\n");
	return 0;
}

