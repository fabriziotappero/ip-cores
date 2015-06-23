#include "testmod.h"
#ifdef LEON2
#include "leon2.h"
#endif

struct divcase {
	int	num;
	int	denom;
	int	res;
};

volatile struct divcase diva[] = {
	{  2,  3, 0}, { 3, -2, -1}, {  2, -3, 0}, {  0,  1, 0}, {  0, -1, 0}, {  1, -1, -1},
	{ -1,  1, -1}, { -2,  3, 0}, { -2, -3, 0}, {9, 7, 1}, 
	{ -9, 2, -4}, {-8, 2, -4}, {-8, -4, 2}, {8, -4, -2}, {-8, -8 , 1},
	{-8, -9, 0}, {11, 2, 5}, {47, 2, 23}, 
	{ 12345,  679, 12345/679}, { -63636,  77, -63636/77},
	{ 12345,  -679, -12345/679}, { -63636,  -77, 63636/77},
	{ 145,  -6079, 0}, { -636,  -77777, 0}, { 63226,  7227777, 0},
	{  0,  0, 0}
 };

struct udivcase {
	unsigned int	num;
	unsigned int	denom;
	unsigned int	res;
};

volatile struct udivcase udiva[] = {
	{  2,  3, 0}, {  0,  1, 0}, { 0xfffffffe,  3, 0xfffffffe/3},
	{ 0xfffffffe,  3, 0xfffffffe/3}, { 0x700ffffe,  7, 0x700ffffe/7},
	{  0,  0, 0}
 };

divtest()
{
#ifdef LEON2
	struct l2regs *lr = (struct l2regs *) 0x80000000;
#endif
	int i = 0;

	/* skip test if divider disabled */
#ifdef LEON2
	if (!((lr->leonconf >> DIV_CONF_BIT) & 1)) return(0);
#else
	if (!((get_asr17() >> 8) & 1)) return(0);	
#endif
	
	report_subtest(DIV_TEST+(get_pid()<<4));
	while (diva[i].denom != 0) {
	    if ((diva[i].num / diva[i].denom) != diva[i].res) fail(1);
	    i++;
	}
	i = 0;
	while (udiva[i].denom != 0) {
	    if ((udiva[i].num / udiva[i].denom) != udiva[i].res) fail(2);
	    i++;
	}
	return(0);
}
