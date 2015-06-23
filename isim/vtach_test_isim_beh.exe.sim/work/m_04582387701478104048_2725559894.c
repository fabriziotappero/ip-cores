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
static const char *ng0 = "/home/alw/projects/vtachspartan/alu.v";
static int ng1[] = {0, 0};
static unsigned int ng2[] = {8U, 0U};
static unsigned int ng3[] = {1U, 0U};
static unsigned int ng4[] = {153U, 0U};
static unsigned int ng5[] = {0U, 0U};
static unsigned int ng6[] = {0U, 8191U};
static unsigned int ng7[] = {6U, 0U};
static unsigned int ng8[] = {4U, 0U};
static unsigned int ng9[] = {9U, 0U};
static unsigned int ng10[] = {2U, 0U};
static unsigned int ng11[] = {3U, 0U};
static unsigned int ng12[] = {5U, 0U};
static unsigned int ng13[] = {7U, 0U};



static void Initial_21_0(char *t0)
{
    char *t1;
    char *t2;

LAB0:    xsi_set_current_line(21, ng0);
    t1 = ((char*)((ng1)));
    t2 = (t0 + 5928);
    xsi_vlogvar_assign_value(t2, t1, 0, 0, 1);

LAB1:    return;
}

static void Initial_22_1(char *t0)
{
    char *t1;
    char *t2;

LAB0:    xsi_set_current_line(22, ng0);
    t1 = ((char*)((ng1)));
    t2 = (t0 + 6408);
    xsi_vlogvar_assign_value(t2, t1, 0, 0, 1);

LAB1:    return;
}

static void Initial_23_2(char *t0)
{
    char *t1;
    char *t2;

LAB0:    xsi_set_current_line(23, ng0);
    t1 = ((char*)((ng1)));
    t2 = (t0 + 6568);
    xsi_vlogvar_assign_value(t2, t1, 0, 0, 1);

LAB1:    return;
}

static void Initial_24_3(char *t0)
{
    char *t1;
    char *t2;

LAB0:    xsi_set_current_line(24, ng0);
    t1 = ((char*)((ng1)));
    t2 = (t0 + 6088);
    xsi_vlogvar_assign_value(t2, t1, 0, 0, 1);

LAB1:    return;
}

