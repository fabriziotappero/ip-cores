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

#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#include "sc2v_step2.h"

void
ShowDefines (char *filedefines)
{

  int readok;

  char *auxchar;
  FILE *file;

  file = fopen (filedefines, (char *) "r");

  while (1){
    readok = fread ((void *) &auxchar, sizeof (char), 1, file);
    if (readok){
	  printf ("%c", auxchar);
	}else{
	  break;
	}
  }
}

WriteNode *
InsertWrite (WriteNode * list, char *name)
{
  WriteNode *wl;

  wl = (WriteNode *) malloc (sizeof (WriteNode));
  strcpy (wl->name, name);
  SGLIB_LIST_ADD (WriteNode, list, wl, next);
  return (list);
}

int
IsWrite (WriteNode * list, char *name)
{
  WriteNode *wll;
  SGLIB_LIST_MAP_ON_ELEMENTS (WriteNode, list, wll, next,
  {
	if ((strcmp (name, (char *) wll->name) == 0)) return (1);
    }
  );
  return (0);
}

void
ShowWritesList (WriteNode * list)
{
  WriteNode *wll;
  SGLIB_LIST_MAP_ON_ELEMENTS (WriteNode, list, wll, next,{
	printf ("%s\n", wll->name);
    }
  );
  return;
}



WriteNode *
ReadWritesFile (WriteNode *list,char *name)
{

  char *leido;
  int ret;
  FILE *file_writes;
  file_writes = fopen (name, (char *) "r");

  leido = (char *) malloc (256 * sizeof (char));

  while (1){
      ret = fscanf (file_writes, "%s", leido);
      if (ret == EOF)
      	break;
      list = InsertWrite (list, leido);
  }
  return(list);
}

PortNode *
InsertPort (PortNode * list, char *name, char *tipo, int size, int pflag)
{
  PortNode *pl;
  pl = (PortNode *) malloc (sizeof (PortNode));
  strcpy (pl->name, name);
  strcpy (pl->tipo, tipo);
  pl->size = size;
  pl->pflag = pflag;
  SGLIB_LIST_ADD (PortNode, list, pl, next);
  return (list);
}

void
ShowPortList (PortNode * list)
{

  PortNode *pll;
  
  SGLIB_LIST_MAP_ON_ELEMENTS (PortNode, list, pll, next,
  {
	printf ("%s ", pll->tipo);
	if (pll->pflag == 1) printf("signed ");
	if (pll->size != 0 && pll->size != 1)
	{
	  printf ("[%d:0] ", (-1 + pll->size));}
	printf ("%s;\n", pll->name);
	}
  );
  return;
}

void
RegOutputs (PortNode * list, InstanceNode *instances)
{

  PortNode *pll;
  SGLIB_LIST_MAP_ON_ELEMENTS (PortNode, list, pll, next,
  {
	if (strcmp (pll->tipo, "output") == 0)
	{
	 if(!IsWire(pll->name,instances)){
	   if (pll->pflag == 1) printf("reg signed "); else printf ("reg ");
	  if (pll->size != 0 && pll->size != 1)
	  {
	    printf ("[%d:0] ", (-1 + pll->size));}
	    printf ("%s;\n", pll->name);}
	  }
	 }
  );
  return;
}

void
EnumeratePorts (PortNode *list)
{
  PortNode *pll;
    
  SGLIB_LIST_MAP_ON_ELEMENTS (PortNode, list, pll, next,
  {
	if (pll->next == NULL)
	{
	  printf ("%s", pll->name); break;
	}
	else
	{
	  printf ("%s,", pll->name);}
	}
  );
  return;
}

SignalNode *
InsertSignal (SignalNode * list, char *name, int size, int arraysize,int sflag)
{
  SignalNode *sl;

  sl = (SignalNode *) malloc (sizeof (SignalNode));
  strcpy (sl->name, name);
  sl->size = size;
  sl->arraysize=arraysize;
  sl->sflag=sflag;
  SGLIB_LIST_ADD (SignalNode, list, sl, next);
  return (list);

}


void 
ShowSignalsList (SignalNode * list, WriteNode * writeslist)
{
  SignalNode *sll;
  SGLIB_LIST_MAP_ON_ELEMENTS (SignalNode, list, sll, next,
  {
	if (IsWrite (writeslist, sll->name))
	{
	  if (sll->sflag==1) printf("reg signed "); else printf ("reg ");
	  if (sll->size != 0 && sll->size != 1)
	  {
	    printf ("[%d:0] ", (-1 + sll->size));
	  }
	  printf ("%s", sll->name);
	}
	else
	{
	  if (sll->sflag==1) printf("wire signed "); else printf ("wire ");
	  if (sll->size != 0 && sll->size != 1)
	  {
		printf ("[%d:0] ", (-1 + sll->size));
	  }
	  printf ("%s", sll->name);
	}
        if(sll->arraysize !=0)
	  printf("[%d:0]", (-1 + sll->arraysize));
	printf(";\n");
  }
  );
  return;
}


