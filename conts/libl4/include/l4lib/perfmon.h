
#include <l4lib/macros.h>
#include L4LIB_INC_SUBARCH(perfmon.h)

#if !defined (CONFIG_DEBUG_PERFMON_USER)

/* Common empty definitions for all arches */
static inline u32 perfmon_read_cyccnt() { return 0; }

static inline void perfmon_reset_start_cyccnt() { }
static inline u32 perfmon_read_reset_start_cyccnt() { return 0; }

#endif
