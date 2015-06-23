/*
 *	68000 C compiler
 *
 *	Copyright 1984, 1985, 1986 Matthew Brandt.
 *  all commercial rights reserved.
 *
 *	This compiler is intended as an instructive tool for personal use. Any
 *	use for profit without the written consent of the author is prohibited.
 *
 *	This compiler may be distributed freely for non-commercial use as long
 *	as this notice stays intact. Please forward any enhancements or questions
 *	to:
 *
 *		Matthew Brandt
 *		Box 920337
 *		Norcross, Ga 30092
 */

/*      global ParseSpecifierarations     */

extern FILE             *input,
                        *list,
                        *output;
extern FILE *outputG;
extern int incldepth;
extern int              lineno;
extern int              nextlabel;
extern int              lastch;
extern int              lastst;
extern char             lastid[33];
extern char             laststr[MAX_STLP1];
extern __int64	ival;
extern double           rval;

extern TABLE            gsyms[257],
                        lsyms;
extern SYM              *lasthead;
extern struct slit      *strtab;
extern int              lc_static;
extern int              lc_auto;
extern struct snode     *bodyptr;       /* parse tree for function */
extern int              global_flag;
extern TABLE            defsyms;
extern int              save_mask;      /* register save mask */
extern int uctran_off;
extern int isPascal;
extern int isOscall;
extern int isInterrupt;
extern int isNocall;
extern int asmblock;
extern int optimize;
extern int exceptions;
extern SYM *currentFn;

extern void error(int n);
extern void needpunc(enum e_sym p);
// Memmgt.c
extern char *xalloc(int);
extern SYM *allocSYM();
extern TYP *allocTYP();
extern AMODE *allocAmode();

// NextToken.c
extern void initsym();
extern void NextToken();
extern int getch();
extern int isspace(char c);
extern void getbase(b);
extern void SkipSpaces();

// Stmt.c
extern struct snode *ParseCompoundStatement();

extern void GenerateDiadic(int op, int len, struct amode *ap1,struct amode *ap2);
// Symbol.c
extern SYM *gsearch(char *na);
extern SYM *search(char *na,SYM *thead);
extern void insert(SYM* sp, TABLE *table);

extern char *litlate(char *);
// Decl.c
extern void dodecl(int defclass);
extern void ParseParameterDeclarations(int);
extern void ParseAutoDeclarations();
extern void ParseSpecifier(TABLE *table);
extern void ParseDeclarationPrefix();
extern void ParseStructDeclaration(int);
extern void ParseEnumerationList(TABLE *table);

extern void initstack();
extern int getline(int listflag);

// Init.c
extern void doinit(SYM *sp);
// Func.c
extern void funcbody(SYM *sp);
// Intexpr.c
extern __int64 GetIntegerExpression();
// Expr.c
extern ENODE *makenode(int nt, ENODE *v1, ENODE *v2);
extern ENODE *makeinode(int nt, __int64 v1);
extern TYP *expression(struct enode **node);
extern int IsLValue(struct enode *node);
// Optimize.c
extern void opt4(struct enode **node);
// GenerateStatement.c
extern void GenerateStatement(struct snode *stmt);
extern void GenerateFunction(struct snode *stmt);
extern void GenerateIntoff(struct snode *stmt);
extern void GenerateInton(struct snode *stmt);
extern void GenerateStop(struct snode *stmt);
extern void GenerateAsm(struct snode *stmt);
extern void GenerateFirstcall(struct snode *stmt);
extern void gen_regrestore();
extern AMODE *make_direct(__int64 i);
// Outcode.c
extern void GenerateByte(int val);
extern void GenerateChar(int val);
extern void genhalf(int val);
extern void GenerateWord(__int64 val);
extern void GenerateLong(__int64 val);
extern void genstorage(int nbytes);
extern void GenerateReference(SYM *sp,int offset);
extern void GenerateLabelReference(int n);
extern void gen_strlab(char *s);
extern void dumplits();
extern int  stringlit(char *s);
extern void nl();
extern void cseg();
extern void dseg();
extern void put_code(int op, int len,AMODE *aps, AMODE *apd, AMODE *);
extern void put_label(int lab);
// Peepgen.c
extern void flush_peep();
extern void GenerateLabel(int labno);
// Gencode.c
extern AMODE *make_label(__int64 lab);
extern AMODE *make_immed(__int64);
extern AMODE *make_indirect(int i);
extern AMODE *make_offset(struct enode *node);
extern void swap_nodes(struct enode *node);
extern int isshort(struct enode *node);
// IdentifyKeyword.c
extern int IdentifyKeyword();
// Preproc.c
extern int preprocess();
// CodeGenerator.c
extern AMODE *make_indirect(int i);
extern AMODE *make_indexed(__int64 o, int i);
extern void GenerateFalseJump(struct enode *node,int label);
extern char *GetNamespace();
extern char nmspace[20][100];
enum e_sg { noseg, codeseg, dataseg, bssseg, idataseg };

