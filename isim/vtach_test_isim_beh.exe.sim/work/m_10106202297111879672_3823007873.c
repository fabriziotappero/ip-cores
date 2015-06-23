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
static const char *ng0 = "/home/alw/projects/vtachspartan/vtach.v";
static unsigned int ng1[] = {2U, 0U};
static unsigned int ng2[] = {0U, 0U};
static int ng3[] = {0, 0};
static unsigned int ng4[] = {1U, 0U};
static unsigned int ng5[] = {2048U, 0U};
static unsigned int ng6[] = {4U, 0U};
static unsigned int ng7[] = {8U, 0U};
static unsigned int ng8[] = {3U, 0U};



static void Cont_26_0(char *t0)
{
    char t3[8];
    char t4[8];
    char *t1;
    char *t2;
    char *t5;
    char *t6;
    char *t7;
    unsigned int t8;
    unsigned int t9;
    unsigned int t10;
    unsigned int t11;
    unsigned int t12;
    char *t13;
    char *t14;
    unsigned int t15;
    unsigned int t16;
    unsigned int t17;
    char *t18;
    char *t19;
    unsigned int t20;
    unsigned int t21;
    unsigned int t22;
    unsigned int t23;
    char *t24;
    char *t25;
    char *t26;
    char *t27;
    char *t28;
    char *t29;
    char *t30;
    unsigned int t31;
    unsigned int t32;
    char *t33;
    unsigned int t34;
    unsigned int t35;
    char *t36;
    unsigned int t37;
    unsigned int t38;
    char *t39;

LAB0:    t1 = (t0 + 7640U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(26, ng0);
    t2 = (t0 + 5928);
    t5 = (t2 + 56U);
    t6 = *((char **)t5);
    memset(t4, 0, 8);
    t7 = (t6 + 4);
    t8 = *((unsigned int *)t7);
    t9 = (~(t8));
    t10 = *((unsigned int *)t6);
    t11 = (t10 & t9);
    t12 = (t11 & 1U);
    if (t12 != 0)
        goto LAB4;

LAB5:    if (*((unsigned int *)t7) != 0)
        goto LAB6;

LAB7:    t14 = (t4 + 4);
    t15 = *((unsigned int *)t4);
    t16 = *((unsigned int *)t14);
    t17 = (t15 || t16);
    if (t17 > 0)
        goto LAB8;

LAB9:    t20 = *((unsigned int *)t4);
    t21 = (~(t20));
    t22 = *((unsigned int *)t14);
    t23 = (t21 || t22);
    if (t23 > 0)
        goto LAB10;

LAB11:    if (*((unsigned int *)t14) > 0)
        goto LAB12;

LAB13:    if (*((unsigned int *)t4) > 0)
        goto LAB14;

LAB15:    memcpy(t3, t25, 8);

LAB16:    t26 = (t0 + 10848);
    t27 = (t26 + 56U);
    t28 = *((char **)t27);
    t29 = (t28 + 56U);
    t30 = *((char **)t29);
    memset(t30, 0, 8);
    t31 = 255U;
    t32 = t31;
    t33 = (t3 + 4);
    t34 = *((unsigned int *)t3);
    t31 = (t31 & t34);
    t35 = *((unsigned int *)t33);
    t32 = (t32 & t35);
    t36 = (t30 + 4);
    t37 = *((unsigned int *)t30);
    *((unsigned int *)t30) = (t37 | t31);
    t38 = *((unsigned int *)t36);
    *((unsigned int *)t36) = (t38 | t32);
    xsi_driver_vfirst_trans(t26, 0, 7);
    t39 = (t0 + 10688);
    *((int *)t39) = 1;

LAB1:    return;
LAB4:    *((unsigned int *)t4) = 1;
    goto LAB7;

LAB6:    t13 = (t4 + 4);
    *((unsigned int *)t4) = 1;
    *((unsigned int *)t13) = 1;
    goto LAB7;

LAB8:    t18 = (t0 + 4728U);
    t19 = *((char **)t18);
    goto LAB9;

LAB10:    t18 = (t0 + 6408);
    t24 = (t18 + 56U);
    t25 = *((char **)t24);
    goto LAB11;

LAB12:    xsi_vlog_unsigned_bit_combine(t3, 8, t19, 8, t25, 8);
    goto LAB16;

LAB14:    memcpy(t3, t19, 8);
    goto LAB16;

}

static void Cont_33_1(char *t0)
{
    char t5[8];
    char t17[8];
    char t36[8];
    char t53[8];
    char t69[8];
    char t77[8];
    char t105[8];
    char t113[8];
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t6;
    unsigned int t7;
    unsigned int t8;
    unsigned int t9;
    unsigned int t10;
    unsigned int t11;
    char *t12;
    char *t13;
    unsigned int t14;
    unsigned int t15;
    unsigned int t16;
    char *t18;
    char *t19;
    unsigned int t20;
    unsigned int t21;
    unsigned int t22;
    unsigned int t23;
    unsigned int t24;
    char *t25;
    char *t26;
    char *t27;
    unsigned int t28;
    unsigned int t29;
    unsigned int t30;
    unsigned int t31;
    unsigned int t32;
    unsigned int t33;
    unsigned int t34;
    unsigned int t35;
    char *t37;
    unsigned int t38;
    unsigned int t39;
    unsigned int t40;
    unsigned int t41;
    unsigned int t42;
    char *t43;
    char *t44;
    unsigned int t45;
    unsigned int t46;
    unsigned int t47;
    unsigned int t48;
    char *t49;
    char *t50;
    char *t51;
    char *t52;
    char *t54;
    char *t55;
    unsigned int t56;
    unsigned int t57;
    unsigned int t58;
    unsigned int t59;
    unsigned int t60;
    unsigned int t61;
    unsigned int t62;
    unsigned int t63;
    unsigned int t64;
    unsigned int t65;
    unsigned int t66;
    unsigned int t67;
    char *t68;
    char *t70;
    unsigned int t71;
    unsigned int t72;
    unsigned int t73;
    unsigned int t74;
    unsigned int t75;
    char *t76;
    unsigned int t78;
    unsigned int t79;
    unsigned int t80;
    char *t81;
    char *t82;
    char *t83;
    unsigned int t84;
    unsigned int t85;
    unsigned int t86;
    unsigned int t87;
    unsigned int t88;
    unsigned int t89;
    unsigned int t90;
    char *t91;
    char *t92;
    unsigned int t93;
    unsigned int t94;
    unsigned int t95;
    int t96;
    unsigned int t97;
    unsigned int t98;
    unsigned int t99;
    int t100;
    unsigned int t101;
    unsigned int t102;
    unsigned int t103;
    unsigned int t104;
    char *t106;
    unsigned int t107;
    unsigned int t108;
    unsigned int t109;
    unsigned int t110;
    unsigned int t111;
    char *t112;
    unsigned int t114;
    unsigned int t115;
    unsigned int t116;
    char *t117;
    char *t118;
    char *t119;
    unsigned int t120;
    unsigned int t121;
    unsigned int t122;
    unsigned int t123;
    unsigned int t124;
    unsigned int t125;
    unsigned int t126;
    char *t127;
    char *t128;
    unsigned int t129;
    unsigned int t130;
    unsigned int t131;
    unsigned int t132;
    unsigned int t133;
    unsigned int t134;
    unsigned int t135;
    unsigned int t136;
    int t137;
    int t138;
    unsigned int t139;
    unsigned int t140;
    unsigned int t141;
    unsigned int t142;
    unsigned int t143;
    unsigned int t144;
    char *t145;
    char *t146;
    char *t147;
    char *t148;
    char *t149;
    unsigned int t150;
    unsigned int t151;
    char *t152;
    unsigned int t153;
    unsigned int t154;
    char *t155;
    unsigned int t156;
    unsigned int t157;
    char *t158;

LAB0:    t1 = (t0 + 7888U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(33, ng0);
    t2 = (t0 + 6088);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    memset(t5, 0, 8);
    t6 = (t4 + 4);
    t7 = *((unsigned int *)t6);
    t8 = (~(t7));
    t9 = *((unsigned int *)t4);
    t10 = (t9 & t8);
    t11 = (t10 & 1U);
    if (t11 != 0)
        goto LAB4;

LAB5:    if (*((unsigned int *)t6) != 0)
        goto LAB6;

LAB7:    t13 = (t5 + 4);
    t14 = *((unsigned int *)t5);
    t15 = *((unsigned int *)t13);
    t16 = (t14 || t15);
    if (t16 > 0)
        goto LAB8;

LAB9:    memcpy(t113, t5, 8);

LAB10:    t145 = (t0 + 10912);
    t146 = (t145 + 56U);
    t147 = *((char **)t146);
    t148 = (t147 + 56U);
    t149 = *((char **)t148);
    memset(t149, 0, 8);
    t150 = 1U;
    t151 = t150;
    t152 = (t113 + 4);
    t153 = *((unsigned int *)t113);
    t150 = (t150 & t153);
    t154 = *((unsigned int *)t152);
    t151 = (t151 & t154);
    t155 = (t149 + 4);
    t156 = *((unsigned int *)t149);
    *((unsigned int *)t149) = (t156 | t150);
    t157 = *((unsigned int *)t155);
    *((unsigned int *)t155) = (t157 | t151);
    xsi_driver_vfirst_trans(t145, 0, 0);
    t158 = (t0 + 10704);
    *((int *)t158) = 1;

LAB1:    return;
LAB4:    *((unsigned int *)t5) = 1;
    goto LAB7;

LAB6:    t12 = (t5 + 4);
    *((unsigned int *)t5) = 1;
    *((unsigned int *)t12) = 1;
    goto LAB7;

LAB8:    t18 = (t0 + 3928U);
    t19 = *((char **)t18);
    memset(t17, 0, 8);
    t18 = (t19 + 4);
    t20 = *((unsigned int *)t18);
    t21 = (~(t20));
    t22 = *((unsigned int *)t19);
    t23 = (t22 & t21);
    t24 = (t23 & 1U);
    if (t24 != 0)
        goto LAB14;

LAB12:    if (*((unsigned int *)t18) == 0)
        goto LAB11;

LAB13:    t25 = (t17 + 4);
    *((unsigned int *)t17) = 1;
    *((unsigned int *)t25) = 1;

LAB14:    t26 = (t17 + 4);
    t27 = (t19 + 4);
    t28 = *((unsigned int *)t19);
    t29 = (~(t28));
    *((unsigned int *)t17) = t29;
    *((unsigned int *)t26) = 0;
    if (*((unsigned int *)t27) != 0)
        goto LAB16;

LAB15:    t34 = *((unsigned int *)t17);
    *((unsigned int *)t17) = (t34 & 1U);
    t35 = *((unsigned int *)t26);
    *((unsigned int *)t26) = (t35 & 1U);
    memset(t36, 0, 8);
    t37 = (t17 + 4);
    t38 = *((unsigned int *)t37);
    t39 = (~(t38));
    t40 = *((unsigned int *)t17);
    t41 = (t40 & t39);
    t42 = (t41 & 1U);
    if (t42 != 0)
        goto LAB17;

LAB18:    if (*((unsigned int *)t37) != 0)
        goto LAB19;

LAB20:    t44 = (t36 + 4);
    t45 = *((unsigned int *)t36);
    t46 = (!(t45));
    t47 = *((unsigned int *)t44);
    t48 = (t46 || t47);
    if (t48 > 0)
        goto LAB21;

LAB22:    memcpy(t77, t36, 8);

LAB23:    memset(t105, 0, 8);
    t106 = (t77 + 4);
    t107 = *((unsigned int *)t106);
    t108 = (~(t107));
    t109 = *((unsigned int *)t77);
    t110 = (t109 & t108);
    t111 = (t110 & 1U);
    if (t111 != 0)
        goto LAB35;

LAB36:    if (*((unsigned int *)t106) != 0)
        goto LAB37;

LAB38:    t114 = *((unsigned int *)t5);
    t115 = *((unsigned int *)t105);
    t116 = (t114 & t115);
    *((unsigned int *)t113) = t116;
    t117 = (t5 + 4);
    t118 = (t105 + 4);
    t119 = (t113 + 4);
    t120 = *((unsigned int *)t117);
    t121 = *((unsigned int *)t118);
    t122 = (t120 | t121);
    *((unsigned int *)t119) = t122;
    t123 = *((unsigned int *)t119);
    t124 = (t123 != 0);
    if (t124 == 1)
        goto LAB39;

LAB40:
LAB41:    goto LAB10;

LAB11:    *((unsigned int *)t17) = 1;
    goto LAB14;

LAB16:    t30 = *((unsigned int *)t17);
    t31 = *((unsigned int *)t27);
    *((unsigned int *)t17) = (t30 | t31);
    t32 = *((unsigned int *)t26);
    t33 = *((unsigned int *)t27);
    *((unsigned int *)t26) = (t32 | t33);
    goto LAB15;

LAB17:    *((unsigned int *)t36) = 1;
    goto LAB20;

LAB19:    t43 = (t36 + 4);
    *((unsigned int *)t36) = 1;
    *((unsigned int *)t43) = 1;
    goto LAB20;

LAB21:    t49 = (t0 + 6568);
    t50 = (t49 + 56U);
    t51 = *((char **)t50);
    t52 = ((char*)((ng1)));
    memset(t53, 0, 8);
    t54 = (t51 + 4);
    t55 = (t52 + 4);
    t56 = *((unsigned int *)t51);
    t57 = *((unsigned int *)t52);
    t58 = (t56 ^ t57);
    t59 = *((unsigned int *)t54);
    t60 = *((unsigned int *)t55);
    t61 = (t59 ^ t60);
    t62 = (t58 | t61);
    t63 = *((unsigned int *)t54);
    t64 = *((unsigned int *)t55);
    t65 = (t63 | t64);
    t66 = (~(t65));
    t67 = (t62 & t66);
    if (t67 != 0)
        goto LAB27;

LAB24:    if (t65 != 0)
        goto LAB26;

LAB25:    *((unsigned int *)t53) = 1;

LAB27:    memset(t69, 0, 8);
    t70 = (t53 + 4);
    t71 = *((unsigned int *)t70);
    t72 = (~(t71));
    t73 = *((unsigned int *)t53);
    t74 = (t73 & t72);
    t75 = (t74 & 1U);
    if (t75 != 0)
        goto LAB28;

LAB29:    if (*((unsigned int *)t70) != 0)
        goto LAB30;

LAB31:    t78 = *((unsigned int *)t36);
    t79 = *((unsigned int *)t69);
    t80 = (t78 | t79);
    *((unsigned int *)t77) = t80;
    t81 = (t36 + 4);
    t82 = (t69 + 4);
    t83 = (t77 + 4);
    t84 = *((unsigned int *)t81);
    t85 = *((unsigned int *)t82);
    t86 = (t84 | t85);
    *((unsigned int *)t83) = t86;
    t87 = *((unsigned int *)t83);
    t88 = (t87 != 0);
    if (t88 == 1)
        goto LAB32;

LAB33:
LAB34:    goto LAB23;

LAB26:    t68 = (t53 + 4);
    *((unsigned int *)t53) = 1;
    *((unsigned int *)t68) = 1;
    goto LAB27;

LAB28:    *((unsigned int *)t69) = 1;
    goto LAB31;

LAB30:    t76 = (t69 + 4);
    *((unsigned int *)t69) = 1;
    *((unsigned int *)t76) = 1;
    goto LAB31;

LAB32:    t89 = *((unsigned int *)t77);
    t90 = *((unsigned int *)t83);
    *((unsigned int *)t77) = (t89 | t90);
    t91 = (t36 + 4);
    t92 = (t69 + 4);
    t93 = *((unsigned int *)t91);
    t94 = (~(t93));
    t95 = *((unsigned int *)t36);
    t96 = (t95 & t94);
    t97 = *((unsigned int *)t92);
    t98 = (~(t97));
    t99 = *((unsigned int *)t69);
    t100 = (t99 & t98);
    t101 = (~(t96));
    t102 = (~(t100));
    t103 = *((unsigned int *)t83);
    *((unsigned int *)t83) = (t103 & t101);
    t104 = *((unsigned int *)t83);
    *((unsigned int *)t83) = (t104 & t102);
    goto LAB34;

LAB35:    *((unsigned int *)t105) = 1;
    goto LAB38;

LAB37:    t112 = (t105 + 4);
    *((unsigned int *)t105) = 1;
    *((unsigned int *)t112) = 1;
    goto LAB38;

LAB39:    t125 = *((unsigned int *)t113);
    t126 = *((unsigned int *)t119);
    *((unsigned int *)t113) = (t125 | t126);
    t127 = (t5 + 4);
    t128 = (t105 + 4);
    t129 = *((unsigned int *)t5);
    t130 = (~(t129));
    t131 = *((unsigned int *)t127);
    t132 = (~(t131));
    t133 = *((unsigned int *)t105);
    t134 = (~(t133));
    t135 = *((unsigned int *)t128);
    t136 = (~(t135));
    t137 = (t130 & t132);
    t138 = (t134 & t136);
    t139 = (~(t137));
    t140 = (~(t138));
    t141 = *((unsigned int *)t119);
    *((unsigned int *)t119) = (t141 & t139);
    t142 = *((unsigned int *)t119);
    *((unsigned int *)t119) = (t142 & t140);
    t143 = *((unsigned int *)t113);
    *((unsigned int *)t113) = (t143 & t139);
    t144 = *((unsigned int *)t113);
    *((unsigned int *)t113) = (t144 & t140);
    goto LAB41;

}

static void Cont_45_2(char *t0)
{
    char t3[8];
    char t4[8];
    char t20[8];
    char *t1;
    char *t2;
    char *t5;
    char *t6;
    char *t7;
    char *t8;
    unsigned int t9;
    unsigned int t10;
    unsigned int t11;
    unsigned int t12;
    unsigned int t13;
    unsigned int t14;
    char *t15;
    char *t16;
    char *t17;
    char *t18;
    char *t19;
    char *t21;
    char *t22;
    unsigned int t23;
    unsigned int t24;
    unsigned int t25;
    unsigned int t26;
    unsigned int t27;
    unsigned int t28;
    unsigned int t29;
    unsigned int t30;
    unsigned int t31;
    unsigned int t32;
    unsigned int t33;
    unsigned int t34;
    char *t35;
    char *t36;
    char *t37;
    char *t38;
    char *t39;
    char *t40;
    char *t41;
    char *t42;
    char *t43;
    char *t44;
    unsigned int t45;
    unsigned int t46;
    char *t47;
    unsigned int t48;
    unsigned int t49;
    char *t50;
    unsigned int t51;
    unsigned int t52;
    char *t53;

LAB0:    t1 = (t0 + 8136U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(45, ng0);
    t2 = (t0 + 6728);
    t5 = (t2 + 56U);
    t6 = *((char **)t5);
    memset(t4, 0, 8);
    t7 = (t4 + 4);
    t8 = (t6 + 4);
    t9 = *((unsigned int *)t6);
    t10 = (t9 >> 8);
    *((unsigned int *)t4) = t10;
    t11 = *((unsigned int *)t8);
    t12 = (t11 >> 8);
    *((unsigned int *)t7) = t12;
    t13 = *((unsigned int *)t4);
    *((unsigned int *)t4) = (t13 & 15U);
    t14 = *((unsigned int *)t7);
    *((unsigned int *)t7) = (t14 & 15U);
    t15 = ((char*)((ng2)));
    t16 = (t0 + 6408);
    t17 = (t16 + 56U);
    t18 = *((char **)t17);
    t19 = ((char*)((ng3)));
    memset(t20, 0, 8);
    t21 = (t18 + 4);
    t22 = (t19 + 4);
    t23 = *((unsigned int *)t18);
    t24 = *((unsigned int *)t19);
    t25 = (t23 ^ t24);
    t26 = *((unsigned int *)t21);
    t27 = *((unsigned int *)t22);
    t28 = (t26 ^ t27);
    t29 = (t25 | t28);
    t30 = *((unsigned int *)t21);
    t31 = *((unsigned int *)t22);
    t32 = (t30 | t31);
    t33 = (~(t32));
    t34 = (t29 & t33);
    if (t34 != 0)
        goto LAB7;

LAB4:    if (t32 != 0)
        goto LAB6;

LAB5:    *((unsigned int *)t20) = 1;

LAB7:    t36 = (t0 + 6248);
    t37 = (t36 + 56U);
    t38 = *((char **)t37);
    t39 = (t0 + 5368U);
    t40 = *((char **)t39);
    xsi_vlogtype_concat(t3, 8, 8, 5U, t40, 1, t38, 1, t20, 1, t15, 1, t4, 4);
    t39 = (t0 + 10976);
    t41 = (t39 + 56U);
    t42 = *((char **)t41);
    t43 = (t42 + 56U);
    t44 = *((char **)t43);
    memset(t44, 0, 8);
    t45 = 255U;
    t46 = t45;
    t47 = (t3 + 4);
    t48 = *((unsigned int *)t3);
    t45 = (t45 & t48);
    t49 = *((unsigned int *)t47);
    t46 = (t46 & t49);
    t50 = (t44 + 4);
    t51 = *((unsigned int *)t44);
    *((unsigned int *)t44) = (t51 | t45);
    t52 = *((unsigned int *)t50);
    *((unsigned int *)t50) = (t52 | t46);
    xsi_driver_vfirst_trans(t39, 0, 7);
    t53 = (t0 + 10720);
    *((int *)t53) = 1;

LAB1:    return;
LAB6:    t35 = (t20 + 4);
    *((unsigned int *)t20) = 1;
    *((unsigned int *)t35) = 1;
    goto LAB7;

}

static void Initial_49_3(char *t0)
{
    char *t1;
    char *t2;

LAB0:    xsi_set_current_line(49, ng0);
    t1 = ((char*)((ng2)));
    t2 = (t0 + 6568);
    xsi_vlogvar_assign_value(t2, t1, 0, 0, 4);

LAB1:    return;
}

static void Initial_50_4(char *t0)
{
    char *t1;
    char *t2;

LAB0:    xsi_set_current_line(50, ng0);
    t1 = ((char*)((ng2)));
    t2 = (t0 + 5928);
    xsi_vlogvar_assign_value(t2, t1, 0, 0, 1);

LAB1:    return;
}

static void Initial_51_5(char *t0)
{
    char *t1;
    char *t2;

LAB0:    xsi_set_current_line(51, ng0);
    t1 = ((char*)((ng2)));
    t2 = (t0 + 6088);
    xsi_vlogvar_assign_value(t2, t1, 0, 0, 1);

LAB1:    return;
}

static void Initial_52_6(char *t0)
{
    char *t1;
    char *t2;

LAB0:    xsi_set_current_line(52, ng0);
    t1 = ((char*)((ng3)));
    t2 = (t0 + 6408);
    xsi_vlogvar_assign_value(t2, t1, 0, 0, 8);

LAB1:    return;
}

static void Initial_53_7(char *t0)
{
    char *t1;
    char *t2;

LAB0:    xsi_set_current_line(53, ng0);
    t1 = ((char*)((ng4)));
    t2 = (t0 + 6248);
    xsi_vlogvar_assign_value(t2, t1, 0, 0, 1);

LAB1:    return;
}

static void Initial_54_8(char *t0)
{
    char *t1;
    char *t2;

LAB0:    xsi_set_current_line(54, ng0);
    t1 = ((char*)((ng5)));
    t2 = (t0 + 6728);
    xsi_vlogvar_assign_value(t2, t1, 0, 0, 12);

LAB1:    return;
}

static void Always_67_9(char *t0)
{
    char t8[8];
    char t24[8];
    char t39[8];
    char t50[8];
    char t69[8];
    char t77[8];
    char t109[8];
    char t117[8];
    char t153[8];
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t5;
    char *t6;
    char *t7;
    char *t9;
    char *t10;
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
    unsigned int t21;
    unsigned int t22;
    char *t23;
    char *t25;
    unsigned int t26;
    unsigned int t27;
    unsigned int t28;
    unsigned int t29;
    unsigned int t30;
    char *t31;
    char *t32;
    unsigned int t33;
    unsigned int t34;
    unsigned int t35;
    unsigned int t36;
    char *t37;
    char *t38;
    unsigned int t40;
    unsigned int t41;
    unsigned int t42;
    unsigned int t43;
    unsigned int t44;
    char *t45;
    char *t46;
    unsigned int t47;
    unsigned int t48;
    unsigned int t49;
    char *t51;
    char *t52;
    unsigned int t53;
    unsigned int t54;
    unsigned int t55;
    unsigned int t56;
    unsigned int t57;
    char *t58;
    char *t59;
    char *t60;
    unsigned int t61;
    unsigned int t62;
    unsigned int t63;
    unsigned int t64;
    unsigned int t65;
    unsigned int t66;
    unsigned int t67;
    unsigned int t68;
    char *t70;
    unsigned int t71;
    unsigned int t72;
    unsigned int t73;
    unsigned int t74;
    unsigned int t75;
    char *t76;
    unsigned int t78;
    unsigned int t79;
    unsigned int t80;
    char *t81;
    char *t82;
    char *t83;
    unsigned int t84;
    unsigned int t85;
    unsigned int t86;
    unsigned int t87;
    unsigned int t88;
    unsigned int t89;
    unsigned int t90;
    char *t91;
    char *t92;
    unsigned int t93;
    unsigned int t94;
    unsigned int t95;
    unsigned int t96;
    unsigned int t97;
    unsigned int t98;
    unsigned int t99;
    unsigned int t100;
    int t101;
    int t102;
    unsigned int t103;
    unsigned int t104;
    unsigned int t105;
    unsigned int t106;
    unsigned int t107;
    unsigned int t108;
    char *t110;
    unsigned int t111;
    unsigned int t112;
    unsigned int t113;
    unsigned int t114;
    unsigned int t115;
    char *t116;
    unsigned int t118;
    unsigned int t119;
    unsigned int t120;
    char *t121;
    char *t122;
    char *t123;
    unsigned int t124;
    unsigned int t125;
    unsigned int t126;
    unsigned int t127;
    unsigned int t128;
    unsigned int t129;
    unsigned int t130;
    char *t131;
    char *t132;
    unsigned int t133;
    unsigned int t134;
    unsigned int t135;
    int t136;
    unsigned int t137;
    unsigned int t138;
    unsigned int t139;
    int t140;
    unsigned int t141;
    unsigned int t142;
    unsigned int t143;
    unsigned int t144;
    char *t145;
    unsigned int t146;
    unsigned int t147;
    unsigned int t148;
    unsigned int t149;
    unsigned int t150;
    char *t151;
    char *t152;
    char *t154;
    unsigned int t155;
    unsigned int t156;
    unsigned int t157;
    unsigned int t158;
    unsigned int t159;
    unsigned int t160;
    unsigned int t161;
    unsigned int t162;
    unsigned int t163;
    char *t164;
    unsigned int t165;
    unsigned int t166;
    unsigned int t167;
    unsigned int t168;
    unsigned int t169;
    char *t170;
    char *t171;

LAB0:    t1 = (t0 + 9872U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(67, ng0);
    t2 = (t0 + 10736);
    *((int *)t2) = 1;
    t3 = (t0 + 9904);
    *((char **)t3) = t2;
    *((char **)t1) = &&LAB4;

LAB1:    return;
LAB4:    xsi_set_current_line(68, ng0);

LAB5:    xsi_set_current_line(69, ng0);
    t4 = (t0 + 6568);
    t5 = (t4 + 56U);
    t6 = *((char **)t5);
    t7 = ((char*)((ng2)));
    memset(t8, 0, 8);
    t9 = (t6 + 4);
    t10 = (t7 + 4);
    t11 = *((unsigned int *)t6);
    t12 = *((unsigned int *)t7);
    t13 = (t11 ^ t12);
    t14 = *((unsigned int *)t9);
    t15 = *((unsigned int *)t10);
    t16 = (t14 ^ t15);
    t17 = (t13 | t16);
    t18 = *((unsigned int *)t9);
    t19 = *((unsigned int *)t10);
    t20 = (t18 | t19);
    t21 = (~(t20));
    t22 = (t17 & t21);
    if (t22 != 0)
        goto LAB9;

LAB6:    if (t20 != 0)
        goto LAB8;

LAB7:    *((unsigned int *)t8) = 1;

LAB9:    memset(t24, 0, 8);
    t25 = (t8 + 4);
    t26 = *((unsigned int *)t25);
    t27 = (~(t26));
    t28 = *((unsigned int *)t8);
    t29 = (t28 & t27);
    t30 = (t29 & 1U);
    if (t30 != 0)
        goto LAB10;

LAB11:    if (*((unsigned int *)t25) != 0)
        goto LAB12;

LAB13:    t32 = (t24 + 4);
    t33 = *((unsigned int *)t24);
    t34 = (!(t33));
    t35 = *((unsigned int *)t32);
    t36 = (t34 || t35);
    if (t36 > 0)
        goto LAB14;

LAB15:    memcpy(t117, t24, 8);

LAB16:    t145 = (t117 + 4);
    t146 = *((unsigned int *)t145);
    t147 = (~(t146));
    t148 = *((unsigned int *)t117);
    t149 = (t148 & t147);
    t150 = (t149 != 0);
    if (t150 > 0)
        goto LAB44;

LAB45:    xsi_set_current_line(73, ng0);
    t2 = (t0 + 6568);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    memset(t24, 0, 8);
    t5 = (t24 + 4);
    t6 = (t4 + 4);
    t11 = *((unsigned int *)t4);
    t12 = (t11 >> 3);
    t13 = (t12 & 1);
    *((unsigned int *)t24) = t13;
    t14 = *((unsigned int *)t6);
    t15 = (t14 >> 3);
    t16 = (t15 & 1);
    *((unsigned int *)t5) = t16;
    t7 = (t0 + 6568);
    t9 = (t7 + 56U);
    t10 = *((char **)t9);
    memset(t39, 0, 8);
    t23 = (t39 + 4);
    t25 = (t10 + 4);
    t17 = *((unsigned int *)t10);
    t18 = (t17 >> 0);
    *((unsigned int *)t39) = t18;
    t19 = *((unsigned int *)t25);
    t20 = (t19 >> 0);
    *((unsigned int *)t23) = t20;
    t21 = *((unsigned int *)t39);
    *((unsigned int *)t39) = (t21 & 7U);
    t22 = *((unsigned int *)t23);
    *((unsigned int *)t23) = (t22 & 7U);
    xsi_vlogtype_concat(t8, 4, 4, 2U, t39, 3, t24, 1);
    t31 = (t0 + 6568);
    xsi_vlogvar_wait_assign_value(t31, t8, 0, 0, 4, 0LL);

LAB46:    xsi_set_current_line(74, ng0);
    t2 = (t0 + 6568);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    t5 = ((char*)((ng6)));
    memset(t8, 0, 8);
    t6 = (t4 + 4);
    t7 = (t5 + 4);
    t11 = *((unsigned int *)t4);
    t12 = *((unsigned int *)t5);
    t13 = (t11 ^ t12);
    t14 = *((unsigned int *)t6);
    t15 = *((unsigned int *)t7);
    t16 = (t14 ^ t15);
    t17 = (t13 | t16);
    t18 = *((unsigned int *)t6);
    t19 = *((unsigned int *)t7);
    t20 = (t18 | t19);
    t21 = (~(t20));
    t22 = (t17 & t21);
    if (t22 != 0)
        goto LAB50;

LAB47:    if (t20 != 0)
        goto LAB49;

LAB48:    *((unsigned int *)t8) = 1;

LAB50:    memset(t24, 0, 8);
    t10 = (t8 + 4);
    t26 = *((unsigned int *)t10);
    t27 = (~(t26));
    t28 = *((unsigned int *)t8);
    t29 = (t28 & t27);
    t30 = (t29 & 1U);
    if (t30 != 0)
        goto LAB51;

LAB52:    if (*((unsigned int *)t10) != 0)
        goto LAB53;

LAB54:    t25 = (t24 + 4);
    t33 = *((unsigned int *)t24);
    t34 = *((unsigned int *)t25);
    t35 = (t33 || t34);
    if (t35 > 0)
        goto LAB55;

LAB56:    memcpy(t69, t24, 8);

LAB57:    memset(t77, 0, 8);
    t76 = (t69 + 4);
    t97 = *((unsigned int *)t76);
    t98 = (~(t97));
    t99 = *((unsigned int *)t69);
    t100 = (t99 & t98);
    t103 = (t100 & 1U);
    if (t103 != 0)
        goto LAB69;

LAB70:    if (*((unsigned int *)t76) != 0)
        goto LAB71;

LAB72:    t82 = (t77 + 4);
    t104 = *((unsigned int *)t77);
    t105 = *((unsigned int *)t82);
    t106 = (t104 || t105);
    if (t106 > 0)
        goto LAB73;

LAB74:    memcpy(t153, t77, 8);

LAB75:    t164 = (t153 + 4);
    t165 = *((unsigned int *)t164);
    t166 = (~(t165));
    t167 = *((unsigned int *)t153);
    t168 = (t167 & t166);
    t169 = (t168 != 0);
    if (t169 > 0)
        goto LAB87;

LAB88:
LAB89:    xsi_set_current_line(75, ng0);
    t2 = (t0 + 6568);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    t5 = ((char*)((ng7)));
    memset(t8, 0, 8);
    t6 = (t4 + 4);
    t7 = (t5 + 4);
    t11 = *((unsigned int *)t4);
    t12 = *((unsigned int *)t5);
    t13 = (t11 ^ t12);
    t14 = *((unsigned int *)t6);
    t15 = *((unsigned int *)t7);
    t16 = (t14 ^ t15);
    t17 = (t13 | t16);
    t18 = *((unsigned int *)t6);
    t19 = *((unsigned int *)t7);
    t20 = (t18 | t19);
    t21 = (~(t20));
    t22 = (t17 & t21);
    if (t22 != 0)
        goto LAB93;

LAB90:    if (t20 != 0)
        goto LAB92;

LAB91:    *((unsigned int *)t8) = 1;

LAB93:    memset(t24, 0, 8);
    t10 = (t8 + 4);
    t26 = *((unsigned int *)t10);
    t27 = (~(t26));
    t28 = *((unsigned int *)t8);
    t29 = (t28 & t27);
    t30 = (t29 & 1U);
    if (t30 != 0)
        goto LAB94;

LAB95:    if (*((unsigned int *)t10) != 0)
        goto LAB96;

LAB97:    t25 = (t24 + 4);
    t33 = *((unsigned int *)t24);
    t34 = *((unsigned int *)t25);
    t35 = (t33 || t34);
    if (t35 > 0)
        goto LAB98;

LAB99:    memcpy(t69, t24, 8);

LAB100:    t76 = (t69 + 4);
    t97 = *((unsigned int *)t76);
    t98 = (~(t97));
    t99 = *((unsigned int *)t69);
    t100 = (t99 & t98);
    t103 = (t100 != 0);
    if (t103 > 0)
        goto LAB112;

LAB113:
LAB114:    goto LAB2;

LAB8:    t23 = (t8 + 4);
    *((unsigned int *)t8) = 1;
    *((unsigned int *)t23) = 1;
    goto LAB9;

LAB10:    *((unsigned int *)t24) = 1;
    goto LAB13;

LAB12:    t31 = (t24 + 4);
    *((unsigned int *)t24) = 1;
    *((unsigned int *)t31) = 1;
    goto LAB13;

LAB14:    t37 = (t0 + 5368U);
    t38 = *((char **)t37);
    memset(t39, 0, 8);
    t37 = (t38 + 4);
    t40 = *((unsigned int *)t37);
    t41 = (~(t40));
    t42 = *((unsigned int *)t38);
    t43 = (t42 & t41);
    t44 = (t43 & 1U);
    if (t44 != 0)
        goto LAB17;

LAB18:    if (*((unsigned int *)t37) != 0)
        goto LAB19;

LAB20:    t46 = (t39 + 4);
    t47 = *((unsigned int *)t39);
    t48 = *((unsigned int *)t46);
    t49 = (t47 || t48);
    if (t49 > 0)
        goto LAB21;

LAB22:    memcpy(t77, t39, 8);

LAB23:    memset(t109, 0, 8);
    t110 = (t77 + 4);
    t111 = *((unsigned int *)t110);
    t112 = (~(t111));
    t113 = *((unsigned int *)t77);
    t114 = (t113 & t112);
    t115 = (t114 & 1U);
    if (t115 != 0)
        goto LAB37;

LAB38:    if (*((unsigned int *)t110) != 0)
        goto LAB39;

LAB40:    t118 = *((unsigned int *)t24);
    t119 = *((unsigned int *)t109);
    t120 = (t118 | t119);
    *((unsigned int *)t117) = t120;
    t121 = (t24 + 4);
    t122 = (t109 + 4);
    t123 = (t117 + 4);
    t124 = *((unsigned int *)t121);
    t125 = *((unsigned int *)t122);
    t126 = (t124 | t125);
    *((unsigned int *)t123) = t126;
    t127 = *((unsigned int *)t123);
    t128 = (t127 != 0);
    if (t128 == 1)
        goto LAB41;

LAB42:
LAB43:    goto LAB16;

LAB17:    *((unsigned int *)t39) = 1;
    goto LAB20;

LAB19:    t45 = (t39 + 4);
    *((unsigned int *)t39) = 1;
    *((unsigned int *)t45) = 1;
    goto LAB20;

LAB21:    t51 = (t0 + 1208U);
    t52 = *((char **)t51);
    memset(t50, 0, 8);
    t51 = (t52 + 4);
    t53 = *((unsigned int *)t51);
    t54 = (~(t53));
    t55 = *((unsigned int *)t52);
    t56 = (t55 & t54);
    t57 = (t56 & 1U);
    if (t57 != 0)
        goto LAB27;

LAB25:    if (*((unsigned int *)t51) == 0)
        goto LAB24;

LAB26:    t58 = (t50 + 4);
    *((unsigned int *)t50) = 1;
    *((unsigned int *)t58) = 1;

LAB27:    t59 = (t50 + 4);
    t60 = (t52 + 4);
    t61 = *((unsigned int *)t52);
    t62 = (~(t61));
    *((unsigned int *)t50) = t62;
    *((unsigned int *)t59) = 0;
    if (*((unsigned int *)t60) != 0)
        goto LAB29;

LAB28:    t67 = *((unsigned int *)t50);
    *((unsigned int *)t50) = (t67 & 1U);
    t68 = *((unsigned int *)t59);
    *((unsigned int *)t59) = (t68 & 1U);
    memset(t69, 0, 8);
    t70 = (t50 + 4);
    t71 = *((unsigned int *)t70);
    t72 = (~(t71));
    t73 = *((unsigned int *)t50);
    t74 = (t73 & t72);
    t75 = (t74 & 1U);
    if (t75 != 0)
        goto LAB30;

LAB31:    if (*((unsigned int *)t70) != 0)
        goto LAB32;

LAB33:    t78 = *((unsigned int *)t39);
    t79 = *((unsigned int *)t69);
    t80 = (t78 & t79);
    *((unsigned int *)t77) = t80;
    t81 = (t39 + 4);
    t82 = (t69 + 4);
    t83 = (t77 + 4);
    t84 = *((unsigned int *)t81);
    t85 = *((unsigned int *)t82);
    t86 = (t84 | t85);
    *((unsigned int *)t83) = t86;
    t87 = *((unsigned int *)t83);
    t88 = (t87 != 0);
    if (t88 == 1)
        goto LAB34;

LAB35:
LAB36:    goto LAB23;

LAB24:    *((unsigned int *)t50) = 1;
    goto LAB27;

LAB29:    t63 = *((unsigned int *)t50);
    t64 = *((unsigned int *)t60);
    *((unsigned int *)t50) = (t63 | t64);
    t65 = *((unsigned int *)t59);
    t66 = *((unsigned int *)t60);
    *((unsigned int *)t59) = (t65 | t66);
    goto LAB28;

LAB30:    *((unsigned int *)t69) = 1;
    goto LAB33;

LAB32:    t76 = (t69 + 4);
    *((unsigned int *)t69) = 1;
    *((unsigned int *)t76) = 1;
    goto LAB33;

LAB34:    t89 = *((unsigned int *)t77);
    t90 = *((unsigned int *)t83);
    *((unsigned int *)t77) = (t89 | t90);
    t91 = (t39 + 4);
    t92 = (t69 + 4);
    t93 = *((unsigned int *)t39);
    t94 = (~(t93));
    t95 = *((unsigned int *)t91);
    t96 = (~(t95));
    t97 = *((unsigned int *)t69);
    t98 = (~(t97));
    t99 = *((unsigned int *)t92);
    t100 = (~(t99));
    t101 = (t94 & t96);
    t102 = (t98 & t100);
    t103 = (~(t101));
    t104 = (~(t102));
    t105 = *((unsigned int *)t83);
    *((unsigned int *)t83) = (t105 & t103);
    t106 = *((unsigned int *)t83);
    *((unsigned int *)t83) = (t106 & t104);
    t107 = *((unsigned int *)t77);
    *((unsigned int *)t77) = (t107 & t103);
    t108 = *((unsigned int *)t77);
    *((unsigned int *)t77) = (t108 & t104);
    goto LAB36;

LAB37:    *((unsigned int *)t109) = 1;
    goto LAB40;

LAB39:    t116 = (t109 + 4);
    *((unsigned int *)t109) = 1;
    *((unsigned int *)t116) = 1;
    goto LAB40;

LAB41:    t129 = *((unsigned int *)t117);
    t130 = *((unsigned int *)t123);
    *((unsigned int *)t117) = (t129 | t130);
    t131 = (t24 + 4);
    t132 = (t109 + 4);
    t133 = *((unsigned int *)t131);
    t134 = (~(t133));
    t135 = *((unsigned int *)t24);
    t136 = (t135 & t134);
    t137 = *((unsigned int *)t132);
    t138 = (~(t137));
    t139 = *((unsigned int *)t109);
    t140 = (t139 & t138);
    t141 = (~(t136));
    t142 = (~(t140));
    t143 = *((unsigned int *)t123);
    *((unsigned int *)t123) = (t143 & t141);
    t144 = *((unsigned int *)t123);
    *((unsigned int *)t123) = (t144 & t142);
    goto LAB43;

LAB44:    xsi_set_current_line(70, ng0);
    t151 = ((char*)((ng4)));
    t152 = (t0 + 6568);
    xsi_vlogvar_wait_assign_value(t152, t151, 0, 0, 4, 0LL);
    goto LAB46;

LAB49:    t9 = (t8 + 4);
    *((unsigned int *)t8) = 1;
    *((unsigned int *)t9) = 1;
    goto LAB50;

LAB51:    *((unsigned int *)t24) = 1;
    goto LAB54;

LAB53:    t23 = (t24 + 4);
    *((unsigned int *)t24) = 1;
    *((unsigned int *)t23) = 1;
    goto LAB54;

LAB55:    t31 = (t0 + 1208U);
    t32 = *((char **)t31);
    t31 = ((char*)((ng2)));
    memset(t39, 0, 8);
    t37 = (t32 + 4);
    t38 = (t31 + 4);
    t36 = *((unsigned int *)t32);
    t40 = *((unsigned int *)t31);
    t41 = (t36 ^ t40);
    t42 = *((unsigned int *)t37);
    t43 = *((unsigned int *)t38);
    t44 = (t42 ^ t43);
    t47 = (t41 | t44);
    t48 = *((unsigned int *)t37);
    t49 = *((unsigned int *)t38);
    t53 = (t48 | t49);
    t54 = (~(t53));
    t55 = (t47 & t54);
    if (t55 != 0)
        goto LAB61;

LAB58:    if (t53 != 0)
        goto LAB60;

LAB59:    *((unsigned int *)t39) = 1;

LAB61:    memset(t50, 0, 8);
    t46 = (t39 + 4);
    t56 = *((unsigned int *)t46);
    t57 = (~(t56));
    t61 = *((unsigned int *)t39);
    t62 = (t61 & t57);
    t63 = (t62 & 1U);
    if (t63 != 0)
        goto LAB62;

LAB63:    if (*((unsigned int *)t46) != 0)
        goto LAB64;

LAB65:    t64 = *((unsigned int *)t24);
    t65 = *((unsigned int *)t50);
    t66 = (t64 & t65);
    *((unsigned int *)t69) = t66;
    t52 = (t24 + 4);
    t58 = (t50 + 4);
    t59 = (t69 + 4);
    t67 = *((unsigned int *)t52);
    t68 = *((unsigned int *)t58);
    t71 = (t67 | t68);
    *((unsigned int *)t59) = t71;
    t72 = *((unsigned int *)t59);
    t73 = (t72 != 0);
    if (t73 == 1)
        goto LAB66;

LAB67:
LAB68:    goto LAB57;

LAB60:    t45 = (t39 + 4);
    *((unsigned int *)t39) = 1;
    *((unsigned int *)t45) = 1;
    goto LAB61;

LAB62:    *((unsigned int *)t50) = 1;
    goto LAB65;

LAB64:    t51 = (t50 + 4);
    *((unsigned int *)t50) = 1;
    *((unsigned int *)t51) = 1;
    goto LAB65;

LAB66:    t74 = *((unsigned int *)t69);
    t75 = *((unsigned int *)t59);
    *((unsigned int *)t69) = (t74 | t75);
    t60 = (t24 + 4);
    t70 = (t50 + 4);
    t78 = *((unsigned int *)t24);
    t79 = (~(t78));
    t80 = *((unsigned int *)t60);
    t84 = (~(t80));
    t85 = *((unsigned int *)t50);
    t86 = (~(t85));
    t87 = *((unsigned int *)t70);
    t88 = (~(t87));
    t101 = (t79 & t84);
    t102 = (t86 & t88);
    t89 = (~(t101));
    t90 = (~(t102));
    t93 = *((unsigned int *)t59);
    *((unsigned int *)t59) = (t93 & t89);
    t94 = *((unsigned int *)t59);
    *((unsigned int *)t59) = (t94 & t90);
    t95 = *((unsigned int *)t69);
    *((unsigned int *)t69) = (t95 & t89);
    t96 = *((unsigned int *)t69);
    *((unsigned int *)t69) = (t96 & t90);
    goto LAB68;

LAB69:    *((unsigned int *)t77) = 1;
    goto LAB72;

LAB71:    t81 = (t77 + 4);
    *((unsigned int *)t77) = 1;
    *((unsigned int *)t81) = 1;
    goto LAB72;

LAB73:    t83 = (t0 + 6248);
    t91 = (t83 + 56U);
    t92 = *((char **)t91);
    t110 = ((char*)((ng4)));
    memset(t109, 0, 8);
    t116 = (t92 + 4);
    t121 = (t110 + 4);
    t107 = *((unsigned int *)t92);
    t108 = *((unsigned int *)t110);
    t111 = (t107 ^ t108);
    t112 = *((unsigned int *)t116);
    t113 = *((unsigned int *)t121);
    t114 = (t112 ^ t113);
    t115 = (t111 | t114);
    t118 = *((unsigned int *)t116);
    t119 = *((unsigned int *)t121);
    t120 = (t118 | t119);
    t124 = (~(t120));
    t125 = (t115 & t124);
    if (t125 != 0)
        goto LAB79;

LAB76:    if (t120 != 0)
        goto LAB78;

LAB77:    *((unsigned int *)t109) = 1;

LAB79:    memset(t117, 0, 8);
    t123 = (t109 + 4);
    t126 = *((unsigned int *)t123);
    t127 = (~(t126));
    t128 = *((unsigned int *)t109);
    t129 = (t128 & t127);
    t130 = (t129 & 1U);
    if (t130 != 0)
        goto LAB80;

LAB81:    if (*((unsigned int *)t123) != 0)
        goto LAB82;

LAB83:    t133 = *((unsigned int *)t77);
    t134 = *((unsigned int *)t117);
    t135 = (t133 & t134);
    *((unsigned int *)t153) = t135;
    t132 = (t77 + 4);
    t145 = (t117 + 4);
    t151 = (t153 + 4);
    t137 = *((unsigned int *)t132);
    t138 = *((unsigned int *)t145);
    t139 = (t137 | t138);
    *((unsigned int *)t151) = t139;
    t141 = *((unsigned int *)t151);
    t142 = (t141 != 0);
    if (t142 == 1)
        goto LAB84;

LAB85:
LAB86:    goto LAB75;

LAB78:    t122 = (t109 + 4);
    *((unsigned int *)t109) = 1;
    *((unsigned int *)t122) = 1;
    goto LAB79;

LAB80:    *((unsigned int *)t117) = 1;
    goto LAB83;

LAB82:    t131 = (t117 + 4);
    *((unsigned int *)t117) = 1;
    *((unsigned int *)t131) = 1;
    goto LAB83;

LAB84:    t143 = *((unsigned int *)t153);
    t144 = *((unsigned int *)t151);
    *((unsigned int *)t153) = (t143 | t144);
    t152 = (t77 + 4);
    t154 = (t117 + 4);
    t146 = *((unsigned int *)t77);
    t147 = (~(t146));
    t148 = *((unsigned int *)t152);
    t149 = (~(t148));
    t150 = *((unsigned int *)t117);
    t155 = (~(t150));
    t156 = *((unsigned int *)t154);
    t157 = (~(t156));
    t136 = (t147 & t149);
    t140 = (t155 & t157);
    t158 = (~(t136));
    t159 = (~(t140));
    t160 = *((unsigned int *)t151);
    *((unsigned int *)t151) = (t160 & t158);
    t161 = *((unsigned int *)t151);
    *((unsigned int *)t151) = (t161 & t159);
    t162 = *((unsigned int *)t153);
    *((unsigned int *)t153) = (t162 & t158);
    t163 = *((unsigned int *)t153);
    *((unsigned int *)t153) = (t163 & t159);
    goto LAB86;

LAB87:    xsi_set_current_line(74, ng0);
    t170 = ((char*)((ng2)));
    t171 = (t0 + 6248);
    xsi_vlogvar_wait_assign_value(t171, t170, 0, 0, 1, 0LL);
    goto LAB89;

LAB92:    t9 = (t8 + 4);
    *((unsigned int *)t8) = 1;
    *((unsigned int *)t9) = 1;
    goto LAB93;

LAB94:    *((unsigned int *)t24) = 1;
    goto LAB97;

LAB96:    t23 = (t24 + 4);
    *((unsigned int *)t24) = 1;
    *((unsigned int *)t23) = 1;
    goto LAB97;

LAB98:    t31 = (t0 + 1208U);
    t32 = *((char **)t31);
    t31 = ((char*)((ng4)));
    memset(t39, 0, 8);
    t37 = (t32 + 4);
    t38 = (t31 + 4);
    t36 = *((unsigned int *)t32);
    t40 = *((unsigned int *)t31);
    t41 = (t36 ^ t40);
    t42 = *((unsigned int *)t37);
    t43 = *((unsigned int *)t38);
    t44 = (t42 ^ t43);
    t47 = (t41 | t44);
    t48 = *((unsigned int *)t37);
    t49 = *((unsigned int *)t38);
    t53 = (t48 | t49);
    t54 = (~(t53));
    t55 = (t47 & t54);
    if (t55 != 0)
        goto LAB104;

LAB101:    if (t53 != 0)
        goto LAB103;

LAB102:    *((unsigned int *)t39) = 1;

LAB104:    memset(t50, 0, 8);
    t46 = (t39 + 4);
    t56 = *((unsigned int *)t46);
    t57 = (~(t56));
    t61 = *((unsigned int *)t39);
    t62 = (t61 & t57);
    t63 = (t62 & 1U);
    if (t63 != 0)
        goto LAB105;

LAB106:    if (*((unsigned int *)t46) != 0)
        goto LAB107;

LAB108:    t64 = *((unsigned int *)t24);
    t65 = *((unsigned int *)t50);
    t66 = (t64 & t65);
    *((unsigned int *)t69) = t66;
    t52 = (t24 + 4);
    t58 = (t50 + 4);
    t59 = (t69 + 4);
    t67 = *((unsigned int *)t52);
    t68 = *((unsigned int *)t58);
    t71 = (t67 | t68);
    *((unsigned int *)t59) = t71;
    t72 = *((unsigned int *)t59);
    t73 = (t72 != 0);
    if (t73 == 1)
        goto LAB109;

LAB110:
LAB111:    goto LAB100;

LAB103:    t45 = (t39 + 4);
    *((unsigned int *)t39) = 1;
    *((unsigned int *)t45) = 1;
    goto LAB104;

LAB105:    *((unsigned int *)t50) = 1;
    goto LAB108;

LAB107:    t51 = (t50 + 4);
    *((unsigned int *)t50) = 1;
    *((unsigned int *)t51) = 1;
    goto LAB108;

LAB109:    t74 = *((unsigned int *)t69);
    t75 = *((unsigned int *)t59);
    *((unsigned int *)t69) = (t74 | t75);
    t60 = (t24 + 4);
    t70 = (t50 + 4);
    t78 = *((unsigned int *)t24);
    t79 = (~(t78));
    t80 = *((unsigned int *)t60);
    t84 = (~(t80));
    t85 = *((unsigned int *)t50);
    t86 = (~(t85));
    t87 = *((unsigned int *)t70);
    t88 = (~(t87));
    t101 = (t79 & t84);
    t102 = (t86 & t88);
    t89 = (~(t101));
    t90 = (~(t102));
    t93 = *((unsigned int *)t59);
    *((unsigned int *)t59) = (t93 & t89);
    t94 = *((unsigned int *)t59);
    *((unsigned int *)t59) = (t94 & t90);
    t95 = *((unsigned int *)t69);
    *((unsigned int *)t69) = (t95 & t89);
    t96 = *((unsigned int *)t69);
    *((unsigned int *)t69) = (t96 & t90);
    goto LAB111;

LAB112:    xsi_set_current_line(75, ng0);
    t81 = ((char*)((ng4)));
    t82 = (t0 + 6248);
    xsi_vlogvar_wait_assign_value(t82, t81, 0, 0, 1, 0LL);
    goto LAB114;

}

static void Always_79_10(char *t0)
{
    char t8[8];
    char t37[8];
    char t44[8];
    char t53[8];
    char t63[8];
    char t71[8];
    char t108[8];
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t5;
    char *t6;
    char *t7;
    char *t9;
    char *t10;
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
    unsigned int t21;
    unsigned int t22;
    char *t23;
    char *t24;
    unsigned int t25;
    unsigned int t26;
    unsigned int t27;
    unsigned int t28;
    unsigned int t29;
    char *t30;
    char *t31;
    char *t32;
    char *t33;
    int t34;
    char *t35;
    char *t36;
    unsigned int t38;
    unsigned int t39;
    unsigned int t40;
    unsigned int t41;
    unsigned int t42;
    unsigned int t43;
    char *t45;
    unsigned int t46;
    unsigned int t47;
    unsigned int t48;
    unsigned int t49;
    unsigned int t50;
    unsigned int t51;
    char *t52;
    unsigned int t54;
    unsigned int t55;
    unsigned int t56;
    unsigned int t57;
    unsigned int t58;
    unsigned int t59;
    unsigned int t60;
    unsigned int t61;
    unsigned int t62;
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
    unsigned int t96;
    unsigned int t97;
    unsigned int t98;
    unsigned int t99;
    unsigned int t100;
    unsigned int t101;
    char *t102;
    unsigned int t103;
    unsigned int t104;
    unsigned int t105;
    unsigned int t106;
    unsigned int t107;
    char *t109;
    char *t110;
    char *t111;
    char *t112;
    char *t113;
    unsigned int t114;
    unsigned int t115;
    unsigned int t116;
    unsigned int t117;
    unsigned int t118;
    unsigned int t119;
    char *t120;

LAB0:    t1 = (t0 + 10120U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(79, ng0);
    t2 = (t0 + 10752);
    *((int *)t2) = 1;
    t3 = (t0 + 10152);
    *((char **)t3) = t2;
    *((char **)t1) = &&LAB4;

LAB1:    return;
LAB4:    xsi_set_current_line(80, ng0);

LAB5:    xsi_set_current_line(81, ng0);
    t4 = (t0 + 6248);
    t5 = (t4 + 56U);
    t6 = *((char **)t5);
    t7 = ((char*)((ng2)));
    memset(t8, 0, 8);
    t9 = (t6 + 4);
    t10 = (t7 + 4);
    t11 = *((unsigned int *)t6);
    t12 = *((unsigned int *)t7);
    t13 = (t11 ^ t12);
    t14 = *((unsigned int *)t9);
    t15 = *((unsigned int *)t10);
    t16 = (t14 ^ t15);
    t17 = (t13 | t16);
    t18 = *((unsigned int *)t9);
    t19 = *((unsigned int *)t10);
    t20 = (t18 | t19);
    t21 = (~(t20));
    t22 = (t17 & t21);
    if (t22 != 0)
        goto LAB9;

LAB6:    if (t20 != 0)
        goto LAB8;

LAB7:    *((unsigned int *)t8) = 1;

LAB9:    t24 = (t8 + 4);
    t25 = *((unsigned int *)t24);
    t26 = (~(t25));
    t27 = *((unsigned int *)t8);
    t28 = (t27 & t26);
    t29 = (t28 != 0);
    if (t29 > 0)
        goto LAB10;

LAB11:    xsi_set_current_line(113, ng0);

LAB62:    xsi_set_current_line(114, ng0);
    t2 = ((char*)((ng2)));
    t3 = (t0 + 5928);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);
    xsi_set_current_line(115, ng0);
    t2 = ((char*)((ng2)));
    t3 = (t0 + 6088);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);
    xsi_set_current_line(116, ng0);
    t2 = ((char*)((ng2)));
    t3 = (t0 + 6408);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 8, 0LL);
    xsi_set_current_line(117, ng0);
    t2 = ((char*)((ng5)));
    t3 = (t0 + 6728);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 12, 0LL);

LAB12:    goto LAB2;

LAB8:    t23 = (t8 + 4);
    *((unsigned int *)t8) = 1;
    *((unsigned int *)t23) = 1;
    goto LAB9;

LAB10:    xsi_set_current_line(82, ng0);
    t30 = (t0 + 6568);
    t31 = (t30 + 56U);
    t32 = *((char **)t31);

LAB13:    t33 = ((char*)((ng4)));
    t34 = xsi_vlog_unsigned_case_compare(t32, 4, t33, 4);
    if (t34 == 1)
        goto LAB14;

LAB15:    t2 = ((char*)((ng1)));
    t34 = xsi_vlog_unsigned_case_compare(t32, 4, t2, 4);
    if (t34 == 1)
        goto LAB16;

LAB17:    t2 = ((char*)((ng6)));
    t34 = xsi_vlog_unsigned_case_compare(t32, 4, t2, 4);
    if (t34 == 1)
        goto LAB18;

LAB19:    t2 = ((char*)((ng7)));
    t34 = xsi_vlog_unsigned_case_compare(t32, 4, t2, 4);
    if (t34 == 1)
        goto LAB20;

LAB21:
LAB23:
LAB22:    xsi_set_current_line(109, ng0);

LAB61:
LAB24:    goto LAB12;

LAB14:    xsi_set_current_line(84, ng0);

LAB25:    xsi_set_current_line(85, ng0);
    t35 = ((char*)((ng2)));
    t36 = (t0 + 5928);
    xsi_vlogvar_wait_assign_value(t36, t35, 0, 0, 1, 0LL);
    xsi_set_current_line(86, ng0);
    t2 = ((char*)((ng4)));
    t3 = (t0 + 6088);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);
    goto LAB24;

LAB16:    xsi_set_current_line(89, ng0);

LAB26:    xsi_set_current_line(90, ng0);
    t3 = (t0 + 4408U);
    t4 = *((char **)t3);
    t3 = (t0 + 6728);
    xsi_vlogvar_wait_assign_value(t3, t4, 0, 0, 12, 0LL);
    xsi_set_current_line(91, ng0);
    t2 = ((char*)((ng4)));
    t3 = (t0 + 5928);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);
    xsi_set_current_line(92, ng0);
    t2 = (t0 + 4888U);
    t3 = *((char **)t2);
    t2 = (t0 + 6408);
    xsi_vlogvar_wait_assign_value(t2, t3, 0, 0, 8, 0LL);
    goto LAB24;

