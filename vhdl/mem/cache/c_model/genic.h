#ifndef GENIC_H
#define GENIC_H

typedef struct _icache_tags {
  unsigned int tag;
  unsigned int valid;
  unsigned int lock;
} icache_tags;

typedef struct _icache_insn {
  unsigned int insn;
  void *decode;
} icache_insn;

typedef struct _data_cache {
  int sz_set,nr_sets,sz_tline,sz_set_log,sz_tline_log;
  unsigned int addrmask,tlinemask;
  icache_insn *sets[4];
  icache_tags  *tags[4];
  unsigned int setrepcnt;
} insn_cache;

/* in genic.c */
insn_cache *genic_create(int size_kb, int nr_sets, int size_tline);
int genic_read(insn_cache *c,unsigned int addr,icache_insn **data);

#endif

