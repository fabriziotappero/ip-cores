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

#include "xsi.h"

struct XSI_INFO xsi_info;



int main(int argc, char **argv)
{
    xsi_init_design(argc, argv);
    xsi_register_info(&xsi_info);

    xsi_register_min_prec_unit(-12);
    work_m_13308596662500982257_4273933090_init();
    work_m_08320463847941471688_3487611372_init();
    work_m_12310458916443855987_1905399362_init();
    work_m_12310458916443855987_1996477019_init();
    work_m_15115720593736110529_3833561510_init();
    work_m_09111896553275442466_4226321008_init();
    work_m_17063284189440612001_1811572986_init();
    work_m_10764087207863065690_2073120511_init();


    xsi_register_tops("work_m_17063284189440612001_1811572986");
    xsi_register_tops("work_m_10764087207863065690_2073120511");


    return xsi_run_simulation(argc, argv);

}