static void Cont_27_4(char *t0)
{
    char t5[8];
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t6;
    char *t7;
    unsigned int t8;
    unsigned int t9;
    unsigned int t10;
    unsigned int t11;
    unsigned int t12;
    unsigned int t13;
    char *t14;
    char *t15;
    char *t16;
    char *t17;
    char *t18;
    unsigned int t19;
    unsigned int t20;
    char *t21;
    unsigned int t22;
    unsigned int t23;
    char *t24;
    unsigned int t25;
    unsigned int t26;
    char *t27;

LAB0:    t1 = (t0 + 8472U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(27, ng0);
    t2 = (t0 + 6248);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    memset(t5, 0, 8);
    t6 = (t5 + 4);
    t7 = (t4 + 4);
    t8 = *((unsigned int *)t4);
    t9 = (t8 >> 16);
    t10 = (t9 & 1);
    *((unsigned int *)t5) = t10;
    t11 = *((unsigned int *)t7);
    t12 = (t11 >> 16);
    t13 = (t12 & 1);
    *((unsigned int *)t6) = t13;
    t14 = (t0 + 10192);
    t15 = (t14 + 56U);
    t16 = *((char **)t15);
    t17 = (t16 + 56U);
    t18 = *((char **)t17);
    memset(t18, 0, 8);
    t19 = 1U;
    t20 = t19;
    t21 = (t5 + 4);
    t22 = *((unsigned int *)t5);
    t19 = (t19 & t22);
    t23 = *((unsigned int *)t21);
    t20 = (t20 & t23);
    t24 = (t18 + 4);
    t25 = *((unsigned int *)t18);
    *((unsigned int *)t18) = (t25 | t19);
    t26 = *((unsigned int *)t24);
    *((unsigned int *)t24) = (t26 | t20);
    xsi_driver_vfirst_trans(t14, 0, 0);
    t27 = (t0 + 10032);
    *((int *)t27) = 1;

LAB1:    return;
}

static void Cont_32_5(char *t0)
{
    char t3[8];
    char t4[8];
    char t5[8];
    char t15[8];
    char t31[8];
    char t47[8];
    char t63[8];
    char t71[8];
    char t119[8];
    char *t1;
    char *t2;
    char *t6;
    char *t7;
    unsigned int t8;
    unsigned int t9;
    unsigned int t10;
    unsigned int t11;
    unsigned int t12;
    unsigned int t13;
    char *t14;
    char *t16;
    char *t17;
    unsigned int t18;
    unsigned int t19;
    unsigned int t20;
    unsigned int t21;
    unsigned int t22;
    unsigned int t23;
    unsigned int t24;
    unsigned int t25;
    unsigned int t26;
    unsigned int t27;
    unsigned int t28;
    unsigned int t29;
    char *t30;
    char *t32;
    unsigned int t33;
    unsigned int t34;
    unsigned int t35;
    unsigned int t36;
    unsigned int t37;
    char *t38;
    char *t39;
    unsigned int t40;
    unsigned int t41;
    unsigned int t42;
    char *t43;
    char *t44;
    char *t45;
    char *t46;
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
    unsigned int t58;
    unsigned int t59;
    unsigned int t60;
    unsigned int t61;
    char *t62;
    char *t64;
    unsigned int t65;
    unsigned int t66;
    unsigned int t67;
    unsigned int t68;
    unsigned int t69;
    char *t70;
    unsigned int t72;
    unsigned int t73;
    unsigned int t74;
    char *t75;
    char *t76;
    char *t77;
    unsigned int t78;
    unsigned int t79;
    unsigned int t80;
    unsigned int t81;
    unsigned int t82;
    unsigned int t83;
    unsigned int t84;
    char *t85;
    char *t86;
    unsigned int t87;
    unsigned int t88;
    unsigned int t89;
    unsigned int t90;
    unsigned int t91;
    unsigned int t92;
    unsigned int t93;
    unsigned int t94;
    int t95;
    int t96;
    unsigned int t97;
    unsigned int t98;
    unsigned int t99;
    unsigned int t100;
    unsigned int t101;
    unsigned int t102;
    char *t103;
    unsigned int t104;
    unsigned int t105;
    unsigned int t106;
    unsigned int t107;
    unsigned int t108;
    char *t109;
    char *t110;
    unsigned int t111;
    unsigned int t112;
    unsigned int t113;
    char *t114;
    unsigned int t115;
    unsigned int t116;
    unsigned int t117;
    unsigned int t118;
    char *t120;
    char *t121;
    char *t122;
    unsigned int t123;
    unsigned int t124;
    unsigned int t125;
    unsigned int t126;
    unsigned int t127;
    unsigned int t128;
    char *t129;
    char *t130;
    char *t131;
    char *t132;
    char *t133;
    unsigned int t134;
    unsigned int t135;
    char *t136;
    unsigned int t137;
    unsigned int t138;
    char *t139;
    unsigned int t140;
    unsigned int t141;
    char *t142;

LAB0:    t1 = (t0 + 8720U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(32, ng0);
    t2 = (t0 + 1688U);
    t6 = *((char **)t2);
    memset(t5, 0, 8);
    t2 = (t5 + 4);
    t7 = (t6 + 4);
    t8 = *((unsigned int *)t6);
    t9 = (t8 >> 8);
    *((unsigned int *)t5) = t9;
    t10 = *((unsigned int *)t7);
    t11 = (t10 >> 8);
    *((unsigned int *)t2) = t11;
    t12 = *((unsigned int *)t5);
    *((unsigned int *)t5) = (t12 & 15U);
    t13 = *((unsigned int *)t2);
    *((unsigned int *)t2) = (t13 & 15U);
    t14 = ((char*)((ng2)));
    memset(t15, 0, 8);
    t16 = (t5 + 4);
    t17 = (t14 + 4);
    t18 = *((unsigned int *)t5);
    t19 = *((unsigned int *)t14);
    t20 = (t18 ^ t19);
    t21 = *((unsigned int *)t16);
    t22 = *((unsigned int *)t17);
    t23 = (t21 ^ t22);
    t24 = (t20 | t23);
    t25 = *((unsigned int *)t16);
    t26 = *((unsigned int *)t17);
    t27 = (t25 | t26);
    t28 = (~(t27));
    t29 = (t24 & t28);
    if (t29 != 0)
        goto LAB7;

LAB4:    if (t27 != 0)
        goto LAB6;

LAB5:    *((unsigned int *)t15) = 1;

LAB7:    memset(t31, 0, 8);
    t32 = (t15 + 4);
    t33 = *((unsigned int *)t32);
    t34 = (~(t33));
    t35 = *((unsigned int *)t15);
    t36 = (t35 & t34);
    t37 = (t36 & 1U);
    if (t37 != 0)
        goto LAB8;

LAB9:    if (*((unsigned int *)t32) != 0)
        goto LAB10;

LAB11:    t39 = (t31 + 4);
    t40 = *((unsigned int *)t31);
    t41 = *((unsigned int *)t39);
    t42 = (t40 || t41);
    if (t42 > 0)
        goto LAB12;

LAB13:    memcpy(t71, t31, 8);

LAB14:    memset(t4, 0, 8);
    t103 = (t71 + 4);
    t104 = *((unsigned int *)t103);
    t105 = (~(t104));
    t106 = *((unsigned int *)t71);
    t107 = (t106 & t105);
    t108 = (t107 & 1U);
    if (t108 != 0)
        goto LAB26;

LAB27:    if (*((unsigned int *)t103) != 0)
        goto LAB28;

LAB29:    t110 = (t4 + 4);
    t111 = *((unsigned int *)t4);
    t112 = *((unsigned int *)t110);
    t113 = (t111 || t112);
    if (t113 > 0)
        goto LAB30;

LAB31:    t115 = *((unsigned int *)t4);
    t116 = (~(t115));
    t117 = *((unsigned int *)t110);
    t118 = (t116 || t117);
    if (t118 > 0)
        goto LAB32;

LAB33:    if (*((unsigned int *)t110) > 0)
        goto LAB34;

LAB35:    if (*((unsigned int *)t4) > 0)
        goto LAB36;

LAB37:    memcpy(t3, t119, 8);

LAB38:    t129 = (t0 + 10256);
    t130 = (t129 + 56U);
    t131 = *((char **)t130);
    t132 = (t131 + 56U);
    t133 = *((char **)t132);
    memset(t133, 0, 8);
    t134 = 255U;
    t135 = t134;
    t136 = (t3 + 4);
    t137 = *((unsigned int *)t3);
    t134 = (t134 & t137);
    t138 = *((unsigned int *)t136);
    t135 = (t135 & t138);
    t139 = (t133 + 4);
    t140 = *((unsigned int *)t133);
    *((unsigned int *)t133) = (t140 | t134);
    t141 = *((unsigned int *)t139);
    *((unsigned int *)t139) = (t141 | t135);
    xsi_driver_vfirst_trans(t129, 0, 7);
    t142 = (t0 + 10048);
    *((int *)t142) = 1;

LAB1:    return;
LAB6:    t30 = (t15 + 4);
    *((unsigned int *)t15) = 1;
    *((unsigned int *)t30) = 1;
    goto LAB7;

LAB8:    *((unsigned int *)t31) = 1;
    goto LAB11;

LAB10:    t38 = (t31 + 4);
    *((unsigned int *)t31) = 1;
    *((unsigned int *)t38) = 1;
    goto LAB11;

LAB12:    t43 = (t0 + 5928);
    t44 = (t43 + 56U);
    t45 = *((char **)t44);
    t46 = ((char*)((ng3)));
    memset(t47, 0, 8);
    t48 = (t45 + 4);
    t49 = (t46 + 4);
    t50 = *((unsigned int *)t45);
    t51 = *((unsigned int *)t46);
    t52 = (t50 ^ t51);
    t53 = *((unsigned int *)t48);
    t54 = *((unsigned int *)t49);
    t55 = (t53 ^ t54);
    t56 = (t52 | t55);
    t57 = *((unsigned int *)t48);
    t58 = *((unsigned int *)t49);
    t59 = (t57 | t58);
    t60 = (~(t59));
    t61 = (t56 & t60);
    if (t61 != 0)
        goto LAB18;

LAB15:    if (t59 != 0)
        goto LAB17;

LAB16:    *((unsigned int *)t47) = 1;

LAB18:    memset(t63, 0, 8);
    t64 = (t47 + 4);
    t65 = *((unsigned int *)t64);
    t66 = (~(t65));
    t67 = *((unsigned int *)t47);
    t68 = (t67 & t66);
    t69 = (t68 & 1U);
    if (t69 != 0)
        goto LAB19;

LAB20:    if (*((unsigned int *)t64) != 0)
        goto LAB21;

LAB22:    t72 = *((unsigned int *)t31);
    t73 = *((unsigned int *)t63);
    t74 = (t72 & t73);
    *((unsigned int *)t71) = t74;
    t75 = (t31 + 4);
    t76 = (t63 + 4);
    t77 = (t71 + 4);
    t78 = *((unsigned int *)t75);
    t79 = *((unsigned int *)t76);
    t80 = (t78 | t79);
    *((unsigned int *)t77) = t80;
    t81 = *((unsigned int *)t77);
    t82 = (t81 != 0);
    if (t82 == 1)
        goto LAB23;

LAB24:
LAB25:    goto LAB14;

LAB17:    t62 = (t47 + 4);
    *((unsigned int *)t47) = 1;
    *((unsigned int *)t62) = 1;
    goto LAB18;

LAB19:    *((unsigned int *)t63) = 1;
    goto LAB22;

LAB21:    t70 = (t63 + 4);
    *((unsigned int *)t63) = 1;
    *((unsigned int *)t70) = 1;
    goto LAB22;

LAB23:    t83 = *((unsigned int *)t71);
    t84 = *((unsigned int *)t77);
    *((unsigned int *)t71) = (t83 | t84);
    t85 = (t31 + 4);
    t86 = (t63 + 4);
    t87 = *((unsigned int *)t31);
    t88 = (~(t87));
    t89 = *((unsigned int *)t85);
    t90 = (~(t89));
    t91 = *((unsigned int *)t63);
    t92 = (~(t91));
    t93 = *((unsigned int *)t86);
    t94 = (~(t93));
    t95 = (t88 & t90);
    t96 = (t92 & t94);
    t97 = (~(t95));
    t98 = (~(t96));
    t99 = *((unsigned int *)t77);
    *((unsigned int *)t77) = (t99 & t97);
    t100 = *((unsigned int *)t77);
    *((unsigned int *)t77) = (t100 & t98);
    t101 = *((unsigned int *)t71);
    *((unsigned int *)t71) = (t101 & t97);
    t102 = *((unsigned int *)t71);
    *((unsigned int *)t71) = (t102 & t98);
    goto LAB25;

LAB26:    *((unsigned int *)t4) = 1;
    goto LAB29;

LAB28:    t109 = (t4 + 4);
    *((unsigned int *)t4) = 1;
    *((unsigned int *)t109) = 1;
    goto LAB29;

LAB30:    t114 = ((char*)((ng4)));
    goto LAB31;

LAB32:    t120 = (t0 + 1688U);
    t121 = *((char **)t120);
    memset(t119, 0, 8);
    t120 = (t119 + 4);
    t122 = (t121 + 4);
    t123 = *((unsigned int *)t121);
    t124 = (t123 >> 0);
    *((unsigned int *)t119) = t124;
    t125 = *((unsigned int *)t122);
    t126 = (t125 >> 0);
    *((unsigned int *)t120) = t126;
    t127 = *((unsigned int *)t119);
    *((unsigned int *)t119) = (t127 & 255U);
    t128 = *((unsigned int *)t120);
    *((unsigned int *)t120) = (t128 & 255U);
    goto LAB33;

LAB34:    xsi_vlog_unsigned_bit_combine(t3, 8, t114, 8, t119, 8);
    goto LAB38;

LAB36:    memcpy(t3, t114, 8);
    goto LAB38;

}

static void Cont_35_6(char *t0)
{
    char t3[8];
    char t4[8];
    char t5[8];
    char t15[8];
    char t31[8];
    char t47[8];
    char t63[8];
    char t71[8];
    char t114[8];
    char *t1;
    char *t2;
    char *t6;
    char *t7;
    unsigned int t8;
    unsigned int t9;
    unsigned int t10;
    unsigned int t11;
    unsigned int t12;
    unsigned int t13;
    char *t14;
    char *t16;
    char *t17;
    unsigned int t18;
    unsigned int t19;
    unsigned int t20;
    unsigned int t21;
    unsigned int t22;
    unsigned int t23;
    unsigned int t24;
    unsigned int t25;
    unsigned int t26;
    unsigned int t27;
    unsigned int t28;
    unsigned int t29;
    char *t30;
    char *t32;
    unsigned int t33;
    unsigned int t34;
    unsigned int t35;
    unsigned int t36;
    unsigned int t37;
    char *t38;
    char *t39;
    unsigned int t40;
    unsigned int t41;
    unsigned int t42;
    char *t43;
    char *t44;
    char *t45;
    char *t46;
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
    unsigned int t58;
    unsigned int t59;
    unsigned int t60;
    unsigned int t61;
    char *t62;
    char *t64;
    unsigned int t65;
    unsigned int t66;
    unsigned int t67;
    unsigned int t68;
    unsigned int t69;
    char *t70;
    unsigned int t72;
    unsigned int t73;
    unsigned int t74;
    char *t75;
    char *t76;
    char *t77;
    unsigned int t78;
    unsigned int t79;
    unsigned int t80;
    unsigned int t81;
    unsigned int t82;
    unsigned int t83;
    unsigned int t84;
    char *t85;
    char *t86;
    unsigned int t87;
    unsigned int t88;
    unsigned int t89;
    unsigned int t90;
    unsigned int t91;
    unsigned int t92;
    unsigned int t93;
    unsigned int t94;
    int t95;
    int t96;
    unsigned int t97;
    unsigned int t98;
    unsigned int t99;
    unsigned int t100;
    unsigned int t101;
    unsigned int t102;
    char *t103;
    unsigned int t104;
    unsigned int t105;
    unsigned int t106;
    unsigned int t107;
    unsigned int t108;
    char *t109;
    char *t110;
    unsigned int t111;
    unsigned int t112;
    unsigned int t113;
    char *t115;
    char *t116;
    unsigned int t117;
    unsigned int t118;
    unsigned int t119;
    unsigned int t120;
    char *t121;
    char *t122;
    char *t123;
    char *t124;
    char *t125;
    char *t126;
    unsigned int t127;
    unsigned int t128;
    char *t129;
    unsigned int t130;
    unsigned int t131;
    char *t132;
    unsigned int t133;
    unsigned int t134;
    char *t135;

LAB0:    t1 = (t0 + 8968U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(35, ng0);
    t2 = (t0 + 1688U);
    t6 = *((char **)t2);
    memset(t5, 0, 8);
    t2 = (t5 + 4);
    t7 = (t6 + 4);
    t8 = *((unsigned int *)t6);
    t9 = (t8 >> 8);
    *((unsigned int *)t5) = t9;
    t10 = *((unsigned int *)t7);
    t11 = (t10 >> 8);
    *((unsigned int *)t2) = t11;
    t12 = *((unsigned int *)t5);
    *((unsigned int *)t5) = (t12 & 15U);
    t13 = *((unsigned int *)t2);
    *((unsigned int *)t2) = (t13 & 15U);
    t14 = ((char*)((ng2)));
    memset(t15, 0, 8);
    t16 = (t5 + 4);
    t17 = (t14 + 4);
    t18 = *((unsigned int *)t5);
    t19 = *((unsigned int *)t14);
    t20 = (t18 ^ t19);
    t21 = *((unsigned int *)t16);
    t22 = *((unsigned int *)t17);
    t23 = (t21 ^ t22);
    t24 = (t20 | t23);
    t25 = *((unsigned int *)t16);
    t26 = *((unsigned int *)t17);
    t27 = (t25 | t26);
    t28 = (~(t27));
    t29 = (t24 & t28);
    if (t29 != 0)
        goto LAB7;

LAB4:    if (t27 != 0)
        goto LAB6;

LAB5:    *((unsigned int *)t15) = 1;

LAB7:    memset(t31, 0, 8);
    t32 = (t15 + 4);
    t33 = *((unsigned int *)t32);
    t34 = (~(t33));
    t35 = *((unsigned int *)t15);
    t36 = (t35 & t34);
    t37 = (t36 & 1U);
    if (t37 != 0)
        goto LAB8;

LAB9:    if (*((unsigned int *)t32) != 0)
        goto LAB10;

LAB11:    t39 = (t31 + 4);
    t40 = *((unsigned int *)t31);
    t41 = *((unsigned int *)t39);
    t42 = (t40 || t41);
    if (t42 > 0)
        goto LAB12;

LAB13:    memcpy(t71, t31, 8);

LAB14:    memset(t4, 0, 8);
    t103 = (t71 + 4);
    t104 = *((unsigned int *)t103);
    t105 = (~(t104));
    t106 = *((unsigned int *)t71);
    t107 = (t106 & t105);
    t108 = (t107 & 1U);
    if (t108 != 0)
        goto LAB26;

LAB27:    if (*((unsigned int *)t103) != 0)
        goto LAB28;

LAB29:    t110 = (t4 + 4);
    t111 = *((unsigned int *)t4);
    t112 = *((unsigned int *)t110);
    t113 = (t111 || t112);
    if (t113 > 0)
        goto LAB30;

LAB31:    t117 = *((unsigned int *)t4);
    t118 = (~(t117));
    t119 = *((unsigned int *)t110);
    t120 = (t118 || t119);
    if (t120 > 0)
        goto LAB32;

LAB33:    if (*((unsigned int *)t110) > 0)
        goto LAB34;

LAB35:    if (*((unsigned int *)t4) > 0)
        goto LAB36;

LAB37:    memcpy(t3, t121, 8);

LAB38:    t122 = (t0 + 10320);
    t123 = (t122 + 56U);
    t124 = *((char **)t123);
    t125 = (t124 + 56U);
    t126 = *((char **)t125);
    memset(t126, 0, 8);
    t127 = 8191U;
    t128 = t127;
    t129 = (t3 + 4);
    t130 = *((unsigned int *)t3);
    t127 = (t127 & t130);
    t131 = *((unsigned int *)t129);
    t128 = (t128 & t131);
    t132 = (t126 + 4);
    t133 = *((unsigned int *)t126);
    *((unsigned int *)t126) = (t133 | t127);
    t134 = *((unsigned int *)t132);
    *((unsigned int *)t132) = (t134 | t128);
    xsi_driver_vfirst_trans(t122, 0, 12);
    t135 = (t0 + 10064);
    *((int *)t135) = 1;

LAB1:    return;
LAB6:    t30 = (t15 + 4);
    *((unsigned int *)t15) = 1;
    *((unsigned int *)t30) = 1;
    goto LAB7;

LAB8:    *((unsigned int *)t31) = 1;
    goto LAB11;

LAB10:    t38 = (t31 + 4);
    *((unsigned int *)t31) = 1;
    *((unsigned int *)t38) = 1;
    goto LAB11;

LAB12:    t43 = (t0 + 5928);
    t44 = (t43 + 56U);
    t45 = *((char **)t44);
    t46 = ((char*)((ng3)));
    memset(t47, 0, 8);
    t48 = (t45 + 4);
    t49 = (t46 + 4);
    t50 = *((unsigned int *)t45);
    t51 = *((unsigned int *)t46);
    t52 = (t50 ^ t51);
    t53 = *((unsigned int *)t48);
    t54 = *((unsigned int *)t49);
    t55 = (t53 ^ t54);
    t56 = (t52 | t55);
    t57 = *((unsigned int *)t48);
    t58 = *((unsigned int *)t49);
    t59 = (t57 | t58);
    t60 = (~(t59));
    t61 = (t56 & t60);
    if (t61 != 0)
        goto LAB18;

LAB15:    if (t59 != 0)
        goto LAB17;

LAB16:    *((unsigned int *)t47) = 1;

LAB18:    memset(t63, 0, 8);
    t64 = (t47 + 4);
    t65 = *((unsigned int *)t64);
    t66 = (~(t65));
    t67 = *((unsigned int *)t47);
    t68 = (t67 & t66);
    t69 = (t68 & 1U);
    if (t69 != 0)
        goto LAB19;

LAB20:    if (*((unsigned int *)t64) != 0)
        goto LAB21;

LAB22:    t72 = *((unsigned int *)t31);
    t73 = *((unsigned int *)t63);
    t74 = (t72 & t73);
    *((unsigned int *)t71) = t74;
    t75 = (t31 + 4);
    t76 = (t63 + 4);
    t77 = (t71 + 4);
    t78 = *((unsigned int *)t75);
    t79 = *((unsigned int *)t76);
    t80 = (t78 | t79);
    *((unsigned int *)t77) = t80;
    t81 = *((unsigned int *)t77);
    t82 = (t81 != 0);
    if (t82 == 1)
        goto LAB23;

LAB24:
LAB25:    goto LAB14;

LAB17:    t62 = (t47 + 4);
    *((unsigned int *)t47) = 1;
    *((unsigned int *)t62) = 1;
    goto LAB18;

LAB19:    *((unsigned int *)t63) = 1;
    goto LAB22;

LAB21:    t70 = (t63 + 4);
    *((unsigned int *)t63) = 1;
    *((unsigned int *)t70) = 1;
    goto LAB22;

LAB23:    t83 = *((unsigned int *)t71);
    t84 = *((unsigned int *)t77);
    *((unsigned int *)t71) = (t83 | t84);
    t85 = (t31 + 4);
    t86 = (t63 + 4);
    t87 = *((unsigned int *)t31);
    t88 = (~(t87));
    t89 = *((unsigned int *)t85);
    t90 = (~(t89));
    t91 = *((unsigned int *)t63);
    t92 = (~(t91));
    t93 = *((unsigned int *)t86);
    t94 = (~(t93));
    t95 = (t88 & t90);
    t96 = (t92 & t94);
    t97 = (~(t95));
    t98 = (~(t96));
    t99 = *((unsigned int *)t77);
    *((unsigned int *)t77) = (t99 & t97);
    t100 = *((unsigned int *)t77);
    *((unsigned int *)t77) = (t100 & t98);
    t101 = *((unsigned int *)t71);
    *((unsigned int *)t71) = (t101 & t97);
    t102 = *((unsigned int *)t71);
    *((unsigned int *)t71) = (t102 & t98);
    goto LAB25;

LAB26:    *((unsigned int *)t4) = 1;
    goto LAB29;

LAB28:    t109 = (t4 + 4);
    *((unsigned int *)t4) = 1;
    *((unsigned int *)t109) = 1;
    goto LAB29;

LAB30:    t115 = (t0 + 1368U);
    t116 = *((char **)t115);
    t115 = ((char*)((ng5)));
    xsi_vlogtype_concat(t114, 13, 13, 2U, t115, 5, t116, 8);
    goto LAB31;

LAB32:    t121 = ((char*)((ng6)));
    goto LAB33;

LAB34:    xsi_vlog_unsigned_bit_combine(t3, 13, t114, 13, t121, 13);
    goto LAB38;

LAB36:    memcpy(t3, t114, 8);
    goto LAB38;

}

static void Cont_38_7(char *t0)
{
    char t3[8];
    char t4[8];
    char t5[8];
    char t15[8];
    char t31[8];
    char t47[8];
    char t63[8];
    char t71[8];
    char t114[8];
    char t115[8];
    char t130[8];
    char *t1;
    char *t2;
    char *t6;
    char *t7;
    unsigned int t8;
    unsigned int t9;
    unsigned int t10;
    unsigned int t11;
    unsigned int t12;
    unsigned int t13;
    char *t14;
    char *t16;
    char *t17;
    unsigned int t18;
    unsigned int t19;
    unsigned int t20;
    unsigned int t21;
    unsigned int t22;
    unsigned int t23;
    unsigned int t24;
    unsigned int t25;
    unsigned int t26;
    unsigned int t27;
    unsigned int t28;
    unsigned int t29;
    char *t30;
    char *t32;
    unsigned int t33;
    unsigned int t34;
    unsigned int t35;
    unsigned int t36;
    unsigned int t37;
    char *t38;
    char *t39;
    unsigned int t40;
    unsigned int t41;
    unsigned int t42;
    char *t43;
    char *t44;
    char *t45;
    char *t46;
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
    unsigned int t58;
    unsigned int t59;
    unsigned int t60;
    unsigned int t61;
    char *t62;
    char *t64;
    unsigned int t65;
    unsigned int t66;
    unsigned int t67;
    unsigned int t68;
    unsigned int t69;
    char *t70;
    unsigned int t72;
    unsigned int t73;
    unsigned int t74;
    char *t75;
    char *t76;
    char *t77;
    unsigned int t78;
    unsigned int t79;
    unsigned int t80;
    unsigned int t81;
    unsigned int t82;
    unsigned int t83;
    unsigned int t84;
    char *t85;
    char *t86;
    unsigned int t87;
    unsigned int t88;
    unsigned int t89;
    unsigned int t90;
    unsigned int t91;
    unsigned int t92;
    unsigned int t93;
    unsigned int t94;
    int t95;
    int t96;
    unsigned int t97;
    unsigned int t98;
    unsigned int t99;
    unsigned int t100;
    unsigned int t101;
    unsigned int t102;
    char *t103;
    unsigned int t104;
    unsigned int t105;
    unsigned int t106;
    unsigned int t107;
    unsigned int t108;
    char *t109;
    char *t110;
    unsigned int t111;
    unsigned int t112;
    unsigned int t113;
    char *t116;
    char *t117;
    char *t118;
    char *t119;
    char *t120;
    unsigned int t121;
    unsigned int t122;
    unsigned int t123;
    unsigned int t124;
    unsigned int t125;
    unsigned int t126;
    char *t127;
    char *t128;
    char *t129;
    char *t131;
    char *t132;
    unsigned int t133;
    unsigned int t134;
    unsigned int t135;
    unsigned int t136;
    unsigned int t137;
    unsigned int t138;
    unsigned int t139;
    unsigned int t140;
    unsigned int t141;
    unsigned int t142;
    char *t143;
    char *t144;
    char *t145;
    char *t146;
    char *t147;
    char *t148;
    unsigned int t149;
    unsigned int t150;
    char *t151;
    unsigned int t152;
    unsigned int t153;
    char *t154;
    unsigned int t155;
    unsigned int t156;
    char *t157;

LAB0:    t1 = (t0 + 9216U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(38, ng0);
    t2 = (t0 + 1688U);
    t6 = *((char **)t2);
    memset(t5, 0, 8);
    t2 = (t5 + 4);
    t7 = (t6 + 4);
    t8 = *((unsigned int *)t6);
    t9 = (t8 >> 8);
    *((unsigned int *)t5) = t9;
    t10 = *((unsigned int *)t7);
    t11 = (t10 >> 8);
    *((unsigned int *)t2) = t11;
    t12 = *((unsigned int *)t5);
    *((unsigned int *)t5) = (t12 & 15U);
    t13 = *((unsigned int *)t2);
    *((unsigned int *)t2) = (t13 & 15U);
    t14 = ((char*)((ng7)));
    memset(t15, 0, 8);
    t16 = (t5 + 4);
    t17 = (t14 + 4);
    t18 = *((unsigned int *)t5);
    t19 = *((unsigned int *)t14);
    t20 = (t18 ^ t19);
    t21 = *((unsigned int *)t16);
    t22 = *((unsigned int *)t17);
    t23 = (t21 ^ t22);
    t24 = (t20 | t23);
    t25 = *((unsigned int *)t16);
    t26 = *((unsigned int *)t17);
    t27 = (t25 | t26);
    t28 = (~(t27));
    t29 = (t24 & t28);
    if (t29 != 0)
        goto LAB7;

LAB4:    if (t27 != 0)
        goto LAB6;

LAB5:    *((unsigned int *)t15) = 1;

LAB7:    memset(t31, 0, 8);
    t32 = (t15 + 4);
    t33 = *((unsigned int *)t32);
    t34 = (~(t33));
    t35 = *((unsigned int *)t15);
    t36 = (t35 & t34);
    t37 = (t36 & 1U);
    if (t37 != 0)
        goto LAB8;

LAB9:    if (*((unsigned int *)t32) != 0)
        goto LAB10;

LAB11:    t39 = (t31 + 4);
    t40 = *((unsigned int *)t31);
    t41 = *((unsigned int *)t39);
    t42 = (t40 || t41);
    if (t42 > 0)
        goto LAB12;

LAB13:    memcpy(t71, t31, 8);

LAB14:    memset(t4, 0, 8);
    t103 = (t71 + 4);
    t104 = *((unsigned int *)t103);
    t105 = (~(t104));
    t106 = *((unsigned int *)t71);
    t107 = (t106 & t105);
    t108 = (t107 & 1U);
    if (t108 != 0)
        goto LAB26;

LAB27:    if (*((unsigned int *)t103) != 0)
        goto LAB28;

LAB29:    t110 = (t4 + 4);
    t111 = *((unsigned int *)t4);
    t112 = *((unsigned int *)t110);
    t113 = (t111 || t112);
    if (t113 > 0)
        goto LAB30;

LAB31:    t139 = *((unsigned int *)t4);
    t140 = (~(t139));
    t141 = *((unsigned int *)t110);
    t142 = (t140 || t141);
    if (t142 > 0)
        goto LAB32;

LAB33:    if (*((unsigned int *)t110) > 0)
        goto LAB34;

LAB35:    if (*((unsigned int *)t4) > 0)
        goto LAB36;

LAB37:    memcpy(t3, t143, 8);

LAB38:    t144 = (t0 + 10384);
    t145 = (t144 + 56U);
    t146 = *((char **)t145);
    t147 = (t146 + 56U);
    t148 = *((char **)t147);
    memset(t148, 0, 8);
    t149 = 8191U;
    t150 = t149;
    t151 = (t3 + 4);
    t152 = *((unsigned int *)t3);
    t149 = (t149 & t152);
    t153 = *((unsigned int *)t151);
    t150 = (t150 & t153);
    t154 = (t148 + 4);
    t155 = *((unsigned int *)t148);
    *((unsigned int *)t148) = (t155 | t149);
    t156 = *((unsigned int *)t154);
    *((unsigned int *)t154) = (t156 | t150);
    xsi_driver_vfirst_trans(t144, 0, 12);
    t157 = (t0 + 10080);
    *((int *)t157) = 1;

LAB1:    return;
LAB6:    t30 = (t15 + 4);
    *((unsigned int *)t15) = 1;
    *((unsigned int *)t30) = 1;
    goto LAB7;

LAB8:    *((unsigned int *)t31) = 1;
    goto LAB11;

LAB10:    t38 = (t31 + 4);
    *((unsigned int *)t31) = 1;
    *((unsigned int *)t38) = 1;
    goto LAB11;

LAB12:    t43 = (t0 + 5928);
    t44 = (t43 + 56U);
    t45 = *((char **)t44);
    t46 = ((char*)((ng3)));
    memset(t47, 0, 8);
    t48 = (t45 + 4);
    t49 = (t46 + 4);
    t50 = *((unsigned int *)t45);
    t51 = *((unsigned int *)t46);
    t52 = (t50 ^ t51);
    t53 = *((unsigned int *)t48);
    t54 = *((unsigned int *)t49);
    t55 = (t53 ^ t54);
    t56 = (t52 | t55);
    t57 = *((unsigned int *)t48);
    t58 = *((unsigned int *)t49);
    t59 = (t57 | t58);
    t60 = (~(t59));
    t61 = (t56 & t60);
    if (t61 != 0)
        goto LAB18;

LAB15:    if (t59 != 0)
        goto LAB17;

LAB16:    *((unsigned int *)t47) = 1;

LAB18:    memset(t63, 0, 8);
    t64 = (t47 + 4);
    t65 = *((unsigned int *)t64);
    t66 = (~(t65));
    t67 = *((unsigned int *)t47);
    t68 = (t67 & t66);
    t69 = (t68 & 1U);
    if (t69 != 0)
        goto LAB19;

LAB20:    if (*((unsigned int *)t64) != 0)
        goto LAB21;

LAB22:    t72 = *((unsigned int *)t31);
    t73 = *((unsigned int *)t63);
    t74 = (t72 & t73);
    *((unsigned int *)t71) = t74;
    t75 = (t31 + 4);
    t76 = (t63 + 4);
    t77 = (t71 + 4);
    t78 = *((unsigned int *)t75);
    t79 = *((unsigned int *)t76);
    t80 = (t78 | t79);
    *((unsigned int *)t77) = t80;
    t81 = *((unsigned int *)t77);
    t82 = (t81 != 0);
    if (t82 == 1)
        goto LAB23;

LAB24:
LAB25:    goto LAB14;

LAB17:    t62 = (t47 + 4);
    *((unsigned int *)t47) = 1;
    *((unsigned int *)t62) = 1;
    goto LAB18;

LAB19:    *((unsigned int *)t63) = 1;
    goto LAB22;

LAB21:    t70 = (t63 + 4);
    *((unsigned int *)t63) = 1;
    *((unsigned int *)t70) = 1;
    goto LAB22;

LAB23:    t83 = *((unsigned int *)t71);
    t84 = *((unsigned int *)t77);
    *((unsigned int *)t71) = (t83 | t84);
    t85 = (t31 + 4);
    t86 = (t63 + 4);
    t87 = *((unsigned int *)t31);
    t88 = (~(t87));
    t89 = *((unsigned int *)t85);
    t90 = (~(t89));
    t91 = *((unsigned int *)t63);
    t92 = (~(t91));
    t93 = *((unsigned int *)t86);
    t94 = (~(t93));
    t95 = (t88 & t90);
    t96 = (t92 & t94);
    t97 = (~(t95));
    t98 = (~(t96));
    t99 = *((unsigned int *)t77);
    *((unsigned int *)t77) = (t99 & t97);
    t100 = *((unsigned int *)t77);
    *((unsigned int *)t77) = (t100 & t98);
    t101 = *((unsigned int *)t71);
    *((unsigned int *)t71) = (t101 & t97);
    t102 = *((unsigned int *)t71);
    *((unsigned int *)t71) = (t102 & t98);
    goto LAB25;

LAB26:    *((unsigned int *)t4) = 1;
    goto LAB29;

LAB28:    t109 = (t4 + 4);
    *((unsigned int *)t4) = 1;
    *((unsigned int *)t109) = 1;
    goto LAB29;

LAB30:    t116 = (t0 + 6248);
    t117 = (t116 + 56U);
    t118 = *((char **)t117);
    memset(t115, 0, 8);
    t119 = (t115 + 4);
    t120 = (t118 + 4);
    t121 = *((unsigned int *)t118);
    t122 = (t121 >> 0);
    *((unsigned int *)t115) = t122;
    t123 = *((unsigned int *)t120);
    t124 = (t123 >> 0);
    *((unsigned int *)t119) = t124;
    t125 = *((unsigned int *)t115);
    *((unsigned int *)t115) = (t125 & 4095U);
    t126 = *((unsigned int *)t119);
    *((unsigned int *)t119) = (t126 & 4095U);
    t127 = (t0 + 6248);
    t128 = (t127 + 56U);
    t129 = *((char **)t128);
    memset(t130, 0, 8);
    t131 = (t130 + 4);
    t132 = (t129 + 4);
    t133 = *((unsigned int *)t129);
    t134 = (t133 >> 16);
    t135 = (t134 & 1);
    *((unsigned int *)t130) = t135;
    t136 = *((unsigned int *)t132);
    t137 = (t136 >> 16);
    t138 = (t137 & 1);
    *((unsigned int *)t131) = t138;
    xsi_vlogtype_concat(t114, 13, 13, 2U, t130, 1, t115, 12);
    goto LAB31;

LAB32:    t143 = ((char*)((ng6)));
    goto LAB33;

LAB34:    xsi_vlog_unsigned_bit_combine(t3, 13, t114, 13, t143, 13);
    goto LAB38;

LAB36:    memcpy(t3, t114, 8);
    goto LAB38;

}

static void Always_47_8(char *t0)
{
    char t6[8];
    char t28[8];
    char t42[8];
    char t66[8];
    char t67[8];
    char t68[8];
    char t69[8];
    char t71[8];
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
    unsigned int t23;
    unsigned int t24;
    unsigned int t25;
    unsigned int t26;
    unsigned int t27;
    char *t29;
    char *t30;
    char *t31;
    unsigned int t32;
    unsigned int t33;
    unsigned int t34;
    unsigned int t35;
    unsigned int t36;
    unsigned int t37;
    char *t38;
    int t39;
    char *t40;
    char *t41;
    char *t43;
    char *t44;
    unsigned int t45;
    unsigned int t46;
    unsigned int t47;
    unsigned int t48;
    unsigned int t49;
    unsigned int t50;
    unsigned int t51;
    unsigned int t52;
    unsigned int t53;
    unsigned int t54;
    unsigned int t55;
    unsigned int t56;
    char *t57;
    char *t58;
    unsigned int t59;
    unsigned int t60;
    unsigned int t61;
    unsigned int t62;
    unsigned int t63;
    char *t64;
    char *t65;
    unsigned int t70;
    char *t72;
    unsigned int t73;
    unsigned int t74;
    unsigned int t75;
    unsigned int t76;
    unsigned int t77;
    unsigned int t78;
    char *t79;
    int t80;
    int t81;
    int t82;

LAB0:    t1 = (t0 + 9464U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(47, ng0);
    t2 = (t0 + 10096);
    *((int *)t2) = 1;
    t3 = (t0 + 9496);
    *((char **)t3) = t2;
    *((char **)t1) = &&LAB4;

LAB1:    return;
LAB4:    xsi_set_current_line(48, ng0);

LAB5:    xsi_set_current_line(49, ng0);
    t4 = (t0 + 2168U);
    t5 = *((char **)t4);
    t4 = ((char*)((ng5)));
    memset(t6, 0, 8);
    t7 = (t5 + 4);
    t8 = (t4 + 4);
    t9 = *((unsigned int *)t5);
    t10 = *((unsigned int *)t4);
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
        goto LAB9;

LAB6:    if (t18 != 0)
        goto LAB8;

LAB7:    *((unsigned int *)t6) = 1;

LAB9:    t22 = (t6 + 4);
    t23 = *((unsigned int *)t22);
    t24 = (~(t23));
    t25 = *((unsigned int *)t6);
    t26 = (t25 & t24);
    t27 = (t26 != 0);
    if (t27 > 0)
        goto LAB10;

LAB11:    xsi_set_current_line(134, ng0);

LAB169:    xsi_set_current_line(135, ng0);
    t2 = ((char*)((ng5)));
    t3 = (t0 + 5928);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);
    xsi_set_current_line(136, ng0);
    t2 = ((char*)((ng5)));
    t3 = (t0 + 6408);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);
    xsi_set_current_line(137, ng0);
    t2 = ((char*)((ng5)));
    t3 = (t0 + 6568);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);
    xsi_set_current_line(138, ng0);
    t2 = ((char*)((ng5)));
    t3 = (t0 + 6088);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);

LAB12:    goto LAB2;

LAB8:    t21 = (t6 + 4);
    *((unsigned int *)t6) = 1;
    *((unsigned int *)t21) = 1;
    goto LAB9;

LAB10:    xsi_set_current_line(50, ng0);
    t29 = (t0 + 1688U);
    t30 = *((char **)t29);
    memset(t28, 0, 8);
    t29 = (t28 + 4);
    t31 = (t30 + 4);
    t32 = *((unsigned int *)t30);
    t33 = (t32 >> 8);
    *((unsigned int *)t28) = t33;
    t34 = *((unsigned int *)t31);
    t35 = (t34 >> 8);
    *((unsigned int *)t29) = t35;
    t36 = *((unsigned int *)t28);
    *((unsigned int *)t28) = (t36 & 15U);
    t37 = *((unsigned int *)t29);
    *((unsigned int *)t29) = (t37 & 15U);

LAB13:    t38 = ((char*)((ng5)));
    t39 = xsi_vlog_unsigned_case_compare(t28, 4, t38, 4);
    if (t39 == 1)
        goto LAB14;

LAB15:    t2 = ((char*)((ng3)));
    t39 = xsi_vlog_unsigned_case_compare(t28, 4, t2, 4);
    if (t39 == 1)
        goto LAB16;

LAB17:    t2 = ((char*)((ng10)));
    t39 = xsi_vlog_unsigned_case_compare(t28, 4, t2, 4);
    if (t39 == 1)
        goto LAB18;

LAB19:    t2 = ((char*)((ng11)));
    t39 = xsi_vlog_unsigned_case_compare(t28, 4, t2, 4);
    if (t39 == 1)
        goto LAB20;

LAB21:    t3 = ((char*)((ng8)));
    t80 = xsi_vlog_unsigned_case_compare(t28, 4, t3, 4);
    if (t80 == 1)
        goto LAB22;

LAB23:    t2 = ((char*)((ng12)));
    t39 = xsi_vlog_unsigned_case_compare(t28, 4, t2, 4);
    if (t39 == 1)
        goto LAB24;

LAB25:    t2 = ((char*)((ng7)));
    t39 = xsi_vlog_unsigned_case_compare(t28, 4, t2, 4);
    if (t39 == 1)
        goto LAB26;

LAB27:    t2 = ((char*)((ng13)));
    t39 = xsi_vlog_unsigned_case_compare(t28, 4, t2, 4);
    if (t39 == 1)
        goto LAB28;

LAB29:    t2 = ((char*)((ng2)));
    t39 = xsi_vlog_unsigned_case_compare(t28, 4, t2, 4);
    if (t39 == 1)
        goto LAB30;

LAB31:
LAB33:
LAB32:    xsi_set_current_line(130, ng0);
    t2 = ((char*)((ng3)));
    t3 = (t0 + 6088);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);

LAB34:    goto LAB12;

LAB14:    xsi_set_current_line(52, ng0);

LAB35:    xsi_set_current_line(53, ng0);
    t40 = (t0 + 1208U);
    t41 = *((char **)t40);
    t40 = ((char*)((ng8)));
    memset(t42, 0, 8);
    t43 = (t41 + 4);
    t44 = (t40 + 4);
    t45 = *((unsigned int *)t41);
    t46 = *((unsigned int *)t40);
    t47 = (t45 ^ t46);
    t48 = *((unsigned int *)t43);
    t49 = *((unsigned int *)t44);
    t50 = (t48 ^ t49);
    t51 = (t47 | t50);
    t52 = *((unsigned int *)t43);
    t53 = *((unsigned int *)t44);
    t54 = (t52 | t53);
    t55 = (~(t54));
    t56 = (t51 & t55);
    if (t56 != 0)
        goto LAB39;

LAB36:    if (t54 != 0)
        goto LAB38;

LAB37:    *((unsigned int *)t42) = 1;

LAB39:    t58 = (t42 + 4);
    t59 = *((unsigned int *)t58);
    t60 = (~(t59));
    t61 = *((unsigned int *)t42);
    t62 = (t61 & t60);
    t63 = (t62 != 0);
    if (t63 > 0)
        goto LAB40;

LAB41:
LAB42:    xsi_set_current_line(58, ng0);
    t2 = (t0 + 1208U);
    t3 = *((char **)t2);
    t2 = ((char*)((ng2)));
    memset(t6, 0, 8);
    t4 = (t3 + 4);
    t5 = (t2 + 4);
    t9 = *((unsigned int *)t3);
    t10 = *((unsigned int *)t2);
    t11 = (t9 ^ t10);
    t12 = *((unsigned int *)t4);
    t13 = *((unsigned int *)t5);
    t14 = (t12 ^ t13);
    t15 = (t11 | t14);
    t16 = *((unsigned int *)t4);
    t17 = *((unsigned int *)t5);
    t18 = (t16 | t17);
    t19 = (~(t18));
    t20 = (t15 & t19);
    if (t20 != 0)
        goto LAB47;

LAB44:    if (t18 != 0)
        goto LAB46;

LAB45:    *((unsigned int *)t6) = 1;

LAB47:    t8 = (t6 + 4);
    t23 = *((unsigned int *)t8);
    t24 = (~(t23));
    t25 = *((unsigned int *)t6);
    t26 = (t25 & t24);
    t27 = (t26 != 0);
    if (t27 > 0)
        goto LAB48;

LAB49:
LAB50:    goto LAB34;

LAB16:    xsi_set_current_line(65, ng0);

LAB52:    xsi_set_current_line(66, ng0);
    t3 = (t0 + 1208U);
    t4 = *((char **)t3);
    t3 = ((char*)((ng8)));
    memset(t6, 0, 8);
    t5 = (t4 + 4);
    t7 = (t3 + 4);
    t9 = *((unsigned int *)t4);
    t10 = *((unsigned int *)t3);
    t11 = (t9 ^ t10);
    t12 = *((unsigned int *)t5);
    t13 = *((unsigned int *)t7);
    t14 = (t12 ^ t13);
    t15 = (t11 | t14);
    t16 = *((unsigned int *)t5);
    t17 = *((unsigned int *)t7);
    t18 = (t16 | t17);
    t19 = (~(t18));
    t20 = (t15 & t19);
    if (t20 != 0)
        goto LAB56;

LAB53:    if (t18 != 0)
        goto LAB55;

LAB54:    *((unsigned int *)t6) = 1;

LAB56:    t21 = (t6 + 4);
    t23 = *((unsigned int *)t21);
    t24 = (~(t23));
    t25 = *((unsigned int *)t6);
    t26 = (t25 & t24);
    t27 = (t26 != 0);
    if (t27 > 0)
        goto LAB57;

LAB58:
LAB59:    goto LAB34;

LAB18:    xsi_set_current_line(70, ng0);

LAB73:    xsi_set_current_line(71, ng0);
    t3 = (t0 + 1208U);
    t4 = *((char **)t3);
    t3 = ((char*)((ng2)));
    memset(t6, 0, 8);
    t5 = (t4 + 4);
    t7 = (t3 + 4);
    t9 = *((unsigned int *)t4);
    t10 = *((unsigned int *)t3);
    t11 = (t9 ^ t10);
    t12 = *((unsigned int *)t5);
    t13 = *((unsigned int *)t7);
    t14 = (t12 ^ t13);
    t15 = (t11 | t14);
    t16 = *((unsigned int *)t5);
    t17 = *((unsigned int *)t7);
    t18 = (t16 | t17);
    t19 = (~(t18));
    t20 = (t15 & t19);
    if (t20 != 0)
        goto LAB77;

LAB74:    if (t18 != 0)
        goto LAB76;

LAB75:    *((unsigned int *)t6) = 1;

LAB77:    t21 = (t6 + 4);
    t23 = *((unsigned int *)t21);
    t24 = (~(t23));
    t25 = *((unsigned int *)t6);
    t26 = (t25 & t24);
    t27 = (t26 != 0);
    if (t27 > 0)
        goto LAB78;

LAB79:
LAB80:    goto LAB34;

LAB20:    goto LAB34;

LAB22:    xsi_set_current_line(77, ng0);

LAB81:    xsi_set_current_line(78, ng0);
    t4 = (t0 + 1688U);
    t5 = *((char **)t4);
    memset(t6, 0, 8);
    t4 = (t6 + 4);
    t7 = (t5 + 4);
    t9 = *((unsigned int *)t5);
    t10 = (t9 >> 4);
    *((unsigned int *)t6) = t10;
    t11 = *((unsigned int *)t7);
    t12 = (t11 >> 4);
    *((unsigned int *)t4) = t12;
    t13 = *((unsigned int *)t6);
    *((unsigned int *)t6) = (t13 & 15U);
    t14 = *((unsigned int *)t4);
    *((unsigned int *)t4) = (t14 & 15U);

LAB82:    t8 = ((char*)((ng5)));
    t81 = xsi_vlog_unsigned_case_compare(t6, 4, t8, 4);
    if (t81 == 1)
        goto LAB83;

LAB84:    t21 = ((char*)((ng3)));
    t82 = xsi_vlog_unsigned_case_compare(t6, 4, t21, 4);
    if (t82 == 1)
        goto LAB85;

LAB86:    t2 = ((char*)((ng10)));
    t39 = xsi_vlog_unsigned_case_compare(t6, 4, t2, 4);
    if (t39 == 1)
        goto LAB87;

LAB88:    t2 = ((char*)((ng11)));
    t39 = xsi_vlog_unsigned_case_compare(t6, 4, t2, 4);
    if (t39 == 1)
        goto LAB89;

LAB90:    t2 = ((char*)((ng2)));
    t39 = xsi_vlog_unsigned_case_compare(t6, 4, t2, 4);
    if (t39 == 1)
        goto LAB91;

LAB92:    t2 = ((char*)((ng9)));
    t39 = xsi_vlog_unsigned_case_compare(t6, 4, t2, 4);
    if (t39 == 1)
        goto LAB93;

LAB94:
LAB96:
LAB95:    xsi_set_current_line(85, ng0);
    t2 = ((char*)((ng5)));
    t3 = (t0 + 6248);
    t4 = (t3 + 56U);
    t5 = *((char **)t4);
    memset(t66, 0, 8);
    t7 = (t66 + 4);
    t8 = (t5 + 4);
    t9 = *((unsigned int *)t5);
    t10 = (t9 >> 16);
    t11 = (t10 & 1);
    *((unsigned int *)t66) = t11;
    t12 = *((unsigned int *)t8);
    t13 = (t12 >> 16);
    t14 = (t13 & 1);
    *((unsigned int *)t7) = t14;
    xsi_vlogtype_concat(t42, 17, 17, 2U, t66, 1, t2, 16);
    t21 = (t0 + 6248);
    xsi_vlogvar_wait_assign_value(t21, t42, 0, 0, 17, 0LL);

LAB97:    xsi_set_current_line(87, ng0);
    t2 = (t0 + 1688U);
    t3 = *((char **)t2);
    memset(t42, 0, 8);
    t2 = (t42 + 4);
    t4 = (t3 + 4);
    t9 = *((unsigned int *)t3);
    t10 = (t9 >> 0);
    *((unsigned int *)t42) = t10;
    t11 = *((unsigned int *)t4);
    t12 = (t11 >> 0);
    *((unsigned int *)t2) = t12;
    t13 = *((unsigned int *)t42);
    *((unsigned int *)t42) = (t13 & 15U);
    t14 = *((unsigned int *)t2);
    *((unsigned int *)t2) = (t14 & 15U);

LAB98:    t5 = ((char*)((ng5)));
    t39 = xsi_vlog_unsigned_case_compare(t42, 4, t5, 4);
    if (t39 == 1)
        goto LAB99;

LAB100:    t7 = ((char*)((ng3)));
    t80 = xsi_vlog_unsigned_case_compare(t42, 4, t7, 4);
    if (t80 == 1)
        goto LAB101;

LAB102:    t2 = ((char*)((ng10)));
    t39 = xsi_vlog_unsigned_case_compare(t42, 4, t2, 4);
    if (t39 == 1)
        goto LAB103;

LAB104:    t2 = ((char*)((ng11)));
    t39 = xsi_vlog_unsigned_case_compare(t42, 4, t2, 4);
    if (t39 == 1)
        goto LAB105;

LAB106:    t2 = ((char*)((ng2)));
    t39 = xsi_vlog_unsigned_case_compare(t42, 4, t2, 4);
    if (t39 == 1)
        goto LAB107;

LAB108:    t2 = ((char*)((ng9)));
    t39 = xsi_vlog_unsigned_case_compare(t42, 4, t2, 4);
    if (t39 == 1)
        goto LAB109;

LAB110:
LAB112:
LAB111:    xsi_set_current_line(94, ng0);
    t2 = ((char*)((ng5)));
    t3 = (t0 + 6248);
    t4 = (t3 + 56U);
    t5 = *((char **)t4);
    memset(t67, 0, 8);
    t7 = (t67 + 4);
    t8 = (t5 + 4);
    t9 = *((unsigned int *)t5);
    t10 = (t9 >> 16);
    t11 = (t10 & 1);
    *((unsigned int *)t67) = t11;
    t12 = *((unsigned int *)t8);
    t13 = (t12 >> 16);
    t14 = (t13 & 1);
    *((unsigned int *)t7) = t14;
    xsi_vlogtype_concat(t66, 17, 17, 2U, t67, 1, t2, 16);
    t21 = (t0 + 6248);
    xsi_vlogvar_wait_assign_value(t21, t66, 0, 0, 17, 0LL);

LAB113:    goto LAB34;

LAB24:    xsi_set_current_line(99, ng0);

LAB114:    xsi_set_current_line(102, ng0);
    t3 = (t0 + 1208U);
    t4 = *((char **)t3);
    t3 = ((char*)((ng8)));
    memset(t66, 0, 8);
    t5 = (t4 + 4);
    t7 = (t3 + 4);
    t9 = *((unsigned int *)t4);
    t10 = *((unsigned int *)t3);
    t11 = (t9 ^ t10);
    t12 = *((unsigned int *)t5);
    t13 = *((unsigned int *)t7);
    t14 = (t12 ^ t13);
    t15 = (t11 | t14);
    t16 = *((unsigned int *)t5);
    t17 = *((unsigned int *)t7);
    t18 = (t16 | t17);
    t19 = (~(t18));
    t20 = (t15 & t19);
    if (t20 != 0)
        goto LAB118;

LAB115:    if (t18 != 0)
        goto LAB117;

LAB116:    *((unsigned int *)t66) = 1;

LAB118:    t21 = (t66 + 4);
    t23 = *((unsigned int *)t21);
    t24 = (~(t23));
    t25 = *((unsigned int *)t66);
    t26 = (t25 & t24);
    t27 = (t26 != 0);
    if (t27 > 0)
        goto LAB119;

LAB120:
LAB121:    xsi_set_current_line(103, ng0);
    t2 = (t0 + 1208U);
    t3 = *((char **)t2);
    t2 = ((char*)((ng2)));
    memset(t66, 0, 8);
    t4 = (t3 + 4);
    t5 = (t2 + 4);
    t9 = *((unsigned int *)t3);
    t10 = *((unsigned int *)t2);
    t11 = (t9 ^ t10);
    t12 = *((unsigned int *)t4);
    t13 = *((unsigned int *)t5);
    t14 = (t12 ^ t13);
    t15 = (t11 | t14);
    t16 = *((unsigned int *)t4);
    t17 = *((unsigned int *)t5);
    t18 = (t16 | t17);
    t19 = (~(t18));
    t20 = (t15 & t19);
    if (t20 != 0)
        goto LAB125;

LAB122:    if (t18 != 0)
        goto LAB124;

LAB123:    *((unsigned int *)t66) = 1;

LAB125:    t8 = (t66 + 4);
    t23 = *((unsigned int *)t8);
    t24 = (~(t23));
    t25 = *((unsigned int *)t66);
    t26 = (t25 & t24);
    t27 = (t26 != 0);
    if (t27 > 0)
        goto LAB126;

LAB127:
LAB128:    goto LAB34;

LAB26:    xsi_set_current_line(106, ng0);

LAB129:    xsi_set_current_line(107, ng0);
    t3 = (t0 + 1208U);
    t4 = *((char **)t3);
    t3 = ((char*)((ng8)));
    memset(t66, 0, 8);
    t5 = (t4 + 4);
    t7 = (t3 + 4);
    t9 = *((unsigned int *)t4);
    t10 = *((unsigned int *)t3);
    t11 = (t9 ^ t10);
    t12 = *((unsigned int *)t5);
    t13 = *((unsigned int *)t7);
    t14 = (t12 ^ t13);
    t15 = (t11 | t14);
    t16 = *((unsigned int *)t5);
    t17 = *((unsigned int *)t7);
    t18 = (t16 | t17);
    t19 = (~(t18));
    t20 = (t15 & t19);
    if (t20 != 0)
        goto LAB133;

LAB130:    if (t18 != 0)
        goto LAB132;

LAB131:    *((unsigned int *)t66) = 1;

LAB133:    t21 = (t66 + 4);
    t23 = *((unsigned int *)t21);
    t24 = (~(t23));
    t25 = *((unsigned int *)t66);
    t26 = (t25 & t24);
    t27 = (t26 != 0);
    if (t27 > 0)
        goto LAB134;

LAB135:
LAB136:    xsi_set_current_line(108, ng0);
    t2 = (t0 + 1208U);
    t3 = *((char **)t2);
    t2 = ((char*)((ng2)));
    memset(t66, 0, 8);
    t4 = (t3 + 4);
    t5 = (t2 + 4);
    t9 = *((unsigned int *)t3);
    t10 = *((unsigned int *)t2);
    t11 = (t9 ^ t10);
    t12 = *((unsigned int *)t4);
    t13 = *((unsigned int *)t5);
    t14 = (t12 ^ t13);
    t15 = (t11 | t14);
    t16 = *((unsigned int *)t4);
    t17 = *((unsigned int *)t5);
    t18 = (t16 | t17);
    t19 = (~(t18));
    t20 = (t15 & t19);
    if (t20 != 0)
        goto LAB140;

LAB137:    if (t18 != 0)
        goto LAB139;

LAB138:    *((unsigned int *)t66) = 1;

LAB140:    t8 = (t66 + 4);
    t23 = *((unsigned int *)t8);
    t24 = (~(t23));
    t25 = *((unsigned int *)t66);
    t26 = (t25 & t24);
    t27 = (t26 != 0);
    if (t27 > 0)
        goto LAB141;

LAB142:
LAB143:    goto LAB34;

LAB28:    xsi_set_current_line(111, ng0);

LAB144:    xsi_set_current_line(112, ng0);
    t3 = (t0 + 1208U);
    t4 = *((char **)t3);
    t3 = ((char*)((ng2)));
    memset(t66, 0, 8);
    t5 = (t4 + 4);
    t7 = (t3 + 4);
    t9 = *((unsigned int *)t4);
    t10 = *((unsigned int *)t3);
    t11 = (t9 ^ t10);
    t12 = *((unsigned int *)t5);
    t13 = *((unsigned int *)t7);
    t14 = (t12 ^ t13);
    t15 = (t11 | t14);
    t16 = *((unsigned int *)t5);
    t17 = *((unsigned int *)t7);
    t18 = (t16 | t17);
    t19 = (~(t18));
    t20 = (t15 & t19);
    if (t20 != 0)
        goto LAB148;

LAB145:    if (t18 != 0)
        goto LAB147;

LAB146:    *((unsigned int *)t66) = 1;

LAB148:    t21 = (t66 + 4);
    t23 = *((unsigned int *)t21);
    t24 = (~(t23));
    t25 = *((unsigned int *)t66);
    t26 = (t25 & t24);
    t27 = (t26 != 0);
    if (t27 > 0)
        goto LAB149;

LAB150:
LAB151:    goto LAB34;

LAB30:    xsi_set_current_line(117, ng0);

LAB152:    xsi_set_current_line(118, ng0);
    t3 = (t0 + 1208U);
    t4 = *((char **)t3);
    t3 = ((char*)((ng8)));
    memset(t66, 0, 8);
    t5 = (t4 + 4);
    t7 = (t3 + 4);
    t9 = *((unsigned int *)t4);
    t10 = *((unsigned int *)t3);
    t11 = (t9 ^ t10);
    t12 = *((unsigned int *)t5);
    t13 = *((unsigned int *)t7);
    t14 = (t12 ^ t13);
    t15 = (t11 | t14);
    t16 = *((unsigned int *)t5);
    t17 = *((unsigned int *)t7);
    t18 = (t16 | t17);
    t19 = (~(t18));
    t20 = (t15 & t19);
    if (t20 != 0)
        goto LAB156;

LAB153:    if (t18 != 0)
        goto LAB155;

LAB154:    *((unsigned int *)t66) = 1;

LAB156:    t21 = (t66 + 4);
    t23 = *((unsigned int *)t21);
    t24 = (~(t23));
    t25 = *((unsigned int *)t66);
    t26 = (t25 & t24);
    t27 = (t26 != 0);
    if (t27 > 0)
        goto LAB157;

LAB158:
LAB159:    xsi_set_current_line(122, ng0);
    t2 = (t0 + 1208U);
    t3 = *((char **)t2);
    t2 = ((char*)((ng2)));
    memset(t66, 0, 8);
    t4 = (t3 + 4);
    t5 = (t2 + 4);
    t9 = *((unsigned int *)t3);
    t10 = *((unsigned int *)t2);
    t11 = (t9 ^ t10);
    t12 = *((unsigned int *)t4);
    t13 = *((unsigned int *)t5);
    t14 = (t12 ^ t13);
    t15 = (t11 | t14);
    t16 = *((unsigned int *)t4);
    t17 = *((unsigned int *)t5);
    t18 = (t16 | t17);
    t19 = (~(t18));
    t20 = (t15 & t19);
    if (t20 != 0)
        goto LAB164;

LAB161:    if (t18 != 0)
        goto LAB163;

LAB162:    *((unsigned int *)t66) = 1;

LAB164:    t8 = (t66 + 4);
    t23 = *((unsigned int *)t8);
    t24 = (~(t23));
    t25 = *((unsigned int *)t66);
    t26 = (t25 & t24);
    t27 = (t26 != 0);
    if (t27 > 0)
        goto LAB165;

LAB166:
LAB167:    goto LAB34;

LAB38:    t57 = (t42 + 4);
    *((unsigned int *)t42) = 1;
    *((unsigned int *)t57) = 1;
    goto LAB39;

LAB40:    xsi_set_current_line(54, ng0);

LAB43:    xsi_set_current_line(55, ng0);
    t64 = ((char*)((ng3)));
    t65 = (t0 + 6408);
    xsi_vlogvar_wait_assign_value(t65, t64, 0, 0, 1, 0LL);
    xsi_set_current_line(56, ng0);
    t2 = ((char*)((ng3)));
    t3 = (t0 + 5928);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);
    goto LAB42;

