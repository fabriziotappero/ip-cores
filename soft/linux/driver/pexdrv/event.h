/***************************************************************************
 *            Event.h
 *
 *  Mon Apr 24 11:38:25 2006
 *  Copyright  2006  User
 *  Email karakozov@gmail.com
 ****************************************************************************/

#ifndef _EVENT_H_
#define _EVENT_H_


#define EVENT_MAGIC 0x89ABCDEF

//Need init wq, event and flag befor used

typedef struct _KEVENT {
	wait_queue_head_t	m_wq;
	struct fasync_struct 	*m_async; 	//for user space
	atomic_t		m_flag;  	//for kernel space
} KEVENT, *PKEVENT;

////////////////////////////////////////////////////////////////////////////////

int InitKevent( KEVENT *event );
int ResetEvent( KEVENT *event );
int SetEvent( KEVENT *event );
int CheckEventFlag( KEVENT *event );
int WaitEvent( KEVENT *event, u32 timeout );
int GrabEvent ( KEVENT * event, u32 timeout );

////////////////////////////////////////////////////////////////////////////////

#endif
