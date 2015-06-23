// ============================================================================
// (C) 2012 Robert Finch
// All Rights Reserved.
// robfinch<remove>@opencores.org
//
// C64 - Raptor64 'C' derived language compiler
//  - 64 bit CPU
//
// This source file is free software: you can redistribute it and/or modify 
// it under the terms of the GNU Lesser General Public License as published 
// by the Free Software Foundation, either version 3 of the License, or     
// (at your option) any later version.                                      
//                                                                          
// This source file is distributed in the hope that it will be useful,      
// but WITHOUT ANY WARRANTY; without even the implied warranty of           
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            
// GNU General Public License for more details.                             
//                                                                          
// You should have received a copy of the GNU General Public License        
// along with this program.  If not, see <http://www.gnu.org/licenses/>.    
//                                                                          
// ============================================================================
//
#include <stdio.h>
#include "c.h"
#include "expr.h"
#include "gen.h"
#include "cglbdec.h"

int IdentifyKeyword()
{
	char *p = lastid;

	if (p[0]=='i') { // if,int,inton,intoff,interrupt,icache
		if (p[1]=='f' && p[2]=='\0')
			return lastst = kw_if;
		if (p[1]=='n' && p[2]=='t' && p[3]=='\0')
			return lastst = kw_int;
		if (p[1]=='n' && p[2]=='t' && p[3]=='o' && p[4]=='n' && p[5]=='\0')
			return lastst = kw_inton;
		if (p[1]=='n' && p[2]=='t' && p[3]=='o' && p[4]=='f' && p[5]=='f' && p[6]=='\0')
			return lastst = kw_intoff;
		if (p[1]=='n' && p[2]=='t' && p[3]=='e' && p[4]=='r' && p[5]=='r' && p[6]=='u' && p[7]=='p' && p[8]=='t' && p[9]=='\0')
			return lastst = kw_interrupt;
		if (p[1]=='c' && p[2]=='a' && p[3]=='c' && p[4]=='h' && p[5]=='e' && p[6]=='\0')
			return lastst = kw_icache;
	}

	if (p[0]=='b' && p[1]=='r' && p[2]=='e' && p[3]=='a' && p[4]=='k' && p[5]=='\0')
		return lastst = kw_break;
	if (p[0]=='b' && p[1]=='y' && p[2]=='t' && p[3]=='e' && p[4]=='\0')
		return lastst = kw_byte;
	if (p[0]=='w' && p[1]=='h' && p[2]=='i' && p[3]=='l' && p[4]=='e' && p[5]=='\0')
		return lastst = kw_while;

	if (p[0]=='d') {	// do,default,double,dcache
		if (p[1]=='o' && p[2]=='\0')
			return lastst = kw_do;
		if (p[1]=='o' && p[2]=='u' && p[3]=='b' && p[4]=='l' && p[5]=='e' && p[6]=='\0')
			return lastst = kw_double;
		if (p[1]=='e' && p[2]=='f' && p[3]=='a' && p[4]=='u' && p[5]=='l' && p[6]=='t' && p[7]=='\0')
			return lastst = kw_default;
		if (p[1]=='c' && p[2]=='a' && p[3]=='c' && p[4]=='h' && p[5]=='e' && p[6]=='\0')
			return lastst = kw_dcache;
	}

	if (p[0]=='o') {	// or,oscall
		if (p[1]=='r' && p[2]=='\0')
			return lastst = lor;
		if (p[1]=='s' && p[2]=='c' && p[3]=='a' && p[4]=='l' && p[5]=='l' && p[6]=='\0')
			return lastst = kw_oscall;
	}

	if (p[0]=='c') {	// case,catch,char,continue
		if(p[1]=='a' && p[2]=='s' && p[3]=='e' && p[4]=='\0')
			return lastst = kw_case;
		if(p[1]=='a' && p[2]=='t' && p[3]=='c' && p[4]=='h' && p[5]=='\0')
			return lastst = kw_catch;
		if(p[1]=='h' && p[2]=='a' && p[3]=='r' && p[4]=='\0')
			return lastst = kw_char;
		if (p[1]=='o' && p[2]=='n' && p[3]=='t' && p[4]=='i' && p[5]=='n' && p[6]=='u' && p[7]=='e' && p[8]=='\0')
			return lastst = kw_continue;
		if (p[1]=='r' && p[2]=='i' && p[3]=='t' && p[4]=='i' && p[5]=='c' && p[6]=='a' && p[7]=='l' && p[8]=='\0')
			return lastst = kw_critical;
	}

	if (p[0]=='l') {	// long,loop,lockfail
		if (p[1]=='o' && p[2]=='n' && p[3]=='g' && p[4]=='\0')
			return lastst = kw_long;
		if (p[1]=='o' && p[2]=='o' && p[3]=='p' && p[4]=='\0')
			return lastst = kw_loop;
		if (p[1]=='o' && p[2]=='c' && p[3]=='k' && p[4]=='f' && p[5]=='a' && p[6]=='i' && p[7]=='l' && p[8]=='\0')
			return lastst = kw_lockfail;
	}

	if (p[0]=='s') {	// switch,short,static,stop,struct,sizeof,signed
		if (p[1]=='w' && p[2]=='i' && p[3]=='t' && p[4]=='c' && p[5]=='h' && p[6]=='\0')
			return lastst = kw_switch;
		if (p[1]=='t' && p[2]=='a' && p[3]=='t' && p[4]=='i' && p[5]=='c' && p[6]=='\0')
			return lastst = kw_static;
		if (p[1]=='h' && p[2]=='o' && p[3]=='r' && p[4]=='t' && p[5]=='\0')
			return lastst = kw_short;
		if (p[1]=='t' && p[2]=='o' && p[3]=='p' && p[4]=='\0')
			return lastst = kw_stop;
		if (p[1]=='t' && p[2]=='r' && p[3]=='u' && p[4]=='c' && p[5]=='t' && p[6]=='\0')
			return lastst = kw_struct;
		if (p[1]=='i' && p[2]=='z' && p[3]=='e' && p[4]=='o' && p[5]=='f' && p[6]=='\0')
			return lastst = kw_sizeof;
		if (p[1]=='i' && p[2]=='g' && p[3]=='n' && p[4]=='e' && p[5]=='d' && p[6]=='\0')
			return lastst = kw_signed;
	}

	if (p[0]=='t') {	// typedef,typenum,throw,then,try
		if (p[1]=='y' && p[2]=='p' && p[3]=='e' && p[4]=='d' && p[5]=='e' && p[6]=='f' && p[7]=='\0')
			return lastst = kw_typedef;
		if (p[1]=='y' && p[2]=='p' && p[3]=='e' && p[4]=='n' && p[5]=='u' && p[6]=='n' && p[7]=='\0')
			return lastst = kw_typenum;
		if (p[1]=='h' && p[2]=='r' && p[3]=='o' && p[4]=='w' && p[5]=='\0')
			return lastst = kw_throw;
		if (p[1]=='h' && p[2]=='e' && p[3]=='n' && p[4]=='\0')
			return lastst = kw_then;
		if (p[1]=='r' && p[2]=='y' && p[3]=='\0')
			return lastst = kw_try;
	}

	if (p[0]=='g' && p[1]=='o' && p[2]=='t' && p[3]=='o' && p[4]=='\0')
		return lastst = kw_goto;
	if (p[0]=='j' && p[1]=='u' && p[2]=='m' && p[3]=='p' && p[4]=='\0')
		return lastst = kw_goto;

	if (p[0]=='e') {	// else,enum,extern
		if (p[1]=='l' && p[2]=='s' && p[3]=='e' && p[4]=='\0')
			return lastst = kw_else;
		if (p[1]=='l' && p[2]=='s' && p[3]=='i' && p[4]=='f' && p[5]=='\0')
			return lastst = kw_elsif;
		if (p[1]=='n' && p[2]=='u' && p[3]=='m' && p[4]=='\0')
			return lastst = kw_enum;
		if (p[1]=='x' && p[2]=='t' && p[3]=='e' && p[4]=='r' && p[5]=='n' && p[6]=='\0')
			return lastst = kw_extern;
	}
	if (p[0]=='a') {	// and,asm
		if (p[1]=='n' && p[2]=='d' && p[3]=='\0')
			return lastst = land;
		if (p[1]=='s' && p[2]=='m' && p[3]=='\0')
			return lastst = kw_asm;
	}
	if (p[0]=='v' && p[1]=='o' && p[2]=='i' && p[3]=='d' && p[4]=='\0')
		return lastst = kw_void;
	if (p[0]=='r' && p[1]=='e') {	// return,register
		if (p[2]=='t' && p[3]=='u' && p[4]=='r' && p[5]=='n' && p[6]=='\0')
			return lastst = kw_return;
		if (p[2]=='g' && p[3]=='i' && p[4]=='s' && p[5]=='t' && p[6]=='e' && p[7]=='r' && p[8]=='\0')
			return lastst = kw_register;
	}
	if (p[0]=='l' && p[1]=='o' && p[2]=='o' && p[3]=='p' && p[4]=='\0')
		return lastst = kw_loop;
	if (p[0]=='u') {	// unsigned,union,until
		if (p[1]=='n' && p[2]=='s' && p[3]=='i' && p[4]=='g' && p[5]=='n' && p[6]=='e' && p[7]=='d' && p[8]=='\0')
			return lastst = kw_unsigned;
		if (p[1]=='n' && p[2]=='i' && p[3]=='o' && p[4]=='n' && p[5]=='\0')
			return lastst = kw_union;
		if (p[1]=='n' && p[2]=='t' && p[3]=='i' && p[4]=='l' && p[5]=='\0')
			return lastst = kw_until;
	}
	if (p[0]=='f') {	// float,forever,for,fallthru,firstcall
		if (p[1]=='o' && p[2]=='r' && p[3]=='\0')
			return lastst = kw_for;
		if (p[1]=='l' && p[2]=='o' && p[3]=='a' && p[4]=='t' && p[5]=='\0')
			return lastst = kw_float;
		if (p[1]=='o' && p[2]=='r' && p[3]=='e' && p[4]=='v' && p[5]=='e' && p[6]=='r' && p[7]=='\0')
			return lastst = kw_forever;
		if (p[1]=='a' && p[2]=='l' && p[3]=='l' && p[4]=='t' && p[5]=='h' && p[6]=='r' && p[7]=='u' && p[8]=='\0')
			return lastst = kw_fallthru;
		if (p[1]=='i' && p[2]=='r' && p[3]=='s' && p[4]=='t' && p[5]=='c' && p[6]=='a' && p[7]=='l' && p[8]=='l' && p[9]=='\0')
			return lastst = kw_firstcall;
	}
	if (p[0]=='m' && p[1]=='o' && p[2]=='d' && p[3]=='\0')
		return lastst = modop;

	if (p[0]=='p') {	// private,public,pascal
		if (p[1]=='r' && p[2]=='i' && p[3]=='v' && p[4]=='a' && p[5]=='t' && p[6]=='e' && p[7]=='\0')
			return lastst = kw_private;
		if (p[1]=='u' && p[2]=='b' && p[3]=='l' && p[4]=='i' && p[5]=='c' && p[6]=='\0')
			return lastst = kw_public;
		if (p[1]=='a' && p[2]=='s' && p[3]=='c' && p[4]=='a' && p[5]=='l' && p[6]=='\0')
			return lastst = kw_pascal;
	}
	if (p[0]=='n') {	// nocall
		if (p[1]=='o' && p[2]=='c' && p[3]=='a' && p[4]=='l' && p[5]=='l' && p[6]=='\0')
			return lastst = kw_nocall;
	}
	// __spinlock,__spinunlock
	if (p[0]=='s' && p[1]=='p' && p[2]=='i' && p[3]=='n' && p[4]=='l' && p[5]=='o' && p[6]=='c' && p[7]=='k' && p[8]=='\0')
		return lastst = kw_spinlock;
	if (p[0]=='s' && p[1]=='p' && p[2]=='i' && p[3]=='n' && p[4]=='u' && p[5]=='n' && p[6]=='l' && p[7]=='o' && p[8]=='c' && p[9]=='k' && p[10]=='\0')
		return lastst = kw_spinunlock;

	if (p[0]=='f' && p[1]=='a' && p[2]=='l' && p[3]=='s' && p[4]=='e' && p[5]=='\0') {
		ival = 0;
		return lastst = iconst;
	}
	if (p[0]=='t' && p[1]=='r' && p[2]=='u' && p[3]=='e' && p[4]=='\0') {
		ival = 1;
		return lastst = iconst;
	}

	return 0;
}
