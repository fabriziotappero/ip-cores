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


%{
#include <stdio.h>
#include <string.h>
#include "sglib.h"
#include "sc2v_step1.h"

  int lineno = 1;
  int processfound = 0;
  int switchfound = 0;
  int lastswitch=0;
  int switchparenthesis[256];
  int ifdeffound = 0;
  char *processname, *processname2;
  char *fileregs;
  char *filename;
  int openedkeys = 0;
  int newline = 0;
  int reg_found = 0;
  int sigreg_found = 0;
  int reglenght = 0;
  int writelenght = 0;
  int array_size=0;
  int integer_found=0;
  int regs_end;
  int i = 0;			//for loops counter
  FILE *file;
  FILE *regs_file;
  char *regname, *regname2;
  char *lastword;		// Stores last WORD for use it in WRITE
  char *file_defines;
  FILE *FILE_DEFINES;
  char *file_writes;
  FILE *FILE_WRITES;		//FILE to store .write to know if it is a wire or reg
  int definefound = 0;
  int defineinvocationfound = 0;
  int opencorchfound = 0;
  int defineparenthesis = 0;
  int openedcase = 0;
  int writingvar=0;

  int default_break_found = 0;
  int default_found;

  int struct_found=0;
  int end_struct=0;
  int ignore_semicolon=0;
  char *structname;

//Directives variables
  int translate;
  int verilog;
  int writemethod;

  void yyerror (const char *str)
  {
    fprintf (stderr, "line: %d error: %s\n", lineno, str);
  }

  int yywrap ()
  {
    return 1;
  }

  main ()
  {
    int i;

    defineslist = NULL;
    regslist = NULL;
    structslist = NULL;
    structsreglist = NULL;

    fprintf (stderr, "\nSystemC to Verilog Translator v0.6");
    fprintf (stderr,
	     "\nProvided by URJC(Universidad Rey Juan Carlos)\nhttp://gdhwsw.escet.urjc.es\n\n");
    fprintf (stderr, "Parsing implementation file.......\n\n");

    processname = (char *) malloc (256 * sizeof (char));
    processname2 = (char *) malloc (256 * sizeof (char));
    fileregs = (char *) malloc (256 * sizeof (char));

    file_defines = (char *) malloc (256 * sizeof (char));
    strcpy (file_defines, (char *) "file_defines.sc2v");
    FILE_DEFINES = fopen (file_defines, (char *) "w");

    file_writes = (char *) malloc (256 * sizeof (char));
    strcpy (file_writes, (char *) "file_writes.sc2v");
    FILE_WRITES = fopen (file_writes, (char *) "w");

    lastword = (char *) malloc (sizeof (char) * 256);
    structname = (char *) malloc (sizeof (char) * 256);

    for (i = 0; i < 256; i++)
      switchparenthesis[i] = 0;

    translate = 1;
    verilog = 0;
    writemethod = 0;

    FILE *yyin = stdin;
    FILE *yyout = stdout;
    yyparse ();
    fclose (FILE_WRITES);
    fclose (FILE_DEFINES);

    fprintf (stderr, "\nDone\n\n");
  }

%}

%token NUMBER WORD SC_REG SC_SIGREG BOOL BIGGER LOWER OPENKEY CLOSEKEY WRITE SYMBOL NEWLINE ENUM INCLUDE 
%token COLON SEMICOLON RANGE OPENPAR CLOSEPAR TWODOUBLEPOINTS OPENCORCH CLOSECORCH SWITCH CASE DEFAULT BREAK
%token HEXA DEFINE READ TRANSLATEOFF TRANSLATEON VERILOGBEGIN VERILOGEND TAB DOLLAR MINEQ
%token VOID TTRUE TFALSE ENDFUNC INC DEC INTEGER EQUALS
%token PIFDEF PIFNDEF PENDDEF PELSE COMMENT STRUCT DOT

%% commands:	/* empty */
|commands command;

