#include        <stdio.h>
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

void ListTable(TABLE *t, int i);

void put_typedef(int td)
{
	fprintf(list,td ? "   1   " : "   -    ");
}

void put_sc(int scl)
{       switch(scl) {
                case sc_static:
                        fprintf(list,"Static      ");
                        break;
                case sc_auto:
                        fprintf(list,"Auto        ");
                        break;
                case sc_global:
                        fprintf(list,"Global      ");
                        break;
                case sc_external:
                        fprintf(list,"External    ");
                        break;
                case sc_type:
                        fprintf(list,"Type        ");
                        break;
                case sc_const:
                        fprintf(list,"Constant    ");
                        break;
                case sc_member:
                        fprintf(list,"Member      ");
                        break;
                case sc_label:
                        fprintf(list,"Label");
                        break;
                case sc_ulabel:
                        fprintf(list,"Undefined label");
                        break;
                }
}

void put_ty(TYP *tp)
{       if(tp == 0)
                return;
        switch(tp->type) {
				case bt_byte:
                        fprintf(list,"Byte");
                        break;
                case bt_char:
                        fprintf(list,"Char");
                        break;
                case bt_short:
                        fprintf(list,"Short");
                        break;
                case bt_enum:
                        fprintf(list,"enum ");
                        goto ucont;
                case bt_long:
                        fprintf(list,"Long");
                        break;
                case bt_unsigned:
                        fprintf(list,"unsigned long");
                        break;
                case bt_float:
                        fprintf(list,"Float");
                        break;
                case bt_double:
                        fprintf(list,"Double");
                        break;
                case bt_pointer:
                        if( tp->val_flag == 0)
                                fprintf(list,"Pointer to ");
                        else
                                fprintf(list,"Array of ");
                        put_ty(tp->btp);
                        break;
                case bt_union:
                        fprintf(list,"union ");
                        goto ucont;
                case bt_struct:
                        fprintf(list,"struct ");
ucont:                  if(tp->sname == 0)
                                fprintf(list,"<no name> ");
                        else
                                fprintf(list,"%s ",tp->sname);
                        break;
                case bt_ifunc:
                case bt_func:
                        fprintf(list,"Function returning ");
                        put_ty(tp->btp);
                        break;
                }
}

void list_var(SYM *sp, int i)
{       int     j;
        for(j = i; j; --j)
                fprintf(list,"    ");
		if (sp->name == NULL)
			fprintf(list,"%-10s =%06x ","<unnamed>",sp->value.u);
		else
			fprintf(list,"%-10s =%06x ",sp->name,sp->value.u);
        if( sp->storage_class == sc_external)
                fprintf(output,"\textern\t%s\n",sp->name);
        else if( sp->storage_class == sc_global )
                fprintf(output,";\tglobal\t%s\n",sp->name);
		put_typedef(sp->storage_class==sc_typedef);
        put_sc(sp->storage_class);
        put_ty(sp->tp);
        fprintf(list,"\n");
        if(sp->tp == 0)
                return;
        if((sp->tp->type == bt_struct || sp->tp->type == bt_union) &&
                sp->storage_class == sc_type)
                ListTable(&(sp->tp->lst),i+1);
}

void ListTable(TABLE *t, int i)
{
	SYM *sp;
	int nn;

	if (t==&gsyms[0]) {
		for (nn = 0; nn < 257; nn++) {
			t = &gsyms[nn];
			sp = t->head;
			while(sp != NULL) {
				list_var(sp,i);
				sp = sp->next;
            }
		}
	}
	else {
		sp = t->head;
		while(sp != NULL) {
			list_var(sp,i);
			sp = sp->next;
        }
	}
}


