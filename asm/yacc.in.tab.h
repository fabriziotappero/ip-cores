typedef union 
{
        int num;
        char *str;
} YYSTYPE;
#define	C	257
#define	OBRA	258
#define	CBRA	259
#define	NUM	260
#define	IMM	261
#define	IMMHEX	262
#define	REG	263
#define	SKIP	264
#define	SKIPAL	265
#define	COND	266
#define	MOV	267
#define	ARI	268
#define	CMP	269
#define	CMPTYP	270
#define	SC	271
#define	BL	272
#define	MEM	273
#define	IO	274
#define	LABEL	275


extern YYSTYPE yylval;
