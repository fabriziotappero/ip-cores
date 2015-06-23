/* 2003: Konrad Eisele <eiselekd@web.de> */

#include <stdlib.h>
#ifdef UNIX
#include <unistd.h>
#include <sys/stat.h>
#include <strings.h>
#endif
#ifdef NT
#include <io.h>
#endif

#include <stdio.h>
#include <fcntl.h>

#include "tmki.h"

ti_namelist *ti_nlappend(ti_namelist *nl,const char *s) {
  int i;
  ti_namelist *n = (ti_namelist *)ti_alloc(sizeof(ti_namelist));
  if (!n) return NULL;
  nl ->n = n;
  i = strlen(s);
  if ( ((n ->s) = ti_alloc(i+1))) { strcpy(n ->s,s); }
  return n;
}

void ti_nlfree(ti_namelist *nl) {
  while (nl) {
    ti_namelist *n = nl ->n;
    if (nl ->s) free(nl ->s);
    nl ->s = 0;
    free(nl);
    nl = n;
  }
}

/* try all [nl->s]/<p><e> combinations
 * nl: list of prefixes
 * p: filename
 * e: extension
 * r: buffer to assemble dest finename
 * rc: buffer size
 * nr: return filename pointer in <r>
 * bin: binary open(NT)
 */
int ti_open_vp(ti_namelist *nl,const char *d,const char *f,const char *e,char *r,unsigned int rc,char **nr,int bin)
{
  ti_namelist x;
  int fd = -1;
  char b[TI_MAXPATH];
  
  if (d[0] == '/' 
#ifdef NT
      || (d[0] && d[1] == ':' && d[2] == '/')
#endif
      ) {
    x.n = 0;
    x.s = b;
    b[0] = 0;
  }
  else {
    x.n = nl;
    x.s = b;
    strncpy(b, d, TI_MAXPATH);
    b[TI_MAXPATH-1] = 0;
    sys_unbashfilename(b, b);
  }
  for (nl = &x; nl; nl = nl->n) {
      if (strlen(nl->s) + strlen(f) + strlen(e) + 2 > rc)
	continue;
      strcpy(r, nl->s);
      if (r[0] && r[strlen(r)-1] != '/')
	strcat(r, "/");
      strcat(r, f);
      strcat(r, e);
      sys_bashfilename(r,r);
      
      /* see if we can open the file for reading */
#ifdef NT
      if ((fd=open(r,O_RDONLY | (bin ? _O_BINARY : _O_TEXT))) >= 0)
#else
      if ((fd=open(r,O_RDONLY )) >= 0)
#endif
      {
	/* in UNIX, further check that it's not a directory */
#ifdef UNIX
	struct stat statbuf;
	int ok =  ((fstat(fd, &statbuf) >= 0) && !S_ISDIR(statbuf.st_mode));
	if (!ok) {
	  ti_print_err("ti_open_vp: %s stat failed or directory",r);
	  close (fd); fd = -1;
	}
	else
#endif
	{
	  char *slash;
	  sys_unbashfilename(r, r);
	  slash = strrchr(r, '/');
	  if (slash) {
	      *slash = 0;
	      *nr = slash + 1;
	  }
	  else *nr = r;
	  return (fd);  
	}
      }
      else  
	ti_print_err("failed to open %s\n", r);
  }
  *r = 0;
  return (-1);
}


