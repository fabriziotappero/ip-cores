/* -----------------------------------------------------------------------------
 *
 *  SystemC to Verilog Translator v0.4
 *  Provided by Universidad Rey Juan Carlos
 *  
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
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston,MA 02111-1307, USA.
 */

#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#include "sc2v_step1.h"

DefineNode *InsertDefine(DefineNode *list,char *name){
    DefineNode *dl;

	dl=(DefineNode *)malloc(sizeof(DefineNode));  
	strcpy(dl->name,name);
	SGLIB_LIST_ADD(DefineNode,list,dl,next);
	
	return(list);
}

int IsDefine(DefineNode *list,char *name){
    
	DefineNode *dll;
	SGLIB_LIST_MAP_ON_ELEMENTS (DefineNode, list, dll, next,
 	 {	     
		 if ((strcmp (name, (char *)dll->name) == 0)) return(1);
     }
     );
	 return(0);
}


RegNode *InsertReg(RegNode *list, char *name, char *name2){
    
	RegNode *rl;
   
	rl=(RegNode *)malloc(sizeof(RegNode));  
	strcpy(rl->name,name);
	strcpy(rl->name2,name2);
	SGLIB_LIST_ADD(RegNode,list,rl,next);
	return(list);
    
}


/*Looks if a WORD of func.y file is a register of the process*/
char *
IsReg (RegNode *list, char *name)
{

  RegNode *rll;
  SGLIB_LIST_MAP_ON_ELEMENTS (RegNode, list, rll, next,
			      {
				  if ((strcmp (name, (char *)rll->name) == 0))
			      {
			      return (rll->name2);}
			      }
  );
  return NULL;
}

StructNode *InsertStruct(StructNode *list, char *name, StructRegNode *reglist){
    
	StructNode *sl;
   
	sl=(StructNode *)malloc(sizeof(StructNode));  
	strcpy(sl->name,name);
	sl->list=reglist;
	SGLIB_LIST_ADD(StructNode,list,sl,next);
	return(list);
    
}

StructRegNode *InsertStructReg(StructRegNode *list, char *name, int length){
    
	StructRegNode *sl;
   
	sl=(StructRegNode *)malloc(sizeof(StructRegNode));  
	strcpy(sl->name,name);
	sl->length=length;
	SGLIB_LIST_ADD(StructRegNode,list,sl,next);
	return(list);
    
}

void
ShowStructs (StructNode * list)
{
  StructNode *sll;
  SGLIB_LIST_MAP_ON_ELEMENTS (StructNode, list, sll, next,
  {
	printf ("%s\n", sll->name);
	StructRegNode *srll;
	SGLIB_LIST_MAP_ON_ELEMENTS (StructRegNode,sll->list, srll,next,
	{
	  printf ("\t%s %d\n",srll->name,srll->length);
    );}
  );
  }
}
