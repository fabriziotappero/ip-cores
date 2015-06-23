
#include "vpi_user.h"

extern void pan_register();

void (*vlog_startup_routines[])() = {
	pan_register,
	0
};

