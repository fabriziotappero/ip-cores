
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "utilities.h"
#include "errcodes.h"


int check_buffer_size(char **buf, int *buf_size_bytes, int requested_size_bytes)
{
  int ret = APP_ERR_NONE;

  if(*buf_size_bytes >= requested_size_bytes)
    {
      return APP_ERR_NONE;
    }

  free(*buf);
  *buf = (char *) malloc(requested_size_bytes);
  if(*buf != NULL) {
    *buf_size_bytes = requested_size_bytes;
  }
  else {
    *buf_size_bytes = 0;
    ret = APP_ERR_MALLOC;
  }

  return ret;
}


int create_timer(timeout_timer * timer)
{
	int r;
	//first timer alarm
	timer->wait_time.it_value.tv_sec = 1;
	timer->wait_time.it_value.tv_nsec = 0;
	//continuous timer alarm -> 0 (we only want one alarm)
	timer->wait_time.it_interval.tv_sec = 0;
	timer->wait_time.it_interval.tv_nsec = 0;

	timer->sev.sigev_notify = SIGEV_NONE;

	r = timer_create(CLOCK_REALTIME, &timer->sev, &timer->timer);
	if ( r )
	{
		fprintf(stderr, "Timer for timeout failed: %s\n", strerror(r));
		return APP_ERR_USB;
	}

	//remaining timer time
	timer->remaining_time = timer->wait_time;
	r = timer_settime(timer->timer, 0, &timer->wait_time, NULL);
	if ( r )
	{
		fprintf(stderr, "Setting timer failed: %s\n", strerror(r));
		return APP_ERR_USB;
	}
	return APP_ERR_NONE;
}

int timedout(timeout_timer * timer)
{
	int timed_out = 0;
	timer_gettime(timer->timer, &timer->remaining_time);
	timed_out = timer->remaining_time.it_value.tv_sec == 0 && timer->remaining_time.it_value.tv_nsec == 0;
	return timed_out;
}
