
#ifndef __TICK_H
#define __TICK_H

#define TICK_MAX_HANDLERS 5

//#define TICK_CLK20M
//#define TICK_CLK22_5M
#define TICK_CLK25M
//#define TICK_CLK30M
//#define TICK_CLK35M
//#define TICK_CLK40M
//#define TICK_CLK45M

#ifdef TICK_CLK20M
//
// @20MHz T = 50ns
//
// 100ms	2,000,000
//#define TICK_EXPIRE_COUNT 0x001e8480-0x1
// 10ms		  200,000
//#define TICK_EXPIRE_COUNT 0x00030d40-0x1
//  1ms		   20,000
#define TICK_EXPIRE_COUNT 0x00004e20-0x1
#endif

#ifdef TICK_CLK22_5M
//
// @22.5MHz T = 44.44..ns
//
// 100ms	2,250,000
//#define TICK_EXPIRE_COUNT 0x00225510-0x1
//  10ms	  225,000
//#define TICK_EXPIRE_COUNT 0x00036EE8-0x1
//   1ms	   22,500
#define TICK_EXPIRE_COUNT 0x000057e4-0x1
#endif

#ifdef TICK_CLK25M
//
// @25MHz T = 40ns
//
// 100ms	2,500,000
//#define TICK_EXPIRE_COUNT 0x002625a0-0x1
//  10ms	  250,000
//#define TICK_EXPIRE_COUNT 0x0003d090-0x1
//   1ms	   25,000
#define TICK_EXPIRE_COUNT 0x000061a8-0x1
#endif

#ifdef TICK_CLK30M
// @30MHz T = 33.33..ns
// 99.99..ms	3,000,000
//#define TICK_EXPIRE_COUNT 0x002dc6c0-0x1
//  9.99..ms      300,000
//#define TICK_EXPIRE_COUNT 0x000493e0-0x1
//  0.99..ms	   30,000
#define TICK_EXPIRE_COUNT 0x00007530-0x1
#endif

#ifdef TICK_CLK35M
// @40MHz T = 28.5714285714..ns
// 100ms	3,500,000
//#define TICK_EXPIRE_COUNT 0x003567e0-0x1
// 10ms		  350,000
//#define TICK_EXPIRE_COUNT 0x00055730-0x1
//  1ms		   35,000
#define TICK_EXPIRE_COUNT 0x000088b8-0x1
#endif

#ifdef TICK_CLK40M
// @40MHz T = 25ns
// 100ms	4,000,000
//#define TICK_EXPIRE_COUNT 0x003d0900-0x1
// 10ms		  400,000
//#define TICK_EXPIRE_COUNT 0x00061a80-0x1
//  1ms		   40,000
#define TICK_EXPIRE_COUNT 0x00009c40-0x1
#endif

#ifdef TICK_CLK45M
// @45MHz T = 22.22..ns
// 100ms	4,500,000
//#define TICK_EXPIRE_COUNT 0x0044aa20-0x1
//  10ms	  450,000
//#define TICK_EXPIRE_COUNT 0x0006ddd0-0x1
//   1ms	   45,000
#define TICK_EXPIRE_COUNT 0x0000afc8-0x1
#endif

struct tick {
	void 	(*handler)(void *);
	void	*arg;
} typedef TICK;

/* timer handler */
int				tick_init(void)								__attribute__ ((section(".text")));
int				tick_add(unsigned long int num,void (* handler)(void *),void *argv)	__attribute__ ((section(".text")));
int				tick_disable(void)							__attribute__ ((section(".icm")));
int				tick_enable(void)							__attribute__ ((section(".icm")));
void				tick_main(void)								__attribute__ ((section(".icm")));

#endif

