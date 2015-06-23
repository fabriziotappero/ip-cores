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

  int module_found = 0;
  int concat_found = 0;
  int opened_pars;
  int *concat_par_num;
  int concats_found = 0;
  int lastsymbol=0;
  char *aux;
  void yyerror (const char *str)
  {
    fprintf (stderr, "error: %s\n", str);
  }

  int yywrap ()
  {
    return 1;
  }

  main ()
  {
    concat_par_num = (int *) malloc (16 * sizeof (int));
    *concat_par_num = 0;
    yyparse ();

  }

%}

%token WORD WORDCOLON
%token OPENPAR CLOSEPAR 
%token MODULE SYMBOL

%% commands:
/* empty */
|commands command;


command:
module 
| 
closepar 
| 
concat 
|
openpar
|
word
|
symbol;

module:
MODULE
{
  lastsymbol=0;
  module_found = 1;
  opened_pars++;
  printf ("%s", (char *) $1);
};

openpar:
OPENPAR
{
  printf ("(");
  opened_pars++;
};

closepar:
CLOSEPAR
{
  if (module_found)
    {
      printf (")");
      opened_pars--;
      module_found = 0;
    }
  else if (concat_found)
    {
      if (opened_pars == *(concat_par_num + concats_found))
	{
	  printf ("}");
	  concats_found--;
	  if (concats_found == 0)
	    {
	      concat_found = 0;
	    }
	}
      else
	{
	  printf (")");
	}
      opened_pars--;
    }
  else
    {
      opened_pars--;
      printf (")");
    }
};

concat:
WORDCOLON
{
 if(lastsymbol==1){
  aux = (char *) $1;
  aux++;
  printf ("{%s", aux);
  concat_found = 1;
  opened_pars++;
  concats_found++;
  *(concat_par_num + concats_found) = opened_pars;
 }else{
   printf ("%s", (char *)$1);
 } 
 lastsymbol=0;
};

symbol:
SYMBOL
{
  lastsymbol=1;
  printf("%c",*((char *)$1));
};

word:
WORD
{
  lastsymbol=0;
  printf("%s",(char *)$1);
};