LAB46:    t7 = (t6 + 4);
    *((unsigned int *)t6) = 1;
    *((unsigned int *)t7) = 1;
    goto LAB47;

LAB48:    xsi_set_current_line(59, ng0);

LAB51:    xsi_set_current_line(60, ng0);
    t21 = ((char*)((ng5)));
    t22 = (t0 + 6408);
    xsi_vlogvar_wait_assign_value(t22, t21, 0, 0, 1, 0LL);
    xsi_set_current_line(61, ng0);
    t2 = ((char*)((ng5)));
    t3 = (t0 + 5928);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);
    goto LAB50;

LAB55:    t8 = (t6 + 4);
    *((unsigned int *)t6) = 1;
    *((unsigned int *)t8) = 1;
    goto LAB56;

LAB57:    xsi_set_current_line(67, ng0);
    t22 = (t0 + 1528U);
    t29 = *((char **)t22);
    memset(t66, 0, 8);
    t22 = (t66 + 4);
    t30 = (t29 + 4);
    t32 = *((unsigned int *)t29);
    t33 = (t32 >> 0);
    *((unsigned int *)t66) = t33;
    t34 = *((unsigned int *)t30);
    t35 = (t34 >> 0);
    *((unsigned int *)t22) = t35;
    t36 = *((unsigned int *)t66);
    *((unsigned int *)t66) = (t36 & 4095U);
    t37 = *((unsigned int *)t22);
    *((unsigned int *)t22) = (t37 & 4095U);
    t31 = (t0 + 1528U);
    t38 = *((char **)t31);
    memset(t69, 0, 8);
    t31 = (t69 + 4);
    t40 = (t38 + 4);
    t45 = *((unsigned int *)t38);
    t46 = (t45 >> 12);
    t47 = (t46 & 1);
    *((unsigned int *)t69) = t47;
    t48 = *((unsigned int *)t40);
    t49 = (t48 >> 12);
    t50 = (t49 & 1);
    *((unsigned int *)t31) = t50;
    memset(t68, 0, 8);
    t41 = (t69 + 4);
    t51 = *((unsigned int *)t41);
    t52 = (~(t51));
    t53 = *((unsigned int *)t69);
    t54 = (t53 & t52);
    t55 = (t54 & 1U);
    if (t55 != 0)
        goto LAB60;

