#include        <stdio.h>
#include <string.h>
#include        "c.h"
#include        "expr.h"
#include        "gen.h"
#include        "cglbdec.h"

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

/*******************************************************
	Modified to support Raptor64 'C64' language
	by Robert Finch
	robfinch@opencores.org
*******************************************************/

void put_mask(int mask);
void align(int n);

/*      variable initialization         */

enum e_gt { nogen, bytegen, chargen, halfgen, wordgen, longgen };
//enum e_sg { noseg, codeseg, dataseg, bssseg, idataseg };

int	       gentype = nogen;
int	       curseg = noseg;
int        outcol = 0;

struct oplst {
        char    *s;
        int     ov;
        }       opl[] =
{       {"move",op_move}, {"addu",op_add}, {"addu", op_addu}, {"mov", op_mov},
		{"add",op_addi}, {"subu",op_sub}, {"subu", op_subu},
                {"subi",op_subi}, {"and",op_and},
		{"sext8",op_sext8}, {"sext16", op_sext16}, {"sext32", op_sext32},
		{"subui",op_subui}, {"shru", op_shru}, {"divsi", op_divsi}, {"not", op_not},
		{"addui",op_addui}, {"shr", op_shr}, {"dw", op_dw}, {"shl", op_shl}, {"shr", op_shr}, {"shru", op_shru},
		{"shli", op_shli}, {"shri", op_shri}, {"shrui", op_shrui},
		{"sw", op_sw}, {"lw", op_lw}, {"lh", op_lh}, {"lc", op_lc}, {"lb", op_lb},
		{"lm", op_lm}, {"sm",op_sm}, {"sb",op_sb}, {"sc",op_sc}, {"sh",op_sh},
		{"call", op_call}, {"ret", op_ret}, {"loop", op_loop}, {"beqi", op_beqi},
		{"jal", op_jal}, {"lwr", op_lwr}, {"swc", op_swc}, {"cache",op_cache},
		{"or",op_or}, {"ori",op_ori}, {"iret", op_iret}, {"andi", op_andi},
		{"xor",op_xor}, {"xori", op_xori}, {"muls",op_muls}, {"mulsi", op_mulsi}, {"mului", op_mului}, 
		{"divs",op_divs}, {"swap",op_swap}, {"mod", op_mod}, {"modu", op_modu},
		{"beq",op_beq}, {"bnei", op_bnei}, {"sei", op_sei},
		{"bltu", op_bltu}, {"bleu",op_bleu}, {"bgtu",op_bgtu}, {"bgeu", op_bgeu},
                {"bhi",op_bhi}, {"bhs",op_bhs}, {"blo",op_blo},
                {"bls",op_bls}, {"mulu",op_mulu}, {"divu",op_divu},
                {"bne",op_bne}, {"blt",op_blt}, {"ble",op_ble},
		{"bgt",op_bgt}, {"bge",op_bge}, {"neg",op_neg}, {"bnr", op_bnr},
                {"not",op_not}, {"cmp",op_cmp}, {"ext",op_ext},
                {"jmp",op_jmp},
                {"lea",op_lea}, {"asr",op_asr}, 
                {"clr",op_clr}, {"link",op_link}, {"unlk",op_unlk},
                {"bra",op_bra}, {"pea",op_pea},
				{"cmp",op_cmpi}, {"tst",op_tst},
		{"stop", op_stop},
		{"bmi", op_bmi}, {"outb", op_outb}, {"inb", op_inb}, {"inbu", op_inbu},
				{"dc",op_dc},
		{"",op_empty}, {"",op_asm},
                {0,0} };

static char *pad(char *op)
{
	static char buf[20];
	int n;

	n = strlen(op);
	strncpy(buf,op,20);
	if (n < 5) {
		strcat(buf, "     ");
		buf[5] = '\0';
	}
	return buf;
}

void putop(int op)
{    
	int     i;
    i = 0;
    while( opl[i].s )
    {
		if( opl[i].ov == op )
		{
			fprintf(output,"\t%s",pad(opl[i].s));
			return;
		}
		++i;
    }
    printf("DIAG - illegal opcode.\n");
}

static void PutConstant(ENODE *offset)
{
	switch( offset->nodetype )
	{
	case en_autocon:
	case en_icon:
			fprintf(output,"%I64d",offset->i);
			break;
	case en_labcon:
			fprintf(output,"L_%I64d",offset->i);
			break;
	case en_nacon:
			fprintf(output,"%s",offset->sp);
			break;
	case en_add:
			PutConstant(offset->p[0]);
			fprintf(output,"+");
			PutConstant(offset->p[1]);
			break;
	case en_sub:
			PutConstant(offset->p[0]);
			fprintf(output,"-");
			PutConstant(offset->p[1]);
			break;
	case en_uminus:
			fprintf(output,"-");
			PutConstant(offset->p[0]);
			break;
	default:
			printf("DIAG - illegal constant node.\n");
			break;
	}
}