LAB18:    xsi_set_current_line(96, ng0);

LAB27:    goto LAB24;

LAB20:    xsi_set_current_line(101, ng0);

LAB28:    xsi_set_current_line(103, ng0);
    t3 = (t0 + 6728);
    t4 = (t3 + 56U);
    t5 = *((char **)t4);
    memset(t8, 0, 8);
    t6 = (t8 + 4);
    t7 = (t5 + 4);
    t11 = *((unsigned int *)t5);
    t12 = (t11 >> 8);
    *((unsigned int *)t8) = t12;
    t13 = *((unsigned int *)t7);
    t14 = (t13 >> 8);
    *((unsigned int *)t6) = t14;
    t15 = *((unsigned int *)t8);
    *((unsigned int *)t8) = (t15 & 15U);
    t16 = *((unsigned int *)t6);
    *((unsigned int *)t6) = (t16 & 15U);
    t9 = ((char*)((ng7)));
    memset(t37, 0, 8);
    t10 = (t8 + 4);
    t23 = (t9 + 4);
    t17 = *((unsigned int *)t8);
    t18 = *((unsigned int *)t9);
    t19 = (t17 ^ t18);
    t20 = *((unsigned int *)t10);
    t21 = *((unsigned int *)t23);
    t22 = (t20 ^ t21);
    t25 = (t19 | t22);
    t26 = *((unsigned int *)t10);
    t27 = *((unsigned int *)t23);
    t28 = (t26 | t27);
    t29 = (~(t28));
    t38 = (t25 & t29);
    if (t38 != 0)
        goto LAB32;