/* Decides if a signal is a wire or a reg*/
int
IsWire (char *name, InstanceNode * list)
{

  InstanceNode *ill;
  SGLIB_LIST_MAP_ON_ELEMENTS (InstanceNode, list, ill, next,
  {
    BindNode * bll;
	SGLIB_LIST_MAP_ON_ELEMENTS (BindNode,ill->bindslist, bll, next,
	{
	if ((strcmp(name,bll->namebind)==0))
	{
	 return 1;
	}
	}
	);}
  );
  return 0;
}



SensibilityNode *
InsertSensibility (SensibilityNode * list, char *name, char *tipo)
{
  SensibilityNode *sl;
  sl = (SensibilityNode *) malloc (sizeof (SensibilityNode));
  strcpy (sl->name, name);
  strcpy (sl->tipo, tipo);
  SGLIB_LIST_ADD (SensibilityNode, list, sl, next);
  return (list);
}

void
ShowSensibilityList (SensibilityNode * list)
{
  SensibilityNode *sll;
  SGLIB_LIST_MAP_ON_ELEMENTS (SensibilityNode, list, sll, next,
  {
	if (!strcmp (sll->tipo, "posedge")|| !strcmp (sll->tipo,"negedge")) 
	  printf (" %s",sll->tipo);
	if (sll->next == NULL)
	{
	  printf (" %s", sll->name); break;
	}
	else
	{
	  printf (" %s or", sll->name);}
    }
  );
  return;
}


ProcessNode *
InsertProcess (ProcessNode * list, char *name,
	       SensibilityNode * SensibilityList, char *tipo)
{
  ProcessNode *pl;
  pl = (ProcessNode *) malloc (sizeof (ProcessNode));
  strcpy (pl->name, name);
  strcpy (pl->tipo, tipo);
  pl->list = SensibilityList;
  SGLIB_LIST_ADD (ProcessNode, list, pl, next);
  return (list);
}


void
ShowProcessList (ProcessNode * list)
{
  ProcessNode *pll;
  SGLIB_LIST_MAP_ON_ELEMENTS (ProcessNode, list, pll, next,
  {
	printf ("%s: always @(", pll->name);
	ShowSensibilityList (pll->list); printf (")\n");
  }
  );
  return;
}


void
ShowProcessCode (ProcessNode * list)
{
  FILE *archivo;
  int readok;
  char lookahead;
  char *filename;
  char auxchar;
  char begin[10];

  ProcessNode *pll;
  SGLIB_LIST_MAP_ON_ELEMENTS (ProcessNode, list, pll, next,
  {
    fprintf(stderr,"Writing process code => %s\n",pll->name);
	printf ("//%s:\n", pll->name);
	filename =(char *) malloc (256 * sizeof (char));
	strcpy (filename, pll->name);
	strcat (filename, (char *) "_regs.sc2v");
	archivo = fopen (filename, (char *) "r");
	while (1)
	{
	  readok =fread ((void *) &auxchar, sizeof (char), 1,archivo);
	  if (readok) printf ("%c", auxchar);
	  else
	    break;
	}
    fclose (archivo);
    printf ("always @(");

    ShowSensibilityList (pll->list);
    printf (" )\n");
    printf ("   begin\n");
    strcpy (filename, pll->name);
    strcat (filename, (char *) ".sc2v");
    archivo = fopen (filename, (char *) "r");

	/*Read the initial begin of the file */
    fscanf (archivo, "%s", begin);
    readok =fread ((void *) &auxchar, sizeof (char), 1,archivo);
			      
	/*Trim the beggining of the file */
	while (auxchar == '\n' || auxchar == ' ' || auxchar == '\t') 
	    readok =fread ((void *) &auxchar, sizeof (char), 1,archivo); printf ("\n   %c", auxchar);
	
	while (1){
	  readok = fread ((void *) &auxchar, sizeof (char), 1,archivo); 
	  if (readok){
	     if (strcmp (pll->tipo, "comb") == 0 && auxchar == '<')
		 {
		   readok = fread ((void *) &lookahead, sizeof (char), 1, archivo); 
		   if (readok){
			  if (lookahead == '='){
			      auxchar = lookahead;
			  }else{
			      printf ("%c", auxchar);
			      auxchar = lookahead;
			  }
		   }
	     }
		 printf ("%c", auxchar);
	  }
      else
      {
        break;
	  }
    }

    fclose (archivo);
    }
  );

}

