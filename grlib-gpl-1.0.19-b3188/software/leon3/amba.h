
#define NAHBSLV 16
#define NAHPSLV 16

#define PPIDMASK  0xFFFFF000
#define PPIRQMASK 0x1F
#define PPAHBMASK  0xFFF00000

struct ahbpp_type {
   unsigned int cfg[4];
   unsigned int mem[4];
};

struct apbpp_type {
   unsigned int cfg;
   unsigned int mem;
};

struct ambadev {
   unsigned int id;
   unsigned int irq;
   unsigned int ppstart;
   unsigned int start[4];
   unsigned int end[4];
};
   
