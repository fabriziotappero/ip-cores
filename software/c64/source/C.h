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

/*      compiler header file    */

enum e_sym {
        id, cconst, iconst, lconst, sconst, rconst, plus, minus,
        star, divide, lshift, rshift, modop, eq, neq, lt, leq, gt,
        geq, assign, asplus, asminus, astimes, asdivide, asmodop,
		aslshift, asrshift, asand, asor, autoinc, autodec, hook, compl,
        comma, colon, semicolon, uparrow, openbr, closebr, begin, end,
        openpa, closepa, pointsto, dot, lor, land, not, or, and,
		ellipsis,

		kw_int, kw_byte, kw_icache, kw_dcache,
        kw_void, kw_char, kw_float, kw_double, kw_struct, kw_union,
        kw_long, kw_short, kw_unsigned, kw_auto, kw_extern,
        kw_register, kw_typedef, kw_static, kw_goto, kw_return,
        kw_sizeof, kw_break, kw_continue, kw_if, kw_else, kw_elsif,
		kw_for, kw_forever, kw_signed,
		kw_firstcall, kw_asm, kw_fallthru, kw_until, kw_loop,
		kw_try, kw_catch, kw_throw, kw_typenum,
        kw_do, kw_while, kw_switch, kw_case, kw_default, kw_enum,
		kw_interrupt, kw_vortex, kw_pascal, kw_oscall, kw_nocall, kw_intoff, kw_inton, kw_then,
		kw_private,kw_public,kw_stop,kw_critical,kw_spinlock,kw_spinunlock,kw_lockfail,
        eof };

enum e_sc {
        sc_static, sc_auto, sc_global, sc_external, sc_type, sc_const,
        sc_member, sc_label, sc_ulabel, sc_typedef };

enum e_bt {
		bt_byte,
        bt_char, bt_short, bt_long, bt_float, bt_double, bt_pointer,
		bt_uchar, bt_ushort, bt_ulong,
        bt_unsigned, bt_struct, bt_union, bt_enum, bt_void, bt_func, bt_ifunc,
		bt_interrupt, bt_oscall, bt_pascal, bt_bitfield, bt_ubitfield, bt_last};

struct slit {
    struct slit     *next;
    int             label;
    char            *str;
};

struct typ;

struct sym {
    struct sym *next;
    char *name;
    __int8 storage_class;
	// Function attributes
	__int8 NumParms;
	struct sym *parms;
	struct sym *nextparm;
	unsigned int IsPrototype : 1;
	unsigned int IsInterrupt : 1;
	unsigned int IsNocall : 1;
	unsigned int IsPascal : 1;
	unsigned int IsLeaf : 1;
	unsigned int DoesThrow : 1;
    union {
        __int64 i;
        unsigned __int64 u;
        double f;
        char *s;
    } value;
    struct typ *tp;
};

typedef struct typ {
    __int8 type;
	__int16 typeno;			// number of the type
	unsigned int val_flag : 1;       /* is it a value type */
	unsigned int isUnsigned : 1;
	unsigned int isShort : 1;
	unsigned int isVolatile : 1;
	__int8		bit_width;
	__int8		bit_offset;
    long        size;
    struct stab {
            struct sym *head, *tail;
            }       lst;
    struct typ      *btp;
    char            *sname;
} TYP;

#define SYM     struct sym
//#define TYP     struct typ
#define TABLE   struct stab

#define MAX_STRLEN      120
#define MAX_STLP1       121
#define ERR_SYNTAX      0
#define ERR_ILLCHAR     1
#define ERR_FPCON       2
#define ERR_ILLTYPE     3
#define ERR_UNDEFINED   4
#define ERR_DUPSYM      5
#define ERR_PUNCT       6
#define ERR_IDEXPECT    7
#define ERR_NOINIT      8
#define ERR_INCOMPLETE  9
#define ERR_ILLINIT     10
#define ERR_INITSIZE    11
#define ERR_ILLCLASS    12
#define ERR_BLOCK       13
#define ERR_NOPOINTER   14
#define ERR_NOFUNC      15
#define ERR_NOMEMBER    16
#define ERR_LVALUE      17
#define ERR_DEREF       18
#define ERR_MISMATCH    19
#define ERR_EXPREXPECT  20
#define ERR_WHILEXPECT  21
#define ERR_NOCASE      22
#define ERR_DUPCASE     23
#define ERR_LABEL       24
#define ERR_PREPROC     25
#define ERR_INCLFILE    26
#define ERR_CANTOPEN    27
#define ERR_DEFINE      28
#define ERR_CATCHEXPECT	29
#define ERR_BITFIELD_WIDTH	30
#define ERR_EXPRTOOCOMPLEX	31
#define ERR_ASMTOOLONG	32
#define ERR_TOOMANYCASECONSTANTS	33
#define ERR_CATCHSTRUCT		34
#define ERR_SEMA_INCR	35
#define ERR_SEMA_ADDR	36

/*      alignment sizes         */

#define AL_BYTE			1
#define AL_CHAR         2
#define AL_SHORT        4
#define AL_LONG         8
#define AL_POINTER      8
#define AL_FLOAT        4
#define AL_DOUBLE       8
#define AL_STRUCT       8

#define TRUE	1
#define FALSE	0
#define NULL	((void *)0)

