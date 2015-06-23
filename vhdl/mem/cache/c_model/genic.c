#include <tmki.h>
#include "genic.h"

/* genic.vhd c model:
 * Currently supports:
 * - multiple sets
 * - tag, valid, lock bits
 */

insn_cache *genic_create(int size_kb, int nr_sets, int size_tline) {
  
  int i,j;
  insn_cache *c;
  int k,l1,l2;
  
  if (size_tline < 2)
    size_tline = 2;
  if (size_tline > 8)
    size_tline = 8;
  if (size_kb < 1)
    size_kb = 1;
  if (size_kb > 64)
    size_kb = 64;
  if (nr_sets < 1)
    nr_sets = 1;
  if (nr_sets > 4)
    nr_sets = 4;
  
  k = 1;
  l1 = 0;
  while (k < size_tline) {
    k = k << 1;
    l1++;
  }
  size_tline = k;
  
  c = (insn_cache *) ti_alloc(sizeof(insn_cache));
  if (!c) { return 0; }

  size_kb = 0x400 * size_kb;
  
  k = 1;
  l2 = 0;
  while (k < size_kb) {
    k = k << 1;
    l2++;
  }
  
  j = size_kb / (size_tline * 4);
  
  for (i = 0;i < nr_sets;i++) {
    c ->sets[i] = (icache_insn *)ti_alloc((size_kb/4) * sizeof(icache_insn));
    c ->tags[i] = (icache_tags *)ti_alloc(j * sizeof(icache_tags));
    if (!(c ->sets[i]&&c ->tags[i])) {
      for (i = 0;i < nr_sets;i++) {
	if (c ->sets[i]) { ti_free(c ->sets[i]); };
	if (c ->tags[i]) { ti_free(c ->tags[i]); };
      }
      ti_free(c); return 0;
    }
  }
  
  k = 0;
  for (i= 0;i<l2;i++) {
    k = k | (1 << i);
  }
  c ->addrmask = k;
  k = 0;
  for (i= 0;i<l1;i++) {
    k = k | (1 << i);
  }
  c ->tlinemask = k << 2;
  
  c ->sz_set = size_kb;
  c ->nr_sets = nr_sets;
  c ->sz_tline = size_tline;
  c ->sz_set_log = l2;
  c ->sz_tline_log = l1;
 
  ti_print_err("\
Create genic model (0x%x):\n\
sets   : %i\n\
setsz  : 0x%x (insns:%x, log:%i, msk:0x%x)\n\
linesz : %i (log:%i, msk:0x%x)\n\
nrlines: 0x%x\n",
c,c->nr_sets, 
c->sz_set, c->sz_set/4, c->sz_set_log, c ->addrmask,
c->sz_tline, c->sz_tline_log, c ->tlinemask,
	       j);
  
  return c;
}

#define amba_read(x,d) 1
#define decode_insn(x) 0
#define release_decode(x) 

icache_insn local_icache_insn;
int genic_read(insn_cache *c,unsigned int addr,icache_insn **data) {

  unsigned int i,ot,o,tag,k,d,m,a,j;
  icache_insn *p;
  icache_tags *l = 0;
  o = addr & c ->addrmask;
  tag = addr & ~(c ->addrmask);
  ot = o >> (2 + c ->sz_tline_log);
  k = 1 << (((addr & c ->tlinemask)>>2));
  
  ti_print_err("\
ICache %x read acccess: addr(0x%x)\n\
cachemem offset: 0x%x\n\
compare tag    : 0x%x\n\
linenr         : 0x%x\n\
linepos mask   : 0x%x\n\
",c,addr,o,tag,ot,k);
  
  for (i = 0;i < c ->nr_sets; i++) {
    if ((c->tags[i])[ot].tag == tag) {
      l = &(c->tags[i][ot]);
      break;
    }
  }
  if (l) {
    p = &(c->sets[i][o/4]);
    *data = p;
    if (l->valid & k) {
      ti_print_err("-Cache hit valid\n");
    } else {
      ti_print_err("-Cache hit invalid\n");
      if (amba_read(addr,&d)) {
	release_decode(p);
        p ->insn = d;
	p ->decode = decode_insn(d);
	l->valid |= k;
	return 1;
      }
    }
  } else {

    ti_print_err("-Cache miss\n");

    for (i = 0;i < c ->nr_sets; i++) {
      if ((c->tags[i])[ot].valid == 0) {
	break;
      }
    }
    if (i = c ->nr_sets) {
      if (c->tags[c->setrepcnt][ot].lock) {
	for (i = 0;i < c ->nr_sets; i++) {
	  if ((c->tags[i])[ot].lock == 0) {
	    break;
	  }
	}
      } else {
	i = c->setrepcnt;
	c->setrepcnt++;
	if (c->setrepcnt >= c->sz_set)
	  c->setrepcnt = 0;
      }
    }
    
    ti_print_err("-Set replace: %i\n",i);
    if (amba_read(addr,&d)) {
      if (i < c ->nr_sets) {
	p = &(c->sets[i][o/4]);
	l = &(c->tags[i][ot]);
	l->valid = k;
	l->tag = tag;
	release_decode(p);
      } else {
	p = &local_icache_insn;
      }
      p->insn = d;
      p->decode = decode_insn(d);
      return 1;
    }
  }
  return 0;
}


