#ifndef __API_THREAD_H__
#define __API_THREAD_H__

#define THREAD_ACTION_MASK	0xF0000000
#define THREAD_CREATE		0x00000000
#define THREAD_RUN		0x10000000
#define THREAD_SUSPEND		0x20000000
#define THREAD_DESTROY		0x30000000
#define THREAD_RECYCLE		0x40000000
#define THREAD_WAIT		0x50000000

#define THREAD_SHARE_MASK	0x00F00000
#define THREAD_SPACE_MASK	0x0F000000
#define THREAD_CREATE_MASK	(THREAD_SHARE_MASK | THREAD_SPACE_MASK)
#define TC_SHARE_CAPS		0x00100000 /* Share all thread capabilities */
#define TC_SHARE_UTCB		0x00200000 /* Share utcb location (same space */
#define TC_SHARE_GROUP		0x00400000 /* Share thread group id */

#define TC_SHARE_SPACE		0x01000000 /* New thread, use given space */
#define TC_COPY_SPACE		0x02000000 /* New thread, copy given space */
#define TC_NEW_SPACE		0x04000000 /* New thread, new space */

/* #define THREAD_USER_MASK	0x000F0000 Reserved for userspace */
#define THREAD_EXIT_MASK	0x0000FFFF /* Thread exit code */
#endif /* __API_THREAD_H__ */
