/*
 * Kernel Interface Page
 *
 * Copyright (C) 2007 Bahadir Balban
 */

#ifndef __KIP_H__
#define __KIP_H__

#define __YEAR__ ((((__DATE__ [7] - '0') * 10 + (__DATE__ [8] - '0')) * 10 \
			+ (__DATE__ [9] - '0')) * 10 + (__DATE__ [10] - '0'))

#define __MONTH__ (__DATE__ [2] == 'n' ? (__DATE__ [1] == 'a' ? 0 : 5) \
		: __DATE__ [2] == 'b' ? 1 \
		: __DATE__ [2] == 'r' ? (__DATE__ [0] == 'M' ? 2 : 3) \
		: __DATE__ [2] == 'y' ? 4 \
		: __DATE__ [2] == 'l' ? 6 \
		: __DATE__ [2] == 'g' ? 7 \
		: __DATE__ [2] == 'p' ? 8 \
		: __DATE__ [2] == 't' ? 9 \
		: __DATE__ [2] == 'v' ? 10 : 11)

#define __DAY__ ((__DATE__ [4] == ' ' ? 0 : __DATE__ [4] - '0') * 10 \
		+ (__DATE__ [5] - '0'))


#define CODEZERO_VERSION		0
#define CODEZERO_SUBVERSION		2
#define KDESC_DATE_SIZE			12
#define KDESC_TIME_SIZE			9

struct kernel_descriptor {
	u32 version;
	u32 subversion;
	u32 magic;
	char date[KDESC_DATE_SIZE];
	char time[KDESC_TIME_SIZE];
} __attribute__((__packed__));

/* Experimental KIP with non-standard offsets */
struct kip {
	/* System descriptions */
	u32 magic;
	u16 version_rsrv;
	u8  api_subversion;
	u8  api_version;
	u32 api_flags;

	u32 container_control;
	u32 time;

	u32 irq_control;
	u32 thread_control;
	u32 ipc_control;
	u32 map;
	u32 ipc;
	u32 capability_control;
	u32 unmap;
	u32 exchange_registers;
	u32 thread_switch;
	u32 schedule;
	u32 getid;
	u32 mutex_control;
	u32 cache_control;
	
	u32 arch_syscall0;
	u32 arch_syscall1;
	u32 arch_syscall2;

	u32 utcb;

	struct kernel_descriptor kdesc;
} __attribute__((__packed__));


#if defined (__KERNEL__)
extern struct kip kip;
#endif /* __KERNEL__ */


#endif /* __KIP_H__ */