char *RegMoniker(int regno)
{
	static char buf[4][20];
	static int n;

	n = (n + 1) & 3;
	switch(regno) {
	case 27:	sprintf(&buf[n], "bp"); break;
	case 28:	sprintf(&buf[n], "xlr"); break;
	case 29:	sprintf(&buf[n], "pc"); break;
	case 30:	sprintf(&buf[n], "sp"); break;
	case 31:	sprintf(&buf[n], "lr"); break;
	default:	sprintf(&buf[n], "r%d", regno); break;
	}
	return &buf[n];
}

void PutAddressMode(AMODE *ap)
{
	switch( ap->mode )
    {
    case am_immed:
		fprintf(output,"#");
    case am_direct:
            PutConstant(ap->offset);
            break;
    case am_reg:
			fprintf(output, "%s", RegMoniker(ap->preg));
            break;
    case am_ind:
			//if (ap->offset != NULL) {
			//	if (ap->offset->i != 0)
			//		fprintf(output, "%I64d[r%d]", ap->offset->i, ap->preg);
			//	else
			//		fprintf(output,"[r%d]",ap->preg);
			//}
			//else
				fprintf(output,"[%s]",RegMoniker(ap->preg));
			break;
    case am_ainc:
            fprintf(output,"******[r%d]",ap->preg);
			fprintf(output,"addui\ta%d,a%d,#",ap->preg,ap->preg);
            break;
    case am_adec:
			fprintf(output,"subui\ta%d,a%d,#",ap->preg,ap->preg);
            fprintf(output,"******[a%d]",ap->preg);
            break;
    case am_indx:
			if (ap->offset->i != 0)
				PutConstant(ap->offset);
            fprintf(output,"[%s]",RegMoniker(ap->preg));
            break;
    case am_indx2:
			if (ap->offset->i != 0)
				PutConstant(ap->offset);
			if (ap->scale==1)
	            fprintf(output,"[%s+%s]",RegMoniker(ap->sreg),RegMoniker(ap->preg));
			else
		        fprintf(output,"[%s+%s*%d]",RegMoniker(ap->sreg),RegMoniker(ap->preg),ap->scale);
            break;
    case am_indx3:
			if (ap->offset->i != 0)
	            PutConstant(ap->offset);
            fprintf(output,"[%s+%s]",RegMoniker(ap->sreg),RegMoniker(ap->preg));
            break;
    case am_mask:
            put_mask(ap->offset);
            break;
    default:
            printf("DIAG - illegal address mode.\n");
            break;
    }
}

/*
 *      output a generic instruction.
 */
void put_code(int op, int len,AMODE *aps,AMODE *apd,AMODE *ap3)
{       if( op == op_dc )
		{
		switch( len )
			{
			case 1: fprintf(output,"\tdb"); break;
			case 2: fprintf(output,"\tdc"); break;
			case 4: fprintf(output,"\tdh"); break;
			case 8: fprintf(output,"\tdw"); break;
			}
		}
	else
		{
			putop(op);
		}
        if( aps != 0 )
        {
                fprintf(output,"\t");
				PutAddressMode(aps);
                if( apd != 0 )
                {
                        fprintf(output,",");
                       	PutAddressMode(apd);
						if (ap3 != NULL) {
							fprintf(output,",");
							PutAddressMode(ap3);
						}
                }
        }
        fprintf(output,"\n");
}

/*
 *      generate a register mask for restore and save.
 */
void put_mask(int mask)
{
	int nn;
	int first = 1;

	for (nn = 0; nn < 32; nn++) {
		if (mask & (1<<nn)) {
			if (!first)
				fprintf(output,"/");
			fprintf(output,"r%d",nn);
			first = 0;
		}
	}
//	fprintf(output,"#0x%04x",mask);

}

/*
 *      generate a register name from a tempref number.
 */
void putreg(int r)
{
	fprintf(output, "r%d", r);
}

/*
 *      generate a named label.
 */
void gen_strlab(char *s)
{       fprintf(output,"%s:\n",s);
}

/*
 *      output a compiler generated label.
 */
void put_label(int lab)
{
	fprintf(output,"L_%d:\n",lab);
}

void GenerateByte(int val)
{
	if( gentype == bytegen && outcol < 60) {
        fprintf(output,",%d",val & 0x00ff);
        outcol += 4;
    }
    else {
        nl();
        fprintf(output,"\tdb\t%d",val & 0x00ff);
        gentype = bytegen;
        outcol = 19;
    }
}