InstanceNode *
InsertInstance (InstanceNode * list, char *nameinstance, char *namemodulo)
{
  InstanceNode *il;
  il = (InstanceNode *) malloc (sizeof (InstanceNode));
  strcpy (il->nameinstance, nameinstance);
  strcpy (il->namemodulo, namemodulo);
  il->bindslist = NULL;
  SGLIB_LIST_ADD (InstanceNode, list, il, next);
  return (list);
}

BindNode *
InsertBind (BindNode * list, char *nameport, char *namebind)
{
  BindNode *bl;
  bl = (BindNode *) malloc (sizeof (BindNode));
  strcpy (bl->nameport, nameport);
  strcpy (bl->namebind, namebind);
  SGLIB_LIST_ADD (BindNode, list, bl, next);
  return (list);

}


void
ShowInstancedModules (InstanceNode * list)
{
  InstanceNode *ill;
  SGLIB_LIST_MAP_ON_ELEMENTS (InstanceNode, list, ill, next,
  {
	printf ("%s %s (", ill->namemodulo,ill->nameinstance);
	BindNode * bll;
	SGLIB_LIST_MAP_ON_ELEMENTS (BindNode,ill->bindslist, bll,next,
	{
	  printf (".%s(%s)",bll->nameport,bll->namebind);
	  if (bll->next == NULL)
	    printf (");\n");
	  else
	    printf (", ");}
    );}
  );
}


EnumeratesNode *InsertEnumerates (EnumeratesNode * list, char *name)
{

  EnumeratesNode *el;
  el = (EnumeratesNode *) malloc (sizeof (EnumeratesNode));
  strcpy (el->name, name);
  SGLIB_LIST_ADD (EnumeratesNode, list, el, next);
  return (list);
}  


int
ShowEnumeratesList (EnumeratesNode *list)
{
 
  EnumeratesNode *ell;
  int i = 0;
  
  printf ("parameter  %s = 0", list->name);
    
  if(list->next!=NULL){
    list=list->next;
    printf(",\n");
    i=1;
    SGLIB_LIST_MAP_ON_ELEMENTS (EnumeratesNode,list, ell,next,
    {
      if(ell->next==NULL)
	  {
	 	printf("           %s = %d;\n\n",ell->name,i);
		return(i);
	  }
  	  else
	  {
	    printf("           %s = %d,\n",ell->name,i);
	  }
	  i++;
	}
	);
  }else{
    printf(";\n\n");
	return(i); 
  }
}

EnumListNode *
InsertEnumList (EnumListNode * list, EnumeratesNode * enumlist, char *name,int istype)
{
  EnumListNode *el;
  el = (EnumListNode *) malloc (sizeof (EnumListNode));
  strcpy (el->name, name);
  el->istype=istype;
  el->list=enumlist;
  SGLIB_LIST_ADD (EnumListNode, list, el, next);
  return (list);
}

void
ShowEnumListList (EnumListNode * list)
{

  int items;
  EnumListNode *ell;
  double bits, bits_round;
  int bits_i;
  
  SGLIB_LIST_MAP_ON_ELEMENTS(EnumListNode,list, ell,next,
  {
  
	  items = ShowEnumeratesList (ell->list);

	  //Calculate the number of bits needed to represent the enumerate
	  bits = log ((double) (items + 1)) / log (2.0);
	  bits_i = bits;
	  bits_round = bits_i;
	  if (bits_round != bits)
	    bits_i++;
	  if (bits_i == 0)
	    bits_i = 1;

	  if (!(ell->istype))
	    {
            if ((bits_i - 1) != 0)
		  printf ("reg [%d:0] %s;\n\n", bits_i - 1, ell->name);
            else
  		  printf ("reg %s;\n\n", ell->name);
	    }

  }
  );
}


int
findEnumList (EnumListNode * list, char *name)
{

  int i = 0;
  EnumListNode *ell;
  
  SGLIB_LIST_MAP_ON_ELEMENTS (EnumListNode,list, ell,next,
  {
  	  //printf("%s %s %d %d\n", aux->name,name,aux->istype,i);
	  if ((strcmp (ell->name, name) == 0) && ((ell->istype) == 1))
	  {
         return i;
      }
	  
	  i++;
   }
   );
   return -1;
}


