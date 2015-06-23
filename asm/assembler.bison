
%{

#include <assert.h>
#include <stdio.h>
#include <string.h>

extern int yylex();
extern int yyparse();
extern int yyerror(const char *);
extern FILE * out;
extern FILE * list;
extern FILE * sym;
extern FILE * ihx;
static void write_intel_hex(FILE * out);

int PC          = 0;
int reloc_start = 0;   // first PC
int reloc_last  = 0;   // last PC
int reloc_end   = 0;   // end of reloc

char memory[0x10000];
unsigned int mem_idx = 0;

enum ExHow { EX_NAME, EX_NUMBER,
             EX_ADD, EX_SUB, EX_MULT, EX_DIV, EX_MOD };

class Expression
{

public:
   Expression(const char * n)
   : how(EX_NAME),
     ex(0),
     name(n),
     number(0)
     {};

   Expression(int n)
   : how(EX_NUMBER),
     ex(0),
     name(0),
     number(n)
     {};

   Expression(Expression * e, ExHow h, const char * n)
   : how(h),
     ex(e),
     name(n),
     number(0)
     {};

   Expression(Expression * e, ExHow h, int n)
   : how(h),
     ex(e),
     name(0),
     number(n)
     {};

   int GetValue() const;
   int ListBase() const;
   bool UsesName() const
      {
        if (how == EX_NAME)     return true;
        if (how == EX_NUMBER)   return false;
        assert(ex);
        return ex->UsesName();
      }


private:
   const ExHow  how;
   Expression * ex;
   const char * name;
   int          number;
};

enum OP_BASE
{
   EXPR,
   REG_RR, REG_RU, REG_RS, REG_R,
   REG_LL, REG_LU, REG_LS, REG_L,
   REG_SP,
   COND_Z,
   COND_NZ
};

enum OP_ATTR
{
   ATT_NONE,
   ATT_POSTINC,
   ATT_PREDEC,
   ATT_OFFSET,
   ATT_CONTENT,
   ATT_PORT,
   ATT_ADDR,
   ATT_IMM,
};

enum OP_HOW
{
   H_NONE     = 0, // unique opcode
   H_BYTE     = 1,
   H_PORT     = 2, //                       #byte
   H_WORD     = 3, //                                      #word
   H_sBW      = 4, // signed                #byte (01X) or #word (10X)
   H_uBW      = 5, // unsigned              #byte (01X) or #word (10X)
   H_sQBW     = 6, // signed quick       or #byte (01X) or #word (10X)
   H_uQBW     = 7, // unsigned quick     or #byte (01X) or #word (10X)
};

class Operand
{
public:
   Operand(OP_BASE b, const char * txt)
   : base(b), attr(ATT_NONE), expr(0), op_text(txt), offset(0) {};

   Operand(Expression * ex)
   : base(EXPR), attr(ATT_NONE), expr(ex), op_text(0), offset(0) {};

   Operand * PostInc()
      {
        assert(attr == ATT_NONE);
        attr = ATT_POSTINC;
        return this;
      };

   Operand * PreDec()
      {
        assert(attr == ATT_NONE);
        attr = ATT_PREDEC;
        return this;
      };

   Operand * Content()
      {
        assert(base == REG_RR || base == REG_LL);
        assert(attr == ATT_NONE);
        attr = ATT_CONTENT;
        return this;
      };

   Operand * Offset(Operand * offs)
      {
        assert(base != EXPR);
        assert(attr == ATT_NONE);
        attr = ATT_OFFSET;

        assert(offs->base == EXPR);
        assert(offs->attr == ATT_NONE);
        assert(offset == 0);
        offset = offs;
        return this;
      };

   Operand * Port()
      {
        assert(base == EXPR);
        assert(attr == ATT_NONE);
        attr = ATT_PORT;
        return this;
      };

   Operand * AbsAddr()
      {
        assert(base == EXPR);
        assert(attr == ATT_NONE);
        attr = ATT_ADDR;
        return this;
      };

   Operand * Immediate()
     {
        assert(base == EXPR);
        assert(attr == ATT_NONE);
        attr = ATT_IMM;
        return this;
     };

   int  GetLength(OP_HOW how);
   int  GetValue();
   int  ListHex(OP_HOW how);
   int  List(OP_HOW how);
   int  ListBase(OP_HOW how);

private:
   OP_BASE      base;
   OP_ATTR      attr;
   Operand    * offset;
   const char * op_text;   // scanned text
   Expression * expr;
};

class Opcode
{
public:
   Opcode(OP_HOW how, unsigned int opc, const char * txt,
          Operand * op1 = 0, Operand * op2 = 0)
   : op_how(how),
     op_code(opc),
     op_text(txt),
     op_1(op1),
     op_2(op2),
     reloc(reloc_end) {};

   int GetLength() const;
   int GetOpcode(int & len) const;
   int List(int pc);
   void Error() const;

private:
   OP_HOW        op_how;
   unsigned char op_code;
   const char  * op_text;   // opcode text
   Operand     * op_1;    // oerand 1
   Operand     * op_2;    // oerand 2
   bool          reloc;   // true if relocated
};

int Reloc(bool rloc, int value)
{
  if (!rloc)   return value;
   return value + reloc_end - reloc_last;
}

class Symbol
{
public:
   static void Add(const char * id, Expression * ex, bool lab, bool reloc);
   static void ListNonlabels();
   static int GetValue(const char * id);
   static void Reset()   { current = symbols; };
   static void PrintSymbols();
   static void Advance(int pc);

private:
   Symbol(const char * id, Expression * ex, bool lab, bool rloc)
   : identifier(id),
     expr(ex),
     label(lab),
     reloc(rloc),
     tail(0) {};

   const char * identifier;
   Expression * expr;
   Symbol     * tail;
   bool         label;   // true if label
   bool         reloc;   // true if relocated

   static Symbol * symbols;
   static Symbol * current;
};

class Line
{
public:
   static void Add(Opcode * opc);
   static void List();

private:
   Line(Opcode * opc)
   : opcode(opc),
     pc(PC),
     tail(0)
     {};

   int      pc;
   Opcode * opcode;
   Line   * tail;

   static Line * first;
   static Line * last;
};

%}