LAB61:    if (*((unsigned int *)t41) != 0)
        goto LAB62;

LAB63:    t44 = (t68 + 4);
    t56 = *((unsigned int *)t68);
    t59 = *((unsigned int *)t44);
    t60 = (t56 || t59);
    if (t60 > 0)
        goto LAB64;

LAB65:    t61 = *((unsigned int *)t68);
    t62 = (~(t61));
    t63 = *((unsigned int *)t44);
    t70 = (t62 || t63);
    if (t70 > 0)
        goto LAB66;

LAB67:    if (*((unsigned int *)t44) > 0)
        goto LAB68;

LAB69:    if (*((unsigned int *)t68) > 0)
        goto LAB70;

LAB71:    memcpy(t67, t58, 8);

LAB72:    t64 = (t0 + 1528U);
    t65 = *((char **)t64);
    memset(t71, 0, 8);
    t64 = (t71 + 4);
    t72 = (t65 + 4);
    t73 = *((unsigned int *)t65);
    t74 = (t73 >> 12);
    t75 = (t74 & 1);
    *((unsigned int *)t71) = t75;
    t76 = *((unsigned int *)t72);
    t77 = (t76 >> 12);
    t78 = (t77 & 1);
    *((unsigned int *)t64) = t78;
    xsi_vlogtype_concat(t42, 17, 17, 3U, t71, 1, t67, 4, t66, 12);
    t79 = (t0 + 6248);
    xsi_vlogvar_wait_assign_value(t79, t42, 0, 0, 17, 0LL);
    goto LAB59;

