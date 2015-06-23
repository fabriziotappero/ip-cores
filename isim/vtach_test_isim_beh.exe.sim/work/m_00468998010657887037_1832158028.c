/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                       */
/*  \   \        Copyright (c) 2003-2009 Xilinx, Inc.                */
/*  /   /          All Right Reserved.                                 */
/* /---/   /\                                                         */
/* \   \  /  \                                                      */
/*  \___\/\___\                                                    */
/***********************************************************************/

/* This file is designed for use with ISim build 0xb4d1ced7 */

#define XSI_HIDE_SYMBOL_SPEC true
#include "xsi.h"
#include <memory.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
static const char *ng0 = "/home/alw/projects/vtachspartan/debounce.v";
static unsigned int ng1[] = {4U, 0U};
static int ng2[] = {0, 0};
static unsigned int ng3[] = {500000U, 0U};
static int ng4[] = {1, 0};



static void Always_33_0(char *t0)
{
    char t15[8];
    char t19[8];
    char t26[8];
    char t34[8];
    char t66[8];
    char t82[8];
    char t90[8];
    char t119[8];
    char t135[8];
    char t143[8];
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t5;
    unsigned int t6;
    unsigned int t7;
    unsigned int t8;
    unsigned int t9;
    unsigned int t10;
    char *t11;
    char *t12;
    char *t13;
    char *t14;
    unsigned int t16;
    unsigned int t17;
    unsigned int t18;
    unsigned int t20;
    unsigned int t21;
    unsigned int t22;
    unsigned int t23;
    unsigned int t24;
    char *t25;
    char *t27;
    unsigned int t28;
    unsigned int t29;
    unsigned int t30;
    unsigned int t31;
    unsigned int t32;
    char *t33;
    unsigned int t35;
    unsigned int t36;
    unsigned int t37;
    char *t38;
    char *t39;
    char *t40;
    unsigned int t41;
    unsigned int t42;
    unsigned int t43;
    unsigned int t44;
    unsigned int t45;
    unsigned int t46;
    unsigned int t47;
    char *t48;
    char *t49;
    unsigned int t50;
    unsigned int t51;
    unsigned int t52;
    unsigned int t53;
    unsigned int t54;
    unsigned int t55;
    unsigned int t56;
    unsigned int t57;
    int t58;
    int t59;
    unsigned int t60;
    unsigned int t61;
    unsigned int t62;
    unsigned int t63;
    unsigned int t64;
    unsigned int t65;
    char *t67;
    unsigned int t68;
    unsigned int t69;
    unsigned int t70;
    unsigned int t71;
    unsigned int t72;
    char *t73;
    char *t74;
    unsigned int t75;
    unsigned int t76;
    unsigned int t77;
    unsigned int t78;
    char *t79;
    char *t80;
    char *t81;
    char *t83;
    unsigned int t84;
    unsigned int t85;
    unsigned int t86;
    unsigned int t87;
    unsigned int t88;
    char *t89;
    unsigned int t91;
    unsigned int t92;
    unsigned int t93;
    char *t94;
    char *t95;
    char *t96;
    unsigned int t97;
    unsigned int t98;
    unsigned int t99;
    unsigned int t100;
    unsigned int t101;
    unsigned int t102;
    unsigned int t103;
    char *t104;
    char *t105;
    unsigned int t106;
    unsigned int t107;
    unsigned int t108;
    int t109;
    unsigned int t110;
    unsigned int t111;
    unsigned int t112;
    int t113;
    unsigned int t114;
    unsigned int t115;
    unsigned int t116;
    unsigned int t117;
    char *t118;
    char *t120;
    char *t121;
    char *t122;
    unsigned int t123;
    unsigned int t124;
    unsigned int t125;
    unsigned int t126;
    unsigned int t127;
    unsigned int t128;
    unsigned int t129;
    unsigned int t130;
    unsigned int t131;
    unsigned int t132;
    unsigned int t133;
    unsigned int t134;
    char *t136;
    unsigned int t137;
    unsigned int t138;
    unsigned int t139;
    unsigned int t140;
    unsigned int t141;
    char *t142;
    unsigned int t144;
    unsigned int t145;
    unsigned int t146;
    char *t147;
    char *t148;
    char *t149;
    unsigned int t150;
    unsigned int t151;
    unsigned int t152;
    unsigned int t153;
    unsigned int t154;
    unsigned int t155;
    unsigned int t156;
    char *t157;
    char *t158;
    unsigned int t159;
    unsigned int t160;
    unsigned int t161;
    int t162;
    unsigned int t163;
    unsigned int t164;
    unsigned int t165;
    int t166;
    unsigned int t167;
    unsigned int t168;
    unsigned int t169;
    unsigned int t170;
    char *t171;

LAB0:    t1 = (t0 + 4208U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(33, ng0);
    t2 = (t0 + 5272);
    *((int *)t2) = 1;
    t3 = (t0 + 4240);
    *((char **)t3) = t2;
    *((char **)t1) = &&LAB4;

LAB1:    return;
LAB4:    xsi_set_current_line(34, ng0);
    t4 = (t0 + 1616U);
    t5 = *((char **)t4);
    t4 = (t5 + 4);
    t6 = *((unsigned int *)t4);
    t7 = (~(t6));
    t8 = *((unsigned int *)t5);
    t9 = (t8 & t7);
    t10 = (t9 != 0);
    if (t10 > 0)
        goto LAB5;

LAB6:    xsi_set_current_line(36, ng0);

LAB8:    xsi_set_current_line(37, ng0);
    t2 = (t0 + 2656);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    memset(t15, 0, 8);
    t5 = (t4 + 4);
    t6 = *((unsigned int *)t5);
    t7 = (~(t6));
    t8 = *((unsigned int *)t4);
    t9 = (t8 & t7);
    t10 = (t9 & 1U);
    if (t10 != 0)
        goto LAB9;

LAB10:    if (*((unsigned int *)t5) != 0)
        goto LAB11;

LAB12:    t12 = (t15 + 4);
    t16 = *((unsigned int *)t15);
    t17 = *((unsigned int *)t12);
    t18 = (t16 || t17);
    if (t18 > 0)
        goto LAB13;

LAB14:    memcpy(t34, t15, 8);

LAB15:    memset(t66, 0, 8);
    t67 = (t34 + 4);
    t68 = *((unsigned int *)t67);
    t69 = (~(t68));
    t70 = *((unsigned int *)t34);
    t71 = (t70 & t69);
    t72 = (t71 & 1U);
    if (t72 != 0)
        goto LAB27;

LAB28:    if (*((unsigned int *)t67) != 0)
        goto LAB29;

LAB30:    t74 = (t66 + 4);
    t75 = *((unsigned int *)t66);
    t76 = (!(t75));
    t77 = *((unsigned int *)t74);
    t78 = (t76 || t77);
    if (t78 > 0)
        goto LAB31;

LAB32:    memcpy(t90, t66, 8);

LAB33:    t118 = (t0 + 2656);
    xsi_vlogvar_wait_assign_value(t118, t90, 0, 0, 1, 0LL);
    xsi_set_current_line(39, ng0);
    t2 = (t0 + 2656);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    memset(t15, 0, 8);
    t5 = (t4 + 4);
    t6 = *((unsigned int *)t5);
    t7 = (~(t6));
    t8 = *((unsigned int *)t4);
    t9 = (t8 & t7);
    t10 = (t9 & 1U);
    if (t10 != 0)
        goto LAB41;

LAB42:    if (*((unsigned int *)t5) != 0)
        goto LAB43;

LAB44:    t12 = (t15 + 4);
    t16 = *((unsigned int *)t15);
    t17 = *((unsigned int *)t12);
    t18 = (t16 || t17);
    if (t18 > 0)
        goto LAB45;

LAB46:    memcpy(t26, t15, 8);

LAB47:    memset(t34, 0, 8);
    t48 = (t26 + 4);
    t61 = *((unsigned int *)t48);
    t62 = (~(t61));
    t63 = *((unsigned int *)t26);
    t64 = (t63 & t62);
    t65 = (t64 & 1U);
    if (t65 != 0)
        goto LAB55;

LAB56:    if (*((unsigned int *)t48) != 0)
        goto LAB57;

LAB58:    t67 = (t34 + 4);
    t68 = *((unsigned int *)t34);
    t69 = (!(t68));
    t70 = *((unsigned int *)t67);
    t71 = (t69 || t70);
    if (t71 > 0)
        goto LAB59;

LAB60:    memcpy(t143, t34, 8);

LAB61:    t171 = (t0 + 2816);
    xsi_vlogvar_wait_assign_value(t171, t143, 0, 0, 1, 0LL);
    xsi_set_current_line(41, ng0);
    t2 = (t0 + 2816);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    memset(t15, 0, 8);
    t5 = (t4 + 4);
    t6 = *((unsigned int *)t5);
    t7 = (~(t6));
    t8 = *((unsigned int *)t4);
    t9 = (t8 & t7);
    t10 = (t9 & 1U);
    if (t10 != 0)
        goto LAB87;

LAB88:    if (*((unsigned int *)t5) != 0)
        goto LAB89;

LAB90:    t12 = (t15 + 4);
    t16 = *((unsigned int *)t15);
    t17 = *((unsigned int *)t12);
    t18 = (t16 || t17);
    if (t18 > 0)
        goto LAB91;

LAB92:    memcpy(t26, t15, 8);

LAB93:    t48 = (t0 + 2976);
    xsi_vlogvar_wait_assign_value(t48, t26, 0, 0, 1, 0LL);

LAB7:    goto LAB2;

LAB5:    xsi_set_current_line(35, ng0);
    t11 = ((char*)((ng1)));
    t12 = (t0 + 2976);
    xsi_vlogvar_wait_assign_value(t12, t11, 0, 0, 1, 0LL);
    t13 = (t0 + 2816);
    xsi_vlogvar_wait_assign_value(t13, t11, 1, 0, 1, 0LL);
    t14 = (t0 + 2656);
    xsi_vlogvar_wait_assign_value(t14, t11, 2, 0, 1, 0LL);
    goto LAB7;

LAB9:    *((unsigned int *)t15) = 1;
    goto LAB12;

LAB11:    t11 = (t15 + 4);
    *((unsigned int *)t15) = 1;
    *((unsigned int *)t11) = 1;
    goto LAB12;

LAB13:    t13 = (t0 + 1936U);
    t14 = *((char **)t13);
    memset(t19, 0, 8);
    t13 = (t14 + 4);
    t20 = *((unsigned int *)t13);
    t21 = (~(t20));
    t22 = *((unsigned int *)t14);
    t23 = (t22 & t21);
    t24 = (t23 & 1U);
    if (t24 != 0)
        goto LAB19;

LAB17:    if (*((unsigned int *)t13) == 0)
        goto LAB16;

LAB18:    t25 = (t19 + 4);
    *((unsigned int *)t19) = 1;
    *((unsigned int *)t25) = 1;

LAB19:    memset(t26, 0, 8);
    t27 = (t19 + 4);
    t28 = *((unsigned int *)t27);
    t29 = (~(t28));
    t30 = *((unsigned int *)t19);
    t31 = (t30 & t29);
    t32 = (t31 & 1U);
    if (t32 != 0)
        goto LAB20;

LAB21:    if (*((unsigned int *)t27) != 0)
        goto LAB22;

LAB23:    t35 = *((unsigned int *)t15);
    t36 = *((unsigned int *)t26);
    t37 = (t35 & t36);
    *((unsigned int *)t34) = t37;
    t38 = (t15 + 4);
    t39 = (t26 + 4);
    t40 = (t34 + 4);
    t41 = *((unsigned int *)t38);
    t42 = *((unsigned int *)t39);
    t43 = (t41 | t42);
    *((unsigned int *)t40) = t43;
    t44 = *((unsigned int *)t40);
    t45 = (t44 != 0);
    if (t45 == 1)
        goto LAB24;

LAB25:
LAB26:    goto LAB15;

LAB16:    *((unsigned int *)t19) = 1;
    goto LAB19;

LAB20:    *((unsigned int *)t26) = 1;
    goto LAB23;

LAB22:    t33 = (t26 + 4);
    *((unsigned int *)t26) = 1;
    *((unsigned int *)t33) = 1;
    goto LAB23;

LAB24:    t46 = *((unsigned int *)t34);
    t47 = *((unsigned int *)t40);
    *((unsigned int *)t34) = (t46 | t47);
    t48 = (t15 + 4);
    t49 = (t26 + 4);
    t50 = *((unsigned int *)t15);
    t51 = (~(t50));
    t52 = *((unsigned int *)t48);
    t53 = (~(t52));
    t54 = *((unsigned int *)t26);
    t55 = (~(t54));
    t56 = *((unsigned int *)t49);
    t57 = (~(t56));
    t58 = (t51 & t53);
    t59 = (t55 & t57);
    t60 = (~(t58));
    t61 = (~(t59));
    t62 = *((unsigned int *)t40);
    *((unsigned int *)t40) = (t62 & t60);
    t63 = *((unsigned int *)t40);
    *((unsigned int *)t40) = (t63 & t61);
    t64 = *((unsigned int *)t34);
    *((unsigned int *)t34) = (t64 & t60);
    t65 = *((unsigned int *)t34);
    *((unsigned int *)t34) = (t65 & t61);
    goto LAB26;

LAB27:    *((unsigned int *)t66) = 1;
    goto LAB30;

LAB29:    t73 = (t66 + 4);
    *((unsigned int *)t66) = 1;
    *((unsigned int *)t73) = 1;
    goto LAB30;

LAB31:    t79 = (t0 + 2976);
    t80 = (t79 + 56U);
    t81 = *((char **)t80);
    memset(t82, 0, 8);
    t83 = (t81 + 4);
    t84 = *((unsigned int *)t83);
    t85 = (~(t84));
    t86 = *((unsigned int *)t81);
    t87 = (t86 & t85);
    t88 = (t87 & 1U);
    if (t88 != 0)
        goto LAB34;

LAB35:    if (*((unsigned int *)t83) != 0)
        goto LAB36;

LAB37:    t91 = *((unsigned int *)t66);
    t92 = *((unsigned int *)t82);
    t93 = (t91 | t92);
    *((unsigned int *)t90) = t93;
    t94 = (t66 + 4);
    t95 = (t82 + 4);
    t96 = (t90 + 4);
    t97 = *((unsigned int *)t94);
    t98 = *((unsigned int *)t95);
    t99 = (t97 | t98);
    *((unsigned int *)t96) = t99;
    t100 = *((unsigned int *)t96);
    t101 = (t100 != 0);
    if (t101 == 1)
        goto LAB38;

LAB39:
LAB40:    goto LAB33;

LAB34:    *((unsigned int *)t82) = 1;
    goto LAB37;

LAB36:    t89 = (t82 + 4);
    *((unsigned int *)t82) = 1;
    *((unsigned int *)t89) = 1;
    goto LAB37;

LAB38:    t102 = *((unsigned int *)t90);
    t103 = *((unsigned int *)t96);
    *((unsigned int *)t90) = (t102 | t103);
    t104 = (t66 + 4);
    t105 = (t82 + 4);
    t106 = *((unsigned int *)t104);
    t107 = (~(t106));
    t108 = *((unsigned int *)t66);
    t109 = (t108 & t107);
    t110 = *((unsigned int *)t105);
    t111 = (~(t110));
    t112 = *((unsigned int *)t82);
    t113 = (t112 & t111);
    t114 = (~(t109));
    t115 = (~(t113));
    t116 = *((unsigned int *)t96);
    *((unsigned int *)t96) = (t116 & t114);
    t117 = *((unsigned int *)t96);
    *((unsigned int *)t96) = (t117 & t115);
    goto LAB40;

LAB41:    *((unsigned int *)t15) = 1;
    goto LAB44;

LAB43:    t11 = (t15 + 4);
    *((unsigned int *)t15) = 1;
    *((unsigned int *)t11) = 1;
    goto LAB44;

LAB45:    t13 = (t0 + 1936U);
    t14 = *((char **)t13);
    memset(t19, 0, 8);
    t13 = (t14 + 4);
    t20 = *((unsigned int *)t13);
    t21 = (~(t20));
    t22 = *((unsigned int *)t14);
    t23 = (t22 & t21);
    t24 = (t23 & 1U);
    if (t24 != 0)
        goto LAB48;

LAB49:    if (*((unsigned int *)t13) != 0)
        goto LAB50;

LAB51:    t28 = *((unsigned int *)t15);
    t29 = *((unsigned int *)t19);
    t30 = (t28 & t29);
    *((unsigned int *)t26) = t30;
    t27 = (t15 + 4);
    t33 = (t19 + 4);
    t38 = (t26 + 4);
    t31 = *((unsigned int *)t27);
    t32 = *((unsigned int *)t33);
    t35 = (t31 | t32);
    *((unsigned int *)t38) = t35;
    t36 = *((unsigned int *)t38);
    t37 = (t36 != 0);
    if (t37 == 1)
        goto LAB52;

LAB53:
LAB54:    goto LAB47;

LAB48:    *((unsigned int *)t19) = 1;
    goto LAB51;

LAB50:    t25 = (t19 + 4);
    *((unsigned int *)t19) = 1;
    *((unsigned int *)t25) = 1;
    goto LAB51;

LAB52:    t41 = *((unsigned int *)t26);
    t42 = *((unsigned int *)t38);
    *((unsigned int *)t26) = (t41 | t42);
    t39 = (t15 + 4);
    t40 = (t19 + 4);
    t43 = *((unsigned int *)t15);
    t44 = (~(t43));
    t45 = *((unsigned int *)t39);
    t46 = (~(t45));
    t47 = *((unsigned int *)t19);
    t50 = (~(t47));
    t51 = *((unsigned int *)t40);
    t52 = (~(t51));
    t58 = (t44 & t46);
    t59 = (t50 & t52);
    t53 = (~(t58));
    t54 = (~(t59));
    t55 = *((unsigned int *)t38);
    *((unsigned int *)t38) = (t55 & t53);
    t56 = *((unsigned int *)t38);
    *((unsigned int *)t38) = (t56 & t54);
    t57 = *((unsigned int *)t26);
    *((unsigned int *)t26) = (t57 & t53);
    t60 = *((unsigned int *)t26);
    *((unsigned int *)t26) = (t60 & t54);
    goto LAB54;

LAB55:    *((unsigned int *)t34) = 1;
    goto LAB58;

LAB57:    t49 = (t34 + 4);
    *((unsigned int *)t34) = 1;
    *((unsigned int *)t49) = 1;
    goto LAB58;

LAB59:    t73 = (t0 + 2816);
    t74 = (t73 + 56U);
    t79 = *((char **)t74);
    memset(t66, 0, 8);
    t80 = (t79 + 4);
    t72 = *((unsigned int *)t80);
    t75 = (~(t72));
    t76 = *((unsigned int *)t79);
    t77 = (t76 & t75);
    t78 = (t77 & 1U);
    if (t78 != 0)
        goto LAB62;

LAB63:    if (*((unsigned int *)t80) != 0)
        goto LAB64;

LAB65:    t83 = (t66 + 4);
    t84 = *((unsigned int *)t66);
    t85 = *((unsigned int *)t83);
    t86 = (t84 || t85);
    if (t86 > 0)
        goto LAB66;

LAB67:    memcpy(t119, t66, 8);

LAB68:    memset(t135, 0, 8);
    t136 = (t119 + 4);
    t137 = *((unsigned int *)t136);
    t138 = (~(t137));
    t139 = *((unsigned int *)t119);
    t140 = (t139 & t138);
    t141 = (t140 & 1U);
    if (t141 != 0)
        goto LAB80;

LAB81:    if (*((unsigned int *)t136) != 0)
        goto LAB82;

LAB83:    t144 = *((unsigned int *)t34);
    t145 = *((unsigned int *)t135);
    t146 = (t144 | t145);
    *((unsigned int *)t143) = t146;
    t147 = (t34 + 4);
    t148 = (t135 + 4);
    t149 = (t143 + 4);
    t150 = *((unsigned int *)t147);
    t151 = *((unsigned int *)t148);
    t152 = (t150 | t151);
    *((unsigned int *)t149) = t152;
    t153 = *((unsigned int *)t149);
    t154 = (t153 != 0);
    if (t154 == 1)
        goto LAB84;

LAB85:
LAB86:    goto LAB61;

LAB62:    *((unsigned int *)t66) = 1;
    goto LAB65;

LAB64:    t81 = (t66 + 4);
    *((unsigned int *)t66) = 1;
    *((unsigned int *)t81) = 1;
    goto LAB65;

LAB66:    t89 = (t0 + 2096U);
    t94 = *((char **)t89);
    memset(t82, 0, 8);
    t89 = (t94 + 4);
    t87 = *((unsigned int *)t89);
    t88 = (~(t87));
    t91 = *((unsigned int *)t94);
    t92 = (t91 & t88);
    t93 = (t92 & 1U);
    if (t93 != 0)
        goto LAB72;

LAB70:    if (*((unsigned int *)t89) == 0)
        goto LAB69;

LAB71:    t95 = (t82 + 4);
    *((unsigned int *)t82) = 1;
    *((unsigned int *)t95) = 1;

LAB72:    memset(t90, 0, 8);
    t96 = (t82 + 4);
    t97 = *((unsigned int *)t96);
    t98 = (~(t97));
    t99 = *((unsigned int *)t82);
    t100 = (t99 & t98);
    t101 = (t100 & 1U);
    if (t101 != 0)
        goto LAB73;

LAB74:    if (*((unsigned int *)t96) != 0)
        goto LAB75;

LAB76:    t102 = *((unsigned int *)t66);
    t103 = *((unsigned int *)t90);
    t106 = (t102 & t103);
    *((unsigned int *)t119) = t106;
    t105 = (t66 + 4);
    t118 = (t90 + 4);
    t120 = (t119 + 4);
    t107 = *((unsigned int *)t105);
    t108 = *((unsigned int *)t118);
    t110 = (t107 | t108);
    *((unsigned int *)t120) = t110;
    t111 = *((unsigned int *)t120);
    t112 = (t111 != 0);
    if (t112 == 1)
        goto LAB77;

LAB78:
LAB79:    goto LAB68;

LAB69:    *((unsigned int *)t82) = 1;
    goto LAB72;

LAB73:    *((unsigned int *)t90) = 1;
    goto LAB76;

LAB75:    t104 = (t90 + 4);
    *((unsigned int *)t90) = 1;
    *((unsigned int *)t104) = 1;
    goto LAB76;

LAB77:    t114 = *((unsigned int *)t119);
    t115 = *((unsigned int *)t120);
    *((unsigned int *)t119) = (t114 | t115);
    t121 = (t66 + 4);
    t122 = (t90 + 4);
    t116 = *((unsigned int *)t66);
    t117 = (~(t116));
    t123 = *((unsigned int *)t121);
    t124 = (~(t123));
    t125 = *((unsigned int *)t90);
    t126 = (~(t125));
    t127 = *((unsigned int *)t122);
    t128 = (~(t127));
    t109 = (t117 & t124);
    t113 = (t126 & t128);
    t129 = (~(t109));
    t130 = (~(t113));
    t131 = *((unsigned int *)t120);
    *((unsigned int *)t120) = (t131 & t129);
    t132 = *((unsigned int *)t120);
    *((unsigned int *)t120) = (t132 & t130);
    t133 = *((unsigned int *)t119);
    *((unsigned int *)t119) = (t133 & t129);
    t134 = *((unsigned int *)t119);
    *((unsigned int *)t119) = (t134 & t130);
    goto LAB79;

LAB80:    *((unsigned int *)t135) = 1;
    goto LAB83;

LAB82:    t142 = (t135 + 4);
    *((unsigned int *)t135) = 1;
    *((unsigned int *)t142) = 1;
    goto LAB83;

LAB84:    t155 = *((unsigned int *)t143);
    t156 = *((unsigned int *)t149);
    *((unsigned int *)t143) = (t155 | t156);
    t157 = (t34 + 4);
    t158 = (t135 + 4);
    t159 = *((unsigned int *)t157);
    t160 = (~(t159));
    t161 = *((unsigned int *)t34);
    t162 = (t161 & t160);
    t163 = *((unsigned int *)t158);
    t164 = (~(t163));
    t165 = *((unsigned int *)t135);
    t166 = (t165 & t164);
    t167 = (~(t162));
    t168 = (~(t166));
    t169 = *((unsigned int *)t149);
    *((unsigned int *)t149) = (t169 & t167);
    t170 = *((unsigned int *)t149);
    *((unsigned int *)t149) = (t170 & t168);
    goto LAB86;

LAB87:    *((unsigned int *)t15) = 1;
    goto LAB90;

LAB89:    t11 = (t15 + 4);
    *((unsigned int *)t15) = 1;
    *((unsigned int *)t11) = 1;
    goto LAB90;

LAB91:    t13 = (t0 + 2096U);
    t14 = *((char **)t13);
    memset(t19, 0, 8);
    t13 = (t14 + 4);
    t20 = *((unsigned int *)t13);
    t21 = (~(t20));
    t22 = *((unsigned int *)t14);
    t23 = (t22 & t21);
    t24 = (t23 & 1U);
    if (t24 != 0)
        goto LAB94;

LAB95:    if (*((unsigned int *)t13) != 0)
        goto LAB96;

LAB97:    t28 = *((unsigned int *)t15);
    t29 = *((unsigned int *)t19);
    t30 = (t28 & t29);
    *((unsigned int *)t26) = t30;
    t27 = (t15 + 4);
    t33 = (t19 + 4);
    t38 = (t26 + 4);
    t31 = *((unsigned int *)t27);
    t32 = *((unsigned int *)t33);
    t35 = (t31 | t32);
    *((unsigned int *)t38) = t35;
    t36 = *((unsigned int *)t38);
    t37 = (t36 != 0);
    if (t37 == 1)
        goto LAB98;

LAB99:
LAB100:    goto LAB93;

LAB94:    *((unsigned int *)t19) = 1;
    goto LAB97;

LAB96:    t25 = (t19 + 4);
    *((unsigned int *)t19) = 1;
    *((unsigned int *)t25) = 1;
    goto LAB97;

LAB98:    t41 = *((unsigned int *)t26);
    t42 = *((unsigned int *)t38);
    *((unsigned int *)t26) = (t41 | t42);
    t39 = (t15 + 4);
    t40 = (t19 + 4);
    t43 = *((unsigned int *)t15);
    t44 = (~(t43));
    t45 = *((unsigned int *)t39);
    t46 = (~(t45));
    t47 = *((unsigned int *)t19);
    t50 = (~(t47));
    t51 = *((unsigned int *)t40);
    t52 = (~(t51));
    t58 = (t44 & t46);
    t59 = (t50 & t52);
    t53 = (~(t58));
    t54 = (~(t59));
    t55 = *((unsigned int *)t38);
    *((unsigned int *)t38) = (t55 & t53);
    t56 = *((unsigned int *)t38);
    *((unsigned int *)t38) = (t56 & t54);
    t57 = *((unsigned int *)t26);
    *((unsigned int *)t26) = (t57 & t53);
    t60 = *((unsigned int *)t26);
    *((unsigned int *)t26) = (t60 & t54);
    goto LAB100;

}

static void Always_45_1(char *t0)
{
    char t13[8];
    char t14[8];
    char t29[8];
    char t30[8];
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t5;
    unsigned int t6;
    unsigned int t7;
    unsigned int t8;
    unsigned int t9;
    unsigned int t10;
    char *t11;
    char *t12;
    unsigned int t15;
    unsigned int t16;
    unsigned int t17;
    char *t18;
    char *t19;
    char *t20;
    unsigned int t21;
    unsigned int t22;
    unsigned int t23;
    unsigned int t24;
    char *t25;
    char *t26;
    char *t27;
    char *t28;

LAB0:    t1 = (t0 + 4456U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(45, ng0);
    t2 = (t0 + 5288);
    *((int *)t2) = 1;
    t3 = (t0 + 4488);
    *((char **)t3) = t2;
    *((char **)t1) = &&LAB4;

LAB1:    return;
LAB4:    xsi_set_current_line(46, ng0);
    t4 = (t0 + 1616U);
    t5 = *((char **)t4);
    t4 = (t5 + 4);
    t6 = *((unsigned int *)t4);
    t7 = (~(t6));
    t8 = *((unsigned int *)t5);
    t9 = (t8 & t7);
    t10 = (t9 != 0);
    if (t10 > 0)
        goto LAB5;

LAB6:    xsi_set_current_line(51, ng0);

LAB9:    xsi_set_current_line(52, ng0);
    t2 = (t0 + 1776U);
    t3 = *((char **)t2);
    t2 = (t0 + 3136);
    xsi_vlogvar_wait_assign_value(t2, t3, 0, 0, 1, 0LL);
    xsi_set_current_line(53, ng0);
    t2 = (t0 + 2976);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    memset(t14, 0, 8);
    t5 = (t4 + 4);
    t6 = *((unsigned int *)t5);
    t7 = (~(t6));
    t8 = *((unsigned int *)t4);
    t9 = (t8 & t7);
    t10 = (t9 & 1U);
    if (t10 != 0)
        goto LAB10;

LAB11:    if (*((unsigned int *)t5) != 0)
        goto LAB12;

LAB13:    t12 = (t14 + 4);
    t15 = *((unsigned int *)t14);
    t16 = *((unsigned int *)t12);
    t17 = (t15 || t16);
    if (t17 > 0)
        goto LAB14;

LAB15:    t21 = *((unsigned int *)t14);
    t22 = (~(t21));
    t23 = *((unsigned int *)t12);
    t24 = (t22 || t23);
    if (t24 > 0)
        goto LAB16;

LAB17:    if (*((unsigned int *)t12) > 0)
        goto LAB18;

LAB19:    if (*((unsigned int *)t14) > 0)
        goto LAB20;

LAB21:    memcpy(t13, t27, 8);

LAB22:    t28 = (t0 + 2496);
    xsi_vlogvar_wait_assign_value(t28, t13, 0, 0, 1, 0LL);
    xsi_set_current_line(54, ng0);
    t2 = (t0 + 2656);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    memset(t14, 0, 8);
    t5 = (t4 + 4);
    t6 = *((unsigned int *)t5);
    t7 = (~(t6));
    t8 = *((unsigned int *)t4);
    t9 = (t8 & t7);
    t10 = (t9 & 1U);
    if (t10 != 0)
        goto LAB23;

LAB24:    if (*((unsigned int *)t5) != 0)
        goto LAB25;

LAB26:    t12 = (t14 + 4);
    t15 = *((unsigned int *)t14);
    t16 = *((unsigned int *)t12);
    t17 = (t15 || t16);
    if (t17 > 0)
        goto LAB27;

LAB28:    t21 = *((unsigned int *)t14);
    t22 = (~(t21));
    t23 = *((unsigned int *)t12);
    t24 = (t22 || t23);
    if (t24 > 0)
        goto LAB29;

LAB30:    if (*((unsigned int *)t12) > 0)
        goto LAB31;

LAB32:    if (*((unsigned int *)t14) > 0)
        goto LAB33;

LAB34:    memcpy(t13, t30, 8);

LAB35:    t27 = (t0 + 3296);
    xsi_vlogvar_wait_assign_value(t27, t13, 0, 0, 19, 0LL);

LAB7:    goto LAB2;

LAB5:    xsi_set_current_line(46, ng0);

LAB8:    xsi_set_current_line(47, ng0);
    t11 = ((char*)((ng2)));
    t12 = (t0 + 3136);
    xsi_vlogvar_wait_assign_value(t12, t11, 0, 0, 1, 0LL);
    xsi_set_current_line(48, ng0);
    t2 = (t0 + 472);
    t3 = *((char **)t2);
    t2 = (t0 + 2496);
    xsi_vlogvar_wait_assign_value(t2, t3, 0, 0, 1, 0LL);
    xsi_set_current_line(49, ng0);
    t2 = ((char*)((ng3)));
    t3 = (t0 + 3296);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 19, 0LL);
    goto LAB7;

LAB10:    *((unsigned int *)t14) = 1;
    goto LAB13;

LAB12:    t11 = (t14 + 4);
    *((unsigned int *)t14) = 1;
    *((unsigned int *)t11) = 1;
    goto LAB13;

LAB14:    t18 = (t0 + 3136);
    t19 = (t18 + 56U);
    t20 = *((char **)t19);
    goto LAB15;

LAB16:    t25 = (t0 + 2496);
    t26 = (t25 + 56U);
    t27 = *((char **)t26);
    goto LAB17;

LAB18:    xsi_vlog_unsigned_bit_combine(t13, 1, t20, 1, t27, 1);
    goto LAB22;

LAB20:    memcpy(t13, t20, 8);
    goto LAB22;

LAB23:    *((unsigned int *)t14) = 1;
    goto LAB26;

LAB25:    t11 = (t14 + 4);
    *((unsigned int *)t14) = 1;
    *((unsigned int *)t11) = 1;
    goto LAB26;

LAB27:    t18 = ((char*)((ng3)));
    memcpy(t29, t18, 8);
    goto LAB28;

LAB29:    t19 = (t0 + 3296);
    t20 = (t19 + 56U);
    t25 = *((char **)t20);
    t26 = ((char*)((ng4)));
    memset(t30, 0, 8);
    xsi_vlog_unsigned_minus(t30, 32, t25, 19, t26, 32);
    goto LAB30;

LAB31:    xsi_vlog_unsigned_bit_combine(t13, 32, t29, 32, t30, 32);
    goto LAB35;

LAB33:    memcpy(t13, t29, 8);
    goto LAB35;

}

static void Cont_57_2(char *t0)
{
    char t8[8];
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t5;
    char *t6;
    char *t7;
    unsigned int t9;
    unsigned int t10;
    unsigned int t11;
    char *t12;
    char *t13;
    char *t14;
    unsigned int t15;
    unsigned int t16;
    unsigned int t17;
    unsigned int t18;
    unsigned int t19;
    unsigned int t20;
    unsigned int t21;
    char *t22;
    char *t23;
    char *t24;
    char *t25;
    char *t26;
    unsigned int t27;
    unsigned int t28;
    char *t29;
    unsigned int t30;
    unsigned int t31;
    char *t32;
    unsigned int t33;
    unsigned int t34;
    char *t35;

LAB0:    t1 = (t0 + 4704U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(57, ng0);
    t2 = (t0 + 3136);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    t5 = (t0 + 2496);
    t6 = (t5 + 56U);
    t7 = *((char **)t6);
    t9 = *((unsigned int *)t4);
    t10 = *((unsigned int *)t7);
    t11 = (t9 ^ t10);
    *((unsigned int *)t8) = t11;
    t12 = (t4 + 4);
    t13 = (t7 + 4);
    t14 = (t8 + 4);
    t15 = *((unsigned int *)t12);
    t16 = *((unsigned int *)t13);
    t17 = (t15 | t16);
    *((unsigned int *)t14) = t17;
    t18 = *((unsigned int *)t14);
    t19 = (t18 != 0);
    if (t19 == 1)
        goto LAB4;

LAB5:
LAB6:    t22 = (t0 + 5400);
    t23 = (t22 + 56U);
    t24 = *((char **)t23);
    t25 = (t24 + 56U);
    t26 = *((char **)t25);
    memset(t26, 0, 8);
    t27 = 1U;
    t28 = t27;
    t29 = (t8 + 4);
    t30 = *((unsigned int *)t8);
    t27 = (t27 & t30);
    t31 = *((unsigned int *)t29);
    t28 = (t28 & t31);
    t32 = (t26 + 4);
    t33 = *((unsigned int *)t26);
    *((unsigned int *)t26) = (t33 | t27);
    t34 = *((unsigned int *)t32);
    *((unsigned int *)t32) = (t34 | t28);
    xsi_driver_vfirst_trans(t22, 0, 0);
    t35 = (t0 + 5304);
    *((int *)t35) = 1;

LAB1:    return;
LAB4:    t20 = *((unsigned int *)t8);
    t21 = *((unsigned int *)t14);
    *((unsigned int *)t8) = (t20 | t21);
    goto LAB6;

}

static void Cont_58_3(char *t0)
{
    char t6[8];
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t5;
    char *t7;
    char *t8;
    unsigned int t9;
    unsigned int t10;
    unsigned int t11;
    unsigned int t12;
    unsigned int t13;
    unsigned int t14;
    unsigned int t15;
    unsigned int t16;
    unsigned int t17;
    unsigned int t18;
    unsigned int t19;
    unsigned int t20;
    char *t21;
    char *t22;
    char *t23;
    char *t24;
    char *t25;
    char *t26;
    unsigned int t27;
    unsigned int t28;
    char *t29;
    unsigned int t30;
    unsigned int t31;
    char *t32;
    unsigned int t33;
    unsigned int t34;
    char *t35;

LAB0:    t1 = (t0 + 4952U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(58, ng0);
    t2 = (t0 + 3296);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    t5 = ((char*)((ng2)));
    memset(t6, 0, 8);
    t7 = (t4 + 4);
    t8 = (t5 + 4);
    t9 = *((unsigned int *)t4);
    t10 = *((unsigned int *)t5);
    t11 = (t9 ^ t10);
    t12 = *((unsigned int *)t7);
    t13 = *((unsigned int *)t8);
    t14 = (t12 ^ t13);
    t15 = (t11 | t14);
    t16 = *((unsigned int *)t7);
    t17 = *((unsigned int *)t8);
    t18 = (t16 | t17);
    t19 = (~(t18));
    t20 = (t15 & t19);
    if (t20 != 0)
        goto LAB7;

LAB4:    if (t18 != 0)
        goto LAB6;

LAB5:    *((unsigned int *)t6) = 1;

LAB7:    t22 = (t0 + 5464);
    t23 = (t22 + 56U);
    t24 = *((char **)t23);
    t25 = (t24 + 56U);
    t26 = *((char **)t25);
    memset(t26, 0, 8);
    t27 = 1U;
    t28 = t27;
    t29 = (t6 + 4);
    t30 = *((unsigned int *)t6);
    t27 = (t27 & t30);
    t31 = *((unsigned int *)t29);
    t28 = (t28 & t31);
    t32 = (t26 + 4);
    t33 = *((unsigned int *)t26);
    *((unsigned int *)t26) = (t33 | t27);
    t34 = *((unsigned int *)t32);
    *((unsigned int *)t32) = (t34 | t28);
    xsi_driver_vfirst_trans(t22, 0, 0);
    t35 = (t0 + 5320);
    *((int *)t35) = 1;

LAB1:    return;
LAB6:    t21 = (t6 + 4);
    *((unsigned int *)t6) = 1;
    *((unsigned int *)t21) = 1;
    goto LAB7;

}


extern void work_m_00468998010657887037_1832158028_init()
{
	static char *pe[] = {(void *)Always_33_0,(void *)Always_45_1,(void *)Cont_57_2,(void *)Cont_58_3};
	xsi_register_didat("work_m_00468998010657887037_1832158028", "isim/vtach_test_isim_beh.exe.sim/work/m_00468998010657887037_1832158028.didat");
	xsi_register_executes(pe);
}
