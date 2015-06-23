#ifndef __PERF_TESTS_H__
#define __PERF_TESTS_H__

/* Architecture specific perfmon cycle counting */
#include <l4lib/types.h>
#include <l4lib/macros.h>
#include L4LIB_INC_SUBARCH(perfmon.h)

struct perfmon_cycles {
	u64 last;	/* Last op cycles */
	u64 min;	/* Minimum cycles */
	u64 max;	/* Max cycles */
	u64 avg;	/* Average cycles */
	u64 total;	/* Total cycles */
	u64 ops;	/* Total ops */
};

/*
 * This is for converting cycle count to timings on
 * Cortex-A9 running at 400Mhz. 25 / 100000 is
 * a rewriting of 2.5 nanosec / 1,000,000 in millisec
 *
 * 25 / 100 = 2.5nanosec * 10 / 1000 = microseconds
 */

#define CORTEXA9_400MHZ_USEC	25 / 10000
#define CORTEXA9_400MHZ_MSEC	25 / 10000000
#define USEC_MULTIPLIER		CORTEXA9_400MHZ_USEC
#define MSEC_MULTIPLIER		CORTEXA9_400MHZ_MSEC

#if !defined(CONFIG_DEBUG_PERFMON_USER)


#define perfmon_record_cycles(ptr, str)

#else /* End of CONFIG_DEBUG_PERFMON_USER */

#define perfmon_record_cycles(pcyc, str)		\
{							\
	(pcyc)->ops++;					\
	(pcyc)->last = perfmon_read_cyccnt() * 64;	\
	(pcyc)->total += (pcyc)->last;			\
	if ((pcyc)->min > (pcyc)->last)			\
		(pcyc)->min = (pcyc)->last;		\
	if ((pcyc)->max < (pcyc)->last)			\
		(pcyc)->max = (pcyc)->last;		\
}

/* Same as above but restarts counter */
#define perfmon_checkpoint_cycles(pcyc, str)		\
{							\
	(pcyc)->last = perfmon_read_cyccnt();		\
	(pcyc)->total += pcyc->last;			\
	perfmon_reset_start_cyccnt();			\
}
#endif /* End of !CONFIG_DEBUG_PERFMON_USER */

void platform_measure_cpu_cycles(void);
void perf_measure_getid_ticks(void);
void perf_measure_cpu_cycles(void);
void perf_measure_getid(void);
void perf_measure_tctrl(void);
int perf_measure_exregs(void);
void perf_measure_ipc(void);
void perf_measure_map(void);
void perf_measure_unmap(void);
void perf_measure_mutex(void);

#endif /* __PERF_TESTS_H__ */
