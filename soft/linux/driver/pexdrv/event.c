/***************************************************************************
 *            Event.c
 *
 *  Mon Apr 24 11:37:38 2006
 *  Copyright  2006  User
 *  Email
 ****************************************************************************/
////////////////////////////////////////////////////////////////////////////////
#include <linux/kernel.h>
#define __NO_VERSION__
#include <linux/module.h>
#include <linux/types.h>
//#include <linux/jiffies.h>
#include <linux/delay.h>
#include <linux/pci.h>
#include <linux/interrupt.h>
#include <linux/bitops.h>
#include <linux/wait.h>
#include <linux/sched.h>
////////////////////////////////////////////////////////////////////////////////
#ifndef _EVENT_H_
        #include "event.h"
#endif
////////////////////////////////////////////////////////////////////////////////
//
KEVENT *CreateKevent ( void )
{
    return NULL;
}
////////////////////////////////////////////////////////////////////////////////
//
int InitKevent ( KEVENT * event )
{
    init_waitqueue_head ( &event->m_wq );
    atomic_set ( &event->m_flag, 0 );
    event->m_async = NULL;

    return 0;
}
////////////////////////////////////////////////////////////////////////////////
//
int ResetEvent ( KEVENT * event )
{
    //printk("<0>%s() %p\n", __FUNCTION__, event);
    atomic_set ( &event->m_flag, 0 );
    return 0;
}
////////////////////////////////////////////////////////////////////////////////
//
int SetEvent ( KEVENT * event )
{
    atomic_set ( &event->m_flag, 1 );   //for kernel space...

    wake_up_interruptible( &event->m_wq );

    //printk("<0>%s(): %p\n", __FUNCTION__, event);

    //if (event->m_async)
    //  kill_fasync(&event->m_async, SIGIO, POLL_IN|POLL_OUT);

    return 0;
}
////////////////////////////////////////////////////////////////////////////////
//
int CheckEventFlag ( KEVENT * event )
{
    //printk("<0>%s(): %p\n", __FUNCTION__, event);

    if ( atomic_read ( &event->m_flag ) )
    {
        //ResetEvent ( event );
        return 1;
    }
    return 0;
}

////////////////////////////////////////////////////////////////////////////////

#define ms_to_jiffies( ms ) (HZ*ms/1000)
#define jiffies_to_ms( jf ) (jf*1000/HZ)

////////////////////////////////////////////////////////////////////////////////
//
int WaitEvent( KEVENT * event, u32 timeout )
{
    int status = -1;

    //printk("<0>%s()\n", __FUNCTION__);

#ifdef DZYTOOLS_2_4_X
    status = interruptible_sleep_on_timeout( &event->m_wq, ms_to_jiffies(timeout) );
#else
    status = wait_event_interruptible_timeout( event->m_wq, atomic_read(&event->m_flag), ms_to_jiffies(timeout) );
#endif

    if(!status) {
        printk("<0>%s(): TIMEOUT\n", __FUNCTION__);
        return -ETIMEDOUT;
    }

    atomic_set ( &event->m_flag, 0 );

    return 0;
}

////////////////////////////////////////////////////////////////////////////////
//
int GrabEvent( KEVENT * event, u32 timeout )
{
    //printk ( "<0>%s(): E %p, T %d\n", __FUNCTION__, event, timeout );

    if( CheckEventFlag( event ) ) {
    	ResetEvent(event);
    	return 0;
    }

    return WaitEvent(event, timeout);
}
