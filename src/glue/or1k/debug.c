
#include <l4/generic/preempt.h>
#include <l4/generic/debug.h>
#include INC_SUBARCH(perfmon.h)
#include INC_GLUE(debug.h)

#if defined (CONFIG_DEBUG_PERFMON_KERNEL)

#define CYCLES_PER_COUNTER_TICKS				64
void system_measure_syscall_end(unsigned long swi_address)
{
	volatile u64 cnt = perfmon_read_cyccnt() * CYCLES_PER_COUNTER_TICKS;
	unsigned int call_offset = (swi_address & 0xFF) >> 2;

	/* Number of syscalls */
	u64 call_count =
		*(((u64 *)&system_accounting.syscalls) + call_offset);

	/* System call timing structure */
	struct syscall_timing *st =
		(struct syscall_timing *)
			&system_accounting.syscall_timings + call_offset;

	/* Set min */
	if (st->min == 0)
	       st->min = cnt;
	else if (st->min > cnt)
		st->min = cnt;

	/* Set max */
	if (st->max < cnt)
		st->max = cnt;

	st->total += cnt;

	/* Average = total timings / total calls */
	st->avg = st->total / call_count;

	/* Update total */
	system_accounting.syscall_timings.all_total += cnt;
}

#endif