command:
  struct_dec
  |
  endfunc
  |
  voidword
  |
  include
  |
  dollar
  |
  tab
  |
  read
  |
  sc_reg
  |
  sc_sigreg
  |
  integer
  |
  number
  |
  bool
  |
  word
  |
  symbol
  |
  write
  |
  newline
  |
  openkey
  |
  closekey
  |
  colon
  |
  semicolon
  |
  range
  |
  openpar
  |
  closepar 
  | 
  void
  |
  opencorch 
  | 
  closecorch 
  |
  bigger 
  | 
  lower 
  | 
  switch 
  |
  case_only
  |
  case_number
  |
  case_hexnumber
  |
  case_hexword
  |
  case_hexnumberword
  |
  case_word
  |
  case_default
  |
  break
  |
  hexa
  |
  definemacro
  |
  defineword
  |
  definenumber
  |
  translateoff
  |
  translateon
  | 
  verilogbegin 
  | 
  verilogend 
  | 
  ifdef 
  |
  ifndef
  | 
  endif 
  | 
  pelse 
  | 
  ttrue 
  | 
  tfalse
  |
  increment
  |
  decrement
  |
  equal
  |
  minorequal
  |
  comment
  |
  struct_access
  ;
 
struct_access:
WORD DOT WORD
{

/*Struct access
 Check if it is a var acess or a reg*/
 if (newline){
   for (i = 0; i < openedkeys; i++)
      fprintf (file, "   ");
 }

 strcpy(structname,(char *)$3);
 strcat(structname,(char *)$1);   	     
 regname2 = IsReg (regslist, structname);

 if (regname2 == NULL){
  fprintf (file, "%s ", structname);
 }else{
  fprintf (file, "%s", regname2);
}
  newline = 0;

 
 /*printf("Access to struct %s.%s\n",(char *)$1,(char *)$3);*/
}

minorequal:
MINEQ
{
 //This rule is needed because <= in the step two could be confused with a non-blocking assignment
 defineparenthesis = 0;
  if (translate == 1 && verilog == 0)
    {
      if (processfound)
	{
	  fprintf (file, "<1+");
	}
    }
  else if (verilog == 1)
    fprintf (file, "<=");
};

endfunc:
ENDFUNC
{
  defineparenthesis = 0;
  if (translate == 1 && verilog == 0)
    {
      if (processfound)
	{
	  for (i = 0; i < openedkeys; i++)
	    fprintf (file, "   ");
	  fprintf (file, "%s = ", processname);
	}
    }
  else if (verilog == 1)
    fprintf (file, "return ");
};


voidword:
VOID
{
  defineparenthesis = 0;
  if (verilog == 1)
    fprintf (file, " void");
};


include:
INCLUDE
{
  defineparenthesis = 0;
  if (verilog == 1)
    fprintf (file, " #include");
};


dollar:
DOLLAR
{
  defineparenthesis = 0;
  if (verilog == 1)
    fprintf (file, " $");
};


tab:
TAB
{
  defineparenthesis = 0;
  if (verilog == 1)
    fprintf (file, " \t");
};

read:
READ OPENPAR CLOSEPAR
{
  defineparenthesis = 0;
  if (verilog == 1)
    fprintf (file, ".read()");

}

defineword:
DEFINE WORD WORD
{

  defineparenthesis = 0;
  if (translate == 1 && verilog == 0)
    {
      if (processfound)
	{
	  fprintf (file, "`define %s %s\n", (char *) $2, (char *) $3);
	  defineslist = InsertDefine (defineslist, (char *) $2);
	}
      else
	{
	  fprintf (FILE_DEFINES, "`define %s %s\n", (char *) $2, (char *) $3);
	  defineslist = InsertDefine (defineslist, (char *) $2);
	}
    }
  else if (verilog == 1)
    fprintf (file, "#define %s %s\n", (char *) $2, (char *) $3);

};

definenumber:
DEFINE WORD NUMBER
{

  defineparenthesis = 0;
  if (translate == 1 && verilog == 0)
    {
      if (processfound)
	{
	  fprintf (file, "`define %s %d\n", (char *) $2, (int) $3);
	  defineslist = InsertDefine (defineslist, (char *) $2);
	}
      else
	{
	  fprintf (FILE_DEFINES, "`define %s %d\n", (char *) $2, (int) $3);
	  defineslist = InsertDefine (defineslist, (char *) $2);
	}
    }
  else if (verilog == 1)
    fprintf (file, "#define %s %d\n", (char *) $2, (int) $3);

};


definemacro:
DEFINE WORD OPENPAR CLOSEPAR
{
  defineparenthesis = 0;
  //Macro found
  if (translate == 1 && verilog == 0)
    {
      defineslist = InsertDefine (defineslist, (char *) $2);

      definefound = 1;
      if (processfound)
	fprintf (file, "`define %s ", (char *) $2);
      else
	fprintf (FILE_DEFINES, "`define %s ", (char *) $2);
    }
  else if (verilog == 1)
    fprintf (file, "#define %s ()", (char *) $2);
}

