/*
 *      code structure definitions.
 */

enum address_mode {
        am_const, am_label, am_string, am_temp, am_auto,
        am_defcon, am_deflab, am_defstr, am_deftemp, am_defauto,
        am_none };

enum instruction {
        i_move, i_add, i_sub, i_mul, i_div, i_mod, i_and, i_or,
        i_xor, i_shl, i_shr, i_jmp, i_jeq, i_jne, i_jlt, i_jle,
        i_jgt, i_jge, i_call, i_enter, i_ret, i_table, i_label };

union aval {
        int             i;
        char            *s;
        };

struct inst {
        struct inst     *fwd, *back;
        int             opcode, size;
        char            sm0, sm1, dm;
        union aval      sv0, sv1, dv;
        };

