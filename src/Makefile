#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU Library General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

#
# Cygwin
#
LEX = flex 
YACC = bison -y
#
# Linux
#
#LEX = lex 
#YACC = yacc 

all:
	$(LEX) sc2v_step1.l
	$(YACC) -d sc2v_step1.y
	gcc lex.yy.c y.tab.c sc2v_step1.c -Isrc -o ../bin/sc2v_step1 -lm

	$(LEX) sc2v_step2.l
	$(YACC) -d sc2v_step2.y 
	gcc lex.yy.c y.tab.c sc2v_step2.c -Isrc -o ../bin/sc2v_step2 -lm

	$(LEX) sc2v_step3.l
	$(YACC) -d sc2v_step3.y
	gcc lex.yy.c y.tab.c -Isrc -o ../bin/sc2v_step3 -lm

clean:
	rm -rf lex.* y.* *.o ../bin/sc2v_step2* ../bin/sc2v_step1* ../bin/sc2v_step3*
