/*
 * libieee1284 - IEEE 1284 library
 * Copyright (C) 2001  Tim Waugh <twaugh@redhat.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#ifndef _MSC_VER
#include <sys/time.h>
#endif
#ifdef __unix__
#include <unistd.h>
#endif
#if defined __MINGW32__ || defined _MSC_VER
#include <sys/timeb.h>
#endif

#include "delay.h"

void udelay(unsigned long usec)
{
#if !(defined __MINGW32__ || defined _MSC_VER)
	struct timeval now, deadline;
	
	gettimeofday(&deadline, NULL);
	deadline.tv_usec += usec;
	deadline.tv_sec += deadline.tv_usec / 1000000;
	deadline.tv_usec %= 1000000;
	
	do {
		gettimeofday(&now, NULL);
	} while ((now.tv_sec < deadline.tv_sec) || 
		(now.tv_sec == deadline.tv_sec &&
		now.tv_usec < deadline.tv_usec));
#else
	/* MinGW has no gettimeofday(). ftime() seems to be the best alternative as I
	 * don't know of any standard Windows function with microsecond accuracy. I
	 * should have a look at the Cygwin source code... - dbjh */
	struct timeb tb;
	long int now, deadline;
	
	ftime(&tb);
	deadline = tb.time * 1000 + tb.millitm + usec / 1000;

	do {
		ftime(&tb);
		now = tb.time * 1000 + tb.millitm;
	} while (now < deadline);
#endif
}