%token	_BYTE	_WORD	_OFFSET	INT	IDENT	EOL	EOFILE	ERROR
	_LL	_L	_LS	_LU	_RR	_R	_RS	_RU
	_RRZ	_RRNZ	_SP	_EXTERN	_STATIC

	ADD	AND	ASR	CALL	CLRB	CLRW	DI	DIV_IS
	DIV_IU	EI	HALT	IN	JMP	LNOT	LEA	LSL
	LSR	MOVE	MD_STP	MD_FIN	MOD_FIN	MUL_IS	MUL_IU	NEG
	NOP	NOT	OUT	OR	RET	RETI	SEQ	SGE
	SGT	SLE	SLT	SNE	SHS	SHI	SLS	SLO
	SUB	XOR

%start	all

%union	{	int          _num;
		const char * _txt;
		Opcode     * _opcode;
		Operand    * _operand;
		Expression * _expression;
	}

%type	<_num>	INT
%type	<_txt>
	IDENT	_BYTE	_WORD
	_LL	_LU	_LS	_L	_RR	_RU	_RS	_R
	_RRZ	_RRNZ	_SP

	ADD	AND	ASR	CALL	CLRB	CLRW	DI	DIV_IS
	DIV_IU	EI	HALT	IN	JMP	LNOT	LEA	LSL
	LSR	MOVE	MD_STP	MD_FIN	MOD_FIN	MUL_IS	MUL_IU	NEG
	NOP	NOT	OUT	OR	RET	RETI	SEQ	SGE
	SGT	SLE	SLT	SNE	SHS	SHI	SLS	SLO
	SUB	XOR

%type	<_opcode>	opcode	rest	line
%type	<_expression>	expr
%type	<_operand>
	value
	imm
	cRR RR RU RS R dRR RRi
	cLL LL LU LS L dLL LLi
	SP dSP SPi oSP
	RRZ RRNZ
	port addr

%%

all	: lines EOFILE
	  {
            reloc_last = PC;
            Symbol::ListNonlabels();
            Line::List();
            Symbol::PrintSymbols();
            fwrite(memory, 1, mem_idx, out);
            write_intel_hex(ihx);
	    return 0;
	  }
	;

lines
	: line			{ if ($1)   Line::Add($1); }
	| lines line		{ if ($2)   Line::Add($2); }
	;

line
	:            EOL	{ $$ =  0; }
	| label      EOL	{ $$ =  0; }
	|       rest EOL	{ $$ = $1; }
	| label rest EOL	{ $$ = $2; }
	;

label	: IDENT ':'
	  { Symbol::Add($1, new Expression(PC), true, reloc_end); }
	;

rest
	: IDENT '='  expr	{ $$ = 0;   Symbol::Add($1, $3, false, false); }
	| _EXTERN IDENT		{ $$ = 0;   }
	| _STATIC IDENT		{ $$ = 0;   }
	| _OFFSET    expr	{ $$ = 0;   reloc_end = $2->GetValue();
                                  reloc_start = PC;  }
	| opcode		{ $$ = $1 }
	;

