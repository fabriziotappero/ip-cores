#include "cache.h"

//-----------------------------------------------------------------
// Defines:
//-----------------------------------------------------------------
// SR Register
#define SPR_SR                  (17)
#define SPR_SR_ICACHE_FLUSH     (1 << 17)
#define SPR_SR_DCACHE_FLUSH     (1 << 18)

//-----------------------------------------------------------------
// mfspr: Read from SPR
//-----------------------------------------------------------------
static inline unsigned long mfspr(unsigned long spr) 
{    
    unsigned long value;
    asm volatile ("l.mfspr\t\t%0,%1,0" : "=r" (value) : "r" (spr));
    return value;
}
//-----------------------------------------------------------------
// mtspr: Write to SPR
//-----------------------------------------------------------------
static inline void mtspr(unsigned long spr, unsigned long value) 
{
    asm volatile ("l.mtspr\t\t%0,%1,0": : "r" (spr), "r" (value));
}
//-----------------------------------------------------------------
// cache_dflush:
//-----------------------------------------------------------------
void cache_dflush(void)
{
	unsigned long sr = mfspr(SPR_SR);    
    mtspr(SPR_SR, sr | SPR_SR_DCACHE_FLUSH);    
}
//-----------------------------------------------------------------
// cache_iflush:
//-----------------------------------------------------------------
void cache_iflush(void)
{
	unsigned long sr = mfspr(SPR_SR);    
    mtspr(SPR_SR, sr | SPR_SR_ICACHE_FLUSH);    
}
//-----------------------------------------------------------------
// cache_flush:
//-----------------------------------------------------------------
void cache_flush(void)
{
	unsigned long sr = mfspr(SPR_SR);    
    mtspr(SPR_SR, sr | SPR_SR_ICACHE_FLUSH | SPR_SR_DCACHE_FLUSH);    
}