int
findEnumerateLength (EnumListNode * list, int offset)
{

  int i,j = 0;
  double bits, bits_round;
  int bits_i;
  
  EnumListNode *ell;
  EnumeratesNode *enumll;
  
  j=0;
  i=0;
  
  SGLIB_LIST_MAP_ON_ELEMENTS (EnumListNode,list, ell,next,
  {
    i++;
    if(i==offset+1){
      SGLIB_LIST_MAP_ON_ELEMENTS (EnumeratesNode,ell->list, enumll,next,
      {
	    j++;
	  });
	}
  });
  
   //Calculate the number of bits needed to represent the enumerate
   bits = log ((double) (j)) / log (2.0);
   bits_i = bits;
   bits_round = bits_i;

   if (bits_round != bits)
    bits_i++;
   if (bits_i == 0)
	bits_i = 1;

   return bits_i;
    	
 }

 /* Functions for functions inputs list*/
FunctionInputNode *InsertFunctionInput (FunctionInputNode * list, char *name, int lenght, int flag){
  FunctionInputNode *fl;
  fl = (FunctionInputNode *) malloc (sizeof (FunctionInputNode));
  strcpy (fl->name, name);
  fl->lenght=lenght;
  fl->sgnflag=flag;
  SGLIB_LIST_ADD (FunctionInputNode, list, fl, next);
  return (list);
}

void ShowFunctionInputs (FunctionInputNode * list){

  FunctionInputNode *fll;

  SGLIB_LIST_REVERSE(FunctionInputNode,list, next);
  
  SGLIB_LIST_MAP_ON_ELEMENTS (FunctionInputNode,list, fll,next,
  {
    if(fll->sgnflag==0)
    {
    if(fll->lenght!=1)
     printf("input [%d:0] %s;\n",(fll->lenght)-1,fll->name); 
    else
     printf("input %s;\n",fll->name); 
     } else {
     if(fll->lenght!=1)
     printf("input signed [%d:0] %s;\n",(fll->lenght)-1,fll->name); 
    else
     printf("input signed %s;\n",fll->name);
     }
  });
}

/* Functions for functions list*/
FunctionNode *InsertFunction (FunctionNode *list, char *name,FunctionInputNode *InputsList,int outputlenght,int flag){
  FunctionNode *fl;
  fl = (FunctionNode *) malloc (sizeof (FunctionNode));
  strcpy (fl->name, name);
  fl->outputlenght=outputlenght;
  fl->list = InputsList;
  fl->sgnflag=flag;
  SGLIB_LIST_ADD (FunctionNode, list, fl, next);
  return (list);
}

void ShowFunctionCode (FunctionNode *list){
  
  FILE *archivo;
  int readok;
  char *filename;
  char auxchar;	
  char begin[10];
	
  FunctionNode *fll;
    	
  SGLIB_LIST_MAP_ON_ELEMENTS (FunctionNode,list, fll,next,
  {
   if(fll->sgnflag==0)
   {
	if(fll->outputlenght!=1)
     printf("function [%d:0] %s;\n\n",(fll->outputlenght)-1,fll->name); 
    else
	 printf("function %s;\n\n",fll->name); 
	} else {
   if(fll->outputlenght!=1)
     printf("function signed [%d:0] %s;\n\n",(fll->outputlenght)-1,fll->name); 
    else
	 printf("function signed %s;\n\n",fll->name);    
   }
   
	ShowFunctionInputs(fll->list);
	
	//Show Registers
	filename =(char *) malloc (256 * sizeof (char));
	strcpy (filename, fll->name);
	strcat (filename, (char *) "_regs.sc2v");
	archivo = fopen (filename, (char *) "r");
	if(archivo==NULL){
		fprintf(stderr,"Error opening file %s\n",filename);
		exit(1);
	}
	printf("\n");	
	while (1)
	{
	  readok =fread ((void *) &auxchar, sizeof (char), 1,archivo);
	  if (readok) printf ("%c", auxchar);
	  else{
		break;
	  }
	}
    fclose (archivo);
	
	printf ("\n   begin\n");
    strcpy (filename, fll->name);
    strcat (filename, (char *) ".sc2v");
    archivo = fopen (filename, (char *) "r");

	/*Read the initial begin of the file */
    fscanf (archivo, "%s", begin);
    readok =fread ((void *) &auxchar, sizeof (char), 1,archivo);
			      
	/*Trim the beggining of the file */
	while (auxchar == '\n' || auxchar == ' ' || auxchar == '\t') 
	    readok =fread ((void *) &auxchar, sizeof (char), 1,archivo); printf ("\n   %c", auxchar);
	
	while (1){
	  readok = fread ((void *) &auxchar, sizeof (char), 1,archivo); 
	  if (readok)
	     printf ("%c", auxchar);
	  else
         break;
	}
    printf("endfunction\n\n");
	
    fclose (archivo);
	
  });
  
}
