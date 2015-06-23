/* -----------------------------------------------------------------------------
 *
 *  SystemC to Verilog Translator v0.4
 *  Provided by Universidad Rey Juan Carlos
 *
 * -----------------------------------------------------------------------------
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Library General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

#include "sglib.h"

#define MAX_NAME_LENGTH 256

typedef struct _DefineNode
{
  char name[MAX_NAME_LENGTH];
  struct _DefineNode *next;
} DefineNode;

typedef struct _RegNode
{
  char name[MAX_NAME_LENGTH];
  char name2[MAX_NAME_LENGTH];
  struct _RegNode *next;
} RegNode;

/*Each struct has a name and a list of the registers declared inside it*/
typedef struct _StructRegNode
{
  char name[MAX_NAME_LENGTH];
  int length;
  struct _StructRegNode *next;
} StructRegNode;

typedef struct _StructNode
{
  char name[MAX_NAME_LENGTH];
  StructRegNode *list;  
  struct _StructNode *next;
} StructNode;

/* Global var to store Regs */
  RegNode *regslist;
/* Global var to store Defines */
  DefineNode *defineslist;
/*Global var to store Structs */
  StructNode *structslist;
  StructRegNode *structsreglist;

/* Functions for defines list*/
DefineNode *InsertDefine(DefineNode *list,char *name);
int IsDefine(DefineNode *list,char *name);

/* Functions for registers list*/
RegNode *InsertReg(RegNode *list, char *name, char *name2);
char *IsReg (RegNode *list,char *name);

/* Functions for structs list*/
StructNode *InsertStruct(StructNode *list, char *name, StructRegNode *reglist);
StructRegNode *InsertStructReg(StructRegNode *list, char *name, int length);
void ShowStructs (StructNode * list);
           


