#ifndef __TEST0_CAP_H__
#define __TEST0_CAP_H__


#include <l4lib/lib/cap.h>
#include <l4/generic/cap-types.h>
#include <l4/api/capability.h>

int cap_request_pager(struct capability *cap);

#endif
