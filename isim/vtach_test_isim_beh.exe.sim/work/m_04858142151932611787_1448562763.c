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
static const char *ng0 = "/home/alw/projects/vtachspartan/display.v";
static int ng1[] = {0, 0};
static int ng2[] = {3, 0};
static int ng3[] = {1, 0};
static unsigned int ng4[] = {0U, 0U};
static unsigned int ng5[] = {14U, 0U};
static unsigned int ng6[] = {1U, 0U};
static unsigned int ng7[] = {13U, 0U};
static unsigned int ng8[] = {2U, 0U};
static unsigned int ng9[] = {11U, 0U};
static unsigned int ng10[] = {3U, 0U};
static unsigned int ng11[] = {7U, 0U};
static unsigned int ng12[] = {126U, 0U};
static unsigned int ng13[] = {48U, 0U};
static unsigned int ng14[] = {109U, 0U};
static unsigned int ng15[] = {121U, 0U};
static unsigned int ng16[] = {4U, 0U};
static unsigned int ng17[] = {51U, 0U};
static unsigned int ng18[] = {5U, 0U};
static unsigned int ng19[] = {91U, 0U};
static unsigned int ng20[] = {6U, 0U};
static unsigned int ng21[] = {95U, 0U};
static unsigned int ng22[] = {112U, 0U};
static unsigned int ng23[] = {8U, 0U};
static unsigned int ng24[] = {127U, 0U};
static unsigned int ng25[] = {9U, 0U};
static unsigned int ng26[] = {123U, 0U};
static unsigned int ng27[] = {10U, 0U};
static unsigned int ng28[] = {119U, 0U};
static unsigned int ng29[] = {31U, 0U};
static unsigned int ng30[] = {12U, 0U};
static unsigned int ng31[] = {78U, 0U};
static unsigned int ng32[] = {61U, 0U};
static unsigned int ng33[] = {79U, 0U};
static unsigned int ng34[] = {15U, 0U};
static unsigned int ng35[] = {71U, 0U};
static unsigned int ng36[] = {73U, 0U};



static void Always_48_0(char *t0)
{
    char t13[8];
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
    char *t28;
    char *t29;

LAB0:    t1 = (t0 + 5624U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(48, ng0);
    t2 = (t0 + 6936);
    *((int *)t2) = 1;
    t3 = (t0 + 5656);
    *((char **)t3) = t2;
    *((char **)t1) = &&LAB4;

LAB1:    return;
LAB4:    xsi_set_current_line(49, ng0);
    t4 = (t0 + 1752U);
    t5 = *((char **)t4);
    t4 = (t5 + 4);
    t6 = *((unsigned int *)t4);
    t7 = (~(t6));
    t8 = *((unsigned int *)t5);
    t9 = (t8 & t7);
    t10 = (t9 != 0);
    if (t10 > 0)
        goto LAB5;

LAB6:    xsi_set_current_line(54, ng0);
    t2 = (t0 + 4072);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    t5 = (t0 + 744);
    t11 = *((char **)t5);
    memset(t13, 0, 8);
    t5 = (t4 + 4);
    t12 = (t11 + 4);
    t6 = *((unsigned int *)t4);
    t7 = *((unsigned int *)t11);
    t8 = (t6 ^ t7);
    t9 = *((unsigned int *)t5);
    t10 = *((unsigned int *)t12);
    t14 = (t9 ^ t10);
    t15 = (t8 | t14);
    t16 = *((unsigned int *)t5);
    t17 = *((unsigned int *)t12);
    t18 = (t16 | t17);
    t19 = (~(t18));
    t20 = (t15 & t19);
    if (t20 != 0)
        goto LAB12;

LAB9:    if (t18 != 0)
        goto LAB11;

LAB10:    *((unsigned int *)t13) = 1;

LAB12:    t22 = (t13 + 4);
    t23 = *((unsigned int *)t22);
    t24 = (~(t23));
    t25 = *((unsigned int *)t13);
    t26 = (t25 & t24);
    t27 = (t26 != 0);
    if (t27 > 0)
        goto LAB13;

LAB14:    xsi_set_current_line(59, ng0);
    t2 = (t0 + 4072);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    t5 = ((char*)((ng3)));
    memset(t13, 0, 8);
    xsi_vlog_unsigned_add(t13, 32, t4, 24, t5, 32);
    t11 = (t0 + 4072);
    xsi_vlogvar_wait_assign_value(t11, t13, 0, 0, 24, 0LL);

LAB15:
LAB7:    goto LAB2;

LAB5:    xsi_set_current_line(49, ng0);

LAB8:    xsi_set_current_line(50, ng0);
    t11 = ((char*)((ng1)));
    t12 = (t0 + 4072);
    xsi_vlogvar_wait_assign_value(t12, t11, 0, 0, 24, 0LL);
    xsi_set_current_line(51, ng0);
    t2 = ((char*)((ng2)));
    t3 = (t0 + 4232);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 2, 0LL);
    goto LAB7;

LAB11:    t21 = (t13 + 4);
    *((unsigned int *)t13) = 1;
    *((unsigned int *)t21) = 1;
    goto LAB12;

LAB13:    xsi_set_current_line(54, ng0);

LAB16:    xsi_set_current_line(55, ng0);
    t28 = ((char*)((ng1)));
    t29 = (t0 + 4072);
    xsi_vlogvar_wait_assign_value(t29, t28, 0, 0, 24, 0LL);
    xsi_set_current_line(56, ng0);
    t2 = (t0 + 4232);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    t5 = ((char*)((ng3)));
    memset(t13, 0, 8);
    xsi_vlog_unsigned_minus(t13, 32, t4, 2, t5, 32);
    t11 = (t0 + 4232);
    xsi_vlogvar_wait_assign_value(t11, t13, 0, 0, 2, 0LL);
    goto LAB15;

}