LAB60:    *((unsigned int *)t68) = 1;
    goto LAB63;

LAB62:    t43 = (t68 + 4);
    *((unsigned int *)t68) = 1;
    *((unsigned int *)t43) = 1;
    goto LAB63;

LAB64:    t57 = ((char*)((ng9)));
    goto LAB65;

LAB66:    t58 = ((char*)((ng5)));
    goto LAB67;

LAB68:    xsi_vlog_unsigned_bit_combine(t67, 4, t57, 4, t58, 4);
    goto LAB72;

LAB70:    memcpy(t67, t57, 8);
    goto LAB72;

LAB76:    t8 = (t6 + 4);
    *((unsigned int *)t6) = 1;
    *((unsigned int *)t8) = 1;
    goto LAB77;

LAB78:    xsi_set_current_line(72, ng0);
    t22 = (t0 + 4728U);
    t29 = *((char **)t22);
    t22 = (t0 + 6248);
    xsi_vlogvar_wait_assign_value(t22, t29, 0, 0, 17, 0LL);
    goto LAB80;

LAB83:    goto LAB97;

LAB85:    xsi_set_current_line(80, ng0);
    t22 = ((char*)((ng5)));
    t29 = (t0 + 6248);
    t30 = (t29 + 56U);
    t31 = *((char **)t30);
    memset(t66, 0, 8);
    t38 = (t66 + 4);
    t40 = (t31 + 4);
    t15 = *((unsigned int *)t31);
    t16 = (t15 >> 0);
    *((unsigned int *)t66) = t16;
    t17 = *((unsigned int *)t40);
    t18 = (t17 >> 0);
    *((unsigned int *)t38) = t18;
    t19 = *((unsigned int *)t66);
    *((unsigned int *)t66) = (t19 & 4095U);
    t20 = *((unsigned int *)t38);
    *((unsigned int *)t38) = (t20 & 4095U);
    t41 = (t0 + 6248);
    t43 = (t41 + 56U);
    t44 = *((char **)t43);
    memset(t67, 0, 8);
    t57 = (t67 + 4);
    t58 = (t44 + 4);
    t23 = *((unsigned int *)t44);
    t24 = (t23 >> 16);
    t25 = (t24 & 1);
    *((unsigned int *)t67) = t25;
    t26 = *((unsigned int *)t58);
    t27 = (t26 >> 16);
    t32 = (t27 & 1);
    *((unsigned int *)t57) = t32;
    xsi_vlogtype_concat(t42, 17, 17, 3U, t67, 1, t66, 12, t22, 4);
    t64 = (t0 + 6248);
    xsi_vlogvar_wait_assign_value(t64, t42, 0, 0, 17, 0LL);
    goto LAB97;