expr
	: INT			{ $$ = new Expression($1);               }
	| IDENT			{ $$ = new Expression($1);               }
	| expr '+' INT		{ $$ = new Expression($1, EX_ADD,  $3);  }
	| expr '-' INT		{ $$ = new Expression($1, EX_SUB,  $3);  }
	| expr '*' INT		{ $$ = new Expression($1, EX_MULT, $3);  }
	| expr '/' INT		{ $$ = new Expression($1, EX_DIV,  $3);  }
	| expr '%' INT		{ $$ = new Expression($1, EX_MOD,  $3);  }
	| expr '+' IDENT	{ $$ = new Expression($1, EX_ADD,  $3);  }
	| expr '-' IDENT	{ $$ = new Expression($1, EX_SUB,  $3);  }
	| expr '*' IDENT	{ $$ = new Expression($1, EX_MULT, $3); }
	| expr '/' IDENT	{ $$ = new Expression($1, EX_DIV,  $3);  }
	| expr '%' IDENT	{ $$ = new Expression($1, EX_MOD,  $3);  }
	;

value
	: expr			{ $$ = new Operand($1); }
	;

imm
	:  '#' value		{ $$ = $2->Immediate(); }
	;

RR	: _RR			{ $$ = new Operand(REG_RR, $1); }	;
RU	: _RU			{ $$ = new Operand(REG_RU, $1); }	;
RS	: _RS			{ $$ = new Operand(REG_RS, $1); }	;
R	: _R			{ $$ = new Operand(REG_R,  $1); }	;
cRR	: '(' RR ')'		{ $$ = $2->Content();           }	;
RRZ	: _RRZ			{ $$ = new Operand(COND_Z, $1); }	;
RRNZ	: _RRNZ			{ $$ = new Operand(COND_NZ, $1); }	;

LL	: _LL			{ $$ = new Operand(REG_LL, $1); }	;
LU	: _LU			{ $$ = new Operand(REG_LU, $1); }	;
LS	: _LS			{ $$ = new Operand(REG_LS, $1); }	;
L	: _L			{ $$ = new Operand(REG_L,  $1); }	;
cLL	: '(' LL ')'		{ $$ = $2->Content();           }	;

SP	: _SP			{ $$ = new Operand(REG_SP,  $1); }	;

dRR	: '-' '(' RR ')'	{ $$ = $3->PreDec();             }	;
dLL	: '-' '(' LL ')'	{ $$ = $3->PreDec();             }	;
dSP	: '-' '(' SP ')'	{ $$ = $3->PreDec();             }	;
RRi	: '(' RR ')' '+'	{ $$ = $2->PostInc();            }	;
LLi	: '(' LL ')' '+'	{ $$ = $2->PostInc();            }	;
SPi	: '(' SP ')' '+'	{ $$ = $2->PostInc();            }	;
oSP	: value '(' SP ')'	{ $$ = $3->Offset($1);           }	;
port	: '(' value ')'		{ $$ = $2->Port();               }	;
addr	: '(' value ')'		{ $$ = $2->AbsAddr();            }	;

/////////////////////////////////////////////////////////////////////////

opcode
: _BYTE value		{ $$ = new Opcode(H_BYTE, 0x00, $1, $2);       }
| _WORD value		{ $$ = new Opcode(H_WORD, 0x00, $1, $2);       }

| HALT			{ $$ = new Opcode(H_NONE,   0x00, $1);         }
| NOP			{ $$ = new Opcode(H_NONE,   0x01, $1);         }
| JMP  value		{ $$ = new Opcode(H_WORD,   0x02, $1, $2);     }
| JMP  RRNZ ',' value	{ $$ = new Opcode(H_WORD,   0x03, $1, $2, $4); }
| JMP  RRZ  ',' value	{ $$ = new Opcode(H_WORD,   0x04, $1, $2, $4); }
| CALL value		{ $$ = new Opcode(H_WORD,   0x05, $1, $2);     }
| CALL '(' RR ')'	{ $$ = new Opcode(H_NONE,   0x06, $1, $3);     }
| RET			{ $$ = new Opcode(H_NONE,   0x07, $1);         }
| MOVE SPi  ',' RR	{ $$ = new Opcode(H_NONE,   0x08, $1, $2, $4); }
| MOVE SPi  ',' RS	{ $$ = new Opcode(H_NONE,   0x09, $1, $2, $4); }
| MOVE SPi  ',' RU	{ $$ = new Opcode(H_NONE,   0x0A, $1, $2, $4); }
| MOVE SPi  ',' LL	{ $$ = new Opcode(H_NONE,   0x0B, $1, $2, $4); }
| MOVE SPi  ',' LS	{ $$ = new Opcode(H_NONE,   0x0C, $1, $2, $4); }
| MOVE SPi  ',' LU	{ $$ = new Opcode(H_NONE,   0x0D, $1, $2, $4); }
| MOVE RR   ',' dSP	{ $$ = new Opcode(H_NONE,   0x0E, $1, $2, $4); }
| MOVE R    ',' dSP	{ $$ = new Opcode(H_NONE,   0x0F, $1, $2, $4); }