void:
WORD TWODOUBLEPOINTS WORD OPENPAR
{
  defineparenthesis = 0;
  if (translate == 1 && verilog == 0)
    {
      strcpy (processname, (char *) $4);
      strcpy (processname2, (char *) $4);
      strcat (processname2, (char *) ".sc2v");
      strcpy (fileregs, (char *) $4);
      strcat (fileregs, (char *) "_regs.sc2v");
    }
  else if (verilog == 1)
    fprintf (file, " %s::%s()", (char *) $1, (char *) $3);

}

sc_reg:
SC_REG LOWER NUMBER BIGGER
{
  defineparenthesis = 0;
  if (translate == 1 && verilog == 0)
    {
      if (processfound)
	{
	  writelenght=1;
	  reglenght = $3;
	  reg_found = 1;
	}
    }
};

sc_sigreg:
SC_SIGREG LOWER NUMBER BIGGER
{
  defineparenthesis = 0;
  if (translate == 1 && verilog == 0)
    {
      if (processfound)
	{
	  writelenght=1;
	  reglenght = $3;
	  sigreg_found = 1;
	}
    }
};

integer:
INTEGER
{
  defineparenthesis = 0;
  if (translate == 1 && verilog == 0)
    {
      if (processfound)
	{
	  fprintf (regs_file, "integer ");
	  integer_found = 1;
	}
    }
};


bool:
BOOL
{
  defineparenthesis = 0;
  if (translate == 1 && verilog == 0)
    {
      if (processfound)
	{
  	  writelenght=1;
	  reglenght=0;
	  reg_found = 1;
	}
    }
  else if (verilog == 1)
    fprintf (file, "bool");
}

;

range:
RANGE OPENPAR NUMBER COLON NUMBER CLOSEPAR
{
  defineparenthesis = 0;
  if (translate == 1 && verilog == 0)
    {
      if (processfound)
	fprintf (file, "[%d:%d]", $3, $5);
      else if (definefound)
	fprintf (FILE_DEFINES, "[%d:%d]", $3, $5);
    }
  else if (verilog == 1)
    fprintf (file, ".range(%d,%d)", $3, $5);
}

;

number:
NUMBER
{
  defineparenthesis = 0;
  if (translate == 1 && verilog == 0)
    {
      if (processfound)
       if(opencorchfound && (reg_found || sigreg_found))
        fprintf (regs_file, "%d:0",$1-1);
       else
	fprintf (file, "%d", $1);
      else if (definefound)
	fprintf (FILE_DEFINES, "%d", $1);
    }
  else if (verilog == 1)
    fprintf (file, "%d", $1);
};

increment:
WORD INC
{
  defineparenthesis = 0;
  if (translate == 1 && verilog == 0)
       if (processfound){
        regname2 = IsReg (regslist, (char *) $1);
        if (regname2 == NULL){
            fprintf (file, "%s=%s+1", (char *) $1,(char *)$1);
        }else
	    fprintf (file, "%s=%s+1", regname2,regname2);
       }
  else if (verilog == 1)
    fprintf (file, "%s++ ", (char *) $1);
};

decrement:
WORD DEC
{
  defineparenthesis = 0;
  if (translate == 1 && verilog == 0)
      if (processfound){
        regname2 = IsReg (regslist, (char *) $1);
        if (regname2 == NULL){
            fprintf (file, "%s=%s+1", (char *) $1,(char *)$1);
        }else
	    fprintf (file, "%s=%s+1", regname2,regname2);
      }
  else if (verilog == 1)
    fprintf (file, "%s-- ", (char *) $1);
};