static void Always_62_1(char *t0)
{
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t5;
    char *t6;
    char *t7;
    int t8;
    char *t9;
    char *t10;

LAB0:    t1 = (t0 + 5872U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(62, ng0);
    t2 = (t0 + 6952);
    *((int *)t2) = 1;
    t3 = (t0 + 5904);
    *((char **)t3) = t2;
    *((char **)t1) = &&LAB4;

LAB1:    return;
LAB4:    xsi_set_current_line(63, ng0);
    t4 = (t0 + 4232);
    t5 = (t4 + 56U);
    t6 = *((char **)t5);

LAB5:    t7 = ((char*)((ng4)));
    t8 = xsi_vlog_unsigned_case_compare(t6, 2, t7, 2);
    if (t8 == 1)
        goto LAB6;

LAB7:    t2 = ((char*)((ng6)));
    t8 = xsi_vlog_unsigned_case_compare(t6, 2, t2, 2);
    if (t8 == 1)
        goto LAB8;

LAB9:    t2 = ((char*)((ng8)));
    t8 = xsi_vlog_unsigned_case_compare(t6, 2, t2, 2);
    if (t8 == 1)
        goto LAB10;

LAB11:    t2 = ((char*)((ng10)));
    t8 = xsi_vlog_unsigned_case_compare(t6, 2, t2, 2);
    if (t8 == 1)
        goto LAB12;

LAB13:
LAB14:    goto LAB2;

LAB6:    xsi_set_current_line(64, ng0);
    t9 = ((char*)((ng5)));
    t10 = (t0 + 4552);
    xsi_vlogvar_wait_assign_value(t10, t9, 0, 0, 4, 0LL);
    goto LAB14;

LAB8:    xsi_set_current_line(65, ng0);
    t3 = ((char*)((ng7)));
    t4 = (t0 + 4552);
    xsi_vlogvar_wait_assign_value(t4, t3, 0, 0, 4, 0LL);
    goto LAB14;

LAB10:    xsi_set_current_line(66, ng0);
    t3 = ((char*)((ng9)));
    t4 = (t0 + 4552);
    xsi_vlogvar_wait_assign_value(t4, t3, 0, 0, 4, 0LL);
    goto LAB14;

LAB12:    xsi_set_current_line(67, ng0);
    t3 = ((char*)((ng11)));
    t4 = (t0 + 4552);
    xsi_vlogvar_wait_assign_value(t4, t3, 0, 0, 4, 0LL);
    goto LAB14;

}

static void Always_72_2(char *t0)
{
    char t9[8];
    char t20[8];
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t5;
    char *t6;
    char *t7;
    int t8;
    char *t10;
    char *t11;
    char *t12;
    unsigned int t13;
    unsigned int t14;
    unsigned int t15;
    unsigned int t16;
    unsigned int t17;
    unsigned int t18;
    char *t19;

LAB0:    t1 = (t0 + 6120U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(72, ng0);
    t2 = (t0 + 6968);
    *((int *)t2) = 1;
    t3 = (t0 + 6152);
    *((char **)t3) = t2;
    *((char **)t1) = &&LAB4;

LAB1:    return;
LAB4:    xsi_set_current_line(73, ng0);
    t4 = (t0 + 4232);
    t5 = (t4 + 56U);
    t6 = *((char **)t5);

LAB5:    t7 = ((char*)((ng4)));
    t8 = xsi_vlog_unsigned_case_compare(t6, 2, t7, 2);
    if (t8 == 1)
        goto LAB6;

LAB7:    t2 = ((char*)((ng6)));
    t8 = xsi_vlog_unsigned_case_compare(t6, 2, t2, 2);
    if (t8 == 1)
        goto LAB8;

LAB9:    t2 = ((char*)((ng8)));
    t8 = xsi_vlog_unsigned_case_compare(t6, 2, t2, 2);
    if (t8 == 1)
        goto LAB10;

LAB11:    t2 = ((char*)((ng10)));
    t8 = xsi_vlog_unsigned_case_compare(t6, 2, t2, 2);
    if (t8 == 1)
        goto LAB12;

LAB13:
LAB14:    goto LAB2;

LAB6:    xsi_set_current_line(74, ng0);
    t10 = (t0 + 1912U);
    t11 = *((char **)t10);
    memset(t9, 0, 8);
    t10 = (t9 + 4);
    t12 = (t11 + 4);
    t13 = *((unsigned int *)t11);
    t14 = (t13 >> 0);
    *((unsigned int *)t9) = t14;
    t15 = *((unsigned int *)t12);
    t16 = (t15 >> 0);
    *((unsigned int *)t10) = t16;
    t17 = *((unsigned int *)t9);
    *((unsigned int *)t9) = (t17 & 15U);
    t18 = *((unsigned int *)t10);
    *((unsigned int *)t10) = (t18 & 15U);
    t19 = (t0 + 4392);
    xsi_vlogvar_wait_assign_value(t19, t9, 0, 0, 4, 0LL);
    goto LAB14;

LAB8:    xsi_set_current_line(75, ng0);
    t3 = (t0 + 1912U);
    t4 = *((char **)t3);
    memset(t9, 0, 8);
    t3 = (t9 + 4);
    t5 = (t4 + 4);
    t13 = *((unsigned int *)t4);
    t14 = (t13 >> 4);
    *((unsigned int *)t9) = t14;
    t15 = *((unsigned int *)t5);
    t16 = (t15 >> 4);
    *((unsigned int *)t3) = t16;
    t17 = *((unsigned int *)t9);
    *((unsigned int *)t9) = (t17 & 15U);
    t18 = *((unsigned int *)t3);
    *((unsigned int *)t3) = (t18 & 15U);
    t7 = (t0 + 4392);
    xsi_vlogvar_wait_assign_value(t7, t9, 0, 0, 4, 0LL);
    goto LAB14;

LAB10:    xsi_set_current_line(76, ng0);
    t3 = (t0 + 1912U);
    t4 = *((char **)t3);
    memset(t9, 0, 8);
    t3 = (t9 + 4);
    t5 = (t4 + 4);
    t13 = *((unsigned int *)t4);
    t14 = (t13 >> 8);
    *((unsigned int *)t9) = t14;
    t15 = *((unsigned int *)t5);
    t16 = (t15 >> 8);
    *((unsigned int *)t3) = t16;
    t17 = *((unsigned int *)t9);
    *((unsigned int *)t9) = (t17 & 15U);
    t18 = *((unsigned int *)t3);
    *((unsigned int *)t3) = (t18 & 15U);
    t7 = (t0 + 4392);
    xsi_vlogvar_wait_assign_value(t7, t9, 0, 0, 4, 0LL);
    goto LAB14;

LAB12:    xsi_set_current_line(77, ng0);
    t3 = (t0 + 1912U);
    t4 = *((char **)t3);
    memset(t20, 0, 8);
    t3 = (t20 + 4);
    t5 = (t4 + 4);
    t13 = *((unsigned int *)t4);
    t14 = (t13 >> 12);
    t15 = (t14 & 1);
    *((unsigned int *)t20) = t15;
    t16 = *((unsigned int *)t5);
    t17 = (t16 >> 12);
    t18 = (t17 & 1);
    *((unsigned int *)t3) = t18;
    t7 = ((char*)((ng4)));
    xsi_vlogtype_concat(t9, 4, 4, 2U, t7, 3, t20, 1);
    t10 = (t0 + 4392);
    xsi_vlogvar_wait_assign_value(t10, t9, 0, 0, 4, 0LL);
    goto LAB14;

}

static void Always_81_3(char *t0)
{
    char t8[8];
    char t35[8];
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
    char *t36;
    char *t37;
    char *t38;
    unsigned int t39;
    unsigned int t40;
    unsigned int t41;
    unsigned int t42;
    unsigned int t43;
    unsigned int t44;
    unsigned int t45;
    unsigned int t46;
    char *t47;

LAB0:    t1 = (t0 + 6368U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(81, ng0);
    t2 = (t0 + 6984);
    *((int *)t2) = 1;
    t3 = (t0 + 6400);
    *((char **)t3) = t2;
    *((char **)t1) = &&LAB4;

LAB1:    return;
LAB4:    xsi_set_current_line(82, ng0);
    t4 = (t0 + 4232);
    t5 = (t4 + 56U);
    t6 = *((char **)t5);
    t7 = ((char*)((ng10)));
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
        goto LAB8;

LAB5:    if (t20 != 0)
        goto LAB7;

LAB6:    *((unsigned int *)t8) = 1;

LAB8:    t24 = (t8 + 4);
    t25 = *((unsigned int *)t24);
    t26 = (~(t25));
    t27 = *((unsigned int *)t8);
    t28 = (t27 & t26);
    t29 = (t28 != 0);
    if (t29 > 0)
        goto LAB9;

LAB10:    xsi_set_current_line(88, ng0);
    t2 = (t0 + 4392);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);

LAB22:    t5 = ((char*)((ng4)));
    t34 = xsi_vlog_unsigned_case_compare(t4, 4, t5, 4);
    if (t34 == 1)
        goto LAB23;

LAB24:    t2 = ((char*)((ng6)));
    t34 = xsi_vlog_unsigned_case_compare(t4, 4, t2, 4);
    if (t34 == 1)
        goto LAB25;

LAB26:    t2 = ((char*)((ng8)));
    t34 = xsi_vlog_unsigned_case_compare(t4, 4, t2, 4);
    if (t34 == 1)
        goto LAB27;

LAB28:    t2 = ((char*)((ng10)));
    t34 = xsi_vlog_unsigned_case_compare(t4, 4, t2, 4);
    if (t34 == 1)
        goto LAB29;

LAB30:    t2 = ((char*)((ng16)));
    t34 = xsi_vlog_unsigned_case_compare(t4, 4, t2, 4);
    if (t34 == 1)
        goto LAB31;

LAB32:    t2 = ((char*)((ng18)));
    t34 = xsi_vlog_unsigned_case_compare(t4, 4, t2, 4);
    if (t34 == 1)
        goto LAB33;

LAB34:    t2 = ((char*)((ng20)));
    t34 = xsi_vlog_unsigned_case_compare(t4, 4, t2, 4);
    if (t34 == 1)
        goto LAB35;

LAB36:    t2 = ((char*)((ng11)));
    t34 = xsi_vlog_unsigned_case_compare(t4, 4, t2, 4);
    if (t34 == 1)
        goto LAB37;

LAB38:    t2 = ((char*)((ng23)));
    t34 = xsi_vlog_unsigned_case_compare(t4, 4, t2, 4);
    if (t34 == 1)
        goto LAB39;

LAB40:    t2 = ((char*)((ng25)));
    t34 = xsi_vlog_unsigned_case_compare(t4, 4, t2, 4);
    if (t34 == 1)
        goto LAB41;

LAB42:    t2 = ((char*)((ng27)));
    t34 = xsi_vlog_unsigned_case_compare(t4, 4, t2, 4);
    if (t34 == 1)
        goto LAB43;

LAB44:    t2 = ((char*)((ng9)));
    t34 = xsi_vlog_unsigned_case_compare(t4, 4, t2, 4);
    if (t34 == 1)
        goto LAB45;

LAB46:    t2 = ((char*)((ng30)));
    t34 = xsi_vlog_unsigned_case_compare(t4, 4, t2, 4);
    if (t34 == 1)
        goto LAB47;

LAB48:    t2 = ((char*)((ng7)));
    t34 = xsi_vlog_unsigned_case_compare(t4, 4, t2, 4);
    if (t34 == 1)
        goto LAB49;

LAB50:    t2 = ((char*)((ng5)));
    t34 = xsi_vlog_unsigned_case_compare(t4, 4, t2, 4);
    if (t34 == 1)
        goto LAB51;

LAB52:    t2 = ((char*)((ng34)));
    t34 = xsi_vlog_unsigned_case_compare(t4, 4, t2, 4);
    if (t34 == 1)
        goto LAB53;

LAB54:
LAB56:
LAB55:    xsi_set_current_line(105, ng0);
    t2 = ((char*)((ng36)));
    memset(t8, 0, 8);
    t3 = (t8 + 4);
    t5 = (t2 + 4);
    t11 = *((unsigned int *)t2);
    t12 = (~(t11));
    *((unsigned int *)t8) = t12;
    *((unsigned int *)t3) = 0;
    if (*((unsigned int *)t5) != 0)
        goto LAB91;

LAB90:    t17 = *((unsigned int *)t8);
    *((unsigned int *)t8) = (t17 & 127U);
    t18 = *((unsigned int *)t3);
    *((unsigned int *)t3) = (t18 & 127U);
    t6 = (t0 + 4712);
    xsi_vlogvar_wait_assign_value(t6, t8, 0, 0, 7, 0LL);

LAB57:
LAB11:    goto LAB2;

LAB7:    t23 = (t8 + 4);
    *((unsigned int *)t8) = 1;
    *((unsigned int *)t23) = 1;
    goto LAB8;

LAB9:    xsi_set_current_line(83, ng0);
    t30 = (t0 + 4392);
    t31 = (t30 + 56U);
    t32 = *((char **)t31);

LAB12:    t33 = ((char*)((ng6)));
    t34 = xsi_vlog_unsigned_case_compare(t32, 4, t33, 4);
    if (t34 == 1)
        goto LAB13;

LAB14:
LAB16:
LAB15:    xsi_set_current_line(85, ng0);
    t2 = ((char*)((ng4)));
    memset(t8, 0, 8);
    t3 = (t8 + 4);
    t4 = (t2 + 4);
    t11 = *((unsigned int *)t2);
    t12 = (~(t11));
    *((unsigned int *)t8) = t12;
    *((unsigned int *)t3) = 0;
    if (*((unsigned int *)t4) != 0)
        goto LAB21;

LAB20:    t17 = *((unsigned int *)t8);
    *((unsigned int *)t8) = (t17 & 127U);
    t18 = *((unsigned int *)t3);
    *((unsigned int *)t3) = (t18 & 127U);
    t5 = (t0 + 4712);
    xsi_vlogvar_wait_assign_value(t5, t8, 0, 0, 7, 0LL);

LAB17:    goto LAB11;

LAB13:    xsi_set_current_line(84, ng0);
    t36 = ((char*)((ng6)));
    memset(t35, 0, 8);
    t37 = (t35 + 4);
    t38 = (t36 + 4);
    t39 = *((unsigned int *)t36);
    t40 = (~(t39));
    *((unsigned int *)t35) = t40;
    *((unsigned int *)t37) = 0;
    if (*((unsigned int *)t38) != 0)
        goto LAB19;

LAB18:    t45 = *((unsigned int *)t35);
    *((unsigned int *)t35) = (t45 & 127U);
    t46 = *((unsigned int *)t37);
    *((unsigned int *)t37) = (t46 & 127U);
    t47 = (t0 + 4712);
    xsi_vlogvar_wait_assign_value(t47, t35, 0, 0, 7, 0LL);
    goto LAB17;

LAB19:    t41 = *((unsigned int *)t35);
    t42 = *((unsigned int *)t38);
    *((unsigned int *)t35) = (t41 | t42);
    t43 = *((unsigned int *)t37);
    t44 = *((unsigned int *)t38);
    *((unsigned int *)t37) = (t43 | t44);
    goto LAB18;

LAB21:    t13 = *((unsigned int *)t8);
    t14 = *((unsigned int *)t4);
    *((unsigned int *)t8) = (t13 | t14);
    t15 = *((unsigned int *)t3);
    t16 = *((unsigned int *)t4);
    *((unsigned int *)t3) = (t15 | t16);
    goto LAB20;

LAB23:    xsi_set_current_line(89, ng0);
    t6 = ((char*)((ng12)));
    memset(t8, 0, 8);
    t7 = (t8 + 4);
    t9 = (t6 + 4);
    t11 = *((unsigned int *)t6);
    t12 = (~(t11));
    *((unsigned int *)t8) = t12;
    *((unsigned int *)t7) = 0;
    if (*((unsigned int *)t9) != 0)
        goto LAB59;

LAB58:    t17 = *((unsigned int *)t8);
    *((unsigned int *)t8) = (t17 & 127U);
    t18 = *((unsigned int *)t7);
    *((unsigned int *)t7) = (t18 & 127U);
    t10 = (t0 + 4712);
    xsi_vlogvar_wait_assign_value(t10, t8, 0, 0, 7, 0LL);
    goto LAB57;

LAB25:    xsi_set_current_line(90, ng0);
    t3 = ((char*)((ng13)));
    memset(t8, 0, 8);
    t5 = (t8 + 4);
    t6 = (t3 + 4);
    t11 = *((unsigned int *)t3);
    t12 = (~(t11));
    *((unsigned int *)t8) = t12;
    *((unsigned int *)t5) = 0;
    if (*((unsigned int *)t6) != 0)
        goto LAB61;

LAB60:    t17 = *((unsigned int *)t8);
    *((unsigned int *)t8) = (t17 & 127U);
    t18 = *((unsigned int *)t5);
    *((unsigned int *)t5) = (t18 & 127U);
    t7 = (t0 + 4712);
    xsi_vlogvar_wait_assign_value(t7, t8, 0, 0, 7, 0LL);
    goto LAB57;

LAB27:    xsi_set_current_line(91, ng0);
    t3 = ((char*)((ng14)));
    memset(t8, 0, 8);
    t5 = (t8 + 4);
    t6 = (t3 + 4);
    t11 = *((unsigned int *)t3);
    t12 = (~(t11));
    *((unsigned int *)t8) = t12;
    *((unsigned int *)t5) = 0;
    if (*((unsigned int *)t6) != 0)
        goto LAB63;

LAB62:    t17 = *((unsigned int *)t8);
    *((unsigned int *)t8) = (t17 & 127U);
    t18 = *((unsigned int *)t5);
    *((unsigned int *)t5) = (t18 & 127U);
    t7 = (t0 + 4712);
    xsi_vlogvar_wait_assign_value(t7, t8, 0, 0, 7, 0LL);
    goto LAB57;

LAB29:    xsi_set_current_line(92, ng0);
    t3 = ((char*)((ng15)));
    memset(t8, 0, 8);
    t5 = (t8 + 4);
    t6 = (t3 + 4);
    t11 = *((unsigned int *)t3);
    t12 = (~(t11));
    *((unsigned int *)t8) = t12;
    *((unsigned int *)t5) = 0;
    if (*((unsigned int *)t6) != 0)
        goto LAB65;

LAB64:    t17 = *((unsigned int *)t8);
    *((unsigned int *)t8) = (t17 & 127U);
    t18 = *((unsigned int *)t5);
    *((unsigned int *)t5) = (t18 & 127U);
    t7 = (t0 + 4712);
    xsi_vlogvar_wait_assign_value(t7, t8, 0, 0, 7, 0LL);
    goto LAB57;

LAB31:    xsi_set_current_line(93, ng0);
    t3 = ((char*)((ng17)));
    memset(t8, 0, 8);
    t5 = (t8 + 4);
    t6 = (t3 + 4);
    t11 = *((unsigned int *)t3);
    t12 = (~(t11));
    *((unsigned int *)t8) = t12;
    *((unsigned int *)t5) = 0;
    if (*((unsigned int *)t6) != 0)
        goto LAB67;

LAB66:    t17 = *((unsigned int *)t8);
    *((unsigned int *)t8) = (t17 & 127U);
    t18 = *((unsigned int *)t5);
    *((unsigned int *)t5) = (t18 & 127U);
    t7 = (t0 + 4712);
    xsi_vlogvar_wait_assign_value(t7, t8, 0, 0, 7, 0LL);
    goto LAB57;

LAB33:    xsi_set_current_line(94, ng0);
    t3 = ((char*)((ng19)));
    memset(t8, 0, 8);
    t5 = (t8 + 4);
    t6 = (t3 + 4);
    t11 = *((unsigned int *)t3);
    t12 = (~(t11));
    *((unsigned int *)t8) = t12;
    *((unsigned int *)t5) = 0;
    if (*((unsigned int *)t6) != 0)
        goto LAB69;

LAB68:    t17 = *((unsigned int *)t8);
    *((unsigned int *)t8) = (t17 & 127U);
    t18 = *((unsigned int *)t5);
    *((unsigned int *)t5) = (t18 & 127U);
    t7 = (t0 + 4712);
    xsi_vlogvar_wait_assign_value(t7, t8, 0, 0, 7, 0LL);
    goto LAB57;

LAB35:    xsi_set_current_line(95, ng0);
    t3 = ((char*)((ng21)));
    memset(t8, 0, 8);
    t5 = (t8 + 4);
    t6 = (t3 + 4);
    t11 = *((unsigned int *)t3);
    t12 = (~(t11));
    *((unsigned int *)t8) = t12;
    *((unsigned int *)t5) = 0;
    if (*((unsigned int *)t6) != 0)
        goto LAB71;

LAB70:    t17 = *((unsigned int *)t8);
    *((unsigned int *)t8) = (t17 & 127U);
    t18 = *((unsigned int *)t5);
    *((unsigned int *)t5) = (t18 & 127U);
    t7 = (t0 + 4712);
    xsi_vlogvar_wait_assign_value(t7, t8, 0, 0, 7, 0LL);
    goto LAB57;

LAB37:    xsi_set_current_line(96, ng0);
    t3 = ((char*)((ng22)));
    memset(t8, 0, 8);
    t5 = (t8 + 4);
    t6 = (t3 + 4);
    t11 = *((unsigned int *)t3);
    t12 = (~(t11));
    *((unsigned int *)t8) = t12;
    *((unsigned int *)t5) = 0;
    if (*((unsigned int *)t6) != 0)
        goto LAB73;

LAB72:    t17 = *((unsigned int *)t8);
    *((unsigned int *)t8) = (t17 & 127U);
    t18 = *((unsigned int *)t5);
    *((unsigned int *)t5) = (t18 & 127U);
    t7 = (t0 + 4712);
    xsi_vlogvar_wait_assign_value(t7, t8, 0, 0, 7, 0LL);
    goto LAB57;

LAB39:    xsi_set_current_line(97, ng0);
    t3 = ((char*)((ng24)));
    memset(t8, 0, 8);
    t5 = (t8 + 4);
    t6 = (t3 + 4);
    t11 = *((unsigned int *)t3);
    t12 = (~(t11));
    *((unsigned int *)t8) = t12;
    *((unsigned int *)t5) = 0;
    if (*((unsigned int *)t6) != 0)
        goto LAB75;

LAB74:    t17 = *((unsigned int *)t8);
    *((unsigned int *)t8) = (t17 & 127U);
    t18 = *((unsigned int *)t5);
    *((unsigned int *)t5) = (t18 & 127U);
    t7 = (t0 + 4712);
    xsi_vlogvar_wait_assign_value(t7, t8, 0, 0, 7, 0LL);
    goto LAB57;

LAB41:    xsi_set_current_line(98, ng0);
    t3 = ((char*)((ng26)));
    memset(t8, 0, 8);
    t5 = (t8 + 4);
    t6 = (t3 + 4);
    t11 = *((unsigned int *)t3);
    t12 = (~(t11));
    *((unsigned int *)t8) = t12;
    *((unsigned int *)t5) = 0;
    if (*((unsigned int *)t6) != 0)
        goto LAB77;

LAB76:    t17 = *((unsigned int *)t8);
    *((unsigned int *)t8) = (t17 & 127U);
    t18 = *((unsigned int *)t5);
    *((unsigned int *)t5) = (t18 & 127U);
    t7 = (t0 + 4712);
    xsi_vlogvar_wait_assign_value(t7, t8, 0, 0, 7, 0LL);
    goto LAB57;

LAB43:    xsi_set_current_line(99, ng0);
    t3 = ((char*)((ng28)));
    memset(t8, 0, 8);
    t5 = (t8 + 4);
    t6 = (t3 + 4);
    t11 = *((unsigned int *)t3);
    t12 = (~(t11));
    *((unsigned int *)t8) = t12;
    *((unsigned int *)t5) = 0;
    if (*((unsigned int *)t6) != 0)
        goto LAB79;

LAB78:    t17 = *((unsigned int *)t8);
    *((unsigned int *)t8) = (t17 & 127U);
    t18 = *((unsigned int *)t5);
    *((unsigned int *)t5) = (t18 & 127U);
    t7 = (t0 + 4712);
    xsi_vlogvar_wait_assign_value(t7, t8, 0, 0, 7, 0LL);
    goto LAB57;

LAB45:    xsi_set_current_line(100, ng0);
    t3 = ((char*)((ng29)));
    memset(t8, 0, 8);
    t5 = (t8 + 4);
    t6 = (t3 + 4);
    t11 = *((unsigned int *)t3);
    t12 = (~(t11));
    *((unsigned int *)t8) = t12;
    *((unsigned int *)t5) = 0;
    if (*((unsigned int *)t6) != 0)
        goto LAB81;

LAB80:    t17 = *((unsigned int *)t8);
    *((unsigned int *)t8) = (t17 & 127U);
    t18 = *((unsigned int *)t5);
    *((unsigned int *)t5) = (t18 & 127U);
    t7 = (t0 + 4712);
    xsi_vlogvar_wait_assign_value(t7, t8, 0, 0, 7, 0LL);
    goto LAB57;

LAB47:    xsi_set_current_line(101, ng0);
    t3 = ((char*)((ng31)));
    memset(t8, 0, 8);
    t5 = (t8 + 4);
    t6 = (t3 + 4);
    t11 = *((unsigned int *)t3);
    t12 = (~(t11));
    *((unsigned int *)t8) = t12;
    *((unsigned int *)t5) = 0;
    if (*((unsigned int *)t6) != 0)
        goto LAB83;

LAB82:    t17 = *((unsigned int *)t8);
    *((unsigned int *)t8) = (t17 & 127U);
    t18 = *((unsigned int *)t5);
    *((unsigned int *)t5) = (t18 & 127U);
    t7 = (t0 + 4712);
    xsi_vlogvar_wait_assign_value(t7, t8, 0, 0, 7, 0LL);
    goto LAB57;

LAB49:    xsi_set_current_line(102, ng0);
    t3 = ((char*)((ng32)));
    memset(t8, 0, 8);
    t5 = (t8 + 4);
    t6 = (t3 + 4);
    t11 = *((unsigned int *)t3);
    t12 = (~(t11));
    *((unsigned int *)t8) = t12;
    *((unsigned int *)t5) = 0;
    if (*((unsigned int *)t6) != 0)
        goto LAB85;

LAB84:    t17 = *((unsigned int *)t8);
    *((unsigned int *)t8) = (t17 & 127U);
    t18 = *((unsigned int *)t5);
    *((unsigned int *)t5) = (t18 & 127U);
    t7 = (t0 + 4712);
    xsi_vlogvar_wait_assign_value(t7, t8, 0, 0, 7, 0LL);
    goto LAB57;

LAB51:    xsi_set_current_line(103, ng0);
    t3 = ((char*)((ng33)));
    memset(t8, 0, 8);
    t5 = (t8 + 4);
    t6 = (t3 + 4);
    t11 = *((unsigned int *)t3);
    t12 = (~(t11));
    *((unsigned int *)t8) = t12;
    *((unsigned int *)t5) = 0;
    if (*((unsigned int *)t6) != 0)
        goto LAB87;

LAB86:    t17 = *((unsigned int *)t8);
    *((unsigned int *)t8) = (t17 & 127U);
    t18 = *((unsigned int *)t5);
    *((unsigned int *)t5) = (t18 & 127U);
    t7 = (t0 + 4712);
    xsi_vlogvar_wait_assign_value(t7, t8, 0, 0, 7, 0LL);
    goto LAB57;

LAB53:    xsi_set_current_line(104, ng0);
    t3 = ((char*)((ng35)));
    memset(t8, 0, 8);
    t5 = (t8 + 4);
    t6 = (t3 + 4);
    t11 = *((unsigned int *)t3);
    t12 = (~(t11));
    *((unsigned int *)t8) = t12;
    *((unsigned int *)t5) = 0;
    if (*((unsigned int *)t6) != 0)
        goto LAB89;

LAB88:    t17 = *((unsigned int *)t8);
    *((unsigned int *)t8) = (t17 & 127U);
    t18 = *((unsigned int *)t5);
    *((unsigned int *)t5) = (t18 & 127U);
    t7 = (t0 + 4712);
    xsi_vlogvar_wait_assign_value(t7, t8, 0, 0, 7, 0LL);
    goto LAB57;

LAB59:    t13 = *((unsigned int *)t8);
    t14 = *((unsigned int *)t9);
    *((unsigned int *)t8) = (t13 | t14);
    t15 = *((unsigned int *)t7);
    t16 = *((unsigned int *)t9);
    *((unsigned int *)t7) = (t15 | t16);
    goto LAB58;

LAB61:    t13 = *((unsigned int *)t8);
    t14 = *((unsigned int *)t6);
    *((unsigned int *)t8) = (t13 | t14);
    t15 = *((unsigned int *)t5);
    t16 = *((unsigned int *)t6);
    *((unsigned int *)t5) = (t15 | t16);
    goto LAB60;

LAB63:    t13 = *((unsigned int *)t8);
    t14 = *((unsigned int *)t6);
    *((unsigned int *)t8) = (t13 | t14);
    t15 = *((unsigned int *)t5);
    t16 = *((unsigned int *)t6);
    *((unsigned int *)t5) = (t15 | t16);
    goto LAB62;

LAB65:    t13 = *((unsigned int *)t8);
    t14 = *((unsigned int *)t6);
    *((unsigned int *)t8) = (t13 | t14);
    t15 = *((unsigned int *)t5);
    t16 = *((unsigned int *)t6);
    *((unsigned int *)t5) = (t15 | t16);
    goto LAB64;

LAB67:    t13 = *((unsigned int *)t8);
    t14 = *((unsigned int *)t6);
    *((unsigned int *)t8) = (t13 | t14);
    t15 = *((unsigned int *)t5);
    t16 = *((unsigned int *)t6);
    *((unsigned int *)t5) = (t15 | t16);
    goto LAB66;

LAB69:    t13 = *((unsigned int *)t8);
    t14 = *((unsigned int *)t6);
    *((unsigned int *)t8) = (t13 | t14);
    t15 = *((unsigned int *)t5);
    t16 = *((unsigned int *)t6);
    *((unsigned int *)t5) = (t15 | t16);
    goto LAB68;

LAB71:    t13 = *((unsigned int *)t8);
    t14 = *((unsigned int *)t6);
    *((unsigned int *)t8) = (t13 | t14);
    t15 = *((unsigned int *)t5);
    t16 = *((unsigned int *)t6);
    *((unsigned int *)t5) = (t15 | t16);
    goto LAB70;

LAB73:    t13 = *((unsigned int *)t8);
    t14 = *((unsigned int *)t6);
    *((unsigned int *)t8) = (t13 | t14);
    t15 = *((unsigned int *)t5);
    t16 = *((unsigned int *)t6);
    *((unsigned int *)t5) = (t15 | t16);
    goto LAB72;

LAB75:    t13 = *((unsigned int *)t8);
    t14 = *((unsigned int *)t6);
    *((unsigned int *)t8) = (t13 | t14);
    t15 = *((unsigned int *)t5);
    t16 = *((unsigned int *)t6);
    *((unsigned int *)t5) = (t15 | t16);
    goto LAB74;

LAB77:    t13 = *((unsigned int *)t8);
    t14 = *((unsigned int *)t6);
    *((unsigned int *)t8) = (t13 | t14);
    t15 = *((unsigned int *)t5);
    t16 = *((unsigned int *)t6);
    *((unsigned int *)t5) = (t15 | t16);
    goto LAB76;

LAB79:    t13 = *((unsigned int *)t8);
    t14 = *((unsigned int *)t6);
    *((unsigned int *)t8) = (t13 | t14);
    t15 = *((unsigned int *)t5);
    t16 = *((unsigned int *)t6);
    *((unsigned int *)t5) = (t15 | t16);
    goto LAB78;

LAB81:    t13 = *((unsigned int *)t8);
    t14 = *((unsigned int *)t6);
    *((unsigned int *)t8) = (t13 | t14);
    t15 = *((unsigned int *)t5);
    t16 = *((unsigned int *)t6);
    *((unsigned int *)t5) = (t15 | t16);
    goto LAB80;

LAB83:    t13 = *((unsigned int *)t8);
    t14 = *((unsigned int *)t6);
    *((unsigned int *)t8) = (t13 | t14);
    t15 = *((unsigned int *)t5);
    t16 = *((unsigned int *)t6);
    *((unsigned int *)t5) = (t15 | t16);
    goto LAB82;

LAB85:    t13 = *((unsigned int *)t8);
    t14 = *((unsigned int *)t6);
    *((unsigned int *)t8) = (t13 | t14);
    t15 = *((unsigned int *)t5);
    t16 = *((unsigned int *)t6);
    *((unsigned int *)t5) = (t15 | t16);
    goto LAB84;

LAB87:    t13 = *((unsigned int *)t8);
    t14 = *((unsigned int *)t6);
    *((unsigned int *)t8) = (t13 | t14);
    t15 = *((unsigned int *)t5);
    t16 = *((unsigned int *)t6);
    *((unsigned int *)t5) = (t15 | t16);
    goto LAB86;

LAB89:    t13 = *((unsigned int *)t8);
    t14 = *((unsigned int *)t6);
    *((unsigned int *)t8) = (t13 | t14);
    t15 = *((unsigned int *)t5);
    t16 = *((unsigned int *)t6);
    *((unsigned int *)t5) = (t15 | t16);
    goto LAB88;

LAB91:    t13 = *((unsigned int *)t8);
    t14 = *((unsigned int *)t5);
    *((unsigned int *)t8) = (t13 | t14);
    t15 = *((unsigned int *)t3);
    t16 = *((unsigned int *)t5);
    *((unsigned int *)t3) = (t15 | t16);
    goto LAB90;

}

static void Always_109_4(char *t0)
{
    char t13[8];
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
    unsigned int t14;

LAB0:    t1 = (t0 + 6616U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(109, ng0);
    t2 = (t0 + 7000);
    *((int *)t2) = 1;
    t3 = (t0 + 6648);
    *((char **)t3) = t2;
    *((char **)t1) = &&LAB4;

LAB1:    return;
LAB4:    xsi_set_current_line(110, ng0);
    t4 = (t0 + 1752U);
    t5 = *((char **)t4);
    t4 = (t5 + 4);
    t6 = *((unsigned int *)t4);
    t7 = (~(t6));
    t8 = *((unsigned int *)t5);
    t9 = (t8 & t7);
    t10 = (t9 != 0);
    if (t10 > 0)
        goto LAB5;

LAB6:    xsi_set_current_line(123, ng0);

LAB9:    xsi_set_current_line(124, ng0);
    t2 = (t0 + 4712);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    memset(t13, 0, 8);
    t5 = (t13 + 4);
    t11 = (t4 + 4);
    t6 = *((unsigned int *)t4);
    t7 = (t6 >> 6);
    t8 = (t7 & 1);
    *((unsigned int *)t13) = t8;
    t9 = *((unsigned int *)t11);
    t10 = (t9 >> 6);
    t14 = (t10 & 1);
    *((unsigned int *)t5) = t14;
    t12 = (t0 + 2312);
    xsi_vlogvar_wait_assign_value(t12, t13, 0, 0, 1, 0LL);
    xsi_set_current_line(125, ng0);
    t2 = (t0 + 4712);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    memset(t13, 0, 8);
    t5 = (t13 + 4);
    t11 = (t4 + 4);
    t6 = *((unsigned int *)t4);
    t7 = (t6 >> 5);
    t8 = (t7 & 1);
    *((unsigned int *)t13) = t8;
    t9 = *((unsigned int *)t11);
    t10 = (t9 >> 5);
    t14 = (t10 & 1);
    *((unsigned int *)t5) = t14;
    t12 = (t0 + 2472);
    xsi_vlogvar_wait_assign_value(t12, t13, 0, 0, 1, 0LL);
    xsi_set_current_line(126, ng0);
    t2 = (t0 + 4712);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    memset(t13, 0, 8);
    t5 = (t13 + 4);
    t11 = (t4 + 4);
    t6 = *((unsigned int *)t4);
    t7 = (t6 >> 4);
    t8 = (t7 & 1);
    *((unsigned int *)t13) = t8;
    t9 = *((unsigned int *)t11);
    t10 = (t9 >> 4);
    t14 = (t10 & 1);
    *((unsigned int *)t5) = t14;
    t12 = (t0 + 2632);
    xsi_vlogvar_wait_assign_value(t12, t13, 0, 0, 1, 0LL);
    xsi_set_current_line(127, ng0);
    t2 = (t0 + 4712);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    memset(t13, 0, 8);
    t5 = (t13 + 4);
    t11 = (t4 + 4);
    t6 = *((unsigned int *)t4);
    t7 = (t6 >> 3);
    t8 = (t7 & 1);
    *((unsigned int *)t13) = t8;
    t9 = *((unsigned int *)t11);
    t10 = (t9 >> 3);
    t14 = (t10 & 1);
    *((unsigned int *)t5) = t14;
    t12 = (t0 + 2792);
    xsi_vlogvar_wait_assign_value(t12, t13, 0, 0, 1, 0LL);
    xsi_set_current_line(128, ng0);
    t2 = (t0 + 4712);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    memset(t13, 0, 8);
    t5 = (t13 + 4);
    t11 = (t4 + 4);
    t6 = *((unsigned int *)t4);
    t7 = (t6 >> 2);
    t8 = (t7 & 1);
    *((unsigned int *)t13) = t8;
    t9 = *((unsigned int *)t11);
    t10 = (t9 >> 2);
    t14 = (t10 & 1);
    *((unsigned int *)t5) = t14;
    t12 = (t0 + 2952);
    xsi_vlogvar_wait_assign_value(t12, t13, 0, 0, 1, 0LL);
    xsi_set_current_line(129, ng0);
    t2 = (t0 + 4712);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    memset(t13, 0, 8);
    t5 = (t13 + 4);
    t11 = (t4 + 4);
    t6 = *((unsigned int *)t4);
    t7 = (t6 >> 1);
    t8 = (t7 & 1);
    *((unsigned int *)t13) = t8;
    t9 = *((unsigned int *)t11);
    t10 = (t9 >> 1);
    t14 = (t10 & 1);
    *((unsigned int *)t5) = t14;
    t12 = (t0 + 3112);
    xsi_vlogvar_wait_assign_value(t12, t13, 0, 0, 1, 0LL);
    xsi_set_current_line(130, ng0);
    t2 = (t0 + 4712);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    memset(t13, 0, 8);
    t5 = (t13 + 4);
    t11 = (t4 + 4);
    t6 = *((unsigned int *)t4);
    t7 = (t6 >> 0);
    t8 = (t7 & 1);
    *((unsigned int *)t13) = t8;
    t9 = *((unsigned int *)t11);
    t10 = (t9 >> 0);
    t14 = (t10 & 1);
    *((unsigned int *)t5) = t14;
    t12 = (t0 + 3272);
    xsi_vlogvar_wait_assign_value(t12, t13, 0, 0, 1, 0LL);
    xsi_set_current_line(131, ng0);
    t2 = (t0 + 4552);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    memset(t13, 0, 8);
    t5 = (t13 + 4);
    t11 = (t4 + 4);
    t6 = *((unsigned int *)t4);
    t7 = (t6 >> 0);
    t8 = (t7 & 1);
    *((unsigned int *)t13) = t8;
    t9 = *((unsigned int *)t11);
    t10 = (t9 >> 0);
    t14 = (t10 & 1);
    *((unsigned int *)t5) = t14;
    t12 = (t0 + 3432);
    xsi_vlogvar_wait_assign_value(t12, t13, 0, 0, 1, 0LL);
    xsi_set_current_line(132, ng0);
    t2 = (t0 + 4552);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    memset(t13, 0, 8);
    t5 = (t13 + 4);
    t11 = (t4 + 4);
    t6 = *((unsigned int *)t4);
    t7 = (t6 >> 1);
    t8 = (t7 & 1);
    *((unsigned int *)t13) = t8;
    t9 = *((unsigned int *)t11);
    t10 = (t9 >> 1);
    t14 = (t10 & 1);
    *((unsigned int *)t5) = t14;
    t12 = (t0 + 3592);
    xsi_vlogvar_wait_assign_value(t12, t13, 0, 0, 1, 0LL);
    xsi_set_current_line(133, ng0);
    t2 = (t0 + 4552);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    memset(t13, 0, 8);
    t5 = (t13 + 4);
    t11 = (t4 + 4);
    t6 = *((unsigned int *)t4);
    t7 = (t6 >> 2);
    t8 = (t7 & 1);
    *((unsigned int *)t13) = t8;
    t9 = *((unsigned int *)t11);
    t10 = (t9 >> 2);
    t14 = (t10 & 1);
    *((unsigned int *)t5) = t14;
    t12 = (t0 + 3752);
    xsi_vlogvar_wait_assign_value(t12, t13, 0, 0, 1, 0LL);
    xsi_set_current_line(134, ng0);
    t2 = (t0 + 4552);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    memset(t13, 0, 8);
    t5 = (t13 + 4);
    t11 = (t4 + 4);
    t6 = *((unsigned int *)t4);
    t7 = (t6 >> 3);
    t8 = (t7 & 1);
    *((unsigned int *)t13) = t8;
    t9 = *((unsigned int *)t11);
    t10 = (t9 >> 3);
    t14 = (t10 & 1);
    *((unsigned int *)t5) = t14;
    t12 = (t0 + 3912);
    xsi_vlogvar_wait_assign_value(t12, t13, 0, 0, 1, 0LL);

LAB7:    goto LAB2;

LAB5:    xsi_set_current_line(110, ng0);

LAB8:    xsi_set_current_line(111, ng0);
    t11 = ((char*)((ng1)));
    t12 = (t0 + 2312);
    xsi_vlogvar_wait_assign_value(t12, t11, 0, 0, 1, 0LL);
    xsi_set_current_line(112, ng0);
    t2 = ((char*)((ng1)));
    t3 = (t0 + 2472);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);
    xsi_set_current_line(113, ng0);
    t2 = ((char*)((ng1)));
    t3 = (t0 + 2632);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);
    xsi_set_current_line(114, ng0);
    t2 = ((char*)((ng1)));
    t3 = (t0 + 2792);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);
    xsi_set_current_line(115, ng0);
    t2 = ((char*)((ng1)));
    t3 = (t0 + 2952);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);
    xsi_set_current_line(116, ng0);
    t2 = ((char*)((ng1)));
    t3 = (t0 + 3112);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);
    xsi_set_current_line(117, ng0);
    t2 = ((char*)((ng1)));
    t3 = (t0 + 3272);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);
    xsi_set_current_line(118, ng0);
    t2 = ((char*)((ng6)));
    t3 = (t0 + 3432);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);
    xsi_set_current_line(119, ng0);
    t2 = ((char*)((ng6)));
    t3 = (t0 + 3592);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);
    xsi_set_current_line(120, ng0);
    t2 = ((char*)((ng6)));
    t3 = (t0 + 3752);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);
    xsi_set_current_line(121, ng0);
    t2 = ((char*)((ng6)));
    t3 = (t0 + 3912);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);
    goto LAB7;

}


extern void work_m_04858142151932611787_1448562763_init()
{
	static char *pe[] = {(void *)Always_48_0,(void *)Always_62_1,(void *)Always_72_2,(void *)Always_81_3,(void *)Always_109_4};
	xsi_register_didat("work_m_04858142151932611787_1448562763", "isim/vtach_test_isim_beh.exe.sim/work/m_04858142151932611787_1448562763.didat");
	xsi_register_executes(pe);
}