| AND  RR   ',' imm	{ $$ = new Opcode(H_uBW,    0x10, $1, $2, $4); }
| OR   RR   ',' imm	{ $$ = new Opcode(H_uBW,    0x12, $1, $2, $4); }
| XOR  RR   ',' imm	{ $$ = new Opcode(H_uBW,    0x14, $1, $2, $4); }
| SEQ  RR   ',' imm	{ $$ = new Opcode(H_sBW,    0x16, $1, $2, $4); }
| SNE  RR   ',' imm	{ $$ = new Opcode(H_sBW,    0x18, $1, $2, $4); }
| SGE  RR   ',' imm	{ $$ = new Opcode(H_sBW,    0x1A, $1, $2, $4); }
| SGT  RR   ',' imm	{ $$ = new Opcode(H_sBW,    0x1C, $1, $2, $4); }
| SLE  RR   ',' imm	{ $$ = new Opcode(H_sBW,    0x1E, $1, $2, $4); }
| SLT  RR   ',' imm	{ $$ = new Opcode(H_sBW,    0x20, $1, $2, $4); }
| SHS  RR   ',' imm	{ $$ = new Opcode(H_uBW,    0x22, $1, $2, $4); }
| SHI  RR   ',' imm	{ $$ = new Opcode(H_uBW,    0x24, $1, $2, $4); }
| SLS  RR   ',' imm	{ $$ = new Opcode(H_uBW,    0x26, $1, $2, $4); }
| SLO  RR   ',' imm	{ $$ = new Opcode(H_uBW,    0x28, $1, $2, $4); }
| ADD  SP   ',' imm	{ $$ = new Opcode(H_uBW,    0x2A, $1, $2, $4); }
| CLRW dSP		{ $$ = new Opcode(H_NONE,   0x2C, $1, $2);     }
| CLRB dSP		{ $$ = new Opcode(H_NONE,   0x2D, $1, $2);     }
| IN   port ',' RU	{ $$ = new Opcode(H_PORT,   0x2E, $1, $2, $4); }
| OUT  R    ',' port	{ $$ = new Opcode(H_PORT,   0x2F, $1, $2, $4); }

| AND  LL   ',' RR	{ $$ = new Opcode(H_NONE,   0x30, $1, $2, $4); }
| OR   LL   ',' RR	{ $$ = new Opcode(H_NONE,   0x31, $1, $2, $4); }
| XOR  LL   ',' RR	{ $$ = new Opcode(H_NONE,   0x32, $1, $2, $4); }
| SEQ  LL   ',' RR	{ $$ = new Opcode(H_NONE,   0x33, $1, $2, $4); }
| SNE  LL   ',' RR	{ $$ = new Opcode(H_NONE,   0x34, $1, $2, $4); }
| SGE  LL   ',' RR	{ $$ = new Opcode(H_NONE,   0x35, $1, $2, $4); }
| SGT  LL   ',' RR	{ $$ = new Opcode(H_NONE,   0x36, $1, $2, $4); }
| SLE  LL   ',' RR	{ $$ = new Opcode(H_NONE,   0x37, $1, $2, $4); }
| SLT  LL   ',' RR	{ $$ = new Opcode(H_NONE,   0x38, $1, $2, $4); }
| SHS  LL   ',' RR	{ $$ = new Opcode(H_NONE,   0x39, $1, $2, $4); }
| SHI  LL   ',' RR	{ $$ = new Opcode(H_NONE,   0x3A, $1, $2, $4); }
| SLS  LL   ',' RR	{ $$ = new Opcode(H_NONE,   0x3B, $1, $2, $4); }
| SLO  LL   ',' RR	{ $$ = new Opcode(H_NONE,   0x3C, $1, $2, $4); }
| LNOT RR		{ $$ = new Opcode(H_NONE,   0x3D, $1, $2);     }
| NEG  RR		{ $$ = new Opcode(H_NONE,   0x3E, $1, $2);     }
| NOT  RR		{ $$ = new Opcode(H_NONE,   0x3F, $1, $2);     }