word:
WORD
{

  defineparenthesis = 0;
  if (translate == 1 && verilog == 0)
    {
	  if(opencorchfound==0){
		strcpy (lastword, (char *) $1);
	  }
	
      if (processfound)
	{
	  if(lastswitch){
	    openedcase=0;
	  }else if (openedcase){
	      fprintf (file, " :\n");

	      for (i = 0; i < openedkeys; i++)
		fprintf (file, "   ");

              fprintf(file,"begin\n");
	      openedcase=0;
	  }
          if (end_struct){
             end_struct=0;
	     struct_found=0;
	     ignore_semicolon=1;
             structslist=InsertStruct(structslist,(char *)$1,structsreglist);

             //ShowStructs(structslist);

             /*Now we should convert all the elements of the struct into regs*/
             StructRegNode *srll;
 	     SGLIB_LIST_MAP_ON_ELEMENTS (StructRegNode,structsreglist, srll,next,
	     {
               if(srll->length==0)
  	         fprintf (regs_file, "reg ");
	       else
   	         fprintf (regs_file, "reg[%d:0] ", (-1 +srll->length));
                 
               regname =(char *) malloc (sizeof (char) * (strlen (srll->name) + 1));
               regname2 = (char *) malloc (sizeof (char) * (strlen (srll->name) + strlen (processname)+strlen((char *)$1)) + 1);
	       strcpy (regname, srll->name);
	       strcpy (regname2, srll->name);
	       strcat (regname, (char *)$1);
               strcat (regname2, (char *)$1);
               strcat (regname2, processname);
               fprintf (regs_file, "%s;\n", regname2); /*By the moment no arrays inside the struct supported*/
	     
 	       regslist = InsertReg (regslist, regname, regname2);
  	       free (regname);
	       free (regname2);
               structsreglist=NULL;
	       reg_found=0; /*To avoid arrays in sructs the interpretation finish here*/
          sigreg_found = 0;
             );}

          }else if(struct_found && (reg_found || sigreg_found)){
              structsreglist=InsertStructReg(structsreglist,(char *)$1,reglenght);
              
          }else if (reg_found || sigreg_found){
	      if(writelenght){
	       writelenght=0;
  	       if(reglenght==0)
            if(sigreg_found) 
 	            fprintf (regs_file, "reg signed");
            else
               fprintf (regs_file, "reg ");
	       else
            if(sigreg_found)
               fprintf (regs_file, "reg signed [%d:0] ", (-1 +reglenght));
            else
   	        fprintf (regs_file, "reg [%d:0] ", (-1 +reglenght));
	      } 
         
	      regname =	(char *) malloc (sizeof (char) * (strlen ((char *) $1) + 1));
	      regname2 = (char *) malloc (sizeof (char) * (strlen ((char *) $1) + strlen (processname)) + 1);
	      strcpy (regname, (char *) $1);
	      strcpy (regname2, (char *) $1);
	      strcat (regname2, processname);
	      fprintf (regs_file, "%s", regname2);

	      regslist = InsertReg (regslist, regname, regname2);
	      free (regname);
	      free (regname2);
	  }else if(integer_found){
	      regname =	(char *) malloc (sizeof (char) * (strlen ((char *) $1) + 1));
	      regname2 = (char *) malloc (sizeof (char) * (strlen ((char *) $1) + strlen (processname)) + 1);
	      strcpy (regname, (char *) $1);
	      strcpy (regname2, (char *) $1);
	      strcat (regname2, processname);
	      fprintf (regs_file, "%s;\n", regname2);

	      regslist = InsertReg (regslist, regname, regname2);

	      //After adding to list print it
	      fprintf (file, "%s ", regname2);
              integer_found=0;
	      free (regname);
	      free (regname2);
     
	  }else{
              
	      if (newline){
                for (i = 0; i < openedkeys; i++)
                  fprintf (file, "   ");
              }
	     
	      regname2 = IsReg (regslist, (char *) $1);
	      if (regname2 == NULL){
                if (IsDefine (defineslist, (char *) $1)){
		   if (ifdeffound == 0){
                      fprintf (file, "`%s", (char *) $1);
                      defineinvocationfound = 1;
                   }else{
                      fprintf (file, "%s", (char *) $1);
                      ifdeffound = 0;
                   }
                }else{
	           fprintf (file, "%s ", (char *) $1);
	        }
             }else
		fprintf (file, "%s", regname2);

             newline = 0;
	  }

        }else if (definefound)
	{

	  if (IsDefine (defineslist, (char *) $1))
	    {

	      fprintf (FILE_DEFINES, "`%s", (char *) $1);
	    }
	  else
	    {
	      fprintf (FILE_DEFINES, "%s ", (char *) $1);
	    }
	}
    }
  else if (verilog == 1)
    fprintf (file, "%s ", (char *) $1);
  lastswitch=0;
};

