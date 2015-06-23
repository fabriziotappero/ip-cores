// 2003: Konrad Eisele <eiselekd@web.de>
#ifndef SCRIPT_TMKI_H
#define SCRIPT_TMKI_H

#include "sys.h"

#if !defined(_SIZE_T) && !defined(_SIZE_T_)
#include <stddef.h> 	/* just for size_t -- how lame! */
#endif

#define TI_MAXPATH 1028
#define TI_TOKENBUF 2056

typedef struct ti_namelist_ {
  struct ti_namelist_ *n;
  char                *s;
} ti_namelist;

/* fixed size memory allocator */
typedef struct ti_memf_chnk_ {
  struct ti_memf_chnk_ *n;
  unsigned int f,c,cc,oe,cs;
} ti_memf_chnk;

typedef struct ti_memf_ctrl_ {
  unsigned int es,cc,f;
  ti_memf_chnk *c;
} ti_memf_ctrl;

/* stringbuffer */
typedef struct ti_strbuf_he_ {
  struct ti_strbuf_chnk_ *n,*f;
  unsigned char *mem;			
  unsigned int l;
} ti_strbuf_he;

typedef struct ti_strbuf_ctrl_ {
  ti_strbuf_he **h;
  unsigned int hs;
  ti_memf_ctrl *m;
} ti_strbuf_ctrl;


/* io.c */
EXTERN void ti_nlfree(ti_namelist *nl);
EXTERN ti_namelist *ti_nlappend(ti_namelist *nl,const char *s);
EXTERN int ti_open_vp(ti_namelist *nl,const char *d,const char *f,const char *e,char *r,unsigned int rc,char **nr,int bin);

/* out.c */
EXTERN void ti_print_err(const char *fmt, ...);

/* mem.c */
EXTERN void ti_free(void *m);
EXTERN void *ti_alloc(size_t c);
EXTERN void *ti_realloc(void *o,size_t oc,size_t nc);
EXTERN ti_strbuf_ctrl *ti_strbuf_init(int hs);
EXTERN void ti_strbuf_free(ti_strbuf_ctrl *ctrl);
EXTERN ti_memf_ctrl *ti_memf_init (unsigned  int es, unsigned  int cc);
EXTERN void ti_memf_free(ti_memf_ctrl *ctrl);

/* sys.c */
EXTERN void sys_bashfilename(char *d,char *s);
EXTERN void sys_unbashfilename(char *d,char *s);

#endif /*SCRIPT_TMKI_H*/