| MOVE LL   ',' RR	{ $$ = new Opcode(H_NONE,   0x40, $1, $2, $4); }
| MOVE LL   ',' cRR	{ $$ = new Opcode(H_NONE,   0x41, $1, $2, $4); }
| MOVE L    ',' cRR	{ $$ = new Opcode(H_NONE,   0x42, $1, $2, $4); }
| MOVE RR   ',' LL	{ $$ = new Opcode(H_NONE,   0x43, $1, $2, $4); }
| MOVE RR   ',' cLL	{ $$ = new Opcode(H_NONE,   0x44, $1, $2, $4); }
| MOVE R    ',' cLL	{ $$ = new Opcode(H_NONE,   0x45, $1, $2, $4); }
| MOVE cRR  ',' RR	{ $$ = new Opcode(H_NONE,   0x46, $1, $2, $4); }
| MOVE cRR  ',' RS	{ $$ = new Opcode(H_NONE,   0x47, $1, $2, $4); }
| MOVE cRR  ',' RU	{ $$ = new Opcode(H_NONE,   0x48, $1, $2, $4); }
| MOVE addr ',' RR	{ $$ = new Opcode(H_WORD,   0x49, $1, $2, $4); }
| MOVE addr ',' RS	{ $$ = new Opcode(H_WORD,   0x4A, $1, $2, $4); }
| MOVE addr ',' RU	{ $$ = new Opcode(H_WORD,   0x4B, $1, $2, $4); }
| MOVE addr ',' LL	{ $$ = new Opcode(H_WORD,   0x4C, $1, $2, $4); }
| MOVE addr ',' LS	{ $$ = new Opcode(H_WORD,   0x4D, $1, $2, $4); }
| MOVE addr ',' LU	{ $$ = new Opcode(H_WORD,   0x4E, $1, $2, $4); }
| MOVE RR   ',' SP	{ $$ = new Opcode(H_NONE,   0x4F, $1, $2, $4); }

| LSL  RR   ',' imm	{ $$ = new Opcode(H_BYTE,   0x52, $1, $2, $4); }
| ASR  RR   ',' imm	{ $$ = new Opcode(H_BYTE,   0x53, $1, $2, $4); }
| LSR  RR   ',' imm	{ $$ = new Opcode(H_BYTE,   0x54, $1, $2, $4); }
| LSL  LL   ',' RR	{ $$ = new Opcode(H_NONE,   0x55, $1, $2, $4); }
| ASR  LL   ',' RR	{ $$ = new Opcode(H_NONE,   0x56, $1, $2, $4); }
| LSR  LL   ',' RR	{ $$ = new Opcode(H_NONE,   0x57, $1, $2, $4); }
| ADD  LL   ',' RR	{ $$ = new Opcode(H_NONE,   0x58, $1, $2, $4); }
| SUB  LL   ',' RR	{ $$ = new Opcode(H_NONE,   0x59, $1, $2, $4); }
| MOVE RR   ',' addr 	{ $$ = new Opcode(H_WORD,   0x5A, $1, $2, $4); }
| MOVE R    ',' addr 	{ $$ = new Opcode(H_WORD,   0x5B, $1, $2, $4); }
| MOVE RR   ',' oSP 	{ $$ = new Opcode(H_uBW,    0x5C, $1, $2, $4); }
| MOVE R    ',' oSP 	{ $$ = new Opcode(H_uBW,    0x5E, $1, $2, $4); }

| MOVE oSP  ',' RR	{ $$ = new Opcode(H_uBW,    0x60, $1, $2, $4); }
| MOVE oSP  ',' RS	{ $$ = new Opcode(H_uBW,    0x62, $1, $2, $4); }
| MOVE oSP  ',' RU	{ $$ = new Opcode(H_uBW,    0x64, $1, $2, $4); }
| MOVE oSP  ',' LL	{ $$ = new Opcode(H_uBW,    0x66, $1, $2, $4); }
| MOVE oSP  ',' LS	{ $$ = new Opcode(H_uBW,    0x68, $1, $2, $4); }
| MOVE oSP  ',' LU	{ $$ = new Opcode(H_uBW,    0x6A, $1, $2, $4); }
| LEA  oSP  ',' RR	{ $$ = new Opcode(H_uBW,    0x6C, $1, $2, $4); }
| MOVE dRR  ',' dLL	{ $$ = new Opcode(H_NONE,   0x6E, $1, $2, $4); }
| MOVE RRi  ',' LLi	{ $$ = new Opcode(H_NONE,   0x6F, $1, $2, $4); }

| MUL_IS		{ $$ = new Opcode(H_NONE,   0x70, $1);         }
| MUL_IU		{ $$ = new Opcode(H_NONE,   0x71, $1);         }
| DIV_IS		{ $$ = new Opcode(H_NONE,   0x72, $1);         }
| DIV_IU		{ $$ = new Opcode(H_NONE,   0x73, $1);         }
| MD_STP		{ $$ = new Opcode(H_NONE,   0x74, $1);         }
| MD_FIN		{ $$ = new Opcode(H_NONE,   0x75, $1);         }
| MOD_FIN		{ $$ = new Opcode(H_NONE,   0x76, $1);         }
| EI			{ $$ = new Opcode(H_NONE,   0x77, $1);         }
| RETI			{ $$ = new Opcode(H_NONE,   0x78, $1);         }
| DI			{ $$ = new Opcode(H_NONE,   0x79, $1);         }