LAB29:    if (t28 != 0)
        goto LAB31;

LAB30:    *((unsigned int *)t37) = 1;

LAB32:    t30 = (t37 + 4);
    t39 = *((unsigned int *)t30);
    t40 = (~(t39));
    t41 = *((unsigned int *)t37);
    t42 = (t41 & t40);
    t43 = (t42 != 0);
    if (t43 > 0)
        goto LAB33;

LAB34:
LAB35:    xsi_set_current_line(105, ng0);
    t2 = (t0 + 5048U);
    t3 = *((char **)t2);
    t2 = ((char*)((ng4)));
    memset(t8, 0, 8);
    t4 = (t3 + 4);
    t5 = (t2 + 4);
    t11 = *((unsigned int *)t3);
    t12 = *((unsigned int *)t2);
    t13 = (t11 ^ t12);
    t14 = *((unsigned int *)t4);
    t15 = *((unsigned int *)t5);
    t16 = (t14 ^ t15);
    t17 = (t13 | t16);
    t18 = *((unsigned int *)t4);
    t19 = *((unsigned int *)t5);
    t20 = (t18 | t19);
    t21 = (~(t20));
    t22 = (t17 & t21);
    if (t22 != 0)
        goto LAB39;

LAB36:    if (t20 != 0)
        goto LAB38;