symbol:
SYMBOL
{
  defineparenthesis = 0;
  if (translate == 1 && verilog == 0)
    {
      if (processfound)
	{
	  if (reg_found || sigreg_found)
	    fprintf (regs_file, "%s", (char *) $1);
	  else
	    fprintf (file, "%s", (char *) $1);
	}
      else if (definefound)
	{
	  fprintf (FILE_DEFINES, "%s", (char *) $1);
	}
    }
  else if (verilog == 1)
    fprintf (file, "%s", (char *) $1);
};

equal:
EQUALS
{
  defineparenthesis = 0;
  reg_found=0;
  sigreg_found=0;
  if (translate == 1 && verilog == 0)
  {
   if (processfound)
	fprintf (file, "=");
	writingvar=1;
  }
  else if (definefound)
    fprintf (FILE_DEFINES, "=");
  else if (verilog == 1)
    fprintf (file, "=");
    
}

write:
WRITE
{
  defineparenthesis = 0;
  if (translate == 1 && verilog == 0)
    {
      writemethod = 1;
      if (processfound)
	{
	  fprintf (file, " <= ");
	  fprintf (FILE_WRITES, "%s\n", lastword);
	}
      else if (definefound)
	{
	  fprintf (FILE_DEFINES, " <= ");
	}

    }
  else if (verilog == 1)
    {
      fprintf (file, ".write");
    }
};

newline:
NEWLINE
{
  defineparenthesis = 0;
  writingvar=0;
  if (translate == 1 && verilog == 0)
    {
      if (processfound & !reg_found & !openedcase & !sigreg_found)
	{
	  fprintf (file, "\n");
	  newline = 1;
	}
      else if (definefound)
	{
	  fprintf (FILE_DEFINES, "\n");
	}

    }
  else if (verilog == 1)
    fprintf (file, "\n");
};

colon:
COLON
{
  defineparenthesis = 0;
  if (translate == 1 && verilog == 0)
    {
      if (processfound)
	{
	  if (reg_found || sigreg_found)
	    {
	      fprintf (regs_file, ",");
	    }
	  else
	    fprintf (file, ",");
	}
      else if (definefound)
	{
	  fprintf (FILE_DEFINES, ",");
	}
    }
  else if (verilog == 1)
    fprintf (file, ",");
};

semicolon:
SEMICOLON
{
  defineparenthesis = 0;
  if (translate == 1 && verilog == 0)
    {
      if (processfound && !struct_found && !ignore_semicolon)
	{
	  if (reg_found || sigreg_found)
	    {
	      fprintf (regs_file, ";\n");
	      reg_found = 0;
         sigreg_found = 0;
	    }
	  else
	    {
	    if (defineinvocationfound == 0 || writingvar)
		  fprintf (file, ";");
	    }
	}
      else if (definefound)
	{
	  fprintf (FILE_DEFINES, ";");
	}
    }
  else if (verilog == 1)
    fprintf (file, ";");
  
  writingvar=0;
  defineinvocationfound = 0;
  ignore_semicolon=0;
};


openpar:
OPENPAR
{
  defineparenthesis = 1;
  if (translate == 1 && verilog == 0 && defineinvocationfound == 0)
    {
      if (processfound)
	{
	  fprintf (file, "(");
	}
      else if (definefound)
	{
	  fprintf (FILE_DEFINES, "(");
	}

    }
  else if (verilog == 1)
    {
      fprintf (file, "(");
    }
  //If par after a sc_reg declaration the declaration is a type cast  
  reg_found=0;
  sigreg_found=0;
}

closepar:
CLOSEPAR
{
  if (translate == 1 && verilog == 0)
    {

      if (processfound)
	{
	  if (defineparenthesis == 0)
	    {
	      fprintf (file, ")");
	      defineinvocationfound = 0;
	    }
	}
      else if (definefound)
	{
	  fprintf (FILE_DEFINES, ")");
	}
    }
  else if (verilog == 1)
    fprintf (file, ")");

};


opencorch:
OPENCORCH
{
  defineparenthesis = 0;
  if (translate == 1 && verilog == 0)
    {
      if (processfound)
	{
	  opencorchfound = 1;
	  if (reg_found || sigreg_found)
	    {
	      fprintf (regs_file, "[");
	    }
	  else
	    fprintf (file, "[");
	}
      else if (definefound)
	{
	  fprintf (FILE_DEFINES, "[");

	}
    }
  else if (verilog == 1)
    fprintf (file, "[");
};