| ADD  RR   ',' imm	{ $$ = new Opcode(H_uQBW,   0xA0, $1, $2, $4); }
| SUB  RR   ',' imm	{ $$ = new Opcode(H_uQBW,   0xB0, $1, $2, $4); }
| MOVE imm  ',' RR	{ $$ = new Opcode(H_sQBW,   0xC0, $1, $2, $4); }
| SEQ  LL   ',' imm  	{ $$ = new Opcode(H_sQBW,   0xD0, $1, $2, $4); }
| MOVE imm  ',' LL	{ $$ = new Opcode(H_sQBW,   0xE0, $1, $2, $4); }
;

// Fx mapped from 8X..EX
%%

//-----------------------------------------------------------------------------
void Line::Add(Opcode * opc)
{
   assert(opc);
Line * l = new Line(opc);
   if (first == 0)
      {
        assert(last == 0);
        first = last = l;
      }
   else
      {
        assert(last->tail == 0);
        last->tail = l;
        last = l;
      }
   PC += opc->GetLength();
}
//-----------------------------------------------------------------------------
Symbol * Symbol::symbols = 0;
Symbol * Symbol::current = 0;

Line * Line::first = 0;
Line * Line::last  = 0;

void Symbol::Add(const char * id, Expression * expr, bool lab, bool reloc)
{
   for (Symbol * s = symbols; s; s = s->tail)
       {
         if (!strcmp(id, s->identifier))
            {
              fprintf(stderr, "Error: Symbol %s already defined\n", id);
              return;
            }

         if (s->tail == 0)
            {
              s->tail = new Symbol(id, expr, lab, reloc);
              return;
            }
       }

   symbols = new Symbol(id, expr, lab, reloc);
}