LAB87:    xsi_set_current_line(81, ng0);
    t3 = ((char*)((ng5)));
    t4 = (t0 + 6248);
    t5 = (t4 + 56U);
    t7 = *((char **)t5);
    memset(t66, 0, 8);
    t8 = (t66 + 4);
    t21 = (t7 + 4);
    t9 = *((unsigned int *)t7);
    t10 = (t9 >> 0);
    *((unsigned int *)t66) = t10;
    t11 = *((unsigned int *)t21);
    t12 = (t11 >> 0);
    *((unsigned int *)t8) = t12;
    t13 = *((unsigned int *)t66);
    *((unsigned int *)t66) = (t13 & 255U);
    t14 = *((unsigned int *)t8);
    *((unsigned int *)t8) = (t14 & 255U);
    t22 = (t0 + 6248);
    t29 = (t22 + 56U);
    t30 = *((char **)t29);
    memset(t67, 0, 8);
    t31 = (t67 + 4);
    t38 = (t30 + 4);
    t15 = *((unsigned int *)t30);
    t16 = (t15 >> 16);
    t17 = (t16 & 1);
    *((unsigned int *)t67) = t17;
    t18 = *((unsigned int *)t38);
    t19 = (t18 >> 16);
    t20 = (t19 & 1);
    *((unsigned int *)t31) = t20;
    xsi_vlogtype_concat(t42, 17, 17, 3U, t67, 1, t66, 8, t3, 8);
    t40 = (t0 + 6248);
    xsi_vlogvar_wait_assign_value(t40, t42, 0, 0, 17, 0LL);
    goto LAB97;

