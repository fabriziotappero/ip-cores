#include        <stdio.h>
#include		<stdlib.h>
#include <string.h>
#include        "c.h"
#include        "expr.h"
#include "Statement.h"
#include        "gen.h"
#include        "cglbdec.h"

/*
 *	68000 C compiler
 *
 *	Copyright 1984, 1985, 1986 Matthew Brandt.
 *  all commercial rights reserved.
 *
 *	This compiler is intended as an instructive tool for personal use. Any
 *	use for profit without the written consent of the author is prohibited.
 *
 *	This compiler may be distributed freely for non-commercial use as long
 *	as this notice stays intact. Please forward any enhancements or questions
 *	to:
 *
 *		Matthew Brandt
 *		Box 920337
 *		Norcross, Ga 30092
 */
/*******************************************************
	Modified to support Raptor64 'C64' language
	by Robert Finch
	robfinch@opencores.org
*******************************************************/

#define BLKSIZE		4000

struct blk {
	char name[8];			// string overwrite area
    struct blk *next;
    char       m[1];           /* memory area */
};

static int      glbsize = 0,    /* size left in current global block */
                locsize = 0,    /* size left in current local block */
                glbindx = 0,    /* global index */
                locindx = 0;    /* local index */

static struct blk       *locblk = 0,    /* pointer to local block */
                        *glbblk = 0;    /* pointer to global block */

char    *xalloc(int siz)
{   
	struct blk *bp;
    char       *rv;

	while(siz % 8)	// align word
		siz++;
    if( global_flag ) {
        if( glbsize >= siz ) {
            rv = &(glbblk->m[glbindx]);
            glbsize -= siz;
            glbindx += siz;
            return rv;
        }
        else {
            bp = calloc(1,sizeof(struct blk) + BLKSIZE);
			if( bp == NULL )
			{
				printf(" not enough memory.\n");
				exit(1);
			}
			strcpy(bp->name,"C64    ");
            bp->next = glbblk;
            glbblk = bp;
            glbsize = BLKSIZE - siz;
            glbindx = siz;
            return glbblk->m;
        }
    }
    else    {
        if( locsize >= siz ) {
            rv = &(locblk->m[locindx]);
            locsize -= siz;
            locindx += siz;
            return rv;
        }
        else {
            bp = calloc(1,sizeof(struct blk) + BLKSIZE);
			if( bp == NULL )
			{
				printf(" not enough local memory.\n");
				exit(1);
			}
			strcpy(bp->name,"C64    ");
            bp->next = locblk;
            locblk = bp;
            locsize = BLKSIZE - siz;
            locindx = siz;
            return locblk->m;
        }
    }
}

void ReleaseLocalMemory()
{
	struct blk      *bp1, *bp2;
    int             blkcnt;
    blkcnt = 0;
    bp1 = locblk;
    while( bp1 != NULL ) {
        bp2 = bp1->next;
        free( bp1 );
        ++blkcnt;
        bp1 = bp2;
    }
    locblk = NULL;
    locsize = 0;
    lsyms.head = NULL;
	lsyms.tail = NULL;
	printf(" releasing %d bytes local tables.\n",blkcnt * BLKSIZE);
}

void ReleaseGlobalMemory()
{
	struct blk      *bp1, *bp2;
    int             blkcnt;
    bp1 = glbblk;
    blkcnt = 0;
    while( bp1 != NULL ) {
        bp2 = bp1->next;
        free(bp1);
        ++blkcnt;
        bp1 = bp2;
    }
    glbblk = NULL;
    glbsize = 0;
//    gsyms.head = NULL;         /* clear global symbol table */
//	gsyms.tail = NULL;
	memset(gsyms,0,sizeof(gsyms));
    printf(" releasing %d bytes global tables.\n",blkcnt * BLKSIZE);
    strtab = NULL;             /* clear literal table */
}

SYM *allocSYM() { return (SYM *)xalloc(sizeof(SYM)); };
TYP *allocTYP() { return (TYP *)xalloc(sizeof(TYP)); };
struct snode *allocSnode() { return (struct snode *)xalloc(sizeof(struct snode)); };
ENODE *allocEnode() { return (ENODE *)xalloc(sizeof(ENODE)); };
AMODE *allocAmode() { return (AMODE *)xalloc(sizeof(AMODE)); };
CSE *allocCSE() { return (CSE *)xalloc(sizeof(CSE)); };

