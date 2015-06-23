#ifndef GENDC_H
#define GENDC_H

typedef struct _cache_tags {
  unsigned int tag;
  unsigned int dirty;
  unsigned int valid;
  unsigned int lock;
} cache_tags;

typedef struct _data_cache {
  int sz_set,nr_sets,sz_tline,sz_set_log,sz_tline_log;
  unsigned int addrmask,tlinemask;
  unsigned char *sets[4];
  cache_tags    *tags[4];
  unsigned int setrepcnt;
  unsigned int writeback;
  unsigned int allocateonstore;
} data_cache;

/* in gendc.c */
data_cache *gendc_create(int size_kb, int nr_sets, int size_tline);
int gendc_read(data_cache *c,unsigned int addr,unsigned int *data);
int gendc_write(data_cache *c,unsigned int addr,unsigned int data);


#endif