LAB37:    *((unsigned int *)t8) = 1;

LAB39:    memset(t37, 0, 8);
    t7 = (t8 + 4);
    t25 = *((unsigned int *)t7);
    t26 = (~(t25));
    t27 = *((unsigned int *)t8);
    t28 = (t27 & t26);
    t29 = (t28 & 1U);
    if (t29 != 0)
        goto LAB40;

LAB41:    if (*((unsigned int *)t7) != 0)
        goto LAB42;

LAB43:    t10 = (t37 + 4);
    t38 = *((unsigned int *)t37);
    t39 = *((unsigned int *)t10);
    t40 = (t38 || t39);
    if (t40 > 0)
        goto LAB44;

LAB45:    memcpy(t71, t37, 8);

LAB46:    t102 = (t71 + 4);
    t103 = *((unsigned int *)t102);
    t104 = (~(t103));
    t105 = *((unsigned int *)t71);
    t106 = (t105 & t104);
    t107 = (t106 != 0);
    if (t107 > 0)
        goto LAB58;

LAB59:
LAB60:    goto LAB24;

LAB31:    t24 = (t37 + 4);
    *((unsigned int *)t37) = 1;
    *((unsigned int *)t24) = 1;
    goto LAB32;

LAB33:    xsi_set_current_line(103, ng0);
    t31 = (t0 + 6728);
    t33 = (t31 + 56U);
    t35 = *((char **)t33);
    memset(t44, 0, 8);
    t36 = (t44 + 4);
    t45 = (t35 + 4);
    t46 = *((unsigned int *)t35);
    t47 = (t46 >> 0);
    *((unsigned int *)t44) = t47;
    t48 = *((unsigned int *)t45);
    t49 = (t48 >> 0);
    *((unsigned int *)t36) = t49;
    t50 = *((unsigned int *)t44);
    *((unsigned int *)t44) = (t50 & 255U);
    t51 = *((unsigned int *)t36);
    *((unsigned int *)t36) = (t51 & 255U);
    t52 = (t0 + 6408);
    xsi_vlogvar_wait_assign_value(t52, t44, 0, 0, 8, 0LL);
    goto LAB35;

