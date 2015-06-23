/*
   Copyright 2011 Martin Schoeberl <masca@imm.dtu.dk>,
                  Technical University of Denmark, DTU Informatics. 
   All rights reserved.

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are met:

      1. Redistributions of source code must retain the above copyright notice,
         this list of conditions and the following disclaimer.

      2. Redistributions in binary form must reproduce the above copyright
         notice, this list of conditions and the following disclaimer in the
         documentation and/or other materials provided with the distribution.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER ``AS IS'' AND ANY EXPRESS
   OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
   OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN
   NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
   DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
   (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
   ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
   THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

   The views and conclusions contained in the software and documentation are
   those of the authors and should not be interpreted as representing official
   policies, either expressed or implied, of the copyright holder.
 */

//
// Grammar and lexical rules for the Leros assembler
// Start with a copy of Patmos

grammar Leros;

@header {
package leros.asm.generated;

import java.util.HashMap;
import java.util.List;

}

@lexer::header {package leros.asm.generated;}


@members {
/** Map symbol to Integer object holding the value or address */
HashMap symbols = new HashMap();
// Mapping of register names
HashMap reg = new HashMap();
int pc = 0;
int code[];
boolean pass2 = false;

static {
	// some default names for registers
	for (int i=0; i<16; ++i) {
//		reg.put("r"+i, new Integer(i));
	}
}

public static String niceHex(int val) {
	String s = Integer.toHexString(val);
	while (s.length() < 4) {
		s = "0"+s;
	}
	s = "0x"+s;
	return s;
}
}

pass1: statement+;

dump: {System.out.println(symbols);};

// Don't know how to return a simple int array :-(
pass2 returns [List mem]
@init{
	System.out.println(pc+" "+symbols);
	code = new int[pc];
	pc = 0;
	pass2 = true;
}
	: statement+ {
	$mem = new ArrayList(pc);
	for (int i=0; i<pc; ++i) {
		$mem.add(new Integer(code[i]));
	}
	}; 

statement: (label)? (directive | instruction)? (COMMENT)? NEWLINE;

label:  ID ':' {symbols.put($ID.text, new Integer(pc));};

// just a dummy example
directive: '.start';

instruction: instr
	{
		System.out.println(pc+" "+niceHex($instr.opc));
		if (pass2) { code[pc] = $instr.opc; }
		++pc;
	};

// Is this additional rule needed to get all values up to instruction?
instr returns [int opc] :
	simple {$opc = $simple.opc;} |
	alu register {$opc = $alu.value + $register.value;} |
	alu imm_val {$opc = $alu.value + $imm_val.value + 0x0100;} |
	branch {$opc = $branch.opc;} |
	io imm_val {$opc = $io.value + $imm_val.value;} |
	loadaddr register {$opc = $loadaddr.value + $register.value;} |
	memind {$opc = $memind.value;}
;

simple returns [int opc]:
	'nop'    {$opc = 0x0000;} |
	'shr'    {$opc = 0x1000;}
	;

alu returns [int value]: 
	'add'    {$value = 0x0800;} |
	'sub'    {$value = 0x0c00;} |
	'load'   {$value = 0x2000;} |
	'and'    {$value = 0x2200;} |
	'or'     {$value = 0x2400;} |
	'xor'    {$value = 0x2600;} |
	'loadh'  {$value = 0x2800;} |
	'store'  {$value = 0x3000;} | // TODO: no immediate version
	'jal'    {$value = 0x4000;} // no immediate version
	;

io returns [int value]: 
	'out'    {$value = 0x3800;} |
	'in'     {$value = 0x3c00;}
	;

loadaddr returns [int value]:
	'loadaddr' {$value = 0x5000;}
	;

memind returns [int value]:
	'load' '(' 'ar' '+' imm_val ')' {$value = 0x6000 + $imm_val.value;} |
	'store' '(' 'ar' '+' imm_val ')' {$value = 0x7000 + $imm_val.value;}
	;

branch returns [int opc]:
	brinstr ID
	{
		int off = 0;
		if (pass2) {
			Integer v = (Integer) symbols.get($ID.text);
        		if ( v!=null ) {
				off = v.intValue();
		        } else {
				throw new Error("Undefined label "+$ID.text);
			}
			off = off - pc;
			// TODO test maximum offset
			// at the moment 8 bits offset
			off &= 0xff;
		}
		$opc = $brinstr.value + off;
	};

brinstr returns [int value]:
	'branch' {$value = 0x4800;} |
	'brz' {$value = 0x4900;} |
	'brnz' {$value = 0x4a00;} |
	'brp' {$value = 0x4b00;} |
	'brn' {$value = 0x4c00;}
	;

// shall use register symbols form the HashMap
register returns [int value]:
	REG {$value = Integer.parseInt($REG.text.substring(1));
		if ($value<0 || $value>255) throw new Error("Wrong register name");};

// at the moment just 8 bit immediate
// can be signed or unsigned 
imm_val returns [int value]:
	INT {$value = Integer.parseInt($INT.text);
		if ($value<-128 || $value>255) throw new Error("Wrong immediate");} |
	'-' INT {$value = (-Integer.parseInt($INT.text)) & 0xff;
		if ($value<-128 || $value>255) throw new Error("Wrong immediate");} |
	'<' ID
	{
		int val = 0;
		if (pass2) {
			Integer v = (Integer) symbols.get($ID.text);
        		if ( v!=null ) {
				val = v.intValue() & 0xff;
		        } else {
				throw new Error("Undefined label "+$ID.text);
			}
		}
		$value = val;
	} |
	'>' ID
	{
		int val = 0;
		if (pass2) {
			Integer v = (Integer) symbols.get($ID.text);
        		if ( v!=null ) {
				val = (v.intValue()>>8) & 0xff;
		        } else {
				throw new Error("Undefined label "+$ID.text);
			}
		}
		$value = val;
	}
	;






/* Lexer rules (start with upper case) */

INT :  '0'..'9'+ ;
REG: 'r' INT;
//SINT: '-'? INT;

ID: ('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'_' | '0'..'9')*;

COMMENT: '//' ~('\n'|'\r')* ;

NEWLINE: '\r'? '\n' ;
WHITSPACE:   (' '|'\t')+ {skip();} ;