closecorch:
CLOSECORCH
{
  defineparenthesis = 0;
  if (translate == 1 && verilog == 0)
    {
      if (processfound)
	  { 
	  opencorchfound = 0;
	  if (reg_found || sigreg_found)
	    {
	      fprintf (regs_file, "]");
	    }
	  else
	    fprintf (file, "]");
	}
      else if (definefound)
	{
	  fprintf (FILE_DEFINES, "]");
	}
    }
  else if (verilog == 1)
    fprintf (file, "]");
};


openkey:
OPENKEY
{
  defineparenthesis = 0;
  if (translate == 1 && verilog == 0)
    {
      openedkeys++;
      if (!definefound)
	{
	  if (openedkeys == 1)
	    {
	      printf ("Found process %s\n", processname);
	      file = fopen (processname2, (char *) "w");
	      regs_file = fopen (fileregs, (char *) "w");
	      processfound = 1;
	    }
	  if (processfound)
	    if (openedkeys != switchparenthesis[switchfound])
	      {
		fprintf (file, "\n");
		for (i = 0; i < openedkeys; i++)
		  fprintf (file, "   ");
		fprintf (file, "begin\n");
		newline = 1;
	      }
	}
    }
  else if (verilog == 1)
    fprintf (file, "{");
};

closekey:
CLOSEKEY
{
  defineparenthesis = 0;
  if(struct_found){
    end_struct=1;
  }else if (translate == 1 && verilog == 0){
      if (processfound && !definefound){
	  if (openedkeys == switchparenthesis[switchfound] && switchfound > 0){
	      fprintf (file, "\n");
	      if (default_found & !default_break_found){
		  for (i = 0; i < openedkeys - 1; i++)
		    fprintf (file, "   ");
		  fprintf (file, "end\n");
		  default_found = 0;
              }
	      for (i = 0; i < openedkeys - 1; i++)
                fprintf (file, "   ");

              fprintf (file, "endcase\n");
              newline = 1;
              switchparenthesis[switchfound] = 0;
              switchfound--;
          }else{
	      fprintf (file, "\n");
	      for (i = 0; i < openedkeys; i++)
		fprintf (file, "   ");
	      fprintf (file, "end\n");
	      newline = 1;
	  }
      }

      openedkeys--;
      if (definefound)
	{
	  definefound = 0;
	  if (processfound)
	    fprintf (file, "\n//Dummy Comment\n");
	  else
	    fprintf (FILE_DEFINES, "\n//Dummy Comment\n");
	}
      else if (openedkeys == 0)
	{
	  fclose (file);
	  fclose (regs_file);
	  processfound = 0;
          /*Clear process struct list*/
          structslist=NULL;
	}
    }
  else if (verilog == 1)
    fprintf (file, "}");
};


bigger:
BIGGER
{
  defineparenthesis = 0;
  if (translate == 1 && verilog == 0)
    {
      if (processfound)
	{
	  fprintf (file, ">");
	}
      else if (definefound)
	{
	  fprintf (FILE_DEFINES, ">");
	}
    }
  else if (verilog == 1)
    fprintf (file, ">");
};

lower:
LOWER
{
  defineparenthesis = 0;
  if (translate == 1 && verilog == 0)
    {
      if (processfound)
	{
	  fprintf (file, "<");
	}
      else if (definefound)
	{
	  fprintf (FILE_DEFINES, "<");
	}
    }
  else if (verilog == 1)
    fprintf (file, "<");
};


switch:
SWITCH
  {
    defineparenthesis = 0;
    lastswitch=1;
    if (translate == 1 && verilog == 0)
      {
	if (processfound && !openedcase)
	  {
	    fprintf (file, "\n");
	    for (i = 0; i < openedkeys; i++)
	      fprintf (file, "   ");
	    fprintf (file, "case");
	    switchfound++;
	    switchparenthesis[switchfound] = openedkeys + 1;
	  }else if (processfound)
	  {
  	    fprintf (file, ":\n");
            for (i = 0; i < openedkeys; i++)
	      fprintf (file, "   ");
	    fprintf(file,"begin\n");
	    for (i = 0; i < openedkeys; i++)
	      fprintf (file, "   ");
	    fprintf (file, "case");
	    switchfound++;
	    switchparenthesis[switchfound] = openedkeys + 1;
	  }
      }
    else if (verilog == 1)
      fprintf (file, "switch");
  };

