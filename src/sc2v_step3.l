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
#include "y.tab.h"

extern int yylval;

%}

%%
"module"[" "]*[a-zA-Z][_a-zA-Z0-9]*[" "]*["("] yylval=(int)strdup(yytext); return MODULE;
"("[" "]*[a-zA-Z][_a-zA-Z0-9" "\[\]:]*[,][ ]*  yylval=(int)strdup(yytext); return WORDCOLON;
[" "]*[a-zA-Z][_a-zA-Z0-9" "\[\]:]*            yylval=(int)strdup(yytext); return WORD;
"("[ ]*                                        return OPENPAR;
[ ]*")"                                        return CLOSEPAR;
[.:"^"!%=/+*_"&""-"<>"?""|""\\"][ ]*           yylval=(int)strdup(yytext); return SYMBOL;


%%