LAB38:    t6 = (t8 + 4);
    *((unsigned int *)t8) = 1;
    *((unsigned int *)t6) = 1;
    goto LAB39;

LAB40:    *((unsigned int *)t37) = 1;
    goto LAB43;

LAB42:    t9 = (t37 + 4);
    *((unsigned int *)t37) = 1;
    *((unsigned int *)t9) = 1;
    goto LAB43;

LAB44:    t23 = (t0 + 6728);
    t24 = (t23 + 56U);
    t30 = *((char **)t24);
    memset(t44, 0, 8);
    t31 = (t44 + 4);
    t33 = (t30 + 4);
    t41 = *((unsigned int *)t30);
    t42 = (t41 >> 8);
    *((unsigned int *)t44) = t42;
    t43 = *((unsigned int *)t33);
    t46 = (t43 >> 8);
    *((unsigned int *)t31) = t46;
    t47 = *((unsigned int *)t44);
    *((unsigned int *)t44) = (t47 & 15U);
    t48 = *((unsigned int *)t31);
    *((unsigned int *)t31) = (t48 & 15U);
    t35 = ((char*)((ng8)));
    memset(t53, 0, 8);
    t36 = (t44 + 4);
    t45 = (t35 + 4);
    t49 = *((unsigned int *)t44);
    t50 = *((unsigned int *)t35);
    t51 = (t49 ^ t50);
    t54 = *((unsigned int *)t36);
    t55 = *((unsigned int *)t45);
    t56 = (t54 ^ t55);
    t57 = (t51 | t56);
    t58 = *((unsigned int *)t36);
    t59 = *((unsigned int *)t45);
    t60 = (t58 | t59);
    t61 = (~(t60));
    t62 = (t57 & t61);
    if (t62 != 0)
        goto LAB50;

