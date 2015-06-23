
#ifndef _CABLE_SIM_H_
#define _CABLE_SIM_H_

#include <stdint.h>
#include "cable_common.h"

jtag_cable_t *cable_rtl_get_driver(void);
int cable_rtl_sim_init();
int cable_rtl_sim_out(uint8_t value);
int cable_rtl_sim_inout(uint8_t value, uint8_t *inval);
void cable_rtl_sim_wait();
int cable_rtl_sim_opt(int c, char *str);

jtag_cable_t *cable_vpi_get_driver(void);
int cable_vpi_init();
int cable_vpi_out(uint8_t value);
int cable_vpi_inout(uint8_t value, uint8_t *inval);
void cable_vpi_wait();
int cable_vpi_opt(int c, char *str);


#endif
