#include <tmki.h>
#include "gendc.h"

/* gendc.vhd c model:
 * Currently supports:
 * - multiple sets
 * - tag, valid, dirty, lock bits
 * - writethrough or writeback
 * - allocateonstore
 */

data_cache *gendc_create(int size_kb, int nr_sets, int size_tline) {
  
  int i,j;
  data_cache *c;
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
  
  c = (data_cache *) ti_alloc(sizeof(data_cache));
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
    c ->sets[i] = ti_alloc(size_kb);
    c ->tags[i] = (cache_tags *)ti_alloc(j * sizeof(cache_tags));
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
Create gendc model (0x%x):\n\
sets   : %i\n\
setsz  : 0x%x (log:%i, msk:0x%x)\n\
linesz : %i (log:%i, msk:0x%x)\n\
nrlines: 0x%x\n",
c,c->nr_sets, 
c->sz_set, c->sz_set_log, c ->addrmask,
c->sz_tline, c->sz_tline_log, c ->tlinemask,
	       j);
  
  return c;
}

#define amba_read(x,d) 1
#define amba_write(x,d) 1

int gendc_read(data_cache *c,unsigned int addr,unsigned int *data) {

  unsigned int i,ot,o,tag,k,d,m,a,j;
  cache_tags *l = 0;
  o = addr & c ->addrmask;
  tag = addr & ~(c ->addrmask);
  ot = o >> (2 + c ->sz_tline_log);
  k = 1 << (((addr & c ->tlinemask)>>2));
  
  ti_print_err("\
Cache %x read acccess: addr(0x%x)\n\
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
    if (l->valid & k) {
      ti_print_err("-Cache hit valid\n");
      d = *((unsigned int*)&(c->sets[i][o]));
    } else {
      ti_print_err("-Cache hit invalid\n");
      if (amba_read(addr,&d)) {
	*data = d;
	*((unsigned int*)&(c->sets[i][o])) = d;
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
      *data = d;
      if (i < c ->nr_sets) {
	l = &(c->tags[i][ot]);
	if (l->dirty) {
	  ti_print_err("-Flush dirty line: ");
	  tag = c->tags[i][ot].tag;
	  tag = tag | (o & c ->tlinemask);
	  for (m = 1,j = 0;j < c->sz_tline;j++,m=m<<1) {
	    if (l->dirty & m) { 
	      d = *(unsigned int *)(&c->sets[i][(o & ~(c ->tlinemask|0x3))|(j<<2)]);
	      a = (o & ~(c ->tlinemask|0x3))|tag|(j<<2);
	      ti_print_err("%i(%x<=%x (set:%i,off:%x) ",j,a,d,i,(o & ~(c ->tlinemask|0x3))|(j<<2));
	      amba_write(a,d);
	    }
	  }
	  l->dirty = 0;
	  ti_print_err("\n");
	}
	*((unsigned int*)&(c->sets[i][o])) = d;
	l->valid = k;
	l->tag = tag;
      }
    }
    return 1;
  }
  return 0;
}


int gendc_write(data_cache *c,unsigned int addr,unsigned int data) {

  unsigned int i,ot,o,tag,k,d,m,a,j;
  cache_tags *l = 0;
  o = addr & c ->addrmask;
  tag = addr & ~(c ->addrmask);
  ot = o >> (2 + c ->sz_tline_log);
  k = 1 << (((addr & c ->tlinemask)>>2));
  
  ti_print_err("\
Cache %x write acccess: addr(0x%x<=0x%x)\n\
cachemem offset: 0x%x\n\
compare tag    : 0x%x\n\
linenr         : 0x%x\n\
linepos mask   : 0x%x\n\
",c,addr,data,o,tag,ot,k);
  
  for (i = 0;i < c ->nr_sets; i++) {
    if ((c->tags[i])[ot].tag == tag) {
      l = &(c->tags[i][ot]);
      break;
    }
  }
  if (l) {
    if (l->valid & k) {
      ti_print_err("-Cache hit valid\n");
      if (c->writeback) {
	l->dirty |= k;
      }
    } else {
      ti_print_err("-Cache hit invalid\n");
      l->valid |= k;
      if (c->writeback) {
	l->dirty |= k;
      }
    }
    ti_print_err("-Cache write: (set:%i,off:%x <= %x)\n",i,o,data);
    *((unsigned int*)&(c->sets[i][o])) = data;
    if (!c->writeback) {
      amba_write(addr,data);
    }
  } else {
    ti_print_err("-Cache miss\n");

    if (c ->allocateonstore) {
      
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
      if (i < c ->nr_sets) {
	
	l = &(c->tags[i][ot]);
	if (l->dirty) {
	  ti_print_err("-Flush dirty line");
	  tag = c->tags[i][ot].tag;
	  tag = tag | (o & c ->tlinemask);
	  for (m = 1,j = 0;j < c->sz_tline;j++,m=m<<1) {
	    if (l->dirty & m) {
	      d = *(unsigned int *)(&c->sets[i][(o & ~(c ->tlinemask|0x3))|(j<<2)]);
	      a = (o & ~(c ->tlinemask|0x3))|tag|(j<<2);
	      ti_print_err("%i(%x<=%x (set:%i,off:%x) ",j,a,d,i,(o & ~(c ->tlinemask|0x3))|(j<<2));
	      amba_write(a,d);
	    }
	  }
	  l->dirty = 0;
	  ti_print_err("\n");
	}
      
	ti_print_err("-Cache write: (set:%i,off:%x <= %x)\n",i,o,data);
	*((unsigned int*)&(c->sets[i][o])) = data;
	l->valid = k;
	l->tag = tag;
	if (!c->writeback) {
	  return amba_write(addr,data);
	} else { 
	  l->dirty = k;
	  return 1;
	}
      }
      else {
	return amba_write(addr,data);
      }
    }
    else {
      return amba_write(addr,data);
    }
  }
  return 0;
}