LAB47:    if (t60 != 0)
        goto LAB49;

LAB48:    *((unsigned int *)t53) = 1;

LAB50:    memset(t63, 0, 8);
    t64 = (t53 + 4);
    t65 = *((unsigned int *)t64);
    t66 = (~(t65));
    t67 = *((unsigned int *)t53);
    t68 = (t67 & t66);
    t69 = (t68 & 1U);
    if (t69 != 0)
        goto LAB51;

LAB52:    if (*((unsigned int *)t64) != 0)
        goto LAB53;

LAB54:    t72 = *((unsigned int *)t37);
    t73 = *((unsigned int *)t63);
    t74 = (t72 & t73);
    *((unsigned int *)t71) = t74;
    t75 = (t37 + 4);
    t76 = (t63 + 4);
    t77 = (t71 + 4);
    t78 = *((unsigned int *)t75);
    t79 = *((unsigned int *)t76);
    t80 = (t78 | t79);
    *((unsigned int *)t77) = t80;
    t81 = *((unsigned int *)t77);
    t82 = (t81 != 0);
    if (t82 == 1)
        goto LAB55;

LAB56:
LAB57:    goto LAB46;

LAB49:    t52 = (t53 + 4);
    *((unsigned int *)t53) = 1;
    *((unsigned int *)t52) = 1;
    goto LAB50;