void GenerateChar(int val)
{
	if( gentype == chargen && outcol < 60) {
        fprintf(output,",%d",val & 0xffff);
        outcol += 6;
    }
    else {
        nl();
        fprintf(output,"\tdc\t%d",val & 0xffff);
        gentype = chargen;
        outcol = 21;
    }
}

void genhalf(int val)
{
	if( gentype == halfgen && outcol < 60) {
        fprintf(output,",%d",val & 0xffffffff);
        outcol += 10;
    }
    else {
        nl();
        fprintf(output,"\tdh\t%d",val & 0xffffffff);
        gentype = halfgen;
        outcol = 25;
    }
}

void GenerateWord(__int64 val)
{
	if( gentype == wordgen && outcol < 58) {
        fprintf(output,",%I64d",val);
        outcol += 18;
    }
    else {
        nl();
        fprintf(output,"\tdh\t%I64d",val);
        gentype = wordgen;
        outcol = 33;
    }
}

void GenerateLong(__int64 val)
{ 
	if( gentype == longgen && outcol < 56) {
                fprintf(output,",%I64d",val);
                outcol += 10;
                }
        else    {
                nl();
                fprintf(output,"\tdw\t%I64d",val);
                gentype = longgen;
                outcol = 25;
                }
}

void GenerateReference(SYM *sp,int offset)
{
	char    sign;
    if( offset < 0) {
        sign = '-';
        offset = -offset;
    }
    else
        sign = '+';
    if( gentype == longgen && outcol < 55 - strlen(sp->name)) {
        if( sp->storage_class == sc_static)
                fprintf(output,",L_%I64d%c%d",sp->value.i,sign,offset);
        else
                fprintf(output,",%s%c%d",sp->name,sign,offset);
        outcol += (11 + strlen(sp->name));
    }
    else {
        nl();
        if(sp->storage_class == sc_static)
            fprintf(output,"\tdw\tL_%I64d%c%d",sp->value.i,sign,offset);
        else
            fprintf(output,"\tdw\t%s%c%d",sp->name,sign,offset);
        outcol = 26 + strlen(sp->name);
        gentype = longgen;
    }
}

void genstorage(int nbytes)
{       nl();
        fprintf(output,"\tdcb.b\t%d,0xff\n",nbytes);
}

void GenerateLabelReference(int n)
{       if( gentype == longgen && outcol < 58) {
                fprintf(output,",L_%d",n);
                outcol += 6;
                }
        else    {
                nl();
                fprintf(output,"\tlong\tL_%d",n);
                outcol = 22;
                gentype = longgen;
                }
}

/*
 *      make s a string literal and return it's label number.
 */
int     stringlit(char *s)
{      
	struct slit *lp;

    ++global_flag;          /* always allocate from global space. */
    lp = (struct slit *)xalloc(sizeof(struct slit));
    lp->label = nextlabel++;
    lp->str = litlate(s);
    lp->next = strtab;
    strtab = lp;
    --global_flag;
    return lp->label;
}

/*
 *      dump the string literal pool.
 */
void dumplits()
{
	char            *cp;

    cseg();
    nl();
	align(8);
    nl();
	while( strtab != NULL) {
	    nl();
        put_label(strtab->label);
        cp = strtab->str;
        while(*cp)
            GenerateChar(*cp++);
        GenerateChar(0);
        strtab = strtab->next;
    }
    nl();
}

void nl()
{       if(outcol > 0) {
                fprintf(output,"\n");
                outcol = 0;
                gentype = nogen;
                }
}

void align(int n)
{
	fprintf(output,"\talign\t%d\n",n);
}

void cseg()
{
	if( curseg != codeseg) {
		nl();
		fprintf(output,"\tcode\n");
		fprintf(output,"\talign\t16\n");
		curseg = codeseg;
    }
}

void dseg()
{    
	if( curseg != dataseg) {
		nl();
		fprintf(output,"\tdata\n");
		fprintf(output,"\talign\t8\n");
		curseg = dataseg;
    }
}

void seg(int sg)
{    
	if( curseg != sg) {
		nl();
		switch(sg) {
		case bssseg:
			fprintf(output,"\tbss\n");
			fprintf(output,"\talign\t8\n");
			break;
		case dataseg:
			fprintf(output,"\tdata\n");
			fprintf(output,"\talign\t8\n");
			break;
		case idataseg:
			fprintf(output,"\tidata\n");
			fprintf(output,"\talign\t8\n");
			break;
		case codeseg:
			fprintf(output,"\tcode\n");
			fprintf(output,"\talign\t16\n");
			break;
		}
		curseg = sg;
    }
}
