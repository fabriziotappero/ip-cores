
#ifndef _UTILITIES_H_
#define _UTILITIES_H_

#include <time.h>	// for timer
#include <signal.h>     // for timer

typedef struct
{
	timer_t timer;
	struct sigevent sev;
	struct itimerspec wait_time;
	struct itimerspec remaining_time;
} timeout_timer;

int create_timer(timeout_timer * timer);
int timedout(timeout_timer * timer);

int check_buffer_size(char **buf, int *buf_size_bytes, int requested_size_bytes);

#endif