LAB89:    xsi_set_current_line(82, ng0);
    t3 = ((char*)((ng5)));
    t4 = (t0 + 6248);
    t5 = (t4 + 56U);
    t7 = *((char **)t5);
    memset(t66, 0, 8);
    t8 = (t66 + 4);
    t21 = (t7 + 4);
    t9 = *((unsigned int *)t7);
    t10 = (t9 >> 0);
    *((unsigned int *)t66) = t10;
    t11 = *((unsigned int *)t21);
    t12 = (t11 >> 0);
    *((unsigned int *)t8) = t12;
    t13 = *((unsigned int *)t66);
    *((unsigned int *)t66) = (t13 & 15U);
    t14 = *((unsigned int *)t8);
    *((unsigned int *)t8) = (t14 & 15U);
    t22 = (t0 + 6248);
    t29 = (t22 + 56U);
    t30 = *((char **)t29);
    memset(t67, 0, 8);
    t31 = (t67 + 4);
    t38 = (t30 + 4);
    t15 = *((unsigned int *)t30);
    t16 = (t15 >> 16);
    t17 = (t16 & 1);
    *((unsigned int *)t67) = t17;
    t18 = *((unsigned int *)t38);
    t19 = (t18 >> 16);
    t20 = (t19 & 1);
    *((unsigned int *)t31) = t20;
    xsi_vlogtype_concat(t42, 17, 17, 3U, t67, 1, t66, 4, t3, 12);
    t40 = (t0 + 6248);
    xsi_vlogvar_wait_assign_value(t40, t42, 0, 0, 17, 0LL);
    goto LAB97;

LAB91:    xsi_set_current_line(83, ng0);
    t3 = (t0 + 4568U);
    t4 = *((char **)t3);
    t3 = ((char*)((ng5)));
    xsi_vlogtype_concat(t42, 17, 17, 2U, t3, 9, t4, 8);
    t5 = (t0 + 6248);
    xsi_vlogvar_wait_assign_value(t5, t42, 0, 0, 17, 0LL);
    goto LAB97;

LAB93:    xsi_set_current_line(84, ng0);
    t3 = ((char*)((ng3)));
    t4 = (t0 + 4888U);
    t5 = *((char **)t4);
    xsi_vlogtype_concat(t42, 17, 17, 2U, t5, 1, t3, 16);
    t4 = (t0 + 6248);
    xsi_vlogvar_wait_assign_value(t4, t42, 0, 0, 17, 0LL);
    goto LAB97;

LAB99:    goto LAB113;

LAB101:    xsi_set_current_line(89, ng0);
    t8 = (t0 + 6248);
    t21 = (t8 + 56U);
    t22 = *((char **)t21);
    memset(t67, 0, 8);
    t29 = (t67 + 4);
    t30 = (t22 + 4);
    t15 = *((unsigned int *)t22);
    t16 = (t15 >> 4);
    *((unsigned int *)t67) = t16;
    t17 = *((unsigned int *)t30);
    t18 = (t17 >> 4);
    *((unsigned int *)t29) = t18;
    t19 = *((unsigned int *)t67);
    *((unsigned int *)t67) = (t19 & 4095U);
    t20 = *((unsigned int *)t29);
    *((unsigned int *)t29) = (t20 & 4095U);
    t31 = ((char*)((ng5)));
    t38 = (t0 + 6248);
    t40 = (t38 + 56U);
    t41 = *((char **)t40);
    memset(t68, 0, 8);
    t43 = (t68 + 4);
    t44 = (t41 + 4);
    t23 = *((unsigned int *)t41);
    t24 = (t23 >> 16);
    t25 = (t24 & 1);
    *((unsigned int *)t68) = t25;
    t26 = *((unsigned int *)t44);
    t27 = (t26 >> 16);
    t32 = (t27 & 1);
    *((unsigned int *)t43) = t32;
    xsi_vlogtype_concat(t66, 17, 17, 3U, t68, 1, t31, 4, t67, 12);
    t57 = (t0 + 6248);
    xsi_vlogvar_wait_assign_value(t57, t66, 0, 0, 17, 0LL);
    goto LAB113;

LAB103:    xsi_set_current_line(90, ng0);
    t3 = (t0 + 6248);
    t4 = (t3 + 56U);
    t5 = *((char **)t4);
    memset(t67, 0, 8);
    t7 = (t67 + 4);
    t8 = (t5 + 4);
    t9 = *((unsigned int *)t5);
    t10 = (t9 >> 8);
    *((unsigned int *)t67) = t10;
    t11 = *((unsigned int *)t8);
    t12 = (t11 >> 8);
    *((unsigned int *)t7) = t12;
    t13 = *((unsigned int *)t67);
    *((unsigned int *)t67) = (t13 & 255U);
    t14 = *((unsigned int *)t7);
    *((unsigned int *)t7) = (t14 & 255U);
    t21 = ((char*)((ng5)));
    t22 = (t0 + 6248);
    t29 = (t22 + 56U);
    t30 = *((char **)t29);
    memset(t68, 0, 8);
    t31 = (t68 + 4);
    t38 = (t30 + 4);
    t15 = *((unsigned int *)t30);
    t16 = (t15 >> 16);
    t17 = (t16 & 1);
    *((unsigned int *)t68) = t17;
    t18 = *((unsigned int *)t38);
    t19 = (t18 >> 16);
    t20 = (t19 & 1);
    *((unsigned int *)t31) = t20;
    xsi_vlogtype_concat(t66, 17, 17, 3U, t68, 1, t21, 8, t67, 8);
    t40 = (t0 + 6248);
    xsi_vlogvar_wait_assign_value(t40, t66, 0, 0, 17, 0LL);
    goto LAB113;

LAB105:    xsi_set_current_line(91, ng0);
    t3 = (t0 + 6248);
    t4 = (t3 + 56U);
    t5 = *((char **)t4);
    memset(t67, 0, 8);
    t7 = (t67 + 4);
    t8 = (t5 + 4);
    t9 = *((unsigned int *)t5);
    t10 = (t9 >> 12);
    *((unsigned int *)t67) = t10;
    t11 = *((unsigned int *)t8);
    t12 = (t11 >> 12);
    *((unsigned int *)t7) = t12;
    t13 = *((unsigned int *)t67);
    *((unsigned int *)t67) = (t13 & 15U);
    t14 = *((unsigned int *)t7);
    *((unsigned int *)t7) = (t14 & 15U);
    t21 = ((char*)((ng5)));
    t22 = (t0 + 6248);
    t29 = (t22 + 56U);
    t30 = *((char **)t29);
    memset(t68, 0, 8);
    t31 = (t68 + 4);
    t38 = (t30 + 4);
    t15 = *((unsigned int *)t30);
    t16 = (t15 >> 16);
    t17 = (t16 & 1);
    *((unsigned int *)t68) = t17;
    t18 = *((unsigned int *)t38);
    t19 = (t18 >> 16);
    t20 = (t19 & 1);
    *((unsigned int *)t31) = t20;
    xsi_vlogtype_concat(t66, 17, 17, 3U, t68, 1, t21, 12, t67, 4);
    t40 = (t0 + 6248);
    xsi_vlogvar_wait_assign_value(t40, t66, 0, 0, 17, 0LL);
    goto LAB113;

LAB107:    xsi_set_current_line(92, ng0);
    t3 = ((char*)((ng3)));
    t4 = (t0 + 5048U);
    t5 = *((char **)t4);
    xsi_vlogtype_concat(t66, 17, 17, 2U, t5, 1, t3, 16);
    t4 = (t0 + 6248);
    xsi_vlogvar_wait_assign_value(t4, t66, 0, 0, 17, 0LL);
    goto LAB113;

LAB109:    xsi_set_current_line(93, ng0);
    t3 = ((char*)((ng3)));
    t4 = (t0 + 5208U);
    t5 = *((char **)t4);
    xsi_vlogtype_concat(t66, 17, 17, 2U, t5, 1, t3, 16);
    t4 = (t0 + 6248);
    xsi_vlogvar_wait_assign_value(t4, t66, 0, 0, 17, 0LL);
    goto LAB113;

LAB117:    t8 = (t66 + 4);
    *((unsigned int *)t66) = 1;
    *((unsigned int *)t8) = 1;
    goto LAB118;

LAB119:    xsi_set_current_line(102, ng0);
    t22 = ((char*)((ng3)));
    t29 = (t0 + 6568);
    xsi_vlogvar_wait_assign_value(t29, t22, 0, 0, 1, 0LL);
    goto LAB121;

LAB124:    t7 = (t66 + 4);
    *((unsigned int *)t66) = 1;
    *((unsigned int *)t7) = 1;
    goto LAB125;

LAB126:    xsi_set_current_line(103, ng0);
    t21 = ((char*)((ng5)));
    t22 = (t0 + 6568);
    xsi_vlogvar_wait_assign_value(t22, t21, 0, 0, 1, 0LL);
    goto LAB128;

LAB132:    t8 = (t66 + 4);
    *((unsigned int *)t66) = 1;
    *((unsigned int *)t8) = 1;
    goto LAB133;

LAB134:    xsi_set_current_line(107, ng0);
    t22 = ((char*)((ng3)));
    t29 = (t0 + 5928);
    xsi_vlogvar_wait_assign_value(t29, t22, 0, 0, 1, 0LL);
    goto LAB136;

