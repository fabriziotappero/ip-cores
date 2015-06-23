/**
 ** timestamp APU HW under Linux
 **/

#include <inttypes.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>

/******/
/* ex xpseudo_asm_gcc.h: */
#define UDI0FCM_IMM_GPR_GPR(a, b, c)                    \
  __asm__ __volatile__("udi0fcm " #a ",%0,%1" : : "r"(b), "r"(c))
/******/

#define UDI_TSTAMP(id) __asm__ __volatile__("udi0fcm 0,%0,%0" : : "r"(id))

void *map_bram(uint32_t addr, uint32_t len) {
  int fd;
  unsigned long page_size;
  void *mem;

  if ((fd = open("/dev/mem", O_RDWR|O_SYNC)) < 0) {
    perror("open /dev/mem");
    return NULL;
  }

  page_size = getpagesize();
  mem = mmap(NULL, len, PROT_WRITE|PROT_READ,
	     MAP_SHARED, fd, addr & ~(page_size-1));
  mem += addr & (page_size-1);

  return mem;
}

int main() {
  uint32_t *bram = map_bram(0xcc000000, 0x1000);
  char c;
  int a, b, i;

  for (i = 0; i < 0x400; i++)
    bram[i] = 0;

  printf("Go!\r\n");
  for (;;) {
    c = getchar();
    UDI_TSTAMP(1);
    UDI_TSTAMP(0xdeadbeef);

    for (i = 0; i < 0x400; i += 2)
      if (bram[i] != 0)
	printf("%02x: (0x%08x) 0x%08x\r\n", i/2, bram[i], bram[i+1]);

    printf("--\r\n");
  }

  return 0;
}
