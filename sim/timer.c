/*
 * timer.c -- timer simulation
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <setjmp.h>

#include "common.h"
#include "console.h"
#include "error.h"
#include "except.h"
#include "cpu.h"
#include "timer.h"


#define TIME_WRAP	1000000		/* avoid overflow of current time */


/*
 * data structure for simulation timer
 */
typedef struct timer {
  struct timer *next;
  int alarm;
  void (*callback)(int param);
  int param;
} Timer;


/*
 * data structure for timer/counter device
 */
typedef struct {
  Word ctrl;
  Word divisor;
  Word counter;
  int irq;
} TimerCounter;


static Bool debug = false;

static Timer *activeTimers = NULL;
static Timer *freeTimers = NULL;
static int currentTime = 0;		/* measured in clock cycles */

static TimerCounter timerCounters[NUMBER_TMRCNT];


Word timerRead(Word addr) {
  int dev, reg;
  Word data;

  if (debug) {
    cPrintf("\n**** TIMER READ from 0x%08X", addr);
  }
  dev = addr >> 12;
  if (dev >= NUMBER_TMRCNT) {
    /* illegal device */
    throwException(EXC_BUS_TIMEOUT);
  }
  reg = addr & 0x0FFF;
  if (reg == TIMER_CTRL) {
    data = timerCounters[dev].ctrl;
  } else
  if (reg == TIMER_DIVISOR) {
    data = timerCounters[dev].divisor;
  } else
  if (reg == TIMER_COUNTER) {
    data = timerCounters[dev].counter;
  } else {
    /* illegal register */
    throwException(EXC_BUS_TIMEOUT);
  }
  if (debug) {
    cPrintf(", data = 0x%08X ****\n", data);
  }
  return data;
}


void timerWrite(Word addr, Word data) {
  int dev, reg;

  if (debug) {
    cPrintf("\n**** TIMER WRITE to 0x%08X, data = 0x%08X ****\n",
            addr, data);
  }
  dev = addr >> 12;
  if (dev >= NUMBER_TMRCNT) {
    /* illegal device */
    throwException(EXC_BUS_TIMEOUT);
  }
  reg = addr & 0x0FFF;
  if (reg == TIMER_CTRL) {
    if (data & TIMER_IEN) {
      timerCounters[dev].ctrl |= TIMER_IEN;
    } else {
      timerCounters[dev].ctrl &= ~TIMER_IEN;
    }
    if (data & TIMER_EXP) {
      timerCounters[dev].ctrl |= TIMER_EXP;
    } else {
      timerCounters[dev].ctrl &= ~TIMER_EXP;
    }
    if ((timerCounters[dev].ctrl & TIMER_IEN) != 0 &&
        (timerCounters[dev].ctrl & TIMER_EXP) != 0) {
      /* raise timer interrupt */
      cpuSetInterrupt(timerCounters[dev].irq);
    } else {
      /* lower timer interrupt */
      cpuResetInterrupt(timerCounters[dev].irq);
    }
  } else
  if (reg == TIMER_DIVISOR) {
    timerCounters[dev].divisor = data;
    timerCounters[dev].counter = data;
  } else {
    /* illegal register */
    throwException(EXC_BUS_TIMEOUT);
  }
}


void timerTick(void) {
  Timer *timer;
  void (*callback)(int param);
  int param;
  int i;

  /* increment current time */
  currentTime += CC_PER_INSTR;
  /* avoid overflow */
  if (currentTime >= TIME_WRAP) {
    currentTime -= TIME_WRAP;
    timer = activeTimers;
    while (timer != NULL) {
      timer->alarm -= TIME_WRAP;
      timer = timer->next;
    }
  }
  /* check whether any simulation timer expired */
  while (activeTimers != NULL &&
         currentTime >= activeTimers->alarm) {
    timer = activeTimers;
    activeTimers = timer->next;
    callback = timer->callback;
    param = timer->param;
    timer->next = freeTimers;
    freeTimers = timer;
    (*callback)(param);
  }
  /* decrement counters and check if an interrupt must be raised */
  for (i = 0; i < NUMBER_TMRCNT; i++) {
    if (timerCounters[i].counter <= CC_PER_INSTR) {
      timerCounters[i].counter += timerCounters[i].divisor - CC_PER_INSTR;
      timerCounters[i].ctrl |= TIMER_EXP;
      if (timerCounters[i].ctrl & TIMER_IEN) {
        /* raise timer interrupt */
        cpuSetInterrupt(timerCounters[i].irq);
      }
    } else {
      timerCounters[i].counter -= CC_PER_INSTR;
    }
  }
}


void timerStart(int usec, void (*callback)(int param), int param) {
  Timer *timer;
  Timer *p;

  if (freeTimers == NULL) {
    error("out of timers");
  }
  timer = freeTimers;
  freeTimers = timer->next;
  timer->alarm = currentTime + usec * CC_PER_USEC;
  timer->callback = callback;
  timer->param = param;
  if (activeTimers == NULL ||
      timer->alarm < activeTimers->alarm) {
    /* link into front of active timers queue */
    timer->next = activeTimers;
    activeTimers = timer;
  } else {
    /* link elsewhere into active timers queue */
    p = activeTimers;
    while (p->next != NULL &&
           p->next->alarm <= timer->alarm) {
      p = p->next;
    }
    timer->next = p->next;
    p->next = timer;
  }
}


void timerReset(void) {
  Timer *timer;
  int i;

  cPrintf("Resetting Timer...\n");
  while (activeTimers != NULL) {
    timer = activeTimers;
    activeTimers = timer->next;
    timer->next = freeTimers;
    freeTimers = timer;
  }
  for (i = 0; i < NUMBER_TMRCNT; i++) {
    timerCounters[i].ctrl = 0x00000000;
    timerCounters[i].divisor = 0xFFFFFFFF;
    timerCounters[i].counter = 0xFFFFFFFF;
    timerCounters[i].irq = IRQ_TIMER_0 + i;
  }
}


void timerInit(void) {
  Timer *timer;
  int i;

  for (i = 0; i < NUMBER_TIMERS; i++) {
    timer = malloc(sizeof(Timer));
    if (timer == NULL) {
      error("cannot allocate simulation timers");
    }
    timer->next = freeTimers;
    freeTimers = timer;
  }
  timerReset();
}


void timerExit(void) {
  Timer *timer;

  while (activeTimers != NULL) {
    timer = activeTimers;
    activeTimers = timer->next;
    timer->next = freeTimers;
    freeTimers = timer;
  }
  while (freeTimers != NULL) {
    timer = freeTimers;
    freeTimers = timer->next;
    free(timer);
  }
}