LAB51:    *((unsigned int *)t63) = 1;
    goto LAB54;

LAB53:    t70 = (t63 + 4);
    *((unsigned int *)t63) = 1;
    *((unsigned int *)t70) = 1;
    goto LAB54;

LAB55:    t83 = *((unsigned int *)t71);
    t84 = *((unsigned int *)t77);
    *((unsigned int *)t71) = (t83 | t84);
    t85 = (t37 + 4);
    t86 = (t63 + 4);
    t87 = *((unsigned int *)t37);
    t88 = (~(t87));
    t89 = *((unsigned int *)t85);
    t90 = (~(t89));
    t91 = *((unsigned int *)t63);
    t92 = (~(t91));
    t93 = *((unsigned int *)t86);
    t94 = (~(t93));
    t34 = (t88 & t90);
    t95 = (t92 & t94);
    t96 = (~(t34));
    t97 = (~(t95));
    t98 = *((unsigned int *)t77);
    *((unsigned int *)t77) = (t98 & t96);
    t99 = *((unsigned int *)t77);
    *((unsigned int *)t77) = (t99 & t97);
    t100 = *((unsigned int *)t71);
    *((unsigned int *)t71) = (t100 & t96);
    t101 = *((unsigned int *)t71);
    *((unsigned int *)t71) = (t101 & t97);
    goto LAB57;