case_number:
CASE NUMBER SYMBOL
{
  defineparenthesis = 0;
  if (translate == 1 && verilog == 0)
    {
      if (processfound)
	{
	 if (!openedcase)
	  for (i = 0; i < openedkeys; i++)
	    fprintf (file, "   ");
	  if (openedcase)
	    fprintf (file, ", %d", $2);
	  else
	    fprintf (file, "%d", $2);

	  newline = 1;
	  openedcase = 1;

	}
    }
  else if (verilog == 1)
    fprintf (file, "case %d %s", $2, (char *) $3);
};

case_hexnumber:
CASE HEXA NUMBER SYMBOL
{
  //Is a dec number
  defineparenthesis = 0;
  if (translate == 1 && verilog == 0)
    {
      if (processfound)
	{
	 if (!openedcase)
	  for (i = 0; i < openedkeys; i++)
	    fprintf (file, "   ");
	  if (openedcase)
	    fprintf (file, ", 'h%d", $3);
	  else
	    fprintf (file, "'h%d", $3);

	  newline = 1;
	  openedcase = 1;

	}
    }
  else if (verilog == 1)
    fprintf (file, "case %d %s", $3, (char *) $4);
};

case_hexword:
CASE HEXA WORD SYMBOL
{
  //Begin with a-F
  defineparenthesis = 0;
  if (translate == 1 && verilog == 0)
    {
      if (processfound)
	{
	 if (!openedcase)
	  for (i = 0; i < openedkeys; i++)
	    fprintf (file, "   ");
	  if (openedcase)
	    fprintf (file, ", 'h%s", (char *)$3);
	  else
	    fprintf (file, "'h%s", (char *)$3);

	  newline = 1;
	  openedcase = 1;

	}
    }
  else if (verilog == 1)
    fprintf (file, "case 0x%s %s", (char *)$3, (char *) $4);
};

case_hexnumberword:
CASE HEXA NUMBER WORD SYMBOL
{
  //Hex number beginning with dec number
  defineparenthesis = 0;
  if (translate == 1 && verilog == 0)
    {
      if (processfound)
	{
	 if (!openedcase)
	  for (i = 0; i < openedkeys; i++)
	    fprintf (file, "   ");
	  if (openedcase)
	    fprintf (file, ", 'h%d%s", $3,(char *)$4);
	  else
	    fprintf (file, "'h%d%s", $3,(char *)$4);

	  newline = 1;
	  openedcase = 1;

	}
    }
  else if (verilog == 1)
    fprintf (file, "case %d%s %s", $3, (char *) $4, (char *)$5);
};

case_word:
CASE WORD SYMBOL
{
  defineparenthesis = 0;
  if (translate == 1 && verilog == 0)
    {
      if (processfound)
	{
	 if (!openedcase)
	  for (i = 0; i < openedkeys; i++)
	    fprintf (file, "   ");
	  if (openedcase){
	    if (IsDefine (defineslist, (char *) $2))
	      fprintf (file, ", `%s", (char *) $2);
		else
		  fprintf (file, ", %s", (char *) $2);
	  }else{
	    if (IsDefine (defineslist, (char *) $2))
	      fprintf (file, "`%s", (char *) $2);
		else
		  fprintf (file, "%s", (char *) $2);
      }
	  newline = 1;
	  openedcase = 1;

	}
    }
  else if (verilog == 1)
    fprintf (file, "case %s %s", (char *) $2, (char *) $3);
};

case_default:
DEFAULT SYMBOL
{
  defineparenthesis = 0;
  if (translate == 1 && verilog == 0)
    {
      if (processfound)
	{
	 if (!openedcase)
	  for (i = 0; i < openedkeys; i++)
	    fprintf (file, "   ");
	  fprintf (file, "default:\n");
	  for (i = 0; i < openedkeys; i++)
	    fprintf (file, "   ");
	  fprintf (file, "begin\n");
	  newline = 1;
	  default_found = 1;
	}
    }
  else if (verilog == 1)
    fprintf (file, "default %s", (char *) $2);
};

case_only:
CASE OPENPAR
{
  defineparenthesis = 0;
  //This rule occurs when in Verilog mode a case appears
  if (verilog == 1)
    fprintf (file, "case(");
};

