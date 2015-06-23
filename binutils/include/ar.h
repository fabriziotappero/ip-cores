/*
 * ar.h -- structure of archives (object libraries)
 */


#ifndef _AR_H_
#define _AR_H_


#define AR_MAGIC	0x0412CF03	/* archive file magic number */
#define MAX_NAME	60		/* max length of member name */


/*
 * The following structure is stored once per archive member.
 */

typedef struct {
  char name[MAX_NAME];
  time_t date;
  int uid;
  int gid;
  int mode;
  int size;
} ArHeader;


#endif /* _AR_H_ */