LAB58:    xsi_set_current_line(105, ng0);
    t109 = (t0 + 6728);
    t110 = (t109 + 56U);
    t111 = *((char **)t110);
    memset(t108, 0, 8);
    t112 = (t108 + 4);
    t113 = (t111 + 4);
    t114 = *((unsigned int *)t111);
    t115 = (t114 >> 0);
    *((unsigned int *)t108) = t115;
    t116 = *((unsigned int *)t113);
    t117 = (t116 >> 0);
    *((unsigned int *)t112) = t117;
    t118 = *((unsigned int *)t108);
    *((unsigned int *)t108) = (t118 & 255U);
    t119 = *((unsigned int *)t112);
    *((unsigned int *)t112) = (t119 & 255U);
    t120 = (t0 + 6408);
    xsi_vlogvar_wait_assign_value(t120, t108, 0, 0, 8, 0LL);
    goto LAB60;

}

static void implSig1_execute(char *t0)
{
    char t4[8];
    char t22[8];
    char *t1;
    char *t2;
    char *t3;
    char *t5;
    unsigned int t6;
    unsigned int t7;
    unsigned int t8;
    unsigned int t9;
    unsigned int t10;
    char *t11;
    char *t12;
    char *t13;
    unsigned int t14;
    unsigned int t15;
    unsigned int t16;
    unsigned int t17;
    unsigned int t18;
    unsigned int t19;
    unsigned int t20;
    unsigned int t21;
    unsigned int t23;
    unsigned int t24;
    unsigned int t25;
    char *t26;
    char *t27;
    char *t28;
    unsigned int t29;
    unsigned int t30;
    unsigned int t31;
    unsigned int t32;
    unsigned int t33;
    unsigned int t34;
    unsigned int t35;
    char *t36;
    char *t37;
    unsigned int t38;
    unsigned int t39;
    unsigned int t40;
    unsigned int t41;
    unsigned int t42;
    unsigned int t43;
    unsigned int t44;
    unsigned int t45;
    int t46;
    int t47;
    unsigned int t48;
    unsigned int t49;
    unsigned int t50;
    unsigned int t51;
    unsigned int t52;
    unsigned int t53;
    char *t54;
    char *t55;
    char *t56;
    char *t57;
    char *t58;
    unsigned int t59;
    unsigned int t60;
    char *t61;
    unsigned int t62;
    unsigned int t63;
    char *t64;
    unsigned int t65;
    unsigned int t66;
    char *t67;

LAB0:    t1 = (t0 + 10368U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    t2 = (t0 + 3928U);
    t3 = *((char **)t2);
    t2 = (t0 + 5368U);
    t5 = *((char **)t2);
    memset(t4, 0, 8);
    t2 = (t5 + 4);
    t6 = *((unsigned int *)t2);
    t7 = (~(t6));
    t8 = *((unsigned int *)t5);
    t9 = (t8 & t7);
    t10 = (t9 & 1U);
    if (t10 != 0)
        goto LAB7;

LAB5:    if (*((unsigned int *)t2) == 0)
        goto LAB4;

LAB6:    t11 = (t4 + 4);
    *((unsigned int *)t4) = 1;
    *((unsigned int *)t11) = 1;

LAB7:    t12 = (t4 + 4);
    t13 = (t5 + 4);
    t14 = *((unsigned int *)t5);
    t15 = (~(t14));
    *((unsigned int *)t4) = t15;
    *((unsigned int *)t12) = 0;
    if (*((unsigned int *)t13) != 0)
        goto LAB9;

LAB8:    t20 = *((unsigned int *)t4);
    *((unsigned int *)t4) = (t20 & 1U);
    t21 = *((unsigned int *)t12);
    *((unsigned int *)t12) = (t21 & 1U);
    t23 = *((unsigned int *)t3);
    t24 = *((unsigned int *)t4);
    t25 = (t23 & t24);
    *((unsigned int *)t22) = t25;
    t26 = (t3 + 4);
    t27 = (t4 + 4);
    t28 = (t22 + 4);
    t29 = *((unsigned int *)t26);
    t30 = *((unsigned int *)t27);
    t31 = (t29 | t30);
    *((unsigned int *)t28) = t31;
    t32 = *((unsigned int *)t28);
    t33 = (t32 != 0);
    if (t33 == 1)
        goto LAB10;

LAB11:
LAB12:    t54 = (t0 + 11040);
    t55 = (t54 + 56U);
    t56 = *((char **)t55);
    t57 = (t56 + 56U);
    t58 = *((char **)t57);
    memset(t58, 0, 8);
    t59 = 1U;
    t60 = t59;
    t61 = (t22 + 4);
    t62 = *((unsigned int *)t22);
    t59 = (t59 & t62);
    t63 = *((unsigned int *)t61);
    t60 = (t60 & t63);
    t64 = (t58 + 4);
    t65 = *((unsigned int *)t58);
    *((unsigned int *)t58) = (t65 | t59);
    t66 = *((unsigned int *)t64);
    *((unsigned int *)t64) = (t66 | t60);
    xsi_driver_vfirst_trans(t54, 0, 0);
    t67 = (t0 + 10768);
    *((int *)t67) = 1;

LAB1:    return;
LAB4:    *((unsigned int *)t4) = 1;
    goto LAB7;

LAB9:    t16 = *((unsigned int *)t4);
    t17 = *((unsigned int *)t13);
    *((unsigned int *)t4) = (t16 | t17);
    t18 = *((unsigned int *)t12);
    t19 = *((unsigned int *)t13);
    *((unsigned int *)t12) = (t18 | t19);
    goto LAB8;

LAB10:    t34 = *((unsigned int *)t22);
    t35 = *((unsigned int *)t28);
    *((unsigned int *)t22) = (t34 | t35);
    t36 = (t3 + 4);
    t37 = (t4 + 4);
    t38 = *((unsigned int *)t3);
    t39 = (~(t38));
    t40 = *((unsigned int *)t36);
    t41 = (~(t40));
    t42 = *((unsigned int *)t4);
    t43 = (~(t42));
    t44 = *((unsigned int *)t37);
    t45 = (~(t44));
    t46 = (t39 & t41);
    t47 = (t43 & t45);
    t48 = (~(t46));
    t49 = (~(t47));
    t50 = *((unsigned int *)t28);
    *((unsigned int *)t28) = (t50 & t48);
    t51 = *((unsigned int *)t28);
    *((unsigned int *)t28) = (t51 & t49);
    t52 = *((unsigned int *)t22);
    *((unsigned int *)t22) = (t52 & t48);
    t53 = *((unsigned int *)t22);
    *((unsigned int *)t22) = (t53 & t49);
    goto LAB12;

}


extern void work_m_10106202297111879672_3823007873_init()
{
	static char *pe[] = {(void *)Cont_26_0,(void *)Cont_33_1,(void *)Cont_45_2,(void *)Initial_49_3,(void *)Initial_50_4,(void *)Initial_51_5,(void *)Initial_52_6,(void *)Initial_53_7,(void *)Initial_54_8,(void *)Always_67_9,(void *)Always_79_10,(void *)implSig1_execute};
	xsi_register_didat("work_m_10106202297111879672_3823007873", "isim/vtach_test_isim_beh.exe.sim/work/m_10106202297111879672_3823007873.didat");
	xsi_register_executes(pe);
}