break:
BREAK SEMICOLON
{
  defineparenthesis = 0;
  if (translate == 1 && verilog == 0)
    {
      if (processfound)
	{
	  if (newline == 0)
	    fprintf (file, "\n");
	  for (i = 0; i < openedkeys; i++)
	    fprintf (file, "   ");
	  fprintf (file, "end\n");
	  if (default_found)
	    {
	      default_break_found = 1;
	    }
	}
    }
  else if (verilog == 1)
    fprintf (file, "break;");
};

hexa:
HEXA
{
  defineparenthesis = 0;
  if (translate == 1 && verilog == 0)
    {
      if (processfound)
	{
	  fprintf (file, "'h");
	}
      else if (definefound)
	{
	  fprintf (FILE_DEFINES, "'h");
	}
    }
  else if (verilog == 1)
    fprintf (file, "0x");
};

translateoff:
TRANSLATEOFF
{
  defineparenthesis = 0;
  translate = 0;
  fprintf (stderr, "line: %d Found Translate off directive \n", lineno);
};

translateon:
TRANSLATEON
{
  defineparenthesis = 0;
  translate = 1;
  fprintf (stderr, "line: %d Found Translate on directive \n", lineno);
};

verilogbegin:
VERILOGBEGIN
{
  defineparenthesis = 0;
  verilog = 1;
  fprintf (stderr, "line: %d Found Verilog Begin directive \n", lineno);
};

verilogend:
VERILOGEND
{
  defineparenthesis = 0;
  verilog = 0;
  fprintf (stderr, "line: %d Found Verilog End directive \n", lineno);
};

ifdef:
PIFDEF
{
  defineparenthesis = 0;
  if (translate == 1 && verilog == 0)
    {
      if (processfound)
	{
	  ifdeffound = 1;
	  fprintf (file, "`ifdef");
	}
      else if (definefound)
	{
	  fprintf (FILE_DEFINES, "`ifdef");
	}
    }
  else if (verilog == 1)
    fprintf (file, "#ifdef");
};

ifndef:
PIFNDEF
{
  defineparenthesis = 0;
  if (translate == 1 && verilog == 0)
    {
      if (processfound)
	{
	  ifdeffound = 1;
	  fprintf (file, "`ifndef");
	}
      else if (definefound)
	{
	  fprintf (FILE_DEFINES, "`ifndef");
	}
    }
  else if (verilog == 1)
    fprintf (file, "#ifndef");
};

endif:
PENDDEF
{
  defineparenthesis = 0;
  if (translate == 1 && verilog == 0)
    {
      if (processfound)
	{
	  fprintf (file, "`endif");
	}
      else if (definefound)
	{
	  fprintf (FILE_DEFINES, "`endif");
	}
    }
  else if (verilog == 1)
    fprintf (file, "#endif");
};

pelse:
PELSE
{
  defineparenthesis = 0;
  if (translate == 1 && verilog == 0)
    {
      if (processfound)
	{
	  fprintf (file, "`else");
	}
      else if (definefound)
	{
	  fprintf (FILE_DEFINES, "`else");
	}
    }
  else if (verilog == 1)
    fprintf (file, "#else");
};

ttrue:
TTRUE
{
  defineparenthesis = 0;
  if (translate == 1 && verilog == 0)
    {
      if (processfound)
	{
	  fprintf (file, "1");
	}
    }
  else if (verilog == 1)
    fprintf (file, "1");
};


tfalse:
TFALSE
{
  defineparenthesis = 0;
  if (translate == 1 && verilog == 0)
    {
      if (processfound)
	{
	  fprintf (file, "0");
	}
    }
  else if (verilog == 1)
    fprintf (file, "0");
};
 
comment:
COMMENT
{
if(processfound){
  //To manage comments inside switch statements
  if(lastswitch){
	openedcase=0;
  }else if (openedcase){
	fprintf (file, " :\n");
      for (i = 0; i < openedkeys; i++)
		fprintf (file, "   ");
        fprintf(file,"begin\n");
        openedcase=0;
  }
  //indent
  if(newline){
    for (i = 0; i < openedkeys; i++)
	  fprintf (file, "   ");
	newline=0;
  }
  fprintf (file, " %s", (char *)$1);
 }
}

struct_dec:
STRUCT OPENKEY
{
  struct_found=1;
}