LAB139:    t7 = (t66 + 4);
    *((unsigned int *)t66) = 1;
    *((unsigned int *)t7) = 1;
    goto LAB140;

LAB141:    xsi_set_current_line(108, ng0);
    t21 = ((char*)((ng5)));
    t22 = (t0 + 5928);
    xsi_vlogvar_wait_assign_value(t22, t21, 0, 0, 1, 0LL);
    goto LAB143;

LAB147:    t8 = (t66 + 4);
    *((unsigned int *)t66) = 1;
    *((unsigned int *)t8) = 1;
    goto LAB148;

LAB149:    xsi_set_current_line(113, ng0);
    t22 = (t0 + 4728U);
    t29 = *((char **)t22);
    t22 = (t0 + 6248);
    xsi_vlogvar_wait_assign_value(t22, t29, 0, 0, 17, 0LL);
    goto LAB151;

LAB155:    t8 = (t66 + 4);
    *((unsigned int *)t66) = 1;
    *((unsigned int *)t8) = 1;
    goto LAB156;

LAB157:    xsi_set_current_line(119, ng0);

LAB160:    xsi_set_current_line(120, ng0);
    t22 = ((char*)((ng3)));
    t29 = (t0 + 5928);
    xsi_vlogvar_wait_assign_value(t29, t22, 0, 0, 1, 0LL);
    goto LAB159;

LAB163:    t7 = (t66 + 4);
    *((unsigned int *)t66) = 1;
    *((unsigned int *)t7) = 1;
    goto LAB164;

LAB165:    xsi_set_current_line(123, ng0);

LAB168:    xsi_set_current_line(124, ng0);
    t21 = ((char*)((ng5)));
    t22 = (t0 + 5928);
    xsi_vlogvar_wait_assign_value(t22, t21, 0, 0, 1, 0LL);
    goto LAB167;

}

static void implSig1_execute(char *t0)
{
    char t3[8];
    char t4[8];
    char t13[8];
    char t14[8];
    char t15[8];
    char t26[8];
    char t53[8];
    char t56[8];
    char t87[8];
    char *t1;
    char *t2;
    char *t5;
    char *t6;
    unsigned int t7;
    unsigned int t8;
    unsigned int t9;
    unsigned int t10;
    unsigned int t11;
    unsigned int t12;
    char *t16;
    char *t17;
    char *t18;
    unsigned int t19;
    unsigned int t20;
    unsigned int t21;
    unsigned int t22;
    unsigned int t23;
    unsigned int t24;
    char *t25;
    char *t27;
    char *t28;
    unsigned int t29;
    unsigned int t30;
    unsigned int t31;
    unsigned int t32;
    unsigned int t33;
    unsigned int t34;
    unsigned int t35;
    unsigned int t36;
    unsigned int t37;
    unsigned int t38;
    unsigned int t39;
    unsigned int t40;
    char *t41;
    char *t42;
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
    char *t54;
    char *t55;
    char *t57;
    unsigned int t58;
    unsigned int t59;
    unsigned int t60;
    unsigned int t61;
    unsigned int t62;
    unsigned int t63;
    char *t64;
    unsigned int t65;
    unsigned int t66;
    unsigned int t67;
    unsigned int t68;
    unsigned int t69;
    char *t70;
    char *t71;
    char *t72;
    unsigned int t73;
    unsigned int t74;
    unsigned int t75;
    unsigned int t76;
    unsigned int t77;
    unsigned int t78;
    unsigned int t79;
    unsigned int t80;
    unsigned int t81;
    unsigned int t82;
    unsigned int t83;
    unsigned int t84;
    char *t85;
    char *t86;
    char *t88;
    unsigned int t89;
    unsigned int t90;
    unsigned int t91;
    unsigned int t92;
    unsigned int t93;
    unsigned int t94;
    char *t95;
    char *t96;
    char *t97;
    char *t98;
    char *t99;
    unsigned int t100;
    unsigned int t101;
    char *t102;
    unsigned int t103;
    unsigned int t104;
    char *t105;
    unsigned int t106;
    unsigned int t107;
    char *t108;

LAB0:    t1 = (t0 + 9712U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    t2 = (t0 + 1528U);
    t5 = *((char **)t2);
    memset(t4, 0, 8);
    t2 = (t4 + 4);
    t6 = (t5 + 4);
    t7 = *((unsigned int *)t5);
    t8 = (t7 >> 0);
    *((unsigned int *)t4) = t8;
    t9 = *((unsigned int *)t6);
    t10 = (t9 >> 0);
    *((unsigned int *)t2) = t10;
    t11 = *((unsigned int *)t4);
    *((unsigned int *)t4) = (t11 & 4095U);
    t12 = *((unsigned int *)t2);
    *((unsigned int *)t2) = (t12 & 4095U);
    t16 = (t0 + 1688U);
    t17 = *((char **)t16);
    memset(t15, 0, 8);
    t16 = (t15 + 4);
    t18 = (t17 + 4);
    t19 = *((unsigned int *)t17);
    t20 = (t19 >> 8);
    *((unsigned int *)t15) = t20;
    t21 = *((unsigned int *)t18);
    t22 = (t21 >> 8);
    *((unsigned int *)t16) = t22;
    t23 = *((unsigned int *)t15);
    *((unsigned int *)t15) = (t23 & 15U);
    t24 = *((unsigned int *)t16);
    *((unsigned int *)t16) = (t24 & 15U);
    t25 = ((char*)((ng13)));
    memset(t26, 0, 8);
    t27 = (t15 + 4);
    t28 = (t25 + 4);
    t29 = *((unsigned int *)t15);
    t30 = *((unsigned int *)t25);
    t31 = (t29 ^ t30);
    t32 = *((unsigned int *)t27);
    t33 = *((unsigned int *)t28);
    t34 = (t32 ^ t33);
    t35 = (t31 | t34);
    t36 = *((unsigned int *)t27);
    t37 = *((unsigned int *)t28);
    t38 = (t36 | t37);
    t39 = (~(t38));
    t40 = (t35 & t39);
    if (t40 != 0)
        goto LAB7;

LAB4:    if (t38 != 0)
        goto LAB6;

LAB5:    *((unsigned int *)t26) = 1;

LAB7:    memset(t14, 0, 8);
    t42 = (t26 + 4);
    t43 = *((unsigned int *)t42);
    t44 = (~(t43));
    t45 = *((unsigned int *)t26);
    t46 = (t45 & t44);
    t47 = (t46 & 1U);
    if (t47 != 0)
        goto LAB8;

LAB9:    if (*((unsigned int *)t42) != 0)
        goto LAB10;

LAB11:    t49 = (t14 + 4);
    t50 = *((unsigned int *)t14);
    t51 = *((unsigned int *)t49);
    t52 = (t50 || t51);
    if (t52 > 0)
        goto LAB12;

LAB13:    t81 = *((unsigned int *)t14);
    t82 = (~(t81));
    t83 = *((unsigned int *)t49);
    t84 = (t82 || t83);
    if (t84 > 0)
        goto LAB14;

LAB15:    if (*((unsigned int *)t49) > 0)
        goto LAB16;

LAB17:    if (*((unsigned int *)t14) > 0)
        goto LAB18;

LAB19:    memcpy(t13, t87, 8);

LAB20:    xsi_vlogtype_concat(t3, 13, 13, 2U, t13, 1, t4, 12);
    t95 = (t0 + 10448);
    t96 = (t95 + 56U);
    t97 = *((char **)t96);
    t98 = (t97 + 56U);
    t99 = *((char **)t98);
    memset(t99, 0, 8);
    t100 = 8191U;
    t101 = t100;
    t102 = (t3 + 4);
    t103 = *((unsigned int *)t3);
    t100 = (t100 & t103);
    t104 = *((unsigned int *)t102);
    t101 = (t101 & t104);
    t105 = (t99 + 4);
    t106 = *((unsigned int *)t99);
    *((unsigned int *)t99) = (t106 | t100);
    t107 = *((unsigned int *)t105);
    *((unsigned int *)t105) = (t107 | t101);
    xsi_driver_vfirst_trans(t95, 0, 12);
    t108 = (t0 + 10112);
    *((int *)t108) = 1;

LAB1:    return;
LAB6:    t41 = (t26 + 4);
    *((unsigned int *)t26) = 1;
    *((unsigned int *)t41) = 1;
    goto LAB7;

LAB8:    *((unsigned int *)t14) = 1;
    goto LAB11;

LAB10:    t48 = (t14 + 4);
    *((unsigned int *)t14) = 1;
    *((unsigned int *)t48) = 1;
    goto LAB11;

LAB12:    t54 = (t0 + 1528U);
    t55 = *((char **)t54);
    memset(t56, 0, 8);
    t54 = (t56 + 4);
    t57 = (t55 + 4);
    t58 = *((unsigned int *)t55);
    t59 = (t58 >> 12);
    t60 = (t59 & 1);
    *((unsigned int *)t56) = t60;
    t61 = *((unsigned int *)t57);
    t62 = (t61 >> 12);
    t63 = (t62 & 1);
    *((unsigned int *)t54) = t63;
    memset(t53, 0, 8);
    t64 = (t56 + 4);
    t65 = *((unsigned int *)t64);
    t66 = (~(t65));
    t67 = *((unsigned int *)t56);
    t68 = (t67 & t66);
    t69 = (t68 & 1U);
    if (t69 != 0)
        goto LAB24;

LAB22:    if (*((unsigned int *)t64) == 0)
        goto LAB21;

LAB23:    t70 = (t53 + 4);
    *((unsigned int *)t53) = 1;
    *((unsigned int *)t70) = 1;

LAB24:    t71 = (t53 + 4);
    t72 = (t56 + 4);
    t73 = *((unsigned int *)t56);
    t74 = (~(t73));
    *((unsigned int *)t53) = t74;
    *((unsigned int *)t71) = 0;
    if (*((unsigned int *)t72) != 0)
        goto LAB26;

LAB25:    t79 = *((unsigned int *)t53);
    *((unsigned int *)t53) = (t79 & 1U);
    t80 = *((unsigned int *)t71);
    *((unsigned int *)t71) = (t80 & 1U);
    goto LAB13;

LAB14:    t85 = (t0 + 1528U);
    t86 = *((char **)t85);
    memset(t87, 0, 8);
    t85 = (t87 + 4);
    t88 = (t86 + 4);
    t89 = *((unsigned int *)t86);
    t90 = (t89 >> 12);
    t91 = (t90 & 1);
    *((unsigned int *)t87) = t91;
    t92 = *((unsigned int *)t88);
    t93 = (t92 >> 12);
    t94 = (t93 & 1);
    *((unsigned int *)t85) = t94;
    goto LAB15;

LAB16:    xsi_vlog_unsigned_bit_combine(t13, 1, t53, 1, t87, 1);
    goto LAB20;

LAB18:    memcpy(t13, t53, 8);
    goto LAB20;

LAB21:    *((unsigned int *)t53) = 1;
    goto LAB24;

LAB26:    t75 = *((unsigned int *)t53);
    t76 = *((unsigned int *)t72);
    *((unsigned int *)t53) = (t75 | t76);
    t77 = *((unsigned int *)t71);
    t78 = *((unsigned int *)t72);
    *((unsigned int *)t71) = (t77 | t78);
    goto LAB25;

}


extern void work_m_04582387701478104048_2725559894_init()
{
	static char *pe[] = {(void *)Initial_21_0,(void *)Initial_22_1,(void *)Initial_23_2,(void *)Initial_24_3,(void *)Cont_27_4,(void *)Cont_32_5,(void *)Cont_35_6,(void *)Cont_38_7,(void *)Always_47_8,(void *)implSig1_execute};
	xsi_register_didat("work_m_04582387701478104048_2725559894", "isim/vtach_test_isim_beh.exe.sim/work/m_04582387701478104048_2725559894.didat");
	xsi_register_executes(pe);
}