//-----------------------------------------------------------------------------
int Operand::GetLength(OP_HOW how)
{
   // how may apply to this or the other argument!
   //
   if (offset)   return offset->GetLength(how);

   if (base != EXPR)    return 0;
   assert(expr);

   switch(how)
      {
        case H_BYTE:
        case H_PORT: return 1;
        case H_WORD: return 2;
      }

   if (expr->UsesName())   return 2;   // not yet known

   if (GetValue() < 0)    switch(how)
      {
        case H_uBW:
        case H_uQBW:   return 2;

        case H_sBW:    if (GetValue() >= -128)   return 1;
                       return 2;

        case H_sQBW:   if (GetValue() >= -8)     return 0;
                       if (GetValue() >= -128)   return 1;
                       return 2;

        default:        fprintf(stderr, "HOW = %d\n", how);
                        assert(0 && "Bad how");
      }

   // here GetValue() >= 0
   switch(how)
      {
        case H_uBW:    if (GetValue() <= 255)   return 1;
                       return 2;

        case H_sBW:    if (GetValue() <= 127)   return 1;
                       return 2;

        case H_uQBW:   if (GetValue() <= 15)    return 0;
                       if (GetValue() <= 255)   return 1;
                       return 2;

        case H_sQBW:   if (GetValue() <= 7)     return 0;
                       if (GetValue() <= 127)   return 1;
                       return 2;

        default:        fprintf(stderr, "HOW = %d\n", how);
                        assert(0 && "Bad how");
      }
}
//-----------------------------------------------------------------------------
int Opcode::GetLength() const
{
int base_len = 1;

   assert(op_text);
   if (*op_text == '.')   base_len = 0;

int op1_len  = 0;
   if (op_1)   op1_len = op_1->GetLength(op_how);

int op2_len  = 0;
   if (op_2)   op2_len = op_2->GetLength(op_how);

   assert(!op1_len || !op2_len);
   return base_len + op1_len + op2_len;
}
//-----------------------------------------------------------------------------
void Line::List()
{
   PC = 0;
   Symbol::Reset();

   for (Line * l = first; l; l = l->tail)
       {
         Symbol::Advance(PC);
         assert(l->opcode);
         assert(l->pc == PC);
         PC += l->opcode->List(PC);
       }
   Symbol::Advance(PC);
   fprintf(stderr, "Bytes = %d (0x%X)\n", PC, PC);
}
//-----------------------------------------------------------------------------
void Symbol::ListNonlabels()
{
   for (Symbol * s = symbols; s; s = s->tail)
       {
         if (s->label)   continue;

         assert(s->identifier);
         fprintf(list, "%s\t= %d\n",
                 s->identifier, s->expr->GetValue() & 0xFFFF);
       }
   fprintf(list, "\n");
}
//-----------------------------------------------------------------------------
void Symbol::PrintSymbols()
{
   for (Symbol * s = symbols; s; s = s->tail)
       {
         if (!s->label)   continue;

         assert(s->identifier);
         fprintf(sym, "%4.4X %s\n",
                 s->expr->GetValue() & 0xFFFF, s->identifier);
       }
}
//-----------------------------------------------------------------------------
int Symbol::GetValue(const char * id)
{
   for (Symbol * s = symbols; s; s = s->tail)
       {
         assert(s->identifier);
         assert(s->expr);
         if (strcmp(id, s->identifier))   continue;
         return 0xFFFF & Reloc(s->reloc, s->expr->GetValue());
       }

   fprintf(stderr, "Symbol %s not defined\n", id);
   assert(0 && "Symbol Not Defined");
   return 0;
}
//-----------------------------------------------------------------------------
int Operand::GetValue()
{
   assert(expr);
   return expr->GetValue();
}
//-----------------------------------------------------------------------------
int Expression::ListBase() const
{
int ret = 0;

   if (ex)   ret += ex->ListBase();

   switch(how)
      {
        case EX_NAME:
             assert(name);
             assert(!ex);
             return fprintf(list, "%s", name);

        case EX_NUMBER:
             assert(!name);
             assert(!ex);
             return fprintf(list, "%d", 0xFFFF & number);

        case EX_ADD:
             assert(ex);
             ret += fprintf(list, " + ");
             break;

        case EX_SUB:
             assert(ex);
             ret += fprintf(list, " - ");
             break;

        case EX_MULT:
             assert(ex);
             ret += fprintf(list, " * ");
             break;

        case EX_DIV:
             assert(ex);
             ret += fprintf(list, " / ");
             break;

        case EX_MOD:
             assert(ex);
             ret += fprintf(list, " / ");
             break;

        default: assert(0);
      }

   if (name)   ret += fprintf(list, "%s", name);
   else        ret += fprintf(list, "%d", number);

   return ret;
}
//-----------------------------------------------------------------------------
int Expression::GetValue() const
{
int ret;

int my_val = number;
   if (name)   my_val = Symbol::GetValue(name);

   switch(how)
      {
        case EX_NAME:
             assert(name);
             assert(!ex);
             ret = 0xFFFF & my_val;
             break;

        case EX_NUMBER:
             assert(!name);
             assert(!ex);
             ret = 0xFFFF & my_val;
             break;

        case EX_ADD:
             assert(ex);
             ret = 0xFFFF & (ex->GetValue() + my_val);
             break;

        case EX_SUB:
             assert(ex);
             ret = 0xFFFF & (ex->GetValue() - my_val);
             break;

        case EX_MULT:
             assert(ex);
             ret = 0xFFFF & (ex->GetValue() * my_val);
             break;

        case EX_DIV:
             assert(ex);
             assert(0xFFFF & my_val);
             ret = 0xFFFF & (ex->GetValue() / my_val);
             break;

        case EX_MOD:
             assert(ex);
             assert(0xFFFF & my_val);
             ret = 0xFFFF & (ex->GetValue() % my_val);
             break;

        default: assert(0);
      }

   return ret;
}
//-----------------------------------------------------------------------------
void Symbol::Advance(int pc)
{
   for (; current; current = current->tail)
      {
        if (!current->label)   continue;

        assert(current->expr);
        int nxt = current->expr->GetValue();
        if (nxt > pc)   return;


        if (nxt == pc)
           {
             assert(current->identifier);
             fprintf(list, "%s:\n", current->identifier);
             continue;
           }

        assert(0);
      }
}
//-----------------------------------------------------------------------------
int Opcode::List(int pc)
{
int len = 0;
int ret = 0;
int real_opcode = GetOpcode(ret);

   len += fprintf(list, "   %4.4X: ", 0xFFFF & Reloc(reloc, pc));

   assert(op_text);
   if (*op_text != '.')
      {
       len += fprintf(list, "%2.2X ", real_opcode);
       memory[mem_idx++] = real_opcode;
      }

   if (op_1)   len += op_1->ListHex(op_how);
   if (op_2)   len += op_2->ListHex(op_how);

   while (len < 20)   len += fprintf(list, " ");

   len += fprintf(list, "%s ", op_text);

   while (len < 22)   len += fprintf(list, " ");

   if (op_1)   len += op_1->List(op_how);
   if (op_2)
      {
        len += fprintf(list, ", ");
        len += op_2->List(op_how);
      }

   fprintf(list, "\n");
   return ret;
}
//-----------------------------------------------------------------------------
int Operand::ListHex(OP_HOW how)
{
   if (offset)   return offset->ListHex(how);

   switch(GetLength(how))
      {
        case 0:   return 0;

        case 1:   memory[mem_idx++] = GetValue();
	          return fprintf(list, "%2.2X ", GetValue() & 0xFF);

        case 2:   memory[mem_idx++] = GetValue();
                  memory[mem_idx++] = GetValue() >> 8;
	          return fprintf(list, "%4.4X ", GetValue() & 0xFFFF);

        default:  assert(0);
      }
}
//-----------------------------------------------------------------------------
int Operand::List(OP_HOW how)
{
int len = 0;

   if (offset)   len += offset->List(how);

   switch(attr)
      {
        case ATT_NONE:
             return len + ListBase(how);

        case ATT_OFFSET:
             len += fprintf(list, "(");
             len += ListBase(how);
             return len + fprintf(list, ")");

        case ATT_POSTINC:
             len += fprintf(list, "(");
             len += ListBase(how);
             return len + fprintf(list, ")+");

        case ATT_PREDEC:
             len += fprintf(list, "-(");
             len += ListBase(how);
             return len + fprintf(list, ")");

        case ATT_CONTENT:
        case ATT_PORT:
        case ATT_ADDR:
             len += fprintf(list, "(");
             len += ListBase(how);
             return len + fprintf(list, ")");

        case ATT_IMM:
             len += fprintf(list, "#");
             return len + ListBase(how);

        default: assert(0);
      }
}
//-----------------------------------------------------------------------------
int Operand::ListBase(OP_HOW how)
{
   if (base != EXPR)
      {
        assert(op_text);
        return fprintf(list, op_text);
     }

   if (expr)   return expr->ListBase();

   switch(GetLength(how))
      {
        case 0:  // quick
        case 1:  return fprintf(list, "%2.2X", GetValue() & 0x0FF);
        case 2:  return fprintf(list, "%4.4X", GetValue() & 0x0FFFF);
      }

   assert(0);
}
//-----------------------------------------------------------------------------
int Opcode::GetOpcode(int & len) const
{
   len = GetLength();

   switch(op_how)
      {
        case H_BYTE:
        case H_WORD: return op_code;
        case H_NONE: if (len == 1)    return op_code;
                     if (len == 2)
                        {
                          assert(op_code & 0x0F1 == 0x61);
                          return op_code | 0x01;
                        }
                     if (len == 3)
                        {
                          assert(op_code & 0x0F1 == 0x60);
                          return op_code;
                        }

                     assert(0);
        case H_PORT: if (len == 2)    return op_code;
                     assert(0);

        case H_sBW:
        case H_uBW:  assert((op_code & 0x01) == 0);
                     if (len == 2)   return op_code | 0x01;
                     if (len == 3)   return op_code;
                     Error();
                     assert(0);

        case H_uQBW:
        case H_sQBW: assert(op_1);
                     assert(op_2);
                     assert((op_code & 0x0F) == 0);
                     if (len == 3)   return 0xF0 | op_code >> 3;
                     if (len == 2)   return 0xF1 | op_code >> 3;

                     assert(len == 1);
                     if (op_code == 0xC0)   // MOVE #, RR
		        return op_code | op_1->GetValue() & 0x0F;
                     if (op_code == 0xE0)   // MOVE #, LL
		        return op_code | op_1->GetValue() & 0x0F;

		     return op_code | op_2->GetValue() & 0x0F;

      }
   assert(0);
}
//-----------------------------------------------------------------------------
void Opcode::Error() const
{
   fprintf(stderr, "Error: ");
   if (op_text) fprintf(stderr, "%s ", op_text);
   fprintf(stderr, "%X", op_code);
   fprintf(stderr, "\n");
}
//-----------------------------------------------------------------------------
void write_intel_record(FILE * out, int adr, int len)
{
char checksum = 0;

   fprintf(out, ":");

   fprintf(out, "%2.2X", len & 0xFF);
   checksum += len;

   fprintf(out, "%4.4X", adr & 0xFFFF);
   checksum += adr >> 8;
   checksum += adr;

   if (len == 0)   { fprintf(out, "01");   checksum ++; }   // end of file
   else            { fprintf(out, "00");                }   // data

   for (int i = adr; i < adr + len; i++)
       {
         fprintf(out, "%2.2X", memory[i] & 0xFF);
         checksum += memory[i];
       }

   fprintf(out, "%2.2X", (-checksum) & 0xFF);
   fprintf(out, "\n");
}
//-----------------------------------------------------------------------------
void write_intel_hex(FILE * out)
{
   for (int i = 0; i < mem_idx; i += 16)
       {
         int len = mem_idx - i;
         if (len > 16)   len = 16;
         write_intel_record(out, i, len);
       }
   write_intel_record(out, 0, 0);
}
//-----------------------------------------------------------------------------
