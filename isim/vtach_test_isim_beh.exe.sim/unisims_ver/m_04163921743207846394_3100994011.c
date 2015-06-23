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
static int ng0[] = {0, 0, 0, 0};
static const char *ng1 = " Warning : Input clock period of, %1.3f ns, on the %s port of instance %m exceeds allotted value of %1.3f ns at simulation time %1.3f ns.";



static void Initial_1388_0(char *t0)
{
    char *t1;
    char *t2;

LAB0:
LAB2:    t1 = ((char*)((ng0)));
    t2 = (t0 + 1720);
    xsi_vlogvar_assign_value(t2, t1, 0, 0, 64);
    t1 = ((char*)((ng0)));
    t2 = (t0 + 1880);
    xsi_vlogvar_assign_value(t2, t1, 0, 0, 64);

LAB1:    return;
}

static void Always_1393_1(char *t0)
{
    char t4[16];
    char t7[16];
    char t19[8];
    char t25[8];
    char t28[8];
    char *t1;
    char *t2;
    char *t3;
    char *t5;
    char *t6;
    char *t8;
    unsigned int t9;
    unsigned int t10;
    unsigned int t11;
    unsigned int t12;
    unsigned int t13;
    char *t14;
    char *t15;
    char *t16;
    double t17;
    double t18;
    char *t20;
    char *t21;
    char *t22;
    double t23;
    double t24;
    double t26;
    double t27;

LAB0:    t1 = (t0 + 3040U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    t2 = (t0 + 3360);
    *((int *)t2) = 1;
    t3 = (t0 + 3072);
    *((char **)t3) = t2;
    *((char **)t1) = &&LAB4;

LAB1:    return;
LAB4:
LAB5:    t5 = xsi_vlog_time(t4, 1.0000000000000000, 1.0000000000000000);
    t6 = (t0 + 1720);
    xsi_vlogvar_wait_assign_value(t6, t4, 0, 0, 64, 0LL);
    t2 = xsi_vlog_time(t4, 1.0000000000000000, 1.0000000000000000);
    t3 = (t0 + 1720);
    t5 = (t3 + 56U);
    t6 = *((char **)t5);
    xsi_vlog_unsigned_minus(t7, 64, t4, 64, t6, 64);
    t8 = (t0 + 1880);
    xsi_vlogvar_wait_assign_value(t8, t7, 0, 0, 64, 0LL);
    t2 = (t0 + 1880);
    t3 = (t2 + 56U);
    t5 = *((char **)t3);
    t6 = (t0 + 608);
    t8 = *((char **)t6);
    xsi_vlog_unsigned_greater(t4, 64, t5, 64, t8, 32);
    t6 = (t4 + 4);
    t9 = *((unsigned int *)t6);
    t10 = (~(t9));
    t11 = *((unsigned int *)t4);
    t12 = (t11 & t10);
    t13 = (t12 != 0);
    if (t13 > 0)
        goto LAB6;

LAB7:
LAB8:    goto LAB2;

LAB6:
LAB9:    t14 = (t0 + 1880);
    t15 = (t14 + 56U);
    t16 = *((char **)t15);
    t17 = xsi_vlog_convert_to_real(t16, 64, 2);
    t18 = (t17 / 1000.0000000000000);
    *((double *)t19) = t18;
    t20 = (t0 + 472);
    t21 = *((char **)t20);
    t20 = (t0 + 608);
    t22 = *((char **)t20);
    t23 = xsi_vlog_convert_to_real(t22, 32, 1);
    t24 = (t23 / 1000.0000000000000);
    *((double *)t25) = t24;
    t20 = xsi_vlog_time(t7, 1.0000000000000000, 1.0000000000000000);
    t26 = xsi_vlog_convert_to_real(t7, 64, 2);
    t27 = (t26 / 1000.0000000000000);
    *((double *)t28) = t27;
    xsi_vlogfile_write(1, 0, 0, ng1, 5, t0, (char)114, t19, 64, (char)118, t21, 40, (char)114, t25, 64, (char)114, t28, 64);
    goto LAB8;

}


extern void unisims_ver_m_04163921743207846394_3100994011_init()
{
	static char *pe[] = {(void *)Initial_1388_0,(void *)Always_1393_1};
	xsi_register_didat("unisims_ver_m_04163921743207846394_3100994011", "isim/vtach_test_isim_beh.exe.sim/unisims_ver/m_04163921743207846394_3100994011.didat");
	xsi_register_executes(pe);
}
