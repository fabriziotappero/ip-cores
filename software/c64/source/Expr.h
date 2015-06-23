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

/*      expression tree descriptions    */

enum e_node {
        en_void,        /* used for parameter lists */
        en_cbw, en_cbc, en_cbh,
		en_ccw, en_cch, en_chw,
		en_cwl, en_cld, en_cfd,
        en_icon, en_fcon, en_labcon, en_nacon, en_autocon,
		en_c_ref, en_uc_ref, en_h_ref, en_uh_ref,
        en_b_ref, en_w_ref, en_ub_ref, en_uw_ref,
        en_fcall, en_tempref, en_regvar, en_add, en_sub, en_mul, en_mod,
        en_div, en_shl, en_shr, en_shru, en_cond, en_assign, 
        en_asadd, en_assub, en_asmul, en_asdiv, en_asmod, en_asrsh, en_asmulu,
        en_aslsh, en_asand, en_asor, en_asxor, en_uminus, en_not, en_compl,
        en_eq, en_ne, en_lt, en_le, en_gt, en_ge,
		en_and, en_or, en_land, en_lor,
        en_xor, en_ainc, en_adec, en_mulu, en_udiv, en_umod, en_ugt,
        en_uge, en_ule, en_ult,
		en_ref, en_ursh,
		en_uwfieldref,en_wfieldref,en_bfieldref,en_ubfieldref,
		en_uhfieldref,en_hfieldref,en_ucfieldref,en_cfieldref
		};

struct enode {
    enum e_node nodetype;
	enum e_bt etype;
	long      esize;
    __int8 constflag;
	__int8 bit_width;
	__int8 bit_offset;
	__int8 scale;
	// The following could be in a value union
    __int64 i;
    double f;
    char  *sp;
    struct enode *p[2];
};

typedef struct enode ENODE;

typedef struct cse {
        struct cse      *next;
        struct enode    *exp;           /* optimizable expression */
        int             uses;           /* number of uses */
        int             duses;          /* number of dereferenced uses */
        short int       voidf;          /* cannot optimize flag */
        short int       reg;            /* AllocateRegisterVarsd register */
        } CSE;


